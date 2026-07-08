# S4-M824 Hypergeometric Fill Direct Method Dispatch

## Gap

`Hypergeometric.fillFrom` handled constant distributions directly, but for all
non-constant methods it routed every output through `Hypergeometric.sampleFrom`,
which re-switched on the selected method for every item.

## Local `rand_distr` Baseline

Hypergeometric sampling picks an implementation strategy from the distribution
parameters, then repeatedly draws using that strategy. Alea's reusable
`Hypergeometric.fillFrom` should switch once per fill and call the selected
method sampler directly while preserving scalar stream shape.

## Implementation

- `src/distributions.zig` updates `Hypergeometric.fillFrom` to switch once on the
  selected method and run the matching draw-loop, inverse-transform, or
  rejection-acceptance sampler directly for each output.
- Focused tests compare direct fills with a scalar `sampleFrom` loop under
  identical seeds, proving output values and stream position stay aligned.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "negative-binomial and hypergeometric samplers"
1/2 distributions.test.negative-binomial and hypergeometric samplers have plausible moments...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
readmecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M824 is closed for the current bar: `Hypergeometric.fillFrom` now avoids
per-item `sampleFrom` method dispatch for non-constant distributions and calls
the selected method sampler directly while preserving stream shape. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
