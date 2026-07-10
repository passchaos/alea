# S4-M1176 Root Weighted Error Aliases

## Gap

S4-M1174 added distribution-level weighted error message helpers matching local
Rust weighted `Display` diagnostics. The next root/prelude audit found that
callers still had to import `distributions` to reach those weighted diagnostics,
while Alea already exposes root/prelude aliases for common Rust discovery names
such as `WeightError`.

## Implementation

- Added root `WeightedError` alias over `distributions.WeightedError`.
- Added root `weightedErrorMessage` alias over `distributions.weightedErrorMessage`.
- Added `prelude.WeightedError` and `prelude.weightedErrorMessage` aliases.
- Focused tests verify root/prelude alias equality and message parity with the
distribution namespace.

## Focused validation

```text
$ zig test src/root.zig --test-filter "root weighted error"
1/2 root.test_0...OK
2/2 root.test.root weighted error aliases mirror distributions...OK
All 2 tests passed.
```

## Result

S4-M1176 is closed for the current bar: weighted diagnostics are discoverable
from root, prelude, and distribution namespaces without adding Rust trait or
error-type machinery. This is not whole-goal completion; S4-M1177 remains
active.
