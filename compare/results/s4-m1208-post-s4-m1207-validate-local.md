# S4-M1208 Post-S4-M1207 Validate-Local Refresh

## Gap

S4-M1207 refreshed the full portability-sensitive `validate-all` aggregate after
the roadmap evidence-path guard. The next Linux-first product bar needed a fresh
local `rand` / `rand_distr` comparison aggregate so the public-surface scan,
Rust comparison smoke, runtime availability check, and current status output all
reflect the post-S4-M1207 status chain.

## Command

```text
$ zig build validate-local
rand_bench_smoke self-test ok
practrand self-test ok
rand_distr standard-normal: 37.1 M samples/s checksum=-3.640
rand_distr standard-normal f32: 35.2 M samples/s checksum=-3.640
apicheck ok
examplecheck ok
rand-status self-test ok
runtimecheck ok: no additional runtime runner available
roadmapcheck ok
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=72 source-tokens=185
surfacecheck ok
toolingcheck ok
readmecheck ok
distcheck ok
statcheck ok
profilecheck ok
```

The aggregate also reran native validation, docs/API/tooling checks, examples,
statcheck, distcheck, the local Rust benchmark parser tests, `rand-status` text,
JSON, schema-version, and self-test steps, plus the current runtime opportunity
scan.

## Result

S4-M1208 is closed for the current bar: `zig build validate-local` passes after
S4-M1207 and confirms the local Rust comparison/status guard chain. This is
validation evidence, not whole-goal completion; S4-M1209 remains active.
