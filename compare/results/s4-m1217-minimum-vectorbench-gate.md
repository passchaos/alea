# S4-M1217 Minimum Vectorbench Gate Refresh

## Gap

S4-M1216 refreshed the full portability-sensitive validation aggregate and moved
the active bar to S4-M1217. The dense-SIMD notes require any future production
normal/exponential vector candidate to be measured in the real vector-slice
`vectorbench` harness across standard and parameterized f32x8/f64x4 workflows,
with same-run direct/default baselines and checksums. This milestone reruns that
minimum gate on the current Linux host before considering any default change.

## Commands

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "StandardNormal f32x8"
alea distributions.fillVectorStandardNormal f32x8 direct: 390.1 M lanes/s checksum=9241.591
alea fillVectorStandardNormal f32x8 direct: 379.9 M lanes/s checksum=9241.591
alea fillVectorStandardNormal f32x8 repair candidate: 358.8 M lanes/s checksum=9241.591
alea fillVectorStandardNormal f32x8 same-candidate repair: 275.5 M lanes/s checksum=11216.549
alea fillVectorStandardNormal f32x8 block-fallback candidate: 358.6 M lanes/s checksum=13422.609
alea fillVectorStandardNormal f32x8 table-cdf16384 candidate: 1127.7 M lanes/s checksum=7206.155

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "fillVectorNormal f32x8"
alea fillVectorNormal f32x8 direct: 396.5 M lanes/s checksum=9241.591
alea fillVectorNormal f32x8 flat-slice candidate: 373.1 M lanes/s checksum=9241.591
alea fillVectorNormal f32x8 repair candidate: 354.5 M lanes/s checksum=9241.591
alea fillVectorNormal f32x8 same-candidate repair: 279.1 M lanes/s checksum=11216.549
alea fillVectorNormal f32x8 block-fallback candidate: 345.3 M lanes/s checksum=13422.609
alea fillVectorNormal f32x8 table-cdf16384 candidate: 1130.4 M lanes/s checksum=7206.155

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "StandardExponential f32x8"
alea distributions.fillVectorStandardExponential f32x8 direct: 393.4 M lanes/s checksum=268436500.000
alea fillVectorStandardExponential f32x8 direct: 377.9 M lanes/s checksum=268436500.000
alea fillVectorStandardExponential f32x8 approx-log candidate: 535.0 M lanes/s checksum=268434200.000
alea fillVectorStandardExponential f32x8 table-cdf candidate: 1106.7 M lanes/s checksum=268445380.000
alea fillVectorStandardExponential f32x8 repair candidate: 345.0 M lanes/s checksum=268436500.000
alea fillVectorStandardExponential f32x8 same-candidate repair: 236.5 M lanes/s checksum=268438850.000
alea fillVectorStandardExponential f32x8 block-fallback candidate: 273.2 M lanes/s checksum=266868140.000

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "fillVectorExponential f32x8"
alea fillVectorExponential f32x8 direct: 357.0 M lanes/s checksum=134218260.000
alea fillVectorExponential f32x8 approx-log candidate: 524.8 M lanes/s checksum=134217100.000
alea fillVectorExponential f32x8 table-cdf candidate: 1074.7 M lanes/s checksum=134222690.000
alea fillVectorExponential f32x8 repair candidate: 347.1 M lanes/s checksum=134218260.000
alea fillVectorExponential f32x8 same-candidate repair: 232.8 M lanes/s checksum=134219420.000
alea fillVectorExponential f32x8 block-fallback candidate: 323.6 M lanes/s checksum=133434070.000

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "StandardNormal f64x4"
alea fillVectorStandardNormal f64x4 direct: 367.9 M lanes/s checksum=968.461
alea fillVectorStandardNormal f64x4 local scalar candidate: 395.9 M lanes/s checksum=968.461
alea fillVectorStandardNormal f64x4 inverse-cdf tail-only candidate: 240.6 M lanes/s checksum=1467.379
alea fillVectorStandardNormal f64x4 table-cdf candidate: 1074.4 M lanes/s checksum=-3356.461
alea fillVectorStandardNormal f64x4 same-candidate repair: 295.6 M lanes/s checksum=2043.352
alea fillVectorStandardNormal f64x4 block-fallback candidate: 366.5 M lanes/s checksum=3355.543

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "fillVectorNormal f64x4"
alea distributions.fillVectorNormal f64x4 direct: 387.7 M lanes/s checksum=968.461
alea fillVectorNormal f64x4 direct: 357.4 M lanes/s checksum=968.461
alea fillVectorNormal f64x4 local scalar candidate: 378.7 M lanes/s checksum=968.461
alea fillVectorNormal f64x4 inverse-cdf tail-only candidate: 242.9 M lanes/s checksum=1467.379
alea fillVectorNormal f64x4 table-cdf candidate: 1114.5 M lanes/s checksum=-3356.461
alea fillVectorNormal f64x4 same-candidate repair: 296.0 M lanes/s checksum=2043.352
alea fillVectorNormal f64x4 block-fallback candidate: 351.9 M lanes/s checksum=3355.543

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "StandardExponential f64x4"
alea fillVectorStandardExponential f64x4 direct: 358.8 M lanes/s checksum=134218705.547
alea fillVectorStandardExponential f64x4 local scalar candidate: 373.3 M lanes/s checksum=134218705.547
alea fillVectorStandardExponential f64x4 approx-log-low candidate: 362.5 M lanes/s checksum=134206156.897
alea fillVectorStandardExponential f64x4 table-cdf candidate: 1090.2 M lanes/s checksum=134199664.106
alea fillVectorStandardExponential f64x4 same-candidate repair: 248.5 M lanes/s checksum=134221283.137
alea fillVectorStandardExponential f64x4 block-fallback candidate: 330.1 M lanes/s checksum=133353024.205

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "fillVectorExponential f64x4"
alea distributions.fillVectorExponential f64x4 direct: 370.2 M lanes/s checksum=67109352.774
alea fillVectorExponential f64x4 direct: 377.0 M lanes/s checksum=67109352.774
alea fillVectorExponential f64x4 local scalar candidate: 379.4 M lanes/s checksum=67109352.774
alea fillVectorExponential f64x4 approx-log-low candidate: 451.9 M lanes/s checksum=67103078.448
alea fillVectorExponential f64x4 table-cdf candidate: 1083.5 M lanes/s checksum=67099832.053
alea fillVectorExponential f64x4 same-candidate repair: 254.7 M lanes/s checksum=67110641.569
alea fillVectorExponential f64x4 block-fallback candidate: 329.8 M lanes/s checksum=66676512.103
```

## Result

S4-M1217 is closed as minimum real-harness dense-SIMD gate evidence. The
checksum-preserving f32x8 repair, same-candidate, all-accepted, block-fallback,
range-block, and flat-slice families still trail same-run direct/default
baselines. f64x4 local-scalar rows are interesting follow-up evidence for scalar
lane-fill call shape, but they are not dense SIMD kernels and do not dominate all
standard plus parameterized direct/distribution rows. Table-CDF and approx-log
families remain much faster where present, but their checksums/output contracts
change, so they remain explicit opt-ins rather than default replacements. No
exact/default-compatible dense SIMD replacement for scalar ziggurat lane-fill is
identified by this gate; S4-M1218 remains active.
