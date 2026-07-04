const std = @import("std");
const alea = @import("alea");

fn printStringSlice(stdout: *std.Io.Writer, label: []const u8, values: []const []const u8) !void {
    try stdout.print("{s}: [", .{label});
    for (values, 0..) |value, i| {
        if (i != 0) try stdout.print(", ", .{});
        try stdout.print("{s}", .{value});
    }
    try stdout.print("]\n", .{});
}

const WeightedRecord = struct {
    label: []const u8,
    score: u32,

    fn weightOf(item: *const WeightedRecord) u32 {
        return item.score;
    }
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const items = [_][]const u8{ "red", "green", "blue", "gold" };
    const float_weights = [_]f64{ 1, 2, 6, 3 };
    const int_weights = [_]u32{ 1, 2, 6, 3 };

    var one_shot_engine = alea.ScalarPrng.init(0x7151);
    const one_shot = alea.Rng.weightedIndexFrom(&one_shot_engine, &float_weights).?;
    try stdout.print("one-shot weighted index: {} ({s})\n", .{ one_shot, items[one_shot] });

    var batch_weighted_engine = alea.ScalarPrng.init(0x7152);
    const weighted_index_batch = try alea.Rng.weightedIndexBatchCheckedFrom(&batch_weighted_engine, allocator, 6, &float_weights);
    defer allocator.free(weighted_index_batch);
    try stdout.print("weighted index batch: {any}\n", .{weighted_index_batch});

    var batch_weighted_u32_engine = alea.ScalarPrng.init(0x7153);
    const weighted_u32_index_batch = try alea.Rng.weightedIndexU32BatchCheckedFrom(&batch_weighted_u32_engine, allocator, 6, &float_weights);
    defer allocator.free(weighted_u32_index_batch);
    try stdout.print("weighted u32 index batch: {any}\n", .{weighted_u32_index_batch});

    var one_shot_u32_engine = alea.ScalarPrng.init(0x716c);
    const one_shot_u32 = (try alea.Rng.weightedIndexU32From(&one_shot_u32_engine, &float_weights)).?;
    try stdout.print("one-shot weighted u32 index: {} ({s})\n", .{ one_shot_u32, items[one_shot_u32] });

    var generic_index_engine = alea.ScalarPrng.init(0x7166);
    const generic_index = alea.seq.weightedIndexFrom(&generic_index_engine, u32, &int_weights).?;
    try stdout.print("generic weighted index: {} ({s})\n", .{ generic_index, items[generic_index] });

    var generic_index_batch_engine = alea.ScalarPrng.init(0x716f);
    const generic_index_batch = try alea.seq.weightedIndexBatchCheckedFrom(allocator, &generic_index_batch_engine, u32, 6, &int_weights);
    defer allocator.free(generic_index_batch);
    try stdout.print("generic weighted index batch: {any}\n", .{generic_index_batch});

    var u32_index_engine = alea.ScalarPrng.init(0x716b);
    const generic_u32_index = (try alea.seq.weightedIndexU32From(&u32_index_engine, u32, &int_weights)).?;
    try stdout.print("generic weighted u32 index: {} ({s})\n", .{ generic_u32_index, items[generic_u32_index] });

    var generic_u32_index_batch_engine = alea.ScalarPrng.init(0x7170);
    const generic_u32_index_batch = try alea.seq.weightedIndexU32BatchCheckedFrom(allocator, &generic_u32_index_batch_engine, u32, 6, &int_weights);
    defer allocator.free(generic_u32_index_batch);
    try stdout.print("generic weighted u32 index batch: {any}\n", .{generic_u32_index_batch});

    var weighted_choice_engine = alea.ScalarPrng.init(0x7158);
    const weighted_value = (try alea.seq.chooseWeightedFrom(&weighted_choice_engine, []const u8, f64, &items, &float_weights)).?;
    try stdout.print("one-shot weighted value: {s}\n", .{weighted_value});

    var weighted_value_batch_engine = alea.ScalarPrng.init(0x7159);
    const weighted_value_batch = try alea.Rng.chooseWeightedBatchCheckedFrom(&weighted_value_batch_engine, []const u8, allocator, 6, &items, &float_weights);
    defer allocator.free(weighted_value_batch);
    try stdout.print("weighted value batch: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ weighted_value_batch[0], weighted_value_batch[1], weighted_value_batch[2], weighted_value_batch[3], weighted_value_batch[4], weighted_value_batch[5] });

    var generic_value_batch_engine = alea.ScalarPrng.init(0x7171);
    const generic_value_batch = try alea.seq.chooseWeightedBatchCheckedFrom(allocator, &generic_value_batch_engine, []const u8, u32, 6, &items, &int_weights);
    defer allocator.free(generic_value_batch);
    try stdout.print("generic weighted value batch: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ generic_value_batch[0], generic_value_batch[1], generic_value_batch[2], generic_value_batch[3], generic_value_batch[4], generic_value_batch[5] });

    var weighted_const_ptr_engine = alea.ScalarPrng.init(0x7163);
    const weighted_const_ptr = (try alea.seq.chooseWeightedConstPtrFrom(&weighted_const_ptr_engine, []const u8, f64, &items, &float_weights)).?;
    try stdout.print("one-shot weighted const ptr: {s}\n", .{weighted_const_ptr.*});

    var weighted_const_ptr_batch_engine = alea.ScalarPrng.init(0x716d);
    const weighted_const_ptr_batch = try alea.Rng.chooseWeightedConstPtrBatchCheckedFrom(&weighted_const_ptr_batch_engine, []const u8, allocator, 6, &items, &float_weights);
    defer allocator.free(weighted_const_ptr_batch);
    try stdout.print("weighted const ptr batch: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ weighted_const_ptr_batch[0].*, weighted_const_ptr_batch[1].*, weighted_const_ptr_batch[2].*, weighted_const_ptr_batch[3].*, weighted_const_ptr_batch[4].*, weighted_const_ptr_batch[5].* });

    var generic_const_ptr_batch_engine = alea.ScalarPrng.init(0x7172);
    const generic_const_ptr_batch = try alea.seq.chooseWeightedConstPtrBatchCheckedFrom(allocator, &generic_const_ptr_batch_engine, []const u8, u32, 6, &items, &int_weights);
    defer allocator.free(generic_const_ptr_batch);
    try stdout.print("generic weighted const ptr batch: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ generic_const_ptr_batch[0].*, generic_const_ptr_batch[1].*, generic_const_ptr_batch[2].*, generic_const_ptr_batch[3].*, generic_const_ptr_batch[4].*, generic_const_ptr_batch[5].* });

    var weighted_mut_ptr_batch_engine = alea.ScalarPrng.init(0x716e);
    var weighted_mut_scores_batch = [_]u8{ 10, 20, 30, 40 };
    const weighted_mut_ptr_batch = try alea.Rng.chooseWeightedPtrBatchCheckedFrom(&weighted_mut_ptr_batch_engine, u8, allocator, 6, &weighted_mut_scores_batch, &float_weights);
    defer allocator.free(weighted_mut_ptr_batch);
    for (weighted_mut_ptr_batch) |score| score.* += 1;
    try stdout.print("weighted mut ptr batch scores: {any}\n", .{weighted_mut_scores_batch});

    var generic_mut_ptr_batch_engine = alea.ScalarPrng.init(0x7173);
    var generic_mut_scores_batch = [_]u8{ 10, 20, 30, 40 };
    const generic_mut_ptr_batch = try alea.seq.chooseWeightedPtrBatchCheckedFrom(allocator, &generic_mut_ptr_batch_engine, u8, u32, 6, &generic_mut_scores_batch, &int_weights);
    defer allocator.free(generic_mut_ptr_batch);
    for (generic_mut_ptr_batch) |score| score.* += 1;
    try stdout.print("generic weighted mut ptr batch scores: {any}\n", .{generic_mut_scores_batch});

    const weighted_records = [_]WeightedRecord{
        .{ .label = "never", .score = 0 },
        .{ .label = "rare", .score = 2 },
        .{ .label = "often", .score = 8 },
        .{ .label = "bonus", .score = 3 },
    };
    var weighted_by_engine = alea.ScalarPrng.init(0x7174);
    const weighted_by_value = (try alea.seq.chooseWeightedByFrom(&weighted_by_engine, WeightedRecord, u32, &weighted_records, WeightedRecord.weightOf)).?;
    try stdout.print("weighted by value: {s}\n", .{weighted_by_value.label});
    var weighted_by_const_ptr_engine = alea.ScalarPrng.init(0x7175);
    const weighted_by_const_ptr = (try alea.seq.chooseWeightedConstPtrByFrom(&weighted_by_const_ptr_engine, WeightedRecord, u32, &weighted_records, WeightedRecord.weightOf)).?;
    try stdout.print("weighted by const ptr: {s}\n", .{weighted_by_const_ptr.label});
    var weighted_by_mut_records = weighted_records;
    var weighted_by_mut_ptr_engine = alea.ScalarPrng.init(0x7176);
    const weighted_by_mut_ptr = (try alea.seq.chooseWeightedPtrByFrom(&weighted_by_mut_ptr_engine, WeightedRecord, u32, &weighted_by_mut_records, WeightedRecord.weightOf)).?;
    weighted_by_mut_ptr.score += 1;
    try stdout.print("weighted by mut ptr score: {}\n", .{weighted_by_mut_ptr.score});

    var alias = try alea.distributions.AliasTable(f64).init(allocator, &float_weights);
    defer alias.deinit();
    var alias_probs: [items.len]f64 = undefined;
    try alias.probabilitiesInto(&alias_probs);
    var alias_engine = alea.ScalarPrng.init(0x7152);
    var alias_samples: [8]usize = undefined;
    alias.fillFrom(&alias_engine, &alias_samples);
    try stdout.print("alias probabilities: {any}\n", .{alias_probs});
    try stdout.print("alias sample indices: {any}\n", .{alias_samples});

    var tree = try alea.distributions.WeightedTree(f64).init(allocator, &float_weights);
    defer tree.deinit();
    try tree.update(1, 8);
    try tree.push(4);
    var tree_probs: [items.len + 1]f64 = undefined;
    try tree.probabilitiesInto(&tree_probs);
    var tree_engine = alea.ScalarPrng.init(0x7153);
    var tree_samples: [8]usize = undefined;
    tree.fillFrom(&tree_engine, &tree_samples);
    try stdout.print("dynamic tree probabilities after update/push: {any}\n", .{tree_probs});
    try stdout.print("dynamic tree sample indices: {any}\n", .{tree_samples});

    var int_tree = try alea.distributions.WeightedIntTree(u32).init(allocator, &int_weights);
    defer int_tree.deinit();
    try int_tree.update(2, 10);
    var int_tree_engine = alea.ScalarPrng.init(0x7154);
    var int_tree_samples: [8]usize = undefined;
    int_tree.fillFrom(&int_tree_engine, &int_tree_samples);
    try stdout.print("integer tree total weight: {}\n", .{int_tree.totalWeight()});
    try stdout.print("integer tree sample indices: {any}\n", .{int_tree_samples});

    var choice = try alea.seq.WeightedChoice([]const u8, f64).init(allocator, &items, &float_weights);
    defer choice.deinit();
    var choice_engine = alea.ScalarPrng.init(0x7155);
    const choice_index = choice.sampleIndexFrom(&choice_engine);
    try stdout.print("weighted choice sample index: {}\n", .{choice_index});
    const choice_index_u32 = try choice.sampleIndexU32From(&choice_engine);
    try stdout.print("weighted choice sample u32 index: {}\n", .{choice_index_u32});
    var choice_values: [8][]const u8 = undefined;
    choice.fillValuesFrom(&choice_engine, &choice_values);
    try printStringSlice(stdout, "weighted choice values", &choice_values);
    var choice_indices: [8]usize = undefined;
    choice.fillIndicesFrom(&choice_engine, &choice_indices);
    try stdout.print("weighted choice indices: {any}\n", .{choice_indices});
    var choice_indices_u32: [8]u32 = undefined;
    try choice.fillIndicesU32From(&choice_engine, &choice_indices_u32);
    try stdout.print("weighted choice u32 indices: {any}\n", .{choice_indices_u32});
    const choice_owned_indices = try choice.indicesFrom(allocator, &choice_engine, 8);
    defer allocator.free(choice_owned_indices);
    try stdout.print("WeightedChoice.indicesFrom: {any}\n", .{choice_owned_indices});
    const choice_owned_indices_u32 = try choice.indicesU32From(allocator, &choice_engine, 8);
    defer allocator.free(choice_owned_indices_u32);
    try stdout.print("WeightedChoice.indicesU32From: {any}\n", .{choice_owned_indices_u32});
    const choice_owned_values = try choice.valuesFrom(allocator, &choice_engine, 8);
    defer allocator.free(choice_owned_values);
    try printStringSlice(stdout, "WeightedChoice.valuesFrom", choice_owned_values);
    const choice_owned_ptrs = try choice.ptrsFrom(allocator, &choice_engine, 8);
    defer allocator.free(choice_owned_ptrs);
    try stdout.print("WeightedChoice.ptrsFrom: [{s}, {s}, {s}, {s}, {s}, {s}, {s}, {s}]\n", .{ choice_owned_ptrs[0].*, choice_owned_ptrs[1].*, choice_owned_ptrs[2].*, choice_owned_ptrs[3].*, choice_owned_ptrs[4].*, choice_owned_ptrs[5].*, choice_owned_ptrs[6].*, choice_owned_ptrs[7].* });

    var no_replace_engine = alea.ScalarPrng.init(0x7156);
    const no_replace = try alea.seq.sampleWeightedFrom(allocator, &no_replace_engine, []const u8, f64, &items, &float_weights, 3);
    defer allocator.free(no_replace);
    try printStringSlice(stdout, "weighted no-replacement sample", no_replace);

    var no_replace_ptrs_engine = alea.ScalarPrng.init(0x7164);
    const no_replace_ptrs = try alea.seq.sampleWeightedPtrsFrom(allocator, &no_replace_ptrs_engine, []const u8, f64, &items, &float_weights, 3);
    defer allocator.free(no_replace_ptrs);
    try stdout.print("weighted no-replacement ptrs: [{s}, {s}, {s}]\n", .{ no_replace_ptrs[0].*, no_replace_ptrs[1].*, no_replace_ptrs[2].* });

    var no_replace_mut_ptrs_engine = alea.ScalarPrng.init(0x7165);
    var weighted_alloc_scores = [_]u8{ 10, 20, 30, 40 };
    const no_replace_mut_ptrs = try alea.seq.sampleWeightedMutPtrsFrom(allocator, &no_replace_mut_ptrs_engine, u8, f64, &weighted_alloc_scores, &float_weights, 3);
    defer allocator.free(no_replace_mut_ptrs);
    for (no_replace_mut_ptrs) |score| score.* += 7;
    try stdout.print("weighted no-replacement mut ptr scores: {any}\n", .{weighted_alloc_scores});

    var no_replace_by_engine = alea.ScalarPrng.init(0x7177);
    const no_replace_by = try alea.seq.sampleWeightedByFrom(allocator, &no_replace_by_engine, WeightedRecord, u32, &weighted_records, 3, WeightedRecord.weightOf);
    defer allocator.free(no_replace_by);
    try stdout.print("weighted by no-replacement sample: [{s}, {s}, {s}]\n", .{ no_replace_by[0].label, no_replace_by[1].label, no_replace_by[2].label });

    var no_replace_by_ptrs_engine = alea.ScalarPrng.init(0x7178);
    const no_replace_by_ptrs = try alea.seq.sampleWeightedPtrsByFrom(allocator, &no_replace_by_ptrs_engine, WeightedRecord, u32, &weighted_records, 3, WeightedRecord.weightOf);
    defer allocator.free(no_replace_by_ptrs);
    try stdout.print("weighted by no-replacement ptrs: [{s}, {s}, {s}]\n", .{ no_replace_by_ptrs[0].label, no_replace_by_ptrs[1].label, no_replace_by_ptrs[2].label });

    var no_replace_by_mut_records = weighted_records;
    var no_replace_by_mut_ptrs_engine = alea.ScalarPrng.init(0x7179);
    const no_replace_by_mut_ptrs = try alea.seq.sampleWeightedMutPtrsByFrom(allocator, &no_replace_by_mut_ptrs_engine, WeightedRecord, u32, &no_replace_by_mut_records, 3, WeightedRecord.weightOf);
    defer allocator.free(no_replace_by_mut_ptrs);
    for (no_replace_by_mut_ptrs) |record| record.score += 10;
    try stdout.print("weighted by no-replacement mut ptr scores: [{}, {}, {}, {}]\n", .{ no_replace_by_mut_records[0].score, no_replace_by_mut_records[1].score, no_replace_by_mut_records[2].score, no_replace_by_mut_records[3].score });

    var weighted_array_engine = alea.ScalarPrng.init(0x7159);
    const weighted_array = (try alea.seq.sampleWeightedArrayFrom(&weighted_array_engine, []const u8, f64, 3, &items, &float_weights)).?;
    try stdout.print("weighted array sample: [{s}, {s}, {s}]\n", .{ weighted_array[0], weighted_array[1], weighted_array[2] });

    var weighted_ptr_array_engine = alea.ScalarPrng.init(0x715f);
    const weighted_ptr_array = (try alea.seq.sampleWeightedPtrArrayFrom(&weighted_ptr_array_engine, []const u8, f64, 3, &items, &float_weights)).?;
    try stdout.print("weighted ptr array sample: [{s}, {s}, {s}]\n", .{ weighted_ptr_array[0].*, weighted_ptr_array[1].*, weighted_ptr_array[2].* });

    var weighted_mut_ptr_array_engine = alea.ScalarPrng.init(0x7160);
    var weighted_scores = [_]u8{ 10, 20, 30, 40 };
    const weighted_mut_ptr_array = (try alea.seq.sampleWeightedMutPtrArrayFrom(&weighted_mut_ptr_array_engine, u8, f64, 3, &weighted_scores, &float_weights)).?;
    for (weighted_mut_ptr_array) |score| score.* += 4;
    try stdout.print("weighted mut ptr array scores: {any}\n", .{weighted_scores});

    var indices_engine = alea.ScalarPrng.init(0x7157);
    const no_replace_indices = try alea.seq.sampleWeightedIndicesFrom(allocator, &indices_engine, f64, &float_weights, 3);
    defer allocator.free(no_replace_indices);
    try stdout.print("weighted no-replacement indices: {any}\n", .{no_replace_indices});

    var u32_indices_engine = alea.ScalarPrng.init(0x716a);
    const no_replace_u32_indices = try alea.seq.sampleWeightedIndicesU32From(allocator, &u32_indices_engine, f64, &float_weights, 3);
    defer allocator.free(no_replace_u32_indices);
    try stdout.print("weighted u32 no-replacement indices: {any}\n", .{no_replace_u32_indices});

    var index_array_engine = alea.ScalarPrng.init(0x715a);
    const weighted_index_array = (try alea.seq.sampleWeightedIndexArrayFrom(&index_array_engine, f64, 3, &float_weights)).?;
    try stdout.print("weighted index array: {any}\n", .{weighted_index_array});

    var u32_index_array_engine = alea.ScalarPrng.init(0x7169);
    const weighted_u32_index_array = (try alea.seq.sampleWeightedIndexArrayU32From(&u32_index_array_engine, f64, 3, &float_weights)).?;
    try stdout.print("weighted u32 index array: {any}\n", .{weighted_u32_index_array});

    var index_vec_engine = alea.ScalarPrng.init(0x7167);
    const weighted_index_vec = try alea.seq.sampleWeightedIndexVecFrom(allocator, &index_vec_engine, f64, &float_weights, 3);
    defer weighted_index_vec.deinit(allocator);
    try stdout.print("weighted IndexVec: [", .{});
    var weighted_index_vec_iter = weighted_index_vec.iter();
    var first_weighted_index = true;
    while (weighted_index_vec_iter.next()) |index| {
        if (!first_weighted_index) try stdout.print(", ", .{});
        first_weighted_index = false;
        try stdout.print("{}", .{index});
    }
    try stdout.print("]\n", .{});

    var indices_into_engine = alea.ScalarPrng.init(0x715b);
    var weighted_indices_into: [3]usize = undefined;
    var weighted_indices_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedIndicesIntoFrom(&indices_into_engine, f64, &float_weights, &weighted_indices_into, &weighted_indices_keys);
    try stdout.print("weighted indices into: {any}\n", .{weighted_indices_into});

    var u32_indices_into_engine = alea.ScalarPrng.init(0x7168);
    var weighted_u32_indices_into: [3]u32 = undefined;
    var weighted_u32_indices_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedIndicesU32IntoFrom(&u32_indices_into_engine, f64, &float_weights, &weighted_u32_indices_into, &weighted_u32_indices_keys);
    try stdout.print("weighted u32 indices into: {any}\n", .{weighted_u32_indices_into});

    var weighted_into_engine = alea.ScalarPrng.init(0x715c);
    var weighted_into_values: [3][]const u8 = undefined;
    var weighted_into_indices: [3]usize = undefined;
    var weighted_into_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedIntoFrom(&weighted_into_engine, []const u8, f64, &items, &float_weights, &weighted_into_values, &weighted_into_indices, &weighted_into_keys);
    try printStringSlice(stdout, "weighted values into", &weighted_into_values);

    var weighted_ptrs_into_engine = alea.ScalarPrng.init(0x7161);
    var weighted_ptrs_into: [3]*const []const u8 = undefined;
    var weighted_ptrs_indices: [3]usize = undefined;
    var weighted_ptrs_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedPtrsIntoFrom(&weighted_ptrs_into_engine, []const u8, f64, &items, &float_weights, &weighted_ptrs_into, &weighted_ptrs_indices, &weighted_ptrs_keys);
    try stdout.print("weighted ptrs into: [{s}, {s}, {s}]\n", .{ weighted_ptrs_into[0].*, weighted_ptrs_into[1].*, weighted_ptrs_into[2].* });

    var weighted_mut_ptrs_into_engine = alea.ScalarPrng.init(0x7162);
    var weighted_scores_into = [_]u8{ 10, 20, 30, 40 };
    var weighted_mut_ptrs_into: [3]*u8 = undefined;
    var weighted_mut_ptrs_indices: [3]usize = undefined;
    var weighted_mut_ptrs_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedMutPtrsIntoFrom(&weighted_mut_ptrs_into_engine, u8, f64, &weighted_scores_into, &float_weights, &weighted_mut_ptrs_into, &weighted_mut_ptrs_indices, &weighted_mut_ptrs_keys);
    for (weighted_mut_ptrs_into) |score| score.* += 5;
    try stdout.print("weighted mut ptrs into scores: {any}\n", .{weighted_scores_into});

    try stdout.print("\nUse weightedIndex or chooseWeighted for simple draws, chooseWeightedBy/ConstPtrBy/PtrBy and sampleWeightedBy/PtrsBy/MutPtrsBy when weights live inside item records, Rng weighted batch helpers for repeated f64 index/value/const-pointer/mutable-pointer draws, AliasTable/WeightedChoice for repeated static weights including owned value/pointer/index batches, WeightedTree/WeightedIntTree for dynamic updates, and seq weighted helpers for allocation-returning item/index/pointer no-replacement, caller-owned usize/u32 index/value/pointer buffers, and fixed-size value/pointer array workflows.\n", .{});
    try stdout.flush();
}
