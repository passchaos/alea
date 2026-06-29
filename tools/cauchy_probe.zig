const std = @import("std");
const alea = @import("alea");

const trials = 3;
const default_count = 16 * 1024 * 1024;
const pi = std.math.pi;

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

    try stdout.print("cauchy probe count={}\n", .{sample_count});
    try benchF64(io, stdout, "current centered open", sample_count, currentCenteredOpen);
    try benchF64(io, stdout, "centered half-open", sample_count, centeredHalfOpen);
    try benchF64(io, stdout, "rust-shaped half-open", sample_count, rustShapedHalfOpen);
    try benchF64(io, stdout, "open precomputed angle", sample_count, openPrecomputedAngle);
    try stdout.flush();
}

fn benchF64(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    sample_count: usize,
    comptime sampleFn: fn (*alea.ScalarPrng) f64,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xca11);
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

fn currentCenteredOpen(engine: *alea.ScalarPrng) f64 {
    return alea.distributions.cauchyFrom(engine, f64, 0, 1);
}

fn centeredHalfOpen(engine: *alea.ScalarPrng) f64 {
    const u = alea.Rng.floatFrom(engine, f64);
    return @tan(pi * (u - 0.5));
}

fn rustShapedHalfOpen(engine: *alea.ScalarPrng) f64 {
    const u = alea.Rng.floatFrom(engine, f64);
    return @tan(pi * u);
}

fn openPrecomputedAngle(engine: *alea.ScalarPrng) f64 {
    const angle = pi * alea.Rng.floatOpenFrom(engine, f64) - pi / 2.0;
    return @tan(angle);
}
