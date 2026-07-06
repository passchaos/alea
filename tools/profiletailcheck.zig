const std = @import("std");
const alea = @import("alea");
const builtin = @import("builtin");

const lanes_per_profile = 8_388_608;

const Profile = enum {
    normal_table_f32,
    normal_table_f64,
    exponential_table_f32,
    exponential_table_f64,
    exponential_approx_log_f32,
};

const TailSpec = struct {
    threshold: f64,
    expected_probability: f64,
    tolerance: f64,
};

const normal_table_tail_specs = [_]TailSpec{
    .{ .threshold = 2.5, .expected_probability = 204.0 / 16384.0, .tolerance = 0.0008 },
    .{ .threshold = 3.0, .expected_probability = 44.0 / 16384.0, .tolerance = 0.0003 },
    .{ .threshold = 3.5, .expected_probability = 8.0 / 16384.0, .tolerance = 0.0001 },
    .{ .threshold = 4.0, .expected_probability = 2.0 / 16384.0, .tolerance = 0.00005 },
};

const exponential_table_tail_specs = [_]TailSpec{
    .{ .threshold = 4.0, .expected_probability = 300.0 / 16384.0, .tolerance = 0.0010 },
    .{ .threshold = 6.0, .expected_probability = 41.0 / 16384.0, .tolerance = 0.0003 },
    .{ .threshold = 8.0, .expected_probability = 5.0 / 16384.0, .tolerance = 0.00012 },
    .{ .threshold = 10.0, .expected_probability = 1.0 / 16384.0, .tolerance = 0.00005 },
};

const exponential_approx_log_tail_specs = [_]TailSpec{
    .{ .threshold = 4.0, .expected_probability = 0.018315639, .tolerance = 0.0012 },
    .{ .threshold = 6.0, .expected_probability = 0.002478752, .tolerance = 0.00035 },
    .{ .threshold = 8.0, .expected_probability = 0.000335463, .tolerance = 0.00016 },
    .{ .threshold = 10.0, .expected_probability = 0.000045400, .tolerance = 0.00005 },
};

pub fn main(init: std.process.Init) !void {
    if (builtin.target.os.tag == .wasi) {
        try runChecks(null);
        std.debug.print("profiletailcheck ok\n", .{});
        return;
    }

    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    try runChecks(stdout);
    try stdout.print("profiletailcheck ok\n", .{});
    try stdout.flush();
}

fn runChecks(stdout: ?*std.Io.Writer) !void {
    try checkSymmetricTailProfile(.normal_table_f32, "VectorStandardNormalTableF32", 0x5741_7a_f32, &normal_table_tail_specs, 4.0, 4.02, stdout);
    try checkSymmetricTailProfile(.normal_table_f64, "VectorStandardNormalTableF64", 0x5741_7a_f64, &normal_table_tail_specs, 4.0, 4.02, stdout);
    try checkPositiveTailProfile(.exponential_table_f32, "VectorStandardExponentialTableF32", 0x5741_e1_f32, &exponential_table_tail_specs, 10.0, 10.41, stdout);
    try checkPositiveTailProfile(.exponential_table_f64, "VectorStandardExponentialTableF64", 0x5741_e1_f64, &exponential_table_tail_specs, 10.0, 10.41, stdout);
    try checkPositiveTailProfile(.exponential_approx_log_f32, "VectorStandardExponentialApproxLogF32", 0x5741_a1_f32, &exponential_approx_log_tail_specs, 10.0, 20.0, stdout);
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

fn checkSymmetricTailProfile(
    comptime profile: Profile,
    comptime name: []const u8,
    seed: u64,
    comptime specs: []const TailSpec,
    min_max_abs: f64,
    max_max_abs: f64,
    stdout: ?*std.Io.Writer,
) !void {
    const VectorType = profileVectorType(profile);
    const info = @typeInfo(VectorType).vector;
    const vectors = lanes_per_profile / info.len;
    var abs_counts: [specs.len]usize = .{0} ** specs.len;
    var positive_counts: [specs.len]usize = .{0} ** specs.len;
    var negative_counts: [specs.len]usize = .{0} ** specs.len;
    var max_abs: f64 = 0;

    var engine = alea.ScalarPrng.init(seed);
    var i: usize = 0;
    while (i < vectors) : (i += 1) {
        const sample = sampleProfile(profile, &engine);
        inline for (0..info.len) |lane| {
            const value: f64 = @floatCast(sample[lane]);
            if (!std.math.isFinite(value)) return error.ProfileTailCheckFailed;
            max_abs = @max(max_abs, @abs(value));
            inline for (specs, 0..) |spec, index| {
                abs_counts[index] += @intFromBool(@abs(value) >= spec.threshold);
                positive_counts[index] += @intFromBool(value >= spec.threshold);
                negative_counts[index] += @intFromBool(value <= -spec.threshold);
            }
        }
    }

    const lanes: f64 = @floatFromInt(vectors * info.len);
    try expectFloatBetween(name, "max_abs", max_abs, min_max_abs, max_max_abs);
    try emit(stdout, "{s}: lanes={} max_abs={d:.8}\n", .{ name, vectors * info.len, max_abs });
    inline for (specs, 0..) |spec, index| {
        const observed = @as(f64, @floatFromInt(abs_counts[index])) / lanes;
        const observed_pos = @as(f64, @floatFromInt(positive_counts[index])) / lanes;
        const observed_neg = @as(f64, @floatFromInt(negative_counts[index])) / lanes;
        try expectProbability(name, "two-sided tail", observed, spec.expected_probability, spec.tolerance);
        try expectProbability(name, "positive tail", observed_pos, spec.expected_probability * 0.5, spec.tolerance * 0.65);
        try expectProbability(name, "negative tail", observed_neg, spec.expected_probability * 0.5, spec.tolerance * 0.65);
        try emit(stdout, "  abs_tail(|x|>={d:.1})={d:.8} pos={d:.8} neg={d:.8} expected={d:.8}\n", .{ spec.threshold, observed, observed_pos, observed_neg, spec.expected_probability });
    }
}

fn checkPositiveTailProfile(
    comptime profile: Profile,
    comptime name: []const u8,
    seed: u64,
    comptime specs: []const TailSpec,
    min_max: f64,
    max_max: f64,
    stdout: ?*std.Io.Writer,
) !void {
    const VectorType = profileVectorType(profile);
    const info = @typeInfo(VectorType).vector;
    const vectors = lanes_per_profile / info.len;
    var counts: [specs.len]usize = .{0} ** specs.len;
    var min_value: f64 = std.math.inf(f64);
    var max_value: f64 = -std.math.inf(f64);

    var engine = alea.ScalarPrng.init(seed);
    var i: usize = 0;
    while (i < vectors) : (i += 1) {
        const sample = sampleProfile(profile, &engine);
        inline for (0..info.len) |lane| {
            const value: f64 = @floatCast(sample[lane]);
            if (!std.math.isFinite(value) or value < 0) return error.ProfileTailCheckFailed;
            min_value = @min(min_value, value);
            max_value = @max(max_value, value);
            inline for (specs, 0..) |spec, index| counts[index] += @intFromBool(value >= spec.threshold);
        }
    }

    const lanes: f64 = @floatFromInt(vectors * info.len);
    try expectFloatBetween(name, "max", max_value, min_max, max_max);
    try emit(stdout, "{s}: lanes={} min={d:.8} max={d:.8}\n", .{ name, vectors * info.len, min_value, max_value });
    inline for (specs, 0..) |spec, index| {
        const observed = @as(f64, @floatFromInt(counts[index])) / lanes;
        try expectProbability(name, "upper tail", observed, spec.expected_probability, spec.tolerance);
        try emit(stdout, "  tail(x>={d:.1})={d:.8} expected={d:.8}\n", .{ spec.threshold, observed, spec.expected_probability });
    }
}

fn expectProbability(comptime profile_name: []const u8, comptime metric: []const u8, value: f64, expected: f64, tolerance: f64) !void {
    try expectFloatBetween(profile_name, metric, value, probabilityMin(expected, tolerance), probabilityMax(expected, tolerance));
}

fn expectFloatBetween(comptime profile_name: []const u8, comptime metric: []const u8, value: f64, min: f64, max: f64) !void {
    if (!floatInClosedRange(value, min, max)) {
        std.debug.print("{s} {s}: {d:.8} not in [{d:.8}, {d:.8}]\n", .{ profile_name, metric, value, min, max });
        return error.ProfileTailCheckFailed;
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

test "profile tail vector type selection matches accepted profiles" {
    try std.testing.expectEqual(@as(usize, 8), @typeInfo(profileVectorType(.normal_table_f32)).vector.len);
    try std.testing.expectEqual(@as(usize, 4), @typeInfo(profileVectorType(.normal_table_f64)).vector.len);
    try std.testing.expectEqual(@as(usize, 8), @typeInfo(profileVectorType(.exponential_approx_log_f32)).vector.len);
}

test "tail probability bounds clamp to valid probability range" {
    try std.testing.expectEqual(@as(f64, 0.0), probabilityMin(0.01, 0.02));
    try std.testing.expectEqual(@as(f64, 0.4), probabilityMin(0.5, 0.1));
    try std.testing.expectEqual(@as(f64, 0.6), probabilityMax(0.5, 0.1));
    try std.testing.expectEqual(@as(f64, 1.0), probabilityMax(0.99, 0.02));
}

test "tail float closed-range predicate accepts boundaries and rejects NaN" {
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
