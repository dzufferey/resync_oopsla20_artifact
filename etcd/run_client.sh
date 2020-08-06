#!/bin/bash

exec $ETCD/bin/tools/benchmark --endpoints=http://REPLICA0:2379 --target-leader --conns=1 --clients=1 \
    put --key-size=8 --sequential-keys --total=10000 --val-size=256
