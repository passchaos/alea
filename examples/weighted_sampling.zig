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

    var weighted_choice_engine = alea.ScalarPrng.init(0x7158);
    const weighted_value = (try alea.seq.chooseWeightedFrom(&weighted_choice_engine, []const u8, f64, &items, &float_weights)).?;
    try stdout.print("one-shot weighted value: {s}\n", .{weighted_value});

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

    var weighted_array_engine = alea.ScalarPrng.init(0x7159);
    const weighted_array = (try alea.seq.sampleWeightedArrayFrom(&weighted_array_engine, []const u8, f64, 3, &items, &float_weights)).?;
    try stdout.print("weighted array sample: [{s}, {s}, {s}]\n", .{ weighted_array[0], weighted_array[1], weighted_array[2] });

    var indices_engine = alea.ScalarPrng.init(0x7157);
    const no_replace_indices = try alea.seq.sampleWeightedIndicesFrom(allocator, &indices_engine, f64, &float_weights, 3);
    defer allocator.free(no_replace_indices);
    try stdout.print("weighted no-replacement indices: {any}\n", .{no_replace_indices});

    var index_array_engine = alea.ScalarPrng.init(0x715a);
    const weighted_index_array = (try alea.seq.sampleWeightedIndexArrayFrom(&index_array_engine, f64, 3, &float_weights)).?;
    try stdout.print("weighted index array: {any}\n", .{weighted_index_array});

    var indices_into_engine = alea.ScalarPrng.init(0x715b);
    var weighted_indices_into: [3]usize = undefined;
    var weighted_indices_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedIndicesIntoFrom(&indices_into_engine, f64, &float_weights, &weighted_indices_into, &weighted_indices_keys);
    try stdout.print("weighted indices into: {any}\n", .{weighted_indices_into});

    try stdout.print("\nUse weightedIndex or chooseWeighted for simple draws, AliasTable for repeated static weights, WeightedTree/WeightedIntTree for dynamic updates, and seq weighted helpers for item/index no-replacement, caller-owned index buffers, and fixed-size array workflows.\n", .{});
    try stdout.flush();
}
