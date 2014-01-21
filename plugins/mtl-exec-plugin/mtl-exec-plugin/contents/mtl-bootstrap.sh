#!/usr/bin/env bash


USER=$1
shift;
HOST=$1
shift;

set -eu

MTL_FILE=$RD_PLUGIN_BASE/mtl

#
# Install mtl if it isn't already on the node.
#
if ! /bin/bash $RD_PLUGIN_BASE/ssh-exec.sh ${USER} ${HOST} test -f mtl
then
	# copy mtl to the remote node.
    export RD_NODE_SCP_DIR=./
	/bin/bash $RD_PLUGIN_BASE/ssh-copy.sh ${USER} ${HOST} ${MTL_FILE}
    /bin/bash $RD_PLUGIN_BASE/ssh-exec.sh ${USER} ${HOST} "chmod +x mtl; ./mtl init --node $HOST"
fi


#	
# Execute the command	
#

exec /bin/bash $RD_PLUGIN_BASE/ssh-exec.sh $USER $HOST ./mtl $@





