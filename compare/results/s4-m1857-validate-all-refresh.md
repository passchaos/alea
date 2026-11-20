# S4-M1857 Validate-All Refresh After the Twelve-Point Rule and Charset Work

Date: 2026-11-20

`zig build validate-all --summary all -j2` on the S4-M1856 tree
(`2805a01c`, the packed charset fill) passes **124/124 steps and
1981/1981 tests**. The aggregate covers the S4-M1854 quantile twelve-point
Owen rule, the S4-M1855 public-CDF twelve-point rule and 20-point removal,
and the S4-M1856 packed charset fill.

Test artifacts:

- native `alea-tests`: 977/977;
- WASI `alea-tests-wasm32-wasi-node`: 977/977;
- `alea-apicheck-tests` 4, `alea-distcheck-tests` 2,
  `alea-distcheck-libc-tests` 2, `alea-statcheck-tests` 2,
  `alea-profilecheck-tests` 2, `alea-doccheck` 19,
  `alea-roadmapcheck-tests` 3, `alea-readmecheck-tests` 7,
  `alea-examplecheck-tests` 2, `alea-toolingcheck-tests` 3.

The step set includes native and WASI `distcheck` with the skew-normal CDF
reference values and the long-run blocks, `distcheck-libc`, `statcheck`,
`profilecheck`, `profilelongcheck`, `profilestresscheck`,
`profiletailcheck`, the PractRand self-test, the six crosscheck targets,
and the chained WASI report. The CDF rule changes move values by at most
1e-11 (S4-M1855) and the charset fill change is a versioned bulk stream
(S4-M1856), so the statistical gates are unaffected.

## Validation

- `zig build validate-all --summary all -j2`: 124/124 steps, 1981/1981
  tests.

## Next Bar

Keep the 50M long-run evidence and the no-known-gaps comparison current;
the large-hypergeometric codegen gap remains the only sub-parity comparable
workload.
