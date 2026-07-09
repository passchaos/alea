# S4-M1149 StudentT Infinity Compatibility

## Gap

S4-M1148 aligned FisherF infinite-degree construction and sampling with local
`rand_distr 0.6.0`. A follow-up audit found the same composition-sensitive edge
in `rand_distr::StudentT::new(nu)`: it constructs `ChiSquared::new(nu)` and
stores the original `dof`. For `nu = +inf`, sampling draws a standard normal,
samples the infinite ChiSquared/Gamma branch, and then evaluates
`normal * sqrt(inf / inf)`, producing NaN while consuming both underlying draws.

Alea previously treated `StudentT(+inf)` as the mathematical limiting standard
normal distribution. That was useful as a parity-plus limit, but it did not match
local `rand_distr` constructor/sample behavior or stream shape on this platform.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '55,67p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/student_t.rs
pub fn new(nu: F) -> Result<StudentT<F>, ChiSquaredError> {
    Ok(StudentT {
        chi: ChiSquared::new(nu)?,
        dof: nu,
    })
}
```

```text
$ sed -n '72,77p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/student_t.rs
fn sample<R: Rng + ?Sized>(&self, rng: &mut R) -> F {
    let norm: F = rng.sample(StandardNormal);
    norm * (self.dof / self.chi.sample(rng)).sqrt()
}
```

A local cargo probe against the cached crate confirms the accepted infinity case
and NaN output:

```text
student dof=inf sample=NaN nan=true finite=false
student dof=1.0 sample=1.20892060016492 nan=false finite=true
student dof=2.0 sample=0.9000772995739084 nan=false finite=true
student dof=10.0 sample=1.0819924097455393 nan=false finite=true
student zero err=true
student nan err=true
```

## Implementation

- Kept StudentT validation accepting positive finite degrees and `+inf` while
  continuing to reject zero, negative, and NaN degrees of freedom.
- Changed scalar/vector top-level, checked, reusable, and fill helpers for
  `dof == +inf` to return/fill NaN and explicitly consume a standard-normal draw
  followed by an infinite-ChiSquared-compatible standard-exponential draw.
- Reusable `StudentT(T).init(+inf)` now stores the real infinite ChiSquared
  sampler for diagnostics/composition instead of a synthetic zero-dof point
  sampler.
- Infinite-dof moment accessors now return `null`, matching the NaN-producing
  local `rand_distr` edge instead of the old standard-normal limit extension.
- Focused tests cover scalar/vector checked, unchecked, fill, reusable, facade,
  direct-source, and invalid/no-consume workflows for `dof == +inf`.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "student-t"
1/2 distributions.test.infinite-dof student-t preserves rand_distr-compatible stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "non-uniform samplers"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

## Full validation

The final S4-M1149 validation run also passed:

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
rand_distr standard-normal: 62.7 M samples/s checksum=-3.640
rand_distr standard-normal f32: 59.0 M samples/s checksum=-3.640
$ zig build test
# passed
```

## Result

S4-M1149 is closed for the current bar: Alea now accepts local `rand_distr`
StudentT infinite-degree edge cases and preserves the corresponding NaN output
and normal-plus-ChiSquared/Gamma draw-shape behavior. This is not whole-goal
completion; S4-M1150 remains active.
