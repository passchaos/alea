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
    .{ .token = "zig build runtimecheck", .reason = "runtime runner availability checker command" },
    .{ .token = "zig build doccheck", .reason = "aggregate documentation checker command" },
    .{ .token = "zig build validate", .reason = "native validation command" },
    .{ .token = "zig build validate-local", .reason = "native plus local rand validation command" },
    .{ .token = "comparison work: it runs native validation plus `surfacecheck`", .reason = "validate-local component explanation" },
    .{ .token = "zig build validate-all", .reason = "broad validation command" },
    .{ .token = "portability-sensitive releases or evidence", .reason = "validate-all usage guidance" },
    .{ .token = "cross-target compile checks, WASI unit", .reason = "validate-all component explanation" },
    .{ .token = "tools/practrand.sh --dry-run", .reason = "PractRand dry-run command" },
    .{ .token = "zig build practrand-dry-run", .reason = "PractRand dry-run build step" },
    .{ .token = "PRACTRAND_BIN", .reason = "custom PractRand binary guidance" },
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

fn hasRequiredToken(readme: []const u8, required: RequiredToken) bool {
    return std.mem.indexOf(u8, readme, required.token) != null;
}

fn hasProjectPositioning(readme: []const u8) bool {
    return std.mem.indexOf(u8, readme, "`alea` is a Zig 0.16 random toolkit") != null;
}

fn hasLocalRandNote(readme: []const u8) bool {
    return std.mem.indexOf(u8, readme, "local `rand` checkout") != null and
        std.mem.indexOf(u8, readme, "~/Work/rand") != null;
}

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
        if (!hasRequiredToken(readme, required)) {
            try stderr.print("readmecheck: README.md missing `{s}` ({s})\n", .{ required.token, required.reason });
            missing += 1;
        }
    }

    if (!hasProjectPositioning(readme)) {
        try stderr.print("readmecheck: README.md missing Zig 0.16 project positioning\n", .{});
        missing += 1;
    }
    if (!hasLocalRandNote(readme)) {
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

test "required-token helper matches exact configured token" {
    const required = RequiredToken{
        .token = "zig build validate-local",
        .reason = "native plus local rand validation command",
    };

    try std.testing.expect(hasRequiredToken("run zig build validate-local before comparing", required));
    try std.testing.expect(!hasRequiredToken("run zig build validate before comparing", required));
}

test "required-token helper covers PractRand dry-run guidance" {
    const dry_run = RequiredToken{
        .token = "tools/practrand.sh --dry-run",
        .reason = "PractRand dry-run command",
    };
    const build_step = RequiredToken{
        .token = "zig build practrand-dry-run",
        .reason = "PractRand dry-run build step",
    };
    const binary = RequiredToken{
        .token = "PRACTRAND_BIN",
        .reason = "custom PractRand binary guidance",
    };

    const text =
        \\sh tools/practrand.sh --dry-run fast 1048576
        \\zig build practrand-dry-run
        \\set PRACTRAND_BIN when the executable is not named RNG_test
    ;
    try std.testing.expect(hasRequiredToken(text, dry_run));
    try std.testing.expect(hasRequiredToken(text, build_step));
    try std.testing.expect(hasRequiredToken(text, binary));
}

test "project positioning and local rand note helpers require full phrases" {
    try std.testing.expect(hasProjectPositioning("`alea` is a Zig 0.16 random toolkit for testing"));
    try std.testing.expect(!hasProjectPositioning("alea is a random toolkit"));

    try std.testing.expect(hasLocalRandNote("Use the local `rand` checkout at ~/Work/rand."));
    try std.testing.expect(!hasLocalRandNote("Use the local `rand` checkout."));
    try std.testing.expect(!hasLocalRandNote("Use ~/Work/rand."));
}
