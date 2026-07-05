# S4-M252 UnicodeCharset String Alphabets

Date: 2026-07-05

## Local Rust Baseline

The local `~/Work/rand/src/distr/slice.rs` implements
`SampleString` for `Choose<'_, char>`. That shape lets Rust users build a
reusable distribution over a slice of `char` values, then append or allocate
UTF-8 strings from that reusable alphabet via `append_string` /
`sample_string`.

Alea already supported random Unicode scalar generation and arbitrary UTF-8
strings through `unicodeUtf8Alloc*` / `unicodeUtf8Into*`, and S4-M251 added
SampleString-style aliases for byte-oriented ASCII `Charset`. The remaining
gap was reusable caller-specified Unicode scalar alphabets with UTF-8
sample/append helpers.

## Alea Change

Alea now provides `ascii.UnicodeCharset`, a Zig-native reusable alphabet over
`u21` Unicode scalar values:

- checked and assert-based construction: `UnicodeCharset.init` /
  `initChecked`;
- diagnostics matching byte `Charset`: `scalarsValue`, `len`, `numChoices`,
  `constantIndex`, `isEmpty`, `scalarAt`, `item`, `get`, `indexOf`,
  `contains`, `probability`, `probabilityAt`, `probabilityIter`,
  `probabilities`, and `probabilitiesInto`;
- UTF-8 capacity diagnostics: `maxUtf8Len` and `utf8Capacity`;
- scalar sampling/fill helpers: `sample*` and `fill*`;
- SampleString-style UTF-8 helpers: `sampleString*` and `appendString*`.

The type keeps Zig's explicit `u21` scalar representation and allocator-owned
`[]u8` / `std.ArrayList(u8)` output instead of copying Rust trait shapes.

## Tests and Validation

Focused tests in `src/ascii.zig` cover:

- scalar choice diagnostics and valid UTF-8 sample/append output;
- facade/direct stream-shape preservation for scalar fills and UTF-8 strings;
- checked empty and invalid-scalar no-consume behavior;
- single-scalar charsets returning deterministic values without consuming;
- allocation failures before random draws for `sampleStringFrom` /
  `appendStringFrom`.

Documentation/example updates:

- `examples/string_generation.zig` prints `unicode charset sampleString`,
  `unicode charset appendString`, and `UnicodeCharset numChoices`.
- `tools/examplecheck.zig` checks the new example tokens.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `docs/examples.md` document `UnicodeCharset`.
- `compare/results/distribution-parity-matrix.md`,
  `compare/results/reproducibility-matrix.md`,
  `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and
  `tools/roadmapcheck.zig` record the milestone and advance the next-gap row
  to S4-M253.

Validation commands for this milestone:

```sh
zig test src/ascii.zig --test-filter "unicode charset"
zig build run-string-generation
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```
