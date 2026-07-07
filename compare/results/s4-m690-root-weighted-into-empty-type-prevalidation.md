# S4-M690 Root Weighted Into Empty-Type Prevalidation

## Gap

`seq` parallel-weighted and accessor-weighted no-replacement value samples now
reject non-zero empty enum-containing value types before allocation or
random-stream use. Root caller-owned weighted no-replacement value buffer helpers
could still evaluate weights or construct a secure engine before failing in the
underlying `seq` value-copy path for uninhabited output types.

Root weighted caller-owned value sample helpers should reject non-zero
uninhabited value types before accessor weight evaluation, entropy, secure-engine
construction, random-stream use, weighted-key sampling, or value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes weighted no-replacement slice sampling via
`IndexedRandom::sample_weighted` in `src/seq/slice.rs`, backed by
`index::sample_weighted` in `src/seq/index.rs`. Rust returns references over
slice items and ordinary use cannot construct impossible output values.

Alea's root caller-owned value-output helpers can name empty enum-containing
output types, so `error.EmptyRange` is the deterministic pre-entropy validation
path for non-empty value buffers.

## API Changed

`src/root.zig` now prevalidates empty enum-containing value types in root
weighted no-replacement caller-owned value helpers:

- `sampleWeightedInto`
- `sampleWeightedIntoChecked`
- `sampleWeightedByInto`
- `sampleWeightedByIntoChecked`

Pointer caller-owned helpers are unchanged because they return addresses into
caller-owned slices instead of constructing values. Public signatures are
unchanged.

Deterministic behavior is explicit:

- Zero-output requests still return before validating the value type.
- Non-zero empty enum-containing value buffers return `error.EmptyRange` before
  accessor weight evaluation, entropy, secure-engine construction,
  weighted-key sampling, random-stream use, or value copying.
- Length/scratch mismatch and checked oversized requests keep existing
  precedence.
- Habitable value types keep existing root weighted no-replacement behavior and
  stream shape.

## Adoption and Documentation

- Focused root tests cover parallel-weight and item-accessor weighted
  caller-owned value output failures for regular structs containing an empty enum
  field. Tests use `std.Io.failing` to prove failure occurs before entropy.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused root test:

```text
$ zig test src/root.zig --test-filter "root random helpers validate deterministic cases before entropy"
1/2 root.test_0...OK
2/2 root.test.root random helpers validate deterministic cases before entropy...OK
All 2 tests passed.
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

No output.

Broader native test gate:

```text
$ zig build test
toolingcheck ok
apicheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M690 is closed for the current bar: root weighted no-replacement
caller-owned value helpers now reject non-zero empty enum-containing output types
before entropy, secure-engine construction, accessor evaluation,
weighted-key sampling, random-stream use, value copying, or assertions. This is
reliability and ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
