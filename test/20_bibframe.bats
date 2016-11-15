#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "BIBFRAME RDF: basic conversion" {
  make rdf
  [ -s slices/kotona-00097-bf.rdf ]
}
