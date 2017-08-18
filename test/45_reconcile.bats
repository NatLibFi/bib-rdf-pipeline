#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Reconcile: basic reconciliation" {
  rm -f slices/kotona-00097-reconciled.nt
  make -j2 reconcile
  [ -s slices/kotona-00097-reconciled.nt ]
}

@test "Reconcile: converting language codes to ISO 639-1" {
  make slices/ajattelemisenalku-00098-reconciled.nt
  grep -q -F '<http://schema.org/inLanguage> "fi"' slices/ajattelemisenalku-00098-reconciled.nt
  ! grep -q -F '<http://schema.org/inLanguage> "fin"' slices/ajattelemisenalku-00098-reconciled.nt
}

@test "Reconcile: retaining work subjects" {
  make slices/trauma-00583-reconciled.nt
  count="$(grep -c '<http://schema.org/about> <.*#Work.*>' slices/trauma-00583-reconciled.nt)"
  [ "$count" -eq 12 ]
}

@test "Reconcile: converting to YSA URIs, basic case" {
  make slices/ajattelemisenalku-00098-reconciled.nt
  # "myytit" -> ysa:Y97600
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/ysa/Y97600>' slices/ajattelemisenalku-00098-reconciled.nt
  ! grep -q -F '<http://schema.org/about> "myytit"' slices/ajattelemisenalku-00098-reconciled.nt
}

@test "Reconcile: converting to YSA URIs, place case" {
  make slices/etyk-00012-reconciled.nt
  # "Eurooppa" -> ysa:Y94111
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/ysa/Y94111>' slices/etyk-00012-reconciled.nt
  ! grep -q -F '<http://schema.org/about> "Eurooppa"' slices/etyk-00012-reconciled.nt
}

@test "Reconcile: converting to YSA URIs, coordinated case" {
  make slices/ajattelemisenalku-00098-reconciled.nt
  # "filosofia -- antiikki" -> ysa:Y95164
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/ysa/Y95164>' slices/ajattelemisenalku-00098-reconciled.nt
  ! grep -q -F '<http://schema.org/about> "filosofia--antiikki"' slices/ajattelemisenalku-00098-reconciled.nt
  ! grep -q -F '<http://schema.org/about> "filosofia -- antiikki"' slices/ajattelemisenalku-00098-reconciled.nt
}

@test "Reconcile: converting to YSA URIs, not found in YSA case" {
  make slices/ajattelemisenalku-00098-reconciled.nt
  # "kirjallisuus -- antiikki" -> remains as literal
  grep -q -F '<http://schema.org/about> "kirjallisuus -- antiikki"@fi' slices/ajattelemisenalku-00098-reconciled.nt
}

@test "Reconcile: converting to YSA URIs, same term as RDA Carrier case" {
  make slices/verkkoaineisto-00608-reconciled.nt
  ! grep -q '<http://schema.org/about> <http://rdaregistry.info/termList/RDACarrierType/1018>' slices/verkkoaineisto-00608-reconciled.nt
}

@test "Reconcile: converting to YSO concept URIs" {
  make slices/ajattelemisenalku-00098-reconciled.nt
  # "myytit" -> ysa:Y97600 -> yso:p1248
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/yso/p1248>' slices/ajattelemisenalku-00098-reconciled.nt
}

@test "Reconcile: converting to YSO Place URIs" {
  make slices/ajattelemisenalku-00098-reconciled.nt
  # "Eurooppa" -> ysa:Y94111 -> yso:p94111
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/yso/p94111>' slices/etyk-00012-reconciled.nt
}

@test "Reconcile: express publisher organizations using CN, preferred label case" {
  make slices/ekumeeninen-00585-reconciled.nt
  # "Suomen ekumeeninen neuvosto" -> cn:26756A
  grep -q -F '<http://schema.org/publisher> <http://urn.fi/URN:NBN:fi:au:cn:26756A>' slices/ekumeeninen-00585-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:cn:26756A> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>' slices/ekumeeninen-00585-reconciled.nt
  # check that no blank nodes remain
  ! grep -q -F '<http://schema.org/publisher> _:' slices/ekumeeninen-00585-reconciled.nt
  ! grep -q '^_:.* <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>' slices/ekumeeninen-00585-reconciled.nt
}

@test "Reconcile: express publisher organizations using CN, alternate label case" {
  make slices/verkkoaineisto-00608-reconciled.nt
  # "University of Jyväskylä" -> cn:8274A
  grep -q -F '<http://schema.org/publisher> <http://urn.fi/URN:NBN:fi:au:cn:8274A>' slices/verkkoaineisto-00608-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:cn:8274A> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>' slices/verkkoaineisto-00608-reconciled.nt
  # check that no blank nodes remain
  ! grep -q -F '<http://schema.org/publisher> _:' slices/verkkoaineisto-00608-reconciled.nt
  ! grep -q '^_:.* <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>' slices/verkkoaineisto-00608-reconciled.nt
}

@test "Reconcile: retain publisher organizations that cannot be reconciled with CN" {
  make slices/punataudista-00084-reconciled.nt
  org="$(grep "<http://schema.org/name> \"Tekijä\"" slices/punataudista-00084-reconciled.nt | cut -d ' ' -f 1)"
  [ -n "$org" ]
  grep -q -F "$org <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>" slices/punataudista-00084-reconciled.nt
}

@test "Reconcile: express subject organizations using CN" {
  make slices/etyk-00012-reconciled.nt
  grep -q -F '<http://schema.org/about> <http://urn.fi/URN:NBN:fi:au:cn:3209A>' slices/etyk-00012-reconciled.nt
}

@test "Reconcile: express subject meetings using CN" {
  make slices/etyk-00012-reconciled.nt
  grep -q -F '<http://schema.org/about> <http://urn.fi/URN:NBN:fi:au:cn:66609A>' slices/etyk-00012-reconciled.nt
}

@test "Reconcile: expressing RDA carrier type" {
  make slices/kotona-00720-reconciled.nt
  grep -q '<http://rdaregistry.info/Elements/u/P60048> <http://rdaregistry.info/termList/RDACarrierType/1018>' slices/kotona-00720-reconciled.nt
  ! grep -q '<http://rdaregistry.info/Elements/u/P60048> <http://www.yso.fi/onto/ysa/Y175712>' slices/kotona-00720-reconciled.nt
}

@test "Reconcile: expressing RDA content type" {
  make slices/kotona-00720-reconciled.nt
  grep -q '<http://rdaregistry.info/Elements/u/P60049> <http://rdaregistry.info/termList/RDAContentType/1020>' slices/kotona-00720-reconciled.nt
}

@test "Reconcile: expressing RDA media type" {
  make slices/kotona-00720-reconciled.nt
  grep -q '<http://rdaregistry.info/Elements/u/P60050> <http://rdaregistry.info/termList/RDAMediaType/1003>' slices/kotona-00720-reconciled.nt
}
