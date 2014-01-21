#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------


# The Plan
# --------

describe mtl publish

it_prints_usage() {
	source ../mtl
	test "mtl publish" \
		= "$(mtl publish --usage)"
}

it_runs_with_no_args() {
	source ../mtl	
	tmpdir=$(mktemp -d "/tmp/mtl.XXXX")
	repo=$tmpdir/mtl.git  ;	
	pushd $tmpdir         ;
	mkdir mtl.git         ;
	cd mtl.git            ;
	git init --bare       ;
	mkdir instance_dir
	pushd instance_dir
	git clone $repo mtl
	cd mtl
	
	echo "test" > test
	git add test
	git commit -m "commit test" test
	git push origin master


	mtl attribute -n foo -v f000
	mtl init --name $(hostname) --repo $repo
	mtl attribute -n bar -v bAAR

	mtl publish

	mtl publish
}
