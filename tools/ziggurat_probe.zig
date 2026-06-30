const std = @import("std");
const alea = @import("alea");

const ziggurat = std.Random.ziggurat;

const trials = 3;
const default_count = 16 * 1024 * 1024;

const norm_ratio = blk: {
    var out: [256]f64 = undefined;
    for (&out, 0..) |*item, i| item.* = ziggurat.NormDist.x[i + 1] / ziggurat.NormDist.x[i];
    break :blk out;
};

const norm_threshold = blk: {
    var out: [256]u64 = undefined;
    for (&out, 0..) |*item, i| {
        const ratio = ziggurat.NormDist.x[i + 1] / ziggurat.NormDist.x[i];
        item.* = @intFromFloat(@ceil(ratio * @as(f64, @floatFromInt(@as(u64, 1) << 51))));
    }
    break :blk out;
};

const norm_lower_threshold = blk: {
    var out: [256]u64 = undefined;
    for (&out, 0..) |*item, i| item.* = (@as(u64, 1) << 51) - norm_threshold[i];
    break :blk out;
};

const norm_upper_threshold = blk: {
    var out: [256]u64 = undefined;
    for (&out, 0..) |*item, i| item.* = (@as(u64, 1) << 51) + norm_threshold[i];
    break :blk out;
};

const exp_ratio = blk: {
    var out: [256]f64 = undefined;
    for (&out, 0..) |*item, i| item.* = ziggurat.ExpDist.x[i + 1] / ziggurat.ExpDist.x[i];
    break :blk out;
};

const exp_threshold = blk: {
    var out: [256]u64 = undefined;
    for (&out, 0..) |*item, i| {
        const ratio = ziggurat.ExpDist.x[i + 1] / ziggurat.ExpDist.x[i];
        item.* = @intFromFloat(@ceil(ratio * @as(f64, @floatFromInt(@as(u64, 1) << 52)) - 0.5));
    }
    break :blk out;
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var args = std.process.Args.Iterator.init(init.minimal.args);
    defer args.deinit();
    _ = args.next();
    const sample_count = if (args.next()) |arg|
        std.fmt.parseInt(usize, arg, 10) catch default_count
    else
        default_count;

    try stdout.print("ziggurat probe count={}\n", .{sample_count});
    try benchF64(io, stdout, "generic normalFastFrom", sample_count, 0xd15a, genericNormal);
    try benchF64(io, stdout, "standard normal raw", sample_count, 0xd15a, standardNormal);
    try benchF64(io, stdout, "ratio normal inline candidate", sample_count, 0xd15a, ratioNormal);
    try benchF64(io, stdout, "mantissa-threshold normal candidate", sample_count, 0xd15a, thresholdNormal);
    try benchF64(io, stdout, "mantissa-range normal candidate", sample_count, 0xd15a, thresholdRangeNormal);
    try benchF64(io, stdout, "table-bound normal candidate", sample_count, 0xd15a, tableBoundNormal);
    try benchF64(io, stdout, "generic exponentialFastFrom", sample_count, 0xe15a, genericExponential);
    try benchF64(io, stdout, "standard exponential raw", sample_count, 0xe15a, standardExponential);
    try benchF64(io, stdout, "ratio exponential inline candidate", sample_count, 0xe15a, ratioExponential);
    try benchF64(io, stdout, "mantissa-threshold exponential candidate", sample_count, 0xe15a, thresholdExponential);
    try benchF64(io, stdout, "table-bound exponential candidate", sample_count, 0xe15a, tableBoundExponential);
    try benchVectorF64(io, stdout, "vector-repair normal f64x4 candidate", sample_count, 0xd15a, vectorRepairNormal);
    try benchVectorF64(io, stdout, "vector-repair exponential f64x4 candidate", sample_count, 0xe15a, vectorRepairExponential);
    try stdout.flush();
}

fn benchF64(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    sample_count: usize,
    seed: u64,
    comptime sampleFn: anytype,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var checksum: f64 = 0;
        var i: usize = 0;
        while (i < sample_count) : (i += 1) checksum += sampleFn(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(sample_count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorF64(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    sample_count: usize,
    seed: u64,
    comptime sampleFn: anytype,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const vector_count = sample_count / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var checksum: f64 = 0;
        var i: usize = 0;
        while (i < vector_count) : (i += 1) {
            const vec = sampleFn(&engine);
            inline for (0..4) |lane| checksum += vec[lane];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn genericNormal(engine: *alea.ScalarPrng) f64 {
    return alea.Rng.normalFastFrom(engine, f64, 0, 1);
}

fn standardNormal(engine: *alea.ScalarPrng) f64 {
    return alea.Rng.standardNormalFastFrom(engine, f64);
}

fn genericExponential(engine: *alea.ScalarPrng) f64 {
    return alea.Rng.exponentialFastFrom(engine, f64, 1);
}

fn standardExponential(engine: *alea.ScalarPrng) f64 {
    return alea.Rng.standardExponentialFastFrom(engine, f64);
}

fn ratioNormal(engine: *alea.ScalarPrng) f64 {
    while (true) {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;

        if (@abs(u) < norm_ratio[i]) {
            @branchHint(.likely);
            return u * ziggurat.NormDist.x[i];
        }
        const x = u * ziggurat.NormDist.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return normalTail(engine, u);
        }
        if (ziggurat.NormDist.f[i + 1] + (ziggurat.NormDist.f[i] - ziggurat.NormDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x * x / 2.0)) return x;
    }
}

fn tableBoundNormal(engine: *alea.ScalarPrng) f64 {
    while (true) {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        const x = u * ziggurat.NormDist.x[i];

        if (@abs(x) < ziggurat.NormDist.x[i + 1]) {
            @branchHint(.likely);
            return x;
        }
        if (i == 0) {
            @branchHint(.unlikely);
            return normalTail(engine, u);
        }
        if (ziggurat.NormDist.f[i + 1] + (ziggurat.NormDist.f[i] - ziggurat.NormDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x * x / 2.0)) return x;
    }
}

fn thresholdNormal(engine: *alea.ScalarPrng) f64 {
    while (true) {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x400) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        const abs_mantissa = if (mantissa >= (@as(u64, 1) << 51))
            mantissa - (@as(u64, 1) << 51)
        else
            (@as(u64, 1) << 51) - mantissa;

        if (abs_mantissa < norm_threshold[i]) {
            @branchHint(.likely);
            return u * ziggurat.NormDist.x[i];
        }
        const x = u * ziggurat.NormDist.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return normalTail(engine, u);
        }
        if (ziggurat.NormDist.f[i + 1] + (ziggurat.NormDist.f[i] - ziggurat.NormDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x * x / 2.0)) return x;
    }
}

fn thresholdRangeNormal(engine: *alea.ScalarPrng) f64 {
    while (true) {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x400) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;

        if (mantissa > norm_lower_threshold[i] and mantissa < norm_upper_threshold[i]) {
            @branchHint(.likely);
            return u * ziggurat.NormDist.x[i];
        }
        const x = u * ziggurat.NormDist.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return normalTail(engine, u);
        }
        if (ziggurat.NormDist.f[i + 1] + (ziggurat.NormDist.f[i] - ziggurat.NormDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x * x / 2.0)) return x;
    }
}

fn normalTail(engine: *alea.ScalarPrng, u: f64) f64 {
    var x: f64 = 1;
    var y: f64 = 0;
    while (-2.0 * y < x * x) {
        x = @log(alea.Rng.floatFrom(engine, f64)) / ziggurat.norm_r;
        y = @log(alea.Rng.floatFrom(engine, f64));
    }
    return if (u < 0) x - ziggurat.norm_r else ziggurat.norm_r - x;
}

fn ratioExponential(engine: *alea.ScalarPrng) f64 {
    while (true) {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x3ff) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);

        if (u < exp_ratio[i]) {
            @branchHint(.likely);
            return u * ziggurat.ExpDist.x[i];
        }
        const x = u * ziggurat.ExpDist.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return ziggurat.exp_r - @log(alea.Rng.floatFrom(engine, f64));
        }
        if (ziggurat.ExpDist.f[i + 1] + (ziggurat.ExpDist.f[i] - ziggurat.ExpDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x)) return x;
    }
}

fn tableBoundExponential(engine: *alea.ScalarPrng) f64 {
    while (true) {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x3ff) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
        const x = u * ziggurat.ExpDist.x[i];

        if (x < ziggurat.ExpDist.x[i + 1]) {
            @branchHint(.likely);
            return x;
        }
        if (i == 0) {
            @branchHint(.unlikely);
            return ziggurat.exp_r - @log(alea.Rng.floatFrom(engine, f64));
        }
        if (ziggurat.ExpDist.f[i + 1] + (ziggurat.ExpDist.f[i] - ziggurat.ExpDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x)) return x;
    }
}

fn thresholdExponential(engine: *alea.ScalarPrng) f64 {
    while (true) {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);

        if (mantissa < exp_threshold[i]) {
            @branchHint(.likely);
            return u * ziggurat.ExpDist.x[i];
        }
        const x = u * ziggurat.ExpDist.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return ziggurat.exp_r - @log(alea.Rng.floatFrom(engine, f64));
        }
        if (ziggurat.ExpDist.f[i + 1] + (ziggurat.ExpDist.f[i] - ziggurat.ExpDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x)) return x;
    }
}

fn vectorRepairNormal(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const VecF64 = @Vector(4, f64);
    const VecU64 = @Vector(4, u64);

    var bits: VecU64 = undefined;
    inline for (0..4) |lane| bits[lane] = engine.next();

    var ratios: VecF64 = undefined;
    var x_values: VecF64 = undefined;
    var out: VecF64 = undefined;
    inline for (0..4) |lane| {
        const i: usize = @as(u8, @truncate(bits[lane]));
        const repr = (@as(u64, 0x400) << 52) | (bits[lane] >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        ratios[lane] = norm_ratio[i];
        x_values[lane] = u * ziggurat.NormDist.x[i];
        out[lane] = x_values[lane];
    }

    const reprs = (@as(VecU64, @splat(@as(u64, 0x400) << 52)) | (bits >> @as(VecU64, @splat(12))));
    const u_values: VecF64 = @as(VecF64, @bitCast(reprs)) - @as(VecF64, @splat(3.0));
    const mask = @abs(u_values) < ratios;
    inline for (0..4) |lane| {
        if (!mask[lane]) out[lane] = ratioNormal(engine);
    }
    return out;
}

fn vectorRepairExponential(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const VecF64 = @Vector(4, f64);
    const VecU64 = @Vector(4, u64);

    var bits: VecU64 = undefined;
    inline for (0..4) |lane| bits[lane] = engine.next();

    var ratios: VecF64 = undefined;
    var out: VecF64 = undefined;
    inline for (0..4) |lane| {
        const i: usize = @as(u8, @truncate(bits[lane]));
        const repr = (@as(u64, 0x3ff) << 52) | (bits[lane] >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
        ratios[lane] = exp_ratio[i];
        out[lane] = u * ziggurat.ExpDist.x[i];
    }

    const reprs = (@as(VecU64, @splat(@as(u64, 0x3ff) << 52)) | (bits >> @as(VecU64, @splat(12))));
    const u_values: VecF64 = @as(VecF64, @bitCast(reprs)) - @as(VecF64, @splat(1.0 - std.math.floatEps(f64) / 2.0));
    const mask = u_values < ratios;
    inline for (0..4) |lane| {
        if (!mask[lane]) out[lane] = ratioExponential(engine);
    }
    return out;
}
