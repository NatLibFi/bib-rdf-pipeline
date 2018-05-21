#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Work transformations: basic generation" {
  rm -f refdata/fanrik-manninen-work-transformations.nt
  make -j2 work-transformations
  [ -s refdata/fanrik-manninen-work-transformations.nt ]
}

@test "Work transformations: translations are consolidated to same original work" {
  make refdata/hawking-work-transformations.nt
  count="$(cut -d ' ' -f 3 refdata/hawking-work-transformations.nt | grep -c 'W00009584101>')"
  [ "$count" -eq 3 ]
}

@test "Work transformations: different translations to the same language are kept apart" {
  make refdata/sjubroder-work-transformations.nt
  diktonius="$(cut -d ' ' -f 3 refdata/sjubroder-work-transformations.nt | grep -c 'W00010308600>')"
  [ "$diktonius" -eq 8 ]
  lauren="$(cut -d ' ' -f 3 refdata/sjubroder-work-transformations.nt | grep -c 'W00052290400>')"
  [ "$lauren" -eq 4 ]
}

@test "Work transformations: prefer URIs for main works" {
  make refdata/kotona-work-transformations.nt
  grep -v -F '<http://urn.fi/URN:NBN:fi:bib:me:W00508353600> <http://www.w3.org/2002/07/owl#sameAs> <http://urn.fi/URN:NBN:fi:bib:me:W00097147201>' refdata/kotona-work-transformations.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:W00097147201> <http://www.w3.org/2002/07/owl#sameAs> <http://urn.fi/URN:NBN:fi:bib:me:W00508353600>' refdata/kotona-work-transformations.nt
}

@test "Work transformations: prefer 240-generated URIs for works over 600-generated URIs" {
  make refdata/trauma-work-transformations.nt
  grep -v -F '<http://urn.fi/URN:NBN:fi:bib:me:W00072746801> <http://www.w3.org/2002/07/owl#sameAs> <http://urn.fi/URN:NBN:fi:bib:me:W00583822610>' refdata/trauma-work-transformations.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:W00583822610> <http://www.w3.org/2002/07/owl#sameAs> <http://urn.fi/URN:NBN:fi:bib:me:W00072746801>' refdata/trauma-work-transformations.nt
}
