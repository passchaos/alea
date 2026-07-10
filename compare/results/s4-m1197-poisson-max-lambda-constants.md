# S4-M1197 Poisson Max-Lambda Public Constants

## Gap

The local `rand_distr 0.6.0` public surface exposes the finite Poisson upper
bound as an associated constant:

```text
$ grep -n "MAX_LAMBDA" ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/poisson.rs
185:    pub const MAX_LAMBDA: f64 = 1.844e19;
```

S4-M1155 aligned Alea's validation semantics with that bound, but the threshold
remained only an internal implementation constant. That left a small public
surface diagnostics gap for callers that want to echo, document, or validate the
same `rand_distr::Poisson::MAX_LAMBDA` threshold without duplicating the literal.

## Change

`src/distributions.zig` now exposes the threshold through Zig-native and
Rust-discoverable names:

- top-level `poisson_max_lambda` and `poissonMaxLambda`;
- reusable sampler associated constants `Poisson.max_lambda` and
  `Poisson.MAX_LAMBDA`;
- vector reusable sampler constants `VectorPoisson(VectorType).max_lambda` and
  `VectorPoisson(VectorType).MAX_LAMBDA`.

The Poisson validation guard now uses the public top-level constant, while
existing checked/unchecked stream behavior remains unchanged. Focused tests
assert the exact constant value and all aliases.

Docs and comparison evidence were refreshed in `docs/api-reference.md`,
`docs/core-guide.md`, `compare/results/distribution-parity-matrix.md`, and the
local `rand_distr` public-surface manifest.

## Validation

```text
$ zig test src/distributions.zig --test-filter "poisson max lambda"
1/3 distributions.test.poisson max lambda guard matches local rand_distr...OK
2/3 distributions.test.poisson max lambda constants mirror local rand_distr...OK
3/3 root.test_0...OK
All 3 tests passed.

$ zig build apicheck
apicheck ok

$ zig build rand-status-self-test
rand-status self-test ok

$ zig build toolingcheck
toolingcheck ok

$ zig build roadmapcheck
roadmapcheck ok

$ zig build validate-local
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
runtimecheck ok: no additional runtime runner available
```

## Result

S4-M1197 is closed for the current bar: Alea now exposes the local
`rand_distr::Poisson::MAX_LAMBDA` threshold as public diagnostics while
preserving the existing max-lambda validation and zero-lambda point-mass
extension. This is a local Rust public-surface diagnostics closure, not
whole-goal completion; S4-M1198 remains active.
