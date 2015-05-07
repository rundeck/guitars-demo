#!/usr/bin/env bash

set -e
set -u


if (( $# != 3 ))
then
    echo >&2 "usage: add-project project remote-node-ip rundeck-ip"
    exit 1
fi
PROJECT=$1
REMOTE_NODE_IP=$2
RD_IP=$3
shift; shift; shift;

fwk_prop_read() {
  local propkey=$1
  value=$(awk -F= "/framework.$propkey/ {print \$2}" /etc/rundeck/framework.properties)
  printf "%s" "${value//[[:space:]]/}"
}
RDECK_URL=$(fwk_prop_read  server.url)
RDECK_USER=$(fwk_prop_read server.username)
RDECK_PASS=$(fwk_prop_read server.password)
RDECK_NAME=$(fwk_prop_read server.name)
RDECK_HOST=$(fwk_prop_read server.hostname)

PROJECT_DIR=/var/rundeck/projects/$PROJECT

# Plugins configuration
: ${HipChatNotification_room:=anvils}
: ${HipChatNotification_apiAuthToken:=3c487171c6bf940d31ae6262920604}

: ${JIRA_url:='https\://simplifyops.atlassian.net'}
: ${JIRA_login:=admin}
: ${JIRA_password:='Rund3ck$$'}



if ! rpm -q epel-release
then
curl -s http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -o epel-release.rpm -z epel-release.rpm
rpm -Uvh epel-release.rpm
sed -i -e 's/^mirrorlist=/#mirrorlist=/g' /etc/yum.repos.d/epel.repo
sed -i -e 's/^#baseurl=/baseurl=/g' /etc/yum.repos.d/epel.repo
fi
yum -y install xmlstarlet


# Create the project
# --------------------------


# Generate the key value pairs used for the call to `rd-project`.
RD_PROJECT_PARAMS=(
    --project.plugin.WorkflowStep.JIRA-Issue-Exists.url=${JIRA_url}
    --project.plugin.WorkflowStep.JIRA-Issue-Exists.login=${JIRA_login}
    --project.plugin.WorkflowStep.JIRA-Issue-Exists.password=${JIRA_password}
    --project.plugin.Notification.JIRA.url=${JIRA_url}
    --project.plugin.Notification.JIRA.login=${JIRA_login}
    --project.plugin.Notification.JIRA.password=${JIRA_password}
    --project.plugin.Notification.HipChatNotification.room=${HipChatNotification_room}
    --project.plugin.Notification.HipChatNotification.apiAuthToken=${HipChatNotification_apiAuthToken}
)


echo "Creating project $PROJECT..."

su - rundeck -c "rd-project -a create -p $PROJECT ${RD_PROJECT_PARAMS[*]}"

# Run simple commands to double check.

echo "Executing dispatch -p $PROJECT ..."
su - rundeck -c "dispatch -p $PROJECT"
# Run an adhoc command.
su - rundeck -c "dispatch -p $PROJECT -f -- whoami"


# Add resources
# --------------

NODES=( www{1,2} app{1,2} db1 )

RESOURCES=${PROJECT_DIR}/etc/resources.xml

if [[ ! -f $RESOURCES ]]
then
    mkdir -p $(dirname $RESOURCES)
    cat >> $RESOURCES <<EOF
    <project>
    </project>
EOF
    chown -R rundeck:rundeck $(dirname $RESOURCES)

    echo "Generated $RESOURCES file because it was not already there."
fi

which xmlstarlet >/dev/null|| { echo "FAIL: xmlstarlet not found." ; exit 1 ; }

for NODE in ${NODES[*]}
do
    # Create local host account
    id $NODE || useradd -d /home/$NODE -m $NODE

    echo "Add host user ${NODE}."

    # Generate an SSH key for this user
    echo "Generate SSH key for user $NODE"
    [[ ! -f /home/$NODE/.ssh/id_rsa.pub ]] && {
        su - $NODE -c "ssh-keygen -b 2048 -t rsa -f /home/$NODE/.ssh/id_rsa -q -N ''"
        chown -R $NODE:$NODE /home/$NODE/.ssh
    }

    # Upload SSH key
    # --------------
    # key-path convention: {org}/{app}/{user}
    #
    KEYPATH="${PROJECT}/${NODE}/id_rsa"
    echo "Uploading SSH key to path: ${KEYPATH}"

    if ! rerun rundeck-admin:key-list --keypath $KEYPATH --user $RDECK_USER --password $RDECK_PASS --url ${RDECK_URL} 2>/dev/null
    then 
    rerun  rundeck-admin: key-upload \
        --keypath $KEYPATH --format private --file /home/$NODE/.ssh/id_rsa \
        --user $RDECK_USER --password $RDECK_PASS --url ${RDECK_URL} 
    rerun  rundeck-admin: key-upload \
        --keypath $KEYPATH.pub --format public --file /home/$NODE/.ssh/id_rsa.pub \
        --user $RDECK_USER --password $RDECK_PASS --url ${RDECK_URL} 
    fi

	if ! xmlstarlet sel -t -m "/project/node[@name='${NODE}']" -v @name $RESOURCES
	then
        ROLE=$(expr $NODE : '\(.*\)[0-9]')
        echo "Adding node: ${NODE}."
    	xmlstarlet ed -P -S -L -s /project -t elem -n NodeTMP -v "" \
    	    -i //NodeTMP -t attr -n "name" -v "${NODE}" \
	        -i //NodeTMP -t attr -n "tags" -v "${ROLE},guitars" \
    	    -i //NodeTMP -t attr -n "hostname" -v "${REMOTE_NODE_IP}" \
        	-i //NodeTMP -t attr -n "username" -v "${NODE}" \
        	-i //NodeTMP -t attr -n "osFamily" -v "unix" \
            -i //NodeTMP -t attr -n "osName" -v "Linux" \
	        -i //NodeTMP -t attr -n "ssh-key-storage-path" -v "keys/$KEYPATH" \
	        -i //NodeTMP -t attr -n "node-executor" -v "mtl-exec" \
    	    -r //NodeTMP -v node \
        	$RESOURCES
	else
    	echo "Node $NODE already defined in resources.xml"
	fi
done



# Add jobs, scripts and options
# -----------------------------

mkdir -p /var/www/html/guitars/{scripts,options,jobs,images}
cp -r /vagrant/provisioning/rundeck/jobs/*    /var/www/html/guitars/jobs/
cp -r /vagrant/provisioning/rundeck/scripts/* /var/www/html/guitars/scripts/
cp -r /vagrant/provisioning/rundeck/options/* /var/www/html/guitars/options/
cp -r /vagrant/provisioning/rundeck/images/* /var/www/html/guitars/images/
chown -R rundeck:apache /var/www/html/guitars/{scripts,options,jobs,images}

# Configure directory resource source
mkdir -p ${PROJECT_DIR}/mtl
cat >> ${PROJECT_DIR}/etc/project.properties <<EOF
#+
resources.source.2.type=directory
resources.source.2.config.directory=${PROJECT_DIR}/mtl
#-
EOF

for template in readme.md motd.md
do
    templ_path=/vagrant/provisioning/rundeck/project/$PROJECT.${template}
    [[ -f ${templ_path} ]] && {
        sed \
            -e "s/@RD_IP@/${RD_IP}/g" \
            -e "s/@PROJECT@/${PROJECT}/g" \
        ${templ_path} >> ${PROJECT_DIR}/${template}
}
done

chown -R rundeck:rundeck  ${PROJECT_DIR}


# Add jobs
for job in /var/www/html/guitars/jobs/*.xml
do
    sed -i -e "s/@RD_IP@/${RD_IP}/g" $job
	su - rundeck -c "rd-jobs load -p $PROJECT -f $job"
done

# List the jobs
su - rundeck -c "rd-jobs list -p $PROJECT"


exit $?
