# S4-M1160 Hypergeometric Large-Population Compatibility

## Gap

S4-M1159 aligned `NormalInverseGaussian` alpha-infinity rejection with local
`rand_distr 0.6.0`. A follow-up discrete-distribution audit found a
Hypergeometric constructor edge where local `rand_distr::Hypergeometric::new`
uses the HIN inverse-transform path and returns `PopulationTooLarge` when the
initial probability underflows to zero.

Alea already had HIN and H2PE-style Hypergeometric paths, but the HIN setup
previously treated an underflowed `initial_p` as "no HIN method" and silently
fell back to the draw-loop sampler. That accepted cases local `rand_distr`
rejects, and it made huge accepted cases more fragile because the mode and HIN
sampling internals used integer additions/casts that could overflow near
`u64::MAX`.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '203,220p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/hypergeometric.rs
        let m = ((k + 1) as f64 * (n1 + 1) as f64 / (n + 2) as f64).floor();
        let sampling_method = if m - f64::max(0.0, k as f64 - n2 as f64) < HIN_THRESHOLD {
            let (initial_p, initial_x) = if k < n2 {
                (
                    fraction_of_products_of_factorials((n2, n - k), (n, n2 - k)),
                    0,
                )
            } else {
                (
                    fraction_of_products_of_factorials((n1, k), (n, k - n2)),
                    (k - n2) as i64,
                )
            };

            if initial_p <= 0.0 || !initial_p.is_finite() {
                return Err(Error::PopulationTooLarge);
```

A local cargo probe confirms the constructor split:

```text
N=9000000000000000000 K=1 s=100 ok Hypergeometric { n1: 1, n2: 8999999999999999999, k: 100, offset_x: 0, sign_x: 1, sampling_method: InverseTransform { initial_p: 1.0, initial_x: 0 } }
N=9000000000000000000 K=100 s=10 ok Hypergeometric { n1: 100, n2: 8999999999999999900, k: 10, offset_x: 0, sign_x: 1, sampling_method: InverseTransform { initial_p: 1.0, initial_x: 0 } }
N=9000000000000000000 K=100 s=100 err PopulationTooLarge
N=1000000000000000000 K=100 s=100 err PopulationTooLarge
N=100000000000000000 K=100 s=100 err PopulationTooLarge
```

## Implementation

- `HypergeometricInverseTransform.init` is now fallible. It still returns
  `null` when the parameter set belongs to the large-mode H2PE path, but returns
  `error.InvalidParameter` when the local `rand_distr` HIN constructor would
  reject an underflowed or non-finite initial probability as `PopulationTooLarge`.
- `Hypergeometric.init` propagates that HIN setup error across reusable scalar
  and vector samplers plus checked scalar/vector sample and fill helpers.
- `hypergeometricMode` computes `k + 1`, `n1 + 1`, and `population + 2` after
  conversion to `f64`, avoiding integer-overflow panics for extreme accepted
  populations.
- HIN reduced-parameter offsets and sample-state math now stay in `u64` where
  Rust's internal `i64` casts would be too narrow, preserving accepted sparse
  huge-population cases on Alea's full `u64` public API.
- Focused tests cover accepted sparse large-population HIN cases, rejected
  underflow cases, scalar/vector checked no-consume behavior, and `u64::MAX`
  mode/sampling safety.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "hypergeometric"
1/3 distributions.test.negative-binomial and hypergeometric samplers have plausible moments...OK
2/3 distributions.test.hypergeometric large-population HIN overflow matches local rand_distr...OK
3/3 root.test_0...OK
All 3 tests passed.
```

## Full validation

```text
$ git diff --check
$ zig build roadmapcheck
roadmapcheck ok
$ zig build toolingcheck
toolingcheck ok
$ zig build rand-status
Alea local rand/rand_distr status (2026-07-10)
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1160 follow-ups closed for current bar
- Next bar: S4-M1161 post-S4-M1160 exact/default dense SIMD, broader runtime, or new local Rust gap
$ zig build rand-status-json
  "latest_validate_local_evidence": "compare/results/s4-m1160-hypergeometric-large-population.md"
$ zig build rand-status-schema-version
1
$ zig build rand-status-self-test
rand-status self-test ok
$ zig build validate-local
rand_distr standard-normal: 59.5 M samples/s checksum=-3.640
rand_distr standard-normal f32: 57.6 M samples/s checksum=-3.640
runtimecheck ok: no additional runtime runner available
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
distcheck ok
statcheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
examplecheck ok
$ zig build test
apicheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M1160 is closed for the current bar: Hypergeometric HIN setup now rejects
large-population initial-probability underflow like local `rand_distr`, while
retaining accepted sparse large-population construction and sampling on Alea's
full `u64` public parameter range. This is not whole-goal completion;
S4-M1161 remains active.
