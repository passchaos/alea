const std = @import("std");

const Evidence = struct {
    milestone: []const u8,
    path: []const u8,
};

const evidence = [_]Evidence{
    .{ .milestone = "S4-M11", .path = "compare/results/s4-m11-blocker-audit.md" },
    .{ .milestone = "S4-M12", .path = "compare/results/s4-m12-vector-profile-example.md" },
    .{ .milestone = "S4-M13", .path = "compare/results/s4-m13-lognormal-profile-example.md" },
    .{ .milestone = "S4-M14", .path = "compare/results/s4-m14-native-f32-profile-example.md" },
    .{ .milestone = "S4-M15", .path = "compare/results/s4-m15-examples-validation.md" },
    .{ .milestone = "S4-M16", .path = "compare/results/s4-m16-weighted-sampling-example.md" },
    .{ .milestone = "S4-M17", .path = "compare/results/s4-m17-multivariate-sampling-example.md" },
    .{ .milestone = "S4-M18", .path = "compare/results/s4-m18-sequence-sampling-example.md" },
    .{ .milestone = "S4-M19", .path = "compare/results/s4-m19-string-generation-example.md" },
    .{ .milestone = "S4-M20", .path = "compare/results/s4-m20-unit-geometry-example.md" },
    .{ .milestone = "S4-M21", .path = "compare/results/s4-m21-distribution-diagnostics-example.md" },
    .{ .milestone = "S4-M22", .path = "compare/results/s4-m22-reproducible-streams-example.md" },
    .{ .milestone = "S4-M23", .path = "compare/results/s4-m23-range-sampling-example.md" },
    .{ .milestone = "S4-M24", .path = "compare/results/s4-m24-discrete-distributions-example.md" },
    .{ .milestone = "S4-M25", .path = "compare/results/s4-m25-continuous-distributions-example.md" },
    .{ .milestone = "S4-M26", .path = "compare/results/s4-m26-advanced-continuous-distributions-example.md" },
    .{ .milestone = "S4-M27", .path = "compare/results/s4-m27-rank-distributions-example.md" },
    .{ .milestone = "S4-M28", .path = "compare/results/s4-m28-examples-catalog.md" },
    .{ .milestone = "S4-M29", .path = "compare/results/s4-m29-examplecheck.md" },
    .{ .milestone = "S4-M30", .path = "compare/results/s4-m30-toolingcheck.md" },
    .{ .milestone = "S4-M31", .path = "compare/results/s4-m31-readme-doccheck.md" },
    .{ .milestone = "S4-M32", .path = "compare/results/s4-m32-roadmapcheck.md" },
    .{ .milestone = "S4-M33", .path = "compare/results/s4-m33-choose-array.md" },
    .{ .milestone = "S4-M34", .path = "compare/results/s4-m34-choose-weighted.md" },
    .{ .milestone = "S4-M35", .path = "compare/results/s4-m35-reservoir-into.md" },
    .{ .milestone = "S4-M36", .path = "compare/results/s4-m36-iterator-into.md" },
    .{ .milestone = "S4-M37", .path = "compare/results/s4-m37-weighted-array.md" },
    .{ .milestone = "S4-M38", .path = "compare/results/s4-m38-weighted-index-array.md" },
    .{ .milestone = "S4-M39", .path = "compare/results/s4-m39-weighted-iterator-array.md" },
    .{ .milestone = "S4-M40", .path = "compare/results/s4-m40-iterator-array.md" },
    .{ .milestone = "S4-M41", .path = "compare/results/s4-m41-weighted-indices-into.md" },
    .{ .milestone = "S4-M42", .path = "compare/results/s4-m42-weighted-into.md" },
    .{ .milestone = "S4-M43", .path = "compare/results/s4-m43-weighted-iterator-into.md" },
    .{ .milestone = "S4-M44", .path = "compare/results/s4-m44-indices-into.md" },
    .{ .milestone = "S4-M45", .path = "compare/results/s4-m45-choose-multiple-into.md" },
    .{ .milestone = "S4-M46", .path = "compare/results/s4-m46-partial-shuffle-split.md" },
    .{ .milestone = "S4-M47", .path = "compare/results/s4-m47-u32-indices-into.md" },
    .{ .milestone = "S4-M48", .path = "compare/results/s4-m48-caller-owned-example.md" },
};

const required_tokens = [_][]const u8{
    "Active Goal Completion Audit",
    "S4-M11",
    "blocked",
    "do not call `update_goal(status=complete)`",
    "S4-M49",
    "No proxy signal is accepted as whole-goal completion",
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
    const roadmap = try readFile(io, allocator, "compare/results/core-rand-coverage.md");
    defer allocator.free(roadmap);
    const audit = try readFile(io, allocator, "compare/results/active-goal-completion-audit.md");
    defer allocator.free(audit);
    const linux_audit = try readFile(io, allocator, "compare/results/linux-no-known-gaps-audit.md");
    defer allocator.free(linux_audit);
    const tooling = try readFile(io, allocator, "docs/tooling.md");
    defer allocator.free(tooling);
    const readme = try readFile(io, allocator, "README.md");
    defer allocator.free(readme);
    const build = try readFile(io, allocator, "build.zig");
    defer allocator.free(build);

    var missing: usize = 0;

    inline for (evidence) |item| {
        std.Io.Dir.cwd().access(io, item.path, .{}) catch |err| {
            try stderr.print("roadmapcheck: missing evidence file {s}: {s}\n", .{ item.path, @errorName(err) });
            missing += 1;
            return;
        };
        if (std.mem.indexOf(u8, roadmap, item.milestone) == null or
            std.mem.indexOf(u8, roadmap, item.path) == null)
        {
            try stderr.print("roadmapcheck: core-rand-coverage.md missing `{s}` / `{s}`\n", .{ item.milestone, item.path });
            missing += 1;
        }
        if (std.mem.indexOf(u8, audit, item.milestone) == null) {
            try stderr.print("roadmapcheck: active-goal-completion-audit.md missing `{s}`\n", .{item.milestone});
            missing += 1;
        }
        if (!std.mem.eql(u8, item.milestone, "S4-M11") and
            std.mem.indexOf(u8, linux_audit, item.path) == null)
        {
            try stderr.print("roadmapcheck: linux-no-known-gaps-audit.md missing `{s}`\n", .{item.path});
            missing += 1;
        }
    }

    inline for (required_tokens) |token| {
        if (std.mem.indexOf(u8, audit, token) == null and std.mem.indexOf(u8, roadmap, token) == null) {
            try stderr.print("roadmapcheck: roadmap/audit missing required token `{s}`\n", .{token});
            missing += 1;
        }
    }

    if (std.mem.indexOf(u8, roadmap, "| S4-M49 | Next unblocked product gap") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M49 next-gap row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M49 next unblocked product gap") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M49 next-gap row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M11 remains unresolved") == null) {
        try stderr.print("roadmapcheck: active audit must keep S4-M11 unresolved statement\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, build, "doccheck_step.dependOn(&run_roadmapcheck.step)") == null) {
        try stderr.print("roadmapcheck: doccheck must depend on roadmapcheck\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, tooling, "zig build roadmapcheck") == null or
        std.mem.indexOf(u8, readme, "zig build roadmapcheck") == null)
    {
        try stderr.print("roadmapcheck: README.md and docs/tooling.md must mention `zig build roadmapcheck`\n", .{});
        missing += 1;
    }

    if (missing != 0) {
        try stderr.flush();
        return error.RoadmapAuditIncomplete;
    }

    try stdout.print("roadmapcheck ok\n", .{});
    try stdout.flush();
}

fn readFile(io: std.Io, allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    return std.Io.Dir.cwd().readFileAlloc(io, path, allocator, .limited(8 * 1024 * 1024));
}
