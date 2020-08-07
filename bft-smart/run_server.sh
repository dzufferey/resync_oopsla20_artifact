#!/bin/bash

N=4

while getopts 'n:f:' option
do
	case "${option}" in
		n) N=${OPTARG};;
	esac
done

if [ -f $BFTS/config/currentView ]; then
	echo "removing config/current"
	rm $BFTS/config/currentView
fi

conf=hosts$N.config
syst=system$N.config

if [ -f $BFTS/config/hosts.config ]; then
	rm $BFTS/config/hosts.config
fi
echo "removing repalcing hosts.config by $conf"
cp $RESYNC/bft-smart/config/$conf $BFTS/config/hosts.config

if [ -f $BFTS/config/system.config ]; then
	rm $BFTS/config/system.config
fi
echo "removing repalcing system.config by $syst"
cp $RESYNC/bft-smart/config/$syst $BFTS/config/system.config

# trap CTRL-C input, and kill every process created
trap "pkill -P $$; sleep 1; exit 1;" INT

id=`$RESYNC/findId.sh`

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
cd $BFTS
exec ./runscripts/smartrun.sh bftsmart.demo.microbenchmarks.ThroughputLatencyServer $id $interval $replySize $stateSize $context $signed
