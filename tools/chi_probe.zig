const std = @import("std");
const alea = @import("alea");

const probe_common = @import("probe_common.zig");
const benchSample = probe_common.benchSample;
const benchFill = probe_common.benchFill4096;

const default_count = 8 * 1024 * 1024;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const sample_count = probe_common.parseCount(init, default_count);

    try stdout.print("chi probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast chi-squared dof=1 current", 0xc105, sample_count, chiSquaredOneCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast normal-square equivalent", 0xc105, sample_count, normalSquareEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar chi-squared dof=1 current", 0xc105, sample_count, chiSquaredOneCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar normal-square equivalent", 0xc105, sample_count, normalSquareEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast chi-squared dof=1 fill current", 0xc105, sample_count, chiSquaredOneFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast normal-square fill equivalent", 0xc105, sample_count, normalSquareFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar chi-squared dof=1 fill current", 0xc105, sample_count, chiSquaredOneFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar normal-square fill equivalent", 0xc105, sample_count, normalSquareFillEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast chi-squared dof=2 current", 0xc205, sample_count, chiSquaredTwoCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast exp-scale equivalent", 0xc205, sample_count, expScaleEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar chi-squared dof=2 current", 0xc205, sample_count, chiSquaredTwoCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar exp-scale equivalent", 0xc205, sample_count, expScaleEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast chi-squared dof=2 fill current", 0xc205, sample_count, chiSquaredTwoFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast exp-scale fill equivalent", 0xc205, sample_count, expScaleFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar chi-squared dof=2 fill current", 0xc205, sample_count, chiSquaredTwoFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar exp-scale fill equivalent", 0xc205, sample_count, expScaleFillEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast chi dof=1 current", 0xc101, sample_count, chiOneCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast abs-normal equivalent", 0xc101, sample_count, absNormalEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar chi dof=1 current", 0xc101, sample_count, chiOneCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar abs-normal equivalent", 0xc101, sample_count, absNormalEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast chi dof=1 fill current", 0xc101, sample_count, chiOneFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast abs-normal fill equivalent", 0xc101, sample_count, absNormalFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar chi dof=1 fill current", 0xc101, sample_count, chiOneFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar abs-normal fill equivalent", 0xc101, sample_count, absNormalFillEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast chi dof=2 current", 0xc202, sample_count, chiTwoCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast rayleigh equivalent", 0xc202, sample_count, rayleighEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast exp-rayleigh equivalent", 0xc202, sample_count, expRayleighEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar chi dof=2 current", 0xc202, sample_count, chiTwoCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar rayleigh equivalent", 0xc202, sample_count, rayleighEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar exp-rayleigh equivalent", 0xc202, sample_count, expRayleighEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast chi dof=2 fill current", 0xc202, sample_count, chiTwoFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast rayleigh fill equivalent", 0xc202, sample_count, rayleighFillEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast exp-rayleigh fill equivalent", 0xc202, sample_count, expRayleighFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar chi dof=2 fill current", 0xc202, sample_count, chiTwoFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar rayleigh fill equivalent", 0xc202, sample_count, rayleighFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar exp-rayleigh fill equivalent", 0xc202, sample_count, expRayleighFillEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0xc411, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar sqrt", 0xc411, sample_count, stagedScalar);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 sqrt", 0xc411, sample_count, stagedVector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0xc411, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar sqrt", 0xc411, sample_count, stagedScalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 sqrt", 0xc411, sample_count, stagedVector4);
    try stdout.flush();
}

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillChiFrom(source, f64, dest, 4);
}

fn chiSquaredOneCurrent(source: anytype) f64 {
    return alea.distributions.chiSquaredFrom(source, f64, 1);
}

fn normalSquareEquivalent(source: anytype) f64 {
    const z = alea.Rng.standardNormalFastFrom(source, f64);
    return z * z;
}

fn chiSquaredOneFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillChiSquaredFrom(source, f64, dest, 1);
}

fn normalSquareFillEquivalent(source: anytype, dest: []f64) void {
    for (dest) |*item| {
        const z = alea.Rng.standardNormalFastFrom(source, f64);
        item.* = z * z;
    }
}

fn chiSquaredTwoCurrent(source: anytype) f64 {
    return alea.distributions.chiSquaredFrom(source, f64, 2);
}

fn expScaleEquivalent(source: anytype) f64 {
    return 2 * alea.Rng.standardExponentialFastFrom(source, f64);
}

fn chiSquaredTwoFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillChiSquaredFrom(source, f64, dest, 2);
}

fn expScaleFillEquivalent(source: anytype, dest: []f64) void {
    for (dest) |*item| item.* = 2 * alea.Rng.standardExponentialFastFrom(source, f64);
}

fn chiOneCurrent(source: anytype) f64 {
    return alea.distributions.chiFrom(source, f64, 1);
}

fn absNormalEquivalent(source: anytype) f64 {
    return @abs(alea.Rng.standardNormalFastFrom(source, f64));
}

fn chiOneFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillChiFrom(source, f64, dest, 1);
}

fn absNormalFillEquivalent(source: anytype, dest: []f64) void {
    for (dest) |*item| item.* = @abs(alea.Rng.standardNormalFastFrom(source, f64));
}

fn chiTwoCurrent(source: anytype) f64 {
    return alea.distributions.chiFrom(source, f64, 2);
}

fn rayleighEquivalent(source: anytype) f64 {
    return alea.distributions.rayleighFrom(source, f64, 1);
}

fn expRayleighEquivalent(source: anytype) f64 {
    return @sqrt(2 * alea.Rng.standardExponentialFastFrom(source, f64));
}

fn chiTwoFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillChiFrom(source, f64, dest, 2);
}

fn rayleighFillEquivalent(source: anytype, dest: []f64) void {
    alea.distributions.fillRayleighFrom(source, f64, dest, 1);
}

fn expRayleighFillEquivalent(source: anytype, dest: []f64) void {
    for (dest) |*item| item.* = expRayleighEquivalent(source);
}

fn stagedScalar(source: anytype, dest: []f64) void {
    alea.distributions.fillChiSquaredFrom(source, f64, dest, 4);
    sqrtScalar(dest);
}

fn stagedVector4(source: anytype, dest: []f64) void {
    alea.distributions.fillChiSquaredFrom(source, f64, dest, 4);
    sqrtVector4(dest);
}

fn sqrtScalar(dest: []f64) void {
    for (dest) |*item| item.* = @sqrt(item.*);
}

fn sqrtVector4(dest: []f64) void {
    const VectorType = @Vector(4, f64);
    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const input: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = @sqrt(input);
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    sqrtScalar(dest[i..]);
}
