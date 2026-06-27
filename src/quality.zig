const std = @import("std");
const root = @import("root.zig");

fn bitBalance(comptime Engine: type, seed: u64) !void {
    var engine = Engine.init(seed);
    var ones: usize = 0;
    const samples = 8192;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        ones += @popCount(engine.next());
    }

    const total_bits = samples * 64;
    const lower = total_bits * 47 / 100;
    const upper = total_bits * 53 / 100;
    try std.testing.expect(ones > lower and ones < upper);
}

test "engine output has coarse bit balance" {
    try bitBalance(root.Alea4x64, 101);
    try bitBalance(root.Wyhash64, 102);
    try bitBalance(root.Xoshiro256, 103);
    try bitBalance(root.Xoshiro256PlusPlus, 104);
    try bitBalance(root.Pcg64, 105);
}

test "bounded integers are coarsely uniform" {
    var engine = root.FastPrng.init(201);
    const rng = root.Rng.init(&engine);

    var buckets = [_]usize{0} ** 10;
    const samples = 20_000;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        buckets[rng.uintLessThan(usize, buckets.len)] += 1;
    }

    for (buckets) |count| {
        try std.testing.expect(count > 1800 and count < 2200);
    }
}

test "normal and exponential means stay in broad windows" {
    var engine = root.DefaultPrng.init(301);
    const rng = root.Rng.init(&engine);

    const samples = 12_000;
    var normal_sum: f64 = 0;
    var exponential_sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        normal_sum += rng.normal(f64, 0, 1);
        exponential_sum += rng.exponential(f64, 2);
    }

    const normal_mean = normal_sum / @as(f64, @floatFromInt(samples));
    const exponential_mean = exponential_sum / @as(f64, @floatFromInt(samples));
    try std.testing.expect(@abs(normal_mean) < 0.05);
    try std.testing.expect(exponential_mean > 0.47 and exponential_mean < 0.53);
}
