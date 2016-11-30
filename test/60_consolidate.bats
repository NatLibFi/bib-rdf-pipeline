#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Consolidate works: basic consolidation" {
  rm -f output/hawking.nt
  rm -f output/hawking.hdt
  make consolidate
  [ -s output/hawking.nt ]
  [ -s output/hawking.hdt ]
}
