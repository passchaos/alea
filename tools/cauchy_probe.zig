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
    try benchF64(io, stdout, "open mulAdd angle", sample_count, openMulAddAngle);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar tan", sample_count, stagedScalarTan);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 tan", sample_count, stagedVector4Tan);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar tan", sample_count, stagedScalarTan);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 tan", sample_count, stagedVector4Tan);
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

fn openMulAddAngle(engine: *alea.ScalarPrng) f64 {
    const angle = @mulAdd(f64, pi, alea.Rng.floatOpenFrom(engine, f64), -pi / 2.0);
    return @tan(angle);
}

fn benchFill(
    comptime Source: type,
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    sample_count: usize,
    comptime fillFn: anytype,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(0xca11);
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
    alea.distributions.fillCauchyFrom(source, f64, dest, 0, 1);
}

fn stagedScalarTan(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    for (dest) |*item| item.* = @tan(pi * (item.* - 0.5));
}

fn stagedVector4Tan(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    const VectorType = @Vector(4, f64);
    const pi_vec: VectorType = @splat(pi);
    const half_vec: VectorType = @splat(0.5);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const u: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = @tan(pi_vec * (u - half_vec));
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = @tan(pi * (dest[i] - 0.5));
}
