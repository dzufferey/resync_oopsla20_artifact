#!/bin/zsh

# argument parsing {{{
zparseopts -D -E -- \
	-setup=SETUP -kill=KILL \
	b=BATCH c:=CONFLICT_PERC q:=REQUEST_COUNT r:=ROUND_COUNT w:=WRITE_PERC \
	n:=REPLICAS \
	h=HELP -help=HELP

if [[ $? -ne 0 ]]; then
	echo "argument parsing failed !" >&2
	exit 1
fi

if [[ -n "$HELP" ]]; then
cat <<EOF
usage:
  TBD ...
EOF
exit 0
fi
# }}}

echo using config file ${0:A:h}/info${REPLICAS[2]}.sh
source ${0:A:h}/info${REPLICAS[2]}.sh

# global vars {{{
IPS_PORTS=( )
for (( i=1; i<=${#IPS}; i++ )); do
	IPS_PORTS[$i]="${IPS[$i]}:$DEFAULT_PORT"
done
# }}}


# kill all lingering processes
killall -9 multipaxos

i=`$RESYNC/findId.sh`

echo replica $i

# start servers
echo running server
echo $GOOLONG/bin/multipaxos $BATCH -addr "$IPS[$((i + 1))]:$DEFAULT_PORT" -id $i ${IPS_PORTS[@]}
exec $GOOLONG/bin/multipaxos $BATCH -addr "$IPS[$((i + 1))]:$DEFAULT_PORT" -id $i ${IPS_PORTS[@]}
