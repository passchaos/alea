# S4-M204 Charset Checked Item Alias

Result: passed.

Purpose: add `Charset.item()` as a checked byte lookup alias for custom ASCII
charsets. Alea already exposed checked `byteAt` and optional `get`; S4-M204
adds the same concise checked item naming style used by reusable `Choice.item`
from S4-M203.

## Local Reference

Local Rust slice workflows make item lookup naming easy to discover from the
sampler context. Alea's `Charset` remains Zig-native and byte-oriented, but
`Charset.item()` gives string-generation users the same checked item lookup
vocabulary as reusable choice samplers while preserving `byteAt`.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/slice.rs`

## Alea API Added

`src/ascii.zig` now exposes:

- `Charset.item`.

Semantics:

- returns the same `u8` as `byteAt(index)` for valid indexes;
- returns `error.InvalidParameter` out of bounds;
- preserves optional `get`, existing `byteAt`, probability diagnostics,
  probability iterators, and string-generation behavior.

Focused tests verify valid first/last bytes and out-of-range error behavior for
predefined `Alphanumeric`.

## Adoption and Documentation

- `examples/string_generation.zig` prints `custom charset item(0)=...`.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the checked item alias.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M205.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "ascii"`
- `zig build run-string-generation`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked charset diagnostics ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
