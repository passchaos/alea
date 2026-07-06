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
    .{ .path = "src/quality.zig", .label = "quality" },
    .{ .path = "src/seed.zig", .label = "Seed" },
    .{ .path = "src/engines/alea4x64.zig", .label = "Alea4x64" },
    .{ .path = "src/engines/chacha.zig", .label = "ChaCha" },
    .{ .path = "src/engines/chacha8.zig", .label = "ChaCha8Rng" },
    .{ .path = "src/engines/chacha20.zig", .label = "ChaCha20Rng" },
    .{ .path = "src/engines/pcg64.zig", .label = "Pcg64" },
    .{ .path = "src/engines/splitmix64.zig", .label = "SplitMix64" },
    .{ .path = "src/engines/step.zig", .label = "StepRng" },
    .{ .path = "src/engines/wyhash64.zig", .label = "Wyhash64" },
    .{ .path = "src/engines/xoshiro128plusplus.zig", .label = "Xoshiro128PlusPlus" },
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
    var public_type_stack: [32]PublicType = undefined;
    var public_type_count: usize = 0;
    var lines = std.mem.splitScalar(u8, source, '\n');
    while (lines.next()) |line| {
        const indent = lineIndent(line);
        if (std.mem.trim(u8, line, " \t\r").len == 0) continue;
        while (public_type_count > 0 and indent <= public_type_stack[public_type_count - 1].indent) {
            public_type_count -= 1;
        }

        const name = publicSymbolName(line) orelse continue;
        if (publicTypeName(line)) |type_name| {
            if (public_type_count < public_type_stack.len) {
                public_type_stack[public_type_count] = .{ .name = type_name, .indent = indent };
                public_type_count += 1;
            }
        }

        if (public_type_count > 0 and indent > public_type_stack[public_type_count - 1].indent) {
            const parent = public_type_stack[public_type_count - 1].name;
            const dotted = try std.fmt.allocPrint(allocator, "{s}.{s}", .{ parent, name });
            defer allocator.free(dotted);
            if (!containsNestedSymbol(api, parent, name)) {
                try stderr.print("{s}: missing `{s}`\n", .{ label, dotted });
                missing += 1;
            }
        } else {
            if (!containsSymbol(api, name)) {
                try stderr.print("{s}: missing `{s}`\n", .{ label, name });
                missing += 1;
            }
        }
    }
    return missing;
}

const PublicType = struct {
    name: []const u8,
    indent: usize,
};

fn containsSymbol(haystack: []const u8, needle: []const u8) bool {
    var offset: usize = 0;
    while (std.mem.indexOfPos(u8, haystack, offset, needle)) |index| {
        const before_ok = index == 0 or !isSymbolChar(haystack[index - 1]);
        const after_index = index + needle.len;
        const after_ok = after_index == haystack.len or !isSymbolChar(haystack[after_index]);
        if (before_ok and after_ok) return true;
        offset = index + 1;
    }
    return false;
}

fn containsNestedSymbol(haystack: []const u8, parent: []const u8, child: []const u8) bool {
    var dotted_buffer: [128]u8 = undefined;
    if (parent.len + child.len + 1 <= dotted_buffer.len) {
        const dotted = std.fmt.bufPrint(&dotted_buffer, "{s}.{s}", .{ parent, child }) catch unreachable;
        if (containsSymbol(haystack, dotted)) return true;
    }

    var offset: usize = 0;
    while (std.mem.indexOfPos(u8, haystack, offset, parent)) |index| {
        const before_ok = index == 0 or !isSymbolChar(haystack[index - 1]);
        const after_parent = index + parent.len;
        if (before_ok and after_parent < haystack.len and haystack[after_parent] == '(') {
            if (std.mem.indexOfScalarPos(u8, haystack, after_parent, ')')) |close| {
                const dot = close + 1;
                const child_start = dot + 1;
                const child_end = child_start + child.len;
                if (dot < haystack.len and haystack[dot] == '.' and
                    child_end <= haystack.len and
                    std.mem.eql(u8, haystack[child_start..child_end], child) and
                    (child_end == haystack.len or !isSymbolChar(haystack[child_end])))
                {
                    return true;
                }
            }
        }
        offset = index + 1;
    }
    return false;
}

fn isSymbolChar(c: u8) bool {
    return std.ascii.isAlphanumeric(c) or c == '_';
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
        if (!isSymbolChar(c)) break;
    }
    if (end == 0) return null;
    return rest[0..end];
}

fn publicTypeName(line: []const u8) ?[]const u8 {
    var rest = std.mem.trimStart(u8, line, " \t");
    if (!consumeToken(&rest, "pub")) return null;
    if (!(consumeToken(&rest, "const") or consumeToken(&rest, "fn"))) return null;

    rest = std.mem.trimStart(u8, rest, " \t");
    var end: usize = 0;
    while (end < rest.len) : (end += 1) {
        const c = rest[end];
        if (!isSymbolChar(c)) break;
    }
    if (end == 0) return null;
    const name = rest[0..end];

    rest = std.mem.trimStart(u8, rest[end..], " \t");
    if (std.mem.startsWith(u8, rest, "=")) {
        rest = std.mem.trimStart(u8, rest[1..], " \t");
        if (std.mem.startsWith(u8, rest, "struct") or
            std.mem.startsWith(u8, rest, "union") or
            std.mem.startsWith(u8, rest, "enum"))
        {
            return name;
        }
    }
    if (std.mem.startsWith(u8, rest, "(")) {
        if (std.mem.indexOf(u8, rest, ") type")) |_| return name;
    }
    return null;
}

fn lineIndent(line: []const u8) usize {
    var count: usize = 0;
    while (count < line.len and (line[count] == ' ' or line[count] == '\t')) : (count += 1) {}
    return count;
}

fn consumeToken(rest: *[]const u8, token: []const u8) bool {
    var s = std.mem.trimStart(u8, rest.*, " \t");
    if (!std.mem.startsWith(u8, s, token)) return false;
    if (s.len > token.len) {
        const next = s[token.len];
        if (isSymbolChar(next)) return false;
    }
    s = s[token.len..];
    rest.* = s;
    return true;
}

test "containsSymbol uses identifier boundaries" {
    try std.testing.expect(containsSymbol("alpha beta gamma", "beta"));
    try std.testing.expect(!containsSymbol("alphabet betamax gamma", "beta"));
    try std.testing.expect(!containsSymbol("alpha_beta gamma", "alpha"));
    try std.testing.expect(containsSymbol("`alpha`", "alpha"));
}

test "containsNestedSymbol accepts dotted and generic-parent documentation" {
    try std.testing.expect(containsNestedSymbol("Sampler.init", "Sampler", "init"));
    try std.testing.expect(containsNestedSymbol("Sampler(u32).init", "Sampler", "init"));
    try std.testing.expect(!containsNestedSymbol("Sampler(u32).initializer", "Sampler", "init"));
}

test "public symbol parsing handles functions, constants, and inline functions" {
    try std.testing.expectEqualStrings("sample", publicSymbolName("pub fn sample() void {").?);
    try std.testing.expectEqualStrings("sampleFast", publicSymbolName("pub inline fn sampleFast() void {").?);
    try std.testing.expectEqualStrings("Value", publicSymbolName("pub const Value = u64;").?);
    try std.testing.expect(publicSymbolName("const Private = u64;") == null);
}

test "public type parsing tracks structs and generic type factories" {
    try std.testing.expectEqualStrings("Sampler", publicTypeName("pub const Sampler = struct {").?);
    try std.testing.expectEqualStrings("Choice", publicTypeName("pub fn Choice(comptime T: type) type {").?);
    try std.testing.expect(publicTypeName("pub const value = 1;") == null);
}
