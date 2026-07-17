# S4-M1224 f64 StandardUniform Throughput Recovery

## Gap

S4-M1223 fixed ordinary f64 StandardUniform correctness by restoring the local
Rust-compatible high-53-bit `n / 2^53` grid across facade, direct-source,
bulk-fill, value-iterator/distribution-fill, and vector paths. The first simple
implementation used full-width integer-to-float conversion, which preserved
correctness but regressed the ordinary f64 hot paths versus the previous 52-bit
bitcast implementation.

S4-M1224 follows the project rule that performance optimization must preserve the
correctness contract established first.

## Change

`src/rng.zig` now computes ordinary f64 StandardUniform values as:

1. a fast exponent-bit base for the upper 52 bits, exactly representing
   `floor(n / 2) / 2^52`;
2. plus the remaining high-53-bit grid bit as either zero or `2^-53`.

This is algebraically the same `n / 2^53` grid as the straightforward
`float(raw >> 11) * 2^-53` conversion, but recovers much of the bitcast
throughput. The same split conversion is used for scalar and vector ordinary f64
paths.

Strict-open `(0, 1)` f64 and open-closed `(0, 1]` f64 helpers keep their
endpoint-specific implementations.

## Validation

Focused correctness regression:

```console
$ zig test src/rng.zig --test-filter "ordinary f64 standard uniform"
1/1 rng.test.ordinary f64 standard uniform uses full 53-bit grid on all paths...OK
All 1 tests passed.
```

Focused same-host throughput checks, 128 MiB scale unless noted:

```console
$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fill f64"
alea fill f64 facade: 718.2 M samples/s checksum=8389303.701
alea fill f64 direct: 718.7 M samples/s checksum=8389303.701

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillRange f64"
alea fillRange f64: 631.8 M samples/s checksum=-1620.857
alea fillRange f64 direct: 688.6 M samples/s checksum=-1620.857

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "float f64"
alea float f64 facade: 727.8 M samples/s checksum=8390382.025
alea float f64 direct: 736.4 M samples/s checksum=8390382.025

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "floatRange f64"
alea floatRange f64 facade: 639.6 M samples/s checksum=-4090.227
alea floatRange f64 direct: 643.4 M samples/s checksum=-4090.227

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "fillVector f64x4"
vector microbench lanes=16777216 filter=fillVector f64x4
alea fillVector f64x4: 826.4 M lanes/s checksum=8388680.868
```

A raw-word bulk-fill attempt that still preserved the 53-bit grid was rejected
before this change because it made `fill f64` slower on the same host, even
though a staged range transform could improve one range row. The adopted split
conversion is simpler and improves scalar/vector ordinary paths without a
separate staged buffer policy.

Broader validation after status/roadmap synchronization:

```console
$ zig build test
...
roadmapcheck ok
toolingcheck ok
readmecheck ok

$ zig build validate
...
statcheck ok
distcheck ok
profilecheck ok

$ zig build validate-local
...
surfacecheck ok
runtimecheck ok: no additional runtime runner available
rand-status self-test ok

$ zig build crosscheck
```

S4-M1224 is closed for the current bar: ordinary f64 StandardUniform keeps the
53-bit grid while regaining a substantial amount of throughput. The next product
bar is S4-M1225.
