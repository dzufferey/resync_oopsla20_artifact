#!/bin/bash

# ThroughputLatencyClient
#       <initial client id>
#       <number of clients>
#       <number of operations>
#       <request size>
#       <interval (ms)>
#       <read only?>
#       <verbose?>
#       <nosig | default | ecdsa>

ID=1001
NBCLI=1
NBOPS=10000
REQSIZE=16
INTERVAL=0
RO="false"
VERBOSE="false"
SIGNED="default"

while getopts 't:o:s:' option
do
	case "${option}" in
		t) NBCLI=${OPTARG};;
		o) NBOPS=${OPTARG};;
		s) REQSIZE=${OPTARG};;
	esac
done

cd $BFTS
exec ./runscripts/smartrun.sh bftsmart.demo.microbenchmarks.ThroughputLatencyClient $ID $NBCLI $NBOPS $REQSIZE $INTERVAL $RO $VERBOSE $SIGNED
