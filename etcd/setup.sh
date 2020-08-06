#!/bin/sh
export ETCDDIR=$HOME/etcd_xp/
export GOPATH=$ETCDDIR
mkdir $ETCDDIR
echo "export ETCDDIR=$ETCDDIR" >> ~/.bashrc
