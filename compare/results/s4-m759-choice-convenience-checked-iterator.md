# S4-M759 Choice Convenience Checked Iterator

## Gap

Recent milestones added focused coverage for checked iterator constructors on
choice and weighted-choice reusable samplers. The unweighted convenience helpers
`chooseIterChecked` and `chooseIterCheckedFrom` still lacked explicit
stream-shape comparison against reusable `Choice.iterFrom`.

## Local `rand` Baseline

The local Rust choice APIs are iterator-oriented. Alea exposes convenience
helpers and reusable `Choice`; checked convenience helpers should preserve the
same deterministic stream shape as the reusable sampler.

## Coverage Added

`src/seq.zig` now tests both:

- `chooseIterCheckedFrom` vs `Choice.iterFrom`;
- `chooseIterChecked` facade vs `Choice.iterFrom`.

No public API changed.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M759 is closed for the current bar: unweighted checked convenience choice
iterators now have explicit stream-shape evidence against reusable `Choice`. This
is reliability/validation work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
