const std = @import("std");
const alea = @import("alea");

const probe_common = @import("probe_common.zig");
const benchSample = probe_common.benchSample;
const benchFill = probe_common.benchFill4096;

const default_count = 16 * 1024 * 1024;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const sample_count = probe_common.parseCount(init, default_count);

    try stdout.print("gamma shape probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast gamma current shape=1 scale=3", 0x6a11, sample_count, gammaCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast exponential equivalent", 0x6a11, sample_count, exponentialEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar gamma current shape=1 scale=3", 0x6a11, sample_count, gammaCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar exponential equivalent", 0x6a11, sample_count, exponentialEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast gamma fill current shape=1 scale=3", 0x6a11, sample_count, gammaFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast exponential fill equivalent", 0x6a11, sample_count, exponentialFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar gamma fill current shape=1 scale=3", 0x6a11, sample_count, gammaFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar exponential fill equivalent", 0x6a11, sample_count, exponentialFillEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast gamma current shape=0.5 scale=3", 0x6a05, sample_count, gammaHalfCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast normal-square equivalent", 0x6a05, sample_count, normalSquareEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar gamma current shape=0.5 scale=3", 0x6a05, sample_count, gammaHalfCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar normal-square equivalent", 0x6a05, sample_count, normalSquareEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast gamma fill current shape=0.5 scale=3", 0x6a05, sample_count, gammaHalfFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast normal-square fill equivalent", 0x6a05, sample_count, normalSquareFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar gamma fill current shape=0.5 scale=3", 0x6a05, sample_count, gammaHalfFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar normal-square fill equivalent", 0x6a05, sample_count, normalSquareFillEquivalent);
    try stdout.flush();
}

fn gammaCurrent(source: anytype) f64 {
    return alea.distributions.gammaFrom(source, f64, 1, 3);
}

fn exponentialEquivalent(source: anytype) f64 {
    return alea.Rng.standardExponentialFastFrom(source, f64) * 3;
}

fn gammaFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillGammaFrom(source, f64, dest, 1, 3);
}

fn exponentialFillEquivalent(source: anytype, dest: []f64) void {
    for (dest) |*item| item.* = alea.Rng.standardExponentialFastFrom(source, f64) * 3;
}

fn gammaHalfCurrent(source: anytype) f64 {
    return alea.distributions.gammaFrom(source, f64, 0.5, 3);
}

fn normalSquareEquivalent(source: anytype) f64 {
    const z = alea.Rng.standardNormalFastFrom(source, f64);
    return 1.5 * z * z;
}

fn gammaHalfFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillGammaFrom(source, f64, dest, 0.5, 3);
}

fn normalSquareFillEquivalent(source: anytype, dest: []f64) void {
    for (dest) |*item| {
        const z = alea.Rng.standardNormalFastFrom(source, f64);
        item.* = 1.5 * z * z;
    }
}
