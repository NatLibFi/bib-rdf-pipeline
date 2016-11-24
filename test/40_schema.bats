#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Schema.org RDF: basic conversion" {
  rm -f slices/*-schema.nt
  make schema
  [ -s slices/kotona-00097-schema.nt ]
}

@test "Schema.org RDF: quoting bad URLs" {
  make slices/bad-url-00639-schema.nt slices/bad-url-00642-schema.nt
  grep -q 'SYNTAX ERROR, quoting' slices/bad-url-00639-schema.log
  grep -q -F '<http://formin.finland.fi/public/download.aspx?ID=96845&GUID=%7BE3C53F54-3FA3-4A33-BA1E-C55F5CA16703%7D>' slices/bad-url-00639-schema.nt
  grep -q 'SYNTAX ERROR, quoting' slices/bad-url-00642-schema.log
  grep -q -F '<http:%5C%5Cwww.ullaneule.net/>' slices/bad-url-00642-schema.nt
}

@test "Schema.org RDF: skipping bad URLs that cannot be quoted" {
  make slices/bad-url-00733-schema.nt
  grep -q 'SYNTAX ERROR, skipping' slices/bad-url-00733-schema.log
  ! grep -q 'http://ethesis.helsinki.fi/julkaisut/kay/fonet/vk/rautakoski/' slices/bad-url-00733-schema.nt 
}

@test "Schema.org RDF: converting language codes to ISO 639-1" {
  make slices/ajattelemisenalku-00098-schema.nt
  grep -q -F '<http://schema.org/inLanguage> "fi"' slices/ajattelemisenalku-00098-schema.nt
  ! grep -q -F '<http://schema.org/inLanguage> "fin"' slices/ajattelemisenalku-00098-schema.nt
}

@test "Schema.org RDF: converting to YSA URIs, basic case" {
  make slices/ajattelemisenalku-00098-schema.nt
  # "myytit" -> ysa:Y97600
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/ysa/Y97600>' slices/ajattelemisenalku-00098-schema.nt
  ! grep -q -F '<http://schema.org/about> "myytit"' slices/ajattelemisenalku-00098-schema.nt
}

@test "Schema.org RDF: converting to YSA URIs, coordinated case" {
  make slices/ajattelemisenalku-00098-schema.nt
  # "filosofia -- antiikki" -> ysa:Y95164
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/ysa/Y95164>' slices/ajattelemisenalku-00098-schema.nt
  ! grep -q -F '<http://schema.org/about> "filosofia--antiikki"' slices/ajattelemisenalku-00098-schema.nt
  ! grep -q -F '<http://schema.org/about> "filosofia -- antiikki"' slices/ajattelemisenalku-00098-schema.nt
}

@test "Schema.org RDF: converting to YSA URIs, not found in YSA case" {
  make slices/ajattelemisenalku-00098-schema.nt
  # "kirjallisuus -- antiikki" -> remains as literal
  grep -q -F '<http://schema.org/about> "kirjallisuus -- antiikki"@fi' slices/ajattelemisenalku-00098-schema.nt
}

@test "Schema.org RDF: converting to YSO URIs" {
  make slices/ajattelemisenalku-00098-schema.nt
  # "myytit" -> ysa:Y97600 -> yso:p1248
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/yso/p1248>' slices/ajattelemisenalku-00098-schema.nt
}

@test "Schema.org RDF: modelling author as schema:author, not schema:creator" {
  make slices/ajanlyhythistoria-00009-schema.nt
  ! grep -q -F '<http://schema.org/creator>' slices/ajanlyhythistoria-00009-schema.nt
  run grep -c -F '<http://schema.org/author>' slices/ajanlyhythistoria-00009-schema.nt
  [ "$output" -eq "3" ]
}

@test "Schema.org RDF: including instance subtitle as part of name" {
  make slices/kotona-00097-schema.nt
  grep -q '<http://schema.org/name> "Im Universum zu Hause : eine Entdeckungsreise"' slices/kotona-00097-schema.nt
}

@test "Schema.org RDF: name does not end in full stop" {
  make slices/ekumeeninen-00585-schema.nt
  grep -q '<http://schema.org/name> "Suomen ekumeeninen neuvosto : toimintakertomus 2009 = Ekumeniska rådet i Finland : verksamhetsberättelse 2009"' slices/ekumeeninen-00585-schema.nt
}

@test "Schema.org RDF: including parallel titles as names" {
  make slices/ekumeeninen-00585-schema.nt
  grep -q '<http://schema.org/name> "Ekumeniska rådet i Finland verksamhetsberättelse 2009"' slices/ekumeeninen-00585-schema.nt
}
