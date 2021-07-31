#!/usr/bin/env bash

function assert_screen_called() {
  local options="$@"
  [[ "$(screen_mock_executions)" == "screen $options" ]] || fail "screen was not called"
}

function assert_screen_not_called() {
  [[ "$(screen_mock_executions)" == "" ]] || fail "screen was called: $(screen_mock_executions)"
}

function common_setup() {
  load 'libs/support/load'
  load 'libs/assert/load'
  test -d "$SCIDE_TESTS_TMP_DIR" || fail "tests temporary directory not found"
  test -n "$SCREEN_MOCK_DATA_FILE" || fail "screen mock data file not defined"
  setup_mocks
}

function fail() {
  local msg="$@"

  >&2 echo "TEST ERROR: $msg"
  exit 2
}

function setup_mocks() {
  echo -n "" > "$SCREEN_MOCK_DATA_FILE"
}

function screen_mock_executions() {
  cat "$SCREEN_MOCK_DATA_FILE"
}

function tmp_path() {
  local path="$1"
  echo -n "${SCIDE_TESTS_TMP_DIR}/${path}"
}
