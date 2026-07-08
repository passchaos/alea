# S4-M843 Erlang Reusable Fill Delegates to Gamma Fill

## Gap

Reusable `Erlang.fillFrom` still looped through `Erlang.sampleFrom` for every
non-degenerate output. Since `Erlang` stores a cached `Gamma` sampler with
integer shape and the same scale, bulk fills can reuse `Gamma.fillFrom` directly
and inherit recent shape-specific Gamma bulk paths, instead of paying an
Erlang-to-Gamma wrapper call per output.

## Local `rand_distr` Baseline

Local `rand_distr` exposes Gamma as the general family behind exponential and
integer-shape waiting-time distributions. Alea's Erlang sampler is a Zig-native
integer-shape wrapper over a cached Gamma sampler, so its bulk fill should
compose through that cached Gamma fill path while preserving repeated-sample
stream shape.

## Implementation

- `src/distributions.zig` updates `Erlang.fillFrom` to keep the scale-zero
  degenerate no-consume path, then call `self.gamma_sampler.fillFrom(source,
  dest)`.
- Focused tests compare reusable Erlang fills with equivalent `Gamma(shape,
  scale).fillFrom`, compare f32 fills with scalar `Erlang.sampleFrom` loops, and
  cover scale-zero no-consume behavior.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M843 is closed for the current bar: reusable `Erlang.fillFrom` now reuses the
cached `Gamma` sampler fill path instead of routing every output through
`Erlang.sampleFrom`, preserving stream shape while sharing Gamma optimized bulk
cases. This is reliability/ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
