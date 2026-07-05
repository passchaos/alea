# S4-M174 IndexVec Content Equality

Result: passed.

Purpose: add representation-independent content equality for compact `IndexVec`
results. Local Rust `rand` derives/implements `PartialEq` for `IndexVec` and
compares `U32` and platform-width backing variants by index contents. Alea
already exposed explicit accessors and conversions; this milestone adds the
same comparison ergonomics in Zig-native method form.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/index.rs` implements `PartialEq for
  IndexVec`;
- matching variants compare their owned vectors directly;
- mixed `U32`/`U64` variants on 64-bit targets compare length and widened index
  contents.

Alea uses `u32` and `usize` backing slices. `IndexVec.eql` follows the same
content semantics without importing Rust trait machinery.

## Alea API Added

`src/seq.zig` now exposes:

- `IndexVec.eql(other)`.

Semantics:

- returns `false` when lengths differ;
- uses direct `std.mem.eql` when both backings have the same element type;
- compares widened contents when one backing is compact `u32` and the other is
  native `usize`;
- treats empty `u32` and empty `usize` index vectors as equal.

Focused tests verify same-backing equality, cross-backing equality in both
argument orders, value mismatch, length mismatch, and empty cross-backing
vectors.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints an `IndexVec.eql cross-backing` row.
- `tools/examplecheck.zig` verifies the example source token.
- `docs/api-reference.md` lists `IndexVec.eql`.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe cross-backing `IndexVec` equality.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "index vec equality"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked `IndexVec` comparison ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
