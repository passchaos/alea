# S4-M1503 Matrix-Normal Cholesky Diagonal Fix

Date: 2026-11-15

## Change

The dynamic `MatrixNormal.sampleIntoUnchecked` and the comptime
`StaticMatrixNormal` sampler multiplied `Z` by the strictly lower triangle of
each Cholesky factor and omitted the diagonal:

```
X[row] = Z[row] + Σ_{k<row} L[row,k]·Z[k]      (should be L[row,row]·Z[row] + …)
```

so every covariance diagonal was silently replaced by 1. A 1×1 matrix normal
with row variance 4 sampled with variance 1, and a 2×1 with row covariance
`diag(4, 9)` sampled with variances 1 and 1. `MatrixT` inherits the fix
through the shared factor.

Both transforms now start from `Z[row]·L[row,row]` (and `Z[col]·L[col,col]`
for the right multiply). The existing correlation-matrix tests still pass
because their `L[0,0] = 1` and their cross-covariances only depend on the
strictly lower entries.

This is a deliberate versioned stream change for non-identity covariances.

## Before/After

| case | before | after | reference |
| --- | --- | --- | --- |
| `MatrixNormal` 1×1, row var 4 | 1.0008 | 4.0032 | 4 |
| `MatrixNormal` 2×1, row `diag(4, 9)` | 1.0021 / 1.0010 | 4.0083 / 9.0088 | 4 / 9 |
| `StaticMatrixNormal` 1×1, row var 4 | 1.0012 | 4.0046 | 4 |

200,000 samples each. The new unit test
`MatrixNormal recovers non-unit covariance scales` gates both the dynamic and
static paths at 20,000 samples.

## Stream and Performance

- `alea matrix normal 2x3` checksum `7176219298974891891` →
  `6414785259981111224`, throughput 88.9M → 85.9M samples/s;
- `alea matrix t 2x3` checksum `6077713839199129262` →
  `1707161836478801433`, throughput 62.2M → 61.3M samples/s.

The checksum changes are the intended distribution correction; the
throughput stays within noise.

## Validation

- `zig build test --summary all` passes 930/930 (native `alea-tests` 911/911).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
