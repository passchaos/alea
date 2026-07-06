# S4-M529 Root One-Shot Index-Weighted Value Choice Helpers

## Gap

Root one-shot weighted value choice helpers covered concrete weight slices.
Index-weighted value selection from an item slice plus comptime index-weight
function still required manually constructing a secure engine and calling
`seq.chooseWeightedByIndex*` directly.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedByIndex`
- `chooseWeightedByIndexChecked`

Empty/all-zero weights return `null` for the nullable helper; the checked helper
rejects them. Single-positive weights return deterministically without drawing
entropy. Invalid weights fail before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndexValue=` in root weighted value
  helper output.
- `tools/examplecheck.zig` guards that example token.
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

Runnable example excerpt showing the guarded by-index value token:

```text
$ zig build run-basic
root weighted value helpers: value=green, byIndexValue=green, fill=[blue, blue, blue, blue], array=[red, blue, blue, green], batch=[blue, blue, blue, blue]
```

```text
$ zig build examplecheck
examplecheck ok
```

```text
$ zig build apicheck
apicheck ok
```

Roadmap guard command was run with an explicit status echo because this cached
build step produced no stdout in this run:

```text
$ zig build roadmapcheck; echo roadmap_status:$?
roadmap_status:0
```

```text
$ git diff --check; echo diffcheck_status:$?
diffcheck_status:0
```

Broader native test gate:

```text
$ zig build test
toolingcheck ok
apicheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M529 is closed for the current bar: root system-entropy callers can choose
values from an item slice and comptime index-weight function without manually
constructing a secure engine. This is API ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
