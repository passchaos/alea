const std = @import("std");

const StepRng = @This();

value: u64,
increment: u64,

pub fn init(initial: u64, increment: u64) StepRng {
    return .{ .value = initial, .increment = increment };
}

pub fn new(initial: u64, increment: u64) StepRng {
    return init(initial, increment);
}

pub fn constant(value: u64) StepRng {
    return init(value, 0);
}

pub fn constRng(value: u64) StepRng {
    return constant(value);
}

pub fn fromSeedBytes(seed: [16]u8) StepRng {
    return init(
        std.mem.readInt(u64, seed[0..8], .little),
        std.mem.readInt(u64, seed[8..16], .little),
    );
}

pub fn random(self: *StepRng) std.Random {
    return std.Random.init(self, fill);
}

pub fn next(self: *StepRng) u64 {
    const result = self.value;
    self.value +%= self.increment;
    return result;
}

pub fn tryNext(self: *StepRng) !u64 {
    return self.next();
}

pub fn nextU64(self: *StepRng) u64 {
    return self.next();
}

pub fn tryNextU64(self: *StepRng) !u64 {
    return self.tryNext();
}

pub fn nextU32(self: *StepRng) u32 {
    return @truncate(self.next());
}

pub fn tryNextU32(self: *StepRng) !u32 {
    return @truncate(try self.tryNext());
}

pub fn fill(self: *StepRng, buf: []u8) void {
    var i: usize = 0;
    while (i + 8 <= buf.len) : (i += 8) {
        std.mem.writeInt(u64, buf[i..][0..8], self.next(), .little);
    }
    if (i < buf.len) {
        var bytes: [8]u8 = undefined;
        std.mem.writeInt(u64, &bytes, self.next(), .little);
        @memcpy(buf[i..], bytes[0 .. buf.len - i]);
    }
}

pub fn fillBytes(self: *StepRng, buf: []u8) void {
    self.fill(buf);
}

pub fn tryFillBytes(self: *StepRng, buf: []u8) !void {
    self.fillBytes(buf);
}

test "step rng sequence and wrapping" {
    var rng = StepRng.init(std.math.maxInt(u64) - 1, 2);
    try std.testing.expectEqual(@as(u64, std.math.maxInt(u64) - 1), rng.next());
    try std.testing.expectEqual(@as(u64, 0), rng.next());
    try std.testing.expectEqual(@as(u64, 2), rng.nextU64());
    try std.testing.expectEqual(@as(u32, 4), rng.nextU32());
}

test "constant step rng does not advance" {
    var rng = StepRng.constant(0x1122_3344_5566_7788);
    try std.testing.expectEqual(@as(u64, 0x1122_3344_5566_7788), rng.next());
    try std.testing.expectEqual(@as(u64, 0x1122_3344_5566_7788), rng.next());
    try std.testing.expectEqual(@as(u32, 0x5566_7788), rng.nextU32());
}

test "step rng fromSeedBytes loads arithmetic sequence state" {
    const seed = [_]u8{
        0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01,
        0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    };
    var rng = StepRng.fromSeedBytes(seed);
    try std.testing.expectEqual(@as(u64, 0x0102_0304_0506_0708), rng.next());
    try std.testing.expectEqual(@as(u64, 0x0102_0304_0506_0718), rng.next());
}

test "step rng fill matches local rand StepRng byte shape" {
    var rng = StepRng.new(255, 1);
    var buf: [24]u8 = undefined;
    rng.fill(&buf);
    try std.testing.expectEqualSlices(u8, &.{
        255, 0, 0, 0, 0, 0, 0, 0,
        0,   1, 0, 0, 0, 0, 0, 0,
        1,   1, 0, 0, 0, 0, 0, 0,
    }, &buf);
}

test "step rng std.Random interop consumes byte stream" {
    var direct = StepRng.new(0x0102_0304_0506_0708, 0x10);
    var via_random = StepRng.new(0x0102_0304_0506_0708, 0x10);
    var std_random = via_random.random();

    var direct_buf: [17]u8 = undefined;
    var random_buf: [17]u8 = undefined;
    direct.fill(&direct_buf);
    std_random.bytes(&random_buf);
    try std.testing.expectEqualSlices(u8, &direct_buf, &random_buf);
    try std.testing.expectEqual(direct.next(), via_random.next());
}
