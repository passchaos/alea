const std = @import("std");
const SplitMix64 = @import("splitmix64.zig");

const Xoshiro256 = @This();

state: [4]u64,

pub fn init(seed_value: u64) Xoshiro256 {
    var self: Xoshiro256 = .{ .state = undefined };
    self.seed(seed_value);
    return self;
}

pub fn seed(self: *Xoshiro256, seed_value: u64) void {
    var sm = SplitMix64.init(seed_value);
    inline for (0..4) |i| self.state[i] = sm.next();
}

pub fn random(self: *Xoshiro256) std.Random {
    return std.Random.init(self, fill);
}

pub fn next(self: *Xoshiro256) u64 {
    const result = std.math.rotl(u64, self.state[1] *% 5, 7) *% 9;
    step(self);
    return result;
}

pub fn split(self: *Xoshiro256) Xoshiro256 {
    var child: Xoshiro256 = .{ .state = undefined };
    inline for (0..4) |i| child.state[i] = self.next();
    child.jump();
    return child;
}

pub fn jump(self: *Xoshiro256) void {
    jumpBy(self, &.{
        0x180ec6d33cfd0aba,
        0xd5a61266f0c9392c,
        0xa9582618e03fc9aa,
        0x39abdc4529b1661c,
    });
}

pub fn longJump(self: *Xoshiro256) void {
    jumpBy(self, &.{
        0x76e15d3efefdcbbf,
        0xc5004e441c522fb3,
        0x77710069854ee241,
        0x39109bb02acbe635,
    });
}

pub fn fill(self: *Xoshiro256, buf: []u8) void {
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

fn step(self: *Xoshiro256) void {
    const t = self.state[1] << 17;

    self.state[2] ^= self.state[0];
    self.state[3] ^= self.state[1];
    self.state[1] ^= self.state[2];
    self.state[0] ^= self.state[3];
    self.state[2] ^= t;
    self.state[3] = std.math.rotl(u64, self.state[3], 45);
}

fn jumpBy(self: *Xoshiro256, table: []const u64) void {
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

test "xoshiro256 split creates deterministic independent stream" {
    var parent_a = Xoshiro256.init(99);
    var parent_b = Xoshiro256.init(99);
    var child_a = parent_a.split();
    var child_b = parent_b.split();

    try std.testing.expectEqual(parent_a.next(), parent_b.next());
    try std.testing.expectEqual(child_a.next(), child_b.next());
    try std.testing.expect(parent_a.next() != child_a.next());
}
