# S4-M1201 f32x8 Vectorbench Refresh

## Gap

After S4-M1200 refreshed full validation, the active bar again allowed
exact/default dense SIMD normal/exponential research. This milestone refreshes
real-harness f32x8 vectorbench evidence for standard normal and standard
exponential fills to check whether any exact/default-compatible dense candidate
now beats scalar ziggurat lane-fill.

## Commands

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "StandardNormal f32x8"
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "StandardExponential f32x8"
```

## Observations

For standard normal f32x8, exact/default checksum-preserving alternatives still
trail the direct scalar lane-fill baseline in the real vector-slice harness:

```text
alea fillVectorStandardNormal f32x8 direct: 473.4 M lanes/s checksum=1257.612
alea fillVectorStandardNormal f32x8 flat-slice candidate: 449.5 M lanes/s checksum=1257.612
alea fillVectorStandardNormal f32x8 repair candidate: 438.4 M lanes/s checksum=1257.612
alea fillVectorStandardNormal f32x8 same-candidate repair: 338.8 M lanes/s checksum=1407.302
alea fillVectorStandardNormal f32x8 all-accepted repair: 370.5 M lanes/s checksum=1407.302
alea fillVectorStandardNormal f32x8 block-fallback candidate: 429.1 M lanes/s checksum=791.049
```

Approximation/output-mapping-changing rows can be faster, but they remain named
opt-ins rather than default replacements:

```text
alea fillVectorStandardNormal f32x8 table-cdf16384 candidate: 1301.7 M lanes/s checksum=-183.872
alea fillVectorStandardNormal f32x8 native candidate: 501.5 M lanes/s checksum=-462.728
alea fillVectorStandardNormal f32x8 inverse-cdf central-only probe: 661.9 M lanes/s checksum=-458.946
alea fillVectorStandardNormal f32x8 inverse-cdf tail-zero probe: 686.9 M lanes/s checksum=-195.529
```

For standard exponential f32x8, exact/default checksum-preserving alternatives
also still trail the direct scalar lane-fill baseline:

```text
alea fillVectorStandardExponential f32x8 direct: 462.2 M lanes/s checksum=4197710.000
alea fillVectorStandardExponential f32x8 flat-slice candidate: 431.5 M lanes/s checksum=4197710.000
alea fillVectorStandardExponential f32x8 repair candidate: 435.2 M lanes/s checksum=4197710.000
alea fillVectorStandardExponential f32x8 same-candidate repair: 294.0 M lanes/s checksum=4197848.000
alea fillVectorStandardExponential f32x8 all-accepted repair: 329.4 M lanes/s checksum=4197848.000
alea fillVectorStandardExponential f32x8 block-fallback candidate: 397.0 M lanes/s checksum=4173532.200
alea fillVectorStandardExponential f32x8 mask-redraw candidate: 292.9 M lanes/s checksum=4168486.200
```

Explicit opt-in approximation rows remain much faster but have separate output
contracts:

```text
alea fillVectorStandardExponential f32x8 approx-log candidate: 652.7 M lanes/s checksum=4191017.500
alea fillVectorStandardExponential f32x8 table-cdf candidate: 1302.8 M lanes/s checksum=4192680.000
```

## Result

S4-M1201 is closed as refreshed dense-SIMD research evidence for f32x8 standard
normal/exponential. No default production change is made: exact/default APIs
remain on scalar ziggurat lane-fill, while native-f32/table/approx-log profiles
remain explicit opt-ins with documented output contracts. This is research
evidence, not whole-goal completion; S4-M1202 remains active.
