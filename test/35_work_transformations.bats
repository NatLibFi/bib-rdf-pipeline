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

@test "Work transformations: translations are consolidated to same original work" {
  make refdata/hawking-work-transformations.nt
  count="$(cut -d ' ' -f 3 refdata/hawking-work-transformations.nt | grep -c '000095841#Work>')"
  [ "$count" -eq 5 ]
}
