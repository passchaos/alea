# S4-M1728 1e7 Long-Run Refresh After The Gamma/Erlang Changes

Date: 2026-11-16

## Result

`zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
`distlongcheck ok (10000000 samples)` with the S4-M1724 inline free-function
gamma kernel and the S4-M1726 Erlang delegation present. The changes are
stream-preserving (the gamma/beta/erlang benchmark checksums are unchanged),
and the long gates confirm the gamma-derived distributions still match:

```
long continuous cdf: beta(0.3)=0.579888 gamma(3)=0.450438
  student-t(0)=0.499955 fisher-f(1)=0.534954 ...
long tails: normal=0.002714 exponential=0.049740
  student-t=0.030199 (expected 0.030099)
long copula 1% joint lower-tail rates: gaussian=0.001869
  student-t=0.003957
distlongcheck ok (10000000 samples)
```

The 1e9 evidence remains `compare/results/s4-m1723-1e9-long-run-refresh.md`;
the gamma/erlang changes do not alter any stream, so that result stands.

## Changed Files

- `compare/results/s4-m1728-1e7-long-run-refresh.md`: this evidence file.
