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
    var found_required: usize = 0;
    var missing_required: usize = 0;
    var opportunities: usize = 0;
    var missing_opportunities: usize = 0;

    inline for (required_tools) |name| {
        if (try findExecutable(io, allocator, path_env, name)) |path| {
            defer allocator.free(path);
            try stdout.print("runtimecheck required {s}: found {s}\n", .{ name, path });
            found_required += 1;
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
            missing_opportunities += 1;
        }
    }

    try stdout.print(
        "runtimecheck summary: required found={d} missing={d}; opportunities found={d} missing={d}\n",
        .{ found_required, missing_required, opportunities, missing_opportunities },
    );

    evaluateRuntimeState(missing_required, opportunities) catch |err| switch (err) {
        error.RequiredRuntimeMissing => {
            try stderr.flush();
            return err;
        },
        error.RuntimeOpportunityAvailable => {
            try stderr.print("runtimecheck: additional runtime runner available; refresh S4-M11 blocker evidence before continuing\n", .{});
            try stderr.flush();
            return err;
        },
    };

    try stdout.print("runtimecheck ok: no additional runtime runner available\n", .{});
    try stdout.flush();
}

fn evaluateRuntimeState(missing_required: usize, opportunities: usize) error{ RequiredRuntimeMissing, RuntimeOpportunityAvailable }!void {
    if (missing_required != 0) return error.RequiredRuntimeMissing;
    if (opportunities != 0) return error.RuntimeOpportunityAvailable;
}

fn findExecutable(io: std.Io, allocator: std.mem.Allocator, path_env: []const u8, name: []const u8) !?[]u8 {
    var it = std.mem.splitScalar(u8, path_env, ':');
    while (it.next()) |raw_dir| {
        const dir = pathSegmentDir(raw_dir);
        const candidate = try std.fs.path.join(allocator, &.{ dir, name });
        if (isExecutable(io, candidate)) return candidate;
        allocator.free(candidate);
    }
    return null;
}

fn pathSegmentDir(raw_dir: []const u8) []const u8 {
    return if (raw_dir.len == 0) "." else raw_dir;
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

test "findExecutable locates executable in PATH order" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var file = try tmp.dir.createFile(std.testing.io, "runner", .{ .permissions = .executable_file });
    file.close(std.testing.io);

    const allocator = std.testing.allocator;
    const dir_path = try std.fs.path.join(allocator, &.{ ".zig-cache/tmp", &tmp.sub_path });
    defer allocator.free(dir_path);

    const path_env = try std.fmt.allocPrint(allocator, "/definitely-missing-alea-runtimecheck:{s}", .{dir_path});
    defer allocator.free(path_env);

    const found = (try findExecutable(std.testing.io, allocator, path_env, "runner")).?;
    defer allocator.free(found);
    const expected = try std.fs.path.join(allocator, &.{ dir_path, "runner" });
    defer allocator.free(expected);
    try std.testing.expectEqualStrings(expected, found);
}

test "findExecutable ignores non-executable and missing entries" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var file = try tmp.dir.createFile(std.testing.io, "plain", .{});
    file.close(std.testing.io);

    const allocator = std.testing.allocator;
    const dir_path = try std.fs.path.join(allocator, &.{ ".zig-cache/tmp", &tmp.sub_path });
    defer allocator.free(dir_path);

    try std.testing.expect(try findExecutable(std.testing.io, allocator, dir_path, "missing") == null);
    if (std.Io.File.Permissions.has_executable_bit) {
        try std.testing.expect(try findExecutable(std.testing.io, allocator, dir_path, "plain") == null);
    }
}

test "runtime state decision prioritizes missing required tools then opportunities" {
    try evaluateRuntimeState(0, 0);
    try std.testing.expectError(error.RequiredRuntimeMissing, evaluateRuntimeState(1, 0));
    try std.testing.expectError(error.RuntimeOpportunityAvailable, evaluateRuntimeState(0, 1));
    try std.testing.expectError(error.RequiredRuntimeMissing, evaluateRuntimeState(1, 1));
}

test "empty PATH segments resolve to current directory" {
    try std.testing.expectEqualStrings(".", pathSegmentDir(""));
    try std.testing.expectEqualStrings("/bin", pathSegmentDir("/bin"));
}
