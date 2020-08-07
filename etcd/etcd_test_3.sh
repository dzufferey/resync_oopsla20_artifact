#!/bin/bash

rm -rf ~/etcd_storage/data

id=`$RESYNC/findId.sh`
ips=(REPLICA0 REPLICA1 REPLICA2 REPLICA3 REPLICA4 REPLICA5 REPLICA6 REPLICA7 REPLICA8)
ip=${ips[$id]}

exec $ETCD/bin/etcd --name s$id \
	--data-dir ~/etcd_storage/data \
	--listen-client-urls http://$ip:2379 \
	--advertise-client-urls http://$ip:2379 \
	--listen-peer-urls http://$ip:2380 \
	--initial-advertise-peer-urls http://$ip:2380 \
	--initial-cluster s0=http://REPLICA0:2380,s1=http://REPLICA1:2380,s2=http://REPLICA2:2380 \
	--initial-cluster-token tkn \
	--initial-cluster-state new \
	--heartbeat-interval '1000' \
	--election-timeout '10000'
