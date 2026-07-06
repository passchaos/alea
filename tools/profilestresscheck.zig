const std = @import("std");
const alea = @import("alea");
const builtin = @import("builtin");

const lanes_per_seed = 262_144;
const seeds = [_]u64{
    0x5708_0000_0000_0001,
    0x5708_0000_0000_0002,
    0x5708_0000_0000_0003,
    0x5708_0000_0000_0005,
    0x5708_0000_0000_0008,
    0x5708_0000_0000_000d,
    0x5708_0000_0000_0015,
    0x5708_0000_0000_0022,
};

const Profile = enum {
    normal_table_f32,
    normal_table_f64,
    exponential_table_f32,
    exponential_table_f64,
    exponential_approx_log_f32,
};

const Gate = struct {
    threshold: f64,
    expected: f64,
};

const TailGate = struct {
    threshold: f64,
    expected: f64,
    tolerance: f64,
};

const normal_cdf_gates = [_]Gate{
    .{ .threshold = -3, .expected = 0.001349898 },
    .{ .threshold = -2, .expected = 0.022750132 },
    .{ .threshold = -1, .expected = 0.158655254 },
    .{ .threshold = 0, .expected = 0.5 },
    .{ .threshold = 1, .expected = 0.841344746 },
    .{ .threshold = 2, .expected = 0.977249868 },
    .{ .threshold = 3, .expected = 0.998650102 },
};

const exponential_cdf_gates = [_]Gate{
    .{ .threshold = 0.1, .expected = 0.095162582 },
    .{ .threshold = 0.25, .expected = 0.221199217 },
    .{ .threshold = 0.5, .expected = 0.393469340 },
    .{ .threshold = 1, .expected = 0.632120559 },
    .{ .threshold = 2, .expected = 0.864664717 },
    .{ .threshold = 4, .expected = 0.981684361 },
    .{ .threshold = 6, .expected = 0.997521248 },
};

const normal_tail_gates = [_]TailGate{
    .{ .threshold = 2.5, .expected = 204.0 / 16384.0, .tolerance = 0.00055 },
    .{ .threshold = 3.0, .expected = 44.0 / 16384.0, .tolerance = 0.00018 },
    .{ .threshold = 3.5, .expected = 8.0 / 16384.0, .tolerance = 0.00008 },
    .{ .threshold = 4.0, .expected = 2.0 / 16384.0, .tolerance = 0.00004 },
};

const exponential_table_tail_gates = [_]TailGate{
    .{ .threshold = 4.0, .expected = 300.0 / 16384.0, .tolerance = 0.00075 },
    .{ .threshold = 6.0, .expected = 41.0 / 16384.0, .tolerance = 0.00022 },
    .{ .threshold = 8.0, .expected = 5.0 / 16384.0, .tolerance = 0.00009 },
    .{ .threshold = 10.0, .expected = 1.0 / 16384.0, .tolerance = 0.00004 },
};

const exponential_approx_log_tail_gates = [_]TailGate{
    .{ .threshold = 4.0, .expected = 0.018315639, .tolerance = 0.00085 },
    .{ .threshold = 6.0, .expected = 0.002478752, .tolerance = 0.00024 },
    .{ .threshold = 8.0, .expected = 0.000335463, .tolerance = 0.00011 },
    .{ .threshold = 10.0, .expected = 0.000045400, .tolerance = 0.00004 },
};

pub fn main(init: std.process.Init) !void {
    if (builtin.target.os.tag == .wasi) {
        try runChecks(null);
        std.debug.print("profilestresscheck ok\n", .{});
        return;
    }

    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    try runChecks(stdout);
    try stdout.print("profilestresscheck ok\n", .{});
    try stdout.flush();
}

fn runChecks(stdout: ?*std.Io.Writer) !void {
    try checkNormalProfile(.normal_table_f32, "VectorStandardNormalTableF32", 0x0000_0000_f32_0000, stdout);
    try checkNormalProfile(.normal_table_f64, "VectorStandardNormalTableF64", 0x0000_0000_f64_0000, stdout);
    try checkExponentialProfile(.exponential_table_f32, "VectorStandardExponentialTableF32", 0x0000_0000_e1_0000, &exponential_table_tail_gates, 10.0, 10.41, stdout);
    try checkExponentialProfile(.exponential_table_f64, "VectorStandardExponentialTableF64", 0x0000_0000_e2_0000, &exponential_table_tail_gates, 10.0, 10.41, stdout);
    try checkExponentialProfile(.exponential_approx_log_f32, "VectorStandardExponentialApproxLogF32", 0x0000_0000_a1_0000, &exponential_approx_log_tail_gates, 10.0, 20.0, stdout);
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

const NormalSeedStats = struct {
    mean: f64,
    variance: f64,
    cdf_counts: [normal_cdf_gates.len]usize,
    tail_counts: [normal_tail_gates.len]usize,
    positive_tail_counts: [normal_tail_gates.len]usize,
    negative_tail_counts: [normal_tail_gates.len]usize,
    max_abs: f64,
};

fn checkNormalProfile(comptime profile: Profile, comptime name: []const u8, seed_salt: u64, stdout: ?*std.Io.Writer) !void {
    var aggregate_sum: f64 = 0;
    var aggregate_sum_squares: f64 = 0;
    var aggregate_cdf_counts: [normal_cdf_gates.len]usize = .{0} ** normal_cdf_gates.len;
    var aggregate_tail_counts: [normal_tail_gates.len]usize = .{0} ** normal_tail_gates.len;
    var aggregate_positive_tail_counts: [normal_tail_gates.len]usize = .{0} ** normal_tail_gates.len;
    var aggregate_negative_tail_counts: [normal_tail_gates.len]usize = .{0} ** normal_tail_gates.len;
    var aggregate_max_abs: f64 = 0;

    inline for (seeds, 0..) |base_seed, seed_index| {
        const stats = try normalSeedStats(profile, base_seed ^ seed_salt);
        aggregate_sum += stats.mean * @as(f64, @floatFromInt(lanes_per_seed));
        aggregate_sum_squares += (stats.variance + stats.mean * stats.mean) * @as(f64, @floatFromInt(lanes_per_seed));
        aggregate_max_abs = @max(aggregate_max_abs, stats.max_abs);
        inline for (aggregate_cdf_counts, 0..) |_, i| aggregate_cdf_counts[i] += stats.cdf_counts[i];
        inline for (aggregate_tail_counts, 0..) |_, i| {
            aggregate_tail_counts[i] += stats.tail_counts[i];
            aggregate_positive_tail_counts[i] += stats.positive_tail_counts[i];
            aggregate_negative_tail_counts[i] += stats.negative_tail_counts[i];
        }
        try expectFloatBetween(name, "seed mean", stats.mean, -0.015, 0.015);
        try expectFloatBetween(name, "seed variance", stats.variance, 0.94, 1.06);
        try emit(stdout, "{s} seed[{}]: mean={d:.8} variance={d:.8} max_abs={d:.8}\n", .{ name, seed_index, stats.mean, stats.variance, stats.max_abs });
    }

    const lanes = @as(f64, @floatFromInt(lanes_per_seed * seeds.len));
    const mean = aggregate_sum / lanes;
    const variance = aggregate_sum_squares / lanes - mean * mean;
    try expectFloatBetween(name, "aggregate mean", mean, -0.006, 0.006);
    try expectFloatBetween(name, "aggregate variance", variance, 0.985, 1.015);
    try expectFloatBetween(name, "aggregate max_abs", aggregate_max_abs, 4.0, 4.02);
    try emit(stdout, "{s} aggregate: seeds={} lanes={} mean={d:.8} variance={d:.8} max_abs={d:.8}\n", .{ name, seeds.len, lanes_per_seed * seeds.len, mean, variance, aggregate_max_abs });
    inline for (normal_cdf_gates, 0..) |gate, i| {
        const observed = @as(f64, @floatFromInt(aggregate_cdf_counts[i])) / lanes;
        try expectProbability(name, "aggregate cdf", observed, gate.expected, 0.006);
        try emit(stdout, "  cdf({d:.1})={d:.8} expected={d:.8}\n", .{ gate.threshold, observed, gate.expected });
    }
    inline for (normal_tail_gates, 0..) |gate, i| {
        const observed = @as(f64, @floatFromInt(aggregate_tail_counts[i])) / lanes;
        const observed_pos = @as(f64, @floatFromInt(aggregate_positive_tail_counts[i])) / lanes;
        const observed_neg = @as(f64, @floatFromInt(aggregate_negative_tail_counts[i])) / lanes;
        try expectProbability(name, "aggregate two-sided tail", observed, gate.expected, gate.tolerance);
        try expectProbability(name, "aggregate positive tail", observed_pos, gate.expected * 0.5, gate.tolerance * 0.75);
        try expectProbability(name, "aggregate negative tail", observed_neg, gate.expected * 0.5, gate.tolerance * 0.75);
        try emit(stdout, "  abs_tail(|x|>={d:.1})={d:.8} pos={d:.8} neg={d:.8} expected={d:.8}\n", .{ gate.threshold, observed, observed_pos, observed_neg, gate.expected });
    }
}

fn normalSeedStats(comptime profile: Profile, seed: u64) !NormalSeedStats {
    const VectorType = profileVectorType(profile);
    const info = @typeInfo(VectorType).vector;
    const vectors = lanes_per_seed / info.len;
    var out = NormalSeedStats{
        .mean = 0,
        .variance = 0,
        .cdf_counts = .{0} ** normal_cdf_gates.len,
        .tail_counts = .{0} ** normal_tail_gates.len,
        .positive_tail_counts = .{0} ** normal_tail_gates.len,
        .negative_tail_counts = .{0} ** normal_tail_gates.len,
        .max_abs = 0,
    };
    var sum: f64 = 0;
    var sum_squares: f64 = 0;
    var engine = alea.ScalarPrng.init(seed);
    var i: usize = 0;
    while (i < vectors) : (i += 1) {
        const sample = sampleProfile(profile, &engine);
        inline for (0..info.len) |lane| {
            const value: f64 = @floatCast(sample[lane]);
            if (!std.math.isFinite(value)) return error.ProfileStressCheckFailed;
            sum += value;
            sum_squares += value * value;
            out.max_abs = @max(out.max_abs, @abs(value));
            inline for (normal_cdf_gates, 0..) |gate, gate_index| out.cdf_counts[gate_index] += @intFromBool(value <= gate.threshold);
            inline for (normal_tail_gates, 0..) |gate, gate_index| {
                out.tail_counts[gate_index] += @intFromBool(@abs(value) >= gate.threshold);
                out.positive_tail_counts[gate_index] += @intFromBool(value >= gate.threshold);
                out.negative_tail_counts[gate_index] += @intFromBool(value <= -gate.threshold);
            }
        }
    }
    const lanes = @as(f64, @floatFromInt(vectors * info.len));
    out.mean = sum / lanes;
    out.variance = sum_squares / lanes - out.mean * out.mean;
    return out;
}

const ExponentialSeedStats = struct {
    mean: f64,
    variance: f64,
    cdf_counts: [exponential_cdf_gates.len]usize,
    tail_counts: [exponential_table_tail_gates.len]usize,
    min_value: f64,
    max_value: f64,
};

fn checkExponentialProfile(comptime profile: Profile, comptime name: []const u8, seed_salt: u64, comptime tail_gates: []const TailGate, min_max: f64, max_max: f64, stdout: ?*std.Io.Writer) !void {
    var aggregate_sum: f64 = 0;
    var aggregate_sum_squares: f64 = 0;
    var aggregate_cdf_counts: [exponential_cdf_gates.len]usize = .{0} ** exponential_cdf_gates.len;
    var aggregate_tail_counts: [tail_gates.len]usize = .{0} ** tail_gates.len;
    var aggregate_min: f64 = std.math.inf(f64);
    var aggregate_max: f64 = -std.math.inf(f64);

    inline for (seeds, 0..) |base_seed, seed_index| {
        const stats = try exponentialSeedStats(profile, tail_gates, base_seed ^ seed_salt);
        aggregate_sum += stats.mean * @as(f64, @floatFromInt(lanes_per_seed));
        aggregate_sum_squares += (stats.variance + stats.mean * stats.mean) * @as(f64, @floatFromInt(lanes_per_seed));
        aggregate_min = @min(aggregate_min, stats.min_value);
        aggregate_max = @max(aggregate_max, stats.max_value);
        inline for (aggregate_cdf_counts, 0..) |_, i| aggregate_cdf_counts[i] += stats.cdf_counts[i];
        inline for (tail_gates, 0..) |_, i| aggregate_tail_counts[i] += stats.tail_counts[i];
        try expectFloatBetween(name, "seed mean", stats.mean, 0.965, 1.035);
        try expectFloatBetween(name, "seed variance", stats.variance, 0.90, 1.10);
        try emit(stdout, "{s} seed[{}]: mean={d:.8} variance={d:.8} min={d:.8} max={d:.8}\n", .{ name, seed_index, stats.mean, stats.variance, stats.min_value, stats.max_value });
    }

    const lanes = @as(f64, @floatFromInt(lanes_per_seed * seeds.len));
    const mean = aggregate_sum / lanes;
    const variance = aggregate_sum_squares / lanes - mean * mean;
    try expectFloatBetween(name, "aggregate mean", mean, 0.990, 1.010);
    try expectFloatBetween(name, "aggregate variance", variance, 0.970, 1.030);
    try expectFloatBetween(name, "aggregate max", aggregate_max, min_max, max_max);
    try emit(stdout, "{s} aggregate: seeds={} lanes={} mean={d:.8} variance={d:.8} min={d:.8} max={d:.8}\n", .{ name, seeds.len, lanes_per_seed * seeds.len, mean, variance, aggregate_min, aggregate_max });
    inline for (exponential_cdf_gates, 0..) |gate, i| {
        const observed = @as(f64, @floatFromInt(aggregate_cdf_counts[i])) / lanes;
        try expectProbability(name, "aggregate cdf", observed, gate.expected, 0.007);
        try emit(stdout, "  cdf({d:.2})={d:.8} expected={d:.8}\n", .{ gate.threshold, observed, gate.expected });
    }
    inline for (tail_gates, 0..) |gate, i| {
        const observed = @as(f64, @floatFromInt(aggregate_tail_counts[i])) / lanes;
        try expectProbability(name, "aggregate upper tail", observed, gate.expected, gate.tolerance);
        try emit(stdout, "  tail(x>={d:.1})={d:.8} expected={d:.8}\n", .{ gate.threshold, observed, gate.expected });
    }
}

fn exponentialSeedStats(comptime profile: Profile, comptime tail_gates: []const TailGate, seed: u64) !ExponentialSeedStats {
    const VectorType = profileVectorType(profile);
    const info = @typeInfo(VectorType).vector;
    const vectors = lanes_per_seed / info.len;
    var out = ExponentialSeedStats{
        .mean = 0,
        .variance = 0,
        .cdf_counts = .{0} ** exponential_cdf_gates.len,
        .tail_counts = .{0} ** tail_gates.len,
        .min_value = std.math.inf(f64),
        .max_value = -std.math.inf(f64),
    };
    var sum: f64 = 0;
    var sum_squares: f64 = 0;
    var engine = alea.ScalarPrng.init(seed);
    var i: usize = 0;
    while (i < vectors) : (i += 1) {
        const sample = sampleProfile(profile, &engine);
        inline for (0..info.len) |lane| {
            const value: f64 = @floatCast(sample[lane]);
            if (!std.math.isFinite(value) or value < 0) return error.ProfileStressCheckFailed;
            sum += value;
            sum_squares += value * value;
            out.min_value = @min(out.min_value, value);
            out.max_value = @max(out.max_value, value);
            inline for (exponential_cdf_gates, 0..) |gate, gate_index| out.cdf_counts[gate_index] += @intFromBool(value <= gate.threshold);
            inline for (tail_gates, 0..) |gate, gate_index| out.tail_counts[gate_index] += @intFromBool(value >= gate.threshold);
        }
    }
    const lanes = @as(f64, @floatFromInt(vectors * info.len));
    out.mean = sum / lanes;
    out.variance = sum_squares / lanes - out.mean * out.mean;
    return out;
}

fn expectProbability(comptime profile_name: []const u8, comptime metric: []const u8, value: f64, expected: f64, tolerance: f64) !void {
    try expectFloatBetween(profile_name, metric, value, probabilityMin(expected, tolerance), probabilityMax(expected, tolerance));
}

fn expectFloatBetween(comptime profile_name: []const u8, comptime metric: []const u8, value: f64, min: f64, max: f64) !void {
    if (!floatInClosedRange(value, min, max)) {
        std.debug.print("{s} {s}: {d:.8} not in [{d:.8}, {d:.8}]\n", .{ profile_name, metric, value, min, max });
        return error.ProfileStressCheckFailed;
    }
}

fn probabilityMin(expected: f64, tolerance: f64) f64 {
    return @max(0, expected - tolerance);
}

fn probabilityMax(expected: f64, tolerance: f64) f64 {
    return @min(1, expected + tolerance);
}

fn floatInClosedRange(value: f64, min: f64, max: f64) bool {
    return value >= min and value <= max;
}

test "profile stress vector type selection matches accepted profiles" {
    try std.testing.expectEqual(@as(usize, 8), @typeInfo(profileVectorType(.normal_table_f32)).vector.len);
    try std.testing.expectEqual(@as(usize, 4), @typeInfo(profileVectorType(.normal_table_f64)).vector.len);
    try std.testing.expectEqual(@as(usize, 8), @typeInfo(profileVectorType(.exponential_approx_log_f32)).vector.len);
}

test "stress probability bounds clamp to valid probability range" {
    try std.testing.expectEqual(@as(f64, 0.0), probabilityMin(0.01, 0.02));
    try std.testing.expectEqual(@as(f64, 0.4), probabilityMin(0.5, 0.1));
    try std.testing.expectEqual(@as(f64, 0.6), probabilityMax(0.5, 0.1));
    try std.testing.expectEqual(@as(f64, 1.0), probabilityMax(0.99, 0.02));
}

test "stress float closed-range predicate accepts boundaries and rejects NaN" {
    try std.testing.expect(floatInClosedRange(0.0, 0.0, 1.0));
    try std.testing.expect(floatInClosedRange(1.0, 0.0, 1.0));
    try std.testing.expect(!floatInClosedRange(-0.01, 0.0, 1.0));
    try std.testing.expect(!floatInClosedRange(1.01, 0.0, 1.0));
    try std.testing.expect(!floatInClosedRange(std.math.nan(f64), 0.0, 1.0));
}

fn emit(stdout: ?*std.Io.Writer, comptime fmt: []const u8, args: anytype) !void {
    if (builtin.target.os.tag == .wasi) {
        std.debug.print(fmt, args);
    } else if (stdout) |writer| {
        try writer.print(fmt, args);
    }
}
