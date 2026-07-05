# S4-M200 Charset Optional Item Lookup

Result: passed.

Purpose: add `Charset.get()` as an optional single-byte lookup for custom ASCII
charsets. Alea already exposed checked `byteAt`, membership helpers, optional
probability lookup, and lazy probability iteration; S4-M200 adds
null-on-missing item lookup matching the reusable choice `get` ergonomics from
S4-M199.

## Local Reference

Local Rust `rand` uses slice-backed string/choice workflows, and Rust slices
provide `get` for optional item lookup. Alea's `Charset` is Zig-native and
byte-oriented, so this milestone exposes an explicit `Charset.get` helper
instead of copying a Rust trait shape.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/slice.rs`

## Alea API Added

`src/ascii.zig` now exposes:

- `Charset.get`.

Semantics:

- returns `?u8`;
- returns the byte for valid indexes;
- returns `null` out of bounds;
- preserves existing checked `byteAt`, membership, probability, probability
  iterator, and string-generation behavior.

Focused tests verify in-range first/last bytes and out-of-range `null` behavior
for predefined `Alphanumeric`.

## Adoption and Documentation

- `examples/string_generation.zig` prints
  `custom charset get(0)=... missing=true`.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the optional item lookup.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M201.

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
