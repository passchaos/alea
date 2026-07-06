const std = @import("std");

const Example = struct {
    path: []const u8,
    step: []const u8,
    aggregate_token: []const u8,
    source_tokens: []const []const u8 = &.{},
};

const examples = [_]Example{
    .{
        .path = "examples/basic.zig",
        .step = "zig build run-basic",
        .aggregate_token = "examples_step.dependOn(&run_example.step)",
        .source_tokens = &.{ "bytesAlloc", "nextU64 raw", "nextU32 raw", "fillBytes raw", "rngReader bytes", "StepRng bytes", "constRng next", "randomValue u16", "root sampler helpers", "sampleDie=", "sampleFill=", "root choice helpers", "choiceIndex=", "choiceIndexU32=", "indexFill=", "indexFillU32=", "indexArray=", "indexArrayU32=", "valueArray=", "choiceBatch=", "root shuffle helpers", "shuffle=", "partial=", "tailPartial=", "root weighted helpers", "weightedIndex=", "root random helpers", "rangeFill", "inclusiveFill", "boolFill", "ratioFill", "valueBatch=", "rangeBatch=", "boolBatch=", "ratioBatch=", "root endpoint float helpers", "openFill=", "openBatch=", "openClosedFill=", "openClosedBatch=", "root duration helpers", "lessThan=", "atMost=", "lessThanBatch=", "atMostBatch=", "root string helpers", "sampleString=", "appendString=", "unicodeScalar=", "unicodeScalarFill=", "unicodeScalarBatch=", "unicodeInto=", "unicodeAlloc=", "valueBatch u16", "uintLessThanBatch u16", "uintAtMostBatch u16", "randomBool p=.25", "randomRatio 3/8", "chanceBatch p=.25", "ratioBatch 3/8", "vectorChanceBatch boolx8", "vectorRatioBatch boolx8", "standardNormalBatch", "standardExponentialBatch", "normalBatch", "exponentialBatch", "vectorStandardNormalBatch f64x4", "vectorStandardExponentialBatch f64x4", "vectorNormalBatch f64x4", "vectorExponentialBatch f64x4", "sample die", "sampleBatch dice", "sampleIter sizeHint", "index choice", "u32 index choice", "index choice array", "u32 index choice array", "index choice batch", "u32 index choice batch", "value choice array", "value choice batch", "const pointer choice", "const pointer choice array", "const pointer choice batch", "mutable pointer choice array", "mutable pointer choice batch" },
    },
    .{ .path = "examples/reproducible_streams.zig", .step = "zig build run-reproducible-streams", .aggregate_token = "examples_step.dependOn(&run_reproducible_streams_example.step)", .source_tokens = &.{ "ChaCha8Rng optional-chacha", "ChaCha12Rng alias", "ChaCha20Rng optional-chacha", "StdRng/ChaCha12 alias", "SmallRng/Xoshiro256++ alias", "Xoshiro128PlusPlus portable-32", "engine raw aliases", "nextU64", "nextU32", "fillBytes", "engine seedFromU64 alias", "engine fromSeed alias", "engine fromSeedBytes alias", "engine fromRng alias", "fork child next" } },
    .{ .path = "examples/range_sampling.zig", .step = "zig build run-range-sampling", .aggregate_token = "examples_step.dependOn(&run_range_sampling_example.step)", .source_tokens = &.{ "randomRange die", "randomRangeAtMost die", "sampleSingle die", "sampleSingleInclusive die", "UniformError alias", "StandardUniform pair", "rangeBatch u16", "rangeAtMostBatchChecked i16", "rangeBatchChecked f64", "durationRangeAtMostBatch", "UniformDuration.newInclusive", "vectorRangeBatch f32x4", "vectorRangeAtMostBatch i32x4", "vectorOpenBatch f32x4", "vectorOpenClosedBatch f32x4", "openBatch f32", "openClosedBatch f32", "Uniform(f64).new", "Uniform(u8).newInclusive", "mapped Uniform even die", "distribution sampleIter die", "VectorUniform(f32x4).new", "VectorUniform(i32x4).newInclusive" } },
    .{ .path = "examples/discrete_distributions.zig", .step = "zig build run-discrete-distributions", .aggregate_token = "examples_step.dependOn(&run_discrete_distributions_example.step)", .source_tokens = &.{ "p()=", "Bernoulli.new(p=.25)", "Bernoulli.fromRatio(1,4)", "BernoulliError alias" } },
    .{ .path = "examples/continuous_distributions.zig", .step = "zig build run-continuous-distributions", .aggregate_token = "examples_step.dependOn(&run_continuous_distributions_example.step)" },
    .{ .path = "examples/advanced_continuous_distributions.zig", .step = "zig build run-advanced-continuous-distributions", .aggregate_token = "examples_step.dependOn(&run_advanced_continuous_distributions_example.step)" },
    .{ .path = "examples/rank_distributions.zig", .step = "zig build run-rank-distributions", .aggregate_token = "examples_step.dependOn(&run_rank_distributions_example.step)" },
    .{ .path = "examples/distribution_diagnostics.zig", .step = "zig build run-distribution-diagnostics", .aggregate_token = "examples_step.dependOn(&run_distribution_diagnostics_example.step)" },
    .{ .path = "examples/vector_profiles.zig", .step = "zig build run-vector-profiles", .aggregate_token = "examples_step.dependOn(&run_vector_profiles_example.step)" },
    .{ .path = "examples/native_f32_profiles.zig", .step = "zig build run-native-f32-profiles", .aggregate_token = "examples_step.dependOn(&run_native_f32_profiles_example.step)" },
    .{ .path = "examples/lognormal_profiles.zig", .step = "zig build run-lognormal-profiles", .aggregate_token = "examples_step.dependOn(&run_lognormal_profiles_example.step)" },
    .{
        .path = "examples/weighted_sampling.zig",
        .step = "zig build run-weighted-sampling",
        .aggregate_token = "examples_step.dependOn(&run_weighted_sampling_example.step)",
        .source_tokens = &.{ "one-shot weighted u32 index", "weighted index batch", "Rng weighted index array", "weighted u32 index batch", "Rng weighted u32 index array", "weighted value batch", "Rng weighted value array", "generic weighted value batch", "generic weighted value array", "weighted const ptr batch", "Rng weighted const ptr array", "generic weighted const ptr batch", "generic weighted const ptr array", "weighted mut ptr batch", "Rng weighted mut ptr array", "generic weighted mut ptr batch", "generic weighted mut ptr array", "weighted index-weight one-shot index", "weighted index-weight one-shot u32 index", "weighted index-weight index fill", "weighted index-weight u32 index fill", "weighted index-weight index batch", "weighted index-weight u32 index batch", "weighted index-weight repeated index array", "weighted index-weight repeated u32 index array", "weighted index-weight value", "weighted index-weight const ptr", "weighted index-weight mut ptr value", "weighted index-weight value fill", "weighted index-weight const ptr fill", "weighted index-weight iter fill", "weighted index-weight mut ptr fill items", "weighted index-weight value batch", "weighted index-weight repeated value array", "weighted index-weight const ptr batch", "weighted index-weight repeated const ptr array", "weighted index-weight mut ptr batch items", "weighted index-weight repeated mut ptr array items", "weightedIndexBatchByIndex/weightedIndexU32BatchByIndex", "weightedIndexArrayByIndex/weightedIndexU32ArrayByIndex", "chooseWeightedByIndex/ConstPtrByIndex/PtrByIndex", "fillChooseWeightedByIndex/ConstPtrByIndex/PtrByIndex", "chooseWeightedBatchByIndex/ConstPtrBatchByIndex/PtrBatchByIndex", "chooseWeightedValueArrayByIndex/ConstPtrArrayByIndex/PtrArrayByIndex", "weighted by value", "weighted by const ptr", "weighted by mut ptr", "weighted by one-shot index", "weighted by one-shot u32 index", "weighted by index fill", "weighted by u32 index fill", "weighted by index batch", "weighted by u32 index batch", "weighted by value fill", "weighted by const ptr fill", "weighted by iter fill", "weighted by mut ptr fill", "weighted by value batch", "weighted by repeated value array", "weighted by const ptr batch", "weighted by repeated const ptr array", "weighted by mut ptr batch", "weighted by repeated mut ptr array", "weighted by repeated index array", "weighted by repeated u32 index array", "weighted by no-replacement sample", "weighted by no-replacement ptrs", "weighted by no-replacement mut ptr", "weighted by no-replacement indices", "weighted by u32 no-replacement indices", "weighted by IndexVec", "weighted index-weight indices", "weighted index-weight u32 indices", "weighted index-weight IndexVec", "weighted index-weight indices into", "weighted index-weight u32 indices into", "weighted index-weight index array", "weighted index-weight u32 index array", "weighted by index array", "weighted by u32 index array", "weighted by array sample", "weighted by ptr array", "weighted by mut ptr array", "WeightedChoice.new numChoices", "WeightedChoice.numChoices", "WeightedChoice.positiveCount", "WeightedChoice.constantIndex", "WeightedChoice.single-positive constantIndex", "WeightedChoice.item(2)", "WeightedChoice.weight(2)", "WeightedChoice.probability(2)", "WeightedChoice.get(2)", "WeightedChoice.weightIter fill", "WeightedChoice.weightIter sizeHint", "WeightedChoice.probabilityIter fill", "WeightedChoice.probabilityIter sizeHint", "WeightedChoice.valueArrayFrom", "WeightedChoice.ptrArrayFrom", "WeightedChoice.indexArrayFrom", "WeightedChoice.indexArrayU32From", "WeightedChoice.indexIterFrom fill", "WeightedChoice.indexIterU32From fill", "seq.chooseWeightedIterFrom fill", "WeightedChoice.initBy sample", "WeightedChoice.updateBy indices", "WeightedChoice.initByIndex sample", "WeightedChoice.updateByIndex values", "WeightedChoice.updateAt totalWeight", "WeightedChoice.updateMany totalWeight", "WeightedChoice.updateWeights totalWeight", "alias new numChoices", "alias numChoices", "alias positiveCount", "alias updateAt totalWeight", "alias updateMany totalWeight", "alias updateWeights totalWeight", "alias weight(2)", "alias probability(2)", "alias weightIter fill", "alias weightIter sizeHint", "alias probabilityIter fill", "alias probabilityIter sizeHint", "alias u32 sample indices", "alias owned u32 indices", "alias sampleIndex alias", "alias u32 iterator fill", "alias u32 index array", "alias initByIndex/updateByIndex", "alias initBy/updateBy", "index-weighted tree sample indices", "index-weighted int tree sample indices", "item-weighted tree sample labels", "item-weighted int tree sample labels", "dynamic tree numChoices", "dynamic tree positiveCount", "dynamic tree constantIndex", "dynamic tree updateMany totalWeight", "dynamic tree updateWeights totalWeight", "dynamic tree single-positive constantIndex", "dynamic tree weight(1)", "dynamic tree probability(1)", "dynamic tree weightIter fill", "dynamic tree weightIter sizeHint", "dynamic tree probabilityIter fill", "dynamic tree probabilityIter sizeHint", "dynamic tree sample u32 index", "dynamic tree u32 index array", "dynamic tree owned indices", "dynamic tree sampleIndex alias", "dynamic tree iterator next", "integer tree numChoices", "integer tree positiveCount", "integer tree constantIndex", "integer tree updateMany totalWeight", "integer tree updateWeights totalWeight", "integer tree single-positive constantIndex", "integer tree weight(2)", "integer tree probability(2)", "integer tree weightIter fill", "integer tree weightIter sizeHint", "integer tree probabilityIter fill", "integer tree probabilityIter sizeHint", "integer tree u32 sample indices", "integer tree u32 index array", "integer tree owned u32 indices", "integer tree fillIndices alias", "integer tree u32 iterator fill", "sampleU32/fillU32", "owned indices/indicesU32", "sampleIndex/fillIndices", "indexArray/indexArrayU32", "iter/iterU32", "initByIndex/updateByIndex", "initByIndex/updateAllByIndex", "initBy/updateAllBy", "weighted by indices into", "weighted by values into", "weighted by ptrs into", "weighted by mut ptrs into", "generic weighted index", "generic weighted index batch", "generic weighted index array", "generic weighted u32 index", "generic weighted u32 index batch", "generic weighted u32 index array", "weighted choice sample u32 index", "weighted choice u32 indices", "WeightedChoice.indicesU32From", "WeightedChoice.valuesFrom", "WeightedChoice.ptrsFrom", "weighted ptrs into", "weighted no-replacement ptrs", "weighted u32 no-replacement indices", "weighted IndexVec", "weighted u32 index array", "weighted u32 indices into" },
    },
    .{
        .path = "examples/sequence_sampling.zig",
        .step = "zig build run-sequence-sampling",
        .aggregate_token = "examples_step.dependOn(&run_sequence_sampling_example.step)",
        .source_tokens = &.{ "IndexVec.valuesInto", "IndexVec.valuesOwned", "IndexVec.ptrsOwned", "IndexVec.mutPtrsOwned", "IndexVec.toOwnedU32Slice", "IndexVec.eql cross-backing", "IndexVec.clone", "IndexVec.index(0)", "index_vec.get", "IndexVec.iter.fill", "IndexVec.values.fill", "IndexVec.intoIter", "IndexVec.fromOwnedSlice", "IndexVec.fromOwnedU32Slice", "IndexVec.intoOwnedSlice", "IndexVec.intoVec", "IndexVec.intoOwnedU32Slice", "Choice.new numChoices", "Choice.numChoices", "distribution Choose numChoices", "Choice.constantIndex", "Choice.single-item constantIndex", "Choice.item(2)", "Choice.probability(0)", "Choice.get(2)", "Choice.probabilityIter fill", "Choice.probabilityIter sizeHint", "Choice.sampleIndexFrom", "Choice.valueArrayFrom", "Choice.ptrArrayFrom", "Choice.valuesFrom", "Choice.ptrsFrom", "Choice.indicesU32From", "Choice.fillIndicesU32From", "Choice.indexArrayFrom", "Choice.indexArrayU32From", "Choice.indexIterFrom fill", "Choice.indexIterU32From fill", "chooseIteratorHintedFrom", "chooseIteratorStableFrom", "sampleIteratorFillFrom", "sampleArrayU32", "chooseFrom", "chooseConstPtrFrom", "choosePtrFrom", "chooseIndexFrom", "chooseIndexU32From", "fillChooseFrom", "fillChooseConstPtrFrom", "fillChooseIndexFrom", "fillChooseIndexU32From", "chooseIndexArrayFrom", "chooseIndexArrayU32From", "chooseRepeatedValueArrayFrom", "chooseRepeatedConstPtrArrayFrom", "chooseRepeatedPtrArrayFrom", "chooseBatchFrom", "chooseConstPtrBatchFrom", "chooseIndexBatchFrom", "chooseIndexU32BatchFrom", "sampleItemsFrom", "sampleItemsIter.fill", "sizeHint=", "sampleItemsIntoFrom", "sampleItemsArrayFrom", "samplePtrArrayFrom", "sampleMutPtrArrayFrom", "sampleMutPtrsIter", "shuffleFrom", "partialShuffleTailSplitFrom", "chooseMultiplePtrs", "samplePtrsIter", "reservoirSamplePtrsInto" },
    },
    .{
        .path = "examples/caller_owned_sampling.zig",
        .step = "zig build run-caller-owned-sampling",
        .aggregate_token = "examples_step.dependOn(&run_caller_owned_sampling_example.step)",
        .source_tokens = &.{ "chooseMultiplePtrsInto", "reservoirSamplePtrsInto", "weighted ptrs into" },
    },
    .{ .path = "examples/multivariate_sampling.zig", .step = "zig build run-multivariate-sampling", .aggregate_token = "examples_step.dependOn(&run_multivariate_sampling_example.step)" },
    .{
        .path = "examples/string_generation.zig",
        .step = "zig build run-string-generation",
        .aggregate_token = "examples_step.dependOn(&run_string_generation_example.step)",
        .source_tokens = &.{ "sampleString alphanumeric", "distribution Alphanumeric/Alphabetic bytes", "appendString alphanumeric", "custom charset numChoices", "custom charset constantIndex", "single charset constantIndex", "custom charset item(0)", "custom charset get(0)", "custom charset probability(0)", "custom charset probabilityIter fill", "custom charset probabilityIter sizeHint", "unicode scalar fill", "unicode scalar batch", "unicode scalar range fill", "unicode scalar range batch", "UniformUnicodeScalar range sampler", "unicode charset sampleString", "unicode charset appendString", "UnicodeCharset numChoices", "unicodeScalarBatch", "fillUnicodeScalar", "unicodeScalarRangeAtMostBatchChecked", "fillUnicodeScalarRangeLessThanChecked", "UnicodeCharset" },
    },
    .{ .path = "examples/unit_geometry.zig", .step = "zig build run-unit-geometry", .aggregate_token = "examples_step.dependOn(&run_unit_geometry_example.step)" },
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
    const build = try std.Io.Dir.cwd().readFileAlloc(io, "build.zig", allocator, .limited(1024 * 1024));
    defer allocator.free(build);

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
        if (std.mem.indexOf(u8, build, example.aggregate_token) == null) {
            try stderr.print("examplecheck: aggregate `zig build examples` missing {s} dependency token `{s}`\n", .{ example.path, example.aggregate_token });
            missing += 1;
        }
    }

    const weighted_source = try std.Io.Dir.cwd().readFileAlloc(io, "examples/weighted_sampling.zig", allocator, .limited(1024 * 1024));
    defer allocator.free(weighted_source);
    if (std.mem.indexOf(u8, weighted_source, "WeightedIndex alias numChoices") == null) {
        try stderr.print("examplecheck: source examples/weighted_sampling.zig missing expected token `WeightedIndex alias numChoices`\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, weighted_source, "weighted namespace numChoices") == null) {
        try stderr.print("examplecheck: source examples/weighted_sampling.zig missing expected token `weighted namespace numChoices`\n", .{});
        missing += 1;
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

test "known examples include representative runnable catalog entries" {
    try std.testing.expect(knownExample("examples/basic.zig"));
    try std.testing.expect(knownExample("examples/weighted_sampling.zig"));
    try std.testing.expect(knownExample("examples/string_generation.zig"));
    try std.testing.expect(!knownExample("examples/definitely-missing.zig"));
}

test "cataloged examples have build and aggregate tokens" {
    inline for (examples) |example| {
        try std.testing.expect(std.mem.startsWith(u8, example.path, "examples/"));
        try std.testing.expect(std.mem.endsWith(u8, example.path, ".zig"));
        try std.testing.expect(std.mem.startsWith(u8, example.step, "zig build run-"));
        try std.testing.expect(std.mem.startsWith(u8, example.aggregate_token, "examples_step.dependOn("));
    }
}
