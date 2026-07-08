# S4-M882 UnicodeCharset UTF-8 Append Direct Index Sampling

## Gap

`UnicodeCharset.appendStringFrom` still routed every appended scalar through
`UnicodeCharset.sampleFrom`, adding a wrapper call before drawing a uniform index,
fetching a scalar, and UTF-8 encoding it.

## Local `rand` Baseline

Local `rand` string/charset workflows sample indexes into a chosen character set
and then encode/output the chosen character. Alea's `UnicodeCharset` stores the
scalar slice directly, so UTF-8 append workflows can draw indexes and encode the
selected scalar directly while preserving the same stream as repeated
`UnicodeCharset.sampleFrom` calls.

## Implementation

- `src/ascii.zig` updates `UnicodeCharset.appendStringFrom` to keep empty-output
  and validation behavior, add a singleton repeated-UTF-8 append path, and for
  non-singleton sets draw uniform indexes directly and encode `self.scalars[index]`
  instead of calling `UnicodeCharset.sampleFrom` for every scalar.
- Focused tests compare `UnicodeCharset.appendStringFrom` with a manual
  `UnicodeCharset.sampleFrom`/UTF-8 append loop under identical seeds.

## Validation

Focused ASCII test:

```text
$ zig test src/ascii.zig --test-filter "unicode charset helpers preserve direct stream shape"
1/2 ascii.test.unicode charset helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M882 is closed for the current bar: `UnicodeCharset.appendStringFrom` now
avoids per-scalar `UnicodeCharset.sampleFrom` wrapper calls for non-singleton
UTF-8 appends while preserving stream shape and singleton behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
