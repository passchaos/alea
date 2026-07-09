# S4-M1142 Parameterized f64x4 Vector Fill Specialization

## Gap

S4-M1141 extended f64x4 standard-normal and standard-exponential fill
specializations to facade standard-parameter workflows. The neighboring
parameterized f64x4 vector fill paths still routed each output through generic
scalar vector wrappers for non-standard normal parameters and exponential
`rate != 1`.

Local Rust baseline check remains the same as S4-M1141: cached
`rand_distr 0.6.0` implements `StandardNormal`, `Normal`, `Exp1`, and `Exp` as
scalar ZIGNOR distributions in `normal.rs` and `exponential.rs`; f32 delegates
through f64 and there is no local SIMD non-uniform implementation. Alea's f64x4
vector fill helpers are Zig-native extensions beyond that scalar Rust surface.

## Implementation

- Added a private f64x4 parameterized-normal fill helper that uses the same exact
  f64 ziggurat draw loop as the standard-normal f64x4 fill path, then applies
  the normal affine transform as a vector operation.
- Added a private f64x4 parameterized-exponential fill helper that uses the same
  exact f64 ziggurat draw loop as the standard-exponential f64x4 fill path, then
  applies the rate scaling as a vector operation.
- Routed `fillVectorNormalFrom(..., @Vector(4, f64), mean, stddev)` through the
  new helper for non-standard parameters after the standard-parameter and
  point-mass cases.
- Routed `fillVectorExponentialFrom(..., @Vector(4, f64), rate)` through the new
  helper for finite `rate != 1` after the infinity and rate-one cases.
- Added focused stream-shape coverage comparing facade and direct-source f64x4
  parameterized fills with the previous scalar-vector helper output.

## Validation

Focused correctness:

```text
$ zig test src/rng.zig --test-filter "parameterized f64x4 vector fills"
1/2 rng.test.parameterized f64x4 vector fills match scalar stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/rng.zig --test-filter "vector"
1/24 rng.test.owned vector strict interval batches preserve fill stream shape...OK
...
10/24 rng.test.parameterized f64x4 vector fills match scalar stream shape...OK
...
24/24 distributions.test.dirichlet sampler returns simplex vectors...OK
All 24 tests passed.
```

Focused f64x4 vectorbench evidence for the finite-rate exponential path:

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "fillVectorExponential f64x4"
vector microbench lanes=16777216 filter=fillVectorExponential f64x4
alea distributions.fillVectorExponential f64x4: 276.7 M lanes/s checksum=4196132.953
alea distributions.fillVectorExponential f64x4 direct: 452.4 M lanes/s checksum=4196132.953
alea fillVectorExponential f64x4: 277.6 M lanes/s checksum=4196132.953
alea fillVectorExponential f64x4 direct: 453.0 M lanes/s checksum=4196132.953
alea fillVectorExponential f64x4 local scalar candidate: 460.5 M lanes/s checksum=4196132.953
```

The exact/default checksum is unchanged. The direct-source finite-rate row uses
the same exact f64 ziggurat draw shape and stays near the benchmark-local scalar
candidate while avoiding a separate output mapping. Facade rows still pay the
`Rng` indirection cost, but they share the same exact stream shape.


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
rand_distr standard-normal: 59.9 M samples/s checksum=-3.640
rand_distr standard-normal f32: 59.3 M samples/s checksum=-3.640
# command exited 0
```

## Result

S4-M1142 is closed for the current bar: parameterized f64x4 normal and
finite-rate exponential vector fills now reuse exact/default f64 ziggurat draw loops plus vector post-scaling/affine transforms where valid. This is a
narrow call-shape improvement, not whole-goal completion; S4-M1143 remains
active.
