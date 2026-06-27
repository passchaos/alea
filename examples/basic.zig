const std = @import("std");
const alea = @import("alea");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
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
    const weighted = rng.weightedIndex(&.{ 0.1, 0.2, 0.7 }).?;
    const token = try alea.ascii.Alphanumeric.alloc(init.gpa, rng, 16);
    defer init.gpa.free(token);

    var deck = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const hand = alea.seq.partialShuffle(rng, u8, &deck, 3);

    seed = seed.mix("child-stream");
    var child_engine = alea.FastPrng.init(seed.stream(42).state);
    const child_rng = alea.Rng.init(&child_engine);

    try stdout.print("dice: {any}\n", .{dice});
    try stdout.print("normal(mean=10,stddev=2.5): {d:.4}\n", .{normal});
    try stdout.print("weighted index: {}\n", .{weighted});
    try stdout.print("token: {s}\n", .{token});
    try stdout.print("partial shuffle hand: {any}\n", .{hand});
    try stdout.print("child stream u64: {}\n", .{child_rng.next()});
    try stdout.flush();
}
