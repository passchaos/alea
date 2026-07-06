#!/usr/bin/env sh
set -eu

usage() {
  cat >&2 <<'USAGE'
usage: tools/practrand.sh [--dry-run] [ENGINE] [BYTES]
       tools/practrand.sh --self-test

Runs Alea raw RNG output through PractRand RNG_test stdin64.

Arguments:
  ENGINE  Alea stream engine name accepted by `zig build stream` (default: fast)
  BYTES   Number of bytes to stream (default: 1073741824)

Environment:
  PRACTRAND_BIN  PractRand executable to run (default: RNG_test)

Examples:
  tools/practrand.sh fast 1073741824
  tools/practrand.sh --dry-run default 1048576
  tools/practrand.sh --self-test
USAGE
}

DRY_RUN=0
if [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi
if [ "${1:-}" = "--self-test" ]; then
  SELF_PATH=$0
  DEFAULT_OUTPUT=$("$SELF_PATH" --dry-run)
  if [ "$DEFAULT_OUTPUT" != "zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1073741824 | RNG_test stdin64" ]; then
    echo "practrand self-test: default dry-run command mismatch" >&2
    printf '%s\n' "$DEFAULT_OUTPUT" >&2
    exit 1
  fi

  CUSTOM_OUTPUT=$(PRACTRAND_BIN=/tmp/RNG_test_custom "$SELF_PATH" --dry-run default 1048576)
  if [ "$CUSTOM_OUTPUT" != "zig build -Doptimize=ReleaseFast stream -- --engine default --bytes 1048576 | /tmp/RNG_test_custom stdin64" ]; then
    echo "practrand self-test: custom dry-run command mismatch" >&2
    printf '%s\n' "$CUSTOM_OUTPUT" >&2
    exit 1
  fi

  SELF_TEST_OUTPUT=$(mktemp "${TMPDIR:-/tmp}/alea-practrand-self-test.XXXXXX")
  trap 'rm -f "$SELF_TEST_OUTPUT"' EXIT
  if "$SELF_PATH" --dry-run fast 1 extra >"$SELF_TEST_OUTPUT" 2>&1; then
    echo "practrand self-test: invalid argument count unexpectedly succeeded" >&2
    exit 1
  fi
  grep -Fq "usage: tools/practrand.sh" "$SELF_TEST_OUTPUT" || {
    echo "practrand self-test: invalid argument usage output mismatch" >&2
    cat "$SELF_TEST_OUTPUT" >&2
    exit 1
  }

  echo "practrand self-test ok"
  exit 0
fi
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=1
  shift
fi

ENGINE="${1:-fast}"
BYTES="${2:-1073741824}"
PRACTRAND_BIN="${PRACTRAND_BIN:-RNG_test}"

if [ $# -gt 2 ]; then
  usage
  exit 2
fi

STREAM_CMD="zig build -Doptimize=ReleaseFast stream -- --engine $ENGINE --bytes $BYTES"
PRACTRAND_CMD="$PRACTRAND_BIN stdin64"

if [ "$DRY_RUN" -eq 1 ]; then
  printf '%s | %s\n' "$STREAM_CMD" "$PRACTRAND_CMD"
  exit 0
fi

if ! command -v "$PRACTRAND_BIN" >/dev/null 2>&1; then
  echo "$PRACTRAND_BIN not found. Install PractRand and ensure $PRACTRAND_BIN is on PATH, or set PRACTRAND_BIN." >&2
  echo "Example: tools/practrand.sh fast 1073741824" >&2
  echo "Dry run: tools/practrand.sh --dry-run fast 1073741824" >&2
  exit 127
fi

zig build -Doptimize=ReleaseFast stream -- --engine "$ENGINE" --bytes "$BYTES" | "$PRACTRAND_BIN" stdin64
