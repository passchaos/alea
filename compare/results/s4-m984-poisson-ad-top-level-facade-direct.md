# S4-M984 Poisson Ahrens-Dieter Top-Level Facade Direct Paths

## Gap

Scalar top-level `poissonAhrensDieter` facade helpers still routed through their
`From` wrappers. S4-M981 and S4-M982 closed the reusable and top-level vector
Ahrens-Dieter facade paths, and S4-M983 made the general Poisson facade direct;
the scalar Ahrens-Dieter-specific facade helpers can now validate once and call
the cached Ahrens-Dieter sampler directly through facade `Rng`.

## Local `rand` Baseline

Local Rust `rand_distr 0.6.0` Poisson uses Ahrens-Dieter rejection for large
lambdas by calling `Distribution::sample(&mut rng)` on the supplied RNG
reference. Alea exposes `poissonAhrensDieter*` as an explicit large-lambda method
profile; its top-level facade helpers should use the facade `Rng` directly rather
than routing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `poissonAhrensDieter` to assert the large-lambda
  precondition and call `PoissonAhrensDieter.init(lambda).sample(rng)` directly.
- `src/distributions.zig` updates `poissonAhrensDieterChecked` to validate and
  call the direct facade sampler instead of routing through
  `poissonAhrensDieterCheckedFrom` / `poissonAhrensDieterFrom`.
- Focused tests cover plausible large-lambda moments and invalid checked facade
  no-consumption behavior.

## Validation

Focused scalar Poisson Ahrens-Dieter tests:

```text
$ zig test src/distributions.zig --test-filter "poisson large lambda has plausible moments"
1/2 distributions.test.poisson large lambda has plausible moments...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid poisson ahrens-dieter helper does not consume random stream"
1/2 distributions.test.invalid poisson ahrens-dieter helper does not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid distribution facade misc scalars do not consume random stream"
1/2 distributions.test.invalid distribution facade misc scalars do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M984 is closed for the current bar: scalar top-level Poisson Ahrens-Dieter
facade helpers now avoid direct-source wrapper aliases while preserving
large-lambda validation and checked invalid-parameter no-consume behavior. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
