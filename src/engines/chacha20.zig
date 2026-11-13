const std = @import("std");
const chacha = @import("chacha.zig");

pub const ChaCha20Rng = chacha.ChaChaRng(std.crypto.stream.chacha.ChaCha20IETF);

test "chacha20 deterministic bytes" {
    var a = ChaCha20Rng.initFromU64(42);
    var b = ChaCha20Rng.initFromU64(42);
    var buf_a: [128]u8 = undefined;
    var buf_b: [128]u8 = undefined;

    a.fill(&buf_a);
    b.fill(&buf_b);
    try std.testing.expectEqualSlices(u8, &buf_a, &buf_b);
}

test "chacha20 fill has stable byte snapshot" {
    var rng = ChaCha20Rng.initFromU64(0x1234_5678_9abc_def0);
    var buf: [24]u8 = undefined;
    rng.fill(&buf);
    try std.testing.expectEqualSlices(u8, &.{
        0xe6, 0x5f, 0xc9, 0x68, 0x91, 0xcf, 0xea, 0xfa,
        0xc0, 0x33, 0x54, 0x27, 0x8f, 0x47, 0x60, 0x75,
        0x57, 0x94, 0xa1, 0x5d, 0xf9, 0xb8, 0x90, 0x6c,
    }, &buf);
}

test "chacha20 addEntropy has stable byte snapshot" {
    var rng = ChaCha20Rng.initFromU64(0x1234_5678_9abc_def0);
    rng.addEntropy("session-a");
    rng.addEntropy(&.{ 0, 1, 2, 3, 4, 5 });
    var buf: [24]u8 = undefined;
    rng.fill(&buf);
    try std.testing.expectEqualSlices(u8, &.{
        0x6c, 0xa0, 0x3f, 0xf4, 0x0b, 0xb8, 0xb8, 0xf9,
        0xd8, 0xd3, 0xb9, 0xd3, 0xff, 0xcb, 0x20, 0xdd,
        0x7a, 0x18, 0x62, 0xf2, 0xed, 0x97, 0xe9, 0xba,
    }, &buf);
}
