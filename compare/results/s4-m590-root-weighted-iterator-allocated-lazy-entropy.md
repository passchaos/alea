# S4-M590 Root Weighted-Iterator Allocated Sample Lazy Entropy

## Gap

The root weighted-iterator `sampleIteratorWeighted` and
`sampleIteratorWeightedChecked` helpers constructed a secure engine for any
non-zero request before delegating to `seq.sampleIteratorWeighted*`. Deterministic
streaming outcomes such as all-zero weights, one positive item, invalid weights
before random competition, or too few positive items in checked mode could
therefore fail only because system entropy was unavailable.

Rust `rand` exposes weighted iterator sampling through explicit RNG-bearing APIs.
Alea's root wrappers intentionally use system entropy, but they should request it
only when weighted-key competition is actually needed.

## API Changed

`src/root.zig` now implements lazy-entropy root sampling for:

- `sampleIteratorWeighted`
- `sampleIteratorWeightedChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- `amount == 0` returns an empty allocated slice before advancing the iterator or
  drawing entropy.
- All-zero or empty iterator input returns an empty allocated slice for
  unchecked non-empty requests.
- All-zero, empty, or insufficient-positive checked input returns
  `error.InvalidParameter`.
- A single positive item returns a one-value allocated slice before entropy is
  requested when the request can be satisfied.
- Invalid weights encountered before random competition begins fail before
  entropy is requested.
- Multi-positive cases that require weighted-key competition still construct the
  root secure engine and preserve the same Efraimidis-Spirakis weighted-key
  ordering semantics as `seq.sampleIteratorWeighted*`.

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
readmecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M590 is closed for the current bar: root weighted-iterator allocated sample
helpers now defer secure-engine construction until random competition is needed.
This is reliability and ergonomics work only; it does not resolve S4-M11 and is
not whole-goal completion evidence.
