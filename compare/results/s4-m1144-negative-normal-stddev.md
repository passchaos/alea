# S4-M1144 Negative Normal Stddev Compatibility

## Gap

The local `rand_distr 0.6.0` baseline accepts finite negative standard deviation
parameters for `Normal::new(mean, std_dev)` and therefore for `LogNormal::new`;
`normal.rs` only rejects non-finite standard deviations. Alea previously rejected
negative finite `stddev` across checked normal/log-normal helpers, leaving a
local `rand_distr` compatibility gap.

## Implementation

- Relaxed exact/default normal validation in `src/rng.zig` from non-negative
  stddev to finite stddev.
- Relaxed scalar/vector/distribution-namespace normal and log-normal helpers in
  `src/distributions.zig`, including native-f32 and table vector profiles.
- Preserved finite checks for mean/stddev and kept non-finite stddev invalid.
- Updated Normal mean/CV construction to mirror local `rand_distr` (`std_dev =
  mean * cv`) so negative means preserve a negative stored stddev.
- Adjusted table-profile min/max accessors to return ordered support bounds even
  when stddev is negative.
- Added focused tests proving negative stddev stream shape against explicit
  standard-normal loops and reusable Normal/LogNormal fill/sample parity.

## Local Rust baseline

```text
$ sed -n '178,190p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/normal.rs
pub fn new(mean: F, std_dev: F) -> Result<Normal<F>, Error> {
    if !std_dev.is_finite() {
        return Err(Error::BadVariance);
    }
    Ok(Normal { mean, std_dev })
}
```

The local docs also demonstrate `Normal::new(2.0, -3.0)` via `from_zscore`.

## Validation

```text
$ zig test src/rng.zig --test-filter "negative normal stddev"
1/2 rng.test.negative normal stddev helpers preserve rand_distr-compatible stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/rng.zig --test-filter "normal"
1/23 rng.test.standard scalar normal parameters match standard stream shape...OK
2/23 rng.test.negative normal stddev helpers preserve rand_distr-compatible stream shape...OK
...
23/23 quality.test.normal and exponential means stay in broad windows...OK
All 23 tests passed.
```


Full local aggregate after updating the latest-evidence pointer:

```text
$ zig build validate-local
...
roadmapcheck ok
toolingcheck ok
rand-status self-test ok
surfacecheck ok
runtimecheck ok: no additional runtime runner available
rand_bench_smoke self-test ok
rand_distr standard-normal: 58.8 M samples/s checksum=-3.640
rand_distr standard-normal f32: 55.4 M samples/s checksum=-3.640
# command exited 0
```

## Result

S4-M1144 is closed for the current bar: Alea now accepts finite negative
`stddev` for normal/log-normal scalar, vector, checked, reusable, native-f32, and
table workflows while preserving stream shape and rejecting non-finite stddev.
This is not whole-goal completion; S4-M1145 remains active.
