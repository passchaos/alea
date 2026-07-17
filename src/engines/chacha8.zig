const std = @import("std");
const SplitMix64 = @import("splitmix64.zig");
const source_helpers = @import("../source.zig");

const ChaCha8Rng = @This();

const Cipher = std.crypto.stream.chacha.ChaCha8IETF;
const buffer_len = 8 * Cipher.block_length;
const nonce = [_]u8{0} ** Cipher.nonce_length;

buffer: [buffer_len]u8,
offset: usize,

pub const seed_length = Cipher.key_length;

pub fn init(seed: [seed_length]u8) ChaCha8Rng {
    var self: ChaCha8Rng = .{
        .buffer = undefined,
        .offset = buffer_len,
    };
    Cipher.stream(&self.buffer, 0, seed, nonce);
    self.offset = 0;
    return self;
}

pub fn initFromU64(seed: u64) ChaCha8Rng {
    var sm = SplitMix64.init(seed);
    var key: [seed_length]u8 = undefined;
    var i: usize = 0;
    while (i < seed_length) : (i += 8) {
        var bytes: [8]u8 = undefined;
        std.mem.writeInt(u64, &bytes, sm.next(), .little);
        @memcpy(key[i..][0..8], &bytes);
    }
    return init(key);
}

pub fn seedFromU64(seed: u64) ChaCha8Rng {
    return initFromU64(seed);
}

pub fn fromSeed(seed: anytype) ChaCha8Rng {
    return initFromU64(seed.state);
}

pub fn fromSeedBytes(seed: [seed_length]u8) ChaCha8Rng {
    return init(seed);
}

pub fn fromRng(source: anytype) ChaCha8Rng {
    var key: [seed_length]u8 = undefined;
    var i: usize = 0;
    while (i < seed_length) : (i += 8) {
        var bytes: [8]u8 = undefined;
        std.mem.writeInt(u64, &bytes, source_helpers.nextU64(source), .little);
        @memcpy(key[i..][0..8], &bytes);
    }
    return init(key);
}

pub fn tryFromRng(source: anytype) !ChaCha8Rng {
    var key: [seed_length]u8 = undefined;
    var i: usize = 0;
    while (i < seed_length) : (i += 8) {
        var bytes: [8]u8 = undefined;
        std.mem.writeInt(u64, &bytes, try source_helpers.tryNextU64(source), .little);
        @memcpy(key[i..][0..8], &bytes);
    }
    return init(key);
}

pub fn random(self: *ChaCha8Rng) std.Random {
    return std.Random.init(self, fill);
}

pub fn addEntropy(self: *ChaCha8Rng, entropy: []const u8) void {
    var key = self.buffer[0..seed_length].*;
    for (entropy, 0..) |byte, i| {
        key[i % key.len] ^= byte;
        key[(i *% 7 +% 13) % key.len] +%= byte;
    }
    Cipher.stream(&self.buffer, 0, key, nonce);
    self.offset = 0;
}

pub fn next(self: *ChaCha8Rng) u64 {
    var bytes: [8]u8 = undefined;
    self.fill(&bytes);
    return std.mem.readInt(u64, &bytes, .little);
}

pub fn tryNext(self: *ChaCha8Rng) !u64 {
    return self.next();
}

pub fn tryNextU64(self: *ChaCha8Rng) !u64 {
    return self.tryNext();
}

pub fn tryNextU32(self: *ChaCha8Rng) !u32 {
    return @truncate((try self.tryNext()) >> 32);
}

pub fn nextU64(self: *ChaCha8Rng) u64 {
    return self.next();
}

pub fn nextU32(self: *ChaCha8Rng) u32 {
    return @truncate(self.next() >> 32);
}

pub fn fill(self: *ChaCha8Rng, out: []u8) void {
    var dest = out;
    while (dest.len > 0) {
        const bytes = self.buffer[seed_length..];
        if (self.offset == bytes.len) refill(self);
        const available = bytes.len - self.offset;
        const n = @min(dest.len, available);
        @memcpy(dest[0..n], bytes[self.offset..][0..n]);
        @memset(bytes[self.offset..][0..n], 0);
        self.offset += n;
        dest = dest[n..];
    }
}

pub fn fillBytes(self: *ChaCha8Rng, out: []u8) void {
    self.fill(out);
}

pub fn tryFillBytes(self: *ChaCha8Rng, out: []u8) !void {
    self.fillBytes(out);
}

pub fn fork(self: *ChaCha8Rng) ChaCha8Rng {
    return fromRng(self);
}

pub fn tryFork(self: *ChaCha8Rng) !ChaCha8Rng {
    return tryFromRng(self);
}

fn refill(self: *ChaCha8Rng) void {
    const key = self.buffer[0..seed_length].*;
    Cipher.stream(&self.buffer, 0, key, nonce);
    self.offset = 0;
}

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
