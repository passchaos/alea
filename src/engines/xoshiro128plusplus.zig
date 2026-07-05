const std = @import("std");
const SplitMix64 = @import("splitmix64.zig");

const Xoshiro128PlusPlus = @This();

state: [4]u32,

pub fn init(seed_value: u64) Xoshiro128PlusPlus {
    var self: Xoshiro128PlusPlus = .{ .state = undefined };
    self.seed(seed_value);
    return self;
}

pub fn seedFromU64(seed_value: u64) Xoshiro128PlusPlus {
    return init(seed_value);
}

pub fn fromSeed(seed_value: anytype) Xoshiro128PlusPlus {
    return init(seed_value.state);
}

pub fn fromSeedBytes(seed_bytes: [16]u8) Xoshiro128PlusPlus {
    var self: Xoshiro128PlusPlus = .{ .state = .{
        std.mem.readInt(u32, seed_bytes[0..4], .little),
        std.mem.readInt(u32, seed_bytes[4..8], .little),
        std.mem.readInt(u32, seed_bytes[8..12], .little),
        std.mem.readInt(u32, seed_bytes[12..16], .little),
    } };
    if (self.isZeroState()) return init(0);
    return self;
}

pub fn fromRng(source: anytype) Xoshiro128PlusPlus {
    const first = source.next();
    const second = source.next();
    return fromSeedWords(first, second);
}

pub fn tryFromRng(source: anytype) !Xoshiro128PlusPlus {
    const first = try source.tryNext();
    const second = try source.tryNext();
    return fromSeedWords(first, second);
}

pub fn seed(self: *Xoshiro128PlusPlus, seed_value: u64) void {
    var sm = SplitMix64.init(seed_value);
    const first = sm.next();
    const second = sm.next();
    self.* = fromSeedWords(first, second);
}

pub fn random(self: *Xoshiro128PlusPlus) std.Random {
    return std.Random.init(self, fill);
}

pub fn next(self: *Xoshiro128PlusPlus) u64 {
    return self.nextU64();
}

pub fn tryNext(self: *Xoshiro128PlusPlus) !u64 {
    return self.next();
}

pub fn nextU64(self: *Xoshiro128PlusPlus) u64 {
    const low: u64 = self.nextU32();
    const high: u64 = self.nextU32();
    return low | (high << 32);
}

pub fn tryNextU64(self: *Xoshiro128PlusPlus) !u64 {
    return self.nextU64();
}

pub fn nextU32(self: *Xoshiro128PlusPlus) u32 {
    const result = std.math.rotl(u32, self.state[0] +% self.state[3], 7) +% self.state[0];
    step(self);
    return result;
}

pub fn tryNextU32(self: *Xoshiro128PlusPlus) !u32 {
    return self.nextU32();
}

pub fn fill(self: *Xoshiro128PlusPlus, buf: []u8) void {
    var i: usize = 0;
    const aligned_len = buf.len - (buf.len & 3);

    while (i < aligned_len) : (i += 4) {
        var bytes: [4]u8 = undefined;
        std.mem.writeInt(u32, &bytes, self.nextU32(), .little);
        @memcpy(buf[i..][0..4], &bytes);
    }

    if (i < buf.len) {
        var bytes: [4]u8 = undefined;
        std.mem.writeInt(u32, &bytes, self.nextU32(), .little);
        @memcpy(buf[i..], bytes[0 .. buf.len - i]);
    }
}

pub fn fillBytes(self: *Xoshiro128PlusPlus, buf: []u8) void {
    self.fill(buf);
}

pub fn tryFillBytes(self: *Xoshiro128PlusPlus, buf: []u8) !void {
    self.fillBytes(buf);
}

pub fn fork(self: *Xoshiro128PlusPlus) Xoshiro128PlusPlus {
    return fromRng(self);
}

pub fn tryFork(self: *Xoshiro128PlusPlus) !Xoshiro128PlusPlus {
    return tryFromRng(self);
}

fn fromSeedWords(first: u64, second: u64) Xoshiro128PlusPlus {
    const self: Xoshiro128PlusPlus = .{ .state = .{
        @truncate(first),
        @truncate(first >> 32),
        @truncate(second),
        @truncate(second >> 32),
    } };
    if (self.isZeroState()) return init(0);
    return self;
}

fn isZeroState(self: Xoshiro128PlusPlus) bool {
    for (self.state) |word| {
        if (word != 0) return false;
    }
    return true;
}

inline fn step(self: *Xoshiro128PlusPlus) void {
    const t = self.state[1] << 9;

    self.state[2] ^= self.state[0];
    self.state[3] ^= self.state[1];
    self.state[1] ^= self.state[2];
    self.state[0] ^= self.state[3];
    self.state[2] ^= t;
    self.state[3] = std.math.rotl(u32, self.state[3], 11);
}

test "xoshiro128++ reference nextU32 sequence" {
    var rng = Xoshiro128PlusPlus.fromSeedBytes(.{
        1, 0, 0, 0,
        2, 0, 0, 0,
        3, 0, 0, 0,
        4, 0, 0, 0,
    });
    const expected = [_]u32{
        641,
        1573767,
        3222811527,
        3517856514,
        836907274,
        4247214768,
        3867114732,
        1355841295,
        495546011,
        621204420,
    };
    for (expected) |value| try std.testing.expectEqual(value, rng.nextU32());
}

test "xoshiro128++ seedFromU64 matches local rand stable sequence" {
    var rng = Xoshiro128PlusPlus.seedFromU64(0);
    var zero_seed_rng = Xoshiro128PlusPlus.fromSeedBytes([_]u8{0} ** 16);
    const expected = [_]u32{
        1179900579,
        1938959192,
        3089844957,
        3657088315,
        1015453891,
        479942911,
        3433842246,
        669252886,
        3985671746,
        2737205563,
    };
    for (expected) |value| {
        try std.testing.expectEqual(value, rng.nextU32());
        try std.testing.expectEqual(value, zero_seed_rng.nextU32());
    }
}

test "xoshiro128++ nextU64 uses little-endian nextU32 pairs" {
    var direct = Xoshiro128PlusPlus.seedFromU64(0);
    var combined = Xoshiro128PlusPlus.seedFromU64(0);

    const low: u64 = direct.nextU32();
    const high: u64 = direct.nextU32();
    try std.testing.expectEqual(low | (high << 32), combined.nextU64());
}

test "xoshiro128++ fill has stable byte snapshot" {
    var rng = Xoshiro128PlusPlus.init(0x1234_5678_9abc_def0);
    var buf: [24]u8 = undefined;
    rng.fill(&buf);
    try std.testing.expectEqualSlices(u8, &.{
        0xe1, 0x1c, 0xfd, 0xe7,
        0xbd, 0xac, 0x07, 0x09,
        0x83, 0x73, 0xdf, 0x3d,
        0xd5, 0x0f, 0xbf, 0x90,
        0x4d, 0x4e, 0x98, 0x4b,
        0x9f, 0x09, 0x8a, 0x2f,
    }, &buf);
}
