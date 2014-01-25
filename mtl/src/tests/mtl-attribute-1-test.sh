#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------


# The Plan
# --------

describe mtl attribute

it_prints_usage() {
	source ../mtl
	test "mtl attribute --name|-n <> [--value|-v <>] [--clear|--remove]" \
		= "$(mtl attribute --usage)"
}

it_will_error_when_no_name_option_specified() {
	source ../mtl	
	! mtl attribute
	! mtl attribute --value balr
}


it_gets_value() {
	source ../mtl
	tmpdir=$(mktemp -d "/tmp/mtl-attribute.XXXX")
	pushd $tmpdir

    mtl init
	mkdir -p .mtl/attributes
	mkdir -p .mtl/attributes/node-executor
	cat > .mtl/attributes/node-executor/metadata <<EOF
NAME="node-executor"
VALUE="mtl-exec"
EOF
		
	test "mtl-exec" = "$(mtl attribute --name node-executor)"

	rm -r $tmpdir
}

it_sets_value() {
	source ../mtl
	tmpdir=$(mktemp -d "/tmp/mtl-attribute.XXXX")
	pushd $tmpdir
    mtl init


	mtl attribute --name node-executor --value mtl-exec		
	test "mtl-exec" = "$(mtl attribute --name node-executor)"

	mtl attribute --name stuff:node-executor --value mtl-exec		
	test "mtl-exec" = "$(mtl attribute --name stuff:node-executor)"

	mtl attribute --name some.stuff:node-executor --value mtl-exec		
	test "mtl-exec" = "$(mtl attribute --name some.stuff:node-executor)"

	mtl attribute --name some.stuff:node-executor.bar --value bar
	test "bar" = "$(mtl attribute --name some.stuff:node-executor.bar)"

    popd
	rm -r $tmpdir
}

it_sets_empty_value() {
	source ../mtl
	tmpdir=$(mktemp -d "/tmp/mtl-attribute.XXXX")
	pushd $tmpdir
    mtl init


	mtl attribute --name description --value ''
	test "" = "$(mtl attribute --name description)"

    popd
    rm -r $tmpdir
}

it_clears_value() {
	source ../mtl
	tmpdir=$(mktemp -d "/tmp/mtl-attribute.XXXX")
	pushd $tmpdir
    mtl init

	mtl attribute --name ssh-test --value testy		

	mtl attribute --name ssh-test --clear
	value=$(mtl attribute --name ssh-test)
	test -z "$value"

    popd
	rm -r $tmpdir
}


it_removes_attribute() {
	source ../mtl
	tmpdir=$(mktemp -d "/tmp/mtl-attribute.XXXX")
	pushd $tmpdir
	mkdir -p .mtl/attributes

	mtl attribute --name ssh-test --value node-executor		

	mtl attribute --name ssh-test --remove
	! mtl attribute --name ssh-test

    popd
	rm -r $tmpdir
}

