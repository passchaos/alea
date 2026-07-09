# S4-M1136 Scalar Exponential Rate-one Sample Delegate

## Gap

S4-M1135 routed scalar rate-one exponential fills through standard-exponential
fills. The scalar single-sample fast helper `exponentialFastFrom(source, T,
rate)` still divided by `rate` even when `rate == 1`, instead of directly using
`standardExponentialFastFrom`.

## Implementation

- Updated `src/rng.zig` so `exponentialFastFrom(..., rate=1)` returns
  `standardExponentialFastFrom(...)` after the infinity point-mass case.
- Added a focused stream-shape test comparing `exponentialFastFrom(..., rate=1)`
  with `standardExponentialFastFrom` for f64 and f32.

## Validation

```text
$ zig test src/rng.zig --test-filter "rate-one scalar exponential"
1/2 rng.test.rate-one scalar exponential matches standard stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/rng.zig --test-filter "degenerate exponential helpers"
1/2 rng.test.degenerate exponential helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/rng.zig --test-filter "owned normal and exponential batches"
1/2 rng.test.owned normal and exponential batches allocate and validate before consuming random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

## Result

S4-M1136 is closed for the current bar: scalar rate-one exponential single-sample
and fill helpers both reuse standard-exponential paths while preserving stream
shape. This is not whole-goal completion; S4-M1137 remains active.
