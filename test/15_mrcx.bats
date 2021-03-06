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

@test "MARCXML: removes birth/death years from living people" {
  make slices/kotona-00508.mrcx
  run bash -c "xmllint --format slices/kotona-00508.mrcx | grep -A 1 'Valtaoja, Esko' | grep 'marc:subfield code=.d.'"
  [ "$status" -ne 0 ]
  make slices/monot-00487.mrcx
  run bash -c "xmllint --format slices/monot-00487.mrcx | grep -A 1 'Harjanne, Maikki' | grep 'marc:subfield code=.d.'"
  [ "$status" -ne 0 ]
  make slices/origwork-00041.mrcx
  run bash -c "xmllint --format slices/origwork-00041.mrcx | grep -A 1 'Tanskanen, Raimo' | grep 'marc:subfield code=.d.'"
  [ "$status" -ne 0 ]
}

@test "MARCXML: removes trailing punctuation from names of people with removed birth/death years" {
  make slices/kotona-00508.mrcx
  run bash -c "xmllint --format slices/kotona-00508.mrcx | grep 'Valtaoja, Esko,'"
  [ "$status" -ne 0 ]
  make slices/monot-00487.mrcx
  run bash -c "xmllint --format slices/monot-00487.mrcx | grep 'Harjanne, Maikki,'"
  [ "$status" -ne 0 ]
  make slices/origwork-00041.mrcx
  run bash -c "xmllint --format slices/origwork-00041.mrcx | grep 'Tanskanen, Raimo,'"
  [ "$status" -ne 0 ]
}

@test "MARCXML: keeps birth/death years for dead people" {
  make slices/fanrik-manninen-00094.mrcx
  xmllint --format slices/fanrik-manninen-00094.mrcx | grep -A 1 'Runeberg, Johan Ludvig' | grep -q 'marc:subfield code="d"'
  xmllint --format slices/fanrik-manninen-00094.mrcx | grep -A 1 'Edelfelt, Albert' | grep -q 'marc:subfield code="d"'
  xmllint --format slices/fanrik-manninen-00094.mrcx | grep -A 1 'Manninen, Otto' | grep -q 'marc:subfield code="d"'
  xmllint --format slices/kollaakestaa-00003.mrcx | grep -A 1 'Palolampi, Erkki' | grep -q 'marc:subfield code="d"'
}

@test "MARCXML: keeps birth/death years for long dead people, even if death year is unknown" {
  make slices/punataudista-00084.mrcx
  xmllint --format slices/punataudista-00084.mrcx | grep -A 1 'Laitinen, Johannes' | grep -q 'marc:subfield code="d"'
  xmllint --format slices/kotkankasvisto-00641.mrcx | grep -A 1 'Ulvinen, Arvi' | grep -q 'marc:subfield code="d"'
}

@test "MARCXML: keeps birth/death years for long dead people, even if information is uncertain" {
  make slices/tvennekomedier-00034.mrcx
  xmllint --format slices/tvennekomedier-00034.mrcx | grep -A 1 'Chronander, Jacob Pettersson' | grep -q 'marc:subfield code="d"'
}

@test "MARCXML: avoid concatenating names of authors (may happen with older versions of Catmandu)" {
  make slices/part-uri-00683.mrcx
  xmllint --format slices/part-uri-00683.mrcx | grep -q -F '<marc:subfield code="a">Pelto-Huikko, Aino</marc:subfield>'
  ! xmllint --format slices/part-uri-00683.mrcx | grep 'Kaunisto, TuijaPelto-Huikko, Aino'
}

@test "MARCXML: removes 490 fields if a 830 field is present" {
  make slices/kotona-00508.mrcx
  run bash -c "xmllint --format slices/kotona-00508.mrcx | grep 'tag=\"490\"'"
  [ "$status" -ne 0 ]
}

@test "MARCXML: retains 490 fields if no 830 fields are present" {
  make slices/sjubroder-00450.mrcx
  xmllint --format slices/sjubroder-00450.mrcx | grep -q 'tag="490"'
}

@test "MARCXML: cleans up bad 260c values" {
  make slices/suoja-pirtti-00000.mrcx
  run bash -c "xmllint --format slices/suoja-pirtti-00000.mrcx | grep -A 3 'tag=.260.' | grep 'code=.c.' | grep 'Merkur'"
  [ "$status" -ne 0 ]
}
