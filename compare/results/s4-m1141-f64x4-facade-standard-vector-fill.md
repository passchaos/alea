# S4-M1141 f64x4 Facade Standard Vector Fill Specialization

## Gap

S4-M1127 and S4-M1128 added checksum-preserving direct-source f64x4
standard-normal and standard-exponential fill specializations, but facade
`Rng` calls still went through the generic vector lane-fill path. After the
S4-M1140 status refresh, the next active bar could close this smaller exact /
default call-shape gap: make facade standard f64x4 vector fills reuse the same
specialized path while preserving output mapping and stream shape.

Local Rust baseline check: cached `rand_distr 0.6.0` implements
`StandardNormal` and `Exp1` as scalar ZIGNOR distributions in
`normal.rs`/`exponential.rs`; f32 delegates through f64 and there is no local
SIMD non-uniform distribution implementation. Alea's f64x4 vector fills remain
an Alea-native extension beyond the local Rust surface, so this change targets
Alea ergonomics/performance without claiming a Rust API clone.

## Implementation

- Routed facade `Rng.fillVectorStandardNormal(@Vector(4, f64), ...)` through
  the private f64x4 standard-normal fill specialization instead of keeping that
  specialization direct-source-only.
- Routed facade `Rng.fillVectorStandardExponential(@Vector(4, f64), ...)`
  through the private f64x4 standard-exponential fill specialization.
- Removed the direct-source-only guard on standard-parameter vector-normal
  delegation so facade `fillVectorNormal(..., mean=0, stddev=1)` and
  `vectorNormal(..., mean=0, stddev=1)` take the same standard-normal paths.
- Added focused stream-shape coverage comparing facade f64x4 standard and
  standard-parameter workflows with direct-source standard fills/samples.

## Validation

Focused correctness:

```text
$ zig test src/rng.zig --test-filter "facade f64x4 standard vector fills"
1/2 rng.test.facade f64x4 standard vector fills match direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/rng.zig --test-filter "checked fill helpers preserve valid-parameter stream shape"
1/3 rng.test.checked fill helpers preserve valid-parameter stream shape...OK
2/3 root.test_0...OK
3/3 distributions.test.checked fill helpers preserve valid-parameter stream shape...OK
All 3 tests passed.

$ zig test src/rng.zig --test-filter "owned vector normal and exponential batches"
1/2 rng.test.owned vector normal and exponential batches allocate and validate before consuming random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Focused f64x4 vectorbench evidence:

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "StandardNormal f64x4"
vector microbench lanes=16777216 filter=StandardNormal f64x4
alea fillVectorStandardNormal f64x4: 322.6 M lanes/s checksum=44.440
alea fillVectorStandardNormal f64x4 direct: 492.0 M lanes/s checksum=44.440
alea fillVectorStandardNormal f64x4 local scalar candidate: 487.7 M lanes/s checksum=44.440

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "Normal f64x4"
vector microbench lanes=16777216 filter=Normal f64x4
alea distributions.fillVectorNormal f64x4: 317.4 M lanes/s checksum=44.440
alea fillVectorStandardNormal f64x4: 331.6 M lanes/s checksum=44.440
alea fillVectorNormal f64x4: 333.0 M lanes/s checksum=44.440
alea fillVectorNormal f64x4 direct: 494.2 M lanes/s checksum=44.440
alea fillVectorNormal f64x4 local scalar candidate: 490.3 M lanes/s checksum=44.440

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "StandardExponential f64x4"
vector microbench lanes=16777216 filter=StandardExponential f64x4
alea fillVectorStandardExponential f64x4: 465.8 M lanes/s checksum=8392265.906
alea fillVectorStandardExponential f64x4 direct: 466.2 M lanes/s checksum=8392265.906
alea fillVectorStandardExponential f64x4 local scalar candidate: 462.8 M lanes/s checksum=8392265.906
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
rand_distr standard-normal: 60.2 M samples/s checksum=-3.640
rand_distr standard-normal f32: 56.5 M samples/s checksum=-3.640
# command exited 0
```

For comparison, the S4-M1127 evidence recorded facade standard-normal at
280.9 M lanes/s before keeping the original direct-source-only specialization.
The S4-M1128 evidence recorded facade standard-exponential at 454.3 M lanes/s.
This S4-M1141 change keeps checksums stable while making the facade standard
exponential row match direct-source throughput and improving the facade normal
rows.

## Result

S4-M1141 is closed for the current bar: f64x4 facade standard vector normal and
exponential workflows now share the specialized exact/default standard fill paths
where their parameters are standard/rate-one. This is a narrow call-shape and
throughput closure, not whole-goal completion; S4-M1142 remains active.
