# S4-M96 Rng Owned Standard Normal and Exponential Batches

Date: 2026-07-04

Purpose: add direct standard normal/exponential one-shot, caller-owned fill, and
allocation-returning scalar/vector batch helpers for `Rng`. This complements
Rust `rand_distr` primitives `StandardNormal` and `Exp1`, plus Alea's existing
parameterized S4-M90 scalar batches and S4-M95 vector batches, without forcing
users to spell `mean=0,stddev=1` or `rate=1` for standard distributions.

## Rust rand Comparison

The local `rand_distr 0.6.0` sources define `StandardNormal` and `Exp1` as the
primitive standard normal and standard exponential distributions, with f32
sampling implemented by sampling f64 then casting. Alea already used the same
standard-distribution stream shape internally through `standardNormalFastFrom`
and `standardExponentialFastFrom`; S4-M96 exposes that shape directly on `Rng`
for one-shot, caller-owned fill, and owned scalar/vector batch workflows.

This remains Zig-native rather than a trait port: batch helpers take an explicit
allocator, vector helpers return owned `[]@Vector(N, f32/f64)` slices, and
allocation failures happen before random-stream consumption.

Local Rust evidence inspected:

- `~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/normal.rs`
  defines `pub struct StandardNormal` and f32-through-f64 sampling;
- `~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/exponential.rs`
  defines `pub struct Exp1` and f32-through-f64 sampling.

## Change

Added standard normal helpers in `src/rng.zig`:

- `Rng.standardNormal(T)`;
- `Rng.standardNormalFrom(source, T)`;
- `Rng.fillStandardNormal(T, dest)`;
- `Rng.fillStandardNormalFrom(source, T, dest)`;
- `Rng.standardNormalBatch(T, allocator, count)`;
- `Rng.standardNormalBatchFrom(source, T, allocator, count)`;
- `Rng.vectorStandardNormalBatch(VectorType, allocator, count)`;
- `Rng.vectorStandardNormalBatchFrom(source, VectorType, allocator, count)`.

Added standard exponential helpers in `src/rng.zig`:

- `Rng.standardExponential(T)`;
- `Rng.standardExponentialFrom(source, T)`;
- `Rng.fillStandardExponential(T, dest)`;
- `Rng.fillStandardExponentialFrom(source, T, dest)`;
- `Rng.standardExponentialBatch(T, allocator, count)`;
- `Rng.standardExponentialBatchFrom(source, T, allocator, count)`;
- `Rng.vectorStandardExponentialBatch(VectorType, allocator, count)`;
- `Rng.vectorStandardExponentialBatchFrom(source, VectorType, allocator, count)`.

The standard helpers route to the same `standardNormalFastFrom` /
`standardExponentialFastFrom` core paths as the parameterized APIs with standard
parameters. Focused tests verify standard helper stream shape against checked
`normal(..., 0, 1)` / `exponential(..., 1)` scalar and vector fills/batches.
Allocation-failure tests verify that owned scalar/vector standard batches do not
consume the random stream before allocation succeeds.

Updated adoption/docs:

- `examples/basic.zig` prints `standardNormalBatch`,
  `standardExponentialBatch`, `vectorStandardNormalBatch f64x4`, and
  `vectorStandardExponentialBatch f64x4` rows;
- `docs/examples.md` describes standard-and-parameterized normal/exponential
  batches in the basic example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions scalar/vector standard-or-parameterized
  normal/exponential batches;
- `tools/examplecheck.zig` guards the basic example tokens;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include S4-M96 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-basic
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- scalar standard normal/exponential one-shot, fill, and owned batch API smoke;
- vector standard normal/exponential owned batch API smoke;
- standard scalar/vector fill and owned-batch stream-shape parity versus checked
  parameterized `normal(..., 0, 1)` and `exponential(..., 1)` paths;
- zero-count owned standard batches returning empty slices before allocation
  failure or random-stream consumption;
- scalar/vector owned standard-batch allocation failures without consuming the
  random stream.

## S4-M96 Decision

S4-M96 is closed for the current `Rng` owned standard normal/exponential batch
bar: callers can now use direct standard-distribution one-shot, fill, and owned
scalar/vector batch helpers without parameter boilerplate or generic sampler
wrappers.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
