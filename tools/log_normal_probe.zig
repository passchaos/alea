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
    try benchSample(alea.FastPrng, io, stdout, "fast sample current", 0x1060, sample_count, sampleCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sample standard+scale", 0x1060, sample_count, sampleStandardScale);
    try benchSample(alea.FastPrng, io, stdout, "fast sample mulAdd", 0x1060, sample_count, sampleMulAdd);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current", 0x1061, sample_count, sampleCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample standard+scale", 0x1061, sample_count, sampleStandardScale);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample mulAdd", 0x1061, sample_count, sampleMulAdd);
    try benchFill(alea.FastPrng, io, stdout, "fast normal-only fill", 0x1062, sample_count, normalOnlyFill);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x1062, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar exp", 0x1062, sample_count, stagedScalarExp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged std.math.exp", 0x1062, sample_count, stagedStdMathExp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged expm1+1", 0x1062, sample_count, stagedExpm1Exp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 exp", 0x1062, sample_count, stagedVector4Exp);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector8 exp", 0x1062, sample_count, stagedVector8Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar normal-only fill", 0x1062, sample_count, normalOnlyFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x1062, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar exp", 0x1062, sample_count, stagedScalarExp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged std.math.exp", 0x1062, sample_count, stagedStdMathExp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged expm1+1", 0x1062, sample_count, stagedExpm1Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 exp", 0x1062, sample_count, stagedVector4Exp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector8 exp", 0x1062, sample_count, stagedVector8Exp);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 normal-only fill", 0x1063, sample_count, normalOnlyFillF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 current fill", 0x1063, sample_count, currentFillF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged scalar exp", 0x1063, sample_count, stagedScalarExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged std.math.exp", 0x1063, sample_count, stagedStdMathExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged expm1+1", 0x1063, sample_count, stagedExpm1ExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged vector4 exp", 0x1063, sample_count, stagedVector4ExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged vector8 exp", 0x1063, sample_count, stagedVector8ExpF32);
    try benchFillF32(alea.FastPrng, io, stdout, "fast f32 staged vector16 exp", 0x1063, sample_count, stagedVector16ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 normal-only fill", 0x1063, sample_count, normalOnlyFillF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 current fill", 0x1063, sample_count, currentFillF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged scalar exp", 0x1063, sample_count, stagedScalarExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged std.math.exp", 0x1063, sample_count, stagedStdMathExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged expm1+1", 0x1063, sample_count, stagedExpm1ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged vector4 exp", 0x1063, sample_count, stagedVector4ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged vector8 exp", 0x1063, sample_count, stagedVector8ExpF32);
    try benchFillF32(alea.ScalarPrng, io, stdout, "scalar f32 staged vector16 exp", 0x1063, sample_count, stagedVector16ExpF32);
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

fn stagedStdMathExp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expStdMath(dest);
}

fn stagedExpm1Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expm1PlusOne(dest);
}

fn stagedVector4Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expVector4(dest);
}

fn stagedVector8Exp(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 0.25);
    expVector8(dest);
}

fn stagedScalarExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expScalarF32(dest);
}

fn stagedStdMathExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expStdMathF32(dest);
}

fn stagedExpm1ExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expm1PlusOneF32(dest);
}

fn stagedVector4ExpF32(source: anytype, dest: []f32) void {
    alea.Rng.fillNormalFrom(source, f32, dest, 0, 0.25);
    expVector4F32(dest);
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

fn expStdMath(dest: []f64) void {
    for (dest) |*item| item.* = std.math.exp(item.*);
}

fn expm1PlusOne(dest: []f64) void {
    for (dest) |*item| item.* = std.math.expm1(item.*) + 1.0;
}

fn expScalarF32(dest: []f32) void {
    for (dest) |*item| item.* = @exp(item.*);
}

fn expStdMathF32(dest: []f32) void {
    for (dest) |*item| item.* = std.math.exp(item.*);
}

fn expm1PlusOneF32(dest: []f32) void {
    for (dest) |*item| item.* = std.math.expm1(item.*) + 1.0;
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
