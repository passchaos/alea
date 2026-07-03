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

    try stdout.print("exponential rate probe count={}\n", .{sample_count});
    try benchFill(alea.FastPrng, io, stdout, "fast current fill rate=2", 0xe157, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast standard then scalar scale", 0xe157, sample_count, standardThenScale);
    try benchFill(alea.FastPrng, io, stdout, "fast standard then vector4 scale", 0xe157, sample_count, standardThenVectorScale);
    try benchFill(alea.FastPrng, io, stdout, "fast reusable sampler fill", 0xe157, sample_count, reusableSamplerFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill rate=2", 0xe157, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar standard then scalar scale", 0xe157, sample_count, standardThenScale);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar standard then vector4 scale", 0xe157, sample_count, standardThenVectorScale);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar reusable sampler fill", 0xe157, sample_count, reusableSamplerFill);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 current fill rate=2", 0xe15c, sample_count, currentFillF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 standard then scalar scale", 0xe15c, sample_count, standardThenScaleF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 standard then vector8 scale", 0xe15c, sample_count, standardThenVectorScaleF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 standard then vector8 divide", 0xe15c, sample_count, standardThenVectorDivideF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 current fill rate=2", 0xe15c, sample_count, currentFillF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 standard then scalar scale", 0xe15c, sample_count, standardThenScaleF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 standard then vector8 scale", 0xe15c, sample_count, standardThenVectorScaleF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 standard then vector8 divide", 0xe15c, sample_count, standardThenVectorDivideF32);
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

fn benchFillF32(
    comptime Source: type,
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime fillFn: anytype,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f32 = 0;
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
    alea.Rng.fillExponentialFrom(source, f64, dest, 2);
}

fn standardThenScale(source: anytype, dest: []f64) void {
    alea.distributions.fillStandardExponentialFrom(source, f64, dest);
    for (dest) |*item| item.* *= 0.5;
}

fn standardThenVectorScale(source: anytype, dest: []f64) void {
    alea.distributions.fillStandardExponentialFrom(source, f64, dest);
    scaleVector4(dest, 0.5);
}

fn reusableSamplerFill(source: anytype, dest: []f64) void {
    const sampler = alea.distributions.Exponential(f64).init(2) catch unreachable;
    sampler.fillFrom(source, dest);
}

fn scaleVector4(dest: []f64, factor: f64) void {
    const VectorType = @Vector(4, f64);
    const factor_vec: VectorType = @splat(factor);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const input: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = input * factor_vec;
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) dest[i] *= factor;
}

fn currentFillF32(source: anytype, dest: []f32) void {
    alea.Rng.fillExponentialFrom(source, f32, dest, 2);
}

fn standardThenScaleF32(source: anytype, dest: []f32) void {
    alea.distributions.fillStandardExponentialFrom(source, f32, dest);
    for (dest) |*item| item.* *= 0.5;
}

fn standardThenVectorScaleF32(source: anytype, dest: []f32) void {
    alea.distributions.fillStandardExponentialFrom(source, f32, dest);
    scaleVector8F32(dest, 0.5);
}

fn standardThenVectorDivideF32(source: anytype, dest: []f32) void {
    alea.distributions.fillStandardExponentialFrom(source, f32, dest);
    divideVector8F32(dest, 2);
}

fn scaleVector8F32(dest: []f32, factor: f32) void {
    const VectorType = @Vector(8, f32);
    const factor_vec: VectorType = @splat(factor);

    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        const input: VectorType = .{
            dest[i],
            dest[i + 1],
            dest[i + 2],
            dest[i + 3],
            dest[i + 4],
            dest[i + 5],
            dest[i + 6],
            dest[i + 7],
        };
        const out = input * factor_vec;
        inline for (0..8) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) dest[i] *= factor;
}

fn divideVector8F32(dest: []f32, divisor: f32) void {
    const VectorType = @Vector(8, f32);
    const divisor_vec: VectorType = @splat(divisor);

    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        const input: VectorType = .{
            dest[i],
            dest[i + 1],
            dest[i + 2],
            dest[i + 3],
            dest[i + 4],
            dest[i + 5],
            dest[i + 6],
            dest[i + 7],
        };
        const out = input / divisor_vec;
        inline for (0..8) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) dest[i] /= divisor;
}
