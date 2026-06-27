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

pub fn random(self: *Alea4x64) std.Random {
    return std.Random.init(self, fill);
}

pub inline fn next(self: *Alea4x64) u64 {
    return lane(self, 0);
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
