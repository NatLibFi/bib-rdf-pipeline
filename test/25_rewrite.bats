#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Rewrite URIs: basic rewriting" {
  rm -f slices/kotona-00097-rewritten.nt
  make -j2 rewrite
  [ -s slices/kotona-00097-rewritten.nt ]
}

@test "Rewrite URIs: work URIs from the record itself" {
  make slices/raamattu-00000-rewritten.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:W00000662900> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/bibframe/Work>' slices/raamattu-00000-rewritten.nt
}

@test "Rewrite URIs: instance URIs from the record itself" {
  make slices/raamattu-00000-rewritten.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:I00000662900> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/bibframe/Instance>' slices/raamattu-00000-rewritten.nt
}

@test "Rewrite URIs: rewriting person URIs" {
  make slices/origwork-00004-rewritten.nt
  make slices/origwork-00041-rewritten.nt
  # author uses 01 sequence number
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:P00004118101> <http://www.w3.org/2000/01/rdf-schema#label> "Burgess, Alan' slices/origwork-00004-rewritten.nt
  # subject uses 02 sequence number
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:P00004118102> <http://www.w3.org/2000/01/rdf-schema#label> "Roseveare, Helen' slices/origwork-00004-rewritten.nt
  # translator uses 03 sequence number
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:P00004118103> <http://www.w3.org/2000/01/rdf-schema#label> "Aho, Oili' slices/origwork-00004-rewritten.nt
  # if there is no main author, then the first contributor (700) uses 01 sequence number
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:P00041961501> <http://www.w3.org/2000/01/rdf-schema#label> "Krolick, Bettye' slices/origwork-00041-rewritten.nt
}

@test "Rewrite URIs: rewriting organization URIs" {
  make slices/forfattning-00006-rewritten.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:O00006154401> <http://www.w3.org/2000/01/rdf-schema#label> "Finland Justitieministeriet' slices/forfattning-00006-rewritten.nt
}

@test "Rewrite URIs: rewriting series URIs" {
  make slices/origwork-00041-rewritten.nt
  # 1st series statement uses 01 sequence number
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:W00041961502> <http://www.w3.org/2000/01/rdf-schema#label> "Braille-neuvottelukunnan julkaisuja' slices/origwork-00041-rewritten.nt
  # 2nd series statement uses 02 sequence number
  grep -q -F '<http://urn.fi/URN:NBN:fi:bib:me:W00041961503> <http://www.w3.org/2000/01/rdf-schema#label> "Braille-delegationens publikationer' slices/origwork-00041-rewritten.nt
}

@test "Rewrite URIs: quoting bad URLs" {
  make slices/bad-url-00639-rewritten.nt slices/bad-url-00642-rewritten.nt
  grep -q 'SYNTAX ERROR, quoting' slices/bad-url-00639-rewritten.log
  grep -q -F '<http://formin.finland.fi/public/download.aspx?ID=96845&GUID=%7BE3C53F54-3FA3-4A33-BA1E-C55F5CA16703%7D>' slices/bad-url-00639-rewritten.nt
  grep -q 'SYNTAX ERROR, quoting' slices/bad-url-00642-rewritten.log
  grep -q -F '<http:%5C%5Cwww.ullaneule.net/>' slices/bad-url-00642-rewritten.nt
}

@test "Rewrite URIs: skipping bad URLs that cannot be quoted" {
  make slices/bad-url-00733-rewritten.nt
  grep -q 'SYNTAX ERROR, skipping' slices/bad-url-00733-rewritten.log
  run grep 'http://ethesis.helsinki.fi/julkaisut/kay/fonet/vk/rautakoski/' slices/bad-url-00733-rewritten.nt 
  [ $status -ne 0 ]
}
