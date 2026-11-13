const std = @import("std");
const alea = @import("alea");

const probe_common = @import("probe_common.zig");
const benchSample = probe_common.benchSample;
const benchFill = probe_common.benchFill1024;

const default_count = 8 * 1024 * 1024;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const sample_count = probe_common.parseCount(init, default_count);

    try stdout.print("frechet probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast sample current shape=1", 0xf7e1, sample_count, sampleShapeOneCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sample reciprocal exp", 0xf7e1, sample_count, sampleShapeOneExpReciprocal);
    try benchSample(alea.FastPrng, io, stdout, "fast sample reciprocal log", 0xf7e1, sample_count, sampleShapeOneLogReciprocal);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current shape=1", 0xf7e1, sample_count, sampleShapeOneCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample reciprocal exp", 0xf7e1, sample_count, sampleShapeOneExpReciprocal);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample reciprocal log", 0xf7e1, sample_count, sampleShapeOneLogReciprocal);
    try benchFill(alea.FastPrng, io, stdout, "fast fill current shape=1", 0xf7e1, sample_count, fillShapeOneCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast fill reciprocal exp", 0xf7e1, sample_count, fillShapeOneExpReciprocal);
    try benchFill(alea.FastPrng, io, stdout, "fast fill reciprocal log", 0xf7e1, sample_count, fillShapeOneLogReciprocal);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill current shape=1", 0xf7e1, sample_count, fillShapeOneCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill reciprocal exp", 0xf7e1, sample_count, fillShapeOneExpReciprocal);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill reciprocal log", 0xf7e1, sample_count, fillShapeOneLogReciprocal);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0xf7ec, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar pow", 0xf7ec, sample_count, stagedScalarPow);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar exp-loglog", 0xf7ec, sample_count, stagedScalarExpLogLog);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 exp-loglog", 0xf7ec, sample_count, stagedVector4ExpLogLog);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0xf7ec, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar pow", 0xf7ec, sample_count, stagedScalarPow);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar exp-loglog", 0xf7ec, sample_count, stagedScalarExpLogLog);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 exp-loglog", 0xf7ec, sample_count, stagedVector4ExpLogLog);
    try stdout.flush();
}

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillFrechetFrom(source, f64, dest, 0, 1, 3);
}

fn sampleShapeOneCurrent(source: anytype) f64 {
    return alea.distributions.frechetFrom(source, f64, 0, 1, 1);
}

fn sampleShapeOneExpReciprocal(source: anytype) f64 {
    return 1.0 / alea.Rng.standardExponentialFastFrom(source, f64);
}

fn sampleShapeOneLogReciprocal(source: anytype) f64 {
    return -1.0 / @log(alea.Rng.floatOpenClosedFrom(source, f64));
}

fn fillShapeOneCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillFrechetFrom(source, f64, dest, 0, 1, 1);
}

fn fillShapeOneExpReciprocal(source: anytype, dest: []f64) void {
    for (dest) |*item| item.* = 1.0 / alea.Rng.standardExponentialFastFrom(source, f64);
}

fn fillShapeOneLogReciprocal(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenClosedFrom(source, f64, dest);
    for (dest) |*item| item.* = -1.0 / @log(item.*);
}

fn stagedScalarPow(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenClosedFrom(source, f64, dest);
    transformScalarPow(dest, 0, 1, -1.0 / 3.0);
}

fn stagedScalarExpLogLog(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenClosedFrom(source, f64, dest);
    transformScalarExpLogLog(dest, 0, 1, -1.0 / 3.0);
}

fn stagedVector4ExpLogLog(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenClosedFrom(source, f64, dest);
    transformVector4ExpLogLog(dest, 0, 1, -1.0 / 3.0);
}

fn transformScalarPow(dest: []f64, location: f64, scale: f64, negative_inverse_shape: f64) void {
    for (dest) |*item| item.* = location + scale * std.math.pow(f64, -@log(item.*), negative_inverse_shape);
}

fn transformScalarExpLogLog(dest: []f64, location: f64, scale: f64, negative_inverse_shape: f64) void {
    for (dest) |*item| item.* = location + scale * @exp(@log(-@log(item.*)) * negative_inverse_shape);
}

fn transformVector4ExpLogLog(dest: []f64, location: f64, scale: f64, negative_inverse_shape: f64) void {
    const VectorType = @Vector(4, f64);
    const location_vec: VectorType = @splat(location);
    const scale_vec: VectorType = @splat(scale);
    const negative_inverse_shape_vec: VectorType = @splat(negative_inverse_shape);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const u: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = location_vec + scale_vec * @exp(@log(-@log(u)) * negative_inverse_shape_vec);
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    transformScalarExpLogLog(dest[i..], location, scale, negative_inverse_shape);
}
