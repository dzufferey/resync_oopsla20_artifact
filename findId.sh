#!/bin/bash

declare -A ids
ids=( ["REPLICA0"]="0"
      ["REPLICA1"]="1"
      ["REPLICA2"]="2"
      ["REPLICA3"]="3" 
      ["REPLICA4"]="4" 
      ["REPLICA5"]="5" 
      ["REPLICA6"]="6" 
      ["REPLICA7"]="7"
      ["REPLICA8"]="8" ) #XXX put the name of the machine on which the system will run

echo ${ids[`hostname`]}
