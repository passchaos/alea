# S4-M1134 Single-vector Exponential Rate-one Delegate

## Gap

S4-M1133 routed rate-one vector exponential *fills* through the shared standard
exponential fill path. The single-vector helper `vectorExponentialFrom(source,
VectorType, rate)` still routed `rate == 1` through the generic exponential
helper and division path, leaving a small stream-shape and implementation
consistency gap next to the fill-slice fix.

## Implementation

- Updated `src/rng.zig` so `vectorExponentialFrom(..., rate=1)` delegates to
  `vectorStandardExponentialFrom` for f32/f64 vectors.
- Added explicit stream-shape coverage comparing single-vector
  `vectorExponentialFrom(..., rate=1)` with `vectorStandardExponentialFrom`.

## Validation

```text
$ zig test src/rng.zig --test-filter "invalid vector distribution helpers"
1/2 rng.test.invalid vector distribution helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ git diff --check

$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ zig build test
roadmapcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M1134 is closed for the current bar: single-vector rate-one vector exponential
sampling now reuses the standard exponential path just like the S4-M1133 fill
helpers. This is not whole-goal completion; S4-M1135 remains active.
