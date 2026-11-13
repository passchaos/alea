const std = @import("std");
const alea = @import("alea");

const probe_common = @import("probe_common.zig");
const benchFill = probe_common.benchFill1024;

const default_count = 16 * 1024 * 1024;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const sample_count = probe_common.parseCount(init, default_count);

    try stdout.print("half-normal probe count={}\n", .{sample_count});
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x4a20, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar abs", 0x4a20, sample_count, stagedScalarAbs);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 abs", 0x4a20, sample_count, stagedVector4Abs);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x4a20, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar abs", 0x4a20, sample_count, stagedScalarAbs);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 abs", 0x4a20, sample_count, stagedVector4Abs);
    try stdout.flush();
}

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillHalfNormalFrom(source, f64, dest, 2);
}

fn stagedScalarAbs(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 2);
    for (dest) |*item| item.* = @abs(item.*);
}

fn stagedVector4Abs(source: anytype, dest: []f64) void {
    alea.Rng.fillNormalFrom(source, f64, dest, 0, 2);
    const VectorType = @Vector(4, f64);
    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const normal: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = @abs(normal);
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = @abs(dest[i]);
}
