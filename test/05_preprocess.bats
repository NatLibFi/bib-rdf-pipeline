#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Preprocess MARC: basic preprocessing" {
  rm -f slices/kotona-00097-preprocessed.alephseq
  make -j2 preprocess
  [ -s slices/kotona-00097-preprocessed.alephseq ]
}

@test "Preprocess MARC: contains YSA subject" {
  make slices/ajanlyhythistoria-00009-preprocessed.alephseq
  grep -q maailmankaikkeus slices/ajanlyhythistoria-00009-preprocessed.alephseq
}

@test "Preprocess MARC: drops subject without KEEP tag" {
  make slices/ajanlyhythistoria-00009-preprocessed.alephseq
  run grep kosmologia slices/ajanlyhythistoria-00009-preprocessed.alephseq
  [ $status -ne 0 ]
}

@test "Preprocess MARC: drop duplicate 130 fields" {
  make slices/sioninwirret-00061-preprocessed.alephseq
  run grep -c -F ' 130' slices/sioninwirret-00061-preprocessed.alephseq
  [ "$output" -eq "1" ]
}
