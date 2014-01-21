#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------


# The Plan
# --------

describe mtl

it_prints_usage() {
	source ../mtl

	! output=$(mtl --usage 2>&1)
	echo $output | grep 'mtl [--usage][--sanity]'

}


it_is_sourceable() {
	source ../mtl
}

it_fails_for_bogus_commands() {
	source ../mtl	
	if ! mtl bogus
	then :
	else exit 1
	fi
}
