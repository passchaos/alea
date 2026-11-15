# S4-M1677 Vector Poisson Small-Lambda CDF Fill

Date: 2026-11-16

## Change

`VectorPoisson.fill`/`fillFrom` ran the per-lane product method for
`lambda < 12`. Added a hoisted inverse-CDF fill path: build a small Poisson
CDF table once per fill call, then draw each lane from one uniform with a
branchless vector search over the table. `sample`/`sampleFrom` keep the
product method, so this is a documented bulk-stream policy for the fill APIs
(the matrix already allows fills to follow each sampler's bulk stream).

The table keeps the true cumulative sum in its last entry instead of clamping
it. Lanes whose uniform lands in the truncated `1e-15` tail fall back to the
exact product method, so the fill distribution stays exactly Poisson; the
fallback rate is about `1e-15` per lane. `lambda >= 12` keeps the
Ahrens-Dieter path.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216`
rows (ScalarPrng):

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `fillVectorPoisson small u64x4 lambda=4` | 66.0 M lanes/s | 133.8 M lanes/s | +103% |
| `... small u64x4 direct lambda=4` | 80.6 M lanes/s | 130.4 M lanes/s | +62% |
| `fillVectorPoisson mid u64x4 lambda=11` | 45.6 M lanes/s | 81.3 M lanes/s | +78% |
| `... mid u64x4 direct lambda=11` | 56.2 M lanes/s | 80.5 M lanes/s | +43% |

Candidate rows kept as evidence: the lockstep product-method candidate
reaches 94-98M lanes/s, the scalar-scan CDF candidate 101-102M, and the
branchless vector CDF candidate 135-139M. The production path matches the
branchless candidate. Checksums change because the fill stream shape is
versioned; `sample`/`sampleFrom` checksums are unchanged.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950).
- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests, including new
  `VectorPoisson(lambda=4)` fill CDF gates at `2`, `4`, and `8` over 800k
  lanes.

## Changed Files

- `src/distributions.zig`: `poissonCdfTableSmall`,
  `vectorPoissonFromCdf`, and the product-method fill branches.
- `bench/vector.zig`: lambda-4/lambda-11 fill rows and candidate rows.
- `tools/distcheck.zig`: vector Poisson fill CDF gates.
- `compare/results/reproducibility-matrix.md`: records the versioned fill
  stream and bulk policy.
- `compare/results/simd-distribution-kernel-notes.md`: records the second
  adopted dense discrete fill kernel.
