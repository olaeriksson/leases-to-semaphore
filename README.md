# DHCP Leases to Ansible Semaphore
This is a small tool that parses the the dhcpd.leases file that ISC DHCPD generates and updates inventories in Ansible Semaphore based on this information.

It supports filtering to only include active IP addresses from a subset of the total DHCP scoop.

This tool fits perfectly in to your infrastructure-as-code projects and allows you to use ISC DHCPD to assign address ranges to your infrastructure components and have your Ansible inventory (in Semaphore) updated automatically when new devices are brought online.

Best used with Docker:
https://hub.docker.com/repository/docker/olaeriksson/leases-to-semaphore
