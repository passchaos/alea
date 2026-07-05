const std = @import("std");
const SplitMix64 = @import("splitmix64.zig");

const Wyhash64 = @This();

const secret = [_]u64{
    0xa0761d6478bd642f,
    0xe7037ed1a0b428db,
    0x8ebc6af09c88c6e3,
    0x589965cc75374cc3,
};

state: u64,

pub fn init(seed: u64) Wyhash64 {
    var sm = SplitMix64.init(seed);
    return .{ .state = sm.next() };
}

pub fn seedFromU64(seed: u64) Wyhash64 {
    return init(seed);
}

pub fn fromSeed(seed: anytype) Wyhash64 {
    return init(seed.state);
}

pub fn fromSeedBytes(seed: [8]u8) Wyhash64 {
    return fromState(std.mem.readInt(u64, &seed, .little));
}

pub fn fromRng(source: anytype) Wyhash64 {
    return fromState(source.next());
}

pub fn tryFromRng(source: anytype) !Wyhash64 {
    return fromState(try source.tryNext());
}

pub fn fromState(state: u64) Wyhash64 {
    return .{ .state = state };
}

pub fn random(self: *Wyhash64) std.Random {
    return std.Random.init(self, fill);
}

pub fn next(self: *Wyhash64) u64 {
    self.state +%= secret[0];
    return wymix(self.state ^ secret[1], self.state);
}

pub fn tryNext(self: *Wyhash64) !u64 {
    return self.next();
}

pub fn nextU64(self: *Wyhash64) u64 {
    return self.next();
}

pub fn nextU32(self: *Wyhash64) u32 {
    return @truncate(self.next() >> 32);
}

pub fn fill(self: *Wyhash64, buf: []u8) void {
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

pub fn fillBytes(self: *Wyhash64, buf: []u8) void {
    self.fill(buf);
}

pub fn fork(self: *Wyhash64) Wyhash64 {
    return fromRng(self);
}

pub fn tryFork(self: *Wyhash64) !Wyhash64 {
    return tryFromRng(self);
}

fn wymix(a: u64, b: u64) u64 {
    const product = @as(u128, a) *% @as(u128, b);
    return @as(u64, @truncate(product)) ^ @as(u64, @truncate(product >> 64));
}

test "wyhash64 deterministic sequence" {
    var rng_a = Wyhash64.init(123);
    var rng_b = Wyhash64.init(123);
    var rng_c = Wyhash64.init(124);

    var i: usize = 0;
    while (i < 16) : (i += 1) {
        const value_a = rng_a.next();
        const value_b = rng_b.next();
        const value_c = rng_c.next();
        try std.testing.expectEqual(value_a, value_b);
        try std.testing.expect(value_a != value_c);
    }
}

test "wyhash64 fill has stable byte snapshot" {
    var rng = Wyhash64.init(0x1234_5678_9abc_def0);
    var buf: [24]u8 = undefined;
    rng.fill(&buf);
    try std.testing.expectEqualSlices(u8, &.{
        0x5b, 0xbd, 0x36, 0xab, 0x9c, 0xea, 0xe3, 0x23,
        0x78, 0x52, 0x12, 0xa3, 0x3c, 0xa3, 0x9d, 0x63,
        0xd8, 0x32, 0xda, 0xee, 0x77, 0x79, 0x30, 0x88,
    }, &buf);
}
