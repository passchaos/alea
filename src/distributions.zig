const std = @import("std");
const Rng = @import("rng.zig");

pub const Error = error{
    EmptyRange,
    InvalidProbability,
    InvalidWeight,
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
    const scale = 2.0 * @as(f64, @floatFromInt(@as(u64, 1) << 63));

    p_int: u64,

    pub fn init(p: f64) Error!Bernoulli {
        if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
        if (p == 1) return .{ .p_int = always_true };
        return .{ .p_int = @intFromFloat(p * scale) };
    }

    pub fn initRatio(numerator: u32, denominator: u32) Error!Bernoulli {
        if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
        if (numerator == denominator) return .{ .p_int = always_true };
        return .{ .p_int = @intFromFloat((@as(f64, @floatFromInt(numerator)) / @as(f64, @floatFromInt(denominator))) * scale) };
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

pub fn normal(rng: Rng, comptime T: type, mean: T, stddev: T) T {
    comptime requireFloat(T);
    std.debug.assert(stddev >= 0);
    const open_uniform = rng.floatOpen(T);
    const angle_uniform = rng.float(T);
    const radius = @sqrt(-2 * @log(open_uniform));
    const theta = @as(T, @floatCast(std.math.tau)) * angle_uniform;
    return mean + stddev * radius * @cos(theta);
}

pub fn exponential(rng: Rng, comptime T: type, rate: T) T {
    comptime requireFloat(T);
    std.debug.assert(rate > 0);
    return -@log(rng.floatOpen(T)) / rate;
}

pub fn poisson(rng: Rng, lambda: f64) u64 {
    std.debug.assert(lambda >= 0);
    if (lambda == 0) return 0;

    if (lambda < 30) {
        const threshold = @exp(-lambda);
        var k: u64 = 0;
        var p: f64 = 1;
        while (p > threshold) {
            k += 1;
            p *= rng.floatOpen(f64);
        }
        return k - 1;
    }

    const sample = normal(rng, f64, lambda, @sqrt(lambda));
    return if (sample < 0) 0 else @intFromFloat(sample + 0.5);
}

pub fn geometric(rng: Rng, p: f64) u64 {
    std.debug.assert(p > 0 and p <= 1);
    if (p == 1) return 1;
    const failures: u64 = @intFromFloat(@floor(@log(1 - rng.floatOpen(f64)) / @log(1 - p)));
    return failures + 1;
}

pub fn gamma(rng: Rng, comptime T: type, shape: T, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(shape > 0 and scale > 0);

    if (shape < 1) {
        const boosted = gamma(rng, T, shape + 1, 1);
        return scale * boosted * std.math.pow(T, rng.floatOpen(T), 1 / shape);
    }

    const d = shape - @as(T, 1.0 / 3.0);
    const c = @as(T, 1.0) / @sqrt(9 * d);

    while (true) {
        const x = normal(rng, T, 0, 1);
        const v_base = 1 + c * x;
        if (v_base <= 0) continue;

        const v = v_base * v_base * v_base;
        const u = rng.float(T);
        if (u < 1 - 0.0331 * (x * x) * (x * x)) return scale * d * v;
        if (@log(u) < 0.5 * x * x + d * (1 - v + @log(v))) return scale * d * v;
    }
}

pub fn beta(rng: Rng, comptime T: type, alpha: T, beta_param: T) T {
    comptime requireFloat(T);
    const x = gamma(rng, T, alpha, 1);
    const y = gamma(rng, T, beta_param, 1);
    return x / (x + y);
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

        pub fn sample(self: Self, rng: Rng) usize {
            const column = rng.uintLessThan(usize, self.prob.len);
            return if (rng.float(f64) < self.prob[column]) column else self.alias[column];
        }
    };
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
}
