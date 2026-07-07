# S4-M650 Rng Choice Fill Empty-Output Prevalidation

## Gap

`Rng` checked repeated choice fill helpers already treat empty output buffers as
no-ops before validating the choice set. The unchecked fill helpers asserted that
the source choice set was non-empty, so calls with an empty output buffer and an
empty choice set could still hit assertions despite being deterministic no-ops.

Unchecked fill helpers should return immediately for empty outputs before choice
validation, random-stream use, or assertions.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source:

- `/home/passchaos/Work/rand/src/seq/slice.rs` documents empty slice choice as
  `None`, while repeated sampling via iterators can be truncated to zero without
  drawing.
- Alea's fill APIs already use zero-length output as a deterministic no-op in
  checked variants and root wrappers.

S4-M650 aligns unchecked fill helpers with that no-op behavior.

## API Changed

`src/rng.zig` now prevalidates empty output buffers in:

- `fillChooseFrom`
- `fillChooseConstPtrFrom`
- `fillChoosePtrFrom`
- `fillChooseIndexFrom`
- `fillChooseIndexU32From`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Empty output buffers return immediately, even when the choice set or index
  length is empty.
- Non-empty empty-choice calls still follow existing checked/unchecked behavior.
- Singleton and random valid paths keep existing behavior and stream shape.

## Adoption and Documentation

- Focused rng tests cover empty-output no-op behavior for value, const-pointer,
  mutable-pointer, usize-index, and u32-index fills with empty inputs and no
  random-stream consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng tests:

```text
$ zig test src/rng.zig --test-filter "invalid facade choice helpers"
1/2 rng.test.invalid facade choice helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/rng.zig --test-filter "empty index choice helpers"
1/2 rng.test.empty index choice helpers do not consume random stream...OK
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
apicheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M650 is closed for the current bar: `Rng` unchecked repeated choice/index fill
helpers now treat empty output buffers as deterministic no-ops before validation,
random-stream use, or assertions. This is reliability and ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
