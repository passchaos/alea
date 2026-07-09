# S4-M1148 FisherF Infinity Compatibility

## Gap

S4-M1147 aligned Gamma and ChiSquared infinite-parameter construction with local
`rand_distr 0.6.0`. A follow-up audit found that `rand_distr::FisherF::new(m,
n)` simply constructs `ChiSquared::new(m)` and `ChiSquared::new(n)` and stores
`dof_ratio = n / m`; it does not reject one-sided infinities and it does not
special-case the both-infinite case as a deterministic ratio. With the local
`Gamma` infinity behavior, all `FisherF` cases with at least one infinite degree
of freedom sample to NaN while consuming the underlying ChiSquared/Gamma draws.

Alea previously treated both-infinite FisherF as a deterministic point mass at 1
and rejected one-sided infinities. That was a local `rand_distr` compatibility
gap.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '86,100p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/fisher_f.rs
pub fn new(m: F, n: F) -> Result<FisherF<F>, Error> {
    Ok(FisherF {
        numer: ChiSquared::new(m).map_err(|x| match x {
            chi_squared::Error::DoFTooSmall => Error::MTooSmall,
        })?,
        denom: ChiSquared::new(n).map_err(|x| match x {
            chi_squared::Error::DoFTooSmall => Error::NTooSmall,
        })?,
        dof_ratio: n / m,
    })
}
```

```text
$ sed -n '107,113p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/fisher_f.rs
fn sample<R: Rng + ?Sized>(&self, rng: &mut R) -> F {
    self.numer.sample(rng) / self.denom.sample(rng) * self.dof_ratio
}
```

A local cargo probe against the cached crate confirms the accepted infinity
cases and NaN outputs:

```text
fisher m=inf n=inf sample=NaN nan=true
fisher m=inf n=2.0 sample=NaN nan=true
fisher m=2.0 n=inf sample=NaN nan=true
```

## Implementation

- Relaxed FisherF validation to accept one-sided and both-sided positive
  infinities while still rejecting zero, negative, and NaN degrees of freedom.
- Removed the prior Alea both-infinite FisherF point-mass special case.
- Reusable scalar and vector FisherF now route infinite-degree cases through a
  ChiSquared/Gamma-compatible draw shape and return NaN, matching local
  `rand_distr` structure instead of using no-consume deterministic output.
- Top-level scalar/vector checked, unchecked, and fill helpers now construct and
  use the reusable sampler for these accepted infinite-degree cases.
- Focused tests cover scalar/vector checked, unchecked, fill, reusable, and
  facade/direct-source paths for `inf/inf`, `inf/finite`, `finite/inf`, and finite dof-one ChiSquared
  branches paired with infinity, and compare stream consumption against explicit
  manual reference draws.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "fisher"
1/2 distributions.test.infinite fisher-f helpers preserve rand_distr-compatible stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "non-uniform samplers"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

## Result

S4-M1148 is closed for the current bar: Alea now accepts local `rand_distr`
FisherF infinite-degree edge cases and preserves the corresponding NaN output
and draw-shape behavior. This is not whole-goal completion; S4-M1149 remains
active.
