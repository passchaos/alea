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

    try stdout.print("pert probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast sample current shape=0", 0x9e70, sample_count, sampleShapeZeroCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast uniform equivalent", 0x9e70, sample_count, sampleUniformEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar sample current shape=0", 0x9e70, sample_count, sampleShapeZeroCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar uniform equivalent", 0x9e70, sample_count, sampleUniformEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast fill current shape=0", 0x9e70, sample_count, fillShapeZeroCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast uniform fill equivalent", 0x9e70, sample_count, fillUniformEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fill current shape=0", 0x9e70, sample_count, fillShapeZeroCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar uniform fill equivalent", 0x9e70, sample_count, fillUniformEquivalent);
    try stdout.flush();
}

fn sampleShapeZeroCurrent(source: anytype) f64 {
    return alea.distributions.pertFrom(source, f64, -1, 0.5, 2, 0);
}

fn sampleUniformEquivalent(source: anytype) f64 {
    return alea.Rng.floatRangeFrom(source, f64, -1, 2);
}

fn fillShapeZeroCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillPertFrom(source, f64, dest, -1, 0.5, 2, 0);
}

fn fillUniformEquivalent(source: anytype, dest: []f64) void {
    alea.Rng.fillRangeFrom(source, f64, dest, -1, 2);
}
