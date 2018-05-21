#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Agent transformations: authors are merged" {
  make refdata/hawking-agent-transformations.nt
  count="$(cut -d ' ' -f 3 refdata/hawking-agent-transformations.nt | grep -c 'P00009584101>')"
  [ "$count" -eq 5 ]
}

@test "Agent transformations: contributors are merged" {
  make refdata/sjubroder-agent-transformations.nt
  count="$(cut -d ' ' -f 3 refdata/hawking-agent-transformations.nt | grep -c 'P00014685402>')"
  [ "$count" -eq 5 ]
}

@test "Agent transformations: prefer authorized persons" {
  make refdata/abckiria-agent-transformations.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:P00310205703> <http://www.w3.org/2002/07/owl#sameAs> <http://urn.fi/URN:NBN:fi:au:pn:000055166>' refdata/abckiria-agent-transformations.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:P00612868401> <http://www.w3.org/2002/07/owl#sameAs> <http://urn.fi/URN:NBN:fi:au:pn:000103346>' refdata/abckiria-agent-transformations.nt

  run grep -F '<http://urn.fi/URN:NBN:fi:au:pn:000055166> <http://www.w3.org/2002/07/owl#sameAs> <http://urn.fi/URN:NBN:fi:bib:me:P00310205703>' refdata/abckiria-agent-transformations.nt
  [ "$status" -ne 0 ]
  run grep -F '<http://urn.fi/URN:NBN:fi:au:pn:000103346> <http://www.w3.org/2002/07/owl#sameAs> <http://urn.fi/URN:NBN:fi:bib:me:P00612868401>' refdata/abckiria-agent-transformations.nt
  [ "$status" -ne 0 ]
}
