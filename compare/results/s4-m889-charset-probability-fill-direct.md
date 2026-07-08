# S4-M889 Charset Probability Iterator Direct Fill

## Gap

ASCII `Charset.ProbabilityIterator.fill` and `UnicodeCharset.ProbabilityIterator.fill`
still filled caller buffers by repeatedly calling `next()`, adding per-slot
optional lookup and index updates even though uniform charset probabilities are a
known constant.

## Local `rand` Baseline

Local `rand` charset/string workflows are uniform over the selected character
set. Alea exposes probability iterators for diagnostics; since every active
charset entry has probability `1 / len`, iterator fills can write that constant
probability directly and advance the index once while preserving iterator
semantics.

## Implementation

- `src/ascii.zig` updates both ASCII and Unicode charset probability iterator
  fills to compute the fill count, `@memset` the constant probability, and advance
  `index` by the filled count instead of calling `next()` for every slot.
- Focused tests cover ASCII probability iterator fill behavior and Unicode
  probability iterator diagnostics through existing charset tests.

## Validation

Focused ASCII tests:

```text
$ zig test src/ascii.zig --test-filter "ascii charset fills requested length"
1/2 ascii.test.ascii charset fills requested length...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "unicode charset strings sample from scalar choices"
1/2 ascii.test.unicode charset strings sample from scalar choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
apicheck ok
toolingcheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M889 is closed for the current bar: ASCII and Unicode charset probability
iterator fills now avoid per-slot `next()` calls while preserving iterator state
and exact uniform probabilities. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
