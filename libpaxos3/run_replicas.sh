#!/bin/bash

while getopts 'n:' option 
do 
	case "${option}" in 
		n) REPLICAS=${OPTARG};; 
	esac 
done 

id=`$RESYNC/findId.sh`
conf=$RESYNC/libpaxos3/paxos$REPLICAS.conf
echo "running replica $id with $conf"
exec ./sample/replica $id $conf
