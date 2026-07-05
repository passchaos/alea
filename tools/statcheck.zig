const std = @import("std");
const alea = @import("alea");
const builtin = @import("builtin");

pub fn main(init: std.process.Init) !void {
    if (builtin.target.os.tag == .wasi) {
        try runChecks();
        std.debug.print("statcheck ok\n", .{});
        return;
    }

    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    try runChecks();
    try stdout.print("statcheck ok\n", .{});
    try stdout.flush();
}

fn runChecks() !void {
    try checkEngine(alea.Alea4x64, "alea4x64");
    try checkEngine(alea.Wyhash64, "wyhash64");
    try checkEngine(alea.Xoshiro256, "xoshiro256");
    try checkEngine(alea.Xoshiro256PlusPlus, "xoshiro256++");
    try checkEngine(alea.Pcg64, "pcg64");
    try checkEngine(alea.ChaCha8Rng, "chacha8");
    try checkEngine(alea.ChaCha, "chacha12");
    try checkEngine(alea.ChaCha20Rng, "chacha20");
    try checkDistributions();
}

fn checkEngine(comptime Engine: type, comptime name: []const u8) !void {
    var engine = if (Engine == alea.ChaCha or Engine == alea.ChaCha8Rng or Engine == alea.ChaCha20Rng)
        Engine.initFromU64(0x51a7_c0de)
    else
        Engine.init(0x51a7_c0de);
    var byte_counts = [_]usize{0} ** 256;
    var low_nibble_counts = [_]usize{0} ** 16;
    var low_nibble_pairs = [_]usize{0} ** 256;
    var ones: usize = 0;
    var transitions: usize = 0;
    var same_low_byte: usize = 0;
    var prev_low_byte: ?u8 = null;
    var prev_low_nibble: ?usize = null;

    const samples = 65_536;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        const value = engine.next();
        ones += @popCount(value);
        const low_nibble: usize = @intCast(value & 0xF);
        low_nibble_counts[low_nibble] += 1;
        if (prev_low_nibble) |prev| {
            low_nibble_pairs[prev * 16 + low_nibble] += 1;
        }
        prev_low_nibble = low_nibble;

        var x = value;
        var b: usize = 0;
        while (b < 8) : (b += 1) {
            const byte: u8 = @truncate(x);
            byte_counts[byte] += 1;
            if (b == 0) {
                if (prev_low_byte) |prev| {
                    transitions += 1;
                    same_low_byte += @intFromBool(prev == byte);
                }
                prev_low_byte = byte;
            }
            x >>= 8;
        }
    }

    const total_bits = samples * 64;
    try expectBetween(name, "bit balance", ones, total_bits * 49 / 100, total_bits * 51 / 100);

    const expected_nibble = samples / low_nibble_counts.len;
    for (low_nibble_counts) |count| {
        try expectBetween(name, "low nibble buckets", count, expected_nibble * 85 / 100, expected_nibble * 115 / 100);
    }

    const expected_pair = (samples - 1) / low_nibble_pairs.len;
    for (low_nibble_pairs) |count| {
        try expectBetween(name, "low nibble serial pairs", count, expected_pair / 2, expected_pair * 3 / 2 + 1);
    }

    const expected_byte = samples * 8 / byte_counts.len;
    for (byte_counts) |count| {
        try expectBetween(name, "byte buckets", count, expected_byte * 80 / 100, expected_byte * 120 / 100);
    }

    const expected_same = transitions / 256;
    try expectBetween(name, "lag-1 low-byte repeats", same_low_byte, expected_same / 2, expected_same * 3 / 2 + 1);
}

fn checkDistributions() !void {
    var engine = alea.DefaultPrng.init(0xd157_5eed);
    const rng = alea.Rng.init(&engine);

    const samples = 50_000;
    var normal_sum: f64 = 0;
    var exponential_sum: f64 = 0;
    var poisson_sum: f64 = 0;
    var binomial_sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        normal_sum += rng.normal(f64, 0, 1);
        exponential_sum += rng.exponential(f64, 2);
        poisson_sum += @floatFromInt(alea.distributions.poisson(rng, 20));
        binomial_sum += @floatFromInt(alea.distributions.binomial(rng, 40, 0.25));
    }

    const n: f64 = @floatFromInt(samples);
    try expectFloatBetween("normal mean", normal_sum / n, -0.025, 0.025);
    try expectFloatBetween("exponential mean", exponential_sum / n, 0.485, 0.515);
    try expectFloatBetween("poisson mean", poisson_sum / n, 19.75, 20.25);
    try expectFloatBetween("binomial mean", binomial_sum / n, 9.85, 10.15);
}

fn expectBetween(comptime source: []const u8, comptime label: []const u8, value: usize, min: usize, max: usize) !void {
    if (value < min or value > max) {
        std.debug.print("{s} {s}: {} not in [{}, {}]\n", .{ source, label, value, min, max });
        return error.StatCheckFailed;
    }
}

fn expectFloatBetween(comptime label: []const u8, value: f64, min: f64, max: f64) !void {
    if (!(value >= min and value <= max)) {
        std.debug.print("{s}: {d:.6} not in [{d:.6}, {d:.6}]\n", .{ label, value, min, max });
        return error.StatCheckFailed;
    }
}
