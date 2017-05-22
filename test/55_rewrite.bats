#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Rewrite URIs: basic rewriting" {
  rm -f merged/hawking-rewritten.hdt
  make -j2 rewrite
  [ -s merged/hawking-rewritten.hdt ]
}

@test "Rewrite URIs: work URIs from the record itself" {
  make merged/raamattu-rewritten.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:W00000662900> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/bibframe/Work>' merged/raamattu-rewritten.nt
}

@test "Rewrite URIs: instance URIs from the record itself" {
  make merged/raamattu-rewritten.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:I00000662900> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/bibframe/Instance>' merged/raamattu-rewritten.nt
}

@test "Rewrite URIs: rewriting person URIs" {
  make merged/origwork-rewritten.nt
  # author uses 01 sequence number
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:A00004118101> <http://schema.org/name> "Burgess, Alan"' merged/origwork-rewritten.nt
  # translator uses 02 sequence number
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:A00004118102> <http://schema.org/name> "Aho, Oili"' merged/origwork-rewritten.nt
  # if there is no main author, then the first contributor (700) uses 01 sequence number
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:A00041961501> <http://schema.org/name> "Krolick, Bettye"' merged/origwork-rewritten.nt
}

@test "Rewrite URIs: rewriting series URIs" {
  make merged/origwork-rewritten.nt
  # 1st series statement uses 01 sequence number
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:S00041961501> <http://schema.org/name> "Braille-neuvottelukunnan julkaisuja"' merged/origwork-rewritten.nt
  # 2nd series statement uses 02 sequence number
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:S00041961502> <http://schema.org/name> "Braille-delegationens publikationer"' merged/origwork-rewritten.nt
}

@test "Rewrite URIs: work URIs when the URI from the record itself has been merged with another" {
  make merged/hawking-rewritten.nt
  # check that the index number 00 is not used
  ! grep -F '<http://urn.fi/URN:NBN:fi:bib:me:W00734304600>' merged/hawking-rewritten.nt
  # check that the original work uses 01 index number instead of 00
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:W00734304601> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/bibframe/Work>' merged/hawking-rewritten.nt
}
