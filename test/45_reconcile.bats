#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

# Disabled, because running this takes a very long time and causes Travis timeouts.
# Instead, reconciliation for single files at a time is done by individual tests.
#
#@test "Reconcile: basic reconciliation" {
#  rm -f slices/kotona-00097-reconciled.nt
#  make -j2 reconcile
#  [ -s slices/kotona-00097-reconciled.nt ]
#}

@test "Reconcile: converting language codes to ISO 639-1" {
  make slices/ajattelemisenalku-00098-reconciled.nt
  grep -q -F '<http://schema.org/inLanguage> "fi"' slices/ajattelemisenalku-00098-reconciled.nt
  run grep -F '<http://schema.org/inLanguage> "fin"' slices/ajattelemisenalku-00098-reconciled.nt
  [ $status -ne 0 ]
}

@test "Reconcile: retaining work subjects" {
  make slices/trauma-00583-reconciled.nt
  count="$(grep -c '<http://schema.org/about> <http://urn.fi/URN:NBN:fi:bib:me:W.*>' slices/trauma-00583-reconciled.nt)"
  [ "$count" -eq 12 ]
}

@test "Reconcile: converting to YSA/YSO URIs, basic case" {
  make slices/ajattelemisenalku-00098-reconciled.nt
  # "myytit" -> ysa:Y97600 -> yso:p1248
  run grep -F '<http://schema.org/about> "myytit"' slices/ajattelemisenalku-00098-reconciled.nt
  [ $status -ne 0 ]
  run grep -F '<http://schema.org/about> <http://www.yso.fi/onto/ysa/Y97600>' slices/ajattelemisenalku-00098-reconciled.nt
  [ $status -ne 0 ]
  run grep -F '<http://schema.org/about> <http://www.yso.fi/onto/allars/Y23220>' slices/ajattelemisenalku-00098-reconciled.nt
  [ $status -ne 0 ]
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/yso/p1248>' slices/ajattelemisenalku-00098-reconciled.nt
}

@test "Reconcile: converting to YSA/YSO URIs, place case" {
  make slices/etyk-00012-reconciled.nt
  # "Eurooppa" -> ysa:Y94111 -> yso:p94111
  run grep -F '<http://schema.org/about> "Eurooppa"' slices/etyk-00012-reconciled.nt
  [ $status -ne 0 ]
  run grep -F '<http://schema.org/about> <http://www.yso.fi/onto/ysa/Y94111>' slices/etyk-00012-reconciled.nt
  [ $status -ne 0 ]
  run grep -F '<http://schema.org/about> <http://www.yso.fi/onto/allars/Y30166>' slices/etyk-00012-reconciled.nt
  [ $status -ne 0 ]
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/yso/p94111>' slices/etyk-00012-reconciled.nt
}

@test "Reconcile: converting to YSA/YSO URIs, coordinated case" {
  make slices/ajattelemisenalku-00098-reconciled.nt
  # "filosofia -- antiikki" -> ysa:Y95164 -> yso:p20343
  run grep -q -F '<http://schema.org/about> "filosofia--antiikki"' slices/ajattelemisenalku-00098-reconciled.nt
  [ $status -ne 0 ]
  run grep -q -F '<http://schema.org/about> "filosofia -- antiikki"' slices/ajattelemisenalku-00098-reconciled.nt
  [ $status -ne 0 ]
  run grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/ysa/Y95164>' slices/ajattelemisenalku-00098-reconciled.nt
  [ $status -ne 0 ]
  run grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/allars/Y39782>' slices/ajattelemisenalku-00098-reconciled.nt
  [ $status -ne 0 ]
  grep -q -F '<http://schema.org/about> <http://www.yso.fi/onto/yso/p20343>' slices/ajattelemisenalku-00098-reconciled.nt
}

@test "Reconcile: converting to YSA/YSO URIs, not found in YSA case" {
  make slices/ajattelemisenalku-00098-reconciled.nt
  # "kirjallisuus -- antiikki" -> remains as literal
  grep -q -F '<http://schema.org/about> "kirjallisuus -- antiikki"@fi' slices/ajattelemisenalku-00098-reconciled.nt
}

@test "Reconcile: converting to YSA/YSO URIs, cyrillic case" {
  make slices/hulluntaivaassa-00490-reconciled.nt
  # "проза--пер. с финск."@ru-cyrl -> removed, as it was an accident that it got through the replication (via 880)
  run grep -q -F '<http://schema.org/about> "проза--пер. с финск."@ru-cyrl' slices/hulluntaivaassa-00490-reconciled.nt
  [ $status -ne 0 ]
  # check that no other subjects are added by mistake
  run grep '<http://schema.org/about>' slices/hulluntaivaassa-00490-reconciled.nt
  [ $status -ne 0 ]
}

@test "Reconcile: converting to YSA URIs, same term as RDA Carrier case" {
  make slices/verkkoaineisto-00608-reconciled.nt
  run grep '<http://schema.org/about> <http://rdaregistry.info/termList/RDACarrierType/1018>' slices/verkkoaineisto-00608-reconciled.nt
  [ $status -ne 0 ]
}

@test "Reconcile: express authors with ID using PN" {
  make slices/kotkankasvisto-00641-reconciled.nt
  grep -q -F '<http://schema.org/author> <http://urn.fi/URN:NBN:fi:au:pn:000061725>' slices/kotkankasvisto-00641-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:pn:000061725> <http://schema.org/name> "Ulvinen, Arvi"' slices/kotkankasvisto-00641-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:pn:000061725> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person>' slices/kotkankasvisto-00641-reconciled.nt
  # check that no agent URIs derived from the bib record ID are left
  run grep -F "http://urn.fi/URN:NBN:fi:bib:me:P00641900301" slices/kotkankasvisto-00641-reconciled.nt
  [ $status -ne 0 ]
}

@test "Reconcile: preserve birth/death years for authors" {
  make slices/abckiria-00097-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:pn:000103346> <http://schema.org/name> "Agricola, Mikael"' slices/abckiria-00097-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:pn:000103346> <http://schema.org/birthDate> "noin 1510"' slices/abckiria-00097-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:pn:000103346> <http://schema.org/deathDate> "1557"' slices/abckiria-00097-reconciled.nt
}

@test "Reconcile: express contributors with ID using PN" {
  make slices/jatuli-00000-reconciled.nt
  grep -q -F '<http://schema.org/contributor> <http://urn.fi/URN:NBN:fi:au:pn:000047367>' slices/jatuli-00000-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:pn:000047367> <http://schema.org/name> "Keränen, Lauri"' slices/jatuli-00000-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:pn:000047367> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person>' slices/jatuli-00000-reconciled.nt
  # check that no agent URIs derived from the bib record ID are left
  run grep -F "http://urn.fi/URN:NBN:fi:bib:me:P00000675302" slices/jatuli-00000-reconciled.nt
  [ $status -ne 0 ]
}

@test "Reconcile: express person subjects with ID using PN" {
  make slices/ajattelemisenalku-00098-reconciled.nt
  grep -q -F '<http://schema.org/about> <http://urn.fi/URN:NBN:fi:au:pn:000043960>' slices/ajattelemisenalku-00098-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:pn:000043960> <http://schema.org/name> "Herakleitos"' slices/ajattelemisenalku-00098-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:pn:000043960> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person>' slices/ajattelemisenalku-00098-reconciled.nt
  # check that no agent URIs derived from the bib record ID are left
  run grep -F "http://urn.fi/URN:NBN:fi:bib:me:P00098125805" slices/ajattelemisenalku-00098-reconciled.nt
  [ $status -ne 0 ]
}

@test "Reconcile: express corporate subjects using CN" {
  make slices/evaluation-00590-reconciled.nt
  grep -q -F '<http://schema.org/about> <http://urn.fi/URN:NBN:fi:au:cn:146806A>' slices/evaluation-00590-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:cn:146806A> <http://schema.org/name> "Kansalliskirjasto"' slices/evaluation-00590-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:cn:146806A> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>' slices/evaluation-00590-reconciled.nt
  # check that no agent URIs derived from the bib record ID are left
  run grep -F "http://urn.fi/URN:NBN:fi:bib:me:O00590886001" slices/evaluation-00590-reconciled.nt
  [ $status -ne 0 ]
}

@test "Reconcile: express publisher organizations using CN, preferred label case" {
  make slices/ekumeeninen-00585-reconciled.nt
  # "Suomen ekumeeninen neuvosto" -> cn:26756A
  grep -q -F '<http://schema.org/publisher> <http://urn.fi/URN:NBN:fi:au:cn:26756A>' slices/ekumeeninen-00585-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:cn:26756A> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>' slices/ekumeeninen-00585-reconciled.nt
  # check that no blank nodes remain
  run grep -F '<http://schema.org/publisher> _:' slices/ekumeeninen-00585-reconciled.nt
  [ $status -ne 0 ]
  run grep '^_:.* <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>' slices/ekumeeninen-00585-reconciled.nt
  [ $status -ne 0 ]
}

@test "Reconcile: express publisher organizations using CN, alternate label case" {
  make slices/verkkoaineisto-00608-reconciled.nt
  # "University of Jyväskylä" -> cn:8274A
  grep -q -F '<http://schema.org/publisher> <http://urn.fi/URN:NBN:fi:au:cn:8274A>' slices/verkkoaineisto-00608-reconciled.nt
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:cn:8274A> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>' slices/verkkoaineisto-00608-reconciled.nt
  # check that the authorized label from CN is used as schema:name
  grep -q -F '<http://urn.fi/URN:NBN:fi:au:cn:8274A> <http://schema.org/name> "Jyväskylän yliopisto"' slices/verkkoaineisto-00608-reconciled.nt
  # check that the non-authorized (alternate) label is not used in the output
  run grep -F '<http://schema.org/name> "University of Jyväskylä"' slices/verkkoaineisto-00608-reconciled.nt
  [ $status -ne 0 ]
  # check that no blank nodes remain
  run grep -F '<http://schema.org/publisher> _:' slices/verkkoaineisto-00608-reconciled.nt
  [ $status -ne 0 ]
  run grep '^_:.* <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Organization>' slices/verkkoaineisto-00608-reconciled.nt
  [ $status -ne 0 ]
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
  run grep '<http://rdaregistry.info/Elements/u/P60048> <http://www.yso.fi/onto/ysa/Y175712>' slices/kotona-00720-reconciled.nt
  [ $status -ne 0 ]
}

@test "Reconcile: expressing RDA content type" {
  make slices/kotona-00720-reconciled.nt
  grep -q '<http://rdaregistry.info/Elements/u/P60049> <http://rdaregistry.info/termList/RDAContentType/1020>' slices/kotona-00720-reconciled.nt
}

@test "Reconcile: expressing RDA media type" {
  make slices/kotona-00720-reconciled.nt
  grep -q '<http://rdaregistry.info/Elements/u/P60050> <http://rdaregistry.info/termList/RDAMediaType/1003>' slices/kotona-00720-reconciled.nt
}

@test "Reconcile: works should be part of collection" {
  make slices/kotkankasvisto-00641-reconciled.nt
  grep -q '<http://urn.fi/URN:NBN:fi:bib:me:W00641900300> <http://schema.org/isPartOf> <http://urn.fi/URN:NBN:fi:bib:me:CFENNI>' slices/kotkankasvisto-00641-reconciled.nt
  grep -q '<http://urn.fi/URN:NBN:fi:bib:me:W00641900301> <http://schema.org/isPartOf> <http://urn.fi/URN:NBN:fi:bib:me:CFENNI>' slices/kotkankasvisto-00641-reconciled.nt
}

@test "Reconcile: instances should be part of collection" {
  make slices/kotkankasvisto-00641-reconciled.nt
  grep -q '<http://urn.fi/URN:NBN:fi:bib:me:I00641900300> <http://schema.org/isPartOf> <http://urn.fi/URN:NBN:fi:bib:me:CFENNI>' slices/kotkankasvisto-00641-reconciled.nt
}

@test "Reconcile: series with ISSNs should be linked to their issn.org identifier" {
  make slices/kotkankasvisto-00641-reconciled.nt
  grep -q '<http://schema.org/sameAs> <https://issn.org/resource/issn/0788-6942>' slices/kotkankasvisto-00641-reconciled.nt
}

@test "Reconcile: invalid ISSNs should not be linked" {
  make slices/bad-issn-00004-reconciled.nt
  run grep '<http://schema.org/sameAs> <https://issn.org/resource/issn/' slices/bad-issn-00004-reconciled.nt
  [ $status -ne 0 ]
}
