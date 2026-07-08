# S4-M821 MappedSampler Fill Direct Mapper Application

## Gap

Distribution `MappedSampler.fillFrom` still routed each output slot through
`MappedSampler.sampleFrom`, adding a wrapper call around base sampler sampling and
mapper application for every filled item.

## Local `rand` Baseline

Rust `Distribution::map` applies a mapping closure to outputs from an underlying
distribution. Alea's mapped sampler fill path should preserve the same stream
shape while applying the mapper directly to each base sampler output in the bulk
fill loop.

## Implementation

- `src/distributions.zig` updates `MappedSampler.fillFrom` to call
  `Rng.sampleFrom(source, In, self.sampler)` and `applyMapper` directly per slot,
  avoiding the intermediate `self.sampleFrom` wrapper.
- Focused tests now compare both mapped fill output values and random stream
  position against manual base-sampler mapping.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "mapped samplers transform reusable sampler outputs"
1/2 distributions.test.mapped samplers transform reusable sampler outputs...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
toolingcheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M821 is closed for the current bar: mapped sampler fills now avoid per-item
`MappedSampler.sampleFrom` wrapper calls and apply the mapper directly to base
sampler outputs while preserving stream shape. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
