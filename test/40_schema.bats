#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Schema.org RDF: basic conversion" {
  rm -f slices/kotona-00097-schema.nt
  make -j2 schema
  [ -s slices/kotona-00097-schema.nt ]
}

@test "Schema.org RDF: conversion of bf:Work and bf:Instance to schema:CreativeWork" {
  make slices/raamattu-00000-schema.nt
  run grep -c -F '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/CreativeWork>' slices/raamattu-00000-schema.nt
  [ "$output" -eq "2" ]
  grep -q '<http://schema.org/exampleOfWork>' slices/raamattu-00000-schema.nt
  grep -q '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt
}

@test "Schema.org RDF: conversion of titles" {
  make slices/raamattu-00000-schema.nt
  work="$(grep '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt | cut -d ' ' -f 1)"
  inst="$(grep '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt | cut -d ' ' -f 3)"
  grep -q "$work <http://schema.org/name> \"Pyhä Raamattu\"" slices/raamattu-00000-schema.nt
  grep -q "$inst <http://schema.org/name> \"Pyhä Raamattu\"" slices/raamattu-00000-schema.nt
}

@test "Schema.org RDF: conversion of notes" {
  make slices/raamattu-00000-schema.nt
  inst="$(grep '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt | cut -d ' ' -f 3)"
  grep -q "$inst <http://schema.org/description> \"Selkänimeke: Raamattu.\"" slices/raamattu-00000-schema.nt
}

@test "Schema.org RDF: conversion of languages" {
  make slices/raamattu-00000-schema.nt
  work="$(grep '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt | cut -d ' ' -f 1)"
  grep -q "$work <http://schema.org/inLanguage> \"fin\"" slices/raamattu-00000-schema.nt
  # check that original language is not declared for the translated work
  ! grep -q "$work <http://schema.org/inLanguage> \"grc\"" slices/raamattu-00000-schema.nt
  ! grep -q "$work <http://schema.org/inLanguage> \"heb\"" slices/raamattu-00000-schema.nt
}

@test "Schema.org RDF: conversion of number of pages" {
  make slices/raamattu-00000-schema.nt
  inst="$(grep '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt | cut -d ' ' -f 3)"
  grep -q "$inst <http://schema.org/numberOfPages> \"363 s.\"" slices/raamattu-00000-schema.nt
}

@test "Schema.org RDF: conversion of publication year" {
  make slices/raamattu-00000-schema.nt
  inst="$(grep '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt | cut -d ' ' -f 3)"
  grep -q "$inst <http://schema.org/datePublished> \"1984\"" slices/raamattu-00000-schema.nt
}

@test "Schema.org RDF: conversion of author (original work, translated work and instance)" {
  make slices/ajanlyhythistoria-00009-schema.nt
  run grep -c -F '<http://schema.org/author>' slices/ajanlyhythistoria-00009-schema.nt
  [ "$output" -eq "3" ]
  # check that schema:creator is not used by mistake
  ! grep -q -F '<http://schema.org/creator>' slices/ajanlyhythistoria-00009-schema.nt
}

@test "Schema.org RDF: conversion of publisher" {
  make slices/raamattu-00000-schema.nt
  inst="$(grep '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt | cut -d ' ' -f 3)"
  # find the uri/bnode of the publisher
  uri="$(grep "$inst <http://schema.org/publisher>" slices/raamattu-00000-schema.nt | cut -d ' ' -f 3)"
  # make sure it's set to something
  [ -n "$uri" ]
  # check the name of the publisher
  grep -q -F "$uri <http://schema.org/name> \"Suomen pipliaseura\"" slices/raamattu-00000-schema.nt
  # check the type of the publisher
  grep -q -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>" slices/raamattu-00000-schema.nt
}

@test "Schema.org RDF: conversion of RDA content types" {
  make slices/raamattu-00000-schema.nt
  work="$(grep '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt | cut -d ' ' -f 1)"
  grep -q "$work <http://rdaregistry.info/Elements/u/P60049> \"teksti\"" slices/raamattu-00000-schema.nt
}

@test "Schema.org RDF: conversion of RDA carrier types" {
  make slices/raamattu-00000-schema.nt
  inst="$(grep '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt | cut -d ' ' -f 3)"
  grep -q "$inst <http://rdaregistry.info/Elements/u/P60048> \"nide\"" slices/raamattu-00000-schema.nt
}

@test "Schema.org RDF: conversion of RDA media types" {
  make slices/raamattu-00000-schema.nt
  inst="$(grep '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt | cut -d ' ' -f 3)"
  grep -q "$inst <http://rdaregistry.info/Elements/u/P60050> \"käytettävissä ilman laitetta\"" slices/raamattu-00000-schema.nt
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


@test "Schema.org RDF: organization name should not end in full stop" {
  make slices/jakaja-00005-schema.nt
  ! grep -q -F '<http://schema.org/name> "Kauppa- ja teollisuusministeriö "' slices/jakaja-00005-schema.nt
}

@test "Schema.org RDF: strip 'jakelija:' prefix from organization name" {
  make slices/superkumikana-cd-00611-schema.nt
  grep -q -F '<http://schema.org/name> "BTJ Finland"' slices/superkumikana-cd-00611-schema.nt
  ! grep -q -F '<http://schema.org/name> "jakelija: BTJ Finland"' slices/superkumikana-cd-00611-schema.nt
}

@test "Schema.org RDF: strip 'jakaja' suffix from organization name" {
  make slices/jakaja-00005-schema.nt
  grep -q -F '<http://schema.org/name> "Valtion painatuskeskus"' slices/jakaja-00005-schema.nt
  ! grep -q -F '<http://schema.org/name> "Valtion painatuskeskus, jakaja"' slices/jakaja-00005-schema.nt
  ! grep -q -F '<http://schema.org/name> "Valtion painatuskeskus jakaja"' slices/jakaja-00005-schema.nt
}

@test "Schema.org RDF: modelling organization authors as schema:Organization" {
  make slices/jakaja-00005-schema.nt
  # find out the URI of the org-author
  uri="$(grep '<http://schema.org/name> \"Perustuslakien valtiontaloussäännösten uudistamiskomitea\"' slices/jakaja-00005-schema.nt | cut -d ' ' -f 1)"
  # make sure it is set to something
  [ -n "$uri" ]
  # check that it's an Organization
  grep -q -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>" slices/jakaja-00005-schema.nt
  # double-check that it's not a Person
  ! grep -q -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person>" slices/jakaja-00005-schema.nt
}

@test "Schema.org RDF: modelling organization contributors as schema:Organization" {
  make slices/jakaja-00005-schema.nt
  # find out the URI of the org-contributor
  uri="$(grep '<http://schema.org/name> \"Lappeenrannan teknillinen korkeakoulu. Energiatekniikan osasto\"' slices/jakaja-00005-schema.nt | cut -d ' ' -f 1)"
  # make sure it is set to something
  [ -n "$uri" ]
  # check that it's an Organization
  grep -q -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>" slices/jakaja-00005-schema.nt
  # double-check that it's not a Person
  ! grep -q -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person>" slices/jakaja-00005-schema.nt
}

@test "Schema.org RDF: modelling organization subjects as schema:Organization" {
  make slices/etyk-00012-schema.nt
  # find out the URI of the org-subject
  uri="$(grep '<http://schema.org/name> \"Euroopan turvallisuus- ja yhteistyöjärjestö\"' slices/etyk-00012-schema.nt | cut -d ' ' -f 1)"
  # make sure it is set to something
  [ -n "$uri" ]
  # check that it's an Organization
  grep -q -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>" slices/etyk-00012-schema.nt
}

@test "Schema.org RDF: modelling meeting subjects as schema:Organization" {
  make slices/etyk-00012-schema.nt
  # find out the URI of the org-subject
  uri="$(grep '<http://schema.org/name> \"Euroopan turvallisuus- ja yhteistyökonferenssi\"' slices/etyk-00012-schema.nt | cut -d ' ' -f 1)"
  # make sure it is set to something
  [ -n "$uri" ]
  # check that it's an Organization
  grep -q -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>" slices/etyk-00012-schema.nt
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
