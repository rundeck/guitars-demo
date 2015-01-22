#!/bin/bash

PROJECTS=$@

echo "Installing RUNDECK Plugins"
set -eu

# Hipchat
[[ ! -f /var/lib/rundeck/libext/rundeck-hipchat-plugin-1.5.0.jar ]] && {
	curl -sfL -o /var/lib/rundeck/libext/rundeck-hipchat-plugin-1.5.0.jar 'http://search.maven.org/remotecontent?filepath=com/hbakkum/rundeck/plugins/rundeck-hipchat-plugin/1.5.0/rundeck-hipchat-plugin-1.5.0.jar'
	printf -- "  - %s\n" rundeck-hipchat-plugin-1.5.0.jar
}
# nexus
#[[ ! -f /var/lib/rundeck/libext/nexus-step-plugins-1.0.0.jar ]] && {
#curl -sfL -o /var/lib/rundeck/libext/nexus-step-plugins-1.0.0.jar https://github.com/rundeck-plugins/nexus-step-plugins/releases/download/v1.0.0/nexus-step-plugins-1.0.0.jar
#	printf -- "  - %s\n" "nexus-step-plugins-1.0.0.jar"
#}

# puppet
[[ ! -f /var/lib/rundeck/libext/puppet-apply-step.zip ]] && {
curl -sfL -o /var/lib/rundeck/libext/puppet-apply-step.zip https://github.com/rundeck-plugins/puppet-apply-step/releases/download/v1.0.0/puppet-apply-step-1.0.0.zip
	printf -- "  - %s\n" "puppet-apply-step.zip"
}
# jira

[[ ! -f /var/lib/rundeck/libext/jira-workflow-step-1.0.0.jar ]] && {
curl -sfL -o /var/lib/rundeck/libext/jira-workflow-step-1.0.0.jar https://github.com/rundeck-plugins/jira-workflow-step/releases/download/v1.0.0/jira-workflow-step-1.0.0.jar

	printf -- "  - %s\n" "jira-workflow-step-1.0.0.jar"
}
[[ ! -f /var/lib/rundeck/libext/jira-notification-1.0.0.jar ]] && {
curl -sfL -o /var/lib/rundeck/libext/jira-notification-1.0.0.jar https://github.com/rundeck-plugins/jira-notification/releases/download/v1.0.0/jira-notification-1.0.0.jar

	printf -- "  - %s\n" "jira-notification-1.0.0.jar"
}
# jabber
[[ ! -f /var/lib/rundeck/libext/jabber-notification-1.0.jar ]] && {
curl -sfL -o /var/lib/rundeck/libext/jabber-notification-1.0.jar https://github.com/rundeck-plugins/jabber-notification/releases/download/v1.0/jabber-notification-1.0.jar
	printf -- "  - %s\n" "jabber-notification-1.0.jar"
}
# pagerduty
[[ ! -f /var/lib/rundeck/libext/PagerDutyNotification.groovy ]] && {
curl -sfL -o /var/lib/rundeck/libext/PagerDutyNotification.groovy https://raw.githubusercontent.com/rundeck-plugins/pagerduty-notification/master/src/PagerDutyNotification.groovy
	printf -- "  - %s\n" "PagerDutyNotification.groovy"
}
# EC2
[[ ! -f /var/lib/rundeck/libext/rundeck-ec2-nodes-plugin-1.4.jar ]] && {
curl -sfL -o /var/lib/rundeck/libext/rundeck-ec2-nodes-plugin-1.4.jar https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/releases/download/1.4/rundeck-ec2-nodes-plugin-1.4.jar
	printf -- "  - %s\n" "rundeck-ec2-nodes-plugin-1.4.jar"
}

chown -R rundeck:rundeck /var/lib/rundeck/libext

echo "Completed Plugin installation."