# S4-M799 IndexVec Fill Direct Backing Paths

## Gap

S4-M791 and S4-M792 reused bulk index-buffer fills for sampled and mapped
value/pointer iterators, and S4-M793 made caller-owned value/pointer mapping
switch once on `IndexVec` backing. The shared base `IndexVec.Iterator.fill` and
`IndexVec.IntoIterator.fill` still called `IndexVec.at()` for every output slot,
which repeated the union dispatch inside high-frequency index fill paths.

## Local `rand` Baseline

The local Rust checkout (`/home/passchaos/Work/rand/src/seq/index.rs`) models
`IndexVecIter` and `IndexVecIntoIter` as enum wrappers around backing slice/vector
iterators (`slice::Iter<u32>` / `vec::IntoIter<u32>` and, on 64-bit targets,
`u64` variants). Iteration dispatches to the active backing iterator instead of
performing an independent `IndexVec::index()` lookup for every item. Alea keeps
its Zig-native explicit `fill` API and applies the same backing-specific idea to
bulk caller-owned fills.

## Implementation

- `src/seq.zig` updates `IndexVec.Iterator.fill` to switch once per fill, copy
  native `usize` backing directly, and map compact `u32` backing directly
  into the caller-owned `usize` destination.
- `src/seq.zig` applies the same direct backing fill path to
  `IndexVec.IntoIterator.fill`, preserving ownership/deinit behavior.
- The focused fill test now covers borrowed compact, borrowed native, consuming
  compact, consuming native, mapped value, const-pointer, and mut-pointer fill
  consumers.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "index vec iterators fill caller-owned buffers"
1/1 seq.test.index vec iterators fill caller-owned buffers...OK
All 1 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
readmecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M799 is closed for the current bar: borrowed and consuming IndexVec iterator
fills now avoid per-slot `at()`/union dispatch and operate directly on backing
storage for each caller-owned fill. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
