# S4-M1243 Stable Iterator Choice Semantics

## Gap

A cross-iteration audit against local Rust `rand 0.10.1` found that Alea's
`chooseIteratorStable` / `chooseIteratorStableFrom` was just an alias for
`chooseIteratorFrom`, which uses a size-hint skip-ahead fast path when the
iterator exposes an exact remaining length (via `sizeHint`, `len`, or
`remaining`). That fast path picks one random index and skips directly to it,
consuming a single RNG draw per call instead of one Bernoulli trial per
element. The draw count therefore depends on whether the iterator reports an
exact length, which breaks the primary purpose of a "stable" iterator choice:
reproducibility across iterator implementations.

Local Rust `rand::seq::IteratorRandom::choose_stable` always uses sequential
coin-flipping (the `CoinFlipper` utility) and never takes the skip-ahead path,
so the RNG stream shape depends only on the elements actually produced by the
iterator, not on the reported `size_hint`. The existing Alea
`chooseIteratorStable*` aliases produced a different stream whenever the
iterator exposed an exact remaining length, contradicting the "Stable" name
and the local Rust semantics.

## Fix

`src/seq.zig` `chooseIteratorStableFrom` no longer delegates to the generic
`chooseIteratorFrom` path that branches on `iteratorExactRemaining`. Instead
it always calls the sequential reservoir sampler `chooseIteratorReservoirFrom`,
which performs one `uintLessThan(seen)` Bernoulli trial per element. The one
carve-out is an exactly-known empty iterator: if `iteratorExactRemaining`
reports `0`, stable choice returns `null` without consuming randomness or
calling `next()`, preserving the library's no-consume contract for trivially
empty inputs (the reservoir algorithm would also consume zero randomness for
an empty iterator, so this is a pure avoidance of an unnecessary `next()` call
on the already-known-empty iterator).

The two affected tests were adjusted to reflect the corrected semantics:

- The "empty exact iterator choice does not read source" test still verifies
  zero `next()` calls and zero RNG consumption for the stable path, because
  the empty carve-out keeps no-consume behavior.
- The "exact-count stable iterator choice does not probe past source" test
  expected the old (incorrect) behavior where a hinted 3-element iterator
  would only call `next()` 3 times (matching the skip-ahead path). After the
  fix, stable choice on a 3-element exact-length iterator makes the same
  `next()` calls as on an unhinted iterator: 4 calls (3 elements + 1
  terminating null). The test was updated to expect 4 calls for both the
  hinted `ExactIter` and the unhinted `PlainIter`, and it still verifies that
  the chosen value and final engine state match between the two iterators.

Non-stable `chooseIteratorFrom` / `chooseIteratorHintedFrom` are unchanged:
they continue to use the one-draw skip-ahead path when an exact remaining
length is available, since callers who want the fastest path (and accept
size-hint-dependent stream shape) should continue to get it.

## Validation

- `zig build test` passes.
- Focused tests:
  - `seq.test.stable iterator choice aliases reservoir selection` verifies
    that both `ScalarPrng` and `DefaultPrng` produce identical chosen values
    and final engine state for a plain (no size hint) iterator when invoked
    through the stable alias and the direct reservoir path, including the
    checked-variant parity.
  - `seq.test.exact-count stable iterator choice does not probe past source`
    verifies that an exact-length iterator and an unhinted iterator produce
    the same chosen value and final engine state through the stable path,
    and that `next()` call counts match between the two (both 4 for 3 items).
  - `seq.test.empty exact iterator choice does not read source` verifies
    zero `next()` calls and zero RNG consumption for the stable path on an
    empty exact-length iterator.
- `zig build validate` passes: `statcheck`, `profilecheck`, `distcheck`,
  example checks, and PractRand self-test all succeed.

## Local Rust reference

Local `rand 0.10.1` source:

```text
$ sed -n '145,186p' ~/Work/rand/src/seq/iterator.rs
    fn choose_stable<R>(mut self, rng: &mut R) -> Option<Self::Item>
    where
        R: Rng + ?Sized,
    {
        let mut consumed = 0;
        let mut result = None;
        let mut coin_flipper = CoinFlipper::new(rng);

        loop {
            let mut next = 0;

            let (lower, _) = self.size_hint();
            if lower >= 2 {
                let highest_selected = (0..lower)
                    .filter(|ix| coin_flipper.random_ratio_one_over(consumed + ix + 1))
                    .last();

                consumed += lower;
                next = lower;

                if let Some(ix) = highest_selected {
                    result = self.nth(ix);
                    next -= ix + 1;
                    debug_assert!(result.is_some(), ...);
                }
            }

            let elem = self.nth(next);
            if elem.is_none() {
                return result;
            }

            if coin_flipper.random_ratio_one_over(consumed + 1) {
                result = elem;
            }
            consumed += 1;
        }
    }
```

The Rust `choose_stable` implementation uses a `CoinFlipper` to perform the
1/k Bernoulli trials with ~2 expected bits of randomness per trial, and it
does use `size_hint().lower` as a *batching hint* to process up to `lower`
elements at once via `nth`, but it never replaces the reservoir with a single
indexed skip. Alea's simpler sequential reservoir implementation has the same
observable stream-shape property (RNG draws depend only on consumed elements,
not on the reported remaining length) and is easier to reason about, so it
was chosen over a port of the `CoinFlipper` batching optimization for now.
