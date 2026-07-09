# S4-M1152 Beta Infinity Compatibility

## Gap

S4-M1151 aligned Pareto/Weibull infinite-scale construction with local
`rand_distr 0.6.0`. A follow-up audit found that local `rand_distr::Beta::new`
validates only `alpha > 0` and `beta > 0`; it accepts one-sided and both-sided
`+inf` shape parameters. Alea previously accepted exactly one infinite shape as
a no-consume endpoint extension and rejected both-infinite shapes.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '113,124p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/beta.rs
pub fn new(alpha: F, beta: F) -> Result<Beta<F>, Error> {
    if !(alpha > F::zero()) {
        return Err(Error::AlphaTooSmall);
    }
    if !(beta > F::zero()) {
        return Err(Error::BetaTooSmall);
    }
```

A local cargo probe against the cached crate confirms accepted infinite shapes
and the resulting edge outputs for this host/seed:

```text
alpha_inf_beta_0_5 sample=1.0 nan=false finite=true inf=false
alpha_inf_beta_1 sample=1.0 nan=false finite=true inf=false
alpha_inf_beta_2 sample=NaN nan=true finite=false inf=false
alpha_0_5_beta_inf sample=0.0 nan=false finite=true inf=false
alpha_1_beta_inf sample=0.0 nan=false finite=true inf=false
alpha_2_beta_inf sample=NaN nan=true finite=false inf=false
both_inf sample=NaN nan=true finite=false inf=false
```

## Implementation

- Relaxed Beta validation to accept both-sided `+inf` shapes while still
  rejecting zero, negative, and NaN shapes.
- Replaced the old one-sided infinite-shape no-consume endpoint path with a
  local `rand_distr` Cheng-algorithm-compatible infinite-parameter path.
- Scalar/vector top-level, checked, reusable, and fill helpers now consume the
  same Open01 draw shape as the corresponding infinite-parameter Cheng branch
  before producing endpoint or NaN outputs.
- Focused tests cover one-sided and both-sided infinite shapes across
  scalar/vector checked, unchecked, fill, reusable, facade/direct-source paths
  plus invalid no-consume cases.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "beta"
1/2 distributions.test.infinite beta helpers preserve rand_distr-compatible stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "kumaraswamy"
1/2 distributions.test.degenerate kumaraswamy helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers"
1/3 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/3 distributions.test.invalid distribution vector helpers do not consume random stream...OK
3/3 root.test_0...OK
All 3 tests passed.
```

## Full validation

The final S4-M1152 validation run also passed:

```text
$ git diff --check
$ zig build roadmapcheck
roadmapcheck ok
$ zig build toolingcheck
toolingcheck ok
$ zig build rand-status
$ zig build rand-status-json
$ zig build rand-status-schema-version
1
$ zig build rand-status-self-test
rand-status self-test ok
$ zig build validate-local
# passed; smoke output included:
rand_distr standard-normal: 27.5 M samples/s checksum=-3.640
rand_distr standard-normal f32: 28.8 M samples/s checksum=-3.640
$ zig build test
# passed
```

## Result

S4-M1152 is closed for the current bar: Alea now accepts local `rand_distr`
Beta infinite-shape edges, including both-sided infinity, while preserving the
corresponding endpoint/NaN outputs and Cheng-algorithm draw shape. This is not
whole-goal completion; S4-M1153 remains active.
