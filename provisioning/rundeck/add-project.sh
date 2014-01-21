#!/usr/bin/env bash

set -e
set -u


if [ $# -ne 2 ]
then
    echo >&2 "usage: add-project project remotenode"
    exit 1
fi
PROJECT=$1
REMOTE_NODE_IP=$2
shift; shift;


# Configure SSHD to pass environment variables to shell.
if ! grep -q "AcceptEnv RD_" /etc/ssh/sshd_config
then	
	echo 'AcceptEnv RD_*' >> /etc/ssh/sshd_config
	/etc/init.d/sshd stop
	/etc/init.d/sshd start
fi

# Create an example project
# --------------------------
echo Creating project $PROJECT...

su - rundeck -c "rd-project -a create -p $PROJECT"

# Run simple commands to double check.
su - rundeck -c "dispatch -p $PROJECT"
# Run an adhoc command.
su - rundeck -c "dispatch -p $PROJECT -f -- whoami"

# Add resources
# --------------

NODES=( www{1,2} app{1,2} db1 )

RESOURCES=/var/rundeck/projects/${PROJECT}/etc/resources.xml

for NAME in ${NODES[*]}
do
	if ! xmlstarlet sel -t -m "/project/node[@name='${NAME}']" -v @name $RESOURCES
	then
    ROLE=$(expr $NAME : '\(.*\)[0-9]')
    echo "Adding node: ${NAME}."
    	xmlstarlet ed -P -S -L -s /project -t elem -n NodeTMP -v "" \
    	    -i //NodeTMP -t attr -n "name" -v "${NAME}" \
	        -i //NodeTMP -t attr -n "tags" -v "${ROLE}" \
    	    -i //NodeTMP -t attr -n "hostname" -v "${REMOTE_NODE_IP}" \
        	-i //NodeTMP -t attr -n "username" -v "${NAME}" \
        	-i //NodeTMP -t attr -n "osFamily" -v "unix" \
        	-i //NodeTMP -t attr -n "osName" -v "Linux" \
	        -i //NodeTMP -t attr -n "ssh-keypath" -v "/var/lib/rundeck/.ssh/id_rsa" \
	        -i //NodeTMP -t attr -n "node-executor" -v "mtl-exec" \
    	    -r //NodeTMP -v node \
        	$RESOURCES
	else
    	echo "Node $NAME already defined in resources.xml"
	fi
done

# Add jobs, scripts and options
# -----------------------------

mkdir -p /var/www/html/$PROJECT/{scripts,options,jobs}
cp -r /vagrant/provisioning/rundeck/jobs/*    /var/www/html/$PROJECT/jobs/
cp -r /vagrant/provisioning/rundeck/scripts/* /var/www/html/$PROJECT/scripts/
cp -r /vagrant/provisioning/rundeck/options/* /var/www/html/$PROJECT/options/
chown -R rundeck:apache /var/www/html/$PROJECT/{scripts,options,jobs}

# Configure directory resource source
mkdir -p /var/rundeck/projects/$PROJECT/mtl
cat >> /var/rundeck/projects/$PROJECT/etc/project.properties <<EOF
#+
resources.source.2.type=directory
resources.source.2.config.directory=/var/rundeck/projects/$PROJECT/mtl
#-
EOF


# Add jobs
for job in /var/www/html/$PROJECT/jobs/*.xml
do
	su - rundeck -c "rd-jobs load -p $PROJECT -f $job"
done

# List the jobs
su - rundeck -c "rd-jobs list -p $PROJECT"


exit $?
