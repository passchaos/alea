# S4-M1124 wasm32 Oversized-u32 Test Guard

## Gap

After S4-M11 was closed for the current bar and the roadmap advanced to the
post-S4-M11 validation bar, `zig build validate-all` exposed a concrete
portability regression: several tests constructed `std.math.maxInt(u32) + 1` as
a `usize` constant. That is valid on 64-bit hosts but overflows at comptime on
`wasm32-wasi`, causing `crosscheck` and `test-wasi` to fail before the tests can
run.

Observed failure shape:

```text
src/distributions.zig:23063:55: error: overflow of integer type 'usize' with value '4294967296'
```

Equivalent oversized-u32 test constants in `src/distributions.zig`,
`src/root.zig`, and `src/seq.zig` hit the same 32-bit `usize` semantic-analysis
problem.

## Implementation

- Added local `oversizedU32LenForTest()` helpers in `src/distributions.zig`,
  `src/root.zig`, and `src/seq.zig` that compute the oversized length through a
  `u64` intermediate before casting on targets where `usize` can represent
  `maxInt(u32) + 1`.
- Guarded only the affected 64-bit-only oversized-population assertions with
  `if (comptime @bitSizeOf(usize) > 32) { ... }` where the surrounding test can
  still provide practical 32-bit coverage without exceeding the wasm compiler's
  function-size limits.
- Retained whole-test skips for tests whose complete purpose is the impossible
  `> maxInt(u32)` slice length on 32-bit `usize` targets.
- Retained the existing monolithic root deterministic-helper test's 32-bit skip:
  after narrowing only its oversized-u32 assertions, the generated Node WASI
  test wasm exceeded V8's maximum single-function size, while native Linux still
  runs the focused root test and covers the oversized prevalidation paths.
- Kept the native 64-bit tests intact so the oversized-u32 prevalidation paths
  still run on local Linux and reject the impossible population before random
  stream consumption or allocator use.

## Validation

Focused native tests after the guard tightening:

```text
$ zig test src/distributions.zig --test-filter "alias table iterators produce repeated indices"
1/2 distributions.test.alias table iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "weighted tree iterators produce repeated indices"
1/2 distributions.test.weighted tree iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution Choose owned u32 indices reject oversized population before allocation"
1/2 distributions.test.distribution Choose owned u32 indices reject oversized population before allocation...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/root.zig --test-filter "root random helpers validate deterministic cases before entropy"
1/2 root.test_0...OK
2/2 root.test.root random helpers validate deterministic cases before entropy...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "owned u32 indices reject oversized population before allocation"
1/4 seq.test.Choice owned u32 indices reject oversized population before allocation...OK
2/4 seq.test.WeightedChoice owned u32 indices reject oversized population before allocation...OK
3/4 root.test_0...OK
4/4 distributions.test.distribution Choose owned u32 indices reject oversized population before allocation...OK
All 4 tests passed.
```

Whitespace/check gate:

```text
$ git diff --check
# completed successfully
```

Full validation rerun for this commit:

```text
$ zig build crosscheck
# completed successfully

$ zig build roadmapcheck && zig build toolingcheck && zig build test
# completed successfully

$ zig build validate-all
...
profilelongcheck ok
# command exited 0
```

## Result

S4-M1124 is closed for the current bar: the post-S4-M11 validation bar now has a
concrete portability fix, `crosscheck` succeeds across the compile-only target
set, and `validate-all` succeeds through native validation, crosscheck, Node WASI
unit/report execution, and accepted profile long checks. This is not whole-goal
completion; the roadmap advances to a stricter S4-M1125 bar.
