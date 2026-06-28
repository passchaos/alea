const std = @import("std");
const Rng = @import("rng.zig");

pub const Error = error{
    EmptyRange,
    InvalidProbability,
    InvalidWeight,
    InvalidParameter,
};

pub fn uniform(rng: Rng, comptime T: type, min: T, max: T) T {
    switch (@typeInfo(T)) {
        .int => return rng.intRangeLessThan(T, min, max),
        .float => return rng.floatRange(T, min, max),
        else => @compileError("uniform supports integer and floating-point types"),
    }
}

pub fn uniformInclusive(rng: Rng, comptime T: type, min: T, max: T) T {
    switch (@typeInfo(T)) {
        .int => return rng.intRangeAtMost(T, min, max),
        .float => {
            std.debug.assert(min <= max);
            return min + (max - min) * rng.float(T);
        },
        else => @compileError("uniformInclusive supports integer and floating-point types"),
    }
}

pub fn bernoulli(rng: Rng, p: f64) bool {
    const dist = Bernoulli.init(p) catch unreachable;
    return dist.sample(rng);
}

pub const Bernoulli = struct {
    const always_true = std.math.maxInt(u64);
    const scale = 0x1.0p64;

    p_int: u64,

    pub fn init(p: f64) Error!Bernoulli {
        if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
        if (p == 1) return .{ .p_int = always_true };
        return .{ .p_int = Rng.probabilityThreshold(p) };
    }

    pub fn initRatio(numerator: u32, denominator: u32) Error!Bernoulli {
        if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
        if (numerator == denominator) return .{ .p_int = always_true };
        const p = @as(f64, @floatFromInt(numerator)) / @as(f64, @floatFromInt(denominator));
        return .{ .p_int = Rng.probabilityThreshold(p) };
    }

    pub fn probability(self: Bernoulli) f64 {
        if (self.p_int == always_true) return 1;
        return @as(f64, @floatFromInt(self.p_int)) / scale;
    }

    pub fn sample(self: Bernoulli, rng: Rng) bool {
        if (self.p_int == always_true) return true;
        return rng.next() < self.p_int;
    }
};

pub const Binomial = struct {
    trials: u64,
    p: f64,

    pub fn init(trials: u64, p: f64) Error!Binomial {
        if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
        return .{ .trials = trials, .p = p };
    }

    pub fn sample(self: Binomial, rng: Rng) u64 {
        return binomial(rng, self.trials, self.p);
    }
};

pub fn binomial(rng: Rng, trials: u64, p: f64) u64 {
    std.debug.assert(p >= 0 and p <= 1);
    if (trials == 0 or p == 0) return 0;
    if (p == 1) return trials;
    if (p == 0.5) return binomialFair(rng, trials);

    const q = if (p <= 0.5) p else 1.0 - p;
    const sampled = binomialSmallP(rng, trials, q);
    return if (p <= 0.5) sampled else trials - sampled;
}

pub fn binomialPoissonApprox(rng: Rng, trials: u64, p: f64) u64 {
    std.debug.assert(p >= 0 and p <= 1);
    if (trials == 0 or p == 0) return 0;
    if (p == 1) return trials;

    const q = if (p <= 0.5) p else 1.0 - p;
    const mean = @as(f64, @floatFromInt(trials)) * q;
    const sampled = @min(poisson(rng, mean), trials);
    return if (p <= 0.5) sampled else trials - sampled;
}

pub const Multinomial = struct {
    trials: u64,
    probabilities: []const f64,
    total_probability: f64,

    pub fn init(trials: u64, probabilities: []const f64) Error!Multinomial {
        if (probabilities.len == 0) return error.EmptyRange;
        var total: f64 = 0;
        for (probabilities) |p| {
            if (!(p >= 0) or !std.math.isFinite(p)) return error.InvalidProbability;
            total += p;
        }
        if (!(total > 0) or !std.math.isFinite(total)) return error.InvalidProbability;
        return .{
            .trials = trials,
            .probabilities = probabilities,
            .total_probability = total,
        };
    }

    pub fn sample(self: Multinomial, allocator: std.mem.Allocator, rng: Rng) ![]u64 {
        const out = try allocator.alloc(u64, self.probabilities.len);
        errdefer allocator.free(out);
        self.sampleInto(rng, out);
        return out;
    }

    pub fn sampleInto(self: Multinomial, rng: Rng, out: []u64) void {
        std.debug.assert(out.len == self.probabilities.len);
        @memset(out, 0);

        var remaining_trials = self.trials;
        var remaining_probability = self.total_probability;
        for (self.probabilities[0 .. self.probabilities.len - 1], out[0 .. out.len - 1]) |p, *slot| {
            if (remaining_trials == 0) return;
            if (p == 0) continue;
            const normalized = p / remaining_probability;
            const count = binomial(rng, remaining_trials, normalized);
            slot.* = count;
            remaining_trials -= count;
            remaining_probability -= p;
        }
        out[out.len - 1] = remaining_trials;
    }
};

pub const NegativeBinomial = struct {
    successes: u64,
    p: f64,

    pub fn init(successes: u64, p: f64) Error!NegativeBinomial {
        if (successes == 0) return error.InvalidParameter;
        if (!(p > 0 and p <= 1)) return error.InvalidProbability;
        return .{ .successes = successes, .p = p };
    }

    pub fn sample(self: NegativeBinomial, rng: Rng) u64 {
        return negativeBinomial(rng, self.successes, self.p);
    }
};

pub fn negativeBinomial(rng: Rng, successes: u64, p: f64) u64 {
    std.debug.assert(successes > 0 and p > 0 and p <= 1);
    if (p == 1) return 0;

    var failures: u64 = 0;
    var i: u64 = 0;
    while (i < successes) : (i += 1) {
        failures += geometric(rng, p) - 1;
    }
    return failures;
}

pub const Hypergeometric = struct {
    population: u64,
    successes: u64,
    draws: u64,

    pub fn init(population: u64, successes: u64, draws: u64) Error!Hypergeometric {
        if (successes > population or draws > population) return error.InvalidParameter;
        return .{ .population = population, .successes = successes, .draws = draws };
    }

    pub fn sample(self: Hypergeometric, rng: Rng) u64 {
        return hypergeometric(rng, self.population, self.successes, self.draws);
    }
};

pub fn hypergeometric(rng: Rng, population: u64, successes: u64, draws: u64) u64 {
    std.debug.assert(successes <= population and draws <= population);
    if (population == 0 or successes == 0 or draws == 0) return 0;
    if (successes == population) return draws;

    var remaining_population = population;
    var remaining_successes = successes;
    var hits: u64 = 0;
    var i: u64 = 0;
    while (i < draws) : (i += 1) {
        const p = @as(f64, @floatFromInt(remaining_successes)) / @as(f64, @floatFromInt(remaining_population));
        if (rng.chance(p)) {
            hits += 1;
            remaining_successes -= 1;
            if (remaining_successes == 0) break;
        }
        remaining_population -= 1;
    }
    return hits;
}

fn binomialFair(rng: Rng, trials: u64) u64 {
    var remaining = trials;
    var successes: u64 = 0;
    while (remaining >= 64) : (remaining -= 64) {
        successes += @popCount(rng.next());
    }
    if (remaining > 0) {
        const mask = (@as(u64, 1) << @intCast(remaining)) - 1;
        successes += @popCount(rng.next() & mask);
    }
    return successes;
}

fn binomialSmallP(rng: Rng, trials: u64, p: f64) u64 {
    if (p == 0) return 0;
    if (trials <= 64) {
        var successes: u64 = 0;
        var i: u64 = 0;
        while (i < trials) : (i += 1) {
            successes += @intFromBool(rng.chance(p));
        }
        return successes;
    }

    const mean = @as(f64, @floatFromInt(trials)) * p;
    if (mean >= 8) return binomialRejectionSmallP(rng, trials, p);

    return binomialWaiting(rng, trials, -@log(1.0 - p));
}

fn binomialWaiting(rng: Rng, trials: u64, q: f64) u64 {
    var successes: u64 = 0;
    var sum: f64 = 0;
    while (true) {
        if (successes == trials) return successes;
        const e = -@log(1.0 - rng.float(f64));
        sum += e / @as(f64, @floatFromInt(trials - successes));
        successes += 1;
        if (sum > q) return successes - 1;
    }
}

fn binomialRejectionSmallP(rng: Rng, trials: u64, p: f64) u64 {
    const t: f64 = @floatFromInt(trials);
    const np = @floor(t * p);
    const pa = np / t;
    const one_minus_pa = 1.0 - pa;
    const pi_4 = 0.7853981633974483096156608458198757;

    const d1x = @sqrt(np * one_minus_pa * @log(32.0 * np / (81.0 * pi_4 * one_minus_pa)));
    const d1 = @round(@max(1.0, d1x));
    const d2x = @sqrt(np * one_minus_pa * @log(32.0 * t * one_minus_pa / (pi_4 * pa)));
    const d2 = @round(@max(1.0, d2x));

    const sqrt_pi_over_2 = 1.2533141373155002512078826424055226;
    const s1 = @sqrt(np * one_minus_pa) * (1.0 + d1 / (4.0 * np));
    const s2 = @sqrt(np * one_minus_pa) * (1.0 + d2 / (4.0 * t * one_minus_pa));
    const c = 2.0 * d1 / np;
    const a1 = @exp(c) * s1 * sqrt_pi_over_2;
    const a12 = a1 + s2 * sqrt_pi_over_2;
    const s1s = s1 * s1;
    const a123 = a12 + (@exp(d1 / (t * one_minus_pa)) *
        2.0 * s1s / d1 *
        @exp(-d1 * d1 / (2.0 * s1s)));
    const s2s = s2 * s2;
    const s = a123 + 2.0 * s2s / d2 * @exp(-d2 * d2 / (2.0 * s2s));
    const lf = std.math.lgamma(f64, np + 1.0) + std.math.lgamma(f64, t - np + 1.0);
    const lp1p = @log(pa / one_minus_pa);
    const q = -@log(1.0 - (p - pa) / one_minus_pa);

    while (true) {
        var x: f64 = undefined;
        var v: f64 = undefined;
        var reject = false;

        const u = s * rng.float(f64);
        if (u <= a1) {
            const n = normal(rng, f64, 0, 1);
            const y = s1 * @abs(n);
            reject = y >= d1;
            if (!reject) {
                const e = -@log(1.0 - rng.float(f64));
                x = @floor(y);
                v = -e - n * n / 2.0 + c;
            }
        } else if (u <= a12) {
            const n = normal(rng, f64, 0, 1);
            const y = s2 * @abs(n);
            reject = y >= d2;
            if (!reject) {
                const e = -@log(1.0 - rng.float(f64));
                x = @floor(-y);
                v = -e - n * n / 2.0;
            }
        } else if (u <= a123) {
            const e1 = -@log(1.0 - rng.float(f64));
            const e2 = -@log(1.0 - rng.float(f64));
            const y = d1 + 2.0 * s1s * e1 / d1;
            x = @floor(y);
            v = -e2 + d1 * (1.0 / (t - np) - y / (2.0 * s1s));
        } else {
            const e1 = -@log(1.0 - rng.float(f64));
            const e2 = -@log(1.0 - rng.float(f64));
            const y = d2 + 2.0 * s2s * e1 / d2;
            x = @floor(-y);
            v = -e2 - d2 * y / (2.0 * s2s);
        }

        reject = reject or x < -np or x > t - np;
        if (!reject) {
            const kf = np + x;
            const lfx = std.math.lgamma(f64, kf + 1.0) + std.math.lgamma(f64, t - kf + 1.0);
            reject = v > lf - lfx + x * lp1p;
        }
        if (reject) continue;

        const x_int: u64 = @intFromFloat(np + x + (1.0 - std.math.floatEps(f64)) / 2.0);
        return x_int + binomialWaiting(rng, trials - x_int, q);
    }
}

pub fn Uniform(comptime T: type) type {
    return struct {
        const Self = @This();

        low: T,
        high: T,
        inclusive: bool = false,

        pub fn init(low: T, high: T) Error!Self {
            if (!rangeLess(T, low, high)) return error.EmptyRange;
            return .{ .low = low, .high = high, .inclusive = false };
        }

        pub fn initInclusive(low: T, high: T) Error!Self {
            if (!rangeLessEqual(T, low, high)) return error.EmptyRange;
            return .{ .low = low, .high = high, .inclusive = true };
        }

        pub fn sample(self: Self, rng: Rng) T {
            if (self.inclusive) {
                return uniformInclusive(rng, T, self.low, self.high);
            }
            return uniform(rng, T, self.low, self.high);
        }
    };
}

pub const Open01 = struct {
    pub fn sample(_: Open01, rng: Rng, comptime T: type) T {
        return rng.floatOpen(T);
    }
};

pub const OpenClosed01 = struct {
    pub fn sample(_: OpenClosed01, rng: Rng, comptime T: type) T {
        return rng.floatOpenClosed(T);
    }
};

pub fn standardNormal(rng: Rng, comptime T: type) T {
    return Rng.normalFastFrom(rng, T, 0, 1);
}

pub fn standardNormalFrom(source: anytype, comptime T: type) T {
    return Rng.normalFastFrom(source, T, 0, 1);
}

pub fn normal(rng: Rng, comptime T: type, mean: T, stddev: T) T {
    comptime requireFloat(T);
    std.debug.assert(stddev >= 0);
    return Rng.normalFastFrom(rng, T, mean, stddev);
}

pub fn StandardNormal(comptime T: type) type {
    return struct {
        pub fn sample(_: @This(), rng: Rng) T {
            return standardNormal(rng, T);
        }

        pub fn sampleFrom(_: @This(), source: anytype) T {
            return standardNormalFrom(source, T);
        }
    };
}

pub fn standardExponential(rng: Rng, comptime T: type) T {
    return Rng.exponentialFastFrom(rng, T, 1);
}

pub fn standardExponentialFrom(source: anytype, comptime T: type) T {
    return Rng.exponentialFastFrom(source, T, 1);
}

pub fn exponential(rng: Rng, comptime T: type, rate: T) T {
    comptime requireFloat(T);
    std.debug.assert(rate > 0);
    return Rng.exponentialFastFrom(rng, T, rate);
}

pub fn Normal(comptime T: type) type {
    return struct {
        const Self = @This();

        mean: T,
        stddev: T,

        pub fn init(mean: T, stddev: T) Error!Self {
            comptime requireFloat(T);
            if (!(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
            if (!std.math.isFinite(mean)) return error.InvalidParameter;
            return .{ .mean = mean, .stddev = stddev };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return rng.normal(T, self.mean, self.stddev);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return Rng.normalFastFrom(source, T, self.mean, self.stddev);
        }
    };
}

pub fn StandardExponential(comptime T: type) type {
    return struct {
        pub fn sample(_: @This(), rng: Rng) T {
            return standardExponential(rng, T);
        }

        pub fn sampleFrom(_: @This(), source: anytype) T {
            return standardExponentialFrom(source, T);
        }
    };
}

pub fn Exponential(comptime T: type) type {
    return struct {
        const Self = @This();

        inverse_rate: T,

        pub fn init(rate: T) Error!Self {
            comptime requireFloat(T);
            if (!(rate > 0) or !std.math.isFinite(rate)) return error.InvalidParameter;
            return .{ .inverse_rate = 1 / rate };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return Rng.exponentialFastFrom(rng, T, 1) * self.inverse_rate;
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return Rng.exponentialFastFrom(source, T, 1) * self.inverse_rate;
        }
    };
}

pub fn logNormal(rng: Rng, comptime T: type, mean: T, stddev: T) T {
    comptime requireFloat(T);
    return @exp(normal(rng, T, mean, stddev));
}

pub fn LogNormal(comptime T: type) type {
    return struct {
        const Self = @This();

        normal_sampler: Normal(T),

        pub fn init(mean: T, stddev: T) Error!Self {
            return .{ .normal_sampler = try Normal(T).init(mean, stddev) };
        }

        pub fn sample(self: *Self, rng: Rng) T {
            return @exp(self.normal_sampler.sample(rng));
        }
    };
}

pub fn poisson(rng: Rng, lambda: f64) u64 {
    std.debug.assert(lambda >= 0 and std.math.isFinite(lambda));
    if (lambda == 0) return 0;

    if (lambda < 12) {
        return poissonProduct(rng, @exp(-lambda));
    }

    return poissonAhrensDieter(rng, lambda);
}

pub const Poisson = struct {
    method: PoissonMethod,

    pub fn init(lambda: f64) Error!Poisson {
        if (!(lambda >= 0) or !std.math.isFinite(lambda)) return error.InvalidParameter;
        if (lambda == 0) return .{ .method = .zero };
        if (lambda < 12) return .{ .method = .{ .product = @exp(-lambda) } };
        return .{ .method = .{ .ahrens_dieter = PoissonAhrensDieter.init(lambda) } };
    }

    pub fn sample(self: Poisson, rng: Rng) u64 {
        return self.sampleFrom(rng);
    }

    pub fn sampleFrom(self: Poisson, source: anytype) u64 {
        return switch (self.method) {
            .zero => 0,
            .product => |threshold| poissonProductFrom(source, threshold),
            .ahrens_dieter => |method| method.sampleFrom(source),
        };
    }
};

const PoissonMethod = union(enum) {
    zero,
    product: f64,
    ahrens_dieter: PoissonAhrensDieter,
};

const PoissonAhrensDieter = struct {
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

    fn init(lambda: f64) PoissonAhrensDieter {
        const s = @sqrt(lambda);
        const b1 = (1.0 / 24.0) / lambda;
        const b2 = 0.3 * b1 * b1;
        const c3 = (1.0 / 7.0) * b1 * b2;
        const c2 = b2 - 15.0 * c3;
        const c1 = b1 - 6.0 * b2 + 45.0 * c3;
        const c0 = 1.0 - b1 + 3.0 * b2 - 15.0 * c3;
        return .{
            .lambda = lambda,
            .s = s,
            .d = 6.0 * lambda * lambda,
            .l = @floor(lambda - 1.1484),
            .c = 0.1069 / lambda,
            .c0 = c0,
            .c1 = c1,
            .c2 = c2,
            .c3 = c3,
            .omega = 1.0 / @sqrt(2.0 * std.math.pi) / s,
        };
    }

    fn sample(self: PoissonAhrensDieter, rng: Rng) u64 {
        return self.sampleFrom(rng);
    }

    fn sampleFrom(self: PoissonAhrensDieter, source: anytype) u64 {
        while (true) {
            const g = Rng.normalFastFrom(source, f64, self.lambda, self.s);
            if (g >= 0) {
                const k1 = @floor(g);
                if (k1 >= self.l) return @intFromFloat(k1);

                const u = Rng.floatFrom(source, f64);
                const diff = self.lambda - k1;
                if (self.d * u >= diff * diff * diff) return @intFromFloat(k1);

                const parts = poissonAdParts(self, k1);
                if (parts.fy * (1.0 - u) <= parts.py * @exp(parts.px - parts.fx)) return @intFromFloat(k1);
            }

            while (true) {
                const e = Rng.exponentialFastFrom(source, f64, 1);
                const u = 2.0 * Rng.floatFrom(source, f64) - 1.0;
                const sign: f64 = if (u < 0) -1 else 1;
                const t = 1.8 + e * sign;
                if (t <= -0.6744) continue;

                const k2 = @floor(self.lambda + self.s * t);
                const parts = poissonAdParts(self, k2);
                if (self.c * @abs(u) <= parts.py * @exp(parts.px + e) - parts.fy * @exp(parts.fx + e)) {
                    return @intFromFloat(k2);
                }
            }
        }
    }
};

pub fn poissonAhrensDieter(rng: Rng, lambda: f64) u64 {
    std.debug.assert(lambda >= 12 and std.math.isFinite(lambda));
    return PoissonAhrensDieter.init(lambda).sample(rng);
}

fn poissonProduct(rng: Rng, threshold: f64) u64 {
    return poissonProductFrom(rng, threshold);
}

fn poissonProductFrom(source: anytype, threshold: f64) u64 {
    var k: u64 = 0;
    var p: f64 = 1;
    while (p > threshold) {
        k += 1;
        p *= Rng.floatFrom(source, f64);
    }
    return k - 1;
}

const PoissonAdParts = struct {
    px: f64,
    py: f64,
    fx: f64,
    fy: f64,
};

const PoissonAdPxPy = struct {
    px: f64,
    py: f64,
};

fn poissonAdParts(method: PoissonAhrensDieter, k: f64) PoissonAdParts {
    const px_py: PoissonAdPxPy = if (k < 10.0) blk: {
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

fn poissonPtrs(rng: Rng, lambda: f64) u64 {
    const sqrt_lambda = @sqrt(lambda);
    const log_lambda = @log(lambda);
    const b = 0.931 + 2.53 * sqrt_lambda;
    const a = -0.059 + 0.02483 * b;
    const inv_alpha = 1.1239 + 1.1328 / (b - 3.4);
    const v_r = 0.9277 - 3.6224 / (b - 2.0);

    while (true) {
        const u = rng.float(f64) - 0.5;
        const v = rng.floatOpen(f64);
        const us = 0.5 - @abs(u);
        const kf = @floor((2.0 * a / us + b) * u + lambda + 0.43);

        if (us >= 0.07 and v <= v_r) return @intFromFloat(kf);
        if (kf < 0 or (us < 0.013 and v > us)) continue;

        const k: u64 = @intFromFloat(kf);
        const lhs = @log(v) + @log(inv_alpha) - @log(a / (us * us) + b);
        const rhs = -lambda + @as(f64, @floatFromInt(k)) * log_lambda - logFactorial(k);
        if (lhs <= rhs) return k;
    }
}

fn logFactorial(k: u64) f64 {
    return std.math.lgamma(f64, @as(f64, @floatFromInt(k + 1)));
}

pub fn geometric(rng: Rng, p: f64) u64 {
    std.debug.assert(p > 0 and p <= 1);
    if (p == 1) return 1;
    const failures: u64 = @intFromFloat(@floor(@log(1 - rng.floatOpen(f64)) / @log(1 - p)));
    return failures + 1;
}

pub const Geometric = struct {
    p: f64,

    pub fn init(p: f64) Error!Geometric {
        if (!(p > 0 and p <= 1)) return error.InvalidProbability;
        return .{ .p = p };
    }

    pub fn sample(self: Geometric, rng: Rng) u64 {
        return geometric(rng, self.p);
    }
};

pub fn gamma(rng: Rng, comptime T: type, shape: T, scale: T) T {
    return gammaFrom(rng, T, shape, scale);
}

pub fn gammaFrom(source: anytype, comptime T: type, shape: T, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(shape > 0 and scale > 0);

    if (shape < 1) {
        const boosted = gammaFrom(source, T, shape + 1, 1);
        return scale * boosted * std.math.pow(T, Rng.floatFrom(source, T), 1 / shape);
    }

    const d = shape - @as(T, 1.0 / 3.0);
    const c = @as(T, 1.0) / @sqrt(9 * d);

    while (true) {
        const x = Rng.normalFastFrom(source, T, 0, 1);
        const v_base = 1 + c * x;
        if (v_base <= 0) continue;

        const v = v_base * v_base * v_base;
        const u = Rng.floatFrom(source, T);
        if (u < 1 - 0.0331 * (x * x) * (x * x)) return scale * d * v;
        if (@log(u) < 0.5 * x * x + d * (1 - v + @log(v))) return scale * d * v;
    }
}

pub fn Gamma(comptime T: type) type {
    return struct {
        const Self = @This();

        shape: T,
        scale: T,
        d: T,
        c: T,
        boost_inverse_shape: T = 0,
        boosted_d: T = 0,
        boosted_c: T = 0,
        is_boosted: bool = false,

        pub fn init(shape: T, scale: T) Error!Self {
            comptime requireFloat(T);
            if (!(shape > 0) or !(scale > 0)) return error.InvalidParameter;
            if (!std.math.isFinite(shape) or !std.math.isFinite(scale)) return error.InvalidParameter;
            return Self.initInternal(shape, scale);
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            if (self.is_boosted) {
                return self.scale * self.sampleMarsaglia(source, self.boosted_d, self.boosted_c) *
                    std.math.pow(T, Rng.floatFrom(source, T), self.boost_inverse_shape);
            }

            return self.scale * self.sampleMarsaglia(source, self.d, self.c);
        }

        fn sampleMarsaglia(_: Self, source: anytype, d: T, c: T) T {
            while (true) {
                const x = Rng.normalFastFrom(source, T, 0, 1);
                const v_base = 1 + c * x;
                if (v_base <= 0) continue;

                const v = v_base * v_base * v_base;
                const u = Rng.floatFrom(source, T);
                if (u < 1 - 0.0331 * (x * x) * (x * x)) return d * v;
                if (@log(u) < 0.5 * x * x + d * (1 - v + @log(v))) return d * v;
            }
        }

        fn initInternal(shape: T, scale: T) Self {
            if (shape < 1) {
                const boosted_shape = shape + 1;
                const boosted_d = boosted_shape - @as(T, 1.0 / 3.0);
                return .{
                    .shape = shape,
                    .scale = scale,
                    .d = 0,
                    .c = 0,
                    .boost_inverse_shape = 1 / shape,
                    .boosted_d = boosted_d,
                    .boosted_c = @as(T, 1.0) / @sqrt(9 * boosted_d),
                    .is_boosted = true,
                };
            }

            const d = shape - @as(T, 1.0 / 3.0);
            return .{
                .shape = shape,
                .scale = scale,
                .d = d,
                .c = @as(T, 1.0) / @sqrt(9 * d),
                .is_boosted = false,
            };
        }
    };
}

pub fn chiSquared(rng: Rng, comptime T: type, dof: T) T {
    comptime requireFloat(T);
    std.debug.assert(dof > 0);
    return gamma(rng, T, dof / 2, 2);
}

pub fn ChiSquared(comptime T: type) type {
    return struct {
        const Self = @This();

        dof: T,
        gamma_sampler: Gamma(T),

        pub fn init(dof: T) Error!Self {
            comptime requireFloat(T);
            if (!(dof > 0) or !std.math.isFinite(dof)) return error.InvalidParameter;
            return .{
                .dof = dof,
                .gamma_sampler = try Gamma(T).init(dof / 2, 2),
            };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return self.gamma_sampler.sampleFrom(source);
        }
    };
}

pub fn beta(rng: Rng, comptime T: type, alpha: T, beta_param: T) T {
    comptime requireFloat(T);
    const x = gamma(rng, T, alpha, 1);
    const y = gamma(rng, T, beta_param, 1);
    return x / (x + y);
}

pub fn Beta(comptime T: type) type {
    return struct {
        const Self = @This();

        alpha: T,
        beta_param: T,
        gamma_a: Gamma(T),
        gamma_b: Gamma(T),

        pub fn init(alpha: T, beta_param: T) Error!Self {
            comptime requireFloat(T);
            if (!(alpha > 0) or !(beta_param > 0)) return error.InvalidParameter;
            if (!std.math.isFinite(alpha) or !std.math.isFinite(beta_param)) return error.InvalidParameter;
            return .{
                .alpha = alpha,
                .beta_param = beta_param,
                .gamma_a = try Gamma(T).init(alpha, 1),
                .gamma_b = try Gamma(T).init(beta_param, 1),
            };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            const x = self.gamma_a.sampleFrom(source);
            const y = self.gamma_b.sampleFrom(source);
            return x / (x + y);
        }
    };
}

pub fn fisherF(rng: Rng, comptime T: type, d1: T, d2: T) T {
    comptime requireFloat(T);
    std.debug.assert(d1 > 0 and d2 > 0);
    const x = chiSquared(rng, T, d1) / d1;
    const y = chiSquared(rng, T, d2) / d2;
    return x / y;
}

pub fn FisherF(comptime T: type) type {
    return struct {
        const Self = @This();

        d1: T,
        d2: T,
        numerator: Gamma(T),
        denominator: Gamma(T),

        pub fn init(d1: T, d2: T) Error!Self {
            comptime requireFloat(T);
            if (!(d1 > 0) or !(d2 > 0)) return error.InvalidParameter;
            if (!std.math.isFinite(d1) or !std.math.isFinite(d2)) return error.InvalidParameter;
            return .{
                .d1 = d1,
                .d2 = d2,
                .numerator = try Gamma(T).init(d1 / 2, 2 / d1),
                .denominator = try Gamma(T).init(d2 / 2, 2 / d2),
            };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return self.numerator.sampleFrom(source) / self.denominator.sampleFrom(source);
        }
    };
}

pub fn studentT(rng: Rng, comptime T: type, dof: T) T {
    comptime requireFloat(T);
    std.debug.assert(dof > 0);
    return normal(rng, T, 0, 1) * @sqrt(dof / chiSquared(rng, T, dof));
}

pub fn StudentT(comptime T: type) type {
    return struct {
        const Self = @This();

        dof: T,
        chi_squared_sampler: ChiSquared(T),

        pub fn init(dof: T) Error!Self {
            comptime requireFloat(T);
            if (!(dof > 0) or !std.math.isFinite(dof)) return error.InvalidParameter;
            return .{
                .dof = dof,
                .chi_squared_sampler = try ChiSquared(T).init(dof),
            };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return Rng.normalFastFrom(source, T, 0, 1) * @sqrt(self.dof / self.chi_squared_sampler.sampleFrom(source));
        }
    };
}

pub fn triangular(rng: Rng, comptime T: type, min: T, mode: T, max: T) T {
    comptime requireFloat(T);
    std.debug.assert(min <= mode and mode <= max and min < max);

    const u = rng.float(T);
    const c = (mode - min) / (max - min);
    if (u < c) {
        return min + @sqrt(u * (max - min) * (mode - min));
    }
    return max - @sqrt((1 - u) * (max - min) * (max - mode));
}

pub fn Triangular(comptime T: type) type {
    return struct {
        const Self = @This();

        min: T,
        mode: T,
        max: T,

        pub fn init(min: T, mode: T, max: T) Error!Self {
            comptime requireFloat(T);
            if (!(min <= mode and mode <= max and min < max)) return error.InvalidParameter;
            if (!std.math.isFinite(min) or !std.math.isFinite(mode) or !std.math.isFinite(max)) return error.InvalidParameter;
            return .{ .min = min, .mode = mode, .max = max };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return triangular(rng, T, self.min, self.mode, self.max);
        }
    };
}

pub fn cauchy(rng: Rng, comptime T: type, median: T, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(scale > 0);
    const u = rng.floatOpen(T);
    return median + scale * @tan(@as(T, @floatCast(std.math.pi)) * (u - 0.5));
}

pub fn Cauchy(comptime T: type) type {
    return struct {
        const Self = @This();

        median: T,
        scale: T,

        pub fn init(median: T, scale: T) Error!Self {
            comptime requireFloat(T);
            if (!(scale > 0) or !std.math.isFinite(scale)) return error.InvalidParameter;
            if (!std.math.isFinite(median)) return error.InvalidParameter;
            return .{ .median = median, .scale = scale };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return cauchy(rng, T, self.median, self.scale);
        }
    };
}

pub fn pareto(rng: Rng, comptime T: type, scale: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and shape > 0);
    return scale / std.math.pow(T, rng.floatOpen(T), 1 / shape);
}

pub fn Pareto(comptime T: type) type {
    return struct {
        const Self = @This();

        scale: T,
        shape: T,

        pub fn init(scale: T, shape: T) Error!Self {
            comptime requireFloat(T);
            if (!(scale > 0) or !(shape > 0)) return error.InvalidParameter;
            if (!std.math.isFinite(scale) or !std.math.isFinite(shape)) return error.InvalidParameter;
            return .{ .scale = scale, .shape = shape };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return pareto(rng, T, self.scale, self.shape);
        }
    };
}

pub fn weibull(rng: Rng, comptime T: type, scale: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and shape > 0);
    return scale * std.math.pow(T, -@log(rng.floatOpen(T)), 1 / shape);
}

pub fn Weibull(comptime T: type) type {
    return struct {
        const Self = @This();

        scale: T,
        shape: T,

        pub fn init(scale: T, shape: T) Error!Self {
            comptime requireFloat(T);
            if (!(scale > 0) or !(shape > 0)) return error.InvalidParameter;
            if (!std.math.isFinite(scale) or !std.math.isFinite(shape)) return error.InvalidParameter;
            return .{ .scale = scale, .shape = shape };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return weibull(rng, T, self.scale, self.shape);
        }
    };
}

pub fn gumbel(rng: Rng, comptime T: type, location: T, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and std.math.isFinite(scale));
    const u = rng.floatOpenClosed(T);
    return location - scale * @log(-@log(u));
}

pub fn Gumbel(comptime T: type) type {
    return struct {
        const Self = @This();

        location: T,
        scale: T,

        pub fn init(location: T, scale: T) Error!Self {
            comptime requireFloat(T);
            if (!std.math.isFinite(location)) return error.InvalidParameter;
            if (!(scale > 0) or !std.math.isFinite(scale)) return error.InvalidParameter;
            return .{ .location = location, .scale = scale };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return gumbel(rng, T, self.location, self.scale);
        }
    };
}

pub fn frechet(rng: Rng, comptime T: type, location: T, scale: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and shape > 0);
    const u = rng.floatOpenClosed(T);
    return location + scale * std.math.pow(T, -@log(u), -1 / shape);
}

pub fn Frechet(comptime T: type) type {
    return struct {
        const Self = @This();

        location: T,
        scale: T,
        shape: T,

        pub fn init(location: T, scale: T, shape: T) Error!Self {
            comptime requireFloat(T);
            if (!std.math.isFinite(location)) return error.InvalidParameter;
            if (!(scale > 0) or !(shape > 0)) return error.InvalidParameter;
            if (!std.math.isFinite(scale) or !std.math.isFinite(shape)) return error.InvalidParameter;
            return .{ .location = location, .scale = scale, .shape = shape };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return frechet(rng, T, self.location, self.scale, self.shape);
        }
    };
}

pub fn skewNormal(rng: Rng, comptime T: type, location: T, scale: T, shape: T) T {
    return skewNormalFrom(rng, T, location, scale, shape);
}

pub fn skewNormalFrom(source: anytype, comptime T: type, location: T, scale: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and std.math.isFinite(shape));

    const z1 = Rng.normalFastFrom(source, T, 0, 1);
    if (shape == 0) return location + scale * z1;

    const z2 = Rng.normalFastFrom(source, T, 0, 1);
    const high = @max(z1, z2);
    const low = @min(z1, z2);
    const normalized = if (shape == -1)
        low
    else if (shape == 1)
        high
    else blk: {
        const one: T = 1;
        const sqrt_two: T = @sqrt(@as(T, 2));
        break :blk ((one + shape) * high + (one - shape) * low) /
            (@sqrt(one + shape * shape) * sqrt_two);
    };
    return location + scale * normalized;
}

pub fn SkewNormal(comptime T: type) type {
    return struct {
        const Self = @This();

        location: T,
        scale: T,
        shape: T,

        pub fn init(location: T, scale: T, shape: T) Error!Self {
            comptime requireFloat(T);
            if (!std.math.isFinite(location)) return error.InvalidParameter;
            if (!(scale > 0) or !std.math.isFinite(scale)) return error.InvalidParameter;
            if (!std.math.isFinite(shape)) return error.InvalidParameter;
            return .{ .location = location, .scale = scale, .shape = shape };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return skewNormalFrom(source, T, self.location, self.scale, self.shape);
        }
    };
}

pub fn pert(rng: Rng, comptime T: type, min: T, mode: T, max: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(min < max and min <= mode and mode <= max and shape >= 0);
    const range = max - min;
    const alpha = 1 + shape * (mode - min) / range;
    const beta_param = 1 + shape * (max - mode) / range;
    return min + range * beta(rng, T, alpha, beta_param);
}

pub fn Pert(comptime T: type) type {
    return struct {
        const Self = @This();

        min: T,
        range: T,
        alpha: T,
        beta_param: T,

        pub fn init(min: T, mode: T, max: T, shape: T) Error!Self {
            comptime requireFloat(T);
            if (!std.math.isFinite(min) or !std.math.isFinite(mode) or !std.math.isFinite(max)) return error.InvalidParameter;
            if (!(min < max) or !(min <= mode and mode <= max)) return error.InvalidParameter;
            if (!(shape >= 0) or !std.math.isFinite(shape)) return error.InvalidParameter;
            const range = max - min;
            return .{
                .min = min,
                .range = range,
                .alpha = 1 + shape * (mode - min) / range,
                .beta_param = 1 + shape * (max - mode) / range,
            };
        }

        pub fn initDefault(min: T, mode: T, max: T) Error!Self {
            return Self.init(min, mode, max, 4);
        }

        pub fn initMean(min: T, mean: T, max: T, shape: T) Error!Self {
            comptime requireFloat(T);
            if (!(shape > 0) or !std.math.isFinite(shape)) return error.InvalidParameter;
            const mode = ((shape + 2) * mean - min - max) / shape;
            return Self.init(min, mode, max, shape);
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.min + self.range * beta(rng, T, self.alpha, self.beta_param);
        }
    };
}

pub fn unitCircle(rng: Rng, comptime T: type) [2]T {
    return unitCircleFrom(rng, T);
}

pub fn unitCircleFrom(source: anytype, comptime T: type) [2]T {
    comptime requireFloat(T);
    while (true) {
        const x1 = signedUnitFloatFrom(source, T);
        const x2 = signedUnitFloatFrom(source, T);
        const sum = x1 * x1 + x2 * x2;
        if (!(sum > 0 and sum < 1)) continue;

        const diff = x1 * x1 - x2 * x2;
        return .{ diff / sum, 2 * x1 * x2 / sum };
    }
}

pub fn unitDisc(rng: Rng, comptime T: type) [2]T {
    return unitDiscFrom(rng, T);
}

pub fn unitDiscFrom(source: anytype, comptime T: type) [2]T {
    comptime requireFloat(T);
    while (true) {
        const x1 = signedUnitFloatFrom(source, T);
        const x2 = signedUnitFloatFrom(source, T);
        if (x1 * x1 + x2 * x2 <= 1) return .{ x1, x2 };
    }
}

pub fn unitSphere(rng: Rng, comptime T: type) [3]T {
    return unitSphereFrom(rng, T);
}

pub fn unitSphereFrom(source: anytype, comptime T: type) [3]T {
    comptime requireFloat(T);
    while (true) {
        const x1 = signedUnitFloatFrom(source, T);
        const x2 = signedUnitFloatFrom(source, T);
        const sum = x1 * x1 + x2 * x2;
        if (sum >= 1) continue;

        const factor = 2 * @sqrt(1 - sum);
        return .{ x1 * factor, x2 * factor, 1 - 2 * sum };
    }
}

pub fn unitBall(rng: Rng, comptime T: type) [3]T {
    return unitBallFrom(rng, T);
}

pub fn unitBallFrom(source: anytype, comptime T: type) [3]T {
    comptime requireFloat(T);
    while (true) {
        const x1 = signedUnitFloatFrom(source, T);
        const x2 = signedUnitFloatFrom(source, T);
        const x3 = signedUnitFloatFrom(source, T);
        if (x1 * x1 + x2 * x2 + x3 * x3 <= 1) return .{ x1, x2, x3 };
    }
}

inline fn signedUnitFloatFrom(source: anytype, comptime T: type) T {
    return switch (T) {
        f32 => blk: {
            const repr = (@as(u32, 0x80) << 23) | @as(u32, @truncate(Rng.nextFrom(source) >> 41));
            break :blk @as(f32, @bitCast(repr)) - 3.0;
        },
        f64 => blk: {
            const repr = (@as(u64, 0x400) << 52) | (Rng.nextFrom(source) >> 12);
            break :blk @as(f64, @bitCast(repr)) - 3.0;
        },
        else => @compileError("alea supports f32 and f64 unit geometry"),
    };
}

pub fn UnitCircle(comptime T: type) type {
    return struct {
        pub fn sample(_: @This(), rng: Rng) [2]T {
            return unitCircle(rng, T);
        }

        pub fn sampleFrom(_: @This(), source: anytype) [2]T {
            return unitCircleFrom(source, T);
        }
    };
}

pub fn UnitDisc(comptime T: type) type {
    return struct {
        pub fn sample(_: @This(), rng: Rng) [2]T {
            return unitDisc(rng, T);
        }

        pub fn sampleFrom(_: @This(), source: anytype) [2]T {
            return unitDiscFrom(source, T);
        }
    };
}

pub fn UnitSphere(comptime T: type) type {
    return struct {
        pub fn sample(_: @This(), rng: Rng) [3]T {
            return unitSphere(rng, T);
        }

        pub fn sampleFrom(_: @This(), source: anytype) [3]T {
            return unitSphereFrom(source, T);
        }
    };
}

pub fn UnitBall(comptime T: type) type {
    return struct {
        pub fn sample(_: @This(), rng: Rng) [3]T {
            return unitBall(rng, T);
        }

        pub fn sampleFrom(_: @This(), source: anytype) [3]T {
            return unitBallFrom(source, T);
        }
    };
}

pub fn inverseGaussian(rng: Rng, comptime T: type, mean: T, shape: T) T {
    return inverseGaussianFrom(rng, T, mean, shape);
}

pub fn inverseGaussianFrom(source: anytype, comptime T: type, mean: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(mean > 0 and shape > 0);

    const z = Rng.normalFastFrom(source, T, 0, 1);
    const y = mean * z * z;
    const mean_over_2shape = mean / (2 * shape);
    const x = mean + mean_over_2shape * (y - @sqrt(4 * shape * y + y * y));
    if (Rng.floatFrom(source, T) <= mean / (mean + x)) return x;
    return mean * mean / x;
}

pub fn InverseGaussian(comptime T: type) type {
    return struct {
        const Self = @This();

        mean: T,
        shape: T,

        pub fn init(mean: T, shape: T) Error!Self {
            comptime requireFloat(T);
            if (!(mean > 0) or !(shape > 0)) return error.InvalidParameter;
            if (!std.math.isFinite(mean) or !std.math.isFinite(shape)) return error.InvalidParameter;
            return .{ .mean = mean, .shape = shape };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return inverseGaussianFrom(source, T, self.mean, self.shape);
        }
    };
}

pub fn normalInverseGaussian(rng: Rng, comptime T: type, alpha: T, beta_param: T) T {
    comptime requireFloat(T);
    std.debug.assert(alpha > 0 and @abs(beta_param) < alpha);

    const ratio = beta_param / alpha;
    const gamma_param = alpha * @sqrt(1 - ratio * ratio);
    const inv_gauss = inverseGaussian(rng, T, 1 / gamma_param, 1);
    return beta_param * inv_gauss + @sqrt(inv_gauss) * normal(rng, T, 0, 1);
}

pub fn NormalInverseGaussian(comptime T: type) type {
    return struct {
        const Self = @This();

        beta_param: T,
        inverse_mean: T,
        inverse_gaussian: InverseGaussian(T),

        pub fn init(alpha: T, beta_param: T) Error!Self {
            comptime requireFloat(T);
            if (!(alpha > 0) or !std.math.isFinite(alpha)) return error.InvalidParameter;
            if (!std.math.isFinite(beta_param) or !(@abs(beta_param) < alpha)) return error.InvalidParameter;

            const ratio = beta_param / alpha;
            const gamma_param = alpha * @sqrt(1 - ratio * ratio);
            const inverse_mean = 1 / gamma_param;
            if (!(inverse_mean > 0) or !std.math.isFinite(inverse_mean)) return error.InvalidParameter;
            return .{
                .beta_param = beta_param,
                .inverse_mean = inverse_mean,
                .inverse_gaussian = try InverseGaussian(T).init(inverse_mean, 1),
            };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            const inv_gauss = self.inverse_gaussian.sampleFrom(source);
            return self.beta_param * inv_gauss + @sqrt(inv_gauss) * Rng.normalFastFrom(source, T, 0, 1);
        }
    };
}

pub fn zipf(rng: Rng, comptime T: type, n: T, exponent: T) T {
    comptime requireFloat(T);
    std.debug.assert(exponent >= 0 and n >= 1);

    const sampler = Zipf(T).init(n, exponent) catch unreachable;
    return sampler.sample(rng);
}

pub fn Zipf(comptime T: type) type {
    return struct {
        const Self = @This();

        exponent: T,
        t: T,
        q: T,

        pub fn init(n: T, exponent: T) Error!Self {
            comptime requireFloat(T);
            if (!(exponent >= 0) or std.math.isNan(exponent)) return error.InvalidParameter;
            if (!(n >= 1) or std.math.isNan(n)) return error.InvalidParameter;
            if (std.math.isInf(n) and exponent <= 1) return error.InvalidParameter;

            const q = if (exponent != 1) 1 / (1 - exponent) else 0;
            const t = if (std.math.isInf(exponent))
                1
            else if (exponent != 1)
                (std.math.pow(T, n, 1 - exponent) - exponent) * q
            else
                1 + @log(n);

            if (!(t > 0) or std.math.isNan(t)) return error.InvalidParameter;
            return .{ .exponent = exponent, .t = t, .q = q };
        }

        pub fn sample(self: Self, rng: Rng) T {
            if (std.math.isInf(self.exponent)) return 1;

            while (true) {
                const inv_b = self.invCdf(rng.float(T));
                const x = @floor(inv_b + 1);
                var ratio = std.math.pow(T, x, -self.exponent);
                if (x > 1) ratio *= std.math.pow(T, inv_b, self.exponent);

                if (rng.float(T) < ratio) return x;
            }
        }

        fn invCdf(self: Self, p: T) T {
            const pt = p * self.t;
            if (pt <= 1) return pt;
            if (self.exponent != 1) return std.math.pow(T, pt * (1 - self.exponent) + self.exponent, self.q);
            return @exp(pt - 1);
        }
    };
}

pub fn zeta(rng: Rng, comptime T: type, exponent: T) T {
    comptime requireFloat(T);
    std.debug.assert(exponent > 1);

    const sampler = Zeta(T).init(exponent) catch unreachable;
    return sampler.sample(rng);
}

pub fn Zeta(comptime T: type) type {
    return struct {
        const Self = @This();

        exponent_minus_one: T,
        b: T,

        pub fn init(exponent: T) Error!Self {
            comptime requireFloat(T);
            if (!(exponent > 1) or std.math.isNan(exponent)) return error.InvalidParameter;
            const exponent_minus_one = exponent - 1;
            return .{
                .exponent_minus_one = exponent_minus_one,
                .b = std.math.pow(T, 2, exponent_minus_one),
            };
        }

        pub fn sample(self: Self, rng: Rng) T {
            while (true) {
                const u = rng.floatOpenClosed(T);
                const x = @floor(std.math.pow(T, u, -1 / self.exponent_minus_one));
                if (std.math.isInf(x)) return x;

                const t = std.math.pow(T, 1 + 1 / x, self.exponent_minus_one);
                const v = rng.float(T);
                if (v * x * (t - 1) * self.b <= t * (self.b - 1)) return x;
            }
        }
    };
}

pub fn Dirichlet(comptime T: type) type {
    return struct {
        const Self = @This();

        alpha: []const T,

        pub fn init(alpha: []const T) Error!Self {
            comptime requireFloat(T);
            if (alpha.len == 0) return error.EmptyRange;
            for (alpha) |a| {
                if (!(a > 0) or !std.math.isFinite(a)) return error.InvalidParameter;
            }
            return .{ .alpha = alpha };
        }

        pub fn sample(self: Self, allocator: std.mem.Allocator, rng: Rng) ![]T {
            const out = try allocator.alloc(T, self.alpha.len);
            errdefer allocator.free(out);
            self.sampleInto(rng, out);
            return out;
        }

        pub fn sampleInto(self: Self, rng: Rng, out: []T) void {
            std.debug.assert(out.len == self.alpha.len);
            var total: T = 0;
            for (self.alpha, out) |a, *slot| {
                const value = gamma(rng, T, a, 1);
                slot.* = value;
                total += value;
            }

            for (out) |*value| value.* /= total;
        }
    };
}

pub fn aliasTable(comptime T: type) type {
    return AliasTable(T);
}

pub fn AliasTable(comptime Weight: type) type {
    return struct {
        const Self = @This();

        prob: []f64,
        alias: []usize,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, weights: []const Weight) !Self {
            std.debug.assert(weights.len > 0);

            const prob = try allocator.alloc(f64, weights.len);
            errdefer allocator.free(prob);
            const alias = try allocator.alloc(usize, weights.len);
            errdefer allocator.free(alias);

            var scaled = try allocator.alloc(f64, weights.len);
            defer allocator.free(scaled);
            var small = try std.ArrayList(usize).initCapacity(allocator, weights.len);
            defer small.deinit(allocator);
            var large = try std.ArrayList(usize).initCapacity(allocator, weights.len);
            defer large.deinit(allocator);

            var total: f64 = 0;
            for (weights) |weight| {
                const value: f64 = switch (@typeInfo(Weight)) {
                    .int => @floatFromInt(weight),
                    .float => @floatCast(weight),
                    else => @compileError("alias weights must be numeric"),
                };
                if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
                total += value;
            }
            if (!(total > 0) or !std.math.isFinite(total)) return error.InvalidWeight;

            for (weights, 0..) |weight, i| {
                const value: f64 = switch (@typeInfo(Weight)) {
                    .int => @floatFromInt(weight),
                    .float => @floatCast(weight),
                    else => unreachable,
                };
                scaled[i] = value * @as(f64, @floatFromInt(weights.len)) / total;
                if (scaled[i] < 1) {
                    try small.append(allocator, i);
                } else {
                    try large.append(allocator, i);
                }
            }

            while (small.pop()) |less| {
                if (large.pop()) |more| {
                    prob[less] = scaled[less];
                    alias[less] = more;
                    scaled[more] = (scaled[more] + scaled[less]) - 1;
                    if (scaled[more] < 1) {
                        try small.append(allocator, more);
                    } else {
                        try large.append(allocator, more);
                    }
                } else {
                    prob[less] = 1;
                    alias[less] = less;
                }
            }

            while (large.pop()) |more| {
                prob[more] = 1;
                alias[more] = more;
            }

            return .{
                .prob = prob,
                .alias = alias,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.prob);
            self.allocator.free(self.alias);
            self.* = undefined;
        }

        pub fn update(self: *Self, weights: []const Weight) !void {
            if (weights.len != self.prob.len) return error.InvalidParameter;

            const next = try Self.init(self.allocator, weights);
            self.allocator.free(self.prob);
            self.allocator.free(self.alias);
            self.prob = next.prob;
            self.alias = next.alias;
        }

        pub fn sample(self: Self, rng: Rng) usize {
            const column = rng.uintLessThan(usize, self.prob.len);
            return if (rng.float(f64) < self.prob[column]) column else self.alias[column];
        }
    };
}

pub fn WeightedTree(comptime Weight: type) type {
    return struct {
        const Self = @This();

        subtotals: std.ArrayList(f64),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, weights: []const Weight) !Self {
            var subtotals = try std.ArrayList(f64).initCapacity(allocator, weights.len);
            errdefer subtotals.deinit(allocator);

            for (weights) |weight| {
                try subtotals.append(allocator, try weightToF64(weight));
            }
            buildSubtotals(subtotals.items);

            return .{
                .subtotals = subtotals,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.subtotals.deinit(self.allocator);
            self.* = undefined;
        }

        pub fn len(self: Self) usize {
            return self.subtotals.items.len;
        }

        pub fn isEmpty(self: Self) bool {
            return self.len() == 0;
        }

        pub fn totalWeight(self: Self) f64 {
            return if (self.subtotals.items.len == 0) 0 else self.subtotals.items[0];
        }

        pub fn isValid(self: Self) bool {
            return self.totalWeight() > 0;
        }

        pub fn get(self: Self, index: usize) Error!f64 {
            if (index >= self.subtotals.items.len) return error.InvalidParameter;
            return self.subtotals.items[index] - self.subtotal(2 * index + 1) - self.subtotal(2 * index + 2);
        }

        pub fn push(self: *Self, weight: Weight) !void {
            const value = try weightToF64(weight);
            const next_total = self.totalWeight() + value;
            if (!std.math.isFinite(next_total)) return error.InvalidWeight;

            try self.subtotals.append(self.allocator, value);
            var index = self.subtotals.items.len - 1;
            while (index != 0) {
                index = (index - 1) / 2;
                self.subtotals.items[index] += value;
            }
        }

        pub fn pop(self: *Self) ?f64 {
            if (self.subtotals.items.len == 0) return null;

            const index = self.subtotals.items.len - 1;
            const weight = self.get(index) catch unreachable;
            _ = self.subtotals.pop();

            var parent_index = index;
            while (parent_index != 0) {
                parent_index = (parent_index - 1) / 2;
                self.subtotals.items[parent_index] -= weight;
            }
            return weight;
        }

        pub fn update(self: *Self, index: usize, weight: Weight) !void {
            if (index >= self.subtotals.items.len) return error.InvalidParameter;

            const value = try weightToF64(weight);
            const old = try self.get(index);
            const delta = value - old;
            const next_total = self.totalWeight() + delta;
            if (next_total < 0 or !std.math.isFinite(next_total)) return error.InvalidWeight;

            var cursor = index;
            while (true) {
                self.subtotals.items[cursor] += delta;
                if (cursor == 0) break;
                cursor = (cursor - 1) / 2;
            }
        }

        pub fn sample(self: Self, rng: Rng) usize {
            return self.sampleChecked(rng) catch unreachable;
        }

        pub fn sampleChecked(self: Self, rng: Rng) Error!usize {
            const total = self.totalWeight();
            if (!(total > 0)) return error.InvalidWeight;

            var target = rng.float(f64) * total;
            var index: usize = 0;
            while (true) {
                const left_index = 2 * index + 1;
                const left = self.subtotal(left_index);
                if (target < left) {
                    index = left_index;
                    continue;
                }
                target -= left;

                const right_index = 2 * index + 2;
                const right = self.subtotal(right_index);
                if (target < right) {
                    index = right_index;
                    continue;
                }
                target -= right;

                const own = self.subtotals.items[index] - left - right;
                if (target < own or own > 0) return index;
            }
        }

        fn subtotal(self: Self, index: usize) f64 {
            return if (index < self.subtotals.items.len) self.subtotals.items[index] else 0;
        }

        fn weightToF64(weight: Weight) Error!f64 {
            const value: f64 = switch (@typeInfo(Weight)) {
                .int => @floatFromInt(weight),
                .float => @floatCast(weight),
                else => @compileError("weighted tree weights must be numeric"),
            };
            if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
            return value;
        }

        fn buildSubtotals(subtotals: []f64) void {
            var i = subtotals.len;
            while (i > 1) {
                i -= 1;
                subtotals[(i - 1) / 2] += subtotals[i];
            }
        }
    };
}

pub fn WeightedIntTree(comptime Weight: type) type {
    return struct {
        const Self = @This();

        subtotals: std.ArrayList(u64),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, weights: []const Weight) !Self {
            comptime requireUnsignedWeight(Weight);
            var subtotals = try std.ArrayList(u64).initCapacity(allocator, weights.len);
            errdefer subtotals.deinit(allocator);

            for (weights) |weight| try subtotals.append(allocator, @intCast(weight));
            buildSubtotals(subtotals.items);

            return .{ .subtotals = subtotals, .allocator = allocator };
        }

        pub fn deinit(self: *Self) void {
            self.subtotals.deinit(self.allocator);
            self.* = undefined;
        }

        pub fn len(self: Self) usize {
            return self.subtotals.items.len;
        }

        pub fn totalWeight(self: Self) u64 {
            return if (self.subtotals.items.len == 0) 0 else self.subtotals.items[0];
        }

        pub fn get(self: Self, index: usize) Error!u64 {
            if (index >= self.subtotals.items.len) return error.InvalidParameter;
            return self.subtotals.items[index] - self.subtotal(2 * index + 1) - self.subtotal(2 * index + 2);
        }

        pub fn update(self: *Self, index: usize, weight: Weight) !void {
            if (index >= self.subtotals.items.len) return error.InvalidParameter;
            const value: u64 = @intCast(weight);
            const old = try self.get(index);
            if (value >= old) {
                const delta = value - old;
                var cursor = index;
                while (true) {
                    self.subtotals.items[cursor] += delta;
                    if (cursor == 0) break;
                    cursor = (cursor - 1) / 2;
                }
            } else {
                const delta = old - value;
                var cursor = index;
                while (true) {
                    self.subtotals.items[cursor] -= delta;
                    if (cursor == 0) break;
                    cursor = (cursor - 1) / 2;
                }
            }
        }

        pub fn sample(self: Self, rng: Rng) usize {
            return self.sampleChecked(rng) catch unreachable;
        }

        pub fn sampleChecked(self: Self, rng: Rng) Error!usize {
            const total = self.totalWeight();
            if (total == 0) return error.InvalidWeight;

            var target = rng.uintLessThan(u64, total);
            var index: usize = 0;
            while (true) {
                const left_index = 2 * index + 1;
                const left = self.subtotal(left_index);
                if (target < left) {
                    index = left_index;
                    continue;
                }
                target -= left;

                const right_index = 2 * index + 2;
                const right = self.subtotal(right_index);
                if (target < right) {
                    index = right_index;
                    continue;
                }
                target -= right;

                const own = self.subtotals.items[index] - left - right;
                if (target < own or own > 0) return index;
            }
        }

        fn subtotal(self: Self, index: usize) u64 {
            return if (index < self.subtotals.items.len) self.subtotals.items[index] else 0;
        }

        fn buildSubtotals(subtotals: []u64) void {
            var i = subtotals.len;
            while (i > 1) {
                i -= 1;
                subtotals[(i - 1) / 2] += subtotals[i];
            }
        }
    };
}

fn requireUnsignedWeight(comptime Weight: type) void {
    if (@typeInfo(Weight) != .int or @typeInfo(Weight).int.signedness != .unsigned) {
        @compileError("WeightedIntTree weights must be unsigned integers");
    }
}

fn rangeLess(comptime T: type, low: T, high: T) bool {
    return switch (@typeInfo(T)) {
        .int, .float => low < high,
        else => @compileError("Uniform supports integer and floating-point types"),
    };
}

fn rangeLessEqual(comptime T: type, low: T, high: T) bool {
    return switch (@typeInfo(T)) {
        .int, .float => low <= high,
        else => @compileError("Uniform supports integer and floating-point types"),
    };
}

fn requireFloat(comptime T: type) void {
    if (@typeInfo(T) != .float) @compileError("expected float type, found " ++ @typeName(T));
}

test "basic distributions stay in expected ranges" {
    const alea = @import("root.zig");
    var engine = alea.Xoshiro256.init(1234);
    const rng = Rng.init(&engine);

    try std.testing.expect(uniform(rng, u32, 5, 9) >= 5);
    try std.testing.expect(uniform(rng, f64, -1, 1) < 1);
    try std.testing.expect((try Bernoulli.initRatio(1, 1)).sample(rng));
    try std.testing.expect(!(try Bernoulli.init(0)).sample(rng));
    try std.testing.expect((try Bernoulli.init(1.0 - std.math.floatEps(f64) / 2.0)).sample(rng));
    try std.testing.expect((try Binomial.init(10, 1)).sample(rng) == 10);
    try std.testing.expect(exponential(rng, f64, 2) >= 0);
    try std.testing.expect(poisson(rng, 4) < 32);
    try std.testing.expect(beta(rng, f64, 2, 5) >= 0);

    const die = try Uniform(u8).initInclusive(1, 6);
    const roll = die.sample(rng);
    try std.testing.expect(roll >= 1 and roll <= 6);
}

test "alias table samples valid indexes" {
    const alea = @import("root.zig");
    var engine = alea.Wyhash64.init(44);
    const rng = Rng.init(&engine);

    var table = try AliasTable(u32).init(std.testing.allocator, &.{ 1, 0, 5, 3 });
    defer table.deinit();

    var i: usize = 0;
    while (i < 32) : (i += 1) {
        const index = table.sample(rng);
        try std.testing.expect(index < 4);
        try std.testing.expect(index != 1);
    }

    try table.update(&.{ 0, 10, 0, 0 });
    i = 0;
    while (i < 16) : (i += 1) {
        try std.testing.expectEqual(@as(usize, 1), table.sample(rng));
    }

    try std.testing.expectError(error.InvalidParameter, table.update(&.{ 1, 2 }));
}

test "weighted tree supports dynamic updates" {
    const alea = @import("root.zig");
    var engine = alea.Wyhash64.init(45);
    const rng = Rng.init(&engine);

    var tree = try WeightedTree(u32).init(std.testing.allocator, &.{ 9, 1, 0 });
    defer tree.deinit();

    try std.testing.expectEqual(@as(usize, 3), tree.len());
    try std.testing.expect(tree.isValid());
    try std.testing.expectApproxEqAbs(@as(f64, 10), tree.totalWeight(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 9), try tree.get(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), try tree.get(1), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), try tree.get(2), 1e-12);

    try tree.update(0, 0);
    try tree.update(1, 0);
    try std.testing.expect(!tree.isValid());
    try std.testing.expectError(error.InvalidWeight, tree.sampleChecked(rng));

    try tree.push(7);
    var i: usize = 0;
    while (i < 16) : (i += 1) {
        try std.testing.expectEqual(@as(usize, 3), tree.sample(rng));
    }

    try tree.update(2, 5);
    var saw_two = false;
    i = 0;
    while (i < 64) : (i += 1) {
        const index = tree.sample(rng);
        try std.testing.expect(index == 2 or index == 3);
        saw_two = saw_two or index == 2;
    }
    try std.testing.expect(saw_two);

    try std.testing.expectApproxEqAbs(@as(f64, 7), tree.pop().?, 1e-12);
    try std.testing.expectEqual(@as(usize, 3), tree.len());
    try std.testing.expectEqual(@as(usize, 2), tree.sample(rng));
    try std.testing.expectError(error.InvalidParameter, tree.update(9, 1));

    var float_tree = try WeightedTree(f64).init(std.testing.allocator, &.{1.0});
    defer float_tree.deinit();
    try std.testing.expectError(error.InvalidWeight, float_tree.push(std.math.nan(f64)));
}

test "weighted int tree supports dynamic updates" {
    const alea = @import("root.zig");
    var engine = alea.Wyhash64.init(46);
    const rng = Rng.init(&engine);

    var tree = try WeightedIntTree(u32).init(std.testing.allocator, &.{ 9, 1, 0 });
    defer tree.deinit();

    try std.testing.expectEqual(@as(usize, 3), tree.len());
    try std.testing.expectEqual(@as(u64, 10), tree.totalWeight());
    try std.testing.expectEqual(@as(u64, 9), try tree.get(0));
    try std.testing.expectEqual(@as(u64, 1), try tree.get(1));
    try std.testing.expectEqual(@as(u64, 0), try tree.get(2));

    try tree.update(0, 0);
    try tree.update(1, 0);
    try std.testing.expectError(error.InvalidWeight, tree.sampleChecked(rng));

    try tree.update(2, 5);
    var i: usize = 0;
    while (i < 16) : (i += 1) try std.testing.expectEqual(@as(usize, 2), tree.sample(rng));

    try std.testing.expectError(error.InvalidParameter, tree.update(9, 1));
}

test "poisson large lambda has plausible moments" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(55);
    const rng = Rng.init(&engine);

    const lambda = 60.0;
    const samples = 20_000;
    var sum: f64 = 0;
    var sum_sq: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        const value: f64 = @floatFromInt(poisson(rng, lambda));
        sum += value;
        sum_sq += value * value;
    }

    const mean = sum / @as(f64, @floatFromInt(samples));
    const variance = sum_sq / @as(f64, @floatFromInt(samples)) - mean * mean;
    try std.testing.expect(mean > 59.0 and mean < 61.0);
    try std.testing.expect(variance > 56.0 and variance < 64.0);
}

test "non-uniform samplers can be reused with sample iterators" {
    const alea = @import("root.zig");
    var engine = alea.DefaultPrng.init(66);
    const rng = Rng.init(&engine);

    var normals = rng.sampleIter(f64, try Normal(f64).init(10, 2));
    try std.testing.expect(normals.next().? > 0);

    var exponentials = rng.sampleIter(f64, try Exponential(f64).init(2));
    try std.testing.expect(exponentials.next().? >= 0);

    var standard_normals = rng.sampleIter(f64, StandardNormal(f64){});
    try std.testing.expect(std.math.isFinite(standard_normals.next().?));

    var standard_exponentials = rng.sampleIter(f64, StandardExponential(f64){});
    try std.testing.expect(standard_exponentials.next().? >= 0);

    var log_normals = rng.sampleIter(f64, try LogNormal(f64).init(0, 0.25));
    try std.testing.expect(log_normals.next().? > 0);

    var poissons = rng.sampleIter(u64, try Poisson.init(12));
    try std.testing.expect(poissons.next().? < 64);

    var geometrics = rng.sampleIter(u64, try Geometric.init(0.25));
    try std.testing.expect(geometrics.next().? >= 1);

    var gammas = rng.sampleIter(f64, try Gamma(f64).init(2, 3));
    try std.testing.expect(gammas.next().? > 0);

    var chi_squared = rng.sampleIter(f64, try ChiSquared(f64).init(4));
    try std.testing.expect(chi_squared.next().? > 0);

    var betas = rng.sampleIter(f64, try Beta(f64).init(2, 5));
    const beta_value = betas.next().?;
    try std.testing.expect(beta_value >= 0 and beta_value <= 1);

    var fisher = rng.sampleIter(f64, try FisherF(f64).init(5, 20));
    try std.testing.expect(fisher.next().? > 0);

    var student = rng.sampleIter(f64, try StudentT(f64).init(10));
    _ = student.next().?;

    var triangulars = rng.sampleIter(f64, try Triangular(f64).init(-1, 0, 2));
    const triangular_value = triangulars.next().?;
    try std.testing.expect(triangular_value >= -1 and triangular_value <= 2);

    var cauchys = rng.sampleIter(f64, try Cauchy(f64).init(0, 1));
    _ = cauchys.next().?;

    var paretos = rng.sampleIter(f64, try Pareto(f64).init(2, 3));
    try std.testing.expect(paretos.next().? >= 2);

    var weibulls = rng.sampleIter(f64, try Weibull(f64).init(2, 1.5));
    try std.testing.expect(weibulls.next().? >= 0);

    var gumbels = rng.sampleIter(f64, try Gumbel(f64).init(0, 1));
    try std.testing.expect(std.math.isFinite(gumbels.next().?));

    var frechets = rng.sampleIter(f64, try Frechet(f64).init(0, 1, 2));
    try std.testing.expect(frechets.next().? >= 0);

    var skew_normals = rng.sampleIter(f64, try SkewNormal(f64).init(0, 1, 1));
    try std.testing.expect(std.math.isFinite(skew_normals.next().?));

    var perts = rng.sampleIter(f64, try Pert(f64).initDefault(-1, 0, 2));
    const pert_value = perts.next().?;
    try std.testing.expect(pert_value >= -1 and pert_value <= 2);

    var inverse_gaussians = rng.sampleIter(f64, try InverseGaussian(f64).init(1, 2));
    try std.testing.expect(inverse_gaussians.next().? > 0);

    var normal_inverse_gaussians = rng.sampleIter(f64, try NormalInverseGaussian(f64).init(2, 1));
    try std.testing.expect(std.math.isFinite(normal_inverse_gaussians.next().?));

    var zipfs = rng.sampleIter(f64, try Zipf(f64).init(10, 1.5));
    const zipf_value = zipfs.next().?;
    try std.testing.expect(zipf_value >= 1 and zipf_value <= 10);

    var zetas = rng.sampleIter(f64, try Zeta(f64).init(3));
    try std.testing.expect(zetas.next().? >= 1);

    var unit_circles = rng.sampleIter([2]f64, UnitCircle(f64){});
    const unit_circle = unit_circles.next().?;
    try std.testing.expectApproxEqAbs(@as(f64, 1), unit_circle[0] * unit_circle[0] + unit_circle[1] * unit_circle[1], 1e-12);

    var unit_spheres = rng.sampleIter([3]f64, UnitSphere(f64){});
    const unit_sphere = unit_spheres.next().?;
    try std.testing.expectApproxEqAbs(@as(f64, 1), unit_sphere[0] * unit_sphere[0] + unit_sphere[1] * unit_sphere[1] + unit_sphere[2] * unit_sphere[2], 1e-12);

    try std.testing.expectError(error.InvalidParameter, Normal(f64).init(0, -1));
    try std.testing.expectError(error.InvalidParameter, Exponential(f64).init(0));
    try std.testing.expectError(error.InvalidParameter, LogNormal(f64).init(0, -1));
    try std.testing.expectError(error.InvalidParameter, Poisson.init(std.math.inf(f64)));
    try std.testing.expectError(error.InvalidProbability, Geometric.init(0));
    try std.testing.expectError(error.InvalidParameter, Gamma(f64).init(0, 1));
    try std.testing.expectError(error.InvalidParameter, ChiSquared(f64).init(0));
    try std.testing.expectError(error.InvalidParameter, Beta(f64).init(1, 0));
    try std.testing.expectError(error.InvalidParameter, FisherF(f64).init(0, 1));
    try std.testing.expectError(error.InvalidParameter, StudentT(f64).init(0));
    try std.testing.expectError(error.InvalidParameter, Triangular(f64).init(1, 0, 2));
    try std.testing.expectError(error.InvalidParameter, Cauchy(f64).init(0, 0));
    try std.testing.expectError(error.InvalidParameter, Pareto(f64).init(1, 0));
    try std.testing.expectError(error.InvalidParameter, Weibull(f64).init(0, 1));
    try std.testing.expectError(error.InvalidParameter, Gumbel(f64).init(0, 0));
    try std.testing.expectError(error.InvalidParameter, Frechet(f64).init(0, 1, 0));
    try std.testing.expectError(error.InvalidParameter, SkewNormal(f64).init(0, 0, 1));
    try std.testing.expectError(error.InvalidParameter, Pert(f64).init(0, 2, 1, 4));
    try std.testing.expectError(error.InvalidParameter, InverseGaussian(f64).init(0, 1));
    try std.testing.expectError(error.InvalidParameter, NormalInverseGaussian(f64).init(1, 1));
    try std.testing.expectError(error.InvalidParameter, Zipf(f64).init(0, 1));
    try std.testing.expectError(error.InvalidParameter, Zipf(f64).init(std.math.inf(f64), 1));
    try std.testing.expectError(error.InvalidParameter, Zeta(f64).init(1));
}

test "binomial sampler has plausible moments" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(67);
    const rng = Rng.init(&engine);

    const trials: u64 = 40;
    const p = 0.25;
    const samples = 20_000;
    var sum: f64 = 0;
    var sum_sq: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        const value: f64 = @floatFromInt(binomial(rng, trials, p));
        sum += value;
        sum_sq += value * value;
    }

    const mean = sum / @as(f64, @floatFromInt(samples));
    const variance = sum_sq / @as(f64, @floatFromInt(samples)) - mean * mean;
    try std.testing.expect(mean > 9.8 and mean < 10.2);
    try std.testing.expect(variance > 7.1 and variance < 7.9);

    var iter = rng.sampleIter(u64, try Binomial.init(8, 0.5));
    try std.testing.expect(iter.next().? <= 8);
    try std.testing.expect(binomialPoissonApprox(rng, 10_000, 0.01) < 200);
    try std.testing.expectError(error.InvalidProbability, Binomial.init(1, 1.1));
}

test "multinomial sampler returns category counts" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(70);
    const rng = Rng.init(&engine);

    const dist = try Multinomial.init(100, &.{ 1.0, 2.0, 3.0 });
    const counts = try dist.sample(std.testing.allocator, rng);
    defer std.testing.allocator.free(counts);

    try std.testing.expectEqual(@as(usize, 3), counts.len);
    var total: u64 = 0;
    for (counts) |count| total += count;
    try std.testing.expectEqual(@as(u64, 100), total);

    var stack_counts: [3]u64 = undefined;
    dist.sampleInto(rng, &stack_counts);
    total = 0;
    for (stack_counts) |count| total += count;
    try std.testing.expectEqual(@as(u64, 100), total);

    try std.testing.expectError(error.EmptyRange, Multinomial.init(1, &.{}));
    try std.testing.expectError(error.InvalidProbability, Multinomial.init(1, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectError(error.InvalidProbability, Multinomial.init(1, &.{ 0.0, 0.0 }));
}

test "negative-binomial and hypergeometric samplers have plausible moments" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(71);
    const rng = Rng.init(&engine);

    const nb = try NegativeBinomial.init(5, 0.4);
    const hg = try Hypergeometric.init(100, 30, 10);
    const samples = 20_000;
    var nb_sum: f64 = 0;
    var hg_sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        nb_sum += @floatFromInt(nb.sample(rng));
        hg_sum += @floatFromInt(hg.sample(rng));
    }

    const n: f64 = @floatFromInt(samples);
    try std.testing.expect(nb_sum / n > 7.2 and nb_sum / n < 7.8);
    try std.testing.expect(hg_sum / n > 2.8 and hg_sum / n < 3.2);

    try std.testing.expectError(error.InvalidParameter, NegativeBinomial.init(0, 0.5));
    try std.testing.expectError(error.InvalidProbability, NegativeBinomial.init(1, 0));
    try std.testing.expectError(error.InvalidParameter, Hypergeometric.init(10, 11, 1));
    try std.testing.expectError(error.InvalidParameter, Hypergeometric.init(10, 1, 11));
}

test "large binomial sampler has plausible moments" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(69);
    const rng = Rng.init(&engine);

    const trials: u64 = 10_000;
    const p = 0.01;
    const samples = 12_000;
    var sum: f64 = 0;
    var sum_sq: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        const value: f64 = @floatFromInt(binomial(rng, trials, p));
        sum += value;
        sum_sq += value * value;
    }

    const mean = sum / @as(f64, @floatFromInt(samples));
    const variance = sum_sq / @as(f64, @floatFromInt(samples)) - mean * mean;
    try std.testing.expect(mean > 99.5 and mean < 100.5);
    try std.testing.expect(variance > 94.0 and variance < 104.0);
}

test "extreme-value and shape samplers have plausible means" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(72);
    const rng = Rng.init(&engine);

    const samples = 30_000;
    var gumbel_sum: f64 = 0;
    var frechet_sum: f64 = 0;
    var skew_sum: f64 = 0;
    var pert_sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        gumbel_sum += gumbel(rng, f64, 0, 1);
        frechet_sum += frechet(rng, f64, 0, 1, 3);
        skew_sum += skewNormal(rng, f64, 0, 1, 1);
        pert_sum += pert(rng, f64, -1, 0.5, 2, 4);
    }

    const n: f64 = @floatFromInt(samples);
    try std.testing.expect(gumbel_sum / n > 0.55 and gumbel_sum / n < 0.61);
    try std.testing.expect(frechet_sum / n > 1.30 and frechet_sum / n < 1.40);
    try std.testing.expect(skew_sum / n > 0.52 and skew_sum / n < 0.60);
    try std.testing.expect(pert_sum / n > 0.45 and pert_sum / n < 0.55);

    const by_mean = try Pert(f64).initMean(-1, 0.5, 2, 4);
    const by_mode = try Pert(f64).init(-1, 0.5, 2, 4);
    try std.testing.expectApproxEqAbs(by_mode.alpha, by_mean.alpha, 1e-12);
    try std.testing.expectApproxEqAbs(by_mode.beta_param, by_mean.beta_param, 1e-12);
}

test "inverse-gaussian and rank samplers have plausible behavior" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(74);
    const rng = Rng.init(&engine);

    const samples = 30_000;
    var inverse_sum: f64 = 0;
    var nig_sum: f64 = 0;
    var zipf_sum: f64 = 0;
    var zeta_sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        const inverse_value = inverseGaussian(rng, f64, 1, 2);
        try std.testing.expect(inverse_value > 0);
        inverse_sum += inverse_value;

        nig_sum += normalInverseGaussian(rng, f64, 2, 1);

        const zipf_value = zipf(rng, f64, 10, 1.5);
        try std.testing.expect(zipf_value >= 1 and zipf_value <= 10);
        zipf_sum += zipf_value;

        const zeta_value = zeta(rng, f64, 3);
        try std.testing.expect(zeta_value >= 1);
        zeta_sum += zeta_value;
    }

    const n: f64 = @floatFromInt(samples);
    try std.testing.expect(inverse_sum / n > 0.97 and inverse_sum / n < 1.03);
    try std.testing.expect(nig_sum / n > 0.53 and nig_sum / n < 0.62);
    try std.testing.expect(zipf_sum / n > 2.3 and zipf_sum / n < 2.7);
    try std.testing.expect(zeta_sum / n > 1.30 and zeta_sum / n < 1.45);

    const high_exponent = try Zipf(f64).init(10, std.math.inf(f64));
    try std.testing.expectEqual(@as(f64, 1), high_exponent.sample(rng));
}

test "unit geometric distributions stay on expected support" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(73);
    const rng = Rng.init(&engine);

    var i: usize = 0;
    while (i < 1000) : (i += 1) {
        const circle = unitCircle(rng, f64);
        try std.testing.expectApproxEqAbs(@as(f64, 1), circle[0] * circle[0] + circle[1] * circle[1], 1e-12);

        const disc = unitDisc(rng, f64);
        try std.testing.expect(disc[0] * disc[0] + disc[1] * disc[1] <= 1);

        const sphere = unitSphere(rng, f64);
        try std.testing.expectApproxEqAbs(@as(f64, 1), sphere[0] * sphere[0] + sphere[1] * sphere[1] + sphere[2] * sphere[2], 1e-12);

        const ball = unitBall(rng, f64);
        try std.testing.expect(ball[0] * ball[0] + ball[1] * ball[1] + ball[2] * ball[2] <= 1);
    }
}

test "dirichlet sampler returns simplex vectors" {
    const alea = @import("root.zig");
    var engine = alea.DefaultPrng.init(68);
    const rng = Rng.init(&engine);

    const dist = try Dirichlet(f64).init(&.{ 1.0, 2.0, 3.0 });
    const sample = try dist.sample(std.testing.allocator, rng);
    defer std.testing.allocator.free(sample);

    try std.testing.expectEqual(@as(usize, 3), sample.len);
    var total: f64 = 0;
    for (sample) |value| {
        try std.testing.expect(value >= 0 and value <= 1);
        total += value;
    }
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), total, 1e-12);

    try std.testing.expectError(error.EmptyRange, Dirichlet(f64).init(&.{}));
    try std.testing.expectError(error.InvalidParameter, Dirichlet(f64).init(&.{ 1.0, 0.0 }));

    var stack_sample: [3]f64 = undefined;
    dist.sampleInto(rng, &stack_sample);
    var stack_total: f64 = 0;
    for (stack_sample) |value| stack_total += value;
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), stack_total, 1e-12);
}
