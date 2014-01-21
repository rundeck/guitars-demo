#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------


# The Plan
# --------

describe mtl info

it_prints_usage() {
	source ../mtl
	test "mtl info --property|-p <> [--dir|-d <>]" \
		= "$(mtl info --usage)"
}

it_can_print_init_properties() {
	source ../mtl	
	tmpdir=$(mktemp -d "/tmp/mtl.XXXX")

	mtl init --name "$(hostname)" --dir "$tmpdir"

	test "$(hostname)" = $(mtl info -p NAME -d $tmpdir)
	test "$tmpdir" = $(mtl info --property DIR --dir $tmpdir)

	rm -r "$tmpdir"
}


