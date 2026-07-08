# S4-M797 Weighted Tree Iterator Fill Direct Storage Paths

## Gap

Dynamic `WeightedTree` / `WeightedIntTree` weight and probability iterators expose
caller-owned `fill` methods. Before this milestone those methods called `next()`
per output slot, which performed per-slot lookup and, for probabilities,
recomputed/validated the total weight each time.

## Local `rand_distr` Baseline

Dynamic weighted-tree style samplers operate over stored cumulative weights.
Alea's dynamic tree introspection iterators can fill caller-owned buffers by
reading tree storage directly, caching totals for probability fills, and advancing
iterator state once.

## Implementation

- `src/distributions.zig` updates `WeightedTree.WeightIterator.fill` and
  `WeightedIntTree.WeightIterator.fill` to fill from `tree.get(index)` in direct
  loops and advance once.
- `src/distributions.zig` updates both probability iterators to compute the total
  once per fill, then divide direct per-index weights by that cached total.
- Existing dynamic tree tests cover weight/probability iterator fills and state
  updates for f64 and integer weighted trees.

## Validation

Focused distribution tests:

```text
$ zig test src/distributions.zig --test-filter "weighted tree supports dynamic updates"
1/2 distributions.test.weighted tree supports dynamic updates...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/distributions.zig --test-filter "weighted int tree supports dynamic updates"
1/2 distributions.test.weighted int tree supports dynamic updates...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M797 is closed for the current bar: dynamic weighted tree weight/probability
iterator fills now use direct storage paths while preserving iterator state and
output semantics. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
