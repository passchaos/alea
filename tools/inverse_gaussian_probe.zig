const std = @import("std");
const alea = @import("alea");

const trials = 3;
const default_count = 4 * 1024 * 1024;

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

    try stdout.print("inverse-gaussian probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast sample current", 0x164a, sample_count, sampleCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sample cached", 0x164a, sample_count, sampleCached);
    try benchSample(alea.FastPrng, io, stdout, "fast sample four-shape cache", 0x164a, sample_count, sampleFourShapeCache);
    try benchSample(alea.FastPrng, io, stdout, "fast sample local sampler", 0x164a, sample_count, sampleLocalSampler);
    try benchSample(alea.FastPrng, io, stdout, "fast sample uniform first", 0x164a, sample_count, sampleUniformFirst);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current", 0x164b, sample_count, sampleCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample cached", 0x164b, sample_count, sampleCached);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample four-shape cache", 0x164b, sample_count, sampleFourShapeCache);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample local sampler", 0x164b, sample_count, sampleLocalSampler);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample uniform first", 0x164b, sample_count, sampleUniformFirst);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x164a, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar", 0x164a, sample_count, stagedScalar);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4", 0x164a, sample_count, stagedVector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x164a, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar", 0x164a, sample_count, stagedScalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4", 0x164a, sample_count, stagedVector4);
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
    alea.distributions.fillInverseGaussianFrom(source, f64, dest, 1, 2);
}

const cached_inverse_gaussian = alea.distributions.InverseGaussian(f64).init(1, 2) catch unreachable;
const cached_four_shape_inverse_gaussian = InverseGaussianFourShapeCache{
    .mean = 1,
    .shape = 2,
    .mean_over_2shape = 0.25,
    .mean_squared = 1,
    .four_shape = 8,
};

fn sampleCurrent(source: anytype) f64 {
    return alea.distributions.inverseGaussianFrom(source, f64, 1, 2);
}

fn sampleCached(source: anytype) f64 {
    return cached_inverse_gaussian.sampleFrom(source);
}

fn sampleFourShapeCache(source: anytype) f64 {
    return cached_four_shape_inverse_gaussian.sampleFrom(source);
}

fn sampleLocalSampler(source: anytype) f64 {
    const dist = alea.distributions.InverseGaussian(f64).init(1, 2) catch unreachable;
    return dist.sampleFrom(source);
}

const InverseGaussianFourShapeCache = struct {
    mean: f64,
    shape: f64,
    mean_over_2shape: f64,
    mean_squared: f64,
    four_shape: f64,

    fn sampleFrom(self: @This(), source: anytype) f64 {
        if (self.mean == 0 or self.shape == std.math.inf(f64)) return self.mean;
        const z = alea.Rng.normalFastFrom(source, f64, 0, 1);
        const y = self.mean * z * z;
        const x = self.mean + self.mean_over_2shape * (y - @sqrt(self.four_shape * y + y * y));
        if (alea.Rng.floatFrom(source, f64) <= self.mean / (self.mean + x)) return x;
        return self.mean_squared / x;
    }
};

fn sampleUniformFirst(source: anytype) f64 {
    const z = alea.Rng.normalFastFrom(source, f64, 0, 1);
    const u = alea.Rng.floatFrom(source, f64);
    const y = z * z;
    const x = 1 + 0.25 * (y - @sqrt(8 * y + y * y));
    if (u <= 1 / (1 + x)) return x;
    return 1 / x;
}

fn stagedScalar(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 1);
    for (dest) |*item| {
        item.* = inverseGaussianFromNormal(source, item.*, 1, 2);
    }
}

fn stagedVector4(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 1);
    inverseGaussianVector4(source, dest, 1, 2);
}

fn inverseGaussianFromNormal(source: anytype, normal: f64, mean: f64, shape: f64) f64 {
    const y = mean * normal * normal;
    const mean_over_2shape = mean / (2 * shape);
    const x = mean + mean_over_2shape * (y - @sqrt(4 * shape * y + y * y));
    if (alea.Rng.floatFrom(source, f64) <= mean / (mean + x)) return x;
    return mean * mean / x;
}

fn inverseGaussianVector4(source: anytype, dest: []f64, mean: f64, shape: f64) void {
    const VectorType = @Vector(4, f64);
    const mean_vec: VectorType = @splat(mean);
    const shape_vec: VectorType = @splat(shape);
    const mean_over_2shape: VectorType = @splat(mean / (2 * shape));
    const mean_squared: VectorType = @splat(mean * mean);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const normal: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const y = mean_vec * normal * normal;
        const x = mean_vec + mean_over_2shape * (y - @sqrt(@as(VectorType, @splat(4.0)) * shape_vec * y + y * y));
        const threshold = mean_vec / (mean_vec + x);
        const u: VectorType = .{
            alea.Rng.floatFrom(source, f64),
            alea.Rng.floatFrom(source, f64),
            alea.Rng.floatFrom(source, f64),
            alea.Rng.floatFrom(source, f64),
        };
        const out = @select(f64, u <= threshold, x, mean_squared / x);
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }
    while (i < dest.len) : (i += 1) {
        dest[i] = inverseGaussianFromNormal(source, dest[i], mean, shape);
    }
}
