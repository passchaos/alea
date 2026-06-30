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

pub fn random(self: *Xoshiro256PlusPlus) std.Random {
    return std.Random.init(self, fill);
}

pub inline fn next(self: *Xoshiro256PlusPlus) u64 {
    const result = std.math.rotl(u64, self.state[0] +% self.state[3], 23) +% self.state[0];
    step(self);
    return result;
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
    const prefix_len = std.mem.alignForward(usize, @intFromPtr(buf.ptr), @alignOf(u64)) - @intFromPtr(buf.ptr);
    const prefix = @min(prefix_len, buf.len);
    while (i < prefix) : (i += 1) {
        const n = self.next();
        buf[i] = @truncate(n);
    }

    const words = std.mem.bytesAsSlice(u64, buf[i .. buf.len - ((buf.len - i) & 7)]);
    for (words) |*word| {
        word.* = if (comptime @import("builtin").target.cpu.arch.endian() == .little) self.next() else @byteSwap(self.next());
    }
    i += words.len * 8;

    if (i < buf.len) {
        var n = self.next();
        while (i < buf.len) : (i += 1) {
            buf[i] = @truncate(n);
            n >>= 8;
        }
    }
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
        0xd6, 0x21, 0xbc, 0x83, 0xf8, 0x9f, 0x8b, 0x13,
        0x80, 0x7c, 0x21, 0xfc, 0x00, 0xd0, 0xe9, 0x4f,
        0xc0, 0x03, 0x9c, 0xab, 0x5c, 0x58, 0x75, 0x33,
    }, &buf);
}
