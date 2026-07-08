# S4-M822 Binomial Fill Direct Sampler Loop

## Gap

`Binomial.fillFrom` handled degenerate all-zero/all-success fills directly, but
for ordinary parameters it still routed every output through `Binomial.sampleFrom`
before reaching the underlying `binomialFrom` sampler.

## Local `rand_distr` Baseline

Binomial bulk workflows repeatedly draw from the same parameterized binomial
sampler. Alea's reusable `Binomial.fillFrom` should preserve the same stream
shape while calling the underlying sampler directly in the fill loop.

## Implementation

- `src/distributions.zig` updates `Binomial.fillFrom` to call
  `binomialFrom(source, self.trials, self.p)` directly for non-degenerate
  outputs.
- Focused tests compare direct fills with a scalar `binomialFrom` loop under
  identical seeds, proving output values and stream position stay aligned.

## Validation

Focused distribution tests:

```text
$ zig test src/distributions.zig --test-filter "binomial sampler has plausible moments"
1/3 distributions.test.binomial sampler has plausible moments...OK
2/3 distributions.test.large binomial sampler has plausible moments...OK
3/3 root.test_0...OK
All 3 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
apicheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M822 is closed for the current bar: `Binomial.fillFrom` now avoids per-item
`Binomial.sampleFrom` wrapper calls for ordinary parameters and calls the
underlying `binomialFrom` sampler directly while preserving stream shape. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
