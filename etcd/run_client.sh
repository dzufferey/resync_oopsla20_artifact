#!/bin/bash


NBCON=10
NBCLI=1000
NBOPS=50000
REQSIZE=32760 #8 bytes short of 32KB as the keyy is 8 bytes

while getopts 'c:t:o:s:' option
do
	case "${option}" in
        c) NBCON=${OPTARG};;
		t) NBCLI=${OPTARG};;
		o) NBOPS=${OPTARG};;
		s) REQSIZE=${OPTARG};;
	esac
done

exec $ETCD/bin/tools/benchmark --endpoints=http://REPLICA0:2379 --target-leader \
    --conns=$NBCON \
    --clients=$NBCLI \
    put --key-size=8 --sequential-keys \
    --total=$NBOPS \
    --val-size=$REQSIZE
