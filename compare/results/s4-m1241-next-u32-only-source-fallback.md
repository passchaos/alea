# S4-M1241 NextU32-Only Source Fallback

## Gap

S4-M1235 preserved source-native `nextU32` for u32 raw helpers, while S4-M1236
through S4-M1240 broadened u64/raw byte/facade paths around `nextU64`. A direct
source exposing only `nextU32()` still could not supply u64-shaped workflows:
`nextU64From`, `tryNextU64From`, generic `nextFrom`, and `Rng.init(&source)` all
needed a u64 raw draw spelling.

This left 32-bit portable raw sources less usable than 64-bit raw sources and
made the facade constructor's widened source contract incomplete.

## Change

`src/source.zig` and `src/rng.zig` now:

- synthesize a little-endian u64 draw from two source-native `nextU32()` draws
  when neither `next()` nor `nextU64()` is available;
- provide the same fallback for `tryNextU64` when only `tryNextU32()` is
  available;
- let `Rng.init` accept sources exposing `nextU32()` only;
- keep native `nextU32()` precedence for u32 raw helpers so u32 streams are not
  over-consumed;
- cover direct and facade nextU32-only workflows with focused tests.

## Validation

Focused tests:

```console
$ zig test src/source.zig
1/1 source.test.source helper prefers next and falls back to nextU64...OK
All 1 tests passed.

$ zig test src/rng.zig --test-filter "rng raw helpers accept native nextU32 only sources"
1/1 rng.test.rng raw helpers accept native nextU32 only sources...OK
All 1 tests passed.
```

Full validation for the committed change:

```console
$ zig build test
$ zig build validate
$ zig build validate-local
$ zig build crosscheck
$ zig build roadmapcheck toolingcheck rand-status-self-test
$ git diff --check
```

## Result

S4-M1241 closes the nextU32-only direct-source fallback hardening: 32-bit raw
sources now participate in u64 raw helpers and `Rng.init` via a documented
little-endian two-draw widening path while retaining native u32 stream shape. The
whole product goal remains active under the next S4-M1242 bar.
