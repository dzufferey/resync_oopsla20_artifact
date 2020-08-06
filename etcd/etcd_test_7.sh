rm -rf ~/etcd_storage/data


$ETCDDIR/etcd-download-test/etcd --name s1 \
	--data-dir ~/etcd_storage/data \
	--listen-client-urls http://139.19.162.64:2379 \
	--advertise-client-urls http://139.19.162.64:2379 \
	--listen-peer-urls http://139.19.162.64:2380 \
	--initial-advertise-peer-urls http://139.19.162.64:2380 \
	--initial-cluster s1=http://139.19.162.64:2380,s2=http://139.19.162.65:2380,s3=http://139.19.162.66:2380,s4=http://139.19.162.67:2380,s5=http://139.19.162.68:2380,s6=http://139.19.162.69:2380,s7=http://139.19.162.80:2380 \
	--initial-cluster-token tkn \
	--initial-cluster-state new \
	--heartbeat-interval '1000' \
	--election-timeout '10000'
