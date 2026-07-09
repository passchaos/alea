# S4-M1126 f32x8 Dense SIMD Probe

## Gap

After S4-M1125 refreshed the post-S4-M1124 status snapshots, the active product
bar is S4-M1126. One completion path is still to find an exact/default-compatible
dense SIMD normal/exponential kernel that beats scalar ziggurat lane-fill in the
real `vectorbench` harness while preserving or explicitly versioning stream
shape. This probe refreshes focused f32x8 evidence for that path.

## Validation

Focused normal probe:

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "StandardNormal f32x8"
vector microbench lanes=16777216 filter=StandardNormal f32x8
alea distributions.fillVectorStandardNormal f32x8: 387.6 M lanes/s checksum=1690.344
alea distributions.fillVectorStandardNormal f32x8 direct: 476.6 M lanes/s checksum=1690.344
alea fillVectorStandardNormal f32x8: 392.4 M lanes/s checksum=1690.344
alea fillVectorStandardNormal f32x8 direct: 477.8 M lanes/s checksum=1690.344
alea fillVectorStandardNormal f32x8 native candidate: 515.2 M lanes/s checksum=-476.872
alea fillVectorStandardNormal f32x8 flat-slice candidate: 467.9 M lanes/s checksum=1690.344
alea fillVectorStandardNormal f32x8 marsaglia-polar candidate: 155.4 M lanes/s checksum=-4595.797
alea fillVectorStandardNormal f32x8 approx-log polar candidate: 114.8 M lanes/s checksum=-4595.796
alea fillVectorStandardNormal f32x8 dense approx-log polar candidate: 185.1 M lanes/s checksum=-3584.059
alea fillVectorStandardNormal f32x8 ratio-uniforms candidate: 98.1 M lanes/s checksum=2559.853
alea fillVectorStandardNormal f32x8 ratio-uniforms dense-block candidate: 15.7 M lanes/s checksum=-1.371
alea fillVectorStandardNormal f32x8 inverse-cdf candidate: 80.2 M lanes/s checksum=842.676
alea fillVectorStandardNormal f32x8 inverse-cdf f32 candidate: 100.5 M lanes/s checksum=842.684
alea fillVectorStandardNormal f32x8 inverse-cdf central candidate: 211.6 M lanes/s checksum=842.684
alea fillVectorStandardNormal f32x8 inverse-cdf tail-repair candidate: 244.8 M lanes/s checksum=842.684
alea fillVectorStandardNormal f32x8 inverse-cdf tail-only candidate: 376.9 M lanes/s checksum=842.684
alea fillVectorStandardNormal f32x8 inverse-cdf reduced candidate: 398.9 M lanes/s checksum=148.397
alea fillVectorStandardNormal f32x8 inverse-cdf central-mask candidate: 324.7 M lanes/s checksum=842.684
alea fillVectorStandardNormal f32x8 inverse-cdf ziggurat-tail candidate: 404.8 M lanes/s checksum=1347.452
alea fillVectorStandardNormal f32x8 inverse-cdf central-only probe: 660.5 M lanes/s checksum=839.273
alea fillVectorStandardNormal f32x8 inverse-cdf tail-zero probe: 686.4 M lanes/s checksum=131.148
alea fillVectorStandardNormal f32x8 clt6 candidate: 269.1 M lanes/s checksum=497.141
alea fillVectorStandardNormal f32x8 clt12 candidate: 150.2 M lanes/s checksum=2489.604
alea fillVectorStandardNormal f32x8 table-cdf candidate: 1305.0 M lanes/s checksum=305.158
alea fillVectorStandardNormal f32x8 table-cdf4096 candidate: 1304.9 M lanes/s checksum=883.002
alea fillVectorStandardNormal f32x8 table-cdf16384 candidate: 1298.3 M lanes/s checksum=1290.618
alea fillVectorStandardNormal f32x8 repair candidate: 444.2 M lanes/s checksum=1690.344
alea fillVectorStandardNormal f32x8 same-candidate repair: 339.5 M lanes/s checksum=1629.022
alea fillVectorStandardNormal f32x8 all-accepted repair: 367.0 M lanes/s checksum=1629.022
alea fillVectorStandardNormal f32x8 block-fallback candidate: 423.6 M lanes/s checksum=1023.902
alea fillVectorStandardNormal f32x8 range-block candidate: 383.9 M lanes/s checksum=1023.902
alea fillVectorStandardNormal f32x8 fast direct: 428.9 M lanes/s checksum=2442.222
alea fillVectorStandardNormal f32x8 fast repair candidate: 302.4 M lanes/s checksum=2442.222
alea fillVectorStandardNormal f32x8 fast same-candidate repair: 307.1 M lanes/s checksum=2572.646
alea fillVectorStandardNormal f32x8 fast all-accepted repair: 337.1 M lanes/s checksum=2572.646
alea fillVectorStandardNormal f32x8 fast block-fallback candidate: 421.8 M lanes/s checksum=3134.210
```

Focused exponential probe:

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "StandardExponential f32x8"
vector microbench lanes=16777216 filter=StandardExponential f32x8
alea distributions.fillVectorStandardExponential f32x8: 356.3 M lanes/s checksum=16787550.000
alea distributions.fillVectorStandardExponential f32x8 direct: 470.5 M lanes/s checksum=16787550.000
alea fillVectorStandardExponential f32x8: 354.5 M lanes/s checksum=16787550.000
alea fillVectorStandardExponential f32x8 direct: 467.6 M lanes/s checksum=16787550.000
alea fillVectorStandardExponential f32x8 native candidate: 502.3 M lanes/s checksum=16771133.000
alea fillVectorStandardExponential f32x8 flat-slice candidate: 448.3 M lanes/s checksum=16787550.000
alea fillVectorStandardExponential f32x8 approx-log candidate: 652.1 M lanes/s checksum=16768773.000
alea fillVectorStandardExponential f32x8 table-cdf candidate: 1299.8 M lanes/s checksum=16774366.000
alea fillVectorStandardExponential f32x8 repair candidate: 434.5 M lanes/s checksum=16787550.000
alea fillVectorStandardExponential f32x8 same-candidate repair: 295.0 M lanes/s checksum=16789230.000
alea fillVectorStandardExponential f32x8 all-accepted repair: 330.5 M lanes/s checksum=16789230.000
alea fillVectorStandardExponential f32x8 block-fallback candidate: 395.6 M lanes/s checksum=16686202.000
alea fillVectorStandardExponential f32x8 mask-redraw candidate: 292.7 M lanes/s checksum=16668582.000
alea fillVectorStandardExponential f32x8 fast direct: 390.0 M lanes/s checksum=16775820.000
alea fillVectorStandardExponential f32x8 fast repair candidate: 292.8 M lanes/s checksum=16775820.000
alea fillVectorStandardExponential f32x8 fast same-candidate repair: 273.1 M lanes/s checksum=16776472.000
alea fillVectorStandardExponential f32x8 fast all-accepted repair: 315.2 M lanes/s checksum=16776472.000
alea fillVectorStandardExponential f32x8 fast block-fallback candidate: 380.4 M lanes/s checksum=16679704.000
```

## Result

S4-M1126 remains active. The exact/checksum-preserving f32x8 candidates in this
run still do not beat the direct scalar lane-fill baselines:

- normal direct baseline: 477.8 M lanes/s; checksum-preserving flat-slice and
  repair candidates: 467.9 M and 444.2 M lanes/s;
- exponential direct baseline: 467.6 M lanes/s; checksum-preserving flat-slice
  and repair candidates: 448.3 M and 434.5 M lanes/s.

The faster native/table/approx-log rows use different checksums/output mappings
and remain explicit opt-in or approximate-profile evidence, not replacements for
stable exact/default behavior. Continue S4-M1126 through either a stronger dense
candidate, broader runtime execution, broader validation, or a newly discovered
local `rand` / `rand_distr` gap.
