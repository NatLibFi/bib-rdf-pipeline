#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Schema.org RDF: basic conversion" {
  rm -f slices/*-schema.nt
#  make -j2 schema
#  [ -s slices/kotona-00097-schema.nt ]
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

@test "Schema.org RDF: modelling author as schema:author, not schema:creator" {
  make slices/ajanlyhythistoria-00009-schema.nt
  ! grep -q -F '<http://schema.org/creator>' slices/ajanlyhythistoria-00009-schema.nt
  run grep -c -F '<http://schema.org/author>' slices/ajanlyhythistoria-00009-schema.nt
  [ "$output" -eq "3" ]
}

@test "Schema.org RDF: organization name should not end in full stop" {
  make slices/jakaja-00005-schema.nt
  ! grep -q -F '<http://schema.org/name> "Kauppa- ja teollisuusministeriö "' slices/jakaja-00005-schema.nt
}

@test "Schema.org RDF: modelling organization authors as schema:Organization" {
  make slices/jakaja-00005-schema.nt
  # find out the URI of the org-author
  uri="$(grep '<http://schema.org/name> \"Perustuslakien valtiontaloussäännösten uudistamiskomitea\"' slices/jakaja-00005-schema.nt | cut -d ' ' -f 1)"
  # make sure it is set to something
  [ -n $uri ]
  # check that it's and Organization
  grep -q -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>" slices/jakaja-00005-schema.nt
  # double-check that it's not a Person
  ! grep -q -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person>" slices/jakaja-00005-schema.nt
}

@test "Schema.org RDF: modelling organization contributors as schema:Organization" {
  make slices/jakaja-00005-schema.nt
  # find out the URI of the org-contributor
  uri="$(grep '<http://schema.org/name> \"Lappeenrannan teknillinen korkeakoulu. Energiatekniikan osasto\"' slices/jakaja-00005-schema.nt | cut -d ' ' -f 1)"
  # make sure it is set to something
  [ -n $uri ]
  # check that it's and Organization
  grep -q -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>" slices/jakaja-00005-schema.nt
  # double-check that it's not a Person
  ! grep -q -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person>" slices/jakaja-00005-schema.nt
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

@test "Schema.org RDF: including part information in names" {
  make slices/titlepart-00077-schema.nt
  grep -q '<http://schema.org/name> "Kootut teokset : 3, Näytelmiä: Olviretki Schleusingenissä ; Leo ja Liisa ; Canzino ; Selman juonet ; Alma"' slices/titlepart-00077-schema.nt
  grep -q '<http://schema.org/name> "Kootut lastut : 1"' slices/titlepart-00077-schema.nt
  grep -q '<http://schema.org/name> "Dekamerone : Neljäs päivä ja siihen kuuluvat 10 kertomusta"' slices/titlepart-00077-schema.nt
}
