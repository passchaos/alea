# S4-M1234 Root String Preallocation Hardening

## Gap

The root one-shot string helpers use system entropy internally. `string`,
`sampleString`, and `appendString` previously requested secure entropy before
performing the output allocation/growth needed by the returned or appended
string. That meant allocation failures were hidden behind entropy failures when
using a failing `std.Io`, and `appendString` could not explicitly guarantee that
visible list contents remain unchanged if entropy fails after capacity growth.

This is a correctness/structure issue in the public root convenience layer:
root helpers elsewhere generally prevalidate deterministic and allocation-failure
paths before secure-engine construction so failure ordering is predictable and
no random stream is consumed for allocation failures.

## Change

`src/root.zig` now:

- factors root alphanumeric owned string generation through
  `rootAlphanumericAlloc`, which allocates the output slice before requesting
  secure entropy and frees it on entropy failure;
- routes both `string` and `sampleString` through that helper;
- updates `appendString` to reserve caller-owned list capacity before entropy,
  advance `items.len` only after entropy succeeds, and preserve visible contents
  on entropy failure or length overflow.

The change intentionally keeps `unicodeUtf8Alloc` unchanged: its final UTF-8
length is variable and may require `toOwnedSlice` to shrink after sampling.
Existing tests already cover its zero-length, initial allocation failure, and
length-overflow prevalidation behavior.

## Validation

Focused test:

```console
$ zig test src/root.zig --test-filter "root string allocation paths allocate before entropy"
1/2 root.test_0...OK
2/2 root.test.root string allocation paths allocate before entropy...OK
All 2 tests passed.
```

Full validation for the committed change:

```console
$ zig build test
$ zig build validate
$ zig build validate-local
$ zig build crosscheck
$ zig build roadmapcheck toolingcheck rand-status-self-test
$ git diff --check
```

## Result

S4-M1234 closes the root alphanumeric string allocation-order follow-up: root
owned/appended ASCII strings now allocate or reserve before secure entropy and
preserve caller-visible output on allocation/entropy failures. The whole product
goal remains active under the next S4-M1235 bar.
