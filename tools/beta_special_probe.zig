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

    try stdout.print("beta special probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast beta current 1,1", 0xbe11, sample_count, betaUnitCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast uniform equivalent", 0xbe11, sample_count, uniformEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast sampler current 1,1", 0xbe11, sample_count, betaUnitSamplerCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar beta current 1,1", 0xbe11, sample_count, betaUnitCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar uniform equivalent", 0xbe11, sample_count, uniformEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sampler current 1,1", 0xbe11, sample_count, betaUnitSamplerCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast beta fill current 1,1", 0xbe11, sample_count, betaUnitFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast uniform fill equivalent", 0xbe11, sample_count, uniformFillEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast sampler fill current 1,1", 0xbe11, sample_count, betaUnitSamplerFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar beta fill current 1,1", 0xbe11, sample_count, betaUnitFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar uniform fill equivalent", 0xbe11, sample_count, uniformFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar sampler fill current 1,1", 0xbe11, sample_count, betaUnitSamplerFillCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast beta current 2,1", 0xbe21, sample_count, betaAlphaCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast sqrt-uniform equivalent", 0xbe21, sample_count, sqrtUniformEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar beta current 2,1", 0xbe21, sample_count, betaAlphaCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sqrt-uniform equivalent", 0xbe21, sample_count, sqrtUniformEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast beta fill current 2,1", 0xbe21, sample_count, betaAlphaFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast sqrt-uniform fill equivalent", 0xbe21, sample_count, sqrtUniformFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar beta fill current 2,1", 0xbe21, sample_count, betaAlphaFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar sqrt-uniform fill equivalent", 0xbe21, sample_count, sqrtUniformFillEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast beta current 1,5", 0xbe15, sample_count, betaBetaCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast complement-root equivalent", 0xbe15, sample_count, complementRootEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar beta current 1,5", 0xbe15, sample_count, betaBetaCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar complement-root equivalent", 0xbe15, sample_count, complementRootEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast beta fill current 1,5", 0xbe15, sample_count, betaBetaFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast complement-root fill equivalent", 0xbe15, sample_count, complementRootFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar beta fill current 1,5", 0xbe15, sample_count, betaBetaFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar complement-root fill equivalent", 0xbe15, sample_count, complementRootFillEquivalent);
    try benchSample(alea.FastPrng, io, stdout, "fast beta current 1,2", 0xbe12, sample_count, betaBetaTwoCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast complement-sqrt equivalent", 0xbe12, sample_count, complementSqrtEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar beta current 1,2", 0xbe12, sample_count, betaBetaTwoCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar complement-sqrt equivalent", 0xbe12, sample_count, complementSqrtEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast beta fill current 1,2", 0xbe12, sample_count, betaBetaTwoFillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast complement-sqrt fill equivalent", 0xbe12, sample_count, complementSqrtFillEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar beta fill current 1,2", 0xbe12, sample_count, betaBetaTwoFillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar complement-sqrt fill equivalent", 0xbe12, sample_count, complementSqrtFillEquivalent);
    try stdout.flush();
}

fn betaUnitCurrent(source: anytype) f64 {
    return alea.distributions.betaFrom(source, f64, 1, 1);
}

fn uniformEquivalent(source: anytype) f64 {
    return alea.Rng.floatFrom(source, f64);
}

fn betaUnitFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillBetaFrom(source, f64, dest, 1, 1);
}

fn uniformFillEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillFrom(source, f64, dest);
}

fn betaUnitSamplerCurrent(source: anytype) f64 {
    const sampler = alea.distributions.Beta(f64).init(1, 1) catch unreachable;
    return sampler.sampleFrom(source);
}

fn betaUnitSamplerFillCurrent(source: anytype, dest: []f64) void {
    const sampler = alea.distributions.Beta(f64).init(1, 1) catch unreachable;
    sampler.fillFrom(source, dest);
}

fn betaAlphaCurrent(source: anytype) f64 {
    return alea.distributions.betaFrom(source, f64, 2, 1);
}

fn sqrtUniformEquivalent(source: anytype) f64 {
    return @sqrt(alea.Rng.floatOpenFrom(source, f64));
}

fn betaAlphaFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillBetaFrom(source, f64, dest, 2, 1);
}

fn sqrtUniformFillEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    for (dest) |*item| item.* = @sqrt(item.*);
}

fn betaBetaCurrent(source: anytype) f64 {
    return alea.distributions.betaFrom(source, f64, 1, 5);
}

fn complementRootEquivalent(source: anytype) f64 {
    return 1.0 - std.math.pow(f64, alea.Rng.floatOpenFrom(source, f64), 0.2);
}

fn betaBetaFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillBetaFrom(source, f64, dest, 1, 5);
}

fn complementRootFillEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    for (dest) |*item| item.* = 1.0 - std.math.pow(f64, item.*, 0.2);
}

fn betaBetaTwoCurrent(source: anytype) f64 {
    return alea.distributions.betaFrom(source, f64, 1, 2);
}

fn complementSqrtEquivalent(source: anytype) f64 {
    return 1.0 - @sqrt(alea.Rng.floatOpenFrom(source, f64));
}

fn betaBetaTwoFillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillBetaFrom(source, f64, dest, 1, 2);
}

fn complementSqrtFillEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    for (dest) |*item| item.* = 1.0 - @sqrt(item.*);
}
