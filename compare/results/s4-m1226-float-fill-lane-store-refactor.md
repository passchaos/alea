# S4-M1226 Float Fill Lane-Store Refactor

## Gap

S4-M1225 fixed a real correctness bug caught during review: an intermediate
ordinary f64 `@Vector(8, f64)` fill loop still stepped/copied four lanes, which
skipped random words and changed the bulk stream shape. The final S4-M1225 code
fixed f64 fill/range loops, but adjacent f32/f64 vectorized float fill loops
still repeated literal lane counts at each call site.

This follow-up is structural and correctness-focused: reduce the chance of
future lane-width drift without changing the public output contracts or making a
performance-only change.

## Change

`src/rng.zig` now:

- derives vectorized f32/f64 slice-fill loop widths from
  `vectorInfo(VectorType).len` instead of hard-coded copy/step constants;
- centralizes scalar-slice lane copies in inline `storeVectorLanes`, so the
  vector type, loop step, and copied lane count remain coupled;
- routes f32 `(0, 1]` conversion through `f32OpenClosedFromBits`, removing a
  duplicated scalar/vector conversion expression.

Focused regression coverage now checks the packed f32 ordinary/open/open-closed
and ranged fill stream shapes with deterministic `StepRng` word packing, plus
f64 strict-open fill parity with repeated scalar sampling.

## Validation

Focused stream-shape tests:

```console
$ zig test src/rng.zig --test-filter "float bulk fill lane helpers"
1/2 rng.test.float bulk fill lane helpers preserve stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/rng.zig --test-filter "ordinary f64"
1/3 rng.test.ordinary f64 standard uniform uses full 53-bit grid on all paths...OK
2/3 rng.test.ordinary f64 bulk fills preserve scalar stream shape...OK
3/3 root.test_0...OK
All 3 tests passed.
```

Broader native gate:

```console
$ zig build test
apicheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
```

Full validation gates:

```console
$ zig build validate
...
statcheck ok
profilecheck ok

$ zig build validate-local
...
surfacecheck ok
runtimecheck ok: no additional runtime runner available
rand-status self-test ok

$ zig build crosscheck

$ git diff --check
```

Focused same-host throughput smoke checks after the refactor:

```console
$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fill f64"
alea fill f64 facade: 801.9 M samples/s checksum=8389303.701
alea fill f64 direct: 803.4 M samples/s checksum=8389303.701

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillRange f64"
alea fillRange f64: 769.8 M samples/s checksum=-1620.857
alea fillRange f64 direct: 771.1 M samples/s checksum=-1620.857

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillOpenClosed f32"
alea fillOpenClosed f32: 1131.8 M samples/s checksum=16776573.000
```

Earlier smoke rows in the same run also showed `fill f32` around 1164M,
`fillOpen f32` around 1118M, `fillOpen f64` around 881M, and `fillVector f64x4`
around 877M lanes/s; those rows are sanity checks, not a new performance claim.

## Result

S4-M1226 is closed for the current bar: the adjacent vectorized float fill code
is structurally less fragile, the packed f32 and strict-open f64 stream shapes
are covered, and the hot f64 fill/range paths remain in the S4-M1225 throughput
range. The whole product goal remains active under the next S4-M1227 bar.
