#!/usr/bin/env bash

(( $# == 3 )) || {
	echo >&2 "Usage: $0 rd-ip rd-url project"
	exit 2
}
RD_IP=$1
RD_URL=$2
PROJECT=$3

RD_USER=admin
RD_PASS=admin

set -eu

echo "Bootstrapping node $(hostname)..."
# Install mtl executable

cp /vagrant/mtl/src/mtl /usr/bin/mtl
chmod 755 /usr/bin/mtl

# Configure SSHD to pass environment variables to shell.
if ! grep -q "AcceptEnv RD_" /etc/ssh/sshd_config
then	
	echo 'AcceptEnv RD_*' >> /etc/ssh/sshd_config
	/etc/init.d/sshd stop
	/etc/init.d/sshd start
fi

# A set of user logins that mascarade as remote nodes

USERS=( www{1,2} app{1,2} db1 )

# Add a user account for each role/user
# -------------------------------------

for user in ${USERS[*]}
do
	id $user 2>/dev/null && continue

    echo "Adding user account for ${user}..."
	useradd -d /home/$user -m $user

	echo "Configure .ssh/authorized_keys with public key in keystore: $PROJECT/$user/id_rsa.pub"
	mkdir -p /home/$user/.ssh
	chmod 700 /home/$user/.ssh

	KEYPATH=$PROJECT/$user/id_rsa.pub

	rerun rundeck-admin:key-content --user $RD_USER --password $RD_PASS --url $RD_URL \
		--keypath $KEYPATH >> /home/$user/.ssh/authorized_keys

	#ssh-keygen -b 2048 -t rsa -f /home/$user/.ssh/id_rsa -q -N ""
	#cat /vagrant/provisioning/rundeck/id_rsa.pub >> /home/$user/.ssh/authorized_keys
	
	chmod 600 /home/$user/.ssh/authorized_keys
	chown -R $user:$user /home/$user/.ssh
    echo "Completed ssh setup for user $user."
done

echo "done."