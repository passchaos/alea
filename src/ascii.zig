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

    pub fn sample(self: Charset, rng: Rng) u8 {
        return self.bytes[rng.uintLessThan(usize, self.bytes.len)];
    }

    pub fn fill(self: Charset, rng: Rng, out: []u8) void {
        for (out) |*byte| byte.* = self.sample(rng);
    }

    pub fn alloc(self: Charset, allocator: std.mem.Allocator, rng: Rng, len: usize) ![]u8 {
        const out = try allocator.alloc(u8, len);
        self.fill(rng, out);
        return out;
    }
};

pub const Alphanumeric = Charset{ .bytes = alphanumeric };
pub const Alphabetic = Charset{ .bytes = alphabetic };
pub const Lowercase = Charset{ .bytes = lowercase };
pub const Uppercase = Charset{ .bytes = uppercase };
pub const Digits = Charset{ .bytes = digits };

pub fn char(rng: Rng) u8 {
    return Alphanumeric.sample(rng);
}

pub fn string(allocator: std.mem.Allocator, rng: Rng, len: usize) ![]u8 {
    return Alphanumeric.alloc(allocator, rng, len);
}

test "ascii charset fills requested length" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(77);
    const rng = alea.Rng.init(&engine);

    const password = try Alphanumeric.alloc(std.testing.allocator, rng, 32);
    defer std.testing.allocator.free(password);

    try std.testing.expectEqual(@as(usize, 32), password.len);
    for (password) |byte| try std.testing.expect(std.ascii.isAlphanumeric(byte));
}
