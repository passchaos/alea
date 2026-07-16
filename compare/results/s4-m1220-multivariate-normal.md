# S4-M1220 Full-Covariance Multivariate Normal

Date: 2026-07-16

## Goal

Raise Alea's multivariate feature bar beyond the local `rand_distr 0.6.0`
surface. The local Rust baseline provides `multi::Dirichlet`, while common
simulation, Bayesian, finance, and correlated-noise workloads also need
repeated normal vectors with a full covariance matrix.

## Implementation

`src/distributions.zig` adds:

- `MultivariateNormal(T)` and `multi.MultivariateNormal(T)`;
- construction from a finite mean vector and finite, symmetric,
  positive-semidefinite row-major covariance matrix;
- one-time O(d^3) Cholesky factorization into owned sampler state;
- allocation-free O(d^2) sampling after construction;
- support for positive-definite, singular, and all-zero covariance;
- allocation-returning, caller-owned, checked, direct-source, and flat batched
  sample APIs matching Alea's existing Multinomial/Dirichlet shapes;
- dimension, rank, degeneracy, mean, Cholesky-factor, variance, and covariance
  diagnostics;
- `clone` and explicit `deinit` ownership operations; and
- `InvalidCovariance` / `MultivariateNormalError` diagnostics.

The sampler writes independent standard-normal variates into the caller's
output buffer and applies `mean + L*z` in reverse row order. Reverse traversal
allows the output buffer to double as scratch, avoiding a second temporary
vector. Singular factors skip zero columns, and a rank-zero covariance returns
the mean without consuming randomness.

## Validation

Focused unit coverage checks:

- exact covariance reconstruction from the stored factor;
- owned constructor state and deep clone behavior;
- f32 and f64 construction;
- invalid length, non-finite, asymmetric, negative-diagonal, indefinite, and
  invalid zero-pivot covariance rejection;
- allocation failure cleanup;
- checked invalid-length no-consume behavior;
- singular perfect-correlation stream shape;
- rank-zero deterministic no-consume batches; and
- empirical three-dimensional means plus all nine covariance entries.

`tools/distcheck.zig` adds an independent 40,000-vector deterministic mean and
full-covariance gate. `examples/multivariate_sampling.zig` demonstrates owned,
caller-buffer, and batch correlated sampling. `bench/throughput.zig` adds
single-vector and flat-batch direct-source rows.

Commands run for this milestone:

```text
$ zig test src/distributions.zig -OReleaseFast --test-filter 'multivariate normal'
All 5 tests passed.

$ zig test src/distributions.zig -OReleaseFast
558 passed; 0 skipped; 1 failed.
Known pre-existing failure: root.test.root random helpers validate deterministic cases before entropy.

$ zig build -Doptimize=ReleaseFast distcheck --summary all
distcheck ok
Build Summary: 5/5 steps succeeded; 1/1 tests passed

$ zig build -Doptimize=ReleaseFast run-multivariate-sampling
multivariate normal mean: { 1, -2, 0.5 }
multivariate normal covariance(0, 1): 0.600

$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 67108864 'multivariate-normal'
alea multivariate-normal direct: 66.4 M vectors/s checksum=130908.637
alea multivariate-normal many direct: 226.2 M vectors/s checksum=43750.156

$ zig build -Doptimize=ReleaseFast apicheck --summary all
apicheck ok

$ zig build -Doptimize=ReleaseFast rand-status-self-test --summary all
rand-status self-test ok

$ zig build doccheck --summary all
doccheck success

$ git diff --check
```

`zig build -Doptimize=ReleaseFast test --summary all` was also run. It now
passes the new multivariate-normal and vector-distribution checks but still
stops on the pre-existing `root.test.root random helpers validate deterministic
cases before entropy` ReleaseFast failure; temporarily checking out HEAD
`src/root.zig` reproduced that same failure, so it is tracked as unrelated to
this S4-M1220 feature change.

## Scope

This closes S4-M1220's concrete multivariate feature bar. It does not claim the
long-term product mission is permanently complete. S4-M1221 remains open for
exact/default dense SIMD research, broader non-WASI execution, longer
validation, or newly discovered core random-workflow gaps.
