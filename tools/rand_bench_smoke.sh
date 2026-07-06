#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'USAGE'
usage: rand_bench_smoke.sh [bytes] [filter]
       rand_bench_smoke.sh [filter]

Runs a tiny filtered local Rust rand/rand_distr comparison benchmark and checks
that the requested filtered row appears while unrelated byte-throughput rows do
not. Defaults to: bytes=1024 filter=standard-normal.
USAGE
}

if [[ "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if (( $# > 2 )); then
    usage >&2
    exit 2
fi

if ! command -v cargo >/dev/null 2>&1; then
    echo "rand_bench_smoke: cargo is required" >&2
    exit 127
fi

bytes=1024
filter=standard-normal
if (( $# >= 1 )); then
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        bytes="$1"
        if (( $# == 2 )); then
            filter="$2"
        fi
    else
        filter="$1"
        if (( $# == 2 )); then
            echo "rand_bench_smoke: filter-only mode accepts one argument" >&2
            usage >&2
            exit 2
        fi
    fi
fi

manifest="${ALEA_RAND_BENCH_MANIFEST:-compare/rand_bench/Cargo.toml}"
expected_row="${ALEA_RAND_BENCH_EXPECTED_ROW:-$filter}"

output=$(cargo run --manifest-path "$manifest" -- "$bytes" "$filter")
printf '%s\n' "$output"

if ! grep -Fiq "$expected_row" <<<"$output"; then
    echo "rand_bench_smoke: expected filtered row containing '$expected_row' in Rust comparison output" >&2
    exit 1
fi

if grep -Fq "rand SmallRng:" <<<"$output"; then
    echo "rand_bench_smoke: filter leaked unrelated byte-throughput row" >&2
    exit 1
fi
