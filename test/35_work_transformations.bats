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
  count="$(cut -d ' ' -f 3 refdata/hawking-work-transformations.nt | grep -c '000095841#Work>')"
  [ "$count" -eq 5 ]
}

@test "Work transformations: prefer URIs for main works" {
  make refdata/kotona-work-transformations.nt
  grep -v -F '<http://urn.fi/URN:NBN:fi:bib:me:005083536#Work> <http://schema.org/sameAs> <http://urn.fi/URN:NBN:fi:bib:me:000971472#Work240-13>' refdata/kotona-work-transformations.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:000971472#Work240-13> <http://schema.org/sameAs> <http://urn.fi/URN:NBN:fi:bib:me:005083536#Work>' refdata/kotona-work-transformations.nt
}

@test "Work transformations: prefer 240-generated URIs for works over 600-generated URIs" {
  make refdata/trauma-work-transformations.nt
  grep -v -F '<http://urn.fi/URN:NBN:fi:bib:me:000727468#Work240-14> <http://schema.org/sameAs> <http://urn.fi/URN:NBN:fi:bib:me:005838226#Work600-36>' refdata/trauma-work-transformations.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:005838226#Work600-36> <http://schema.org/sameAs> <http://urn.fi/URN:NBN:fi:bib:me:000727468#Work240-14>' refdata/trauma-work-transformations.nt
}
