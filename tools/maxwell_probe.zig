const std = @import("std");
const alea = @import("alea");

const probe_common = @import("probe_common.zig");
const benchFill = probe_common.benchFill1024;

const default_count = 4 * 1024 * 1024;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const sample_count = probe_common.parseCount(init, default_count);

    try stdout.print("maxwell probe count={}\n", .{sample_count});
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x4a7e12, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar combine", 0x4a7e12, sample_count, stagedScalar);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 combine", 0x4a7e12, sample_count, stagedVector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x4a7e12, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar combine", 0x4a7e12, sample_count, stagedScalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 combine", 0x4a7e12, sample_count, stagedVector4);
    try stdout.flush();
}

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillMaxwellFrom(source, f64, dest, 2);
}

fn stagedScalar(source: anytype, dest: []f64) void {
    var y_normals: [1024]f64 = undefined;
    var z_normals: [1024]f64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, y_normals.len);
        alea.Rng.fillNormalFrom(source, f64, dest[i .. i + take], 0, 2);
        alea.Rng.fillNormalFrom(source, f64, y_normals[0..take], 0, 2);
        alea.Rng.fillNormalFrom(source, f64, z_normals[0..take], 0, 2);
        combineScalar(dest[i .. i + take], y_normals[0..take], z_normals[0..take]);
        i += take;
    }
}

fn stagedVector4(source: anytype, dest: []f64) void {
    var y_normals: [1024]f64 = undefined;
    var z_normals: [1024]f64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, y_normals.len);
        alea.Rng.fillNormalFrom(source, f64, dest[i .. i + take], 0, 2);
        alea.Rng.fillNormalFrom(source, f64, y_normals[0..take], 0, 2);
        alea.Rng.fillNormalFrom(source, f64, z_normals[0..take], 0, 2);
        combineVector4(dest[i .. i + take], y_normals[0..take], z_normals[0..take]);
        i += take;
    }
}

fn combineScalar(dest: []f64, y_normals: []const f64, z_normals: []const f64) void {
    for (dest, y_normals, z_normals) |*item, y, z| {
        const x = item.*;
        item.* = @sqrt(x * x + y * y + z * z);
    }
}

fn combineVector4(dest: []f64, y_normals: []const f64, z_normals: []const f64) void {
    const VectorType = @Vector(4, f64);
    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const x: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const y: VectorType = .{ y_normals[i], y_normals[i + 1], y_normals[i + 2], y_normals[i + 3] };
        const z: VectorType = .{ z_normals[i], z_normals[i + 1], z_normals[i + 2], z_normals[i + 3] };
        const out = @sqrt(x * x + y * y + z * z);
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    combineScalar(dest[i..], y_normals[i..], z_normals[i..]);
}
