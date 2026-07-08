# S4-M823 NegativeBinomial Fill Direct Sampler Loop

## Gap

S4-M822 tightened `Binomial.fillFrom` to call the underlying sampler directly.
`NegativeBinomial.fillFrom` still routed ordinary non-degenerate output through
`NegativeBinomial.sampleFrom`, adding a wrapper call for every filled item before
reaching `negativeBinomialFrom`.

## Local `rand_distr` Baseline

Negative-binomial bulk workflows repeatedly draw from the same parameterized
negative-binomial sampler. Alea's reusable `NegativeBinomial.fillFrom` should
preserve the same stream shape while calling the underlying sampler directly in
the fill loop.

## Implementation

- `src/distributions.zig` updates `NegativeBinomial.fillFrom` to call
  `negativeBinomialFrom(source, self.successes, self.p)` directly for
  non-degenerate outputs.
- Focused tests compare direct fills with a scalar `negativeBinomialFrom` loop
  under identical seeds, proving output values and stream position stay aligned.

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
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M823 is closed for the current bar: `NegativeBinomial.fillFrom` now avoids
per-item `NegativeBinomial.sampleFrom` wrapper calls for ordinary parameters and
calls the underlying `negativeBinomialFrom` sampler directly while preserving
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
