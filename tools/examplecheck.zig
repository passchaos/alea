const std = @import("std");

const Example = struct {
    path: []const u8,
    step: []const u8,
    source_tokens: []const []const u8 = &.{},
};

const examples = [_]Example{
    .{
        .path = "examples/basic.zig",
        .step = "zig build run-basic",
        .source_tokens = &.{ "bytesAlloc", "valueBatch u16", "chanceBatch p=.25", "ratioBatch 3/8", "vectorChanceBatch boolx8", "vectorRatioBatch boolx8", "standardNormalBatch", "standardExponentialBatch", "normalBatch", "exponentialBatch", "vectorStandardNormalBatch f64x4", "vectorStandardExponentialBatch f64x4", "vectorNormalBatch f64x4", "vectorExponentialBatch f64x4", "sampleBatch dice", "index choice", "u32 index choice", "const pointer choice" },
    },
    .{ .path = "examples/reproducible_streams.zig", .step = "zig build run-reproducible-streams" },
    .{ .path = "examples/range_sampling.zig", .step = "zig build run-range-sampling", .source_tokens = &.{ "rangeBatch u16", "rangeBatchChecked f64", "durationRangeAtMostBatch", "vectorRangeBatch f32x4", "vectorOpenBatch f32x4", "vectorOpenClosedBatch f32x4", "openBatch f32", "openClosedBatch f32" } },
    .{ .path = "examples/discrete_distributions.zig", .step = "zig build run-discrete-distributions" },
    .{ .path = "examples/continuous_distributions.zig", .step = "zig build run-continuous-distributions" },
    .{ .path = "examples/advanced_continuous_distributions.zig", .step = "zig build run-advanced-continuous-distributions" },
    .{ .path = "examples/rank_distributions.zig", .step = "zig build run-rank-distributions" },
    .{ .path = "examples/distribution_diagnostics.zig", .step = "zig build run-distribution-diagnostics" },
    .{ .path = "examples/vector_profiles.zig", .step = "zig build run-vector-profiles" },
    .{ .path = "examples/native_f32_profiles.zig", .step = "zig build run-native-f32-profiles" },
    .{ .path = "examples/lognormal_profiles.zig", .step = "zig build run-lognormal-profiles" },
    .{
        .path = "examples/weighted_sampling.zig",
        .step = "zig build run-weighted-sampling",
        .source_tokens = &.{ "one-shot weighted u32 index", "generic weighted index", "generic weighted u32 index", "weighted choice sample u32 index", "weighted choice u32 indices", "WeightedChoice.indicesU32From", "WeightedChoice.valuesFrom", "WeightedChoice.ptrsFrom", "weighted ptrs into", "weighted no-replacement ptrs", "weighted u32 no-replacement indices", "weighted IndexVec", "weighted u32 index array", "weighted u32 indices into" },
    },
    .{
        .path = "examples/sequence_sampling.zig",
        .step = "zig build run-sequence-sampling",
        .source_tokens = &.{ "IndexVec.valuesInto", "IndexVec.valuesOwned", "IndexVec.ptrsOwned", "IndexVec.mutPtrsOwned", "IndexVec.toOwnedU32Slice", "Choice.sampleIndexFrom", "Choice.valuesFrom", "Choice.ptrsFrom", "Choice.indicesU32From", "Choice.fillIndicesU32From", "sampleArrayU32", "chooseMultiplePtrs", "reservoirSamplePtrsInto" },
    },
    .{
        .path = "examples/caller_owned_sampling.zig",
        .step = "zig build run-caller-owned-sampling",
        .source_tokens = &.{ "chooseMultiplePtrsInto", "reservoirSamplePtrsInto", "weighted ptrs into" },
    },
    .{ .path = "examples/multivariate_sampling.zig", .step = "zig build run-multivariate-sampling" },
    .{
        .path = "examples/string_generation.zig",
        .step = "zig build run-string-generation",
        .source_tokens = &.{ "unicode scalar fill", "unicode scalar batch", "unicode scalar range fill", "unicode scalar range batch", "unicodeScalarBatch", "fillUnicodeScalar", "unicodeScalarRangeAtMostBatchChecked", "fillUnicodeScalarRangeLessThanChecked" },
    },
    .{ .path = "examples/unit_geometry.zig", .step = "zig build run-unit-geometry" },
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
    const docs = try std.Io.Dir.cwd().readFileAlloc(io, "docs/examples.md", allocator, .limited(1024 * 1024));
    defer allocator.free(docs);

    var missing: usize = 0;
    inline for (examples) |example| {
        std.Io.Dir.cwd().access(io, example.path, .{}) catch |err| {
            try stderr.print("examplecheck: missing source {s}: {s}\n", .{ example.path, @errorName(err) });
            missing += 1;
            return;
        };
        const source = try std.Io.Dir.cwd().readFileAlloc(io, example.path, allocator, .limited(1024 * 1024));
        defer allocator.free(source);
        for (example.source_tokens) |token| {
            if (std.mem.indexOf(u8, source, token) == null) {
                try stderr.print("examplecheck: source {s} missing expected token `{s}`\n", .{ example.path, token });
                missing += 1;
            }
        }
        if (std.mem.indexOf(u8, docs, example.path) == null) {
            try stderr.print("examplecheck: docs/examples.md missing source `{s}`\n", .{example.path});
            missing += 1;
        }
        if (std.mem.indexOf(u8, docs, example.step) == null) {
            try stderr.print("examplecheck: docs/examples.md missing step `{s}`\n", .{example.step});
            missing += 1;
        }
    }

    var dir = try std.Io.Dir.cwd().openDir(io, "examples", .{ .iterate = true });
    defer dir.close(io);
    var it = dir.iterate();
    while (try it.next(io)) |entry| {
        if (entry.kind != .file or !std.mem.endsWith(u8, entry.name, ".zig")) continue;
        const path = try std.fmt.allocPrint(allocator, "examples/{s}", .{entry.name});
        defer allocator.free(path);
        if (!knownExample(path)) {
            try stderr.print("examplecheck: source {s} is not listed in tools/examplecheck.zig\n", .{path});
            missing += 1;
        }
    }

    if (std.mem.indexOf(u8, docs, "zig build examples") == null) {
        try stderr.print("examplecheck: docs/examples.md missing aggregate `zig build examples`\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, docs, "zig build validate") == null) {
        try stderr.print("examplecheck: docs/examples.md missing validate relationship\n", .{});
        missing += 1;
    }

    if (missing != 0) {
        try stderr.flush();
        return error.ExampleCatalogIncomplete;
    }

    try stdout.print("examplecheck ok\n", .{});
    try stdout.flush();
}

fn knownExample(path: []const u8) bool {
    inline for (examples) |example| {
        if (std.mem.eql(u8, path, example.path)) return true;
    }
    return false;
}
