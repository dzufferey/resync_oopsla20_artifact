#!/bin/sh
export ETCDDIR=~/etcd_xp/
export GOPATH=$ETCDDIR
mkdir $ETCDDIR
echo "export ETCDDIR=$ETCDDIR" >> ~/.bashrc
