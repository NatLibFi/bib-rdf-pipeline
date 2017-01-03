#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "BIBFRAME RDF: basic conversion" {
  rm -f slices/kotona-00097-bf.rdf
  make rdf
  [ -s slices/kotona-00097-bf.rdf ]
}

@test "BIBFRAME RDF: don't use rdf:resource as property" {
  make slices/part-uri-00683-bf.rdf
  ! grep -q -F '<rdf:resource' slices/part-uri-00683-bf.rdf
}
