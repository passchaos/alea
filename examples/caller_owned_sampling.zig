const std = @import("std");
const alea = @import("alea");

const Counter = struct {
    next_value: u32 = 0,
    limit: u32,

    pub fn next(self: *@This()) ?u32 {
        if (self.next_value >= self.limit) return null;
        const value = self.next_value;
        self.next_value += 1;
        return value;
    }
};

const WeightedEntry = struct {
    item: u32,
    weight: f64,
};

const WeightedCounter = struct {
    next_value: u32 = 0,
    limit: u32,

    pub fn next(self: *@This()) ?WeightedEntry {
        if (self.next_value >= self.limit) return null;
        const value = self.next_value;
        self.next_value += 1;
        return .{ .item = value, .weight = @floatFromInt(value + 1) };
    }
};

fn printStringArray(stdout: *std.Io.Writer, label: []const u8, values: []const []const u8) !void {
    try stdout.print("{s}: [", .{label});
    for (values, 0..) |value, i| {
        if (i != 0) try stdout.print(", ", .{});
        try stdout.print("{s}", .{value});
    }
    try stdout.print("]\n", .{});
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const items = [_][]const u8{ "ant", "bee", "cat", "dog", "eel", "fox", "gnu", "hen" };
    const weights = [_]f64{ 1, 2, 6, 3, 0, 4, 8, 5 };

    var index_engine = alea.ScalarPrng.init(0xc011_0001);
    var indices: [4]usize = undefined;
    try alea.seq.sampleIndicesIntoCheckedFrom(&index_engine, items.len, &indices);
    try stdout.print("indices into: {any}\n", .{indices});

    var index_u32_engine = alea.ScalarPrng.init(0xc011_0002);
    var indices_u32: [4]u32 = undefined;
    try alea.seq.sampleIndicesU32IntoCheckedFrom(&index_u32_engine, @intCast(items.len), &indices_u32);
    try stdout.print("u32 indices into: {any}\n", .{indices_u32});

    var chosen_engine = alea.ScalarPrng.init(0xc011_0003);
    var chosen: [3][]const u8 = undefined;
    var chosen_indices: [3]usize = undefined;
    _ = try alea.seq.chooseMultipleIntoFrom(&chosen_engine, []const u8, &items, &chosen, &chosen_indices);
    try printStringArray(stdout, "chooseMultipleInto", &chosen);

    var chosen_ptr_engine = alea.ScalarPrng.init(0xc011_0009);
    var chosen_ptrs: [3]*const []const u8 = undefined;
    var chosen_ptr_indices: [3]usize = undefined;
    _ = try alea.seq.chooseMultiplePtrsIntoFrom(&chosen_ptr_engine, []const u8, &items, &chosen_ptrs, &chosen_ptr_indices);
    try stdout.print("chooseMultiplePtrsInto: [{s}, {s}, {s}]\n", .{ chosen_ptrs[0].*, chosen_ptrs[1].*, chosen_ptrs[2].* });

    var reservoir_engine = alea.ScalarPrng.init(0xc011_0004);
    var reservoir: [4][]const u8 = undefined;
    try alea.seq.reservoirSampleIntoFrom(&reservoir_engine, []const u8, &items, &reservoir);
    try printStringArray(stdout, "reservoirSampleInto", &reservoir);

    var reservoir_ptr_engine = alea.ScalarPrng.init(0xc011_000a);
    var reservoir_ptrs: [4]*const []const u8 = undefined;
    try alea.seq.reservoirSamplePtrsIntoFrom(&reservoir_ptr_engine, []const u8, &items, &reservoir_ptrs);
    try stdout.print("reservoirSamplePtrsInto: [{s}, {s}, {s}, {s}]\n", .{ reservoir_ptrs[0].*, reservoir_ptrs[1].*, reservoir_ptrs[2].*, reservoir_ptrs[3].* });

    var iter_engine = alea.ScalarPrng.init(0xc011_0005);
    var iter = Counter{ .limit = 20 };
    var iter_sample: [5]u32 = undefined;
    _ = alea.seq.sampleIteratorIntoFrom(&iter_engine, u32, &iter, &iter_sample);
    try stdout.print("sampleIteratorInto: {any}\n", .{iter_sample});

    var weighted_index_engine = alea.ScalarPrng.init(0xc011_0006);
    var weighted_indices: [3]usize = undefined;
    var weighted_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedIndicesIntoFrom(&weighted_index_engine, f64, &weights, &weighted_indices, &weighted_keys);
    try stdout.print("weighted indices into: {any}\n", .{weighted_indices});

    var weighted_item_engine = alea.ScalarPrng.init(0xc011_0007);
    var weighted_items: [3][]const u8 = undefined;
    var weighted_item_indices: [3]usize = undefined;
    var weighted_item_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedIntoFrom(&weighted_item_engine, []const u8, f64, &items, &weights, &weighted_items, &weighted_item_indices, &weighted_item_keys);
    try printStringArray(stdout, "weighted values into", &weighted_items);

    var weighted_ptr_engine = alea.ScalarPrng.init(0xc011_000b);
    var weighted_ptrs: [3]*const []const u8 = undefined;
    var weighted_ptr_indices: [3]usize = undefined;
    var weighted_ptr_keys: [3]f64 = undefined;
    _ = try alea.seq.sampleWeightedPtrsIntoFrom(&weighted_ptr_engine, []const u8, f64, &items, &weights, &weighted_ptrs, &weighted_ptr_indices, &weighted_ptr_keys);
    try stdout.print("weighted ptrs into: [{s}, {s}, {s}]\n", .{ weighted_ptrs[0].*, weighted_ptrs[1].*, weighted_ptrs[2].* });

    var weighted_iter_engine = alea.ScalarPrng.init(0xc011_0008);
    var weighted_iter = WeightedCounter{ .limit = 20 };
    var weighted_iter_sample: [5]u32 = undefined;
    var weighted_iter_keys: [5]f64 = undefined;
    _ = try alea.seq.sampleIteratorWeightedIntoFrom(&weighted_iter_engine, u32, &weighted_iter, &weighted_iter_sample, &weighted_iter_keys);
    try stdout.print("sampleIteratorWeightedInto: {any}\n", .{weighted_iter_sample});

    try stdout.print("\nUse caller-owned buffers when you need predictable allocation behavior: index/item/pointer/iterator/weighted helpers validate sizes before drawing where their stream shape permits.\n", .{});
    try stdout.flush();
}
