# S4-M443 `rand-status-json` Schema Version

## Gap

S4-M440 added stable boolean fields to `rand-status-json`, but the JSON object did
not identify its schema version. Scripts could consume field names, but they had
no explicit way to detect a future schema revision.

## Change

`tools/rand_status.zig` now emits and tests:

```text
"schema_version": 1
```

`docs/tooling.md` includes `schema_version` in the documented JSON field list,
and `tools/toolingcheck.zig` guards the source and documentation tokens.

## Validation

Observed JSON output excerpt:

```text
$ zig build rand-status-json
  "schema_version": 1,
```

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

S4-M443 is closed for the current bar: script consumers can check an explicit
`rand-status-json` schema version. This is tooling compatibility only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
