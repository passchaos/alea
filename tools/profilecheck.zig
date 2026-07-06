const std = @import("std");
const alea = @import("alea");
const builtin = @import("builtin");

const lanes_per_profile = 1_048_576;

const Profile = enum {
    normal_table_f32,
    normal_table_f64,
    exponential_table_f32,
    exponential_table_f64,
    exponential_approx_log_f32,
};

const normal_thresholds = [_]f64{ -3, -2, -1, 0, 1, 2, 3 };
const normal_expected = [_]f64{ 0.001349898, 0.022750132, 0.158655254, 0.5, 0.841344746, 0.977249868, 0.998650102 };

const exponential_thresholds = [_]f64{ 0.1, 0.25, 0.5, 1, 2, 4, 6 };
const exponential_expected = [_]f64{ 0.095162582, 0.221199217, 0.393469340, 0.632120559, 0.864664717, 0.981684361, 0.997521248 };

pub fn main(init: std.process.Init) !void {
    if (builtin.target.os.tag == .wasi) {
        try runChecks(null);
        std.debug.print("profilecheck ok\n", .{});
        return;
    }

    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    try runChecks(stdout);
    try stdout.print("profilecheck ok\n", .{});
    try stdout.flush();
}

fn runChecks(stdout: ?*std.Io.Writer) !void {
    try checkProfile(.normal_table_f32, "VectorStandardNormalTableF32", 0x51_40_6d_f32, &normal_thresholds, &normal_expected, -0.006, 0.006, 0.985, 1.015, 0.006, stdout);
    try checkProfile(.normal_table_f64, "VectorStandardNormalTableF64", 0x51_40_6d_f64, &normal_thresholds, &normal_expected, -0.006, 0.006, 0.985, 1.015, 0.006, stdout);
    try checkProfile(.exponential_table_f32, "VectorStandardExponentialTableF32", 0x51_40_e1_f32, &exponential_thresholds, &exponential_expected, 0.992, 1.008, 0.975, 1.025, 0.006, stdout);
    try checkProfile(.exponential_table_f64, "VectorStandardExponentialTableF64", 0x51_40_e1_f64, &exponential_thresholds, &exponential_expected, 0.992, 1.008, 0.975, 1.025, 0.006, stdout);
    try checkProfile(.exponential_approx_log_f32, "VectorStandardExponentialApproxLogF32", 0x51_40_a1_f32, &exponential_thresholds, &exponential_expected, 0.990, 1.010, 0.965, 1.035, 0.008, stdout);
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

fn checkProfile(
    comptime profile: Profile,
    comptime name: []const u8,
    seed: u64,
    comptime thresholds: anytype,
    comptime expected: anytype,
    min_mean: f64,
    max_mean: f64,
    min_variance: f64,
    max_variance: f64,
    cdf_tolerance: f64,
    stdout: ?*std.Io.Writer,
) !void {
    if (thresholds.len != expected.len) @compileError("threshold and expected CDF lengths must match");

    const VectorType = profileVectorType(profile);
    const info = @typeInfo(VectorType).vector;
    const vectors = lanes_per_profile / info.len;
    var counts: [thresholds.len]usize = .{0} ** thresholds.len;
    var sum: f64 = 0;
    var sum_squares: f64 = 0;
    var min_value: f64 = std.math.inf(f64);
    var max_value: f64 = -std.math.inf(f64);

    var engine = alea.ScalarPrng.init(seed);
    var i: usize = 0;
    while (i < vectors) : (i += 1) {
        const sample = sampleProfile(profile, &engine);
        inline for (0..info.len) |lane| {
            const value: f64 = @floatCast(sample[lane]);
            if (!std.math.isFinite(value)) return error.ProfileCheckFailed;
            sum += value;
            sum_squares += value * value;
            min_value = @min(min_value, value);
            max_value = @max(max_value, value);
            inline for (thresholds, 0..) |threshold, cdf_index| {
                counts[cdf_index] += @intFromBool(value <= threshold);
            }
        }
    }

    const lanes: f64 = @floatFromInt(vectors * info.len);
    const mean = sum / lanes;
    const variance = sum_squares / lanes - mean * mean;

    try expectFloatBetween(name, "mean", mean, min_mean, max_mean);
    try expectFloatBetween(name, "variance", variance, min_variance, max_variance);

    try emit(stdout, "{s}: lanes={} mean={d:.8} variance={d:.8} min={d:.8} max={d:.8}\n", .{ name, vectors * info.len, mean, variance, min_value, max_value });
    inline for (thresholds, 0..) |threshold, cdf_index| {
        const observed = @as(f64, @floatFromInt(counts[cdf_index])) / lanes;
        const expected_value = expected[cdf_index];
        try expectFloatBetween(name, "cdf", observed, @max(0, expected_value - cdf_tolerance), @min(1, expected_value + cdf_tolerance));
        try emit(stdout, "  cdf({d:.2})={d:.8} expected={d:.8}\n", .{ threshold, observed, expected_value });
    }
}

fn expectFloatBetween(comptime profile_name: []const u8, comptime metric: []const u8, value: f64, min: f64, max: f64) !void {
    if (!floatInClosedRange(value, min, max)) {
        std.debug.print("{s} {s}: {d:.8} not in [{d:.8}, {d:.8}]\n", .{ profile_name, metric, value, min, max });
        return error.ProfileCheckFailed;
    }
}

fn floatInClosedRange(value: f64, min: f64, max: f64) bool {
    return value >= min and value <= max;
}

test "profile vector type selection matches accepted profiles" {
    try std.testing.expectEqual(@as(usize, 8), @typeInfo(profileVectorType(.normal_table_f32)).vector.len);
    try std.testing.expectEqual(@as(usize, 4), @typeInfo(profileVectorType(.normal_table_f64)).vector.len);
    try std.testing.expectEqual(@as(usize, 8), @typeInfo(profileVectorType(.exponential_approx_log_f32)).vector.len);
}

test "float closed-range predicate accepts boundaries and rejects NaN" {
    try std.testing.expect(floatInClosedRange(0.0, 0.0, 1.0));
    try std.testing.expect(floatInClosedRange(1.0, 0.0, 1.0));
    try std.testing.expect(floatInClosedRange(0.5, 0.0, 1.0));
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
