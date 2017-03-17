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

@test "MARCXML: adds missing 765 for translations" {
  make slices/ajanlyhythistoria-00009.mrcx
  xmllint --format slices/ajanlyhythistoria-00009.mrcx | grep -A 3 'tag="765"' | grep 'marc:subfield code="s">A brief history of time'
}

@test "MARCXML: removes \$2=rdacontent subfield from 336" {
  make slices/kotona-00720.mrcx
  ! xmllint --format slices/kotona-00720.mrcx | grep -A 4 'tag="336"' | grep 'marc:subfield code="2"'
}

@test "MARCXML: removes \$2=rdamedia subfield from 337" {
  make slices/kotona-00720.mrcx
  ! xmllint --format slices/kotona-00720.mrcx | grep -A 4 'tag="337"' | grep 'marc:subfield code="2"'
}

@test "MARCXML: removes birth/death years from living people" {
  make slices/kotona-00508.mrcx
  ! xmllint --format slices/kotona-00508.mrcx | grep -A 1 'Valtaoja, Esko' | grep 'marc:subfield code="d"'
  make slices/origwork-00041.mrcx
  ! xmllint --format slices/origwork-00041.mrcx | grep -A 1 'Tanskanen, Raimo' | grep 'marc:subfield code="d"'
}

@test "MARCXML: removes birth/death years from recently dead people" {
  make slices/kollaakestaa-00003.mrcx
  ! xmllint --format slices/kollaakestaa-00003.mrcx | grep -A 1 'Palolampi, Erkki' | grep 'marc:subfield code="d"'
}

@test "MARCXML: removes birth/death years from people who still could be living or recently dead" {
  make slices/kotkankasvisto-00641.mrcx
  ! xmllint --format slices/kotkankasvisto-00641.mrcx | grep -A 1 'Laitinen, Johannes' | grep 'marc:subfield code="d"'
}

@test "MARCXML: keeps birth/death years for long dead people" {
  make slices/fanrik-manninen-00094.mrcx
  xmllint --format slices/fanrik-manninen-00094.mrcx | grep -A 1 'Runeberg, Johan Ludvig' | grep -q 'marc:subfield code="d"'
  xmllint --format slices/fanrik-manninen-00094.mrcx | grep -A 1 'Edelfelt, Albert' | grep -q 'marc:subfield code="d"'
  xmllint --format slices/fanrik-manninen-00094.mrcx | grep -A 1 'Manninen, Otto' | grep -q 'marc:subfield code="d"'
}

@test "MARCXML: keeps birth/death years for long dead people, even if death year is unknown" {
  make slices/punataudista-00084.mrcx
  xmllint --format slices/punataudista-00084.mrcx | grep -A 1 'Laitinen, Johannes' | grep -q 'marc:subfield code="d"'
}

@test "MARCXML: keeps birth/death years for long dead people, even if information is uncertain" {
  make slices/tvennekomedier-00034.mrcx
  xmllint --format slices/tvennekomedier-00034.mrcx | grep -A 1 'Chronander, Jacob Pettersson' | grep -q 'marc:subfield code="d"'
}
