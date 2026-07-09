# S4-M1156 Geometric Zero-Probability Compatibility

## Gap

S4-M1155 aligned Alea Poisson max-lambda validation with local
`rand_distr::Poisson::new`. A follow-up discrete-distribution audit found that
local `rand_distr::Geometric::new(p)` is a failure-count distribution and accepts
`p == 0.0` and `p == -0.0`; sampling those states returns `u64::MAX` without
using random draws because `1.0 - p` rounds to `1.0`.

Alea intentionally keeps `Geometric` as its one-based trial-count sampler, where
`p == 0` remains invalid because there is no finite trial count for a success.
The Rust-style failure-count API is `GeometricFailures`, so S4-M1156 aligns that
surface with local `rand_distr` while also making one-based `Geometric` saturate
tiny positive probabilities whose failure-count baseline saturates.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '77,90p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/geometric.rs
    pub fn new(p: f64) -> Result<Self, Error> {
        let mut pi = 1.0 - p;
        if !p.is_finite() || !(0.0..=1.0).contains(&p) {
            Err(Error::InvalidProbability)
        } else if pi == 1.0 || p >= 2.0 / 3.0 {
            Ok(Geometric { p, pi, k: 0 })
        } else {
```

```text
$ sed -n '103,118p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/geometric.rs
        if self.p >= 2.0 / 3.0 {
            // use the trivial algorithm:
            let mut failures = 0;
            loop {
                let u = rng.random::<f64>();
                if u <= self.p {
                    break;
                }
                failures += 1;
            }
            return failures;
        }

        if self.pi == 1.0 {
            return u64::MAX;
        }
```

A local cargo probe using a constant-zero RNG confirms constructor and sample
edges:

```text
p=0.0 ok sample=18446744073709551615
p=-0.0 ok sample=18446744073709551615
p=2.2250738585072014e-308 ok sample=18446744073709551615
p=1e-320 ok sample=18446744073709551615
p=1.0 ok sample=0
p=inf err=InvalidProbability
p=NaN err=InvalidProbability
```

## Implementation

- `GeometricFailures` and `VectorGeometricFailures` now accept `p == 0.0` and
  `p == -0.0` and return or fill `std.math.maxInt(u64)` without consuming
  randomness.
- Failure-count helpers also saturate tiny finite probabilities where `1.0 - p`
  rounds to `1.0`, matching local `rand_distr`'s `pi == 1.0` branch.
- One-based `Geometric` keeps `p == 0` invalid, preserving Alea's documented
  trial-count semantics, but it now saturates tiny positive probabilities to
  `maxInt(u64)` instead of overflowing the `failures + 1` conversion.
- Focused tests cover scalar/vector checked, unchecked, reusable, fill, direct
  source, negative zero, no-consume behavior, accessors, and invalid negative
  probability rejection.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "geometric failures zero"
1/2 distributions.test.geometric failures zero probability matches local rand_distr...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "geometric"
1/4 distributions.test.geometric failures zero probability matches local rand_distr...OK
2/4 distributions.test.negative-binomial and hypergeometric samplers have plausible moments...OK
3/4 distributions.test.unit geometric distributions stay on expected support...OK
4/4 root.test_0...OK
All 4 tests passed.

$ zig test src/distributions.zig --test-filter "discrete"
1/5 distributions.test.invalid discrete distribution helpers do not consume random stream...OK
2/5 distributions.test.invalid distribution facade discrete scalars do not consume random stream...OK
3/5 distributions.test.degenerate discrete distribution helpers do not consume random stream...OK
4/5 distributions.test.zero-length discrete distribution fills do not validate or consume random stream...OK
5/5 root.test_0...OK
All 5 tests passed.
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
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1156 follow-ups closed for current bar
- Next bar: S4-M1157 post-S4-M1156 exact/default dense SIMD, broader runtime, or new local Rust gap
$ zig build rand-status-json
  "latest_validate_local_evidence": "compare/results/s4-m1156-geometric-zero-probability.md"
$ zig build rand-status-schema-version
1
$ zig build rand-status-self-test
rand-status self-test ok
$ zig build validate-local
rand_distr standard-normal: 41.1 M samples/s checksum=-3.640
rand_distr standard-normal f32: 37.9 M samples/s checksum=-3.640
runtimecheck ok: no additional runtime runner available
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
distcheck ok
statcheck ok
profilecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
examplecheck ok
$ zig build test
roadmapcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M1156 is closed for the current bar: Alea's rand-style failure-count
Geometric surface now matches local `rand_distr` zero-probability saturation,
while Alea's one-based trial-count `Geometric` keeps its zero-probability
rejection. This is not whole-goal completion; S4-M1157 remains active.
