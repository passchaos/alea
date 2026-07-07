# S4-M779 Stable Iterator Choice Exact-Count End-Probe Avoidance

## Gap

S4-M778 tightened exact-count weighted iterator choices. The stable unweighted
iterator choice path (`chooseIteratorFrom` / `chooseIteratorStableFrom` and root
wrappers) still used generic reservoir iteration for exact-size sources, which
preserved stream shape but required one extra trailing null probe to discover the
end of the iterator.

## Local `rand` Baseline

Rust `IteratorRandom::choose` works over iterators and may use size hints for
optimized selection. Alea exposes both hint-sensitive (`chooseIteratorHinted*`)
and stable reservoir (`chooseIterator*` / `chooseIteratorStable*`) APIs. For the
stable API, Alea can preserve the reservoir random-stream shape while using exact
remaining information to stop after the reported count and avoid the trailing
probe.

## Implementation

- `src/seq.zig` adds `chooseIteratorReservoirExactFrom` and routes
  `chooseIteratorFrom` / stable aliases through it when exact remaining is
  available.
- `src/root.zig` adds `rootChooseIteratorReservoirExact` and routes root
  `chooseIterator` / stable wrappers through it for exact-size sources.
- Empty exact sources still return without reads. Singleton exact sources return
  without entropy. Multi-entry exact sources preserve reservoir stream shape while
  avoiding the extra null read.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-count stable iterator choice does not probe past source"
1/2 seq.test.exact-count stable iterator choice does not probe past source...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/root.zig --test-filter "root random helpers validate deterministic cases before entropy"
1/2 root.test_0...OK
2/2 root.test.root random helpers validate deterministic cases before entropy...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
toolingcheck ok
apicheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M779 is closed for the current bar: seq/root stable unweighted iterator
one-shot choices now read exact-size sources exactly for their reported remaining
count, avoiding trailing end probes while preserving reservoir stream shape. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
