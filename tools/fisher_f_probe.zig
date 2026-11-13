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

    try stdout.print("fisher-f probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast fisher current d=2,2", 0xf122, sample_count, sampleCurrent);
    try benchSample(alea.FastPrng, io, stdout, "fast uniform-ratio equivalent", 0xf122, sample_count, sampleUniformRatio);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar fisher current d=2,2", 0xf122, sample_count, sampleCurrent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar uniform-ratio equivalent", 0xf122, sample_count, sampleUniformRatio);
    try benchFill(alea.FastPrng, io, stdout, "fast fisher fill current d=2,2", 0xf122, sample_count, fillCurrent);
    try benchFill(alea.FastPrng, io, stdout, "fast uniform-ratio fill equivalent", 0xf122, sample_count, fillUniformRatio);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fisher fill current d=2,2", 0xf122, sample_count, fillCurrent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar uniform-ratio fill equivalent", 0xf122, sample_count, fillUniformRatio);
    try stdout.flush();
}

fn sampleCurrent(source: anytype) f64 {
    return alea.distributions.fisherFFrom(source, f64, 2, 2);
}

fn sampleUniformRatio(source: anytype) f64 {
    const u = alea.Rng.floatOpenFrom(source, f64);
    return u / (1 - u);
}

fn fillCurrent(source: anytype, dest: []f64) void {
    alea.distributions.fillFisherFFrom(source, f64, dest, 2, 2);
}

fn fillUniformRatio(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    for (dest) |*item| item.* = item.* / (1 - item.*);
}
