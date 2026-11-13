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

    try stdout.print("student-t probe count={}\n", .{sample_count});
    try benchSample(alea.FastPrng, io, stdout, "fast student-t current dof=1", 0x57d1, sample_count, sampleStudentOne);
    try benchSample(alea.FastPrng, io, stdout, "fast cauchy equivalent", 0x57d1, sample_count, sampleCauchyEquivalent);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar student-t current dof=1", 0x57d1, sample_count, sampleStudentOne);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar cauchy equivalent", 0x57d1, sample_count, sampleCauchyEquivalent);
    try benchFill(alea.FastPrng, io, stdout, "fast student-t fill current dof=1", 0x57d1, sample_count, fillStudentOne);
    try benchFill(alea.FastPrng, io, stdout, "fast cauchy fill equivalent", 0x57d1, sample_count, fillCauchyEquivalent);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar student-t fill current dof=1", 0x57d1, sample_count, fillStudentOne);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar cauchy fill equivalent", 0x57d1, sample_count, fillCauchyEquivalent);
    try stdout.flush();
}

fn sampleStudentOne(source: anytype) f64 {
    return alea.distributions.studentTFrom(source, f64, 1);
}

fn sampleCauchyEquivalent(source: anytype) f64 {
    return alea.distributions.cauchyFrom(source, f64, 0, 1);
}

fn fillStudentOne(source: anytype, dest: []f64) void {
    alea.distributions.fillStudentTFrom(source, f64, dest, 1);
}

fn fillCauchyEquivalent(source: anytype, dest: []f64) void {
    alea.distributions.fillCauchyFrom(source, f64, dest, 0, 1);
}
