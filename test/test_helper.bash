#!/usr/bin/env bash

TEST_FILE=`basename $BATS_TEST_FILENAME .bats`

global_setup() {
	make realclean
	testinputfile=test/input/$TEST_FILE.alephseq
	if [ -f $testinputfile ]; then
		cp $testinputfile input/
	fi
}
