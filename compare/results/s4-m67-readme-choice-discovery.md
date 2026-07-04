# S4-M67 README Quick-Start Index/Pointer Discovery

Date: 2026-07-04

Purpose: keep first-contact documentation aligned with recently added collection
choice APIs. The README quick start should not lag behind the focused examples
for basic one-shot index and const-pointer selection.

## Change

Updated `README.md` Quick Start:

- adds `rng.chooseIndex(items.len)`;
- adds `rng.chooseConstPtr(u32, &items)`;
- keeps the existing partial-shuffle sample.

Updated `tools/readmecheck.zig`:

- verifies `rng.chooseIndex` appears in README;
- verifies `rng.chooseConstPtr` appears in README.

Updated `docs/tooling.md` to describe `readmecheck` as verifying README
discovery links, quick-start API tokens, and validation commands.

## Validation

Commands:

```sh
git diff --check
zig build readmecheck
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

## S4-M67 Decision

S4-M67 is closed for the current README discovery bar: first-contact docs and the
README checker now keep one-shot index and const-pointer choice visible.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
