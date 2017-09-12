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
  # check that no additional keys were generated by accident
  count="$(wc -l <slices/etyk-00012-work-keys.nt)"
  echo $count
  [ "$count" -eq 1 ]
}

@test "Work keys: translation case" {
  make slices/kotona-00097-work-keys.nt
  # original work
  grep -q -F '<http://purl.org/dc/terms/identifier> "kotona maailmankaikkeudessa/valtaoja, esko"' slices/kotona-00097-work-keys.nt
  # translated work, key based on translated title
  grep -q -F '<http://purl.org/dc/terms/identifier> "im universum zu hause eine entdeckungsreise/valtaoja, esko/uhlmann, peter"' slices/kotona-00097-work-keys.nt
  # translated work, key based on original title
  grep -q -F '<http://purl.org/dc/terms/identifier> "kotona maailmankaikkeudessa saksa/valtaoja, esko/uhlmann, peter"' slices/kotona-00097-work-keys.nt
  # check that no additional keys were generated by accident
  count="$(wc -l <slices/kotona-00097-work-keys.nt)"
  echo $count
  [ "$count" -eq 3 ]
}

@test "Work keys: corporate author case" {
  make slices/ekumeeninen-00585-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "suomen ekumeeninen neuvosto toimintakertomus 2009 ekumeniska rådet i finland verksamhetsberättelse 2009/suomen ekumeeninen neuvosto"' slices/ekumeeninen-00585-work-keys.nt
  # check that no additional keys were generated by accident
  count="$(wc -l <slices/ekumeeninen-00585-work-keys.nt)"
  echo $count
  [ "$count" -eq 1 ]
}

@test "Work keys: no main author case" {
  make slices/part-uri-00683-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "viemäreiden sisäpuoliset saneerausmenetelmät renovation of drains and sewers with nodig methods/muoviteollisuus (yhdistys)"' slices/part-uri-00683-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "viemäreiden sisäpuoliset saneerausmenetelmät renovation of drains and sewers with nodig methods/suomen standardisoimisliitto"' slices/part-uri-00683-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "viemäreiden sisäpuoliset saneerausmenetelmät renovation of drains and sewers with nodig methods/kaunisto, tuija"' slices/part-uri-00683-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "viemäreiden sisäpuoliset saneerausmenetelmät renovation of drains and sewers with nodig methods/pelto-huikko, aino"' slices/part-uri-00683-work-keys.nt
  # check that no additional keys were generated by accident
  count="$(wc -l <slices/part-uri-00683-work-keys.nt)"
  echo $count
  [ "$count" -eq 4 ]
} 

@test "Work keys: uniform title case" {
  make slices/raamattu-00000-work-keys.nt
  grep -q -F '<http://purl.org/dc/terms/identifier> "raamattu"' slices/raamattu-00000-work-keys.nt
  # check that no additional keys were generated by accident
  count="$(wc -l <slices/raamattu-00000-work-keys.nt)"
  echo $count
  [ "$count" -eq 1 ]
}

@test "Work keys: parallel title case" {
  make slices/jakaja-00005-work-keys.nt
  # parallel titles should not be used as work keys
  run grep -F '<http://purl.org/dc/terms/identifier> "grundlagarna och statshushållningen kommittén för revision av grundlagarnas stadganden om statshushållning' slices/jakaja-00005-work-keys.nt
  [ $status -ne 0 ]
}

@test "Work keys: subtitle case" {
  make slices/ajanlyhythistoria-00009-work-keys.nt
  # subtitle should be part of work key
  grep -q -F '<http://purl.org/dc/terms/identifier> "ajan lyhyt historia alkuräjähdyksestä mustiin aukkoihin/hawking, stephen/varteva, risto"' slices/ajanlyhythistoria-00009-work-keys.nt
  # title without subtitle should not be used for work keys
  run grep -F '<http://purl.org/dc/terms/identifier> "ajan lyhyt historia/hawking, stephen"' slices/ajanlyhythistoria-00009-work-keys.nt
  [ $status -ne 0 ]
}

@test "Work keys: part number case" {
  make slices/titlepart-00077-work-keys.nt
  # part number should be part of work key
  grep -q -F '<http://purl.org/dc/terms/identifier> "kootut lastut 1/aho, juhani"' slices/titlepart-00077-work-keys.nt
}

@test "Work keys: part title case" {
  make slices/titlepart-00077-work-keys.nt
  # part title should be part of work key
  grep -q -F '<http://purl.org/dc/terms/identifier> "dekamerone neljäs päivä ja siihen kuuluvat 10 kertomusta/boccaccio, giovanni/elenius-pantzopoulos, anja"' slices/titlepart-00077-work-keys.nt
}

@test "Work keys: part number and title case" {
  make slices/titlepart-00077-work-keys.nt
  # part number and title should be part of work key, in that order
  grep -q -F '<http://purl.org/dc/terms/identifier> "kootut teokset 3 näytelmiä olviretki schleusingenissä leo ja liisa canzino selman juonet alma/kivi, aleksis"' slices/titlepart-00077-work-keys.nt
}

@test "Work keys: no recurring spaces" {
  make refdata/fanrik-manninen-work-keys.nt
  run grep '  ' refdata/fanrik-manninen-work-keys.nt
  [ $status -ne 0 ]
}

@test "Work keys: no trailing spaces in titles" {
  make refdata/fanrik-manninen-work-keys.nt
  run grep ' /' refdata/fanrik-manninen-work-keys.nt
  [ $status -ne 0 ]
}

@test "Work keys: no trailing commas" {
  make refdata/prepub-work-keys.nt
  run grep ',"' refdata/prepub-work-keys.nt
  [ $status -ne 0 ]
}

@test "Work keys: no birth/death years" {
  make refdata/sjubroder-work-keys.nt
  run grep '1834-1872' refdata/sjubroder-work-keys.nt
  [ $status -ne 0 ]
}
