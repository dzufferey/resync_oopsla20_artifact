#!/bin/bash

N=4

while getopts 'n:f:' option 
do 
	case "${option}" in 
		n) N=${OPTARG};; 
	esac 
done 

if [ -f config/currentView ]; then
	echo "removing config/current"
	rm config/currentView
fi
	
conf=hosts$N.config
syst=system$N.config

if [ -f config/hosts.config ]; then
	rm config/hosts.config
fi
echo "removing replcing hosts.config by $conf"
cp config/$conf config/hosts.config

if [ -f config/system.config ]; then
	rm config/system.config
fi
echo "removing replcing system.config by $syst"
cp config/$syst config/system.config

# trap CTRL-C input, and kill every process created
trap "pkill -P $$; sleep 1; exit 1;" INT

# echo packaging 
# ant jar

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

# ThroughputLatencyServer
#       <processId>
#       <measurement interval> req/ms
#       <reply size>
#       <state size>
#       <context?>
#       <nosig | default | ecdsa>
#       [rwd | rw]

interval=10000
replySize=4
stateSize=1000
context="false"
signed="default"

echo "running replica $id"
exec ./runscripts/smartrun.sh bftsmart.demo.microbenchmarks.ThroughputLatencyServer $id $interval $replySize $stateSize $context $signed
