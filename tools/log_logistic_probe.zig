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

    try stdout.print("log-logistic probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast sample current shape=1", 0x106111, sample_count, sampleShapeOneCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sample ratio equivalent", 0x106111, sample_count, sampleRatioEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current shape=1", 0x106111, sample_count, sampleShapeOneCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample ratio equivalent", 0x106111, sample_count, sampleRatioEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast fill current shape=1", 0x106111, sample_count, fillShapeOneCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast fill ratio equivalent", 0x106111, sample_count, fillRatioEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill current shape=1", 0x106111, sample_count, fillShapeOneCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill ratio equivalent", 0x106111, sample_count, fillRatioEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x1061aa, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar pow", 0x1061aa, sample_count, stagedScalarPow);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar exp-logit", 0x1061aa, sample_count, stagedScalarExpLogit);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 exp-logit", 0x1061aa, sample_count, stagedVector4ExpLogit);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x1061aa, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar pow", 0x1061aa, sample_count, stagedScalarPow);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar exp-logit", 0x1061aa, sample_count, stagedScalarExpLogit);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 exp-logit", 0x1061aa, sample_count, stagedVector4ExpLogit);
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
    alea.distributions.fillLogLogisticFrom(source, f64, dest, 2, 3);
}

fn sampleShapeOneCurrent(source: anytype) f64 {
    return alea.distributions.logLogisticFrom(source, f64, 2, 1);
}

fn sampleRatioEquivalent(source: anytype) f64 {
    const u = alea.Rng.floatOpenFrom(source, f64);
    return 2 * u / (1 - u);
}

fn fillShapeOneCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillLogLogisticFrom(source, f64, dest, 2, 1);
}

fn fillRatioEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    for (dest) |*item| item.* = 2 * item.* / (1 - item.*);
}

fn stagedScalarPow(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformScalarPow(dest, 2, 1.0 / 3.0);
}

fn stagedScalarExpLogit(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformScalarExpLogit(dest, 2, 1.0 / 3.0);
}

fn stagedVector4ExpLogit(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformVector4ExpLogit(dest, 2, 1.0 / 3.0);
}

fn transformScalarPow(dest: []f64, scale: f64, inverse_shape: f64) void {
    for (dest) |*item| {
        const u = item.*;
        item.* = scale * std.math.pow(f64, u / (1.0 - u), inverse_shape);
    }
}

fn transformScalarExpLogit(dest: []f64, scale: f64, inverse_shape: f64) void {
    for (dest) |*item| {
        const u = item.*;
        item.* = scale * @exp(@log(u / (1.0 - u)) * inverse_shape);
    }
}

fn transformVector4ExpLogit(dest: []f64, scale: f64, inverse_shape: f64) void {
    const VectorType = @Vector(4, f64);
    const scale_vec: VectorType = @splat(scale);
    const inverse_shape_vec: VectorType = @splat(inverse_shape);
    const one_vec: VectorType = @splat(1.0);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const u: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = scale_vec * @exp(@log(u / (one_vec - u)) * inverse_shape_vec);
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    transformScalarExpLogit(dest[i..], scale, inverse_shape);
}
