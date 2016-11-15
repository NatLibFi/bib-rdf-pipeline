#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Schema.org RDF: basic conversion" {
  make schema
  [ -s slices/kotona-00097-schema.nt ]
}
