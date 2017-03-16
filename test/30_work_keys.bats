#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Work keys: basic generation" {
  rm -f slices/kotona-00097-work-keys.nt
  make -j2 work-keys
  [ -s slices/kotona-00097-work-keys.nt ]
}

@test "Work keys: not a translation case" {
  make slices/etyk-00012-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "etykin konfliktinesto ja kriisinhallinta/soininen, mika"' slices/etyk-00012-work-keys.nt
}

@test "Work keys: translation case" {
  make slices/kotona-00097-work-keys.nt
  # original work
  grep -q -F '<http://purl.org/dc/terms/identifier> "kotona maailmankaikkeudessa/valtaoja, esko"' slices/kotona-00097-work-keys.nt
  # translated work, key based on translated title
  grep -q -F '<http://purl.org/dc/terms/identifier> "im universum zu hause eine entdeckungsreise/valtaoja, esko"' slices/kotona-00097-work-keys.nt
  # translated work, key based on original title
  grep -q -F '<http://purl.org/dc/terms/identifier> "kotona maailmankaikkeudessa saksa/valtaoja, esko"' slices/kotona-00097-work-keys.nt
}

@test "Work keys: corporate author case" {
  make slices/ekumeeninen-00585-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "suomen ekumeeninen neuvosto ekumeniska rådet i finland verksamhetsberättelse 2009/suomen ekumeeninen neuvosto"' slices/ekumeeninen-00585-work-keys.nt
}

@test "Work keys: multiple authors case" {
  make slices/part-uri-00683-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "viemäreiden sisäpuoliset saneerausmenetelmät renovation of drains and sewers with nodig methods/muoviteollisuus (yhdistys)"' slices/part-uri-00683-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "viemäreiden sisäpuoliset saneerausmenetelmät renovation of drains and sewers with nodig methods/suomen standardisoimisliitto"' slices/part-uri-00683-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "viemäreiden sisäpuoliset saneerausmenetelmät renovation of drains and sewers with nodig methods/kaunisto, tuija"' slices/part-uri-00683-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "viemäreiden sisäpuoliset saneerausmenetelmät renovation of drains and sewers with nodig methods/pelto-huikko, aino"' slices/part-uri-00683-work-keys.nt
} 

@test "Work keys: uniform title case" {
  make slices/origwork-00041-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "new international manual of braille music notation"' slices/origwork-00041-work-keys.nt
}

@test "Work keys: no recurring spaces" {
  make refdata/fanrik-manninen-work-keys.nt
  ! grep '  ' refdata/fanrik-manninen-work-keys.nt
}

@test "Work keys: no trailing spaces in titles" {
  make refdata/fanrik-manninen-work-keys.nt
  ! grep ' /' refdata/fanrik-manninen-work-keys.nt
}
