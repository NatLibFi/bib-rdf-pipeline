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

@test "Preprocess MARC: drop \$9 subfields with multiple values" {
  make slices/aikuiskasvatus-00602-preprocessed.alephseq
  run grep '000114384,' slices/aikuiskasvatus-00602-preprocessed.alephseq
  [ $status -ne 0 ]
}

@test "Preprocess MARC: convert Fennica SID to 035 field" {
  make slices/kotona-00097-preprocessed.alephseq
  grep -F '000971472 035   L $$a(FI-FENNI)848382' slices/kotona-00097-preprocessed.alephseq
}

@test "Preprocess MARC: keep 880 fields which link to a field we want to keep" {
  make slices/hulluntaivaassa-00490-preprocessed.alephseq
  grep -F ' 880   L $$6260' slices/hulluntaivaassa-00490-preprocessed.alephseq
}

@test "Preprocess MARC: drop 880 fields which link to a field we want to drop" {
  make slices/hulluntaivaassa-00490-preprocessed.alephseq
  run grep -F ' 880   L $$6650' slices/hulluntaivaassa-00490-preprocessed.alephseq
  [ $status -ne 0 ]
}
