# S4-M591 Root Weighted-Iterator Into Lazy Entropy

## Gap

The root weighted-iterator `sampleIteratorWeightedInto` and
`sampleIteratorWeightedIntoChecked` helpers constructed a secure engine for any
non-empty output before delegating to `seq.sampleIteratorWeightedInto*`.
Deterministic streaming outcomes such as all-zero weights, one positive item,
invalid weights before random competition, too few positive items in checked
mode, or scratch-length failures could therefore be tied to system entropy.

Alea's root wrappers intentionally use system entropy, but they should request it
only when weighted-key competition is actually needed.

## API Changed

`src/root.zig` now implements lazy-entropy root sampling for:

- `sampleIteratorWeightedInto`
- `sampleIteratorWeightedIntoChecked`

`sampleIteratorFill` aliases are unaffected because they are unweighted
reservoir helpers. The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- `out.len == 0` returns before advancing the iterator or drawing entropy.
- Scratch-key length mismatches return `error.LengthMismatch` before entropy.
- All-zero or empty iterator input returns `0` for unchecked non-empty outputs.
- All-zero, empty, or insufficient-positive checked input returns
  `error.InvalidParameter`.
- A single positive item fills one slot before entropy is requested when the
  request can be satisfied.
- Invalid weights encountered before random competition begins fail before
  entropy is requested.
- Multi-positive cases that require weighted-key competition still construct the
  root secure engine and preserve the same Efraimidis-Spirakis weighted-key
  ordering semantics as `seq.sampleIteratorWeightedInto*`.

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
examplecheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M591 is closed for the current bar: root weighted-iterator into helpers now
defer secure-engine construction until random competition is needed. This is
reliability and ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
