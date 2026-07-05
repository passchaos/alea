# S4-M309 Surfacecheck Token Matcher Tests

Date: 2026-07-06

## Purpose

S4-M304 hardened `surfacecheck` manifest-token matching to avoid false positives
from ordinary substring matches. S4-M309 adds focused tests around that helper so
future edits do not silently reintroduce short-token matching bugs.

## Change

`tools/surfacecheck.zig` now includes unit tests covering:

- exact backtick-wrapped code tokens such as `` `p` `` and `` `len` ``;
- identifier-boundary matching for plain identifiers;
- rejection of short-token false positives inside unrelated words, such as
  `p` inside `alphabetic` or `len` inside `length`;
- fallback matching for scoped/non-identifier tokens and manifest phrases such
  as `slice::Choose` and "No new unblocked local Rust public-surface gap".

## Validation

Relevant validation:

```sh
zig fmt tools/surfacecheck.zig tools/roadmapcheck.zig
zig test tools/surfacecheck.zig
zig build surfacecheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone improves local comparison-tool test coverage. It does not resolve
S4-M11's exact/default-compatible dense SIMD normal/exponential blocker, does not
add an additional architecture/runtime runner, and is not whole-goal completion
evidence.
