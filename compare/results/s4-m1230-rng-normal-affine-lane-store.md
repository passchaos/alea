# S4-M1230 Rng Normal Affine Lane-Store Refactor

## Gap

After S4-M1226 through S4-M1229 removed lane-count drift risks from core float
fills and distribution helpers, one core `rng.zig` slice transform still used a
direct vector-length query and hand-written lane loads/stores:
`normalAffineInPlaceVector`, which applies `mean + stddev * z` after staged
standard-normal fills.

This is a small but correctness-sensitive helper because a lane copy/stride
mismatch could corrupt parameterized normal fills without changing the underlying
standard-normal generator.

## Change

`src/rng.zig` now:

- adds `loadVectorLanes` beside the existing `storeVectorLanes` helper;
- derives `normalAffineInPlaceVector` width from `vectorInfo(VectorType).len`;
- uses the shared lane helpers for loading and storing the affine-transformed
  vector chunk.

A focused non-multiple-of-lane test compares f32/f64 vectorized affine transforms
against scalar slice formulas.

## Validation

Focused tests:

```console
$ zig test src/rng.zig --test-filter "normal affine in-place helper"
1/1 rng.test.normal affine in-place helper preserves scalar slice transform...OK
All 1 tests passed.
```

Full validation:

```console
$ zig build test
apicheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok

$ zig build validate
...
statcheck ok
profilecheck ok

$ zig build validate-local
...
surfacecheck ok
runtimecheck ok: no additional runtime runner available
rand_bench_smoke self-test ok

$ zig build crosscheck

$ git diff --check
```

Status tooling check:

```console
$ zig build roadmapcheck toolingcheck rand-status-self-test
roadmapcheck ok
toolingcheck ok
rand-status self-test ok
```

## Result

S4-M1230 closes the remaining core `rng.zig` affine lane-store refactor: staged
normal affine transforms now share the same vector lane helper pattern as the
other core/distribution slice transforms. The whole product goal remains active
under the next S4-M1231 bar.
