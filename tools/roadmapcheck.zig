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
    .{ .milestone = "S4-M49", .path = "compare/results/s4-m49-indexvec-item-iterators.md" },
    .{ .milestone = "S4-M50", .path = "compare/results/s4-m50-indexvec-into.md" },
    .{ .milestone = "S4-M51", .path = "compare/results/s4-m51-indexvec-mutptrs.md" },
    .{ .milestone = "S4-M52", .path = "compare/results/s4-m52-choose-multiple-ptrs-into.md" },
    .{ .milestone = "S4-M53", .path = "compare/results/s4-m53-choose-ptr-array.md" },
    .{ .milestone = "S4-M54", .path = "compare/results/s4-m54-weighted-ptr-array.md" },
    .{ .milestone = "S4-M55", .path = "compare/results/s4-m55-weighted-ptrs-into.md" },
    .{ .milestone = "S4-M56", .path = "compare/results/s4-m56-choose-const-ptr.md" },
    .{ .milestone = "S4-M57", .path = "compare/results/s4-m57-choose-weighted-const-ptr.md" },
    .{ .milestone = "S4-M58", .path = "compare/results/s4-m58-choose-multiple-ptrs.md" },
    .{ .milestone = "S4-M59", .path = "compare/results/s4-m59-weighted-ptrs.md" },
    .{ .milestone = "S4-M60", .path = "compare/results/s4-m60-reservoir-ptrs.md" },
    .{ .milestone = "S4-M61", .path = "compare/results/s4-m61-reservoir-ptrs-into.md" },
    .{ .milestone = "S4-M62", .path = "compare/results/s4-m62-caller-owned-pointer-example.md" },
    .{ .milestone = "S4-M63", .path = "compare/results/s4-m63-choose-index.md" },
    .{ .milestone = "S4-M64", .path = "compare/results/s4-m64-generic-weighted-index.md" },
    .{ .milestone = "S4-M65", .path = "compare/results/s4-m65-example-output-check.md" },
    .{ .milestone = "S4-M66", .path = "compare/results/s4-m66-s4-m11-blockercheck.md" },
    .{ .milestone = "S4-M67", .path = "compare/results/s4-m67-readme-choice-discovery.md" },
    .{ .milestone = "S4-M68", .path = "compare/results/s4-m68-doccheck-dependency-check.md" },
    .{ .milestone = "S4-M69", .path = "compare/results/s4-m69-weighted-indexvec.md" },
    .{ .milestone = "S4-M70", .path = "compare/results/s4-m70-weighted-u32-indices-into.md" },
    .{ .milestone = "S4-M71", .path = "compare/results/s4-m71-weighted-u32-index-array.md" },
    .{ .milestone = "S4-M72", .path = "compare/results/s4-m72-weighted-u32-indices.md" },
    .{ .milestone = "S4-M73", .path = "compare/results/s4-m73-u32-index-array.md" },
    .{ .milestone = "S4-M74", .path = "compare/results/s4-m74-indexvec-u32-export.md" },
    .{ .milestone = "S4-M75", .path = "compare/results/s4-m75-indexvec-owned-mapping.md" },
    .{ .milestone = "S4-M76", .path = "compare/results/s4-m76-choose-index-u32.md" },
    .{ .milestone = "S4-M77", .path = "compare/results/s4-m77-generic-weighted-index-u32.md" },
    .{ .milestone = "S4-M78", .path = "compare/results/s4-m78-rng-weighted-index-u32.md" },
    .{ .milestone = "S4-M79", .path = "compare/results/s4-m79-weighted-choice-index-fills.md" },
    .{ .milestone = "S4-M80", .path = "compare/results/s4-m80-choice-index-fills.md" },
    .{ .milestone = "S4-M81", .path = "compare/results/s4-m81-choice-sample-index.md" },
    .{ .milestone = "S4-M82", .path = "compare/results/s4-m82-choice-owned-indices.md" },
    .{ .milestone = "S4-M83", .path = "compare/results/s4-m83-weighted-choice-owned-indices.md" },
    .{ .milestone = "S4-M84", .path = "compare/results/s4-m84-choice-owned-values-ptrs.md" },
    .{ .milestone = "S4-M85", .path = "compare/results/s4-m85-rng-owned-batches.md" },
    .{ .milestone = "S4-M86", .path = "compare/results/s4-m86-rng-owned-bytes.md" },
    .{ .milestone = "S4-M87", .path = "compare/results/s4-m87-rng-owned-ranges.md" },
    .{ .milestone = "S4-M88", .path = "compare/results/s4-m88-rng-owned-strict-intervals.md" },
    .{ .milestone = "S4-M89", .path = "compare/results/s4-m89-rng-owned-probabilities.md" },
    .{ .milestone = "S4-M90", .path = "compare/results/s4-m90-rng-owned-normal-exponential.md" },
    .{ .milestone = "S4-M91", .path = "compare/results/s4-m91-rng-owned-durations.md" },
    .{ .milestone = "S4-M92", .path = "compare/results/s4-m92-rng-owned-vector-ranges.md" },
    .{ .milestone = "S4-M93", .path = "compare/results/s4-m93-rng-owned-vector-strict-intervals.md" },
    .{ .milestone = "S4-M94", .path = "compare/results/s4-m94-rng-owned-vector-probabilities.md" },
    .{ .milestone = "S4-M95", .path = "compare/results/s4-m95-rng-owned-vector-normal-exponential.md" },
    .{ .milestone = "S4-M96", .path = "compare/results/s4-m96-rng-owned-standard-normal-exponential.md" },
    .{ .milestone = "S4-M97", .path = "compare/results/s4-m97-rng-owned-unicode-scalars.md" },
    .{ .milestone = "S4-M98", .path = "compare/results/s4-m98-unicode-scalar-ranges.md" },
    .{ .milestone = "S4-M99", .path = "compare/results/s4-m99-rng-owned-bounded-uint.md" },
    .{ .milestone = "S4-M100", .path = "compare/results/s4-m100-rng-owned-inclusive-ranges.md" },
    .{ .milestone = "S4-M101", .path = "compare/results/s4-m101-rng-owned-vector-inclusive-ranges.md" },
    .{ .milestone = "S4-M102", .path = "compare/results/s4-m102-rng-owned-index-choice-batches.md" },
    .{ .milestone = "S4-M103", .path = "compare/results/s4-m103-rng-owned-value-choice-batches.md" },
    .{ .milestone = "S4-M104", .path = "compare/results/s4-m104-rng-owned-const-ptr-choice-batches.md" },
    .{ .milestone = "S4-M105", .path = "compare/results/s4-m105-rng-owned-mut-ptr-choice-batches.md" },
    .{ .milestone = "S4-M106", .path = "compare/results/s4-m106-rng-owned-weighted-index-batches.md" },
    .{ .milestone = "S4-M107", .path = "compare/results/s4-m107-rng-owned-weighted-u32-index-batches.md" },
    .{ .milestone = "S4-M108", .path = "compare/results/s4-m108-rng-owned-weighted-value-batches.md" },
    .{ .milestone = "S4-M109", .path = "compare/results/s4-m109-rng-owned-weighted-const-ptr-batches.md" },
    .{ .milestone = "S4-M110", .path = "compare/results/s4-m110-rng-owned-weighted-mut-ptr-batches.md" },
    .{ .milestone = "S4-M111", .path = "compare/results/s4-m111-generic-weighted-index-batches.md" },
    .{ .milestone = "S4-M112", .path = "compare/results/s4-m112-generic-weighted-value-batches.md" },
    .{ .milestone = "S4-M113", .path = "compare/results/s4-m113-generic-weighted-const-ptr-batches.md" },
    .{ .milestone = "S4-M114", .path = "compare/results/s4-m114-generic-weighted-mut-ptr-batches.md" },
    .{ .milestone = "S4-M115", .path = "compare/results/s4-m115-accessor-weighted-choices.md" },
    .{ .milestone = "S4-M116", .path = "compare/results/s4-m116-accessor-weighted-samples.md" },
    .{ .milestone = "S4-M117", .path = "compare/results/s4-m117-accessor-weighted-into.md" },
    .{ .milestone = "S4-M118", .path = "compare/results/s4-m118-accessor-weighted-index-samples.md" },
    .{ .milestone = "S4-M119", .path = "compare/results/s4-m119-accessor-weighted-index-arrays.md" },
};

const required_tokens = [_][]const u8{
    "Active Goal Completion Audit",
    "S4-M11",
    "blocked",
    "do not call `update_goal(status=complete)`",
    "S4-M120",
    "No proxy signal is accepted as whole-goal completion",
};

const blocker_tokens = [_][]const u8{
    "exact/default-compatible dense SIMD",
    "qemu-aarch64",
    "qemu-riscv64",
    "wine",
    "wasmtime",
    "wasmer",
    "no SIMD non-uniform implementation",
    "Do not call `update_goal(status=complete)`",
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
    const blocker = try readFile(io, allocator, "compare/results/s4-m11-blocker-audit.md");
    defer allocator.free(blocker);

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

    inline for (blocker_tokens) |token| {
        if (std.mem.indexOf(u8, blocker, token) == null) {
            try stderr.print("roadmapcheck: s4-m11-blocker-audit.md missing blocker token `{s}`\n", .{token});
            missing += 1;
        }
    }

    if (std.mem.indexOf(u8, roadmap, "| S4-M120 | Next unblocked product gap") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M120 next-gap row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M120 next unblocked product gap") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M120 next-gap row\n", .{});
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
