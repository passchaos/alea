# S4-M817 Choice Value Iterator Direct Index Mapping

## Gap

S4-M803 optimized reusable `Choice` value fills by mapping generated indexes
directly into item storage. The scalar `Choice.ValueIterator.nextValue` path still
routed each item through `sampleValueFrom`, adding a wrapper call for every
iterator element.

## Local `rand` Baseline

Rust choice iterators are uniform index streams over a fixed slice length mapped
into the backing slice. Alea's reusable `Choice` value iterator should do the
same for scalar `next()` calls while preserving empty enum and singleton
no-consumption behavior.

## Implementation

- `src/seq.zig` updates `Choice.ValueIterator.nextValue` to return `null` for
  empty-enum output types, return the singleton item without consuming entropy,
  or generate a uniform index and map directly to `items[index]`.
- Focused tests compare iterator `next()` output with helper-generated indexes
  under identical seeds, proving stream shape stays aligned.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M817 is closed for the current bar: reusable `Choice` value iterator scalar
`next()` calls now avoid per-item `sampleValueFrom` wrapper calls and map
generated indexes directly into item storage while preserving stream shape. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
