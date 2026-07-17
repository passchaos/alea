# S4-M1228 Distribution Transform Lane-Store Sweep

## Gap

S4-M1227 introduced shared vector lane load/store helpers in
`src/distributions.zig` and applied them to the most obvious staged slice
transforms. A follow-up grep still found a second cluster of distribution
post-transform helpers that open-coded `dest[i + lane]` copies and direct
`@typeInfo(VectorType).vector.len` queries.

These helpers are correctness-sensitive because they transform staged scalar
uniform/normal buffers in place. A lane-count drift here would not necessarily
break compilation, but it could silently skip or duplicate staged samples. The
S4-M1228 bar completes this lane-store sweep for the remaining distribution
slice transforms.

## Change

`src/distributions.zig` now:

- routes the remaining staged distribution transforms through
  `loadVectorLanes` / `storeVectorLanes`;
- derives their vector widths through `vectorInfo(VectorType).len`;
- covers inverse Gaussian normal-buffer transforms and open/open-closed uniform
  transforms used by Cauchy, Triangular, Rayleigh, Logistic, Laplace,
  LogLogistic, PowerFunction, Gumbel, Frechet, Arcsine, Pareto, and Weibull;
- uses `vectorInfo(...).len` consistently in vector unit geometry helpers too.

The focused regression test now compares vectorized f32 slice transforms against
the scalar formulas on a non-multiple-of-lane buffer and checks inverse-Gaussian
vector/chunk stream shape against repeated scalar transformation.

## Validation

Focused tests:

```console
$ zig test src/distributions.zig --test-filter "distribution vector lane helpers"
1/2 distributions.test.distribution vector lane helpers preserve scalar slice transforms...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Native gate:

```console
$ zig build test
apicheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
```

Focused throughput sanity checks after the refactor:

```console
$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillTriangular"
alea fillTriangular: 343.4 M samples/s checksum=350566.296
alea fillTriangular scalar direct: 324.7 M samples/s checksum=348638.486

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillCauchy"
alea fillCauchy: 72.0 M samples/s checksum=601538.593
alea fillCauchy fast direct: 74.7 M samples/s checksum=601538.593
alea fillCauchy scalar direct: 73.2 M samples/s checksum=-7612291.016

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillLogistic"
alea fillLogistic: 158.6 M samples/s checksum=1294.193
alea fillLogistic scalar direct: 155.5 M samples/s checksum=4327.590

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillRayleigh"
alea fillRayleigh: 191.2 M samples/s checksum=2629321.133
alea fillRayleigh scalar direct: 182.1 M samples/s checksum=2629357.351

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fillInverseGaussian"
alea fillInverseGaussian: 219.8 M samples/s checksum=1049168.644
alea fillInverseGaussian scalar direct: 243.7 M samples/s checksum=1048444.479
```

These rows are sanity checks for checksum/output preservation and broad
throughput range. They are not a new performance-closure claim.

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

$ zig build roadmapcheck toolingcheck rand-status-self-test
roadmapcheck ok
rand-status self-test ok
toolingcheck ok
```

## Result

S4-M1228 closes the remaining distribution staged-transform lane-store sweep:
no `dest[i + lane]` stores remain in `src/distributions.zig`, and the focused
tests cover both formula-equivalent slice transforms and an entropy-consuming
inverse-Gaussian transform. The whole product goal remains active under the next
S4-M1229 bar.
