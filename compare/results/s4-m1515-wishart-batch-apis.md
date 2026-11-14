# S4-M1515 Wishart and Inverse-Wishart Batch Sampling APIs

Date: 2026-11-15

## Change

The matrix-variate family was inconsistent: `MatrixNormal`, `MatrixT`,
`Dirichlet`, and `Multinomial` expose batch `sampleManyInto` /
`sampleManyIntoFrom` methods, but `Wishart` and `InverseWishart` only had
single-draw methods. The allocator-backed samplers now provide:

- `Wishart(T).sampleManyInto` / `sampleManyIntoFrom` — fill consecutive
  `dim×dim` draws into one flat `[]T` buffer with no per-draw allocation.
- `Wishart(T).sampleManyIntoChecked` / `sampleManyIntoCheckedFrom` — reject
  lengths that are not a multiple of `dim·dim`.
- `InverseWishart(T).sampleManyInto` / `sampleManyIntoFrom` /
  `sampleManyIntoChecked` / `sampleManyIntoCheckedFrom` — the same surface.
- `StaticWishart(T, dim).sampleManyInto` / `sampleManyIntoFrom` and
  `StaticInverseWishart(T, dim).sampleManyInto` / `sampleManyIntoFrom` —
  fill `[]Matrix` from repeated comptime-dimension draws.

The batch path reuses the existing per-draw kernels, so it consumes exactly
the same random stream as repeated single draws and changes no existing
output.

## Tests

New unit test `Wishart batch sampling matches repeated draws and validates
lengths` covers:

- dynamic `Wishart` and `InverseWishart` flat batches against three
  consecutive single draws from an identically seeded source, including the
  final engine state;
- checked batches rejecting `len = 5` for `dim = 2` and accepting `len = 8`;
- empty batches not consuming randomness;
- static `StaticWishart` / `StaticInverseWishart` `[]Matrix` batches against
  repeated `sampleFrom` draws with matching engine state;
- f32 batch output staying positive definite per block.

`zig build test -Dtest-filter=Wishart --summary all` passes 17/17
`alea-tests`, and `zig build test --summary all` passes 938/938 (native
917/917). `zig build doccheck` (including `apicheck` for the 12 new API
entries) and `zig build distcheck` pass.

## Stream and Performance

No RNG stream or existing output changed. The batch methods remove repeated
allocator calls for multi-draw Bayesian workflows; they do not change the
per-draw arithmetic.
