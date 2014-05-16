#!/usr/bin/env bash


USER=$1
shift;
HOST=$1
shift;

set -eu

MTL_FILE=/var/rundeck/lib/mtl/mtl

ssh-copy() {
    local file=$1
    /bin/bash $RD_PLUGIN_BASE/ssh-copy.sh ${USER} ${HOST} ${file}
    return $?
}
ssh-exec() {
    /bin/bash $RD_PLUGIN_BASE/ssh-exec.sh ${USER} ${HOST} $@
    return $?
}

: ${RD_NODE_SCP_DIR:=./}
export RD_NODE_SCP_DIR

#
# Initialize mtl with the node context.
#
if ! ssh-exec test -d ./.mtl
then
    # Push the bootstrap commands into the array.
    commands=(${commands[@]:-} "mtl init --name ${RD_NODE_NAME};")

    # Execute the bootstrap commands.
    ssh-exec ${commands[@]}
fi


#	
# Execute the user command	
#
ssh-exec $@
exit_code=$?

#
# Collect the data from mtl
#
resource_file=/var/rundeck/projects/${RD_RUNDECK_PROJECT}/mtl/${RD_NODE_NAME}.xml

(ssh-exec mtl export) > ${resource_file} 

#
# Exit with the ssh code from the executed user command.
exit ${exit_code:-0}





