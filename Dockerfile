FROM debian:bullseye

MAINTAINER Ola Eriksson

STOPSIGNAL SIGINT

ENV PERIOD=300
ENV LEASEFILE=/dhcpd.leases
ENV SEMAPHORE_URL=http://127.0.0.1:3000
ENV SEMAPHORE_USER=admin
ENV SEMAPHORE_PASSWORD=password
ENV PROJECT=project1
ENV INVENTORY=inventory1
ENV GROUP=hosts
ENV NETWORKS=127.0.0.0/8

RUN apt-get update && \
	apt-get install -y make libmojolicious-perl libmoose-perl libset-intervaltree-perl && \
	echo "" | cpan -T -i Net::IPAddress::Filter Net::ISC::DHCPd::Leases && \
	rm -rf /root/.cpan && \
	apt remove -y make

ADD leases_to_semaphore.pl /usr/local/bin
ADD entrypoint.sh /

RUN chmod u+x /entrypoint.sh

CMD /entrypoint.sh
