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

    try stdout.print("standard fill probe count={}\n", .{sample_count});
    try benchFill(io, stdout, "standard exponential current fill", 0xe15a, sample_count, currentExponentialFill);
    try benchFill(io, stdout, "standard exponential direct loop", 0xe15a, sample_count, directExponentialLoop);
    try benchFill(io, stdout, "standard normal current fill", 0xd15a, sample_count, currentNormalFill);
    try benchFill(io, stdout, "standard normal direct loop", 0xd15a, sample_count, directNormalLoop);
    try stdout.flush();
}

fn benchFill(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime fillFn: fn (*alea.ScalarPrng, []f64) void,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
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

fn currentExponentialFill(source: *alea.ScalarPrng, dest: []f64) void {
    alea.distributions.fillStandardExponentialFrom(source, f64, dest);
}

fn directExponentialLoop(source: *alea.ScalarPrng, dest: []f64) void {
    for (dest) |*item| item.* = alea.Rng.standardExponentialFastFrom(source, f64);
}

fn currentNormalFill(source: *alea.ScalarPrng, dest: []f64) void {
    alea.distributions.fillStandardNormalFrom(source, f64, dest);
}

fn directNormalLoop(source: *alea.ScalarPrng, dest: []f64) void {
    for (dest) |*item| item.* = alea.Rng.standardNormalFastFrom(source, f64);
}
