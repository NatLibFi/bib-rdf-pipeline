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
