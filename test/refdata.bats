#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
}

@test "ISO639-2 to Finnish language name mapping" {
  make refdata/iso639-2-fi.csv
  [ -s refdata/iso639-2-fi.csv ]
}
