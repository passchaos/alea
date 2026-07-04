# S4-M163 Choice Value and Pointer Arrays

Result: passed.

Purpose: add fixed-size repeated value and const-pointer arrays to reusable
unweighted choices. `Choice` already exposed value/pointer fills, owned
value/pointer batches, index fills, owned index batches, and S4-M162 fixed index
arrays. The remaining reusable-choice asymmetry was stack-friendly repeated
value and pointer output.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes indexed slice choice,
  pointer/reference choice, and fixed-size sample workflows through Rust traits;
- Alea sequence helpers already expose `chooseArray` / `sampleItemsArray` and
  `choosePtrArray` / `samplePtrArray` for no-replacement fixed-size slice
  samples;
- reusable `Choice.values*` / `Choice.ptrs*` already covered heap-owned
  repeated with-replacement batches.

This milestone adds the analogous reusable-sampler, repeated with-replacement,
stack-output shape without introducing Rust trait machinery.

## Alea API Added

`src/seq.zig` now exposes on `Choice(T)`:

- `Choice.valueArray`;
- `Choice.valueArrayFrom`;
- `Choice.ptrArray`;
- `Choice.ptrArrayFrom`.

The value helpers return `[N]T`. The pointer helpers return `[N]*const T`.
Both mirror the existing caller-owned `fillValuesFrom` / `fillFrom` stream
shape.

Focused tests verify:

- fixed value arrays match caller-owned `fillValuesFrom` under identical seeds;
- fixed const-pointer arrays match caller-owned `fillFrom` under identical
  seeds;
- facade and direct-source paths preserve stream shape;
- zero-length fixed arrays return without sampling;
- single-item choices return deterministic arrays without consuming the random
  stream.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `Choice.valueArrayFrom` and
  `Choice.ptrArrayFrom` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe fixed-size reusable choice value/pointer arrays.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "Choice value and pointer arrays"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable unweighted choice stack-output
ergonomics gap only. It does not resolve S4-M11's exact/default-compatible dense
SIMD normal/exponential blocker, does not add a new architecture/runtime runner,
and is not whole-goal completion evidence.
