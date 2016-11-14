#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
}

@test "ISO639-2 to Finnish language name mapping" {
  make refdata/iso639-2-fi.csv
  [ -s refdata/iso639-2-fi.csv ]
}

@test "ISO639-1 to ISO639-2 mapping" {
  make refdata/iso639-1-2-mapping.nt
  [ -s refdata/iso639-1-2-mapping.nt ]
}

@test "YSA labels and YSO mappings" {
  make refdata/ysa-skos-labels.nt
  [ -s refdata/ysa-skos-labels.nt ]
}

