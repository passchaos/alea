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

    try stdout.print("unit geometry probe count={}\n", .{sample_count});
    try benchSample2(alea.FastPrng, io, stdout, "fast unit circle point current", 0xc11c1e, sample_count, sampleUnitCircleCurrent);
    try benchAlea4x64Sample2(io, stdout, "fast unit circle point lane-pair", 0xc11c1e, sample_count, sampleUnitCircleLanePair);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit circle point trig", 0xc11c1e, sample_count, sampleUnitCircleTrig);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit circle point fma", 0xc11c1e, sample_count, sampleUnitCircleFma);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit circle point numerator-fma", 0xc11c1e, sample_count, sampleUnitCircleNumeratorFma);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit circle point split-check", 0xc11c1e, sample_count, sampleUnitCircleSplitCheck);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit circle point normalize", 0xc11c1e, sample_count, sampleUnitCircleNormalize);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit circle point reciprocal", 0xc11c1e, sample_count, sampleUnitCircleReciprocal);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit circle point alt formula", 0xc11c1e, sample_count, sampleUnitCircleAltFormula);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit circle point pair", 0xc11c1e, sample_count, sampleUnitCirclePair);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit circle point range", 0xc11c1e, sample_count, sampleUnitCircleRange);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit disc point current", 0xd15c, sample_count, sampleUnitDiscCurrent);
    try benchAlea4x64Sample2(io, stdout, "fast unit disc point lane-pair", 0xd15c, sample_count, sampleUnitDiscLanePair);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit disc point fma", 0xd15c, sample_count, sampleUnitDiscFma);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit disc point pair", 0xd15c, sample_count, sampleUnitDiscPair);
    try benchSample2(alea.FastPrng, io, stdout, "fast unit disc point range", 0xd15c, sample_count, sampleUnitDiscRange);
    try benchSample3(alea.FastPrng, io, stdout, "fast unit sphere point current", 0x59e7e, sample_count, sampleUnitSphereCurrent);
    try benchAlea4x64Sample3(io, stdout, "fast unit sphere point lane-pair", 0x59e7e, sample_count, sampleUnitSphereLanePair);
    try benchSample3(alea.FastPrng, io, stdout, "fast unit sphere point fma", 0x59e7e, sample_count, sampleUnitSphereFma);
    try benchSample3(alea.FastPrng, io, stdout, "fast unit sphere point pair", 0x59e7e, sample_count, sampleUnitSpherePair);
    try benchSample3(alea.FastPrng, io, stdout, "fast unit sphere point range", 0x59e7e, sample_count, sampleUnitSphereRange);
    try benchFill(alea.FastPrng, io, stdout, "fast unit circle point-loop fill", 0xc11c1e, sample_count, pointLoopUnitCircle);
    try benchFill(alea.FastPrng, io, stdout, "fast unit disc point-loop fill", 0xd15c, sample_count, pointLoopUnitDisc);
    try benchFill3(alea.FastPrng, io, stdout, "fast unit sphere point-loop fill", 0x59e7e, sample_count, pointLoopUnitSphere);
    try benchSample3(alea.ScalarPrng, io, stdout, "scalar unit circle point current", 0xc11c1e, sample_count, sampleUnitCircleCurrent);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit circle point trig", 0xc11c1e, sample_count, sampleUnitCircleTrig);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit circle point fma", 0xc11c1e, sample_count, sampleUnitCircleFma);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit circle point numerator-fma", 0xc11c1e, sample_count, sampleUnitCircleNumeratorFma);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit circle point split-check", 0xc11c1e, sample_count, sampleUnitCircleSplitCheck);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit circle point normalize", 0xc11c1e, sample_count, sampleUnitCircleNormalize);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit circle point reciprocal", 0xc11c1e, sample_count, sampleUnitCircleReciprocal);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit circle point alt formula", 0xc11c1e, sample_count, sampleUnitCircleAltFormula);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit circle point pair", 0xc11c1e, sample_count, sampleUnitCirclePair);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit circle point range", 0xc11c1e, sample_count, sampleUnitCircleRange);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit disc point current", 0xd15c, sample_count, sampleUnitDiscCurrent);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit disc point fma", 0xd15c, sample_count, sampleUnitDiscFma);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit disc point pair", 0xd15c, sample_count, sampleUnitDiscPair);
    try benchSample2(alea.ScalarPrng, io, stdout, "scalar unit disc point range", 0xd15c, sample_count, sampleUnitDiscRange);
    try benchSample3(alea.ScalarPrng, io, stdout, "scalar unit sphere point current", 0x59e7e, sample_count, sampleUnitSphereCurrent);
    try benchSample3(alea.ScalarPrng, io, stdout, "scalar unit sphere point fma", 0x59e7e, sample_count, sampleUnitSphereFma);
    try benchSample3(alea.ScalarPrng, io, stdout, "scalar unit sphere point pair", 0x59e7e, sample_count, sampleUnitSpherePair);
    try benchSample3(alea.ScalarPrng, io, stdout, "scalar unit sphere point range", 0x59e7e, sample_count, sampleUnitSphereRange);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar unit circle point-loop fill", 0xc11c1e, sample_count, pointLoopUnitCircle);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar unit disc point-loop fill", 0xd15c, sample_count, pointLoopUnitDisc);
    try benchFill3(alea.ScalarPrng, io, stdout, "scalar unit sphere point-loop fill", 0x59e7e, sample_count, pointLoopUnitSphere);
    try benchFill(alea.FastPrng, io, stdout, "fast unit circle current fill", 0xc11c1e, sample_count, currentUnitCircle);
    try benchFill(alea.FastPrng, io, stdout, "fast unit circle batched candidates", 0xc11c1e, sample_count, batchedUnitCircle);
    try benchFill(alea.FastPrng, io, stdout, "fast unit circle numerator-fma fill", 0xc11c1e, sample_count, batchedUnitCircleNumeratorFma);
    try benchFill(alea.FastPrng, io, stdout, "fast unit disc current fill", 0xd15c, sample_count, currentUnitDisc);
    try benchFill(alea.FastPrng, io, stdout, "fast unit disc batched candidates", 0xd15c, sample_count, batchedUnitDisc);
    try benchFill3(alea.FastPrng, io, stdout, "fast unit sphere current fill", 0x59e7e, sample_count, currentUnitSphere);
    try benchFill3(alea.FastPrng, io, stdout, "fast unit sphere batched candidates", 0x59e7e, sample_count, batchedUnitSphere);
    try benchSample3(alea.FastPrng, io, stdout, "fast unit ball point current", 0xba11, sample_count, sampleUnitBallCurrent);
    try benchSample3(alea.FastPrng, io, stdout, "fast unit ball point fma", 0xba11, sample_count, sampleUnitBallFma);
    try benchFill3(alea.FastPrng, io, stdout, "fast unit ball current fill", 0xba11, sample_count, currentUnitBall);
    try benchFill3(alea.FastPrng, io, stdout, "fast unit ball batched x2", 0xba11, sample_count, batchedUnitBall2);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar unit circle current fill", 0xc11c1e, sample_count, currentUnitCircle);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar unit circle batched candidates", 0xc11c1e, sample_count, batchedUnitCircle);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar unit circle numerator-fma fill", 0xc11c1e, sample_count, batchedUnitCircleNumeratorFma);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar unit disc current fill", 0xd15c, sample_count, currentUnitDisc);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar unit disc batched candidates", 0xd15c, sample_count, batchedUnitDisc);
    try benchFill3(alea.ScalarPrng, io, stdout, "scalar unit sphere current fill", 0x59e7e, sample_count, currentUnitSphere);
    try benchFill3(alea.ScalarPrng, io, stdout, "scalar unit sphere batched candidates", 0x59e7e, sample_count, batchedUnitSphere);
    try benchSample3(alea.ScalarPrng, io, stdout, "scalar unit ball point current", 0xba11, sample_count, sampleUnitBallCurrent);
    try benchSample3(alea.ScalarPrng, io, stdout, "scalar unit ball point fma", 0xba11, sample_count, sampleUnitBallFma);
    try benchFill3(alea.ScalarPrng, io, stdout, "scalar unit ball current fill", 0xba11, sample_count, currentUnitBall);
    try benchFill3(alea.ScalarPrng, io, stdout, "scalar unit ball batched x2", 0xba11, sample_count, batchedUnitBall2);
    try benchFill3(alea.ScalarPrng, io, stdout, "scalar unit ball batched x3", 0xba11, sample_count, batchedUnitBall3);
    try benchFill3(alea.ScalarPrng, io, stdout, "scalar unit ball batched x4", 0xba11, sample_count, batchedUnitBall4);
    try stdout.flush();
}

fn benchAlea4x64Sample2(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime sampleFn: fn (*LaneAlea4x64) [2]f64,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = LaneAlea4x64.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var checksum: f64 = 0;
        var i: usize = 0;
        while (i < sample_count) : (i += 1) checksum += sampleFn(&engine)[0];

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

fn benchAlea4x64Sample3(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime sampleFn: fn (*LaneAlea4x64) [3]f64,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = LaneAlea4x64.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var checksum: f64 = 0;
        var i: usize = 0;
        while (i < sample_count) : (i += 1) checksum += sampleFn(&engine)[0];

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

fn benchSample2(
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
        while (i < sample_count) : (i += 1) checksum += sampleFn(&engine)[0];

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

fn benchSample3(
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
        while (i < sample_count) : (i += 1) checksum += sampleFn(&engine)[0];

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
    var out: [1024][2]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value[0];
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

fn benchFill3(
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
    var out: [1024][3]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value[0];
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

fn currentUnitDisc(source: anytype, dest: [][2]f64) void {
    alea.distributions.fillUnitDiscFrom(source, f64, dest);
}

fn currentUnitCircle(source: anytype, dest: [][2]f64) void {
    alea.distributions.fillUnitCircleFrom(source, f64, dest);
}

fn currentUnitSphere(source: anytype, dest: [][3]f64) void {
    alea.distributions.fillUnitSphereFrom(source, f64, dest);
}

fn currentUnitBall(source: anytype, dest: [][3]f64) void {
    alea.distributions.fillUnitBallFrom(source, f64, dest);
}

fn pointLoopUnitCircle(source: anytype, dest: [][2]f64) void {
    for (dest) |*item| item.* = sampleUnitCircleFma(source);
}

fn pointLoopUnitDisc(source: anytype, dest: [][2]f64) void {
    for (dest) |*item| item.* = sampleUnitDiscFma(source);
}

fn pointLoopUnitSphere(source: anytype, dest: [][3]f64) void {
    for (dest) |*item| item.* = sampleUnitSphereFma(source);
}

fn sampleUnitCircleCurrent(source: anytype) [2]f64 {
    return alea.distributions.unitCircleFrom(source, f64);
}

fn sampleUnitDiscCurrent(source: anytype) [2]f64 {
    return alea.distributions.unitDiscFrom(source, f64);
}

fn sampleUnitSphereCurrent(source: anytype) [3]f64 {
    return alea.distributions.unitSphereFrom(source, f64);
}

fn sampleUnitBallCurrent(source: anytype) [3]f64 {
    return alea.distributions.unitBallFrom(source, f64);
}

fn signedUnitFloat(source: anytype) f64 {
    const repr = (@as(u64, 0x400) << 52) | (alea.Rng.nextFrom(source) >> 12);
    return @as(f64, @bitCast(repr)) - 3.0;
}

fn sampleUnitCircleTrig(source: anytype) [2]f64 {
    const angle = 2.0 * std.math.pi * alea.Rng.floatFrom(source, f64);
    return .{ @cos(angle), @sin(angle) };
}

fn sampleUnitCircleFma(source: anytype) [2]f64 {
    while (true) {
        const x = signedUnitFloat(source);
        const y = signedUnitFloat(source);
        const x2 = x * x;
        const y2 = y * y;
        const sum = @mulAdd(f64, y, y, x2);
        if (!(sum > 0 and sum < 1)) continue;
        return .{ (x2 - y2) / sum, 2 * x * y / sum };
    }
}

fn sampleUnitCircleNumeratorFma(source: anytype) [2]f64 {
    while (true) {
        const x = signedUnitFloat(source);
        const y = signedUnitFloat(source);
        const x2 = x * x;
        const sum = @mulAdd(f64, y, y, x2);
        if (!(sum > 0 and sum < 1)) continue;
        return .{ @mulAdd(f64, -y, y, x2) / sum, @mulAdd(f64, 2 * x, y, 0) / sum };
    }
}

fn sampleUnitCircleSplitCheck(source: anytype) [2]f64 {
    while (true) {
        const x = signedUnitFloat(source);
        const y = signedUnitFloat(source);
        const x2 = x * x;
        const y2 = y * y;
        const sum = @mulAdd(f64, y, y, x2);
        if (sum >= 1) continue;
        if (sum == 0) continue;
        return .{ (x2 - y2) / sum, 2 * x * y / sum };
    }
}

fn sampleUnitCircleNormalize(source: anytype) [2]f64 {
    while (true) {
        const x = signedUnitFloat(source);
        const y = signedUnitFloat(source);
        const sum = @mulAdd(f64, y, y, x * x);
        if (!(sum > 0 and sum < 1)) continue;
        const scale = 1 / @sqrt(sum);
        return .{ x * scale, y * scale };
    }
}

fn sampleUnitCircleReciprocal(source: anytype) [2]f64 {
    while (true) {
        const x = signedUnitFloat(source);
        const y = signedUnitFloat(source);
        const x2 = x * x;
        const y2 = y * y;
        const sum = @mulAdd(f64, y, y, x2);
        if (!(sum > 0 and sum < 1)) continue;
        const inv_sum = 1 / sum;
        return .{ (x2 - y2) * inv_sum, 2 * x * y * inv_sum };
    }
}

fn sampleUnitCircleAltFormula(source: anytype) [2]f64 {
    while (true) {
        const x = signedUnitFloat(source);
        const y = signedUnitFloat(source);
        const x2 = x * x;
        const sum = @mulAdd(f64, y, y, x2);
        if (!(sum > 0 and sum < 1)) continue;
        return .{ 2 * x2 / sum - 1, 2 * x * y / sum };
    }
}

fn sampleUnitDiscFma(source: anytype) [2]f64 {
    while (true) {
        const x = signedUnitFloat(source);
        const y = signedUnitFloat(source);
        if (@mulAdd(f64, y, y, x * x) <= 1) return .{ x, y };
    }
}

fn sampleUnitSphereFma(source: anytype) [3]f64 {
    while (true) {
        const x = signedUnitFloat(source);
        const y = signedUnitFloat(source);
        const sum = @mulAdd(f64, y, y, x * x);
        if (sum >= 1) continue;
        const factor = 2 * @sqrt(1 - sum);
        return .{ x * factor, y * factor, 1 - 2 * sum };
    }
}

fn sampleUnitBallFma(source: anytype) [3]f64 {
    while (true) {
        const x = signedUnitFloat(source);
        const y = signedUnitFloat(source);
        const z = signedUnitFloat(source);
        const xy = @mulAdd(f64, y, y, x * x);
        if (@mulAdd(f64, z, z, xy) <= 1) return .{ x, y, z };
    }
}

const LaneAlea4x64 = struct {
    state: [4]u64,
    index: usize,

    const increment = [_]u64{
        0xa0761d6478bd642f,
        0xe7037ed1a0b428db,
        0x8ebc6af09c88c6e3,
        0x589965cc75374cc3,
    };

    fn init(seed: u64) LaneAlea4x64 {
        const engine = alea.FastPrng.init(seed);
        return .{ .state = engine.state, .index = 0 };
    }

    pub fn next(self: *LaneAlea4x64) u64 {
        const lane_index = self.index & 3;
        self.index += 1;
        self.state[lane_index] +%= increment[lane_index];
        var z = self.state[lane_index];
        z = (z ^ (z >> 30)) *% 0xbf58476d1ce4e5b9;
        z = (z ^ (z >> 27)) *% 0x94d049bb133111eb;
        return z ^ (z >> 31);
    }
};

fn sampleUnitCircleLanePair(source: *LaneAlea4x64) [2]f64 {
    return sampleUnitCirclePair(source);
}

fn sampleUnitDiscLanePair(source: *LaneAlea4x64) [2]f64 {
    return sampleUnitDiscPair(source);
}

fn sampleUnitSphereLanePair(source: *LaneAlea4x64) [3]f64 {
    return sampleUnitSpherePair(source);
}

fn signedUnitPair(source: anytype) @Vector(2, f64) {
    const RawVector = @Vector(2, u64);
    const raw: RawVector = .{
        (@as(u64, 0x400) << 52) | (alea.Rng.nextFrom(source) >> 12),
        (@as(u64, 0x400) << 52) | (alea.Rng.nextFrom(source) >> 12),
    };
    return @as(@Vector(2, f64), @bitCast(raw)) - @as(@Vector(2, f64), @splat(3.0));
}

fn sampleUnitCirclePair(source: anytype) [2]f64 {
    while (true) {
        const pair = signedUnitPair(source);
        const x = pair[0];
        const y = pair[1];
        const sum = x * x + y * y;
        if (!(sum > 0 and sum < 1)) continue;
        return .{ (x * x - y * y) / sum, 2 * x * y / sum };
    }
}

fn sampleUnitDiscPair(source: anytype) [2]f64 {
    while (true) {
        const pair = signedUnitPair(source);
        const x = pair[0];
        const y = pair[1];
        if (x * x + y * y <= 1) return .{ x, y };
    }
}

fn sampleUnitSpherePair(source: anytype) [3]f64 {
    while (true) {
        const pair = signedUnitPair(source);
        const x = pair[0];
        const y = pair[1];
        const sum = x * x + y * y;
        if (sum >= 1) continue;
        const factor = 2 * @sqrt(1 - sum);
        return .{ x * factor, y * factor, 1 - 2 * sum };
    }
}

fn sampleUnitCircleRange(source: anytype) [2]f64 {
    while (true) {
        const x = alea.Rng.floatRangeFrom(source, f64, -1, 1);
        const y = alea.Rng.floatRangeFrom(source, f64, -1, 1);
        const sum = x * x + y * y;
        if (!(sum > 0 and sum < 1)) continue;
        return .{ (x * x - y * y) / sum, 2 * x * y / sum };
    }
}

fn sampleUnitDiscRange(source: anytype) [2]f64 {
    while (true) {
        const x = alea.Rng.floatRangeFrom(source, f64, -1, 1);
        const y = alea.Rng.floatRangeFrom(source, f64, -1, 1);
        if (x * x + y * y <= 1) return .{ x, y };
    }
}

fn sampleUnitSphereRange(source: anytype) [3]f64 {
    while (true) {
        const x = alea.Rng.floatRangeFrom(source, f64, -1, 1);
        const y = alea.Rng.floatRangeFrom(source, f64, -1, 1);
        const sum = x * x + y * y;
        if (sum >= 1) continue;
        const factor = 2 * @sqrt(1 - sum);
        return .{ x * factor, y * factor, 1 - 2 * sum };
    }
}

fn batchedUnitCircle(source: anytype, dest: [][2]f64) void {
    var x_candidates: [2048]f64 = undefined;
    var y_candidates: [2048]f64 = undefined;

    var filled: usize = 0;
    while (filled < dest.len) {
        const remaining = dest.len - filled;
        const candidate_count = @min(x_candidates.len, @max(remaining, remaining * 2));
        fillSignedUnit(source, x_candidates[0..candidate_count]);
        fillSignedUnit(source, y_candidates[0..candidate_count]);

        var i: usize = 0;
        while (i < candidate_count and filled < dest.len) : (i += 1) {
            const x = x_candidates[i];
            const y = y_candidates[i];
            const sum = x * x + y * y;
            if (sum > 0 and sum < 1) {
                dest[filled] = .{ (x * x - y * y) / sum, 2 * x * y / sum };
                filled += 1;
            }
        }
    }
}

fn batchedUnitCircleNumeratorFma(source: anytype, dest: [][2]f64) void {
    var x_candidates: [2048]f64 = undefined;
    var y_candidates: [2048]f64 = undefined;

    var filled: usize = 0;
    while (filled < dest.len) {
        const remaining = dest.len - filled;
        const candidate_count = @min(x_candidates.len, @max(remaining, remaining * 2));
        fillSignedUnit(source, x_candidates[0..candidate_count]);
        fillSignedUnit(source, y_candidates[0..candidate_count]);

        var i: usize = 0;
        while (i < candidate_count and filled < dest.len) : (i += 1) {
            const x = x_candidates[i];
            const y = y_candidates[i];
            const x2 = x * x;
            const sum = @mulAdd(f64, y, y, x2);
            if (sum > 0 and sum < 1) {
                dest[filled] = .{ @mulAdd(f64, -y, y, x2) / sum, @mulAdd(f64, 2 * x, y, 0) / sum };
                filled += 1;
            }
        }
    }
}

fn batchedUnitDisc(source: anytype, dest: [][2]f64) void {
    var x_candidates: [2048]f64 = undefined;
    var y_candidates: [2048]f64 = undefined;

    var filled: usize = 0;
    while (filled < dest.len) {
        const remaining = dest.len - filled;
        const candidate_count = @min(x_candidates.len, @max(remaining, remaining * 2));
        fillSignedUnit(source, x_candidates[0..candidate_count]);
        fillSignedUnit(source, y_candidates[0..candidate_count]);

        var i: usize = 0;
        while (i < candidate_count and filled < dest.len) : (i += 1) {
            const x = x_candidates[i];
            const y = y_candidates[i];
            if (x * x + y * y <= 1) {
                dest[filled] = .{ x, y };
                filled += 1;
            }
        }
    }
}

fn batchedUnitSphere(source: anytype, dest: [][3]f64) void {
    var x_candidates: [2048]f64 = undefined;
    var y_candidates: [2048]f64 = undefined;

    var filled: usize = 0;
    while (filled < dest.len) {
        const remaining = dest.len - filled;
        const candidate_count = @min(x_candidates.len, @max(remaining, remaining * 2));
        fillSignedUnit(source, x_candidates[0..candidate_count]);
        fillSignedUnit(source, y_candidates[0..candidate_count]);

        var i: usize = 0;
        while (i < candidate_count and filled < dest.len) : (i += 1) {
            const x = x_candidates[i];
            const y = y_candidates[i];
            const sum = x * x + y * y;
            if (sum < 1) {
                const factor = 2 * @sqrt(1 - sum);
                dest[filled] = .{ x * factor, y * factor, 1 - 2 * sum };
                filled += 1;
            }
        }
    }
}

fn batchedUnitBall2(source: anytype, dest: [][3]f64) void {
    batchedUnitBall(source, dest, 2);
}

fn batchedUnitBall3(source: anytype, dest: [][3]f64) void {
    batchedUnitBall(source, dest, 3);
}

fn batchedUnitBall4(source: anytype, dest: [][3]f64) void {
    batchedUnitBall(source, dest, 4);
}

fn batchedUnitBall(source: anytype, dest: [][3]f64, comptime multiplier: usize) void {
    var x_candidates: [4096]f64 = undefined;
    var y_candidates: [4096]f64 = undefined;
    var z_candidates: [4096]f64 = undefined;

    var filled: usize = 0;
    while (filled < dest.len) {
        const remaining = dest.len - filled;
        const candidate_count = @min(x_candidates.len, @max(remaining, remaining * multiplier));
        fillSignedUnit(source, x_candidates[0..candidate_count]);
        fillSignedUnit(source, y_candidates[0..candidate_count]);
        fillSignedUnit(source, z_candidates[0..candidate_count]);

        var i: usize = 0;
        while (i < candidate_count and filled < dest.len) : (i += 1) {
            const x = x_candidates[i];
            const y = y_candidates[i];
            const z = z_candidates[i];
            if (x * x + y * y + z * z <= 1) {
                dest[filled] = .{ x, y, z };
                filled += 1;
            }
        }
    }
}

fn fillSignedUnit(source: anytype, dest: []f64) void {
    for (dest) |*item| {
        const repr = (@as(u64, 0x400) << 52) | (alea.Rng.nextFrom(source) >> 12);
        item.* = @as(f64, @bitCast(repr)) - 3.0;
    }
}
