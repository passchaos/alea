# S4-M164 WeightedChoice Value and Pointer Arrays

Result: passed.

Purpose: add fixed-size repeated value and const-pointer arrays to reusable
weighted choices. `WeightedChoice` already exposed value/pointer fills, owned
value/pointer batches, index fills, owned index batches, and fixed index arrays.
After S4-M163 added reusable unweighted `Choice.valueArray*` and `ptrArray*`,
the remaining reusable-choice asymmetry was stack-friendly repeated weighted
value and pointer output.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes weighted slice choice and
  repeated weighted-reference workflows through `choose_weighted`,
  `choose_weighted_mut`, and iterator-style APIs;
- cached local `rand_distr 0.6.0` exposes reusable weighted index samplers such
  as `WeightedAliasIndex` and `WeightedTreeIndex`;
- Alea sequence helpers already expose fixed-size weighted item and pointer
  arrays for no-replacement workflows, while `WeightedChoice.values*` and
  `WeightedChoice.ptrs*` covered heap-owned repeated with-replacement batches.

This milestone adds the analogous reusable weighted-sampler, repeated
with-replacement, stack-output shape without copying Rust trait machinery.

## Alea API Added

`src/seq.zig` now exposes on `WeightedChoice(T, Weight)`:

- `WeightedChoice.valueArray`;
- `WeightedChoice.valueArrayFrom`;
- `WeightedChoice.ptrArray`;
- `WeightedChoice.ptrArrayFrom`.

The value helpers return `[N]T`. The pointer helpers return `[N]*const T`.
Both mirror the existing caller-owned `fillValuesFrom` / `fillFrom` stream
shape.

Focused tests verify:

- fixed value arrays match caller-owned `fillValuesFrom` under identical seeds;
- fixed const-pointer arrays match caller-owned `fillFrom` under identical
  seeds;
- facade and direct-source paths preserve stream shape;
- zero-length fixed arrays return without sampling;
- single-positive weighted choices return deterministic arrays without
  consuming the random stream.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `WeightedChoice.valueArrayFrom` and
  `WeightedChoice.ptrArrayFrom` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe fixed-size reusable weighted-choice value/pointer arrays.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "WeightedChoice value and pointer arrays"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable weighted choice stack-output
ergonomics gap only. It does not resolve S4-M11's exact/default-compatible dense
SIMD normal/exponential blocker, does not add a new architecture/runtime runner,
and is not whole-goal completion evidence.
