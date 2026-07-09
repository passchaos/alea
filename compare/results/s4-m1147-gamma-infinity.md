# S4-M1147 Gamma Infinity Compatibility

## Gap

After S4-M1146, the next local `rand_distr` audit found that cached
`rand_distr 0.6.0` accepts `Gamma::new(shape, scale)` when either parameter is
positive infinity, and samples evaluate to positive infinity. `ChiSquared::new`
delegates to Gamma with `shape = dof / 2` and `scale = 2`, so infinite degrees
of freedom are accepted as well. Alea still rejected non-finite Gamma
shape/scale and finite-only ChiSquared/Chi degrees of freedom.

Alea has an established parity-plus convention for deterministic point-mass
states: collapsed valid distributions return/fill the deterministic value
without consuming randomness. S4-M1147 therefore accepts the same constructor
edge values as local `rand_distr` while preserving Alea's no-consume point-mass
stream contract for these infinite Gamma-family limits.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '176,186p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/gamma.rs
pub fn new(shape: F, scale: F) -> Result<Gamma<F>, Error> {
    if !(shape > F::zero()) {
        return Err(Error::ShapeTooSmall);
    }
    if !(scale > F::zero()) {
        return Err(Error::ScaleTooSmall);
    }

    let repr = if shape == F::infinity() || scale == F::infinity() {
        One(Exp::new(F::zero()).unwrap())
```

```text
$ sed -n '105,115p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/chi_squared.rs
pub fn new(k: F) -> Result<ChiSquared<F>, Error> {
    let repr = if k == F::one() {
        DoFExactlyOne
    } else {
        if !(F::from(0.5).unwrap() * k > F::zero()) {
            return Err(Error::DoFTooSmall);
        }
        DoFAnythingElse(Gamma::new(F::from(0.5).unwrap() * k, F::from(2.0).unwrap()).unwrap())
```

A local cargo probe against the cached crate confirms accepted infinity and
rejected zero/NaN edges:

```text
gamma_shape_inf sample=inf
gamma_scale_inf sample=inf
gamma_scale_zero_err=true
gamma_shape_zero_err=true
gamma_nan_shape_err=true
chi_squared_inf sample=inf
chi_squared_zero_err=true
```

## Implementation

- `Gamma(T).init` / `new`, scalar top-level helpers, checked helpers, fill
  helpers, and `VectorGamma` now accept `shape == +inf` or `scale == +inf`.
- Infinite Gamma shape/scale states return/fill `+inf` without consuming
  randomness. Existing Alea parity-plus `scale == 0` point mass remains a
  zero-valued no-consume extension.
- Gamma diagnostics retain distribution support (`minValue() == 0`) while
  exposing `maxValue() == +inf` for infinite point states.
- `ChiSquared(T)` and `Chi(T)` scalar/vector/top-level/checked/fill/reusable
  paths now accept `dof == +inf` and return/fill `+inf` without consuming
  randomness.
- Focused tests cover scalar, vector, checked, fill, reusable, accessor, and
  invalid/no-consume paths for Gamma, ChiSquared, and Chi.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "degenerate gamma"
1/2 distributions.test.degenerate gamma helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate chi"
1/2 distributions.test.degenerate chi-squared and chi helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Full local aggregate after updating the latest-evidence pointer:

```text
$ zig build validate-local
...
rand_distr standard-normal: 54.1 M samples/s checksum=-3.640
rand_distr standard-normal f32: 50.5 M samples/s checksum=-3.640
rand-status self-test ok
roadmapcheck ok
toolingcheck ok
runtimecheck ok: no additional runtime runner available
apicheck ok
surfacecheck ok
examplecheck ok
readmecheck ok
statcheck ok
distcheck ok
practrand self-test ok
```

Broad package tests also pass:

```text
$ zig build test
apicheck ok
examplecheck ok
```

## Result

S4-M1147 is closed for the current bar: Alea now accepts and handles local
`rand_distr` Gamma/ChiSquared infinite-parameter edges while keeping the Alea
point-mass no-consume stream contract. This is not whole-goal completion;
S4-M1148 remains active.
