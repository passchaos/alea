# S4-M647 Unicode Charset Unchecked Invalid Prevalidation

## Gap

`UnicodeCharset` checked helpers already reject non-zero empty and invalid scalar
sets before random-stream use. The unchecked UTF-8 string helpers could allocate
or reserve first and then rely on assertions or `utf8Encode(... ) catch
unreachable` for empty or invalid scalar sets.

Fallible UTF-8 string helpers should reject non-zero empty/invalid scalar sets
before allocation, before random-stream use, and before mutating append buffers.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source:

- `/home/passchaos/Work/rand/src/distr/slice.rs` exposes `Choose::new(slice)`
  which returns an `Empty` error for empty slices before a reusable sampler can
  be used.
- Alea's `UnicodeCharset` APIs are Zig-native fallible helpers; empty custom
  charsets use `error.EmptyCharset` and invalid scalar sets use
  `error.InvalidParameter`.

S4-M647 aligns unchecked UTF-8 string helpers with that fallible behavior while
preserving zero-length no-op semantics.

## API Changed

`src/ascii.zig` now prevalidates non-zero empty or invalid Unicode charsets in:

- `UnicodeCharset.sampleStringFrom`
- `UnicodeCharset.appendStringFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Non-zero empty charset UTF-8 string requests return `error.EmptyCharset` before
  allocation and random-stream use.
- Non-zero invalid scalar-set requests return `error.InvalidParameter` before
  allocation, random-stream use, or UTF-8 encoding.
- Non-zero append requests on invalid charsets return before reserving capacity
  or mutating the destination list.
- Zero-length allocation and append calls still return/no-op without checking
  charset validity or consuming the random stream.
- Valid and singleton Unicode charsets keep existing behavior and stream shape.

## Adoption and Documentation

- Focused ascii tests cover empty/invalid charset failures before allocation,
  random-stream use, and append-buffer mutation, plus zero-length no-op behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused ascii tests:

```text
$ zig test src/ascii.zig --test-filter "unicode charset unchecked strings"
1/2 ascii.test.unicode charset unchecked strings validate before allocation...OK
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
readmecheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M647 is closed for the current bar: `UnicodeCharset` unchecked UTF-8 string
helpers now reject non-zero empty or invalid scalar sets before allocation,
random-stream use, and append-buffer mutation. This is reliability and
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
