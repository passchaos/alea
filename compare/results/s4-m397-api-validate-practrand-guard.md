# S4-M397 API Validate PractRand Prose Guard

## Gap

The API reference says `zig build validate` includes `zig build
practrand-self-test` for no-external PractRand wrapper validation. `toolingcheck`
required the command name but did not guard the semantic phrase
"no-external PractRand wrapper validation".

## Change

`tools/toolingcheck.zig` now requires `docs/api-reference.md` to contain:

```text
no-external PractRand wrapper validation
```

This keeps API validation guidance explicit that the PractRand wrapper check does
not require `RNG_test`.

## Validation

Focused validation commands:

```text
$ zig build toolingcheck
toolingcheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M397 is closed for the current bar: API validation guidance retains the
no-external PractRand wrapper validation meaning and toolingcheck guards it. This
is validation documentation reliability only; it does not resolve S4-M11 and is
not whole-goal completion evidence.
