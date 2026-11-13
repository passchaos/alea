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

    try stdout.print("gumbel probe count={}\n", .{sample_count});
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x6cbe1, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar loglog", 0x6cbe1, sample_count, stagedScalar);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 loglog", 0x6cbe1, sample_count, stagedVector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x6cbe1, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar loglog", 0x6cbe1, sample_count, stagedScalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 loglog", 0x6cbe1, sample_count, stagedVector4);
    try stdout.flush();
}

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillGumbelFrom(source, f64, dest, 0, 1);
}

fn stagedScalar(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenClosedFrom(source, f64, dest);
    transformScalar(dest, 0, 1);
}

fn stagedVector4(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenClosedFrom(source, f64, dest);
    transformVector4(dest, 0, 1);
}

fn transformScalar(dest: []f64, location: f64, scale: f64) void {
    for (dest) |*item| item.* = location - scale * @log(-@log(item.*));
}

fn transformVector4(dest: []f64, location: f64, scale: f64) void {
    const VectorType = @Vector(4, f64);
    const location_vec: VectorType = @splat(location);
    const scale_vec: VectorType = @splat(scale);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const u: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = location_vec - scale_vec * @log(-@log(u));
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    transformScalar(dest[i..], location, scale);
}
