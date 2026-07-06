# S4-M471 Root One-Shot Caller-Owned Fill Helpers

## Gap

The root module exposed system-entropy one-shot scalar helpers (`random`,
`randomRange`, `randomBool`, `randomRatio`) and a generic `fill`, but callers who
wanted caller-owned range/probability buffers had to manually construct a secure
engine and then use `Rng.fillRange`, `Rng.fillChance`, or `Rng.fillRatio`. Local
Rust makes quick random/fill workflows easy through `rng()` plus `fill` and range
helpers; Alea should keep the Zig-native explicit-`std.Io` model while reducing
that boilerplate.

## API Added

`src/root.zig` now exposes:

- `fillRange`
- `fillRangeChecked`
- `fillRangeAtMost`
- `fillRangeAtMostChecked`
- `fillRandomBool`
- `fillRandomBoolChecked`
- `fillRandomRatio`
- `fillRandomRatioChecked`

The helpers draw system entropy only when output actually needs random data.
Empty slices, collapsed ranges, and degenerate probability/ratio cases return
without touching the entropy source, matching existing deterministic root helper
behavior.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `rangeFill`, `inclusiveFill`, `boolFill`,
  and `ratioFill` in the root random helper output.
- `tools/examplecheck.zig` guards those example tokens.
- `docs/api-reference.md` lists the new root public symbols.
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

Runnable example and guard checks:

```text
$ zig build run-basic
root random helpers: random=21513, range=4, bool=false, fill={ 119, 87, 30, 16 }, rangeFill={ 5, 3, 1, 2 }, inclusiveFill={ 5, 2, 6, 6 }, boolFill={ false, true, false, false, false, false, false, false }, ratioFill={ true, false, false, false, true, false, false, true }, iterNext=78, iterUnbounded=true
```

```text
$ zig build examplecheck
examplecheck ok
```

```text
$ zig build apicheck
apicheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

Broader native test gate:

```text
$ zig build test
readmecheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
```

```text
$ git diff --check
```

## Result

S4-M471 is closed for the current bar: root system-entropy callers can fill
caller-owned range and probability buffers without manually constructing a secure
engine. This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
