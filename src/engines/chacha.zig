const std = @import("std");
const SplitMix64 = @import("splitmix64.zig");
const source_helpers = @import("../source.zig");

/// Generic buffered ChaCha engine.
///
/// Each 512-byte refill runs `Cipher.stream` once with the current key and a
/// zero nonce. The first `key_length` bytes of that block are retained as the
/// next key (they are never emitted), and the remaining bytes are exposed as
/// output. This is a rekeying construction rather than a counter-mode stream:
/// the first block matches the standard ChaCha keystream bytes after the key
/// prefix, and every later block uses the previous block's hidden key prefix.
pub fn ChaChaRng(comptime Cipher: type) type {
    return struct {
        const Self = @This();

        const buffer_len = 8 * Cipher.block_length;
        const nonce = [_]u8{0} ** Cipher.nonce_length;

        buffer: [buffer_len]u8,
        offset: usize,

        pub const seed_length = Cipher.key_length;

        pub fn init(seed: [seed_length]u8) Self {
            var self: Self = .{
                .buffer = undefined,
                .offset = buffer_len,
            };
            Cipher.stream(&self.buffer, 0, seed, nonce);
            self.offset = 0;
            return self;
        }

        pub fn initFromU64(seed: u64) Self {
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

        pub fn seedFromU64(seed: u64) Self {
            return initFromU64(seed);
        }

        pub fn fromSeed(seed: anytype) Self {
            return initFromU64(seed.state);
        }

        pub fn fromSeedBytes(seed: [seed_length]u8) Self {
            return init(seed);
        }

        pub fn fromRng(source: anytype) Self {
            var key: [seed_length]u8 = undefined;
            var i: usize = 0;
            while (i < seed_length) : (i += 8) {
                var bytes: [8]u8 = undefined;
                std.mem.writeInt(u64, &bytes, source_helpers.nextU64(source), .little);
                @memcpy(key[i..][0..8], &bytes);
            }
            return init(key);
        }

        pub fn tryFromRng(source: anytype) !Self {
            var key: [seed_length]u8 = undefined;
            var i: usize = 0;
            while (i < seed_length) : (i += 8) {
                var bytes: [8]u8 = undefined;
                std.mem.writeInt(u64, &bytes, try source_helpers.tryNextU64(source), .little);
                @memcpy(key[i..][0..8], &bytes);
            }
            return init(key);
        }

        pub fn random(self: *Self) std.Random {
            return std.Random.init(self, fill);
        }

        pub fn addEntropy(self: *Self, entropy: []const u8) void {
            var key = self.buffer[0..seed_length].*;
            for (entropy, 0..) |byte, i| {
                key[i % key.len] ^= byte;
                key[(i *% 7 +% 13) % key.len] +%= byte;
            }
            Cipher.stream(&self.buffer, 0, key, nonce);
            self.offset = 0;
        }

        pub fn next(self: *Self) u64 {
            var bytes: [8]u8 = undefined;
            self.fill(&bytes);
            return std.mem.readInt(u64, &bytes, .little);
        }

        pub fn tryNext(self: *Self) !u64 {
            return self.next();
        }

        pub fn tryNextU64(self: *Self) !u64 {
            return self.tryNext();
        }

        pub fn tryNextU32(self: *Self) !u32 {
            return @truncate((try self.tryNext()) >> 32);
        }

        pub fn nextU64(self: *Self) u64 {
            return self.next();
        }

        pub fn nextU32(self: *Self) u32 {
            return @truncate(self.next() >> 32);
        }

        pub fn fill(self: *Self, out: []u8) void {
            var dest = out;
            while (dest.len > 0) {
                const bytes = self.buffer[seed_length..];
                if (self.offset == bytes.len) refill(self);
                const available = bytes.len - self.offset;
                const n = @min(dest.len, available);
                @memcpy(dest[0..n], bytes[self.offset..][0..n]);
                // The copied keystream bytes are already public output, and
                // the hidden key prefix is overwritten by the next refill, so
                // zeroing the consumed buffer region would only add a second
                // memory pass over every emitted byte.
                self.offset += n;
                dest = dest[n..];
            }
        }

        pub fn fillBytes(self: *Self, out: []u8) void {
            self.fill(out);
        }

        pub fn tryFillBytes(self: *Self, out: []u8) !void {
            self.fillBytes(out);
        }

        pub fn fork(self: *Self) Self {
            return fromRng(self);
        }

        pub fn tryFork(self: *Self) !Self {
            return tryFromRng(self);
        }

        fn refill(self: *Self) void {
            const key = self.buffer[0..seed_length].*;
            Cipher.stream(&self.buffer, 0, key, nonce);
            self.offset = 0;
        }
    };
}

pub const ChaCha = ChaChaRng(std.crypto.stream.chacha.ChaCha12IETF);

test "chacha deterministic bytes" {
    var a = ChaCha.initFromU64(42);
    var b = ChaCha.initFromU64(42);
    var buf_a: [128]u8 = undefined;
    var buf_b: [128]u8 = undefined;

    a.fill(&buf_a);
    b.fill(&buf_b);
    try std.testing.expectEqualSlices(u8, &buf_a, &buf_b);
}

test "chacha fill has stable byte snapshot" {
    var rng = ChaCha.initFromU64(0x1234_5678_9abc_def0);
    var buf: [24]u8 = undefined;
    rng.fill(&buf);
    try std.testing.expectEqualSlices(u8, &.{
        0xf1, 0x1c, 0xd9, 0x81, 0xce, 0x73, 0x82, 0x95,
        0x01, 0x5f, 0xc5, 0x4d, 0x2d, 0x43, 0x88, 0xe8,
        0x3b, 0xec, 0x27, 0x9d, 0xb0, 0xb7, 0xba, 0xe0,
    }, &buf);
}

test "chacha addEntropy has stable byte snapshot" {
    var rng = ChaCha.initFromU64(0x1234_5678_9abc_def0);
    rng.addEntropy("session-a");
    rng.addEntropy(&.{ 0, 1, 2, 3, 4, 5 });
    var buf: [24]u8 = undefined;
    rng.fill(&buf);
    try std.testing.expectEqualSlices(u8, &.{
        0xb7, 0x2a, 0x15, 0x98, 0x0c, 0xb1, 0x0e, 0x08,
        0xaf, 0x0b, 0xd7, 0xfc, 0xbf, 0x24, 0x77, 0x0f,
        0xdf, 0x00, 0x2c, 0x6f, 0x37, 0x2d, 0x7d, 0x90,
    }, &buf);
}

test "chacha rekeying matches the documented stream construction" {
    const Cipher = std.crypto.stream.chacha.ChaCha12IETF;
    const nonce = [_]u8{0} ** Cipher.nonce_length;

    var seed: [ChaCha.seed_length]u8 = undefined;
    for (&seed, 0..) |*byte, i| byte.* = @intCast(i);

    var engine = ChaCha.init(seed);
    var output: [512]u8 = undefined;
    engine.fill(&output);

    var first_block: [512]u8 = undefined;
    Cipher.stream(&first_block, 0, seed, nonce);
    try std.testing.expectEqualSlices(u8, first_block[Cipher.key_length..], output[0 .. 512 - Cipher.key_length]);

    var next_key: [Cipher.key_length]u8 = undefined;
    @memcpy(&next_key, first_block[0..Cipher.key_length]);
    var second_block: [512]u8 = undefined;
    Cipher.stream(&second_block, 0, next_key, nonce);
    try std.testing.expectEqualSlices(u8, second_block[Cipher.key_length .. 2 * Cipher.key_length], output[512 - Cipher.key_length ..]);
}
