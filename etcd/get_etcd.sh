#!bin/bash
set -x #echo on

ETCD_VER=v3.4.10

DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download

rm -f $ETCDDIR/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf $ETCDDIR/etcd-download-test && mkdir -p $ETCDDIR/etcd-download-test

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o $ETCDDIR/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf $ETCDDIR/etcd-${ETCD_VER}-linux-amd64.tar.gz -C $ETCDDIR/etcd-download-test --strip-components=1
rm -f $ETCDDIR/etcd-${ETCD_VER}-linux-amd64.tar.gz

$ETCDDIR/etcd-download-test/etcd --version
$ETCDDIR/etcd-download-test/etcdctl version
