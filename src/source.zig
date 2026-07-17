const std = @import("std");

pub inline fn nextU64(source: anytype) u64 {
    if (comptime hasDecl(@TypeOf(source), "next")) return source.next();
    return source.nextU64();
}

pub inline fn tryNextU64(source: anytype) !u64 {
    // Seed-derivation helpers historically consumed `tryNext()` when a source
    // provided it.  Keep that precedence for sources exposing both spellings,
    // but accept the Rust-discoverable `tryNextU64()` alias as a fallback.
    if (comptime hasDecl(@TypeOf(source), "tryNext")) return source.tryNext();
    if (comptime hasDecl(@TypeOf(source), "tryNextU64")) return source.tryNextU64();
    return nextU64(source);
}

pub fn hasDecl(comptime Source: type, comptime name: []const u8) bool {
    const info = @typeInfo(Source);
    if (info == .pointer and info.pointer.size == .one) {
        return @hasDecl(info.pointer.child, name);
    }
    return @hasDecl(Source, name);
}

test "source helper prefers next and falls back to nextU64" {
    const Both = struct {
        fn next(_: *@This()) u64 {
            return 1;
        }

        fn nextU64(_: *@This()) u64 {
            return 2;
        }
    };
    const NativeU64 = struct {
        fn nextU64(_: *@This()) u64 {
            return 3;
        }
    };

    var both = Both{};
    try std.testing.expectEqual(@as(u64, 1), nextU64(&both));
    var native = NativeU64{};
    try std.testing.expectEqual(@as(u64, 3), nextU64(&native));
}
