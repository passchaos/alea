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

fn printIndexVec(stdout: *std.Io.Writer, index_vec: alea.seq.IndexVec) !void {
    try stdout.print("[", .{});
    var iter = index_vec.iter();
    var first = true;
    while (iter.next()) |index| {
        if (!first) try stdout.print(", ", .{});
        first = false;
        try stdout.print("{}", .{index});
    }
    try stdout.print("]", .{});
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const items = [_][]const u8{ "ant", "bee", "cat", "dog", "eel", "fox", "gnu", "hen" };

    var index_engine = alea.ScalarPrng.init(0x5e11_0001);
    const indices = try alea.seq.sampleIndicesFrom(allocator, &index_engine, items.len, 4);
    defer allocator.free(indices);
    try stdout.print("sampleIndices: {any}\n", .{indices});

    var indices_into_engine = alea.ScalarPrng.init(0x5e11_0010);
    var indices_into: [4]usize = undefined;
    try alea.seq.sampleIndicesIntoCheckedFrom(&indices_into_engine, items.len, &indices_into);
    try stdout.print("sampleIndicesInto: {any}\n", .{indices_into});

    var indices_u32_engine = alea.ScalarPrng.init(0x5e11_0013);
    var indices_u32_into: [4]u32 = undefined;
    try alea.seq.sampleIndicesU32IntoCheckedFrom(&indices_u32_engine, @intCast(items.len), &indices_u32_into);
    try stdout.print("sampleIndicesU32Into: {any}\n", .{indices_u32_into});

    var index_vec_engine = alea.ScalarPrng.init(0x5e11_0002);
    const index_vec = try alea.seq.sampleIndexVecFrom(allocator, &index_vec_engine, 10_000, 6);
    defer index_vec.deinit(allocator);
    try stdout.print("sampleIndexVec len={} values=", .{index_vec.len()});
    try printIndexVec(stdout, index_vec);
    try stdout.print("\n", .{});

    var item_index_engine = alea.ScalarPrng.init(0x5e11_0014);
    const item_index_vec = try alea.seq.sampleIndexVecFrom(allocator, &item_index_engine, items.len, 3);
    defer item_index_vec.deinit(allocator);
    var item_values = try item_index_vec.valuesChecked([]const u8, &items);
    const mapped0 = item_values.next().?;
    const mapped1 = item_values.next().?;
    const mapped2 = item_values.next().?;
    try stdout.print("IndexVec.values: {s}, {s}, {s}\n", .{ mapped0, mapped1, mapped2 });
    var mapped_into: [3][]const u8 = undefined;
    try item_index_vec.valuesIntoChecked([]const u8, &items, &mapped_into);
    try stdout.print("IndexVec.valuesInto: {s}, {s}, {s}\n", .{ mapped_into[0], mapped_into[1], mapped_into[2] });
    var mapped_ptrs: [3]*const []const u8 = undefined;
    try item_index_vec.ptrsIntoChecked([]const u8, &items, &mapped_ptrs);
    try stdout.print("IndexVec.ptrsInto: {s}, {s}, {s}\n", .{ mapped_ptrs[0].*, mapped_ptrs[1].*, mapped_ptrs[2].* });
    var mutable_scores = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };
    var mapped_mut_ptrs: [3]*u8 = undefined;
    try item_index_vec.mutPtrsIntoChecked(u8, &mutable_scores, &mapped_mut_ptrs);
    for (mapped_mut_ptrs) |score| score.* += 1;
    try stdout.print("IndexVec.mutPtrsInto updated scores: {any}\n", .{mutable_scores});

    var choose_engine = alea.ScalarPrng.init(0x5e11_0003);
    const chosen = try alea.seq.chooseMultipleFrom(allocator, &choose_engine, []const u8, &items, 3);
    defer allocator.free(chosen);
    try stdout.print("chooseMultiple items: {s}, {s}, {s}\n", .{ chosen[0], chosen[1], chosen[2] });

    var choose_into_engine = alea.ScalarPrng.init(0x5e11_0011);
    var chosen_into: [3][]const u8 = undefined;
    var chosen_into_indices: [3]usize = undefined;
    _ = try alea.seq.chooseMultipleIntoFrom(&choose_into_engine, []const u8, &items, &chosen_into, &chosen_into_indices);
    try stdout.print("chooseMultipleInto items: {s}, {s}, {s}\n", .{ chosen_into[0], chosen_into[1], chosen_into[2] });

    var choose_ptrs_engine = alea.ScalarPrng.init(0x5e11_0015);
    var chosen_ptrs: [3]*const []const u8 = undefined;
    var chosen_ptr_indices: [3]usize = undefined;
    _ = try alea.seq.chooseMultiplePtrsIntoFrom(&choose_ptrs_engine, []const u8, &items, &chosen_ptrs, &chosen_ptr_indices);
    try stdout.print("chooseMultiplePtrsInto items: {s}, {s}, {s}\n", .{ chosen_ptrs[0].*, chosen_ptrs[1].*, chosen_ptrs[2].* });

    var choose_mut_ptrs_engine = alea.ScalarPrng.init(0x5e11_0016);
    var mutable_subset_scores = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };
    var chosen_mut_ptrs: [3]*u8 = undefined;
    var chosen_mut_ptr_indices: [3]usize = undefined;
    _ = try alea.seq.chooseMultipleMutPtrsIntoFrom(&choose_mut_ptrs_engine, u8, &mutable_subset_scores, &chosen_mut_ptrs, &chosen_mut_ptr_indices);
    for (chosen_mut_ptrs) |score| score.* += 2;
    try stdout.print("chooseMultipleMutPtrsInto updated scores: {any}\n", .{mutable_subset_scores});

    var choose_array_engine = alea.ScalarPrng.init(0x5e11_000a);
    const chosen_array = alea.seq.chooseArrayFrom(&choose_array_engine, []const u8, 3, &items).?;
    try stdout.print("chooseArray items: {s}, {s}, {s}\n", .{ chosen_array[0], chosen_array[1], chosen_array[2] });

    var choose_ptr_array_engine = alea.ScalarPrng.init(0x5e11_0017);
    const chosen_ptr_array = alea.seq.choosePtrArrayFrom(&choose_ptr_array_engine, []const u8, 3, &items).?;
    try stdout.print("choosePtrArray items: {s}, {s}, {s}\n", .{ chosen_ptr_array[0].*, chosen_ptr_array[1].*, chosen_ptr_array[2].* });

    var choose_mut_ptr_array_engine = alea.ScalarPrng.init(0x5e11_0018);
    var mutable_array_scores = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };
    const chosen_mut_ptr_array = alea.seq.chooseMutPtrArrayFrom(&choose_mut_ptr_array_engine, u8, 3, &mutable_array_scores).?;
    for (chosen_mut_ptr_array) |score| score.* += 3;
    try stdout.print("chooseMutPtrArray updated scores: {any}\n", .{mutable_array_scores});

    var swr_engine = alea.ScalarPrng.init(0x5e11_0004);
    const sample = try alea.Rng.sampleWithoutReplacementFrom(&swr_engine, []const u8, allocator, &items, 3);
    defer allocator.free(sample);
    try stdout.print("Rng.sampleWithoutReplacementFrom: {s}, {s}, {s}\n", .{ sample[0], sample[1], sample[2] });

    var deck = items;
    var shuffle_engine = alea.ScalarPrng.init(0x5e11_0005);
    const hand = alea.seq.partialShuffleFrom(&shuffle_engine, []const u8, &deck, 3);
    try stdout.print("partialShuffle hand: {s}, {s}, {s}; deck head now: {s}, {s}, {s}\n", .{ hand[0], hand[1], hand[2], deck[0], deck[1], deck[2] });

    var split_deck = items;
    var split_engine = alea.ScalarPrng.init(0x5e11_0012);
    const split = alea.seq.partialShuffleSplitFrom(&split_engine, []const u8, &split_deck, 3);
    try stdout.print("partialShuffleSplit selected: {s}, {s}, {s}; rest-len={}\n", .{ split.selected[0], split.selected[1], split.selected[2], split.rest.len });

    var reservoir_engine = alea.ScalarPrng.init(0x5e11_0006);
    const reservoir = try alea.seq.reservoirSampleFrom(allocator, &reservoir_engine, []const u8, &items, 4);
    defer allocator.free(reservoir);
    try stdout.print("reservoirSample: {s}, {s}, {s}, {s}\n", .{ reservoir[0], reservoir[1], reservoir[2], reservoir[3] });

    var reservoir_into_engine = alea.ScalarPrng.init(0x5e11_000b);
    var reservoir_into: [4][]const u8 = undefined;
    try alea.seq.reservoirSampleIntoFrom(&reservoir_into_engine, []const u8, &items, &reservoir_into);
    try stdout.print("reservoirSampleInto: {s}, {s}, {s}, {s}\n", .{ reservoir_into[0], reservoir_into[1], reservoir_into[2], reservoir_into[3] });

    const choice = alea.seq.Choice([]const u8).init(&items).?;
    var choice_engine = alea.ScalarPrng.init(0x5e11_0007);
    var choice_values: [5][]const u8 = undefined;
    choice.fillValuesFrom(&choice_engine, &choice_values);
    try stdout.print("Choice.fillValuesFrom: {s}, {s}, {s}, {s}, {s}\n", .{ choice_values[0], choice_values[1], choice_values[2], choice_values[3], choice_values[4] });

    var iter_choice_engine = alea.ScalarPrng.init(0x5e11_0008);
    var stream = Counter{ .limit = 20 };
    const picked = alea.seq.chooseIteratorFrom(&iter_choice_engine, u32, &stream).?;
    try stdout.print("chooseIteratorFrom counter[0..20): {}\n", .{picked});

    var iter_array_engine = alea.ScalarPrng.init(0x5e11_000e);
    var array_stream = Counter{ .limit = 20 };
    const stream_array = alea.seq.sampleIteratorArrayFrom(&iter_array_engine, u32, 5, &array_stream).?;
    try stdout.print("sampleIteratorArrayFrom counter[0..20): {any}\n", .{stream_array});

    var iter_sample_engine = alea.ScalarPrng.init(0x5e11_0009);
    var sample_stream = Counter{ .limit = 20 };
    const stream_sample = try alea.seq.sampleIteratorFrom(allocator, &iter_sample_engine, u32, &sample_stream, 5);
    defer allocator.free(stream_sample);
    try stdout.print("sampleIteratorFrom counter[0..20): {any}\n", .{stream_sample});

    var iter_into_engine = alea.ScalarPrng.init(0x5e11_000c);
    var into_stream = Counter{ .limit = 20 };
    var stream_into: [5]u32 = undefined;
    _ = alea.seq.sampleIteratorIntoFrom(&iter_into_engine, u32, &into_stream, &stream_into);
    try stdout.print("sampleIteratorIntoFrom counter[0..20): {any}\n", .{stream_into});

    const WeightedEntry = struct { item: u32, weight: f64 };
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
    var weighted_iter_engine = alea.ScalarPrng.init(0x5e11_000d);
    var weighted_stream = WeightedCounter{ .limit = 20 };
    const weighted_stream_array = (try alea.seq.sampleIteratorWeightedArrayFrom(&weighted_iter_engine, u32, 5, &weighted_stream)).?;
    try stdout.print("sampleIteratorWeightedArrayFrom counter[0..20): {any}\n", .{weighted_stream_array});

    var weighted_into_engine = alea.ScalarPrng.init(0x5e11_000f);
    var weighted_into_stream = WeightedCounter{ .limit = 20 };
    var weighted_stream_into: [5]u32 = undefined;
    var weighted_stream_keys: [5]f64 = undefined;
    _ = try alea.seq.sampleIteratorWeightedIntoFrom(&weighted_into_engine, u32, &weighted_into_stream, &weighted_stream_into, &weighted_stream_keys);
    try stdout.print("sampleIteratorWeightedIntoFrom counter[0..20): {any}\n", .{weighted_stream_into});

    try stdout.print("\nUse sampleIndices/sampleIndicesInto/IndexVec for indexes and value/const-pointer/mutable-pointer mapping, chooseArray/choosePtrArray for fixed-size arrays, chooseMultiple/chooseMultipleInto/chooseMultiplePtrsInto or sampleWithoutReplacement for item/pointer subsets, partialShuffle/partialShuffleSplit for in-place heads/rests, reservoirSample/reservoirSampleInto for slices, sampleIteratorArray/sampleIterator/sampleIteratorInto for streams, weighted iterator arrays/into buffers, and Choice/iterator helpers for reusable or streaming choices.\n", .{});
    try stdout.flush();
}
