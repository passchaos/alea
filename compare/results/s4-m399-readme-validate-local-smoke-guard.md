# S4-M399 README Validate-Local Smoke Guard

## Gap

README explains that `zig build validate-local` runs native validation plus the
local Rust comparison gates. `readmecheck` guarded only the beginning of that
sentence (`rand-bench-test`) and did not require the smoke/self-test plus
surface/runtime tail, so the README could lose the stronger local comparison
coverage explanation.

## Change

`tools/readmecheck.zig` now requires the README token:

```text
`rand-bench-smoke-self-test`, `surfacecheck`, and `runtimecheck`
```

The focused helper test was updated to include `rand-bench-smoke` and
`rand-bench-smoke-self-test` in its validate-local sample prose.

## Validation

Focused validation commands:

```text
$ zig build readmecheck
readmecheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M399 is closed for the current bar: README's validate-local guidance keeps the
full local Rust comparison smoke/self-test plus surface/runtime coverage visible.
This is validation documentation reliability only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
