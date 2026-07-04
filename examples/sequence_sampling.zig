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

    var index_array_u32_engine = alea.ScalarPrng.init(0x5e11_001f);
    const index_array_u32 = try alea.seq.sampleArrayU32CheckedFrom(&index_array_u32_engine, 4, @intCast(items.len));
    try stdout.print("sampleArrayU32: {any}\n", .{index_array_u32});

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
    const mapped_owned = try item_index_vec.valuesOwnedChecked(allocator, []const u8, &items);
    defer allocator.free(mapped_owned);
    try stdout.print("IndexVec.valuesOwned: {s}, {s}, {s}\n", .{ mapped_owned[0], mapped_owned[1], mapped_owned[2] });
    var compact_index_copy: [3]u32 = undefined;
    try item_index_vec.copyIntoU32(&compact_index_copy);
    try stdout.print("IndexVec.copyIntoU32: {any}\n", .{compact_index_copy});
    const compact_owned_copy = try item_index_vec.toOwnedU32Slice(allocator);
    defer allocator.free(compact_owned_copy);
    try stdout.print("IndexVec.toOwnedU32Slice: {any}\n", .{compact_owned_copy});
    var mapped_ptrs: [3]*const []const u8 = undefined;
    try item_index_vec.ptrsIntoChecked([]const u8, &items, &mapped_ptrs);
    try stdout.print("IndexVec.ptrsInto: {s}, {s}, {s}\n", .{ mapped_ptrs[0].*, mapped_ptrs[1].*, mapped_ptrs[2].* });
    const mapped_owned_ptrs = try item_index_vec.ptrsOwnedChecked(allocator, []const u8, &items);
    defer allocator.free(mapped_owned_ptrs);
    try stdout.print("IndexVec.ptrsOwned: {s}, {s}, {s}\n", .{ mapped_owned_ptrs[0].*, mapped_owned_ptrs[1].*, mapped_owned_ptrs[2].* });
    var mutable_scores = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };
    var mapped_mut_ptrs: [3]*u8 = undefined;
    try item_index_vec.mutPtrsIntoChecked(u8, &mutable_scores, &mapped_mut_ptrs);
    for (mapped_mut_ptrs) |score| score.* += 1;
    const mapped_owned_mut_ptrs = try item_index_vec.mutPtrsOwnedChecked(allocator, u8, &mutable_scores);
    defer allocator.free(mapped_owned_mut_ptrs);
    for (mapped_owned_mut_ptrs) |score| score.* += 1;
    try stdout.print("IndexVec.mutPtrsOwned updated scores: {any}\n", .{mutable_scores});

    var choose_engine = alea.ScalarPrng.init(0x5e11_0003);
    const chosen = try alea.seq.chooseMultipleFrom(allocator, &choose_engine, []const u8, &items, 3);
    defer allocator.free(chosen);
    try stdout.print("chooseMultiple items: {s}, {s}, {s}\n", .{ chosen[0], chosen[1], chosen[2] });

    var sample_items_engine = alea.ScalarPrng.init(0x5e11_001b);
    const sampled_items = try alea.seq.sampleItemsFrom(allocator, &sample_items_engine, []const u8, &items, 3);
    defer allocator.free(sampled_items);
    try stdout.print("sampleItemsFrom items: {s}, {s}, {s}\n", .{ sampled_items[0], sampled_items[1], sampled_items[2] });

    var choose_into_engine = alea.ScalarPrng.init(0x5e11_0011);
    var chosen_into: [3][]const u8 = undefined;
    var chosen_into_indices: [3]usize = undefined;
    _ = try alea.seq.chooseMultipleIntoFrom(&choose_into_engine, []const u8, &items, &chosen_into, &chosen_into_indices);
    try stdout.print("chooseMultipleInto items: {s}, {s}, {s}\n", .{ chosen_into[0], chosen_into[1], chosen_into[2] });

    var sample_items_into_engine = alea.ScalarPrng.init(0x5e11_001c);
    var sampled_items_into: [3][]const u8 = undefined;
    var sampled_items_into_indices: [3]usize = undefined;
    _ = try alea.seq.sampleItemsIntoFrom(&sample_items_into_engine, []const u8, &items, &sampled_items_into, &sampled_items_into_indices);
    try stdout.print("sampleItemsIntoFrom items: {s}, {s}, {s}\n", .{ sampled_items_into[0], sampled_items_into[1], sampled_items_into[2] });

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

    var choose_ptrs_alloc_engine = alea.ScalarPrng.init(0x5e11_0019);
    const chosen_ptrs_alloc = try alea.seq.chooseMultiplePtrsFrom(allocator, &choose_ptrs_alloc_engine, []const u8, &items, 3);
    defer allocator.free(chosen_ptrs_alloc);
    try stdout.print("chooseMultiplePtrs items: {s}, {s}, {s}\n", .{ chosen_ptrs_alloc[0].*, chosen_ptrs_alloc[1].*, chosen_ptrs_alloc[2].* });

    var choose_mut_ptrs_alloc_engine = alea.ScalarPrng.init(0x5e11_001a);
    var mutable_alloc_scores = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };
    const chosen_mut_ptrs_alloc = try alea.seq.chooseMultipleMutPtrsFrom(allocator, &choose_mut_ptrs_alloc_engine, u8, &mutable_alloc_scores, 3);
    defer allocator.free(chosen_mut_ptrs_alloc);
    for (chosen_mut_ptrs_alloc) |score| score.* += 6;
    try stdout.print("chooseMultipleMutPtrs updated scores: {any}\n", .{mutable_alloc_scores});

    var choose_array_engine = alea.ScalarPrng.init(0x5e11_000a);
    const chosen_array = alea.seq.chooseArrayFrom(&choose_array_engine, []const u8, 3, &items).?;
    try stdout.print("chooseArray items: {s}, {s}, {s}\n", .{ chosen_array[0], chosen_array[1], chosen_array[2] });

    var sample_items_array_engine = alea.ScalarPrng.init(0x5e11_001d);
    const sampled_items_array = alea.seq.sampleItemsArrayFrom(&sample_items_array_engine, []const u8, 3, &items).?;
    try stdout.print("sampleItemsArrayFrom items: {s}, {s}, {s}\n", .{ sampled_items_array[0], sampled_items_array[1], sampled_items_array[2] });

    var choose_ptr_array_engine = alea.ScalarPrng.init(0x5e11_0017);
    const chosen_ptr_array = alea.seq.choosePtrArrayFrom(&choose_ptr_array_engine, []const u8, 3, &items).?;
    try stdout.print("choosePtrArray items: {s}, {s}, {s}\n", .{ chosen_ptr_array[0].*, chosen_ptr_array[1].*, chosen_ptr_array[2].* });

    var sample_ptr_array_engine = alea.ScalarPrng.init(0x5e11_001e);
    const sampled_ptr_array = alea.seq.samplePtrArrayFrom(&sample_ptr_array_engine, []const u8, 3, &items).?;
    try stdout.print("samplePtrArrayFrom items: {s}, {s}, {s}\n", .{ sampled_ptr_array[0].*, sampled_ptr_array[1].*, sampled_ptr_array[2].* });

    var choose_mut_ptr_array_engine = alea.ScalarPrng.init(0x5e11_0018);
    var mutable_array_scores = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };
    const chosen_mut_ptr_array = alea.seq.chooseMutPtrArrayFrom(&choose_mut_ptr_array_engine, u8, 3, &mutable_array_scores).?;
    for (chosen_mut_ptr_array) |score| score.* += 3;
    try stdout.print("chooseMutPtrArray updated scores: {any}\n", .{mutable_array_scores});

    var sample_mut_ptr_array_engine = alea.ScalarPrng.init(0x5e11_001f);
    var mutable_sample_array_scores = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };
    const sampled_mut_ptr_array = alea.seq.sampleMutPtrArrayFrom(&sample_mut_ptr_array_engine, u8, 3, &mutable_sample_array_scores).?;
    for (sampled_mut_ptr_array) |score| score.* += 4;
    try stdout.print("sampleMutPtrArrayFrom updated scores: {any}\n", .{mutable_sample_array_scores});

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

    var reservoir_ptrs_engine = alea.ScalarPrng.init(0x5e11_001b);
    const reservoir_ptrs = try alea.seq.reservoirSamplePtrsFrom(allocator, &reservoir_ptrs_engine, []const u8, &items, 4);
    defer allocator.free(reservoir_ptrs);
    try stdout.print("reservoirSamplePtrs: {s}, {s}, {s}, {s}\n", .{ reservoir_ptrs[0].*, reservoir_ptrs[1].*, reservoir_ptrs[2].*, reservoir_ptrs[3].* });

    var reservoir_mut_ptrs_engine = alea.ScalarPrng.init(0x5e11_001c);
    var mutable_reservoir_scores = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };
    const reservoir_mut_ptrs = try alea.seq.reservoirSampleMutPtrsFrom(allocator, &reservoir_mut_ptrs_engine, u8, &mutable_reservoir_scores, 4);
    defer allocator.free(reservoir_mut_ptrs);
    for (reservoir_mut_ptrs) |score| score.* += 8;
    try stdout.print("reservoirSampleMutPtrs updated scores: {any}\n", .{mutable_reservoir_scores});

    var reservoir_into_engine = alea.ScalarPrng.init(0x5e11_000b);
    var reservoir_into: [4][]const u8 = undefined;
    try alea.seq.reservoirSampleIntoFrom(&reservoir_into_engine, []const u8, &items, &reservoir_into);
    try stdout.print("reservoirSampleInto: {s}, {s}, {s}, {s}\n", .{ reservoir_into[0], reservoir_into[1], reservoir_into[2], reservoir_into[3] });

    var reservoir_ptrs_into_engine = alea.ScalarPrng.init(0x5e11_001d);
    var reservoir_ptrs_into: [4]*const []const u8 = undefined;
    try alea.seq.reservoirSamplePtrsIntoFrom(&reservoir_ptrs_into_engine, []const u8, &items, &reservoir_ptrs_into);
    try stdout.print("reservoirSamplePtrsInto: {s}, {s}, {s}, {s}\n", .{ reservoir_ptrs_into[0].*, reservoir_ptrs_into[1].*, reservoir_ptrs_into[2].*, reservoir_ptrs_into[3].* });

    var reservoir_mut_ptrs_into_engine = alea.ScalarPrng.init(0x5e11_001e);
    var mutable_reservoir_into_scores = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };
    var reservoir_mut_ptrs_into: [4]*u8 = undefined;
    try alea.seq.reservoirSampleMutPtrsIntoFrom(&reservoir_mut_ptrs_into_engine, u8, &mutable_reservoir_into_scores, &reservoir_mut_ptrs_into);
    for (reservoir_mut_ptrs_into) |score| score.* += 9;
    try stdout.print("reservoirSampleMutPtrsInto updated scores: {any}\n", .{mutable_reservoir_into_scores});

    const choice = alea.seq.Choice([]const u8).init(&items).?;
    var choice_engine = alea.ScalarPrng.init(0x5e11_0007);
    const choice_index = choice.sampleIndexFrom(&choice_engine);
    try stdout.print("Choice.sampleIndexFrom: {}\n", .{choice_index});
    var choice_values: [5][]const u8 = undefined;
    choice.fillValuesFrom(&choice_engine, &choice_values);
    try stdout.print("Choice.fillValuesFrom: {s}, {s}, {s}, {s}, {s}\n", .{ choice_values[0], choice_values[1], choice_values[2], choice_values[3], choice_values[4] });
    var choice_indices: [5]usize = undefined;
    choice.fillIndicesFrom(&choice_engine, &choice_indices);
    try stdout.print("Choice.fillIndicesFrom: {any}\n", .{choice_indices});
    var choice_indices_u32: [5]u32 = undefined;
    try choice.fillIndicesU32From(&choice_engine, &choice_indices_u32);
    try stdout.print("Choice.fillIndicesU32From: {any}\n", .{choice_indices_u32});
    const choice_owned_indices = try choice.indicesFrom(allocator, &choice_engine, 5);
    defer allocator.free(choice_owned_indices);
    try stdout.print("Choice.indicesFrom: {any}\n", .{choice_owned_indices});
    const choice_owned_indices_u32 = try choice.indicesU32From(allocator, &choice_engine, 5);
    defer allocator.free(choice_owned_indices_u32);
    try stdout.print("Choice.indicesU32From: {any}\n", .{choice_owned_indices_u32});
    const choice_owned_values = try choice.valuesFrom(allocator, &choice_engine, 5);
    defer allocator.free(choice_owned_values);
    try stdout.print("Choice.valuesFrom: {s}, {s}, {s}, {s}, {s}\n", .{ choice_owned_values[0], choice_owned_values[1], choice_owned_values[2], choice_owned_values[3], choice_owned_values[4] });
    const choice_owned_ptrs = try choice.ptrsFrom(allocator, &choice_engine, 5);
    defer allocator.free(choice_owned_ptrs);
    try stdout.print("Choice.ptrsFrom: {s}, {s}, {s}, {s}, {s}\n", .{ choice_owned_ptrs[0].*, choice_owned_ptrs[1].*, choice_owned_ptrs[2].*, choice_owned_ptrs[3].*, choice_owned_ptrs[4].* });

    var iter_choice_engine = alea.ScalarPrng.init(0x5e11_0008);
    var stream = Counter{ .limit = 20 };
    const picked = alea.seq.chooseIteratorFrom(&iter_choice_engine, u32, &stream).?;
    try stdout.print("chooseIteratorFrom counter[0..20): {}\n", .{picked});

    var stable_choice_engine = alea.ScalarPrng.init(0x5e11_0017);
    var stable_stream = Counter{ .limit = 20 };
    const stable_picked = alea.seq.chooseIteratorStableFrom(&stable_choice_engine, u32, &stable_stream).?;
    try stdout.print("chooseIteratorStableFrom counter[0..20): {}\n", .{stable_picked});

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

    var fill_engine = alea.ScalarPrng.init(0x5e11_0018);
    var fill_stream = Counter{ .limit = 20 };
    var fill_out: [5]u32 = undefined;
    _ = alea.seq.sampleIteratorFillFrom(&fill_engine, u32, &fill_stream, &fill_out);
    try stdout.print("sampleIteratorFillFrom counter[0..20): {any}\n", .{fill_out});

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

    try stdout.print("\nUse sampleIndices/sampleIndicesInto/IndexVec for indexes and lazy/caller-owned/allocation-returning value/const-pointer/mutable-pointer mapping, sampleArrayU32 for compact fixed-size index arrays, chooseArray/sampleItemsArray and choosePtrArray/samplePtrArray for fixed-size item/pointer arrays, chooseMultiple/sampleItems plus chooseMultipleInto/sampleItemsInto and pointer variants for allocation-returning and caller-owned item/pointer subsets, sampleWithoutReplacement for Rng-owned subset sampling, partialShuffle/partialShuffleSplit for in-place heads/rests, reservoirSample/reservoirSamplePtrs/reservoirSampleInto/reservoirSamplePtrsInto for slices, sampleIteratorArray/sampleIterator/sampleIteratorInto for streams, weighted iterator arrays/into buffers, and Choice/iterator helpers for reusable value/pointer/index batches or streaming choices.\n", .{});
    try stdout.flush();
}
