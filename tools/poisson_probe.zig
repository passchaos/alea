const std = @import("std");
const alea = @import("alea");

const trials = 3;
const default_count = 4 * 1024 * 1024;
const lambda = 20.0;

const Method = struct {
    lambda: f64,
    s: f64,
    d: f64,
    l: f64,
    c: f64,
    c0: f64,
    c1: f64,
    c2: f64,
    c3: f64,
    omega: f64,

    fn init(value: f64) Method {
        const s = @sqrt(value);
        const b1 = (1.0 / 24.0) / value;
        const b2 = 0.3 * b1 * b1;
        const c3 = (1.0 / 7.0) * b1 * b2;
        const c2 = b2 - 15.0 * c3;
        const c1 = b1 - 6.0 * b2 + 45.0 * c3;
        const c0 = 1.0 - b1 + 3.0 * b2 - 15.0 * c3;
        return .{
            .lambda = value,
            .s = s,
            .d = 6.0 * value * value,
            .l = @floor(value - 1.1484),
            .c = 0.1069 / value,
            .c0 = c0,
            .c1 = c1,
            .c2 = c2,
            .c3 = c3,
            .omega = 1.0 / @sqrt(2.0 * std.math.pi) / s,
        };
    }
};

const Parts = struct {
    px: f64,
    py: f64,
    fx: f64,
    fy: f64,
};

const PxPy = struct {
    px: f64,
    py: f64,
};

const Counts = struct {
    first: usize = 0,
    squeeze: usize = 0,
    exact: usize = 0,
    fallback: usize = 0,
    negative_normal: usize = 0,
    fallback_t_reject: usize = 0,
    fallback_accept_reject: usize = 0,

    fn total(self: Counts) usize {
        return self.first + self.squeeze + self.exact + self.fallback;
    }
};

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

    try stdout.print("poisson probe lambda={d} count={}\n", .{ lambda, sample_count });
    try benchSample(alea.FastPrng, io, stdout, "fast top-level poissonFrom", 0xa157, sample_count, sampleTopLevel);
    try benchCached(alea.FastPrng, io, stdout, "fast cached Poisson.sampleFrom", 0xa157, sample_count);
    try benchFill(alea.FastPrng, io, stdout, "fast fillPoissonFrom", 0xa159, sample_count);
    try benchSample(alea.ScalarPrng, io, stdout, "scalar top-level poissonFrom", 0xa157, sample_count, sampleTopLevel);
    try benchCached(alea.ScalarPrng, io, stdout, "scalar cached Poisson.sampleFrom", 0xa157, sample_count);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar fillPoissonFrom", 0xa157, sample_count);
    try printBranchCounts(alea.FastPrng, stdout, "fast branch profile", 0xa157, sample_count);
    try printBranchCounts(alea.ScalarPrng, stdout, "scalar branch profile", 0xa157, sample_count);
    try stdout.flush();
}

fn benchSample(
    comptime Source: type,
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime sampleFn: anytype,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var checksum: u64 = 0;
        var i: usize = 0;
        while (i < sample_count) : (i += 1) checksum +%= sampleFn(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(sample_count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchCached(
    comptime Source: type,
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Poisson.init(lambda) catch unreachable;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var checksum: u64 = 0;
        var i: usize = 0;
        while (i < sample_count) : (i += 1) checksum +%= dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(sample_count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFill(
    comptime Source: type,
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var checksum: u64 = 0;
        var remaining = sample_count;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillPoissonFrom(&engine, out[0..n], lambda);
            for (out[0..n]) |value| checksum +%= value;
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
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn sampleTopLevel(source: anytype) u64 {
    return alea.distributions.poissonFrom(source, lambda);
}

fn printBranchCounts(
    comptime Source: type,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
) !void {
    var engine = Source.init(seed);
    const method = Method.init(lambda);
    var counts = Counts{};
    var checksum: u64 = 0;
    var i: usize = 0;
    while (i < sample_count) : (i += 1) checksum +%= sampleCounted(&engine, method, &counts);

    const total_f: f64 = @floatFromInt(counts.total());
    try stdout.print(
        "{s}: total={} first={} ({d:.2}%) squeeze={} ({d:.2}%) exact={} ({d:.2}%) fallback={} ({d:.2}%) negative_normal={} t_reject={} accept_reject={} checksum={}\n",
        .{
            name,
            counts.total(),
            counts.first,
            percent(counts.first, total_f),
            counts.squeeze,
            percent(counts.squeeze, total_f),
            counts.exact,
            percent(counts.exact, total_f),
            counts.fallback,
            percent(counts.fallback, total_f),
            counts.negative_normal,
            counts.fallback_t_reject,
            counts.fallback_accept_reject,
            checksum,
        },
    );
}

fn sampleCounted(source: anytype, method: Method, counts: *Counts) u64 {
    while (true) {
        const g = alea.Rng.normalFastFrom(source, f64, method.lambda, method.s);
        if (g >= 0) {
            const k1 = @floor(g);
            if (k1 >= method.l) {
                counts.first += 1;
                return @intFromFloat(k1);
            }

            const u = alea.Rng.floatFrom(source, f64);
            const diff = method.lambda - k1;
            if (method.d * u >= diff * diff * diff) {
                counts.squeeze += 1;
                return @intFromFloat(k1);
            }

            const parts = poissonAdParts(method, k1);
            if (parts.fy * (1.0 - u) <= parts.py * @exp(parts.px - parts.fx)) {
                counts.exact += 1;
                return @intFromFloat(k1);
            }
        } else {
            counts.negative_normal += 1;
        }

        while (true) {
            const e = alea.Rng.exponentialFastFrom(source, f64, 1);
            const u = 2.0 * alea.Rng.floatFrom(source, f64) - 1.0;
            const sign: f64 = if (u < 0) -1 else 1;
            const t = 1.8 + e * sign;
            if (t <= -0.6744) {
                counts.fallback_t_reject += 1;
                continue;
            }

            const k2 = @floor(method.lambda + method.s * t);
            const parts = poissonAdParts(method, k2);
            if (method.c * @abs(u) <= parts.py * @exp(parts.px + e) - parts.fy * @exp(parts.fx + e)) {
                counts.fallback += 1;
                return @intFromFloat(k2);
            }
            counts.fallback_accept_reject += 1;
        }
    }
}

fn poissonAdParts(method: Method, k: f64) Parts {
    const px_py: PxPy = if (k < 10.0) blk: {
        const fact = [_]f64{ 1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880 };
        const ki: usize = @intFromFloat(k);
        break :blk .{
            .px = -method.lambda,
            .py = std.math.pow(f64, method.lambda, k) / fact[ki],
        };
    } else blk: {
        const delta_base = 1.0 / (12.0 * k);
        const delta = delta_base - 4.8 * delta_base * delta_base * delta_base;
        const v = (method.lambda - k) / k;
        const a = [_]f64{
            -0.5000000002,
            0.3333333343,
            -0.2499998565,
            0.1999997049,
            -0.1666848753,
            0.1428833286,
            -0.1241963125,
            0.1101687109,
            -0.1142650302,
            0.1055093006,
        };
        var poly: f64 = 0;
        var idx: usize = a.len;
        while (idx > 0) {
            idx -= 1;
            poly = poly * v + a[idx];
        }
        const px = if (@abs(v) <= 0.25)
            k * v * v * poly - delta
        else
            k * @log(1.0 + v) - (method.lambda - k) - delta;
        break :blk .{
            .px = px,
            .py = 1.0 / @sqrt(2.0 * std.math.pi) / @sqrt(k),
        };
    };

    const x = (k - method.lambda + 0.5) / method.s;
    const x2 = x * x;
    return .{
        .px = px_py.px,
        .py = px_py.py,
        .fx = -0.5 * x2,
        .fy = method.omega * (((method.c3 * x2 + method.c2) * x2 + method.c1) * x2 + method.c0),
    };
}

fn percent(value: usize, total: f64) f64 {
    return 100.0 * @as(f64, @floatFromInt(value)) / total;
}
