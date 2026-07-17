# S4-M1227 Distribution Lane-Store Refactor

## Gap

S4-M1226 removed duplicated magic lane counts from core `rng.zig` float slice
fills after a real f64 vector-width drift bug had been caught. A follow-up audit
found the same structural pattern in `src/distributions.zig`: staged
slice-to-vector transforms such as f32 standard normal/exponential chunk fills,
log-normal/half-normal post transforms, and optional libmvec exp transforms were
still open-coding vector lane loads/stores.

The goal for S4-M1227 is not a new algorithm. It is a correctness/maintainability
hardening step: keep vector width, loop stride, and lane copy count tied to the
same `VectorType` so future width changes do not silently alter output shape.

## Change

`src/distributions.zig` now:

- adds inline `loadVectorLanes` and `storeVectorLanes` helpers near
  `vectorInfo` / `vectorChild`;
- uses those helpers in f32 standard normal/exponential chunk fills;
- uses them in `scaleInPlaceVector`, `expInPlaceVector`, `absInPlaceVector`, and
  the optional f32/f64 libmvec exp in-place wrappers;
- derives lane counts through `vectorInfo(VectorType).len` rather than repeating
  raw `@typeInfo(VectorType).vector.len` or literal lane counts at each copy
  site.

Focused tests now cover staged slice transforms for scale, abs, and exp across
non-multiple-of-vector-length buffers, while existing standard f32 fill tests
continue to cover repeated scalar stream shape.

## Validation

Focused tests:

```console
$ zig test src/distributions.zig --test-filter "distribution vector lane helpers"
1/1 distributions.test.distribution vector lane helpers preserve scalar slice transforms...OK
All 1 tests passed.

$ zig test src/distributions.zig --test-filter "standard f32 fills preserve scalar stream shape"
1/2 distributions.test.standard f32 fills preserve scalar stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Native gate:

```console
$ zig build test
apicheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
```

Focused throughput sanity checks after the refactor:

```console
$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillStandardNormal f32"
alea fillStandardNormal f32: 272.8 M samples/s checksum=-1258.017
alea fillStandardNormal f32 fast direct: 414.4 M samples/s checksum=-1258.017
alea fillStandardNormal f32 scalar direct: 464.1 M samples/s checksum=-709.500

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillStandardExponential f32"
alea fillStandardExponential f32: 364.2 M samples/s checksum=2096190.500
alea fillStandardExponential f32 fast direct: 376.9 M samples/s checksum=2096190.500
alea fillStandardExponential f32 scalar direct: 435.6 M samples/s checksum=2097282.200

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillLogNormal f32"
alea fillLogNormal f32: 129.5 M samples/s checksum=1082346.600
alea fillLogNormal f32 fast direct: 133.0 M samples/s checksum=1082346.600
alea fillLogNormal f32 scalar direct: 140.3 M samples/s checksum=1081944.100
alea fillLogNormal f32 stddev=1: 75.9 M samples/s checksum=1731700.317
alea fillLogNormal f32 stddev=1 fast direct: 76.0 M samples/s checksum=1731700.317
alea fillLogNormal f32 stddev=1 scalar direct: 78.4 M samples/s checksum=1730302.499

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillHalfNormal"
alea fillHalfNormal: 262.8 M samples/s checksum=1672790.258
alea fillHalfNormal scalar direct: 419.1 M samples/s checksum=1672808.826
```

These rows are sanity checks for checksum/output preservation and broad
throughput range, not a new performance-closure claim.

Full validation:

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

## Result

S4-M1227 closes a structure-level correctness hardening bar: distribution-level
vector slice transforms now share the same lane load/store pattern as the core
float fills, reducing future drift risk while preserving focused stream-shape and
slice-transform tests. The whole product goal remains active under the next
S4-M1228 bar.
