const std = @import("std");

const Check = struct {
    path: []const u8,
    label: []const u8,
};

const checks = [_]Check{
    .{ .path = "src/root.zig", .label = "root" },
    .{ .path = "src/rng.zig", .label = "Rng" },
    .{ .path = "src/distributions.zig", .label = "distributions" },
    .{ .path = "src/seq.zig", .label = "seq" },
    .{ .path = "src/ascii.zig", .label = "ascii" },
    .{ .path = "src/seed.zig", .label = "Seed" },
    .{ .path = "src/engines/alea4x64.zig", .label = "Alea4x64" },
    .{ .path = "src/engines/chacha.zig", .label = "ChaCha" },
    .{ .path = "src/engines/pcg64.zig", .label = "Pcg64" },
    .{ .path = "src/engines/splitmix64.zig", .label = "SplitMix64" },
    .{ .path = "src/engines/wyhash64.zig", .label = "Wyhash64" },
    .{ .path = "src/engines/xoshiro256.zig", .label = "Xoshiro256" },
    .{ .path = "src/engines/xoshiro256plusplus.zig", .label = "Xoshiro256PlusPlus" },
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var stderr_buffer: [1024]u8 = undefined;
    var stderr_file = std.Io.File.stderr().writer(io, &stderr_buffer);
    const stderr = &stderr_file.interface;

    const allocator = std.heap.smp_allocator;
    const api = try std.Io.Dir.cwd().readFileAlloc(io, "docs/api-reference.md", allocator, .limited(8 * 1024 * 1024));
    defer allocator.free(api);

    var missing_count: usize = 0;
    inline for (checks) |check| {
        missing_count += try checkFile(io, allocator, stderr, api, check.path, check.label);
    }

    if (missing_count != 0) {
        try stderr.print("apicheck failed: {} public symbol(s) missing from docs/api-reference.md\n", .{missing_count});
        try stderr.flush();
        return error.ApiReferenceIncomplete;
    }

    try stdout.print("apicheck ok\n", .{});
    try stdout.flush();
}

fn checkFile(io: std.Io, allocator: std.mem.Allocator, stderr: *std.Io.Writer, api: []const u8, path: []const u8, label: []const u8) !usize {
    const source = try std.Io.Dir.cwd().readFileAlloc(io, path, allocator, .limited(8 * 1024 * 1024));
    defer allocator.free(source);

    var missing: usize = 0;
    var lines = std.mem.splitScalar(u8, source, '\n');
    while (lines.next()) |line| {
        const name = publicSymbolName(line) orelse continue;
        if (std.mem.indexOf(u8, api, name) == null) {
            try stderr.print("{s}: missing `{s}`\n", .{ label, name });
            missing += 1;
        }
    }
    return missing;
}

fn publicSymbolName(line: []const u8) ?[]const u8 {
    var rest = std.mem.trimStart(u8, line, " \t");
    if (!consumeToken(&rest, "pub")) return null;
    _ = consumeToken(&rest, "inline");
    if (!(consumeToken(&rest, "fn") or consumeToken(&rest, "const"))) return null;

    rest = std.mem.trimStart(u8, rest, " \t");
    if (rest.len == 0) return null;

    var end: usize = 0;
    while (end < rest.len) : (end += 1) {
        const c = rest[end];
        if (!std.ascii.isAlphanumeric(c) and c != '_') break;
    }
    if (end == 0) return null;
    return rest[0..end];
}

fn consumeToken(rest: *[]const u8, token: []const u8) bool {
    var s = std.mem.trimStart(u8, rest.*, " \t");
    if (!std.mem.startsWith(u8, s, token)) return false;
    if (s.len > token.len) {
        const next = s[token.len];
        if (std.ascii.isAlphanumeric(next) or next == '_') return false;
    }
    s = s[token.len..];
    rest.* = s;
    return true;
}
