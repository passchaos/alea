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

    try stdout.print("laplace probe count={}\n", .{sample_count});
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x1aa, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar log", 0x1aa, sample_count, stagedScalar);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 log", 0x1aa, sample_count, stagedVector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x1aa, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar log", 0x1aa, sample_count, stagedScalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 log", 0x1aa, sample_count, stagedVector4);
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
    alea.distributions.fillLaplaceFrom(source, f64, dest, 0, 1);
}

fn stagedScalar(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformScalar(dest, 0, 1);
}

fn stagedVector4(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformVector4(dest, 0, 1);
}

fn transformScalar(dest: []f64, location: f64, scale: f64) void {
    for (dest) |*item| {
        const centered = item.* - 0.5;
        const sign: f64 = if (centered < 0) -1 else 1;
        item.* = location - scale * sign * @log(1.0 - 2.0 * @abs(centered));
    }
}

fn transformVector4(dest: []f64, location: f64, scale: f64) void {
    const VectorType = @Vector(4, f64);
    const location_vec: VectorType = @splat(location);
    const scale_vec: VectorType = @splat(scale);
    const half_vec: VectorType = @splat(0.5);
    const one_vec: VectorType = @splat(1.0);
    const two_vec: VectorType = @splat(2.0);
    const positive: VectorType = @splat(1.0);
    const negative: VectorType = @splat(-1.0);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const u: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const centered = u - half_vec;
        const sign = @select(f64, centered < @as(VectorType, @splat(0.0)), negative, positive);
        const out = location_vec - scale_vec * sign * @log(one_vec - two_vec * @abs(centered));
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    transformScalar(dest[i..], location, scale);
}
