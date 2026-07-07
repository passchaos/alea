# S4-M641 Root Iterator Exact-Short Prevalidation

## Gap

Root checked iterator sampling helpers previously discovered too-short iterators
only after allocating output buffers and consuming iterator items. Weighted
checked iterator helpers could also allocate temporary state before proving an
exact-known iterator could never satisfy the request.

When an iterator advertises an exact remaining count through `sizeHint`, `len`,
or `remaining`, checked helpers should reject impossible requests before output
allocation, before secure-engine construction, and before iterator consumption.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source:

- `/home/passchaos/Work/rand/src/seq/iterator.rs` documents that
  `IteratorRandom` uses `Iterator::size_hint` for choose-style performance, and
  that iterator sampling returns fewer than the requested amount when the
  iterator contains insufficient elements.
- Alea exposes both saturating iterator helpers and checked exact-count helpers.
  The checked helpers return `error.InvalidParameter` for insufficient input.

S4-M641 keeps Alea's Zig-native checked semantics and improves them beyond a
late failure: exact-short iterators fail before allocation/entropy and without
advancing the iterator.

## API Changed

`src/root.zig` now uses exact iterator metadata to prevalidate checked paths:

- `sampleIteratorChecked`
- `sampleIteratorIntoChecked`
- `sampleIteratorFillChecked` (via `sampleIteratorIntoChecked`)
- `sampleIteratorArrayChecked`
- `sampleIteratorWeightedChecked`
- `sampleIteratorWeightedIntoChecked`
- `sampleIteratorWeightedArrayChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-output checked calls still return before checking iterator length.
- Exact-known short iterators return `error.InvalidParameter` before output
  allocation, secure-engine construction, or iterator advancement.
- Unknown-length iterators keep the existing late checked failure behavior.
- Valid exact and random paths still use the existing reservoir / weighted
  iterator algorithms.

## Adoption and Documentation

- Focused root tests cover exact-short failures before allocation/entropy and
  before iterator consumption, plus the existing empty, short, deterministic,
  and failing-entropy iterator paths.
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
roadmapcheck ok
readmecheck ok
examplecheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M641 is closed for the current bar: root checked iterator sample helpers now
reject exact-known insufficient input before output allocation, secure-engine
construction, and iterator consumption. This is reliability and ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
