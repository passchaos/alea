const std = @import("std");
const Rng = @import("rng.zig");

pub const alphanumeric = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
pub const alphabetic = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
pub const lowercase = "abcdefghijklmnopqrstuvwxyz";
pub const uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
pub const digits = "0123456789";

pub const Charset = struct {
    bytes: []const u8,

    pub const ProbabilityIterator = struct {
        const Iterator = @This();

        charset: Charset,
        index: usize = 0,

        pub fn next(self: *Iterator) ?f64 {
            const value = self.charset.probability(self.index) orelse return null;
            self.index += 1;
            return value;
        }

        pub fn remaining(self: Iterator) usize {
            return self.charset.len() - self.index;
        }

        pub fn len(self: Iterator) usize {
            return self.remaining();
        }

        pub fn sizeHint(self: Iterator) struct { lower: usize, upper: ?usize } {
            const length = self.remaining();
            return .{ .lower = length, .upper = length };
        }

        pub fn fill(self: *Iterator, dest: []f64) usize {
            const count = @min(dest.len, self.remaining());
            for (dest[0..count]) |*slot| slot.* = self.next().?;
            return count;
        }
    };

    pub fn init(bytes: []const u8) Charset {
        std.debug.assert(bytes.len > 0);
        return .{ .bytes = bytes };
    }

    pub fn initChecked(bytes: []const u8) error{EmptyCharset}!Charset {
        if (bytes.len == 0) return error.EmptyCharset;
        return .{ .bytes = bytes };
    }

    pub fn bytesValue(self: Charset) []const u8 {
        return self.bytes;
    }

    pub fn len(self: Charset) usize {
        return self.bytes.len;
    }

    pub fn numChoices(self: Charset) usize {
        return self.bytes.len;
    }

    pub fn constantIndex(self: Charset) ?usize {
        return if (self.bytes.len == 1) 0 else null;
    }

    pub fn isEmpty(self: Charset) bool {
        return self.len() == 0;
    }

    pub fn byteAt(self: Charset, index: usize) error{InvalidParameter}!u8 {
        if (index >= self.bytes.len) return error.InvalidParameter;
        return self.bytes[index];
    }

    pub fn item(self: Charset, index: usize) error{InvalidParameter}!u8 {
        return self.byteAt(index);
    }

    pub fn get(self: Charset, index: usize) ?u8 {
        if (index >= self.bytes.len) return null;
        return self.bytes[index];
    }

    pub fn indexOf(self: Charset, byte: u8) ?usize {
        return std.mem.indexOfScalar(u8, self.bytes, byte);
    }

    pub fn contains(self: Charset, byte: u8) bool {
        return self.indexOf(byte) != null;
    }

    pub fn probabilityAt(self: Charset, index: usize) error{InvalidParameter}!f64 {
        if (index >= self.bytes.len) return error.InvalidParameter;
        return 1.0 / @as(f64, @floatFromInt(self.bytes.len));
    }

    pub fn probability(self: Charset, index: usize) ?f64 {
        return self.probabilityAt(index) catch null;
    }

    pub fn probabilityIter(self: Charset) ProbabilityIterator {
        return .{ .charset = self };
    }

    pub fn probabilities(self: Charset, allocator: std.mem.Allocator) ![]f64 {
        const out = try allocator.alloc(f64, self.bytes.len);
        errdefer allocator.free(out);
        try self.probabilitiesInto(out);
        return out;
    }

    pub fn probabilitiesInto(self: Charset, out: []f64) error{InvalidParameter}!void {
        if (out.len != self.bytes.len) return error.InvalidParameter;
        if (out.len == 0) return;
        @memset(out, 1.0 / @as(f64, @floatFromInt(self.bytes.len)));
    }

    pub fn sample(self: Charset, rng: Rng) u8 {
        return self.sampleFrom(rng);
    }

    pub fn sampleChecked(self: Charset, rng: Rng) error{EmptyCharset}!u8 {
        return self.sampleCheckedFrom(rng);
    }

    pub fn sampleCheckedFrom(self: Charset, source: anytype) error{EmptyCharset}!u8 {
        if (self.bytes.len == 0) return error.EmptyCharset;
        return self.sampleFrom(source);
    }

    pub fn sampleFrom(self: Charset, source: anytype) u8 {
        if (self.bytes.len == 1) return self.bytes[0];
        if (comptime @bitSizeOf(usize) <= 64) {
            const byte_count: u64 = @intCast(self.bytes.len);
            const index = Rng.uintLessThanFrom(source, u64, byte_count);
            return self.bytes[@intCast(index)];
        }
        return self.bytes[Rng.uintLessThanFrom(source, usize, self.bytes.len)];
    }

    pub fn fill(self: Charset, rng: Rng, out: []u8) void {
        self.fillFrom(rng, out);
    }

    pub fn fillChecked(self: Charset, rng: Rng, out: []u8) error{EmptyCharset}!void {
        try self.fillCheckedFrom(rng, out);
    }

    pub fn fillCheckedFrom(self: Charset, source: anytype, out: []u8) error{EmptyCharset}!void {
        if (out.len == 0) return;
        if (self.bytes.len == 0) return error.EmptyCharset;
        self.fillFrom(source, out);
    }

    pub fn fillFrom(self: Charset, source: anytype, out: []u8) void {
        if (self.bytes.len == 1) {
            @memset(out, self.bytes[0]);
            return;
        }
        if (comptime @bitSizeOf(usize) <= 64) {
            const byte_count: u64 = @intCast(self.bytes.len);
            for (out) |*byte| {
                const index = Rng.uintLessThanFrom(source, u64, byte_count);
                byte.* = self.bytes[@intCast(index)];
            }
            return;
        }
        for (out) |*byte| byte.* = self.bytes[Rng.uintLessThanFrom(source, usize, self.bytes.len)];
    }

    pub fn alloc(self: Charset, allocator: std.mem.Allocator, rng: Rng, length: usize) ![]u8 {
        return self.allocFrom(allocator, rng, length);
    }

    pub fn allocChecked(self: Charset, allocator: std.mem.Allocator, rng: Rng, length: usize) ![]u8 {
        return self.allocCheckedFrom(allocator, rng, length);
    }

    pub fn allocCheckedFrom(self: Charset, allocator: std.mem.Allocator, source: anytype, length: usize) ![]u8 {
        if (length == 0) return allocator.alloc(u8, 0);
        if (self.bytes.len == 0) return error.EmptyCharset;
        return self.allocFrom(allocator, source, length);
    }

    pub fn allocFrom(self: Charset, allocator: std.mem.Allocator, source: anytype, length: usize) ![]u8 {
        if (length == 0) return allocator.alloc(u8, 0);
        if (self.bytes.len == 0) return error.EmptyCharset;
        const out = try allocator.alloc(u8, length);
        self.fillFrom(source, out);
        return out;
    }

    pub fn sampleString(self: Charset, allocator: std.mem.Allocator, rng: Rng, length: usize) ![]u8 {
        return self.sampleStringFrom(allocator, rng, length);
    }

    pub fn sampleStringFrom(self: Charset, allocator: std.mem.Allocator, source: anytype, length: usize) ![]u8 {
        return self.allocFrom(allocator, source, length);
    }

    pub fn sampleStringChecked(self: Charset, allocator: std.mem.Allocator, rng: Rng, length: usize) ![]u8 {
        return self.sampleStringCheckedFrom(allocator, rng, length);
    }

    pub fn sampleStringCheckedFrom(self: Charset, allocator: std.mem.Allocator, source: anytype, length: usize) ![]u8 {
        return self.allocCheckedFrom(allocator, source, length);
    }

    pub fn appendString(self: Charset, allocator: std.mem.Allocator, rng: Rng, string_buffer: *std.ArrayList(u8), length: usize) !void {
        try self.appendStringFrom(allocator, rng, string_buffer, length);
    }

    pub fn appendStringFrom(self: Charset, allocator: std.mem.Allocator, source: anytype, string_buffer: *std.ArrayList(u8), length: usize) !void {
        if (length == 0) return;
        if (self.bytes.len == 0) return error.EmptyCharset;
        const old_len = string_buffer.items.len;
        try string_buffer.resize(allocator, old_len + length);
        self.fillFrom(source, string_buffer.items[old_len..]);
    }

    pub fn appendStringChecked(self: Charset, allocator: std.mem.Allocator, rng: Rng, string_buffer: *std.ArrayList(u8), length: usize) !void {
        try self.appendStringCheckedFrom(allocator, rng, string_buffer, length);
    }

    pub fn appendStringCheckedFrom(self: Charset, allocator: std.mem.Allocator, source: anytype, string_buffer: *std.ArrayList(u8), length: usize) !void {
        if (length == 0) return;
        if (self.bytes.len == 0) return error.EmptyCharset;
        try self.appendStringFrom(allocator, source, string_buffer, length);
    }
};

pub const UnicodeCharset = struct {
    scalars: []const u21,

    pub const ProbabilityIterator = struct {
        const Iterator = @This();

        charset: UnicodeCharset,
        index: usize = 0,

        pub fn next(self: *Iterator) ?f64 {
            const value = self.charset.probability(self.index) orelse return null;
            self.index += 1;
            return value;
        }

        pub fn remaining(self: Iterator) usize {
            return self.charset.len() - self.index;
        }

        pub fn len(self: Iterator) usize {
            return self.remaining();
        }

        pub fn sizeHint(self: Iterator) struct { lower: usize, upper: ?usize } {
            const length = self.remaining();
            return .{ .lower = length, .upper = length };
        }

        pub fn fill(self: *Iterator, dest: []f64) usize {
            const count = @min(dest.len, self.remaining());
            for (dest[0..count]) |*slot| slot.* = self.next().?;
            return count;
        }
    };

    pub fn init(scalars: []const u21) UnicodeCharset {
        std.debug.assert(scalars.len > 0);
        for (scalars) |scalar| std.debug.assert(std.unicode.utf8ValidCodepoint(scalar));
        return .{ .scalars = scalars };
    }

    pub fn initChecked(scalars: []const u21) error{ EmptyCharset, InvalidParameter }!UnicodeCharset {
        try validateScalars(scalars);
        return .{ .scalars = scalars };
    }

    pub fn scalarsValue(self: UnicodeCharset) []const u21 {
        return self.scalars;
    }

    pub fn len(self: UnicodeCharset) usize {
        return self.scalars.len;
    }

    pub fn numChoices(self: UnicodeCharset) usize {
        return self.scalars.len;
    }

    pub fn constantIndex(self: UnicodeCharset) ?usize {
        return if (self.scalars.len == 1) 0 else null;
    }

    pub fn isEmpty(self: UnicodeCharset) bool {
        return self.len() == 0;
    }

    pub fn scalarAt(self: UnicodeCharset, index: usize) error{InvalidParameter}!u21 {
        if (index >= self.scalars.len) return error.InvalidParameter;
        return self.scalars[index];
    }

    pub fn item(self: UnicodeCharset, index: usize) error{InvalidParameter}!u21 {
        return self.scalarAt(index);
    }

    pub fn get(self: UnicodeCharset, index: usize) ?u21 {
        if (index >= self.scalars.len) return null;
        return self.scalars[index];
    }

    pub fn indexOf(self: UnicodeCharset, scalar: u21) ?usize {
        return std.mem.indexOfScalar(u21, self.scalars, scalar);
    }

    pub fn contains(self: UnicodeCharset, scalar: u21) bool {
        return self.indexOf(scalar) != null;
    }

    pub fn maxUtf8Len(self: UnicodeCharset) usize {
        var max_len: usize = 0;
        for (self.scalars) |scalar| {
            const scalar_len: usize = std.unicode.utf8CodepointSequenceLength(scalar) catch unreachable;
            max_len = @max(max_len, scalar_len);
        }
        return max_len;
    }

    pub fn utf8Capacity(self: UnicodeCharset, length: usize) error{OutOfMemory}!usize {
        return std.math.mul(usize, self.maxUtf8Len(), length) catch return error.OutOfMemory;
    }

    pub fn probabilityAt(self: UnicodeCharset, index: usize) error{InvalidParameter}!f64 {
        if (index >= self.scalars.len) return error.InvalidParameter;
        return 1.0 / @as(f64, @floatFromInt(self.scalars.len));
    }

    pub fn probability(self: UnicodeCharset, index: usize) ?f64 {
        return self.probabilityAt(index) catch null;
    }

    pub fn probabilityIter(self: UnicodeCharset) ProbabilityIterator {
        return .{ .charset = self };
    }

    pub fn probabilities(self: UnicodeCharset, allocator: std.mem.Allocator) ![]f64 {
        const out = try allocator.alloc(f64, self.scalars.len);
        errdefer allocator.free(out);
        try self.probabilitiesInto(out);
        return out;
    }

    pub fn probabilitiesInto(self: UnicodeCharset, out: []f64) error{InvalidParameter}!void {
        if (out.len != self.scalars.len) return error.InvalidParameter;
        if (out.len == 0) return;
        @memset(out, 1.0 / @as(f64, @floatFromInt(self.scalars.len)));
    }

    pub fn sample(self: UnicodeCharset, rng: Rng) u21 {
        return self.sampleFrom(rng);
    }

    pub fn sampleChecked(self: UnicodeCharset, rng: Rng) error{ EmptyCharset, InvalidParameter }!u21 {
        return self.sampleCheckedFrom(rng);
    }

    pub fn sampleCheckedFrom(self: UnicodeCharset, source: anytype) error{ EmptyCharset, InvalidParameter }!u21 {
        try self.validateNonEmpty();
        return self.sampleFrom(source);
    }

    pub fn sampleFrom(self: UnicodeCharset, source: anytype) u21 {
        std.debug.assert(self.scalars.len > 0);
        if (self.scalars.len == 1) return self.scalars[0];
        if (comptime @bitSizeOf(usize) <= 64) {
            const scalar_count: u64 = @intCast(self.scalars.len);
            const index = Rng.uintLessThanFrom(source, u64, scalar_count);
            return self.scalars[@intCast(index)];
        }
        return self.scalars[Rng.uintLessThanFrom(source, usize, self.scalars.len)];
    }

    pub fn fill(self: UnicodeCharset, rng: Rng, out: []u21) void {
        self.fillFrom(rng, out);
    }

    pub fn fillChecked(self: UnicodeCharset, rng: Rng, out: []u21) error{ EmptyCharset, InvalidParameter }!void {
        try self.fillCheckedFrom(rng, out);
    }

    pub fn fillCheckedFrom(self: UnicodeCharset, source: anytype, out: []u21) error{ EmptyCharset, InvalidParameter }!void {
        if (out.len == 0) return;
        try self.validateNonEmpty();
        self.fillFrom(source, out);
    }

    pub fn fillFrom(self: UnicodeCharset, source: anytype, out: []u21) void {
        std.debug.assert(self.scalars.len > 0 or out.len == 0);
        if (self.scalars.len == 1) {
            @memset(out, self.scalars[0]);
            return;
        }
        if (comptime @bitSizeOf(usize) <= 64) {
            const scalar_count: u64 = @intCast(self.scalars.len);
            for (out) |*scalar| {
                const index = Rng.uintLessThanFrom(source, u64, scalar_count);
                scalar.* = self.scalars[@intCast(index)];
            }
            return;
        }
        for (out) |*scalar| scalar.* = self.scalars[Rng.uintLessThanFrom(source, usize, self.scalars.len)];
    }

    pub fn sampleString(self: UnicodeCharset, allocator: std.mem.Allocator, rng: Rng, length: usize) ![]u8 {
        return self.sampleStringFrom(allocator, rng, length);
    }

    pub fn sampleStringFrom(self: UnicodeCharset, allocator: std.mem.Allocator, source: anytype, length: usize) ![]u8 {
        if (length == 0) return allocator.alloc(u8, 0);
        try self.validateNonEmpty();
        const capacity = try self.utf8Capacity(length);
        var out = try std.ArrayList(u8).initCapacity(allocator, capacity);
        errdefer out.deinit(allocator);
        try self.appendStringFrom(allocator, source, &out, length);
        return out.toOwnedSlice(allocator);
    }

    pub fn sampleStringChecked(self: UnicodeCharset, allocator: std.mem.Allocator, rng: Rng, length: usize) ![]u8 {
        return self.sampleStringCheckedFrom(allocator, rng, length);
    }

    pub fn sampleStringCheckedFrom(self: UnicodeCharset, allocator: std.mem.Allocator, source: anytype, length: usize) ![]u8 {
        if (length == 0) return allocator.alloc(u8, 0);
        try self.validateNonEmpty();
        return self.sampleStringFrom(allocator, source, length);
    }

    pub fn appendString(self: UnicodeCharset, allocator: std.mem.Allocator, rng: Rng, string_buffer: *std.ArrayList(u8), length: usize) !void {
        try self.appendStringFrom(allocator, rng, string_buffer, length);
    }

    pub fn appendStringFrom(self: UnicodeCharset, allocator: std.mem.Allocator, source: anytype, string_buffer: *std.ArrayList(u8), length: usize) !void {
        if (length == 0) return;
        try self.validateNonEmpty();
        try string_buffer.ensureUnusedCapacity(allocator, try self.utf8Capacity(length));

        if (self.scalars.len == 1) {
            var buf: [4]u8 = undefined;
            const written = std.unicode.utf8Encode(self.scalars[0], &buf) catch unreachable;
            var i: usize = 0;
            while (i < length) : (i += 1) string_buffer.appendSliceAssumeCapacity(buf[0..written]);
            return;
        }

        if (comptime @bitSizeOf(usize) <= 64) {
            const scalar_count: u64 = @intCast(self.scalars.len);
            var i: usize = 0;
            while (i < length) : (i += 1) {
                const index = Rng.uintLessThanFrom(source, u64, scalar_count);
                var buf: [4]u8 = undefined;
                const written = std.unicode.utf8Encode(self.scalars[@intCast(index)], &buf) catch unreachable;
                string_buffer.appendSliceAssumeCapacity(buf[0..written]);
            }
            return;
        }

        var i: usize = 0;
        while (i < length) : (i += 1) {
            const index = Rng.uintLessThanFrom(source, usize, self.scalars.len);
            var buf: [4]u8 = undefined;
            const written = std.unicode.utf8Encode(self.scalars[index], &buf) catch unreachable;
            string_buffer.appendSliceAssumeCapacity(buf[0..written]);
        }
    }

    pub fn appendStringChecked(self: UnicodeCharset, allocator: std.mem.Allocator, rng: Rng, string_buffer: *std.ArrayList(u8), length: usize) !void {
        try self.appendStringCheckedFrom(allocator, rng, string_buffer, length);
    }

    pub fn appendStringCheckedFrom(self: UnicodeCharset, allocator: std.mem.Allocator, source: anytype, string_buffer: *std.ArrayList(u8), length: usize) !void {
        if (length == 0) return;
        try self.validateNonEmpty();
        try self.appendStringFrom(allocator, source, string_buffer, length);
    }

    fn validateNonEmpty(self: UnicodeCharset) error{ EmptyCharset, InvalidParameter }!void {
        try validateScalars(self.scalars);
    }

    fn validateScalars(scalars: []const u21) error{ EmptyCharset, InvalidParameter }!void {
        if (scalars.len == 0) return error.EmptyCharset;
        for (scalars) |scalar| {
            if (!std.unicode.utf8ValidCodepoint(scalar)) return error.InvalidParameter;
        }
    }
};

pub const Alphanumeric = Charset{ .bytes = alphanumeric };
pub const Alphabetic = Charset{ .bytes = alphabetic };
pub const Lowercase = Charset{ .bytes = lowercase };
pub const Uppercase = Charset{ .bytes = uppercase };
pub const Digits = Charset{ .bytes = digits };

pub fn char(rng: Rng) u8 {
    return charFrom(rng);
}

pub fn charFrom(source: anytype) u8 {
    return Alphanumeric.sampleFrom(source);
}

pub fn string(allocator: std.mem.Allocator, rng: Rng, len: usize) ![]u8 {
    return stringFrom(allocator, rng, len);
}

pub fn stringFrom(allocator: std.mem.Allocator, source: anytype, len: usize) ![]u8 {
    return Alphanumeric.allocFrom(allocator, source, len);
}

pub fn sampleString(allocator: std.mem.Allocator, rng: Rng, len: usize) ![]u8 {
    return sampleStringFrom(allocator, rng, len);
}

pub fn sampleStringFrom(allocator: std.mem.Allocator, source: anytype, len: usize) ![]u8 {
    return Alphanumeric.sampleStringFrom(allocator, source, len);
}

pub fn appendString(allocator: std.mem.Allocator, rng: Rng, string_buffer: *std.ArrayList(u8), len: usize) !void {
    try appendStringFrom(allocator, rng, string_buffer, len);
}

pub fn appendStringFrom(allocator: std.mem.Allocator, source: anytype, string_buffer: *std.ArrayList(u8), len: usize) !void {
    try Alphanumeric.appendStringFrom(allocator, source, string_buffer, len);
}

pub fn unicodeScalar(rng: Rng) u21 {
    return unicodeScalarFrom(rng);
}

pub fn unicodeScalarFrom(source: anytype) u21 {
    return Rng.unicodeScalarFrom(source);
}

pub fn unicodeUtf8Alloc(allocator: std.mem.Allocator, rng: Rng, len: usize) ![]u8 {
    return unicodeUtf8AllocFrom(allocator, rng, len);
}

pub fn unicodeUtf8Capacity(len: usize) error{OutOfMemory}!usize {
    return std.math.mul(usize, len, 4) catch return error.OutOfMemory;
}

pub fn unicodeUtf8Into(rng: Rng, out: []u8, len: usize) ![]u8 {
    return unicodeUtf8IntoFrom(rng, out, len);
}

pub fn unicodeUtf8IntoFrom(source: anytype, out: []u8, len: usize) ![]u8 {
    const capacity = try unicodeUtf8Capacity(len);
    if (out.len < capacity) return error.NoSpaceLeft;

    var written: usize = 0;
    var i: usize = 0;
    while (i < len) : (i += 1) {
        var buf: [4]u8 = undefined;
        const n = std.unicode.utf8Encode(unicodeScalarFrom(source), &buf) catch unreachable;
        @memcpy(out[written..][0..n], buf[0..n]);
        written += n;
    }

    return out[0..written];
}

pub fn unicodeUtf8AllocFrom(allocator: std.mem.Allocator, source: anytype, len: usize) ![]u8 {
    const capacity = try unicodeUtf8Capacity(len);
    var out = try std.ArrayList(u8).initCapacity(allocator, capacity);
    errdefer out.deinit(allocator);

    var i: usize = 0;
    while (i < len) : (i += 1) {
        var buf: [4]u8 = undefined;
        const n = std.unicode.utf8Encode(unicodeScalarFrom(source), &buf) catch unreachable;
        try out.appendSlice(allocator, buf[0..n]);
    }

    return out.toOwnedSlice(allocator);
}

test "ascii charset fills requested length" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(77);
    const rng = alea.Rng.init(&engine);

    const password = try Alphanumeric.alloc(std.testing.allocator, rng, 32);
    defer std.testing.allocator.free(password);

    try std.testing.expectEqualSlices(u8, alphanumeric, Alphanumeric.bytesValue());
    try std.testing.expectEqual(alphanumeric.len, Alphanumeric.len());
    try std.testing.expectEqual(alphanumeric.len, Alphanumeric.numChoices());
    try std.testing.expectEqual(@as(?usize, null), Alphanumeric.constantIndex());
    try std.testing.expect(!Alphanumeric.isEmpty());
    try std.testing.expectEqual(@as(u8, 'A'), try Alphanumeric.byteAt(0));
    try std.testing.expectError(error.InvalidParameter, Alphanumeric.byteAt(alphanumeric.len));
    try std.testing.expectEqual(@as(u8, 'A'), try Alphanumeric.item(0));
    try std.testing.expectEqual(@as(u8, '9'), try Alphanumeric.item(alphanumeric.len - 1));
    try std.testing.expectError(error.InvalidParameter, Alphanumeric.item(alphanumeric.len));
    try std.testing.expectEqual(@as(?u8, 'A'), Alphanumeric.get(0));
    try std.testing.expectEqual(@as(?u8, '9'), Alphanumeric.get(alphanumeric.len - 1));
    try std.testing.expectEqual(@as(?u8, null), Alphanumeric.get(alphanumeric.len));
    try std.testing.expectEqual(@as(?usize, 0), Alphanumeric.indexOf('A'));
    try std.testing.expectEqual(@as(?usize, 61), Alphanumeric.indexOf('9'));
    try std.testing.expect(Alphanumeric.contains('z'));
    try std.testing.expect(!Alphanumeric.contains('_'));
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / @as(f64, @floatFromInt(alphanumeric.len))), try Alphanumeric.probabilityAt(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / @as(f64, @floatFromInt(alphanumeric.len))), try Alphanumeric.probabilityAt(alphanumeric.len - 1), 1e-12);
    try std.testing.expectError(error.InvalidParameter, Alphanumeric.probabilityAt(alphanumeric.len));
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / @as(f64, @floatFromInt(alphanumeric.len))), Alphanumeric.probability(0).?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / @as(f64, @floatFromInt(alphanumeric.len))), Alphanumeric.probability(alphanumeric.len - 1).?, 1e-12);
    try std.testing.expectEqual(@as(?f64, null), Alphanumeric.probability(alphanumeric.len));
    var probability_iter = Alphanumeric.probabilityIter();
    try std.testing.expectEqual(alphanumeric.len, probability_iter.len());
    var probability_hint = probability_iter.sizeHint();
    try std.testing.expectEqual(alphanumeric.len, probability_hint.lower);
    try std.testing.expectEqual(@as(?usize, alphanumeric.len), probability_hint.upper);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / @as(f64, @floatFromInt(alphanumeric.len))), probability_iter.next().?, 1e-12);
    try std.testing.expectEqual(alphanumeric.len - 1, probability_iter.remaining());
    probability_hint = probability_iter.sizeHint();
    try std.testing.expectEqual(alphanumeric.len - 1, probability_hint.lower);
    try std.testing.expectEqual(@as(?usize, alphanumeric.len - 1), probability_hint.upper);
    var iter_probabilities: [3]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 3), probability_iter.fill(&iter_probabilities));
    for (iter_probabilities) |probability| {
        try std.testing.expectApproxEqAbs(@as(f64, 1.0 / @as(f64, @floatFromInt(alphanumeric.len))), probability, 1e-12);
    }
    try std.testing.expectEqual(alphanumeric.len - 4, probability_iter.len());
    probability_hint = probability_iter.sizeHint();
    try std.testing.expectEqual(alphanumeric.len - 4, probability_hint.lower);
    try std.testing.expectEqual(@as(?usize, alphanumeric.len - 4), probability_hint.upper);
    var iter_tail: [alphanumeric.len]f64 = undefined;
    try std.testing.expectEqual(alphanumeric.len - 4, probability_iter.fill(&iter_tail));
    try std.testing.expectEqual(@as(?f64, null), probability_iter.next());
    probability_hint = probability_iter.sizeHint();
    try std.testing.expectEqual(@as(usize, 0), probability_hint.lower);
    try std.testing.expectEqual(@as(?usize, 0), probability_hint.upper);
    var probabilities_buf: [alphanumeric.len]f64 = undefined;
    try Alphanumeric.probabilitiesInto(&probabilities_buf);
    for (probabilities_buf) |probability| {
        try std.testing.expectApproxEqAbs(@as(f64, 1.0 / @as(f64, @floatFromInt(alphanumeric.len))), probability, 1e-12);
    }
    var wrong_probability_len: [alphanumeric.len - 1]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, Alphanumeric.probabilitiesInto(&wrong_probability_len));
    const probabilities = try Alphanumeric.probabilities(std.testing.allocator);
    defer std.testing.allocator.free(probabilities);
    try std.testing.expectEqualSlices(f64, &probabilities_buf, probabilities);
    try std.testing.expectEqual(@as(usize, 32), password.len);
    for (password) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

    var direct_buf: [32]u8 = undefined;
    Alphanumeric.fillFrom(&engine, &direct_buf);
    for (direct_buf) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));
    var charset_fill_engine = alea.ScalarPrng.init(0x5880_a5c1);
    var charset_loop_engine = alea.ScalarPrng.init(0x5880_a5c1);
    var charset_fill: [32]u8 = undefined;
    var charset_loop: [32]u8 = undefined;
    Alphanumeric.fillFrom(&charset_fill_engine, &charset_fill);
    for (&charset_loop) |*byte| byte.* = Alphanumeric.sampleFrom(&charset_loop_engine);
    try std.testing.expectEqualSlices(u8, &charset_loop, &charset_fill);
    try std.testing.expectEqual(charset_loop_engine.next(), charset_fill_engine.next());

    const direct_password = try Alphanumeric.allocFrom(std.testing.allocator, &engine, 32);
    defer std.testing.allocator.free(direct_password);
    try std.testing.expectEqual(@as(usize, 32), direct_password.len);
    for (direct_password) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

    const direct_char = charFrom(&engine);
    try std.testing.expect(std.ascii.isAlphanumeric(direct_char));

    const direct_string = try stringFrom(std.testing.allocator, &engine, 16);
    defer std.testing.allocator.free(direct_string);
    for (direct_string) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

    const direct_sample_string = try sampleStringFrom(std.testing.allocator, &engine, 16);
    defer std.testing.allocator.free(direct_sample_string);
    for (direct_sample_string) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

    var append_list = try std.ArrayList(u8).initCapacity(std.testing.allocator, 3);
    defer append_list.deinit(std.testing.allocator);
    try append_list.appendSlice(std.testing.allocator, "id:");
    try Alphanumeric.appendStringFrom(std.testing.allocator, &engine, &append_list, 8);
    try std.testing.expectEqualStrings("id:", append_list.items[0..3]);
    for (append_list.items[3..]) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

    const checked_char = try Alphanumeric.sampleCheckedFrom(&engine);
    try std.testing.expect(std.ascii.isAlphanumeric(checked_char));
    var checked_buf: [8]u8 = undefined;
    try Alphanumeric.fillCheckedFrom(&engine, &checked_buf);
    for (checked_buf) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));
    const checked_alloc = try Alphanumeric.allocCheckedFrom(std.testing.allocator, &engine, 8);
    defer std.testing.allocator.free(checked_alloc);
    for (checked_alloc) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));
    const checked_sample_string = try Alphanumeric.sampleStringCheckedFrom(std.testing.allocator, &engine, 8);
    defer std.testing.allocator.free(checked_sample_string);
    for (checked_sample_string) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

    try std.testing.expectError(error.EmptyCharset, Charset.initChecked(""));
}

test "unicode scalar string generation produces valid utf8" {
    const alea = @import("root.zig");
    var engine = alea.DefaultPrng.init(78);
    const rng = alea.Rng.init(&engine);

    var i: usize = 0;
    while (i < 256) : (i += 1) {
        const scalar = unicodeScalar(rng);
        try std.testing.expect(scalar < 0xD800 or scalar > 0xDFFF);
        try std.testing.expect(scalar < 0x11_0000);

        const direct_scalar = unicodeScalarFrom(&engine);
        try std.testing.expect(direct_scalar < 0xD800 or direct_scalar > 0xDFFF);
        try std.testing.expect(direct_scalar < 0x11_0000);
    }

    const text = try unicodeUtf8Alloc(std.testing.allocator, rng, 64);
    defer std.testing.allocator.free(text);
    try std.testing.expectEqual(@as(usize, 64), try std.unicode.utf8CountCodepoints(text));

    const direct_text = try unicodeUtf8AllocFrom(std.testing.allocator, &engine, 64);
    defer std.testing.allocator.free(direct_text);
    try std.testing.expectEqual(@as(usize, 64), try std.unicode.utf8CountCodepoints(direct_text));

    var into_buf: [64 * 4]u8 = undefined;
    const into_text = try unicodeUtf8Into(rng, &into_buf, 64);
    try std.testing.expectEqual(@as(usize, 64), try std.unicode.utf8CountCodepoints(into_text));
}

test "ascii helpers preserve direct stream shape" {
    const alea = @import("root.zig");

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_a5c1);
        var direct_engine = Engine.init(0x5150_a5c1);
        const rng = alea.Rng.init(&facade_engine);

        try std.testing.expectEqual(Alphanumeric.sample(rng), Alphanumeric.sampleFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try std.testing.expectEqual(try Alphanumeric.sampleChecked(rng), try Alphanumeric.sampleCheckedFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_buf: [32]u8 = undefined;
        var direct_buf: [32]u8 = undefined;
        Alphanumeric.fill(rng, &facade_buf);
        Alphanumeric.fillFrom(&direct_engine, &direct_buf);
        try std.testing.expectEqualSlices(u8, &facade_buf, &direct_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try Alphanumeric.fillChecked(rng, &facade_buf);
        try Alphanumeric.fillCheckedFrom(&direct_engine, &direct_buf);
        try std.testing.expectEqualSlices(u8, &facade_buf, &direct_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_alloc = try Alphanumeric.alloc(std.testing.allocator, rng, 32);
        defer std.testing.allocator.free(facade_alloc);
        const direct_alloc = try Alphanumeric.allocFrom(std.testing.allocator, &direct_engine, 32);
        defer std.testing.allocator.free(direct_alloc);
        try std.testing.expectEqualSlices(u8, facade_alloc, direct_alloc);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_alloc = try Alphanumeric.allocChecked(std.testing.allocator, rng, 32);
        defer std.testing.allocator.free(facade_checked_alloc);
        const direct_checked_alloc = try Alphanumeric.allocCheckedFrom(std.testing.allocator, &direct_engine, 32);
        defer std.testing.allocator.free(direct_checked_alloc);
        try std.testing.expectEqualSlices(u8, facade_checked_alloc, direct_checked_alloc);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try std.testing.expectEqual(char(rng), charFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_string = try string(std.testing.allocator, rng, 32);
        defer std.testing.allocator.free(facade_string);
        const direct_string = try stringFrom(std.testing.allocator, &direct_engine, 32);
        defer std.testing.allocator.free(direct_string);
        try std.testing.expectEqualSlices(u8, facade_string, direct_string);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_sample_string = try sampleString(std.testing.allocator, rng, 16);
        defer std.testing.allocator.free(facade_sample_string);
        const direct_sample_string = try sampleStringFrom(std.testing.allocator, &direct_engine, 16);
        defer std.testing.allocator.free(direct_sample_string);
        try std.testing.expectEqualSlices(u8, facade_sample_string, direct_sample_string);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_list = try std.ArrayList(u8).initCapacity(std.testing.allocator, 2);
        defer facade_list.deinit(std.testing.allocator);
        try facade_list.appendSlice(std.testing.allocator, "x=");
        var direct_list = try std.ArrayList(u8).initCapacity(std.testing.allocator, 2);
        defer direct_list.deinit(std.testing.allocator);
        try direct_list.appendSlice(std.testing.allocator, "x=");
        try appendString(std.testing.allocator, rng, &facade_list, 12);
        try appendStringFrom(std.testing.allocator, &direct_engine, &direct_list, 12);
        try std.testing.expectEqualSlices(u8, facade_list.items, direct_list.items);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try std.testing.expectEqual(unicodeScalar(rng), unicodeScalarFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_text = try unicodeUtf8Alloc(std.testing.allocator, rng, 16);
        defer std.testing.allocator.free(facade_text);
        const direct_text = try unicodeUtf8AllocFrom(std.testing.allocator, &direct_engine, 16);
        defer std.testing.allocator.free(direct_text);
        try std.testing.expectEqualSlices(u8, facade_text, direct_text);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_text_buf: [16 * 4]u8 = undefined;
        var direct_text_buf: [16 * 4]u8 = undefined;
        const facade_text_into = try unicodeUtf8Into(rng, &facade_text_buf, 16);
        const direct_text_into = try unicodeUtf8IntoFrom(&direct_engine, &direct_text_buf, 16);
        try std.testing.expectEqualSlices(u8, facade_text_into, direct_text_into);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
}

test "invalid charset init does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_a5c2);

    try std.testing.expectError(error.EmptyCharset, Charset.initChecked(""));
    try std.testing.expectEqual(@as(u64, 0x96ac5eed591f009a), engine.next());

    const empty = Charset{ .bytes = "" };
    try std.testing.expect(empty.isEmpty());
    try std.testing.expectError(error.EmptyCharset, empty.sampleCheckedFrom(&engine));
    try std.testing.expectEqual(@as(u64, 0xb0fd2136eb6f389a), engine.next());
    var buf: [4]u8 = undefined;
    try std.testing.expectError(error.EmptyCharset, empty.fillCheckedFrom(&engine, &buf));
    try std.testing.expectEqual(@as(u64, 0xf4e0fac4c36143dd), engine.next());
    try std.testing.expectError(error.EmptyCharset, empty.allocCheckedFrom(std.testing.allocator, &engine, 4));
    try std.testing.expectEqual(@as(u64, 0xaacd156f0aacb592), engine.next());

    var zero_buf: [0]u8 = .{};
    try empty.fillCheckedFrom(&engine, &zero_buf);
    try std.testing.expectEqual(@as(u64, 0xdca041c18ee841a9), engine.next());
    const zero_alloc = try empty.allocCheckedFrom(std.testing.allocator, &engine, 0);
    defer std.testing.allocator.free(zero_alloc);
    try std.testing.expectEqual(@as(usize, 0), zero_alloc.len);
    try std.testing.expectEqual(@as(u64, 0xf4008d0537611435), engine.next());
    var empty_probabilities: [0]f64 = .{};
    try empty.probabilitiesInto(&empty_probabilities);
    const owned_empty_probabilities = try empty.probabilities(std.testing.allocator);
    defer std.testing.allocator.free(owned_empty_probabilities);
    try std.testing.expectEqual(@as(usize, 0), owned_empty_probabilities.len);
}

test "sampleString checked aliases handle empty charsets without consuming" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_a551);
    var control = alea.ScalarPrng.init(0x5150_a551);
    const empty = Charset{ .bytes = "" };

    try std.testing.expectError(error.EmptyCharset, empty.sampleStringCheckedFrom(std.testing.allocator, &engine, 4));
    try std.testing.expectEqual(control.next(), engine.next());

    var list = try std.ArrayList(u8).initCapacity(std.testing.allocator, 0);
    defer list.deinit(std.testing.allocator);
    try std.testing.expectError(error.EmptyCharset, empty.appendStringCheckedFrom(std.testing.allocator, &engine, &list, 4));
    try std.testing.expectEqual(control.next(), engine.next());

    const empty_string = try empty.sampleStringCheckedFrom(std.testing.allocator, &engine, 0);
    defer std.testing.allocator.free(empty_string);
    try std.testing.expectEqual(@as(usize, 0), empty_string.len);
    try std.testing.expectEqual(control.next(), engine.next());

    try empty.appendStringCheckedFrom(std.testing.allocator, &engine, &list, 0);
    try std.testing.expectEqual(@as(usize, 0), list.items.len);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "sampleString unchecked aliases handle empty charsets before allocation" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_a552);
    var control = alea.ScalarPrng.init(0x5150_a552);
    const empty = Charset{ .bytes = "" };

    var alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyCharset, empty.allocFrom(alloc.allocator(), &engine, 4));
    try std.testing.expect(!alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var sample_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyCharset, empty.sampleStringFrom(sample_alloc.allocator(), &engine, 4));
    try std.testing.expect(!sample_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var list = try std.ArrayList(u8).initCapacity(std.testing.allocator, 4);
    defer list.deinit(std.testing.allocator);
    try list.appendSlice(std.testing.allocator, "seed");
    var append_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyCharset, empty.appendStringFrom(append_alloc.allocator(), &engine, &list, 4));
    try std.testing.expect(!append_alloc.has_induced_failure);
    try std.testing.expectEqualStrings("seed", list.items);
    try std.testing.expectEqual(control.next(), engine.next());

    const zero = try empty.sampleStringFrom(std.testing.allocator, &engine, 0);
    defer std.testing.allocator.free(zero);
    try std.testing.expectEqual(@as(usize, 0), zero.len);
    try empty.appendStringFrom(std.testing.allocator, &engine, &list, 0);
    try std.testing.expectEqualStrings("seed", list.items);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "unicode charset strings sample from scalar choices" {
    const alea = @import("root.zig");
    const symbols = UnicodeCharset.init(&.{ 'α', 'β', 'γ', 0x1F600 });
    var engine = alea.ScalarPrng.init(0x5150_b001);
    const rng = alea.Rng.init(&engine);

    try std.testing.expectEqual(@as([]const u21, &.{ 'α', 'β', 'γ', 0x1F600 }), symbols.scalarsValue());
    try std.testing.expectEqual(@as(usize, 4), symbols.len());
    try std.testing.expectEqual(@as(usize, 4), symbols.numChoices());
    try std.testing.expectEqual(@as(?usize, null), symbols.constantIndex());
    try std.testing.expect(!symbols.isEmpty());
    try std.testing.expectEqual(@as(u21, 'α'), try symbols.scalarAt(0));
    try std.testing.expectEqual(@as(u21, 0x1F600), try symbols.item(3));
    try std.testing.expectError(error.InvalidParameter, symbols.item(4));
    try std.testing.expectEqual(@as(?u21, 'β'), symbols.get(1));
    try std.testing.expectEqual(@as(?u21, null), symbols.get(4));
    try std.testing.expectEqual(@as(?usize, 2), symbols.indexOf('γ'));
    try std.testing.expect(symbols.contains(0x1F600));
    try std.testing.expect(!symbols.contains('δ'));
    try std.testing.expectEqual(@as(usize, 4), symbols.maxUtf8Len());
    try std.testing.expectEqual(@as(usize, 20), try symbols.utf8Capacity(5));
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), try symbols.probabilityAt(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), symbols.probability(3).?, 1e-12);
    try std.testing.expectEqual(@as(?f64, null), symbols.probability(4));
    var probability_iter = symbols.probabilityIter();
    try std.testing.expectEqual(@as(usize, 4), probability_iter.len());
    var probability_hint = probability_iter.sizeHint();
    try std.testing.expectEqual(@as(usize, 4), probability_hint.lower);
    try std.testing.expectEqual(@as(?usize, 4), probability_hint.upper);
    var probability_buf: [2]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 2), probability_iter.fill(&probability_buf));
    for (probability_buf) |probability| try std.testing.expectApproxEqAbs(@as(f64, 0.25), probability, 1e-12);
    probability_hint = probability_iter.sizeHint();
    try std.testing.expectEqual(@as(usize, 2), probability_hint.lower);
    try std.testing.expectEqual(@as(?usize, 2), probability_hint.upper);
    const probabilities = try symbols.probabilities(std.testing.allocator);
    defer std.testing.allocator.free(probabilities);
    try std.testing.expectEqualSlices(f64, &.{ 0.25, 0.25, 0.25, 0.25 }, probabilities);
    var wrong_probabilities: [3]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, symbols.probabilitiesInto(&wrong_probabilities));

    const scalar = symbols.sample(rng);
    try std.testing.expect(symbols.contains(scalar));
    var scalar_buf: [12]u21 = undefined;
    symbols.fill(rng, &scalar_buf);
    for (scalar_buf) |item| try std.testing.expect(symbols.contains(item));

    const text = try symbols.sampleString(std.testing.allocator, rng, 12);
    defer std.testing.allocator.free(text);
    var view = try std.unicode.Utf8View.init(text);
    var iter = view.iterator();
    var count: usize = 0;
    while (iter.nextCodepoint()) |codepoint| {
        count += 1;
        try std.testing.expect(symbols.contains(codepoint));
    }
    try std.testing.expectEqual(@as(usize, 12), count);

    var appended = try std.ArrayList(u8).initCapacity(std.testing.allocator, 4);
    defer appended.deinit(std.testing.allocator);
    try appended.appendSlice(std.testing.allocator, "u:");
    try symbols.appendString(std.testing.allocator, rng, &appended, 6);
    try std.testing.expectEqualStrings("u:", appended.items[0..2]);
    view = try std.unicode.Utf8View.init(appended.items[2..]);
    iter = view.iterator();
    count = 0;
    while (iter.nextCodepoint()) |codepoint| {
        count += 1;
        try std.testing.expect(symbols.contains(codepoint));
    }
    try std.testing.expectEqual(@as(usize, 6), count);

    const singleton = UnicodeCharset.init(&.{0x2665});
    try std.testing.expectEqual(@as(?usize, 0), singleton.constantIndex());
    try std.testing.expectEqual(@as(u21, 0x2665), singleton.sampleFrom(&engine));
    var singleton_buf: [3]u21 = undefined;
    singleton.fillFrom(&engine, &singleton_buf);
    try std.testing.expectEqualSlices(u21, &.{ 0x2665, 0x2665, 0x2665 }, &singleton_buf);
    const singleton_text = try singleton.sampleStringFrom(std.testing.allocator, &engine, 3);
    defer std.testing.allocator.free(singleton_text);
    try std.testing.expectEqualStrings("♥♥♥", singleton_text);
}

test "unicode charset helpers preserve direct stream shape" {
    const alea = @import("root.zig");
    const symbols = UnicodeCharset.init(&.{ '水', '火', '木', '金', '土' });

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_b002);
        var direct_engine = Engine.init(0x5150_b002);
        const rng = alea.Rng.init(&facade_engine);

        try std.testing.expectEqual(symbols.sample(rng), symbols.sampleFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try std.testing.expectEqual(try symbols.sampleChecked(rng), try symbols.sampleCheckedFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_buf: [16]u21 = undefined;
        var direct_buf: [16]u21 = undefined;
        symbols.fill(rng, &facade_buf);
        symbols.fillFrom(&direct_engine, &direct_buf);
        try std.testing.expectEqualSlices(u21, &facade_buf, &direct_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        var fill_engine = Engine.init(0x5150_b003);
        var loop_engine = Engine.init(0x5150_b003);
        var fill_values: [16]u21 = undefined;
        var loop_values: [16]u21 = undefined;
        symbols.fillFrom(&fill_engine, &fill_values);
        for (&loop_values) |*scalar| scalar.* = symbols.sampleFrom(&loop_engine);
        try std.testing.expectEqualSlices(u21, &loop_values, &fill_values);
        try std.testing.expectEqual(loop_engine.next(), fill_engine.next());

        try symbols.fillChecked(rng, &facade_buf);
        try symbols.fillCheckedFrom(&direct_engine, &direct_buf);
        try std.testing.expectEqualSlices(u21, &facade_buf, &direct_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_text = try symbols.sampleString(std.testing.allocator, rng, 10);
        defer std.testing.allocator.free(facade_text);
        const direct_text = try symbols.sampleStringFrom(std.testing.allocator, &direct_engine, 10);
        defer std.testing.allocator.free(direct_text);
        try std.testing.expectEqualSlices(u8, facade_text, direct_text);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_text = try symbols.sampleStringChecked(std.testing.allocator, rng, 10);
        defer std.testing.allocator.free(facade_checked_text);
        const direct_checked_text = try symbols.sampleStringCheckedFrom(std.testing.allocator, &direct_engine, 10);
        defer std.testing.allocator.free(direct_checked_text);
        try std.testing.expectEqualSlices(u8, facade_checked_text, direct_checked_text);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_list = try std.ArrayList(u8).initCapacity(std.testing.allocator, 2);
        defer facade_list.deinit(std.testing.allocator);
        try facade_list.appendSlice(std.testing.allocator, "z=");
        var direct_list = try std.ArrayList(u8).initCapacity(std.testing.allocator, 2);
        defer direct_list.deinit(std.testing.allocator);
        try direct_list.appendSlice(std.testing.allocator, "z=");
        try symbols.appendString(std.testing.allocator, rng, &facade_list, 7);
        try symbols.appendStringFrom(std.testing.allocator, &direct_engine, &direct_list, 7);
        try std.testing.expectEqualSlices(u8, facade_list.items, direct_list.items);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        var append_fill_engine = Engine.init(0x5150_b004);
        var append_loop_engine = Engine.init(0x5150_b004);
        var append_direct = try std.ArrayList(u8).initCapacity(std.testing.allocator, 2);
        defer append_direct.deinit(std.testing.allocator);
        try append_direct.appendSlice(std.testing.allocator, "q=");
        var append_loop = try std.ArrayList(u8).initCapacity(std.testing.allocator, 2);
        defer append_loop.deinit(std.testing.allocator);
        try append_loop.appendSlice(std.testing.allocator, "q=");
        try symbols.appendStringFrom(std.testing.allocator, &append_fill_engine, &append_direct, 7);
        var append_i: usize = 0;
        while (append_i < 7) : (append_i += 1) {
            var buf: [4]u8 = undefined;
            const written = std.unicode.utf8Encode(symbols.sampleFrom(&append_loop_engine), &buf) catch unreachable;
            try append_loop.appendSlice(std.testing.allocator, buf[0..written]);
        }
        try std.testing.expectEqualSlices(u8, append_loop.items, append_direct.items);
        try std.testing.expectEqual(append_loop_engine.next(), append_fill_engine.next());

        try symbols.appendStringChecked(std.testing.allocator, rng, &facade_list, 7);
        try symbols.appendStringCheckedFrom(std.testing.allocator, &direct_engine, &direct_list, 7);
        try std.testing.expectEqualSlices(u8, facade_list.items, direct_list.items);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
}

test "unicode charset checked helpers validate without consuming" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_b003);
    var control = alea.ScalarPrng.init(0x5150_b003);
    const empty = UnicodeCharset{ .scalars = &.{} };
    const invalid = UnicodeCharset{ .scalars = &.{0xD800} };

    try std.testing.expectError(error.EmptyCharset, UnicodeCharset.initChecked(&.{}));
    try std.testing.expectError(error.InvalidParameter, UnicodeCharset.initChecked(&.{0xD800}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyCharset, empty.sampleCheckedFrom(&engine));
    try std.testing.expectEqual(control.next(), engine.next());
    try std.testing.expectError(error.InvalidParameter, invalid.sampleCheckedFrom(&engine));
    try std.testing.expectEqual(control.next(), engine.next());

    var scalar_buf: [2]u21 = undefined;
    try std.testing.expectError(error.EmptyCharset, empty.fillCheckedFrom(&engine, &scalar_buf));
    try std.testing.expectEqual(control.next(), engine.next());
    try std.testing.expectError(error.InvalidParameter, invalid.fillCheckedFrom(&engine, &scalar_buf));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyCharset, empty.sampleStringCheckedFrom(std.testing.allocator, &engine, 3));
    try std.testing.expectEqual(control.next(), engine.next());
    try std.testing.expectError(error.InvalidParameter, invalid.sampleStringCheckedFrom(std.testing.allocator, &engine, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    var list = try std.ArrayList(u8).initCapacity(std.testing.allocator, 2);
    defer list.deinit(std.testing.allocator);
    try list.appendSlice(std.testing.allocator, "x:");
    try std.testing.expectError(error.EmptyCharset, empty.appendStringCheckedFrom(std.testing.allocator, &engine, &list, 3));
    try std.testing.expectEqual(control.next(), engine.next());
    try std.testing.expectError(error.InvalidParameter, invalid.appendStringCheckedFrom(std.testing.allocator, &engine, &list, 3));
    try std.testing.expectEqual(control.next(), engine.next());
    try std.testing.expectEqualStrings("x:", list.items);

    const zero_empty = try empty.sampleStringCheckedFrom(std.testing.allocator, &engine, 0);
    defer std.testing.allocator.free(zero_empty);
    try std.testing.expectEqual(@as(usize, 0), zero_empty.len);
    try std.testing.expectEqual(control.next(), engine.next());
    const zero_invalid = try invalid.sampleStringCheckedFrom(std.testing.allocator, &engine, 0);
    defer std.testing.allocator.free(zero_invalid);
    try std.testing.expectEqual(@as(usize, 0), zero_invalid.len);
    try std.testing.expectEqual(control.next(), engine.next());
    try invalid.appendStringCheckedFrom(std.testing.allocator, &engine, &list, 0);
    try std.testing.expectEqualStrings("x:", list.items);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_scalar_buf: [0]u21 = .{};
    try invalid.fillCheckedFrom(&engine, &empty_scalar_buf);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "unicode charset unchecked strings validate before allocation" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_b007);
    var control = alea.ScalarPrng.init(0x5150_b007);
    const empty = UnicodeCharset{ .scalars = &.{} };
    const invalid = UnicodeCharset{ .scalars = &.{0xD800} };

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyCharset, empty.sampleStringFrom(empty_alloc.allocator(), &engine, 3));
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, invalid.sampleStringFrom(invalid_alloc.allocator(), &engine, 3));
    try std.testing.expect(!invalid_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var list = try std.ArrayList(u8).initCapacity(std.testing.allocator, 4);
    defer list.deinit(std.testing.allocator);
    try list.appendSlice(std.testing.allocator, "u:");
    var empty_append_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyCharset, empty.appendStringFrom(empty_append_alloc.allocator(), &engine, &list, 3));
    try std.testing.expect(!empty_append_alloc.has_induced_failure);
    try std.testing.expectEqualStrings("u:", list.items);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_append_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, invalid.appendStringFrom(invalid_append_alloc.allocator(), &engine, &list, 3));
    try std.testing.expect(!invalid_append_alloc.has_induced_failure);
    try std.testing.expectEqualStrings("u:", list.items);
    try std.testing.expectEqual(control.next(), engine.next());

    const zero_empty = try empty.sampleStringFrom(std.testing.allocator, &engine, 0);
    defer std.testing.allocator.free(zero_empty);
    try std.testing.expectEqual(@as(usize, 0), zero_empty.len);
    const zero_invalid = try invalid.sampleStringFrom(std.testing.allocator, &engine, 0);
    defer std.testing.allocator.free(zero_invalid);
    try std.testing.expectEqual(@as(usize, 0), zero_invalid.len);
    try invalid.appendStringFrom(std.testing.allocator, &engine, &list, 0);
    try std.testing.expectEqualStrings("u:", list.items);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "single-scalar unicode charset helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_b006);
    var control = alea.ScalarPrng.init(0x5150_b006);
    const rng = alea.Rng.init(&engine);
    const singleton = UnicodeCharset.init(&.{0x2665});

    try std.testing.expectEqual(@as(?usize, 0), singleton.constantIndex());
    try std.testing.expectEqual(@as(u21, 0x2665), singleton.sampleFrom(&engine));
    try std.testing.expectEqual(control.next(), engine.next());
    try std.testing.expectEqual(@as(u21, 0x2665), try singleton.sampleChecked(rng));
    try std.testing.expectEqual(control.next(), engine.next());

    var scalar_buf: [4]u21 = undefined;
    singleton.fillFrom(&engine, &scalar_buf);
    try std.testing.expectEqualSlices(u21, &.{ 0x2665, 0x2665, 0x2665, 0x2665 }, &scalar_buf);
    try std.testing.expectEqual(control.next(), engine.next());
    try singleton.fillChecked(rng, &scalar_buf);
    try std.testing.expectEqualSlices(u21, &.{ 0x2665, 0x2665, 0x2665, 0x2665 }, &scalar_buf);
    try std.testing.expectEqual(control.next(), engine.next());

    const text = try singleton.sampleStringFrom(std.testing.allocator, &engine, 3);
    defer std.testing.allocator.free(text);
    try std.testing.expectEqualStrings("♥♥♥", text);
    try std.testing.expectEqual(control.next(), engine.next());

    var list = try std.ArrayList(u8).initCapacity(std.testing.allocator, 2);
    defer list.deinit(std.testing.allocator);
    try list.appendSlice(std.testing.allocator, "s:");
    try singleton.appendString(std.testing.allocator, rng, &list, 2);
    try std.testing.expectEqualStrings("s:♥♥", list.items);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "initial unicode charset allocation failures do not consume random stream" {
    const alea = @import("root.zig");
    const symbols = UnicodeCharset.init(&.{ 'α', 'β', 0x1F600 });

    var sample_engine = alea.ScalarPrng.init(0x5150_b004);
    var sample_control = alea.ScalarPrng.init(0x5150_b004);
    var sample_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, symbols.sampleStringFrom(sample_alloc.allocator(), &sample_engine, 8));
    try std.testing.expect(sample_alloc.has_induced_failure);
    try std.testing.expectEqual(sample_control.next(), sample_engine.next());

    var append_engine = alea.ScalarPrng.init(0x5150_b005);
    var append_control = alea.ScalarPrng.init(0x5150_b005);
    var append_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    var list = try std.ArrayList(u8).initCapacity(std.testing.allocator, 2);
    defer list.deinit(std.testing.allocator);
    try list.appendSlice(std.testing.allocator, "p:");
    try std.testing.expectError(error.OutOfMemory, symbols.appendStringFrom(append_alloc.allocator(), &append_engine, &list, 8));
    try std.testing.expect(append_alloc.has_induced_failure);
    try std.testing.expectEqualStrings("p:", list.items);
    try std.testing.expectEqual(append_control.next(), append_engine.next());
}

test "invalid charset facade helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_a5cc);
    var control = alea.ScalarPrng.init(0x5150_a5cc);
    const rng = alea.Rng.init(&engine);
    const empty = Charset{ .bytes = "" };

    try std.testing.expectError(error.EmptyCharset, empty.sampleChecked(rng));
    try std.testing.expectEqual(control.next(), engine.next());

    var buf: [4]u8 = undefined;
    try std.testing.expectError(error.EmptyCharset, empty.fillChecked(rng, &buf));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyCharset, empty.allocChecked(std.testing.allocator, rng, 4));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "single-byte charset helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_a5d0);
    var control = alea.ScalarPrng.init(0x5150_a5d0);
    const rng = Rng.init(&engine);
    const only_x = Charset.init("x");
    try std.testing.expectEqual(@as(?usize, 0), only_x.constantIndex());

    try std.testing.expectEqual(@as(u8, 'x'), only_x.sampleFrom(&engine));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(u8, 'x'), try only_x.sampleChecked(rng));
    try std.testing.expectEqual(control.next(), engine.next());

    var out: [5]u8 = undefined;
    only_x.fillFrom(&engine, &out);
    try std.testing.expectEqualSlices(u8, "xxxxx", &out);
    try std.testing.expectEqual(control.next(), engine.next());

    try only_x.fillChecked(rng, &out);
    try std.testing.expectEqualSlices(u8, "xxxxx", &out);
    try std.testing.expectEqual(control.next(), engine.next());

    const allocated = try only_x.allocFrom(std.testing.allocator, &engine, 5);
    defer std.testing.allocator.free(allocated);
    try std.testing.expectEqualSlices(u8, "xxxxx", allocated);
    try std.testing.expectEqual(control.next(), engine.next());

    const checked_allocated = try only_x.allocChecked(std.testing.allocator, rng, 5);
    defer std.testing.allocator.free(checked_allocated);
    try std.testing.expectEqualSlices(u8, "xxxxx", checked_allocated);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "zero-length string helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_a5c3);

    const ascii = try stringFrom(std.testing.allocator, &engine, 0);
    defer std.testing.allocator.free(ascii);
    try std.testing.expectEqual(@as(usize, 0), ascii.len);
    try std.testing.expectEqual(@as(u64, 0xfa9e9b58f16c4eca), engine.next());

    const unicode = try unicodeUtf8AllocFrom(std.testing.allocator, &engine, 0);
    defer std.testing.allocator.free(unicode);
    try std.testing.expectEqual(@as(usize, 0), unicode.len);
    try std.testing.expectEqual(@as(u64, 0x19457be7e6aa9412), engine.next());

    var facade_engine = alea.ScalarPrng.init(0x5150_a5c5);
    var control_engine = alea.ScalarPrng.init(0x5150_a5c5);
    const rng = alea.Rng.init(&facade_engine);

    const facade_ascii = try string(std.testing.allocator, rng, 0);
    defer std.testing.allocator.free(facade_ascii);
    try std.testing.expectEqual(@as(usize, 0), facade_ascii.len);
    try std.testing.expectEqual(control_engine.next(), facade_engine.next());

    const facade_unicode = try unicodeUtf8Alloc(std.testing.allocator, rng, 0);
    defer std.testing.allocator.free(facade_unicode);
    try std.testing.expectEqual(@as(usize, 0), facade_unicode.len);
    try std.testing.expectEqual(control_engine.next(), facade_engine.next());
}

test "initial string allocation failures do not consume random stream" {
    const alea = @import("root.zig");

    var ascii_engine = alea.ScalarPrng.init(0x5150_a5c6);
    var ascii_control = alea.ScalarPrng.init(0x5150_a5c6);
    var ascii_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, stringFrom(ascii_alloc.allocator(), &ascii_engine, 8));
    try std.testing.expect(ascii_alloc.has_induced_failure);
    try std.testing.expectEqual(ascii_control.next(), ascii_engine.next());

    var unicode_engine = alea.ScalarPrng.init(0x5150_a5c7);
    var unicode_control = alea.ScalarPrng.init(0x5150_a5c7);
    var unicode_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, unicodeUtf8AllocFrom(unicode_alloc.allocator(), &unicode_engine, 8));
    try std.testing.expect(unicode_alloc.has_induced_failure);
    try std.testing.expectEqual(unicode_control.next(), unicode_engine.next());

    var facade_engine = alea.ScalarPrng.init(0x5150_a5c8);
    var facade_control = alea.ScalarPrng.init(0x5150_a5c8);
    const rng = alea.Rng.init(&facade_engine);

    var facade_ascii_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, string(facade_ascii_alloc.allocator(), rng, 8));
    try std.testing.expect(facade_ascii_alloc.has_induced_failure);
    try std.testing.expectEqual(facade_control.next(), facade_engine.next());

    var facade_unicode_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, unicodeUtf8Alloc(facade_unicode_alloc.allocator(), rng, 8));
    try std.testing.expect(facade_unicode_alloc.has_induced_failure);
    try std.testing.expectEqual(facade_control.next(), facade_engine.next());
}

test "unicode utf8 allocation length overflow does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_a5c4);

    try std.testing.expectError(error.OutOfMemory, unicodeUtf8AllocFrom(std.testing.allocator, &engine, std.math.maxInt(usize)));
    try std.testing.expectEqual(@as(u64, 0x5472254f9f2945e9), engine.next());
}

test "unicode utf8 output buffer validation does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_a5c9);
    var control = alea.ScalarPrng.init(0x5150_a5c9);

    try std.testing.expectEqual(@as(usize, 0), try unicodeUtf8Capacity(0));
    try std.testing.expectEqual(@as(usize, 8), try unicodeUtf8Capacity(2));
    try std.testing.expectEqual(@as(usize, std.math.maxInt(usize) - 3), try unicodeUtf8Capacity(std.math.maxInt(usize) / 4));
    try std.testing.expectError(error.OutOfMemory, unicodeUtf8Capacity(std.math.maxInt(usize)));

    var tiny: [0]u8 = .{};
    try std.testing.expectError(error.OutOfMemory, unicodeUtf8IntoFrom(&engine, &tiny, std.math.maxInt(usize)));
    try std.testing.expectEqual(control.next(), engine.next());

    var short: [7]u8 = undefined;
    try std.testing.expectError(error.NoSpaceLeft, unicodeUtf8IntoFrom(&engine, &short, 2));
    try std.testing.expectEqual(control.next(), engine.next());

    var facade_engine = alea.ScalarPrng.init(0x5150_a5ca);
    var facade_control = alea.ScalarPrng.init(0x5150_a5ca);
    const rng = alea.Rng.init(&facade_engine);
    try std.testing.expectError(error.NoSpaceLeft, unicodeUtf8Into(rng, &short, 2));
    try std.testing.expectEqual(facade_control.next(), facade_engine.next());

    var empty: [0]u8 = .{};
    const text = try unicodeUtf8IntoFrom(&engine, &empty, 0);
    try std.testing.expectEqual(@as(usize, 0), text.len);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "unicode utf8 into has stable byte snapshot" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_a5cb);

    var buf: [6 * 4]u8 = undefined;
    const text = try unicodeUtf8IntoFrom(&engine, &buf, 6);
    try std.testing.expectEqualSlices(u8, &.{
        0xf3, 0x8b, 0x84, 0xa3, 0xf1, 0xb7, 0x84, 0x94,
        0xf0, 0xaf, 0xa0, 0xa0, 0xf0, 0xab, 0xa1, 0x9a,
        0xf2, 0xb7, 0x93, 0xb6, 0xf1, 0xa6, 0x8f, 0x97,
    }, text);
    try std.testing.expectEqual(@as(u64, 0x63aca2a5212f8669), engine.next());
}

test "ascii helpers have stable snapshots" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x1234_5678_9abc_def0);
    const rng = alea.Rng.init(&engine);

    try std.testing.expectEqual(@as(u8, 'I'), char(rng));

    var filled: [16]u8 = undefined;
    Alphanumeric.fill(rng, &filled);
    try std.testing.expectEqualSlices(u8, "YgyjAl2O8koQA6gG", &filled);

    const sampled = try string(std.testing.allocator, rng, 16);
    defer std.testing.allocator.free(sampled);
    try std.testing.expectEqualSlices(u8, "2jpYtsabnOVHQtfb", sampled);

    try std.testing.expectEqual(@as(u21, 0x59e2b), unicodeScalar(rng));

    const utf8 = try unicodeUtf8Alloc(std.testing.allocator, rng, 6);
    defer std.testing.allocator.free(utf8);
    try std.testing.expectEqualSlices(u8, &.{
        0xf1, 0x9e, 0xb9, 0x99, 0xf2, 0xa8, 0x9b, 0x83,
        0xf1, 0xaa, 0xaf, 0xae, 0xf1, 0x93, 0xb5, 0xae,
        0xf3, 0x9f, 0xa8, 0xa9, 0xf4, 0x85, 0xa2, 0x8c,
    }, utf8);
    try std.testing.expectEqual(@as(u64, 0x11b40122bde6eb6a), engine.next());
}
