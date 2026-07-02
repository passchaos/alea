const std = @import("std");
const alea = @import("alea");

extern "c" fn exp(f64) f64;
extern "c" fn expf(f32) f32;

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
    try benchSample(alea.FastPrng, io, stdout, "fast sample current", 0x1060, sample_count, sampleCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sample standard+scale", 0x1060, sample_count, sampleStandardScale);
    try benchSample(alea.FastPrng, io, stdout, "fast sample mulAdd", 0x1060, sample_count, sampleMulAdd);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current", 0x1061, sample_count, sampleCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample standard+scale", 0x1061, sample_count, sampleStandardScale);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample mulAdd", 0x1061, sample_count, sampleMulAdd);
    try benchFill(alea.FastPrng, io, stdout, "fast normal-only fill", 0x1062, sample_count, normalOnlyFill);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x1062, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar exp", 0x1062, sample_count, stagedScalarExp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged index exp", 0x1062, sample_count, stagedIndexExp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged prefetch8 exp", 0x1062, sample_count, stagedPrefetch8Exp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged prefetch16 exp", 0x1062, sample_count, stagedPrefetch16Exp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged libc exp", 0x1062, sample_count, stagedLibcExp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged unroll4 exp", 0x1062, sample_count, stagedUnroll4Exp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged unroll8 exp", 0x1062, sample_count, stagedUnroll8Exp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged optimized exp", 0x1062, sample_count, stagedOptimizedExp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged std.math.exp", 0x1062, sample_count, stagedStdMathExp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged expm1+1", 0x1062, sample_count, stagedExpm1Exp);
    try benchFill(alea.FastPrng, io, stdout, "fast standard scale then exp", 0x1062, sample_count, standardScaleThenExp);
    try benchFill(alea.FastPrng, io, stdout, "fast standard fused affine exp", 0x1062, sample_count, standardFusedAffineExp);
    try benchFill(alea.FastPrng, io, stdout, "fast standard fused affine std.math.exp", 0x1062, sample_count, standardFusedAffineStdMathExp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector2 exp", 0x1062, sample_count, stagedVector2Exp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 exp", 0x1062, sample_count, stagedVector4Exp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector8 exp", 0x1062, sample_count, stagedVector8Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar normal-only fill", 0x1062, sample_count, normalOnlyFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x1062, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar exp", 0x1062, sample_count, stagedScalarExp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged index exp", 0x1062, sample_count, stagedIndexExp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged prefetch8 exp", 0x1062, sample_count, stagedPrefetch8Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged prefetch16 exp", 0x1062, sample_count, stagedPrefetch16Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged libc exp", 0x1062, sample_count, stagedLibcExp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged unroll4 exp", 0x1062, sample_count, stagedUnroll4Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged unroll8 exp", 0x1062, sample_count, stagedUnroll8Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged optimized exp", 0x1062, sample_count, stagedOptimizedExp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged std.math.exp", 0x1062, sample_count, stagedStdMathExp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged expm1+1", 0x1062, sample_count, stagedExpm1Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar standard scale then exp", 0x1062, sample_count, standardScaleThenExp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar standard fused affine exp", 0x1062, sample_count, standardFusedAffineExp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar standard fused affine std.math.exp", 0x1062, sample_count, standardFusedAffineStdMathExp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector2 exp", 0x1062, sample_count, stagedVector2Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 exp", 0x1062, sample_count, stagedVector4Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector8 exp", 0x1062, sample_count, stagedVector8Exp);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 normal-only fill", 0x1063, sample_count, normalOnlyFillF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 current fill", 0x1063, sample_count, currentFillF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged scalar exp", 0x1063, sample_count, stagedScalarExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged index exp", 0x1063, sample_count, stagedIndexExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged prefetch16 exp", 0x1063, sample_count, stagedPrefetch16ExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged prefetch32 exp", 0x1063, sample_count, stagedPrefetch32ExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged libc expf", 0x1063, sample_count, stagedLibcExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged unroll4 exp", 0x1063, sample_count, stagedUnroll4ExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged unroll8 exp", 0x1063, sample_count, stagedUnroll8ExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged optimized exp", 0x1063, sample_count, stagedOptimizedExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged std.math.exp", 0x1063, sample_count, stagedStdMathExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged expm1+1", 0x1063, sample_count, stagedExpm1ExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 standard scale then exp", 0x1063, sample_count, standardScaleThenExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 standard fused affine exp", 0x1063, sample_count, standardFusedAffineExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 standard fused affine std.math.exp", 0x1063, sample_count, standardFusedAffineStdMathExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 public approx", 0x1063, sample_count, publicApproxFillF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged hybrid expm1 0.25", 0x1063, sample_count, stagedHybridExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged vector2 exp", 0x1063, sample_count, stagedVector2ExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged vector4 exp", 0x1063, sample_count, stagedVector4ExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged vector8 exp", 0x1063, sample_count, stagedVector8ExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged vector16 exp", 0x1063, sample_count, stagedVector16ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 normal-only fill", 0x1063, sample_count, normalOnlyFillF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 current fill", 0x1063, sample_count, currentFillF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged scalar exp", 0x1063, sample_count, stagedScalarExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged index exp", 0x1063, sample_count, stagedIndexExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged prefetch16 exp", 0x1063, sample_count, stagedPrefetch16ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged prefetch32 exp", 0x1063, sample_count, stagedPrefetch32ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged libc expf", 0x1063, sample_count, stagedLibcExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged unroll4 exp", 0x1063, sample_count, stagedUnroll4ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged unroll8 exp", 0x1063, sample_count, stagedUnroll8ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged optimized exp", 0x1063, sample_count, stagedOptimizedExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged std.math.exp", 0x1063, sample_count, stagedStdMathExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged expm1+1", 0x1063, sample_count, stagedExpm1ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 standard scale then exp", 0x1063, sample_count, standardScaleThenExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 standard fused affine exp", 0x1063, sample_count, standardFusedAffineExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 standard fused affine std.math.exp", 0x1063, sample_count, standardFusedAffineStdMathExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 public approx", 0x1063, sample_count, publicApproxFillF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged hybrid expm1 0.25", 0x1063, sample_count, stagedHybridExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged vector2 exp", 0x1063, sample_count, stagedVector2ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged vector4 exp", 0x1063, sample_count, stagedVector4ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged vector8 exp", 0x1063, sample_count, stagedVector8ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged vector16 exp", 0x1063, sample_count, stagedVector16ExpF32);
    try compareExpm1ErrorF32(io, stdout, "f32 expm1+1 diff stddev=0.25", 0x1064, sample_count, 0.25);
    try compareExpm1ErrorF32(io, stdout, "f32 expm1+1 diff stddev=1.0", 0x1064, sample_count, 1.0);
    try compareExpm1ErrorF32(io, stdout, "f32 expm1+1 diff stddev=2.0", 0x1064, sample_count, 2.0);
    try compareHybridExpm1ErrorF32(io, stdout, "f32 hybrid expm1 diff stddev=1.0 threshold=0.25", 0x1065, sample_count, 1.0, 0.25);
    try compareHybridExpm1ErrorF32(io, stdout, "f32 hybrid expm1 diff stddev=2.0 threshold=0.25", 0x1065, sample_count, 2.0, 0.25);
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
    var best_checksum: f64 = 0;
    var out: [1024]f32 = undefined;

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

fn normalOnlyFill(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
}

fn currentFillF32(source: anytype, dest: []f32) void {
    alea.distributions.fillLogNormalFrom(source, f32, dest, 0, 0.25);
}

fn normalOnlyFillF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
}

fn sampleCurrent(source: anytype) f64 {
    return alea.distributions.logNormalFrom(source, f64, 0, 0.25);
}

fn sampleStandardScale(source: anytype) f64 {
    return @exp(0.25 * alea.Rng.standardNormalFastFrom(source, f64));
}

fn sampleMulAdd(source: anytype) f64 {
    return @exp(@mulAdd(f64, 0.25, alea.Rng.standardNormalFastFrom(source, f64), 0));
}

fn stagedScalarExp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expScalar(dest);
}

fn stagedIndexExp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expIndex(dest);
}

fn stagedPrefetch8Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expPrefetch(dest, 8);
}

fn stagedPrefetch16Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expPrefetch(dest, 16);
}

fn stagedLibcExp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expLibc(dest);
}

fn stagedUnroll4Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expUnroll4(dest);
}

fn stagedUnroll8Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expUnroll8(dest);
}

fn stagedOptimizedExp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expOptimized(dest);
}

fn stagedStdMathExp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expStdMath(dest);
}

fn stagedExpm1Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expm1PlusOne(dest);
}

fn standardScaleThenExp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 1);
    scaleOnly(dest, 0.25);
    expScalar(dest);
}

fn standardFusedAffineExp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 1);
    fusedAffineExp(dest, 0, 0.25);
}

fn standardFusedAffineStdMathExp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 1);
    fusedAffineStdMathExp(dest, 0, 0.25);
}

fn stagedVector4Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expVector4(dest);
}

fn stagedVector2Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expVector2(dest);
}

fn stagedVector8Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expVector8(dest);
}

fn stagedScalarExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expScalarF32(dest);
}

fn stagedIndexExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expIndexF32(dest);
}

fn stagedPrefetch16ExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expPrefetchF32(dest, 16);
}

fn stagedPrefetch32ExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expPrefetchF32(dest, 32);
}

fn stagedLibcExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expLibcF32(dest);
}

fn stagedUnroll4ExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expUnroll4F32(dest);
}

fn stagedUnroll8ExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expUnroll8F32(dest);
}

fn stagedOptimizedExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expOptimizedF32(dest);
}

fn stagedStdMathExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expStdMathF32(dest);
}

fn stagedExpm1ExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expm1PlusOneF32(dest);
}

fn standardScaleThenExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 1);
    scaleOnlyF32(dest, 0.25);
    expScalarF32(dest);
}

fn standardFusedAffineExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 1);
    fusedAffineExpF32(dest, 0, 0.25);
}

fn standardFusedAffineStdMathExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 1);
    fusedAffineStdMathExpF32(dest, 0, 0.25);
}

fn publicApproxFillF32(source: anytype, dest: []f32) void {
    alea.distributions.fillLogNormalApproxF32From(source, dest, 0, 0.25);
}

fn stagedHybridExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expHybridF32(dest, 0.25);
}

fn stagedVector4ExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expVector4F32(dest);
}

fn stagedVector2ExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expVector2F32(dest);
}

fn stagedVector8ExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expVector8F32(dest);
}

fn stagedVector16ExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expVector16F32(dest);
}

fn expScalar(dest: []f64) void {
    for (dest) |*item| item.* = @exp(item.*);
}

fn expIndex(dest: []f64) void {
    var i: usize = 0;
    while (i < dest.len) : (i += 1) dest[i] = @exp(dest[i]);
}

fn expPrefetch(dest: []f64, comptime distance: usize) void {
    var i: usize = 0;
    while (i < dest.len) : (i += 1) {
        if (i + distance < dest.len) {
            @prefetch(&dest[i + distance], .{ .rw = .read, .locality = 3, .cache = .data });
        }
        dest[i] = @exp(dest[i]);
    }
}

fn expLibc(dest: []f64) void {
    for (dest) |*item| item.* = exp(item.*);
}

fn expUnroll4(dest: []f64) void {
    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        dest[i] = @exp(dest[i]);
        dest[i + 1] = @exp(dest[i + 1]);
        dest[i + 2] = @exp(dest[i + 2]);
        dest[i + 3] = @exp(dest[i + 3]);
    }
    while (i < dest.len) : (i += 1) dest[i] = @exp(dest[i]);
}

fn expUnroll8(dest: []f64) void {
    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        dest[i] = @exp(dest[i]);
        dest[i + 1] = @exp(dest[i + 1]);
        dest[i + 2] = @exp(dest[i + 2]);
        dest[i + 3] = @exp(dest[i + 3]);
        dest[i + 4] = @exp(dest[i + 4]);
        dest[i + 5] = @exp(dest[i + 5]);
        dest[i + 6] = @exp(dest[i + 6]);
        dest[i + 7] = @exp(dest[i + 7]);
    }
    while (i < dest.len) : (i += 1) dest[i] = @exp(dest[i]);
}

fn expOptimized(dest: []f64) void {
    @setFloatMode(.optimized);
    for (dest) |*item| item.* = @exp(item.*);
}

fn expStdMath(dest: []f64) void {
    for (dest) |*item| item.* = std.math.exp(item.*);
}

fn expm1PlusOne(dest: []f64) void {
    for (dest) |*item| item.* = std.math.expm1(item.*) + 1.0;
}

fn scaleOnly(dest: []f64, scale: f64) void {
    for (dest) |*item| item.* *= scale;
}

fn fusedAffineExp(dest: []f64, mean: f64, stddev: f64) void {
    for (dest) |*item| item.* = @exp(mean + stddev * item.*);
}

fn fusedAffineStdMathExp(dest: []f64, mean: f64, stddev: f64) void {
    for (dest) |*item| item.* = std.math.exp(mean + stddev * item.*);
}

fn expScalarF32(dest: []f32) void {
    for (dest) |*item| item.* = @exp(item.*);
}

fn expIndexF32(dest: []f32) void {
    var i: usize = 0;
    while (i < dest.len) : (i += 1) dest[i] = @exp(dest[i]);
}

fn expPrefetchF32(dest: []f32, comptime distance: usize) void {
    var i: usize = 0;
    while (i < dest.len) : (i += 1) {
        if (i + distance < dest.len) {
            @prefetch(&dest[i + distance], .{ .rw = .read, .locality = 3, .cache = .data });
        }
        dest[i] = @exp(dest[i]);
    }
}

fn expLibcF32(dest: []f32) void {
    for (dest) |*item| item.* = expf(item.*);
}

fn expUnroll4F32(dest: []f32) void {
    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        dest[i] = @exp(dest[i]);
        dest[i + 1] = @exp(dest[i + 1]);
        dest[i + 2] = @exp(dest[i + 2]);
        dest[i + 3] = @exp(dest[i + 3]);
    }
    while (i < dest.len) : (i += 1) dest[i] = @exp(dest[i]);
}

fn expUnroll8F32(dest: []f32) void {
    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        dest[i] = @exp(dest[i]);
        dest[i + 1] = @exp(dest[i + 1]);
        dest[i + 2] = @exp(dest[i + 2]);
        dest[i + 3] = @exp(dest[i + 3]);
        dest[i + 4] = @exp(dest[i + 4]);
        dest[i + 5] = @exp(dest[i + 5]);
        dest[i + 6] = @exp(dest[i + 6]);
        dest[i + 7] = @exp(dest[i + 7]);
    }
    while (i < dest.len) : (i += 1) dest[i] = @exp(dest[i]);
}

fn expOptimizedF32(dest: []f32) void {
    @setFloatMode(.optimized);
    for (dest) |*item| item.* = @exp(item.*);
}

fn expStdMathF32(dest: []f32) void {
    for (dest) |*item| item.* = std.math.exp(item.*);
}

fn expm1PlusOneF32(dest: []f32) void {
    for (dest) |*item| item.* = std.math.expm1(item.*) + 1.0;
}

fn scaleOnlyF32(dest: []f32, scale: f32) void {
    for (dest) |*item| item.* *= scale;
}

fn fusedAffineExpF32(dest: []f32, mean: f32, stddev: f32) void {
    for (dest) |*item| item.* = @exp(mean + stddev * item.*);
}

fn fusedAffineStdMathExpF32(dest: []f32, mean: f32, stddev: f32) void {
    for (dest) |*item| item.* = std.math.exp(mean + stddev * item.*);
}

fn expHybridF32(dest: []f32, threshold: f32) void {
    for (dest) |*item| {
        item.* = if (@abs(item.*) <= threshold)
            std.math.expm1(item.*) + 1.0
        else
            @exp(item.*);
    }
}

fn compareExpm1ErrorF32(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    stddev: f32,
) !void {
    var engine = alea.ScalarPrng.init(seed);
    var max_abs: f32 = 0;
    var max_rel: f32 = 0;
    var max_ulp: u32 = 0;
    var changed: usize = 0;
    var i: usize = 0;

    const start = std.Io.Clock.awake.now(io).nanoseconds;
    while (i < sample_count) : (i += 1) {
        const x = stddev * alea.Rng.standardNormalFastFrom(&engine, f32);
        const direct = @exp(x);
        const candidate = std.math.expm1(x) + 1.0;
        if (direct != candidate) {
            changed += 1;
            const abs_diff = @abs(candidate - direct);
            const rel_diff = abs_diff / direct;
            const ulp_diff = floatDistanceF32(direct, candidate);
            max_abs = @max(max_abs, abs_diff);
            max_rel = @max(max_rel, rel_diff);
            max_ulp = @max(max_ulp, ulp_diff);
        }
    }
    const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
    const million_per_s = (@as(f64, @floatFromInt(sample_count)) / 1_000_000.0) /
        (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);

    try stdout.print(
        "{s}: {d:.1} M samples/s changed={} max_abs={d:.9} max_rel={d:.9} max_ulp={}\n",
        .{ name, million_per_s, changed, max_abs, max_rel, max_ulp },
    );
}

fn compareHybridExpm1ErrorF32(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    stddev: f32,
    threshold: f32,
) !void {
    var engine = alea.ScalarPrng.init(seed);
    var max_abs: f32 = 0;
    var max_rel: f32 = 0;
    var max_ulp: u32 = 0;
    var changed: usize = 0;
    var hybrid_used: usize = 0;
    var i: usize = 0;

    const start = std.Io.Clock.awake.now(io).nanoseconds;
    while (i < sample_count) : (i += 1) {
        const x = stddev * alea.Rng.standardNormalFastFrom(&engine, f32);
        const direct = @exp(x);
        const candidate = if (@abs(x) <= threshold) blk: {
            hybrid_used += 1;
            break :blk std.math.expm1(x) + 1.0;
        } else @exp(x);
        if (direct != candidate) {
            changed += 1;
            const abs_diff = @abs(candidate - direct);
            const rel_diff = abs_diff / direct;
            const ulp_diff = floatDistanceF32(direct, candidate);
            max_abs = @max(max_abs, abs_diff);
            max_rel = @max(max_rel, rel_diff);
            max_ulp = @max(max_ulp, ulp_diff);
        }
    }
    const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
    const million_per_s = (@as(f64, @floatFromInt(sample_count)) / 1_000_000.0) /
        (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);

    try stdout.print(
        "{s}: {d:.1} M samples/s used={} changed={} max_abs={d:.9} max_rel={d:.9} max_ulp={}\n",
        .{ name, million_per_s, hybrid_used, changed, max_abs, max_rel, max_ulp },
    );
}

fn floatDistanceF32(a: f32, b: f32) u32 {
    const ai = orderedFloatBitsF32(a);
    const bi = orderedFloatBitsF32(b);
    return if (ai >= bi) ai - bi else bi - ai;
}

fn orderedFloatBitsF32(value: f32) u32 {
    const bits: u32 = @bitCast(value);
    if ((bits & 0x8000_0000) != 0) return ~bits;
    return bits | 0x8000_0000;
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

fn expVector2(dest: []f64) void {
    const VectorType = @Vector(2, f64);
    var i: usize = 0;
    while (i + 2 <= dest.len) : (i += 2) {
        var vec: VectorType = .{ dest[i], dest[i + 1] };
        vec = @exp(vec);
        inline for (0..2) |lane| dest[i + lane] = vec[lane];
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

fn expVector4F32(dest: []f32) void {
    const VectorType = @Vector(4, f32);
    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        var vec: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        vec = @exp(vec);
        inline for (0..4) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = @exp(dest[i]);
}

fn expVector2F32(dest: []f32) void {
    const VectorType = @Vector(2, f32);
    var i: usize = 0;
    while (i + 2 <= dest.len) : (i += 2) {
        var vec: VectorType = .{ dest[i], dest[i + 1] };
        vec = @exp(vec);
        inline for (0..2) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = @exp(dest[i]);
}

fn expVector8F32(dest: []f32) void {
    const VectorType = @Vector(8, f32);
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

fn expVector16F32(dest: []f32) void {
    const VectorType = @Vector(16, f32);
    var i: usize = 0;
    while (i + 16 <= dest.len) : (i += 16) {
        var vec: VectorType = .{
            dest[i],
            dest[i + 1],
            dest[i + 2],
            dest[i + 3],
            dest[i + 4],
            dest[i + 5],
            dest[i + 6],
            dest[i + 7],
            dest[i + 8],
            dest[i + 9],
            dest[i + 10],
            dest[i + 11],
            dest[i + 12],
            dest[i + 13],
            dest[i + 14],
            dest[i + 15],
        };
        vec = @exp(vec);
        inline for (0..16) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = @exp(dest[i]);
}
