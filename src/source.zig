const std = @import("std");

pub inline fn nextU64(source: anytype) u64 {
    if (comptime hasDecl(@TypeOf(source), "next")) return source.next();
    if (comptime hasDecl(@TypeOf(source), "nextU64")) return source.nextU64();
    if (comptime hasDecl(@TypeOf(source), "nextU32")) return nextU64FromU32(source);
    @compileError(@typeName(@TypeOf(source)) ++ " must expose next, nextU64, or nextU32");
}

pub inline fn nextU32(source: anytype) u32 {
    if (comptime hasDecl(@TypeOf(source), "nextU32")) return source.nextU32();
    if (comptime hasDecl(@TypeOf(source), "next") or hasDecl(@TypeOf(source), "nextU64")) {
        return @truncate(nextU64(source) >> 32);
    }
    @compileError(@typeName(@TypeOf(source)) ++ " must expose nextU32 or a u64 raw draw");
}

pub inline fn tryNextU64(source: anytype) !u64 {
    // Seed-derivation helpers historically consumed `tryNext()` when a source
    // provided it.  Keep that precedence for sources exposing both spellings,
    // but accept the Rust-discoverable raw aliases as fallbacks.
    if (comptime hasDecl(@TypeOf(source), "tryNext")) return source.tryNext();
    if (comptime hasDecl(@TypeOf(source), "tryNextU64")) return source.tryNextU64();
    if (comptime hasDecl(@TypeOf(source), "tryNextU32")) return tryNextU64FromU32(source);
    if (comptime hasDecl(@TypeOf(source), "next") or hasDecl(@TypeOf(source), "nextU64") or hasDecl(@TypeOf(source), "nextU32")) return nextU64(source);
    @compileError(@typeName(@TypeOf(source)) ++ " must expose a fallible or infallible raw draw");
}

pub inline fn tryNextU32(source: anytype) !u32 {
    if (comptime hasDecl(@TypeOf(source), "tryNextU32")) return source.tryNextU32();
    if (comptime hasDecl(@TypeOf(source), "nextU32")) return source.nextU32();
    if (comptime hasDecl(@TypeOf(source), "tryNext") or hasDecl(@TypeOf(source), "tryNextU64") or hasDecl(@TypeOf(source), "next") or hasDecl(@TypeOf(source), "nextU64")) {
        return @truncate((try tryNextU64(source)) >> 32);
    }
    @compileError(@typeName(@TypeOf(source)) ++ " must expose a u32 raw draw or a u64 raw draw");
}

pub inline fn nextU64FromU32(source: anytype) u64 {
    const low: u64 = source.nextU32();
    const high: u64 = source.nextU32();
    return low | (high << 32);
}

pub inline fn tryNextU64FromU32(source: anytype) !u64 {
    const low: u64 = try source.tryNextU32();
    const high: u64 = try source.tryNextU32();
    return low | (high << 32);
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
    const NativeU32 = struct {
        index: u32 = 0,

        fn nextU32(self: *@This()) u32 {
            self.index += 1;
            return self.index;
        }
    };

    var both = Both{};
    try std.testing.expectEqual(@as(u64, 1), nextU64(&both));
    var native = NativeU64{};
    try std.testing.expectEqual(@as(u64, 3), nextU64(&native));
    var native32 = NativeU32{};
    try std.testing.expectEqual(@as(u64, 0x0000_0002_0000_0001), nextU64(&native32));
}
