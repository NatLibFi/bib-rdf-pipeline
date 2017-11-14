#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

# Disabled, because running this takes a very long time and causes Travis timeouts.
# Instead, merging single files at a time is done by individual tests.
#
#@test "Merge works: basic merging" {
#  rm -f merged/hawking-merged.nt
#  make -j2 merge
#  [ -s merged/hawking-merged.nt ]
#}

@test "Merge works: translations are linked to same original work" {
  make merged/kotona-merged.nt
  count="$(grep translationOf merged/kotona-merged.nt | cut -d ' ' -f 3 | sort | uniq -c | awk '{ print $1 }')"
  [ "$count" -eq 2 ]
}

@test "Merge works: transitive handling of work keys" {
  make merged/fanrik-manninen-merged.nt
  count="$(grep workExample merged/fanrik-manninen-merged.nt | cut -d ' ' -f 1 | sort | uniq -c | wc -l)"
  [ "$count" -le 2 ]
  # Ideally the count would be just 1, but since we don't use person authorities yet,
  # there is one outlier in the set
}

@test "Merge works: series are merged based on title" {
  make merged/fanrik-manninen-merged.nt
  count="$(grep -c -F '<http://schema.org/name> "Helppohintainen koulu- ja kansankirjasto"' merged/fanrik-manninen-merged.nt)"
  [ "$count" -eq 1 ]
}

@test "Merge works: series are merged based on ISSN" {
  make merged/kotona-merged.nt
  count="$(grep -F '<http://schema.org/issn> "0357-7937"' merged/kotona-merged.nt | cut -d ' ' -f 1 | sort | uniq | wc -l)"
  [ "$count" -eq 1 ]
}
