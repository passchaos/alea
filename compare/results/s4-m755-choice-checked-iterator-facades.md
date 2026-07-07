# S4-M755 Choice Checked Iterator Facades

## Gap

S4-M754 fixed and covered checked facade iterators for weighted index samplers.
The choice samplers (`Choose`, `Choice`, and `WeightedChoice`) already had
checked value/index iterator facade constructors, but focused tests mostly used
the direct-source `*CheckedFrom` variants.

The facade checked iterator constructors should have explicit stream-shape
coverage so future refactors cannot repeat the facade/direct payload mismatch
class of bug.

## Local `rand` Baseline

The local Rust choice APIs are iterator-oriented. Alea exposes both facade `Rng`
and direct-source checked iterator constructors; both entry points should remain
stable and equivalent for deterministic stream shape.

## Coverage Added

Focused tests now construct and compare facade checked iterators against direct
checked iterators for:

- distribution-layer `Choose.valueIterChecked`, `indexIterChecked`, and
  `indexIterU32Checked`;
- reusable `Choice.valueIterChecked`, `indexIterChecked`, and
  `indexIterU32Checked`;
- reusable `WeightedChoice.valueIterChecked`, `indexIterChecked`, and
  `indexIterU32Checked`.

No public API changed.

## Validation

Focused sequence and distribution tests:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
readmecheck ok
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M755 is closed for the current bar: checked value/index iterator facade
constructors for `Choose`, `Choice`, and `WeightedChoice` now have explicit
facade/direct stream-shape coverage. This is reliability/validation work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
