const std = @import("std");
const alea = @import("alea");

const trials = 3;
const default_count = 8 * 1024 * 1024;

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

    try stdout.print("power-function probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast sample current shape=1", 0x90b1, sample_count, sampleShapeOneCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast uniform equivalent", 0x90b1, sample_count, sampleUniformEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current shape=1", 0x90b1, sample_count, sampleShapeOneCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar uniform equivalent", 0x90b1, sample_count, sampleUniformEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast fill current shape=1", 0x90b1, sample_count, fillShapeOneCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast uniform fill equivalent", 0x90b1, sample_count, fillUniformEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill current shape=1", 0x90b1, sample_count, fillShapeOneCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar uniform fill equivalent", 0x90b1, sample_count, fillUniformEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast sample current shape=2", 0x90b2, sample_count, sampleShapeTwoCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sqrt equivalent", 0x90b2, sample_count, sampleSqrtEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast sampler current shape=2", 0x90b2, sample_count, samplerShapeTwoCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current shape=2", 0x90b2, sample_count, sampleShapeTwoCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sqrt equivalent", 0x90b2, sample_count, sampleSqrtEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sampler current shape=2", 0x90b2, sample_count, samplerShapeTwoCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast fill current shape=2", 0x90b2, sample_count, fillShapeTwoCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast sqrt fill equivalent", 0x90b2, sample_count, fillSqrtEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast sampler fill current shape=2", 0x90b2, sample_count, samplerShapeTwoFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill current shape=2", 0x90b2, sample_count, fillShapeTwoCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar sqrt fill equivalent", 0x90b2, sample_count, fillSqrtEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar sampler fill current shape=2", 0x90b2, sample_count, samplerShapeTwoFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x90b0, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar pow", 0x90b0, sample_count, stagedScalarPow);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar exp-log", 0x90b0, sample_count, stagedScalarExpLog);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 exp-log", 0x90b0, sample_count, stagedVector4ExpLog);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x90b0, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar pow", 0x90b0, sample_count, stagedScalarPow);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar exp-log", 0x90b0, sample_count, stagedScalarExpLog);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 exp-log", 0x90b0, sample_count, stagedVector4ExpLog);
    try stdout.flush();
}

fn benchSample(
    comptime Source: type,
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime sampleFn: anytype,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(seed);
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

fn benchFill(
    comptime Source: type,
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime fillFn: anytype,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f64 = 0;
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

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillPowerFunctionFrom(source, f64, dest, -1, 2, 3);
}

fn sampleShapeOneCurrent(source: anytype) f64 {
    return alea.distributions.powerFunctionFrom(source, f64, -1, 2, 1);
}

fn sampleUniformEquivalent(source: anytype) f64 {
    return alea.Rng.floatRangeFrom(source, f64, -1, 2);
}

fn fillShapeOneCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillPowerFunctionFrom(source, f64, dest, -1, 2, 1);
}

fn fillUniformEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillRangeFrom(source, f64, dest, -1, 2);
}

fn sampleShapeTwoCurrent(source: anytype) f64 {
    return alea.distributions.powerFunctionFrom(source, f64, -1, 2, 2);
}

fn sampleSqrtEquivalent(source: anytype) f64 {
    return -1 + 3 * @sqrt(alea.Rng.floatOpenFrom(source, f64));
}

fn fillShapeTwoCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillPowerFunctionFrom(source, f64, dest, -1, 2, 2);
}

fn fillSqrtEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    for (dest) |*item| item.* = -1 + 3 * @sqrt(item.*);
}

fn samplerShapeTwoCurrent(source: anytype) f64 {
    const sampler = alea.distributions.PowerFunction(f64).init(-1, 2, 2) catch unreachable;
    return sampler.sampleFrom(source);
}

fn samplerShapeTwoFillCurrent(source: anytype, dest: []f64) void {
    const sampler = alea.distributions.PowerFunction(f64).init(-1, 2, 2) catch unreachable;
    sampler.fillFrom(source, dest);
}

fn stagedScalarPow(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformScalarPow(dest, -1, 3, 1.0 / 3.0);
}

fn stagedScalarExpLog(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformScalarExpLog(dest, -1, 3, 1.0 / 3.0);
}

fn stagedVector4ExpLog(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformVector4ExpLog(dest, -1, 3, 1.0 / 3.0);
}

fn transformScalarPow(dest: []f64, min: f64, width: f64, inverse_shape: f64) void {
    for (dest) |*item| item.* = min + width * std.math.pow(f64, item.*, inverse_shape);
}

fn transformScalarExpLog(dest: []f64, min: f64, width: f64, inverse_shape: f64) void {
    for (dest) |*item| item.* = min + width * @exp(@log(item.*) * inverse_shape);
}

fn transformVector4ExpLog(dest: []f64, min: f64, width: f64, inverse_shape: f64) void {
    const VectorType = @Vector(4, f64);
    const min_vec: VectorType = @splat(min);
    const width_vec: VectorType = @splat(width);
    const inverse_shape_vec: VectorType = @splat(inverse_shape);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const u: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = min_vec + width_vec * @exp(@log(u) * inverse_shape_vec);
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    transformScalarExpLog(dest[i..], min, width, inverse_shape);
}
