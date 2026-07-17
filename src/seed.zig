const std = @import("std");
const SplitMix64 = @import("engines/splitmix64.zig");
const source_helpers = @import("source.zig");

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

pub fn fromRng(source: anytype) Seed {
    return .{ .state = source_helpers.nextU64(source) };
}

pub fn tryFromRng(source: anytype) !Seed {
    return .{ .state = try source_helpers.tryNextU64(source) };
}

pub fn secure(io: std.Io) !Seed {
    var bytes_buf: [8]u8 = undefined;
    try std.Io.randomSecure(io, &bytes_buf);
    return .{ .state = std.mem.readInt(u64, &bytes_buf, .little) };
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

test "seed derivation and byte output have stable snapshots" {
    const base = Seed.fromString("experiment-a");
    try std.testing.expectEqual(@as(u64, 0x64bab27be76df0c1), base.state);
    try std.testing.expectEqual(base.state, Seed.fromBytes("experiment-a").state);
    try std.testing.expectEqual(@as(u64, 0x172c0c1763e19935), base.mix("fold-1").state);
    try std.testing.expectEqual(@as(u64, 0x4fa7b3f2a955e9bd), base.stream(3).state);

    var sequence = base;
    try std.testing.expectEqual(@as(u64, 0x7a14e9e97a98bab8), sequence.next());
    try std.testing.expectEqual(@as(u64, 0x9519e353f5722873), sequence.next());
    try std.testing.expectEqual(@as(u64, 0xa129a5eee602e8eb), sequence.state);

    var bytes_seed = base;
    var out: [20]u8 = undefined;
    bytes_seed.bytes(&out);
    try std.testing.expectEqualSlices(u8, &.{
        0xb8, 0xba, 0x98, 0x7a, 0xe9, 0xe9, 0x14, 0x7a,
        0x73, 0x28, 0x72, 0xf5, 0x53, 0xe3, 0x19, 0x95,
        0x3d, 0x9d, 0xdf, 0x3d,
    }, &out);
    try std.testing.expectEqual(@as(u64, 0x3f611fa8654d6500), bytes_seed.state);
}
