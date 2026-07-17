# S4-M1236 NextU64 Direct-Source Native Fallback

## Gap

After S4-M1235 aligned `tryNextU32From` with source-native `nextU32`, the
adjacent u64 direct-source helpers still only accepted Zig-style `next()` or
fallible `tryNextU64` / `tryNext` methods. A source exposing only the
Rust-discoverable `nextU64` raw alias could not be used with `Rng.nextU64From`,
and `Rng.tryNextU64From` would also miss that native alias before attempting the
`next()` fallback.

This is a direct-source interoperability gap: Alea advertises Rust-discoverable
raw aliases, so the facade's direct-source helpers should accept sources that
expose those aliases even when they do not also expose Zig's `next` spelling.

## Change

`src/rng.zig` now:

- adds `sourceCanNextU64` beside the existing try/u32 capability checks;
- makes `Rng.nextU64From` dispatch to source-native `nextU64` before falling
  back to `next`;
- makes `Rng.tryNextU64From` dispatch to source-native `nextU64` when no
  fallible u64/next hook exists;
- adds focused coverage proving both infallible and fallible-shaped direct
  helpers use `nextU64` without calling `next`.

## Validation

Focused test:

```console
$ zig test src/rng.zig --test-filter "rng direct raw aliases dispatch source native nextU64"
1/1 rng.test.rng direct raw aliases dispatch source native nextU64...OK
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

S4-M1236 closes the direct-source native-u64 alias fallback hardening: facade
`From` raw helpers now accept sources that expose Rust-style `nextU64` only,
while preserving the existing `tryNextU64` / `tryNext` / `next` precedence. The
whole product goal remains active under the next S4-M1237 bar.
