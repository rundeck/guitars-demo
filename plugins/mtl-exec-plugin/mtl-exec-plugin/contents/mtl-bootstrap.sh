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
    #ssh-copy ${MTL_FILE} >/dev/null
    #commands=("chmod +x ./mtl;")
    commands=(${commands[@]:-} "mtl init --name ${RD_NODE_NAME};")
    # Bootstrap the rest of the crucial attributes for remote execution. 
    commands=(${commands[@]} "mtl attribute -n description   -v '$RD_NODE_DESCRIPTION';")
    commands=(${commands[@]} "mtl attribute -n hostname      -v $RD_NODE_HOSTNAME;")
    commands=(${commands[@]} "mtl attribute -n node-executor -v $RD_NODE_NODE_EXECUTOR;")
    commands=(${commands[@]} "mtl attribute -n osFamily      -v $RD_NODE_OS_FAMILY;")
    commands=(${commands[@]} "mtl attribute -n osName        -v $RD_NODE_OS_NAME;")
    commands=(${commands[@]} "mtl attribute -n hostname      -v $RD_NODE_HOSTNAME;")
    commands=(${commands[@]} "mtl attribute -n username      -v $RD_NODE_USERNAME;")
    commands=(${commands[@]} "mtl attribute -n tags          -v $RD_NODE_TAGS;")
    commands=(${commands[@]} "mtl attribute -n ssh-keypath   -v $RD_NODE_SSH_KEYPATH;")

    ssh-exec ${commands[@]}
fi


#	
# Execute the command	
#
ssh-exec $@
exit_code=$?

#
# Collect the data
#
resource_file=/var/rundeck/projects/${RD_RUNDECK_PROJECT}/mtl/${RD_NODE_NAME}.xml

(ssh-exec mtl export) > ${resource_file} 

exit ${exit_code:-0}





