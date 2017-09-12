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

@test "Schema.org RDF: conversion of additional types" {
  make slices/raamattu-00000-schema.nt
  work="$(grep '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt | cut -d ' ' -f 1)"
  inst="$(grep '<http://schema.org/workExample>' slices/raamattu-00000-schema.nt | cut -d ' ' -f 3)"
  # Works should be typed schema:CreativeWork and bf:Work
  grep -q "$work <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/CreativeWork>" slices/raamattu-00000-schema.nt
  grep -q "$work <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/bibframe/Work>" slices/raamattu-00000-schema.nt
  # Instances should be typed schema:CreativeWork and bf:Instance
  grep -q "$inst <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/CreativeWork>" slices/raamattu-00000-schema.nt
  grep -q "$inst <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/bibframe/Instance>" slices/raamattu-00000-schema.nt
}

@test "Schema.org RDF: conversion of original work for translation (240 case)" {
  make slices/ajanlyhythistoria-00009-schema.nt
  work="$(grep '<http://schema.org/workExample>' slices/ajanlyhythistoria-00009-schema.nt | cut -d ' ' -f 1)"
  orig="$(grep "$work <http://schema.org/translationOfWork>" slices/ajanlyhythistoria-00009-schema.nt | cut -d ' ' -f 3)"
  # make sure we have some URI/bnode for the original work
  [ -n "$orig" ]
  grep -q "$orig <http://schema.org/name> \"A brief history of time\"" slices/ajanlyhythistoria-00009-schema.nt
  grep -q "$orig <http://schema.org/inLanguage> \"eng\"" slices/ajanlyhythistoria-00009-schema.nt
  grep -q "$orig <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/CreativeWork>" slices/ajanlyhythistoria-00009-schema.nt
  grep -q "$orig <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/bibframe/Work>" slices/ajanlyhythistoria-00009-schema.nt
  grep -q "$orig <http://schema.org/workTranslation> $work" slices/ajanlyhythistoria-00009-schema.nt
}

@test "Schema.org RDF: conversion of original work for translation (765 \$t case)" {
  make slices/forfattning-00006-schema.nt
  work="$(grep '<http://schema.org/workExample>' slices/forfattning-00006-schema.nt | cut -d ' ' -f 1)"
  grep -q "$work <http://schema.org/translationOfWork>" slices/forfattning-00006-schema.nt
  # make sure ISSNs of the original work are preserved too
  grep -q '<http://schema.org/issn> "1237-3419"' slices/forfattning-00006-schema.nt
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
  run grep "$work <http://schema.org/inLanguage> \"grc\"" slices/raamattu-00000-schema.nt
  [ $status -ne 0 ]
  run grep "$work <http://schema.org/inLanguage> \"heb\"" slices/raamattu-00000-schema.nt
  [ $status -ne 0 ]
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
  # check that it's expressed only one way
  run grep -c -F '<http://schema.org/datePublished>' slices/raamattu-00000-schema.nt
  [ "$output" -eq "1" ]
}

@test "Schema.org RDF: conversion of publication event" {
  make slices/punataudista-00084-schema.nt
  # check that there is only one publication event
  run grep -c -F '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/PublicationEvent>' slices/punataudista-00084-schema.nt
  [ "$output" -eq "1" ]
  pubevt="$(grep '<http://schema.org/publication>' slices/punataudista-00084-schema.nt | cut -d ' ' -f 3)"
  # make sure we have some URI/bnode for the publication event
  [ -n "$pubevt" ]
  grep -q "$pubevt <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/PublicationEvent>" slices/punataudista-00084-schema.nt
  grep -q "$pubevt <http://schema.org/startDate> \"1915\"" slices/punataudista-00084-schema.nt
  # check the publication place
  place="$(grep "$pubevt <http://schema.org/location>" slices/punataudista-00084-schema.nt | cut -d ' ' -f 3)"
  [ -n "$place" ]
  grep -q "$place <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Place>" slices/punataudista-00084-schema.nt
  grep -q "$place <http://schema.org/name> \"Tampere\"" slices/punataudista-00084-schema.nt
}

@test "Schema.org RDF: conversion of ISBNs" {
  make slices/ajanlyhythistoria-00009-schema.nt
  inst="$(grep '<http://schema.org/workExample>' slices/ajanlyhythistoria-00009-schema.nt | cut -d ' ' -f 3)"
  grep -q "$inst <http://schema.org/isbn> \"951-0-19440-9\"" slices/ajanlyhythistoria-00009-schema.nt
}

@test "Schema.org RDF: conversion of author (original work and translated work)" {
  make slices/ajanlyhythistoria-00009-schema.nt
  run grep -c -F '<http://schema.org/author>' slices/ajanlyhythistoria-00009-schema.nt
  [ "$output" -eq "2" ]
  # check that schema:creator is not used by mistake
  run grep -F '<http://schema.org/creator>' slices/ajanlyhythistoria-00009-schema.nt
  [ $status -ne 0 ]
}

@test "Schema.org RDF: conversion of authors with ID" {
  make slices/kotkankasvisto-00641-schema.nt
  author="$(grep '<http://schema.org/author>' slices/kotkankasvisto-00641-schema.nt | cut -d ' ' -f 3)"
  [ -n "$author" ]
  grep -q -F "$author <http://schema.org/identifier> \"000061725\"" slices/kotkankasvisto-00641-schema.nt
}

@test "Schema.org RDF: conversion of contributors" {
  make slices/ajanlyhythistoria-00009-schema.nt
  run grep -c -F '<http://schema.org/contributor>' slices/ajanlyhythistoria-00009-schema.nt
  [ "$output" -eq "2" ]
}

@test "Schema.org RDF: conversion of contributors with ID" {
  make slices/jatuli-00000-schema.nt
  contributor="$(grep '<http://schema.org/name> "Keränen, Lauri"' slices/jatuli-00000-schema.nt | cut -d ' ' -f 1)"
  [ -n "$contributor" ]
  grep -q -F "$contributor <http://schema.org/identifier> \"000047367\"" slices/jatuli-00000-schema.nt
}

@test "Schema.org RDF: conversion of contributors with roles" {
  make slices/origwork-00004-schema.nt
  grep -q -F '<http://schema.org/name> "Aho, Oili"' slices/origwork-00004-schema.nt
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
  # check that there is only one publisher (e.g. not manufacturer)
  run grep -c -F '<http://schema.org/publisher>' slices/raamattu-00000-schema.nt
  [ "$output" -eq "1" ]
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

@test "Schema.org RDF: conversion of electronic version (856 with \$y case)" {
  make slices/verkkoaineisto-00608-schema.nt
  work="$(grep '<http://schema.org/workExample>' slices/verkkoaineisto-00608-schema.nt | cut -d ' ' -f 1 | head -n 1)"
  elec="$(grep '<http://schema.org/bookFormat> <http://schema.org/EBook>' slices/verkkoaineisto-00608-schema.nt | cut -d ' ' -f 1)"
  # check that we found an electronic resource
  [ -n "$elec" ]
  # check that it is linked to the work both ways
  grep -q "$work <http://schema.org/workExample> $elec" slices/verkkoaineisto-00608-schema.nt
  grep -q "$elec <http://schema.org/exampleOfWork> $work" slices/verkkoaineisto-00608-schema.nt
  # check that it has the correct information
  grep -q "$elec <http://schema.org/url> <http://urn.fi/URN:ISBN:978-951-39-4908-2>" slices/verkkoaineisto-00608-schema.nt
  grep -q "$elec <http://schema.org/name> \"Open sourcing digital heritage : digital surrogates, museums and knowledge management in the age of open networks\"" slices/verkkoaineisto-00608-schema.nt
  grep -q "$elec <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Book>" slices/verkkoaineisto-00608-schema.nt
  grep -q "$elec <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/CreativeWork>" slices/verkkoaineisto-00608-schema.nt
  grep -q "$elec <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/bibframe/Instance>" slices/verkkoaineisto-00608-schema.nt
}

@test "Schema.org RDF: conversion of electronic version (856 without \$y case)" {
  make slices/fanrik-manninen-00641-schema.nt
  elec="$(grep '<http://schema.org/bookFormat> <http://schema.org/EBook>' slices/fanrik-manninen-00641-schema.nt | cut -d ' ' -f 1)"
  grep -q "$elec <http://schema.org/url> <http://www.gutenberg.org/etext/12757>" slices/fanrik-manninen-00641-schema.nt
}

@test "Schema.org RDF: conversion on electronic version (530 with \$u case)" {
  make slices/jatuli-00000-schema.nt
  elec="$(grep '<http://schema.org/bookFormat> <http://schema.org/EBook>' slices/jatuli-00000-schema.nt | cut -d ' ' -f 1)"
  grep -q "$elec <http://schema.org/url> <http://urn.fi/URN:ISBN:978-0-357-35801-6>" slices/jatuli-00000-schema.nt
  # check that the electronic instance is not a blank node
  [ "${elec:0:1}" != "_" ]
}

@test "Schema.org RDF: conversion of series (main work case)" {
  make slices/forfattning-00006-schema.nt
  work="$(grep '<http://schema.org/workExample>' slices/forfattning-00006-schema.nt | head -n 1 | cut -d ' ' -f 1)"
  [ -n "$work" ]
  grep -q "$work <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Periodical>" slices/forfattning-00006-schema.nt

  inst="$(grep '<http://rdaregistry.info/Elements/u/P60048> "nide"' slices/forfattning-00006-schema.nt | cut -d ' ' -f 1)"
  [ -n "$inst" ]
  grep -q "$inst <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Periodical>" slices/forfattning-00006-schema.nt
  grep -q "$inst <http://schema.org/issn> \"0787-3182\"" slices/forfattning-00006-schema.nt
}

@test "Schema.org RDF: conversion of series (series statement case)" {
  make slices/etyk-00012-schema.nt
  work="$(grep '<http://schema.org/workExample>' slices/etyk-00012-schema.nt | cut -d ' ' -f 1)"
  series="$(grep "<http://schema.org/hasPart> $work" slices/etyk-00012-schema.nt | cut -d ' ' -f 1)"
  # check that we found a series
  [ -n "$series" ]
  # check that it has the correct information
  grep -q "$series <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Periodical>" slices/etyk-00012-schema.nt
  grep -q "$series <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/CreativeWork>" slices/etyk-00012-schema.nt
  grep -q "$series <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/bibframe/Work>" slices/etyk-00012-schema.nt
  grep -q "$series <http://schema.org/name> \"Julkaisusarja / Maanpuolustuskorkeakoulu, strategian laitos. 1, Strategian tutkimuksia\"" slices/etyk-00012-schema.nt
  grep -q "$series <http://schema.org/issn> \"1236-4959\"" slices/etyk-00012-schema.nt
  
}

@test "Schema.org RDF: conversion of series with volumes" {
  # TODO: this is incomplete: we should also convert volume numbers etc. See issue #46
  make slices/origwork-00041-schema.nt
  grep -q -F '<http://schema.org/name> "Braille-neuvottelukunnan julkaisuja"' slices/origwork-00041-schema.nt
  run grep -F '<http://schema.org/name> "Braille-neuvottelukunnan julkaisuja ;"' slices/origwork-00041-schema.nt
  [ $status -ne 0 ]
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
  run grep 'http://ethesis.helsinki.fi/julkaisut/kay/fonet/vk/rautakoski/' slices/bad-url-00733-schema.nt 
  [ $status -ne 0 ]
}

@test "Schema.org RDF: organization name should not end in full stop" {
  make slices/jakaja-00005-schema.nt
  run grep -F '<http://schema.org/name> "Kauppa- ja teollisuusministeriö "' slices/jakaja-00005-schema.nt
  [ $status -ne 0 ]
}

@test "Schema.org RDF: strip 'jakelija:' prefix from organization name" {
  make slices/superkumikana-cd-00611-schema.nt
  grep -q -F '<http://schema.org/name> "BTJ Finland"' slices/superkumikana-cd-00611-schema.nt
  run grep -F '<http://schema.org/name> "jakelija: BTJ Finland"' slices/superkumikana-cd-00611-schema.nt
  [ $status -ne 0 ]
}

@test "Schema.org RDF: strip 'jakaja' suffix from organization name" {
  make slices/jakaja-00005-schema.nt
  grep -q -F '<http://schema.org/name> "Valtion painatuskeskus"' slices/jakaja-00005-schema.nt
  run grep -F '<http://schema.org/name> "Valtion painatuskeskus, jakaja"' slices/jakaja-00005-schema.nt
  [ $status -ne 0 ]
  run grep -F '<http://schema.org/name> "Valtion painatuskeskus jakaja"' slices/jakaja-00005-schema.nt
  [ $status -ne 0 ]
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
  run grep -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person>" slices/jakaja-00005-schema.nt
  [ $status -ne 0 ]
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
  run grep -F "$uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person>" slices/jakaja-00005-schema.nt
  [ $status -ne 0 ]
}

@test "Schema.org RDF: conversion of 600 \$a person subjects" {
  make slices/origwork-00004-schema.nt
  # find out the URI of a subject person
  person="$(grep 'Roseveare, Helen' slices/origwork-00004-schema.nt | cut -d ' ' -f 1)"
  # make sure it's set to something
  [ -n "$person" ]
  # check that it's a Person
  grep -q -F "$person <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person>" slices/origwork-00004-schema.nt
  # check its name
  grep -q -F "$person <http://schema.org/name> \"Roseveare, Helen\"" slices/origwork-00004-schema.nt
  # check that the main work is about this person
  grep -q -F "<http://schema.org/about> $person" slices/origwork-00004-schema.nt
}

@test "Schema.org RDF: conversion of person subjects with ID" {
  make slices/ajattelemisenalku-00098-schema.nt
  subject="$(grep '<http://schema.org/name> "Herakleitos"' slices/ajattelemisenalku-00098-schema.nt | cut -d ' ' -f 1)"
  [ -n "$subject" ]
  grep -q -F "$subject <http://schema.org/identifier> \"000043960\"" slices/ajattelemisenalku-00098-schema.nt
}

@test "Schema.org RDF: conversion of 600 \$t work subjects" {
  make slices/trauma-00583-schema.nt
  # find out the URI of a subject work
  work="$(grep 'King Lear' slices/trauma-00583-schema.nt | cut -d ' ' -f 1)"
  # make sure it is set to something
  [ -n "$work" ]
  # check that it's a CreativeWork and a bf:Work
  grep -q -F "$work <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/CreativeWork>" slices/trauma-00583-schema.nt
  grep -q -F "$work <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/bibframe/Work>" slices/trauma-00583-schema.nt
  # check its name
  grep -q -F "$work <http://schema.org/name> \"King Lear\"" slices/trauma-00583-schema.nt
  # check that the main work is about it
  grep -q -F "<http://schema.org/about> $work" slices/trauma-00583-schema.nt

  # find out the author URI of that work
  author="$(grep "$work <http://schema.org/author>" slices/trauma-00583-schema.nt | cut -d ' ' -f 3)"
  # make sure it's set to something
  [ -n "$author" ]
  # check that it's a Person
  grep -q -F "$author <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person>" slices/trauma-00583-schema.nt
  # check its name
  grep -q -F "$author <http://schema.org/name> \"Shakespeare, William\"" slices/trauma-00583-schema.nt
}

@test "Schema.org RDF: conversion of 650 subjects" {
  make slices/ajanlyhythistoria-00009-schema.nt
  work="$(grep '<http://schema.org/workExample>' slices/ajanlyhythistoria-00009-schema.nt | cut -d ' ' -f 1)"
  # check that a particular subject is found
  grep -q -F "$work <http://schema.org/about> \"suhteellisuusteoria\"" slices/ajanlyhythistoria-00009-schema.nt
  # check that the number of subjects is expected
  run grep -c -F "$work <http://schema.org/about>" slices/ajanlyhythistoria-00009-schema.nt
  [ "$output" -eq "7" ]
}

@test "Schema.org RDF: conversion of 651 subjects" {
  make slices/etyk-00012-schema.nt
  work="$(grep '<http://schema.org/workExample>' slices/etyk-00012-schema.nt | cut -d ' ' -f 1)"
  # check that a particular subject is found
  grep -q -F "$work <http://schema.org/about> \"Eurooppa\"" slices/etyk-00012-schema.nt
  # check that the number of subjects is expected
  run grep -c -F "$work <http://schema.org/about>" slices/etyk-00012-schema.nt
  [ "$output" -eq "10" ]
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
  grep -q '<http://schema.org/name> "Ekumeniska rådet i Finland : verksamhetsberättelse 2009"' slices/ekumeeninen-00585-schema.nt
}

@test "Schema.org RDF: including part information in names" {
  make slices/titlepart-00077-schema.nt
  grep -q '<http://schema.org/name> "Kootut teokset : 3, Näytelmiä: Olviretki Schleusingenissä ; Leo ja Liisa ; Canzino ; Selman juonet ; Alma"' slices/titlepart-00077-schema.nt
  grep -q '<http://schema.org/name> "Kootut lastut : 1"' slices/titlepart-00077-schema.nt
  grep -q '<http://schema.org/name> "Dekamerone : Neljäs päivä ja siihen kuuluvat 10 kertomusta"' slices/titlepart-00077-schema.nt
}

@test "Schema.org RDF: not mixing up languages from different records" {
  make slices/langpart-00000-schema.nt
  inst1="$(grep '<http://schema.org/datePublished> "1985"' slices/langpart-00000-schema.nt | cut -d ' ' -f 1)"
  [ -n "$inst1" ]
  work1="$(grep "<http://schema.org/workExample> $inst1" slices/langpart-00000-schema.nt | cut -d ' ' -f 1)"
  [ -n "$work1" ]
  orig1="$(grep "<http://schema.org/workTranslation> $work1" slices/langpart-00000-schema.nt | cut -d ' ' -f 1)"
  [ -n "$orig1" ]

  grep -q "$work1 <http://schema.org/inLanguage> \"swe\"" slices/langpart-00000-schema.nt
  grep -q "$orig1 <http://schema.org/inLanguage> \"fin\"" slices/langpart-00000-schema.nt

  run grep "$work1 <http://schema.org/inLanguage> \"fin\"" slices/langpart-00000-schema.nt
  [ $status -ne 0 ]
  run grep "$orig1 <http://schema.org/inLanguage> \"swe\"" slices/langpart-00000-schema.nt
  [ $status -ne 0 ]
}
