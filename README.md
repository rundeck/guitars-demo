The example shown here models a hypothetical application called
"Guitars", a simple web-based service using several functional roles
like web, app and database services.

The purpose of this example is to show how dev and ops teams can
collaborate around how to restart the web tier, manage software
promotions, run status health checks and a nightly batch job.

This is a multi-machine vagrant configuration that installs
and configures a rundeck instance and an Apache httpd instance.

The httpd instance is used as a simple web-based file
repository from which scripts and job options are shared to Rundeck. 

To run this example, you will bring up VMs using vagrant, log in 
to Rundeck and perform certain jobs.

## Vagrant configuration

This vagrant configuration defines one virtual machine:

* **rundeck**: The rundeck instance used by all the teams.
* **stg1**: Target node where the application deployments reside.
* **prd1**: Target node where the application deployments reside.

The rundeck VMs run a centos base box and installs software via yum/rpm.

### Requirements

* Internet access to download packages from public repositories.
* [Vagrant 1.2.2](http://downloads.vagrantup.com)

### Startup

Start up the VMs like so:

    vagrant up

You can access the rundeck and httpd instances from your host machine using the following URLs:

* rundeck: http://192.168.50.3:4440
* httpd: http://192.168.50.3/guitars


## Nodes

The guitars project contains several nodes. Go to the "Nodes" page and press the button
"Show all nodes". You will see the following nodes:

* app1
* app2
* db1
* www1
* www2

Each of the nodes play a role in running the Guitars application.

The Tags columns shows how each node is tagged with user defined
labels. You can use tags for grouping or classification.
For example, all of the nodes tagged "guitars" represent the
guitars hosts.
There are also tags that describe functionally like "www" and "app" and "db".
Clicking on any of the tag names filters the nodes for ones that are tagged with that label.
Clicking on the "guitars" tag will list all the guitars nodes again.



### Jobs

The rundeck instance will come up with the following demo jobs 
already loaded. All jobs are organized under a common group called "guitars".

- db/nightly_catalog_rebuild - 'rebuild the catalog data'
- release/Deploy - 'deploy the packages'
- release/Promote - 'promote the packages'
- release/UnDeploy - 'remove the packages'
- web/Restart - 'restart the web servers'
- web/Status - 'check the status of guitars'
- web/start - 'start the web servers'
- web/stop - 'stop the web servers'

Each job is defined in its own file using the 
[XML format](http://rundeck.org/docs/manpages/man5/job-v20.html). 
[YAML](http://rundeck.org/docs/manpages/man5/job-yaml-v12.html) could also have been used as an alternative syntax. Rundeck jobs can call
scripts stored in a web server by specifying its location with a 
[scripturl](http://rundeck.org/docs/manpages/man5/job-v20.html#script-sequence-step).
Storing scripts outside of a rundeck job, faciliates better collaboration
and configuration management.

Using job groups is optional but is often helpful to organize procedures
and simplify setting up ACL policies.
