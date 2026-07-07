# S4-M665 Rng Sampler Fill Empty-Output Prevalidation

## Gap

Generic sampler fill helpers delegated to sampler-provided `fill` / `fillFrom`
hooks before checking whether the destination slice was empty. Empty output
buffers should be deterministic no-ops regardless of whether a sampler offers a
bulk fill hook.

Unchecked sampler fill helpers should return immediately for empty outputs before
invoking sampler hooks, random-stream use, or sampler assertions.

## Local `rand` Baseline

The local Rust `rand` checkout exposes `Distribution::sample_iter` and slice fill
patterns where taking or filling zero outputs is semantically a no-op. Alea's
samplers are Zig-native and may expose optimized `fill` / `fillFrom` hooks; this
milestone makes the common zero-output contract explicit at the `Rng` wrapper
boundary.

## API Changed

`src/rng.zig` now prevalidates empty output buffers in:

- `fillSample`
- `fillSampleFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Empty output buffers return immediately without invoking sampler fill hooks.
- Non-empty sampler fills keep existing hook dispatch and stream shape.
- `sampleIter(...).fill(empty)` and `sampleIterFrom(...).fill(empty)` inherit
  the same no-op behavior through the shared fill helpers.

## Adoption and Documentation

- Focused rng tests cover empty facade/direct sampler fills and iterator fills
  with rejecting sampler fill hooks, proving no hook invocation and no
  random-stream consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng test:

```text
$ zig test src/rng.zig --test-filter "empty sampler fills do not call sampler fill hooks"
1/2 rng.test.empty sampler fills do not call sampler fill hooks...OK
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
apicheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M665 is closed for the current bar: `Rng` generic sampler fill helpers now
treat empty output buffers as deterministic no-ops before sampler hook dispatch,
random-stream use, or assertions. This is reliability and ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
