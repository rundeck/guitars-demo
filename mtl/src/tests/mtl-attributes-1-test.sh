#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------


# The Plan
# --------

describe mtl attributes

it_prints_usage() {
	source ../mtl
	test "mtl attributes -n|--name <> [-v|--value <>]" \
		= "$(mtl attributes --usage)"
}

it_matches_names() {
	source ../mtl
	tmpdir=$(mktemp -d /tmp/mtl-attributes.XXXX)
	pushd $tmpdir

	mkdir attributes
	mkdir attributes/node-executor
	cat > attributes/node-executor/metadata <<-EOF
	NAME="node-executor"
	VALUE="mtl-exec"
	EOF
	mkdir attributes/file-copier
	cat > attributes/file-copier/metadata <<-EOF
	NAME="file-copier"
	VALUE="mtl-copy"
	EOF
	
	test file-copier = "$(mtl attributes --name file-copier)"
	test file-copier = "$(mtl attributes --name file-\*)"
	test file-copier = "$(mtl attributes --name f\*)"
	test node-executor = "$(mtl attributes --name node-executor)"
	test node-executor = "$(mtl attributes --name 'node-*')"
	test node-executor = "$(mtl attributes --name 'n*')"

	list=( $(mtl attributes) )
	test ${#list[*]} -eq 2
	test file-copier = "${list[0]}"
	test node-executor = "${list[1]}"

	rm -r $tmpdir
}

it_lists_values() {
	source ../mtl
	tmpdir=$(mktemp -d /tmp/mtl-attributes.XXXX)
	pushd $tmpdir

	mkdir attributes
	mkdir attributes/file-copier
	cat > attributes/file-copier/metadata <<-EOF
	NAME="file-copier"
	VALUE="mtl-copy"
	EOF
	mkdir attributes/node-executor
	cat > attributes/node-executor/metadata <<-EOF
	NAME="node-executor"
	VALUE="mtl-exec"
	EOF
	
	test "file-copier mtl-copy"   = "$(mtl attributes --name file-copier --value)"
	test "node-executor mtl-exec" = "$(mtl attributes --name node-executor --value)"

	list=( $(mtl attributes --value) )
	test ${#list[*]} -eq 4

	rm -r $tmpdir
}
