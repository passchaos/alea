const std = @import("std");

const required_tools = [_][]const u8{
    "node",
    "cargo",
    "rustc",
};

const opportunity_tools = [_][]const u8{
    "qemu-aarch64",
    "qemu-riscv64",
    "qemu-x86_64",
    "wine",
    "wine64",
    "wasmtime",
    "wasmer",
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = std.heap.smp_allocator;

    var stdout_buffer: [2048]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var stderr_buffer: [2048]u8 = undefined;
    var stderr_file = std.Io.File.stderr().writer(io, &stderr_buffer);
    const stderr = &stderr_file.interface;

    const path_env = init.environ_map.get("PATH") orelse "";
    var missing_required: usize = 0;
    var opportunities: usize = 0;

    inline for (required_tools) |name| {
        if (try findExecutable(io, allocator, path_env, name)) |path| {
            defer allocator.free(path);
            try stdout.print("runtimecheck required {s}: found {s}\n", .{ name, path });
        } else {
            try stderr.print("runtimecheck required {s}: missing\n", .{name});
            missing_required += 1;
        }
    }

    inline for (opportunity_tools) |name| {
        if (try findExecutable(io, allocator, path_env, name)) |path| {
            defer allocator.free(path);
            try stderr.print("runtimecheck opportunity {s}: found {s}\n", .{ name, path });
            opportunities += 1;
        } else {
            try stdout.print("runtimecheck opportunity {s}: missing\n", .{name});
        }
    }

    if (missing_required != 0) {
        try stderr.flush();
        return error.RequiredRuntimeMissing;
    }
    if (opportunities != 0) {
        try stderr.print("runtimecheck: additional runtime runner available; refresh S4-M11 blocker evidence before continuing\n", .{});
        try stderr.flush();
        return error.RuntimeOpportunityAvailable;
    }

    try stdout.print("runtimecheck ok: no additional runtime runner available\n", .{});
    try stdout.flush();
}

fn findExecutable(io: std.Io, allocator: std.mem.Allocator, path_env: []const u8, name: []const u8) !?[]u8 {
    var it = std.mem.splitScalar(u8, path_env, ':');
    while (it.next()) |raw_dir| {
        const dir = if (raw_dir.len == 0) "." else raw_dir;
        const candidate = try std.fs.path.join(allocator, &.{ dir, name });
        if (isExecutable(io, candidate)) return candidate;
        allocator.free(candidate);
    }
    return null;
}

fn isExecutable(io: std.Io, path: []const u8) bool {
    const options: std.Io.Dir.AccessOptions = .{ .execute = true };
    if (std.fs.path.isAbsolute(path)) {
        std.Io.Dir.accessAbsolute(io, path, options) catch return false;
    } else {
        std.Io.Dir.cwd().access(io, path, options) catch return false;
    }
    return true;
}
