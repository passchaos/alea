const std = @import("std");
const alea = @import("alea");

const trials = 3;
const default_count = 16 * 1024 * 1024;

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

    try stdout.print("standard fill probe count={}\n", .{sample_count});
    try benchFill(io, stdout, "standard exponential current fill", 0xe15a, sample_count, currentExponentialFill);
    try benchFill(io, stdout, "standard exponential direct loop", 0xe15a, sample_count, directExponentialLoop);
    try benchFill(io, stdout, "standard exponential vector4 chunk", 0xe15a, sample_count, vectorExponential4Chunk);
    try benchFill(io, stdout, "standard normal current fill", 0xd15a, sample_count, currentNormalFill);
    try benchFill(io, stdout, "standard normal direct loop", 0xd15a, sample_count, directNormalLoop);
    try benchFill(io, stdout, "standard normal vector4 chunk", 0xd15a, sample_count, vectorNormal4Chunk);
    try benchFillF32(io, stdout, "standard exponential f32 current fill", 0xe15a, sample_count, currentExponentialF32Fill);
    try benchFillF32(io, stdout, "standard exponential f32 vector8 chunk", 0xe15a, sample_count, vectorExponentialF32Chunk);
    try benchFillF32(io, stdout, "standard normal f32 current fill", 0xd15a, sample_count, currentNormalF32Fill);
    try benchFillF32(io, stdout, "standard normal f32 vector8 chunk", 0xd15a, sample_count, vectorNormalF32Chunk);
    try benchFillF32Fast(io, stdout, "fast facade standard exponential f32 current fill", 0xe15a, sample_count, currentExponentialF32FillFacade);
    try benchFillF32Fast(io, stdout, "fast cached-rng standard exponential f32 fill", 0xe15a, sample_count, cachedRngExponentialF32Fill);
    try benchFillF32Fast(io, stdout, "fast facade standard normal f32 current fill", 0xd15a, sample_count, currentNormalF32FillFacade);
    try benchFillF32Fast(io, stdout, "fast cached-rng standard normal f32 fill", 0xd15a, sample_count, cachedRngNormalF32Fill);
    try stdout.flush();
}

fn benchFill(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime fillFn: fn (*alea.ScalarPrng, []f64) void,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
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

fn benchFillF32(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime fillFn: fn (*alea.ScalarPrng, []f32) void,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f32 = 0;
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

fn benchFillF32Fast(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime fillFn: fn (*alea.FastPrng, []f32) void,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f32 = 0;
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

const CachedRng = struct {
    ptr: *anyopaque,
    nextFn: *const fn (ptr: *anyopaque) u64,

    fn init(rng: alea.Rng) CachedRng {
        return .{ .ptr = rng.ptr, .nextFn = rng.nextFn };
    }

    pub fn next(self: CachedRng) u64 {
        return self.nextFn(self.ptr);
    }
};

fn currentExponentialFill(source: *alea.ScalarPrng, dest: []f64) void {
    alea.distributions.fillStandardExponentialFrom(source, f64, dest);
}

fn directExponentialLoop(source: *alea.ScalarPrng, dest: []f64) void {
    for (dest) |*item| item.* = alea.Rng.standardExponentialFastFrom(source, f64);
}

fn vectorExponential4Chunk(source: *alea.ScalarPrng, dest: []f64) void {
    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const vec = alea.Rng.vectorStandardExponentialFrom(source, @Vector(4, f64));
        inline for (0..4) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = alea.Rng.standardExponentialFastFrom(source, f64);
}

fn currentNormalFill(source: *alea.ScalarPrng, dest: []f64) void {
    alea.distributions.fillStandardNormalFrom(source, f64, dest);
}

fn directNormalLoop(source: *alea.ScalarPrng, dest: []f64) void {
    for (dest) |*item| item.* = alea.Rng.standardNormalFastFrom(source, f64);
}

fn vectorNormal4Chunk(source: *alea.ScalarPrng, dest: []f64) void {
    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const vec = alea.Rng.vectorStandardNormalFrom(source, @Vector(4, f64));
        inline for (0..4) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = alea.Rng.standardNormalFastFrom(source, f64);
}

fn currentExponentialF32Fill(source: *alea.ScalarPrng, dest: []f32) void {
    alea.distributions.fillStandardExponentialFrom(source, f32, dest);
}

fn vectorExponentialF32Chunk(source: *alea.ScalarPrng, dest: []f32) void {
    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        const vec = alea.Rng.vectorStandardExponentialFrom(source, @Vector(8, f32));
        inline for (0..8) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = alea.Rng.standardExponentialFastFrom(source, f32);
}

fn currentExponentialF32FillFacade(source: *alea.FastPrng, dest: []f32) void {
    const rng = alea.Rng.init(source);
    alea.distributions.fillStandardExponential(rng, f32, dest);
}

fn cachedRngExponentialF32Fill(source: *alea.FastPrng, dest: []f32) void {
    const rng = alea.Rng.init(source);
    const cached = CachedRng.init(rng);
    alea.distributions.fillStandardExponentialFrom(cached, f32, dest);
}

fn currentNormalF32Fill(source: *alea.ScalarPrng, dest: []f32) void {
    alea.distributions.fillStandardNormalFrom(source, f32, dest);
}

fn vectorNormalF32Chunk(source: *alea.ScalarPrng, dest: []f32) void {
    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        const vec = alea.Rng.vectorStandardNormalFrom(source, @Vector(8, f32));
        inline for (0..8) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = alea.Rng.standardNormalFastFrom(source, f32);
}

fn currentNormalF32FillFacade(source: *alea.FastPrng, dest: []f32) void {
    const rng = alea.Rng.init(source);
    alea.distributions.fillStandardNormal(rng, f32, dest);
}

fn cachedRngNormalF32Fill(source: *alea.FastPrng, dest: []f32) void {
    const rng = alea.Rng.init(source);
    const cached = CachedRng.init(rng);
    alea.distributions.fillStandardNormalFrom(cached, f32, dest);
}
