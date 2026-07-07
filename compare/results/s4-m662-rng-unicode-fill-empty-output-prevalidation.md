# S4-M662 Rng Unicode Scalar Fill Empty-Output Prevalidation

## Gap

Checked Unicode scalar range fill helpers already treat empty output buffers as
no-ops before validating scalar/range parameters. The unchecked range fill helpers
validated via `catch unreachable` before checking output length, so empty outputs
with invalid parameters could still trigger assertions despite being no-ops.

Unchecked Unicode scalar range fill helpers should return immediately for empty
outputs before scalar/range validation, random-stream use, or assertions.

## Local `rand` Baseline

The local Rust `rand` checkout exposes `UniformChar` for Unicode `char` ranges in
`src/distr/uniform_other.rs`. Invalid ranges are rejected before sampling, while
zero-output fill/iterator-style workflows are semantically no-ops. Alea checked
helpers already model this no-op behavior for empty outputs; S4-M662 applies the
same deterministic behavior to unchecked Unicode scalar range fill helpers.

## API Changed

`src/rng.zig` now prevalidates empty output buffers in:

- `fillUnicodeScalarRangeLessThanFrom`
- `fillUnicodeScalarRangeAtMostFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Empty output buffers return immediately, even with invalid scalar/range
  parameters.
- Non-empty invalid-parameter unchecked calls keep existing assertion behavior.
- Collapsed valid Unicode scalar ranges keep existing deterministic fill
  behavior.
- Random valid paths keep existing stream shape.

## Adoption and Documentation

- Focused rng tests cover empty-output no-op behavior for invalid exclusive and
  inclusive Unicode scalar ranges with no random-stream consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng test:

```text
$ zig test src/rng.zig --test-filter "invalid unicode scalar ranges do not consume random stream"
1/2 rng.test.invalid unicode scalar ranges do not consume random stream...OK
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
toolingcheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M662 is closed for the current bar: `Rng` unchecked Unicode scalar range fill
helpers now treat empty output buffers as deterministic no-ops before validation,
random-stream use, or assertions. This is reliability and ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
