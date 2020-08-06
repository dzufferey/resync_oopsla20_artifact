#!/bin/bash

# this script will insert the information into all the configuration files

declare -A addresses
declare -A ips
declare -A hosts

# TODO put the URL of the machines
addresses=( ["REPLICA0"]="srv-76-164.mpi-sws.org"
            ["REPLICA1"]="srv-76-165.mpi-sws.org"
            ["REPLICA2"]="srv-76-166.mpi-sws.org"
            ["REPLICA3"]="srv-76-167.mpi-sws.org"
            ["REPLICA4"]="srv-76-168.mpi-sws.org"
            ["REPLICA5"]="srv-76-169.mpi-sws.org"
            ["REPLICA6"]="srv-76-117.mpi-sws.org"
            ["REPLICA7"]="srv-76-118.mpi-sws.org"
            ["REPLICA8"]="srv-76-119.mpi-sws.org" )

# TODO put the IP addresses
ips=( ["REPLICA0"]="139.19.162.64"
      ["REPLICA1"]="139.19.162.65"
      ["REPLICA2"]="139.19.162.66"
      ["REPLICA3"]="139.19.162.67"
      ["REPLICA4"]="139.19.162.68"
      ["REPLICA5"]="139.19.162.69"
      ["REPLICA6"]="139.19.162.17"
      ["REPLICA7"]="139.19.162.18"
      ["REPLICA8"]="139.19.162.19" )

# TODO put the hostname here (output of hostname command)
hosts=( ["REPLICA0"]="srv-76-164"
        ["REPLICA1"]="srv-76-165"
        ["REPLICA2"]="srv-76-166"
        ["REPLICA3"]="srv-76-167"
        ["REPLICA4"]="srv-76-168"
        ["REPLICA5"]="srv-76-169"
        ["REPLICA6"]="srv-76-117"
        ["REPLICA7"]="srv-76-118"
        ["REPLICA8"]="srv-76-119" )

sed -i "
s/REPLICA0/${hosts[REPLICA0]}/g
s/REPLICA1/${hosts[REPLICA1]}/g
s/REPLICA2/${hosts[REPLICA2]}/g
s/REPLICA3/${hosts[REPLICA3]}/g
s/REPLICA4/${hosts[REPLICA4]}/g
s/REPLICA5/${hosts[REPLICA5]}/g
s/REPLICA6/${hosts[REPLICA6]}/g
s/REPLICA7/${hosts[REPLICA7]}/g
s/REPLICA8/${hosts[REPLICA8]}/g
" findId.sh

# PSync, Goolong
sed -i "
s/REPLICA0/${addresses[REPLICA0]}/g
s/REPLICA1/${addresses[REPLICA1]}/g
s/REPLICA2/${addresses[REPLICA2]}/g
s/REPLICA3/${addresses[REPLICA3]}/g
s/REPLICA4/${addresses[REPLICA4]}/g
s/REPLICA5/${addresses[REPLICA5]}/g
s/REPLICA6/${addresses[REPLICA6]}/g
s/REPLICA7/${addresses[REPLICA7]}/g
s/REPLICA8/${addresses[REPLICA8]}/g
" psync/batching/*.xml psync/byzantine/*.xml psync/default/*.xml goolong/info*.sh

# LibPaxos3, Bft-SMaRt, etcd
sed -i "
s/REPLICA0/${ips[REPLICA0]}/g
s/REPLICA1/${ips[REPLICA1]}/g
s/REPLICA2/${ips[REPLICA2]}/g
s/REPLICA3/${ips[REPLICA3]}/g
s/REPLICA4/${ips[REPLICA4]}/g
s/REPLICA5/${ips[REPLICA5]}/g
s/REPLICA6/${ips[REPLICA6]}/g
s/REPLICA7/${ips[REPLICA7]}/g
s/REPLICA8/${ips[REPLICA8]}/g
" libpaxos3/*.conf bft-smart/config/hosts*.config etcd/*.sh
