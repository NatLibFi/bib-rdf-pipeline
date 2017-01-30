#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Reconcile: converting language codes to ISO 639-1" {
  make slices/ajattelemisenalku-00098-schema.nt
  grep -q -F '<http://schema.org/inLanguage> "fi"' slices/ajattelemisenalku-00098-schema.nt
  ! grep -q -F '<http://schema.org/inLanguage> "fin"' slices/ajattelemisenalku-00098-schema.nt
}

@test "Reconcile: converting to YSA URIs, basic case" {
  make slices/ajattelemisenalku-00098-schema.nt
  # "myytit" -> ysa:Y97600
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/ysa/Y97600>' slices/ajattelemisenalku-00098-schema.nt
  ! grep -q -F '<http://schema.org/about> "myytit"' slices/ajattelemisenalku-00098-schema.nt
}

@test "Reconcile: converting to YSA URIs, coordinated case" {
  make slices/ajattelemisenalku-00098-schema.nt
  # "filosofia -- antiikki" -> ysa:Y95164
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/ysa/Y95164>' slices/ajattelemisenalku-00098-schema.nt
  ! grep -q -F '<http://schema.org/about> "filosofia--antiikki"' slices/ajattelemisenalku-00098-schema.nt
  ! grep -q -F '<http://schema.org/about> "filosofia -- antiikki"' slices/ajattelemisenalku-00098-schema.nt
}

@test "Reconcile: converting to YSA URIs, not found in YSA case" {
  make slices/ajattelemisenalku-00098-schema.nt
  # "kirjallisuus -- antiikki" -> remains as literal
  grep -q -F '<http://schema.org/about> "kirjallisuus -- antiikki"@fi' slices/ajattelemisenalku-00098-schema.nt
}

@test "Reconcile: converting to YSA URIs, same term as RDA Carrier case" {
  make slices/verkkoaineisto-00608-schema.nt
  ! grep -q '<http://schema.org/about> <http://rdaregistry.info/termList/RDACarrierType/1018>' slices/verkkoaineisto-00608-schema.nt
}

@test "Reconcile: converting to YSO URIs" {
  make slices/ajattelemisenalku-00098-schema.nt
  # "myytit" -> ysa:Y97600 -> yso:p1248
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/yso/p1248>' slices/ajattelemisenalku-00098-schema.nt
}

@test "Reconcile: expressing RDA carrier type" {
  make slices/kotona-00720-schema.nt
  grep -q '<http://rdaregistry.info/Elements/u/P60048> <http://rdaregistry.info/termList/RDACarrierType/1018>' slices/kotona-00720-schema.nt
  ! grep -q '<http://rdaregistry.info/Elements/u/P60048> <http://www.yso.fi/onto/ysa/Y175712>' slices/kotona-00720-schema.nt
}

@test "Reconcile: expressing RDA content type" {
  make slices/kotona-00720-schema.nt
  grep -q '<http://rdaregistry.info/Elements/u/P60049> <http://rdaregistry.info/termList/RDAContentType/1020>' slices/kotona-00720-schema.nt
}

@test "Reconcile: expressing RDA media type" {
  make slices/kotona-00720-schema.nt
  grep -q '<http://rdaregistry.info/Elements/u/P60050> <http://rdaregistry.info/termList/RDAMediaType/1003>' slices/kotona-00720-schema.nt
}
