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

    fn refreshedWeightOf(item: *const WeightedRecord) u32 {
        if (std.mem.eql(u8, item.label, "never")) return 5;
        if (std.mem.eql(u8, item.label, "bonus")) return 0;
        return item.score;
    }
};

fn indexWeight(index: usize) u32 {
    return switch (index) {
        0 => 1,
        2 => 6,
        3 => 3,
        else => 0,
    };
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

    var index_weight_one_engine = alea.ScalarPrng.init(0x71a0);
    const index_weight_one = (try alea.seq.weightedIndexByIndexFrom(&index_weight_one_engine, u32, items.len, indexWeight)).?;
    try stdout.print("weighted index-weight one-shot index: {} ({s})\n", .{ index_weight_one, items[index_weight_one] });

    var index_weight_one_u32_engine = alea.ScalarPrng.init(0x71a1);
    const index_weight_one_u32 = (try alea.seq.weightedIndexU32ByIndexFrom(&index_weight_one_u32_engine, u32, items.len, indexWeight)).?;
    try stdout.print("weighted index-weight one-shot u32 index: {} ({s})\n", .{ index_weight_one_u32, items[index_weight_one_u32] });

    var index_weight_fill_engine = alea.ScalarPrng.init(0x71a2);
    var index_weight_fill: [6]?usize = undefined;
    try alea.seq.fillWeightedIndexByIndexFrom(&index_weight_fill_engine, u32, &index_weight_fill, items.len, indexWeight);
    try stdout.print("weighted index-weight index fill: {any}\n", .{index_weight_fill});

    var index_weight_u32_fill_engine = alea.ScalarPrng.init(0x71a3);
    var index_weight_u32_fill: [6]?u32 = undefined;
    try alea.seq.fillWeightedIndexU32ByIndexFrom(&index_weight_u32_fill_engine, u32, &index_weight_u32_fill, items.len, indexWeight);
    try stdout.print("weighted index-weight u32 index fill: {any}\n", .{index_weight_u32_fill});

    var index_weight_batch_engine = alea.ScalarPrng.init(0x71a4);
    const index_weight_batch = try alea.seq.weightedIndexBatchByIndexFrom(allocator, &index_weight_batch_engine, u32, 6, items.len, indexWeight);
    defer allocator.free(index_weight_batch);
    try stdout.print("weighted index-weight index batch: {any}\n", .{index_weight_batch});

    var index_weight_u32_batch_engine = alea.ScalarPrng.init(0x71a5);
    const index_weight_u32_batch = try alea.seq.weightedIndexU32BatchByIndexFrom(allocator, &index_weight_u32_batch_engine, u32, 6, items.len, indexWeight);
    defer allocator.free(index_weight_u32_batch);
    try stdout.print("weighted index-weight u32 index batch: {any}\n", .{index_weight_u32_batch});

    var index_weight_value_engine = alea.ScalarPrng.init(0x71a6);
    const index_weight_value = (try alea.seq.chooseWeightedByIndexFrom(&index_weight_value_engine, []const u8, u32, &items, indexWeight)).?;
    try stdout.print("weighted index-weight value: {s}\n", .{index_weight_value});

    var index_weight_const_ptr_engine = alea.ScalarPrng.init(0x71a7);
    const index_weight_const_ptr = (try alea.seq.chooseWeightedConstPtrByIndexFrom(&index_weight_const_ptr_engine, []const u8, u32, &items, indexWeight)).?;
    try stdout.print("weighted index-weight const ptr: {s}\n", .{index_weight_const_ptr.*});

    var index_weight_mut_items = items;
    var index_weight_mut_ptr_engine = alea.ScalarPrng.init(0x71a8);
    const index_weight_mut_ptr = (try alea.seq.chooseWeightedPtrByIndexFrom(&index_weight_mut_ptr_engine, []const u8, u32, &index_weight_mut_items, indexWeight)).?;
    index_weight_mut_ptr.* = "picked";
    try stdout.print("weighted index-weight mut ptr value: {s}\n", .{index_weight_mut_ptr.*});

    var index_weight_value_fill_engine = alea.ScalarPrng.init(0x71a9);
    var index_weight_value_fill: [6]?[]const u8 = undefined;
    try alea.seq.fillChooseWeightedByIndexFrom(&index_weight_value_fill_engine, []const u8, u32, &index_weight_value_fill, &items, indexWeight);
    try stdout.print("weighted index-weight value fill: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ index_weight_value_fill[0].?, index_weight_value_fill[1].?, index_weight_value_fill[2].?, index_weight_value_fill[3].?, index_weight_value_fill[4].?, index_weight_value_fill[5].? });

    var index_weight_const_ptr_fill_engine = alea.ScalarPrng.init(0x71aa);
    var index_weight_const_ptr_fill: [6]?*const []const u8 = undefined;
    try alea.seq.fillChooseWeightedConstPtrByIndexFrom(&index_weight_const_ptr_fill_engine, []const u8, u32, &index_weight_const_ptr_fill, &items, indexWeight);
    try stdout.print("weighted index-weight const ptr fill: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ index_weight_const_ptr_fill[0].?.*, index_weight_const_ptr_fill[1].?.*, index_weight_const_ptr_fill[2].?.*, index_weight_const_ptr_fill[3].?.*, index_weight_const_ptr_fill[4].?.*, index_weight_const_ptr_fill[5].?.* });

    var index_weight_mut_fill_items = items;
    var index_weight_mut_ptr_fill_engine = alea.ScalarPrng.init(0x71ab);
    var index_weight_mut_ptr_fill: [6]?*[]const u8 = undefined;
    try alea.seq.fillChooseWeightedPtrByIndexFrom(&index_weight_mut_ptr_fill_engine, []const u8, u32, &index_weight_mut_ptr_fill, &index_weight_mut_fill_items, indexWeight);
    for (index_weight_mut_ptr_fill) |slot| slot.?.* = "fill";
    try stdout.print("weighted index-weight mut ptr fill items: [{s}, {s}, {s}, {s}]\n", .{ index_weight_mut_fill_items[0], index_weight_mut_fill_items[1], index_weight_mut_fill_items[2], index_weight_mut_fill_items[3] });

    var index_weight_value_batch_engine = alea.ScalarPrng.init(0x71ac);
    const index_weight_value_batch = try alea.seq.chooseWeightedBatchByIndexFrom(allocator, &index_weight_value_batch_engine, []const u8, u32, 6, &items, indexWeight);
    defer allocator.free(index_weight_value_batch);
    try stdout.print("weighted index-weight value batch: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ index_weight_value_batch[0].?, index_weight_value_batch[1].?, index_weight_value_batch[2].?, index_weight_value_batch[3].?, index_weight_value_batch[4].?, index_weight_value_batch[5].? });

    var index_weight_const_ptr_batch_engine = alea.ScalarPrng.init(0x71ad);
    const index_weight_const_ptr_batch = try alea.seq.chooseWeightedConstPtrBatchByIndexFrom(allocator, &index_weight_const_ptr_batch_engine, []const u8, u32, 6, &items, indexWeight);
    defer allocator.free(index_weight_const_ptr_batch);
    try stdout.print("weighted index-weight const ptr batch: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ index_weight_const_ptr_batch[0].?.*, index_weight_const_ptr_batch[1].?.*, index_weight_const_ptr_batch[2].?.*, index_weight_const_ptr_batch[3].?.*, index_weight_const_ptr_batch[4].?.*, index_weight_const_ptr_batch[5].?.* });

    var index_weight_mut_batch_items = items;
    var index_weight_mut_ptr_batch_engine = alea.ScalarPrng.init(0x71ae);
    const index_weight_mut_ptr_batch = try alea.seq.chooseWeightedPtrBatchByIndexFrom(allocator, &index_weight_mut_ptr_batch_engine, []const u8, u32, 6, &index_weight_mut_batch_items, indexWeight);
    defer allocator.free(index_weight_mut_ptr_batch);
    for (index_weight_mut_ptr_batch) |slot| slot.?.* = "batch";
    try stdout.print("weighted index-weight mut ptr batch items: [{s}, {s}, {s}, {s}]\n", .{ index_weight_mut_batch_items[0], index_weight_mut_batch_items[1], index_weight_mut_batch_items[2], index_weight_mut_batch_items[3] });

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

    var weighted_by_index_engine = alea.ScalarPrng.init(0x719a);
    const weighted_by_index = (try alea.seq.weightedIndexByFrom(&weighted_by_index_engine, WeightedRecord, u32, &weighted_records, WeightedRecord.weightOf)).?;
    try stdout.print("weighted by one-shot index: {} ({s})\n", .{ weighted_by_index, weighted_records[weighted_by_index].label });

    var weighted_by_u32_index_engine = alea.ScalarPrng.init(0x719b);
    const weighted_by_u32_index = (try alea.seq.weightedIndexU32ByFrom(&weighted_by_u32_index_engine, WeightedRecord, u32, &weighted_records, WeightedRecord.weightOf)).?;
    try stdout.print("weighted by one-shot u32 index: {} ({s})\n", .{ weighted_by_u32_index, weighted_records[weighted_by_u32_index].label });

    var weighted_by_index_fill_engine = alea.ScalarPrng.init(0x719c);
    var weighted_by_index_fill: [6]?usize = undefined;
    try alea.seq.fillWeightedIndexByFrom(&weighted_by_index_fill_engine, WeightedRecord, u32, &weighted_by_index_fill, &weighted_records, WeightedRecord.weightOf);
    try stdout.print("weighted by index fill: {any}\n", .{weighted_by_index_fill});

    var weighted_by_u32_index_fill_engine = alea.ScalarPrng.init(0x719d);
    var weighted_by_u32_index_fill: [6]?u32 = undefined;
    try alea.seq.fillWeightedIndexU32ByFrom(&weighted_by_u32_index_fill_engine, WeightedRecord, u32, &weighted_by_u32_index_fill, &weighted_records, WeightedRecord.weightOf);
    try stdout.print("weighted by u32 index fill: {any}\n", .{weighted_by_u32_index_fill});

    var weighted_by_index_batch_engine = alea.ScalarPrng.init(0x719e);
    const weighted_by_index_batch = try alea.seq.weightedIndexBatchByFrom(allocator, &weighted_by_index_batch_engine, WeightedRecord, u32, 6, &weighted_records, WeightedRecord.weightOf);
    defer allocator.free(weighted_by_index_batch);
    try stdout.print("weighted by index batch: {any}\n", .{weighted_by_index_batch});

    var weighted_by_u32_index_batch_engine = alea.ScalarPrng.init(0x719f);
    const weighted_by_u32_index_batch = try alea.seq.weightedIndexU32BatchByFrom(allocator, &weighted_by_u32_index_batch_engine, WeightedRecord, u32, 6, &weighted_records, WeightedRecord.weightOf);
    defer allocator.free(weighted_by_u32_index_batch);
    try stdout.print("weighted by u32 index batch: {any}\n", .{weighted_by_u32_index_batch});

    var weighted_by_fill_engine = alea.ScalarPrng.init(0x7194);
    var weighted_by_fill_values: [6]?WeightedRecord = undefined;
    try alea.seq.fillChooseWeightedByFrom(&weighted_by_fill_engine, WeightedRecord, u32, &weighted_by_fill_values, &weighted_records, WeightedRecord.weightOf);
    try stdout.print("weighted by value fill: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ weighted_by_fill_values[0].?.label, weighted_by_fill_values[1].?.label, weighted_by_fill_values[2].?.label, weighted_by_fill_values[3].?.label, weighted_by_fill_values[4].?.label, weighted_by_fill_values[5].?.label });

    var weighted_by_ptr_fill_engine = alea.ScalarPrng.init(0x7195);
    var weighted_by_ptr_fill: [6]?*const WeightedRecord = undefined;
    try alea.seq.fillChooseWeightedConstPtrByFrom(&weighted_by_ptr_fill_engine, WeightedRecord, u32, &weighted_by_ptr_fill, &weighted_records, WeightedRecord.weightOf);
    try stdout.print("weighted by const ptr fill: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ weighted_by_ptr_fill[0].?.label, weighted_by_ptr_fill[1].?.label, weighted_by_ptr_fill[2].?.label, weighted_by_ptr_fill[3].?.label, weighted_by_ptr_fill[4].?.label, weighted_by_ptr_fill[5].?.label });

    var weighted_by_mut_fill_records = weighted_records;
    var weighted_by_mut_fill_engine = alea.ScalarPrng.init(0x7196);
    var weighted_by_mut_fill: [6]?*WeightedRecord = undefined;
    try alea.seq.fillChooseWeightedPtrByFrom(&weighted_by_mut_fill_engine, WeightedRecord, u32, &weighted_by_mut_fill, &weighted_by_mut_fill_records, WeightedRecord.weightOf);
    for (weighted_by_mut_fill) |record| record.?.score += 1;
    try stdout.print("weighted by mut ptr fill scores: [{}, {}, {}, {}]\n", .{ weighted_by_mut_fill_records[0].score, weighted_by_mut_fill_records[1].score, weighted_by_mut_fill_records[2].score, weighted_by_mut_fill_records[3].score });

    var weighted_by_batch_engine = alea.ScalarPrng.init(0x7197);
    const weighted_by_batch = try alea.seq.chooseWeightedBatchByFrom(allocator, &weighted_by_batch_engine, WeightedRecord, u32, 6, &weighted_records, WeightedRecord.weightOf);
    defer allocator.free(weighted_by_batch);
    try stdout.print("weighted by value batch: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ weighted_by_batch[0].?.label, weighted_by_batch[1].?.label, weighted_by_batch[2].?.label, weighted_by_batch[3].?.label, weighted_by_batch[4].?.label, weighted_by_batch[5].?.label });

    var weighted_by_ptr_batch_engine = alea.ScalarPrng.init(0x7198);
    const weighted_by_ptr_batch = try alea.seq.chooseWeightedConstPtrBatchByFrom(allocator, &weighted_by_ptr_batch_engine, WeightedRecord, u32, 6, &weighted_records, WeightedRecord.weightOf);
    defer allocator.free(weighted_by_ptr_batch);
    try stdout.print("weighted by const ptr batch: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ weighted_by_ptr_batch[0].?.label, weighted_by_ptr_batch[1].?.label, weighted_by_ptr_batch[2].?.label, weighted_by_ptr_batch[3].?.label, weighted_by_ptr_batch[4].?.label, weighted_by_ptr_batch[5].?.label });

    var weighted_by_mut_batch_records = weighted_records;
    var weighted_by_mut_batch_engine = alea.ScalarPrng.init(0x7199);
    const weighted_by_mut_batch = try alea.seq.chooseWeightedPtrBatchByFrom(allocator, &weighted_by_mut_batch_engine, WeightedRecord, u32, 6, &weighted_by_mut_batch_records, WeightedRecord.weightOf);
    defer allocator.free(weighted_by_mut_batch);
    for (weighted_by_mut_batch) |record| record.?.score += 1;
    try stdout.print("weighted by mut ptr batch scores: [{}, {}, {}, {}]\n", .{ weighted_by_mut_batch_records[0].score, weighted_by_mut_batch_records[1].score, weighted_by_mut_batch_records[2].score, weighted_by_mut_batch_records[3].score });

    var alias = try alea.distributions.AliasTable(f64).init(allocator, &float_weights);
    defer alias.deinit();
    var alias_probs: [items.len]f64 = undefined;
    try alias.probabilitiesInto(&alias_probs);
    var alias_engine = alea.ScalarPrng.init(0x7152);
    var alias_samples: [8]usize = undefined;
    alias.fillFrom(&alias_engine, &alias_samples);
    var alias_u32_engine = alea.ScalarPrng.init(0x71bc);
    var alias_u32_samples: [8]u32 = undefined;
    try alias.fillU32CheckedFrom(&alias_u32_engine, &alias_u32_samples);
    var alias_owned_engine = alea.ScalarPrng.init(0x71bd);
    const alias_owned_u32 = try alias.indicesU32From(allocator, &alias_owned_engine, 6);
    defer allocator.free(alias_owned_u32);
    var alias_alias_engine = alea.ScalarPrng.init(0x71be);
    const alias_alias_index = alias.sampleIndexFrom(&alias_alias_engine);
    var alias_iter_engine = alea.ScalarPrng.init(0x71bf);
    var alias_iter = alias.iterU32From(&alias_iter_engine);
    var alias_iter_u32: [6]u32 = undefined;
    alias_iter.fill(&alias_iter_u32);
    var alias_array_engine = alea.ScalarPrng.init(0x71c2);
    const alias_array_u32 = try alias.indexArrayU32CheckedFrom(&alias_array_engine, 4);
    var alias_by_index = try alea.distributions.AliasTable(u32).initByIndex(allocator, items.len, indexWeight);
    defer alias_by_index.deinit();
    try alias_by_index.updateByIndex(indexWeight);
    var alias_by_index_engine = alea.ScalarPrng.init(0x71c0);
    var alias_by_index_samples: [6]usize = undefined;
    alias_by_index.fillFrom(&alias_by_index_engine, &alias_by_index_samples);
    var alias_by_item = try alea.distributions.AliasTable(u32).initBy(allocator, WeightedRecord, &weighted_records, WeightedRecord.weightOf);
    defer alias_by_item.deinit();
    try alias_by_item.updateBy(WeightedRecord, &weighted_records, WeightedRecord.refreshedWeightOf);
    var alias_by_item_engine = alea.ScalarPrng.init(0x71c1);
    var alias_by_item_samples: [6]usize = undefined;
    alias_by_item.fillFrom(&alias_by_item_engine, &alias_by_item_samples);
    try stdout.print("alias probabilities: {any}\n", .{alias_probs});
    try stdout.print("alias sample indices: {any}\n", .{alias_samples});
    try stdout.print("alias u32 sample indices: {any}\n", .{alias_u32_samples});
    try stdout.print("alias owned u32 indices: {any}\n", .{alias_owned_u32});
    try stdout.print("alias sampleIndex alias: {}\n", .{alias_alias_index});
    try stdout.print("alias u32 iterator fill: {any}\n", .{alias_iter_u32});
    try stdout.print("alias u32 index array: {any}\n", .{alias_array_u32});
    try stdout.print("alias initByIndex/updateByIndex indices: {any}\n", .{alias_by_index_samples});
    try stdout.print("alias initBy/updateBy labels: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ weighted_records[alias_by_item_samples[0]].label, weighted_records[alias_by_item_samples[1]].label, weighted_records[alias_by_item_samples[2]].label, weighted_records[alias_by_item_samples[3]].label, weighted_records[alias_by_item_samples[4]].label, weighted_records[alias_by_item_samples[5]].label });

    var tree = try alea.distributions.WeightedTree(f64).init(allocator, &float_weights);
    defer tree.deinit();
    try tree.update(1, 8);
    try tree.push(4);
    var tree_probs: [items.len + 1]f64 = undefined;
    try tree.probabilitiesInto(&tree_probs);
    var tree_engine = alea.ScalarPrng.init(0x7153);
    var tree_samples: [8]usize = undefined;
    tree.fillFrom(&tree_engine, &tree_samples);
    var tree_u32_engine = alea.ScalarPrng.init(0x71b4);
    const tree_sample_u32 = try tree.sampleU32CheckedFrom(&tree_u32_engine);
    var tree_owned_engine = alea.ScalarPrng.init(0x71b6);
    const tree_owned_indices = try tree.indicesCheckedFrom(allocator, &tree_owned_engine, 6);
    defer allocator.free(tree_owned_indices);
    var tree_array_engine = alea.ScalarPrng.init(0x71c3);
    const tree_array_u32 = try tree.indexArrayU32CheckedFrom(&tree_array_engine, 4);
    try stdout.print("dynamic tree probabilities after update/push: {any}\n", .{tree_probs});
    try stdout.print("dynamic tree sample indices: {any}\n", .{tree_samples});
    try stdout.print("dynamic tree sample u32 index: {}\n", .{tree_sample_u32});
    try stdout.print("dynamic tree owned indices: {any}\n", .{tree_owned_indices});
    try stdout.print("dynamic tree u32 index array: {any}\n", .{tree_array_u32});
    var tree_alias_engine = alea.ScalarPrng.init(0x71b8);
    const tree_alias_index = try tree.sampleIndexCheckedFrom(&tree_alias_engine);
    try stdout.print("dynamic tree sampleIndex alias: {}\n", .{tree_alias_index});
    var tree_iter_engine = alea.ScalarPrng.init(0x71ba);
    var tree_iter = tree.iterFrom(&tree_iter_engine);
    try stdout.print("dynamic tree iterator next: {}\n", .{tree_iter.next().?});

    var int_tree = try alea.distributions.WeightedIntTree(u32).init(allocator, &int_weights);
    defer int_tree.deinit();
    try int_tree.update(2, 10);
    var int_tree_engine = alea.ScalarPrng.init(0x7154);
    var int_tree_samples: [8]usize = undefined;
    int_tree.fillFrom(&int_tree_engine, &int_tree_samples);
    var int_tree_u32_engine = alea.ScalarPrng.init(0x71b5);
    var int_tree_u32_samples: [8]u32 = undefined;
    int_tree.fillU32From(&int_tree_u32_engine, &int_tree_u32_samples);
    var int_tree_owned_u32_engine = alea.ScalarPrng.init(0x71b7);
    const int_tree_owned_u32 = try int_tree.indicesU32CheckedFrom(allocator, &int_tree_owned_u32_engine, 6);
    defer allocator.free(int_tree_owned_u32);
    var int_tree_array_engine = alea.ScalarPrng.init(0x71c4);
    const int_tree_array_u32 = try int_tree.indexArrayU32CheckedFrom(&int_tree_array_engine, 4);
    try stdout.print("integer tree total weight: {}\n", .{int_tree.totalWeight()});
    try stdout.print("integer tree sample indices: {any}\n", .{int_tree_samples});
    try stdout.print("integer tree u32 sample indices: {any}\n", .{int_tree_u32_samples});
    try stdout.print("integer tree owned u32 indices: {any}\n", .{int_tree_owned_u32});
    try stdout.print("integer tree u32 index array: {any}\n", .{int_tree_array_u32});
    var int_tree_alias_engine = alea.ScalarPrng.init(0x71b9);
    var int_tree_alias_fill: [6]usize = undefined;
    try int_tree.fillIndicesCheckedFrom(&int_tree_alias_engine, &int_tree_alias_fill);
    try stdout.print("integer tree fillIndices alias: {any}\n", .{int_tree_alias_fill});
    var int_tree_iter_engine = alea.ScalarPrng.init(0x71bb);
    var int_tree_iter = int_tree.iterU32From(&int_tree_iter_engine);
    var int_tree_iter_u32: [6]u32 = undefined;
    int_tree_iter.fill(&int_tree_iter_u32);
    try stdout.print("integer tree u32 iterator fill: {any}\n", .{int_tree_iter_u32});

    var index_tree = try alea.distributions.WeightedTree(u32).initByIndex(allocator, items.len, indexWeight);
    defer index_tree.deinit();
    try index_tree.updateAllByIndex(indexWeight);
    var index_tree_engine = alea.ScalarPrng.init(0x71b0);
    var index_tree_samples: [6]usize = undefined;
    index_tree.fillFrom(&index_tree_engine, &index_tree_samples);
    try stdout.print("index-weighted tree sample indices: {any}\n", .{index_tree_samples});

    var index_int_tree = try alea.distributions.WeightedIntTree(u32).initByIndex(allocator, items.len, indexWeight);
    defer index_int_tree.deinit();
    try index_int_tree.updateAllByIndex(indexWeight);
    var index_int_tree_engine = alea.ScalarPrng.init(0x71b1);
    var index_int_tree_samples: [6]usize = undefined;
    index_int_tree.fillFrom(&index_int_tree_engine, &index_int_tree_samples);
    try stdout.print("index-weighted int tree sample indices: {any}\n", .{index_int_tree_samples});

    var item_tree = try alea.distributions.WeightedTree(u32).initBy(allocator, WeightedRecord, &weighted_records, WeightedRecord.weightOf);
    defer item_tree.deinit();
    try item_tree.updateAllBy(WeightedRecord, &weighted_records, WeightedRecord.refreshedWeightOf);
    var item_tree_engine = alea.ScalarPrng.init(0x71b2);
    var item_tree_samples: [6]usize = undefined;
    item_tree.fillFrom(&item_tree_engine, &item_tree_samples);
    try stdout.print("item-weighted tree sample labels: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ weighted_records[item_tree_samples[0]].label, weighted_records[item_tree_samples[1]].label, weighted_records[item_tree_samples[2]].label, weighted_records[item_tree_samples[3]].label, weighted_records[item_tree_samples[4]].label, weighted_records[item_tree_samples[5]].label });

    var item_int_tree = try alea.distributions.WeightedIntTree(u32).initBy(allocator, WeightedRecord, &weighted_records, WeightedRecord.weightOf);
    defer item_int_tree.deinit();
    try item_int_tree.updateAllBy(WeightedRecord, &weighted_records, WeightedRecord.refreshedWeightOf);
    var item_int_tree_engine = alea.ScalarPrng.init(0x71b3);
    var item_int_tree_samples: [6]usize = undefined;
    item_int_tree.fillFrom(&item_int_tree_engine, &item_int_tree_samples);
    try stdout.print("item-weighted int tree sample labels: [{s}, {s}, {s}, {s}, {s}, {s}]\n", .{ weighted_records[item_int_tree_samples[0]].label, weighted_records[item_int_tree_samples[1]].label, weighted_records[item_int_tree_samples[2]].label, weighted_records[item_int_tree_samples[3]].label, weighted_records[item_int_tree_samples[4]].label, weighted_records[item_int_tree_samples[5]].label });

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
    const choice_index_array = choice.indexArrayFrom(&choice_engine, 6);
    try stdout.print("WeightedChoice.indexArrayFrom: {any}\n", .{choice_index_array});
    const choice_index_array_u32 = try choice.indexArrayU32From(&choice_engine, 6);
    try stdout.print("WeightedChoice.indexArrayU32From: {any}\n", .{choice_index_array_u32});
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

    var choice_by = try alea.seq.WeightedChoice(WeightedRecord, u32).initBy(allocator, &weighted_records, WeightedRecord.weightOf);
    defer choice_by.deinit();
    var choice_by_engine = alea.ScalarPrng.init(0x7186);
    const choice_by_sample = choice_by.sampleFrom(&choice_by_engine);
    try stdout.print("WeightedChoice.initBy sample: {s}\n", .{choice_by_sample.label});
    try choice_by.updateBy(WeightedRecord.weightOf);
    var choice_by_indices: [4]usize = undefined;
    choice_by.fillIndicesFrom(&choice_by_engine, &choice_by_indices);
    try stdout.print("WeightedChoice.updateBy indices: {any}\n", .{choice_by_indices});

    var choice_by_index = try alea.seq.WeightedChoice([]const u8, u32).initByIndex(allocator, &items, indexWeight);
    defer choice_by_index.deinit();
    var choice_by_index_engine = alea.ScalarPrng.init(0x71af);
    const choice_by_index_sample = choice_by_index.sampleFrom(&choice_by_index_engine);
    try stdout.print("WeightedChoice.initByIndex sample: {s}\n", .{choice_by_index_sample.*});
    try choice_by_index.updateByIndex(indexWeight);
    var choice_by_index_values: [4][]const u8 = undefined;
    choice_by_index.fillValuesFrom(&choice_by_index_engine, &choice_by_index_values);
    try printStringSlice(stdout, "WeightedChoice.updateByIndex values", &choice_by_index_values);

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

    var no_replace_by_indices_engine = alea.ScalarPrng.init(0x717e);
    const no_replace_by_indices = try alea.seq.sampleWeightedIndicesByFrom(allocator, &no_replace_by_indices_engine, WeightedRecord, u32, &weighted_records, 3, WeightedRecord.weightOf);
    defer allocator.free(no_replace_by_indices);
    try stdout.print("weighted by no-replacement indices: {any}\n", .{no_replace_by_indices});

    var no_replace_by_u32_indices_engine = alea.ScalarPrng.init(0x717f);
    const no_replace_by_u32_indices = try alea.seq.sampleWeightedIndicesU32ByFrom(allocator, &no_replace_by_u32_indices_engine, WeightedRecord, u32, &weighted_records, 3, WeightedRecord.weightOf);
    defer allocator.free(no_replace_by_u32_indices);
    try stdout.print("weighted by u32 no-replacement indices: {any}\n", .{no_replace_by_u32_indices});

    var no_replace_by_index_vec_engine = alea.ScalarPrng.init(0x7180);
    const no_replace_by_index_vec = try alea.seq.sampleWeightedIndexVecByFrom(allocator, &no_replace_by_index_vec_engine, WeightedRecord, u32, &weighted_records, 3, WeightedRecord.weightOf);
    defer no_replace_by_index_vec.deinit(allocator);
    try stdout.print("weighted by IndexVec: [", .{});
    var no_replace_by_index_vec_iter = no_replace_by_index_vec.iter();
    var first_by_index = true;
    while (no_replace_by_index_vec_iter.next()) |index| {
        if (!first_by_index) try stdout.print(", ", .{});
        first_by_index = false;
        try stdout.print("{}", .{index});
    }
    try stdout.print("]\n", .{});

    var no_replace_by_index_weight_engine = alea.ScalarPrng.init(0x718d);
    const no_replace_by_index_weight = try alea.seq.sampleWeightedIndicesByIndexFrom(allocator, &no_replace_by_index_weight_engine, u32, items.len, 3, indexWeight);
    defer allocator.free(no_replace_by_index_weight);
    try stdout.print("weighted index-weight indices: {any}\n", .{no_replace_by_index_weight});

    var no_replace_by_index_weight_u32_engine = alea.ScalarPrng.init(0x718e);
    const no_replace_by_index_weight_u32 = try alea.seq.sampleWeightedIndicesU32ByIndexFrom(allocator, &no_replace_by_index_weight_u32_engine, u32, items.len, 3, indexWeight);
    defer allocator.free(no_replace_by_index_weight_u32);
    try stdout.print("weighted index-weight u32 indices: {any}\n", .{no_replace_by_index_weight_u32});

    var no_replace_by_index_weight_vec_engine = alea.ScalarPrng.init(0x718f);
    const no_replace_by_index_weight_vec = try alea.seq.sampleWeightedIndexVecByIndexFrom(allocator, &no_replace_by_index_weight_vec_engine, u32, items.len, 3, indexWeight);
    defer no_replace_by_index_weight_vec.deinit(allocator);
    try stdout.print("weighted index-weight IndexVec: [", .{});
    var no_replace_by_index_weight_vec_iter = no_replace_by_index_weight_vec.iter();
    var first_index_weight = true;
    while (no_replace_by_index_weight_vec_iter.next()) |index| {
        if (!first_index_weight) try stdout.print(", ", .{});
        first_index_weight = false;
        try stdout.print("{}", .{index});
    }
    try stdout.print("]\n", .{});

    var no_replace_by_index_weight_into_engine = alea.ScalarPrng.init(0x7190);
    var no_replace_by_index_weight_into: [3]usize = undefined;
    var no_replace_by_index_weight_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedIndicesByIndexIntoFrom(&no_replace_by_index_weight_into_engine, u32, items.len, &no_replace_by_index_weight_into, &no_replace_by_index_weight_keys, indexWeight);
    try stdout.print("weighted index-weight indices into: {any}\n", .{no_replace_by_index_weight_into});

    var no_replace_by_index_weight_u32_into_engine = alea.ScalarPrng.init(0x7191);
    var no_replace_by_index_weight_u32_into: [3]u32 = undefined;
    var no_replace_by_index_weight_u32_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedIndicesU32ByIndexIntoFrom(&no_replace_by_index_weight_u32_into_engine, u32, items.len, &no_replace_by_index_weight_u32_into, &no_replace_by_index_weight_u32_keys, indexWeight);
    try stdout.print("weighted index-weight u32 indices into: {any}\n", .{no_replace_by_index_weight_u32_into});

    var weighted_index_weight_array_engine = alea.ScalarPrng.init(0x7192);
    const weighted_index_weight_array = (try alea.seq.sampleWeightedIndexArrayByIndexFrom(&weighted_index_weight_array_engine, u32, 3, items.len, indexWeight)).?;
    try stdout.print("weighted index-weight index array: {any}\n", .{weighted_index_weight_array});

    var weighted_index_weight_u32_array_engine = alea.ScalarPrng.init(0x7193);
    const weighted_index_weight_u32_array = (try alea.seq.sampleWeightedIndexArrayU32ByIndexFrom(&weighted_index_weight_u32_array_engine, u32, 3, items.len, indexWeight)).?;
    try stdout.print("weighted index-weight u32 index array: {any}\n", .{weighted_index_weight_u32_array});

    var weighted_by_index_array_engine = alea.ScalarPrng.init(0x7181);
    const weighted_by_index_array = (try alea.seq.sampleWeightedIndexArrayByFrom(&weighted_by_index_array_engine, WeightedRecord, u32, 3, &weighted_records, WeightedRecord.weightOf)).?;
    try stdout.print("weighted by index array: {any}\n", .{weighted_by_index_array});

    var weighted_by_u32_index_array_engine = alea.ScalarPrng.init(0x7182);
    const weighted_by_u32_index_array = (try alea.seq.sampleWeightedIndexArrayU32ByFrom(&weighted_by_u32_index_array_engine, WeightedRecord, u32, 3, &weighted_records, WeightedRecord.weightOf)).?;
    try stdout.print("weighted by u32 index array: {any}\n", .{weighted_by_u32_index_array});

    var weighted_by_array_engine = alea.ScalarPrng.init(0x7183);
    const weighted_by_array = (try alea.seq.sampleWeightedArrayByFrom(&weighted_by_array_engine, WeightedRecord, u32, 3, &weighted_records, WeightedRecord.weightOf)).?;
    try stdout.print("weighted by array sample: [{s}, {s}, {s}]\n", .{ weighted_by_array[0].label, weighted_by_array[1].label, weighted_by_array[2].label });

    var weighted_by_ptr_array_engine = alea.ScalarPrng.init(0x7184);
    const weighted_by_ptr_array = (try alea.seq.sampleWeightedPtrArrayByFrom(&weighted_by_ptr_array_engine, WeightedRecord, u32, 3, &weighted_records, WeightedRecord.weightOf)).?;
    try stdout.print("weighted by ptr array: [{s}, {s}, {s}]\n", .{ weighted_by_ptr_array[0].label, weighted_by_ptr_array[1].label, weighted_by_ptr_array[2].label });

    var weighted_by_mut_array_records = weighted_records;
    var weighted_by_mut_array_engine = alea.ScalarPrng.init(0x7185);
    const weighted_by_mut_array = (try alea.seq.sampleWeightedMutPtrArrayByFrom(&weighted_by_mut_array_engine, WeightedRecord, u32, 3, &weighted_by_mut_array_records, WeightedRecord.weightOf)).?;
    for (weighted_by_mut_array) |record| record.score += 30;
    try stdout.print("weighted by mut ptr array scores: [{}, {}, {}, {}]\n", .{ weighted_by_mut_array_records[0].score, weighted_by_mut_array_records[1].score, weighted_by_mut_array_records[2].score, weighted_by_mut_array_records[3].score });

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

    var weighted_by_indices_into_engine = alea.ScalarPrng.init(0x717a);
    var weighted_by_indices_into: [3]usize = undefined;
    var weighted_by_indices_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedIndicesByIntoFrom(&weighted_by_indices_into_engine, WeightedRecord, u32, &weighted_records, &weighted_by_indices_into, &weighted_by_indices_keys, WeightedRecord.weightOf);
    try stdout.print("weighted by indices into: {any}\n", .{weighted_by_indices_into});

    var weighted_by_values_into_engine = alea.ScalarPrng.init(0x717b);
    var weighted_by_values_into: [3]WeightedRecord = undefined;
    var weighted_by_values_indices: [3]usize = undefined;
    var weighted_by_values_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedByIntoFrom(&weighted_by_values_into_engine, WeightedRecord, u32, &weighted_records, &weighted_by_values_into, &weighted_by_values_indices, &weighted_by_values_keys, WeightedRecord.weightOf);
    try stdout.print("weighted by values into: [{s}, {s}, {s}]\n", .{ weighted_by_values_into[0].label, weighted_by_values_into[1].label, weighted_by_values_into[2].label });

    var weighted_by_ptrs_into_engine = alea.ScalarPrng.init(0x717c);
    var weighted_by_ptrs_into: [3]*const WeightedRecord = undefined;
    var weighted_by_ptrs_indices: [3]usize = undefined;
    var weighted_by_ptrs_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedPtrsByIntoFrom(&weighted_by_ptrs_into_engine, WeightedRecord, u32, &weighted_records, &weighted_by_ptrs_into, &weighted_by_ptrs_indices, &weighted_by_ptrs_keys, WeightedRecord.weightOf);
    try stdout.print("weighted by ptrs into: [{s}, {s}, {s}]\n", .{ weighted_by_ptrs_into[0].label, weighted_by_ptrs_into[1].label, weighted_by_ptrs_into[2].label });

    var weighted_by_mut_ptrs_into_engine = alea.ScalarPrng.init(0x717d);
    var weighted_by_mut_records_into = weighted_records;
    var weighted_by_mut_ptrs_into: [3]*WeightedRecord = undefined;
    var weighted_by_mut_ptrs_indices: [3]usize = undefined;
    var weighted_by_mut_ptrs_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedMutPtrsByIntoFrom(&weighted_by_mut_ptrs_into_engine, WeightedRecord, u32, &weighted_by_mut_records_into, &weighted_by_mut_ptrs_into, &weighted_by_mut_ptrs_indices, &weighted_by_mut_ptrs_keys, WeightedRecord.weightOf);
    for (weighted_by_mut_ptrs_into) |record| record.score += 20;
    try stdout.print("weighted by mut ptrs into scores: [{}, {}, {}, {}]\n", .{ weighted_by_mut_records_into[0].score, weighted_by_mut_records_into[1].score, weighted_by_mut_records_into[2].score, weighted_by_mut_records_into[3].score });

    try stdout.print("\nUse weightedIndex or chooseWeighted for simple draws, weightedIndexByIndex/weightedIndexU32ByIndex plus fillWeightedIndexByIndex/fillWeightedIndexU32ByIndex, weightedIndexBatchByIndex/weightedIndexU32BatchByIndex, chooseWeightedByIndex/ConstPtrByIndex/PtrByIndex, fillChooseWeightedByIndex/ConstPtrByIndex/PtrByIndex, and chooseWeightedBatchByIndex/ConstPtrBatchByIndex/PtrBatchByIndex for length/index-weight accessors, weightedIndexBy/weightedIndexU32By plus fillWeightedIndexBy/fillWeightedIndexU32By and weightedIndexBatchBy/weightedIndexU32BatchBy when weights live inside item records, chooseWeightedBy/ConstPtrBy/PtrBy, fillChooseWeightedBy/ConstPtrBy/PtrBy, and chooseWeightedBatchBy/ConstPtrBatchBy/PtrBatchBy for accessor-weighted item choices, sampleWeightedBy/PtrsBy/MutPtrsBy for accessor-weighted no-replacement draws, sampleWeightedIndicesByIndex, sampleWeightedIndicesByIndexInto, and sampleWeightedIndexArrayByIndex for length/index-weight no-replacement workflows, Rng weighted batch helpers for repeated f64 index/value/const-pointer/mutable-pointer draws, AliasTable/WeightedChoice for repeated static weights including compact sampleU32/fillU32 index output, owned indices/indicesU32 or value/pointer/index batches, fixed-size indexArray/indexArrayU32 outputs, sampleIndex/fillIndices aliases, iter/iterU32 repeated streams, initBy/updateBy construction from item weight accessors, and initByIndex/updateByIndex construction from index weights, WeightedTree/WeightedIntTree for dynamic updates including initBy/updateAllBy construction from item weight accessors, initByIndex/updateAllByIndex construction from index weights, compact sampleU32/fillU32 index output, owned indices/indicesU32 batches, fixed-size indexArray/indexArrayU32 outputs, sampleIndex/fillIndices aliases, and iter/iterU32 repeated index streams, and seq weighted helpers for allocation-returning item/index/pointer no-replacement, caller-owned usize/u32 index/value/pointer/accessor-weighted buffers, and fixed-size value/pointer array workflows.\n", .{});
    try stdout.flush();
}
