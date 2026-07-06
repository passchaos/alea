# S4-M377 Vectorbench Filter-Only Arguments

## Gap

The main throughput benchmark accepts either `[bytes] [filter]` or a filter-only
first argument. `vectorbench` documented focused vector/SIMD evidence, but its
first argument was always consumed as a lane count attempt; a non-numeric filter
fell back to default lanes and was not used as a filter.

## Change

`bench/vector.zig` now parses options like the main benchmark:

- no arguments -> default lanes, no filter;
- numeric first argument -> lane count;
- non-numeric first argument -> default lanes and that value as the filter;
- numeric first argument plus second argument -> lane count plus filter.

Focused parser tests cover all four cases. `build.zig` now creates
`alea-vectorbench-tests` and makes `zig build vectorbench` run those tests before
the executable. `tools/toolingcheck.zig` guards that dependency shape, and
`docs/tooling.md` documents filter-only support.

## Validation

Focused validation command:

```text
$ zig build vectorbench -- normal
vector microbench lanes=16777216 filter=normal
```

Broader validation commands:

```text
$ zig build toolingcheck
toolingcheck ok
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M377 is closed for the current bar: focused vector/SIMD evidence can be
collected with filter-only arguments, and the parser behavior is tested. This is
performance-tooling ergonomics only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
