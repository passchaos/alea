# S4-M1133 Vector Exponential Rate-one Delegate

## Gap

S4-M1128's f64x4 standard-exponential specialization noted that rate-one vector
exponential fills should benefit through the shared standard-exponential path.
`Rng.fillVectorExponentialFrom(source, VectorType, dest, rate)` still routed
`rate == 1` through the generic exponential scalar helper and division path,
leaving implementation and evidence slightly out of sync.

## Implementation

- Updated `src/rng.zig` so `fillVectorExponentialFrom` delegates `rate == 1` to
  `fillVectorStandardExponentialFrom` after the infinity point-mass case.
- This preserves exact/default output and stream shape while reusing the
  specialized standard-exponential fill paths for f64x4 and the existing f32x8
  standard path.

## Validation

Focused vector tests:

```text
$ zig test src/rng.zig --test-filter "vector"
1/22 rng.test.owned vector strict interval batches preserve fill stream shape...OK
...
22/22 distributions.test.dirichlet sampler returns simplex vectors...OK
All 22 tests passed.
```

Focused f64x4 benchmark:

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "Exponential f64x4"
vector microbench lanes=16777216 filter=Exponential f64x4
alea fillVectorStandardExponential f64x4 direct: 465.3 M lanes/s checksum=8392265.906
alea fillVectorExponential f64x4 direct: 465.2 M lanes/s checksum=4196132.953
alea fillVectorExponential f64x4 local scalar candidate: 464.4 M lanes/s checksum=4196132.953
```

Focused f32x8 benchmark:

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "Exponential f32x8"
vector microbench lanes=16777216 filter=Exponential f32x8
alea fillVectorStandardExponential f32x8 direct: 472.2 M lanes/s checksum=16787550.000
alea fillVectorExponential f32x8: 469.5 M lanes/s checksum=8393775.000
alea fillVectorExponential f32x8 direct: 468.5 M lanes/s checksum=8393775.000
alea fillVectorExponential f32x8 flat-slice candidate: 442.5 M lanes/s checksum=8393775.000
```

## Result

S4-M1133 is closed for the current bar: rate-one vector exponential fills now
reuse the standard-exponential fill path, preserving checksums and matching the
intended exact/default stream shape. This is not whole-goal completion; S4-M1134
remains active for the next stricter product bar.
