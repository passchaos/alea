const std = @import("std");
const SplitMix64 = @import("splitmix64.zig");

const ChaCha = @This();

const Cipher = std.crypto.stream.chacha.ChaCha12IETF;
const buffer_len = 8 * Cipher.block_length;
const nonce = [_]u8{0} ** Cipher.nonce_length;

buffer: [buffer_len]u8,
offset: usize,

pub const seed_length = Cipher.key_length;

pub fn init(seed: [seed_length]u8) ChaCha {
    var self: ChaCha = .{
        .buffer = undefined,
        .offset = buffer_len,
    };
    Cipher.stream(&self.buffer, 0, seed, nonce);
    self.offset = 0;
    return self;
}

pub fn initFromU64(seed: u64) ChaCha {
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

pub fn random(self: *ChaCha) std.Random {
    return std.Random.init(self, fill);
}

pub fn addEntropy(self: *ChaCha, entropy: []const u8) void {
    var key = self.buffer[0..seed_length].*;
    for (entropy, 0..) |byte, i| {
        key[i % key.len] ^= byte;
        key[(i *% 7 +% 13) % key.len] +%= byte;
    }
    Cipher.stream(&self.buffer, 0, key, nonce);
    self.offset = 0;
}

pub fn next(self: *ChaCha) u64 {
    var bytes: [8]u8 = undefined;
    self.fill(&bytes);
    return std.mem.readInt(u64, &bytes, .little);
}

pub fn fill(self: *ChaCha, out: []u8) void {
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

fn refill(self: *ChaCha) void {
    const key = self.buffer[0..seed_length].*;
    Cipher.stream(&self.buffer, 0, key, nonce);
    self.offset = 0;
}

test "chacha deterministic bytes" {
    var a = ChaCha.initFromU64(42);
    var b = ChaCha.initFromU64(42);
    var buf_a: [128]u8 = undefined;
    var buf_b: [128]u8 = undefined;

    a.fill(&buf_a);
    b.fill(&buf_b);
    try std.testing.expectEqualSlices(u8, &buf_a, &buf_b);
}
