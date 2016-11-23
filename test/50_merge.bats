#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Merge works: basic merging" {
  make merge
  [ -s slices/kotona-00097-merged.nt ]
  [ -s merged/hawking-merged.nt ]
}
