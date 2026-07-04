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

    var index_vec_engine = alea.ScalarPrng.init(0x5e11_0002);
    const index_vec = try alea.seq.sampleIndexVecFrom(allocator, &index_vec_engine, 10_000, 6);
    defer index_vec.deinit(allocator);
    try stdout.print("sampleIndexVec len={} values=", .{index_vec.len()});
    try printIndexVec(stdout, index_vec);
    try stdout.print("\n", .{});

    var choose_engine = alea.ScalarPrng.init(0x5e11_0003);
    const chosen = try alea.seq.chooseMultipleFrom(allocator, &choose_engine, []const u8, &items, 3);
    defer allocator.free(chosen);
    try stdout.print("chooseMultiple items: {s}, {s}, {s}\n", .{ chosen[0], chosen[1], chosen[2] });

    var choose_array_engine = alea.ScalarPrng.init(0x5e11_000a);
    const chosen_array = alea.seq.chooseArrayFrom(&choose_array_engine, []const u8, 3, &items).?;
    try stdout.print("chooseArray items: {s}, {s}, {s}\n", .{ chosen_array[0], chosen_array[1], chosen_array[2] });

    var swr_engine = alea.ScalarPrng.init(0x5e11_0004);
    const sample = try alea.Rng.sampleWithoutReplacementFrom(&swr_engine, []const u8, allocator, &items, 3);
    defer allocator.free(sample);
    try stdout.print("Rng.sampleWithoutReplacementFrom: {s}, {s}, {s}\n", .{ sample[0], sample[1], sample[2] });

    var deck = items;
    var shuffle_engine = alea.ScalarPrng.init(0x5e11_0005);
    const hand = alea.seq.partialShuffleFrom(&shuffle_engine, []const u8, &deck, 3);
    try stdout.print("partialShuffle hand: {s}, {s}, {s}; deck head now: {s}, {s}, {s}\n", .{ hand[0], hand[1], hand[2], deck[0], deck[1], deck[2] });

    var reservoir_engine = alea.ScalarPrng.init(0x5e11_0006);
    const reservoir = try alea.seq.reservoirSampleFrom(allocator, &reservoir_engine, []const u8, &items, 4);
    defer allocator.free(reservoir);
    try stdout.print("reservoirSample: {s}, {s}, {s}, {s}\n", .{ reservoir[0], reservoir[1], reservoir[2], reservoir[3] });

    const choice = alea.seq.Choice([]const u8).init(&items).?;
    var choice_engine = alea.ScalarPrng.init(0x5e11_0007);
    var choice_values: [5][]const u8 = undefined;
    choice.fillValuesFrom(&choice_engine, &choice_values);
    try stdout.print("Choice.fillValuesFrom: {s}, {s}, {s}, {s}, {s}\n", .{ choice_values[0], choice_values[1], choice_values[2], choice_values[3], choice_values[4] });

    var iter_choice_engine = alea.ScalarPrng.init(0x5e11_0008);
    var stream = Counter{ .limit = 20 };
    const picked = alea.seq.chooseIteratorFrom(&iter_choice_engine, u32, &stream).?;
    try stdout.print("chooseIteratorFrom counter[0..20): {}\n", .{picked});

    var iter_sample_engine = alea.ScalarPrng.init(0x5e11_0009);
    var sample_stream = Counter{ .limit = 20 };
    const stream_sample = try alea.seq.sampleIteratorFrom(allocator, &iter_sample_engine, u32, &sample_stream, 5);
    defer allocator.free(stream_sample);
    try stdout.print("sampleIteratorFrom counter[0..20): {any}\n", .{stream_sample});

    try stdout.print("\nUse sampleIndices/IndexVec for indexes, chooseArray for fixed-size arrays, chooseMultiple or sampleWithoutReplacement for item subsets, partialShuffle for in-place heads, reservoirSample for streams, and Choice/iterator helpers for reusable or streaming choices.\n", .{});
    try stdout.flush();
}
