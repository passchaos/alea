const std = @import("std");
const SplitMix64 = @import("splitmix64.zig");

const Pcg64 = @This();

const multiplier: u128 = 0x2360ed051fc65da44385df649fccf645;

state: u128,
inc: u128,

pub fn init(seed: u64) Pcg64 {
    var sm = SplitMix64.init(seed);
    return initTwo(sm.next(), sm.next());
}

pub fn initTwo(seed: u64, stream: u64) Pcg64 {
    var self: Pcg64 = .{
        .state = 0,
        .inc = (@as(u128, stream) << 1) | 1,
    };
    _ = self.next();
    self.state +%= seed;
    _ = self.next();
    return self;
}

pub fn random(self: *Pcg64) std.Random {
    return std.Random.init(self, fill);
}

pub fn next(self: *Pcg64) u64 {
    const old = self.state;
    self.state = old *% multiplier +% self.inc;

    const xorshifted: u64 = @truncate((old >> 64) ^ old);
    const rot: u6 = @intCast(old >> 122);
    return std.math.rotr(u64, xorshifted, rot);
}

pub fn fill(self: *Pcg64, buf: []u8) void {
    var i: usize = 0;
    const aligned_len = buf.len - (buf.len & 7);

    while (i < aligned_len) : (i += 8) {
        var bytes: [8]u8 = undefined;
        std.mem.writeInt(u64, &bytes, self.next(), .little);
        @memcpy(buf[i..][0..8], &bytes);
    }

    if (i < buf.len) {
        var bytes: [8]u8 = undefined;
        std.mem.writeInt(u64, &bytes, self.next(), .little);
        @memcpy(buf[i..], bytes[0 .. buf.len - i]);
    }
}

test "pcg64 stream selection is deterministic" {
    var a = Pcg64.initTwo(1, 7);
    var b = Pcg64.initTwo(1, 7);
    var c = Pcg64.initTwo(1, 8);

    var i: usize = 0;
    while (i < 8) : (i += 1) {
        const value_a = a.next();
        const value_b = b.next();
        const value_c = c.next();
        try std.testing.expectEqual(value_a, value_b);
        try std.testing.expect(value_a != value_c);
    }
}

test "pcg64 initTwo has stable snapshots" {
    var stream = Pcg64.initTwo(1, 7);
    try std.testing.expectEqual(@as(u64, 0xf0d8729930c00555), stream.next());
    try std.testing.expectEqual(@as(u64, 0xb70772f9f2173593), stream.next());
}
