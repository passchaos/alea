# S4-M1135 Scalar Exponential Rate-one Fill Delegate

## Gap

S4-M1133 and S4-M1134 aligned vector exponential rate-one fill and single-vector
helpers with the standard-exponential paths. The scalar slice helper
`fillExponentialFrom(source, T, dest, rate)` still handled `rate == 1` through
`exponentialFastFrom(..., rate)` per element instead of delegating to
`fillStandardExponentialFrom`.

## Implementation

- Updated `src/rng.zig` so scalar `fillExponentialFrom(..., rate=1)` delegates to
  `fillStandardExponentialFrom` after the infinity point-mass case.
- Existing scalar batch helpers benefit through their existing fill delegation.

## Validation

```text
$ zig test src/rng.zig --test-filter "checked fill helpers preserve valid-parameter stream shape"
1/3 rng.test.checked fill helpers preserve valid-parameter stream shape...OK
2/3 root.test_0...OK
3/3 distributions.test.checked fill helpers preserve valid-parameter stream shape...OK
All 3 tests passed.

$ zig test src/rng.zig --test-filter "owned normal and exponential batches"
1/2 rng.test.owned normal and exponential batches allocate and validate before consuming random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

## Result

S4-M1135 is closed for the current bar: scalar rate-one exponential fills now use
the standard-exponential fill path, matching the vector rate-one delegation work
while preserving stream shape. This is not whole-goal completion; S4-M1136
remains active.
