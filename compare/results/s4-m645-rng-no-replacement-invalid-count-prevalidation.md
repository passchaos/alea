# S4-M645 Rng No-Replacement Invalid-Count Prevalidation

## Gap

The root no-replacement helpers already reject oversized sample counts before
allocation and secure-engine construction. The method/direct `Rng` layer still
relied on debug assertions in unchecked no-replacement value sampling, so direct
callers could hit an assertion instead of receiving a fallible Zig error.

`Rng` no-replacement helpers should report invalid counts explicitly before
allocation and before random-stream use.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source:

- `/home/passchaos/Work/rand/src/seq/index.rs` documents exact index sampling as
  panicking when `amount > length`.
- `/home/passchaos/Work/rand/src/seq/slice.rs` exposes saturating slice sampling
  for `IndexedRandom::sample`.

Alea keeps Zig-native fallible exact-count semantics for `Rng` no-replacement
value sampling: invalid exact-count requests return `error.InvalidParameter`
instead of panicking or relying on assertions.

## API Changed

`src/rng.zig` now prevalidates oversized counts in:

- `Rng.sampleWithoutReplacement`
- `sampleWithoutReplacementFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Oversized sample counts return `error.InvalidParameter` before any allocation
  or random-stream use.
- Zero-count requests still return empty allocations before building a pool.
- Valid calls keep the existing pool/swap-remove sampling behavior.
- Checked wrappers continue to return the same error for the same invalid inputs.

## Adoption and Documentation

- Focused rng tests cover invalid-count failures before allocation and random
  stream consumption for both the method and direct `From` helper.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng tests:

```text
$ zig test src/rng.zig --test-filter "invalid unchecked sample without replacement"
1/2 rng.test.invalid unchecked sample without replacement fails before allocation and stream use...OK
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
readmecheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M645 is closed for the current bar: `Rng` unchecked no-replacement value
sampling now rejects oversized sample counts before allocation and random-stream
use. This is reliability and ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
