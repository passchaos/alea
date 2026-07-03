# Cross-Platform Reproducibility Infrastructure Blocker

`S4-M1` raises the previous local-only reproducibility requirement. It requires
stable-output validation on at least one additional OS or architecture, or a
strong blocker with exact missing infrastructure. The original blocker is now
resolved for the current Stage 4 bar by a Node-backed `wasm32-wasi` runner; this
file remains as the infrastructure history and follow-up note for broader
non-WASI runners.

## Local Environment

Available Zig installations:

```text
/home/passchaos/Temp/zig-x86_64-linux-0.16.0/zig
/home/passchaos/.zvm/0.15.2/zig
```

Host:

```text
Linux robot-NUC13RNGi5 6.8.0-124-generic #124-Ubuntu SMP PREEMPT_DYNAMIC Tue May 26 13:00:45 UTC 2026 x86_64 x86_64 x86_64 GNU/Linux
```

Only the Zig 0.16.0 x86_64 Linux toolchain is installed natively in the current
environment. Zig can cross-compile to other targets, and Node.js now provides a
WASI runtime for the `wasm32-wasi` evidence below.

Checked runtime tools on 2026-07-03:

```text
qemu-aarch64: missing
qemu-riscv64: missing
wine: missing
wasmtime: missing
node: v26.4.0 with `node:wasi` preview1 support
```

There is no local Zig 0.16.0 aarch64, macOS, Windows, or RISC-V runner
available for executing `zig build repro`, `zig build test`, and
`zig build -Doptimize=ReleaseFast distcheck` on those broader platforms. The
local Node.js runtime is sufficient for the current `wasm32-wasi` evidence.

## Completed Evidence

The current x86_64 Linux baseline is checked in at:

```text
compare/results/2026-06-28-repro-x86_64-linux.md
```

The x86_64 Linux snapshot was re-run during S4-M1 review and still matches the
checked-in baseline. It was rechecked again on 2026-07-01 with `zig build repro`,
`zig build test`, and `zig build -Doptimize=ReleaseFast statcheck`; all passed
on the local x86_64 Linux Zig 0.16.0 toolchain. The second-platform runtime
blocker was refreshed on 2026-07-02 with `command -v qemu-aarch64`,
`command -v qemu-riscv64`, `command -v wine`, `command -v wasmtime`,
`uname -a`, and `zig version`; the host is still x86_64 Linux with Zig 0.16.0
and no second-platform runtime was available. It was refreshed again on
2026-07-03 with the same runtime checks, plus `zig build repro`,
`zig build test`, and `zig build -Doptimize=ReleaseFast statcheck`; all passed
locally, and no second-platform runtime was available. A follow-up
WASI compile-only smoke check, `zig test -target wasm32-wasi -fno-emit-bin
src/root.zig`, now succeeds after removing a test-only `u64` output-buffer
assumption that was invalid on 32-bit `usize` targets. The build now exposes a
repeatable `zig build crosscheck` step which compile-checks the unit tests for
`wasm32-wasi`, `aarch64-linux`, `riscv64-linux`, `x86_64-windows`, `x86_64-macos`, and `aarch64-macos` without executing them. The
local Node.js WASI runtime can execute the wasm32-wasi unit test binary through
`zig build test-wasi`; this exercises the checked-in stable snapshot and
stream-shape unit tests on a 32-bit `usize` WASI target. Enabling that runtime
check required making ASCII charset bounded draws target-width independent and
making `Xoshiro256PlusPlus.fill` use explicit little-endian word writes instead
of pointer-alignment-dependent word casting. The WASI report is checked in at
`compare/results/2026-07-03-repro-wasm32-wasi-node.md`, closing the current
S4-M1 second-target evidence bar. QEMU/Wine/native second-OS runners are still
not installed locally, so broader non-WASI platform coverage is the next
portability bar beyond the current Stage 4 milestone.

## Follow-Up

Keep the local cross-target checks green:

```sh
zig build crosscheck
zig build test-wasi
zig build wasi-report
```

To raise the bar beyond the current WASI evidence, provide one of:

- a second physical or virtual runner with Zig 0.16.0,
- a working QEMU user-mode runner for a non-x86_64 Linux target,
- a Windows runner or Wine setup suitable for Zig 0.16.0 outputs.

Then run:

```sh
zig build repro
zig build test
zig build -Doptimize=ReleaseFast statcheck
zig build -Doptimize=ReleaseFast distcheck
```

Then add another snapshot report and compare the stable-output rows against the
x86_64 Linux and wasm32-wasi baselines.
