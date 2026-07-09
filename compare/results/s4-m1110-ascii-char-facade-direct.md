# S4-M1110 ASCII Char Facade Direct Path

## Gap

Top-level `ascii.char` still delegated the facade alphanumeric byte helper
through `charFrom(rng)`. The reusable ASCII `Charset.sample` facade now samples
through facade `Rng` directly, so the top-level convenience helper can call that
facade instead of bouncing through the direct-source wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes top-level alphanumeric character helpers for
common password/identifier-style workflows. This change tightens the top-level
ASCII facade path without changing byte selection, stream shape, or singleton
no-consume behavior.

## Implementation

- `src/ascii.zig` updates top-level `char` to call `Alphanumeric.sample(rng)`
  directly.
- `charFrom` remains unchanged for explicit direct-source workflows.

## Validation

Focused ASCII tests:

```text
$ zig test src/ascii.zig --test-filter "ascii helpers preserve direct stream shape"
1/2 ascii.test.ascii helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "single-byte charset helpers do not consume random stream"
1/2 ascii.test.single-byte charset helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
examplecheck ok
readmecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M1110 is closed for the current bar: top-level `ascii.char` now avoids the
`charFrom` direct-source wrapper alias while preserving stream shape and
alphanumeric sampling behavior. This is reliability / ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
