#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Work keys: basic generation" {
  rm -f slices/kotona-00097-work-keys.nt
  make work-keys
  [ -s slices/kotona-00097-work-keys.nt ]
}
