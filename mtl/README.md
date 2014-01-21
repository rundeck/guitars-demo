# MTL, Meta Tool Language 

When you want to be close to the metal.

## Preparation

Use `mtl init` to initialize the environment for mtl. 
Creates a workspace in current working directory.

    mtl init 

Default values are: `--name $(hostname) --dir $(pwd)`

Initialize mtl with a specific name and base directory. 

    mtl init --name Targa.local --dir /home/alexh/mtl

The values of these input parameters can be accessed with 
the `mtl info` command.

## Info

Return a metadata value by specifying the name of the property.

    mtl info --property|-p <property>

Get the value of the NAME property.

    mtl info --property NAME

returns ...

    web1.local    

Get the value of the dir property.

    mtl info -p DIR

returns ...
  
    /home/alexh/mtl

## Attributes

### Set and get attributes

Use `mtl attribute` to declare attributes about this instance. 
Attributes can describe properties and state.

    mtl attribute -n listen_port -v 8080
    mtl attribute -n mypath      -v /my/path
    mtl attribute -n status      -v active

Return the value of an attribute.
    
    mtl attribute -n listen_port 

returns... 8080

Use a prefix in the attribute to organize them. 
Follows the machine-tags format.

    mtl attribute -n namespace:predicate -v value   

Declare some attributes across several namespaces.

    mtl attribute -n packages:tomcat      -v tomcat-7.0.42.zip
    mtl attribute -n packages:estore      -v estore-1.0.42.war
    mtl attribute -n estore:customer      -v acme.com
    mtl attribute -n estore:url           -v http://192.168.50.12:8080/estore
	mtl attribute -n tomcat:listen_port   -v 8080
	mtl attribute -n tomcat:catalina_base -v /home/tomcat

Use attributes to model metrics.

    mtl attribute -n metrics:estore.deploys  -v 5
    mtl attribute -n metrics:estore.restarts -v 5


Alternative mtl syntax using long option name for name and value parameters.

    mtl attribute --name listen_port --value 8080

### Clear and remove attributes

    mtl attribute --name|-n <attribute> [--clear --remove]

Clear the value for status.

    mtl attribute -n status --clear

Remove status.

    mtl attribute -n status --remove

### List attributes

Use `mtl attributes` to list all the attributes for this instance.

    mtl attributes [--values|-v]

List attribute names prefixed tomcat:

    mtl attributes -n "tomcat:*"

returns...

    tomcat:listen_port
    tomcat:catalina_base


List attributes and show their values.

    mtl attributes -n "tomcat:*" -v

returns...

     tomcat:listen_port 8080
     tomcat:catalina_base /home/tomcat



## Commands

### Declare commands

Declare new commands with `mtl command`.

Define status command with an inline script:

    mtl command -n status --script "curl -sf `mtl attribute -n estore:url`; exit $?"

A stop command that executes a script file:

    mtl command -n stop --scriptfile $(mtl info -n dir)/bin/stop

Define stop command but scriptfile is a url address:

    mtl command -n stop --scriptfile http://repo/script

Delegate command to another module. 
The other module must contain the same command.

    mtl command -n start --delegate altmodule

### List commands

List the commands with `mtl commands`.

    mtl commands

returns ...

    start
    status
    stop

List commands starting with 'sto':
   
    mtl commands -n "sto*"

returns ...

    stop


### Execute commands

Use `mtl exec` to execute declared commands.


Execute start command defined in this instance:

    mtl exec -n stop

Execute a command with options:

    mtl exec -n status --url $(mtl attribute estore:url)

Execute a command in another mtl module

    mtl exec -m othermodule -n command

## Command options

### Declare options for a command

Use `mtl option` to declare an option for a command.

    mtl option -n <name> --command <> --arguments <> --default <> --description <>

Create an option called --jumps for the command, dance:

    mtl option -n jumps --command dance --arguments true --default 3 --description 'num times to jump'

Changes usage for the dance command to:

    mtl exec dance --jumps <3>

Similar usage as stubbs:add-option.


### List options

Specify the command name:

    mtl option --command dance

returns ...

    jumps


## Local metadata storage

### Instance directory structure

The `mtl init` initializes a directory structure and 
stores metadata for the new mtl instance.

    .
    |-- attributes/
    |-- commands/
    `-- metadata

The metadata file contains the name and dir values used by `mtl init`

    name="Targa.local"
    dir="/home/alexh/mtl
    created_at="Thu Jan 16 09:20:56 PST 2014"
    created_by="alexh"

The attributes and commands directory are discussed in sections below.

### Attribute local storage

Attribute metadata stored in flat files

    .
    |-- attributes/
    |   |-- listen_port/
    |   |-- mypath/
    |   `-- status/
    |       `-- metadata
    |-- commands/
    `-- metadata

The metadata file contains the properties about the attribute

    cat ./attributes/status/metadata
    NAME="status"
    VALUE="myvalue"


### Command local storage

Command metadata stored in flat files

	 .
	 |-- attributes/
	 |-- commands/
	 |   |-- start/
	 |   |-- status/
	 |   `-- stop/
	 |       `-- metadata
	 `-- metadata

The metadata file contains the properties about the attribute

    cat ./commands/stop/metadata
    NAME="stop"
    DESCRIPTION="stop command"
    OPTIONS=""

## Synchronization

mtl data can be shared with other nodes through synchronization 
of the mtl metadata. How synchronization is done depends on the backend.

Module containing backend implementation is defaulted
to ... env_var or attribute?

### publish

The publish command pushes mtl state to the store. 

Publish all state to store.

    mtl publish

Future ideas:

Publish using implementation from the specified module

	mtl publish --module git-mtl-store
	
    mtl publish --attributes
    mtl attribute -n myvar --publish
    mtl attributes -n "stuff:*" --publish

### fetch

The fetch command pulls mtl state from the store. 

    mtl fetch

fetch using implementation from the specified module

	mtl fetch --repo repositry


## Defaults

### Adding mtl commands (syntax sugar)

A defaults system could store handlers for invoking user defined mtl commands.

Here a script handles calls to mtl defined commands.

    mtl defaults handler --script "$(mtl exec ${1} ${2} ${@:3})"

Turns user defined commands into mtl sub commands.

    mtl stop --foo bar

Default handler resolves to: `mtl exec stop --foo bar`


## Don't like the word 'mtl'?

Alternative names to mtl.

meta. 

	meta attribute -n sayhi -v hi

	meta command -n sayhi -script "echo ${1:-$(yo:attribute sayhi:message)}"  
	meta exec sayhi --message "hello"  
	meta sayhi --message "hello"

node. 

	node attribute sayhi hi

	node command sayhi -script "echo ${1:-$(yo:attribute sayhi:message)}"  
	node exec sayhi  "hello"  
	node sayhi  "hello"

self.

    self attribute sayhi:message hi
    self attribute --name sayhi:message --value hi
    self exec status


yo. Yo is self in spanish:

    yo:attribute sayhi:message hi

    yo:command sayhi -script "echo ${1:-$(yo:attribute sayhi:message)}"  
    yo:exec sayhi  "hello"  
    yo:sayhi  "hello"

proto. because it's a prototype object system design: 

    proto:attribute fooattry value_1 ;# alternative namespace ideas

object. object system:

    object:attribute fooattry value_1  ;# ditto

instance. same as object:

    instance:attribute fooattry value_1  ;# ditto


# Scratch

    mtl init --name $(hostname) --repo $repo
	mtl fetch
	
	mtl attribute -n foo -v f000
	mtl attribute -n bar -v bAAR
	mtl attribute -n baz -v B@@z

	mtl publish
	


