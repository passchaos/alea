const std = @import("std");
const alea = @import("alea");

const probe_common = @import("probe_common.zig");
const benchSample = probe_common.benchSample;
const benchFill = probe_common.benchFill1024;

const default_count = 16 * 1024 * 1024;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const sample_count = probe_common.parseCount(init, default_count);

    try stdout.print("rayleigh probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast sample current", 0x7a11, sample_count, sampleCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sample exp-sqrt", 0x7a11, sample_count, sampleExpSqrt);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current", 0x7a11, sample_count, sampleCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample exp-sqrt", 0x7a11, sample_count, sampleExpSqrt);
    try benchFill(alea.FastPrng, io, stdout, "fast fill exp-sqrt", 0x7a12, sample_count, fillExpSqrt);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill exp-sqrt", 0x7a12, sample_count, fillExpSqrt);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x7a12, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar log/sqrt", 0x7a12, sample_count, stagedScalar);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 log/sqrt", 0x7a12, sample_count, stagedVector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x7a12, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar log/sqrt", 0x7a12, sample_count, stagedScalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 log/sqrt", 0x7a12, sample_count, stagedVector4);
    try stdout.flush();
}

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillRayleighFrom(source, f64, dest, 2);
}

fn sampleCurrent(source: anytype) f64 {
    return alea.distributions.rayleighFrom(source, f64, 2);
}

fn sampleExpSqrt(source: anytype) f64 {
    return 2 * @sqrt(2 * alea.Rng.standardExponentialFastFrom(source, f64));
}

fn fillExpSqrt(source: anytype, dest: []f64) void {
    for (dest) |*item| item.* = sampleExpSqrt(source);
}

fn stagedScalar(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformScalar(dest, 2);
}

fn stagedVector4(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformVector4(dest, 2);
}

fn transformScalar(dest: []f64, scale: f64) void {
    for (dest) |*item| item.* = scale * @sqrt(-2.0 * @log(item.*));
}

fn transformVector4(dest: []f64, scale: f64) void {
    const VectorType = @Vector(4, f64);
    const scale_vec: VectorType = @splat(scale);
    const neg_two_vec: VectorType = @splat(-2.0);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const u: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = scale_vec * @sqrt(neg_two_vec * @log(u));
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    transformScalar(dest[i..], scale);
}
