# S4-M1221 Multivariate-Normal Small-Dimension Throughput

Date: 2026-07-16

## Gap

The initial S4-M1220 throughput rows reused a small output buffer and only
checksummed coordinate zero. Under ReleaseFast, LLVM could therefore remove
work for unobserved coordinates across repeated batch calls, producing
different direct/batch checksums and a false approximately threefold batch
speedup.

Common multivariate-normal workloads are also heavily concentrated in small
dimensions, while the original Cholesky transform used dynamic row-major
indexing and nested loops for every vector.

## Changes

- The throughput benchmark now allocates the complete measured output, observes
  every coordinate outside the timed region, and reports matching direct/batch
  checksums.
- `MultivariateNormal(f64)` specializes equivalent one-, two-, and
  three-dimensional Cholesky transforms. The operations retain the generic
  reverse-traversal multiply/add order.
- Full-rank three-dimensional f32/f64 batches draw `z0`, `z1`, and `z2`
  directly beside their triangular transform, removing dynamic dimension
  checks from the hottest batch shape.
- Rank-zero batches directly copy the deterministic mean without random draws.
- A focused regression test compares allocation-free batch output against
  repeated single-vector output and final RNG state for f32/f64 full-rank and
  f64 singular covariance.

## Performance

Same-host ReleaseFast/native 1GiB-count comparison:

```text
Baseline generic transform:
alea multivariate-normal direct: 81.4 M vectors/s checksum=-1052222.473
alea multivariate-normal many direct: 83.9 M vectors/s checksum=-1052222.473
alea multivariate-normal f32 direct: 158.8 M vectors/s checksum=-1052222.473
alea multivariate-normal f32 many direct: 75.8 M vectors/s checksum=-1052222.473

Accepted mixed specialization:
alea multivariate-normal direct: 123.5 M vectors/s checksum=-1052222.473
alea multivariate-normal many direct: 182.5 M vectors/s checksum=-1052222.473
alea multivariate-normal f32 direct: 159.6 M vectors/s checksum=-1052222.473
alea multivariate-normal f32 many direct: 173.0 M vectors/s checksum=-1052222.473
```

An attempted two-pass bulk-standard-normal transformation was rejected: it
regressed f64 batch throughput to about 78M and f32 batch to about 101M
vectors/s because the extra memory pass outweighed generation savings.

## Validation

```text
$ zig test src/distributions.zig -OReleaseFast --test-filter 'multivariate normal'
All 7 tests passed.

$ zig build -Doptimize=ReleaseFast statcheck --summary all
statcheck ok

$ zig build -Doptimize=ReleaseFast distcheck --summary all
distcheck ok

$ zig build crosscheck --summary all
Build Summary: 7/7 steps succeeded

$ zig build validate-local --summary all
Build Summary: 114/114 steps succeeded; 599/599 tests passed
```

A ReleaseFast direct `zig test src/distributions.zig` run also passes every new
multivariate-normal test and still reports only the pre-existing
`root.test.root random helpers validate deterministic cases before entropy`
failure documented by S4-M1220; the default validation aggregate passes fully.

## Scope

This closes S4-M1221's first performance follow-up for the new
full-covariance sampler. It does not complete the long-term mission; S4-M1222
remains open for broader runtime/validation work, dense default SIMD research,
or newly discovered core random-workflow gaps.
