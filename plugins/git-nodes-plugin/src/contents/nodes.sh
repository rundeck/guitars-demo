#!/bin/bash
#
# Interfaces Yana and returns Node data formatted in XML format:
# * Reference: http://rundeck.org/docs/manpages/man5/resource-v13.html

# Fail if a command errors or an unset variable is referenced.
set -eu

# Input parameters.
: ${RD_CONFIG_REPO} ${RD_CONFIG_DIRECTORY}

# Create the directory if it does not exist.
[[ ! -d ${RD_CONFIG_DIRECTORY} ]] && mkdir -p ${RD_CONFIG_DIRECTORY}

# Change to the working directory.
cd ${RD_CONFIG_DIRECTORY}

# Clone the repository if it hasn't been done yet.
[[ ! -d ${RD_CONFIG_DIRECTORY}.git ]] && git clone ${RD_CONFIG_REPO} . >/dev/null

# Pull changes from the repo.
git pull >> pull.log

# Output mandatory project XML
echo "<project/>"
#
# Done.
#
exit $?
