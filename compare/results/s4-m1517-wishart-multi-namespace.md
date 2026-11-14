# S4-M1517 Wishart Family in the `multi` Namespace

Date: 2026-11-15

## Change

The `multi` namespace exposed `Dirichlet`, the multivariate normal/t/Laplace/
skew-normal family, both copulas, `MatrixNormal`/`StaticMatrixNormal`,
`MatrixT`/`StaticMatrixT`, `MatrixVonMisesFisher`, and `MatrixFisher`, but
not the Wishart family even though those are matrix-variate distributions.
Added four namespace aliases:

- `multi.Wishart(T)`
- `multi.InverseWishart(T)`
- `multi.StaticWishart(T, dimension)`
- `multi.StaticInverseWishart(T, dimension)`

They return the same types as the top-level declarations, so no code
generation or stream behavior changes.

## Validation

- The Wishart batch test now asserts all four aliases are identical to their
  top-level types at comptime.
- `zig build test -Dtest-filter=Wishart doccheck --summary all` passes
  36/36 steps and 17/17 `alea-tests` (including `apicheck` for the four new
  API-reference entries).
- `zig build test --summary all` passes 938/938 (native `alea-tests`
  917/917) and `zig build distcheck` passes.

No RNG stream or sampling code changed.
