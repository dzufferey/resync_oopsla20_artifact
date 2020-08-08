#!/bin/bash
source $PSYNC/test_scripts/deps

t=184

echo running batching replica for $t seconds
java -cp ${cp} example.batching.BatchingClient -id `$RESYNC/findId.sh` $* &
sleep $((t + 4))
echo stopping ...
pkill -P $$
sleep 1
