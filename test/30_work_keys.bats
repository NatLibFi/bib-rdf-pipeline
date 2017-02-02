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

@test "Work keys: no recurring spaces" {
  make refdata/fanrik-manninen-work-keys.nt
  ! grep '  ' refdata/fanrik-manninen-work-keys.nt
}

@test "Work keys: no trailing spaces in titles" {
  make refdata/fanrik-manninen-work-keys.nt
  ! grep ' /' refdata/fanrik-manninen-work-keys.nt
}
