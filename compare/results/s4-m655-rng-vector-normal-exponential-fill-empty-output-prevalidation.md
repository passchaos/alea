# S4-M655 Rng Vector Normal/Exponential Fill Empty-Output Prevalidation

## Gap

S4-M653 aligned vector range/probability unchecked fill helpers with checked/root
behavior: empty output buffers are deterministic no-ops before parameter
validation. Vector normal and exponential unchecked fill helpers still asserted
parameter validity before checking output length, so empty outputs with invalid
parameters could trigger assertions despite being no-ops.

Unchecked vector normal/exponential fill helpers should return immediately for
empty outputs before parameter validation, random-stream use, or assertions.

## Local `rand_distr` Baseline

The local Rust `rand_distr` checkout remains the baseline comparison source for
normal/exponential distributions. Its constructors validate invalid standard
deviation or rate parameters, while caller workflows that request zero samples
are semantically no-ops. Alea checked helpers already model this no-op behavior
for empty outputs; S4-M655 applies the same deterministic behavior to unchecked
vector fill helpers.

## API Changed

`src/rng.zig` now prevalidates empty output buffers in:

- `fillVectorNormalFrom`
- `fillVectorExponentialFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Empty output buffers return immediately, even with invalid vector
  normal/exponential parameters.
- Non-empty invalid-parameter unchecked calls keep existing assertion behavior.
- Deterministic zero-standard-deviation and infinite-rate paths keep existing
  behavior.
- Random valid paths keep existing stream shape.

## Adoption and Documentation

- Focused rng tests cover empty-output no-op behavior for invalid vector normal
  and exponential parameters with no random-stream consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng tests:

```text
$ zig test src/rng.zig --test-filter "invalid facade checked fills"
1/2 rng.test.invalid facade checked fills do not consume random stream...OK
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
readmecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M655 is closed for the current bar: `Rng` unchecked vector normal/exponential
fill helpers now treat empty output buffers as deterministic no-ops before
validation, random-stream use, or assertions. This is reliability and ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
