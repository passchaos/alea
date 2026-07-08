# S4-M796 AliasTable Iterator Fill Direct Storage Paths

## Gap

Static `AliasTable` weight and probability iterators expose caller-owned `fill`
methods. Before this milestone those methods called `next()` per output slot,
which then looked up each weight or probability individually even though the
underlying `weight_values` slice is already stored contiguously.

## Local `rand` Baseline

Rust weighted-index samplers expose reusable weighted sampling from stored
weights. Alea additionally exposes weight/probability introspection iterators; it
can fill caller-owned buffers directly from stored weights without per-slot
lookup overhead.

## Implementation

- `src/distributions.zig` updates `AliasTable.WeightIterator.fill` to memcpy
  stored `weight_values` for the requested range and advance the iterator index.
- `src/distributions.zig` updates `AliasTable.ProbabilityIterator.fill` to divide
  stored weights by the table total in a direct loop and advance once.
- Existing AliasTable introspection tests cover partial `next()` followed by
  `fill`, remaining/size-hint updates, and end-of-iterator behavior.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "alias table exposes totals and reconstructs weights"
1/1 distributions.test.alias table exposes totals and reconstructs weights...OK
All 1 tests passed.
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

S4-M796 is closed for the current bar: static AliasTable weight/probability
iterator fills now use direct storage paths while preserving iterator state and
output semantics. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
