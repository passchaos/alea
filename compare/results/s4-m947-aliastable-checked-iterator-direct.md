# S4-M947 AliasTable Checked Iterator Direct Constructors

## Gap

Static `AliasTable` checked iterator constructors still routed through unchecked
iterator wrappers or checked direct-source wrappers. The checked constructors do
not need additional validation for `usize` iterators, and compact `u32` checked
facades only need width prevalidation before constructing their iterator payload.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows are iterator-oriented:
construct a reusable weighted sampler, then repeatedly sample indexes from an RNG
reference. Alea exposes static `AliasTable` facade and direct-source checked
iterators; those constructors should build their iterator payloads directly while
preserving deterministic stream shape.

## Implementation

- `src/distributions.zig` updates `AliasTable.iterChecked` to construct the facade
  `usize` sample iterator directly.
- `src/distributions.zig` updates `AliasTable.iterCheckedFrom` to construct the
  direct-source `usize` sample iterator directly.
- `src/distributions.zig` updates `AliasTable.iterU32Checked` to keep compact
  width prevalidation and then construct the facade compact iterator directly.
- Focused tests compare checked facade/direct iterators against unchecked iterator
  stream shape and cover oversized compact iterator prevalidation.

## Validation

Focused AliasTable test:

```text
$ zig test src/distributions.zig --test-filter "alias table iterators produce repeated indices"
1/2 distributions.test.alias table iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M947 is closed for the current bar: static `AliasTable` checked iterator
constructors now avoid iterator wrapper aliases while preserving stream shape and
compact width validation. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
