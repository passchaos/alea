const std = @import("std");

const RequiredToken = struct {
    token: []const u8,
    reason: []const u8,
};

const required_tokens = [_]RequiredToken{
    .{ .token = "docs/core-guide.md", .reason = "core API guide discovery" },
    .{ .token = "docs/api-reference.md", .reason = "public API reference discovery" },
    .{ .token = "docs/examples.md", .reason = "runnable examples catalog discovery" },
    .{ .token = "docs/tooling.md", .reason = "build/tooling catalog discovery" },
    .{ .token = "compare/results/core-rand-coverage.md", .reason = "living roadmap discovery" },
    .{ .token = "compare/results/performance-triage.md", .reason = "performance evidence discovery" },
    .{ .token = "zig build test", .reason = "unit/documentation validation command" },
    .{ .token = "zig build apicheck", .reason = "API reference checker command" },
    .{ .token = "zig build examplecheck", .reason = "examples catalog checker command" },
    .{ .token = "zig build toolingcheck", .reason = "tooling catalog checker command" },
    .{ .token = "zig build readmecheck", .reason = "README discovery checker command" },
    .{ .token = "zig build roadmapcheck", .reason = "roadmap/audit checker command" },
    .{ .token = "zig build surfacecheck", .reason = "local rand public-surface checker command" },
    .{ .token = "zig build doccheck", .reason = "aggregate documentation checker command" },
    .{ .token = "zig build validate", .reason = "native validation command" },
    .{ .token = "zig build validate-local", .reason = "native plus local rand validation command" },
    .{ .token = "zig build validate-all", .reason = "broad validation command" },
    .{ .token = "zig build run-basic", .reason = "runnable example entry point" },
    .{ .token = "zig build examples", .reason = "aggregate examples command" },
    .{ .token = "zig build -l", .reason = "generated build-step list discovery" },
    .{ .token = "rng.chooseIndex", .reason = "quick-start one-shot index choice" },
    .{ .token = "rng.chooseConstPtr", .reason = "quick-start const-pointer choice" },
};

const required_files = [_][]const u8{
    "README.md",
    "docs/core-guide.md",
    "docs/api-reference.md",
    "docs/examples.md",
    "docs/tooling.md",
    "compare/results/core-rand-coverage.md",
    "compare/results/performance-triage.md",
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var stderr_buffer: [2048]u8 = undefined;
    var stderr_file = std.Io.File.stderr().writer(io, &stderr_buffer);
    const stderr = &stderr_file.interface;

    const allocator = std.heap.smp_allocator;
    const readme = try std.Io.Dir.cwd().readFileAlloc(io, "README.md", allocator, .limited(1024 * 1024));
    defer allocator.free(readme);

    var missing: usize = 0;

    inline for (required_files) |path| {
        std.Io.Dir.cwd().access(io, path, .{}) catch |err| {
            try stderr.print("readmecheck: missing referenced file {s}: {s}\n", .{ path, @errorName(err) });
            missing += 1;
        };
    }

    inline for (required_tokens) |required| {
        if (std.mem.indexOf(u8, readme, required.token) == null) {
            try stderr.print("readmecheck: README.md missing `{s}` ({s})\n", .{ required.token, required.reason });
            missing += 1;
        }
    }

    if (std.mem.indexOf(u8, readme, "`alea` is a Zig 0.16 random toolkit") == null) {
        try stderr.print("readmecheck: README.md missing Zig 0.16 project positioning\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, readme, "local `rand` checkout") == null or
        std.mem.indexOf(u8, readme, "~/Work/rand") == null)
    {
        try stderr.print("readmecheck: README.md missing local rand comparison note\n", .{});
        missing += 1;
    }

    if (missing != 0) {
        try stderr.flush();
        return error.ReadmeIncomplete;
    }

    try stdout.print("readmecheck ok\n", .{});
    try stdout.flush();
}
