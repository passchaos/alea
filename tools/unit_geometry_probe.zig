const std = @import("std");
const alea = @import("alea");

const trials = 3;
const default_count = 8 * 1024 * 1024;

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

    try stdout.print("unit geometry probe count={}\n", .{sample_count});
    try benchFill(io, stdout, "unit circle current fill", 0xc11c1e, sample_count, currentUnitCircle);
    try benchFill(io, stdout, "unit circle batched candidates", 0xc11c1e, sample_count, batchedUnitCircle);
    try benchFill(io, stdout, "unit disc current fill", 0xd15c, sample_count, currentUnitDisc);
    try benchFill(io, stdout, "unit disc batched candidates", 0xd15c, sample_count, batchedUnitDisc);
    try stdout.flush();
}

fn benchFill(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime fillFn: fn (*alea.ScalarPrng, [][2]f64) void,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024][2]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value[0];
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

fn currentUnitDisc(source: *alea.ScalarPrng, dest: [][2]f64) void {
    alea.distributions.fillUnitDiscFrom(source, f64, dest);
}

fn currentUnitCircle(source: *alea.ScalarPrng, dest: [][2]f64) void {
    alea.distributions.fillUnitCircleFrom(source, f64, dest);
}

fn batchedUnitCircle(source: *alea.ScalarPrng, dest: [][2]f64) void {
    var x_candidates: [2048]f64 = undefined;
    var y_candidates: [2048]f64 = undefined;

    var filled: usize = 0;
    while (filled < dest.len) {
        const remaining = dest.len - filled;
        const candidate_count = @min(x_candidates.len, @max(remaining, remaining * 2));
        fillSignedUnit(source, x_candidates[0..candidate_count]);
        fillSignedUnit(source, y_candidates[0..candidate_count]);

        var i: usize = 0;
        while (i < candidate_count and filled < dest.len) : (i += 1) {
            const x = x_candidates[i];
            const y = y_candidates[i];
            const sum = x * x + y * y;
            if (sum > 0 and sum < 1) {
                dest[filled] = .{ (x * x - y * y) / sum, 2 * x * y / sum };
                filled += 1;
            }
        }
    }
}

fn batchedUnitDisc(source: *alea.ScalarPrng, dest: [][2]f64) void {
    var x_candidates: [2048]f64 = undefined;
    var y_candidates: [2048]f64 = undefined;

    var filled: usize = 0;
    while (filled < dest.len) {
        const remaining = dest.len - filled;
        const candidate_count = @min(x_candidates.len, @max(remaining, remaining * 2));
        fillSignedUnit(source, x_candidates[0..candidate_count]);
        fillSignedUnit(source, y_candidates[0..candidate_count]);

        var i: usize = 0;
        while (i < candidate_count and filled < dest.len) : (i += 1) {
            const x = x_candidates[i];
            const y = y_candidates[i];
            if (x * x + y * y <= 1) {
                dest[filled] = .{ x, y };
                filled += 1;
            }
        }
    }
}

fn fillSignedUnit(source: *alea.ScalarPrng, dest: []f64) void {
    for (dest) |*item| {
        const repr = (@as(u64, 0x400) << 52) | (source.next() >> 12);
        item.* = @as(f64, @bitCast(repr)) - 3.0;
    }
}
