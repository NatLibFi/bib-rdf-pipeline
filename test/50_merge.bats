#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Merge works: basic merging" {
  rm -f slices/kotona-00097-merged.nt
  rm -f merged/hawking-merged.nt
  make merge
  [ -s slices/kotona-00097-merged.nt ]
  [ -s merged/hawking-merged.nt ]
}
