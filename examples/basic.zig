const std = @import("std");
const alea = @import("alea");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var seed = alea.Seed.fromString("alea-demo");
    var engine = alea.DefaultPrng.init(seed.stream(0).state);
    const rng = alea.Rng.init(&engine);

    var dice: [8]u8 = undefined;
    for (&dice) |*die| {
        die.* = rng.intRangeAtMost(u8, 1, 6);
    }

    const normal = rng.normal(f64, 10.0, 2.5);
    const outage_count = alea.distributions.binomial(rng, 40, 0.25);
    const weighted = rng.weightedIndex(&.{ 0.1, 0.2, 0.7 }).?;
    const token = try alea.ascii.Alphanumeric.alloc(init.gpa, rng, 16);
    defer init.gpa.free(token);
    const unicode = try alea.ascii.unicodeUtf8Alloc(init.gpa, rng, 6);
    defer init.gpa.free(unicode);
    const random_bytes = try rng.bytesAlloc(init.gpa, 8);
    defer init.gpa.free(random_bytes);
    const random_words = try rng.valueBatch(u16, init.gpa, 4);
    defer init.gpa.free(random_words);
    const bounded_words = try rng.uintLessThanBatch(u16, init.gpa, 4, 1000);
    defer init.gpa.free(bounded_words);
    const inclusive_words = try rng.uintAtMostBatch(u16, init.gpa, 4, 999);
    defer init.gpa.free(inclusive_words);
    const chance_flags = try rng.chanceBatch(init.gpa, 8, 0.25);
    defer init.gpa.free(chance_flags);
    const ratio_flags = try rng.ratioBatch(init.gpa, 8, 3, 8);
    defer init.gpa.free(ratio_flags);
    const vector_chance_flags = try rng.vectorChanceBatch(@Vector(8, bool), init.gpa, 2, 0.25);
    defer init.gpa.free(vector_chance_flags);
    const vector_ratio_flags = try rng.vectorRatioBatch(@Vector(8, bool), init.gpa, 2, 3, 8);
    defer init.gpa.free(vector_ratio_flags);
    const standard_normal_batch = try rng.standardNormalBatch(f64, init.gpa, 4);
    defer init.gpa.free(standard_normal_batch);
    const standard_exponential_batch = try rng.standardExponentialBatch(f64, init.gpa, 4);
    defer init.gpa.free(standard_exponential_batch);
    const normal_batch = try rng.normalBatch(f64, init.gpa, 4, 10, 2.5);
    defer init.gpa.free(normal_batch);
    const exponential_batch = try rng.exponentialBatch(f64, init.gpa, 4, 4);
    defer init.gpa.free(exponential_batch);
    const vector_standard_normal_batch = try rng.vectorStandardNormalBatch(@Vector(4, f64), init.gpa, 2);
    defer init.gpa.free(vector_standard_normal_batch);
    const vector_standard_exponential_batch = try rng.vectorStandardExponentialBatch(@Vector(4, f64), init.gpa, 2);
    defer init.gpa.free(vector_standard_exponential_batch);
    const vector_normal_batch = try rng.vectorNormalBatch(@Vector(4, f64), init.gpa, 2, 0, 1);
    defer init.gpa.free(vector_normal_batch);
    const vector_exponential_batch = try rng.vectorExponentialBatch(@Vector(4, f64), init.gpa, 2, 2);
    defer init.gpa.free(vector_exponential_batch);

    const dirichlet = try alea.distributions.Dirichlet(f64).init(&.{ 1.0, 2.0, 3.0 });
    var proportions: [3]f64 = undefined;
    dirichlet.sampleInto(rng, &proportions);

    var deck = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const hand = alea.seq.partialShuffle(rng, u8, &deck, 3);
    const colors = [_][]const u8{ "red", "green", "blue", "gold" };
    const color_index = rng.chooseIndex(colors.len).?;
    const compact_color_index = rng.chooseIndexU32(@intCast(colors.len)).?;
    const color_indices = try rng.chooseIndexBatch(init.gpa, 4, colors.len);
    defer init.gpa.free(color_indices);
    const compact_color_indices = try rng.chooseIndexU32Batch(init.gpa, 4, @intCast(colors.len));
    defer init.gpa.free(compact_color_indices);
    const color_values = try rng.chooseBatch([]const u8, init.gpa, 4, &colors);
    defer init.gpa.free(color_values);
    const color_ptr = rng.chooseConstPtr([]const u8, &colors).?;
    const die_sampler = try alea.distributions.Uniform(u8).initInclusive(1, 6);
    const owned_rolls = try rng.sampleBatch(u8, init.gpa, die_sampler, 6);
    defer init.gpa.free(owned_rolls);

    const Iter = struct {
        next_value: u8 = 0,
        pub fn next(self: *@This()) ?u8 {
            if (self.next_value == 10) return null;
            const value = self.next_value;
            self.next_value += 1;
            return value;
        }
    };
    var iter = Iter{};
    const stream_choice = alea.seq.chooseIterator(rng, u8, &iter).?;

    seed = seed.mix("child-stream");
    var child_engine = alea.FastPrng.init(seed.stream(42).state);
    const child_rng = alea.Rng.init(&child_engine);

    try stdout.print("dice: {any}\n", .{dice});
    try stdout.print("normal(mean=10,stddev=2.5): {d:.4}\n", .{normal});
    try stdout.print("binomial(n=40,p=.25): {}\n", .{outage_count});
    try stdout.print("weighted index: {}\n", .{weighted});
    try stdout.print("token: {s}\n", .{token});
    try stdout.print("unicode scalars: {s}\n", .{unicode});
    try stdout.print("bytesAlloc: {any}\n", .{random_bytes});
    try stdout.print("valueBatch u16: {any}\n", .{random_words});
    try stdout.print("uintLessThanBatch u16 <1000: {any}\n", .{bounded_words});
    try stdout.print("uintAtMostBatch u16 <=999: {any}\n", .{inclusive_words});
    try stdout.print("chanceBatch p=.25: {any}\n", .{chance_flags});
    try stdout.print("ratioBatch 3/8: {any}\n", .{ratio_flags});
    try stdout.print("vectorChanceBatch boolx8 p=.25: {any}\n", .{vector_chance_flags});
    try stdout.print("vectorRatioBatch boolx8 3/8: {any}\n", .{vector_ratio_flags});
    try stdout.print("standardNormalBatch: {any}\n", .{standard_normal_batch});
    try stdout.print("standardExponentialBatch: {any}\n", .{standard_exponential_batch});
    try stdout.print("normalBatch: {any}\n", .{normal_batch});
    try stdout.print("exponentialBatch: {any}\n", .{exponential_batch});
    try stdout.print("vectorStandardNormalBatch f64x4: {any}\n", .{vector_standard_normal_batch});
    try stdout.print("vectorStandardExponentialBatch f64x4: {any}\n", .{vector_standard_exponential_batch});
    try stdout.print("vectorNormalBatch f64x4: {any}\n", .{vector_normal_batch});
    try stdout.print("vectorExponentialBatch f64x4: {any}\n", .{vector_exponential_batch});
    try stdout.print("dirichlet: {any}\n", .{proportions});
    try stdout.print("partial shuffle hand: {any}\n", .{hand});
    try stdout.print("index choice: {} ({s})\n", .{ color_index, colors[color_index] });
    try stdout.print("u32 index choice: {} ({s})\n", .{ compact_color_index, colors[compact_color_index] });
    try stdout.print("index choice batch: {any}\n", .{color_indices});
    try stdout.print("u32 index choice batch: {any}\n", .{compact_color_indices});
    try stdout.print("value choice batch: {s}, {s}, {s}, {s}\n", .{ color_values[0], color_values[1], color_values[2], color_values[3] });
    try stdout.print("const pointer choice: {s}\n", .{color_ptr.*});
    try stdout.print("sampleBatch dice: {any}\n", .{owned_rolls});
    try stdout.print("iterator choice: {}\n", .{stream_choice});
    try stdout.print("child stream u64: {}\n", .{child_rng.next()});
    try stdout.flush();
}
