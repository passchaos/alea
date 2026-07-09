# S4-M1127 f64x4 Standard Normal Direct Fill Specialization

## Gap

S4-M1126's fresh dense-SIMD probe kept the overall exact/default dense-kernel bar
active, but the same focused f64x4 `vectorbench` run exposed a smaller
checksum-preserving production opportunity: direct-source `@Vector(4, f64)`
standard-normal fills were slower than a benchmark-local scalar-lane helper that
called the same exact ziggurat kernel directly.

This is not a new dense SIMD algorithm and does not replace the broader S4-M1126
bar. It is a safe exact/default call-shape improvement for direct-source f64x4
standard-normal and parameterized-normal fills.

## Implementation

- Added a private `fillVectorStandardNormalF64x4From` helper in `src/rng.zig`.
- Routed only direct-source `fillVectorStandardNormalFrom(source, @Vector(4, f64),
  dest)` through that helper.
- Left facade `Rng` calls on the existing generic path: an attempted
  facade-inclusive specialization preserved checksums but regressed the facade
  row, so it was not kept.
- `fillVectorNormalFrom(source, @Vector(4, f64), dest, 0, 1)` benefits through
  the existing direct-source standard-normal delegation.

## Validation

Focused correctness:

```text
$ zig test src/rng.zig --test-filter "vector"
1/22 rng.test.owned vector strict interval batches preserve fill stream shape...OK
2/22 rng.test.owned vector strict interval batches allocate before consuming random stream...OK
3/22 rng.test.value and vector sampling have stable snapshots...OK
4/22 rng.test.invalid vector probability helpers do not consume random stream...OK
5/22 rng.test.degenerate vector probability fills do not consume random stream...OK
6/22 rng.test.invalid vector distribution helpers do not consume random stream...OK
7/22 rng.test.invalid facade vector helpers do not consume random stream...OK
8/22 rng.test.owned vector range batches allocate and validate before consuming random stream...OK
9/22 rng.test.owned vector normal and exponential batches allocate and validate before consuming random stream...OK
10/22 rng.test.owned vector standard normal and exponential batches allocate before consuming random stream...OK
11/22 rng.test.owned vector probability batches allocate and validate before consuming random stream...OK
12/22 rng.test.degenerate owned vector probability batches do not consume random stream...OK
13/22 root.test_0...OK
14/22 distributions.test.distribution vector helpers preserve support and stream shape...OK
15/22 distributions.test.invalid distribution vector helpers do not consume random stream...OK
16/22 distributions.test.zero-length distribution vector fills do not validate or consume random stream...OK
17/22 distributions.test.vector native f32 parameterized samplers have stable snapshots...OK
18/22 distributions.test.vector table f32 normal has stable snapshots...OK
19/22 distributions.test.vector table f64 normal has stable snapshots...OK
20/22 distributions.test.vector approximate-log f32 exponential has stable snapshots...OK
21/22 distributions.test.vector table exponential has stable snapshots...OK
22/22 distributions.test.dirichlet sampler returns simplex vectors...OK
All 22 tests passed.
```

Focused f64x4 standard-normal benchmark after the kept direct-source-only
specialization:

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "StandardNormal f64x4"
vector microbench lanes=16777216 filter=StandardNormal f64x4
alea fillVectorStandardNormal f64x4: 280.9 M lanes/s checksum=44.440
alea fillVectorStandardNormal f64x4 direct: 480.8 M lanes/s checksum=44.440
alea fillVectorStandardNormal f64x4 local scalar candidate: 477.6 M lanes/s checksum=44.440
alea fillVectorStandardNormal f64x4 noinline local candidate: 327.5 M lanes/s checksum=44.440
alea fillVectorStandardNormal f64x4 table-cdf candidate: 1279.1 M lanes/s checksum=81.564
```

Focused f64x4 parameterized-normal benchmark after the same specialization:

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "Normal f64x4"
vector microbench lanes=16777216 filter=Normal f64x4
alea distributions.fillVectorNormal f64x4 direct: 478.8 M lanes/s checksum=44.440
alea fillVectorStandardNormal f64x4 direct: 484.0 M lanes/s checksum=44.440
alea fillVectorNormal f64x4 direct: 478.5 M lanes/s checksum=44.440
alea fillVectorNormal f64x4 local scalar candidate: 474.0 M lanes/s checksum=44.440
```

For comparison, immediately before the production specialization in the same
turn, focused probes showed:

```text
alea fillVectorStandardNormal f64x4 direct: 440.8 M lanes/s checksum=44.440
alea fillVectorStandardNormal f64x4 local scalar candidate: 489.7 M lanes/s checksum=44.440
alea fillVectorStandardExponential f64x4 direct: 459.2 M lanes/s checksum=8392265.906
alea fillVectorStandardExponential f64x4 local scalar candidate: 463.5 M lanes/s checksum=8392265.906
```

The kept change targets the normal direct-source gap only; f64x4 exponential did
not show a comparable durable specialization opportunity.

## Result

S4-M1127 is closed for the current bar: direct-source f64x4 exact/default
standard-normal and parameterized-normal fills now use the faster
checksum-preserving call shape. Whole-goal completion is still not claimed;
S4-M1128 should continue broader dense-kernel research, additional runtime
coverage, broader validation, or new local `rand` / `rand_distr` gap discovery.
