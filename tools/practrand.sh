#!/usr/bin/env sh
set -eu

usage() {
  cat >&2 <<'USAGE'
usage: tools/practrand.sh [--dry-run] [ENGINE] [BYTES]

Runs Alea raw RNG output through PractRand RNG_test stdin64.

Arguments:
  ENGINE  Alea stream engine name accepted by `zig build stream` (default: fast)
  BYTES   Number of bytes to stream (default: 1073741824)

Environment:
  PRACTRAND_BIN  PractRand executable to run (default: RNG_test)

Examples:
  tools/practrand.sh fast 1073741824
  tools/practrand.sh --dry-run default 1048576
USAGE
}

DRY_RUN=0
if [ "${1:-}" = "--help" ]; then
  usage
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
