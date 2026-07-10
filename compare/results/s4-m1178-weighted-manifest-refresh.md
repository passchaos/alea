# S4-M1178 Weighted Manifest Refresh

## Gap

Recent weighted work closed several diagnostics and ergonomics gaps after the
original local Rust and `rand_distr` public-surface manifests were written. The
manifests needed to record those closures explicitly so future audits do not
rediscover the same weighted iterator, weighted error message, and root/prelude
weighted error alias surfaces as new gaps.

## Updates

- `compare/results/s4-m288-local-rand-public-surface-manifest.md` now maps
  `WeightedIndexIter`, weighted error diagnostics, and `weighted::Error`
  discovery to the S4-M1172 weighted iterator clone/format helpers, S4-M1174
  weighted error message helpers, and S4-M1176 root/prelude weighted error
  aliases.
- `compare/results/s4-m294-rand-distr-public-surface-manifest.md` now maps
  `WeightedAliasIndex` diagnostics and `WeightedTreeIndex` `new` / `Default` /
  `Clone` / `Debug` / `PartialEq` / `try_sample` workflows to S4-M1167 through
  S4-M1176 closures and the distribution parity matrix.

## Validation

```text
$ git diff -- compare/results/s4-m288-local-rand-public-surface-manifest.md compare/results/s4-m294-rand-distr-public-surface-manifest.md
# manifests cite S4-M1172, S4-M1174, and S4-M1176 weighted closures

$ git diff --check

$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ zig build rand-status-self-test
rand-status self-test ok
```

## Result

S4-M1178 is closed for the current bar: local Rust and cached `rand_distr`
weighted manifest coverage is refreshed after the recent weighted closures.
This is audit evidence, not whole-goal completion; S4-M1179 remains active.
