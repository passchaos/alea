const std = @import("std");
const SplitMix64 = @import("splitmix64.zig");

const ChaCha20Rng = @This();

const Cipher = std.crypto.stream.chacha.ChaCha20IETF;
const buffer_len = 8 * Cipher.block_length;
const nonce = [_]u8{0} ** Cipher.nonce_length;

buffer: [buffer_len]u8,
offset: usize,

pub const seed_length = Cipher.key_length;

pub fn init(seed: [seed_length]u8) ChaCha20Rng {
    var self: ChaCha20Rng = .{
        .buffer = undefined,
        .offset = buffer_len,
    };
    Cipher.stream(&self.buffer, 0, seed, nonce);
    self.offset = 0;
    return self;
}

pub fn initFromU64(seed: u64) ChaCha20Rng {
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

pub fn seedFromU64(seed: u64) ChaCha20Rng {
    return initFromU64(seed);
}

pub fn fromSeed(seed: anytype) ChaCha20Rng {
    return initFromU64(seed.state);
}

pub fn fromSeedBytes(seed: [seed_length]u8) ChaCha20Rng {
    return init(seed);
}

pub fn fromRng(source: anytype) ChaCha20Rng {
    var key: [seed_length]u8 = undefined;
    var i: usize = 0;
    while (i < seed_length) : (i += 8) {
        var bytes: [8]u8 = undefined;
        std.mem.writeInt(u64, &bytes, source.next(), .little);
        @memcpy(key[i..][0..8], &bytes);
    }
    return init(key);
}

pub fn tryFromRng(source: anytype) !ChaCha20Rng {
    var key: [seed_length]u8 = undefined;
    var i: usize = 0;
    while (i < seed_length) : (i += 8) {
        var bytes: [8]u8 = undefined;
        std.mem.writeInt(u64, &bytes, try source.tryNext(), .little);
        @memcpy(key[i..][0..8], &bytes);
    }
    return init(key);
}

pub fn random(self: *ChaCha20Rng) std.Random {
    return std.Random.init(self, fill);
}

pub fn addEntropy(self: *ChaCha20Rng, entropy: []const u8) void {
    var key = self.buffer[0..seed_length].*;
    for (entropy, 0..) |byte, i| {
        key[i % key.len] ^= byte;
        key[(i *% 7 +% 13) % key.len] +%= byte;
    }
    Cipher.stream(&self.buffer, 0, key, nonce);
    self.offset = 0;
}

pub fn next(self: *ChaCha20Rng) u64 {
    var bytes: [8]u8 = undefined;
    self.fill(&bytes);
    return std.mem.readInt(u64, &bytes, .little);
}

pub fn tryNext(self: *ChaCha20Rng) !u64 {
    return self.next();
}

pub fn tryNextU64(self: *ChaCha20Rng) !u64 {
    return self.tryNext();
}

pub fn tryNextU32(self: *ChaCha20Rng) !u32 {
    return @truncate((try self.tryNext()) >> 32);
}

pub fn nextU64(self: *ChaCha20Rng) u64 {
    return self.next();
}

pub fn nextU32(self: *ChaCha20Rng) u32 {
    return @truncate(self.next() >> 32);
}

pub fn fill(self: *ChaCha20Rng, out: []u8) void {
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

pub fn fillBytes(self: *ChaCha20Rng, out: []u8) void {
    self.fill(out);
}

pub fn tryFillBytes(self: *ChaCha20Rng, out: []u8) !void {
    self.fillBytes(out);
}

pub fn fork(self: *ChaCha20Rng) ChaCha20Rng {
    return fromRng(self);
}

pub fn tryFork(self: *ChaCha20Rng) !ChaCha20Rng {
    return tryFromRng(self);
}

fn refill(self: *ChaCha20Rng) void {
    const key = self.buffer[0..seed_length].*;
    Cipher.stream(&self.buffer, 0, key, nonce);
    self.offset = 0;
}

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
