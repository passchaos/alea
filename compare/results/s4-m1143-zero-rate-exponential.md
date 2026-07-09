# S4-M1143 Zero-rate Exponential Compatibility

## Gap

The local `rand_distr 0.6.0` baseline accepts `Exp::new(0.0)` and samples
positive infinity (`rand_distr-0.6.0/src/exponential.rs`, `test_zero`). Alea had
already accepted `rate == inf` as the deterministic point mass at zero, but
checked exact/default exponential helpers still rejected positive zero rate.
This left a small local `rand_distr` compatibility gap.

The intended Zig-native semantics are:

- `rate == +0.0`: valid infinite point mass; return/fill `+inf` without consuming
  random stream;
- `rate == -0.0`, negative finite rates, and NaN: invalid;
- `rate == +inf`: valid zero point mass, unchanged from prior evidence.

## Implementation

- Added shared `isValidExponentialRate` validation in `src/rng.zig` and
  `src/distributions.zig` so positive zero is accepted while negative zero and
  NaN remain invalid.
- Updated scalar/vector/top-level/checked `Rng` exponential helpers to return or
  fill positive infinity for `rate == 0` without consuming randomness.
- Updated distribution-namespace scalar, vector, native-f32, approx-log, table,
  and reusable exponential helpers to use the same validation and zero-rate
  point-mass behavior.
- Added focused tests for positive-zero no-consume behavior and updated old
  invalid-rate tests to use negative zero where the invalid-sign case is the
  intended check.

## Local Rust baseline

```text
$ sed -n '185,215p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/exponential.rs
...
#[test]
fn test_zero() {
    let d = Exp::new(0.0).unwrap();
    assert_eq!(d.sample(&mut crate::test::rng(21)), f64::infinity());
}
```

## Validation

```text
$ zig test src/distributions.zig --test-filter "zero-rate exponential"
1/3 distributions.test.zero-rate exponential distribution helpers return infinity without consuming random stream...OK
2/3 root.test_0...OK
3/3 rng.test.zero-rate exponential helpers return infinity without consuming random stream...OK
All 3 tests passed.

$ zig test src/rng.zig --test-filter "zero-rate exponential"
1/3 rng.test.zero-rate exponential helpers return infinity without consuming random stream...OK
2/3 root.test_0...OK
3/3 distributions.test.zero-rate exponential distribution helpers return infinity without consuming random stream...OK
All 3 tests passed.

$ zig test src/rng.zig --test-filter "exponential"
1/17 rng.test.invalid scalar exponential helpers do not consume random stream...OK
...
13/17 distributions.test.zero-rate exponential distribution helpers return infinity without consuming random stream...OK
...
17/17 quality.test.normal and exponential means stay in broad windows...OK
All 17 tests passed.
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
rand_distr standard-normal: 41.9 M samples/s checksum=-3.640
rand_distr standard-normal f32: 39.8 M samples/s checksum=-3.640
# command exited 0
```

## Result

S4-M1143 is closed for the current bar: Alea now matches the local
`rand_distr::Exp::new(0.0)` zero-rate convention across scalar/vector,
top-level/checked, and reusable exponential workflows while retaining invalid
negative-zero/NaN handling. This is not whole-goal completion; S4-M1144 remains
active.
