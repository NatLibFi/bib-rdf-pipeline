#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "BIBFRAME RDF: basic conversion" {
  rm -f slices/kotona-00097-bf2.rdf
  make -j2 rdf
  [ -s slices/kotona-00097-bf2.rdf ]
}
