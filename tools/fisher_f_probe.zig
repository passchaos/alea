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

    try stdout.print("fisher-f probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast fisher current d=2,2", 0xf122, sample_count, sampleCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast uniform-ratio equivalent", 0xf122, sample_count, sampleUniformRatio);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar fisher current d=2,2", 0xf122, sample_count, sampleCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar uniform-ratio equivalent", 0xf122, sample_count, sampleUniformRatio);
    try benchFill(alea.FastPrng, io, stdout, "fast fisher fill current d=2,2", 0xf122, sample_count, fillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast uniform-ratio fill equivalent", 0xf122, sample_count, fillUniformRatio);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fisher fill current d=2,2", 0xf122, sample_count, fillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar uniform-ratio fill equivalent", 0xf122, sample_count, fillUniformRatio);
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

fn sampleCurrent(source: anytype) f64 {
    return alea.distributions.fisherFFrom(source, f64, 2, 2);
}

fn sampleUniformRatio(source: anytype) f64 {
    const u = alea.Rng.floatOpenFrom(source, f64);
    return u / (1 - u);
}

fn fillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillFisherFFrom(source, f64, dest, 2, 2);
}

fn fillUniformRatio(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    for (dest) |*item| item.* = item.* / (1 - item.*);
}
