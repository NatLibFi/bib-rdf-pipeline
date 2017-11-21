#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Agent keys: author key" {
  make slices/hawking-00009-agent-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "W00009584100/hawking, stephen"' slices/hawking-00009-agent-keys.nt
}

@test "Agent keys: contributor key" {
  make slices/hawking-00009-agent-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "W00009584100/sagan, carl"' slices/hawking-00009-agent-keys.nt
}

@test "Agent keys: don't create keys for authorized persons" {
  make slices/sjubroder-00010-agent-keys.nt
  run grep -F 'diktonius, elmer' slices/sjubroder-00010-agent-keys.nt
  [ $status -ne 0 ]
}
