# S4-M1229 Vector Sampler Lane-Count Sweep

## Gap

S4-M1228 completed the staged distribution transform lane-store sweep, but a
follow-up audit still found direct `@typeInfo(VectorType).vector.len` queries in
vector sampler wrappers. These were not immediate functional bugs, but they were
the last remaining distribution-side lane-count call sites bypassing the
central `vectorInfo(VectorType).len` helper introduced for structural consistency.

The goal for S4-M1229 is a narrow maintainability/correctness hardening step:
make vector sampler wrappers use the same lane-count path as the core and staged
transform code, without changing output mappings or stream shape.

## Change

`src/distributions.zig` now uses `vectorInfo(VectorType).len` in the remaining
vector sampler/rank sampler wrappers, covering:

- `VectorGamma`, `VectorChiSquared`, `VectorChi`, `VectorErlang`;
- `VectorBeta`, `VectorFisherF`, `VectorStudentT`;
- non-finite `triangularFromUniformVector` fallback;
- `VectorZipf` and `VectorZeta`.

A grep now finds no remaining direct `@typeInfo(VectorType).vector.len` uses in
`src/distributions.zig`.

## Validation

Focused tests:

```console
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "checked fill helpers preserve valid-parameter stream shape"
1/3 distributions.test.checked fill helpers preserve valid-parameter stream shape...OK
2/3 root.test_0...OK
3/3 rng.test.checked fill helpers preserve valid-parameter stream shape...OK
All 3 tests passed.
```

Structural grep:

```console
$ grep -n "@typeInfo(VectorType).vector.len" src/distributions.zig
# no output
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

S4-M1229 closes the remaining vector sampler lane-count sweep in
`src/distributions.zig`: distribution vector wrappers now consistently use
`vectorInfo(VectorType).len`, and focused vector/checked-fill tests preserve
stream shape. The whole product goal remains active under the next S4-M1230 bar.
