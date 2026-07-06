# S4-M421 README Current Rand Status Discovery

## Gap

S4-M420 added a concise current local `rand` / `rand_distr` comparison status
snapshot, but README only pointed generally at `compare/results/`. Users asking
for the current status versus Rust `rand` needed a direct discovery path.

## Change

README now says to start with
`compare/results/s4-m420-current-rand-status.md` for the current local `rand` /
`rand_distr` comparison status.

`tools/readmecheck.zig` now requires that status snapshot token in README and in
the file discovery list.

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

```text
$ git diff --check
```

## Result

S4-M421 is closed for the current bar: README exposes the current local Rust
comparison status snapshot. This is documentation discoverability only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
