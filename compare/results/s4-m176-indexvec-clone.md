# S4-M176 IndexVec Representation-Preserving Clone

Result: passed.

Purpose: add explicit deep cloning for `IndexVec`. Local Rust `rand` derives
`Clone` for `IndexVec`, which duplicates the owned backing representation. Alea
already supports owned backing adoption, equality, and consuming conversions;
this milestone adds a Zig-native allocator-explicit clone method that preserves
compact/native backing representation.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/index.rs` derives `Clone` for `IndexVec`;
- Rust cloning duplicates the active owned vector variant (`U32` or platform
  width backing);
- cloned values participate in the same `len`, iteration, equality, conversion,
  and ownership workflows as the source.

Alea uses explicit allocator ownership instead of Rust implicit allocation. The
new method takes an allocator, duplicates the current backing slice, and returns
an independent owned `IndexVec` that must be deinitialized by the caller.

## Alea API Added

`src/seq.zig` now exposes:

- `IndexVec.clone(allocator)`.

Semantics:

- compact `u32` backing clones to compact `u32` backing;
- native `usize` backing clones to native `usize` backing;
- cloned backing is independent from the source backing;
- allocation failure is reported and leaves the source unchanged.

Focused tests verify representation preservation, pointer independence,
content equality before source mutation, independence after source mutation,
and allocation-failure behavior.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints an `IndexVec.clone` equality row.
- `tools/examplecheck.zig` verifies the example source token.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe representation-preserving `IndexVec` deep clone.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "index vec clone"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked `IndexVec` clone ergonomics gap only. It does
not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
