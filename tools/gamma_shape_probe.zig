const std = @import("std");
const alea = @import("alea");

const trials = 3;
const default_count = 16 * 1024 * 1024;

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

    try stdout.print("gamma shape probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast gamma current shape=1 scale=3", 0x6a11, sample_count, gammaCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast exponential equivalent", 0x6a11, sample_count, exponentialEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar gamma current shape=1 scale=3", 0x6a11, sample_count, gammaCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar exponential equivalent", 0x6a11, sample_count, exponentialEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast gamma fill current shape=1 scale=3", 0x6a11, sample_count, gammaFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast exponential fill equivalent", 0x6a11, sample_count, exponentialFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar gamma fill current shape=1 scale=3", 0x6a11, sample_count, gammaFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar exponential fill equivalent", 0x6a11, sample_count, exponentialFillEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast gamma current shape=0.5 scale=3", 0x6a05, sample_count, gammaHalfCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast normal-square equivalent", 0x6a05, sample_count, normalSquareEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar gamma current shape=0.5 scale=3", 0x6a05, sample_count, gammaHalfCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar normal-square equivalent", 0x6a05, sample_count, normalSquareEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast gamma fill current shape=0.5 scale=3", 0x6a05, sample_count, gammaHalfFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast normal-square fill equivalent", 0x6a05, sample_count, normalSquareFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar gamma fill current shape=0.5 scale=3", 0x6a05, sample_count, gammaHalfFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar normal-square fill equivalent", 0x6a05, sample_count, normalSquareFillEquivalent);
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
    var out: [4096]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, out[0..n]);
            for (out[0..n]) |item| checksum += item;
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

fn gammaCurrent(source: anytype) f64 {
    return alea.distributions.gammaFrom(source, f64, 1, 3);
}

fn exponentialEquivalent(source: anytype) f64 {
    return alea.Rng.standardExponentialFastFrom(source, f64) * 3;
}

fn gammaFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillGammaFrom(source, f64, dest, 1, 3);
}

fn exponentialFillEquivalent(source: anytype, dest: []f64) void {
    for (dest) |*item| item.* = alea.Rng.standardExponentialFastFrom(source, f64) * 3;
}

fn gammaHalfCurrent(source: anytype) f64 {
    return alea.distributions.gammaFrom(source, f64, 0.5, 3);
}

fn normalSquareEquivalent(source: anytype) f64 {
    const z = alea.Rng.standardNormalFastFrom(source, f64);
    return 1.5 * z * z;
}

fn gammaHalfFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillGammaFrom(source, f64, dest, 0.5, 3);
}

fn normalSquareFillEquivalent(source: anytype, dest: []f64) void {
    for (dest) |*item| {
        const z = alea.Rng.standardNormalFastFrom(source, f64);
        item.* = 1.5 * z * z;
    }
}
