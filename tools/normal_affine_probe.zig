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

    try stdout.print("normal affine probe count={}\n", .{sample_count});
    try benchFill(alea.FastPrng, io, stdout, "fast current fill mean=2 std=0.5", 0xa551, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast standard then scalar affine", 0xa551, sample_count, standardThenScalarAffine);
    try benchFill(alea.FastPrng, io, stdout, "fast standard then vector4 affine", 0xa551, sample_count, standardThenVectorAffine);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill mean=2 std=0.5", 0xa551, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar standard then scalar affine", 0xa551, sample_count, standardThenScalarAffine);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar standard then vector4 affine", 0xa551, sample_count, standardThenVectorAffine);
    try stdout.flush();
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

fn currentFill(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 2, 0.5);
}

fn standardThenScalarAffine(source: anytype, dest: []f64) void {
    alea.distributions.fillStandardNormalFrom(source, f64, dest);
    for (dest) |*item| item.* = 2.0 + 0.5 * item.*;
}

fn standardThenVectorAffine(source: anytype, dest: []f64) void {
    alea.distributions.fillStandardNormalFrom(source, f64, dest);
    affineVector4(dest, 2, 0.5);
}

fn affineVector4(dest: []f64, mean: f64, stddev: f64) void {
    const VectorType = @Vector(4, f64);
    const mean_vec: VectorType = @splat(mean);
    const stddev_vec: VectorType = @splat(stddev);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const input: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = mean_vec + stddev_vec * input;
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) dest[i] = mean + stddev * dest[i];
}
