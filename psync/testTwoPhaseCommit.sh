#!/bin/bash
source $PSYNC/test_scripts/deps

t=60

echo running 3 Two Phase Commit replicas
 java -cp ${cp} example.TpcEvtRunner -id `$RESYNC/findId.sh` --conf $RESYNC/psync/default/9replicas-conf.xml $* &
sleep $((t + 2))
echo stopping ...
pkill -P $$
sleep 1
