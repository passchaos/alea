# S4-M348 Readmecheck Helper Tests

## Gap

`readmecheck` verifies README discovery links, validation commands, project
positioning, and the local Rust `rand` comparison note. Before S4-M348,
`zig build readmecheck` only ran the executable README audit; helper assumptions
for required-token matching, project positioning, and local-rand-note detection
had no focused unit tests wired into the build step.

## Change

`tools/readmecheck.zig` now factors those checks through helper functions and
includes focused tests for:

- configured required-token matching;
- Zig 0.16 project-positioning detection;
- local `rand` checkout note detection requiring both `local \`rand\` checkout`
  and `~/Work/rand`.

`build.zig` now creates `alea-readmecheck-tests` and makes `zig build
readmecheck` run those tests before the `alea-readmecheck` executable audit.
`zig build doccheck` now depends on the full `readmecheck` step, not only the
checker executable, so documentation validation also includes the helper tests.

`tools/toolingcheck.zig` guards this new dependency shape, and `docs/tooling.md`
documents that readmecheck runs helper tests.

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
examplecheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M348 is closed for the current bar: README discovery checking now has a
focused helper-test layer that runs before the executable audit. This is
evidence/tooling hardening only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
