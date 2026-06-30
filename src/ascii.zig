const std = @import("std");
const Rng = @import("rng.zig");

pub const alphanumeric = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
pub const alphabetic = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
pub const lowercase = "abcdefghijklmnopqrstuvwxyz";
pub const uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
pub const digits = "0123456789";

pub const Charset = struct {
    bytes: []const u8,

    pub fn init(bytes: []const u8) Charset {
        std.debug.assert(bytes.len > 0);
        return .{ .bytes = bytes };
    }

    pub fn initChecked(bytes: []const u8) error{EmptyCharset}!Charset {
        if (bytes.len == 0) return error.EmptyCharset;
        return .{ .bytes = bytes };
    }

    pub fn sample(self: Charset, rng: Rng) u8 {
        return self.sampleFrom(rng);
    }

    pub fn sampleFrom(self: Charset, source: anytype) u8 {
        return self.bytes[Rng.uintLessThanFrom(source, usize, self.bytes.len)];
    }

    pub fn fill(self: Charset, rng: Rng, out: []u8) void {
        self.fillFrom(rng, out);
    }

    pub fn fillFrom(self: Charset, source: anytype, out: []u8) void {
        for (out) |*byte| byte.* = self.sampleFrom(source);
    }

    pub fn alloc(self: Charset, allocator: std.mem.Allocator, rng: Rng, len: usize) ![]u8 {
        return self.allocFrom(allocator, rng, len);
    }

    pub fn allocFrom(self: Charset, allocator: std.mem.Allocator, source: anytype, len: usize) ![]u8 {
        const out = try allocator.alloc(u8, len);
        self.fillFrom(source, out);
        return out;
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

pub fn unicodeScalar(rng: Rng) u21 {
    return unicodeScalarFrom(rng);
}

pub fn unicodeScalarFrom(source: anytype) u21 {
    return Rng.unicodeScalarFrom(source);
}

pub fn unicodeUtf8Alloc(allocator: std.mem.Allocator, rng: Rng, len: usize) ![]u8 {
    return unicodeUtf8AllocFrom(allocator, rng, len);
}

pub fn unicodeUtf8AllocFrom(allocator: std.mem.Allocator, source: anytype, len: usize) ![]u8 {
    var out = try std.ArrayList(u8).initCapacity(allocator, len);
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

    try std.testing.expectEqual(@as(usize, 32), password.len);
    for (password) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

    var direct_buf: [32]u8 = undefined;
    Alphanumeric.fillFrom(&engine, &direct_buf);
    for (direct_buf) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

    const direct_password = try Alphanumeric.allocFrom(std.testing.allocator, &engine, 32);
    defer std.testing.allocator.free(direct_password);
    try std.testing.expectEqual(@as(usize, 32), direct_password.len);
    for (direct_password) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

    const direct_char = charFrom(&engine);
    try std.testing.expect(std.ascii.isAlphanumeric(direct_char));

    const direct_string = try stringFrom(std.testing.allocator, &engine, 16);
    defer std.testing.allocator.free(direct_string);
    for (direct_string) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

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
}

test "ascii helpers preserve direct stream shape" {
    const alea = @import("root.zig");

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_a5c1);
        var direct_engine = Engine.init(0x5150_a5c1);
        const rng = alea.Rng.init(&facade_engine);

        try std.testing.expectEqual(Alphanumeric.sample(rng), Alphanumeric.sampleFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_buf: [32]u8 = undefined;
        var direct_buf: [32]u8 = undefined;
        Alphanumeric.fill(rng, &facade_buf);
        Alphanumeric.fillFrom(&direct_engine, &direct_buf);
        try std.testing.expectEqualSlices(u8, &facade_buf, &direct_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_alloc = try Alphanumeric.alloc(std.testing.allocator, rng, 32);
        defer std.testing.allocator.free(facade_alloc);
        const direct_alloc = try Alphanumeric.allocFrom(std.testing.allocator, &direct_engine, 32);
        defer std.testing.allocator.free(direct_alloc);
        try std.testing.expectEqualSlices(u8, facade_alloc, direct_alloc);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try std.testing.expectEqual(char(rng), charFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_string = try string(std.testing.allocator, rng, 32);
        defer std.testing.allocator.free(facade_string);
        const direct_string = try stringFrom(std.testing.allocator, &direct_engine, 32);
        defer std.testing.allocator.free(direct_string);
        try std.testing.expectEqualSlices(u8, facade_string, direct_string);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try std.testing.expectEqual(unicodeScalar(rng), unicodeScalarFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_text = try unicodeUtf8Alloc(std.testing.allocator, rng, 16);
        defer std.testing.allocator.free(facade_text);
        const direct_text = try unicodeUtf8AllocFrom(std.testing.allocator, &direct_engine, 16);
        defer std.testing.allocator.free(direct_text);
        try std.testing.expectEqualSlices(u8, facade_text, direct_text);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
}
