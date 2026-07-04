# S4-M19 String Generation Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for ASCII charset and Unicode string
generation APIs, including allocation-returning and caller-owned-buffer shapes.

## Change

Added `examples/string_generation.zig` and build step:

```sh
zig build run-string-generation
```

The example demonstrates:

- `ascii.stringFrom` for alphanumeric allocation-returning strings;
- predefined charset fills such as `Lowercase.fillFrom`;
- custom `Charset` diagnostics through `probabilitiesInto`;
- custom charset `fillFrom` and `allocFrom`;
- `unicodeScalarFrom`;
- `unicodeUtf8AllocFrom`;
- `unicodeUtf8Capacity` plus `unicodeUtf8IntoFrom` for caller-owned UTF-8
  buffers;
- checked empty-charset handling through `sampleCheckedFrom`.

It prints deterministic output and a short decision guide for predefined ASCII
charsets, custom charsets, allocated Unicode strings, and caller-owned UTF-8
buffers.

## Validation

Command:

```sh
zig build run-string-generation
```

Result: passed and printed deterministic ASCII/custom charset/Unicode outputs.

`zig build examples` includes this example, so `zig build validate` covers it
through the examples validation gate added in S4-M15.

## S4-M19 Decision

S4-M19 is closed for the current string-generation adoption bar: ASCII and
Unicode string generation users now have runnable guidance in addition to API
docs, unit tests, and reproducibility snapshots.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
