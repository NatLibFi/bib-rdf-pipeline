#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "MARCXML: basic conversion" {
  rm -f slices/kotona-00097.mrcx
  make -j2 mrcx
  [ -s slices/kotona-00097.mrcx ]
}

@test "MARCXML: skips prepublication records" {
  make slices/prepub-00566.mrcx
  run bash -c "xmllint --format slices/prepub-00566.mrcx | grep '001' | grep 005663958"
  [ "$status" -eq 1 ]
}

@test "MARCXML: contains YSA subject" {
  make slices/ajanlyhythistoria-00009.mrcx
  grep -q maailmankaikkeus slices/ajanlyhythistoria-00009.mrcx
}

@test "MARCXML: drops subject without KEEP tag" {
  make slices/ajanlyhythistoria-00009.mrcx
  run grep -q kosmologia slices/ajanlyhythistoria-00009.mrcx
  [ "$status" -eq 1 ]
}

@test "MARCXML: adds missing 240\$a from 500 note" {
  make slices/origwork-00004.mrcx
  xmllint --format slices/origwork-00004.mrcx | grep -A 1 'tag="240"' | grep 'marc:subfield code="a">DAYLIGHT MUST COME'
  ! xmllint --format slices/origwork-00004.mrcx | grep -A 1 'tag="500"' | grep 'marc:subfield code="a">ENGL. ALKUTEOS: DAYLIGHT MUST COME'
}

@test "MARCXML: adds missing 240\$a from 500 note (with extra space)" {
  make slices/origwork-00271.mrcx
  xmllint --format slices/origwork-00271.mrcx | grep -A 1 'tag="240"' | grep 'marc:subfield code="a">Nationalökonimien i hovedtraek'
  ! xmllint --format slices/origwork-00271.mrcx | grep -A 1 'tag="500"' | grep 'marc:subfield code="a">Alkuteos : Nationalökonimien i hovedtraek.'
}

@test "MARCXML: adds missing 240\$a from 130\$a" {
  make slices/origwork-00041.mrcx
  xmllint --format slices/origwork-00041.mrcx | grep -A 1 'tag="240"' | grep 'marc:subfield code="a">New international manual of Braille music notation'
}

@test "MARCXML: adds missing 240\$l subfield" {
  make slices/ajanlyhythistoria-00009.mrcx
  xmllint --format slices/ajanlyhythistoria-00009.mrcx | grep -A 3 'tag="240"' | grep 'marc:subfield code="l"'
}

@test "MARCXML: removes \$2=rdacontent subfield from 336" {
  make slices/kotona-00720.mrcx
  ! xmllint --format slices/kotona-00720.mrcx | grep -A 4 'tag="336"' | grep 'marc:subfield code="2"'
}

@test "MARCXML: removes \$2=rdamedia subfield from 337" {
  make slices/kotona-00720.mrcx
  ! xmllint --format slices/kotona-00720.mrcx | grep -A 4 'tag="337"' | grep 'marc:subfield code="2"'
}
