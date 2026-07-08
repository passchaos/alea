# S4-M899 Choice Checked Sample Direct Index Paths

## Gap

Reusable `Choice.sampleValueCheckedFrom`, `Choice.sampleIndexCheckedFrom`, and
`Choice.sampleIndexU32CheckedFrom` still validated checked preconditions and then
routed through unchecked scalar sample helpers. The unchecked helpers already
draw a uniform in-bounds index and map into the item slice, so checked scalar
samples can use the same direct index mapping after validation without changing
stream shape.

## Local `rand` Baseline

Local Rust `rand` slice choice APIs under `rand::seq` sample a uniform index into
the input slice for non-empty choices and fail before random draws for empty
inputs. Alea's reusable `Choice` adds Zig-native checked value/index/u32 helpers;
for validated non-empty choices, these helpers should keep the same uniform-index
mapping as the unchecked sample paths while preserving explicit checked errors.

## Implementation

- `src/seq.zig` updates `Choice.sampleValueCheckedFrom` to keep empty-enum
  prevalidation and then directly execute singleton or uniform-index value
  mapping.
- `src/seq.zig` updates `Choice.sampleIndexCheckedFrom` to directly execute
  singleton or uniform-index `usize` sampling.
- `src/seq.zig` updates `Choice.sampleIndexU32CheckedFrom` to keep oversized
  compact-index prevalidation and then directly execute singleton or uniform-index
  `u32` sampling.
- The focused reusable `Choice` test now compares checked scalar samples against
  helper-generated value, `usize`, and compact `u32` indexes while existing
  coverage preserves empty-enum and allocation/no-consume behavior.

## Validation

Focused reusable choice test:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M899 is closed for the current bar: reusable `Choice` checked scalar
value/index/u32 samples now avoid unchecked sampling wrappers after prevalidation
while preserving stream shape, singleton behavior, and checked error behavior.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
