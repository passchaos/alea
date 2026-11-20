# S4-M1866 Validate-All Refresh After the Reusable CDF Models

Date: 2026-11-20

`zig build validate-all --summary all -j2` on the S4-M1865 tree
(`7f1c29a5`) passes **124/124 steps and 1987/1987 tests**. The aggregate
covers the three reusable CDF models added after S4-M1861
(`VonMisesCdfModel`, `SkewNormalCdfModel`, `WrappedSkewNormalCdfModel`)
plus the earlier S4-M1854..M1862 rule, charset, and vector changes.

Test artifacts:

- native `alea-tests`: 999/999;
- WASI `alea-tests-wasm32-wasi-node`: 999/999;
- `alea-apicheck-tests` 4, `alea-distcheck-tests` 2,
  `alea-distcheck-libc-tests` 2, `alea-statcheck-tests` 2,
  `alea-profilecheck-tests` 2, `alea-doccheck` 19,
  `alea-roadmapcheck-tests` 3, `alea-readmecheck-tests` 7,
  `alea-examplecheck-tests` 2, `alea-toolingcheck-tests` 3.

The step set includes native and WASI `distcheck` with the skew CDF and
long-run gates, `distcheck-libc`, `statcheck`, `profilecheck`,
`profilelongcheck`, `profilestresscheck`, `profiletailcheck`, the PractRand
self-test, the six crosscheck targets, and the chained WASI report.

The models add public API but no stream changes: `SkewNormalCdfModel` is
bit-identical to the free CDF, `VonMisesCdfModel` agrees to 3.6e-13, and
`WrappedSkewNormalCdfModel` agrees to 8.04e-11 (all documented in their
types), so the statistical gates are unaffected.

## Validation

- `zig build validate-all --summary all -j2`: 124/124 steps, 1987/1987
  tests.

## Next Bar

The 1e9 background run remains the next statistical bar; the
large-hypergeometric codegen gap remains the only sub-parity comparable
workload.
