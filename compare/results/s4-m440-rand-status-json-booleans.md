# S4-M440 Boolean Fields In `rand-status-json`

## Gap

`zig build rand-status-json` exposed stable string fields, but scripts still had
to parse prose to answer common yes/no questions such as whether validate-local
passes, whether a new local gap is known, whether S4-M11 is blocked, or whether
opportunity runners are available.

## Change

`tools/rand_status.zig` now emits and self-tests stable boolean fields:

- `validate_local_passes: true`
- `opportunity_runners_available: false`
- `no_known_unblocked_gap: true`
- `s4_m11_blocked: true`

`docs/tooling.md` documents those fields in the JSON schema list, and
`tools/toolingcheck.zig` guards the source/schema tokens.

## Validation

Observed JSON output excerpt:

```text
$ zig build rand-status-json
  "validate_local_passes": true,
  "opportunity_runners_available": false,
  "no_known_unblocked_gap": true,
  "s4_m11_blocked": true,
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

S4-M440 is closed for the current bar: `rand-status-json` includes stable boolean
fields for script-friendly status checks. This is tooling ergonomics only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
