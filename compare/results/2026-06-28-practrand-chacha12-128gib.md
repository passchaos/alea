# PractRand 128GiB Run: ChaCha12

Timestamp: 2026-06-28 CST

PractRand 0.96 was built under `/tmp/practrand/PractRand`. `ChaCha12` was
tested through `zig build stream` with `stdin64`, `-tlmin 128GB`, and `-tlmax
128GB`.

## Command

```sh
zig build -Doptimize=ReleaseFast stream -- --engine chacha12 --bytes 137438953472 \
  | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 128GB -tlmax 128GB
```

## Result

```text
RNG_test using PractRand version 0.96
RNG = RNG_stdin64, seed = unknown
test set = core, folding = standard (64 bit)

rng=RNG_stdin64, seed=unknown
length= 128 gigabytes (2^37 bytes), time= 980 seconds
  no anomalies in 320 test result(s)
```
