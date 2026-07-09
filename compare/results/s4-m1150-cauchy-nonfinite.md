# S4-M1150 Cauchy Nonfinite Parameter Compatibility

## Gap

S4-M1149 aligned StudentT infinite-degree construction and sampling with local
`rand_distr 0.6.0`. A follow-up audit found that local
`rand_distr::Cauchy::new(median, scale)` validates only `scale > 0`; it accepts
non-finite medians, including `+inf`, `-inf`, and `NaN`, and it accepts
`scale = +inf`. Alea previously required both median and scale to be finite,
except for the existing Alea parity-plus `scale == 0` point-mass extension.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '92,98p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/cauchy.rs
pub fn new(median: F, scale: F) -> Result<Cauchy<F>, Error> {
    if !(scale > F::zero()) {
        return Err(Error::ScaleTooSmall);
    }
    Ok(Cauchy { median, scale })
}
```

```text
$ sed -n '105,113p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/cauchy.rs
fn sample<R: Rng + ?Sized>(&self, rng: &mut R) -> F {
    // sample from [0, 1)
    let x = StandardUniform.sample(rng);
    // get standard cauchy random number
    // note that π/2 is not exactly representable, even if x=0.5 the result is finite
    let comp_dev = (F::PI() * x).tan();
    // shift and scale according to parameters
    self.median + self.scale * comp_dev
}
```

A local cargo probe against the cached crate confirms accepted non-finite edge
cases and rejected non-positive/NaN scale edges:

```text
median_inf sample=inf nan=false finite=false inf=true
median_neg_inf sample=-inf nan=false finite=false inf=true
median_nan sample=NaN nan=true finite=false inf=false
scale_inf sample=-inf nan=false finite=false inf=true
both_inf sample=NaN nan=true finite=false inf=false
scale_zero_err=true
scale_neg_err=true
scale_nan_err=true
```

## Implementation

- Relaxed Cauchy validation to allow unrestricted median values and `scale ==
  +inf`, while still rejecting negative and NaN scale.
- Preserved the existing Alea parity-plus `scale == 0` deterministic point-mass
  extension; this remains a documented deviation from local `rand_distr`, which
  rejects zero scale.
- Scalar/vector top-level, checked, reusable, and fill helpers now accept local
  `rand_distr` non-finite Cauchy parameter edges.
- Sampling keeps Alea's existing centered strict-open Cauchy transform for
  reproducibility and throughput; the meaningful compatibility point here is
  constructor acceptance and non-finite arithmetic behavior, not byte-for-byte
  Rust Cauchy output.
- Focused tests cover scalar/vector checked, unchecked, fill, reusable,
  facade/direct-source paths plus invalid scale no-consume cases.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "cauchy"
1/3 distributions.test.degenerate cauchy and gumbel helpers do not consume random stream...OK
2/3 distributions.test.nonfinite cauchy parameters follow local rand_distr acceptance...OK
3/3 root.test_0...OK
All 3 tests passed.

$ zig test src/distributions.zig --test-filter "non-uniform samplers"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

## Full validation

The final S4-M1150 validation run also passed:

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
rand_distr standard-normal: 40.6 M samples/s checksum=-3.640
rand_distr standard-normal f32: 39.2 M samples/s checksum=-3.640
$ zig build test
# passed
```

## Result

S4-M1150 is closed for the current bar: Alea now accepts local `rand_distr`
Cauchy non-finite median and infinite-scale parameter edges while preserving the
existing Alea zero-scale point-mass extension and Cauchy transform stream shape.
This is not whole-goal completion; S4-M1151 remains active.
