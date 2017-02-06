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
  ! grep -q kosmologia slices/ajanlyhythistoria-00009-preprocessed.alephseq
}

