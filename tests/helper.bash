#!/usr/bin/env bash
set -e

bin_dir="${PWD}/bin"
mocks_dir="${PWD}/tests/mocks"
screen_mock="${mocks_dir}/screen"

tmp_dirs=()
trap "cleanup $tmp_dir" EXIT

function assert_screen_called_with() {
  local options="$@"

  local executions="$(screen_mock_executions)"
  test -n "$executions" || fail "expected screen to be called with '$options' but it was not called"
  [[ "$executions" == "screen $options" ]] || \
    fail "expected screen to be called with '$options' but it was called like this: '$executions'"
}

function assert_screen_not_called() {
  [[ "$(screen_mock_executions)" == "" ]] || fail "screen was called: $(screen_mock_executions)"
}

function cleanup() {
  for dir in ${tmp_dirs[@]}; do
    test -n "$dir" && test -d "$dir" && rm -fr "$dir"
  done
}

function common_setup() {
  load 'libs/support/load'
  load 'libs/assert/load'

  tmp_dir=`mktemp -d -t scide.tests.XXXXXX`
  tmp_dirs+=("$tmp_dir")
  echo "Temporary directory: $tmp_dir"

  unset SCIDE_AUTO
  unset SCIDE_BIN
  unset SCIDE_PROJECTS
  unset SCIDE_SCREEN

  export SCREEN_MOCK_DATA_FILE="${tmp_dir}/screen-mock-data"

  PATH="$bin_dir:$mocks_dir:$PATH"

  mkdir "${tmp_dir}/twd"
  cd "${tmp_dir}/twd"

  setup_mocks
}

function fail() {
  local msg="$@"

  >&2 echo "TEST ERROR: $msg"
  exit 2
}

function setup_mocks() {
  test -n "$SCREEN_MOCK_DATA_FILE" && echo -n "" > "$SCREEN_MOCK_DATA_FILE"
}

function screen_mock_executions() {
  cat "$SCREEN_MOCK_DATA_FILE"
}
