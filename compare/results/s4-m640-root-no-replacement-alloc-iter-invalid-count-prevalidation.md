# S4-M640 Root No-Replacement Allocation/Iterator Invalid-Count Prevalidation

## Gap

Root unchecked unweighted no-replacement value/pointer allocation and iterator
helpers relied on debug assertions before delegating to checked variants when the
caller requested more samples than the item population length. In safe builds
that is a panic path, and in non-asserting builds the validation happens later in
the checked helper.

Alea's root system-entropy helpers should report invalid counts explicitly before
output allocation and before secure-engine construction. This keeps fallible Zig
APIs predictable while preserving the existing checked helper semantics.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source:

- `/home/passchaos/Work/rand/src/seq/index.rs` documents
  `rand::seq::index::sample` as panicking when `amount > length` and implements
  that panic before selecting an index-sampling algorithm.
- `/home/passchaos/Work/rand/src/seq/slice.rs` clamps slice
  `IndexedRandom::sample` requests to `min(amount, self.len())` before calling
  `index::sample`.

Alea keeps both styles available in Zig-native form: checked/root helpers return
`error.InvalidParameter` for exact-count requests that exceed the population,
while separate choose-style helpers keep saturating semantics where that is the
intended API. S4-M640 tightens the exact-count unchecked helpers so they return a
fallible error instead of relying on an assertion.

## API Changed

`src/root.zig` now prevalidates oversized sample amounts in:

- `sampleWithoutReplacement`
- `samplePtrs`
- `sampleMutPtrs`
- `sampleItemsIter`
- `samplePtrsIter`
- `sampleMutPtrsIter`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-count samples still return empty allocations/iterators before drawing
  entropy.
- Sample amounts larger than the population return `error.InvalidParameter`
  before output allocation and secure-engine construction.
- Full-range populations still return deterministic copies or pointer/index
  iterators before entropy is requested.
- Random valid paths still construct the root secure engine and delegate to the
  existing random sampling paths.

## Adoption and Documentation

- Focused root tests cover invalid-count failures before allocation/entropy,
  zero-output behavior, full-range deterministic paths, and failing-entropy
  random paths.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused root tests:

```text
$ zig test src/root.zig --test-filter "root random helpers"
1/3 root.test_0...OK
2/3 root.test.root random helpers use explicit system entropy...OK
3/3 root.test.root random helpers validate deterministic cases before entropy...OK
All 3 tests passed.
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
examplecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M640 is closed for the current bar: root unweighted no-replacement
value/pointer allocation and iterator helpers now reject oversized sample amounts
before output allocation and secure-engine construction in unchecked variants.
This is reliability and ergonomics work only; it does not resolve S4-M11 and is
not whole-goal completion evidence.
