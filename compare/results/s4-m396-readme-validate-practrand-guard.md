# S4-M396 README Validate PractRand Prose Guard

## Gap

S4-M391 made `zig build validate` run `zig build practrand-self-test`, and README
already mentioned this in prose. However, `readmecheck` only required the command
list and not the explanation that broad native validation includes the
no-external PractRand wrapper self-test.

## Change

`tools/readmecheck.zig` now requires README to contain:

```text
broad native checks including the no-external PractRand wrapper self-test
```

A focused helper test covers that required token and rejects weaker generic
`zig build validate` prose.

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

S4-M396 is closed for the current bar: README's broad-native-validation prose now
keeps the PractRand wrapper self-test coverage visible and readmecheck guards it.
This is validation documentation reliability only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
