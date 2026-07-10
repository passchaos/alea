# S4-M1174 Weighted Error Message Helpers

## Gap

After S4-M1173 refreshed `validate-all`, the next local Rust weighted audit
found a diagnostics ergonomics gap: local `rand::distr::weighted::Error`
implements `Display` with stable human-readable messages.

Local Rust source evidence:

```text
$ sed -n '80,120p' ~/Work/rand/src/distr/weighted/mod.rs
impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        f.write_str(match *self {
            Error::InvalidInput => "Weights sequence is empty/too long/unordered",
            Error::InvalidWeight => "A weight is negative, too large or not a valid number",
            Error::InsufficientNonZero => "Not enough weights > zero",
            Error::Overflow => "Overflow when summing weights",
        })
    }
}
```

Alea intentionally keeps Zig error sets instead of Rust error types/traits, but a
Zig-native message helper is useful for logs and user-facing diagnostics.

## Implementation

- Added top-level `weightedErrorMessage(err: WeightedError) []const u8`.
- Added `distributions.weighted.errorMessage(err)` for the Rust-discoverable
  weighted namespace.
- The four local Rust weighted variants return the same display text:
  `InvalidInput`, `InvalidWeight`, `InsufficientNonZero`, and `Overflow`.
- Other shared `distributions.Error` values fall back to `@errorName(err)`, so
  the helper remains safe with Alea's broader shared error set.
- Focused tests verify all local Rust strings and namespace parity.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "weighted error messages"
1/1 distributions.test.weighted error messages mirror local Rust Display diagnostics...OK
All 1 tests passed.
```

## Full validation

```text
$ git diff --check

$ zig build apicheck
apicheck ok

$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ zig build rand-status-self-test
rand-status self-test ok

$ zig test src/distributions.zig --test-filter "weighted"
1/123 distributions.test.weighted samplers clone and equality mirror local Rust derives...OK
...
123/123 seq.test.sampleIteratorWeightedArray returns fixed-size weighted iterator samples...OK
All 123 tests passed.

$ zig build test
readmecheck ok
examplecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok

$ zig build validate-local
rand_bench_smoke self-test ok
practrand self-test ok
runtimecheck ok: no additional runtime runner available
"current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1174 follow-ups closed for current bar"
"remaining_blocker": "S4-M1175 post-S4-M1174 next product bar"
"latest_validate_local_evidence": "compare/results/s4-m1174-weighted-error-message.md"
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand-status self-test ok
roadmapcheck ok
apicheck ok
readmecheck ok
examplecheck ok
rand_distr standard-normal: 34.3 M samples/s checksum=-3.640
rand_distr standard-normal f32: 33.8 M samples/s checksum=-3.640
```

## Result

S4-M1174 is closed for the current bar: Alea weighted errors now have
Zig-native message helpers matching local Rust weighted `Display` diagnostics.
This is not whole-goal completion; S4-M1175 remains active.
