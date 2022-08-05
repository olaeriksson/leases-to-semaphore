#!/bin/sh

if [ $# != 1 ]; then
	echo "USAGE: build.sh <tag>"
	exit 1
fi

tag="$1"

docker build -t olaeriksson/leases-to-semaphore:${tag} .
