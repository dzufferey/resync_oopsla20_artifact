#!/bin/bash
source $PSYNC/test_scripts/deps

t=64

echo running byzantine consensus replicas for $t seconds
 java -cp ${cp} example.byzantine.test.Runner -id 0 `$RESYNC/findId.sh` $* &
sleep $((t + 4))
echo stopping ...
pkill -P $$
sleep 1
