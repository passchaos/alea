# S4-M1861 Validate-All Refresh After the Cos-Polynomial Work

Date: 2026-11-20

`zig build validate-all --summary all -j2` on the S4-M1860 tree
(`087c51f6`) passes **124/124 steps and 1981/1981 tests**. The aggregate
covers the S4-M1858 vectorized Owen geometry cos polynomial and the
S4-M1860 vector cos polynomial in the von Mises f64x4 kernel (plus the
earlier S4-M1854..M1856 rule and charset changes).

Test artifacts:

- native `alea-tests`: 977/977;
- WASI `alea-tests-wasm32-wasi-node`: 977/977;
- `alea-apicheck-tests` 4, `alea-distcheck-tests` 2,
  `alea-distcheck-libc-tests` 2, `alea-statcheck-tests` 2,
  `alea-profilecheck-tests` 2, `alea-doccheck` 19,
  `alea-roadmapcheck-tests` 3, `alea-readmecheck-tests` 7,
  `alea-examplecheck-tests` 2, `alea-toolingcheck-tests` 3.

The step set includes native and WASI `distcheck` with the skew CDF and
long-run gates, `distcheck-libc`, `statcheck`, `profilecheck`,
`profilelongcheck`, `profilestresscheck`, `profiletailcheck`, the PractRand
self-test, the six crosscheck targets, and the chained WASI report.

Accuracy notes for this tree: the S4-M1858 geometry polynomial changes
public CDF values by at most 1e-11 at the rule level and produced zero
changed values on a 393,060-point plain/wrapped skew CDF grid, so the
statistical gates are unaffected. The S4-M1860 change is a versioned
low-bit stream for `VectorVonMises(f64x4)` (recorded in
`reproducibility-matrix.md`); the vector moment tests and the long-run
vector gates for vMF/Watson/Bingham pass.

## Validation

- `zig build validate-all --summary all -j2`: 124/124 steps, 1981/1981
  tests.

## Next Bar

The 1e9 background run is the next statistical bar; the
large-hypergeometric codegen gap remains the only sub-parity comparable
workload.
