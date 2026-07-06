# S4-M447 `rand-status` Schema-Version Command

## Gap

S4-M443 added `schema_version` to `rand-status-json`, but scripts still had to
parse the full JSON object just to check schema compatibility.

## Change

- `tools/rand_status.zig` now supports `--schema-version`, printing the current
  schema version as `1`.
- `build.zig` adds `zig build rand-status-schema-version` and includes it in
  `validate-local`.
- README, core guide, API reference, and tooling docs mention the command.
- `tools/readmecheck.zig` and `tools/toolingcheck.zig` guard the command,
  dependency shape, help text, and aggregate docs.

## Validation

Observed schema-version output:

```text
$ zig build rand-status-schema-version
1
```

Focused validation commands:

```text
$ zig build rand-status-schema-version
1
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
$ zig build readmecheck
readmecheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M447 is closed for the current bar: scripts can cheaply query the
`rand-status-json` schema version. This is tooling compatibility only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
