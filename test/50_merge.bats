#!/usr/bin/env bats

load test_helper

setup () {
  global_setup
  make slice
}

@test "Merge works: basic merging" {
  rm -f merged/hawking-merged.hdt
  make merge
  [ -s merged/hawking-merged.hdt ]
}

@test "Merge works: translations are linked to same original work" {
  count="$(grep translationOf merged/kotona-merged.nt | cut -d ' ' -f 3 | sort | uniq -c | awk '{ print $1 }')"
  [ "$count" -eq 2 ]
}

@test "Merge works: transitive handling of work keys" {
  count="$(grep workExample merged/fanrik-manninen-merged.nt | cut -d ' ' -f 1 | sort | uniq -c | wc -l)"
  [ "$count" -le 2 ]
  # Ideally the count would be just 1, but since we don't use person authorities yet,
  # there is one outlier in the set
}
