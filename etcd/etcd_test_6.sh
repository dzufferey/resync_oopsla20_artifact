#!/bin/bash

rm -rf ~/etcd_storage/data

id=$((`$RESYNC/findId.sh` + 1))

exec $ETCD/bin/etcd --name s$id \
	--data-dir ~/etcd_storage/data \
	--listen-client-urls http://REPLICA0:2379 \
	--advertise-client-urls http://REPLICA0:2379 \
	--listen-peer-urls http://REPLICA0:2380 \
	--initial-advertise-peer-urls http://REPLICA0:2380 \
	--initial-cluster s1=http://REPLICA0:2380,s2=http://REPLICA1:2380,s3=http://REPLICA2:2380,s4=http://REPLICA3:2380,s5=http://REPLICA4:2380,s6=http://REPLICA5:2380 \
	--initial-cluster-token tkn \
	--initial-cluster-state new \
	--heartbeat-interval '1000' \
	--election-timeout '10000'
