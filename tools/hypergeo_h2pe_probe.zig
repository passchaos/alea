const std = @import("std");
const alea = @import("alea");

const trials = 3;
const default_count = 128 * 1024 * 1024 / 256;

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

    try benchCurrent(io, stdout, sample_count);
    try benchH2pe(io, stdout, sample_count);
    try stdout.flush();
}

fn benchCurrent(io: std.Io, stdout: *std.Io.Writer, sample_count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Hypergeometric.init(5000, 2500, 500) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x4966);
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
    try stdout.print(
        "current large hypergeometric scalar direct: {d:.1} M samples/s count={} checksum={}\n",
        .{ best_million_per_s, sample_count, best_checksum },
    );
}

fn benchH2pe(io: std.Io, stdout: *std.Io.Writer, sample_count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = HypergeometricH2pe.init(5000, 2500, 500) orelse return;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x4966);
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
    try stdout.print(
        "h2pe candidate large hypergeometric: {d:.1} M samples/s count={} checksum={}\n",
        .{ best_million_per_s, sample_count, best_checksum },
    );
}

const HypergeometricH2pe = struct {
    n1: u64,
    n2: u64,
    k: u64,
    offset_x: i64,
    sign_x: i64,
    m: f64,
    a: f64,
    lambda_l: f64,
    lambda_r: f64,
    x_l: f64,
    x_r: f64,
    p1: f64,
    p2: f64,
    p3: f64,

    fn init(population: u64, successes: u64, draws: u64) ?HypergeometricH2pe {
        const params = ReducedParams.init(population, successes, draws);
        const m = @floor(@as(f64, @floatFromInt(params.k + 1)) *
            @as(f64, @floatFromInt(params.n1 + 1)) / @as(f64, @floatFromInt(population + 2)));
        const lower_bound = @max(@as(f64, 0), @as(f64, @floatFromInt(params.k)) - @as(f64, @floatFromInt(params.n2)));
        if (m - lower_bound < 10) return null;

        const n_f: f64 = @floatFromInt(population);
        const n1_f: f64 = @floatFromInt(params.n1);
        const n2_f: f64 = @floatFromInt(params.n2);
        const k_f: f64 = @floatFromInt(params.k);
        const a = lnOfFactorial(m) + lnOfFactorial(n1_f - m) +
            lnOfFactorial(k_f - m) + lnOfFactorial(n2_f - k_f + m);

        const d = 1.5 * @sqrt((n_f - k_f) * k_f * n1_f * n2_f / ((n_f - 1.0) * n_f * n_f)) + 0.5;
        const x_l = m - d + 0.5;
        const x_r = m + d + 0.5;
        const k_l = @exp(a - lnOfFactorial(x_l) - lnOfFactorial(n1_f - x_l) -
            lnOfFactorial(k_f - x_l) - lnOfFactorial(n2_f - k_f + x_l));
        const k_r = @exp(a - lnOfFactorial(x_r - 1.0) - lnOfFactorial(n1_f - x_r + 1.0) -
            lnOfFactorial(k_f - x_r + 1.0) - lnOfFactorial(n2_f - k_f + x_r - 1.0));
        const lambda_l = -@log(x_l * (n2_f - k_f + x_l) / ((n1_f - x_l + 1.0) * (k_f - x_l + 1.0)));
        const lambda_r = -@log((n1_f - x_r + 1.0) * (k_f - x_r + 1.0) / (x_r * (n2_f - k_f + x_r)));
        const p1 = 2.0 * d;
        const p2 = p1 + k_l / lambda_l;
        const p3 = p2 + k_r / lambda_r;
        if (!std.math.isFinite(p3) or !(p3 > 0)) return null;

        return .{
            .n1 = params.n1,
            .n2 = params.n2,
            .k = params.k,
            .offset_x = params.offset_x,
            .sign_x = params.sign_x,
            .m = m,
            .a = a,
            .lambda_l = lambda_l,
            .lambda_r = lambda_r,
            .x_l = x_l,
            .x_r = x_r,
            .p1 = p1,
            .p2 = p2,
            .p3 = p3,
        };
    }

    fn sampleFrom(self: *const HypergeometricH2pe, source: anytype) u64 {
        while (true) {
            const y, const v = self.selectCandidate(source);
            if (self.accept(y, v)) return self.finish(y);
        }
    }

    fn selectCandidate(self: *const HypergeometricH2pe, source: anytype) struct { f64, f64 } {
        while (true) {
            const u = alea.Rng.floatFrom(source, f64) * self.p3;
            var v = alea.Rng.floatFrom(source, f64);
            if (u <= self.p1) return .{ @floor(self.x_l + u), v };
            if (u <= self.p2) {
                const y = @floor(self.x_l + @log(v) / self.lambda_l);
                if (y >= @max(@as(f64, 0), @as(f64, @floatFromInt(self.k)) - @as(f64, @floatFromInt(self.n2)))) {
                    v *= (u - self.p1) * self.lambda_l;
                    return .{ y, v };
                }
            } else {
                const y = @floor(self.x_r - @log(v) / self.lambda_r);
                if (y <= @min(@as(f64, @floatFromInt(self.n1)), @as(f64, @floatFromInt(self.k)))) {
                    v *= (u - self.p2) * self.lambda_r;
                    return .{ y, v };
                }
            }
        }
    }

    fn accept(self: *const HypergeometricH2pe, y: f64, v: f64) bool {
        var f: f64 = 1.0;
        if (self.m < y) {
            var i: u64 = @intFromFloat(self.m);
            const y_i: u64 = @intFromFloat(y);
            while (i < y_i) {
                i += 1;
                f *= @as(f64, @floatFromInt(self.n1 - i + 1)) * @as(f64, @floatFromInt(self.k - i + 1));
                f /= @as(f64, @floatFromInt(i)) * @as(f64, @floatFromInt(self.n2 - self.k + i));
            }
        } else {
            var i: u64 = @intFromFloat(y);
            const m_i: u64 = @intFromFloat(self.m);
            while (i < m_i) {
                i += 1;
                f *= @as(f64, @floatFromInt(i)) * @as(f64, @floatFromInt(self.n2 - self.k + i));
                f /= @as(f64, @floatFromInt(self.n1 - i + 1)) * @as(f64, @floatFromInt(self.k - i + 1));
            }
        }
        return v <= f;
    }

    fn finish(self: *const HypergeometricH2pe, y: f64) u64 {
        const x: i64 = @intFromFloat(y);
        return @intCast(self.offset_x + self.sign_x * x);
    }
};

const ReducedParams = struct {
    n1: u64,
    n2: u64,
    k: u64,
    offset_x: i64,
    sign_x: i64,

    fn init(population: u64, successes: u64, draws: u64) ReducedParams {
        const failures = population - successes;
        var sign_x: i64 = 1;
        var offset_x: i64 = 0;
        const n1, const n2 = if (successes > failures) blk: {
            sign_x = -1;
            offset_x = @intCast(draws);
            break :blk .{ failures, successes };
        } else .{ successes, failures };
        const k = if (draws <= population / 2) draws else blk: {
            offset_x += @as(i64, @intCast(n1)) * sign_x;
            sign_x *= -1;
            break :blk population - draws;
        };
        return .{ .n1 = n1, .n2 = n2, .k = k, .offset_x = offset_x, .sign_x = sign_x };
    }
};

fn lnOfFactorial(v: f64) f64 {
    const v3 = v + 3.0;
    const ln_fac = (v3 + 0.5) * @log(v3) - v3 + @as(f64, 0.91893853320467274178) + 1.0 / (12.0 * v3);
    return ln_fac - @log((v + 3.0) * (v + 2.0) * (v + 1.0));
}
