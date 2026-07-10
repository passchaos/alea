# S4-M1172 Weighted Iterator Clone and Format Helpers

## Gap

After S4-M1171 refreshed `validate-all`, the next local Rust weighted audit
found an iterator ergonomics gap. Local `rand::distr::weighted::WeightedIndex`
returns `WeightedIndexIter` from `weights()`, and that iterator implements both
`Clone` and `Debug`.

Local Rust source evidence:

```text
$ rg -n "WeightedIndexIter|impl<X> Debug|impl<X> Clone" ~/Work/rand/src/distr/weighted/weighted_index.rs
~/Work/rand/src/distr/weighted/weighted_index.rs:244:pub struct WeightedIndexIter<'a, X: SampleUniform + PartialOrd> {
~/Work/rand/src/distr/weighted/weighted_index.rs:249:impl<X> Debug for WeightedIndexIter<'_, X>
~/Work/rand/src/distr/weighted/weighted_index.rs:262:impl<X> Clone for WeightedIndexIter<'_, X>
~/Work/rand/src/distr/weighted/weighted_index.rs:342:    pub fn weights(&self) -> WeightedIndexIter<'_, X>
```

Alea already had lazy weighted `weightIter` / `probabilityIter` helpers with
size hints and fill methods. S4-M1172 adds explicit Zig-native clone and format
helpers to those iterators without importing Rust trait shapes.

## Implementation

- `AliasTable(Weight).WeightIterator` and `.ProbabilityIterator` now expose:
  - `clone()`, preserving the current iterator cursor;
  - `format(writer)`, supporting `std.Io.Writer.print("{f}", .{iter})` debug
    snapshots with current index and remaining length.
- `WeightedTree(Weight)` and `WeightedIntTree(Weight)` weight/probability
  iterators expose the same helpers.
- Focused tests verify cloned iterators resume from the same cursor for static
  alias tables, generic dynamic trees, and integer dynamic trees, and verify the
  `{f}` formatter names for each iterator family.
- API reference, core guide, parity matrix, status output, and roadmap guards
  now record the S4-M1172 closure and raise the active product bar to S4-M1173.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "weighted iterator clone"
1/1 distributions.test.weighted iterator clone and format mirror local Rust iterator helpers...OK
All 1 tests passed.
```

## Full validation

```text
$ git diff --check

$ zig build apicheck
apicheck ok

$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ zig build rand-status-self-test
rand-status self-test ok

$ zig test src/distributions.zig --test-filter "weighted"
1/122 distributions.test.weighted samplers clone and equality mirror local Rust derives...OK
...
122/122 seq.test.sampleIteratorWeightedArray returns fixed-size weighted iterator samples...OK
All 122 tests passed.

$ zig build test
apicheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok

$ zig build validate-local
practrand self-test ok
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
runtimecheck ok: no additional runtime runner available
"current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1172 follow-ups closed for current bar"
"remaining_blocker": "S4-M1173 post-S4-M1172 next product bar"
"latest_validate_local_evidence": "compare/results/s4-m1172-weighted-iterator-clone-format.md"
rand-status self-test ok
rand_distr standard-normal: 23.8 M samples/s checksum=-3.640
rand_distr standard-normal f32: 16.9 M samples/s checksum=-3.640
```

## Result

S4-M1172 is closed for the current bar: Alea's lazy weighted iterators now cover
local Rust `WeightedIndexIter` clone/debug-style workflows with Zig-native
`clone` and `{f}` format helpers. This is not whole-goal completion; S4-M1173
remains active.
