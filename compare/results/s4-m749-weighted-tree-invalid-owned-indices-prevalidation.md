# S4-M749 Weighted Tree Invalid Owned Indices Prevalidation

## Gap

Dynamic `WeightedTree` and `WeightedIntTree` can enter invalid sampling states
(for example, all-zero weights). Checked fill/scalar/iterator helpers validate
that state before random-stream use, but checked allocation-returning index
helpers allocated their output buffer first and only discovered invalid state when
filling it.

For non-zero checked owned index requests, invalid dynamic trees should fail
before allocation and before random-stream use.

## Local `rand_distr` Baseline

The local Rust `rand_distr` weighted-tree workflow validates weighted sampling
state before producing samples. Alea's dynamic weighted trees expose more
allocation-returning helpers; their checked variants should preserve the same
pre-sampling validation contract while keeping zero-count requests as empty
allocation no-ops.

## Coverage Added

`src/distributions.zig` now prevalidates non-zero requests before allocation:

- `WeightedTree(Weight).indicesCheckedFrom`;
- `WeightedTree(Weight).indicesU32CheckedFrom`;
- `WeightedIntTree(Weight).indicesCheckedFrom`;
- `WeightedIntTree(Weight).indicesU32CheckedFrom`.

Focused tests use all-zero invalid dynamic trees with failing allocators and
verify each checked owned helper returns `error.InvalidWeight`, does not induce
allocator failure, and leaves the random stream unchanged.

Zero-count requests still return empty allocations before invalid-state checks,
matching the existing batch no-op policy.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "weighted tree owned index batches mirror fills"
1/2 distributions.test.weighted tree owned index batches mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M749 is closed for the current bar: dynamic `WeightedTree` and
`WeightedIntTree` checked allocation-returning index outputs now reject invalid
all-zero trees before allocation or random-stream use for non-zero requests. This
is reliability/validation work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
