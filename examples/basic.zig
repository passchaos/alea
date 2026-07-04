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
    const outage_count = alea.distributions.binomial(rng, 40, 0.25);
    const weighted = rng.weightedIndex(&.{ 0.1, 0.2, 0.7 }).?;
    const token = try alea.ascii.Alphanumeric.alloc(init.gpa, rng, 16);
    defer init.gpa.free(token);
    const unicode = try alea.ascii.unicodeUtf8Alloc(init.gpa, rng, 6);
    defer init.gpa.free(unicode);

    const dirichlet = try alea.distributions.Dirichlet(f64).init(&.{ 1.0, 2.0, 3.0 });
    var proportions: [3]f64 = undefined;
    dirichlet.sampleInto(rng, &proportions);

    var deck = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const hand = alea.seq.partialShuffle(rng, u8, &deck, 3);
    const colors = [_][]const u8{ "red", "green", "blue", "gold" };
    const color_index = rng.chooseIndex(colors.len).?;
    const color_ptr = rng.chooseConstPtr([]const u8, &colors).?;

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
    try stdout.print("dirichlet: {any}\n", .{proportions});
    try stdout.print("partial shuffle hand: {any}\n", .{hand});
    try stdout.print("index choice: {} ({s})\n", .{ color_index, colors[color_index] });
    try stdout.print("const pointer choice: {s}\n", .{color_ptr.*});
    try stdout.print("iterator choice: {}\n", .{stream_choice});
    try stdout.print("child stream u64: {}\n", .{child_rng.next()});
    try stdout.flush();
}
