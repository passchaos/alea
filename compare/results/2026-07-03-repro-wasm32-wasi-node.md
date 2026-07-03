# Reproducibility Snapshot: wasm32-wasi via Node WASI

Timestamp: 2026-07-03 CST

Environment:

```text
Host: Linux robot-NUC13RNGi5 6.8.0-124-generic x86_64
Zig 0.16.0
Target: wasm32-wasi
Runner: Node.js v26.4.0 `node:wasi` preview1 runtime
```

Commands:

```sh
zig build test-wasi
zig build wasi-report
```

`test-wasi` compiles `src/root.zig` for `wasm32-wasi` and executes the Zig unit
suite through `tools/run_wasi_test.js`. It passed all 217 unit tests, including
stable snapshot and stream-shape tests.

`wasi-report` compiles and runs `tools/repro.zig`, `tools/statcheck.zig`, and
`tools/distcheck.zig` for `wasm32-wasi` through the same Node WASI runner.

Output:

```text
alea4x64 0x5cdd12b4692c7acc 0x132e71f2d82fb474 0xb102719d1ed3258e 0x3cd7656419d1e4a9 0xcf25d6c3393a21c 0xfa2b6f1d90be9edc 0x201c8ddee03dd597 0xfe3b3b834a82545e
wyhash64 0xea6ec06239837012 0xfaa96b2855c28b16 0xf4d6d1d0d25b0c23 0x90f4deca828bdc47 0xec54c7f0880c4187 0xb1e782f4db5a48ff 0xed8daad2cd1bcc93 0xb0e79b89102c1d45
xoshiro256 0xcf1350dcca3debe9 0xacc53b3fb46c231f 0x17d76a4d73642536 0xe573ffdbe8dfbf83 0x9ead861bfcab7610 0x56d3d3ff75d17a51 0x38f2b88d6d71a195 0xea19f8079a35ad2d
xoshiro256++ 0x90f04d8eb6e86ab7 0xa4d43de824364ec2 0x328afd223e55c09c 0xef51b3efc9e8cf18 0x6e9cecb1524379c5 0x2231cf91567b40be 0x46690abd2ffc8134 0xe72c526bd82fbebb
pcg64 0xd107c87cf47826e3 0xee753d681e2cdd8a 0xe8ee7e617e86b26a 0xa6f045ea9a163b88 0xae5512586de842c7 0x1beca7be9d55cac3 0xf32cb250ff5dbf82 0x8e7b9794033a7e41
chacha12 0xbad83e8d1668dd87 0x7ffeae133c896656 0x6ebc7b40925fd959 0xb5eefeef8c409b9f 0x386f2e19cbcc1124 0xf6ad3ecd2eb7dd71 0x62e118fdfb3333f1 0x1ff1f9f4582a907e
seed.fromString(repro)=0x80d3f431deaa1604
seed.stream(7)=0x57d26fe02eebb5a4
statcheck ok
distcheck ok
```

Interpretation:

- The reproducibility snapshot matches `compare/results/2026-06-28-repro-x86_64-linux.md`.
- `statcheck` and `distcheck` both pass when executed under the `wasm32-wasi`
  target, giving a second executed target for Stage 4 reproducibility evidence.
- Enabling the WASI execution exposed and fixed target-width/alignment-sensitive
  byte mappings: ASCII charset sampling now uses a u64 bounded draw for stable
  32-bit/64-bit target output, and `Xoshiro256PlusPlus.fill` now writes explicit
  little-endian words instead of depending on pointer alignment.
