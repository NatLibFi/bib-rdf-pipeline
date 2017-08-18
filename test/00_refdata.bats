#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make realclean
}

@test "Reference data: ISO639-2 to Finnish language name mapping" {
  make refdata/iso639-2-fi.csv
  [ -s refdata/iso639-2-fi.csv ]
}

@test "Reference data: ISO639-1 to ISO639-2 mapping" {
  make refdata/iso639-1-2-mapping.nt
  [ -s refdata/iso639-1-2-mapping.nt ]
}

@test "Reference data: YSA labels and YSO mappings" {
  make refdata/ysa-skos-labels.nt
  [ -s refdata/ysa-skos-labels.nt ]
}

@test "Reference data: Corporate names (normalized)" {
  make refdata/cn-labels.nt
  [ -s refdata/cn-labels.nt ]
  # make sure language tags have been stripped
  run grep '"@' refdata/cn-labels.nt
  [ $status -ne 0 ]
}

@test "Reference data: RDA Carrier types" {
  make refdata/RDACarrierType.nt
  [ -s refdata/RDACarrierType.nt ]
}

@test "Reference data: RDA Content types" {
  make refdata/RDAContentType.nt
  [ -s refdata/RDAContentType.nt ]
}

@test "Reference data: RDA Content types shouldn't have double slashes" {
  make refdata/RDAContentType.nt
  run grep 'RDAContentType//' refdata/RDAContentType.nt
  [ $status -ne 0 ]
}

@test "Reference data: RDA Media types" {
  make refdata/RDAMediaType.nt
  [ -s refdata/RDAMediaType.nt ]
}

