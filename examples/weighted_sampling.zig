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

    var generic_index_engine = alea.ScalarPrng.init(0x7166);
    const generic_index = alea.seq.weightedIndexFrom(&generic_index_engine, u32, &int_weights).?;
    try stdout.print("generic weighted index: {} ({s})\n", .{ generic_index, items[generic_index] });

    var weighted_choice_engine = alea.ScalarPrng.init(0x7158);
    const weighted_value = (try alea.seq.chooseWeightedFrom(&weighted_choice_engine, []const u8, f64, &items, &float_weights)).?;
    try stdout.print("one-shot weighted value: {s}\n", .{weighted_value});
    var weighted_const_ptr_engine = alea.ScalarPrng.init(0x7163);
    const weighted_const_ptr = (try alea.seq.chooseWeightedConstPtrFrom(&weighted_const_ptr_engine, []const u8, f64, &items, &float_weights)).?;
    try stdout.print("one-shot weighted const ptr: {s}\n", .{weighted_const_ptr.*});

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
    var choice_values: [8][]const u8 = undefined;
    choice.fillValuesFrom(&choice_engine, &choice_values);
    try printStringSlice(stdout, "weighted choice values", &choice_values);

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

    var index_array_engine = alea.ScalarPrng.init(0x715a);
    const weighted_index_array = (try alea.seq.sampleWeightedIndexArrayFrom(&index_array_engine, f64, 3, &float_weights)).?;
    try stdout.print("weighted index array: {any}\n", .{weighted_index_array});

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

    try stdout.print("\nUse weightedIndex or chooseWeighted for simple draws, AliasTable for repeated static weights, WeightedTree/WeightedIntTree for dynamic updates, and seq weighted helpers for allocation-returning item/index/pointer no-replacement, caller-owned index/value/pointer buffers, and fixed-size value/pointer array workflows.\n", .{});
    try stdout.flush();
}
