# PractRand 1GiB Smoke: Xoshiro256PlusPlus Portable Fill

Timestamp: 2026-07-03 CST

This smoke run was added after `Xoshiro256PlusPlus.fill` switched from a
pointer-alignment-dependent word-cast implementation to explicit little-endian
word writes. The engine `next()` sequence is unchanged, but the byte-fill stream
mapping is now target-width and pointer-alignment independent.

## Command

```sh
zig build -Doptimize=ReleaseFast stream -- --engine 'xoshiro256++' --bytes 1073741824 \
  | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 1GB -tlmax 1GB
```

## Result

```text
RNG_test using PractRand version 0.96
RNG = RNG_stdin64, seed = unknown
test set = core, folding = standard (64 bit)

rng=RNG_stdin64, seed=unknown
length= 1 gigabyte (2^30 bytes), time= 8.0 seconds
  no anomalies in 227 test result(s)
```

## Interpretation

The 1GiB smoke is clean for the new portable `fill` byte mapping. The earlier
64GiB/128GiB `xoshiro256++` PractRand reports remain evidence for the unchanged
engine transition function; a longer rerun of the portable `fill` stream can be
added when raising the statistical bar again.
