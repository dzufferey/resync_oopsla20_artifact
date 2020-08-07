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

killall -9 client

# start client
echo running client
echo "$GOOLONG/bin/client $CONFLICT_PERC $REQUEST_COUNT $ROUND_COUNT $WRITE_PERC ${IPS_PORTS[@]}"
exec $GOOLONG/client $CONFLICT_PERC $REQUEST_COUNT $ROUND_COUNT $WRITE_PERC ${IPS_PORTS[@]}
