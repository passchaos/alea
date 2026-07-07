# S4-M589 Root Weighted-Iterator Array Lazy Entropy

## Gap

The root weighted-iterator `sampleIteratorWeightedArray` and
`sampleIteratorWeightedArrayChecked` helpers constructed a secure engine for any
non-zero fixed-size request before delegating to `seq.sampleIteratorWeightedArray*`.
That meant deterministic streaming outcomes such as all-zero weights, a single
positive item, or too few positive items still failed when system entropy was
unavailable.

Rust `rand` exposes weighted iterator sampling through explicit RNG-bearing
APIs. Alea's root wrappers intentionally use system entropy, but they should
only request it when random competition between candidates is actually needed.

## API Changed

`src/root.zig` now implements lazy-entropy root sampling for:

- `sampleIteratorWeightedArray`
- `sampleIteratorWeightedArrayChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- `N == 0` returns an empty array before advancing the iterator or drawing
  entropy.
- All-zero or empty iterator input returns `null` for unchecked non-empty arrays.
- All-zero, empty, or insufficient-positive checked input returns
  `error.InvalidParameter`.
- A single positive item with `N == 1` returns that item before entropy is
  requested.
- Invalid weights encountered before random competition begins fail before
  entropy is requested.
- Multi-positive cases that require weighted-key competition still construct the
  root secure engine and preserve the same Efraimidis-Spirakis weighted-key
  ordering semantics as `seq.sampleIteratorWeightedArray*`.

## Adoption and Documentation

- Focused root tests cover deterministic no-entropy behavior for the new lazy
  paths and continue to cover failing-entropy random paths.
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

Broader native test gate:

```text
$ zig build test
readmecheck ok
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M589 is closed for the current bar: root weighted-iterator fixed-size array
helpers now defer secure-engine construction until random competition is needed.
This is reliability and ergonomics work only; it does not resolve S4-M11 and is
not whole-goal completion evidence.
