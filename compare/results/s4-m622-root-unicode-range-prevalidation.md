# S4-M622 Root Unicode Scalar Range Prevalidation

## Gap

Root unchecked Unicode scalar range scalar/fill helpers converted validation
failures into the random path, which could request system entropy before invalid
Unicode scalar ranges or invalid code points were reported.

This milestone aligns unchecked Unicode scalar scalar/fill behavior with checked
helpers and batch prevalidation work.

## API Changed

`src/root.zig` now prevalidates:

- `unicodeScalarRangeLessThan`
- `unicodeScalarRangeAtMost`
- `fillUnicodeScalarRangeLessThan`
- `fillUnicodeScalarRangeAtMost`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Empty destinations still return before validating parameters or drawing
  entropy.
- Invalid Unicode ranges and invalid code points return their errors before
  secure-engine construction for scalar and non-empty fill requests.
- Collapsed deterministic valid paths still return/fill deterministic Unicode
  scalar values before entropy is requested.
- Random valid paths still construct the root secure engine and delegate to the
  existing random fill/scalar paths.

## Adoption and Documentation

- Focused root tests cover invalid-range/codepoint failures before entropy,
  empty-output behavior, deterministic collapsed paths, and failing-entropy
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

S4-M622 is closed for the current bar: root unchecked Unicode scalar range
scalar/fill helpers now prevalidate invalid parameters before secure-engine
construction. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
