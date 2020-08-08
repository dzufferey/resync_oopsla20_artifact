#!/bin/bash
source $PSYNC/test_scripts/deps

t=64

echo running Two Phase Commit replica
 java -cp ${cp} example.TpcEvtRunner -id `$RESYNC/findId.sh` $* &
sleep $((t + 4))
echo stopping ...
pkill -P $$
sleep 1
