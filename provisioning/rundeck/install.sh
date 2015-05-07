#!/usr/bin/env bash

set -e 
set -u

# Process command line arguments.

if (( $# < 2 ))
then
    echo >&2 "usage: $0 rdip rundeck_yum_repo"
    exit 1
fi

RDIP=$1
RUNDECK_REPO_URL=$2

# Software install
# ----------------
#
# Utilities
yum -y install coreutils

#
# JRE
#
yum -y install java-1.7.0
#
# Rundeck 
#
if [ -n "$RUNDECK_REPO_URL" ]
then
    curl -# --fail -L -o /etc/yum.repos.d/rundeck.repo "$RUNDECK_REPO_URL" || {
        echo "failed downloading rundeck.repo config"
        exit 2
    }
else
    if ! rpm -q rundeck-repo
    then
        rpm -Uvh http://repo.rundeck.org/latest.rpm 
    fi
fi

yum -y install rundeck

# Reset the home directory permission as it comes group writeable.
# This is needed for ssh requirements.
chmod 755 ~rundeck

# Configure the system

# install mtl
mkdir -p /var/rundeck/lib/mtl
cp /vagrant/mtl/src/mtl /var/rundeck/lib/mtl/mtl
chown -R rundeck:rundeck /var/rundeck/lib/mtl

# install the mtl-exec node executor.
cp /vagrant/provisioning/rundeck/id_rsa* /var/lib/rundeck/.ssh/
chown rundeck:rundeck /var/lib/rundeck/.ssh/

cp /vagrant/plugins/mtl-exec-plugin/mtl-exec-plugin.zip /var/lib/rundeck/libext/

# install the resource model source plugin.
cp /vagrant/plugins/git-nodes-plugin/dist/git-nodes-plugin.zip /var/lib/rundeck/libext

# install the nexus plugin
cp /vagrant/plugins/nexus-deploy-plugin/nexus-artifact-deploy-plugin.zip /var/lib/rundeck/libext

chown -R rundeck /var/lib/rundeck/libext


# Rewrite the rundeck-config.properties to use the IP of this vagrant VM
sed -i "s^grails.serverURL=.*^grails.serverURL=http://$RDIP:4440^g" /etc/rundeck/rundeck-config.properties 
cat >> /etc/rundeck/rundeck-config.properties <<EOF
# Enable storage facility feature to store mtl data.
feature.incubator.storage=true
rundeck.projectsStorageType=filesystem
#rundeck.projectsStorageType=db
EOF

# Add the ACL
cp /vagrant/provisioning/rundeck/aclpolicy/* /etc/rundeck/
chown rundeck:rundeck /etc/rundeck/*.aclpolicy
chmod 444 /etc/rundeck/*.aclpolicy

# Add user/roles to the realm.properties
cat >> /etc/rundeck/realm.properties <<EOF
admin:admin,user,admin,acme
dev:dev,dev,user,acme
ops:ops,ops,user,acme
releng:releng,releng,user,acme
EOF

#
# Disable the firewall so we can easily access it from the host
service iptables stop
#


# Start up rundeck
# ----------------
#
set +e
if ! /etc/init.d/rundeckd status
then
    echo "Starting rundeck..."
    (
        exec 0>&- # close stdin
        /etc/init.d/rundeckd start 
    ) &> /var/log/rundeck/service.log # redirect stdout/err to a log.

    let count=0
    let max=18
    while [ $count -le $max ]
    do
        if ! grep  "Connector@" /var/log/rundeck/service.log
        then  printf >&2 ".";# progress output.
        else  break; # successful message.
        fi
        let count=$count+1;# increment attempts
        [ $count -eq $max ] && {
            echo >&2 "FAIL: Execeeded max attemps "
            exit 1
        }
        sleep 10
    done
fi

echo "Rundeck started."

exit $?
