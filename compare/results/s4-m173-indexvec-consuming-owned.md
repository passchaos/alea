# S4-M173 IndexVec Consuming Owned Conversions

Result: passed.

Purpose: add consuming owned-slice conversions for compact `IndexVec` results.
Before this milestone, callers could copy an `IndexVec` to owned `[]usize` or
`[]u32` slices through `toOwnedSlice` / `toOwnedU32Slice`, but then still needed
to `deinit` the original `IndexVec`. Local Rust `rand` exposes
`IndexVec::into_vec`, which consumes the index vector and returns owned indexes.
S4-M173 adds Zig-native consuming conversions while preserving explicit compact
`u32` export behavior.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/index.rs` exposes `IndexVec::into_vec`,
  consuming the sampled index vector and returning `Vec<usize>`;
- Rust hides the backing representation behind `IndexVec`, and conversion may
  or may not be trivial;
- Alea already exposes explicit non-consuming `toOwnedSlice` and
  `toOwnedU32Slice` conversions plus `deinit`.

This milestone keeps Alea explicit: consuming conversions are named
`intoOwned*`, transfer matching backings directly, and still offer compact `u32`
output separately.

## Alea API Added

`src/seq.zig` now exposes:

- `IndexVec.intoOwnedSlice`;
- `IndexVec.intoOwnedU32Slice`.

Semantics:

- `intoOwnedSlice` returns the existing `usize` backing directly when present;
- `intoOwnedSlice` widens `u32` backing to `usize`, frees the consumed `u32`
  backing after successful allocation/copy, and returns the widened slice;
- `intoOwnedU32Slice` returns the existing `u32` backing directly when present;
- `intoOwnedU32Slice` narrows `usize` backing to `u32`, rejects values above
  `maxInt(u32)`, frees the consumed `usize` backing after successful
  allocation/copy, and returns the narrowed slice.

Focused tests verify:

- compact `IndexVec` results can be consumed into owned `[]usize` or `[]u32`;
- matching backings transfer without copying;
- `usize` backing narrows to `u32` when representable;
- non-representable `usize` backing returns `error.InvalidParameter`;
- allocation failure does not free the source backing before conversion
  succeeds.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `IndexVec.intoOwnedSlice` and
  `IndexVec.intoOwnedU32Slice` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe consuming `IndexVec` conversion ergonomics.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "index vec consuming owned conversions"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked `IndexVec` ownership ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
