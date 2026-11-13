const std = @import("std");
const chacha = @import("chacha.zig");

pub const ChaCha8Rng = chacha.ChaChaRng(std.crypto.stream.chacha.ChaCha8IETF);

test "chacha8 deterministic bytes" {
    var a = ChaCha8Rng.initFromU64(42);
    var b = ChaCha8Rng.initFromU64(42);
    var buf_a: [128]u8 = undefined;
    var buf_b: [128]u8 = undefined;

    a.fill(&buf_a);
    b.fill(&buf_b);
    try std.testing.expectEqualSlices(u8, &buf_a, &buf_b);
}

test "chacha8 fill has stable byte snapshot" {
    var rng = ChaCha8Rng.initFromU64(0x1234_5678_9abc_def0);
    var buf: [24]u8 = undefined;
    rng.fill(&buf);
    try std.testing.expectEqualSlices(u8, &.{
        0x67, 0x1e, 0x7f, 0x50, 0xcb, 0x64, 0x66, 0x45,
        0x3c, 0x4f, 0x2d, 0x9b, 0x3b, 0xc6, 0x0f, 0x5a,
        0x06, 0xf7, 0x6e, 0xe5, 0x9a, 0xc8, 0x35, 0x64,
    }, &buf);
}

test "chacha8 addEntropy has stable byte snapshot" {
    var rng = ChaCha8Rng.initFromU64(0x1234_5678_9abc_def0);
    rng.addEntropy("session-a");
    rng.addEntropy(&.{ 0, 1, 2, 3, 4, 5 });
    var buf: [24]u8 = undefined;
    rng.fill(&buf);
    try std.testing.expectEqualSlices(u8, &.{
        0x88, 0xdf, 0xb2, 0xe7, 0xf9, 0x69, 0x8c, 0x21,
        0xf0, 0xdd, 0x94, 0x80, 0x45, 0x1b, 0x16, 0xe7,
        0xbb, 0x7e, 0x02, 0x10, 0xda, 0xc1, 0xeb, 0x20,
    }, &buf);
}
