const std = @import("std");
const alea = @import("alea");

const trials = 3;
const default_count = 4 * 1024 * 1024;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var args = std.process.Args.Iterator.init(init.minimal.args);
    defer args.deinit();
    _ = args.next();
    const sample_count = if (args.next()) |arg|
        std.fmt.parseInt(usize, arg, 10) catch default_count
    else
        default_count;

    try stdout.print("maxwell probe count={}\n", .{sample_count});
    try benchFill(alea.FastPrng, io, stdout, "fast current fill", 0x4a7e12, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast staged scalar combine", 0x4a7e12, sample_count, stagedScalar);
    try benchFill(alea.FastPrng, io, stdout, "fast staged vector4 combine", 0x4a7e12, sample_count, stagedVector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill", 0x4a7e12, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged scalar combine", 0x4a7e12, sample_count, stagedScalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar staged vector4 combine", 0x4a7e12, sample_count, stagedVector4);
    try stdout.flush();
}

fn benchFill(
    comptime Source: type,
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime fillFn: anytype,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }

        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(sample_count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
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
