const std = @import("std");
const alea = @import("alea");

const probe_common = @import("probe_common.zig");
const benchFill = probe_common.benchFill4096;

const default_count = 16 * 1024 * 1024;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const sample_count = probe_common.parseCount(init, default_count);

    try stdout.print("normal affine probe count={}\n", .{sample_count});
    try benchFill(alea.FastPrng, io, stdout, "fast current fill mean=2 std=0.5", 0xa551, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast standard then scalar affine", 0xa551, sample_count, standardThenScalarAffine);
    try benchFill(alea.FastPrng, io, stdout, "fast standard then vector4 affine", 0xa551, sample_count, standardThenVectorAffine);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill mean=2 std=0.5", 0xa551, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar standard then scalar affine", 0xa551, sample_count, standardThenScalarAffine);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar standard then vector4 affine", 0xa551, sample_count, standardThenVectorAffine);
    try stdout.flush();
}

fn currentFill(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 2, 0.5);
}

fn standardThenScalarAffine(source: anytype, dest: []f64) void {
    alea.distributions.fillStandardNormalFrom(source, f64, dest);
    for (dest) |*item| item.* = 2.0 + 0.5 * item.*;
}

fn standardThenVectorAffine(source: anytype, dest: []f64) void {
    alea.distributions.fillStandardNormalFrom(source, f64, dest);
    affineVector4(dest, 2, 0.5);
}

fn affineVector4(dest: []f64, mean: f64, stddev: f64) void {
    const VectorType = @Vector(4, f64);
    const mean_vec: VectorType = @splat(mean);
    const stddev_vec: VectorType = @splat(stddev);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const input: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = mean_vec + stddev_vec * input;
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) dest[i] = mean + stddev * dest[i];
}
