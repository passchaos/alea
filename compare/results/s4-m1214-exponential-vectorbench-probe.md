# S4-M1214 Exponential Vectorbench Probe

## Gap

S4-M1214 continued the exact/default dense SIMD normal/exponential research thread
after the post-S4-M1213 validation refresh. Recent normal inverse-CDF probes still
failed to beat exact/default scalar ziggurat lane-fill, while exponential has
explicit throughput opt-ins (`approx-log` and table-CDF) whose output contracts
intentionally differ from defaults. This milestone reruns a focused same-host
`vectorbench` probe for exact/default exponential baselines and the fastest
non-default exponential candidates.

## Commands

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "StandardExponential f32x8 direct"
vector microbench lanes=4194304 filter=StandardExponential f32x8 direct
alea distributions.fillVectorStandardExponential f32x8 direct: 367.9 M lanes/s checksum=4197710.000
alea fillVectorStandardExponential f32x8 direct: 326.3 M lanes/s checksum=4197710.000

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "StandardExponential f64x4 direct"
vector microbench lanes=4194304 filter=StandardExponential f64x4 direct
alea fillVectorStandardExponential f64x4 direct: 300.4 M lanes/s checksum=2097619.725

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "fillVectorExponential f32x8 direct"
vector microbench lanes=4194304 filter=fillVectorExponential f32x8 direct
alea fillVectorExponential f32x8 direct: 315.7 M lanes/s checksum=2098855.000

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "fillVectorExponential f64x4 direct"
vector microbench lanes=4194304 filter=fillVectorExponential f64x4 direct
alea distributions.fillVectorExponential f64x4 direct: 308.3 M lanes/s checksum=1048809.863
alea fillVectorExponential f64x4 direct: 308.5 M lanes/s checksum=1048809.863

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "approx-log candidate"
vector microbench lanes=4194304 filter=approx-log candidate
alea fillVectorStandardExponential f32x8 approx-log candidate: 552.4 M lanes/s checksum=4191017.500
alea fillVectorStandardExponential f64x4 approx-log candidate: 327.3 M lanes/s checksum=2095769.481
alea fillVectorExponential f32x8 approx-log candidate: 556.7 M lanes/s checksum=2095508.800
alea fillVectorExponential f64x4 approx-log candidate: 327.3 M lanes/s checksum=1047884.740

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "table-cdf candidate"
vector microbench lanes=4194304 filter=table-cdf candidate
alea fillVectorStandardExponential f32x8 table-cdf candidate: 903.5 M lanes/s checksum=4192680.000
alea fillVectorStandardExponential f64x4 table-cdf candidate: 920.7 M lanes/s checksum=2095542.322
alea fillVectorExponential f32x8 table-cdf candidate: 923.7 M lanes/s checksum=2096340.000
alea fillVectorExponential f64x4 table-cdf candidate: 913.7 M lanes/s checksum=1047771.161
```

The table-CDF filter also reports normal table rows; those are retained in the
command output but are not the S4-M1214 decision point.

## Result

S4-M1214 is closed as dense-SIMD research evidence for the current bar. The
approx-log and table-CDF exponential rows beat exact/default direct ziggurat
lane-fill, but their checksums differ and their output/distribution contracts are
explicit non-default opt-ins. No exact/default-compatible replacement for scalar
ziggurat lane-fill is identified by this probe. This is research evidence, not
whole-goal completion; S4-M1215 remains active.
