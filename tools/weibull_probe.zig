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

    try stdout.print("weibull probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast sample current shape=1", 0x8e11, sample_count, sampleShapeOneCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sample exponential equivalent", 0x8e11, sample_count, sampleExponentialEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current shape=1", 0x8e11, sample_count, sampleShapeOneCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample exponential equivalent", 0x8e11, sample_count, sampleExponentialEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast fill current shape=1", 0x8e11, sample_count, fillShapeOneCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast fill exponential equivalent", 0x8e11, sample_count, fillExponentialEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill current shape=1", 0x8e11, sample_count, fillShapeOneCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill exponential equivalent", 0x8e11, sample_count, fillExponentialEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x8e1b, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar pow", 0x8e1b, sample_count, stagedScalarPow);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar exp-loglog", 0x8e1b, sample_count, stagedScalarExpLogLog);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 exp-loglog", 0x8e1b, sample_count, stagedVector4ExpLogLog);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x8e1b, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar pow", 0x8e1b, sample_count, stagedScalarPow);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar exp-loglog", 0x8e1b, sample_count, stagedScalarExpLogLog);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 exp-loglog", 0x8e1b, sample_count, stagedVector4ExpLogLog);
    try stdout.flush();
}

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillWeibullFrom(source, f64, dest, 2, 1.5);
}

fn sampleShapeOneCurrent(source: anytype) f64 {
    return alea.distributions.weibullFrom(source, f64, 2, 1);
}

fn sampleExponentialEquivalent(source: anytype) f64 {
    return 2 * alea.Rng.standardExponentialFastFrom(source, f64);
}

fn fillShapeOneCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillWeibullFrom(source, f64, dest, 2, 1);
}

fn fillExponentialEquivalent(source: anytype, dest: []f64) void {
    for (dest) |*item| item.* = 2 * alea.Rng.standardExponentialFastFrom(source, f64);
}

fn stagedScalarPow(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformScalarPow(dest, 2, 1.0 / 1.5);
}

fn stagedScalarExpLogLog(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformScalarExpLogLog(dest, 2, 1.0 / 1.5);
}

fn stagedVector4ExpLogLog(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformVector4ExpLogLog(dest, 2, 1.0 / 1.5);
}

fn transformScalarPow(dest: []f64, scale: f64, inverse_shape: f64) void {
    for (dest) |*item| item.* = scale * std.math.pow(f64, -@log(item.*), inverse_shape);
}

fn transformScalarExpLogLog(dest: []f64, scale: f64, inverse_shape: f64) void {
    for (dest) |*item| item.* = scale * @exp(@log(-@log(item.*)) * inverse_shape);
}

fn transformVector4ExpLogLog(dest: []f64, scale: f64, inverse_shape: f64) void {
    const VectorType = @Vector(4, f64);
    const scale_vec: VectorType = @splat(scale);
    const inverse_shape_vec: VectorType = @splat(inverse_shape);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const u: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = scale_vec * @exp(@log(-@log(u)) * inverse_shape_vec);
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    transformScalarExpLogLog(dest[i..], scale, inverse_shape);
}
