#!/bin/bash
source $PSYNC/test_scripts/deps

t=64

echo running 3 LV replicas for $t seconds
java -cp ${cp} example.PerfTest2 -id `$RESYNC/findId.sh` $* &
sleep $((t + 4))
echo stopping ...
pkill -P $$
sleep 1
