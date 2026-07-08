# S4-M960 Distribution Choose Sample Facade Direct Paths

## Gap

Distribution-layer `Choose.sample` and `Choose.sampleValue` facade helpers still
routed through direct-source or pointer sample wrappers. The facade helpers can
generate the uniform index through their facade `Rng` and map directly into item
storage while preserving singleton no-consume behavior and stream shape.

## Local `rand` Baseline

Local Rust `rand` slice-choice workflows sample references or copied values
directly from an RNG reference. Alea's distribution-layer `Choose` facade should
mirror that direct workflow without routing through direct-source wrappers.

## Implementation

- `src/distributions.zig` updates `Choose.sample` to handle singleton choices
  without consuming randomness and otherwise call `Rng.uintLessThanFrom(rng,
  usize, items.len)` directly before mapping to `*const T`.
- `src/distributions.zig` updates `Choose.sampleValue` to use the same direct
  facade-index generation and return a copied item directly.
- Focused tests cover distribution Choose pointer/value sample stream shape,
  singleton no-consume behavior, and facade/direct workflows.

## Validation

Focused distribution Choose test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M960 is closed for the current bar: distribution-layer `Choose.sample` and
`sampleValue` now avoid direct-source/pointer sample wrapper aliases while
preserving stream shape and singleton behavior. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
