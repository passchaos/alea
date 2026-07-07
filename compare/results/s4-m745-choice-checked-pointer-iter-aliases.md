# S4-M745 Choice Checked Pointer Iter Aliases

## Gap

Recent milestones added checked aliases for pointer fills/batches, value
outputs, `usize`/compact index outputs, and many iterator constructors. The
canonical repeated pointer iterator names still had an inconsistency:

- distribution-layer `Choose.iter` / `iterFrom` had no checked alias;
- reusable `Choice.iter` / `iterFrom` had no checked alias;
- reusable `WeightedChoice.iter` / `iterFrom` had no checked alias.

`ptrIterChecked*` aliases existed, but users discovering the canonical `iter*`
forms still had to switch naming conventions to stay in the checked API family.

## Local `rand` Baseline

The local Rust `rand` sequence API is iterator-oriented for repeated reference
sampling, including weighted repeated reference choice. Alea keeps the
Zig-native reusable sampler design and explicit checked naming. These aliases do
not copy Rust traits; they make the existing allocation-free pointer iterator
surface easier to use consistently.

## API Added

`src/distributions.zig` now exposes:

- `Choose(T).iterChecked`;
- `Choose(T).iterCheckedFrom`.

`src/seq.zig` now exposes:

- `Choice(T).iterChecked`;
- `Choice(T).iterCheckedFrom`;
- `WeightedChoice(T, Weight).iterChecked`;
- `WeightedChoice(T, Weight).iterCheckedFrom`.

`docs/api-reference.md` lists the new public symbols.

## Semantics

The checked aliases preserve existing canonical iterator behavior:

- checked facade aliases match checked direct-source aliases;
- checked direct-source aliases match existing `iterFrom` stream shape;
- iterator `fill` on checked aliases matches existing iterator `fill` stream
  shape;
- no new random-stream consumption or allocation is introduced.

Validation for empty slice construction continues to live on `initChecked` and
on the existing `chooseIterChecked*` convenience helpers.

## Validation

Focused sequence tests:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
2/2 root.test_0...OK
All 2 tests passed.
```

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
examplecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M745 is closed for the current bar: canonical repeated pointer iterator
helpers for `Choose`, `Choice`, and `WeightedChoice` now have checked aliases
with stream-shape parity tests and API documentation. This is ergonomics/API
consistency work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
