# S4-M1225 f64 Uniform Low-Bit Bitcast and 8-Lane Bulk

## Gap

S4-M1224 recovered ordinary f64 StandardUniform throughput while preserving the
S4-M1223 high-53-bit `n / 2^53` grid. Two small hot-path costs remained:

- the low grid bit was still converted through `@floatFromInt(low_bit) * 2^-53`;
- f64 slice fills and f64 range fills still chunked four f64 lanes at a time even
  though the conversion helper is generic over vector width.

The goal for this follow-up was deliberately narrow: improve throughput only if
we can keep the exact S4-M1223 f64 StandardUniform grid and scalar stream shape.

## Change

`src/rng.zig` now:

- forms the low half-ULP contribution by bitcasting either `0` or the binary
  representation of `2^-53`, avoiding a low-bit integer-to-float multiply;
- widens ordinary f64 `fill` and `fillRange` chunks from `@Vector(4, f64)` to
  `@Vector(8, f64)`;
- uses `lanes = @typeInfo(VectorType).vector.len` in those loops so chunk width
  and copy width cannot drift again.

Focused tests now cover both the edge-grid values and scalar stream shape for
ordinary f64 bulk fills/ranges.

## Validation

Correctness and stream-shape tests:

```console
$ zig test src/rng.zig --test-filter "ordinary f64"
1/3 rng.test.ordinary f64 standard uniform uses full 53-bit grid on all paths...OK
2/3 rng.test.ordinary f64 bulk fills preserve scalar stream shape...OK
3/3 root.test_0...OK
All 3 tests passed.
```

A dedicated stream-shape check caught an intermediate invalid `@Vector(8, f64)`
loop that still copied only four lanes and skipped half the random words; the
adopted loops now use the vector lane count for both stepping and copying.

Focused same-host throughput checks:

```console
$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "float f64"
alea float f64 facade: 778.0 M samples/s checksum=8390382.025
alea float f64 direct: 785.6 M samples/s checksum=8390382.025

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fill f64"
alea fill f64 facade: 803.9 M samples/s checksum=8389303.701
alea fill f64 direct: 803.7 M samples/s checksum=8389303.701

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillRange f64"
alea fillRange f64: 768.9 M samples/s checksum=-1620.857
alea fillRange f64 direct: 771.2 M samples/s checksum=-1620.857

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216 "fillVector f64x4"
vector microbench lanes=16777216 filter=fillVector f64x4
alea fillVector f64x4: 893.4 M lanes/s checksum=8388680.868
```

Fresh local Rust reference rows on the same host:

```console
$ cargo run --manifest-path compare/rand_bench/Cargo.toml --release -- 134217728 "float f64"
rand float f64: 853.5 M samples/s checksum=8389588.847

$ cargo run --manifest-path compare/rand_bench/Cargo.toml --release -- 134217728 "float range f64"
rand float range f64: 799.2 M samples/s checksum=2189.696
```

Broader validation:

```console
$ zig build test
...
roadmapcheck ok

$ zig build validate
...
statcheck ok
profilecheck ok

$ zig build validate-local
...
surfacecheck ok
runtimecheck ok: no additional runtime runner available

$ zig build crosscheck

$ git diff --check
```

## Result

S4-M1225 is closed for the current bar: ordinary f64 StandardUniform keeps the
correct 53-bit grid, bulk/range fills preserve scalar stream shape, and the hot
paths recover additional throughput. Local Rust scalar f64 still has a lead in
one focused row, so the next product bar is S4-M1226 rather than whole-goal
completion.
