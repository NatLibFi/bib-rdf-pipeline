#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Agent transformations: authors are merged" {
  make refdata/hawking-agent-transformations.nt
  count="$(cut -d ' ' -f 3 refdata/hawking-agent-transformations.nt | grep -c 'P00009584101>')"
  [ "$count" -eq 5 ]
}

@test "Agent transformations: contributors are merged" {
  make refdata/sjubroder-agent-transformations.nt
  count="$(cut -d ' ' -f 3 refdata/hawking-agent-transformations.nt | grep -c 'P00014685402>')"
  [ "$count" -eq 5 ]
}

