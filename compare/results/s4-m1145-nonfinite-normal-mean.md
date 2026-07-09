# S4-M1145 Non-finite Normal Mean Compatibility

## Gap

The local `rand_distr 0.6.0` baseline treats `Normal::new(mean, std_dev)` as
having an unrestricted `mean` and only rejects non-finite `std_dev`. Since
`LogNormal::new(mu, sigma)` delegates to `Normal::new`, the log-space `mu` has
the same unrestricted construction semantics. Alea still rejected non-finite
normal/log-normal means in checked and reusable exact/default helper paths,
leaving a local `rand_distr` compatibility gap after S4-M1144 accepted finite
negative standard deviations.

## Local Rust baseline

```text
$ sed -n '189,193p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/normal.rs
pub fn new(mean: F, std_dev: F) -> Result<Normal<F>, Error> {
    if !std_dev.is_finite() {
        return Err(Error::BadVariance);
    }
    Ok(Normal { mean, std_dev })
```

`LogNormal::new` delegates directly to `Normal::new`:

```text
$ sed -n '296,298p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/normal.rs
pub fn new(mu: F, sigma: F) -> Result<LogNormal<F>, Error> {
    let norm = Normal::new(mu, sigma)?;
    Ok(LogNormal { norm })
```

Sampling still consumes a standard-normal variate before applying the affine
transform:

```text
$ sed -n '244,246p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/normal.rs
fn sample<R: Rng + ?Sized>(&self, rng: &mut R) -> F {
    self.from_zscore(rng.sample(StandardNormal))
}
```

## Implementation

- Relaxed `src/rng.zig` normal validation for scalar, vector, fill, batch, and
  checked paths from finite mean plus finite stddev to finite stddev only.
- Relaxed `src/distributions.zig` exact/default normal/log-normal validation,
  including reusable `Normal`, `LogNormal`, native-f32 normal/log-normal, and
  table vector normal profiles, to accept non-finite means while still rejecting
  non-finite stddev.
- Preserved S4-M1144 finite negative-stddev semantics and the existing
  zero-stddev no-consume point-mass behavior as an explicit Alea stream-shape
  contract.
- Added focused tests for `+inf`, `-inf`, and `NaN` means proving that non-zero
  stddev paths consume the same standard-normal draws as the manual baseline
  stream shape and produce the expected infinite or NaN affine/log-normal
  result.

## Focused validation

```text
$ zig test src/rng.zig --test-filter "normal"
1/24 rng.test.standard scalar normal parameters match standard stream shape...OK
2/24 rng.test.negative normal stddev helpers preserve rand_distr-compatible stream shape...OK
3/24 rng.test.nonfinite normal mean helpers preserve rand_distr-compatible stream shape...OK
...
24/24 quality.test.normal and exponential means stay in broad windows...OK
All 24 tests passed.

$ zig test src/distributions.zig --test-filter "normal"
1/24 distributions.test.invalid normal exponential wrapper helpers do not consume random stream...OK
2/24 distributions.test.degenerate normal and log-normal helpers do not consume random stream...OK
...
24/24 quality.test.normal and exponential means stay in broad windows...OK
All 24 tests passed.

$ zig test src/distributions.zig --test-filter "log-normal"
1/8 distributions.test.degenerate normal and log-normal helpers do not consume random stream...OK
2/8 distributions.test.log-normal approximation has stable snapshots...OK
...
8/8 root.test_0...OK
All 8 tests passed.
```

Full local aggregate after updating the latest-evidence pointer:

```text
$ zig build validate-local
...
rand_distr standard-normal: 57.8 M samples/s checksum=-3.640
rand_distr standard-normal f32: 54.8 M samples/s checksum=-3.640
rand-status self-test ok
roadmapcheck ok
toolingcheck ok
runtimecheck ok: no additional runtime runner available
apicheck ok
surfacecheck ok
examplecheck ok
readmecheck ok
distcheck ok
practrand self-test ok
profilecheck ok
```

Broad package tests also pass:

```text
$ zig build test
```

## Result

S4-M1145 is closed for the current bar: Alea now accepts unrestricted
normal/log-normal log-space means wherever the local `rand_distr` constructor
semantics apply, still rejects non-finite stddev, and preserves the documented
random-stream shape for non-zero stddev draws. This is not whole-goal completion;
S4-M1146 remains active.
