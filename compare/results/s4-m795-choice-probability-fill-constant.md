# S4-M795 Uniform Choice Probability Fill Constant Path

## Gap

Reusable `Choice(T).ProbabilityIterator.fill` and distribution-layer
`Choose(T).ProbabilityIterator.fill` enumerate a uniform probability distribution.
Before this milestone their fill methods computed `remaining()` and then called
`next()` once per slot, which in turn called `probability()` even though every
remaining probability is the same constant value.

## Local `rand` Baseline

Rust choice APIs expose uniform selection over a slice. Alea adds explicit
probability introspection and can fill caller-owned probability buffers via a
Zig-native constant path for uniform choices.

## Implementation

- `src/seq.zig` updates `Choice(T).ProbabilityIterator.fill` to write the
  constant `1 / len` probability directly with `@memset` and advance the iterator
  index once.
- `src/distributions.zig` applies the same constant fill path to
  distribution-layer `Choose(T).ProbabilityIterator.fill`.
- Existing probability iterator tests cover partial `next()` followed by `fill`,
  remaining/size-hint updates, and end-of-iterator behavior.

## Validation

Focused sequence/distribution tests:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M795 is closed for the current bar: uniform choice probability iterator fills
now use a direct constant fill path while preserving iterator state and output
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
