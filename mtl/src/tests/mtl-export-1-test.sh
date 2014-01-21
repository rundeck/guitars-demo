#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------


# The Plan
# --------

describe mtl export

it_prints_usage() {
	source ../mtl
	test "mtl export" \
		= "$(mtl export --usage)"
}


it_generates_resourcexml() {
	source ../mtl	
	tmpdir=$(mktemp -d "/tmp/mtl.XXXX")
	pushd $tmpdir

	mtl init --name $(hostname)
	mtl attribute --name node-executor --value mtl-exec
	mtl attribute --name file-copier --value mtl-copy

	mtl export > resource.xml


	xmlstarlet val resource.xml
	test $(hostname) = "$(xmlstarlet sel -t -m /project/node -v @name resource.xml)"
	#test mtl-exec = "$(xmlstarlet sel -t -m /project/node/attribute[@name='node-executor'] -v @value resource.xml)"

	#rm -r $tmpdir
}
