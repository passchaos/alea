const std = @import("std");
const alea = @import("alea");
const builtin = @import("builtin");

const lanes_per_seed = 1_048_576;
const seeds = [_]u64{
    0x5109_0000_0000_0001,
    0x5109_0000_0000_0003,
    0x5109_0000_0000_0007,
    0x5109_0000_0000_000f,
    0x5109_0000_0000_001f,
    0x5109_0000_0000_003f,
    0x5109_0000_0000_007f,
    0x5109_0000_0000_00ff,
};

const Profile = enum {
    normal_table_f32,
    normal_table_f64,
    exponential_table_f32,
    exponential_table_f64,
    exponential_approx_log_f32,
};

const TailGate = struct {
    threshold: f64,
    expected: f64,
    tolerance: f64,
};

const normal_tail_gates = [_]TailGate{
    .{ .threshold = 2.5, .expected = 204.0 / 16384.0, .tolerance = 0.00032 },
    .{ .threshold = 3.0, .expected = 44.0 / 16384.0, .tolerance = 0.00011 },
    .{ .threshold = 3.5, .expected = 8.0 / 16384.0, .tolerance = 0.000045 },
    .{ .threshold = 4.0, .expected = 2.0 / 16384.0, .tolerance = 0.000025 },
};

const exponential_table_tail_gates = [_]TailGate{
    .{ .threshold = 4.0, .expected = 300.0 / 16384.0, .tolerance = 0.00042 },
    .{ .threshold = 6.0, .expected = 41.0 / 16384.0, .tolerance = 0.00013 },
    .{ .threshold = 8.0, .expected = 5.0 / 16384.0, .tolerance = 0.000055 },
    .{ .threshold = 10.0, .expected = 1.0 / 16384.0, .tolerance = 0.000028 },
};

const exponential_approx_log_tail_gates = [_]TailGate{
    .{ .threshold = 4.0, .expected = 0.018315639, .tolerance = 0.00050 },
    .{ .threshold = 6.0, .expected = 0.002478752, .tolerance = 0.00015 },
    .{ .threshold = 8.0, .expected = 0.000335463, .tolerance = 0.000070 },
    .{ .threshold = 10.0, .expected = 0.000045400, .tolerance = 0.000028 },
};

pub fn main(init: std.process.Init) !void {
    if (builtin.target.os.tag == .wasi) {
        try runChecks(null);
        std.debug.print("profilelongcheck ok\n", .{});
        return;
    }

    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    try runChecks(stdout);
    try stdout.print("profilelongcheck ok\n", .{});
    try stdout.flush();
}

fn runChecks(stdout: ?*std.Io.Writer) !void {
    try checkNormalProfile(.normal_table_f32, "VectorStandardNormalTableF32", 0x0000_f32_5109_0000, stdout);
    try checkNormalProfile(.normal_table_f64, "VectorStandardNormalTableF64", 0x0000_f64_5109_0000, stdout);
    try checkExponentialProfile(.exponential_table_f32, "VectorStandardExponentialTableF32", 0x0000_e1_5109_0000, &exponential_table_tail_gates, 10.0, 10.41, stdout);
    try checkExponentialProfile(.exponential_table_f64, "VectorStandardExponentialTableF64", 0x0000_e2_5109_0000, &exponential_table_tail_gates, 10.0, 10.41, stdout);
    try checkExponentialProfile(.exponential_approx_log_f32, "VectorStandardExponentialApproxLogF32", 0x0000_a1_5109_0000, &exponential_approx_log_tail_gates, 12.0, 22.0, stdout);
}

fn profileVectorType(comptime profile: Profile) type {
    return switch (profile) {
        .normal_table_f32, .exponential_table_f32, .exponential_approx_log_f32 => @Vector(8, f32),
        .normal_table_f64, .exponential_table_f64 => @Vector(4, f64),
    };
}

fn sampleProfile(comptime profile: Profile, source: *alea.ScalarPrng) profileVectorType(profile) {
    return switch (profile) {
        .normal_table_f32 => alea.distributions.vectorStandardNormalTableF32From(source, @Vector(8, f32)),
        .normal_table_f64 => alea.distributions.vectorStandardNormalTableF64From(source, @Vector(4, f64)),
        .exponential_table_f32 => alea.distributions.vectorStandardExponentialTableF32From(source, @Vector(8, f32)),
        .exponential_table_f64 => alea.distributions.vectorStandardExponentialTableF64From(source, @Vector(4, f64)),
        .exponential_approx_log_f32 => alea.distributions.vectorStandardExponentialApproxLogF32From(source, @Vector(8, f32)),
    };
}

fn checkNormalProfile(comptime profile: Profile, comptime name: []const u8, seed_salt: u64, stdout: ?*std.Io.Writer) !void {
    var sum: f64 = 0;
    var sum_squares: f64 = 0;
    var tail_counts: [normal_tail_gates.len]usize = .{0} ** normal_tail_gates.len;
    var positive_tail_counts: [normal_tail_gates.len]usize = .{0} ** normal_tail_gates.len;
    var negative_tail_counts: [normal_tail_gates.len]usize = .{0} ** normal_tail_gates.len;
    var max_abs: f64 = 0;

    inline for (seeds, 0..) |base_seed, seed_index| {
        const stats = try normalSeedStats(profile, base_seed ^ seed_salt);
        sum += stats.sum;
        sum_squares += stats.sum_squares;
        max_abs = @max(max_abs, stats.max_abs);
        inline for (normal_tail_gates, 0..) |_, i| {
            tail_counts[i] += stats.tail_counts[i];
            positive_tail_counts[i] += stats.positive_tail_counts[i];
            negative_tail_counts[i] += stats.negative_tail_counts[i];
        }
        try expectFloatBetween(name, "seed mean", stats.mean, -0.008, 0.008);
        try expectFloatBetween(name, "seed variance", stats.variance, 0.965, 1.035);
        try emit(stdout, "{s} seed[{}]: mean={d:.8} variance={d:.8} max_abs={d:.8}\n", .{ name, seed_index, stats.mean, stats.variance, stats.max_abs });
    }

    const lanes = @as(f64, @floatFromInt(lanes_per_seed * seeds.len));
    const mean = sum / lanes;
    const variance = sum_squares / lanes - mean * mean;
    try expectFloatBetween(name, "mean", mean, -0.0035, 0.0035);
    try expectFloatBetween(name, "variance", variance, 0.992, 1.008);
    try expectFloatBetween(name, "max_abs", max_abs, 4.0, 4.02);
    try emit(stdout, "{s} long aggregate: seeds={} lanes={} mean={d:.8} variance={d:.8} max_abs={d:.8}\n", .{ name, seeds.len, lanes_per_seed * seeds.len, mean, variance, max_abs });
    inline for (normal_tail_gates, 0..) |gate, i| {
        const observed = @as(f64, @floatFromInt(tail_counts[i])) / lanes;
        const observed_pos = @as(f64, @floatFromInt(positive_tail_counts[i])) / lanes;
        const observed_neg = @as(f64, @floatFromInt(negative_tail_counts[i])) / lanes;
        try expectProbability(name, "two-sided tail", observed, gate.expected, gate.tolerance);
        try expectProbability(name, "positive tail", observed_pos, gate.expected * 0.5, gate.tolerance * 0.7);
        try expectProbability(name, "negative tail", observed_neg, gate.expected * 0.5, gate.tolerance * 0.7);
        try emit(stdout, "  abs_tail(|x|>={d:.1})={d:.8} pos={d:.8} neg={d:.8} expected={d:.8}\n", .{ gate.threshold, observed, observed_pos, observed_neg, gate.expected });
    }
}

const NormalSeedStats = struct {
    sum: f64,
    sum_squares: f64,
    mean: f64,
    variance: f64,
    tail_counts: [normal_tail_gates.len]usize,
    positive_tail_counts: [normal_tail_gates.len]usize,
    negative_tail_counts: [normal_tail_gates.len]usize,
    max_abs: f64,
};

fn normalSeedStats(comptime profile: Profile, seed: u64) !NormalSeedStats {
    const VectorType = profileVectorType(profile);
    const info = @typeInfo(VectorType).vector;
    const vectors = lanes_per_seed / info.len;
    var out = NormalSeedStats{
        .sum = 0,
        .sum_squares = 0,
        .mean = 0,
        .variance = 0,
        .tail_counts = .{0} ** normal_tail_gates.len,
        .positive_tail_counts = .{0} ** normal_tail_gates.len,
        .negative_tail_counts = .{0} ** normal_tail_gates.len,
        .max_abs = 0,
    };
    var engine = alea.ScalarPrng.init(seed);
    var i: usize = 0;
    while (i < vectors) : (i += 1) {
        const sample = sampleProfile(profile, &engine);
        inline for (0..info.len) |lane| {
            const value: f64 = @floatCast(sample[lane]);
            if (!std.math.isFinite(value)) return error.ProfileLongCheckFailed;
            out.sum += value;
            out.sum_squares += value * value;
            out.max_abs = @max(out.max_abs, @abs(value));
            inline for (normal_tail_gates, 0..) |gate, gate_index| {
                out.tail_counts[gate_index] += @intFromBool(@abs(value) >= gate.threshold);
                out.positive_tail_counts[gate_index] += @intFromBool(value >= gate.threshold);
                out.negative_tail_counts[gate_index] += @intFromBool(value <= -gate.threshold);
            }
        }
    }
    const lanes = @as(f64, @floatFromInt(vectors * info.len));
    out.mean = out.sum / lanes;
    out.variance = out.sum_squares / lanes - out.mean * out.mean;
    return out;
}

fn checkExponentialProfile(comptime profile: Profile, comptime name: []const u8, seed_salt: u64, comptime tail_gates: []const TailGate, min_max: f64, max_max: f64, stdout: ?*std.Io.Writer) !void {
    var sum: f64 = 0;
    var sum_squares: f64 = 0;
    var tail_counts: [tail_gates.len]usize = .{0} ** tail_gates.len;
    var min_value: f64 = std.math.inf(f64);
    var max_value: f64 = -std.math.inf(f64);

    inline for (seeds, 0..) |base_seed, seed_index| {
        const stats = try exponentialSeedStats(profile, tail_gates, base_seed ^ seed_salt);
        sum += stats.sum;
        sum_squares += stats.sum_squares;
        min_value = @min(min_value, stats.min_value);
        max_value = @max(max_value, stats.max_value);
        inline for (tail_gates, 0..) |_, i| tail_counts[i] += stats.tail_counts[i];
        try expectFloatBetween(name, "seed mean", stats.mean, 0.980, 1.020);
        try expectFloatBetween(name, "seed variance", stats.variance, 0.940, 1.060);
        try emit(stdout, "{s} seed[{}]: mean={d:.8} variance={d:.8} min={d:.8} max={d:.8}\n", .{ name, seed_index, stats.mean, stats.variance, stats.min_value, stats.max_value });
    }

    const lanes = @as(f64, @floatFromInt(lanes_per_seed * seeds.len));
    const mean = sum / lanes;
    const variance = sum_squares / lanes - mean * mean;
    try expectFloatBetween(name, "mean", mean, 0.995, 1.005);
    try expectFloatBetween(name, "variance", variance, 0.985, 1.015);
    try expectFloatBetween(name, "max", max_value, min_max, max_max);
    try emit(stdout, "{s} long aggregate: seeds={} lanes={} mean={d:.8} variance={d:.8} min={d:.8} max={d:.8}\n", .{ name, seeds.len, lanes_per_seed * seeds.len, mean, variance, min_value, max_value });
    inline for (tail_gates, 0..) |gate, i| {
        const observed = @as(f64, @floatFromInt(tail_counts[i])) / lanes;
        try expectProbability(name, "upper tail", observed, gate.expected, gate.tolerance);
        try emit(stdout, "  tail(x>={d:.1})={d:.8} expected={d:.8}\n", .{ gate.threshold, observed, gate.expected });
    }
}

const ExponentialSeedStats = struct {
    sum: f64,
    sum_squares: f64,
    mean: f64,
    variance: f64,
    tail_counts: [exponential_table_tail_gates.len]usize,
    min_value: f64,
    max_value: f64,
};

fn exponentialSeedStats(comptime profile: Profile, comptime tail_gates: []const TailGate, seed: u64) !ExponentialSeedStats {
    const VectorType = profileVectorType(profile);
    const info = @typeInfo(VectorType).vector;
    const vectors = lanes_per_seed / info.len;
    var out = ExponentialSeedStats{
        .sum = 0,
        .sum_squares = 0,
        .mean = 0,
        .variance = 0,
        .tail_counts = .{0} ** tail_gates.len,
        .min_value = std.math.inf(f64),
        .max_value = -std.math.inf(f64),
    };
    var engine = alea.ScalarPrng.init(seed);
    var i: usize = 0;
    while (i < vectors) : (i += 1) {
        const sample = sampleProfile(profile, &engine);
        inline for (0..info.len) |lane| {
            const value: f64 = @floatCast(sample[lane]);
            if (!std.math.isFinite(value) or value < 0) return error.ProfileLongCheckFailed;
            out.sum += value;
            out.sum_squares += value * value;
            out.min_value = @min(out.min_value, value);
            out.max_value = @max(out.max_value, value);
            inline for (tail_gates, 0..) |gate, gate_index| out.tail_counts[gate_index] += @intFromBool(value >= gate.threshold);
        }
    }
    const lanes = @as(f64, @floatFromInt(vectors * info.len));
    out.mean = out.sum / lanes;
    out.variance = out.sum_squares / lanes - out.mean * out.mean;
    return out;
}

fn expectProbability(comptime profile_name: []const u8, comptime metric: []const u8, value: f64, expected: f64, tolerance: f64) !void {
    try expectFloatBetween(profile_name, metric, value, @max(0, expected - tolerance), @min(1, expected + tolerance));
}

fn expectFloatBetween(comptime profile_name: []const u8, comptime metric: []const u8, value: f64, min: f64, max: f64) !void {
    if (!(value >= min and value <= max)) {
        std.debug.print("{s} {s}: {d:.8} not in [{d:.8}, {d:.8}]\n", .{ profile_name, metric, value, min, max });
        return error.ProfileLongCheckFailed;
    }
}

fn emit(stdout: ?*std.Io.Writer, comptime fmt: []const u8, args: anytype) !void {
    if (builtin.target.os.tag == .wasi) {
        std.debug.print(fmt, args);
    } else if (stdout) |writer| {
        try writer.print(fmt, args);
    }
}
