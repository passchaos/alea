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

    try stdout.print("log-normal probe count={}\n", .{sample_count});
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x1062, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar exp", 0x1062, sample_count, stagedScalarExp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 exp", 0x1062, sample_count, stagedVector4Exp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector8 exp", 0x1062, sample_count, stagedVector8Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x1062, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar exp", 0x1062, sample_count, stagedScalarExp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 exp", 0x1062, sample_count, stagedVector4Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector8 exp", 0x1062, sample_count, stagedVector8Exp);
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
    alea.distributions.fillLogNormalFrom(source, f64, dest, 0, 0.25);
}

fn stagedScalarExp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expScalar(dest);
}

fn stagedVector4Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expVector4(dest);
}

fn stagedVector8Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expVector8(dest);
}

fn expScalar(dest: []f64) void {
    for (dest) |*item| item.* = @exp(item.*);
}

fn expVector4(dest: []f64) void {
    const VectorType = @Vector(4, f64);
    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        var vec: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        vec = @exp(vec);
        inline for (0..4) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = @exp(dest[i]);
}

fn expVector8(dest: []f64) void {
    const VectorType = @Vector(8, f64);
    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        var vec: VectorType = .{
            dest[i],
            dest[i + 1],
            dest[i + 2],
            dest[i + 3],
            dest[i + 4],
            dest[i + 5],
            dest[i + 6],
            dest[i + 7],
        };
        vec = @exp(vec);
        inline for (0..8) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = @exp(dest[i]);
}
