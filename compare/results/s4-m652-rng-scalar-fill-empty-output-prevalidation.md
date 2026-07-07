# S4-M652 Rng Scalar Fill Empty-Output Prevalidation

## Gap

`Rng` checked scalar fill helpers already treat empty output buffers as no-ops
before validating ranges or probabilities. The unchecked scalar range/probability
fill helpers asserted parameter validity before checking output length, so empty
outputs with invalid parameters could still trigger assertions despite being
no-ops.

Unchecked scalar fill helpers should return immediately for empty outputs before
range/probability validation, random-stream use, or assertions.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source. `rand` range and
probability APIs assert/panic or return construction errors for invalid
parameters, while iterator/fill style workflows that request zero outputs are
semantically no-ops. Alea checked helpers already model this no-op behavior for
empty outputs; S4-M652 applies the same deterministic behavior to unchecked fill
helpers.

## API Changed

`src/rng.zig` now prevalidates empty output buffers in:

- `fillRangeFrom`
- `fillRangeAtMostFrom`
- `fillUintLessThanFrom`
- `fillChanceFrom`
- `fillRatioFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Empty output buffers return immediately, even with invalid range/probability
  parameters.
- Non-empty invalid-parameter unchecked calls keep existing assertion behavior.
- Collapsed valid ranges and endpoint probabilities keep existing deterministic
  fill behavior.
- Random valid paths keep existing stream shape.

## Adoption and Documentation

- Focused rng tests cover empty-output no-op behavior for invalid exclusive
  ranges, inclusive ranges, uint upper bounds, floating ranges, probabilities,
  and ratios with no random-stream consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng tests:

```text
$ zig test src/rng.zig --test-filter "invalid facade range helpers"
1/2 rng.test.invalid facade range helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

No output.

Broader native test gate:

```text
$ zig build test
roadmapcheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M652 is closed for the current bar: `Rng` unchecked scalar range/probability
fill helpers now treat empty output buffers as deterministic no-ops before
validation, random-stream use, or assertions. This is reliability and ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
