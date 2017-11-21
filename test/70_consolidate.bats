#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Consolidate works: basic consolidation" {
  skip "not implemented, see https://github.com/NatLibFi/bib-rdf-pipeline/issues/3"
  rm -f output/hawking.nt
  rm -f output/hawking.hdt
  make -j2 consolidate
  [ -s output/hawking.nt ]
  [ -s output/hawking.hdt ]
}
