# S4-M820 Distribution Choose Pointer Iterator Direct Index Mapping

## Gap

S4-M818 optimized distribution-layer `Choose` value iterators by mapping generated
indexes directly into item storage. The scalar `Choose.PtrIterator.nextValue`
path still routed each item through `sampleFrom`, adding a wrapper call for every
iterator element.

## Local `rand` Baseline

Rust choice iterators are uniform index streams over a fixed slice length mapped
into the backing slice. Alea's distribution-layer `Choose` pointer iterator
should do the same for scalar `next()` calls while preserving singleton
no-consumption behavior.

## Implementation

- `src/distributions.zig` updates `Choose.PtrIterator.nextValue` to return the
  singleton pointer without consuming entropy, or generate a uniform index and
  map directly to `&items[index]`.
- Focused tests compare iterator `next()` output with helper-generated indexes
  under identical seeds, proving stream shape stays aligned.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M820 is closed for the current bar: distribution-layer `Choose` pointer
iterator scalar `next()` calls now avoid per-item `sampleFrom` wrapper calls and
map generated indexes directly into item storage while preserving stream shape.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
