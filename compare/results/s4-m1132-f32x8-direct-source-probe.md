# S4-M1132 f32x8 Direct-source Probe Refresh

## Gap

After S4-M1127/S4-M1128 found safe f64x4 direct-source standard normal and
standard exponential call-shape wins, S4-M1132 rechecked the neighboring f32x8
direct-source standard normal/exponential rows to avoid assuming f64x4 evidence
transfers to f32x8.

## Validation

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "StandardNormal f32x8"
vector microbench lanes=16777216 filter=StandardNormal f32x8
alea distributions.fillVectorStandardNormal f32x8 direct: 477.9 M lanes/s checksum=1690.344
alea fillVectorStandardNormal f32x8 direct: 477.5 M lanes/s checksum=1690.344
alea fillVectorStandardNormal f32x8 flat-slice candidate: 465.1 M lanes/s checksum=1690.344
alea fillVectorStandardNormal f32x8 repair candidate: 443.2 M lanes/s checksum=1690.344
alea fillVectorStandardNormal f32x8 table-cdf candidate: 1303.4 M lanes/s checksum=305.158

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "StandardExponential f32x8"
vector microbench lanes=16777216 filter=StandardExponential f32x8
alea distributions.fillVectorStandardExponential f32x8 direct: 471.2 M lanes/s checksum=16787550.000
alea fillVectorStandardExponential f32x8 direct: 471.2 M lanes/s checksum=16787550.000
alea fillVectorStandardExponential f32x8 flat-slice candidate: 447.2 M lanes/s checksum=16787550.000
alea fillVectorStandardExponential f32x8 repair candidate: 433.8 M lanes/s checksum=16787550.000
alea fillVectorStandardExponential f32x8 approx-log candidate: 653.2 M lanes/s checksum=16768773.000
alea fillVectorStandardExponential f32x8 table-cdf candidate: 1298.8 M lanes/s checksum=16774366.000
```

## Result

S4-M1132 is closed for the current bar as refreshed negative evidence:
checksum-preserving f32x8 flat-slice/repair candidates still trail the direct
exact/default scalar-lane baselines, while faster table/approx-log rows keep
different output mappings. No production change was made. S4-M1133 remains
active for the next stricter product bar.
