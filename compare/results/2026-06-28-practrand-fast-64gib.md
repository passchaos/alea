# PractRand 64GiB Run: FastPrng

Timestamp: 2026-06-28 CST

PractRand 0.96 was built under `/tmp/practrand/PractRand`. `FastPrng`
(`Alea4x64`) was tested through `zig build stream` with `stdin64`, `-tlmin
64GB`, and `-tlmax 64GB`.

## Command

```sh
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 68719476736 \
  | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 64GB -tlmax 64GB
```

## Result

```text
RNG_test using PractRand version 0.96
RNG = RNG_stdin64, seed = unknown
test set = core, folding = standard (64 bit)

rng=RNG_stdin64, seed=unknown
length= 64 gigabytes (2^36 bytes), time= 473 seconds
  no anomalies in 308 test result(s)
```
