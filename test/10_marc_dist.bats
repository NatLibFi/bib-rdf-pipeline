#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "MARC distribution: basic generation" {
  rm -f merged/hawking.mrcx
  make marcdist
  [ -s merged/hawking.mrcx ]
}
