#!/bin/sh

while :
do
	perl /usr/local/bin/leases_to_semaphore.pl $LEASEFILE $SEMAPHORE_URL $SEMAPHORE_USER $SEMAPHORE_PASSWORD $PROJECT $INVENTORY $GROUP $NETWORKS

	if [ $PERIOD = 0 ]; then
		exit 0
	fi

	sleep $PERIOD
done
