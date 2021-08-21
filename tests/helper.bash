#!/usr/bin/env bash
set -e

bin_dir="${PWD}/bin"
mocks_dir="${PWD}/tests/mocks"
screen_mock="${mocks_dir}/screen"
new_line=$'\n'

tmp_dirs=()
trap "cleanup $tmp_dir" EXIT

function assert_screen_called() {
  local expected_execution="$@"
  local executions="$(screen_mock_executions)"

  test -n "$executions" || fail "expected screen to be called as '$expected_execution' but it was not called"
  [[ "$executions" == "$expected_execution" ]] || \
    fail "expected screen to be called as '$expected_execution' but it was called like this: '$executions'"

  screen_call_assertions=$(( $screen_call_assertions + 1 ))
}

function assert_screen_called_with_tmp_config() {
  local expected_execution="$@ -c "
  local executions="$(screen_mock_executions)"

  test -n "$executions" || fail "expected screen to be called as '$expected_execution' but it was not called"
  begins_with "$executions" "$expected_execution" || \
    fail "expected screen to be called as '${expected_execution}<tmp/.screenrc>' (with a temporary configuration file) but it was called like this: '$executions'"

  local strip="$(echo -n "$expected_execution"|wc -m)"
  local start=$(( $strip + 1 ))
  local config_file="$(echo -n "$executions"|cut -c${start}-1000)"
  echo -n "$config_file"

  screen_call_assertions=$(( $screen_call_assertions + 1 ))
}

function assert_screen_not_called() {
  [[ "$(screen_mock_executions)" == "" ]] || fail "screen was called: $(screen_mock_executions)"
  assert_no_screen_config

  screen_call_assertions=$(( $screen_call_assertions + 1 ))
  screen_config_assertions=$(( $screen_config_assertions + 1 ))
}

function assert_screen_config() {
  local expected_config_file="$1"
  shift
  local expected_config="$@"

  assert_equal "$(screen_mock_config)" "${expected_config_file}${new_line}${expected_config}"

  screen_config_assertions=$(( $screen_config_assertions + 1 ))
}

function assert_no_screen_config() {
  if test -e "$SCREEN_MOCK_CONFIG_FILE"; then
    fail "screen was called with a configuration file"
  fi
}

function begins_with() {
  case "$1" in
    "$2"*)
      true
    ;;
    *)
      false
    ;;
  esac
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
  unset SCIDE_DEFAULT
  unset SCIDE_DRY_RUN
  unset SCIDE_PROJECTS
  unset SCIDE_SCREEN

  export SCREEN_MOCK_DATA_FILE="${tmp_dir}/screen-mock-data"
  export SCREEN_MOCK_CONFIG_FILE="${tmp_dir}/screen-mock-config"

  PATH="$bin_dir:$mocks_dir:$PATH"

  mkdir "${tmp_dir}/twd"
  cd "${tmp_dir}/twd"

  setup_mocks
}

function common_teardown() {
  verify
}

function verify() {
  assert_equal "total screen calls assertions $screen_call_assertions" "total screen calls assertions 1"
  assert_equal "total screen config files assertions $screen_config_assertions" "total screen config files assertions 1"
}

function fail() {
  local msg="$@"

  >&2 echo "TEST ERROR: $msg"
  exit 2
}

function setup_mocks() {
  test -f "$SCREEN_MOCK_CONFIG_FILE" && rm -f "$SCREEN_MOCK_CONFIG_FILE"
  test -n "$SCREEN_MOCK_DATA_FILE" && echo -n "" > "$SCREEN_MOCK_DATA_FILE"
  screen_call_assertions=0
  screen_config_assertions=0
}

function screen_mock_config() {
  cat "$SCREEN_MOCK_CONFIG_FILE"
}

function screen_mock_executions() {
  cat "$SCREEN_MOCK_DATA_FILE"
}
