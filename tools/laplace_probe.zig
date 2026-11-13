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

    try stdout.print("laplace probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast sample current", 0x1a9, sample_count, sampleCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sample sign-exp", 0x1a9, sample_count, sampleSignExp);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current", 0x1a9, sample_count, sampleCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample sign-exp", 0x1a9, sample_count, sampleSignExp);
    try benchFill(alea.FastPrng, io, stdout, "fast fill sign-exp", 0x1aa, sample_count, fillSignExp);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill sign-exp", 0x1aa, sample_count, fillSignExp);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x1aa, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar log", 0x1aa, sample_count, stagedScalar);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 log", 0x1aa, sample_count, stagedVector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x1aa, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar log", 0x1aa, sample_count, stagedScalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 log", 0x1aa, sample_count, stagedVector4);
    try stdout.flush();
}

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillLaplaceFrom(source, f64, dest, 0, 1);
}

fn sampleCurrent(source: anytype) f64 {
    return alea.distributions.laplaceFrom(source, f64, 0, 1);
}

fn sampleSignExp(source: anytype) f64 {
    const magnitude = alea.Rng.standardExponentialFastFrom(source, f64);
    return if ((alea.Rng.nextFrom(source) & 1) == 0) magnitude else -magnitude;
}

fn fillSignExp(source: anytype, dest: []f64) void {
    for (dest) |*item| item.* = sampleSignExp(source);
}

fn stagedScalar(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformScalar(dest, 0, 1);
}

fn stagedVector4(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformVector4(dest, 0, 1);
}

fn transformScalar(dest: []f64, location: f64, scale: f64) void {
    for (dest) |*item| {
        const centered = item.* - 0.5;
        const sign: f64 = if (centered < 0) -1 else 1;
        item.* = location - scale * sign * @log(1.0 - 2.0 * @abs(centered));
    }
}

fn transformVector4(dest: []f64, location: f64, scale: f64) void {
    const VectorType = @Vector(4, f64);
    const location_vec: VectorType = @splat(location);
    const scale_vec: VectorType = @splat(scale);
    const half_vec: VectorType = @splat(0.5);
    const one_vec: VectorType = @splat(1.0);
    const two_vec: VectorType = @splat(2.0);
    const positive: VectorType = @splat(1.0);
    const negative: VectorType = @splat(-1.0);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const u: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const centered = u - half_vec;
        const sign = @select(f64, centered < @as(VectorType, @splat(0.0)), negative, positive);
        const out = location_vec - scale_vec * sign * @log(one_vec - two_vec * @abs(centered));
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    transformScalar(dest[i..], location, scale);
}
