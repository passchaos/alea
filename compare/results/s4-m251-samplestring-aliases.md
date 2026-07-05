# S4-M251 SampleString Aliases

Date: 2026-07-05

## Local Rust Baseline

The local `~/Work/rand/src/distr/distribution.rs` defines `SampleString` with
`append_string` and `sample_string`. Local `rand/src/distr/other.rs` implements
this trait for `Alphanumeric` and `Alphabetic`, making ASCII string generation
more discoverable than manually collecting sampled bytes.

Alea already supported allocation-returning ASCII strings via `Charset.alloc*`
and top-level `ascii.string*`, but did not expose the Rust-discoverable
`sampleString` / `appendString` naming.

## Alea Change

Alea now provides SampleString-style aliases:

- `Charset.sampleString`, `sampleStringFrom`, `sampleStringChecked`, and
  `sampleStringCheckedFrom`
- `Charset.appendString`, `appendStringFrom`, `appendStringChecked`, and
  `appendStringCheckedFrom`
- top-level `ascii.sampleString`, `sampleStringFrom`, `appendString`, and
  `appendStringFrom` using `Alphanumeric`

The append APIs target `std.ArrayList(u8)` so callers can reuse Zig-owned string
buffers while keeping allocator ownership explicit.

## Tests and Validation

Focused tests in `src/ascii.zig` cover:

- allocation-returning `sampleStringFrom` aliases produce charset-valid bytes;
- `appendStringFrom` appends requested bytes without losing existing prefixes;
- facade/direct string aliases preserve stream shape;
- checked empty-charset sample/append aliases fail without consuming the source;
- zero-length checked sample/append aliases return without validating or drawing.

Documentation/example updates:

- `examples/string_generation.zig` prints `sampleString alphanumeric` and
  `appendString alphanumeric`; `tools/examplecheck.zig` guards both tokens.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `docs/examples.md` document the new aliases.
- `compare/results/reproducibility-matrix.md`,
  `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M252.

Validation commands for this milestone:

```sh
zig test src/ascii.zig --test-filter "sampleString"
zig test src/ascii.zig --test-filter "ascii helpers preserve"
zig build run-string-generation
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```
