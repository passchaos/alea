# S4-M727 Choice Pointer Iterator Aliases

## Gap

Distribution-layer `Choose` exposes explicit `ptrIter*` and checked pointer
iterator aliases alongside its canonical pointer iterator behavior. Reusable
`seq.Choice` only exposed generic `iter*` pointer iterators, leaving pointer
iterator discovery less consistent with `Choose`, value iterators, and checked
alias naming.

Reusable `Choice` should expose explicit pointer iterator aliases that preserve
existing pointer iterator stream shape and add checked aliases for API
consistency.

## Local `rand` Baseline

The local Rust `rand` checkout exposes slice choice workflows centered on
reference output. Alea's reusable `Choice(T)` already provides pointer iterators
through `iter*`; explicit `ptrIter*` aliases make that reference-oriented path
more discoverable while retaining Zig-native pointer/value/index output families.

## API Added

`src/seq.zig` adds pointer iterator aliases to `Choice(T)`:

- `Choice(T).ptrIter`
- `Choice(T).ptrIterFrom`
- `Choice(T).ptrIterChecked`
- `Choice(T).ptrIterCheckedFrom`

The aliases delegate to existing `iter*` behavior. `docs/api-reference.md` lists
the new public symbols. Existing APIs are unchanged.

Deterministic behavior is explicit:

- `ptrIterFrom` preserves `iterFrom` scalar and fill stream shape.
- Checked pointer iterator aliases do not introduce new failure modes because
  non-empty `Choice` construction already validates the item slice.

## Adoption and Documentation

- Focused seq tests compare `ptrIterFrom` and `iterFrom` scalar draws and fill
  output/stream shape.
- Tests compare checked and unchecked pointer iterator aliases for stream parity.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.
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
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M727 is closed for the current bar: reusable `Choice` now has explicit pointer
iterator aliases and checked aliases that preserve existing pointer iterator
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
