# Stream Exporter Validation

Timestamp: 2026-06-28 CST

The raw stream exporter is intended for external statistical tools such as
PractRand/TestU01-compatible pipelines.

## Local Tool Availability

The following commands were checked and were not available in the local shell:

```sh
RNG_test
practrand
ent
dieharder
```

## Smoke Command

```sh
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1048576 > /tmp/alea-fast-1m.bin
sha256sum /tmp/alea-fast-1m.bin
wc -c /tmp/alea-fast-1m.bin
```

Output:

```text
084fb19d7e0d99bff82856f1869c6b155856b3bbbcb2a5f08b4d40a5d9c7fbe3  /tmp/alea-fast-1m.bin
1048576 /tmp/alea-fast-1m.bin
```

## External Test Command

When PractRand is available, run:

```sh
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1073741824 | RNG_test stdin64
```

Repeat for `default`, `wyhash64`, `pcg64`, `xoshiro256++`, and `chacha12`
before treating the engine quality claim as externally validated.
