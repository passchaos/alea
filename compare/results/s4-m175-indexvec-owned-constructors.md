# S4-M175 IndexVec Owned Backing Constructors

Result: passed.

Purpose: add explicit owned-backing constructors for `IndexVec`. Local Rust
`rand` supports constructing `IndexVec` from owned backing vectors via
`From<Vec<u32>>` and, on 64-bit targets, `From<Vec<u64>>`. Alea already exposed
sampling-produced `IndexVec` values plus copying/consuming conversions; this
milestone adds Zig-native adoption of caller-owned compact or native backing
slices without copying.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/index.rs` implements `From<Vec<u32>> for
  IndexVec`;
- 64-bit Rust targets also implement `From<Vec<u64>> for IndexVec`;
- these conversions adopt owned backing vectors and then participate in the same
  `len`, indexing, iteration, equality, and conversion APIs as sampled
  `IndexVec` results.

Alea uses explicit allocator ownership instead of Rust `Vec` ownership. The new
constructors accept owned slices and make `IndexVec.deinit` responsible for
freeing them with the matching allocator.

## Alea API Added

`src/seq.zig` now exposes:

- `IndexVec.fromOwnedSlice(items: []usize)`;
- `IndexVec.fromOwnedU32Slice(items: []u32)`.

Semantics:

- both constructors adopt the caller-provided owned backing without copying;
- `fromOwnedSlice` stores native `usize` indexes;
- `fromOwnedU32Slice` stores compact `u32` indexes;
- adopted vectors work with `len`, `at`, `iter`, `eql`, `copyInto`, and
  `deinit` like sampled `IndexVec` results.

Focused tests verify pointer identity for both constructors, accessors, equality
against another backing representation, and copy-out behavior.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `IndexVec.fromOwnedSlice` and
  `IndexVec.fromOwnedU32Slice` equality rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe owned-backing adoption.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "owned-slice constructors"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked `IndexVec` owned-construction ergonomics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
