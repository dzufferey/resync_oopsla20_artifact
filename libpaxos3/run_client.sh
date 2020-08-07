#!/bin/bash

while getopts 'n:' option
do
	case "${option}" in
		n) REPLICAS=${OPTARG};;
	esac
done

conf=$RESYNC/libpaxos3/paxos$REPLICAS.conf
echo "running client with $conf"
exec $LPAXOS/sample/client $conf -o 100 -p 0 -v 32768
