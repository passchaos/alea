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

    try stdout.print("triangular probe count={}\n", .{sample_count});
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x751a, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar sqrt", 0x751a, sample_count, stagedScalar);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 sqrt", 0x751a, sample_count, stagedVector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x751a, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar sqrt", 0x751a, sample_count, stagedScalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 sqrt", 0x751a, sample_count, stagedVector4);
    try stdout.flush();
}

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillTriangularFrom(source, f64, dest, -1, 0, 2);
}

fn stagedScalar(source: anytype, dest: []f64) void {
    alea.Rng.fillFrom(source, f64, dest);
    transformScalar(dest, -1, 0, 2);
}

fn stagedVector4(source: anytype, dest: []f64) void {
    alea.Rng.fillFrom(source, f64, dest);
    transformVector4(dest, -1, 0, 2);
}

fn transformScalar(dest: []f64, min: f64, mode: f64, max: f64) void {
    const width = max - min;
    const left_width = mode - min;
    const right_width = max - mode;
    const c = left_width / width;
    for (dest) |*item| {
        const u = item.*;
        item.* = if (u < c)
            min + @sqrt(u * width * left_width)
        else
            max - @sqrt((1.0 - u) * width * right_width);
    }
}

fn transformVector4(dest: []f64, min: f64, mode: f64, max: f64) void {
    const VectorType = @Vector(4, f64);
    const min_vec: VectorType = @splat(min);
    const max_vec: VectorType = @splat(max);
    const width = max - min;
    const left_width = mode - min;
    const right_width = max - mode;
    const c_vec: VectorType = @splat(left_width / width);
    const one_vec: VectorType = @splat(1.0);
    const left_scale_vec: VectorType = @splat(width * left_width);
    const right_scale_vec: VectorType = @splat(width * right_width);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const u: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const left = min_vec + @sqrt(u * left_scale_vec);
        const right = max_vec - @sqrt((one_vec - u) * right_scale_vec);
        const out = @select(f64, u < c_vec, left, right);
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    transformScalar(dest[i..], min, mode, max);
}
