# S4-M473 Root One-Shot String Helpers

## Gap

The root system-entropy API covered random scalars, ranges, caller-owned fills,
and allocation-returning batches, but common string generation still required
manual secure-engine construction plus `alea.ascii` calls. Local Rust users can
quickly reach string/token workflows through `rng()` and distribution sampling;
Alea should keep explicit Zig `std.Io` entropy while making root one-shot string
workflows similarly direct.

## API Added

`src/root.zig` now exposes:

- `char`
- `string`
- `sampleString`
- `appendString`
- `unicodeScalar`
- `unicodeUtf8Capacity`
- `unicodeUtf8Into`
- `unicodeUtf8Alloc`

Zero-length string/UTF-8 helpers return without drawing entropy, and
`unicodeUtf8Into` checks caller capacity before touching entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root string helpers` output with ASCII and
  Unicode helpers.
- `tools/examplecheck.zig` guards those example tokens.
- `docs/api-reference.md` lists the new root public symbols.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused root tests:

```text
$ zig test src/root.zig --test-filter "root random helpers"
1/3 root.test_0...OK
2/3 root.test.root random helpers use explicit system entropy...OK
3/3 root.test.root random helpers validate deterministic cases before entropy...OK
All 3 tests passed.
```

Runnable example and guard checks:

```text
$ zig build run-basic
root string helpers: char=Q, string=W0PH7L4K, sampleString=y2akspEM, appendString=v3m0NlOv, unicodeScalar=U+39E71, unicodeInto=񽨴񕀴𱙾𬘨, unicodeAlloc=󺤍򻑱󀬶󒹾
```

```text
$ zig build examplecheck
examplecheck ok
```

```text
$ zig build apicheck
apicheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

Broader native test gate:

```text
$ zig build test
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok
readmecheck ok
```

```text
$ git diff --check
```

## Result

S4-M473 is closed for the current bar: root system-entropy callers can generate
alphanumeric strings plus Unicode scalars/UTF-8 without manually constructing a
secure engine. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
