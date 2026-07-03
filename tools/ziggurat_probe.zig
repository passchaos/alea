const std = @import("std");
const alea = @import("alea");

const ziggurat = std.Random.ziggurat;

const trials = 3;
const default_count: usize = 16 * 1024 * 1024;

const alea4x64_increment = [_]u64{
    0xa0761d6478bd642f,
    0xe7037ed1a0b428db,
    0x8ebc6af09c88c6e3,
    0x589965cc75374cc3,
};

var probe_filter: ?[]const u8 = null;

fn shouldRun(name: []const u8) bool {
    return probe_filter == null or std.mem.indexOf(u8, name, probe_filter.?) != null;
}

const norm_ratio = blk: {
    var out: [256]f64 = undefined;
    for (&out, 0..) |*item, i| item.* = ziggurat.NormDist.x[i + 1] / ziggurat.NormDist.x[i];
    break :blk out;
};

const norm_ratio_f32 = blk: {
    var out: [256]f32 = undefined;
    for (&out, 0..) |*item, i| item.* = @floatCast(ziggurat.NormDist.x[i + 1] / ziggurat.NormDist.x[i]);
    break :blk out;
};

const norm_x_f32 = blk: {
    var out: [257]f32 = undefined;
    for (&out, 0..) |*item, i| item.* = @floatCast(ziggurat.NormDist.x[i]);
    break :blk out;
};

const norm_f_f32 = blk: {
    var out: [257]f32 = undefined;
    for (&out, 0..) |*item, i| item.* = @floatCast(ziggurat.NormDist.f[i]);
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

const exp_threshold_f32 = blk: {
    var out: [256]u32 = undefined;
    for (&out, 0..) |*item, i| {
        const ratio = ziggurat.ExpDist.x[i + 1] / ziggurat.ExpDist.x[i];
        item.* = @intFromFloat(@ceil(ratio * @as(f64, @floatFromInt(@as(u32, 1) << 23)) - 0.5));
    }
    break :blk out;
};

const exp_x_f32 = blk: {
    var out: [257]f32 = undefined;
    for (&out, 0..) |*item, i| item.* = @floatCast(ziggurat.ExpDist.x[i]);
    break :blk out;
};

const exp_f_f32 = blk: {
    var out: [257]f32 = undefined;
    for (&out, 0..) |*item, i| item.* = @floatCast(ziggurat.ExpDist.f[i]);
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
    var sample_count = default_count;
    if (args.next()) |arg| {
        sample_count = std.fmt.parseInt(usize, arg, 10) catch blk: {
            probe_filter = arg;
            break :blk sample_count;
        };
    }
    if (args.next()) |arg| probe_filter = arg;

    try stdout.print("ziggurat probe count={} filter={s}\n", .{ sample_count, probe_filter orelse "<all>" });
    try benchF64(io, stdout, "generic normalFastFrom", sample_count, 0xd15a, genericNormal);
    try benchF64(io, stdout, "standard normal raw", sample_count, 0xd15a, standardNormal);
    try benchF64(io, stdout, "ratio normal inline candidate", sample_count, 0xd15a, ratioNormal);
    try benchF64(io, stdout, "mantissa-threshold normal candidate", sample_count, 0xd15a, thresholdNormal);
    try benchF64(io, stdout, "mantissa-range normal candidate", sample_count, 0xd15a, thresholdRangeNormal);
    try benchF64(io, stdout, "table-bound normal candidate", sample_count, 0xd15a, tableBoundNormal);
    try benchF32(io, stdout, "standard normal f32 raw", sample_count, 0xd15a, standardNormalF32);
    try benchF32(io, stdout, "ratio normal f32 cast candidate", sample_count, 0xd15a, ratioNormalF32);
    try benchF32(io, stdout, "table-bound normal f32 cast candidate", sample_count, 0xd15a, tableBoundNormalF32);
    try benchF32(io, stdout, "native normal f32 candidate", sample_count, 0xd15a, nativeNormalF32);
    try benchF64(io, stdout, "generic exponentialFastFrom", sample_count, 0xe15a, genericExponential);
    try benchF64(io, stdout, "standard exponential raw", sample_count, 0xe15a, standardExponential);
    try benchF64(io, stdout, "ratio exponential inline candidate", sample_count, 0xe15a, ratioExponential);
    try benchF64(io, stdout, "mantissa-threshold exponential candidate", sample_count, 0xe15a, thresholdExponential);
    try benchF64(io, stdout, "table-bound exponential candidate", sample_count, 0xe15a, tableBoundExponential);
    try benchF32(io, stdout, "standard exponential f32 raw", sample_count, 0xe15a, standardExponentialF32);
    try benchF32(io, stdout, "threshold exponential f32 cast candidate", sample_count, 0xe15a, thresholdExponentialF32);
    try benchF32(io, stdout, "native exponential f32 candidate", sample_count, 0xe15a, nativeExponentialF32);
    try benchVectorF64(io, stdout, "vector-repair normal f64x4 candidate", sample_count, 0xd15a, vectorRepairNormal);
    try benchVectorF64(io, stdout, "vector-repair exponential f64x4 candidate", sample_count, 0xe15a, vectorRepairExponential);
    try benchVectorF64Fast(io, stdout, "alea4x64-lane scalar normal f64x4", sample_count, 0xd15a, vectorLaneNormalAlea4x64Scalar);
    try benchVectorF64Fast(io, stdout, "alea4x64-lane vector-repair normal f64x4 candidate", sample_count, 0xd15a, vectorRepairNormalAlea4x64Lanes);
    try benchVectorF64Fast(io, stdout, "alea4x64-lane scalar exponential f64x4", sample_count, 0xe15a, vectorLaneExponentialAlea4x64Scalar);
    try benchVectorF64Fast(io, stdout, "alea4x64-lane vector-repair exponential f64x4 candidate", sample_count, 0xe15a, vectorRepairExponentialAlea4x64Lanes);
    try benchVectorF32(io, stdout, "vector-repair normal f32x8 candidate", sample_count, 0xd15a, vectorRepairNormalF32);
    try benchVectorF32(io, stdout, "vector-repair exponential f32x8 candidate", sample_count, 0xe15a, vectorRepairExponentialF32);
    try benchVectorF32(io, stdout, "vector-repair normal f32x8 correct", sample_count, 0xd15a, vectorRepairNormalF32Correct);
    try benchVectorF32(io, stdout, "vector-repair exponential f32x8 correct", sample_count, 0xe15a, vectorRepairExponentialF32Correct);
    try benchVectorF32Fast(io, stdout, "alea4x64-lane scalar normal f32x8", sample_count, 0xd15a, vectorLaneNormalF32Alea4x64Scalar);
    try benchVectorF32Fast(io, stdout, "alea4x64-lane vector-repair normal f32x8 candidate", sample_count, 0xd15a, vectorRepairNormalF32Alea4x64Lanes);
    try benchVectorF32Fast(io, stdout, "alea4x64-lane scalar exponential f32x8", sample_count, 0xe15a, vectorLaneExponentialF32Alea4x64Scalar);
    try benchVectorF32Fast(io, stdout, "alea4x64-lane vector-repair exponential f32x8 candidate", sample_count, 0xe15a, vectorRepairExponentialF32Alea4x64Lanes);
    try benchVectorF32Fast(io, stdout, "fast vector-repair normal f32x8 candidate", sample_count, 0xd15a, vectorRepairNormalF32Fast);
    try benchVectorF32Fast(io, stdout, "fast vector-repair exponential f32x8 candidate", sample_count, 0xe15a, vectorRepairExponentialF32Fast);
    try benchVectorF32Fast(io, stdout, "fast vector-repair normal f32x8 correct", sample_count, 0xd15a, vectorRepairNormalF32FastCorrect);
    try benchVectorF32Fast(io, stdout, "fast vector-repair exponential f32x8 correct", sample_count, 0xe15a, vectorRepairExponentialF32FastCorrect);
    try benchFillF32Fast(io, stdout, "fast standard normal f32 fill current", sample_count, 0xd15a, currentStandardNormalF32FillFast);
    try benchFillF32Fast(io, stdout, "fast alea4x64-lane standard normal f32 fill", sample_count, 0xd15a, laneStandardNormalF32FillFast);
    try benchFillF32Fast(io, stdout, "fast standard exponential f32 fill current", sample_count, 0xe15a, currentStandardExponentialF32FillFast);
    try benchFillF32Fast(io, stdout, "fast alea4x64-lane standard exponential f32 fill", sample_count, 0xe15a, laneStandardExponentialF32FillFast);
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
    if (!shouldRun(name)) return;
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

fn benchF32(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    sample_count: usize,
    seed: u64,
    comptime sampleFn: anytype,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var checksum: f32 = 0;
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
    if (!shouldRun(name)) return;
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

fn benchVectorF32(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    sample_count: usize,
    seed: u64,
    comptime sampleFn: anytype,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    const vector_count = sample_count / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var checksum: f32 = 0;
        var i: usize = 0;
        while (i < vector_count) : (i += 1) {
            const vec = sampleFn(&engine);
            inline for (0..8) |lane| checksum += vec[lane];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorF32Fast(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    sample_count: usize,
    seed: u64,
    comptime sampleFn: anytype,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    const vector_count = sample_count / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var checksum: f32 = 0;
        var i: usize = 0;
        while (i < vector_count) : (i += 1) {
            const vec = sampleFn(&engine);
            inline for (0..8) |lane| checksum += vec[lane];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorF64Fast(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    sample_count: usize,
    seed: u64,
    comptime sampleFn: anytype,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const vector_count = sample_count / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(seed);
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

fn benchFillF32Fast(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    sample_count: usize,
    seed: u64,
    comptime fillFn: anytype,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = sample_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
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

fn genericNormal(engine: *alea.ScalarPrng) f64 {
    return alea.Rng.normalFastFrom(engine, f64, 0, 1);
}

fn standardNormal(engine: *alea.ScalarPrng) f64 {
    return alea.Rng.standardNormalFastFrom(engine, f64);
}

fn standardNormalF32(engine: *alea.ScalarPrng) f32 {
    return alea.Rng.standardNormalFastFrom(engine, f32);
}

fn ratioNormalF32(engine: *alea.ScalarPrng) f32 {
    return @floatCast(ratioNormal(engine));
}

fn tableBoundNormalF32(engine: *alea.ScalarPrng) f32 {
    return @floatCast(tableBoundNormal(engine));
}

fn nativeNormalF32(engine: *alea.ScalarPrng) f32 {
    while (true) {
        const bits: u32 = @truncate(engine.next());
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 9;
        const repr = (@as(u32, 0x80) << 23) | mantissa;
        const u: f32 = @as(f32, @bitCast(repr)) - 3.0;

        if (@abs(u) < norm_ratio_f32[i]) {
            @branchHint(.likely);
            return u * norm_x_f32[i];
        }
        const x = u * norm_x_f32[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return nativeNormalTailF32(engine, u);
        }
        if (norm_f_f32[i + 1] + (norm_f_f32[i] - norm_f_f32[i + 1]) * alea.Rng.floatFrom(engine, f32) < @exp(-x * x / 2.0)) return x;
    }
}

fn nativeNormalTailF32(engine: *alea.ScalarPrng, u: f32) f32 {
    var x: f32 = 1;
    var y: f32 = 0;
    while (-2.0 * y < x * x) {
        x = @log(alea.Rng.floatOpenFrom(engine, f32)) / @as(f32, @floatCast(ziggurat.norm_r));
        y = @log(alea.Rng.floatOpenFrom(engine, f32));
    }
    return if (u < 0) x - @as(f32, @floatCast(ziggurat.norm_r)) else @as(f32, @floatCast(ziggurat.norm_r)) - x;
}

fn genericExponential(engine: *alea.ScalarPrng) f64 {
    return alea.Rng.exponentialFastFrom(engine, f64, 1);
}

fn standardExponential(engine: *alea.ScalarPrng) f64 {
    return alea.Rng.standardExponentialFastFrom(engine, f64);
}

fn standardExponentialF32(engine: *alea.ScalarPrng) f32 {
    return alea.Rng.standardExponentialFastFrom(engine, f32);
}

fn thresholdExponentialF32(engine: *alea.ScalarPrng) f32 {
    return @floatCast(thresholdExponential(engine));
}

fn nativeExponentialF32(engine: *alea.ScalarPrng) f32 {
    while (true) {
        const bits: u32 = @truncate(engine.next());
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 9;
        const repr = (@as(u32, 0x7f) << 23) | mantissa;
        const u: f32 = @as(f32, @bitCast(repr)) - (1.0 - std.math.floatEps(f32) / 2.0);

        if (mantissa < exp_threshold_f32[i]) {
            @branchHint(.likely);
            return u * exp_x_f32[i];
        }
        const x = u * exp_x_f32[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return @as(f32, @floatCast(ziggurat.exp_r)) - @log(alea.Rng.floatOpenFrom(engine, f32));
        }
        if (exp_f_f32[i + 1] + (exp_f_f32[i] - exp_f_f32[i + 1]) * alea.Rng.floatFrom(engine, f32) < @exp(-x)) return x;
    }
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
        x = @log(alea.Rng.floatOpenFrom(engine, f64)) / ziggurat.norm_r;
        y = @log(alea.Rng.floatOpenFrom(engine, f64));
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
            return ziggurat.exp_r - @log(alea.Rng.floatOpenFrom(engine, f64));
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
            return ziggurat.exp_r - @log(alea.Rng.floatOpenFrom(engine, f64));
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
            return ziggurat.exp_r - @log(alea.Rng.floatOpenFrom(engine, f64));
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

fn vectorLaneNormalAlea4x64Scalar(engine: *alea.FastPrng) @Vector(4, f64) {
    const lanes = nextAlea4x64Lanes(engine);
    var out: @Vector(4, f64) = undefined;
    inline for (0..4) |lane| out[lane] = ratioNormalAlea4x64Lane(engine, lane, lanes[lane]);
    return out;
}

fn vectorLaneExponentialAlea4x64Scalar(engine: *alea.FastPrng) @Vector(4, f64) {
    const lanes = nextAlea4x64Lanes(engine);
    var out: @Vector(4, f64) = undefined;
    inline for (0..4) |lane| out[lane] = thresholdExponentialAlea4x64Lane(engine, lane, lanes[lane]);
    return out;
}

fn vectorRepairNormalAlea4x64Lanes(engine: *alea.FastPrng) @Vector(4, f64) {
    const VecF64 = @Vector(4, f64);
    const VecU64 = @Vector(4, u64);

    const bits = nextAlea4x64Lanes(engine);

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
        if (!mask[lane]) out[lane] = ratioNormalAlea4x64Lane(engine, lane, bits[lane]);
    }
    return out;
}

fn vectorRepairExponentialAlea4x64Lanes(engine: *alea.FastPrng) @Vector(4, f64) {
    const VecF64 = @Vector(4, f64);
    const VecU64 = @Vector(4, u64);

    const bits = nextAlea4x64Lanes(engine);

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
        if (!mask[lane]) out[lane] = thresholdExponentialAlea4x64Lane(engine, lane, bits[lane]);
    }
    return out;
}

fn vectorLaneNormalF32Alea4x64Scalar(engine: *alea.FastPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |index| {
        const lane = index % 4;
        const bits = nextAlea4x64Lane(engine, lane);
        out[index] = @floatCast(ratioNormalAlea4x64Lane(engine, lane, bits));
    }
    return out;
}

fn vectorLaneExponentialF32Alea4x64Scalar(engine: *alea.FastPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |index| {
        const lane = index % 4;
        const bits = nextAlea4x64Lane(engine, lane);
        out[index] = @floatCast(thresholdExponentialAlea4x64Lane(engine, lane, bits));
    }
    return out;
}

fn vectorRepairNormalF32Alea4x64Lanes(engine: *alea.FastPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    inline for (0..2) |chunk| {
        const bits = nextAlea4x64Lanes(engine);
        const base = chunk * 4;
        var ratios: @Vector(4, f64) = undefined;
        var u_vec: @Vector(4, f64) = undefined;
        inline for (0..4) |lane| {
            const i: usize = @as(u8, @truncate(bits[lane]));
            const repr = (@as(u64, 0x400) << 52) | (bits[lane] >> 12);
            const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
            ratios[lane] = norm_ratio[i];
            u_vec[lane] = u;
            out[base + lane] = @floatCast(u * ziggurat.NormDist.x[i]);
        }
        const mask = @abs(u_vec) < ratios;
        inline for (0..4) |lane| {
            if (!mask[lane]) out[base + lane] = @floatCast(ratioNormalAlea4x64Lane(engine, lane, bits[lane]));
        }
    }
    return out;
}

fn vectorRepairExponentialF32Alea4x64Lanes(engine: *alea.FastPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    inline for (0..2) |chunk| {
        const bits = nextAlea4x64Lanes(engine);
        const base = chunk * 4;
        var thresholds: @Vector(4, u64) = undefined;
        var mantissas: @Vector(4, u64) = undefined;
        inline for (0..4) |lane| {
            const i: usize = @as(u8, @truncate(bits[lane]));
            const mantissa = bits[lane] >> 12;
            const repr = (@as(u64, 0x3ff) << 52) | mantissa;
            const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
            thresholds[lane] = exp_threshold[i];
            mantissas[lane] = mantissa;
            out[base + lane] = @floatCast(u * ziggurat.ExpDist.x[i]);
        }
        const mask = mantissas < thresholds;
        inline for (0..4) |lane| {
            if (!mask[lane]) out[base + lane] = @floatCast(thresholdExponentialAlea4x64Lane(engine, lane, bits[lane]));
        }
    }
    return out;
}

fn vectorRepairNormalF32(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const VecF32 = @Vector(8, f32);
    var out: VecF32 = undefined;

    inline for (0..8) |lane| {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;

        out[lane] = @floatCast(u * ziggurat.NormDist.x[i]);
        if (!(@abs(u) < norm_ratio[i])) {
            out[lane] = @floatCast(ratioNormal(engine));
        }
    }
    return out;
}

fn vectorRepairExponentialF32(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const VecF32 = @Vector(8, f32);
    var out: VecF32 = undefined;

    inline for (0..8) |lane| {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);

        out[lane] = @floatCast(u * ziggurat.ExpDist.x[i]);
        if (!(mantissa < exp_threshold[i])) {
            out[lane] = @floatCast(thresholdExponential(engine));
        }
    }
    return out;
}

fn vectorRepairNormalF32Correct(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const VecF32 = @Vector(8, f32);
    var out: VecF32 = undefined;

    inline for (0..8) |lane| out[lane] = @floatCast(ratioNormal(engine));
    return out;
}

fn vectorRepairExponentialF32Correct(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const VecF32 = @Vector(8, f32);
    var out: VecF32 = undefined;

    inline for (0..8) |lane| out[lane] = @floatCast(thresholdExponential(engine));
    return out;
}

fn ratioNormalFast(engine: *alea.FastPrng) f64 {
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
            return normalTailFast(engine, u);
        }
        if (ziggurat.NormDist.f[i + 1] + (ziggurat.NormDist.f[i] - ziggurat.NormDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x * x / 2.0)) return x;
    }
}

fn normalTailFast(engine: *alea.FastPrng, u: f64) f64 {
    var x: f64 = 1;
    var y: f64 = 0;
    while (-2.0 * y < x * x) {
        x = @log(alea.Rng.floatOpenFrom(engine, f64)) / ziggurat.norm_r;
        y = @log(alea.Rng.floatOpenFrom(engine, f64));
    }
    return if (u < 0) x - ziggurat.norm_r else ziggurat.norm_r - x;
}

fn thresholdExponentialFast(engine: *alea.FastPrng) f64 {
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
            return ziggurat.exp_r - @log(alea.Rng.floatOpenFrom(engine, f64));
        }
        if (ziggurat.ExpDist.f[i + 1] + (ziggurat.ExpDist.f[i] - ziggurat.ExpDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x)) return x;
    }
}

fn vectorRepairNormalF32Fast(engine: *alea.FastPrng) @Vector(8, f32) {
    const VecF32 = @Vector(8, f32);
    var out: VecF32 = undefined;

    inline for (0..8) |lane| {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;

        out[lane] = @floatCast(u * ziggurat.NormDist.x[i]);
        if (!(@abs(u) < norm_ratio[i])) {
            out[lane] = @floatCast(ratioNormalFast(engine));
        }
    }
    return out;
}

fn vectorRepairExponentialF32Fast(engine: *alea.FastPrng) @Vector(8, f32) {
    const VecF32 = @Vector(8, f32);
    var out: VecF32 = undefined;

    inline for (0..8) |lane| {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);

        out[lane] = @floatCast(u * ziggurat.ExpDist.x[i]);
        if (!(mantissa < exp_threshold[i])) {
            out[lane] = @floatCast(thresholdExponentialFast(engine));
        }
    }
    return out;
}

fn vectorRepairNormalF32FastCorrect(engine: *alea.FastPrng) @Vector(8, f32) {
    const VecF32 = @Vector(8, f32);
    var out: VecF32 = undefined;

    inline for (0..8) |lane| out[lane] = @floatCast(ratioNormalFast(engine));
    return out;
}

fn vectorRepairExponentialF32FastCorrect(engine: *alea.FastPrng) @Vector(8, f32) {
    const VecF32 = @Vector(8, f32);
    var out: VecF32 = undefined;

    inline for (0..8) |lane| out[lane] = @floatCast(thresholdExponentialFast(engine));
    return out;
}

fn currentStandardNormalF32FillFast(engine: *alea.FastPrng, dest: []f32) void {
    alea.distributions.fillStandardNormalFrom(engine, f32, dest);
}

fn laneStandardNormalF32FillFast(engine: *alea.FastPrng, dest: []f32) void {
    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        const vec = vectorLaneNormalF32Alea4x64Scalar(engine);
        inline for (0..8) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) {
        dest[i] = switch (i & 3) {
            0 => @floatCast(ratioNormalAlea4x64Lane(engine, 0, nextAlea4x64Lane(engine, 0))),
            1 => @floatCast(ratioNormalAlea4x64Lane(engine, 1, nextAlea4x64Lane(engine, 1))),
            2 => @floatCast(ratioNormalAlea4x64Lane(engine, 2, nextAlea4x64Lane(engine, 2))),
            else => @floatCast(ratioNormalAlea4x64Lane(engine, 3, nextAlea4x64Lane(engine, 3))),
        };
    }
}

fn currentStandardExponentialF32FillFast(engine: *alea.FastPrng, dest: []f32) void {
    alea.distributions.fillStandardExponentialFrom(engine, f32, dest);
}

fn laneStandardExponentialF32FillFast(engine: *alea.FastPrng, dest: []f32) void {
    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        const vec = vectorLaneExponentialF32Alea4x64Scalar(engine);
        inline for (0..8) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) {
        dest[i] = switch (i & 3) {
            0 => @floatCast(thresholdExponentialAlea4x64Lane(engine, 0, nextAlea4x64Lane(engine, 0))),
            1 => @floatCast(thresholdExponentialAlea4x64Lane(engine, 1, nextAlea4x64Lane(engine, 1))),
            2 => @floatCast(thresholdExponentialAlea4x64Lane(engine, 2, nextAlea4x64Lane(engine, 2))),
            else => @floatCast(thresholdExponentialAlea4x64Lane(engine, 3, nextAlea4x64Lane(engine, 3))),
        };
    }
}

fn nextAlea4x64Lanes(engine: *alea.FastPrng) @Vector(4, u64) {
    var out: @Vector(4, u64) = undefined;
    inline for (0..4) |lane| out[lane] = nextAlea4x64Lane(engine, lane);
    return out;
}

fn nextAlea4x64Lane(engine: *alea.FastPrng, comptime lane: usize) u64 {
    engine.state[lane] +%= alea4x64_increment[lane];
    var z = engine.state[lane];
    z = (z ^ (z >> 30)) *% 0xbf58476d1ce4e5b9;
    z = (z ^ (z >> 27)) *% 0x94d049bb133111eb;
    return z ^ (z >> 31);
}

fn ratioNormalAlea4x64Lane(engine: *alea.FastPrng, comptime lane: usize, initial_bits: u64) f64 {
    var bits = initial_bits;
    while (true) {
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
            return normalTailAlea4x64Lane(engine, lane, u);
        }
        if (ziggurat.NormDist.f[i + 1] + (ziggurat.NormDist.f[i] - ziggurat.NormDist.f[i + 1]) * f64FromRaw(nextAlea4x64Lane(engine, lane)) < @exp(-x * x / 2.0)) return x;
        bits = nextAlea4x64Lane(engine, lane);
    }
}

fn normalTailAlea4x64Lane(engine: *alea.FastPrng, comptime lane: usize, u: f64) f64 {
    var x: f64 = 1;
    var y: f64 = 0;
    while (-2.0 * y < x * x) {
        x = @log(f64OpenFromRaw(nextAlea4x64Lane(engine, lane))) / ziggurat.norm_r;
        y = @log(f64OpenFromRaw(nextAlea4x64Lane(engine, lane)));
    }
    return if (u < 0) x - ziggurat.norm_r else ziggurat.norm_r - x;
}

fn thresholdExponentialAlea4x64Lane(engine: *alea.FastPrng, comptime lane: usize, initial_bits: u64) f64 {
    var bits = initial_bits;
    while (true) {
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
            return ziggurat.exp_r - @log(f64OpenFromRaw(nextAlea4x64Lane(engine, lane)));
        }
        if (ziggurat.ExpDist.f[i + 1] + (ziggurat.ExpDist.f[i] - ziggurat.ExpDist.f[i + 1]) * f64FromRaw(nextAlea4x64Lane(engine, lane)) < @exp(-x)) return x;
        bits = nextAlea4x64Lane(engine, lane);
    }
}

fn f64FromRaw(raw: u64) f64 {
    return @as(f64, @floatFromInt(raw >> 11)) * (1.0 / 9007199254740992.0);
}

fn f64OpenFromRaw(raw: u64) f64 {
    const repr = (@as(u64, 0x3ff) << 52) | (raw >> 12);
    return @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
}
