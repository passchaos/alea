# S4-M458 Latest Validate-Local Evidence In `rand-status-json`

## Gap

`rand-status-json` exposed current status fields but did not directly identify
the latest validate-local evidence artifact. Scripts could see that
validate-local passes but had to discover the evidence path elsewhere.

## Change

`tools/rand_status.zig` now emits and tests:

```text
"latest_validate_local_evidence": "compare/results/s4-m448-validate-local-after-rand-status-schema-version.md"
```

`docs/tooling.md` documents the field, and `tools/toolingcheck.zig` guards the
source/docs tokens.

## Validation

Focused validation commands:

```text
$ zig build rand-status-json
```

```text
$ zig build rand-status-self-test
rand-status self-test ok
```

```text
$ zig build toolingcheck
toolingcheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M458 is closed for the current bar: script consumers can jump from
`rand-status-json` to the latest validate-local evidence artifact. This is
tooling ergonomics only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
