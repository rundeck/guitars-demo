#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------


# The Plan
# --------

describe mtl --sanity

it_is_a_flag() {
	source ../mtl
	mtl --sanity
	mtl --sanity ytinas
}

it_passes_sanity_test() {
	source ../mtl
	test "horns high" = "$(mtl --sanity)"
}
