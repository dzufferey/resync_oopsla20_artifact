#!/bin/bash

while getopts 'n:' option 
do 
	case "${option}" in 
		n) REPLICAS=${OPTARG};; 
	esac 
done 

declare -A ids
ids=( ["srv-76-164"]="0"
      ["srv-76-165"]="1"
      ["srv-76-166"]="2"
      ["srv-76-167"]="3"
      ["srv-76-168"]="4"
      ["srv-76-169"]="5"
      ["srv-76-180"]="6"
      ["srv-76-181"]="7"
      ["srv-76-182"]="8"
    ) #XXX put the name of the machine on which the system will run


id=${ids[`hostname`]}
conf=paxos$REPLICAS.conf
echo "running replica $id with $conf"
exec ./sample/replica $id $conf
