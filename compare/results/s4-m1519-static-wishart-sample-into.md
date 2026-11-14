# S4-M1519 Static Wishart Caller-Matrix Sample APIs

Date: 2026-11-15

## Change

`StaticMatrixNormal` and `StaticMatrixT` expose `sampleInto` /
`sampleIntoFrom` to fill a caller-owned `Matrix`, but `StaticWishart` and
`StaticInverseWishart` only returned a new matrix. Added the missing pair:

- `StaticWishart(T, dim).sampleInto(rng, *Matrix)`
- `StaticWishart(T, dim).sampleIntoFrom(source, *Matrix)`
- `StaticInverseWishart(T, dim).sampleInto(rng, *Matrix)`
- `StaticInverseWishart(T, dim).sampleIntoFrom(source, *Matrix)`

Both forward to the existing `sampleFrom` implementation, so the stream and
values are identical to the return-value APIs.

## Validation

- The Wishart batch test now compares `sampleIntoFrom` against `sampleFrom`
  from an identically seeded source for both static samplers, including the
  final engine state, and exercises the `Rng`-based `sampleInto` path.
- Four new `docs/api-reference.md` entries pass `apicheck`.
- `zig build test -Dtest-filter=Wishart doccheck --summary all` passes 36/36
  steps and 17/17 `alea-tests`.
- `zig build test --summary all` passes 938/938 (native `alea-tests`
  917/917) and `zig build distcheck` passes.

No RNG stream or existing output changed.
