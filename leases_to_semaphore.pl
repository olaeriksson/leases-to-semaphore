use strict;
use warnings;

use Socket;
use Net::ISC::DHCPd::Leases;
use Net::IPAddress::Filter;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json encode_json);

use Data::Dumper;

if(scalar(@ARGV) < 8) {
	die "Usage: $0 <path_to_lease_file> <url_to_semaphore> <username> <password> <project_name> <inventory_name> <group_name> <ipfilter> [<more ipfilters>] [...]";
}

my $leasefile = shift;
my $semaphoreurl = shift;
my $semaphoreuser = shift;
my $semaphorepassword = shift;
my $projectname = shift;
my $inventoryname = shift;
my $groupname = shift;

my $ipfilter = Net::IPAddress::Filter->new();
while(my $i = shift) {
	$ipfilter->add_range($i);
}

# parse the leases file
my $leases = Net::ISC::DHCPd::Leases->new(file => $leasefile);
$leases->parse;

my @hosts;
for my $lease ($leases->leases) {
	next unless ($lease->ends < time);
	next unless ($ipfilter->in_filter($lease->ip_address));

	my $ip = $lease->ip_address;
	my $hostname = gethostbyaddr($lease->ip_address, AF_INET);
	
	push @hosts, defined($hostname) ? $hostname : $ip;
}

# Create inventory content
my $inventorycontent = "[$groupname]\n";
foreach( @hosts) {
	   	$inventorycontent .= "\t$_\n";
}

# Create user agent
my $ua = Mojo::UserAgent->new or die "Failed to create Mojo UserAgent";

# Log in to Semaphore
my $tx = $ua->post("$semaphoreurl/api/auth/login" => {} => json => { auth => $semaphoreuser, password => $semaphorepassword});
unless ($tx->result->code == 204) { die "Failed to log in to Semaphore at $semaphoreurl"; }

# Figure out project id
$tx = $ua->get("$semaphoreurl/api/projects");
unless ($tx->result->code == 200) { die "Failed to list projects"; }

my $json = decode_json $tx->result->body;
my $projectid;
foreach(@$json) {
		if(lc $projectname eq lc %$_{name}) {
				$projectid = %$_{id};
				last;
		}
}
if(not defined($projectid)) { die "Project with name $projectname could not be found in Semaphore"; }

# Extract current version of inventory
$tx = $ua->get("$semaphoreurl/api/project/$projectid/inventory");
unless( $tx->result->code == 200 ) { die "Failed to list inventories"; }

$json = decode_json $tx->result->body;
my $inventoryid;
my $inventoryjson;
foreach(@$json) {
		if(lc $inventoryname eq lc $_->{name}) {
				$inventoryid = $_->{id};
				$inventoryjson = $_;
				last;
		}
}
if(not defined($inventoryid)) { die "Inventory with name $inventoryname could not be found in Semaphore"; }

# Inject new content
$inventoryjson->{inventory} = $inventorycontent;

# Push inventory information back to Semaphore
$tx = $ua->put("$semaphoreurl/api/project/$projectid/inventory/$inventoryid" => {} => json => $inventoryjson);
unless( $tx->result->code == 204 ) { die "Failed to update Semaphore Inventory"; }

# Log out from Semaphore
$tx = $ua->post("$semaphoreurl/api/auth/logout");
unless( $tx->result->code == 204 ) { die "Failed to logout from Semaphore"; }
