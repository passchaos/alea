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

    try stdout.print("beta special probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast beta current 1,1", 0xbe11, sample_count, betaUnitCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast uniform equivalent", 0xbe11, sample_count, uniformEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar beta current 1,1", 0xbe11, sample_count, betaUnitCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar uniform equivalent", 0xbe11, sample_count, uniformEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast beta fill current 1,1", 0xbe11, sample_count, betaUnitFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast uniform fill equivalent", 0xbe11, sample_count, uniformFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar beta fill current 1,1", 0xbe11, sample_count, betaUnitFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar uniform fill equivalent", 0xbe11, sample_count, uniformFillEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast beta current 2,1", 0xbe21, sample_count, betaAlphaCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sqrt-uniform equivalent", 0xbe21, sample_count, sqrtUniformEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar beta current 2,1", 0xbe21, sample_count, betaAlphaCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sqrt-uniform equivalent", 0xbe21, sample_count, sqrtUniformEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast beta fill current 2,1", 0xbe21, sample_count, betaAlphaFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast sqrt-uniform fill equivalent", 0xbe21, sample_count, sqrtUniformFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar beta fill current 2,1", 0xbe21, sample_count, betaAlphaFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar sqrt-uniform fill equivalent", 0xbe21, sample_count, sqrtUniformFillEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast beta current 1,5", 0xbe15, sample_count, betaBetaCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast complement-root equivalent", 0xbe15, sample_count, complementRootEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar beta current 1,5", 0xbe15, sample_count, betaBetaCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar complement-root equivalent", 0xbe15, sample_count, complementRootEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast beta fill current 1,5", 0xbe15, sample_count, betaBetaFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast complement-root fill equivalent", 0xbe15, sample_count, complementRootFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar beta fill current 1,5", 0xbe15, sample_count, betaBetaFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar complement-root fill equivalent", 0xbe15, sample_count, complementRootFillEquivalent);
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

fn betaUnitCurrent(source: anytype) f64 {
    return alea.distributions.betaFrom(source, f64, 1, 1);
}

fn uniformEquivalent(source: anytype) f64 {
    return alea.Rng.floatFrom(source, f64);
}

fn betaUnitFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillBetaFrom(source, f64, dest, 1, 1);
}

fn uniformFillEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillFrom(source, f64, dest);
}

fn betaAlphaCurrent(source: anytype) f64 {
    return alea.distributions.betaFrom(source, f64, 2, 1);
}

fn sqrtUniformEquivalent(source: anytype) f64 {
    return @sqrt(alea.Rng.floatOpenFrom(source, f64));
}

fn betaAlphaFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillBetaFrom(source, f64, dest, 2, 1);
}

fn sqrtUniformFillEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    for (dest) |*item| item.* = @sqrt(item.*);
}

fn betaBetaCurrent(source: anytype) f64 {
    return alea.distributions.betaFrom(source, f64, 1, 5);
}

fn complementRootEquivalent(source: anytype) f64 {
    return 1.0 - std.math.pow(f64, alea.Rng.floatOpenFrom(source, f64), 0.2);
}

fn betaBetaFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillBetaFrom(source, f64, dest, 1, 5);
}

fn complementRootFillEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    for (dest) |*item| item.* = 1.0 - std.math.pow(f64, item.*, 0.2);
}
