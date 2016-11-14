#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "convert to MARCXML" {
  make mrcx
  [ -s slices/kotona-00097.mrcx ]
}
