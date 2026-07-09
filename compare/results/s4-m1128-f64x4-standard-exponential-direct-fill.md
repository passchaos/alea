# S4-M1128 f64x4 Standard Exponential Direct Fill Specialization

## Gap

After S4-M1127 specialized direct-source f64x4 standard-normal fills, the active
S4-M1128 bar continued to look for exact/default dense-kernel, runtime, or local
`rand` / `rand_distr` gaps. A neighboring direct-source f64x4 standard
exponential call-shape was still routed through the generic vector scalar helper.
A small direct-source specialization could preserve checksum/stream shape while
matching the benchmark-local scalar helper and avoiding the generic helper layer.

This is a narrow exact/default call-shape improvement, not a new approximate
profile and not whole-goal completion.

## Implementation

- Added private `fillVectorStandardExponentialF64x4From` in `src/rng.zig`.
- Routed only direct-source `fillVectorStandardExponentialFrom(source,
  @Vector(4, f64), dest)` through it.
- Left facade `Rng` behavior unchanged, mirroring S4-M1127's safer
  direct-source-only scope.
- `fillVectorExponentialFrom(source, @Vector(4, f64), dest, 1)` benefits through
  existing standard-exponential delegation; parameterized `rate != 1` keeps the
  existing scalar helper and scaling path.

## Validation

Focused vector correctness:

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

Focused f64x4 standard-exponential benchmark after the specialization:

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "StandardExponential f64x4"
vector microbench lanes=16777216 filter=StandardExponential f64x4
alea fillVectorStandardExponential f64x4: 454.3 M lanes/s checksum=8392265.906
alea fillVectorStandardExponential f64x4 direct: 465.1 M lanes/s checksum=8392265.906
alea fillVectorStandardExponential f64x4 local scalar candidate: 464.9 M lanes/s checksum=8392265.906
alea fillVectorStandardExponential f64x4 approx-log-low candidate: 451.7 M lanes/s checksum=8383185.343
alea fillVectorStandardExponential f64x4 table-cdf candidate: 1280.5 M lanes/s checksum=8386486.176
```

Focused f64x4 exponential benchmark after the specialization:

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "Exponential f64x4"
vector microbench lanes=16777216 filter=Exponential f64x4
alea distributions.fillVectorExponential f64x4 direct: 466.1 M lanes/s checksum=4196132.953
alea fillVectorStandardExponential f64x4 direct: 466.1 M lanes/s checksum=8392265.906
alea fillVectorExponential f64x4 direct: 466.8 M lanes/s checksum=4196132.953
alea fillVectorExponential f64x4 local scalar candidate: 464.2 M lanes/s checksum=4196132.953
```

For comparison, the pre-specialization probe in this turn showed:

```text
alea fillVectorStandardExponential f64x4 direct: 459.2 M lanes/s checksum=8392265.906
alea fillVectorStandardExponential f64x4 local scalar candidate: 463.5 M lanes/s checksum=8392265.906
```

## Result

S4-M1128 is closed for the current bar: direct-source f64x4 exact/default
standard-exponential fills now use the checksum-preserving specialized call
shape, with focused direct rows matching/slightly exceeding the benchmark-local
candidate. Whole-goal completion is still not claimed; S4-M1129 should continue
broader dense-kernel research, additional runtime coverage, broader validation,
or new local `rand` / `rand_distr` gap discovery.
