# PractRand 16GiB Runs

Timestamp: 2026-06-28 CST

PractRand 0.96 was built under `/tmp/practrand/PractRand`. The following
engines were tested through `zig build stream` with `stdin64`, `-tlmin 16GB`,
and `-tlmax 16GB`.

## Commands

```sh
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 17179869184 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 16GB -tlmax 16GB
zig build -Doptimize=ReleaseFast stream -- --engine default --bytes 17179869184 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 16GB -tlmax 16GB
zig build -Doptimize=ReleaseFast stream -- --engine wyhash64 --bytes 17179869184 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 16GB -tlmax 16GB
zig build -Doptimize=ReleaseFast stream -- --engine pcg64 --bytes 17179869184 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 16GB -tlmax 16GB
zig build -Doptimize=ReleaseFast stream -- --engine 'xoshiro256++' --bytes 17179869184 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 16GB -tlmax 16GB
zig build -Doptimize=ReleaseFast stream -- --engine chacha12 --bytes 17179869184 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 16GB -tlmax 16GB
```

## Results

| Engine | Result | Time |
| --- | --- | --- |
| `fast` / `Alea4x64` | no anomalies in 283 test results | 124s |
| `default` / `Xoshiro256` | no anomalies in 283 test results | 125s |
| `wyhash64` | no anomalies in 283 test results | 123s |
| `pcg64` | no anomalies in 283 test results | 123s |
| `xoshiro256++` | no anomalies in 283 test results | 122s |
| `chacha12` | no anomalies in 283 test results | 126s |

Each run reported `test set = core, folding = standard (64 bit)` and length
`16 gigabytes (2^34 bytes)`.
