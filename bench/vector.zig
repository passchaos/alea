const std = @import("std");
const alea = @import("alea");

const trials = 3;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const lanes: usize = 16 * 1024 * 1024;
    try stdout.print("vector microbench\n", .{});
    try benchFillVectorRangeF32(io, stdout, "alea fillVectorRange f32x8", lanes);
    try benchFillVectorNormalF32(io, stdout, "alea fillVectorNormal f32x8", lanes / 4);
    try benchFillVectorExponentialF32(io, stdout, "alea fillVectorExponential f32x8", lanes);
    try benchFillVectorExponentialF64(io, stdout, "alea fillVectorExponential f64x4", lanes / 2);
    try stdout.flush();
}

fn benchFillVectorRangeF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xf188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorRange(@Vector(8, f32), out[0..n], -1, 1);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorNormalF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorNormal(@Vector(8, f32), out[0..n], 0, 1);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorExponentialF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorExponential(@Vector(8, f32), out[0..n], 2);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorExponentialF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe184);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorExponential(@Vector(4, f64), out[0..n], 2);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn checksumVectors(vectors: []const @Vector(8, f32), len: usize) f32 {
    var checksum: f32 = 0;
    for (vectors[0..len]) |vec| {
        inline for (0..8) |lane| checksum += vec[lane];
    }
    return checksum;
}

fn checksumVectorsF64(vectors: []const @Vector(4, f64), len: usize) f64 {
    var checksum: f64 = 0;
    for (vectors[0..len]) |vec| {
        inline for (0..4) |lane| checksum += vec[lane];
    }
    return checksum;
}
