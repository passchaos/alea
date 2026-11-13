const std = @import("std");
const alea = @import("alea");

const probe_common = @import("probe_common.zig");
const benchFill = probe_common.benchFill1024;

const default_count = 8 * 1024 * 1024;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const sample_count = probe_common.parseCount(init, default_count);

    try stdout.print("arcsine probe count={}\n", .{sample_count});
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0xa2c5, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar sin", 0xa2c5, sample_count, stagedScalar);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 sin", 0xa2c5, sample_count, stagedVector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0xa2c5, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar sin", 0xa2c5, sample_count, stagedScalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 sin", 0xa2c5, sample_count, stagedVector4);
    try stdout.flush();
}

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillArcsineFrom(source, f64, dest, -1, 3);
}

fn stagedScalar(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformScalar(dest, -1, 4);
}

fn stagedVector4(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    transformVector4(dest, -1, 4);
}

fn transformScalar(dest: []f64, min: f64, width: f64) void {
    for (dest) |*item| {
        const s = @sin(std.math.pi * item.* / 2.0);
        item.* = min + width * s * s;
    }
}

fn transformVector4(dest: []f64, min: f64, width: f64) void {
    const VectorType = @Vector(4, f64);
    const min_vec: VectorType = @splat(min);
    const width_vec: VectorType = @splat(width);
    const scale_vec: VectorType = @splat(std.math.pi / 2.0);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const u: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const s = @sin(scale_vec * u);
        const out = min_vec + width_vec * s * s;
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    transformScalar(dest[i..], min, width);
}
