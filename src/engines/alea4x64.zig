const std = @import("std");
const SplitMix64 = @import("splitmix64.zig");

const Alea4x64 = @This();

const increment = [_]u64{
    0xa0761d6478bd642f,
    0xe7037ed1a0b428db,
    0x8ebc6af09c88c6e3,
    0x589965cc75374cc3,
};

state: [4]u64,

pub fn init(seed_value: u64) Alea4x64 {
    var sm = SplitMix64.init(seed_value);
    return .{ .state = .{ sm.next(), sm.next(), sm.next(), sm.next() } };
}

pub fn seedFromU64(seed: u64) Alea4x64 {
    return init(seed);
}

pub fn fromSeed(seed: anytype) Alea4x64 {
    return init(seed.state);
}

pub fn fromSeedBytes(seed: [32]u8) Alea4x64 {
    return .{ .state = .{
        std.mem.readInt(u64, seed[0..8], .little),
        std.mem.readInt(u64, seed[8..16], .little),
        std.mem.readInt(u64, seed[16..24], .little),
        std.mem.readInt(u64, seed[24..32], .little),
    } };
}

pub fn fromRng(source: anytype) Alea4x64 {
    return .{ .state = .{ source.next(), source.next(), source.next(), source.next() } };
}

pub fn tryFromRng(source: anytype) !Alea4x64 {
    return .{ .state = .{
        try source.tryNext(),
        try source.tryNext(),
        try source.tryNext(),
        try source.tryNext(),
    } };
}

pub fn random(self: *Alea4x64) std.Random {
    return std.Random.init(self, fill);
}

pub inline fn next(self: *Alea4x64) u64 {
    return lane(self, 0);
}

pub fn tryNext(self: *Alea4x64) !u64 {
    return self.next();
}

pub fn nextU64(self: *Alea4x64) u64 {
    return self.next();
}

pub fn nextU32(self: *Alea4x64) u32 {
    return @truncate(self.next() >> 32);
}

pub fn fill(self: *Alea4x64, buf: []u8) void {
    var i: usize = 0;
    const aligned_len = buf.len - (buf.len & 31);

    while (i < aligned_len) : (i += 32) {
        std.mem.writeInt(u64, buf[i..][0..8], lane(self, 0), .little);
        std.mem.writeInt(u64, buf[i + 8 ..][0..8], lane(self, 1), .little);
        std.mem.writeInt(u64, buf[i + 16 ..][0..8], lane(self, 2), .little);
        std.mem.writeInt(u64, buf[i + 24 ..][0..8], lane(self, 3), .little);
    }

    while (i + 8 <= buf.len) : (i += 8) {
        std.mem.writeInt(u64, buf[i..][0..8], self.next(), .little);
    }

    if (i < buf.len) {
        var n = self.next();
        while (i < buf.len) : (i += 1) {
            buf[i] = @truncate(n);
            n >>= 8;
        }
    }
}

pub fn fillBytes(self: *Alea4x64, buf: []u8) void {
    self.fill(buf);
}

pub fn fork(self: *Alea4x64) Alea4x64 {
    return fromRng(self);
}

pub fn tryFork(self: *Alea4x64) !Alea4x64 {
    return tryFromRng(self);
}

inline fn lane(self: *Alea4x64, comptime i: usize) u64 {
    self.state[i] +%= increment[i];
    var z = self.state[i];
    z = (z ^ (z >> 30)) *% 0xbf58476d1ce4e5b9;
    z = (z ^ (z >> 27)) *% 0x94d049bb133111eb;
    return z ^ (z >> 31);
}

test "alea4x64 deterministic" {
    var a = Alea4x64.init(5);
    var b = Alea4x64.init(5);
    var buf_a: [257]u8 = undefined;
    var buf_b: [257]u8 = undefined;
    a.fill(&buf_a);
    b.fill(&buf_b);
    try std.testing.expectEqualSlices(u8, &buf_a, &buf_b);
}

test "alea4x64 fill has stable byte snapshot" {
    var rng = Alea4x64.init(0x1234_5678_9abc_def0);
    var buf: [24]u8 = undefined;
    rng.fill(&buf);
    try std.testing.expectEqualSlices(u8, &.{
        0x30, 0x9f, 0x7a, 0x9a, 0x5e, 0xbd, 0xfc, 0x99,
        0x44, 0x32, 0x1e, 0x91, 0x5a, 0x05, 0xe4, 0xdb,
        0xe9, 0x31, 0x6c, 0xab, 0x40, 0x5b, 0xfa, 0x08,
    }, &buf);
}
