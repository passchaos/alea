# S4-M790 Hinted Iterator Choice Inexact Metadata Reuse

## Gap

`seq.chooseIteratorHintedFrom` first asks for exact remaining metadata. When an
iterator provided only an inexact `sizeHint`, the helper fell back to
`chooseIteratorFrom`, which queried the same metadata path again before running
the stable reservoir algorithm. Iterators with observable or expensive inexact
metadata therefore saw duplicate size-hint probes.

## Local `rand` Baseline

Rust `IteratorRandom::choose` can use iterator size hints where available but
falls back to reservoir choice when exact size is unavailable. Alea's hinted API
can do the same while ensuring the inexact metadata path is observed once before
fallback.

## Implementation

- `src/seq.zig` factors the stable fallback reservoir loop into
  `chooseIteratorReservoirFrom`.
- `chooseIteratorHintedFrom` now prevalidates empty output types, queries exact
  remaining once, and falls back directly to `chooseIteratorReservoirFrom` when
  metadata is unavailable or inexact.
- Focused tests count inexact `sizeHint` calls and compare fallback stream shape
  against `chooseIteratorFrom` on a plain iterator.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "hinted iterator choice fallback reuses inexact metadata probe"
1/2 seq.test.hinted iterator choice fallback reuses inexact metadata probe...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M790 is closed for the current bar: seq hinted iterator choices now avoid a
duplicate inexact metadata probe on fallback paths while preserving reservoir
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
