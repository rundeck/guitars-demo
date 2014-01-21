#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------


# The Plan
# --------

describe mtl fetch

it_prints_usage() {
	source ../mtl
	test "mtl fetch [--repo|-r <>]" \
		= "$(mtl fetch --usage)"
}

it_fails_missing_repo() {
	source ../mtl	
	tmpdir=$(mktemp -d "/tmp/mtl.XXXX")
	pushd $tmpdir

	mtl init --name $(hostname)
	! mtl fetch 2> $tmpdir/err
	grep "repo not specified" $tmpdir/err
}



it_runs_with_no_args() {
	source ../mtl	
	tmpdir=$(mktemp -d "/tmp/mtl.XXXX")
	
	pushd $tmpdir         ;
	mkdir mtl.git         ;
	repo=$tmpdir/mtl.git  ;
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


	mtl init --name $(hostname) --repo $repo
	mtl fetch

	mtl fetch
}
