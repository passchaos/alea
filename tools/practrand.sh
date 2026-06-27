#!/usr/bin/env sh
set -eu

ENGINE="${1:-fast}"
BYTES="${2:-1073741824}"

if ! command -v RNG_test >/dev/null 2>&1; then
  echo "RNG_test not found. Install PractRand and ensure RNG_test is on PATH." >&2
  echo "Example: ./tools/practrand.sh fast 1073741824" >&2
  exit 127
fi

zig build -Doptimize=ReleaseFast stream -- --engine "$ENGINE" --bytes "$BYTES" | RNG_test stdin64
