# S4-M1137 Scalar Normal Standard-parameter Sample Delegate

## Gap

Scalar normal fill and vector normal helpers already route standard parameters
(`mean=0`, `stddev=1`) through standard-normal paths. The scalar single-sample
fast helper `normalFastFrom(source, T, mean, stddev)` still computed
`mean + stddev * standardNormalFastFrom(...)` for standard parameters, instead
of directly using `standardNormalFastFrom`.

## Implementation

- Updated `src/rng.zig` so `normalFastFrom(..., mean=0, stddev=1)` returns
  `standardNormalFastFrom(...)` after the `stddev == 0` point-mass case.
- Added focused f64/f32 stream-shape coverage comparing standard-parameter
  `normalFastFrom` with `standardNormalFastFrom`.

## Validation

```text
$ zig test src/rng.zig --test-filter "standard scalar normal"
1/2 rng.test.standard scalar normal parameters match standard stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

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

S4-M1137 is closed for the current bar: scalar standard-parameter normal single
samples now use the same standard-normal path as scalar fills, vector helpers,
and owned batches. This is not whole-goal completion; S4-M1138 remains active.
