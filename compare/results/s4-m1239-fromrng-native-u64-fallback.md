# S4-M1239 FromRng Native-U64 Fallback

## Gap

S4-M1238 made the generic direct-source draw primitive accept sources that expose
Rust-style `nextU64()` without Zig's `next()`. The seed-derivation layer still
used `source.next()` / `source.tryNext()` directly in `Seed.fromRng`,
`Seed.tryFromRng`, engine `fromRng`, and engine `tryFromRng`.

That left child-stream derivation inconsistent with the raw and generic helper
surface: a source exposing `nextU64()` or `tryNextU64()` could feed
`Rng.nextU64From`, generic random values, and byte helpers, but could not seed or
fork deterministic engines through the Rust-discoverable `fromRng` APIs.

## Change

`src/source.zig` now centralizes direct-source raw draw discovery:

- `source.nextU64(source)` preserves Zig-native `next()` precedence and falls
  back to `nextU64()`;
- `source.tryNextU64(source)` preserves fallible `tryNext()` precedence, accepts
  `tryNextU64()`, and falls back to an infallible native-u64 draw;
- `source.hasDecl` shares pointer/value declaration probing with `Rng`.

`src/seed.zig`, every seedable engine, and `src/rng.zig` now use this shared
helper for seed material or generic raw draws. Focused root tests cover
`Seed.fromRng`, engine `fromRng`, `Seed.tryFromRng`, and engine `tryFromRng` with
`nextU64`-only / `tryNextU64`-only sources while comparing against the old
`next` / `tryNext` reference stream shape.

## Validation

Focused tests:

```console
$ zig test src/source.zig
1/1 source.test.source helper prefers next and falls back to nextU64...OK
All 1 tests passed.

$ zig test src/root.zig --test-filter "engine and seed fromRng aliases accept native nextU64 sources"
1/2 root.test_0...OK
2/2 root.test.engine and seed fromRng aliases accept native nextU64 sources...OK
All 2 tests passed.

$ zig test src/root.zig --test-filter "fallible engine and seed fromRng aliases accept native tryNextU64 sources"
1/2 root.test_0...OK
2/2 root.test.fallible engine and seed fromRng aliases accept native tryNextU64 sources...OK
All 2 tests passed.
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

S4-M1239 closes the fromRng native-u64 fallback hardening: deterministic seed and
fork workflows now accept the same Rust-style raw-u64 source shapes as the rest
of the direct-source helper surface, while preserving existing `next` /
`tryNext` precedence. The whole product goal remains active under the next
S4-M1240 bar.
