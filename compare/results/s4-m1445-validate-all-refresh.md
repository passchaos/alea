# S4-M1445 Validate-All Refresh After S4-M1444

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1803/1803
tests with the cached binomial sampler present:

- native `alea-tests` 888/888,
- WASI Node tests 888/888,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 907/907 tests (native
888/888), and `apicheck`, `toolingcheck`, `examplecheck`, `readmecheck`, and
`roadmapcheck` pass. The full 16MiB benchmark suite keeps every existing
checksum identical and adds the two runtime-parameter binomial rows
(`alea binomial runtime sampler` 17.1-17.2M, `alea binomial runtime cached`
37.1-39.3M, both checksum `6552418`).
