#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------


# The Plan
# --------

describe mtl init

it_prints_usage() {
	source ../mtl
	test "mtl init [--name|-n <>][--dir|-d <>][--repo|-r <>][--fetch]" \
		= "$(mtl init --usage)"
}

it_can_init_with_no_args() {
	source ../mtl	
	mtl init	
	test -f .mtl/metadata
	. .mtl/metadata

	test "$NAME" = "$(hostname)"
	test "$DIR" = "$(pwd)"
	test "$CREATED_BY" = "$(whoami)"
}

it_can_init_with_args() {
	source ../mtl	
	tmpdir=$(mktemp -d "/tmp/mtl.XXXX")

	mtl init --name $(hostname) --dir $tmpdir

	test -d $tmpdir/.mtl
	test -f $tmpdir/.mtl/metadata

	rm -r $tmpdir
}
