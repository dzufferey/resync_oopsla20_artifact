#!/bin/bash
source $PSYNC/test_scripts/deps

t=184

echo running LastVoting replica for $t seconds
java -cp ${cp} example.PerfTest2 -id `$RESYNC/findId.sh` $* &
sleep $((t + 4))
echo stopping ...
pkill -P $$
sleep 1
