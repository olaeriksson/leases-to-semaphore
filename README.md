# DHCPD Leases to Ansible Semaphore
This is a small tool that parses the the dhcpd.leases file that ISC DHCPD generates and updates inventories in Ansible Semaphore based on this information. ISC DHCPD is the most common DHCP server and is provided with most Linux distribution.

It supports filtering to only include active IP addresses from a subset of the total DHCP scoop.

This tool fits perfectly in to your infrastructure-as-code projects and allows you to use ISC DHCPD to assign address ranges to your infrastructure components and have your Ansible inventory (in Semaphore) updated automatically when new devices are brought online.

Best used with Docker:
https://hub.docker.com/repository/docker/olaeriksson/leases-to-semaphore

Docker
======
When running in a Docker container, the script will loop and update the Semaphore inventory once every minute. The dhcpd.leases file created by the DHCP server is mounted in to the container.

No persistant storage is required.

How to run
----------
docker run --rm --name leases-to-semaphore \
  -e SEMAPHORE_URL=http://127.0.0.1:3000/ \
  -e SEMAPHORE_USER=dhcpuser \
  -e SEMAPHORE_PASSWORD=secret \
  -e PROJECT=MySemaphoreProject \
  -e INVENTORY=InventoryToUpdate \
  -e GROUP=GroupName \
  -e NETWORKS="192.168.1.0/24 10.10.0.0/16" \
  .v /var/lib/dhcp/dhcpd.leases:/dhcpd.leases:ro \
  olaeriksson/leases-to-semaphore
  
  If you wish to run on other intervals than 60 seconds, you can do this with -e PERIOD=seconds.
