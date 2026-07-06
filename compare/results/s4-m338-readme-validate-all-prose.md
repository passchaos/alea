# S4-M338 README Validate-All Prose

## Gap

README listed `zig build validate-all`, but it did not explain when a maintainer
or adopter should prefer it over `zig build validate` or `zig build
validate-local`. After S4-M336 and S4-M337 hardened the aggregate dependency
shape, the README still needed matching prose so the broad portability-oriented
validation path is discoverable without opening the tooling catalog.

## Change

README now says:

```text
Use `zig build validate-all` before portability-sensitive releases or evidence
refreshes: it runs native validation plus cross-target compile checks, WASI unit
tests, and the chained WASI report.
```

`tools/readmecheck.zig` now guards the usage phrase
`portability-sensitive releases or evidence` and the component explanation
`cross-target compile checks, WASI unit` so the prose cannot disappear while the
command remains listed.

## Validation

Focused validation command:

```text
$ zig build readmecheck
readmecheck ok
```

Broader documentation/roadmap validation command:

```text
$ zig build doccheck
apicheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M338 is closed for the current bar: README now explains the
portability-sensitive `validate-all` aggregate and `readmecheck` guards that
explanation. This is documentation/tooling hardening only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
