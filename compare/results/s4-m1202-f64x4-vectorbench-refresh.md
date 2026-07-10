# S4-M1202 f64x4 Vectorbench Refresh

## Gap

S4-M1201 refreshed f32x8 standard normal/exponential evidence. S4-M1202 refreshes
the adjacent real-harness f64x4 standard normal and standard exponential rows to
check whether any exact/default-compatible dense SIMD candidate now beats scalar
ziggurat lane-fill.

## Commands

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "StandardNormal f64x4"
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "StandardExponential f64x4"
```

## Observations

For standard normal f64x4, checksum-preserving or default-compatible candidates
still do not beat the direct scalar lane-fill baseline:

```text
alea fillVectorStandardNormal f64x4 direct: 489.8 M lanes/s checksum=-149.495
alea fillVectorStandardNormal f64x4 local scalar candidate: 482.9 M lanes/s checksum=-149.495
alea fillVectorStandardNormal f64x4 noinline local candidate: 328.3 M lanes/s checksum=-149.495
alea fillVectorStandardNormal f64x4 same-candidate repair: 354.2 M lanes/s checksum=-220.832
alea fillVectorStandardNormal f64x4 all-accepted repair: 369.7 M lanes/s checksum=-220.832
alea fillVectorStandardNormal f64x4 block-fallback candidate: 437.0 M lanes/s checksum=-95.265
alea fillVectorStandardNormal f64x4 range-block candidate: 375.0 M lanes/s checksum=-95.265
```

For standard exponential f64x4, the benchmark-local scalar helper and low-degree
approx-log candidate can exceed the direct row in this short focused run, but
they are not default replacements: one is not a production implementation shape,
and the approx-log rows change output mapping/precision contracts. Exact repair
and block-fallback candidates still trail or change checksums:

```text
alea fillVectorStandardExponential f64x4 direct: 375.3 M lanes/s checksum=2097619.725
alea fillVectorStandardExponential f64x4 local scalar candidate: 440.4 M lanes/s checksum=2097619.725
alea fillVectorStandardExponential f64x4 approx-log-low candidate: 451.0 M lanes/s checksum=2095768.419
alea fillVectorStandardExponential f64x4 same-candidate repair: 313.6 M lanes/s checksum=2097801.581
alea fillVectorStandardExponential f64x4 all-accepted repair: 329.4 M lanes/s checksum=2097801.581
alea fillVectorStandardExponential f64x4 block-fallback candidate: 403.7 M lanes/s checksum=2084742.531
alea fillVectorStandardExponential f64x4 mask-redraw candidate: 349.3 M lanes/s checksum=2082945.806
```

Explicit table opt-ins remain much faster and keep their versioned output
contract:

```text
alea fillVectorStandardNormal f64x4 table-cdf candidate: 1278.2 M lanes/s checksum=-143.118
alea fillVectorStandardExponential f64x4 table-cdf candidate: 1281.5 M lanes/s checksum=2095542.322
```

## Result

S4-M1202 is closed as refreshed dense-SIMD research evidence for f64x4 standard
normal/exponential. No default production change is made: exact/default APIs
remain on scalar ziggurat lane-fill, while table and approximation profiles
remain explicit opt-ins or benchmark-only candidates. This is research evidence,
not whole-goal completion; S4-M1203 remains active.
