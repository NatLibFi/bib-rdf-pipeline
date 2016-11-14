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

@test "MARCXML contains YSA subject" {
  make slices/ajanlyhythistoria-00009.mrcx
  grep -q maailmankaikkeus slices/ajanlyhythistoria-00009.mrcx
}

@test "MARCXML drops subject without KEEP tag" {
  make slices/ajanlyhythistoria-00009.mrcx
  run grep -q kosmologia slices/ajanlyhythistoria-00009.mrcx
  [ "$status" -eq 1 ]
}

