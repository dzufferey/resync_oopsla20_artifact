#!/bin/bash
source $PSYNC/test_scripts/deps

t=184

echo running byzantine consensus replicas for $t seconds
java -cp ${cp} example.byzantine.test.Runner -id `$RESYNC/findId.sh` $* &
sleep $((t + 4))
echo stopping ...
pkill -P $$
sleep 1
