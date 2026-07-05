const std = @import("std");
const SplitMix64 = @import("splitmix64.zig");

const Xoshiro256PlusPlus = @This();

state: [4]u64,

pub fn init(seed_value: u64) Xoshiro256PlusPlus {
    var self: Xoshiro256PlusPlus = .{ .state = undefined };
    var sm = SplitMix64.init(seed_value);
    inline for (0..4) |i| self.state[i] = sm.next();
    return self;
}

pub fn seedFromU64(seed_value: u64) Xoshiro256PlusPlus {
    return init(seed_value);
}

pub fn random(self: *Xoshiro256PlusPlus) std.Random {
    return std.Random.init(self, fill);
}

pub inline fn next(self: *Xoshiro256PlusPlus) u64 {
    const result = std.math.rotl(u64, self.state[0] +% self.state[3], 23) +% self.state[0];
    step(self);
    return result;
}

pub fn nextU64(self: *Xoshiro256PlusPlus) u64 {
    return self.next();
}

pub fn nextU32(self: *Xoshiro256PlusPlus) u32 {
    return @truncate(self.next() >> 32);
}

pub fn jump(self: *Xoshiro256PlusPlus) void {
    jumpBy(self, &.{
        0x180ec6d33cfd0aba,
        0xd5a61266f0c9392c,
        0xa9582618e03fc9aa,
        0x39abdc4529b1661c,
    });
}

pub fn fill(self: *Xoshiro256PlusPlus, buf: []u8) void {
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

pub fn fillBytes(self: *Xoshiro256PlusPlus, buf: []u8) void {
    self.fill(buf);
}

inline fn step(self: *Xoshiro256PlusPlus) void {
    const t = self.state[1] << 17;

    self.state[2] ^= self.state[0];
    self.state[3] ^= self.state[1];
    self.state[1] ^= self.state[2];
    self.state[0] ^= self.state[3];
    self.state[2] ^= t;
    self.state[3] = std.math.rotl(u64, self.state[3], 45);
}

fn jumpBy(self: *Xoshiro256PlusPlus, table: []const u64) void {
    var next_state = [_]u64{0} ** 4;

    for (table) |jump_bits| {
        var bits = jump_bits;
        var b: usize = 0;
        while (b < 64) : (b += 1) {
            if ((bits & 1) != 0) {
                inline for (0..4) |i| next_state[i] ^= self.state[i];
            }
            _ = self.next();
            bits >>= 1;
        }
    }

    self.state = next_state;
}

test "xoshiro256++ deterministic" {
    var a = Xoshiro256PlusPlus.init(12);
    var b = Xoshiro256PlusPlus.init(12);
    var i: usize = 0;
    while (i < 32) : (i += 1) try std.testing.expectEqual(a.next(), b.next());
}

test "xoshiro256++ jump has stable snapshots" {
    var jumped = Xoshiro256PlusPlus.init(99);
    jumped.jump();
    try std.testing.expectEqual(@as(u64, 0xcbf20e55c1eca77c), jumped.next());
    try std.testing.expectEqual(@as(u64, 0x65b235c8b9458037), jumped.next());
}

test "xoshiro256++ fill has stable byte snapshot" {
    var rng = Xoshiro256PlusPlus.init(0x1234_5678_9abc_def0);
    var buf: [24]u8 = undefined;
    rng.fill(&buf);
    try std.testing.expectEqualSlices(u8, &.{
        0xd6, 0x1b, 0x7a, 0xa9, 0x07, 0x76, 0x4f, 0x4d,
        0x21, 0xd0, 0x10, 0x69, 0xc7, 0x27, 0xa0, 0x9b,
        0xbc, 0xe0, 0x3a, 0x15, 0x62, 0xb0, 0xad, 0x87,
    }, &buf);
}
