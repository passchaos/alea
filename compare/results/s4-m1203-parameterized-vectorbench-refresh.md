# S4-M1203 Parameterized Vectorbench Refresh

## Gap

S4-M1201 and S4-M1202 refreshed standard f32x8/f64x4 normal/exponential
vectorbench evidence. S4-M1203 refreshes the adjacent parameterized
`fillVectorNormal` and `fillVectorExponential` real-harness rows for f32x8 and
f64x4, checking whether exact/default-compatible dense candidates now beat scalar
ziggurat lane-fill when affine/rate transforms are included.

## Commands

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "fillVectorNormal f32x8"
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "fillVectorExponential f32x8"
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "fillVectorNormal f64x4"
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "fillVectorExponential f64x4"
```

## Observations

For parameterized normal f32x8, exact/default checksum-preserving candidates
still trail direct scalar lane-fill:

```text
alea fillVectorNormal f32x8 direct: 466.6 M lanes/s checksum=1257.612
alea fillVectorNormal f32x8 flat-slice candidate: 448.0 M lanes/s checksum=1257.612
alea fillVectorNormal f32x8 repair candidate: 435.7 M lanes/s checksum=1257.612
alea fillVectorNormal f32x8 block-fallback candidate: 422.0 M lanes/s checksum=791.049
```

For parameterized exponential f32x8, exact/default direct remains the strongest
checksum-preserving production shape, while approximation/table rows remain
explicit opt-ins:

```text
alea fillVectorExponential f32x8 direct: 443.9 M lanes/s checksum=2098855.000
alea fillVectorExponential f32x8 flat-slice candidate: 421.2 M lanes/s checksum=2098855.000
alea fillVectorExponential f32x8 repair candidate: 433.7 M lanes/s checksum=2098855.000
alea fillVectorExponential f32x8 approx-log candidate: 640.5 M lanes/s checksum=2095508.800
alea fillVectorExponential f32x8 table-cdf candidate: 1246.7 M lanes/s checksum=2096340.000
```

For parameterized normal f64x4, direct scalar lane-fill remains ahead of the
checksum-preserving local scalar candidate and repair/fallback candidates:

```text
alea fillVectorNormal f64x4 direct: 473.5 M lanes/s checksum=-149.495
alea fillVectorNormal f64x4 local scalar candidate: 471.8 M lanes/s checksum=-149.495
alea fillVectorNormal f64x4 same-candidate repair: 355.6 M lanes/s checksum=-220.832
alea fillVectorNormal f64x4 block-fallback candidate: 435.0 M lanes/s checksum=-95.265
```

For parameterized exponential f64x4, direct scalar lane-fill is again the
strongest checksum-preserving production shape in this focused run. Approx-log
and table rows remain output-mapping-changing opt-ins/candidates:

```text
alea fillVectorExponential f64x4 direct: 457.5 M lanes/s checksum=1048809.863
alea fillVectorExponential f64x4 local scalar candidate: 449.9 M lanes/s checksum=1048809.863
alea fillVectorExponential f64x4 approx-log-low candidate: 453.0 M lanes/s checksum=1047884.210
alea fillVectorExponential f64x4 table-cdf candidate: 1276.3 M lanes/s checksum=1047771.161
```

## Result

S4-M1203 is closed as refreshed dense-SIMD research evidence for parameterized
f32x8/f64x4 normal/exponential fills. No default production change is made:
exact/default APIs remain on scalar ziggurat lane-fill, while table/approx/native
profiles remain explicit opt-ins or benchmark-only candidates. This is research
evidence, not whole-goal completion; S4-M1204 remains active.
