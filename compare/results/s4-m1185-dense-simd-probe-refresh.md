# S4-M1185 Dense SIMD Probe Refresh

## Gap

After S4-M1184 refreshed full validation for the WeightedChoice typed-diagnostics
change, the active product bar again allowed exact/default dense SIMD
normal/exponential research. S4-M1185 refreshes focused real-harness
`vectorbench` evidence for f32x8 and f64x4 standard and parameterized
normal/exponential fills, avoiding the older 2026-07-03 baseline becoming stale.

## Commands

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "StandardNormal f32x8"
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "StandardExponential f32x8"
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "fillVectorNormal f32x8"
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "fillVectorExponential f32x8"
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "StandardNormal f64x4"
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "StandardExponential f64x4"
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "fillVectorNormal f64x4"
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "fillVectorExponential f64x4"
```

## Key Observations

Exact/default checksum-preserving f32x8 candidates still do not beat the direct
scalar lane-fill rows in the real vector-slice harness:

```text
StandardNormal f32x8 direct: 478.3 M lanes/s checksum=1690.344
StandardNormal f32x8 flat-slice: 457.3 M lanes/s checksum=1690.344
StandardNormal f32x8 repair: 436.9 M lanes/s checksum=1690.344

fillVectorNormal f32x8 direct: 466.0 M lanes/s checksum=1690.344
fillVectorNormal f32x8 flat-slice: 458.9 M lanes/s checksum=1690.344
fillVectorNormal f32x8 repair: 434.2 M lanes/s checksum=1690.344

StandardExponential f32x8 direct: 470.8 M lanes/s checksum=16787550.000
StandardExponential f32x8 flat-slice: 429.1 M lanes/s checksum=16787550.000
StandardExponential f32x8 repair: 433.1 M lanes/s checksum=16787550.000

fillVectorExponential f32x8 direct: 451.3 M lanes/s checksum=8393775.000
fillVectorExponential f32x8 flat-slice: 426.2 M lanes/s checksum=8393775.000
fillVectorExponential f32x8 repair: 432.5 M lanes/s checksum=8393775.000
```

f64x4 production direct rows also keep the default position. Some benchmark-only
local scalar helpers or stream-versioned / approximation rows can be faster in
individual filters, but they either are not a production implementation shape or
change checksums/output mapping:

```text
StandardNormal f64x4 direct: 431.7 M lanes/s checksum=44.440
StandardNormal f64x4 local scalar candidate: 466.1 M lanes/s checksum=44.440
StandardNormal f64x4 block-fallback: 436.3 M lanes/s checksum=-238.560

fillVectorNormal f64x4 direct: 484.9 M lanes/s checksum=44.440
fillVectorNormal f64x4 local scalar candidate: 474.6 M lanes/s checksum=44.440
fillVectorNormal f64x4 block-fallback: 433.2 M lanes/s checksum=-238.560

StandardExponential f64x4 direct: 429.3 M lanes/s checksum=8392265.906
StandardExponential f64x4 local scalar candidate: 452.1 M lanes/s checksum=8392265.906
StandardExponential f64x4 approx-log-low: 450.9 M lanes/s checksum=8383185.343

fillVectorExponential f64x4 direct: 455.3 M lanes/s checksum=4196132.953
fillVectorExponential f64x4 local scalar candidate: 449.7 M lanes/s checksum=4196132.953
fillVectorExponential f64x4 approx-log-low: 452.5 M lanes/s checksum=4191592.671
```

The known explicit approximation opt-ins remain much faster but keep their
versioned output/distribution contracts instead of replacing exact/default APIs:

```text
StandardNormal f32x8 table-cdf16384: 1301.4 M lanes/s checksum=1290.618
StandardExponential f32x8 approx-log: 652.6 M lanes/s checksum=16768773.000
StandardExponential f32x8 table-cdf: 1300.4 M lanes/s checksum=16774366.000
StandardNormal f64x4 table-cdf: 1281.5 M lanes/s checksum=81.564
StandardExponential f64x4 table-cdf: 1253.9 M lanes/s checksum=8386486.176
```

## Result

S4-M1185 is closed as refreshed dense-SIMD research evidence. No production
change is made: exact/default normal/exponential vector APIs remain scalar
ziggurat lane-fill, while table/approx-log/native-f32 paths remain explicit
opt-ins with documented output contracts. This is not whole-goal completion;
S4-M1186 remains active.
