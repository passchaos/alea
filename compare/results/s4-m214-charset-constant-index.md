# S4-M214 Charset Singleton Constant-Index Diagnostics

Result: passed.

Purpose: add `Charset.constantIndex()` as a custom ASCII charset diagnostic for
single-byte no-consume sampling paths. `Charset` already returns/fills the only
byte without consuming randomness when its alphabet has one byte; S4-M214
exposes that point-mass index directly and aligns string-generation diagnostics
with `Choice.constantIndex`.

## Local Reference

Local Rust `rand` exposes `distr::slice::Choose::num_choices()` for reusable
slice choices, and Alea already exposes `Charset.numChoices()` for count
diagnostics. `Charset.constantIndex()` is a Zig-native diagnostic alias for the
deterministic single-byte case rather than a Rust trait port.

Relevant local Rust source:

- `/home/passchaos/Work/rand/src/distr/slice.rs`

## Alea API Added

`src/ascii.zig` now exposes:

- `Charset.constantIndex`.

Semantics:

- returns `?usize`;
- returns `0` for single-byte charsets;
- returns `null` for charsets with more than one byte;
- empty charsets are only reachable through manually constructed values and
  return `null`;
- does not allocate;
- does not consume randomness;
- matches the deterministic no-consume sample/fill/alloc path used by
  single-byte `Charset`.

Focused tests verify multi-byte `null` and single-byte `0` behavior alongside
the existing single-byte no-consume stream tests.

## Adoption and Documentation

- `examples/string_generation.zig` prints `custom charset constantIndex: ...`
  and `single charset constantIndex: ...`.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the diagnostic.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M215.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "ascii helpers generate expected shapes"`
- `zig test src/root.zig --test-filter "single-byte charset helpers do not consume random stream"`
- `zig build run-string-generation`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked charset diagnostics gap only. It does not
resolve S4-M11's exact/default-compatible dense SIMD normal/exponential blocker,
does not add a new architecture/runtime runner, and is not whole-goal completion
evidence.
