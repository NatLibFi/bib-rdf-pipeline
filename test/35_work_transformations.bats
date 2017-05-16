#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Work transformations: basic generation" {
  rm -f refdata/fanrik-manninen-work-transformations.nt
  make -j2 work-transformations
  [ -s refdata/fanrik-manninen-work-transformations.nt ]
}
