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

    pub fn bytesValue(self: Charset) []const u8 {
        return self.bytes;
    }

    pub fn len(self: Charset) usize {
        return self.bytes.len;
    }

    pub fn isEmpty(self: Charset) bool {
        return self.len() == 0;
    }

    pub fn byteAt(self: Charset, index: usize) error{InvalidParameter}!u8 {
        if (index >= self.bytes.len) return error.InvalidParameter;
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
        for (out) |*byte| byte.* = self.sampleFrom(source);
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
        const out = try allocator.alloc(u8, length);
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
    try std.testing.expect(!Alphanumeric.isEmpty());
    try std.testing.expectEqual(@as(u8, 'A'), try Alphanumeric.byteAt(0));
    try std.testing.expectError(error.InvalidParameter, Alphanumeric.byteAt(alphanumeric.len));
    try std.testing.expectEqual(@as(?usize, 0), Alphanumeric.indexOf('A'));
    try std.testing.expectEqual(@as(?usize, 61), Alphanumeric.indexOf('9'));
    try std.testing.expect(Alphanumeric.contains('z'));
    try std.testing.expect(!Alphanumeric.contains('_'));
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / @as(f64, @floatFromInt(alphanumeric.len))), try Alphanumeric.probabilityAt(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / @as(f64, @floatFromInt(alphanumeric.len))), try Alphanumeric.probabilityAt(alphanumeric.len - 1), 1e-12);
    try std.testing.expectError(error.InvalidParameter, Alphanumeric.probabilityAt(alphanumeric.len));
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

    const direct_password = try Alphanumeric.allocFrom(std.testing.allocator, &engine, 32);
    defer std.testing.allocator.free(direct_password);
    try std.testing.expectEqual(@as(usize, 32), direct_password.len);
    for (direct_password) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

    const direct_char = charFrom(&engine);
    try std.testing.expect(std.ascii.isAlphanumeric(direct_char));

    const direct_string = try stringFrom(std.testing.allocator, &engine, 16);
    defer std.testing.allocator.free(direct_string);
    for (direct_string) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

    const checked_char = try Alphanumeric.sampleCheckedFrom(&engine);
    try std.testing.expect(std.ascii.isAlphanumeric(checked_char));
    var checked_buf: [8]u8 = undefined;
    try Alphanumeric.fillCheckedFrom(&engine, &checked_buf);
    for (checked_buf) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));
    const checked_alloc = try Alphanumeric.allocCheckedFrom(std.testing.allocator, &engine, 8);
    defer std.testing.allocator.free(checked_alloc);
    for (checked_alloc) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));

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
