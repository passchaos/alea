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

    try stdout.print("skew-normal probe count={}\n", .{sample_count});
    try benchFill(alea.FastPrng, io, stdout, "fast shape=1 current", 0x5ce8, sample_count, currentShape1);
    try benchFill(alea.FastPrng, io, stdout, "fast shape=1 staged scalar", 0x5ce8, sample_count, stagedShape1Scalar);
    try benchFill(alea.FastPrng, io, stdout, "fast shape=1 staged vector4", 0x5ce8, sample_count, stagedShape1Vector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar shape=1 current", 0x5ce8, sample_count, currentShape1);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar shape=1 staged scalar", 0x5ce8, sample_count, stagedShape1Scalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar shape=1 staged vector4", 0x5ce8, sample_count, stagedShape1Vector4);
    try benchFill(alea.FastPrng, io, stdout, "fast shape=2 current", 0x5ce2, sample_count, currentShape2);
    try benchFill(alea.FastPrng, io, stdout, "fast shape=2 staged scalar", 0x5ce2, sample_count, stagedShape2Scalar);
    try benchFill(alea.FastPrng, io, stdout, "fast shape=2 staged vector4", 0x5ce2, sample_count, stagedShape2Vector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar shape=2 current", 0x5ce2, sample_count, currentShape2);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar shape=2 staged scalar", 0x5ce2, sample_count, stagedShape2Scalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar shape=2 staged vector4", 0x5ce2, sample_count, stagedShape2Vector4);
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

fn currentShape1(source: anytype, dest: []f64) void {
    alea.distributions.fillSkewNormalFrom(source, f64, dest, 0, 1, 1);
}

fn stagedShape1Scalar(source: anytype, dest: []f64) void {
    stagedScalar(source, dest, 0, 1, 1);
}

fn stagedShape1Vector4(source: anytype, dest: []f64) void {
    stagedVector4(source, dest, 0, 1, 1);
}

fn currentShape2(source: anytype, dest: []f64) void {
    alea.distributions.fillSkewNormalFrom(source, f64, dest, 0, 1, 2);
}

fn stagedShape2Scalar(source: anytype, dest: []f64) void {
    stagedScalar(source, dest, 0, 1, 2);
}

fn stagedShape2Vector4(source: anytype, dest: []f64) void {
    stagedVector4(source, dest, 0, 1, 2);
}

fn stagedScalar(source: anytype, dest: []f64, location: f64, scale: f64, shape: f64) void {
    var second_normals: [1024]f64 = undefined;
    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, second_normals.len);
        alea.Rng.fillNormalFrom(source, f64, dest[i .. i + take], 0, 1);
        alea.Rng.fillNormalFrom(source, f64, second_normals[0..take], 0, 1);
        combineScalar(dest[i .. i + take], second_normals[0..take], location, scale, shape);
        i += take;
    }
}

fn stagedVector4(source: anytype, dest: []f64, location: f64, scale: f64, shape: f64) void {
    var second_normals: [1024]f64 = undefined;
    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, second_normals.len);
        alea.Rng.fillNormalFrom(source, f64, dest[i .. i + take], 0, 1);
        alea.Rng.fillNormalFrom(source, f64, second_normals[0..take], 0, 1);
        combineVector4(dest[i .. i + take], second_normals[0..take], location, scale, shape);
        i += take;
    }
}

fn combineScalar(dest: []f64, second_normals: []const f64, location: f64, scale: f64, shape: f64) void {
    for (dest, second_normals) |*item, second| {
        const first = item.*;
        const high = @max(first, second);
        const low = @min(first, second);
        const normalized = if (shape == -1)
            low
        else if (shape == 1)
            high
        else
            ((1.0 + shape) * high + (1.0 - shape) * low) /
                (@sqrt(1.0 + shape * shape) * @sqrt(2.0));
        item.* = location + scale * normalized;
    }
}

fn combineVector4(dest: []f64, second_normals: []const f64, location: f64, scale: f64, shape: f64) void {
    const VectorType = @Vector(4, f64);
    const location_vec: VectorType = @splat(location);
    const scale_vec: VectorType = @splat(scale);
    const shape_vec: VectorType = @splat(shape);
    const one_vec: VectorType = @splat(1.0);
    const denom_vec: VectorType = @splat(@sqrt(1.0 + shape * shape) * @sqrt(2.0));

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const first: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const second: VectorType = .{ second_normals[i], second_normals[i + 1], second_normals[i + 2], second_normals[i + 3] };
        const high = @max(first, second);
        const low = @min(first, second);
        const normalized = if (shape == -1)
            low
        else if (shape == 1)
            high
        else
            ((one_vec + shape_vec) * high + (one_vec - shape_vec) * low) / denom_vec;
        const out = location_vec + scale_vec * normalized;
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }
    combineScalar(dest[i..], second_normals[i..], location, scale, shape);
}
