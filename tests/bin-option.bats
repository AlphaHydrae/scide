#!/usr/bin/env bats
load "helper"

function setup() {
  common_setup
}

@test "cannot run a non-existent screen binary specified through the -b option" {
  run scide -b foo
  assert_failure 100
  assert_screen_not_called
}

@test "cannot run a non-existent screen binary specified through the --bin option" {
  run scide --bin foo
  assert_failure 100
  assert_screen_not_called
}

@test "cannot run a non-existent screen binary specified through the \$SCIDE_BIN environment variable" {
  SCIDE_BIN=foo run scide
  assert_failure 100
  assert_screen_not_called
}

@test "cannot run a non-executable screen binary specified through the -b option" {
  touch non_executable_screen
  run scide -b non_executable_screen
  assert_failure 101
  assert_screen_not_called
}

@test "cannot run a non-executable screen binary specified through the --bin option" {
  touch non_executable_screen
  run scide --bin non_executable_screen
  assert_failure 101
  assert_screen_not_called
}

@test "cannot run a non-executable screen binary specified through the \$SCIDE_BIN environment variable" {
  touch non_executable_screen
  SCIDE_BIN="non_executable_screen" run scide
  assert_failure 101
  assert_screen_not_called
}
