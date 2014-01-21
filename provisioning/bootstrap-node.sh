#!/usr/bin/env bash

set -eu

# Configure SSHD to pass environment variables to shell.
if ! grep -q "AcceptEnv RD_" /etc/ssh/sshd_config
then	
	echo 'AcceptEnv RD_*' >> /etc/ssh/sshd_config
	/etc/init.d/sshd stop
	/etc/init.d/sshd start
fi

# Fictitious hosts that mascarade as local nodes

USERS=( www{1,2} app{1,2} db1 )

# Add a user account for each role/user
# -------------------------------------

for user in ${USERS[*]}
do
	if ! grep $user /etc/passwd
	then		:
	else		continue
	fi		
    echo "Adding user ${user}."
	useradd -d /home/$user -m $user
	mkdir /home/$user/.ssh
	ssh-keygen -b 2048 -t rsa -f /home/$user/.ssh/id_rsa -q -N ""
	cat /vagrant/provisioning/rundeck/id_rsa.pub >> /home/$user/.ssh/authorized_keys
	chmod 600 /home/$user/.ssh/authorized_keys
	chown -R $user:$user /home/$user/.ssh
done

echo "done."