# S4-M839 ChiSquared Reusable Fill Delegates to Gamma Fill

## Gap

Reusable `ChiSquared.fillFrom` still looped through `ChiSquared.sampleFrom` for
every non-degenerate output. Since `ChiSquared` stores a cached `Gamma` sampler
with `shape = dof / 2` and `scale = 2`, this missed the shared `Gamma.fillFrom`
paths added in recent milestones, including the shape-one standard-exponential
bulk staging used for `dof == 2`.

## Local `rand_distr` Baseline

Local `rand_distr` implements chi-squared sampling through Gamma/Exp primitives:
degenerate zero degrees of freedom are point masses, `dof == 1` is a squared
standard normal, and other degrees of freedom use Gamma composition. Alea's
reusable `ChiSquared` already caches that Gamma sampler, so bulk fills can
compose through `Gamma.fillFrom` directly instead of repeating a wrapper call per
output.

## Implementation

- `src/distributions.zig` updates `ChiSquared.fillFrom` to delegate to
  `self.gamma_sampler.fillFrom(source, dest)`. This preserves dof-zero
  no-consume behavior through the cached degenerate Gamma and lets dof-two reuse
  the shape-one Gamma standard-exponential staging path.
- Focused tests compare dof-two `ChiSquared.fillFrom` with an equivalent cached
  `Gamma(1, 2).fillFrom`, compare f32 reusable fills with scalar
  `ChiSquared.sampleFrom` loops, and cover dof-zero no-consume behavior.

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
examplecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M839 is closed for the current bar: reusable `ChiSquared.fillFrom` now reuses
the cached `Gamma` sampler fill path instead of routing every output through
`ChiSquared.sampleFrom`, preserving stream shape while sharing Gamma's optimized
bulk cases. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
