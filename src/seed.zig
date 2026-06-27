const std = @import("std");
const SplitMix64 = @import("engines/splitmix64.zig");

const Seed = @This();

state: u64,

pub fn init(value: u64) Seed {
    return .{ .state = value };
}

pub fn fromBytes(input: []const u8) Seed {
    return .{ .state = std.hash.Wyhash.hash(0xa1ea5eed, input) };
}

pub fn fromString(input: []const u8) Seed {
    return fromBytes(input);
}

pub fn mix(self: Seed, input: []const u8) Seed {
    var buf: [8]u8 = undefined;
    std.mem.writeInt(u64, &buf, self.state, .little);
    var h = std.hash.Wyhash.init(0xa1ea5eed);
    h.update(&buf);
    h.update(input);
    return .{ .state = h.final() };
}

pub fn stream(self: Seed, index: u64) Seed {
    var sm = SplitMix64.init(self.state ^ (index *% 0x9e3779b97f4a7c15));
    return .{ .state = sm.next() };
}

pub fn next(self: *Seed) u64 {
    var sm = SplitMix64.init(self.state);
    const value = sm.next();
    self.state = sm.state;
    return value;
}

pub fn bytes(self: *Seed, out: []u8) void {
    var i: usize = 0;
    while (i < out.len) {
        var block: [8]u8 = undefined;
        std.mem.writeInt(u64, &block, self.next(), .little);
        const n = @min(block.len, out.len - i);
        @memcpy(out[i..][0..n], block[0..n]);
        i += n;
    }
}

test "seed from strings and streams is reproducible" {
    const base = Seed.fromString("experiment-a");
    try std.testing.expectEqual(base.stream(3).state, base.stream(3).state);
    try std.testing.expect(base.stream(3).state != base.stream(4).state);
}
