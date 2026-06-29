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

    try stdout.print("kumaraswamy probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast sample current alpha=1 beta=5", 0x9a15, sample_count, sampleAlphaOneCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sample alpha-one equivalent", 0x9a15, sample_count, sampleAlphaOneEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast sampler current alpha=1 beta=5", 0x9a15, sample_count, samplerAlphaOneCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current alpha=1 beta=5", 0x9a15, sample_count, sampleAlphaOneCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample alpha-one equivalent", 0x9a15, sample_count, sampleAlphaOneEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sampler current alpha=1 beta=5", 0x9a15, sample_count, samplerAlphaOneCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast fill current alpha=1 beta=5", 0x9a15, sample_count, fillAlphaOneCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast fill alpha-one equivalent", 0x9a15, sample_count, fillAlphaOneEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast sampler fill current alpha=1 beta=5", 0x9a15, sample_count, samplerAlphaOneFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill current alpha=1 beta=5", 0x9a15, sample_count, fillAlphaOneCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill alpha-one equivalent", 0x9a15, sample_count, fillAlphaOneEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar sampler fill current alpha=1 beta=5", 0x9a15, sample_count, samplerAlphaOneFillCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sample current alpha=2 beta=1", 0x9a21, sample_count, sampleBetaOneCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sample beta-one equivalent", 0x9a21, sample_count, sampleBetaOneEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast sampler current alpha=2 beta=1", 0x9a21, sample_count, samplerBetaOneCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current alpha=2 beta=1", 0x9a21, sample_count, sampleBetaOneCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample beta-one equivalent", 0x9a21, sample_count, sampleBetaOneEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sampler current alpha=2 beta=1", 0x9a21, sample_count, samplerBetaOneCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast fill current alpha=2 beta=1", 0x9a21, sample_count, fillBetaOneCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast fill beta-one equivalent", 0x9a21, sample_count, fillBetaOneEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast sampler fill current alpha=2 beta=1", 0x9a21, sample_count, samplerBetaOneFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill current alpha=2 beta=1", 0x9a21, sample_count, fillBetaOneCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill beta-one equivalent", 0x9a21, sample_count, fillBetaOneEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar sampler fill current alpha=2 beta=1", 0x9a21, sample_count, samplerBetaOneFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x9a78, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar pow", 0x9a78, sample_count, stagedScalarPow);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar exp-log", 0x9a78, sample_count, stagedScalarExpLog);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 exp-log", 0x9a78, sample_count, stagedVector4ExpLog);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x9a78, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar pow", 0x9a78, sample_count, stagedScalarPow);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar exp-log", 0x9a78, sample_count, stagedScalarExpLog);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 exp-log", 0x9a78, sample_count, stagedVector4ExpLog);
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

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillKumaraswamyFrom(source, f64, dest, 2, 5);
}

fn sampleAlphaOneCurrent(source: anytype) f64 {
    return alea.distributions.kumaraswamyFrom(source, f64, 1, 5);
}

fn sampleAlphaOneEquivalent(source: anytype) f64 {
    return 1 - std.math.pow(f64, 1 - alea.Rng.floatOpenFrom(source, f64), 0.2);
}

fn fillAlphaOneCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillKumaraswamyFrom(source, f64, dest, 1, 5);
}

fn fillAlphaOneEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    for (dest) |*item| item.* = 1 - std.math.pow(f64, 1 - item.*, 0.2);
}

fn samplerAlphaOneCurrent(source: anytype) f64 {
    const sampler = alea.distributions.Kumaraswamy(f64).init(1, 5) catch unreachable;
    return sampler.sampleFrom(source);
}

fn samplerAlphaOneFillCurrent(source: anytype, dest: []f64) void {
    const sampler = alea.distributions.Kumaraswamy(f64).init(1, 5) catch unreachable;
    sampler.fillFrom(source, dest);
}

fn sampleBetaOneCurrent(source: anytype) f64 {
    return alea.distributions.kumaraswamyFrom(source, f64, 2, 1);
}

fn sampleBetaOneEquivalent(source: anytype) f64 {
    return @sqrt(alea.Rng.floatOpenFrom(source, f64));
}

fn fillBetaOneCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillKumaraswamyFrom(source, f64, dest, 2, 1);
}

fn fillBetaOneEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    for (dest) |*item| item.* = @sqrt(item.*);
}

fn samplerBetaOneCurrent(source: anytype) f64 {
    const sampler = alea.distributions.Kumaraswamy(f64).init(2, 1) catch unreachable;
    return sampler.sampleFrom(source);
}

fn samplerBetaOneFillCurrent(source: anytype, dest: []f64) void {
    const sampler = alea.distributions.Kumaraswamy(f64).init(2, 1) catch unreachable;
    sampler.fillFrom(source, dest);
}

fn stagedScalarPow(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformScalarPow(dest, 0.5, 0.2);
}

fn stagedScalarExpLog(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformScalarExpLog(dest, 0.5, 0.2);
}

fn stagedVector4ExpLog(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformVector4ExpLog(dest, 0.5, 0.2);
}

fn transformScalarPow(dest: []f64, inverse_alpha: f64, inverse_beta: f64) void {
    for (dest) |*item| {
        const u = item.*;
        item.* = std.math.pow(f64, 1.0 - std.math.pow(f64, 1.0 - u, inverse_beta), inverse_alpha);
    }
}

fn transformScalarExpLog(dest: []f64, inverse_alpha: f64, inverse_beta: f64) void {
    for (dest) |*item| {
        const u = item.*;
        const inner = 1.0 - @exp(@log(1.0 - u) * inverse_beta);
        item.* = @exp(@log(inner) * inverse_alpha);
    }
}

fn transformVector4ExpLog(dest: []f64, inverse_alpha: f64, inverse_beta: f64) void {
    const VectorType = @Vector(4, f64);
    const inverse_alpha_vec: VectorType = @splat(inverse_alpha);
    const inverse_beta_vec: VectorType = @splat(inverse_beta);
    const one_vec: VectorType = @splat(1.0);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const u: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const inner = one_vec - @exp(@log(one_vec - u) * inverse_beta_vec);
        const out = @exp(@log(inner) * inverse_alpha_vec);
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    transformScalarExpLog(dest[i..], inverse_alpha, inverse_beta);
}
