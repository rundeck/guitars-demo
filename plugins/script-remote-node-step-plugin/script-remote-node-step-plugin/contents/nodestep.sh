#!/bin/sh

##
# This script will be executed on each matched node for the workflow.
##

##
# Arguments defined in the plugin.yaml will be passed to the script
##

uname -a
id

NODE=$1
EXAMPLE=$2
ASIF=$3
AVENGER=$4
VAMPIRES=$5

##
# Config options to the plugin will also be available as environment
# variables, however your SSHD must be configured with AllowEnv RD_*
# to enable this on remote nodes.
##

echo "Example: $EXAMPLE"
echo "Avenger: $AVENGER"
echo "Vapire: $VAMPIRES"

mtl attribute -n stuff:asif -v "$ASIF"
mtl attribute -n stuff:avenger -v "$AVENGER"
mtl attribute -n stuff:vampire -v "$VAMPIRES"


exit 0
