# S4-M1210 Inverse-CDF Tail Probe

## Gap

S4-M1210 continued the exact/default dense SIMD normal research thread after the
post-S4-M1209 validation refresh. The strongest valid inverse-CDF family rows
were still below scalar ziggurat lane-fill, while invalid central-only diagnostic
probes suggested that tail handling was the expensive part. This milestone reruns
a focused same-host `vectorbench` probe for direct ziggurat baselines, valid
tail-only inverse-CDF candidates, and invalid diagnostic lower bounds.

## Commands

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "StandardNormal f32x8 direct"
vector microbench lanes=4194304 filter=StandardNormal f32x8 direct
alea distributions.fillVectorStandardNormal f32x8 direct: 428.9 M lanes/s checksum=1257.612
alea fillVectorStandardNormal f32x8 direct: 446.5 M lanes/s checksum=1257.612

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "StandardNormal f64x4 direct"
vector microbench lanes=4194304 filter=StandardNormal f64x4 direct
alea fillVectorStandardNormal f64x4 direct: 397.5 M lanes/s checksum=-149.495

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "fillVectorNormal f32x8 direct"
vector microbench lanes=4194304 filter=fillVectorNormal f32x8 direct
alea fillVectorNormal f32x8 direct: 465.3 M lanes/s checksum=1257.612

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "fillVectorNormal f64x4 direct"
vector microbench lanes=4194304 filter=fillVectorNormal f64x4 direct
alea distributions.fillVectorNormal f64x4 direct: 384.0 M lanes/s checksum=-149.495
alea fillVectorNormal f64x4 direct: 385.3 M lanes/s checksum=-149.495

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "inverse-cdf tail-only"
vector microbench lanes=4194304 filter=inverse-cdf tail-only
alea fillVectorStandardNormal f32x8 inverse-cdf tail-only candidate: 212.0 M lanes/s checksum=-480.437
alea fillVectorStandardNormal f64x4 inverse-cdf tail-only candidate: 278.7 M lanes/s checksum=13.189
alea fillVectorNormal f32x8 inverse-cdf tail-only candidate: 364.9 M lanes/s checksum=-480.437
alea fillVectorNormal f64x4 inverse-cdf tail-only candidate: 287.9 M lanes/s checksum=13.189

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "central-only"
vector microbench lanes=4194304 filter=central-only
alea fillVectorStandardNormal f32x8 inverse-cdf central-only probe: 620.5 M lanes/s checksum=-458.946
alea fillVectorNormal f32x8 inverse-cdf central-only probe: 635.9 M lanes/s checksum=-458.946

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "tail-zero"
vector microbench lanes=4194304 filter=tail-zero
alea fillVectorStandardNormal f32x8 inverse-cdf tail-zero probe: 288.6 M lanes/s checksum=-195.529
alea fillVectorNormal f32x8 inverse-cdf tail-zero probe: 582.9 M lanes/s checksum=-195.529
```

## Result

S4-M1210 is closed as dense-SIMD research evidence for the current bar. The valid
inverse-CDF tail-only candidates still trail same-host exact/default scalar
ziggurat lane-fill baselines for standard and parameterized f32x8/f64x4 normal
workflows. Central-only and tail-zero probes remain invalid diagnostic lower
bounds: their checksums and distribution contracts differ, so they cannot replace
or opt into a sampler. This is research evidence, not whole-goal completion;
S4-M1211 remains active.
