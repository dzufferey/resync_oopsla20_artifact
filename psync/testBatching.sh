#!/bin/bash
source $PSYNC/test_scripts/deps

t=64

echo running BLV replicas for $t seconds
java -cp ${cp} example.batching.BatchingClient -id `$RESYNC/findId.sh` $* &
sleep $((t + 4))
echo stopping ...
pkill -P $$
sleep 1
