# S4-M976 Hypergeometric Sampler Facade Direct Paths

## Gap

Reusable `Hypergeometric.sample` and `Hypergeometric.fill` facade helpers still
routed through their direct-source wrappers. The sampler already stores the
selected method, so facade sample/fill can dispatch directly to the constant,
draw-loop, inverse-transform, or rejection-acceptance path through the facade
`Rng` while preserving stream shape.

## Local `rand` Baseline

Local Rust `rand_distr` hypergeometric workflows sample directly from an RNG
reference. Alea's reusable hypergeometric sampler chooses the method at
construction time and should expose facade sample/fill methods that dispatch
through that method without a direct-source wrapper hop.

## Implementation

- `src/distributions.zig` updates `Hypergeometric.sample` to switch on the stored
  method and sample directly through the facade `Rng`.
- `src/distributions.zig` updates `Hypergeometric.fill` to dispatch directly to
  constant fill, draw-loop fill, inverse-transform sampling, or
  rejection-acceptance sampling through the facade `Rng`.
- Focused tests cover hypergeometric plausible behavior and invalid/no-consume
  paths.

## Validation

Focused Hypergeometric tests:

```text
$ zig test src/distributions.zig --test-filter "negative-binomial and hypergeometric samplers have plausible moments"
1/2 distributions.test.negative-binomial and hypergeometric samplers have plausible moments...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid scalar distribution helpers do not consume random stream"
1/2 distributions.test.invalid scalar distribution helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
toolingcheck ok
apicheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M976 is closed for the current bar: reusable Hypergeometric facade sample/fill
helpers now avoid direct-source wrapper aliases while preserving method-specific
stream shape and degenerate behavior. This is reliability/ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
