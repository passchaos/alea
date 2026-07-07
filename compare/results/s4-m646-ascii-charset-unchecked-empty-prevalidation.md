# S4-M646 ASCII Charset Unchecked Empty Prevalidation

## Gap

ASCII `Charset` checked helpers already reject non-zero empty charsets before
random-stream use. The unchecked allocation/string helpers could allocate or
resize first and then rely on assertions in `sampleFrom` / `fillFrom` for empty
charsets.

Fallible allocation/string helpers should reject non-zero empty charsets before
allocation, before random-stream use, and before mutating append buffers.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source:

- `/home/passchaos/Work/rand/src/distr/slice.rs` exposes `Choose::new(slice)`
  which returns an `Empty` error for empty slices before a reusable sampler can
  be used.
- Alea's `Charset` APIs are Zig-native fallible helpers; empty custom charsets
  use `error.EmptyCharset`.

S4-M646 aligns unchecked allocation/string helpers with that fallible behavior
while preserving zero-length no-op semantics.

## API Changed

`src/ascii.zig` now prevalidates non-zero empty charsets in:

- `Charset.allocFrom`
- `Charset.sampleStringFrom` through `allocFrom`
- `Charset.appendStringFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Non-zero empty charset allocation/string requests return `error.EmptyCharset`
  before allocation and random-stream use.
- Non-zero append requests on empty charsets return `error.EmptyCharset` before
  resizing or mutating the destination list.
- Zero-length allocation and append calls still return/no-op without checking
  charset emptiness or consuming the random stream.
- Non-empty and singleton charsets keep existing behavior and stream shape.

## Adoption and Documentation

- Focused ascii tests cover empty-charset failures before allocation, random
  stream use, and append-buffer mutation, plus zero-length no-op behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused ascii tests:

```text
$ zig test src/ascii.zig --test-filter "sampleString unchecked aliases"
1/2 ascii.test.sampleString unchecked aliases handle empty charsets before allocation...OK
2/2 root.test_0...OK
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
apicheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M646 is closed for the current bar: ASCII `Charset` unchecked
allocation/string helpers now reject non-zero empty charsets before allocation,
random-stream use, and append-buffer mutation. This is reliability and ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
