const std = @import("std");
const Rng = @import("rng.zig");
const Alea4x64 = @import("engines/alea4x64.zig");

pub const Error = error{
    EmptyRange,
    InvalidProbability,
    InvalidWeight,
    InvalidParameter,
    InvalidLength,
};

pub fn uniform(rng: Rng, comptime T: type, min: T, max: T) T {
    return uniformFrom(rng, T, min, max);
}

pub fn uniformFrom(source: anytype, comptime T: type, min: T, max: T) T {
    switch (@typeInfo(T)) {
        .int => return Rng.intRangeLessThanFrom(source, T, min, max),
        .float => {
            std.debug.assert(min <= max);
            return Rng.floatRangeFrom(source, T, min, max);
        },
        else => @compileError("uniform supports integer and floating-point types"),
    }
}

pub fn uniformChecked(rng: Rng, comptime T: type, min: T, max: T) Error!T {
    return uniformCheckedFrom(rng, T, min, max);
}

pub fn uniformCheckedFrom(source: anytype, comptime T: type, min: T, max: T) Error!T {
    switch (@typeInfo(T)) {
        .int => return Rng.intRangeLessThanCheckedFrom(source, T, min, max),
        .float => return Rng.floatRangeCheckedFrom(source, T, min, max),
        else => @compileError("uniformChecked supports integer and floating-point types"),
    }
}

pub fn fillUniform(rng: Rng, comptime T: type, dest: []T, min: T, max: T) void {
    fillUniformFrom(rng, T, dest, min, max);
}

pub fn fillUniformFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) void {
    switch (@typeInfo(T)) {
        .int, .float => Rng.fillRangeFrom(source, T, dest, min, max),
        else => @compileError("fillUniform supports integer and floating-point slices"),
    }
}

pub fn fillUniformChecked(rng: Rng, comptime T: type, dest: []T, min: T, max: T) Error!void {
    return fillUniformCheckedFrom(rng, T, dest, min, max);
}

pub fn fillUniformCheckedFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) Error!void {
    switch (@typeInfo(T)) {
        .int, .float => try Rng.fillRangeCheckedFrom(source, T, dest, min, max),
        else => @compileError("fillUniformChecked supports integer and floating-point slices"),
    }
}

pub fn uniformInclusive(rng: Rng, comptime T: type, min: T, max: T) T {
    return uniformInclusiveFrom(rng, T, min, max);
}

pub fn uniformInclusiveFrom(source: anytype, comptime T: type, min: T, max: T) T {
    switch (@typeInfo(T)) {
        .int => return Rng.intRangeAtMostFrom(source, T, min, max),
        .float => {
            std.debug.assert(min <= max);
            return min + (max - min) * uniformClosedUnitFrom(source, T);
        },
        else => @compileError("uniformInclusive supports integer and floating-point types"),
    }
}

pub fn uniformInclusiveChecked(rng: Rng, comptime T: type, min: T, max: T) Error!T {
    return uniformInclusiveCheckedFrom(rng, T, min, max);
}

pub fn uniformInclusiveCheckedFrom(source: anytype, comptime T: type, min: T, max: T) Error!T {
    switch (@typeInfo(T)) {
        .int => return Rng.intRangeAtMostCheckedFrom(source, T, min, max),
        .float => {
            if (!(min <= max) or !std.math.isFinite(min) or !std.math.isFinite(max)) return error.EmptyRange;
            return uniformInclusiveFrom(source, T, min, max);
        },
        else => @compileError("uniformInclusiveChecked supports integer and floating-point types"),
    }
}

pub fn fillUniformInclusive(rng: Rng, comptime T: type, dest: []T, min: T, max: T) void {
    fillUniformInclusiveFrom(rng, T, dest, min, max);
}

pub fn fillUniformInclusiveFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) void {
    switch (@typeInfo(T)) {
        .int => {
            for (dest) |*item| item.* = Rng.intRangeAtMostFrom(source, T, min, max);
        },
        .float => {
            std.debug.assert(min <= max and std.math.isFinite(min) and std.math.isFinite(max));
            const width = max - min;
            for (dest) |*item| item.* = min + width * uniformClosedUnitFrom(source, T);
        },
        else => @compileError("fillUniformInclusive supports integer and floating-point slices"),
    }
}

pub fn fillUniformInclusiveChecked(rng: Rng, comptime T: type, dest: []T, min: T, max: T) Error!void {
    return fillUniformInclusiveCheckedFrom(rng, T, dest, min, max);
}

pub fn fillUniformInclusiveCheckedFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) Error!void {
    if (dest.len == 0) return;
    switch (@typeInfo(T)) {
        .int => {
            if (min > max) return error.EmptyRange;
            fillUniformInclusiveFrom(source, T, dest, min, max);
        },
        .float => {
            if (!(min <= max) or !std.math.isFinite(min) or !std.math.isFinite(max)) return error.EmptyRange;
            fillUniformInclusiveFrom(source, T, dest, min, max);
        },
        else => @compileError("fillUniformInclusiveChecked supports integer and floating-point slices"),
    }
}

pub fn vectorUniform(rng: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    return vectorUniformFrom(rng, VectorType, min, max);
}

pub fn vectorUniformFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    return Rng.vectorRangeFrom(source, VectorType, min, max);
}

pub fn vectorUniformChecked(rng: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    return vectorUniformCheckedFrom(rng, VectorType, min, max);
}

pub fn vectorUniformCheckedFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    return Rng.vectorRangeCheckedFrom(source, VectorType, min, max);
}

pub fn fillVectorUniform(rng: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    fillVectorUniformFrom(rng, VectorType, dest, min, max);
}

pub fn fillVectorUniformFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    Rng.fillVectorRangeFrom(source, VectorType, dest, min, max);
}

pub fn fillVectorUniformChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    return fillVectorUniformCheckedFrom(rng, VectorType, dest, min, max);
}

pub fn fillVectorUniformCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    return Rng.fillVectorRangeCheckedFrom(source, VectorType, dest, min, max);
}

pub fn vectorUniformInclusive(rng: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    return vectorUniformInclusiveFrom(rng, VectorType, min, max);
}

pub fn vectorUniformInclusiveFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    const info = vectorInfo(VectorType);
    switch (@typeInfo(info.child)) {
        .int => {
            std.debug.assert(min <= max);
            var out: VectorType = undefined;
            inline for (0..info.len) |lane| out[lane] = Rng.intRangeAtMostFrom(source, info.child, min, max);
            return out;
        },
        .float => {
            std.debug.assert(min <= max and std.math.isFinite(min) and std.math.isFinite(max));
            return @as(VectorType, @splat(min)) +
                (@as(VectorType, @splat(max)) - @as(VectorType, @splat(min))) *
                    vectorClosedUnitFrom(source, VectorType);
        },
        else => @compileError("vectorUniformInclusive supports integer and floating-point vectors"),
    }
}

pub fn vectorUniformInclusiveChecked(rng: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    return vectorUniformInclusiveCheckedFrom(rng, VectorType, min, max);
}

pub fn vectorUniformInclusiveCheckedFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    try validateVectorInclusiveRange(VectorType, min, max);
    return vectorUniformInclusiveFrom(source, VectorType, min, max);
}

pub fn fillVectorUniformInclusive(rng: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    fillVectorUniformInclusiveFrom(rng, VectorType, dest, min, max);
}

pub fn fillVectorUniformInclusiveFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    _ = vectorInfo(VectorType);
    for (dest) |*item| item.* = vectorUniformInclusiveFrom(source, VectorType, min, max);
}

pub fn fillVectorUniformInclusiveChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    return fillVectorUniformInclusiveCheckedFrom(rng, VectorType, dest, min, max);
}

pub fn fillVectorUniformInclusiveCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    try validateVectorInclusiveRange(VectorType, min, max);
    fillVectorUniformInclusiveFrom(source, VectorType, dest, min, max);
}

fn validateVectorInclusiveRange(comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    const info = vectorInfo(VectorType);
    switch (@typeInfo(info.child)) {
        .int => {
            if (min > max) return error.EmptyRange;
        },
        .float => {
            if (!(min <= max) or !std.math.isFinite(min) or !std.math.isFinite(max)) return error.EmptyRange;
        },
        else => @compileError("vectorUniformInclusiveChecked supports integer and floating-point vectors"),
    }
}

fn uniformClosedUnitFrom(source: anytype, comptime T: type) T {
    comptime requireFloat(T);
    return switch (T) {
        f32 => @as(f32, @floatFromInt(@as(u24, @truncate(Rng.nextFrom(source) >> 40)))) *
            (1.0 / 16777215.0),
        f64 => @as(f64, @floatFromInt(Rng.nextFrom(source) >> 11)) *
            (1.0 / 9007199254740991.0),
        else => @compileError("alea supports f32 and f64 floats"),
    };
}

fn vectorClosedUnitFrom(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    var out: VectorType = undefined;
    inline for (0..info.len) |lane| out[lane] = uniformClosedUnitFrom(source, info.child);
    return out;
}

pub fn bernoulli(rng: Rng, p: f64) bool {
    const dist = Bernoulli.init(p) catch unreachable;
    return dist.sampleFrom(rng);
}

pub fn bernoulliFrom(source: anytype, p: f64) bool {
    const dist = Bernoulli.init(p) catch unreachable;
    return dist.sampleFrom(source);
}

pub fn bernoulliChecked(rng: Rng, p: f64) Error!bool {
    return bernoulliCheckedFrom(rng, p);
}

pub fn bernoulliCheckedFrom(source: anytype, p: f64) Error!bool {
    const dist = try Bernoulli.init(p);
    return dist.sampleFrom(source);
}

pub fn fillBernoulli(rng: Rng, dest: []bool, p: f64) void {
    fillBernoulliFrom(rng, dest, p);
}

pub fn fillBernoulliFrom(source: anytype, dest: []bool, p: f64) void {
    const dist = Bernoulli.init(p) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillBernoulliChecked(rng: Rng, dest: []bool, p: f64) Error!void {
    return fillBernoulliCheckedFrom(rng, dest, p);
}

pub fn fillBernoulliCheckedFrom(source: anytype, dest: []bool, p: f64) Error!void {
    if (dest.len == 0) return;
    const dist = try Bernoulli.init(p);
    dist.fillFrom(source, dest);
}

pub fn vectorBernoulli(rng: Rng, comptime VectorType: type, p: f64) VectorType {
    return vectorBernoulliFrom(rng, VectorType, p);
}

pub fn vectorBernoulliFrom(source: anytype, comptime VectorType: type, p: f64) VectorType {
    const dist = VectorBernoulli(VectorType).init(p) catch unreachable;
    return dist.sampleFrom(source);
}

pub fn vectorBernoulliChecked(rng: Rng, comptime VectorType: type, p: f64) Error!VectorType {
    return vectorBernoulliCheckedFrom(rng, VectorType, p);
}

pub fn vectorBernoulliCheckedFrom(source: anytype, comptime VectorType: type, p: f64) Error!VectorType {
    const dist = try VectorBernoulli(VectorType).init(p);
    return dist.sampleFrom(source);
}

pub fn fillVectorBernoulli(rng: Rng, comptime VectorType: type, dest: []VectorType, p: f64) void {
    fillVectorBernoulliFrom(rng, VectorType, dest, p);
}

pub fn fillVectorBernoulliFrom(source: anytype, comptime VectorType: type, dest: []VectorType, p: f64) void {
    const dist = VectorBernoulli(VectorType).init(p) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillVectorBernoulliChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, p: f64) Error!void {
    return fillVectorBernoulliCheckedFrom(rng, VectorType, dest, p);
}

pub fn fillVectorBernoulliCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, p: f64) Error!void {
    if (dest.len == 0) return;
    const dist = try VectorBernoulli(VectorType).init(p);
    dist.fillFrom(source, dest);
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

    pub fn probabilityValue(self: Bernoulli) f64 {
        return self.probability();
    }

    pub fn expectedValue(self: Bernoulli) f64 {
        return self.probability();
    }

    pub fn varianceValue(self: Bernoulli) f64 {
        const p = self.probability();
        return p * (1 - p);
    }

    pub fn modeValue(self: Bernoulli) ?bool {
        const p = self.probability();
        if (p == 0.5) return null;
        return p > 0.5;
    }

    pub fn minValue(self: Bernoulli) bool {
        _ = self;
        return false;
    }

    pub fn maxValue(self: Bernoulli) bool {
        _ = self;
        return true;
    }

    pub fn sample(self: Bernoulli, rng: Rng) bool {
        return self.sampleFrom(rng);
    }

    pub fn sampleFrom(self: Bernoulli, source: anytype) bool {
        if (self.p_int == always_true) return true;
        return Rng.nextFrom(source) < self.p_int;
    }

    pub fn fill(self: Bernoulli, rng: Rng, dest: []bool) void {
        self.fillFrom(rng, dest);
    }

    pub fn fillFrom(self: Bernoulli, source: anytype, dest: []bool) void {
        if (self.p_int == 0) {
            @memset(dest, false);
            return;
        }
        if (self.p_int == always_true) {
            @memset(dest, true);
            return;
        }
        if (self.p_int == Rng.probabilityThreshold(0.5)) {
            Rng.fillChanceFrom(source, dest, 0.5);
            return;
        }
        if (self.p_int == Rng.probabilityThreshold(0.25)) {
            Rng.fillChanceFrom(source, dest, 0.25);
            return;
        }
        for (dest) |*item| item.* = Rng.nextFrom(source) < self.p_int;
    }
};

pub fn VectorBernoulli(comptime VectorType: type) type {
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("VectorBernoulli expects a bool vector");

    return struct {
        const Self = @This();
        const always_true = Bernoulli.always_true;
        const scale = Bernoulli.scale;

        p_int: u64,

        pub fn init(p: f64) Error!Self {
            if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
            if (p == 1) return .{ .p_int = always_true };
            return .{ .p_int = Rng.probabilityThreshold(p) };
        }

        pub fn initRatio(numerator: u32, denominator: u32) Error!Self {
            if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
            if (numerator == denominator) return .{ .p_int = always_true };
            const p = @as(f64, @floatFromInt(numerator)) / @as(f64, @floatFromInt(denominator));
            return .{ .p_int = Rng.probabilityThreshold(p) };
        }

        pub fn probability(self: Self) f64 {
            if (self.p_int == always_true) return 1;
            return @as(f64, @floatFromInt(self.p_int)) / scale;
        }

        pub fn probabilityValue(self: Self) f64 {
            return self.probability();
        }

        pub fn expectedValue(self: Self) f64 {
            return self.probability();
        }

        pub fn varianceValue(self: Self) f64 {
            const p = self.probability();
            return p * (1 - p);
        }

        pub fn modeValue(self: Self) ?bool {
            const p = self.probability();
            if (p == 0.5) return null;
            return p > 0.5;
        }

        pub fn minValue(self: Self) bool {
            _ = self;
            return false;
        }

        pub fn maxValue(self: Self) bool {
            _ = self;
            return true;
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            if (self.p_int == 0) return @splat(false);
            if (self.p_int == always_true) return @splat(true);
            if (self.p_int == Rng.probabilityThreshold(0.5)) return Rng.vectorChanceFrom(source, VectorType, 0.5);
            if (self.p_int == Rng.probabilityThreshold(0.25)) return Rng.vectorChanceFrom(source, VectorType, 0.25);

            var out: VectorType = undefined;
            inline for (0..info.len) |lane| out[lane] = Rng.nextFrom(source) < self.p_int;
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            if (self.p_int == 0) {
                @memset(dest, @as(VectorType, @splat(false)));
                return;
            }
            if (self.p_int == always_true) {
                @memset(dest, @as(VectorType, @splat(true)));
                return;
            }
            if (self.p_int == Rng.probabilityThreshold(0.5)) {
                Rng.fillVectorChanceFrom(source, VectorType, dest, 0.5);
                return;
            }
            if (self.p_int == Rng.probabilityThreshold(0.25)) {
                Rng.fillVectorChanceFrom(source, VectorType, dest, 0.25);
                return;
            }
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub const Binomial = struct {
    trials: u64,
    p: f64,

    pub fn init(trials: u64, p: f64) Error!Binomial {
        if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
        return .{ .trials = trials, .p = p };
    }

    pub fn trialsValue(self: Binomial) u64 {
        return self.trials;
    }

    pub fn probabilityValue(self: Binomial) f64 {
        return self.p;
    }

    pub fn expectedValue(self: Binomial) f64 {
        return @as(f64, @floatFromInt(self.trials)) * self.p;
    }

    pub fn varianceValue(self: Binomial) f64 {
        return @as(f64, @floatFromInt(self.trials)) * self.p * (1 - self.p);
    }

    pub fn minValue(self: Binomial) u64 {
        _ = self;
        return 0;
    }

    pub fn maxValue(self: Binomial) u64 {
        return self.trials;
    }

    pub fn sample(self: Binomial, rng: Rng) u64 {
        return self.sampleFrom(rng);
    }

    pub fn sampleFrom(self: Binomial, source: anytype) u64 {
        return binomialFrom(source, self.trials, self.p);
    }

    pub fn fill(self: Binomial, rng: Rng, dest: []u64) void {
        self.fillFrom(rng, dest);
    }

    pub fn fillFrom(self: Binomial, source: anytype, dest: []u64) void {
        for (dest) |*item| item.* = self.sampleFrom(source);
    }
};

pub fn binomial(rng: Rng, trials: u64, p: f64) u64 {
    return binomialFrom(rng, trials, p);
}

pub fn binomialChecked(rng: Rng, trials: u64, p: f64) Error!u64 {
    return binomialCheckedFrom(rng, trials, p);
}

pub fn binomialCheckedFrom(source: anytype, trials: u64, p: f64) Error!u64 {
    const dist = try Binomial.init(trials, p);
    return dist.sampleFrom(source);
}

pub fn fillBinomial(rng: Rng, dest: []u64, trials: u64, p: f64) void {
    fillBinomialFrom(rng, dest, trials, p);
}

pub fn fillBinomialFrom(source: anytype, dest: []u64, trials: u64, p: f64) void {
    const dist = Binomial.init(trials, p) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillBinomialChecked(rng: Rng, dest: []u64, trials: u64, p: f64) Error!void {
    return fillBinomialCheckedFrom(rng, dest, trials, p);
}

pub fn fillBinomialCheckedFrom(source: anytype, dest: []u64, trials: u64, p: f64) Error!void {
    if (dest.len == 0) return;
    const dist = try Binomial.init(trials, p);
    dist.fillFrom(source, dest);
}

pub fn vectorBinomial(rng: Rng, comptime VectorType: type, trials: u64, p: f64) VectorType {
    return vectorBinomialFrom(rng, VectorType, trials, p);
}

pub fn vectorBinomialFrom(source: anytype, comptime VectorType: type, trials: u64, p: f64) VectorType {
    const dist = VectorBinomial(VectorType).init(trials, p) catch unreachable;
    return dist.sampleFrom(source);
}

pub fn vectorBinomialChecked(rng: Rng, comptime VectorType: type, trials: u64, p: f64) Error!VectorType {
    return vectorBinomialCheckedFrom(rng, VectorType, trials, p);
}

pub fn vectorBinomialCheckedFrom(source: anytype, comptime VectorType: type, trials: u64, p: f64) Error!VectorType {
    const dist = try VectorBinomial(VectorType).init(trials, p);
    return dist.sampleFrom(source);
}

pub fn fillVectorBinomial(rng: Rng, comptime VectorType: type, dest: []VectorType, trials: u64, p: f64) void {
    fillVectorBinomialFrom(rng, VectorType, dest, trials, p);
}

pub fn fillVectorBinomialFrom(source: anytype, comptime VectorType: type, dest: []VectorType, trials: u64, p: f64) void {
    const dist = VectorBinomial(VectorType).init(trials, p) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillVectorBinomialChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, trials: u64, p: f64) Error!void {
    return fillVectorBinomialCheckedFrom(rng, VectorType, dest, trials, p);
}

pub fn fillVectorBinomialCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, trials: u64, p: f64) Error!void {
    if (dest.len == 0) return;
    const dist = try VectorBinomial(VectorType).init(trials, p);
    dist.fillFrom(source, dest);
}

pub fn VectorBinomial(comptime VectorType: type) type {
    const info = vectorInfo(VectorType);
    if (info.child != u64) @compileError("VectorBinomial expects a u64 vector");

    return struct {
        const Self = @This();

        sampler: Binomial,

        pub fn init(trials: u64, p: f64) Error!Self {
            return .{ .sampler = try Binomial.init(trials, p) };
        }

        pub fn trialsValue(self: Self) u64 {
            return self.sampler.trialsValue();
        }

        pub fn probabilityValue(self: Self) f64 {
            return self.sampler.probabilityValue();
        }

        pub fn expectedValue(self: Self) f64 {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) f64 {
            return self.sampler.varianceValue();
        }

        pub fn minValue(self: Self) u64 {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) u64 {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..info.len) |lane| out[lane] = self.sampler.sampleFrom(source);
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            if (self.sampler.trials == 0 or self.sampler.p == 0) {
                @memset(dest, @as(VectorType, @splat(0)));
                return;
            }
            if (self.sampler.p == 1) {
                @memset(dest, @as(VectorType, @splat(self.sampler.trials)));
                return;
            }
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn binomialFrom(source: anytype, trials: u64, p: f64) u64 {
    std.debug.assert(p >= 0 and p <= 1);
    if (trials == 0 or p == 0) return 0;
    if (p == 1) return trials;
    if (p == 0.5) return binomialFairFrom(source, trials);

    const q = if (p <= 0.5) p else 1.0 - p;
    const sampled = binomialSmallPFrom(source, trials, q);
    return if (p <= 0.5) sampled else trials - sampled;
}

pub fn binomialPoissonApprox(rng: Rng, trials: u64, p: f64) u64 {
    return binomialPoissonApproxFrom(rng, trials, p);
}

pub fn binomialPoissonApproxFrom(source: anytype, trials: u64, p: f64) u64 {
    std.debug.assert(p >= 0 and p <= 1);
    if (trials == 0 or p == 0) return 0;
    if (p == 1) return trials;

    const q = if (p <= 0.5) p else 1.0 - p;
    const mean = @as(f64, @floatFromInt(trials)) * q;
    const sampled = @min(poissonFrom(source, mean), trials);
    return if (p <= 0.5) sampled else trials - sampled;
}

pub fn binomialPoissonApproxChecked(rng: Rng, trials: u64, p: f64) Error!u64 {
    return binomialPoissonApproxCheckedFrom(rng, trials, p);
}

pub fn binomialPoissonApproxCheckedFrom(source: anytype, trials: u64, p: f64) Error!u64 {
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    return binomialPoissonApproxFrom(source, trials, p);
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

    pub fn trialsValue(self: Multinomial) u64 {
        return self.trials;
    }

    pub fn probabilitiesValue(self: Multinomial) []const f64 {
        return self.probabilities;
    }

    pub fn probabilityAt(self: Multinomial, index: usize) Error!f64 {
        if (index >= self.probabilities.len) return error.InvalidParameter;
        return self.probabilities[index];
    }

    pub fn normalizedProbabilityAt(self: Multinomial, index: usize) Error!f64 {
        return try self.probabilityAt(index) / self.total_probability;
    }

    pub fn normalizedProbabilities(self: Multinomial, allocator: std.mem.Allocator) ![]f64 {
        const out = try allocator.alloc(f64, self.probabilities.len);
        errdefer allocator.free(out);
        try self.normalizedProbabilitiesInto(out);
        return out;
    }

    pub fn normalizedProbabilitiesInto(self: Multinomial, out: []f64) Error!void {
        if (out.len != self.probabilities.len) return error.InvalidLength;
        for (self.probabilities, out) |probability, *slot| slot.* = probability / self.total_probability;
    }

    pub fn expectedCountAt(self: Multinomial, index: usize) Error!f64 {
        const p = try self.normalizedProbabilityAt(index);
        return @as(f64, @floatFromInt(self.trials)) * p;
    }

    pub fn expectedCounts(self: Multinomial, allocator: std.mem.Allocator) ![]f64 {
        const out = try allocator.alloc(f64, self.probabilities.len);
        errdefer allocator.free(out);
        try self.expectedCountsInto(out);
        return out;
    }

    pub fn expectedCountsInto(self: Multinomial, out: []f64) Error!void {
        if (out.len != self.probabilities.len) return error.InvalidLength;
        const trials_float = @as(f64, @floatFromInt(self.trials));
        for (self.probabilities, out) |probability, *slot| {
            slot.* = trials_float * probability / self.total_probability;
        }
    }

    pub fn varianceAt(self: Multinomial, index: usize) Error!f64 {
        const p = try self.normalizedProbabilityAt(index);
        return @as(f64, @floatFromInt(self.trials)) * p * (1 - p);
    }

    pub fn variances(self: Multinomial, allocator: std.mem.Allocator) ![]f64 {
        const out = try allocator.alloc(f64, self.probabilities.len);
        errdefer allocator.free(out);
        try self.variancesInto(out);
        return out;
    }

    pub fn variancesInto(self: Multinomial, out: []f64) Error!void {
        if (out.len != self.probabilities.len) return error.InvalidLength;
        const trials_float = @as(f64, @floatFromInt(self.trials));
        for (self.probabilities, out) |probability, *slot| {
            const p = probability / self.total_probability;
            slot.* = trials_float * p * (1 - p);
        }
    }

    pub fn covarianceAt(self: Multinomial, i: usize, j: usize) Error!f64 {
        if (i == j) return self.varianceAt(i);
        const p_i = try self.normalizedProbabilityAt(i);
        const p_j = try self.normalizedProbabilityAt(j);
        return -@as(f64, @floatFromInt(self.trials)) * p_i * p_j;
    }

    pub fn covariances(self: Multinomial, allocator: std.mem.Allocator) ![]f64 {
        const count = std.math.mul(usize, self.probabilities.len, self.probabilities.len) catch return error.OutOfMemory;
        const out = try allocator.alloc(f64, count);
        errdefer allocator.free(out);
        try self.covariancesInto(out);
        return out;
    }

    pub fn covariancesInto(self: Multinomial, out: []f64) Error!void {
        const count = std.math.mul(usize, self.probabilities.len, self.probabilities.len) catch return error.InvalidLength;
        if (out.len != count) return error.InvalidLength;
        const trials_float = @as(f64, @floatFromInt(self.trials));
        var row: usize = 0;
        while (row < self.probabilities.len) : (row += 1) {
            const p_i = self.probabilities[row] / self.total_probability;
            var col: usize = 0;
            while (col < self.probabilities.len) : (col += 1) {
                const p_j = self.probabilities[col] / self.total_probability;
                out[row * self.probabilities.len + col] = if (row == col)
                    trials_float * p_i * (1 - p_i)
                else
                    -trials_float * p_i * p_j;
            }
        }
    }

    pub fn categoryCountValue(self: Multinomial) usize {
        return self.probabilities.len;
    }

    pub fn totalProbabilityValue(self: Multinomial) f64 {
        return self.total_probability;
    }

    pub fn sample(self: Multinomial, allocator: std.mem.Allocator, rng: Rng) ![]u64 {
        return self.sampleFrom(allocator, rng);
    }

    pub fn sampleFrom(self: Multinomial, allocator: std.mem.Allocator, source: anytype) ![]u64 {
        const out = try allocator.alloc(u64, self.probabilities.len);
        errdefer allocator.free(out);
        self.sampleIntoFrom(source, out);
        return out;
    }

    pub fn sampleInto(self: Multinomial, rng: Rng, out: []u64) void {
        self.sampleIntoFrom(rng, out);
    }

    pub fn sampleIntoChecked(self: Multinomial, rng: Rng, out: []u64) Error!void {
        try self.sampleIntoCheckedFrom(rng, out);
    }

    pub fn sampleIntoCheckedFrom(self: Multinomial, source: anytype, out: []u64) Error!void {
        if (out.len != self.probabilities.len) return error.InvalidLength;
        self.sampleIntoFrom(source, out);
    }

    pub fn sampleManyInto(self: Multinomial, rng: Rng, out: []u64) void {
        self.sampleManyIntoFrom(rng, out);
    }

    pub fn sampleManyIntoChecked(self: Multinomial, rng: Rng, out: []u64) Error!void {
        try self.sampleManyIntoCheckedFrom(rng, out);
    }

    pub fn sampleManyIntoCheckedFrom(self: Multinomial, source: anytype, out: []u64) Error!void {
        if (out.len % self.probabilities.len != 0) return error.InvalidLength;
        self.sampleManyIntoFrom(source, out);
    }

    pub fn sampleManyIntoFrom(self: Multinomial, source: anytype, out: []u64) void {
        std.debug.assert(out.len % self.probabilities.len == 0);
        var offset: usize = 0;
        while (offset < out.len) : (offset += self.probabilities.len) {
            self.sampleIntoFrom(source, out[offset..][0..self.probabilities.len]);
        }
    }

    pub fn sampleIntoFrom(self: Multinomial, source: anytype, out: []u64) void {
        std.debug.assert(out.len == self.probabilities.len);
        @memset(out, 0);

        var remaining_trials = self.trials;
        var remaining_probability = self.total_probability;
        for (self.probabilities[0 .. self.probabilities.len - 1], out[0 .. out.len - 1]) |p, *slot| {
            if (remaining_trials == 0) return;
            if (p == 0) continue;
            const normalized = p / remaining_probability;
            const count = binomialFrom(source, remaining_trials, normalized);
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

    pub fn successesValue(self: NegativeBinomial) u64 {
        return self.successes;
    }

    pub fn probabilityValue(self: NegativeBinomial) f64 {
        return self.p;
    }

    pub fn expectedValue(self: NegativeBinomial) f64 {
        return @as(f64, @floatFromInt(self.successes)) * (1 - self.p) / self.p;
    }

    pub fn varianceValue(self: NegativeBinomial) f64 {
        return @as(f64, @floatFromInt(self.successes)) * (1 - self.p) / (self.p * self.p);
    }

    pub fn minValue(self: NegativeBinomial) u64 {
        _ = self;
        return 0;
    }

    pub fn maxValue(self: NegativeBinomial) ?u64 {
        _ = self;
        return null;
    }

    pub fn sample(self: NegativeBinomial, rng: Rng) u64 {
        return self.sampleFrom(rng);
    }

    pub fn sampleFrom(self: NegativeBinomial, source: anytype) u64 {
        return negativeBinomialFrom(source, self.successes, self.p);
    }

    pub fn fill(self: NegativeBinomial, rng: Rng, dest: []u64) void {
        self.fillFrom(rng, dest);
    }

    pub fn fillFrom(self: NegativeBinomial, source: anytype, dest: []u64) void {
        for (dest) |*item| item.* = self.sampleFrom(source);
    }
};

pub fn negativeBinomial(rng: Rng, successes: u64, p: f64) u64 {
    return negativeBinomialFrom(rng, successes, p);
}

pub fn negativeBinomialChecked(rng: Rng, successes: u64, p: f64) Error!u64 {
    return negativeBinomialCheckedFrom(rng, successes, p);
}

pub fn negativeBinomialCheckedFrom(source: anytype, successes: u64, p: f64) Error!u64 {
    const dist = try NegativeBinomial.init(successes, p);
    return dist.sampleFrom(source);
}

pub fn fillNegativeBinomial(rng: Rng, dest: []u64, successes: u64, p: f64) void {
    fillNegativeBinomialFrom(rng, dest, successes, p);
}

pub fn fillNegativeBinomialFrom(source: anytype, dest: []u64, successes: u64, p: f64) void {
    const dist = NegativeBinomial.init(successes, p) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillNegativeBinomialChecked(rng: Rng, dest: []u64, successes: u64, p: f64) Error!void {
    return fillNegativeBinomialCheckedFrom(rng, dest, successes, p);
}

pub fn fillNegativeBinomialCheckedFrom(source: anytype, dest: []u64, successes: u64, p: f64) Error!void {
    if (dest.len == 0) return;
    const dist = try NegativeBinomial.init(successes, p);
    dist.fillFrom(source, dest);
}

pub fn vectorNegativeBinomial(rng: Rng, comptime VectorType: type, successes: u64, p: f64) VectorType {
    return vectorNegativeBinomialFrom(rng, VectorType, successes, p);
}

pub fn vectorNegativeBinomialFrom(source: anytype, comptime VectorType: type, successes: u64, p: f64) VectorType {
    const dist = VectorNegativeBinomial(VectorType).init(successes, p) catch unreachable;
    return dist.sampleFrom(source);
}

pub fn vectorNegativeBinomialChecked(rng: Rng, comptime VectorType: type, successes: u64, p: f64) Error!VectorType {
    return vectorNegativeBinomialCheckedFrom(rng, VectorType, successes, p);
}

pub fn vectorNegativeBinomialCheckedFrom(source: anytype, comptime VectorType: type, successes: u64, p: f64) Error!VectorType {
    const dist = try VectorNegativeBinomial(VectorType).init(successes, p);
    return dist.sampleFrom(source);
}

pub fn fillVectorNegativeBinomial(rng: Rng, comptime VectorType: type, dest: []VectorType, successes: u64, p: f64) void {
    fillVectorNegativeBinomialFrom(rng, VectorType, dest, successes, p);
}

pub fn fillVectorNegativeBinomialFrom(source: anytype, comptime VectorType: type, dest: []VectorType, successes: u64, p: f64) void {
    const dist = VectorNegativeBinomial(VectorType).init(successes, p) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillVectorNegativeBinomialChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, successes: u64, p: f64) Error!void {
    return fillVectorNegativeBinomialCheckedFrom(rng, VectorType, dest, successes, p);
}

pub fn fillVectorNegativeBinomialCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, successes: u64, p: f64) Error!void {
    if (dest.len == 0) return;
    const dist = try VectorNegativeBinomial(VectorType).init(successes, p);
    dist.fillFrom(source, dest);
}

pub fn VectorNegativeBinomial(comptime VectorType: type) type {
    const info = vectorInfo(VectorType);
    if (info.child != u64) @compileError("VectorNegativeBinomial expects a u64 vector");

    return struct {
        const Self = @This();

        sampler: NegativeBinomial,

        pub fn init(successes: u64, p: f64) Error!Self {
            return .{ .sampler = try NegativeBinomial.init(successes, p) };
        }

        pub fn successesValue(self: Self) u64 {
            return self.sampler.successesValue();
        }

        pub fn probabilityValue(self: Self) f64 {
            return self.sampler.probabilityValue();
        }

        pub fn expectedValue(self: Self) f64 {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) f64 {
            return self.sampler.varianceValue();
        }

        pub fn minValue(self: Self) u64 {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) ?u64 {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..info.len) |lane| out[lane] = self.sampler.sampleFrom(source);
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            if (self.sampler.p == 1) {
                @memset(dest, @as(VectorType, @splat(0)));
                return;
            }
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn negativeBinomialFrom(source: anytype, successes: u64, p: f64) u64 {
    std.debug.assert(successes > 0 and p > 0 and p <= 1);
    if (p == 1) return 0;

    var failures: u64 = 0;
    var i: u64 = 0;
    while (i < successes) : (i += 1) {
        failures += geometricFrom(source, p) - 1;
    }
    return failures;
}

pub const Hypergeometric = struct {
    population: u64,
    successes: u64,
    draws: u64,
    method: HypergeometricMethodTag,
    inverse_transform: HypergeometricInverseTransform = undefined,
    rejection_acceptance: HypergeometricRejectionAcceptance = undefined,

    pub fn init(population: u64, successes: u64, draws: u64) Error!Hypergeometric {
        if (successes > population or draws > population) return error.InvalidParameter;
        var self: Hypergeometric = .{
            .population = population,
            .successes = successes,
            .draws = draws,
            .method = .draw_loop,
        };
        if (HypergeometricInverseTransform.init(population, successes, draws)) |method| {
            self.method = .inverse_transform;
            self.inverse_transform = method;
        } else if (HypergeometricRejectionAcceptance.init(population, successes, draws)) |method| {
            self.method = .rejection_acceptance;
            self.rejection_acceptance = method;
        }
        return self;
    }

    pub fn populationValue(self: Hypergeometric) u64 {
        return self.population;
    }

    pub fn successesValue(self: Hypergeometric) u64 {
        return self.successes;
    }

    pub fn drawsValue(self: Hypergeometric) u64 {
        return self.draws;
    }

    pub fn expectedValue(self: Hypergeometric) f64 {
        if (self.population == 0) return 0;
        return @as(f64, @floatFromInt(self.draws)) *
            @as(f64, @floatFromInt(self.successes)) /
            @as(f64, @floatFromInt(self.population));
    }

    pub fn varianceValue(self: Hypergeometric) f64 {
        if (self.population <= 1) return 0;
        const population: f64 = @floatFromInt(self.population);
        const successes: f64 = @floatFromInt(self.successes);
        const draws: f64 = @floatFromInt(self.draws);
        const p = successes / population;
        return draws * p * (1 - p) * (population - draws) / (population - 1);
    }

    pub fn minValue(self: Hypergeometric) u64 {
        const failures = self.population - self.successes;
        return if (self.draws > failures) self.draws - failures else 0;
    }

    pub fn maxValue(self: Hypergeometric) u64 {
        return @min(self.successes, self.draws);
    }

    pub fn sample(self: *const Hypergeometric, rng: Rng) u64 {
        return self.sampleFrom(rng);
    }

    pub fn sampleFrom(self: *const Hypergeometric, source: anytype) u64 {
        return switch (self.method) {
            .draw_loop => hypergeometricDrawLoopFrom(source, self.population, self.successes, self.draws),
            .inverse_transform => self.inverse_transform.sampleFrom(source),
            .rejection_acceptance => self.rejection_acceptance.sampleFrom(source),
        };
    }

    pub fn fill(self: *const Hypergeometric, rng: Rng, dest: []u64) void {
        self.fillFrom(rng, dest);
    }

    pub fn fillFrom(self: *const Hypergeometric, source: anytype, dest: []u64) void {
        for (dest) |*item| item.* = self.sampleFrom(source);
    }
};

pub fn hypergeometric(rng: Rng, population: u64, successes: u64, draws: u64) u64 {
    return hypergeometricFrom(rng, population, successes, draws);
}

pub fn hypergeometricChecked(rng: Rng, population: u64, successes: u64, draws: u64) Error!u64 {
    return hypergeometricCheckedFrom(rng, population, successes, draws);
}

pub fn hypergeometricCheckedFrom(source: anytype, population: u64, successes: u64, draws: u64) Error!u64 {
    const dist = try Hypergeometric.init(population, successes, draws);
    return dist.sampleFrom(source);
}

pub fn fillHypergeometric(rng: Rng, dest: []u64, population: u64, successes: u64, draws: u64) void {
    fillHypergeometricFrom(rng, dest, population, successes, draws);
}

pub fn fillHypergeometricFrom(source: anytype, dest: []u64, population: u64, successes: u64, draws: u64) void {
    const dist = Hypergeometric.init(population, successes, draws) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillHypergeometricChecked(rng: Rng, dest: []u64, population: u64, successes: u64, draws: u64) Error!void {
    return fillHypergeometricCheckedFrom(rng, dest, population, successes, draws);
}

pub fn fillHypergeometricCheckedFrom(source: anytype, dest: []u64, population: u64, successes: u64, draws: u64) Error!void {
    if (dest.len == 0) return;
    const dist = try Hypergeometric.init(population, successes, draws);
    dist.fillFrom(source, dest);
}

pub fn vectorHypergeometric(rng: Rng, comptime VectorType: type, population: u64, successes: u64, draws: u64) VectorType {
    return vectorHypergeometricFrom(rng, VectorType, population, successes, draws);
}

pub fn vectorHypergeometricFrom(source: anytype, comptime VectorType: type, population: u64, successes: u64, draws: u64) VectorType {
    const dist = VectorHypergeometric(VectorType).init(population, successes, draws) catch unreachable;
    return dist.sampleFrom(source);
}

pub fn vectorHypergeometricChecked(rng: Rng, comptime VectorType: type, population: u64, successes: u64, draws: u64) Error!VectorType {
    return vectorHypergeometricCheckedFrom(rng, VectorType, population, successes, draws);
}

pub fn vectorHypergeometricCheckedFrom(source: anytype, comptime VectorType: type, population: u64, successes: u64, draws: u64) Error!VectorType {
    const dist = try VectorHypergeometric(VectorType).init(population, successes, draws);
    return dist.sampleFrom(source);
}

pub fn fillVectorHypergeometric(rng: Rng, comptime VectorType: type, dest: []VectorType, population: u64, successes: u64, draws: u64) void {
    fillVectorHypergeometricFrom(rng, VectorType, dest, population, successes, draws);
}

pub fn fillVectorHypergeometricFrom(source: anytype, comptime VectorType: type, dest: []VectorType, population: u64, successes: u64, draws: u64) void {
    const dist = VectorHypergeometric(VectorType).init(population, successes, draws) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillVectorHypergeometricChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, population: u64, successes: u64, draws: u64) Error!void {
    return fillVectorHypergeometricCheckedFrom(rng, VectorType, dest, population, successes, draws);
}

pub fn fillVectorHypergeometricCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, population: u64, successes: u64, draws: u64) Error!void {
    if (dest.len == 0) return;
    const dist = try VectorHypergeometric(VectorType).init(population, successes, draws);
    dist.fillFrom(source, dest);
}

pub fn VectorHypergeometric(comptime VectorType: type) type {
    const info = vectorInfo(VectorType);
    if (info.child != u64) @compileError("VectorHypergeometric expects a u64 vector");

    return struct {
        const Self = @This();

        sampler: Hypergeometric,

        pub fn init(population: u64, successes: u64, draws: u64) Error!Self {
            return .{ .sampler = try Hypergeometric.init(population, successes, draws) };
        }

        pub fn populationValue(self: Self) u64 {
            return self.sampler.populationValue();
        }

        pub fn successesValue(self: Self) u64 {
            return self.sampler.successesValue();
        }

        pub fn drawsValue(self: Self) u64 {
            return self.sampler.drawsValue();
        }

        pub fn expectedValue(self: Self) f64 {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) f64 {
            return self.sampler.varianceValue();
        }

        pub fn minValue(self: Self) u64 {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) u64 {
            return self.sampler.maxValue();
        }

        pub fn sample(self: *const Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: *const Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..info.len) |lane| out[lane] = self.sampler.sampleFrom(source);
            return out;
        }

        pub fn fill(self: *const Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: *const Self, source: anytype, dest: []VectorType) void {
            const min = self.sampler.minValue();
            const max = self.sampler.maxValue();
            if (min == max) {
                @memset(dest, @as(VectorType, @splat(min)));
                return;
            }
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn hypergeometricFrom(source: anytype, population: u64, successes: u64, draws: u64) u64 {
    std.debug.assert(successes <= population and draws <= population);
    if (population == 0 or successes == 0 or draws == 0) return 0;
    if (successes == population) return draws;

    const dist = Hypergeometric.init(population, successes, draws) catch unreachable;
    return dist.sampleFrom(source);
}

const HypergeometricMethodTag = enum {
    draw_loop,
    inverse_transform,
    rejection_acceptance,
};

const HypergeometricInverseTransform = struct {
    n1: u64,
    n2: u64,
    k: u64,
    offset_x: i64,
    sign_x: i64,
    initial_p: f64,
    initial_x: i64,

    fn init(population: u64, successes: u64, draws: u64) ?HypergeometricInverseTransform {
        const params = HypergeometricReducedParams.init(population, successes, draws);
        const mode = hypergeometricMode(population, params.n1, params.k);
        const lower_bound = @max(@as(f64, 0), @as(f64, @floatFromInt(params.k)) - @as(f64, @floatFromInt(params.n2)));
        if (mode - lower_bound >= 10) return null;

        const initial_p, const initial_x = if (params.k < params.n2) .{
            fractionOfProductsOfFactorials(.{ params.n2, population - params.k }, .{ population, params.n2 - params.k }),
            @as(i64, 0),
        } else .{
            fractionOfProductsOfFactorials(.{ params.n1, params.k }, .{ population, params.k - params.n2 }),
            @as(i64, @intCast(params.k - params.n2)),
        };
        if (!(initial_p > 0) or !std.math.isFinite(initial_p)) return null;

        return .{
            .n1 = params.n1,
            .n2 = params.n2,
            .k = params.k,
            .offset_x = params.offset_x,
            .sign_x = params.sign_x,
            .initial_p = initial_p,
            .initial_x = initial_x,
        };
    }

    fn sampleFrom(self: *const HypergeometricInverseTransform, source: anytype) u64 {
        var p = self.initial_p;
        var x = self.initial_x;
        var u = Rng.floatFrom(source, f64);
        const k_i: i64 = @intCast(self.k);
        const n1_i: i64 = @intCast(self.n1);
        const n2_i: i64 = @intCast(self.n2);

        while (u > p and x < k_i) {
            u -= p;
            p *= @as(f64, @floatFromInt(n1_i - x)) * @as(f64, @floatFromInt(k_i - x));
            p /= @as(f64, @floatFromInt(x + 1)) * @as(f64, @floatFromInt(n2_i - k_i + 1 + x));
            x += 1;
        }

        const result = self.offset_x + self.sign_x * x;
        return @intCast(result);
    }
};

const HypergeometricRejectionAcceptance = struct {
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

    fn init(population: u64, successes: u64, draws: u64) ?HypergeometricRejectionAcceptance {
        const params = HypergeometricReducedParams.init(population, successes, draws);
        const m = hypergeometricMode(population, params.n1, params.k);
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

    fn sampleFrom(self: *const HypergeometricRejectionAcceptance, source: anytype) u64 {
        while (true) {
            const y, const v = self.selectCandidate(source);
            if (self.accept(y, v)) return self.finish(y);
        }
    }

    fn selectCandidate(self: *const HypergeometricRejectionAcceptance, source: anytype) struct { f64, f64 } {
        while (true) {
            const u = Rng.floatFrom(source, f64) * self.p3;
            var v = Rng.floatFrom(source, f64);
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

    fn accept(self: *const HypergeometricRejectionAcceptance, y: f64, v: f64) bool {
        if (self.m < 100.0 or y <= 50.0) {
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

        const y1 = y + 1.0;
        const ym = y - self.m;
        const yn = @as(f64, @floatFromInt(self.n1)) - y + 1.0;
        const yk = @as(f64, @floatFromInt(self.k)) - y + 1.0;
        const nk = @as(f64, @floatFromInt(self.n2 - self.k)) + y1;
        const r = -ym / y1;
        const s = ym / yn;
        const t = ym / yk;
        const e = -ym / nk;
        const g = yn * yk / (y1 * nk) - 1.0;
        const dg = if (g < 0.0) 1.0 + g else 1.0;
        const gu = g * (1.0 + g * (-0.5 + g / 3.0));
        const gl = gu - pow4(g) / (4.0 * dg);
        const xm = self.m + 0.5;
        const xn = @as(f64, @floatFromInt(self.n1)) - self.m + 0.5;
        const xk = @as(f64, @floatFromInt(self.k)) - self.m + 0.5;
        const nm = @as(f64, @floatFromInt(self.n2 - self.k)) + xm;
        const ub = xm * r * (1.0 + r * (-0.5 + r / 3.0)) +
            xn * s * (1.0 + s * (-0.5 + s / 3.0)) +
            xk * t * (1.0 + t * (-0.5 + t / 3.0)) +
            nm * e * (1.0 + e * (-0.5 + e / 3.0)) +
            y * gu - self.m * gl + 0.0034;
        const av = @log(v);
        if (av > ub) return false;

        const dr = if (r < 0.0) xm * pow4(r) / (1.0 + r) else xm * pow4(r);
        const ds = if (s < 0.0) xn * pow4(s) / (1.0 + s) else xn * pow4(s);
        const dt = if (t < 0.0) xk * pow4(t) / (1.0 + t) else xk * pow4(t);
        const de = if (e < 0.0) nm * pow4(e) / (1.0 + e) else nm * pow4(e);
        if (av < ub - 0.25 * (dr + ds + dt + de) + (y + self.m) * (gl - gu) - 0.0078) {
            return true;
        }

        const av_critical = self.a - lnOfFactorial(y) -
            lnOfFactorial(@as(f64, @floatFromInt(self.n1)) - y) -
            lnOfFactorial(@as(f64, @floatFromInt(self.k)) - y) -
            lnOfFactorial(@as(f64, @floatFromInt(self.n2 - self.k)) + y);
        return av <= av_critical;
    }

    fn finish(self: *const HypergeometricRejectionAcceptance, y: f64) u64 {
        const x: i64 = @intFromFloat(y);
        return @intCast(self.offset_x + self.sign_x * x);
    }
};

const HypergeometricReducedParams = struct {
    n1: u64,
    n2: u64,
    k: u64,
    offset_x: i64,
    sign_x: i64,

    fn init(population: u64, successes: u64, draws: u64) HypergeometricReducedParams {
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

fn hypergeometricMode(population: u64, n1: u64, k: u64) f64 {
    return @floor(@as(f64, @floatFromInt(k + 1)) *
        @as(f64, @floatFromInt(n1 + 1)) / @as(f64, @floatFromInt(population + 2)));
}

fn lnOfFactorial(v: f64) f64 {
    const v3 = v + 3.0;
    const ln_fac = (v3 + 0.5) * @log(v3) - v3 + @as(f64, 0.91893853320467274178) + 1.0 / (12.0 * v3);
    return ln_fac - @log((v + 3.0) * (v + 2.0) * (v + 1.0));
}

fn pow4(x: f64) f64 {
    const squared = x * x;
    return squared * squared;
}

fn fractionOfProductsOfFactorials(numerator: struct { u64, u64 }, denominator: struct { u64, u64 }) f64 {
    const min_top = @min(numerator[0], numerator[1]);
    const min_bottom = @min(denominator[0], denominator[1]);
    const min_all = @min(min_top, min_bottom);

    const max_top = @max(numerator[0], numerator[1]);
    const max_bottom = @max(denominator[0], denominator[1]);
    const max_all = @max(max_top, max_bottom);

    var result: f64 = 1;
    var i = min_all;
    while (i < max_all) {
        i += 1;
        if (i <= min_top) result *= @floatFromInt(i);
        if (i <= min_bottom) result /= @floatFromInt(i);
        if (i <= max_top) result *= @floatFromInt(i);
        if (i <= max_bottom) result /= @floatFromInt(i);
    }
    return result;
}

fn hypergeometricDrawLoopFrom(source: anytype, population: u64, successes: u64, draws: u64) u64 {
    if (population == 0 or successes == 0 or draws == 0) return 0;
    if (successes == population) return draws;

    var remaining_population = population;
    var remaining_successes = successes;
    var hits: u64 = 0;
    var i: u64 = 0;
    while (i < draws) : (i += 1) {
        const p = @as(f64, @floatFromInt(remaining_successes)) / @as(f64, @floatFromInt(remaining_population));
        if (Rng.floatFrom(source, f64) < p) {
            hits += 1;
            remaining_successes -= 1;
            if (remaining_successes == 0) break;
        }
        remaining_population -= 1;
    }
    return hits;
}

fn binomialFair(rng: Rng, trials: u64) u64 {
    return binomialFairFrom(rng, trials);
}

fn binomialFairFrom(source: anytype, trials: u64) u64 {
    var remaining = trials;
    var successes: u64 = 0;
    while (remaining >= 64) : (remaining -= 64) {
        successes += @popCount(Rng.nextFrom(source));
    }
    if (remaining > 0) {
        const mask = (@as(u64, 1) << @intCast(remaining)) - 1;
        successes += @popCount(Rng.nextFrom(source) & mask);
    }
    return successes;
}

fn binomialSmallP(rng: Rng, trials: u64, p: f64) u64 {
    return binomialSmallPFrom(rng, trials, p);
}

fn binomialSmallPFrom(source: anytype, trials: u64, p: f64) u64 {
    if (p == 0) return 0;
    if (trials <= 64) {
        const threshold = Rng.probabilityThreshold(p);
        var successes: u64 = 0;
        var i: u64 = 0;
        while (i < trials) : (i += 1) {
            successes += @intFromBool(Rng.nextFrom(source) < threshold);
        }
        return successes;
    }

    const mean = @as(f64, @floatFromInt(trials)) * p;
    if (mean >= 8) return binomialRejectionSmallPFrom(source, trials, p);

    return binomialWaitingFrom(source, trials, -@log(1.0 - p));
}

fn binomialWaiting(rng: Rng, trials: u64, q: f64) u64 {
    return binomialWaitingFrom(rng, trials, q);
}

fn binomialWaitingFrom(source: anytype, trials: u64, q: f64) u64 {
    var successes: u64 = 0;
    var sum: f64 = 0;
    while (true) {
        if (successes == trials) return successes;
        const e = -@log(1.0 - Rng.floatFrom(source, f64));
        sum += e / @as(f64, @floatFromInt(trials - successes));
        successes += 1;
        if (sum > q) return successes - 1;
    }
}

fn binomialRejectionSmallP(rng: Rng, trials: u64, p: f64) u64 {
    return binomialRejectionSmallPFrom(rng, trials, p);
}

fn binomialRejectionSmallPFrom(source: anytype, trials: u64, p: f64) u64 {
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

        const u = s * Rng.floatFrom(source, f64);
        if (u <= a1) {
            const n = Rng.normalFastFrom(source, f64, 0, 1);
            const y = s1 * @abs(n);
            reject = y >= d1;
            if (!reject) {
                const e = -@log(1.0 - Rng.floatFrom(source, f64));
                x = @floor(y);
                v = -e - n * n / 2.0 + c;
            }
        } else if (u <= a12) {
            const n = Rng.normalFastFrom(source, f64, 0, 1);
            const y = s2 * @abs(n);
            reject = y >= d2;
            if (!reject) {
                const e = -@log(1.0 - Rng.floatFrom(source, f64));
                x = @floor(-y);
                v = -e - n * n / 2.0;
            }
        } else if (u <= a123) {
            const e1 = -@log(1.0 - Rng.floatFrom(source, f64));
            const e2 = -@log(1.0 - Rng.floatFrom(source, f64));
            const y = d1 + 2.0 * s1s * e1 / d1;
            x = @floor(y);
            v = -e2 + d1 * (1.0 / (t - np) - y / (2.0 * s1s));
        } else {
            const e1 = -@log(1.0 - Rng.floatFrom(source, f64));
            const e2 = -@log(1.0 - Rng.floatFrom(source, f64));
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
        return x_int + binomialWaitingFrom(source, trials - x_int, q);
    }
}

fn UniformMoment(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .int => f64,
        .float => T,
        else => @compileError("Uniform supports integer and floating-point types"),
    };
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

        pub fn lowValue(self: Self) T {
            return self.low;
        }

        pub fn highValue(self: Self) T {
            return self.high;
        }

        pub fn isInclusive(self: Self) bool {
            return self.inclusive;
        }

        pub fn expectedValue(self: Self) UniformMoment(T) {
            return switch (@typeInfo(T)) {
                .int => blk: {
                    const low = @as(f64, @floatFromInt(self.low));
                    const high = @as(f64, @floatFromInt(self.high));
                    const endpoint_count: f64 = if (self.inclusive) 1 else 0;
                    const count = high - low + endpoint_count;
                    break :blk low + (count - 1) / 2;
                },
                .float => self.low + (self.high - self.low) / 2,
                else => @compileError("Uniform supports integer and floating-point types"),
            };
        }

        pub fn varianceValue(self: Self) UniformMoment(T) {
            return switch (@typeInfo(T)) {
                .int => blk: {
                    const low = @as(f64, @floatFromInt(self.low));
                    const high = @as(f64, @floatFromInt(self.high));
                    const endpoint_count: f64 = if (self.inclusive) 1 else 0;
                    const count = high - low + endpoint_count;
                    break :blk (count * count - 1) / 12;
                },
                .float => blk: {
                    const width = self.high - self.low;
                    break :blk width * width / 12;
                },
                else => @compileError("Uniform supports integer and floating-point types"),
            };
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            if (self.inclusive) {
                return uniformInclusiveFrom(source, T, self.low, self.high);
            }
            return uniformFrom(source, T, self.low, self.high);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            if (self.inclusive) {
                for (dest) |*item| item.* = uniformInclusiveFrom(source, T, self.low, self.high);
            } else {
                Rng.fillRangeFrom(source, T, dest, self.low, self.high);
            }
        }
    };
}

pub fn VectorUniform(comptime VectorType: type) type {
    const info = vectorInfo(VectorType);
    const Child = info.child;
    _ = UniformMoment(Child);

    return struct {
        const Self = @This();

        low: Child,
        high: Child,
        inclusive: bool = false,

        pub fn init(low: Child, high: Child) Error!Self {
            if (!rangeLess(Child, low, high)) return error.EmptyRange;
            return .{ .low = low, .high = high, .inclusive = false };
        }

        pub fn initInclusive(low: Child, high: Child) Error!Self {
            if (!rangeLessEqual(Child, low, high)) return error.EmptyRange;
            return .{ .low = low, .high = high, .inclusive = true };
        }

        pub fn lowValue(self: Self) Child {
            return self.low;
        }

        pub fn highValue(self: Self) Child {
            return self.high;
        }

        pub fn isInclusive(self: Self) bool {
            return self.inclusive;
        }

        pub fn expectedValue(self: Self) UniformMoment(Child) {
            return switch (@typeInfo(Child)) {
                .int => blk: {
                    const low = @as(f64, @floatFromInt(self.low));
                    const high = @as(f64, @floatFromInt(self.high));
                    const endpoint_count: f64 = if (self.inclusive) 1 else 0;
                    const count = high - low + endpoint_count;
                    break :blk low + (count - 1) / 2;
                },
                .float => self.low + (self.high - self.low) / 2,
                else => unreachable,
            };
        }

        pub fn varianceValue(self: Self) UniformMoment(Child) {
            return switch (@typeInfo(Child)) {
                .int => blk: {
                    const low = @as(f64, @floatFromInt(self.low));
                    const high = @as(f64, @floatFromInt(self.high));
                    const endpoint_count: f64 = if (self.inclusive) 1 else 0;
                    const count = high - low + endpoint_count;
                    break :blk (count * count - 1) / 12;
                },
                .float => blk: {
                    const width = self.high - self.low;
                    break :blk width * width / 12;
                },
                else => unreachable,
            };
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            if (self.inclusive) {
                return vectorUniformInclusiveFrom(source, VectorType, self.low, self.high);
            }
            return vectorUniformFrom(source, VectorType, self.low, self.high);
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            if (self.inclusive) {
                fillVectorUniformInclusiveFrom(source, VectorType, dest, self.low, self.high);
            } else {
                fillVectorUniformFrom(source, VectorType, dest, self.low, self.high);
            }
        }
    };
}

pub const Open01 = struct {
    pub fn lowValue(self: Open01, comptime T: type) T {
        _ = self;
        return zeroOf(T);
    }

    pub fn highValue(self: Open01, comptime T: type) T {
        _ = self;
        return oneOf(T);
    }

    pub fn includesLow(self: Open01) bool {
        _ = self;
        return false;
    }

    pub fn includesHigh(self: Open01) bool {
        _ = self;
        return false;
    }

    pub fn expectedValue(self: Open01, comptime T: type) T {
        _ = self;
        return splatOrScalar(T, 0.5);
    }

    pub fn varianceValue(self: Open01, comptime T: type) T {
        _ = self;
        return splatOrScalar(T, 1.0 / 12.0);
    }

    pub fn sample(_: Open01, rng: Rng, comptime T: type) T {
        return open01From(rng, T);
    }

    pub fn sampleFrom(_: Open01, source: anytype, comptime T: type) T {
        return open01From(source, T);
    }

    pub fn fill(_: Open01, rng: Rng, comptime T: type, dest: []T) void {
        fillOpen01From(rng, T, dest);
    }

    pub fn fillFrom(_: Open01, source: anytype, comptime T: type, dest: []T) void {
        fillOpen01From(source, T, dest);
    }
};

pub const OpenClosed01 = struct {
    pub fn lowValue(self: OpenClosed01, comptime T: type) T {
        _ = self;
        return zeroOf(T);
    }

    pub fn highValue(self: OpenClosed01, comptime T: type) T {
        _ = self;
        return oneOf(T);
    }

    pub fn includesLow(self: OpenClosed01) bool {
        _ = self;
        return false;
    }

    pub fn includesHigh(self: OpenClosed01) bool {
        _ = self;
        return true;
    }

    pub fn expectedValue(self: OpenClosed01, comptime T: type) T {
        _ = self;
        return splatOrScalar(T, 0.5);
    }

    pub fn varianceValue(self: OpenClosed01, comptime T: type) T {
        _ = self;
        return splatOrScalar(T, 1.0 / 12.0);
    }

    pub fn sample(_: OpenClosed01, rng: Rng, comptime T: type) T {
        return openClosed01From(rng, T);
    }

    pub fn sampleFrom(_: OpenClosed01, source: anytype, comptime T: type) T {
        return openClosed01From(source, T);
    }

    pub fn fill(_: OpenClosed01, rng: Rng, comptime T: type, dest: []T) void {
        fillOpenClosed01From(rng, T, dest);
    }

    pub fn fillFrom(_: OpenClosed01, source: anytype, comptime T: type, dest: []T) void {
        fillOpenClosed01From(source, T, dest);
    }
};

pub fn standardNormal(rng: Rng, comptime T: type) T {
    return Rng.standardNormalFastFrom(rng, T);
}

pub fn standardNormalFrom(source: anytype, comptime T: type) T {
    return Rng.standardNormalFastFrom(source, T);
}

pub fn fillStandardNormal(rng: Rng, comptime T: type, dest: []T) void {
    fillStandardNormalFrom(rng, T, dest);
}

pub fn fillStandardNormalFrom(source: anytype, comptime T: type, dest: []T) void {
    comptime requireFloat(T);
    for (dest) |*item| item.* = standardNormalFrom(source, T);
}

pub fn vectorStandardNormal(rng: Rng, comptime VectorType: type) VectorType {
    return vectorStandardNormalFrom(rng, VectorType);
}

pub fn vectorStandardNormalFrom(source: anytype, comptime VectorType: type) VectorType {
    return Rng.vectorStandardNormalFrom(source, VectorType);
}

pub fn fillVectorStandardNormal(rng: Rng, comptime VectorType: type, dest: []VectorType) void {
    fillVectorStandardNormalFrom(rng, VectorType, dest);
}

pub fn fillVectorStandardNormalFrom(source: anytype, comptime VectorType: type, dest: []VectorType) void {
    Rng.fillVectorStandardNormalFrom(source, VectorType, dest);
}

pub fn normal(rng: Rng, comptime T: type, mean: T, stddev: T) T {
    return normalFrom(rng, T, mean, stddev);
}

pub fn normalFrom(source: anytype, comptime T: type, mean: T, stddev: T) T {
    comptime requireFloat(T);
    std.debug.assert(stddev >= 0);
    return Rng.normalFastFrom(source, T, mean, stddev);
}

pub fn normalChecked(rng: Rng, comptime T: type, mean: T, stddev: T) Error!T {
    return normalCheckedFrom(rng, T, mean, stddev);
}

pub fn normalCheckedFrom(source: anytype, comptime T: type, mean: T, stddev: T) Error!T {
    return Rng.normalCheckedFrom(source, T, mean, stddev);
}

pub fn fillNormal(rng: Rng, comptime T: type, dest: []T, mean: T, stddev: T) void {
    fillNormalFrom(rng, T, dest, mean, stddev);
}

pub fn fillNormalFrom(source: anytype, comptime T: type, dest: []T, mean: T, stddev: T) void {
    Rng.fillNormalFrom(source, T, dest, mean, stddev);
}

pub fn fillNormalChecked(rng: Rng, comptime T: type, dest: []T, mean: T, stddev: T) Error!void {
    return fillNormalCheckedFrom(rng, T, dest, mean, stddev);
}

pub fn fillNormalCheckedFrom(source: anytype, comptime T: type, dest: []T, mean: T, stddev: T) Error!void {
    try Rng.fillNormalCheckedFrom(source, T, dest, mean, stddev);
}

pub fn vectorNormal(rng: Rng, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) VectorType {
    return vectorNormalFrom(rng, VectorType, mean, stddev);
}

pub fn vectorNormalFrom(source: anytype, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) VectorType {
    return Rng.vectorNormalFrom(source, VectorType, mean, stddev);
}

pub fn vectorNormalChecked(rng: Rng, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!VectorType {
    return vectorNormalCheckedFrom(rng, VectorType, mean, stddev);
}

pub fn vectorNormalCheckedFrom(source: anytype, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!VectorType {
    return Rng.vectorNormalCheckedFrom(source, VectorType, mean, stddev);
}

pub fn fillVectorNormal(rng: Rng, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) void {
    fillVectorNormalFrom(rng, VectorType, dest, mean, stddev);
}

pub fn fillVectorNormalFrom(source: anytype, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) void {
    Rng.fillVectorNormalFrom(source, VectorType, dest, mean, stddev);
}

pub fn fillVectorNormalChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!void {
    return fillVectorNormalCheckedFrom(rng, VectorType, dest, mean, stddev);
}

pub fn fillVectorNormalCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!void {
    return Rng.fillVectorNormalCheckedFrom(source, VectorType, dest, mean, stddev);
}

pub fn StandardNormal(comptime T: type) type {
    return struct {
        pub fn meanValue(_: @This()) T {
            return 0;
        }

        pub fn stddevValue(_: @This()) T {
            return 1;
        }

        pub fn expectedValue(_: @This()) T {
            return 0;
        }

        pub fn varianceValue(_: @This()) T {
            return 1;
        }

        pub fn medianValue(_: @This()) T {
            return 0;
        }

        pub fn modeValue(_: @This()) T {
            return 0;
        }

        pub fn minValue(_: @This()) ?T {
            return null;
        }

        pub fn maxValue(_: @This()) ?T {
            return null;
        }

        pub fn sample(_: @This(), rng: Rng) T {
            return standardNormal(rng, T);
        }

        pub fn sampleFrom(_: @This(), source: anytype) T {
            return standardNormalFrom(source, T);
        }

        pub fn fill(_: @This(), rng: Rng, dest: []T) void {
            fillStandardNormal(rng, T, dest);
        }

        pub fn fillFrom(_: @This(), source: anytype, dest: []T) void {
            fillStandardNormalFrom(source, T, dest);
        }
    };
}

pub fn VectorStandardNormal(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        pub fn meanValue(_: @This()) Child {
            return 0;
        }

        pub fn stddevValue(_: @This()) Child {
            return 1;
        }

        pub fn expectedValue(_: @This()) Child {
            return 0;
        }

        pub fn varianceValue(_: @This()) Child {
            return 1;
        }

        pub fn medianValue(_: @This()) Child {
            return 0;
        }

        pub fn modeValue(_: @This()) Child {
            return 0;
        }

        pub fn minValue(_: @This()) ?Child {
            return null;
        }

        pub fn maxValue(_: @This()) ?Child {
            return null;
        }

        pub fn sample(_: @This(), rng: Rng) VectorType {
            return vectorStandardNormal(rng, VectorType);
        }

        pub fn sampleFrom(_: @This(), source: anytype) VectorType {
            return vectorStandardNormalFrom(source, VectorType);
        }

        pub fn fill(_: @This(), rng: Rng, dest: []VectorType) void {
            fillVectorStandardNormal(rng, VectorType, dest);
        }

        pub fn fillFrom(_: @This(), source: anytype, dest: []VectorType) void {
            fillVectorStandardNormalFrom(source, VectorType, dest);
        }
    };
}

pub fn standardExponential(rng: Rng, comptime T: type) T {
    return Rng.standardExponentialFastFrom(rng, T);
}

pub fn standardExponentialFrom(source: anytype, comptime T: type) T {
    return Rng.standardExponentialFastFrom(source, T);
}

pub fn fillStandardExponential(rng: Rng, comptime T: type, dest: []T) void {
    fillStandardExponentialFrom(rng, T, dest);
}

pub fn fillStandardExponentialFrom(source: anytype, comptime T: type, dest: []T) void {
    comptime requireFloat(T);
    for (dest) |*item| item.* = standardExponentialFrom(source, T);
}

pub fn vectorStandardExponential(rng: Rng, comptime VectorType: type) VectorType {
    return vectorStandardExponentialFrom(rng, VectorType);
}

pub fn vectorStandardExponentialFrom(source: anytype, comptime VectorType: type) VectorType {
    return Rng.vectorStandardExponentialFrom(source, VectorType);
}

pub fn fillVectorStandardExponential(rng: Rng, comptime VectorType: type, dest: []VectorType) void {
    fillVectorStandardExponentialFrom(rng, VectorType, dest);
}

pub fn fillVectorStandardExponentialFrom(source: anytype, comptime VectorType: type, dest: []VectorType) void {
    Rng.fillVectorStandardExponentialFrom(source, VectorType, dest);
}

pub fn exponential(rng: Rng, comptime T: type, rate: T) T {
    return exponentialFrom(rng, T, rate);
}

pub fn exponentialFrom(source: anytype, comptime T: type, rate: T) T {
    comptime requireFloat(T);
    std.debug.assert(rate > 0);
    return Rng.exponentialFastFrom(source, T, rate);
}

pub fn exponentialChecked(rng: Rng, comptime T: type, rate: T) Error!T {
    return exponentialCheckedFrom(rng, T, rate);
}

pub fn exponentialCheckedFrom(source: anytype, comptime T: type, rate: T) Error!T {
    return Rng.exponentialCheckedFrom(source, T, rate);
}

pub fn fillExponential(rng: Rng, comptime T: type, dest: []T, rate: T) void {
    fillExponentialFrom(rng, T, dest, rate);
}

pub fn fillExponentialFrom(source: anytype, comptime T: type, dest: []T, rate: T) void {
    Rng.fillExponentialFrom(source, T, dest, rate);
}

pub fn fillExponentialChecked(rng: Rng, comptime T: type, dest: []T, rate: T) Error!void {
    return fillExponentialCheckedFrom(rng, T, dest, rate);
}

pub fn fillExponentialCheckedFrom(source: anytype, comptime T: type, dest: []T, rate: T) Error!void {
    try Rng.fillExponentialCheckedFrom(source, T, dest, rate);
}

pub fn vectorExponential(rng: Rng, comptime VectorType: type, rate: vectorChild(VectorType)) VectorType {
    return vectorExponentialFrom(rng, VectorType, rate);
}

pub fn vectorExponentialFrom(source: anytype, comptime VectorType: type, rate: vectorChild(VectorType)) VectorType {
    return Rng.vectorExponentialFrom(source, VectorType, rate);
}

pub fn vectorExponentialChecked(rng: Rng, comptime VectorType: type, rate: vectorChild(VectorType)) Error!VectorType {
    return vectorExponentialCheckedFrom(rng, VectorType, rate);
}

pub fn vectorExponentialCheckedFrom(source: anytype, comptime VectorType: type, rate: vectorChild(VectorType)) Error!VectorType {
    return Rng.vectorExponentialCheckedFrom(source, VectorType, rate);
}

pub fn fillVectorExponential(rng: Rng, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) void {
    fillVectorExponentialFrom(rng, VectorType, dest, rate);
}

pub fn fillVectorExponentialFrom(source: anytype, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) void {
    Rng.fillVectorExponentialFrom(source, VectorType, dest, rate);
}

pub fn fillVectorExponentialChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) Error!void {
    return fillVectorExponentialCheckedFrom(rng, VectorType, dest, rate);
}

pub fn fillVectorExponentialCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) Error!void {
    return Rng.fillVectorExponentialCheckedFrom(source, VectorType, dest, rate);
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

        pub fn initMeanCv(mean: T, coefficient_of_variation: T) Error!Self {
            comptime requireFloat(T);
            if (!(coefficient_of_variation >= 0) or !std.math.isFinite(coefficient_of_variation)) return error.InvalidParameter;
            return Self.init(mean, @abs(mean) * coefficient_of_variation);
        }

        pub fn fromZScore(self: Self, z_score: T) T {
            return self.mean + self.stddev * z_score;
        }

        pub fn meanValue(self: Self) T {
            return self.mean;
        }

        pub fn stddevValue(self: Self) T {
            return self.stddev;
        }

        pub fn expectedValue(self: Self) T {
            return self.mean;
        }

        pub fn varianceValue(self: Self) T {
            return self.stddev * self.stddev;
        }

        pub fn medianValue(self: Self) T {
            return self.mean;
        }

        pub fn modeValue(self: Self) T {
            return self.mean;
        }

        pub fn minValue(self: Self) ?T {
            return if (self.stddev == 0) self.mean else null;
        }

        pub fn maxValue(self: Self) ?T {
            return if (self.stddev == 0) self.mean else null;
        }

        pub fn coefficientOfVariationValue(self: Self) ?T {
            if (self.mean == 0) return null;
            return self.stddev / @abs(self.mean);
        }

        pub fn sample(self: Self, rng: Rng) T {
            return rng.normal(T, self.mean, self.stddev);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return Rng.normalFastFrom(source, T, self.mean, self.stddev);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            Rng.fillNormalFrom(source, T, dest, self.mean, self.stddev);
        }
    };
}

pub fn VectorNormal(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        mean: Child,
        stddev: Child,

        pub fn init(mean: Child, stddev: Child) Error!Self {
            if (!(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
            if (!std.math.isFinite(mean)) return error.InvalidParameter;
            return .{ .mean = mean, .stddev = stddev };
        }

        pub fn initMeanCv(mean: Child, coefficient_of_variation: Child) Error!Self {
            if (!(coefficient_of_variation >= 0) or !std.math.isFinite(coefficient_of_variation)) return error.InvalidParameter;
            return Self.init(mean, @abs(mean) * coefficient_of_variation);
        }

        pub fn fromZScore(self: Self, z_score: Child) Child {
            return self.mean + self.stddev * z_score;
        }

        pub fn meanValue(self: Self) Child {
            return self.mean;
        }

        pub fn stddevValue(self: Self) Child {
            return self.stddev;
        }

        pub fn expectedValue(self: Self) Child {
            return self.mean;
        }

        pub fn varianceValue(self: Self) Child {
            return self.stddev * self.stddev;
        }

        pub fn medianValue(self: Self) Child {
            return self.mean;
        }

        pub fn modeValue(self: Self) Child {
            return self.mean;
        }

        pub fn minValue(self: Self) ?Child {
            return if (self.stddev == 0) self.mean else null;
        }

        pub fn maxValue(self: Self) ?Child {
            return if (self.stddev == 0) self.mean else null;
        }

        pub fn coefficientOfVariationValue(self: Self) ?Child {
            if (self.mean == 0) return null;
            return self.stddev / @abs(self.mean);
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return vectorNormal(rng, VectorType, self.mean, self.stddev);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            return vectorNormalFrom(source, VectorType, self.mean, self.stddev);
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            fillVectorNormalFrom(source, VectorType, dest, self.mean, self.stddev);
        }
    };
}

pub fn StandardExponential(comptime T: type) type {
    return struct {
        pub fn rateValue(_: @This()) T {
            return 1;
        }

        pub fn inverseRateValue(_: @This()) T {
            return 1;
        }

        pub fn expectedValue(_: @This()) T {
            return 1;
        }

        pub fn varianceValue(_: @This()) T {
            return 1;
        }

        pub fn medianValue(_: @This()) T {
            return @log(@as(T, 2));
        }

        pub fn modeValue(_: @This()) T {
            return 0;
        }

        pub fn minValue(_: @This()) T {
            return 0;
        }

        pub fn maxValue(_: @This()) ?T {
            return null;
        }

        pub fn sample(_: @This(), rng: Rng) T {
            return standardExponential(rng, T);
        }

        pub fn sampleFrom(_: @This(), source: anytype) T {
            return standardExponentialFrom(source, T);
        }

        pub fn fill(_: @This(), rng: Rng, dest: []T) void {
            fillStandardExponential(rng, T, dest);
        }

        pub fn fillFrom(_: @This(), source: anytype, dest: []T) void {
            fillStandardExponentialFrom(source, T, dest);
        }
    };
}

pub fn VectorStandardExponential(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        pub fn rateValue(_: @This()) Child {
            return 1;
        }

        pub fn inverseRateValue(_: @This()) Child {
            return 1;
        }

        pub fn expectedValue(_: @This()) Child {
            return 1;
        }

        pub fn varianceValue(_: @This()) Child {
            return 1;
        }

        pub fn medianValue(_: @This()) Child {
            return @log(@as(Child, 2));
        }

        pub fn modeValue(_: @This()) Child {
            return 0;
        }

        pub fn minValue(_: @This()) Child {
            return 0;
        }

        pub fn maxValue(_: @This()) ?Child {
            return null;
        }

        pub fn sample(_: @This(), rng: Rng) VectorType {
            return vectorStandardExponential(rng, VectorType);
        }

        pub fn sampleFrom(_: @This(), source: anytype) VectorType {
            return vectorStandardExponentialFrom(source, VectorType);
        }

        pub fn fill(_: @This(), rng: Rng, dest: []VectorType) void {
            fillVectorStandardExponential(rng, VectorType, dest);
        }

        pub fn fillFrom(_: @This(), source: anytype, dest: []VectorType) void {
            fillVectorStandardExponentialFrom(source, VectorType, dest);
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

        pub fn rateValue(self: Self) T {
            return 1 / self.inverse_rate;
        }

        pub fn inverseRateValue(self: Self) T {
            return self.inverse_rate;
        }

        pub fn expectedValue(self: Self) T {
            return self.inverse_rate;
        }

        pub fn varianceValue(self: Self) T {
            return self.inverse_rate * self.inverse_rate;
        }

        pub fn medianValue(self: Self) T {
            return @log(@as(T, 2)) * self.inverse_rate;
        }

        pub fn modeValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return Rng.exponentialFastFrom(rng, T, 1) * self.inverse_rate;
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return Rng.exponentialFastFrom(source, T, 1) * self.inverse_rate;
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn VectorExponential(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        inverse_rate: Child,

        pub fn init(rate: Child) Error!Self {
            if (!(rate > 0) or !std.math.isFinite(rate)) return error.InvalidParameter;
            return .{ .inverse_rate = 1 / rate };
        }

        pub fn rateValue(self: Self) Child {
            return 1 / self.inverse_rate;
        }

        pub fn inverseRateValue(self: Self) Child {
            return self.inverse_rate;
        }

        pub fn expectedValue(self: Self) Child {
            return self.inverse_rate;
        }

        pub fn varianceValue(self: Self) Child {
            return self.inverse_rate * self.inverse_rate;
        }

        pub fn medianValue(self: Self) Child {
            return @log(@as(Child, 2)) * self.inverse_rate;
        }

        pub fn modeValue(self: Self) Child {
            _ = self;
            return 0;
        }

        pub fn minValue(self: Self) Child {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?Child {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return vectorStandardExponential(rng, VectorType) * @as(VectorType, @splat(self.inverse_rate));
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            return vectorStandardExponentialFrom(source, VectorType) * @as(VectorType, @splat(self.inverse_rate));
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            fillVectorExponentialFrom(source, VectorType, dest, 1 / self.inverse_rate);
        }
    };
}

pub fn logNormal(rng: Rng, comptime T: type, mean: T, stddev: T) T {
    return logNormalFrom(rng, T, mean, stddev);
}

pub fn logNormalChecked(rng: Rng, comptime T: type, mean: T, stddev: T) Error!T {
    return logNormalCheckedFrom(rng, T, mean, stddev);
}

pub fn logNormalCheckedFrom(source: anytype, comptime T: type, mean: T, stddev: T) Error!T {
    var dist = try LogNormal(T).init(mean, stddev);
    return dist.sampleFrom(source);
}

pub fn logNormalFrom(source: anytype, comptime T: type, mean: T, stddev: T) T {
    comptime requireFloat(T);
    if (mean == 0) return @exp(stddev * Rng.standardNormalFastFrom(source, T));
    return @exp(mean + stddev * Rng.standardNormalFastFrom(source, T));
}

pub fn fillLogNormal(rng: Rng, comptime T: type, dest: []T, mean: T, stddev: T) void {
    fillLogNormalFrom(rng, T, dest, mean, stddev);
}

pub fn fillLogNormalFrom(source: anytype, comptime T: type, dest: []T, mean: T, stddev: T) void {
    comptime requireFloat(T);
    std.debug.assert(stddev >= 0);
    Rng.fillNormalFrom(source, T, dest, mean, stddev);
    expInPlace(T, dest);
}

pub fn fillLogNormalChecked(rng: Rng, comptime T: type, dest: []T, mean: T, stddev: T) Error!void {
    return fillLogNormalCheckedFrom(rng, T, dest, mean, stddev);
}

pub fn fillLogNormalCheckedFrom(source: anytype, comptime T: type, dest: []T, mean: T, stddev: T) Error!void {
    if (dest.len == 0) return;
    var dist = try LogNormal(T).init(mean, stddev);
    dist.fillFrom(source, dest);
}

pub fn vectorLogNormal(rng: Rng, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) VectorType {
    return vectorLogNormalFrom(rng, VectorType, mean, stddev);
}

pub fn vectorLogNormalFrom(source: anytype, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) VectorType {
    const normal_vec = vectorNormalFrom(source, VectorType, mean, stddev);
    return @exp(normal_vec);
}

pub fn vectorLogNormalChecked(rng: Rng, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!VectorType {
    return vectorLogNormalCheckedFrom(rng, VectorType, mean, stddev);
}

pub fn vectorLogNormalCheckedFrom(source: anytype, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!VectorType {
    _ = try VectorLogNormal(VectorType).init(mean, stddev);
    return vectorLogNormalFrom(source, VectorType, mean, stddev);
}

pub fn fillVectorLogNormal(rng: Rng, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) void {
    fillVectorLogNormalFrom(rng, VectorType, dest, mean, stddev);
}

pub fn fillVectorLogNormalFrom(source: anytype, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) void {
    fillVectorNormalFrom(source, VectorType, dest, mean, stddev);
    expVectorSliceInPlace(VectorType, dest);
}

pub fn fillVectorLogNormalChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!void {
    return fillVectorLogNormalCheckedFrom(rng, VectorType, dest, mean, stddev);
}

pub fn fillVectorLogNormalCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    _ = try VectorLogNormal(VectorType).init(mean, stddev);
    fillVectorLogNormalFrom(source, VectorType, dest, mean, stddev);
}

const log_normal_approx_f32_max_abs_mean: f32 = 0.25;
const log_normal_approx_f32_max_stddev: f32 = 0.25;

pub fn logNormalApproxF32(rng: Rng, mean: f32, stddev: f32) f32 {
    return logNormalApproxF32From(rng, mean, stddev);
}

pub fn logNormalApproxF32From(source: anytype, mean: f32, stddev: f32) f32 {
    std.debug.assert(logNormalApproxF32ParametersValid(mean, stddev));
    const z = Rng.standardNormalFastFrom(source, f32);
    const log_space = if (mean == 0) stddev * z else mean + stddev * z;
    return expm1ApproxPositiveF32(log_space);
}

pub fn logNormalApproxF32Checked(rng: Rng, mean: f32, stddev: f32) Error!f32 {
    return logNormalApproxF32CheckedFrom(rng, mean, stddev);
}

pub fn logNormalApproxF32CheckedFrom(source: anytype, mean: f32, stddev: f32) Error!f32 {
    if (!logNormalApproxF32ParametersValid(mean, stddev)) return error.InvalidParameter;
    return logNormalApproxF32From(source, mean, stddev);
}

pub fn fillLogNormalApproxF32(rng: Rng, dest: []f32, mean: f32, stddev: f32) void {
    fillLogNormalApproxF32From(rng, dest, mean, stddev);
}

pub fn fillLogNormalApproxF32From(source: anytype, dest: []f32, mean: f32, stddev: f32) void {
    std.debug.assert(logNormalApproxF32ParametersValid(mean, stddev));
    Rng.fillNormalFrom(source, f32, dest, mean, stddev);
    expm1ApproxPositiveInPlaceF32(dest);
}

pub fn fillLogNormalApproxF32Checked(rng: Rng, dest: []f32, mean: f32, stddev: f32) Error!void {
    return fillLogNormalApproxF32CheckedFrom(rng, dest, mean, stddev);
}

pub fn fillLogNormalApproxF32CheckedFrom(source: anytype, dest: []f32, mean: f32, stddev: f32) Error!void {
    if (dest.len == 0) return;
    if (!logNormalApproxF32ParametersValid(mean, stddev)) return error.InvalidParameter;
    fillLogNormalApproxF32From(source, dest, mean, stddev);
}

pub fn LogNormal(comptime T: type) type {
    return struct {
        const Self = @This();

        normal_sampler: Normal(T),

        pub fn init(mean: T, stddev: T) Error!Self {
            return .{ .normal_sampler = try Normal(T).init(mean, stddev) };
        }

        pub fn initMeanCv(mean: T, coefficient_of_variation: T) Error!Self {
            comptime requireFloat(T);
            if (coefficient_of_variation == 0) {
                if (mean == 0) {
                    return .{ .normal_sampler = .{ .mean = -std.math.inf(T), .stddev = 0 } };
                }
                if (!(mean > 0) or !std.math.isFinite(mean)) return error.InvalidParameter;
                return .{ .normal_sampler = try Normal(T).init(@log(mean), 0) };
            }
            if (!(mean > 0) or !std.math.isFinite(mean)) return error.InvalidParameter;
            if (!(coefficient_of_variation >= 0) or !std.math.isFinite(coefficient_of_variation)) return error.InvalidParameter;

            const variance_ratio = coefficient_of_variation * coefficient_of_variation;
            const stddev = @sqrt(std.math.log1p(variance_ratio));
            const log_mean = @log(mean) - 0.5 * stddev * stddev;
            return .{ .normal_sampler = try Normal(T).init(log_mean, stddev) };
        }

        pub fn sample(self: *Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: *Self, source: anytype) T {
            return logNormalFrom(source, T, self.normal_sampler.mean, self.normal_sampler.stddev);
        }

        pub fn fromZScore(self: Self, z_score: T) T {
            return @exp(self.normal_sampler.fromZScore(z_score));
        }

        pub fn logMean(self: Self) T {
            return self.normal_sampler.meanValue();
        }

        pub fn logMeanValue(self: Self) T {
            return self.logMean();
        }

        pub fn logStddev(self: Self) T {
            return self.normal_sampler.stddevValue();
        }

        pub fn logStddevValue(self: Self) T {
            return self.logStddev();
        }

        pub fn linearMeanValue(self: Self) T {
            const sigma = self.logStddev();
            return @exp(self.logMean() + 0.5 * sigma * sigma);
        }

        pub fn medianValue(self: Self) T {
            return @exp(self.logMean());
        }

        pub fn modeValue(self: Self) T {
            const sigma = self.logStddev();
            return @exp(self.logMean() - sigma * sigma);
        }

        pub fn expectedValue(self: Self) T {
            return self.linearMeanValue();
        }

        pub fn varianceValue(self: Self) T {
            const sigma = self.logStddev();
            const mean = self.linearMeanValue();
            return (@exp(sigma * sigma) - 1) * mean * mean;
        }

        pub fn minValue(self: Self) T {
            if (self.logStddev() == 0) return self.linearMeanValue();
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            if (self.logStddev() == 0) return self.linearMeanValue();
            return null;
        }

        pub fn coefficientOfVariationValue(self: Self) T {
            const sigma = self.logStddev();
            return @sqrt(@exp(sigma * sigma) - 1);
        }

        pub fn fill(self: *Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: *Self, source: anytype, dest: []T) void {
            self.normal_sampler.fillFrom(source, dest);
            expInPlace(T, dest);
        }
    };
}

pub fn VectorLogNormal(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        normal_sampler: VectorNormal(VectorType),

        pub fn init(mean: Child, stddev: Child) Error!Self {
            return .{ .normal_sampler = try VectorNormal(VectorType).init(mean, stddev) };
        }

        pub fn meanValue(self: Self) Child {
            return self.normal_sampler.meanValue();
        }

        pub fn stddevValue(self: Self) Child {
            return self.normal_sampler.stddevValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            return vectorLogNormalFrom(source, VectorType, self.normal_sampler.mean, self.normal_sampler.stddev);
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            fillVectorLogNormalFrom(source, VectorType, dest, self.normal_sampler.mean, self.normal_sampler.stddev);
        }
    };
}

pub const LogNormalApproxF32 = struct {
    const Self = @This();

    pub const max_abs_mean: f32 = log_normal_approx_f32_max_abs_mean;
    pub const max_stddev: f32 = log_normal_approx_f32_max_stddev;

    mean: f32,
    stddev: f32,

    pub fn init(mean: f32, stddev: f32) Error!Self {
        if (!logNormalApproxF32ParametersValid(mean, stddev)) return error.InvalidParameter;
        return .{ .mean = mean, .stddev = stddev };
    }

    pub fn meanValue(self: Self) f32 {
        return self.mean;
    }

    pub fn stddevValue(self: Self) f32 {
        return self.stddev;
    }

    pub fn maxAbsMeanValue(_: Self) f32 {
        return max_abs_mean;
    }

    pub fn maxStddevValue(_: Self) f32 {
        return max_stddev;
    }

    pub fn sample(self: Self, rng: Rng) f32 {
        return self.sampleFrom(rng);
    }

    pub fn sampleFrom(self: Self, source: anytype) f32 {
        return logNormalApproxF32From(source, self.mean, self.stddev);
    }

    pub fn fill(self: Self, rng: Rng, dest: []f32) void {
        self.fillFrom(rng, dest);
    }

    pub fn fillFrom(self: Self, source: anytype, dest: []f32) void {
        fillLogNormalApproxF32From(source, dest, self.mean, self.stddev);
    }
};

pub fn halfNormal(rng: Rng, comptime T: type, scale: T) T {
    return halfNormalFrom(rng, T, scale);
}

pub fn halfNormalChecked(rng: Rng, comptime T: type, scale: T) Error!T {
    return halfNormalCheckedFrom(rng, T, scale);
}

pub fn halfNormalCheckedFrom(source: anytype, comptime T: type, scale: T) Error!T {
    const dist = try HalfNormal(T).init(scale);
    return dist.sampleFrom(source);
}

pub fn halfNormalFrom(source: anytype, comptime T: type, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and std.math.isFinite(scale));

    return @abs(Rng.normalFastFrom(source, T, 0, scale));
}

pub fn fillHalfNormal(rng: Rng, comptime T: type, dest: []T, scale: T) void {
    fillHalfNormalFrom(rng, T, dest, scale);
}

pub fn fillHalfNormalFrom(source: anytype, comptime T: type, dest: []T, scale: T) void {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and std.math.isFinite(scale));
    if (comptime T == f64 and (@TypeOf(source) == Rng or @TypeOf(source) == *Alea4x64)) {
        Rng.fillNormalFrom(source, T, dest, 0, scale);
        absInPlace(T, dest);
        return;
    }
    for (dest) |*item| item.* = halfNormalFrom(source, T, scale);
}

pub fn fillHalfNormalChecked(rng: Rng, comptime T: type, dest: []T, scale: T) Error!void {
    return fillHalfNormalCheckedFrom(rng, T, dest, scale);
}

pub fn fillHalfNormalCheckedFrom(source: anytype, comptime T: type, dest: []T, scale: T) Error!void {
    if (dest.len == 0) return;
    const dist = try HalfNormal(T).init(scale);
    dist.fillFrom(source, dest);
}

pub fn vectorHalfNormal(rng: Rng, comptime VectorType: type, scale: vectorChild(VectorType)) VectorType {
    return vectorHalfNormalFrom(rng, VectorType, scale);
}

pub fn vectorHalfNormalFrom(source: anytype, comptime VectorType: type, scale: vectorChild(VectorType)) VectorType {
    std.debug.assert(scale > 0 and std.math.isFinite(scale));
    return @abs(vectorNormalFrom(source, VectorType, 0, scale));
}

pub fn vectorHalfNormalChecked(rng: Rng, comptime VectorType: type, scale: vectorChild(VectorType)) Error!VectorType {
    return vectorHalfNormalCheckedFrom(rng, VectorType, scale);
}

pub fn vectorHalfNormalCheckedFrom(source: anytype, comptime VectorType: type, scale: vectorChild(VectorType)) Error!VectorType {
    _ = try VectorHalfNormal(VectorType).init(scale);
    return vectorHalfNormalFrom(source, VectorType, scale);
}

pub fn fillVectorHalfNormal(rng: Rng, comptime VectorType: type, dest: []VectorType, scale: vectorChild(VectorType)) void {
    fillVectorHalfNormalFrom(rng, VectorType, dest, scale);
}

pub fn fillVectorHalfNormalFrom(source: anytype, comptime VectorType: type, dest: []VectorType, scale: vectorChild(VectorType)) void {
    fillVectorNormalFrom(source, VectorType, dest, 0, scale);
    absVectorSliceInPlace(VectorType, dest);
}

pub fn fillVectorHalfNormalChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, scale: vectorChild(VectorType)) Error!void {
    return fillVectorHalfNormalCheckedFrom(rng, VectorType, dest, scale);
}

pub fn fillVectorHalfNormalCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, scale: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    _ = try VectorHalfNormal(VectorType).init(scale);
    fillVectorHalfNormalFrom(source, VectorType, dest, scale);
}

pub fn HalfNormal(comptime T: type) type {
    return struct {
        const Self = @This();

        scale: T,

        pub fn init(scale: T) Error!Self {
            comptime requireFloat(T);
            if (!(scale > 0) or !std.math.isFinite(scale)) return error.InvalidParameter;
            return .{ .scale = scale };
        }

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn expectedValue(self: Self) T {
            return self.scale * @sqrt(2 / @as(T, @floatCast(std.math.pi)));
        }

        pub fn varianceValue(self: Self) T {
            return self.scale * self.scale * (1 - 2 / @as(T, @floatCast(std.math.pi)));
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return halfNormalFrom(source, T, self.scale);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn VectorHalfNormal(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        scale: Child,

        pub fn init(scale: Child) Error!Self {
            if (!(scale > 0) or !std.math.isFinite(scale)) return error.InvalidParameter;
            return .{ .scale = scale };
        }

        pub fn scaleValue(self: Self) Child {
            return self.scale;
        }

        pub fn expectedValue(self: Self) Child {
            return self.scale * @sqrt(2 / @as(Child, @floatCast(std.math.pi)));
        }

        pub fn varianceValue(self: Self) Child {
            return self.scale * self.scale * (1 - 2 / @as(Child, @floatCast(std.math.pi)));
        }

        pub fn minValue(self: Self) Child {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?Child {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            return vectorHalfNormalFrom(source, VectorType, self.scale);
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            fillVectorHalfNormalFrom(source, VectorType, dest, self.scale);
        }
    };
}

pub fn poisson(rng: Rng, lambda: f64) u64 {
    return poissonFrom(rng, lambda);
}

pub fn poissonFrom(source: anytype, lambda: f64) u64 {
    std.debug.assert(lambda >= 0 and std.math.isFinite(lambda));
    if (lambda == 0) return 0;

    if (lambda < 12) {
        return poissonProductFrom(source, @exp(-lambda));
    }

    return poissonAhrensDieterFrom(source, lambda);
}

pub fn poissonChecked(rng: Rng, lambda: f64) Error!u64 {
    return poissonCheckedFrom(rng, lambda);
}

pub fn poissonCheckedFrom(source: anytype, lambda: f64) Error!u64 {
    const dist = try Poisson.init(lambda);
    return dist.sampleFrom(source);
}

pub fn fillPoisson(rng: Rng, dest: []u64, lambda: f64) void {
    fillPoissonFrom(rng, dest, lambda);
}

pub fn fillPoissonFrom(source: anytype, dest: []u64, lambda: f64) void {
    const dist = Poisson.init(lambda) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillPoissonChecked(rng: Rng, dest: []u64, lambda: f64) Error!void {
    return fillPoissonCheckedFrom(rng, dest, lambda);
}

pub fn fillPoissonCheckedFrom(source: anytype, dest: []u64, lambda: f64) Error!void {
    if (dest.len == 0) return;
    const dist = try Poisson.init(lambda);
    dist.fillFrom(source, dest);
}

pub fn vectorPoisson(rng: Rng, comptime VectorType: type, lambda: f64) VectorType {
    return vectorPoissonFrom(rng, VectorType, lambda);
}

pub fn vectorPoissonFrom(source: anytype, comptime VectorType: type, lambda: f64) VectorType {
    const dist = VectorPoisson(VectorType).init(lambda) catch unreachable;
    return dist.sampleFrom(source);
}

pub fn vectorPoissonChecked(rng: Rng, comptime VectorType: type, lambda: f64) Error!VectorType {
    return vectorPoissonCheckedFrom(rng, VectorType, lambda);
}

pub fn vectorPoissonCheckedFrom(source: anytype, comptime VectorType: type, lambda: f64) Error!VectorType {
    const dist = try VectorPoisson(VectorType).init(lambda);
    return dist.sampleFrom(source);
}

pub fn fillVectorPoisson(rng: Rng, comptime VectorType: type, dest: []VectorType, lambda: f64) void {
    fillVectorPoissonFrom(rng, VectorType, dest, lambda);
}

pub fn fillVectorPoissonFrom(source: anytype, comptime VectorType: type, dest: []VectorType, lambda: f64) void {
    const dist = VectorPoisson(VectorType).init(lambda) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillVectorPoissonChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, lambda: f64) Error!void {
    return fillVectorPoissonCheckedFrom(rng, VectorType, dest, lambda);
}

pub fn fillVectorPoissonCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, lambda: f64) Error!void {
    if (dest.len == 0) return;
    const dist = try VectorPoisson(VectorType).init(lambda);
    dist.fillFrom(source, dest);
}

pub const Poisson = struct {
    method: PoissonMethod,

    pub fn init(lambda: f64) Error!Poisson {
        if (!(lambda >= 0) or !std.math.isFinite(lambda)) return error.InvalidParameter;
        if (lambda == 0) return .{ .method = .zero };
        if (lambda < 12) return .{ .method = .{ .product = @exp(-lambda) } };
        return .{ .method = .{ .ahrens_dieter = PoissonAhrensDieter.init(lambda) } };
    }

    pub fn lambdaValue(self: Poisson) f64 {
        return switch (self.method) {
            .zero => 0,
            .product => |threshold| -@log(threshold),
            .ahrens_dieter => |method| method.lambda,
        };
    }

    pub fn expectedValue(self: Poisson) f64 {
        return self.lambdaValue();
    }

    pub fn varianceValue(self: Poisson) f64 {
        return self.lambdaValue();
    }

    pub fn minValue(self: Poisson) u64 {
        _ = self;
        return 0;
    }

    pub fn maxValue(self: Poisson) ?u64 {
        return if (self.lambdaValue() == 0) 0 else null;
    }

    pub fn sample(self: Poisson, rng: Rng) u64 {
        return self.sampleFrom(rng);
    }

    pub inline fn sampleFrom(self: Poisson, source: anytype) u64 {
        return switch (self.method) {
            .zero => 0,
            .product => |threshold| poissonProductFrom(source, threshold),
            .ahrens_dieter => |method| method.sampleFrom(source),
        };
    }

    pub fn fill(self: Poisson, rng: Rng, dest: []u64) void {
        self.fillFrom(rng, dest);
    }

    pub inline fn fillFrom(self: Poisson, source: anytype, dest: []u64) void {
        switch (self.method) {
            .zero => @memset(dest, 0),
            .product => |threshold| {
                for (dest) |*item| item.* = poissonProductFrom(source, threshold);
            },
            .ahrens_dieter => |method| {
                for (dest) |*item| item.* = method.sampleFrom(source);
            },
        }
    }
};

pub fn VectorPoisson(comptime VectorType: type) type {
    const info = vectorInfo(VectorType);
    if (info.child != u64) @compileError("VectorPoisson expects a u64 vector");

    return struct {
        const Self = @This();

        sampler: Poisson,

        pub fn init(lambda: f64) Error!Self {
            return .{ .sampler = try Poisson.init(lambda) };
        }

        pub fn lambdaValue(self: Self) f64 {
            return self.sampler.lambdaValue();
        }

        pub fn expectedValue(self: Self) f64 {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) f64 {
            return self.sampler.varianceValue();
        }

        pub fn minValue(self: Self) u64 {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?u64 {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..info.len) |lane| out[lane] = @intCast(self.sampler.sampleFrom(source));
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            if (self.sampler.lambdaValue() == 0) {
                @memset(dest, @as(VectorType, @splat(0)));
                return;
            }
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

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

    inline fn sampleFrom(self: PoissonAhrensDieter, source: anytype) u64 {
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
    return poissonAhrensDieterFrom(rng, lambda);
}

pub fn poissonAhrensDieterFrom(source: anytype, lambda: f64) u64 {
    std.debug.assert(lambda >= 12 and std.math.isFinite(lambda));
    return PoissonAhrensDieter.init(lambda).sampleFrom(source);
}

pub fn poissonAhrensDieterChecked(rng: Rng, lambda: f64) Error!u64 {
    return poissonAhrensDieterCheckedFrom(rng, lambda);
}

pub fn poissonAhrensDieterCheckedFrom(source: anytype, lambda: f64) Error!u64 {
    if (!(lambda >= 12) or !std.math.isFinite(lambda)) return error.InvalidParameter;
    return poissonAhrensDieterFrom(source, lambda);
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
    return geometricFrom(rng, p);
}

pub fn geometricFrom(source: anytype, p: f64) u64 {
    std.debug.assert(p > 0 and p <= 1);
    return geometricFailuresFrom(source, p) + 1;
}

pub fn geometricChecked(rng: Rng, p: f64) Error!u64 {
    return geometricCheckedFrom(rng, p);
}

pub fn geometricCheckedFrom(source: anytype, p: f64) Error!u64 {
    const dist = try Geometric.init(p);
    return dist.sampleFrom(source);
}

pub fn geometricFailures(rng: Rng, p: f64) u64 {
    return geometricFailuresFrom(rng, p);
}

pub fn geometricFailuresFrom(source: anytype, p: f64) u64 {
    std.debug.assert(p > 0 and p <= 1);
    if (p == 1) return 0;
    return @intFromFloat(@floor(@log(1 - Rng.floatOpenFrom(source, f64)) / @log(1 - p)));
}

pub fn geometricFailuresChecked(rng: Rng, p: f64) Error!u64 {
    return geometricFailuresCheckedFrom(rng, p);
}

pub fn geometricFailuresCheckedFrom(source: anytype, p: f64) Error!u64 {
    const dist = try GeometricFailures.init(p);
    return dist.sampleFrom(source);
}

pub fn fillGeometricFailures(rng: Rng, dest: []u64, p: f64) void {
    fillGeometricFailuresFrom(rng, dest, p);
}

pub fn fillGeometricFailuresFrom(source: anytype, dest: []u64, p: f64) void {
    const dist = GeometricFailures.init(p) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillGeometricFailuresChecked(rng: Rng, dest: []u64, p: f64) Error!void {
    return fillGeometricFailuresCheckedFrom(rng, dest, p);
}

pub fn fillGeometricFailuresCheckedFrom(source: anytype, dest: []u64, p: f64) Error!void {
    if (dest.len == 0) return;
    const dist = try GeometricFailures.init(p);
    dist.fillFrom(source, dest);
}

pub fn standardGeometric(rng: Rng) u64 {
    return standardGeometricFrom(rng);
}

pub fn standardGeometricFrom(source: anytype) u64 {
    var failures: u64 = 0;
    while (true) {
        const zeros = @clz(Rng.nextFrom(source));
        failures += zeros;
        if (zeros < 64) return failures;
    }
}

pub fn fillStandardGeometric(rng: Rng, dest: []u64) void {
    fillStandardGeometricFrom(rng, dest);
}

pub fn fillStandardGeometricFrom(source: anytype, dest: []u64) void {
    for (dest) |*item| item.* = standardGeometricFrom(source);
}

pub fn vectorStandardGeometric(rng: Rng, comptime VectorType: type) VectorType {
    return vectorStandardGeometricFrom(rng, VectorType);
}

pub fn vectorStandardGeometricFrom(source: anytype, comptime VectorType: type) VectorType {
    return (VectorStandardGeometric(VectorType){}).sampleFrom(source);
}

pub fn fillVectorStandardGeometric(rng: Rng, comptime VectorType: type, dest: []VectorType) void {
    fillVectorStandardGeometricFrom(rng, VectorType, dest);
}

pub fn fillVectorStandardGeometricFrom(source: anytype, comptime VectorType: type, dest: []VectorType) void {
    (VectorStandardGeometric(VectorType){}).fillFrom(source, dest);
}

pub fn fillGeometric(rng: Rng, dest: []u64, p: f64) void {
    fillGeometricFrom(rng, dest, p);
}

pub fn fillGeometricFrom(source: anytype, dest: []u64, p: f64) void {
    const dist = Geometric.init(p) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillGeometricChecked(rng: Rng, dest: []u64, p: f64) Error!void {
    return fillGeometricCheckedFrom(rng, dest, p);
}

pub fn fillGeometricCheckedFrom(source: anytype, dest: []u64, p: f64) Error!void {
    if (dest.len == 0) return;
    const dist = try Geometric.init(p);
    dist.fillFrom(source, dest);
}

pub fn vectorGeometric(rng: Rng, comptime VectorType: type, p: f64) VectorType {
    return vectorGeometricFrom(rng, VectorType, p);
}

pub fn vectorGeometricFrom(source: anytype, comptime VectorType: type, p: f64) VectorType {
    const dist = VectorGeometric(VectorType).init(p) catch unreachable;
    return dist.sampleFrom(source);
}

pub fn vectorGeometricChecked(rng: Rng, comptime VectorType: type, p: f64) Error!VectorType {
    return vectorGeometricCheckedFrom(rng, VectorType, p);
}

pub fn vectorGeometricCheckedFrom(source: anytype, comptime VectorType: type, p: f64) Error!VectorType {
    const dist = try VectorGeometric(VectorType).init(p);
    return dist.sampleFrom(source);
}

pub fn fillVectorGeometric(rng: Rng, comptime VectorType: type, dest: []VectorType, p: f64) void {
    fillVectorGeometricFrom(rng, VectorType, dest, p);
}

pub fn fillVectorGeometricFrom(source: anytype, comptime VectorType: type, dest: []VectorType, p: f64) void {
    const dist = VectorGeometric(VectorType).init(p) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillVectorGeometricChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, p: f64) Error!void {
    return fillVectorGeometricCheckedFrom(rng, VectorType, dest, p);
}

pub fn fillVectorGeometricCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, p: f64) Error!void {
    if (dest.len == 0) return;
    const dist = try VectorGeometric(VectorType).init(p);
    dist.fillFrom(source, dest);
}

pub const Geometric = struct {
    p: f64,

    pub fn init(p: f64) Error!Geometric {
        if (!(p > 0 and p <= 1)) return error.InvalidProbability;
        return .{ .p = p };
    }

    pub fn probabilityValue(self: Geometric) f64 {
        return self.p;
    }

    pub fn expectedValue(self: Geometric) f64 {
        return 1 / self.p;
    }

    pub fn varianceValue(self: Geometric) f64 {
        return (1 - self.p) / (self.p * self.p);
    }

    pub fn modeValue(self: Geometric) u64 {
        _ = self;
        return 1;
    }

    pub fn minValue(self: Geometric) u64 {
        _ = self;
        return 1;
    }

    pub fn maxValue(self: Geometric) ?u64 {
        _ = self;
        return null;
    }

    pub fn sample(self: Geometric, rng: Rng) u64 {
        return self.sampleFrom(rng);
    }

    pub fn sampleFrom(self: Geometric, source: anytype) u64 {
        return geometricFrom(source, self.p);
    }

    pub fn fill(self: Geometric, rng: Rng, dest: []u64) void {
        self.fillFrom(rng, dest);
    }

    pub fn fillFrom(self: Geometric, source: anytype, dest: []u64) void {
        for (dest) |*item| item.* = self.sampleFrom(source);
    }
};

pub fn VectorGeometric(comptime VectorType: type) type {
    const info = vectorInfo(VectorType);
    if (info.child != u64) @compileError("VectorGeometric expects a u64 vector");

    return struct {
        const Self = @This();

        sampler: Geometric,

        pub fn init(p: f64) Error!Self {
            return .{ .sampler = try Geometric.init(p) };
        }

        pub fn probabilityValue(self: Self) f64 {
            return self.sampler.probabilityValue();
        }

        pub fn expectedValue(self: Self) f64 {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) f64 {
            return self.sampler.varianceValue();
        }

        pub fn modeValue(self: Self) u64 {
            return self.sampler.modeValue();
        }

        pub fn minValue(self: Self) u64 {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) ?u64 {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..info.len) |lane| out[lane] = self.sampler.sampleFrom(source);
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            if (self.sampler.p == 1) {
                @memset(dest, @as(VectorType, @splat(1)));
                return;
            }
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub const GeometricFailures = struct {
    p: f64,

    pub fn init(p: f64) Error!GeometricFailures {
        if (!(p > 0 and p <= 1)) return error.InvalidProbability;
        return .{ .p = p };
    }

    pub fn probabilityValue(self: GeometricFailures) f64 {
        return self.p;
    }

    pub fn expectedValue(self: GeometricFailures) f64 {
        return (1 - self.p) / self.p;
    }

    pub fn varianceValue(self: GeometricFailures) f64 {
        return (1 - self.p) / (self.p * self.p);
    }

    pub fn modeValue(self: GeometricFailures) u64 {
        _ = self;
        return 0;
    }

    pub fn minValue(self: GeometricFailures) u64 {
        _ = self;
        return 0;
    }

    pub fn maxValue(self: GeometricFailures) ?u64 {
        _ = self;
        return null;
    }

    pub fn sample(self: GeometricFailures, rng: Rng) u64 {
        return self.sampleFrom(rng);
    }

    pub fn sampleFrom(self: GeometricFailures, source: anytype) u64 {
        return geometricFailuresFrom(source, self.p);
    }

    pub fn fill(self: GeometricFailures, rng: Rng, dest: []u64) void {
        self.fillFrom(rng, dest);
    }

    pub fn fillFrom(self: GeometricFailures, source: anytype, dest: []u64) void {
        for (dest) |*item| item.* = self.sampleFrom(source);
    }
};

pub fn vectorGeometricFailures(rng: Rng, comptime VectorType: type, p: f64) VectorType {
    return vectorGeometricFailuresFrom(rng, VectorType, p);
}

pub fn vectorGeometricFailuresFrom(source: anytype, comptime VectorType: type, p: f64) VectorType {
    const dist = VectorGeometricFailures(VectorType).init(p) catch unreachable;
    return dist.sampleFrom(source);
}

pub fn vectorGeometricFailuresChecked(rng: Rng, comptime VectorType: type, p: f64) Error!VectorType {
    return vectorGeometricFailuresCheckedFrom(rng, VectorType, p);
}

pub fn vectorGeometricFailuresCheckedFrom(source: anytype, comptime VectorType: type, p: f64) Error!VectorType {
    const dist = try VectorGeometricFailures(VectorType).init(p);
    return dist.sampleFrom(source);
}

pub fn fillVectorGeometricFailures(rng: Rng, comptime VectorType: type, dest: []VectorType, p: f64) void {
    fillVectorGeometricFailuresFrom(rng, VectorType, dest, p);
}

pub fn fillVectorGeometricFailuresFrom(source: anytype, comptime VectorType: type, dest: []VectorType, p: f64) void {
    const dist = VectorGeometricFailures(VectorType).init(p) catch unreachable;
    dist.fillFrom(source, dest);
}

pub fn fillVectorGeometricFailuresChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, p: f64) Error!void {
    return fillVectorGeometricFailuresCheckedFrom(rng, VectorType, dest, p);
}

pub fn fillVectorGeometricFailuresCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, p: f64) Error!void {
    if (dest.len == 0) return;
    const dist = try VectorGeometricFailures(VectorType).init(p);
    dist.fillFrom(source, dest);
}

pub fn VectorGeometricFailures(comptime VectorType: type) type {
    const info = vectorInfo(VectorType);
    if (info.child != u64) @compileError("VectorGeometricFailures expects a u64 vector");

    return struct {
        const Self = @This();

        sampler: GeometricFailures,

        pub fn init(p: f64) Error!Self {
            return .{ .sampler = try GeometricFailures.init(p) };
        }

        pub fn probabilityValue(self: Self) f64 {
            return self.sampler.probabilityValue();
        }

        pub fn expectedValue(self: Self) f64 {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) f64 {
            return self.sampler.varianceValue();
        }

        pub fn modeValue(self: Self) u64 {
            return self.sampler.modeValue();
        }

        pub fn minValue(self: Self) u64 {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) ?u64 {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..info.len) |lane| out[lane] = self.sampler.sampleFrom(source);
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            if (self.sampler.p == 1) {
                @memset(dest, @as(VectorType, @splat(0)));
                return;
            }
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn VectorStandardGeometric(comptime VectorType: type) type {
    const info = vectorInfo(VectorType);
    if (info.child != u64) @compileError("VectorStandardGeometric expects a u64 vector");

    return struct {
        const Self = @This();

        pub fn probabilityValue(self: Self) f64 {
            _ = self;
            return 0.5;
        }

        pub fn expectedValue(self: Self) f64 {
            _ = self;
            return 1;
        }

        pub fn varianceValue(self: Self) f64 {
            _ = self;
            return 2;
        }

        pub fn modeValue(self: Self) u64 {
            _ = self;
            return 0;
        }

        pub fn minValue(self: Self) u64 {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?u64 {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            _ = self;
            return vectorStandardGeometricFrom(rng, VectorType);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            _ = self;
            var out: VectorType = undefined;
            inline for (0..info.len) |lane| out[lane] = standardGeometricFrom(source);
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            _ = self;
            for (dest) |*item| item.* = vectorStandardGeometricFrom(source, VectorType);
        }
    };
}

pub const StandardGeometric = struct {
    pub fn probabilityValue(self: StandardGeometric) f64 {
        _ = self;
        return 0.5;
    }

    pub fn expectedValue(self: StandardGeometric) f64 {
        _ = self;
        return 1;
    }

    pub fn varianceValue(self: StandardGeometric) f64 {
        _ = self;
        return 2;
    }

    pub fn modeValue(self: StandardGeometric) u64 {
        _ = self;
        return 0;
    }

    pub fn minValue(self: StandardGeometric) u64 {
        _ = self;
        return 0;
    }

    pub fn maxValue(self: StandardGeometric) ?u64 {
        _ = self;
        return null;
    }

    pub fn sample(self: StandardGeometric, rng: Rng) u64 {
        _ = self;
        return standardGeometricFrom(rng);
    }

    pub fn sampleFrom(self: StandardGeometric, source: anytype) u64 {
        _ = self;
        return standardGeometricFrom(source);
    }

    pub fn fill(self: StandardGeometric, rng: Rng, dest: []u64) void {
        self.fillFrom(rng, dest);
    }

    pub fn fillFrom(self: StandardGeometric, source: anytype, dest: []u64) void {
        _ = self;
        for (dest) |*item| item.* = standardGeometricFrom(source);
    }
};

pub fn gamma(rng: Rng, comptime T: type, shape: T, scale: T) T {
    return gammaFrom(rng, T, shape, scale);
}

pub fn gammaChecked(rng: Rng, comptime T: type, shape: T, scale: T) Error!T {
    return gammaCheckedFrom(rng, T, shape, scale);
}

pub fn gammaCheckedFrom(source: anytype, comptime T: type, shape: T, scale: T) Error!T {
    const dist = try Gamma(T).init(shape, scale);
    return dist.sampleFrom(source);
}

pub fn gammaFrom(source: anytype, comptime T: type, shape: T, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(shape > 0 and scale > 0);

    if (shape < 1) {
        if (shape == 0.5) {
            const z = Rng.standardNormalFastFrom(source, T);
            return (scale * 0.5) * z * z;
        }

        const boosted = gammaFrom(source, T, shape + 1, 1);
        return scale * boosted * std.math.pow(T, Rng.floatFrom(source, T), 1 / shape);
    }

    if (shape == 1) return scale * Rng.standardExponentialFastFrom(source, T);

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

pub fn fillGamma(rng: Rng, comptime T: type, dest: []T, shape: T, scale: T) void {
    fillGammaFrom(rng, T, dest, shape, scale);
}

pub fn fillGammaFrom(source: anytype, comptime T: type, dest: []T, shape: T, scale: T) void {
    if (shape == 0.5) {
        const half_scale = scale * 0.5;
        for (dest) |*item| {
            const z = Rng.standardNormalFastFrom(source, T);
            item.* = half_scale * z * z;
        }
        return;
    }

    const sampler = Gamma(T).init(shape, scale) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillGammaChecked(rng: Rng, comptime T: type, dest: []T, shape: T, scale: T) Error!void {
    return fillGammaCheckedFrom(rng, T, dest, shape, scale);
}

pub fn fillGammaCheckedFrom(source: anytype, comptime T: type, dest: []T, shape: T, scale: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Gamma(T).init(shape, scale);
    sampler.fillFrom(source, dest);
}

pub fn vectorGamma(rng: Rng, comptime VectorType: type, shape: vectorChild(VectorType), scale: vectorChild(VectorType)) VectorType {
    return vectorGammaFrom(rng, VectorType, shape, scale);
}

pub fn vectorGammaFrom(source: anytype, comptime VectorType: type, shape: vectorChild(VectorType), scale: vectorChild(VectorType)) VectorType {
    const sampler = VectorGamma(VectorType).init(shape, scale) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn vectorGammaChecked(rng: Rng, comptime VectorType: type, shape: vectorChild(VectorType), scale: vectorChild(VectorType)) Error!VectorType {
    return vectorGammaCheckedFrom(rng, VectorType, shape, scale);
}

pub fn vectorGammaCheckedFrom(source: anytype, comptime VectorType: type, shape: vectorChild(VectorType), scale: vectorChild(VectorType)) Error!VectorType {
    const sampler = try VectorGamma(VectorType).init(shape, scale);
    return sampler.sampleFrom(source);
}

pub fn fillVectorGamma(rng: Rng, comptime VectorType: type, dest: []VectorType, shape: vectorChild(VectorType), scale: vectorChild(VectorType)) void {
    fillVectorGammaFrom(rng, VectorType, dest, shape, scale);
}

pub fn fillVectorGammaFrom(source: anytype, comptime VectorType: type, dest: []VectorType, shape: vectorChild(VectorType), scale: vectorChild(VectorType)) void {
    const sampler = VectorGamma(VectorType).init(shape, scale) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillVectorGammaChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, shape: vectorChild(VectorType), scale: vectorChild(VectorType)) Error!void {
    return fillVectorGammaCheckedFrom(rng, VectorType, dest, shape, scale);
}

pub fn fillVectorGammaCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, shape: vectorChild(VectorType), scale: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    const sampler = try VectorGamma(VectorType).init(shape, scale);
    sampler.fillFrom(source, dest);
}

pub fn VectorGamma(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        sampler: Gamma(Child),

        pub fn init(shape: Child, scale: Child) Error!Self {
            return .{ .sampler = try Gamma(Child).init(shape, scale) };
        }

        pub fn shapeValue(self: Self) Child {
            return self.sampler.shapeValue();
        }

        pub fn scaleValue(self: Self) Child {
            return self.sampler.scaleValue();
        }

        pub fn expectedValue(self: Self) Child {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) Child {
            return self.sampler.varianceValue();
        }

        pub fn modeValue(self: Self) Child {
            return self.sampler.modeValue();
        }

        pub fn minValue(self: Self) Child {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) ?Child {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..@typeInfo(VectorType).vector.len) |lane| out[lane] = self.sampler.sampleFrom(source);
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
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

        pub fn shapeValue(self: Self) T {
            return self.shape;
        }

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn expectedValue(self: Self) T {
            return self.shape * self.scale;
        }

        pub fn varianceValue(self: Self) T {
            return self.shape * self.scale * self.scale;
        }

        pub fn modeValue(self: Self) T {
            if (self.shape <= 1) return 0;
            return (self.shape - 1) * self.scale;
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            if (self.shape == 1) return self.scale * Rng.standardExponentialFastFrom(source, T);

            if (self.is_boosted) {
                return self.scale * self.sampleMarsaglia(source, self.boosted_d, self.boosted_c) *
                    std.math.pow(T, Rng.floatFrom(source, T), self.boost_inverse_shape);
            }

            return self.scale * self.sampleMarsaglia(source, self.d, self.c);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
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
    return chiSquaredFrom(rng, T, dof);
}

pub fn chiSquaredChecked(rng: Rng, comptime T: type, dof: T) Error!T {
    return chiSquaredCheckedFrom(rng, T, dof);
}

pub fn chiSquaredCheckedFrom(source: anytype, comptime T: type, dof: T) Error!T {
    const dist = try ChiSquared(T).init(dof);
    return dist.sampleFrom(source);
}

pub fn chiSquaredFrom(source: anytype, comptime T: type, dof: T) T {
    comptime requireFloat(T);
    std.debug.assert(dof > 0);
    return gammaFrom(source, T, dof / 2, 2);
}

pub fn fillChiSquared(rng: Rng, comptime T: type, dest: []T, dof: T) void {
    fillChiSquaredFrom(rng, T, dest, dof);
}

pub fn fillChiSquaredFrom(source: anytype, comptime T: type, dest: []T, dof: T) void {
    if (dof == 1) {
        for (dest) |*item| {
            const z = Rng.standardNormalFastFrom(source, T);
            item.* = z * z;
        }
        return;
    }

    const sampler = ChiSquared(T).init(dof) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillChiSquaredChecked(rng: Rng, comptime T: type, dest: []T, dof: T) Error!void {
    return fillChiSquaredCheckedFrom(rng, T, dest, dof);
}

pub fn fillChiSquaredCheckedFrom(source: anytype, comptime T: type, dest: []T, dof: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try ChiSquared(T).init(dof);
    sampler.fillFrom(source, dest);
}

pub fn vectorChiSquared(rng: Rng, comptime VectorType: type, dof: vectorChild(VectorType)) VectorType {
    return vectorChiSquaredFrom(rng, VectorType, dof);
}

pub fn vectorChiSquaredFrom(source: anytype, comptime VectorType: type, dof: vectorChild(VectorType)) VectorType {
    const sampler = VectorChiSquared(VectorType).init(dof) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn vectorChiSquaredChecked(rng: Rng, comptime VectorType: type, dof: vectorChild(VectorType)) Error!VectorType {
    return vectorChiSquaredCheckedFrom(rng, VectorType, dof);
}

pub fn vectorChiSquaredCheckedFrom(source: anytype, comptime VectorType: type, dof: vectorChild(VectorType)) Error!VectorType {
    const sampler = try VectorChiSquared(VectorType).init(dof);
    return sampler.sampleFrom(source);
}

pub fn fillVectorChiSquared(rng: Rng, comptime VectorType: type, dest: []VectorType, dof: vectorChild(VectorType)) void {
    fillVectorChiSquaredFrom(rng, VectorType, dest, dof);
}

pub fn fillVectorChiSquaredFrom(source: anytype, comptime VectorType: type, dest: []VectorType, dof: vectorChild(VectorType)) void {
    const sampler = VectorChiSquared(VectorType).init(dof) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillVectorChiSquaredChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, dof: vectorChild(VectorType)) Error!void {
    return fillVectorChiSquaredCheckedFrom(rng, VectorType, dest, dof);
}

pub fn fillVectorChiSquaredCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, dof: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    const sampler = try VectorChiSquared(VectorType).init(dof);
    sampler.fillFrom(source, dest);
}

pub fn VectorChiSquared(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        sampler: ChiSquared(Child),

        pub fn init(dof: Child) Error!Self {
            return .{ .sampler = try ChiSquared(Child).init(dof) };
        }

        pub fn dofValue(self: Self) Child {
            return self.sampler.dofValue();
        }

        pub fn expectedValue(self: Self) Child {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) Child {
            return self.sampler.varianceValue();
        }

        pub fn modeValue(self: Self) Child {
            return self.sampler.modeValue();
        }

        pub fn minValue(self: Self) Child {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) ?Child {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..@typeInfo(VectorType).vector.len) |lane| out[lane] = self.sampler.sampleFrom(source);
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
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

        pub fn dofValue(self: Self) T {
            return self.dof;
        }

        pub fn expectedValue(self: Self) T {
            return self.dof;
        }

        pub fn varianceValue(self: Self) T {
            return 2 * self.dof;
        }

        pub fn modeValue(self: Self) T {
            if (self.dof <= 2) return 0;
            return self.dof - 2;
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return self.gamma_sampler.sampleFrom(source);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn chi(rng: Rng, comptime T: type, dof: T) T {
    return chiFrom(rng, T, dof);
}

pub fn chiChecked(rng: Rng, comptime T: type, dof: T) Error!T {
    return chiCheckedFrom(rng, T, dof);
}

pub fn chiCheckedFrom(source: anytype, comptime T: type, dof: T) Error!T {
    const dist = try Chi(T).init(dof);
    return dist.sampleFrom(source);
}

pub fn chiFrom(source: anytype, comptime T: type, dof: T) T {
    comptime requireFloat(T);
    std.debug.assert(dof > 0);
    if (dof == 1) return @abs(Rng.standardNormalFastFrom(source, T));
    return @sqrt(chiSquaredFrom(source, T, dof));
}

pub fn fillChi(rng: Rng, comptime T: type, dest: []T, dof: T) void {
    fillChiFrom(rng, T, dest, dof);
}

pub fn fillChiFrom(source: anytype, comptime T: type, dest: []T, dof: T) void {
    if (dof == 1) {
        for (dest) |*item| item.* = @abs(Rng.standardNormalFastFrom(source, T));
        return;
    }

    const sampler = Chi(T).init(dof) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillChiChecked(rng: Rng, comptime T: type, dest: []T, dof: T) Error!void {
    return fillChiCheckedFrom(rng, T, dest, dof);
}

pub fn fillChiCheckedFrom(source: anytype, comptime T: type, dest: []T, dof: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Chi(T).init(dof);
    sampler.fillFrom(source, dest);
}

pub fn vectorChi(rng: Rng, comptime VectorType: type, dof: vectorChild(VectorType)) VectorType {
    return vectorChiFrom(rng, VectorType, dof);
}

pub fn vectorChiFrom(source: anytype, comptime VectorType: type, dof: vectorChild(VectorType)) VectorType {
    const sampler = VectorChi(VectorType).init(dof) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn vectorChiChecked(rng: Rng, comptime VectorType: type, dof: vectorChild(VectorType)) Error!VectorType {
    return vectorChiCheckedFrom(rng, VectorType, dof);
}

pub fn vectorChiCheckedFrom(source: anytype, comptime VectorType: type, dof: vectorChild(VectorType)) Error!VectorType {
    const sampler = try VectorChi(VectorType).init(dof);
    return sampler.sampleFrom(source);
}

pub fn fillVectorChi(rng: Rng, comptime VectorType: type, dest: []VectorType, dof: vectorChild(VectorType)) void {
    fillVectorChiFrom(rng, VectorType, dest, dof);
}

pub fn fillVectorChiFrom(source: anytype, comptime VectorType: type, dest: []VectorType, dof: vectorChild(VectorType)) void {
    const sampler = VectorChi(VectorType).init(dof) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillVectorChiChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, dof: vectorChild(VectorType)) Error!void {
    return fillVectorChiCheckedFrom(rng, VectorType, dest, dof);
}

pub fn fillVectorChiCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, dof: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    const sampler = try VectorChi(VectorType).init(dof);
    sampler.fillFrom(source, dest);
}

pub fn VectorChi(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        sampler: Chi(Child),

        pub fn init(dof: Child) Error!Self {
            return .{ .sampler = try Chi(Child).init(dof) };
        }

        pub fn dofValue(self: Self) Child {
            return self.sampler.dofValue();
        }

        pub fn expectedValue(self: Self) Child {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) Child {
            return self.sampler.varianceValue();
        }

        pub fn modeValue(self: Self) Child {
            return self.sampler.modeValue();
        }

        pub fn minValue(self: Self) Child {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) ?Child {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..@typeInfo(VectorType).vector.len) |lane| out[lane] = self.sampler.sampleFrom(source);
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn Chi(comptime T: type) type {
    return struct {
        const Self = @This();

        chi_squared_sampler: ChiSquared(T),

        pub fn init(dof: T) Error!Self {
            return .{ .chi_squared_sampler = try ChiSquared(T).init(dof) };
        }

        pub fn dofValue(self: Self) T {
            return self.chi_squared_sampler.dofValue();
        }

        pub fn expectedValue(self: Self) T {
            const dof = self.dofValue();
            const half = dof / 2;
            return @exp(@log(@as(T, 2)) / 2 + std.math.lgamma(T, (dof + 1) / 2) - std.math.lgamma(T, half));
        }

        pub fn varianceValue(self: Self) T {
            const mean = self.expectedValue();
            return self.dofValue() - mean * mean;
        }

        pub fn modeValue(self: Self) T {
            const dof = self.dofValue();
            if (dof <= 1) return 0;
            return @sqrt(dof - 1);
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return @sqrt(self.chi_squared_sampler.sampleFrom(source));
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn erlang(rng: Rng, comptime T: type, shape: u64, scale: T) T {
    return erlangFrom(rng, T, shape, scale);
}

pub fn erlangChecked(rng: Rng, comptime T: type, shape: u64, scale: T) Error!T {
    return erlangCheckedFrom(rng, T, shape, scale);
}

pub fn erlangCheckedFrom(source: anytype, comptime T: type, shape: u64, scale: T) Error!T {
    const dist = try Erlang(T).init(shape, scale);
    return dist.sampleFrom(source);
}

pub fn erlangFrom(source: anytype, comptime T: type, shape: u64, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(shape > 0 and scale > 0);
    return gammaFrom(source, T, @as(T, @floatFromInt(shape)), scale);
}

pub fn fillErlang(rng: Rng, comptime T: type, dest: []T, shape: u64, scale: T) void {
    fillErlangFrom(rng, T, dest, shape, scale);
}

pub fn fillErlangFrom(source: anytype, comptime T: type, dest: []T, shape: u64, scale: T) void {
    const sampler = Erlang(T).init(shape, scale) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillErlangChecked(rng: Rng, comptime T: type, dest: []T, shape: u64, scale: T) Error!void {
    return fillErlangCheckedFrom(rng, T, dest, shape, scale);
}

pub fn fillErlangCheckedFrom(source: anytype, comptime T: type, dest: []T, shape: u64, scale: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Erlang(T).init(shape, scale);
    sampler.fillFrom(source, dest);
}

pub fn vectorErlang(rng: Rng, comptime VectorType: type, shape: u64, scale: vectorChild(VectorType)) VectorType {
    return vectorErlangFrom(rng, VectorType, shape, scale);
}

pub fn vectorErlangFrom(source: anytype, comptime VectorType: type, shape: u64, scale: vectorChild(VectorType)) VectorType {
    const sampler = VectorErlang(VectorType).init(shape, scale) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn vectorErlangChecked(rng: Rng, comptime VectorType: type, shape: u64, scale: vectorChild(VectorType)) Error!VectorType {
    return vectorErlangCheckedFrom(rng, VectorType, shape, scale);
}

pub fn vectorErlangCheckedFrom(source: anytype, comptime VectorType: type, shape: u64, scale: vectorChild(VectorType)) Error!VectorType {
    const sampler = try VectorErlang(VectorType).init(shape, scale);
    return sampler.sampleFrom(source);
}

pub fn fillVectorErlang(rng: Rng, comptime VectorType: type, dest: []VectorType, shape: u64, scale: vectorChild(VectorType)) void {
    fillVectorErlangFrom(rng, VectorType, dest, shape, scale);
}

pub fn fillVectorErlangFrom(source: anytype, comptime VectorType: type, dest: []VectorType, shape: u64, scale: vectorChild(VectorType)) void {
    const sampler = VectorErlang(VectorType).init(shape, scale) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillVectorErlangChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, shape: u64, scale: vectorChild(VectorType)) Error!void {
    return fillVectorErlangCheckedFrom(rng, VectorType, dest, shape, scale);
}

pub fn fillVectorErlangCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, shape: u64, scale: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    const sampler = try VectorErlang(VectorType).init(shape, scale);
    sampler.fillFrom(source, dest);
}

pub fn VectorErlang(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        sampler: Erlang(Child),

        pub fn init(shape: u64, scale: Child) Error!Self {
            return .{ .sampler = try Erlang(Child).init(shape, scale) };
        }

        pub fn shapeValue(self: Self) u64 {
            return self.sampler.shapeValue();
        }

        pub fn scaleValue(self: Self) Child {
            return self.sampler.scaleValue();
        }

        pub fn expectedValue(self: Self) Child {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) Child {
            return self.sampler.varianceValue();
        }

        pub fn modeValue(self: Self) Child {
            return self.sampler.modeValue();
        }

        pub fn minValue(self: Self) Child {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) ?Child {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..@typeInfo(VectorType).vector.len) |lane| out[lane] = self.sampler.sampleFrom(source);
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn Erlang(comptime T: type) type {
    return struct {
        const Self = @This();

        shape: u64,
        gamma_sampler: Gamma(T),

        pub fn init(shape: u64, scale: T) Error!Self {
            comptime requireFloat(T);
            if (shape == 0) return error.InvalidParameter;
            if (!(scale > 0) or !std.math.isFinite(scale)) return error.InvalidParameter;
            return .{
                .shape = shape,
                .gamma_sampler = try Gamma(T).init(@as(T, @floatFromInt(shape)), scale),
            };
        }

        pub fn shapeValue(self: Self) u64 {
            return self.shape;
        }

        pub fn scaleValue(self: Self) T {
            return self.gamma_sampler.scaleValue();
        }

        pub fn expectedValue(self: Self) T {
            return @as(T, @floatFromInt(self.shape)) * self.scaleValue();
        }

        pub fn varianceValue(self: Self) T {
            const scale = self.scaleValue();
            return @as(T, @floatFromInt(self.shape)) * scale * scale;
        }

        pub fn modeValue(self: Self) T {
            return @as(T, @floatFromInt(self.shape - 1)) * self.scaleValue();
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return self.gamma_sampler.sampleFrom(source);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn beta(rng: Rng, comptime T: type, alpha: T, beta_param: T) T {
    return betaFrom(rng, T, alpha, beta_param);
}

pub fn betaChecked(rng: Rng, comptime T: type, alpha: T, beta_param: T) Error!T {
    return betaCheckedFrom(rng, T, alpha, beta_param);
}

pub fn betaCheckedFrom(source: anytype, comptime T: type, alpha: T, beta_param: T) Error!T {
    const dist = try Beta(T).init(alpha, beta_param);
    return dist.sampleFrom(source);
}

pub fn betaFrom(source: anytype, comptime T: type, alpha: T, beta_param: T) T {
    comptime requireFloat(T);
    if (alpha == 1 and beta_param == 1) return Rng.floatFrom(source, T);
    if (alpha == 2 and beta_param == 1) return @sqrt(Rng.floatOpenFrom(source, T));
    if (alpha == 1 and beta_param == 2) return 1 - @sqrt(Rng.floatOpenFrom(source, T));
    if (beta_param == 1) return std.math.pow(T, Rng.floatOpenFrom(source, T), 1 / alpha);

    const x = gammaFrom(source, T, alpha, 1);
    const y = gammaFrom(source, T, beta_param, 1);
    return x / (x + y);
}

pub fn fillBeta(rng: Rng, comptime T: type, dest: []T, alpha: T, beta_param: T) void {
    fillBetaFrom(rng, T, dest, alpha, beta_param);
}

pub fn fillBetaFrom(source: anytype, comptime T: type, dest: []T, alpha: T, beta_param: T) void {
    if (alpha == 1 and beta_param == 1) {
        Rng.fillFrom(source, T, dest);
        return;
    }
    if (alpha == 2 and beta_param == 1) {
        Rng.fillOpenFrom(source, T, dest);
        for (dest) |*item| item.* = @sqrt(item.*);
        return;
    }
    if (alpha == 1 and beta_param == 2) {
        Rng.fillOpenFrom(source, T, dest);
        for (dest) |*item| item.* = 1 - @sqrt(item.*);
        return;
    }
    if (beta_param == 1) {
        Rng.fillOpenFrom(source, T, dest);
        const inverse_alpha = 1 / alpha;
        for (dest) |*item| item.* = std.math.pow(T, item.*, inverse_alpha);
        return;
    }

    const sampler = Beta(T).init(alpha, beta_param) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillBetaChecked(rng: Rng, comptime T: type, dest: []T, alpha: T, beta_param: T) Error!void {
    return fillBetaCheckedFrom(rng, T, dest, alpha, beta_param);
}

pub fn fillBetaCheckedFrom(source: anytype, comptime T: type, dest: []T, alpha: T, beta_param: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Beta(T).init(alpha, beta_param);
    sampler.fillFrom(source, dest);
}

pub fn vectorBeta(rng: Rng, comptime VectorType: type, alpha: vectorChild(VectorType), beta_param: vectorChild(VectorType)) VectorType {
    return vectorBetaFrom(rng, VectorType, alpha, beta_param);
}

pub fn vectorBetaFrom(source: anytype, comptime VectorType: type, alpha: vectorChild(VectorType), beta_param: vectorChild(VectorType)) VectorType {
    const sampler = VectorBeta(VectorType).init(alpha, beta_param) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn vectorBetaChecked(rng: Rng, comptime VectorType: type, alpha: vectorChild(VectorType), beta_param: vectorChild(VectorType)) Error!VectorType {
    return vectorBetaCheckedFrom(rng, VectorType, alpha, beta_param);
}

pub fn vectorBetaCheckedFrom(source: anytype, comptime VectorType: type, alpha: vectorChild(VectorType), beta_param: vectorChild(VectorType)) Error!VectorType {
    const sampler = try VectorBeta(VectorType).init(alpha, beta_param);
    return sampler.sampleFrom(source);
}

pub fn fillVectorBeta(rng: Rng, comptime VectorType: type, dest: []VectorType, alpha: vectorChild(VectorType), beta_param: vectorChild(VectorType)) void {
    fillVectorBetaFrom(rng, VectorType, dest, alpha, beta_param);
}

pub fn fillVectorBetaFrom(source: anytype, comptime VectorType: type, dest: []VectorType, alpha: vectorChild(VectorType), beta_param: vectorChild(VectorType)) void {
    const sampler = VectorBeta(VectorType).init(alpha, beta_param) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillVectorBetaChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, alpha: vectorChild(VectorType), beta_param: vectorChild(VectorType)) Error!void {
    return fillVectorBetaCheckedFrom(rng, VectorType, dest, alpha, beta_param);
}

pub fn fillVectorBetaCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, alpha: vectorChild(VectorType), beta_param: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    const sampler = try VectorBeta(VectorType).init(alpha, beta_param);
    sampler.fillFrom(source, dest);
}

pub fn VectorBeta(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        sampler: Beta(Child),

        pub fn init(alpha: Child, beta_param: Child) Error!Self {
            return .{ .sampler = try Beta(Child).init(alpha, beta_param) };
        }

        pub fn alphaValue(self: Self) Child {
            return self.sampler.alphaValue();
        }

        pub fn betaValue(self: Self) Child {
            return self.sampler.betaValue();
        }

        pub fn expectedValue(self: Self) Child {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) Child {
            return self.sampler.varianceValue();
        }

        pub fn modeValue(self: Self) ?Child {
            return self.sampler.modeValue();
        }

        pub fn minValue(self: Self) Child {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) Child {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..@typeInfo(VectorType).vector.len) |lane| out[lane] = self.sampler.sampleFrom(source);
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn Beta(comptime T: type) type {
    return struct {
        const Self = @This();
        const Method = enum { generic, uniform, sqrt_alpha, sqrt_beta };

        alpha: T,
        beta_param: T,
        gamma_a: Gamma(T),
        gamma_b: Gamma(T),
        method: Method,

        pub fn init(alpha: T, beta_param: T) Error!Self {
            comptime requireFloat(T);
            if (!(alpha > 0) or !(beta_param > 0)) return error.InvalidParameter;
            if (!std.math.isFinite(alpha) or !std.math.isFinite(beta_param)) return error.InvalidParameter;
            return .{
                .alpha = alpha,
                .beta_param = beta_param,
                .gamma_a = try Gamma(T).init(alpha, 1),
                .gamma_b = try Gamma(T).init(beta_param, 1),
                .method = if (alpha == 1 and beta_param == 1)
                    .uniform
                else if (alpha == 2 and beta_param == 1)
                    .sqrt_alpha
                else if (alpha == 1 and beta_param == 2)
                    .sqrt_beta
                else
                    .generic,
            };
        }

        pub fn alphaValue(self: Self) T {
            return self.alpha;
        }

        pub fn betaValue(self: Self) T {
            return self.beta_param;
        }

        pub fn expectedValue(self: Self) T {
            return self.alpha / (self.alpha + self.beta_param);
        }

        pub fn varianceValue(self: Self) T {
            const total = self.alpha + self.beta_param;
            return self.alpha * self.beta_param / (total * total * (total + 1));
        }

        pub fn modeValue(self: Self) ?T {
            if (self.alpha > 1 and self.beta_param > 1) {
                return (self.alpha - 1) / (self.alpha + self.beta_param - 2);
            }
            if (self.alpha < 1 and self.beta_param < 1) return null;
            if (self.alpha == 1 and self.beta_param == 1) return null;
            if (self.alpha <= 1) return 0;
            return 1;
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) T {
            _ = self;
            return 1;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            switch (self.method) {
                .uniform => return Rng.floatFrom(source, T),
                .sqrt_alpha => return @sqrt(Rng.floatOpenFrom(source, T)),
                .sqrt_beta => return 1 - @sqrt(Rng.floatOpenFrom(source, T)),
                .generic => {},
            }

            const x = self.gamma_a.sampleFrom(source);
            const y = self.gamma_b.sampleFrom(source);
            return x / (x + y);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            switch (self.method) {
                .uniform => {
                    Rng.fillFrom(source, T, dest);
                    return;
                },
                .sqrt_alpha => {
                    Rng.fillOpenFrom(source, T, dest);
                    for (dest) |*item| item.* = @sqrt(item.*);
                    return;
                },
                .sqrt_beta => {
                    Rng.fillOpenFrom(source, T, dest);
                    for (dest) |*item| item.* = 1 - @sqrt(item.*);
                    return;
                },
                .generic => {},
            }

            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn fisherF(rng: Rng, comptime T: type, d1: T, d2: T) T {
    return fisherFFrom(rng, T, d1, d2);
}

pub fn fisherFChecked(rng: Rng, comptime T: type, d1: T, d2: T) Error!T {
    return fisherFCheckedFrom(rng, T, d1, d2);
}

pub fn fisherFCheckedFrom(source: anytype, comptime T: type, d1: T, d2: T) Error!T {
    const dist = try FisherF(T).init(d1, d2);
    return dist.sampleFrom(source);
}

pub fn fisherFFrom(source: anytype, comptime T: type, d1: T, d2: T) T {
    comptime requireFloat(T);
    std.debug.assert(d1 > 0 and d2 > 0);
    const x = chiSquaredFrom(source, T, d1) / d1;
    const y = chiSquaredFrom(source, T, d2) / d2;
    return x / y;
}

pub fn fillFisherF(rng: Rng, comptime T: type, dest: []T, d1: T, d2: T) void {
    fillFisherFFrom(rng, T, dest, d1, d2);
}

pub fn fillFisherFFrom(source: anytype, comptime T: type, dest: []T, d1: T, d2: T) void {
    const sampler = FisherF(T).init(d1, d2) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillFisherFChecked(rng: Rng, comptime T: type, dest: []T, d1: T, d2: T) Error!void {
    return fillFisherFCheckedFrom(rng, T, dest, d1, d2);
}

pub fn fillFisherFCheckedFrom(source: anytype, comptime T: type, dest: []T, d1: T, d2: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try FisherF(T).init(d1, d2);
    sampler.fillFrom(source, dest);
}

pub fn vectorFisherF(rng: Rng, comptime VectorType: type, d1: vectorChild(VectorType), d2: vectorChild(VectorType)) VectorType {
    return vectorFisherFFrom(rng, VectorType, d1, d2);
}

pub fn vectorFisherFFrom(source: anytype, comptime VectorType: type, d1: vectorChild(VectorType), d2: vectorChild(VectorType)) VectorType {
    const sampler = VectorFisherF(VectorType).init(d1, d2) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn vectorFisherFChecked(rng: Rng, comptime VectorType: type, d1: vectorChild(VectorType), d2: vectorChild(VectorType)) Error!VectorType {
    return vectorFisherFCheckedFrom(rng, VectorType, d1, d2);
}

pub fn vectorFisherFCheckedFrom(source: anytype, comptime VectorType: type, d1: vectorChild(VectorType), d2: vectorChild(VectorType)) Error!VectorType {
    const sampler = try VectorFisherF(VectorType).init(d1, d2);
    return sampler.sampleFrom(source);
}

pub fn fillVectorFisherF(rng: Rng, comptime VectorType: type, dest: []VectorType, d1: vectorChild(VectorType), d2: vectorChild(VectorType)) void {
    fillVectorFisherFFrom(rng, VectorType, dest, d1, d2);
}

pub fn fillVectorFisherFFrom(source: anytype, comptime VectorType: type, dest: []VectorType, d1: vectorChild(VectorType), d2: vectorChild(VectorType)) void {
    const sampler = VectorFisherF(VectorType).init(d1, d2) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillVectorFisherFChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, d1: vectorChild(VectorType), d2: vectorChild(VectorType)) Error!void {
    return fillVectorFisherFCheckedFrom(rng, VectorType, dest, d1, d2);
}

pub fn fillVectorFisherFCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, d1: vectorChild(VectorType), d2: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    const sampler = try VectorFisherF(VectorType).init(d1, d2);
    sampler.fillFrom(source, dest);
}

pub fn VectorFisherF(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        sampler: FisherF(Child),

        pub fn init(d1: Child, d2: Child) Error!Self {
            return .{ .sampler = try FisherF(Child).init(d1, d2) };
        }

        pub fn d1Value(self: Self) Child {
            return self.sampler.d1Value();
        }

        pub fn d2Value(self: Self) Child {
            return self.sampler.d2Value();
        }

        pub fn expectedValue(self: Self) ?Child {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) ?Child {
            return self.sampler.varianceValue();
        }

        pub fn minValue(self: Self) Child {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) ?Child {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..@typeInfo(VectorType).vector.len) |lane| out[lane] = self.sampler.sampleFrom(source);
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
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

        pub fn d1Value(self: Self) T {
            return self.d1;
        }

        pub fn d2Value(self: Self) T {
            return self.d2;
        }

        pub fn expectedValue(self: Self) ?T {
            if (self.d2 <= 2) return null;
            return self.d2 / (self.d2 - 2);
        }

        pub fn varianceValue(self: Self) ?T {
            if (self.d2 <= 4) return null;
            const numerator = 2 * self.d2 * self.d2 * (self.d1 + self.d2 - 2);
            const denominator = self.d1 * (self.d2 - 2) * (self.d2 - 2) * (self.d2 - 4);
            return numerator / denominator;
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return self.numerator.sampleFrom(source) / self.denominator.sampleFrom(source);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn studentT(rng: Rng, comptime T: type, dof: T) T {
    return studentTFrom(rng, T, dof);
}

pub fn studentTChecked(rng: Rng, comptime T: type, dof: T) Error!T {
    return studentTCheckedFrom(rng, T, dof);
}

pub fn studentTCheckedFrom(source: anytype, comptime T: type, dof: T) Error!T {
    const dist = try StudentT(T).init(dof);
    return dist.sampleFrom(source);
}

pub fn studentTFrom(source: anytype, comptime T: type, dof: T) T {
    comptime requireFloat(T);
    std.debug.assert(dof > 0);
    return Rng.normalFastFrom(source, T, 0, 1) * @sqrt(dof / chiSquaredFrom(source, T, dof));
}

pub fn fillStudentT(rng: Rng, comptime T: type, dest: []T, dof: T) void {
    fillStudentTFrom(rng, T, dest, dof);
}

pub fn fillStudentTFrom(source: anytype, comptime T: type, dest: []T, dof: T) void {
    const sampler = StudentT(T).init(dof) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillStudentTChecked(rng: Rng, comptime T: type, dest: []T, dof: T) Error!void {
    return fillStudentTCheckedFrom(rng, T, dest, dof);
}

pub fn fillStudentTCheckedFrom(source: anytype, comptime T: type, dest: []T, dof: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try StudentT(T).init(dof);
    sampler.fillFrom(source, dest);
}

pub fn vectorStudentT(rng: Rng, comptime VectorType: type, dof: vectorChild(VectorType)) VectorType {
    return vectorStudentTFrom(rng, VectorType, dof);
}

pub fn vectorStudentTFrom(source: anytype, comptime VectorType: type, dof: vectorChild(VectorType)) VectorType {
    const sampler = VectorStudentT(VectorType).init(dof) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn vectorStudentTChecked(rng: Rng, comptime VectorType: type, dof: vectorChild(VectorType)) Error!VectorType {
    return vectorStudentTCheckedFrom(rng, VectorType, dof);
}

pub fn vectorStudentTCheckedFrom(source: anytype, comptime VectorType: type, dof: vectorChild(VectorType)) Error!VectorType {
    const sampler = try VectorStudentT(VectorType).init(dof);
    return sampler.sampleFrom(source);
}

pub fn fillVectorStudentT(rng: Rng, comptime VectorType: type, dest: []VectorType, dof: vectorChild(VectorType)) void {
    fillVectorStudentTFrom(rng, VectorType, dest, dof);
}

pub fn fillVectorStudentTFrom(source: anytype, comptime VectorType: type, dest: []VectorType, dof: vectorChild(VectorType)) void {
    const sampler = VectorStudentT(VectorType).init(dof) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillVectorStudentTChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, dof: vectorChild(VectorType)) Error!void {
    return fillVectorStudentTCheckedFrom(rng, VectorType, dest, dof);
}

pub fn fillVectorStudentTCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, dof: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    const sampler = try VectorStudentT(VectorType).init(dof);
    sampler.fillFrom(source, dest);
}

pub fn VectorStudentT(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        sampler: StudentT(Child),

        pub fn init(dof: Child) Error!Self {
            return .{ .sampler = try StudentT(Child).init(dof) };
        }

        pub fn dofValue(self: Self) Child {
            return self.sampler.dofValue();
        }

        pub fn expectedValue(self: Self) ?Child {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) ?Child {
            return self.sampler.varianceValue();
        }

        pub fn minValue(self: Self) ?Child {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) ?Child {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            var out: VectorType = undefined;
            inline for (0..@typeInfo(VectorType).vector.len) |lane| out[lane] = self.sampler.sampleFrom(source);
            return out;
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
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

        pub fn dofValue(self: Self) T {
            return self.dof;
        }

        pub fn expectedValue(self: Self) ?T {
            if (self.dof <= 1) return null;
            return 0;
        }

        pub fn varianceValue(self: Self) ?T {
            if (self.dof <= 2) return null;
            return self.dof / (self.dof - 2);
        }

        pub fn minValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return Rng.normalFastFrom(source, T, 0, 1) * @sqrt(self.dof / self.chi_squared_sampler.sampleFrom(source));
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn triangular(rng: Rng, comptime T: type, min: T, mode: T, max: T) T {
    return triangularFrom(rng, T, min, mode, max);
}

pub fn triangularChecked(rng: Rng, comptime T: type, min: T, mode: T, max: T) Error!T {
    return triangularCheckedFrom(rng, T, min, mode, max);
}

pub fn triangularCheckedFrom(source: anytype, comptime T: type, min: T, mode: T, max: T) Error!T {
    const dist = try Triangular(T).init(min, mode, max);
    return dist.sampleFrom(source);
}

pub fn triangularFrom(source: anytype, comptime T: type, min: T, mode: T, max: T) T {
    comptime requireFloat(T);
    std.debug.assert(min <= mode and mode <= max and min < max);

    const u = Rng.floatFrom(source, T);
    const c = (mode - min) / (max - min);
    if (u < c) {
        return min + @sqrt(u * (max - min) * (mode - min));
    }
    return max - @sqrt((1 - u) * (max - min) * (max - mode));
}

pub fn fillTriangular(rng: Rng, comptime T: type, dest: []T, min: T, mode: T, max: T) void {
    fillTriangularFrom(rng, T, dest, min, mode, max);
}

pub fn fillTriangularFrom(source: anytype, comptime T: type, dest: []T, min: T, mode: T, max: T) void {
    comptime requireFloat(T);
    std.debug.assert(min <= mode and mode <= max and min < max);
    Rng.fillFrom(source, T, dest);
    triangularFromUniforms(T, dest, min, mode, max);
}

pub fn fillTriangularChecked(rng: Rng, comptime T: type, dest: []T, min: T, mode: T, max: T) Error!void {
    return fillTriangularCheckedFrom(rng, T, dest, min, mode, max);
}

pub fn fillTriangularCheckedFrom(source: anytype, comptime T: type, dest: []T, min: T, mode: T, max: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Triangular(T).init(min, mode, max);
    sampler.fillFrom(source, dest);
}

pub fn vectorTriangular(rng: Rng, comptime VectorType: type, min: vectorChild(VectorType), mode: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    return vectorTriangularFrom(rng, VectorType, min, mode, max);
}

pub fn vectorTriangularFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), mode: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    const sampler = VectorTriangular(VectorType).init(min, mode, max) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn vectorTriangularChecked(rng: Rng, comptime VectorType: type, min: vectorChild(VectorType), mode: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    return vectorTriangularCheckedFrom(rng, VectorType, min, mode, max);
}

pub fn vectorTriangularCheckedFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), mode: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    const sampler = try VectorTriangular(VectorType).init(min, mode, max);
    return sampler.sampleFrom(source);
}

pub fn fillVectorTriangular(rng: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), mode: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    fillVectorTriangularFrom(rng, VectorType, dest, min, mode, max);
}

pub fn fillVectorTriangularFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), mode: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    const sampler = VectorTriangular(VectorType).init(min, mode, max) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillVectorTriangularChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), mode: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    return fillVectorTriangularCheckedFrom(rng, VectorType, dest, min, mode, max);
}

pub fn fillVectorTriangularCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), mode: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    const sampler = try VectorTriangular(VectorType).init(min, mode, max);
    sampler.fillFrom(source, dest);
}

fn triangularFromUniformVector(comptime VectorType: type, uniform_vec: VectorType, min: vectorChild(VectorType), mode: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    const Child = vectorChild(VectorType);
    const width = max - min;
    const left_width = mode - min;
    const right_width = max - mode;
    const c_vec: VectorType = @splat(left_width / width);
    const one_vec: VectorType = @splat(1);
    const min_vec: VectorType = @splat(min);
    const max_vec: VectorType = @splat(max);
    const left_scale_vec: VectorType = @splat(width * left_width);
    const right_scale_vec: VectorType = @splat(width * right_width);
    const left = min_vec + @sqrt(uniform_vec * left_scale_vec);
    const right = max_vec - @sqrt((one_vec - uniform_vec) * right_scale_vec);
    return @select(Child, uniform_vec < c_vec, left, right);
}

pub fn VectorTriangular(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        sampler: Triangular(Child),

        pub fn init(min: Child, mode: Child, max: Child) Error!Self {
            return .{ .sampler = try Triangular(Child).init(min, mode, max) };
        }

        pub fn minValue(self: Self) Child {
            return self.sampler.minValue();
        }

        pub fn modeValue(self: Self) Child {
            return self.sampler.modeValue();
        }

        pub fn maxValue(self: Self) Child {
            return self.sampler.maxValue();
        }

        pub fn expectedValue(self: Self) Child {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) Child {
            return self.sampler.varianceValue();
        }

        pub fn medianValue(self: Self) Child {
            return self.sampler.medianValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            const uniform_vec = Rng.vectorFrom(source, VectorType);
            return triangularFromUniformVector(VectorType, uniform_vec, self.minValue(), self.modeValue(), self.maxValue());
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
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

        pub fn minValue(self: Self) T {
            return self.min;
        }

        pub fn modeValue(self: Self) T {
            return self.mode;
        }

        pub fn maxValue(self: Self) T {
            return self.max;
        }

        pub fn expectedValue(self: Self) T {
            return (self.min + self.mode + self.max) / 3;
        }

        pub fn varianceValue(self: Self) T {
            return (self.min * self.min + self.mode * self.mode + self.max * self.max -
                self.min * self.mode - self.min * self.max - self.mode * self.max) / 18;
        }

        pub fn medianValue(self: Self) T {
            const midpoint = (self.min + self.max) / 2;
            if (self.mode >= midpoint) {
                return self.min + @sqrt((self.max - self.min) * (self.mode - self.min) / 2);
            }
            return self.max - @sqrt((self.max - self.min) * (self.max - self.mode) / 2);
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return triangularFrom(source, T, self.min, self.mode, self.max);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            fillTriangularFrom(source, T, dest, self.min, self.mode, self.max);
        }
    };
}

pub fn arcsine(rng: Rng, comptime T: type, min: T, max: T) T {
    return arcsineFrom(rng, T, min, max);
}

pub fn arcsineChecked(rng: Rng, comptime T: type, min: T, max: T) Error!T {
    return arcsineCheckedFrom(rng, T, min, max);
}

pub fn arcsineCheckedFrom(source: anytype, comptime T: type, min: T, max: T) Error!T {
    const dist = try Arcsine(T).init(min, max);
    return dist.sampleFrom(source);
}

pub fn arcsineFrom(source: anytype, comptime T: type, min: T, max: T) T {
    comptime requireFloat(T);
    std.debug.assert(min < max and std.math.isFinite(min) and std.math.isFinite(max));

    const u = Rng.floatOpenFrom(source, T);
    const s = @sin(@as(T, @floatCast(std.math.pi)) * u / 2);
    return min + (max - min) * s * s;
}

pub fn fillArcsine(rng: Rng, comptime T: type, dest: []T, min: T, max: T) void {
    fillArcsineFrom(rng, T, dest, min, max);
}

pub fn fillArcsineFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) void {
    comptime requireFloat(T);
    std.debug.assert(min < max and std.math.isFinite(min) and std.math.isFinite(max));
    Rng.fillOpenFrom(source, T, dest);
    arcsineFromOpenUniforms(T, dest, min, max - min);
}

pub fn fillArcsineChecked(rng: Rng, comptime T: type, dest: []T, min: T, max: T) Error!void {
    return fillArcsineCheckedFrom(rng, T, dest, min, max);
}

pub fn fillArcsineCheckedFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Arcsine(T).init(min, max);
    sampler.fillFrom(source, dest);
}

pub fn vectorArcsine(rng: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    return vectorArcsineFrom(rng, VectorType, min, max);
}

pub fn vectorArcsineFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    const sampler = VectorArcsine(VectorType).init(min, max) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn vectorArcsineChecked(rng: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    return vectorArcsineCheckedFrom(rng, VectorType, min, max);
}

pub fn vectorArcsineCheckedFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    const sampler = try VectorArcsine(VectorType).init(min, max);
    return sampler.sampleFrom(source);
}

pub fn fillVectorArcsine(rng: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    fillVectorArcsineFrom(rng, VectorType, dest, min, max);
}

pub fn fillVectorArcsineFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    const sampler = VectorArcsine(VectorType).init(min, max) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillVectorArcsineChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    return fillVectorArcsineCheckedFrom(rng, VectorType, dest, min, max);
}

pub fn fillVectorArcsineCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    const sampler = try VectorArcsine(VectorType).init(min, max);
    sampler.fillFrom(source, dest);
}

fn arcsineFromOpenUniformVector(comptime VectorType: type, uniform_vec: VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    const Child = vectorChild(VectorType);
    const min_vec: VectorType = @splat(min);
    const width_vec: VectorType = @splat(max - min);
    const angle_scale_vec: VectorType = @splat(@as(Child, @floatCast(std.math.pi)) / 2);
    const s = @sin(angle_scale_vec * uniform_vec);
    return min_vec + width_vec * s * s;
}

pub fn VectorArcsine(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        sampler: Arcsine(Child),

        pub fn init(min: Child, max: Child) Error!Self {
            return .{ .sampler = try Arcsine(Child).init(min, max) };
        }

        pub fn minValue(self: Self) Child {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) Child {
            return self.sampler.maxValue();
        }

        pub fn expectedValue(self: Self) Child {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) Child {
            return self.sampler.varianceValue();
        }

        pub fn medianValue(self: Self) Child {
            return self.sampler.medianValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            const uniform_vec = Rng.vectorOpenFrom(source, VectorType);
            return arcsineFromOpenUniformVector(VectorType, uniform_vec, self.minValue(), self.maxValue());
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn Arcsine(comptime T: type) type {
    return struct {
        const Self = @This();

        min: T,
        max: T,

        pub fn init(min: T, max: T) Error!Self {
            comptime requireFloat(T);
            if (!(min < max) or !std.math.isFinite(min) or !std.math.isFinite(max)) return error.InvalidParameter;
            return .{ .min = min, .max = max };
        }

        pub fn minValue(self: Self) T {
            return self.min;
        }

        pub fn maxValue(self: Self) T {
            return self.max;
        }

        pub fn expectedValue(self: Self) T {
            return (self.min + self.max) / 2;
        }

        pub fn varianceValue(self: Self) T {
            const range = self.max - self.min;
            return range * range / 8;
        }

        pub fn medianValue(self: Self) T {
            return (self.min + self.max) / 2;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return arcsineFrom(source, T, self.min, self.max);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            fillArcsineFrom(source, T, dest, self.min, self.max);
        }
    };
}

pub fn cauchy(rng: Rng, comptime T: type, median: T, scale: T) T {
    return cauchyFrom(rng, T, median, scale);
}

pub fn cauchyChecked(rng: Rng, comptime T: type, median: T, scale: T) Error!T {
    return cauchyCheckedFrom(rng, T, median, scale);
}

pub fn cauchyCheckedFrom(source: anytype, comptime T: type, median: T, scale: T) Error!T {
    const dist = try Cauchy(T).init(median, scale);
    return dist.sampleFrom(source);
}

pub fn cauchyFrom(source: anytype, comptime T: type, median: T, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(scale > 0);
    const angle = @as(T, @floatCast(std.math.pi)) * Rng.floatOpenFrom(source, T);
    return median - scale * @cos(angle) / @sin(angle);
}

pub fn fillCauchy(rng: Rng, comptime T: type, dest: []T, median: T, scale: T) void {
    fillCauchyFrom(rng, T, dest, median, scale);
}

pub fn fillCauchyFrom(source: anytype, comptime T: type, dest: []T, median: T, scale: T) void {
    comptime requireFloat(T);
    std.debug.assert(scale > 0);
    Rng.fillOpenFrom(source, T, dest);
    cauchyFromOpenUniforms(T, dest, median, scale);
}

pub fn fillCauchyChecked(rng: Rng, comptime T: type, dest: []T, median: T, scale: T) Error!void {
    return fillCauchyCheckedFrom(rng, T, dest, median, scale);
}

pub fn fillCauchyCheckedFrom(source: anytype, comptime T: type, dest: []T, median: T, scale: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Cauchy(T).init(median, scale);
    sampler.fillFrom(source, dest);
}

pub fn vectorCauchy(rng: Rng, comptime VectorType: type, median: vectorChild(VectorType), scale: vectorChild(VectorType)) VectorType {
    return vectorCauchyFrom(rng, VectorType, median, scale);
}

pub fn vectorCauchyFrom(source: anytype, comptime VectorType: type, median: vectorChild(VectorType), scale: vectorChild(VectorType)) VectorType {
    const sampler = VectorCauchy(VectorType).init(median, scale) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn vectorCauchyChecked(rng: Rng, comptime VectorType: type, median: vectorChild(VectorType), scale: vectorChild(VectorType)) Error!VectorType {
    return vectorCauchyCheckedFrom(rng, VectorType, median, scale);
}

pub fn vectorCauchyCheckedFrom(source: anytype, comptime VectorType: type, median: vectorChild(VectorType), scale: vectorChild(VectorType)) Error!VectorType {
    const sampler = try VectorCauchy(VectorType).init(median, scale);
    return sampler.sampleFrom(source);
}

pub fn fillVectorCauchy(rng: Rng, comptime VectorType: type, dest: []VectorType, median: vectorChild(VectorType), scale: vectorChild(VectorType)) void {
    fillVectorCauchyFrom(rng, VectorType, dest, median, scale);
}

pub fn fillVectorCauchyFrom(source: anytype, comptime VectorType: type, dest: []VectorType, median: vectorChild(VectorType), scale: vectorChild(VectorType)) void {
    const sampler = VectorCauchy(VectorType).init(median, scale) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillVectorCauchyChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, median: vectorChild(VectorType), scale: vectorChild(VectorType)) Error!void {
    return fillVectorCauchyCheckedFrom(rng, VectorType, dest, median, scale);
}

pub fn fillVectorCauchyCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, median: vectorChild(VectorType), scale: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    const sampler = try VectorCauchy(VectorType).init(median, scale);
    sampler.fillFrom(source, dest);
}

fn cauchyFromOpenUniformVector(comptime VectorType: type, uniform_vec: VectorType, median: vectorChild(VectorType), scale: vectorChild(VectorType)) VectorType {
    const Child = vectorChild(VectorType);
    const pi_vec: VectorType = @splat(@as(Child, @floatCast(std.math.pi)));
    const half_vec: VectorType = @splat(0.5);
    const median_vec: VectorType = @splat(median);
    const scale_vec: VectorType = @splat(scale);
    return median_vec + scale_vec * @tan(pi_vec * (uniform_vec - half_vec));
}

pub fn VectorCauchy(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        sampler: Cauchy(Child),

        pub fn init(median: Child, scale: Child) Error!Self {
            return .{ .sampler = try Cauchy(Child).init(median, scale) };
        }

        pub fn medianValue(self: Self) Child {
            return self.sampler.medianValue();
        }

        pub fn modeValue(self: Self) Child {
            return self.sampler.modeValue();
        }

        pub fn scaleValue(self: Self) Child {
            return self.sampler.scaleValue();
        }

        pub fn expectedValue(self: Self) ?Child {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) ?Child {
            return self.sampler.varianceValue();
        }

        pub fn minValue(self: Self) ?Child {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) ?Child {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            const uniform_vec = Rng.vectorOpenFrom(source, VectorType);
            return cauchyFromOpenUniformVector(VectorType, uniform_vec, self.medianValue(), self.scaleValue());
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
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

        pub fn medianValue(self: Self) T {
            return self.median;
        }

        pub fn modeValue(self: Self) T {
            return self.median;
        }

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn expectedValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn varianceValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn minValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return cauchyFrom(source, T, self.median, self.scale);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            fillCauchyFrom(source, T, dest, self.median, self.scale);
        }
    };
}

pub fn laplace(rng: Rng, comptime T: type, location: T, scale: T) T {
    return laplaceFrom(rng, T, location, scale);
}

pub fn laplaceChecked(rng: Rng, comptime T: type, location: T, scale: T) Error!T {
    return laplaceCheckedFrom(rng, T, location, scale);
}

pub fn laplaceCheckedFrom(source: anytype, comptime T: type, location: T, scale: T) Error!T {
    const dist = try Laplace(T).init(location, scale);
    return dist.sampleFrom(source);
}

pub fn laplaceFrom(source: anytype, comptime T: type, location: T, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and std.math.isFinite(scale));

    const u = Rng.floatOpenFrom(source, T) - @as(T, 0.5);
    const one: T = 1;
    const sign: T = if (u < 0) -1 else 1;
    return location - scale * sign * @log(one - 2 * @abs(u));
}

pub fn fillLaplace(rng: Rng, comptime T: type, dest: []T, location: T, scale: T) void {
    fillLaplaceFrom(rng, T, dest, location, scale);
}

pub fn fillLaplaceFrom(source: anytype, comptime T: type, dest: []T, location: T, scale: T) void {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and std.math.isFinite(scale));
    Rng.fillOpenFrom(source, T, dest);
    laplaceFromOpenUniforms(T, dest, location, scale);
}

pub fn fillLaplaceChecked(rng: Rng, comptime T: type, dest: []T, location: T, scale: T) Error!void {
    return fillLaplaceCheckedFrom(rng, T, dest, location, scale);
}

pub fn fillLaplaceCheckedFrom(source: anytype, comptime T: type, dest: []T, location: T, scale: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Laplace(T).init(location, scale);
    sampler.fillFrom(source, dest);
}

pub fn vectorLaplace(rng: Rng, comptime VectorType: type, location: vectorChild(VectorType), scale: vectorChild(VectorType)) VectorType {
    return vectorLaplaceFrom(rng, VectorType, location, scale);
}

pub fn vectorLaplaceFrom(source: anytype, comptime VectorType: type, location: vectorChild(VectorType), scale: vectorChild(VectorType)) VectorType {
    const sampler = VectorLaplace(VectorType).init(location, scale) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn vectorLaplaceChecked(rng: Rng, comptime VectorType: type, location: vectorChild(VectorType), scale: vectorChild(VectorType)) Error!VectorType {
    return vectorLaplaceCheckedFrom(rng, VectorType, location, scale);
}

pub fn vectorLaplaceCheckedFrom(source: anytype, comptime VectorType: type, location: vectorChild(VectorType), scale: vectorChild(VectorType)) Error!VectorType {
    const sampler = try VectorLaplace(VectorType).init(location, scale);
    return sampler.sampleFrom(source);
}

pub fn fillVectorLaplace(rng: Rng, comptime VectorType: type, dest: []VectorType, location: vectorChild(VectorType), scale: vectorChild(VectorType)) void {
    fillVectorLaplaceFrom(rng, VectorType, dest, location, scale);
}

pub fn fillVectorLaplaceFrom(source: anytype, comptime VectorType: type, dest: []VectorType, location: vectorChild(VectorType), scale: vectorChild(VectorType)) void {
    const sampler = VectorLaplace(VectorType).init(location, scale) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillVectorLaplaceChecked(rng: Rng, comptime VectorType: type, dest: []VectorType, location: vectorChild(VectorType), scale: vectorChild(VectorType)) Error!void {
    return fillVectorLaplaceCheckedFrom(rng, VectorType, dest, location, scale);
}

pub fn fillVectorLaplaceCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, location: vectorChild(VectorType), scale: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    const sampler = try VectorLaplace(VectorType).init(location, scale);
    sampler.fillFrom(source, dest);
}

fn laplaceFromOpenUniformVector(comptime VectorType: type, uniform_vec: VectorType, location: vectorChild(VectorType), scale: vectorChild(VectorType)) VectorType {
    const Child = vectorChild(VectorType);
    const location_vec: VectorType = @splat(location);
    const scale_vec: VectorType = @splat(scale);
    const half_vec: VectorType = @splat(0.5);
    const one_vec: VectorType = @splat(1);
    const two_vec: VectorType = @splat(2);
    const positive: VectorType = @splat(1);
    const negative: VectorType = @splat(-1);
    const centered = uniform_vec - half_vec;
    const sign = @select(Child, centered < @as(VectorType, @splat(0)), negative, positive);
    return location_vec - scale_vec * sign * @log(one_vec - two_vec * @abs(centered));
}

pub fn VectorLaplace(comptime VectorType: type) type {
    const Child = vectorChild(VectorType);
    requireFloat(Child);

    return struct {
        const Self = @This();

        sampler: Laplace(Child),

        pub fn init(location: Child, scale: Child) Error!Self {
            return .{ .sampler = try Laplace(Child).init(location, scale) };
        }

        pub fn locationValue(self: Self) Child {
            return self.sampler.locationValue();
        }

        pub fn scaleValue(self: Self) Child {
            return self.sampler.scaleValue();
        }

        pub fn medianValue(self: Self) Child {
            return self.sampler.medianValue();
        }

        pub fn modeValue(self: Self) Child {
            return self.sampler.modeValue();
        }

        pub fn expectedValue(self: Self) Child {
            return self.sampler.expectedValue();
        }

        pub fn varianceValue(self: Self) Child {
            return self.sampler.varianceValue();
        }

        pub fn minValue(self: Self) ?Child {
            return self.sampler.minValue();
        }

        pub fn maxValue(self: Self) ?Child {
            return self.sampler.maxValue();
        }

        pub fn sample(self: Self, rng: Rng) VectorType {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) VectorType {
            const uniform_vec = Rng.vectorOpenFrom(source, VectorType);
            return laplaceFromOpenUniformVector(VectorType, uniform_vec, self.locationValue(), self.scaleValue());
        }

        pub fn fill(self: Self, rng: Rng, dest: []VectorType) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []VectorType) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn Laplace(comptime T: type) type {
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

        pub fn locationValue(self: Self) T {
            return self.location;
        }

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn medianValue(self: Self) T {
            return self.location;
        }

        pub fn modeValue(self: Self) T {
            return self.location;
        }

        pub fn expectedValue(self: Self) T {
            return self.location;
        }

        pub fn varianceValue(self: Self) T {
            return 2 * self.scale * self.scale;
        }

        pub fn minValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return laplaceFrom(source, T, self.location, self.scale);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            fillLaplaceFrom(source, T, dest, self.location, self.scale);
        }
    };
}

pub fn logistic(rng: Rng, comptime T: type, location: T, scale: T) T {
    return logisticFrom(rng, T, location, scale);
}

pub fn logisticChecked(rng: Rng, comptime T: type, location: T, scale: T) Error!T {
    return logisticCheckedFrom(rng, T, location, scale);
}

pub fn logisticCheckedFrom(source: anytype, comptime T: type, location: T, scale: T) Error!T {
    const dist = try Logistic(T).init(location, scale);
    return dist.sampleFrom(source);
}

pub fn logisticFrom(source: anytype, comptime T: type, location: T, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and std.math.isFinite(scale));

    const u = Rng.floatOpenFrom(source, T);
    return location + scale * @log(u / (1 - u));
}

pub fn fillLogistic(rng: Rng, comptime T: type, dest: []T, location: T, scale: T) void {
    fillLogisticFrom(rng, T, dest, location, scale);
}

pub fn fillLogisticFrom(source: anytype, comptime T: type, dest: []T, location: T, scale: T) void {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and std.math.isFinite(scale));
    Rng.fillOpenFrom(source, T, dest);
    logisticFromOpenUniforms(T, dest, location, scale);
}

pub fn fillLogisticChecked(rng: Rng, comptime T: type, dest: []T, location: T, scale: T) Error!void {
    return fillLogisticCheckedFrom(rng, T, dest, location, scale);
}

pub fn fillLogisticCheckedFrom(source: anytype, comptime T: type, dest: []T, location: T, scale: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Logistic(T).init(location, scale);
    sampler.fillFrom(source, dest);
}

pub fn Logistic(comptime T: type) type {
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

        pub fn locationValue(self: Self) T {
            return self.location;
        }

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn medianValue(self: Self) T {
            return self.location;
        }

        pub fn modeValue(self: Self) T {
            return self.location;
        }

        pub fn expectedValue(self: Self) T {
            return self.location;
        }

        pub fn varianceValue(self: Self) T {
            const pi: T = @floatCast(std.math.pi);
            return pi * pi * self.scale * self.scale / 3;
        }

        pub fn minValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return logisticFrom(source, T, self.location, self.scale);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            fillLogisticFrom(source, T, dest, self.location, self.scale);
        }
    };
}

pub fn logLogistic(rng: Rng, comptime T: type, scale: T, shape: T) T {
    return logLogisticFrom(rng, T, scale, shape);
}

pub fn logLogisticChecked(rng: Rng, comptime T: type, scale: T, shape: T) Error!T {
    return logLogisticCheckedFrom(rng, T, scale, shape);
}

pub fn logLogisticCheckedFrom(source: anytype, comptime T: type, scale: T, shape: T) Error!T {
    const dist = try LogLogistic(T).init(scale, shape);
    return dist.sampleFrom(source);
}

pub fn logLogisticFrom(source: anytype, comptime T: type, scale: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and shape > 0 and std.math.isFinite(scale) and std.math.isFinite(shape));

    const u = Rng.floatOpenFrom(source, T);
    if (shape == 1) return scale * u / (1 - u);
    return scale * std.math.pow(T, u / (1 - u), 1 / shape);
}

pub fn fillLogLogistic(rng: Rng, comptime T: type, dest: []T, scale: T, shape: T) void {
    fillLogLogisticFrom(rng, T, dest, scale, shape);
}

pub fn fillLogLogisticFrom(source: anytype, comptime T: type, dest: []T, scale: T, shape: T) void {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and shape > 0 and std.math.isFinite(scale) and std.math.isFinite(shape));
    Rng.fillOpenFrom(source, T, dest);
    if (shape == 1) {
        logLogisticShapeOneFromOpenUniforms(T, dest, scale);
        return;
    }

    logLogisticFromOpenUniforms(T, dest, scale, 1 / shape);
}

pub fn fillLogLogisticChecked(rng: Rng, comptime T: type, dest: []T, scale: T, shape: T) Error!void {
    return fillLogLogisticCheckedFrom(rng, T, dest, scale, shape);
}

pub fn fillLogLogisticCheckedFrom(source: anytype, comptime T: type, dest: []T, scale: T, shape: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try LogLogistic(T).init(scale, shape);
    sampler.fillFrom(source, dest);
}

pub fn LogLogistic(comptime T: type) type {
    return struct {
        const Self = @This();
        const Method = enum { generic, ratio };

        scale: T,
        inverse_shape: T,
        method: Method,

        pub fn init(scale: T, shape: T) Error!Self {
            comptime requireFloat(T);
            if (!(scale > 0) or !(shape > 0)) return error.InvalidParameter;
            if (!std.math.isFinite(scale) or !std.math.isFinite(shape)) return error.InvalidParameter;
            return .{ .scale = scale, .inverse_shape = 1 / shape, .method = if (shape == 1) .ratio else .generic };
        }

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn shapeValue(self: Self) T {
            return 1 / self.inverse_shape;
        }

        pub fn expectedValue(self: Self) ?T {
            const shape = self.shapeValue();
            if (shape <= 1) return null;
            const angle = @as(T, @floatCast(std.math.pi)) / shape;
            return self.scale * angle / @sin(angle);
        }

        pub fn varianceValue(self: Self) ?T {
            const shape = self.shapeValue();
            if (shape <= 2) return null;
            const angle = @as(T, @floatCast(std.math.pi)) / shape;
            const second_angle = 2 * angle;
            const second_moment = self.scale * self.scale * second_angle / @sin(second_angle);
            const mean = self.expectedValue().?;
            return second_moment - mean * mean;
        }

        pub fn medianValue(self: Self) T {
            return self.scale;
        }

        pub fn modeValue(self: Self) T {
            const shape = self.shapeValue();
            if (shape <= 1) return 0;
            return self.scale * std.math.pow(T, (shape - 1) / (shape + 1), 1 / shape);
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            const u = Rng.floatOpenFrom(source, T);
            if (self.method == .ratio) return self.scale * u / (1 - u);
            return self.scale * std.math.pow(T, u / (1 - u), self.inverse_shape);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            Rng.fillOpenFrom(source, T, dest);
            if (self.method == .ratio) {
                logLogisticShapeOneFromOpenUniforms(T, dest, self.scale);
                return;
            }

            logLogisticFromOpenUniforms(T, dest, self.scale, self.inverse_shape);
        }
    };
}

pub fn kumaraswamy(rng: Rng, comptime T: type, alpha: T, beta_param: T) T {
    return kumaraswamyFrom(rng, T, alpha, beta_param);
}

pub fn kumaraswamyChecked(rng: Rng, comptime T: type, alpha: T, beta_param: T) Error!T {
    return kumaraswamyCheckedFrom(rng, T, alpha, beta_param);
}

pub fn kumaraswamyCheckedFrom(source: anytype, comptime T: type, alpha: T, beta_param: T) Error!T {
    const dist = try Kumaraswamy(T).init(alpha, beta_param);
    return dist.sampleFrom(source);
}

pub fn kumaraswamyFrom(source: anytype, comptime T: type, alpha: T, beta_param: T) T {
    comptime requireFloat(T);
    std.debug.assert(alpha > 0 and beta_param > 0 and std.math.isFinite(alpha) and std.math.isFinite(beta_param));

    if (alpha == 2 and beta_param == 1) return @sqrt(Rng.floatOpenFrom(source, T));
    if (beta_param == 1) return std.math.pow(T, Rng.floatOpenFrom(source, T), 1 / alpha);
    if (alpha == 1) return 1 - std.math.pow(T, 1 - Rng.floatOpenFrom(source, T), 1 / beta_param);

    const u = Rng.floatOpenFrom(source, T);
    return std.math.pow(T, 1 - std.math.pow(T, 1 - u, 1 / beta_param), 1 / alpha);
}

pub fn fillKumaraswamy(rng: Rng, comptime T: type, dest: []T, alpha: T, beta_param: T) void {
    fillKumaraswamyFrom(rng, T, dest, alpha, beta_param);
}

pub fn fillKumaraswamyFrom(source: anytype, comptime T: type, dest: []T, alpha: T, beta_param: T) void {
    comptime requireFloat(T);
    std.debug.assert(alpha > 0 and beta_param > 0 and std.math.isFinite(alpha) and std.math.isFinite(beta_param));
    if (alpha == 2 and beta_param == 1) {
        Rng.fillOpenFrom(source, T, dest);
        for (dest) |*item| item.* = @sqrt(item.*);
        return;
    }
    if (beta_param == 1) {
        Rng.fillOpenFrom(source, T, dest);
        const inverse_alpha = 1 / alpha;
        for (dest) |*item| item.* = std.math.pow(T, item.*, inverse_alpha);
        return;
    }
    if (alpha == 1) {
        Rng.fillOpenFrom(source, T, dest);
        const inverse_beta = 1 / beta_param;
        for (dest) |*item| item.* = 1 - std.math.pow(T, 1 - item.*, inverse_beta);
        return;
    }

    for (dest) |*item| item.* = kumaraswamyFrom(source, T, alpha, beta_param);
}

pub fn fillKumaraswamyChecked(rng: Rng, comptime T: type, dest: []T, alpha: T, beta_param: T) Error!void {
    return fillKumaraswamyCheckedFrom(rng, T, dest, alpha, beta_param);
}

pub fn fillKumaraswamyCheckedFrom(source: anytype, comptime T: type, dest: []T, alpha: T, beta_param: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Kumaraswamy(T).init(alpha, beta_param);
    sampler.fillFrom(source, dest);
}

pub fn Kumaraswamy(comptime T: type) type {
    return struct {
        const Self = @This();
        const Method = enum { generic, alpha_one, beta_one, beta_one_sqrt };

        inverse_alpha: T,
        inverse_beta: T,
        method: Method,

        pub fn init(alpha: T, beta_param: T) Error!Self {
            comptime requireFloat(T);
            if (!(alpha > 0) or !(beta_param > 0)) return error.InvalidParameter;
            if (!std.math.isFinite(alpha) or !std.math.isFinite(beta_param)) return error.InvalidParameter;
            return .{
                .inverse_alpha = 1 / alpha,
                .inverse_beta = 1 / beta_param,
                .method = if (alpha == 2 and beta_param == 1)
                    .beta_one_sqrt
                else if (beta_param == 1)
                    .beta_one
                else if (alpha == 1)
                    .alpha_one
                else
                    .generic,
            };
        }

        pub fn alphaValue(self: Self) T {
            return 1 / self.inverse_alpha;
        }

        pub fn betaValue(self: Self) T {
            return 1 / self.inverse_beta;
        }

        pub fn expectedValue(self: Self) T {
            return self.momentValue(1);
        }

        pub fn varianceValue(self: Self) T {
            const first_moment = self.momentValue(1);
            const second_moment = self.momentValue(2);
            return second_moment - first_moment * first_moment;
        }

        pub fn modeValue(self: Self) ?T {
            const alpha = self.alphaValue();
            const beta_param = self.betaValue();
            if (alpha > 1 and alpha * beta_param > 1) {
                return std.math.pow(T, (alpha - 1) / (alpha * beta_param - 1), 1 / alpha);
            }
            if (alpha < 1 and beta_param < 1) return null;
            if (alpha == 1 and beta_param == 1) return null;
            if (beta_param <= 1) return 1;
            return 0;
        }

        pub fn medianValue(self: Self) T {
            return std.math.pow(T, 1 - std.math.pow(T, 0.5, self.inverse_beta), self.inverse_alpha);
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) T {
            _ = self;
            return 1;
        }

        fn momentValue(self: Self, order: T) T {
            const beta_param = self.betaValue();
            const beta_arg = 1 + order * self.inverse_alpha;
            return beta_param * @exp(std.math.lgamma(T, beta_arg) + std.math.lgamma(T, beta_param) - std.math.lgamma(T, beta_arg + beta_param));
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            switch (self.method) {
                .beta_one_sqrt => return @sqrt(Rng.floatOpenFrom(source, T)),
                .beta_one => return std.math.pow(T, Rng.floatOpenFrom(source, T), self.inverse_alpha),
                .alpha_one => return 1 - std.math.pow(T, 1 - Rng.floatOpenFrom(source, T), self.inverse_beta),
                .generic => {},
            }

            const u = Rng.floatOpenFrom(source, T);
            return std.math.pow(T, 1 - std.math.pow(T, 1 - u, self.inverse_beta), self.inverse_alpha);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            switch (self.method) {
                .beta_one_sqrt => {
                    Rng.fillOpenFrom(source, T, dest);
                    for (dest) |*item| item.* = @sqrt(item.*);
                    return;
                },
                .beta_one => {
                    Rng.fillOpenFrom(source, T, dest);
                    for (dest) |*item| item.* = std.math.pow(T, item.*, self.inverse_alpha);
                    return;
                },
                .alpha_one => {
                    Rng.fillOpenFrom(source, T, dest);
                    for (dest) |*item| item.* = 1 - std.math.pow(T, 1 - item.*, self.inverse_beta);
                    return;
                },
                .generic => {},
            }

            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn powerFunction(rng: Rng, comptime T: type, min: T, max: T, shape: T) T {
    return powerFunctionFrom(rng, T, min, max, shape);
}

pub fn powerFunctionChecked(rng: Rng, comptime T: type, min: T, max: T, shape: T) Error!T {
    return powerFunctionCheckedFrom(rng, T, min, max, shape);
}

pub fn powerFunctionCheckedFrom(source: anytype, comptime T: type, min: T, max: T, shape: T) Error!T {
    const dist = try PowerFunction(T).init(min, max, shape);
    return dist.sampleFrom(source);
}

pub fn powerFunctionFrom(source: anytype, comptime T: type, min: T, max: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(min < max and shape > 0);
    std.debug.assert(std.math.isFinite(min) and std.math.isFinite(max) and std.math.isFinite(shape));

    if (shape == 1) return Rng.floatRangeFrom(source, T, min, max);
    if (shape == 2) return min + (max - min) * @sqrt(Rng.floatOpenFrom(source, T));
    return min + (max - min) * std.math.pow(T, Rng.floatOpenFrom(source, T), 1 / shape);
}

pub fn fillPowerFunction(rng: Rng, comptime T: type, dest: []T, min: T, max: T, shape: T) void {
    fillPowerFunctionFrom(rng, T, dest, min, max, shape);
}

pub fn fillPowerFunctionFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T, shape: T) void {
    comptime requireFloat(T);
    std.debug.assert(min < max and shape > 0);
    std.debug.assert(std.math.isFinite(min) and std.math.isFinite(max) and std.math.isFinite(shape));
    if (shape == 1) {
        Rng.fillRangeFrom(source, T, dest, min, max);
        return;
    }
    if (shape == 2) {
        const width = max - min;
        Rng.fillOpenFrom(source, T, dest);
        for (dest) |*item| item.* = min + width * @sqrt(item.*);
        return;
    }

    Rng.fillOpenFrom(source, T, dest);
    powerFunctionFromOpenUniforms(T, dest, min, max - min, 1 / shape);
}

pub fn fillPowerFunctionChecked(rng: Rng, comptime T: type, dest: []T, min: T, max: T, shape: T) Error!void {
    return fillPowerFunctionCheckedFrom(rng, T, dest, min, max, shape);
}

pub fn fillPowerFunctionCheckedFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T, shape: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try PowerFunction(T).init(min, max, shape);
    sampler.fillFrom(source, dest);
}

pub fn PowerFunction(comptime T: type) type {
    return struct {
        const Self = @This();
        const Method = enum { generic, uniform, sqrt };

        min: T,
        range: T,
        inverse_shape: T,
        method: Method,

        pub fn init(min: T, max: T, shape: T) Error!Self {
            comptime requireFloat(T);
            if (!(min < max) or !(shape > 0)) return error.InvalidParameter;
            if (!std.math.isFinite(min) or !std.math.isFinite(max) or !std.math.isFinite(shape)) return error.InvalidParameter;
            return .{
                .min = min,
                .range = max - min,
                .inverse_shape = 1 / shape,
                .method = if (shape == 1) .uniform else if (shape == 2) .sqrt else .generic,
            };
        }

        pub fn minValue(self: Self) T {
            return self.min;
        }

        pub fn maxValue(self: Self) T {
            return self.min + self.range;
        }

        pub fn shapeValue(self: Self) T {
            return 1 / self.inverse_shape;
        }

        pub fn expectedValue(self: Self) T {
            const shape = self.shapeValue();
            return self.min + self.range * shape / (shape + 1);
        }

        pub fn varianceValue(self: Self) T {
            const shape = self.shapeValue();
            return self.range * self.range * shape / ((shape + 1) * (shape + 1) * (shape + 2));
        }

        pub fn medianValue(self: Self) T {
            return self.min + self.range * std.math.pow(T, 0.5, self.inverse_shape);
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return switch (self.method) {
                .uniform => Rng.floatRangeFrom(source, T, self.min, self.min + self.range),
                .sqrt => self.min + self.range * @sqrt(Rng.floatOpenFrom(source, T)),
                .generic => self.min + self.range * std.math.pow(T, Rng.floatOpenFrom(source, T), self.inverse_shape),
            };
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            switch (self.method) {
                .uniform => {
                    Rng.fillRangeFrom(source, T, dest, self.min, self.min + self.range);
                    return;
                },
                .sqrt => {
                    Rng.fillOpenFrom(source, T, dest);
                    for (dest) |*item| item.* = self.min + self.range * @sqrt(item.*);
                    return;
                },
                .generic => {},
            }

            Rng.fillOpenFrom(source, T, dest);
            powerFunctionFromOpenUniforms(T, dest, self.min, self.range, self.inverse_shape);
        }
    };
}

pub fn rayleigh(rng: Rng, comptime T: type, scale: T) T {
    return rayleighFrom(rng, T, scale);
}

pub fn rayleighChecked(rng: Rng, comptime T: type, scale: T) Error!T {
    return rayleighCheckedFrom(rng, T, scale);
}

pub fn rayleighCheckedFrom(source: anytype, comptime T: type, scale: T) Error!T {
    const dist = try Rayleigh(T).init(scale);
    return dist.sampleFrom(source);
}

pub fn rayleighFrom(source: anytype, comptime T: type, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and std.math.isFinite(scale));

    return scale * @sqrt(-2 * @log(Rng.floatOpenFrom(source, T)));
}

pub fn fillRayleigh(rng: Rng, comptime T: type, dest: []T, scale: T) void {
    fillRayleighFrom(rng, T, dest, scale);
}

pub fn fillRayleighFrom(source: anytype, comptime T: type, dest: []T, scale: T) void {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and std.math.isFinite(scale));
    Rng.fillOpenFrom(source, T, dest);
    rayleighFromOpenUniforms(T, dest, scale);
}

pub fn fillRayleighChecked(rng: Rng, comptime T: type, dest: []T, scale: T) Error!void {
    return fillRayleighCheckedFrom(rng, T, dest, scale);
}

pub fn fillRayleighCheckedFrom(source: anytype, comptime T: type, dest: []T, scale: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Rayleigh(T).init(scale);
    sampler.fillFrom(source, dest);
}

pub fn Rayleigh(comptime T: type) type {
    return struct {
        const Self = @This();

        scale: T,

        pub fn init(scale: T) Error!Self {
            comptime requireFloat(T);
            if (!(scale > 0) or !std.math.isFinite(scale)) return error.InvalidParameter;
            return .{ .scale = scale };
        }

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn expectedValue(self: Self) T {
            return self.scale * @sqrt(@as(T, @floatCast(std.math.pi)) / 2);
        }

        pub fn varianceValue(self: Self) T {
            return self.scale * self.scale * (4 - @as(T, @floatCast(std.math.pi))) / 2;
        }

        pub fn medianValue(self: Self) T {
            return self.scale * @sqrt(2 * @log(@as(T, 2)));
        }

        pub fn modeValue(self: Self) T {
            return self.scale;
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return rayleighFrom(source, T, self.scale);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            fillRayleighFrom(source, T, dest, self.scale);
        }
    };
}

pub fn maxwell(rng: Rng, comptime T: type, scale: T) T {
    return maxwellFrom(rng, T, scale);
}

pub fn maxwellChecked(rng: Rng, comptime T: type, scale: T) Error!T {
    return maxwellCheckedFrom(rng, T, scale);
}

pub fn maxwellCheckedFrom(source: anytype, comptime T: type, scale: T) Error!T {
    const dist = try Maxwell(T).init(scale);
    return dist.sampleFrom(source);
}

pub fn maxwellFrom(source: anytype, comptime T: type, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and std.math.isFinite(scale));

    const x = Rng.normalFastFrom(source, T, 0, scale);
    const y = Rng.normalFastFrom(source, T, 0, scale);
    const z = Rng.normalFastFrom(source, T, 0, scale);
    return @sqrt(x * x + y * y + z * z);
}

pub fn fillMaxwell(rng: Rng, comptime T: type, dest: []T, scale: T) void {
    fillMaxwellFrom(rng, T, dest, scale);
}

pub fn fillMaxwellFrom(source: anytype, comptime T: type, dest: []T, scale: T) void {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and std.math.isFinite(scale));
    for (dest) |*item| item.* = maxwellFrom(source, T, scale);
}

pub fn fillMaxwellChecked(rng: Rng, comptime T: type, dest: []T, scale: T) Error!void {
    return fillMaxwellCheckedFrom(rng, T, dest, scale);
}

pub fn fillMaxwellCheckedFrom(source: anytype, comptime T: type, dest: []T, scale: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Maxwell(T).init(scale);
    sampler.fillFrom(source, dest);
}

pub fn Maxwell(comptime T: type) type {
    return struct {
        const Self = @This();

        scale: T,

        pub fn init(scale: T) Error!Self {
            comptime requireFloat(T);
            if (!(scale > 0) or !std.math.isFinite(scale)) return error.InvalidParameter;
            return .{ .scale = scale };
        }

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn expectedValue(self: Self) T {
            return 2 * self.scale * @sqrt(2 / @as(T, @floatCast(std.math.pi)));
        }

        pub fn varianceValue(self: Self) T {
            const pi: T = @floatCast(std.math.pi);
            return self.scale * self.scale * (3 * pi - 8) / pi;
        }

        pub fn modeValue(self: Self) T {
            return @sqrt(@as(T, 2)) * self.scale;
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return maxwellFrom(source, T, self.scale);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn pareto(rng: Rng, comptime T: type, scale: T, shape: T) T {
    return paretoFrom(rng, T, scale, shape);
}

pub fn paretoChecked(rng: Rng, comptime T: type, scale: T, shape: T) Error!T {
    return paretoCheckedFrom(rng, T, scale, shape);
}

pub fn paretoCheckedFrom(source: anytype, comptime T: type, scale: T, shape: T) Error!T {
    const dist = try Pareto(T).init(scale, shape);
    return dist.sampleFrom(source);
}

pub fn paretoFrom(source: anytype, comptime T: type, scale: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and shape > 0);
    return scale / std.math.pow(T, Rng.floatOpenFrom(source, T), 1 / shape);
}

pub fn fillPareto(rng: Rng, comptime T: type, dest: []T, scale: T, shape: T) void {
    fillParetoFrom(rng, T, dest, scale, shape);
}

pub fn fillParetoFrom(source: anytype, comptime T: type, dest: []T, scale: T, shape: T) void {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and shape > 0);
    if (shape == 1) {
        Rng.fillOpenFrom(source, T, dest);
        for (dest) |*item| item.* = scale / item.*;
        return;
    }

    Rng.fillOpenFrom(source, T, dest);
    paretoFromOpenUniforms(T, dest, scale, 1 / shape);
}

pub fn fillParetoChecked(rng: Rng, comptime T: type, dest: []T, scale: T, shape: T) Error!void {
    return fillParetoCheckedFrom(rng, T, dest, scale, shape);
}

pub fn fillParetoCheckedFrom(source: anytype, comptime T: type, dest: []T, scale: T, shape: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Pareto(T).init(scale, shape);
    sampler.fillFrom(source, dest);
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

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn shapeValue(self: Self) T {
            return self.shape;
        }

        pub fn expectedValue(self: Self) ?T {
            if (self.shape <= 1) return null;
            return self.scale * self.shape / (self.shape - 1);
        }

        pub fn varianceValue(self: Self) ?T {
            if (self.shape <= 2) return null;
            const shape_minus_one = self.shape - 1;
            return self.scale * self.scale * self.shape / (shape_minus_one * shape_minus_one * (self.shape - 2));
        }

        pub fn medianValue(self: Self) T {
            return self.scale * std.math.pow(T, 2, 1 / self.shape);
        }

        pub fn modeValue(self: Self) T {
            return self.scale;
        }

        pub fn minValue(self: Self) T {
            return self.scale;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return paretoFrom(source, T, self.scale, self.shape);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            fillParetoFrom(source, T, dest, self.scale, self.shape);
        }
    };
}

pub fn weibull(rng: Rng, comptime T: type, scale: T, shape: T) T {
    return weibullFrom(rng, T, scale, shape);
}

pub fn weibullChecked(rng: Rng, comptime T: type, scale: T, shape: T) Error!T {
    return weibullCheckedFrom(rng, T, scale, shape);
}

pub fn weibullCheckedFrom(source: anytype, comptime T: type, scale: T, shape: T) Error!T {
    const dist = try Weibull(T).init(scale, shape);
    return dist.sampleFrom(source);
}

pub fn weibullFrom(source: anytype, comptime T: type, scale: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and shape > 0);
    if (shape == 1) return scale * Rng.standardExponentialFastFrom(source, T);
    return scale * std.math.pow(T, -@log(Rng.floatOpenFrom(source, T)), 1 / shape);
}

pub fn fillWeibull(rng: Rng, comptime T: type, dest: []T, scale: T, shape: T) void {
    fillWeibullFrom(rng, T, dest, scale, shape);
}

pub fn fillWeibullFrom(source: anytype, comptime T: type, dest: []T, scale: T, shape: T) void {
    comptime requireFloat(T);
    std.debug.assert(scale > 0 and shape > 0);
    if (shape == 1) {
        for (dest) |*item| item.* = scale * Rng.standardExponentialFastFrom(source, T);
        return;
    }

    Rng.fillOpenFrom(source, T, dest);
    weibullFromOpenUniforms(T, dest, scale, 1 / shape);
}

pub fn fillWeibullChecked(rng: Rng, comptime T: type, dest: []T, scale: T, shape: T) Error!void {
    return fillWeibullCheckedFrom(rng, T, dest, scale, shape);
}

pub fn fillWeibullCheckedFrom(source: anytype, comptime T: type, dest: []T, scale: T, shape: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Weibull(T).init(scale, shape);
    sampler.fillFrom(source, dest);
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

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn shapeValue(self: Self) T {
            return self.shape;
        }

        pub fn expectedValue(self: Self) T {
            return self.scale * std.math.gamma(T, 1 + 1 / self.shape);
        }

        pub fn varianceValue(self: Self) T {
            const mean_scale_factor = std.math.gamma(T, 1 + 1 / self.shape);
            const second_moment_scale_factor = std.math.gamma(T, 1 + 2 / self.shape);
            const scale_squared = self.scale * self.scale;
            return scale_squared * (second_moment_scale_factor - mean_scale_factor * mean_scale_factor);
        }

        pub fn medianValue(self: Self) T {
            return self.scale * std.math.pow(T, @log(@as(T, 2)), 1 / self.shape);
        }

        pub fn modeValue(self: Self) T {
            if (self.shape <= 1) return 0;
            return self.scale * std.math.pow(T, (self.shape - 1) / self.shape, 1 / self.shape);
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return weibullFrom(source, T, self.scale, self.shape);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            fillWeibullFrom(source, T, dest, self.scale, self.shape);
        }
    };
}

pub fn gumbel(rng: Rng, comptime T: type, location: T, scale: T) T {
    return gumbelFrom(rng, T, location, scale);
}

pub fn gumbelChecked(rng: Rng, comptime T: type, location: T, scale: T) Error!T {
    return gumbelCheckedFrom(rng, T, location, scale);
}

pub fn gumbelCheckedFrom(source: anytype, comptime T: type, location: T, scale: T) Error!T {
    const dist = try Gumbel(T).init(location, scale);
    return dist.sampleFrom(source);
}

pub fn gumbelFrom(source: anytype, comptime T: type, location: T, scale: T) T {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and std.math.isFinite(scale));
    const u = Rng.floatOpenClosedFrom(source, T);
    return location - scale * @log(-@log(u));
}

pub fn fillGumbel(rng: Rng, comptime T: type, dest: []T, location: T, scale: T) void {
    fillGumbelFrom(rng, T, dest, location, scale);
}

pub fn fillGumbelFrom(source: anytype, comptime T: type, dest: []T, location: T, scale: T) void {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and std.math.isFinite(scale));
    Rng.fillOpenClosedFrom(source, T, dest);
    gumbelFromOpenClosedUniforms(T, dest, location, scale);
}

pub fn fillGumbelChecked(rng: Rng, comptime T: type, dest: []T, location: T, scale: T) Error!void {
    return fillGumbelCheckedFrom(rng, T, dest, location, scale);
}

pub fn fillGumbelCheckedFrom(source: anytype, comptime T: type, dest: []T, location: T, scale: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Gumbel(T).init(location, scale);
    sampler.fillFrom(source, dest);
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

        pub fn locationValue(self: Self) T {
            return self.location;
        }

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn expectedValue(self: Self) T {
            const euler_mascheroni = @as(T, 0.57721566490153286060651209008240243104215933593992);
            return self.location + euler_mascheroni * self.scale;
        }

        pub fn varianceValue(self: Self) T {
            const scale = self.scale;
            return std.math.pi * std.math.pi * scale * scale / 6;
        }

        pub fn medianValue(self: Self) T {
            return self.location - self.scale * @log(@log(@as(T, 2)));
        }

        pub fn modeValue(self: Self) T {
            return self.location;
        }

        pub fn minValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return gumbelFrom(source, T, self.location, self.scale);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            fillGumbelFrom(source, T, dest, self.location, self.scale);
        }
    };
}

pub fn frechet(rng: Rng, comptime T: type, location: T, scale: T, shape: T) T {
    return frechetFrom(rng, T, location, scale, shape);
}

pub fn frechetChecked(rng: Rng, comptime T: type, location: T, scale: T, shape: T) Error!T {
    return frechetCheckedFrom(rng, T, location, scale, shape);
}

pub fn frechetCheckedFrom(source: anytype, comptime T: type, location: T, scale: T, shape: T) Error!T {
    const dist = try Frechet(T).init(location, scale, shape);
    return dist.sampleFrom(source);
}

pub fn frechetFrom(source: anytype, comptime T: type, location: T, scale: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and shape > 0);
    const u = Rng.floatOpenClosedFrom(source, T);
    return location + scale * std.math.pow(T, -@log(u), -1 / shape);
}

pub fn fillFrechet(rng: Rng, comptime T: type, dest: []T, location: T, scale: T, shape: T) void {
    fillFrechetFrom(rng, T, dest, location, scale, shape);
}

pub fn fillFrechetFrom(source: anytype, comptime T: type, dest: []T, location: T, scale: T, shape: T) void {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and shape > 0);
    Rng.fillOpenClosedFrom(source, T, dest);
    if (shape == 1) {
        frechetShapeOneFromOpenClosedUniforms(T, dest, location, scale);
        return;
    }

    frechetFromOpenClosedUniforms(T, dest, location, scale, -1 / shape);
}

pub fn fillFrechetChecked(rng: Rng, comptime T: type, dest: []T, location: T, scale: T, shape: T) Error!void {
    return fillFrechetCheckedFrom(rng, T, dest, location, scale, shape);
}

pub fn fillFrechetCheckedFrom(source: anytype, comptime T: type, dest: []T, location: T, scale: T, shape: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Frechet(T).init(location, scale, shape);
    sampler.fillFrom(source, dest);
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

        pub fn locationValue(self: Self) T {
            return self.location;
        }

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn shapeValue(self: Self) T {
            return self.shape;
        }

        pub fn expectedValue(self: Self) ?T {
            if (!(self.shape > 1)) return null;
            return self.location + self.scale * std.math.gamma(T, 1 - 1 / self.shape);
        }

        pub fn varianceValue(self: Self) ?T {
            if (!(self.shape > 2)) return null;
            const mean_factor = std.math.gamma(T, 1 - 1 / self.shape);
            const second_moment_factor = std.math.gamma(T, 1 - 2 / self.shape);
            const scale_squared = self.scale * self.scale;
            return scale_squared * (second_moment_factor - mean_factor * mean_factor);
        }

        pub fn medianValue(self: Self) T {
            return self.location + self.scale * std.math.pow(T, @log(@as(T, 2)), -1 / self.shape);
        }

        pub fn modeValue(self: Self) T {
            return self.location + self.scale * std.math.pow(T, self.shape / (self.shape + 1), 1 / self.shape);
        }

        pub fn minValue(self: Self) T {
            return self.location;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return frechetFrom(source, T, self.location, self.scale, self.shape);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            fillFrechetFrom(source, T, dest, self.location, self.scale, self.shape);
        }
    };
}

pub fn skewNormal(rng: Rng, comptime T: type, location: T, scale: T, shape: T) T {
    return skewNormalFrom(rng, T, location, scale, shape);
}

pub fn skewNormalChecked(rng: Rng, comptime T: type, location: T, scale: T, shape: T) Error!T {
    return skewNormalCheckedFrom(rng, T, location, scale, shape);
}

pub fn skewNormalCheckedFrom(source: anytype, comptime T: type, location: T, scale: T, shape: T) Error!T {
    const dist = try SkewNormal(T).init(location, scale, shape);
    return dist.sampleFrom(source);
}

pub inline fn skewNormalFrom(source: anytype, comptime T: type, location: T, scale: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and std.math.isFinite(shape));

    const z1 = Rng.normalFastFrom(source, T, 0, 1);
    if (shape == 0) return location + scale * z1;

    const z2 = Rng.normalFastFrom(source, T, 0, 1);
    const normalized = if (shape == -1)
        @min(z1, z2)
    else if (shape == 1)
        @max(z1, z2)
    else blk: {
        const delta = shape / @sqrt(1 + shape * shape);
        break :blk delta * @abs(z1) + @sqrt(1 - delta * delta) * z2;
    };
    return location + scale * normalized;
}

pub fn fillSkewNormal(rng: Rng, comptime T: type, dest: []T, location: T, scale: T, shape: T) void {
    fillSkewNormalFrom(rng, T, dest, location, scale, shape);
}

pub fn fillSkewNormalFrom(source: anytype, comptime T: type, dest: []T, location: T, scale: T, shape: T) void {
    comptime requireFloat(T);
    std.debug.assert(std.math.isFinite(location) and scale > 0 and std.math.isFinite(shape));
    if (shape == 0) {
        for (dest) |*item| item.* = location + scale * Rng.normalFastFrom(source, T, 0, 1);
        return;
    }
    if (shape == -1) {
        for (dest) |*item| {
            const z1 = Rng.normalFastFrom(source, T, 0, 1);
            const z2 = Rng.normalFastFrom(source, T, 0, 1);
            item.* = location + scale * @min(z1, z2);
        }
        return;
    }
    if (shape == 1) {
        for (dest) |*item| {
            const z1 = Rng.normalFastFrom(source, T, 0, 1);
            const z2 = Rng.normalFastFrom(source, T, 0, 1);
            item.* = location + scale * @max(z1, z2);
        }
        return;
    }
    if (shape != 0 and shape != -1 and shape != 1) {
        const delta = shape / @sqrt(1 + shape * shape);
        const orthogonal = @sqrt(1 - delta * delta);
        for (dest) |*item| {
            const z1 = Rng.normalFastFrom(source, T, 0, 1);
            const z2 = Rng.normalFastFrom(source, T, 0, 1);
            item.* = location + scale * (delta * @abs(z1) + orthogonal * z2);
        }
        return;
    }
}

pub fn fillSkewNormalChecked(rng: Rng, comptime T: type, dest: []T, location: T, scale: T, shape: T) Error!void {
    return fillSkewNormalCheckedFrom(rng, T, dest, location, scale, shape);
}

pub fn fillSkewNormalCheckedFrom(source: anytype, comptime T: type, dest: []T, location: T, scale: T, shape: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try SkewNormal(T).init(location, scale, shape);
    sampler.fillFrom(source, dest);
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

        pub fn locationValue(self: Self) T {
            return self.location;
        }

        pub fn scaleValue(self: Self) T {
            return self.scale;
        }

        pub fn shapeValue(self: Self) T {
            return self.shape;
        }

        pub fn expectedValue(self: Self) T {
            const delta = self.shape / @sqrt(1 + self.shape * self.shape);
            return self.location + self.scale * delta * @sqrt(2.0 / std.math.pi);
        }

        pub fn varianceValue(self: Self) T {
            const delta = self.shape / @sqrt(1 + self.shape * self.shape);
            const scale_squared = self.scale * self.scale;
            return scale_squared * (1 - 2.0 * delta * delta / std.math.pi);
        }

        pub fn minValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub inline fn sampleFrom(self: Self, source: anytype) T {
            return skewNormalFrom(source, T, self.location, self.scale, self.shape);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub inline fn fillFrom(self: Self, source: anytype, dest: []T) void {
            fillSkewNormalFrom(source, T, dest, self.location, self.scale, self.shape);
        }
    };
}

pub fn pert(rng: Rng, comptime T: type, min: T, mode: T, max: T, shape: T) T {
    return pertFrom(rng, T, min, mode, max, shape);
}

pub fn pertChecked(rng: Rng, comptime T: type, min: T, mode: T, max: T, shape: T) Error!T {
    return pertCheckedFrom(rng, T, min, mode, max, shape);
}

pub fn pertCheckedFrom(source: anytype, comptime T: type, min: T, mode: T, max: T, shape: T) Error!T {
    const dist = try Pert(T).init(min, mode, max, shape);
    return dist.sampleFrom(source);
}

pub fn pertFrom(source: anytype, comptime T: type, min: T, mode: T, max: T, shape: T) T {
    comptime requireFloat(T);
    std.debug.assert(min < max and min <= mode and mode <= max and shape >= 0);
    const range = max - min;
    const alpha = 1 + shape * (mode - min) / range;
    const beta_param = 1 + shape * (max - mode) / range;
    return min + range * betaFrom(source, T, alpha, beta_param);
}

pub fn fillPert(rng: Rng, comptime T: type, dest: []T, min: T, mode: T, max: T, shape: T) void {
    fillPertFrom(rng, T, dest, min, mode, max, shape);
}

pub fn fillPertFrom(source: anytype, comptime T: type, dest: []T, min: T, mode: T, max: T, shape: T) void {
    comptime requireFloat(T);
    std.debug.assert(min < max and min <= mode and mode <= max and shape >= 0);
    const sampler = Pert(T).init(min, mode, max, shape) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillPertChecked(rng: Rng, comptime T: type, dest: []T, min: T, mode: T, max: T, shape: T) Error!void {
    return fillPertCheckedFrom(rng, T, dest, min, mode, max, shape);
}

pub fn fillPertCheckedFrom(source: anytype, comptime T: type, dest: []T, min: T, mode: T, max: T, shape: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Pert(T).init(min, mode, max, shape);
    sampler.fillFrom(source, dest);
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

        pub fn initRange(min: T, max: T) PertBuilder(T) {
            comptime requireFloat(T);
            return .{ .min = min, .max = max, .shape = 4 };
        }

        pub fn initMean(min: T, mean: T, max: T, shape: T) Error!Self {
            comptime requireFloat(T);
            if (!(shape > 0) or !std.math.isFinite(shape)) return error.InvalidParameter;
            const mode = ((shape + 2) * mean - min - max) / shape;
            return Self.init(min, mode, max, shape);
        }

        pub fn minValue(self: Self) T {
            return self.min;
        }

        pub fn maxValue(self: Self) T {
            return self.min + self.range;
        }

        pub fn shapeValue(self: Self) T {
            return self.alpha + self.beta_param - 2;
        }

        pub fn modeValue(self: Self) ?T {
            const shape = self.shapeValue();
            if (shape == 0) return null;
            return self.min + self.range * (self.alpha - 1) / shape;
        }

        pub fn alphaValue(self: Self) T {
            return self.alpha;
        }

        pub fn betaValue(self: Self) T {
            return self.beta_param;
        }

        pub fn expectedValue(self: Self) T {
            return self.min + self.range * self.alpha / (self.alpha + self.beta_param);
        }

        pub fn varianceValue(self: Self) T {
            const sum = self.alpha + self.beta_param;
            return self.range * self.range * self.alpha * self.beta_param / (sum * sum * (sum + 1));
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            return self.min + self.range * betaFrom(source, T, self.alpha, self.beta_param);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn PertBuilder(comptime T: type) type {
    return struct {
        const Self = @This();

        min: T,
        max: T,
        shape: T,

        pub fn minValue(self: Self) T {
            return self.min;
        }

        pub fn maxValue(self: Self) T {
            return self.max;
        }

        pub fn shapeValue(self: Self) T {
            return self.shape;
        }

        pub fn withShape(self: Self, shape: T) Self {
            return .{ .min = self.min, .max = self.max, .shape = shape };
        }

        pub fn withMode(self: Self, mode: T) Error!Pert(T) {
            return Pert(T).init(self.min, mode, self.max, self.shape);
        }

        pub fn withMean(self: Self, mean: T) Error!Pert(T) {
            return Pert(T).initMean(self.min, mean, self.max, self.shape);
        }
    };
}

pub fn unitCircle(rng: Rng, comptime T: type) [2]T {
    return unitCircleFrom(rng, T);
}

pub fn unitCircleFrom(source: anytype, comptime T: type) [2]T {
    comptime requireFloat(T);
    if (T == f64) return unitCircleF64PointFrom(source);
    while (true) {
        const x1 = signedUnitFloatFrom(source, T);
        const x2 = signedUnitFloatFrom(source, T);
        const sum = x1 * x1 + x2 * x2;
        if (!(sum > 0 and sum < 1)) continue;

        const diff = x1 * x1 - x2 * x2;
        return .{ diff / sum, 2 * x1 * x2 / sum };
    }
}

pub fn fillUnitCircle(rng: Rng, comptime T: type, dest: [][2]T) void {
    fillUnitCircleFrom(rng, T, dest);
}

pub fn fillUnitCircleFrom(source: anytype, comptime T: type, dest: [][2]T) void {
    if (T == f64) {
        fillUnitCircleF64From(source, dest);
        return;
    }
    for (dest) |*item| item.* = unitCircleFrom(source, T);
}

pub fn unitDisc(rng: Rng, comptime T: type) [2]T {
    return unitDiscFrom(rng, T);
}

pub fn unitDiscFrom(source: anytype, comptime T: type) [2]T {
    comptime requireFloat(T);
    if (T == f64) return unitDiscF64PointFrom(source);
    while (true) {
        const x1 = signedUnitFloatFrom(source, T);
        const x2 = signedUnitFloatFrom(source, T);
        if (x1 * x1 + x2 * x2 <= 1) return .{ x1, x2 };
    }
}

pub fn fillUnitDisc(rng: Rng, comptime T: type, dest: [][2]T) void {
    fillUnitDiscFrom(rng, T, dest);
}

pub fn fillUnitDiscFrom(source: anytype, comptime T: type, dest: [][2]T) void {
    if (T == f64) {
        fillUnitDiscF64From(source, dest);
        return;
    }
    for (dest) |*item| item.* = unitDiscFrom(source, T);
}

pub fn unitSphere(rng: Rng, comptime T: type) [3]T {
    return unitSphereFrom(rng, T);
}

pub fn unitSphereFrom(source: anytype, comptime T: type) [3]T {
    comptime requireFloat(T);
    if (T == f64) return unitSphereF64PointFrom(source);
    while (true) {
        const x1 = signedUnitFloatFrom(source, T);
        const x2 = signedUnitFloatFrom(source, T);
        const sum = x1 * x1 + x2 * x2;
        if (sum >= 1) continue;

        const factor = 2 * @sqrt(1 - sum);
        return .{ x1 * factor, x2 * factor, 1 - 2 * sum };
    }
}

pub fn fillUnitSphere(rng: Rng, comptime T: type, dest: [][3]T) void {
    fillUnitSphereFrom(rng, T, dest);
}

pub fn fillUnitSphereFrom(source: anytype, comptime T: type, dest: [][3]T) void {
    if (T == f64) {
        fillUnitSphereF64From(source, dest);
        return;
    }
    for (dest) |*item| item.* = unitSphereFrom(source, T);
}

pub fn unitBall(rng: Rng, comptime T: type) [3]T {
    return unitBallFrom(rng, T);
}

pub fn unitBallFrom(source: anytype, comptime T: type) [3]T {
    comptime requireFloat(T);
    if (T == f64) return unitBallF64PointFrom(source);
    while (true) {
        const x1 = signedUnitFloatFrom(source, T);
        const x2 = signedUnitFloatFrom(source, T);
        const x3 = signedUnitFloatFrom(source, T);
        if (x1 * x1 + x2 * x2 + x3 * x3 <= 1) return .{ x1, x2, x3 };
    }
}

pub fn fillUnitBall(rng: Rng, comptime T: type, dest: [][3]T) void {
    fillUnitBallFrom(rng, T, dest);
}

pub fn fillUnitBallFrom(source: anytype, comptime T: type, dest: [][3]T) void {
    if (T == f64) {
        fillUnitBallF64From(source, dest);
        return;
    }
    for (dest) |*item| item.* = unitBallFrom(source, T);
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

fn signedUnitF64PointFrom(source: anytype) f64 {
    const repr = (@as(u64, 0x400) << 52) | (Rng.nextFrom(source) >> 12);
    return @as(f64, @bitCast(repr)) - 3.0;
}

fn unitCircleF64PointFrom(source: anytype) [2]f64 {
    while (true) {
        const x = signedUnitF64PointFrom(source);
        const y = signedUnitF64PointFrom(source);
        const x2 = x * x;
        const y2 = y * y;
        const sum = @mulAdd(f64, y, y, x2);
        if (!(sum > 0 and sum < 1)) continue;
        return .{ (x2 - y2) / sum, 2 * x * y / sum };
    }
}

fn unitDiscF64PointFrom(source: anytype) [2]f64 {
    while (true) {
        const x = signedUnitF64PointFrom(source);
        const y = signedUnitF64PointFrom(source);
        if (@mulAdd(f64, y, y, x * x) <= 1) return .{ x, y };
    }
}

fn unitSphereF64PointFrom(source: anytype) [3]f64 {
    while (true) {
        const x = signedUnitF64PointFrom(source);
        const y = signedUnitF64PointFrom(source);
        const sum = @mulAdd(f64, y, y, x * x);
        if (sum >= 1) continue;
        const factor = 2 * @sqrt(1 - sum);
        return .{ x * factor, y * factor, 1 - 2 * sum };
    }
}

fn unitBallF64PointFrom(source: anytype) [3]f64 {
    while (true) {
        const x = signedUnitF64PointFrom(source);
        const y = signedUnitF64PointFrom(source);
        const z = signedUnitF64PointFrom(source);
        const xy = @mulAdd(f64, y, y, x * x);
        if (@mulAdd(f64, z, z, xy) <= 1) return .{ x, y, z };
    }
}

fn fillUnitDiscF64From(source: anytype, dest: [][2]f64) void {
    var x_candidates: [2048]f64 = undefined;
    var y_candidates: [2048]f64 = undefined;

    var filled: usize = 0;
    while (filled < dest.len) {
        const remaining = dest.len - filled;
        const candidate_count = @min(x_candidates.len, @max(remaining, remaining * 2));
        fillSignedUnitF64(source, x_candidates[0..candidate_count]);
        fillSignedUnitF64(source, y_candidates[0..candidate_count]);

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

fn fillUnitCircleF64From(source: anytype, dest: [][2]f64) void {
    var x_candidates: [2048]f64 = undefined;
    var y_candidates: [2048]f64 = undefined;

    var filled: usize = 0;
    while (filled < dest.len) {
        const remaining = dest.len - filled;
        const candidate_count = @min(x_candidates.len, @max(remaining, remaining * 2));
        fillSignedUnitF64(source, x_candidates[0..candidate_count]);
        fillSignedUnitF64(source, y_candidates[0..candidate_count]);

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

fn fillUnitSphereF64From(source: anytype, dest: [][3]f64) void {
    var x_candidates: [2048]f64 = undefined;
    var y_candidates: [2048]f64 = undefined;

    var filled: usize = 0;
    while (filled < dest.len) {
        const remaining = dest.len - filled;
        const candidate_count = @min(x_candidates.len, @max(remaining, remaining * 2));
        fillSignedUnitF64(source, x_candidates[0..candidate_count]);
        fillSignedUnitF64(source, y_candidates[0..candidate_count]);

        var i: usize = 0;
        while (i < candidate_count and filled < dest.len) : (i += 1) {
            const x = x_candidates[i];
            const y = y_candidates[i];
            const sum = x * x + y * y;
            if (sum < 1) {
                const factor = 2 * @sqrt(1 - sum);
                dest[filled] = .{ x * factor, y * factor, 1 - 2 * sum };
                filled += 1;
            }
        }
    }
}

fn fillUnitBallF64From(source: anytype, dest: [][3]f64) void {
    var x_candidates: [4096]f64 = undefined;
    var y_candidates: [4096]f64 = undefined;
    var z_candidates: [4096]f64 = undefined;

    var filled: usize = 0;
    while (filled < dest.len) {
        const remaining = dest.len - filled;
        const candidate_count = @min(x_candidates.len, @max(remaining, remaining * 2));
        fillSignedUnitF64(source, x_candidates[0..candidate_count]);
        fillSignedUnitF64(source, y_candidates[0..candidate_count]);
        fillSignedUnitF64(source, z_candidates[0..candidate_count]);

        var i: usize = 0;
        while (i < candidate_count and filled < dest.len) : (i += 1) {
            const x = x_candidates[i];
            const y = y_candidates[i];
            const z = z_candidates[i];
            if (x * x + y * y + z * z <= 1) {
                dest[filled] = .{ x, y, z };
                filled += 1;
            }
        }
    }
}

fn fillSignedUnitF64(source: anytype, dest: []f64) void {
    if (comptime @TypeOf(source) == Rng or @TypeOf(source) == *Alea4x64) {
        Rng.fillRangeFrom(source, f64, dest, -1, 1);
        return;
    }
    for (dest) |*item| {
        const repr = (@as(u64, 0x400) << 52) | (Rng.nextFrom(source) >> 12);
        item.* = @as(f64, @bitCast(repr)) - 3.0;
    }
}

pub fn UnitCircle(comptime T: type) type {
    return struct {
        pub fn dimensionValue(_: @This()) usize {
            return 2;
        }

        pub fn radiusValue(_: @This()) T {
            return 1;
        }

        pub fn isSurface(_: @This()) bool {
            return true;
        }

        pub fn coordinateExpectedValue(_: @This()) T {
            return 0;
        }

        pub fn coordinateVarianceValue(_: @This()) T {
            return 1.0 / 2.0;
        }

        pub fn radialExpectedValue(_: @This()) T {
            return 1;
        }

        pub fn radialVarianceValue(_: @This()) T {
            return 0;
        }

        pub fn sample(_: @This(), rng: Rng) [2]T {
            return unitCircle(rng, T);
        }

        pub fn sampleFrom(_: @This(), source: anytype) [2]T {
            return unitCircleFrom(source, T);
        }

        pub fn fill(_: @This(), rng: Rng, dest: [][2]T) void {
            fillUnitCircle(rng, T, dest);
        }

        pub fn fillFrom(_: @This(), source: anytype, dest: [][2]T) void {
            fillUnitCircleFrom(source, T, dest);
        }
    };
}

pub fn UnitDisc(comptime T: type) type {
    return struct {
        pub fn dimensionValue(_: @This()) usize {
            return 2;
        }

        pub fn radiusValue(_: @This()) T {
            return 1;
        }

        pub fn isSurface(_: @This()) bool {
            return false;
        }

        pub fn coordinateExpectedValue(_: @This()) T {
            return 0;
        }

        pub fn coordinateVarianceValue(_: @This()) T {
            return 1.0 / 4.0;
        }

        pub fn radialExpectedValue(_: @This()) T {
            return 2.0 / 3.0;
        }

        pub fn radialVarianceValue(_: @This()) T {
            return 1.0 / 18.0;
        }

        pub fn sample(_: @This(), rng: Rng) [2]T {
            return unitDisc(rng, T);
        }

        pub fn sampleFrom(_: @This(), source: anytype) [2]T {
            return unitDiscFrom(source, T);
        }

        pub fn fill(_: @This(), rng: Rng, dest: [][2]T) void {
            fillUnitDisc(rng, T, dest);
        }

        pub fn fillFrom(_: @This(), source: anytype, dest: [][2]T) void {
            fillUnitDiscFrom(source, T, dest);
        }
    };
}

pub fn UnitSphere(comptime T: type) type {
    return struct {
        pub fn dimensionValue(_: @This()) usize {
            return 3;
        }

        pub fn radiusValue(_: @This()) T {
            return 1;
        }

        pub fn isSurface(_: @This()) bool {
            return true;
        }

        pub fn coordinateExpectedValue(_: @This()) T {
            return 0;
        }

        pub fn coordinateVarianceValue(_: @This()) T {
            return 1.0 / 3.0;
        }

        pub fn radialExpectedValue(_: @This()) T {
            return 1;
        }

        pub fn radialVarianceValue(_: @This()) T {
            return 0;
        }

        pub fn sample(_: @This(), rng: Rng) [3]T {
            return unitSphere(rng, T);
        }

        pub fn sampleFrom(_: @This(), source: anytype) [3]T {
            return unitSphereFrom(source, T);
        }

        pub fn fill(_: @This(), rng: Rng, dest: [][3]T) void {
            fillUnitSphere(rng, T, dest);
        }

        pub fn fillFrom(_: @This(), source: anytype, dest: [][3]T) void {
            fillUnitSphereFrom(source, T, dest);
        }
    };
}

pub fn UnitBall(comptime T: type) type {
    return struct {
        pub fn dimensionValue(_: @This()) usize {
            return 3;
        }

        pub fn radiusValue(_: @This()) T {
            return 1;
        }

        pub fn isSurface(_: @This()) bool {
            return false;
        }

        pub fn coordinateExpectedValue(_: @This()) T {
            return 0;
        }

        pub fn coordinateVarianceValue(_: @This()) T {
            return 1.0 / 5.0;
        }

        pub fn radialExpectedValue(_: @This()) T {
            return 3.0 / 4.0;
        }

        pub fn radialVarianceValue(_: @This()) T {
            return 3.0 / 80.0;
        }

        pub fn sample(_: @This(), rng: Rng) [3]T {
            return unitBall(rng, T);
        }

        pub fn sampleFrom(_: @This(), source: anytype) [3]T {
            return unitBallFrom(source, T);
        }

        pub fn fill(_: @This(), rng: Rng, dest: [][3]T) void {
            fillUnitBall(rng, T, dest);
        }

        pub fn fillFrom(_: @This(), source: anytype, dest: [][3]T) void {
            fillUnitBallFrom(source, T, dest);
        }
    };
}

pub fn inverseGaussian(rng: Rng, comptime T: type, mean: T, shape: T) T {
    return inverseGaussianFrom(rng, T, mean, shape);
}

pub fn inverseGaussianChecked(rng: Rng, comptime T: type, mean: T, shape: T) Error!T {
    return inverseGaussianCheckedFrom(rng, T, mean, shape);
}

pub fn inverseGaussianCheckedFrom(source: anytype, comptime T: type, mean: T, shape: T) Error!T {
    const dist = try InverseGaussian(T).init(mean, shape);
    return dist.sampleFrom(source);
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

pub fn fillInverseGaussian(rng: Rng, comptime T: type, dest: []T, mean: T, shape: T) void {
    fillInverseGaussianFrom(rng, T, dest, mean, shape);
}

pub fn fillInverseGaussianFrom(source: anytype, comptime T: type, dest: []T, mean: T, shape: T) void {
    comptime requireFloat(T);
    std.debug.assert(mean > 0 and shape > 0);
    Rng.fillNormalFrom(source, T, dest, 0, 1);
    inverseGaussianFromNormals(source, T, dest, mean, shape);
}

pub fn fillInverseGaussianChecked(rng: Rng, comptime T: type, dest: []T, mean: T, shape: T) Error!void {
    return fillInverseGaussianCheckedFrom(rng, T, dest, mean, shape);
}

pub fn fillInverseGaussianCheckedFrom(source: anytype, comptime T: type, dest: []T, mean: T, shape: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try InverseGaussian(T).init(mean, shape);
    sampler.fillFrom(source, dest);
}

pub fn InverseGaussian(comptime T: type) type {
    return struct {
        const Self = @This();

        mean: T,
        shape: T,
        mean_over_2shape: T,
        mean_squared: T,

        pub fn init(mean: T, shape: T) Error!Self {
            comptime requireFloat(T);
            if (!(mean > 0) or !(shape > 0)) return error.InvalidParameter;
            if (!std.math.isFinite(mean) or !std.math.isFinite(shape)) return error.InvalidParameter;
            return .{
                .mean = mean,
                .shape = shape,
                .mean_over_2shape = mean / (2 * shape),
                .mean_squared = mean * mean,
            };
        }

        pub fn meanValue(self: Self) T {
            return self.mean;
        }

        pub fn shapeValue(self: Self) T {
            return self.shape;
        }

        pub fn expectedValue(self: Self) T {
            return self.mean;
        }

        pub fn varianceValue(self: Self) T {
            return self.mean_squared * self.mean / self.shape;
        }

        pub fn minValue(self: Self) T {
            _ = self;
            return 0;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            const z = Rng.normalFastFrom(source, T, 0, 1);
            const y = self.mean * z * z;
            const x = self.mean + self.mean_over_2shape * (y - @sqrt(4 * self.shape * y + y * y));
            if (Rng.floatFrom(source, T) <= self.mean / (self.mean + x)) return x;
            return self.mean_squared / x;
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            fillInverseGaussianFrom(source, T, dest, self.mean, self.shape);
        }
    };
}

pub fn normalInverseGaussian(rng: Rng, comptime T: type, alpha: T, beta_param: T) T {
    return normalInverseGaussianFrom(rng, T, alpha, beta_param);
}

pub fn normalInverseGaussianChecked(rng: Rng, comptime T: type, alpha: T, beta_param: T) Error!T {
    return normalInverseGaussianCheckedFrom(rng, T, alpha, beta_param);
}

pub fn normalInverseGaussianCheckedFrom(source: anytype, comptime T: type, alpha: T, beta_param: T) Error!T {
    const dist = try NormalInverseGaussian(T).init(alpha, beta_param);
    return dist.sampleFrom(source);
}

pub fn normalInverseGaussianFrom(source: anytype, comptime T: type, alpha: T, beta_param: T) T {
    comptime requireFloat(T);
    std.debug.assert(alpha > 0 and @abs(beta_param) < alpha);

    const ratio = beta_param / alpha;
    const gamma_param = alpha * @sqrt(1 - ratio * ratio);
    const inv_gauss = inverseGaussianFrom(source, T, 1 / gamma_param, 1);
    return beta_param * inv_gauss + @sqrt(inv_gauss) * Rng.normalFastFrom(source, T, 0, 1);
}

pub fn fillNormalInverseGaussian(rng: Rng, comptime T: type, dest: []T, alpha: T, beta_param: T) void {
    fillNormalInverseGaussianFrom(rng, T, dest, alpha, beta_param);
}

pub fn fillNormalInverseGaussianFrom(source: anytype, comptime T: type, dest: []T, alpha: T, beta_param: T) void {
    const sampler = NormalInverseGaussian(T).init(alpha, beta_param) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillNormalInverseGaussianChecked(rng: Rng, comptime T: type, dest: []T, alpha: T, beta_param: T) Error!void {
    return fillNormalInverseGaussianCheckedFrom(rng, T, dest, alpha, beta_param);
}

pub fn fillNormalInverseGaussianCheckedFrom(source: anytype, comptime T: type, dest: []T, alpha: T, beta_param: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try NormalInverseGaussian(T).init(alpha, beta_param);
    sampler.fillFrom(source, dest);
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

        pub fn alphaValue(self: Self) T {
            const gamma_param = 1 / self.inverse_mean;
            return @sqrt(gamma_param * gamma_param + self.beta_param * self.beta_param);
        }

        pub fn betaValue(self: Self) T {
            return self.beta_param;
        }

        pub fn gammaValue(self: Self) T {
            return 1 / self.inverse_mean;
        }

        pub fn expectedValue(self: Self) T {
            return self.beta_param * self.inverse_mean;
        }

        pub fn varianceValue(self: Self) T {
            const gamma_param = self.gammaValue();
            const alpha = self.alphaValue();
            return alpha * alpha / (gamma_param * gamma_param * gamma_param);
        }

        pub fn minValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn maxValue(self: Self) ?T {
            _ = self;
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            const inv_gauss = self.inverse_gaussian.sampleFrom(source);
            return self.beta_param * inv_gauss + @sqrt(inv_gauss) * Rng.normalFastFrom(source, T, 0, 1);
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            self.inverse_gaussian.fillFrom(source, dest);
            for (dest) |*item| {
                const inv_gauss = item.*;
                item.* = self.beta_param * inv_gauss + @sqrt(inv_gauss) * Rng.normalFastFrom(source, T, 0, 1);
            }
        }
    };
}

pub fn zipf(rng: Rng, comptime T: type, n: T, exponent: T) T {
    return zipfFrom(rng, T, n, exponent);
}

pub fn zipfChecked(rng: Rng, comptime T: type, n: T, exponent: T) Error!T {
    return zipfCheckedFrom(rng, T, n, exponent);
}

pub fn zipfCheckedFrom(source: anytype, comptime T: type, n: T, exponent: T) Error!T {
    const dist = try Zipf(T).init(n, exponent);
    return dist.sampleFrom(source);
}

pub fn zipfFrom(source: anytype, comptime T: type, n: T, exponent: T) T {
    comptime requireFloat(T);
    std.debug.assert(exponent >= 0 and n >= 1);
    const sampler = Zipf(T).init(n, exponent) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn fillZipf(rng: Rng, comptime T: type, dest: []T, n: T, exponent: T) void {
    fillZipfFrom(rng, T, dest, n, exponent);
}

pub fn fillZipfFrom(source: anytype, comptime T: type, dest: []T, n: T, exponent: T) void {
    const sampler = Zipf(T).init(n, exponent) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillZipfChecked(rng: Rng, comptime T: type, dest: []T, n: T, exponent: T) Error!void {
    return fillZipfCheckedFrom(rng, T, dest, n, exponent);
}

pub fn fillZipfCheckedFrom(source: anytype, comptime T: type, dest: []T, n: T, exponent: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Zipf(T).init(n, exponent);
    sampler.fillFrom(source, dest);
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

        pub fn nValue(self: Self) ?T {
            if (std.math.isInf(self.exponent)) return null;
            if (self.exponent == 1) return @exp(self.t - 1);
            return std.math.pow(T, self.t * (1 - self.exponent) + self.exponent, self.q);
        }

        pub fn minValue(_: Self) T {
            return 1;
        }

        pub fn maxValue(self: Self) T {
            if (std.math.isInf(self.exponent)) return 1;
            return self.nValue().?;
        }

        pub fn exponentValue(self: Self) T {
            return self.exponent;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            if (std.math.isInf(self.exponent)) return 1;

            while (true) {
                const inv_b = self.invCdf(Rng.floatFrom(source, T));
                const x = @floor(inv_b + 1);
                var ratio = std.math.pow(T, x, -self.exponent);
                if (x > 1) ratio *= std.math.pow(T, inv_b, self.exponent);

                if (Rng.floatFrom(source, T) < ratio) return x;
            }
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
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
    return zetaFrom(rng, T, exponent);
}

pub fn zetaChecked(rng: Rng, comptime T: type, exponent: T) Error!T {
    return zetaCheckedFrom(rng, T, exponent);
}

pub fn zetaCheckedFrom(source: anytype, comptime T: type, exponent: T) Error!T {
    const dist = try Zeta(T).init(exponent);
    return dist.sampleFrom(source);
}

pub fn zetaFrom(source: anytype, comptime T: type, exponent: T) T {
    comptime requireFloat(T);
    std.debug.assert(exponent > 1);

    const sampler = Zeta(T).init(exponent) catch unreachable;
    return sampler.sampleFrom(source);
}

pub fn fillZeta(rng: Rng, comptime T: type, dest: []T, exponent: T) void {
    fillZetaFrom(rng, T, dest, exponent);
}

pub fn fillZetaFrom(source: anytype, comptime T: type, dest: []T, exponent: T) void {
    const sampler = Zeta(T).init(exponent) catch unreachable;
    sampler.fillFrom(source, dest);
}

pub fn fillZetaChecked(rng: Rng, comptime T: type, dest: []T, exponent: T) Error!void {
    return fillZetaCheckedFrom(rng, T, dest, exponent);
}

pub fn fillZetaCheckedFrom(source: anytype, comptime T: type, dest: []T, exponent: T) Error!void {
    if (dest.len == 0) return;
    const sampler = try Zeta(T).init(exponent);
    sampler.fillFrom(source, dest);
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

        pub fn exponentValue(self: Self) T {
            return self.exponent_minus_one + 1;
        }

        pub fn minValue(_: Self) T {
            return 1;
        }

        pub fn maxValue(_: Self) ?T {
            return null;
        }

        pub fn sample(self: Self, rng: Rng) T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) T {
            while (true) {
                const u = Rng.floatOpenClosedFrom(source, T);
                const x = @floor(std.math.pow(T, u, -1 / self.exponent_minus_one));
                if (std.math.isInf(x)) return x;

                const t = std.math.pow(T, 1 + 1 / x, self.exponent_minus_one);
                const v = Rng.floatFrom(source, T);
                if (v * x * (t - 1) * self.b <= t * (self.b - 1)) return x;
            }
        }

        pub fn fill(self: Self, rng: Rng, dest: []T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
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

        pub fn alphaValues(self: Self) []const T {
            return self.alpha;
        }

        pub fn alphaAt(self: Self, index: usize) Error!T {
            if (index >= self.alpha.len) return error.InvalidParameter;
            return self.alpha[index];
        }

        pub fn meanAt(self: Self, index: usize) Error!T {
            return try self.alphaAt(index) / self.totalAlphaValue();
        }

        pub fn means(self: Self, allocator: std.mem.Allocator) ![]T {
            const out = try allocator.alloc(T, self.alpha.len);
            errdefer allocator.free(out);
            try self.meansInto(out);
            return out;
        }

        pub fn meansInto(self: Self, out: []T) Error!void {
            if (out.len != self.alpha.len) return error.InvalidLength;
            const alpha_0 = self.totalAlphaValue();
            for (self.alpha, out) |alpha_i, *slot| slot.* = alpha_i / alpha_0;
        }

        pub fn varianceAt(self: Self, index: usize) Error!T {
            const alpha_i = try self.alphaAt(index);
            const alpha_0 = self.totalAlphaValue();
            return alpha_i * (alpha_0 - alpha_i) / (alpha_0 * alpha_0 * (alpha_0 + 1));
        }

        pub fn variances(self: Self, allocator: std.mem.Allocator) ![]T {
            const out = try allocator.alloc(T, self.alpha.len);
            errdefer allocator.free(out);
            try self.variancesInto(out);
            return out;
        }

        pub fn variancesInto(self: Self, out: []T) Error!void {
            if (out.len != self.alpha.len) return error.InvalidLength;
            const alpha_0 = self.totalAlphaValue();
            const denominator = alpha_0 * alpha_0 * (alpha_0 + 1);
            for (self.alpha, out) |alpha_i, *slot| slot.* = alpha_i * (alpha_0 - alpha_i) / denominator;
        }

        pub fn covarianceAt(self: Self, i: usize, j: usize) Error!T {
            if (i == j) return self.varianceAt(i);
            const alpha_i = try self.alphaAt(i);
            const alpha_j = try self.alphaAt(j);
            const alpha_0 = self.totalAlphaValue();
            return -(alpha_i * alpha_j) / (alpha_0 * alpha_0 * (alpha_0 + 1));
        }

        pub fn covariances(self: Self, allocator: std.mem.Allocator) ![]T {
            const count = std.math.mul(usize, self.alpha.len, self.alpha.len) catch return error.OutOfMemory;
            const out = try allocator.alloc(T, count);
            errdefer allocator.free(out);
            try self.covariancesInto(out);
            return out;
        }

        pub fn covariancesInto(self: Self, out: []T) Error!void {
            const count = std.math.mul(usize, self.alpha.len, self.alpha.len) catch return error.InvalidLength;
            if (out.len != count) return error.InvalidLength;
            const alpha_0 = self.totalAlphaValue();
            const denominator = alpha_0 * alpha_0 * (alpha_0 + 1);
            var row: usize = 0;
            while (row < self.alpha.len) : (row += 1) {
                var col: usize = 0;
                while (col < self.alpha.len) : (col += 1) {
                    const alpha_i = self.alpha[row];
                    const alpha_j = self.alpha[col];
                    out[row * self.alpha.len + col] = if (row == col)
                        alpha_i * (alpha_0 - alpha_i) / denominator
                    else
                        -(alpha_i * alpha_j) / denominator;
                }
            }
        }

        pub fn dimensionValue(self: Self) usize {
            return self.alpha.len;
        }

        pub fn totalAlphaValue(self: Self) T {
            var total: T = 0;
            for (self.alpha) |value| total += value;
            return total;
        }

        pub fn sample(self: Self, allocator: std.mem.Allocator, rng: Rng) ![]T {
            return self.sampleFrom(allocator, rng);
        }

        pub fn sampleFrom(self: Self, allocator: std.mem.Allocator, source: anytype) ![]T {
            const out = try allocator.alloc(T, self.alpha.len);
            errdefer allocator.free(out);
            self.sampleIntoFrom(source, out);
            return out;
        }

        pub fn sampleInto(self: Self, rng: Rng, out: []T) void {
            self.sampleIntoFrom(rng, out);
        }

        pub fn sampleIntoChecked(self: Self, rng: Rng, out: []T) Error!void {
            try self.sampleIntoCheckedFrom(rng, out);
        }

        pub fn sampleIntoCheckedFrom(self: Self, source: anytype, out: []T) Error!void {
            if (out.len != self.alpha.len) return error.InvalidLength;
            self.sampleIntoFrom(source, out);
        }

        pub fn sampleManyInto(self: Self, rng: Rng, out: []T) void {
            self.sampleManyIntoFrom(rng, out);
        }

        pub fn sampleManyIntoChecked(self: Self, rng: Rng, out: []T) Error!void {
            try self.sampleManyIntoCheckedFrom(rng, out);
        }

        pub fn sampleManyIntoCheckedFrom(self: Self, source: anytype, out: []T) Error!void {
            if (out.len % self.alpha.len != 0) return error.InvalidLength;
            self.sampleManyIntoFrom(source, out);
        }

        pub fn sampleManyIntoFrom(self: Self, source: anytype, out: []T) void {
            std.debug.assert(out.len % self.alpha.len == 0);
            var offset: usize = 0;
            while (offset < out.len) : (offset += self.alpha.len) {
                self.sampleIntoFrom(source, out[offset..][0..self.alpha.len]);
            }
        }

        pub fn sampleIntoFrom(self: Self, source: anytype, out: []T) void {
            std.debug.assert(out.len == self.alpha.len);
            var total: T = 0;
            for (self.alpha, out) |a, *slot| {
                const value = gammaFrom(source, T, a, 1);
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
        total: f64,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, input_weights: []const Weight) !Self {
            if (input_weights.len == 0) return error.InvalidWeight;

            const prob = try allocator.alloc(f64, input_weights.len);
            errdefer allocator.free(prob);
            const alias = try allocator.alloc(usize, input_weights.len);
            errdefer allocator.free(alias);

            var scaled = try allocator.alloc(f64, input_weights.len);
            defer allocator.free(scaled);
            var small = try std.ArrayList(usize).initCapacity(allocator, input_weights.len);
            defer small.deinit(allocator);
            var large = try std.ArrayList(usize).initCapacity(allocator, input_weights.len);
            defer large.deinit(allocator);

            var total: f64 = 0;
            for (input_weights) |weight| {
                const value: f64 = switch (@typeInfo(Weight)) {
                    .int => @floatFromInt(weight),
                    .float => @floatCast(weight),
                    else => @compileError("alias weights must be numeric"),
                };
                if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
                total += value;
            }
            if (!(total > 0) or !std.math.isFinite(total)) return error.InvalidWeight;

            for (input_weights, 0..) |weight, i| {
                const value: f64 = switch (@typeInfo(Weight)) {
                    .int => @floatFromInt(weight),
                    .float => @floatCast(weight),
                    else => unreachable,
                };
                scaled[i] = value * @as(f64, @floatFromInt(input_weights.len)) / total;
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
                .total = total,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.prob);
            self.allocator.free(self.alias);
            self.* = undefined;
        }

        pub fn update(self: *Self, input_weights: []const Weight) !void {
            if (input_weights.len != self.prob.len) return error.InvalidParameter;

            const next = try Self.init(self.allocator, input_weights);
            self.allocator.free(self.prob);
            self.allocator.free(self.alias);
            self.prob = next.prob;
            self.alias = next.alias;
            self.total = next.total;
        }

        pub fn len(self: Self) usize {
            return self.prob.len;
        }

        pub fn isEmpty(self: Self) bool {
            return self.len() == 0;
        }

        pub fn totalWeight(self: Self) f64 {
            return self.total;
        }

        pub fn weights(self: Self, allocator: std.mem.Allocator) ![]f64 {
            const out = try allocator.alloc(f64, self.prob.len);
            errdefer allocator.free(out);
            try self.weightsInto(out);
            return out;
        }

        pub fn weightsInto(self: Self, out: []f64) Error!void {
            if (out.len != self.prob.len) return error.InvalidLength;
            @memset(out, 0);

            const column_scale = self.total / @as(f64, @floatFromInt(self.prob.len));
            for (self.prob, self.alias, 0..) |probability, alias_index, index| {
                out[index] += probability * column_scale;
                out[alias_index] += (1 - probability) * column_scale;
            }
        }

        pub fn probabilities(self: Self, allocator: std.mem.Allocator) ![]f64 {
            const out = try allocator.alloc(f64, self.prob.len);
            errdefer allocator.free(out);
            try self.probabilitiesInto(out);
            return out;
        }

        pub fn probabilitiesInto(self: Self, out: []f64) Error!void {
            try self.weightsInto(out);
            for (out) |*value| value.* /= self.total;
        }

        pub fn weightAt(self: Self, index: usize) Error!f64 {
            if (index >= self.prob.len) return error.InvalidParameter;
            const column_scale = self.total / @as(f64, @floatFromInt(self.prob.len));
            var value = self.prob[index] * column_scale;
            for (self.prob, self.alias) |probability, alias_index| {
                if (alias_index == index) value += (1 - probability) * column_scale;
            }
            return value;
        }

        pub fn probabilityAt(self: Self, index: usize) Error!f64 {
            return try self.weightAt(index) / self.total;
        }

        pub fn sample(self: Self, rng: Rng) usize {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) usize {
            const column = Rng.uintLessThanFrom(source, usize, self.prob.len);
            return if (Rng.floatFrom(source, f64) < self.prob[column]) column else self.alias[column];
        }

        pub fn fill(self: Self, rng: Rng, dest: []usize) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []usize) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }
    };
}

pub fn WeightedTree(comptime Weight: type) type {
    return struct {
        const Self = @This();

        subtotals: std.ArrayList(f64),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, input_weights: []const Weight) !Self {
            var subtotals = try std.ArrayList(f64).initCapacity(allocator, input_weights.len);
            errdefer subtotals.deinit(allocator);

            for (input_weights) |weight| {
                try subtotals.append(allocator, try weightToF64(weight));
            }
            try buildSubtotals(subtotals.items);

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
            const total = self.totalWeight();
            return total > 0 and std.math.isFinite(total);
        }

        pub fn get(self: Self, index: usize) Error!f64 {
            if (index >= self.subtotals.items.len) return error.InvalidParameter;
            return self.subtotals.items[index] - self.subtotal(2 * index + 1) - self.subtotal(2 * index + 2);
        }

        pub fn weightAt(self: Self, index: usize) Error!f64 {
            return self.get(index);
        }

        pub fn probabilityAt(self: Self, index: usize) Error!f64 {
            const weight = try self.get(index);
            const total = self.totalWeight();
            if (!(total > 0) or !std.math.isFinite(total)) return error.InvalidWeight;
            return weight / total;
        }

        pub fn weights(self: Self, allocator: std.mem.Allocator) ![]f64 {
            const out = try allocator.alloc(f64, self.len());
            errdefer allocator.free(out);
            try self.weightsInto(out);
            return out;
        }

        pub fn weightsInto(self: Self, out: []f64) Error!void {
            if (out.len != self.len()) return error.InvalidLength;
            for (out, 0..) |*slot, index| slot.* = try self.get(index);
        }

        pub fn probabilities(self: Self, allocator: std.mem.Allocator) ![]f64 {
            const out = try allocator.alloc(f64, self.len());
            errdefer allocator.free(out);
            try self.probabilitiesInto(out);
            return out;
        }

        pub fn probabilitiesInto(self: Self, out: []f64) Error!void {
            if (out.len != self.len()) return error.InvalidLength;
            if (out.len == 0) return;
            const total = self.totalWeight();
            if (!(total > 0) or !std.math.isFinite(total)) return error.InvalidWeight;
            for (out, 0..) |*slot, index| slot.* = (try self.get(index)) / total;
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
            return self.sampleCheckedFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) usize {
            return self.sampleCheckedFrom(source) catch unreachable;
        }

        pub fn fill(self: Self, rng: Rng, dest: []usize) void {
            self.fillChecked(rng, dest) catch unreachable;
        }

        pub fn fillChecked(self: Self, rng: Rng, dest: []usize) Error!void {
            try self.fillCheckedFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []usize) void {
            self.fillCheckedFrom(source, dest) catch unreachable;
        }

        pub fn fillCheckedFrom(self: Self, source: anytype, dest: []usize) Error!void {
            if (dest.len == 0) return;
            const total = self.totalWeight();
            if (!(total > 0) or !std.math.isFinite(total)) return error.InvalidWeight;
            for (dest) |*item| item.* = self.sampleWithTotalFrom(source, total);
        }

        pub fn sampleCheckedFrom(self: Self, source: anytype) Error!usize {
            const total = self.totalWeight();
            if (!(total > 0) or !std.math.isFinite(total)) return error.InvalidWeight;

            return self.sampleWithTotalFrom(source, total);
        }

        fn sampleWithTotalFrom(self: Self, source: anytype, total: f64) usize {
            var target = Rng.floatFrom(source, f64) * total;
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

        fn buildSubtotals(subtotals: []f64) Error!void {
            var i = subtotals.len;
            while (i > 1) {
                i -= 1;
                const parent = (i - 1) / 2;
                subtotals[parent] += subtotals[i];
                if (!std.math.isFinite(subtotals[parent])) return error.InvalidWeight;
            }
        }
    };
}

pub fn WeightedIntTree(comptime Weight: type) type {
    return struct {
        const Self = @This();

        subtotals: std.ArrayList(u64),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, input_weights: []const Weight) !Self {
            comptime requireUnsignedWeight(Weight);
            var subtotals = try std.ArrayList(u64).initCapacity(allocator, input_weights.len);
            errdefer subtotals.deinit(allocator);

            for (input_weights) |weight| try subtotals.append(allocator, try weightToU64(weight));
            try buildSubtotals(subtotals.items);

            return .{ .subtotals = subtotals, .allocator = allocator };
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

        pub fn totalWeight(self: Self) u64 {
            return if (self.subtotals.items.len == 0) 0 else self.subtotals.items[0];
        }

        pub fn isValid(self: Self) bool {
            return self.totalWeight() > 0;
        }

        pub fn get(self: Self, index: usize) Error!u64 {
            if (index >= self.subtotals.items.len) return error.InvalidParameter;
            return self.subtotals.items[index] - self.subtotal(2 * index + 1) - self.subtotal(2 * index + 2);
        }

        pub fn weightAt(self: Self, index: usize) Error!u64 {
            return self.get(index);
        }

        pub fn probabilityAt(self: Self, index: usize) Error!f64 {
            const weight = try self.get(index);
            const total = self.totalWeight();
            if (total == 0) return error.InvalidWeight;
            return @as(f64, @floatFromInt(weight)) / @as(f64, @floatFromInt(total));
        }

        pub fn weights(self: Self, allocator: std.mem.Allocator) ![]u64 {
            const out = try allocator.alloc(u64, self.len());
            errdefer allocator.free(out);
            try self.weightsInto(out);
            return out;
        }

        pub fn weightsInto(self: Self, out: []u64) Error!void {
            if (out.len != self.len()) return error.InvalidLength;
            for (out, 0..) |*slot, index| slot.* = try self.get(index);
        }

        pub fn probabilities(self: Self, allocator: std.mem.Allocator) ![]f64 {
            const out = try allocator.alloc(f64, self.len());
            errdefer allocator.free(out);
            try self.probabilitiesInto(out);
            return out;
        }

        pub fn probabilitiesInto(self: Self, out: []f64) Error!void {
            if (out.len != self.len()) return error.InvalidLength;
            if (out.len == 0) return;
            const total = self.totalWeight();
            if (total == 0) return error.InvalidWeight;
            const total_float = @as(f64, @floatFromInt(total));
            for (out, 0..) |*slot, index| slot.* = @as(f64, @floatFromInt(try self.get(index))) / total_float;
        }

        pub fn push(self: *Self, weight: Weight) !void {
            const value = try weightToU64(weight);
            const next_total = std.math.add(u64, self.totalWeight(), value) catch return error.InvalidWeight;

            try self.subtotals.append(self.allocator, value);
            var index = self.subtotals.items.len - 1;
            while (index != 0) {
                index = (index - 1) / 2;
                self.subtotals.items[index] += value;
            }
            std.debug.assert(self.totalWeight() == next_total);
        }

        pub fn pop(self: *Self) ?u64 {
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
            const value = try weightToU64(weight);
            const old = try self.get(index);
            if (value >= old) {
                const delta = value - old;
                _ = std.math.add(u64, self.totalWeight(), delta) catch return error.InvalidWeight;
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
            return self.sampleCheckedFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) usize {
            return self.sampleCheckedFrom(source) catch unreachable;
        }

        pub fn fill(self: Self, rng: Rng, dest: []usize) void {
            self.fillChecked(rng, dest) catch unreachable;
        }

        pub fn fillChecked(self: Self, rng: Rng, dest: []usize) Error!void {
            try self.fillCheckedFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []usize) void {
            self.fillCheckedFrom(source, dest) catch unreachable;
        }

        pub fn fillCheckedFrom(self: Self, source: anytype, dest: []usize) Error!void {
            if (dest.len == 0) return;
            const total = self.totalWeight();
            if (total == 0) return error.InvalidWeight;
            for (dest) |*item| item.* = self.sampleWithTotalFrom(source, total);
        }

        pub fn sampleCheckedFrom(self: Self, source: anytype) Error!usize {
            const total = self.totalWeight();
            if (total == 0) return error.InvalidWeight;

            return self.sampleWithTotalFrom(source, total);
        }

        fn sampleWithTotalFrom(self: Self, source: anytype, total: u64) usize {
            var target = Rng.uintLessThanFrom(source, u64, total);
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

        fn buildSubtotals(subtotals: []u64) Error!void {
            var i = subtotals.len;
            while (i > 1) {
                i -= 1;
                const parent = (i - 1) / 2;
                subtotals[parent] = std.math.add(u64, subtotals[parent], subtotals[i]) catch return error.InvalidWeight;
            }
        }

        fn weightToU64(weight: Weight) Error!u64 {
            if (@typeInfo(Weight).int.bits > 64 and weight > std.math.maxInt(u64)) return error.InvalidWeight;
            return @intCast(weight);
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
        .int => low < high,
        .float => std.math.isFinite(low) and std.math.isFinite(high) and low < high,
        else => @compileError("Uniform supports integer and floating-point types"),
    };
}

fn rangeLessEqual(comptime T: type, low: T, high: T) bool {
    return switch (@typeInfo(T)) {
        .int => low <= high,
        .float => std.math.isFinite(low) and std.math.isFinite(high) and low <= high,
        else => @compileError("Uniform supports integer and floating-point types"),
    };
}

fn requireFloat(comptime T: type) void {
    if (@typeInfo(T) != .float) @compileError("expected float type, found " ++ @typeName(T));
}

fn requireFloatOrFloatVector(comptime T: type) void {
    switch (@typeInfo(T)) {
        .float => {},
        .vector => |info| requireFloat(info.child),
        else => @compileError("expected float or float vector type, found " ++ @typeName(T)),
    }
}

fn vectorInfo(comptime VectorType: type) @TypeOf(@typeInfo(VectorType).vector) {
    const info = @typeInfo(VectorType);
    if (info != .vector) @compileError("expected vector type, found " ++ @typeName(VectorType));
    return info.vector;
}

fn vectorChild(comptime VectorType: type) type {
    @setEvalBranchQuota(2000);
    return vectorInfo(VectorType).child;
}

fn zeroOf(comptime T: type) T {
    requireFloatOrFloatVector(T);
    return switch (@typeInfo(T)) {
        .float => 0,
        .vector => @splat(0),
        else => unreachable,
    };
}

fn oneOf(comptime T: type) T {
    requireFloatOrFloatVector(T);
    return switch (@typeInfo(T)) {
        .float => 1,
        .vector => @splat(1),
        else => unreachable,
    };
}

fn splatOrScalar(comptime T: type, comptime value: comptime_float) T {
    requireFloatOrFloatVector(T);
    return switch (@typeInfo(T)) {
        .float => value,
        .vector => |info| @splat(@as(info.child, value)),
        else => unreachable,
    };
}

fn open01From(source: anytype, comptime T: type) T {
    requireFloatOrFloatVector(T);
    return switch (@typeInfo(T)) {
        .float => Rng.floatOpenFrom(source, T),
        .vector => Rng.vectorOpenFrom(source, T),
        else => unreachable,
    };
}

fn openClosed01From(source: anytype, comptime T: type) T {
    requireFloatOrFloatVector(T);
    return switch (@typeInfo(T)) {
        .float => Rng.floatOpenClosedFrom(source, T),
        .vector => Rng.vectorOpenClosedFrom(source, T),
        else => unreachable,
    };
}

fn fillOpen01From(source: anytype, comptime T: type, dest: []T) void {
    requireFloatOrFloatVector(T);
    switch (@typeInfo(T)) {
        .float => Rng.fillOpenFrom(source, T, dest),
        .vector => Rng.fillVectorOpenFrom(source, T, dest),
        else => unreachable,
    }
}

fn fillOpenClosed01From(source: anytype, comptime T: type, dest: []T) void {
    requireFloatOrFloatVector(T);
    switch (@typeInfo(T)) {
        .float => Rng.fillOpenClosedFrom(source, T, dest),
        .vector => Rng.fillVectorOpenClosedFrom(source, T, dest),
        else => unreachable,
    }
}

fn expInPlace(comptime T: type, dest: []T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => expInPlaceVector(T, @Vector(8, f32), dest),
        f64 => expInPlaceScalar(T, dest),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn expInPlaceScalar(comptime T: type, dest: []T) void {
    for (dest) |*item| item.* = @exp(item.*);
}

fn expInPlaceVector(comptime T: type, comptime VectorType: type, dest: []T) void {
    const len = @typeInfo(VectorType).vector.len;
    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var vec: VectorType = undefined;
        inline for (0..len) |lane| vec[lane] = dest[i + lane];
        vec = @exp(vec);
        inline for (0..len) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = @exp(dest[i]);
}

fn logNormalApproxF32ParametersValid(mean: f32, stddev: f32) bool {
    return std.math.isFinite(mean) and
        std.math.isFinite(stddev) and
        stddev >= 0 and
        @abs(mean) <= log_normal_approx_f32_max_abs_mean and
        stddev <= log_normal_approx_f32_max_stddev;
}

fn expm1ApproxPositiveF32(value: f32) f32 {
    return std.math.expm1(value) + 1.0;
}

fn expm1ApproxPositiveInPlaceF32(dest: []f32) void {
    for (dest) |*item| item.* = expm1ApproxPositiveF32(item.*);
}

fn floatDistancePositiveF32(a: f32, b: f32) u32 {
    std.debug.assert(a >= 0 and b >= 0);
    const ai: u32 = @bitCast(a);
    const bi: u32 = @bitCast(b);
    return if (ai >= bi) ai - bi else bi - ai;
}

fn expVectorSliceInPlace(comptime VectorType: type, dest: []VectorType) void {
    const info = vectorInfo(VectorType);
    requireFloat(info.child);
    for (dest) |*item| item.* = @exp(item.*);
}

fn absVectorSliceInPlace(comptime VectorType: type, dest: []VectorType) void {
    const info = vectorInfo(VectorType);
    requireFloat(info.child);
    for (dest) |*item| item.* = @abs(item.*);
}

fn absInPlace(comptime T: type, dest: []T) void {
    switch (T) {
        f32 => absInPlaceVector(T, @Vector(8, f32), dest),
        f64 => absInPlaceVector(T, @Vector(4, f64), dest),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn absInPlaceVector(comptime T: type, comptime VectorType: type, dest: []T) void {
    const len = @typeInfo(VectorType).vector.len;
    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var vec: VectorType = undefined;
        inline for (0..len) |lane| vec[lane] = dest[i + lane];
        vec = @abs(vec);
        inline for (0..len) |lane| dest[i + lane] = vec[lane];
    }
    while (i < dest.len) : (i += 1) dest[i] = @abs(dest[i]);
}

fn inverseGaussianFromNormals(source: anytype, comptime T: type, dest: []T, mean: T, shape: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => inverseGaussianFromNormalsVector(source, T, @Vector(8, f32), dest, mean, shape),
        f64 => inverseGaussianFromNormalsVector(source, T, @Vector(4, f64), dest, mean, shape),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn inverseGaussianFromNormalsVector(source: anytype, comptime T: type, comptime VectorType: type, dest: []T, mean: T, shape: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const mean_vec: VectorType = @splat(mean);
    const shape_vec: VectorType = @splat(shape);
    const mean_over_2shape: VectorType = @splat(mean / (2 * shape));
    const mean_squared: VectorType = @splat(mean * mean);
    const four_vec: VectorType = @splat(4.0);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var normal_vec: VectorType = undefined;
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| {
            normal_vec[lane] = dest[i + lane];
            uniform_vec[lane] = Rng.floatFrom(source, T);
        }

        const y = mean_vec * normal_vec * normal_vec;
        const x = mean_vec + mean_over_2shape * (y - @sqrt(four_vec * shape_vec * y + y * y));
        const threshold = mean_vec / (mean_vec + x);
        const out = @select(T, uniform_vec <= threshold, x, mean_squared / x);

        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        dest[i] = inverseGaussianFromNormal(source, T, dest[i], mean, shape);
    }
}

fn inverseGaussianFromNormal(source: anytype, comptime T: type, normal_sample: T, mean: T, shape: T) T {
    const y = mean * normal_sample * normal_sample;
    const mean_over_2shape = mean / (2 * shape);
    const x = mean + mean_over_2shape * (y - @sqrt(4 * shape * y + y * y));
    if (Rng.floatFrom(source, T) <= mean / (mean + x)) return x;
    return mean * mean / x;
}

fn cauchyFromOpenUniforms(comptime T: type, dest: []T, median: T, scale: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => cauchyFromOpenUniformsVector(T, @Vector(8, f32), dest, median, scale),
        f64 => cauchyFromOpenUniformsVector(T, @Vector(4, f64), dest, median, scale),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn cauchyFromOpenUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, median: T, scale: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const pi_vec: VectorType = @splat(@as(T, @floatCast(std.math.pi)));
    const half_vec: VectorType = @splat(0.5);
    const median_vec: VectorType = @splat(median);
    const scale_vec: VectorType = @splat(scale);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const out = median_vec + scale_vec * @tan(pi_vec * (uniform_vec - half_vec));
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        dest[i] = median + scale * @tan(@as(T, @floatCast(std.math.pi)) * (dest[i] - 0.5));
    }
}

fn triangularFromUniforms(comptime T: type, dest: []T, min: T, mode: T, max: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => triangularFromUniformsVector(T, @Vector(8, f32), dest, min, mode, max),
        f64 => triangularFromUniformsVector(T, @Vector(4, f64), dest, min, mode, max),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn triangularFromUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, min: T, mode: T, max: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const width = max - min;
    const left_width = mode - min;
    const right_width = max - mode;
    const c_vec: VectorType = @splat(left_width / width);
    const one_vec: VectorType = @splat(1.0);
    const min_vec: VectorType = @splat(min);
    const max_vec: VectorType = @splat(max);
    const left_scale_vec: VectorType = @splat(width * left_width);
    const right_scale_vec: VectorType = @splat(width * right_width);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const left = min_vec + @sqrt(uniform_vec * left_scale_vec);
        const right = max_vec - @sqrt((one_vec - uniform_vec) * right_scale_vec);
        const out = @select(T, uniform_vec < c_vec, left, right);
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        const u = dest[i];
        dest[i] = if (u < left_width / width)
            min + @sqrt(u * width * left_width)
        else
            max - @sqrt((1 - u) * width * right_width);
    }
}

fn rayleighFromOpenUniforms(comptime T: type, dest: []T, scale: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => rayleighFromOpenUniformsVector(T, @Vector(8, f32), dest, scale),
        f64 => rayleighFromOpenUniformsVector(T, @Vector(4, f64), dest, scale),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn rayleighFromOpenUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, scale: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const scale_vec: VectorType = @splat(scale);
    const neg_two_vec: VectorType = @splat(-2.0);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const out = scale_vec * @sqrt(neg_two_vec * @log(uniform_vec));
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        dest[i] = scale * @sqrt(-2 * @log(dest[i]));
    }
}

fn logisticFromOpenUniforms(comptime T: type, dest: []T, location: T, scale: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => logisticFromOpenUniformsVector(T, @Vector(8, f32), dest, location, scale),
        f64 => logisticFromOpenUniformsVector(T, @Vector(4, f64), dest, location, scale),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn logisticFromOpenUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, location: T, scale: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const location_vec: VectorType = @splat(location);
    const scale_vec: VectorType = @splat(scale);
    const one_vec: VectorType = @splat(1.0);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const out = location_vec + scale_vec * @log(uniform_vec / (one_vec - uniform_vec));
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        const u = dest[i];
        dest[i] = location + scale * @log(u / (1 - u));
    }
}

fn laplaceFromOpenUniforms(comptime T: type, dest: []T, location: T, scale: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => laplaceFromOpenUniformsVector(T, @Vector(8, f32), dest, location, scale),
        f64 => laplaceFromOpenUniformsVector(T, @Vector(4, f64), dest, location, scale),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn laplaceFromOpenUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, location: T, scale: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const location_vec: VectorType = @splat(location);
    const scale_vec: VectorType = @splat(scale);
    const half_vec: VectorType = @splat(0.5);
    const one_vec: VectorType = @splat(1.0);
    const two_vec: VectorType = @splat(2.0);
    const positive: VectorType = @splat(1.0);
    const negative: VectorType = @splat(-1.0);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const centered = uniform_vec - half_vec;
        const sign = @select(T, centered < @as(VectorType, @splat(0.0)), negative, positive);
        const out = location_vec - scale_vec * sign * @log(one_vec - two_vec * @abs(centered));
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        const centered = dest[i] - 0.5;
        const sign: T = if (centered < 0) -1 else 1;
        dest[i] = location - scale * sign * @log(1 - 2 * @abs(centered));
    }
}

fn logLogisticFromOpenUniforms(comptime T: type, dest: []T, scale: T, inverse_shape: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => logLogisticFromOpenUniformsVector(T, @Vector(8, f32), dest, scale, inverse_shape),
        f64 => logLogisticFromOpenUniformsVector(T, @Vector(4, f64), dest, scale, inverse_shape),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn logLogisticFromOpenUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, scale: T, inverse_shape: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const scale_vec: VectorType = @splat(scale);
    const inverse_shape_vec: VectorType = @splat(inverse_shape);
    const one_vec: VectorType = @splat(1.0);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const out = scale_vec * @exp(@log(uniform_vec / (one_vec - uniform_vec)) * inverse_shape_vec);
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        const u = dest[i];
        dest[i] = scale * @exp(@log(u / (1 - u)) * inverse_shape);
    }
}

fn logLogisticShapeOneFromOpenUniforms(comptime T: type, dest: []T, scale: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => logLogisticShapeOneFromOpenUniformsVector(T, @Vector(8, f32), dest, scale),
        f64 => logLogisticShapeOneFromOpenUniformsVector(T, @Vector(4, f64), dest, scale),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn logLogisticShapeOneFromOpenUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, scale: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const scale_vec: VectorType = @splat(scale);
    const one_vec: VectorType = @splat(1.0);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const out = scale_vec * uniform_vec / (one_vec - uniform_vec);
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        const u = dest[i];
        dest[i] = scale * u / (1 - u);
    }
}

fn powerFunctionFromOpenUniforms(comptime T: type, dest: []T, min: T, width: T, inverse_shape: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => powerFunctionFromOpenUniformsVector(T, @Vector(8, f32), dest, min, width, inverse_shape),
        f64 => powerFunctionFromOpenUniformsVector(T, @Vector(4, f64), dest, min, width, inverse_shape),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn powerFunctionFromOpenUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, min: T, width: T, inverse_shape: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const min_vec: VectorType = @splat(min);
    const width_vec: VectorType = @splat(width);
    const inverse_shape_vec: VectorType = @splat(inverse_shape);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const out = min_vec + width_vec * @exp(@log(uniform_vec) * inverse_shape_vec);
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        dest[i] = min + width * @exp(@log(dest[i]) * inverse_shape);
    }
}

fn gumbelFromOpenClosedUniforms(comptime T: type, dest: []T, location: T, scale: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => gumbelFromOpenClosedUniformsVector(T, @Vector(8, f32), dest, location, scale),
        f64 => gumbelFromOpenClosedUniformsVector(T, @Vector(4, f64), dest, location, scale),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn gumbelFromOpenClosedUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, location: T, scale: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const location_vec: VectorType = @splat(location);
    const scale_vec: VectorType = @splat(scale);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const out = location_vec - scale_vec * @log(-@log(uniform_vec));
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        dest[i] = location - scale * @log(-@log(dest[i]));
    }
}

fn frechetFromOpenClosedUniforms(comptime T: type, dest: []T, location: T, scale: T, negative_inverse_shape: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => frechetFromOpenClosedUniformsVector(T, @Vector(8, f32), dest, location, scale, negative_inverse_shape),
        f64 => frechetFromOpenClosedUniformsVector(T, @Vector(4, f64), dest, location, scale, negative_inverse_shape),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn frechetFromOpenClosedUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, location: T, scale: T, negative_inverse_shape: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const location_vec: VectorType = @splat(location);
    const scale_vec: VectorType = @splat(scale);
    const negative_inverse_shape_vec: VectorType = @splat(negative_inverse_shape);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const out = location_vec + scale_vec * @exp(@log(-@log(uniform_vec)) * negative_inverse_shape_vec);
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        dest[i] = location + scale * @exp(@log(-@log(dest[i])) * negative_inverse_shape);
    }
}

fn frechetShapeOneFromOpenClosedUniforms(comptime T: type, dest: []T, location: T, scale: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => frechetShapeOneFromOpenClosedUniformsVector(T, @Vector(8, f32), dest, location, scale),
        f64 => frechetShapeOneFromOpenClosedUniformsVector(T, @Vector(4, f64), dest, location, scale),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn frechetShapeOneFromOpenClosedUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, location: T, scale: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const location_vec: VectorType = @splat(location);
    const negative_scale_vec: VectorType = @splat(-scale);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const out = location_vec + negative_scale_vec / @log(uniform_vec);
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) dest[i] = location - scale / @log(dest[i]);
}

fn arcsineFromOpenUniforms(comptime T: type, dest: []T, min: T, width: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => arcsineFromOpenUniformsVector(T, @Vector(8, f32), dest, min, width),
        f64 => arcsineFromOpenUniformsVector(T, @Vector(4, f64), dest, min, width),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn arcsineFromOpenUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, min: T, width: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const min_vec: VectorType = @splat(min);
    const width_vec: VectorType = @splat(width);
    const angle_scale_vec: VectorType = @splat(@as(T, @floatCast(std.math.pi)) / 2);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const s = @sin(angle_scale_vec * uniform_vec);
        const out = min_vec + width_vec * s * s;
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        const s = @sin(@as(T, @floatCast(std.math.pi)) * dest[i] / 2);
        dest[i] = min + width * s * s;
    }
}

fn paretoFromOpenUniforms(comptime T: type, dest: []T, scale: T, inverse_shape: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => paretoFromOpenUniformsVector(T, @Vector(8, f32), dest, scale, inverse_shape),
        f64 => paretoFromOpenUniformsVector(T, @Vector(4, f64), dest, scale, inverse_shape),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn paretoFromOpenUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, scale: T, inverse_shape: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const scale_vec: VectorType = @splat(scale);
    const neg_inverse_shape_vec: VectorType = @splat(-inverse_shape);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const out = scale_vec * @exp(@log(uniform_vec) * neg_inverse_shape_vec);
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        dest[i] = scale * @exp(-@log(dest[i]) * inverse_shape);
    }
}

fn weibullFromOpenUniforms(comptime T: type, dest: []T, scale: T, inverse_shape: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => weibullFromOpenUniformsVector(T, @Vector(8, f32), dest, scale, inverse_shape),
        f64 => weibullFromOpenUniformsVector(T, @Vector(4, f64), dest, scale, inverse_shape),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn weibullFromOpenUniformsVector(comptime T: type, comptime VectorType: type, dest: []T, scale: T, inverse_shape: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const scale_vec: VectorType = @splat(scale);
    const inverse_shape_vec: VectorType = @splat(inverse_shape);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var uniform_vec: VectorType = undefined;
        inline for (0..len) |lane| uniform_vec[lane] = dest[i + lane];
        const out = scale_vec * @exp(@log(-@log(uniform_vec)) * inverse_shape_vec);
        inline for (0..len) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) {
        dest[i] = scale * @exp(@log(-@log(dest[i])) * inverse_shape);
    }
}

test "basic distributions stay in expected ranges" {
    const alea = @import("root.zig");
    var engine = alea.Xoshiro256.init(1234);
    const rng = Rng.init(&engine);

    try std.testing.expect(uniform(rng, u32, 5, 9) >= 5);
    try std.testing.expect(uniform(rng, f64, -1, 1) < 1);
    try std.testing.expect(try uniformChecked(rng, u32, 5, 9) >= 5);
    try std.testing.expect(try uniformCheckedFrom(&engine, f64, -1, 1) < 1);
    try std.testing.expect(try uniformInclusiveChecked(rng, u32, 5, 9) <= 9);
    try std.testing.expect(try uniformInclusiveCheckedFrom(&engine, f64, -1, 1) <= 1);
    try std.testing.expectError(error.EmptyRange, uniformCheckedFrom(&engine, u32, 9, 5));
    try std.testing.expectError(error.EmptyRange, uniformInclusiveCheckedFrom(&engine, f64, std.math.inf(f64), 1));
    var uniform_int_buf: [8]u32 = undefined;
    fillUniform(rng, u32, &uniform_int_buf, 5, 9);
    for (uniform_int_buf) |value| try std.testing.expect(value >= 5 and value < 9);
    fillUniformFrom(&engine, u32, &uniform_int_buf, 5, 9);
    for (uniform_int_buf) |value| try std.testing.expect(value >= 5 and value < 9);
    try fillUniformChecked(rng, u32, &uniform_int_buf, 5, 9);
    for (uniform_int_buf) |value| try std.testing.expect(value >= 5 and value < 9);
    try fillUniformCheckedFrom(&engine, u32, &uniform_int_buf, 5, 9);
    for (uniform_int_buf) |value| try std.testing.expect(value >= 5 and value < 9);
    try std.testing.expectError(error.EmptyRange, fillUniformCheckedFrom(&engine, u32, &uniform_int_buf, 9, 5));
    var uniform_float_buf: [8]f64 = undefined;
    fillUniform(rng, f64, &uniform_float_buf, -1, 1);
    for (uniform_float_buf) |value| try std.testing.expect(value >= -1 and value < 1);
    try fillUniformCheckedFrom(&engine, f64, &uniform_float_buf, -1, 1);
    for (uniform_float_buf) |value| try std.testing.expect(value >= -1 and value < 1);
    var inclusive_int_buf: [8]u32 = undefined;
    fillUniformInclusive(rng, u32, &inclusive_int_buf, 5, 9);
    for (inclusive_int_buf) |value| try std.testing.expect(value >= 5 and value <= 9);
    fillUniformInclusiveFrom(&engine, u32, &inclusive_int_buf, 5, 9);
    for (inclusive_int_buf) |value| try std.testing.expect(value >= 5 and value <= 9);
    try fillUniformInclusiveChecked(rng, u32, &inclusive_int_buf, 5, 9);
    for (inclusive_int_buf) |value| try std.testing.expect(value >= 5 and value <= 9);
    try fillUniformInclusiveCheckedFrom(&engine, u32, &inclusive_int_buf, 5, 9);
    for (inclusive_int_buf) |value| try std.testing.expect(value >= 5 and value <= 9);
    try std.testing.expectError(error.EmptyRange, fillUniformInclusiveCheckedFrom(&engine, u32, &inclusive_int_buf, 9, 5));
    const counting_source = struct {
        count: usize = 0,

        pub fn next(self: *@This()) u64 {
            self.count += 1;
            return 0;
        }
    };
    var unchecked_counter = counting_source{};
    var checked_counter = counting_source{};
    var unchecked_inclusive: [4]u32 = undefined;
    var checked_inclusive: [4]u32 = undefined;
    fillUniformInclusiveFrom(&unchecked_counter, u32, &unchecked_inclusive, 5, 5);
    try fillUniformInclusiveCheckedFrom(&checked_counter, u32, &checked_inclusive, 5, 5);
    try std.testing.expectEqual(unchecked_counter.count, checked_counter.count);
    var inclusive_float_buf: [8]f64 = undefined;
    fillUniformInclusive(rng, f64, &inclusive_float_buf, -1, 1);
    for (inclusive_float_buf) |value| try std.testing.expect(value >= -1 and value <= 1);
    try fillUniformInclusiveCheckedFrom(&engine, f64, &inclusive_float_buf, -1, 1);
    for (inclusive_float_buf) |value| try std.testing.expect(value >= -1 and value <= 1);
    try std.testing.expectError(error.EmptyRange, fillUniformInclusiveCheckedFrom(&engine, f64, &inclusive_float_buf, std.math.inf(f64), 1));
    try std.testing.expect((try Bernoulli.initRatio(1, 1)).sample(rng));
    try std.testing.expect(!(try Bernoulli.init(0)).sample(rng));
    const fair_bernoulli = try Bernoulli.init(0.5);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), fair_bernoulli.probability(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), fair_bernoulli.probabilityValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), fair_bernoulli.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), fair_bernoulli.varianceValue(), 1e-12);
    try std.testing.expect(fair_bernoulli.modeValue() == null);
    try std.testing.expectEqual(false, (try Bernoulli.init(0.25)).modeValue().?);
    try std.testing.expectEqual(true, (try Bernoulli.init(0.75)).modeValue().?);
    try std.testing.expectEqual(false, fair_bernoulli.minValue());
    try std.testing.expectEqual(true, fair_bernoulli.maxValue());
    try std.testing.expect((try Bernoulli.init(1.0 - std.math.floatEps(f64) / 2.0)).sample(rng));
    try std.testing.expect(try bernoulliChecked(rng, 1.0));
    var direct_bernoulli_engine = alea.ScalarPrng.init(64);
    try std.testing.expect(bernoulliFrom(&direct_bernoulli_engine, 1.0));
    try std.testing.expect(try bernoulliCheckedFrom(&direct_bernoulli_engine, 1.0));
    try std.testing.expect(std.math.isFinite(normalFrom(&direct_bernoulli_engine, f64, 0, 1)));
    try std.testing.expect(std.math.isFinite(try normalCheckedFrom(&direct_bernoulli_engine, f64, 0, 1)));
    var top_normal_buf: [8]f64 = undefined;
    fillNormal(rng, f64, &top_normal_buf, 0, 1);
    for (top_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));
    fillNormalFrom(&direct_bernoulli_engine, f64, &top_normal_buf, 0, 1);
    for (top_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillNormalChecked(rng, f64, &top_normal_buf, 0, 1);
    for (top_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillNormalCheckedFrom(&direct_bernoulli_engine, f64, &top_normal_buf, 0, 1);
    for (top_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try std.testing.expectError(error.InvalidParameter, fillNormalCheckedFrom(&direct_bernoulli_engine, f64, &top_normal_buf, 0, -1));
    try std.testing.expect(exponentialFrom(&direct_bernoulli_engine, f64, 2) >= 0);
    try std.testing.expect(try exponentialCheckedFrom(&direct_bernoulli_engine, f64, 2) >= 0);
    var top_exponential_buf: [8]f64 = undefined;
    fillExponential(rng, f64, &top_exponential_buf, 2);
    for (top_exponential_buf) |value| try std.testing.expect(value >= 0);
    fillExponentialFrom(&direct_bernoulli_engine, f64, &top_exponential_buf, 2);
    for (top_exponential_buf) |value| try std.testing.expect(value >= 0);
    try fillExponentialChecked(rng, f64, &top_exponential_buf, 2);
    for (top_exponential_buf) |value| try std.testing.expect(value >= 0);
    try fillExponentialCheckedFrom(&direct_bernoulli_engine, f64, &top_exponential_buf, 2);
    for (top_exponential_buf) |value| try std.testing.expect(value >= 0);
    try std.testing.expectError(error.InvalidParameter, fillExponentialCheckedFrom(&direct_bernoulli_engine, f64, &top_exponential_buf, 0));
    try std.testing.expect(poissonFrom(&direct_bernoulli_engine, 4) < 32);
    try std.testing.expect(try poissonCheckedFrom(&direct_bernoulli_engine, 4) < 32);
    try std.testing.expectError(error.InvalidParameter, poissonCheckedFrom(&direct_bernoulli_engine, std.math.inf(f64)));
    try std.testing.expect((try Bernoulli.initRatio(1, 1)).sampleFrom(&direct_bernoulli_engine));
    var bernoulli_buf: [8]bool = undefined;
    fillBernoulli(rng, &bernoulli_buf, 1);
    for (bernoulli_buf) |value| try std.testing.expect(value);
    fillBernoulliFrom(&direct_bernoulli_engine, &bernoulli_buf, 0);
    for (bernoulli_buf) |value| try std.testing.expect(!value);
    try fillBernoulliChecked(rng, &bernoulli_buf, 1);
    for (bernoulli_buf) |value| try std.testing.expect(value);
    try fillBernoulliCheckedFrom(&direct_bernoulli_engine, &bernoulli_buf, 0);
    for (bernoulli_buf) |value| try std.testing.expect(!value);
    try std.testing.expectError(error.InvalidProbability, fillBernoulliCheckedFrom(&direct_bernoulli_engine, &bernoulli_buf, -0.1));
    const bernoulli_sampler = try Bernoulli.init(0.5);
    bernoulli_sampler.fillFrom(&direct_bernoulli_engine, &bernoulli_buf);
    try std.testing.expectError(error.InvalidProbability, bernoulliCheckedFrom(&direct_bernoulli_engine, 1.1));
    try std.testing.expect((try Binomial.init(10, 1)).sample(rng) == 10);
    try std.testing.expectEqual(@as(u64, 10), try binomialChecked(rng, 10, 1));
    try std.testing.expectEqual(@as(u64, 10), try binomialCheckedFrom(&direct_bernoulli_engine, 10, 1));
    try std.testing.expectError(error.InvalidProbability, binomialCheckedFrom(&direct_bernoulli_engine, 10, 1.1));
    var binomial_buf: [8]u64 = undefined;
    fillBinomial(rng, &binomial_buf, 10, 1);
    for (binomial_buf) |value| try std.testing.expectEqual(@as(u64, 10), value);
    try fillBinomialChecked(rng, &binomial_buf, 10, 1);
    for (binomial_buf) |value| try std.testing.expectEqual(@as(u64, 10), value);
    try fillBinomialCheckedFrom(&direct_bernoulli_engine, &binomial_buf, 10, 1);
    for (binomial_buf) |value| try std.testing.expectEqual(@as(u64, 10), value);
    try std.testing.expectError(error.InvalidProbability, fillBinomialCheckedFrom(&direct_bernoulli_engine, &binomial_buf, 10, 1.1));
    const binomial_sampler = try Binomial.init(10, 0.5);
    try std.testing.expectEqual(@as(u64, 10), binomial_sampler.trialsValue());
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), binomial_sampler.probabilityValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5), binomial_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2.5), binomial_sampler.varianceValue(), 1e-12);
    try std.testing.expectEqual(@as(u64, 0), binomial_sampler.minValue());
    try std.testing.expectEqual(@as(u64, 10), binomial_sampler.maxValue());
    binomial_sampler.fillFrom(&direct_bernoulli_engine, &binomial_buf);
    for (binomial_buf) |value| try std.testing.expect(value <= 10);
    try std.testing.expect(exponential(rng, f64, 2) >= 0);
    try std.testing.expect(poisson(rng, 4) < 32);
    try std.testing.expect(beta(rng, f64, 2, 5) >= 0);

    const die = try Uniform(u8).initInclusive(1, 6);
    const roll = die.sample(rng);
    try std.testing.expect(roll >= 1 and roll <= 6);

    const float_edge = struct {
        value: u64,

        pub fn next(self: *@This()) u64 {
            return self.value;
        }

        pub fn fill(self: *@This(), buf: []u8) void {
            var i: usize = 0;
            while (i < buf.len) : (i += 1) {
                if ((i & 7) == 0) self.value +%= 0x9e3779b97f4a7c15;
                buf[i] = @truncate(self.value >> @intCast((i & 7) * 8));
            }
        }
    };
    var min_float_engine = float_edge{ .value = 0 };
    try std.testing.expectEqual(@as(f64, -1), uniformInclusiveFrom(&min_float_engine, f64, -1, 3));
    var max_float_engine = float_edge{ .value = std.math.maxInt(u64) };
    try std.testing.expectEqual(@as(f64, 3), uniformInclusiveFrom(&max_float_engine, f64, -1, 3));
}

test "alias table init allocation failure cleans up" {
    for (0..5) |fail_index| {
        var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = fail_index });
        try std.testing.expectError(error.OutOfMemory, AliasTable(u32).init(failing.allocator(), &.{ 1, 2, 3 }));
        try std.testing.expect(failing.has_induced_failure);
    }
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
    try std.testing.expect(table.sampleFrom(&engine) < 4);
    var alias_buf: [8]usize = undefined;
    table.fill(rng, &alias_buf);
    for (alias_buf) |index| {
        try std.testing.expect(index < 4);
        try std.testing.expect(index != 1);
    }
    table.fillFrom(&engine, &alias_buf);
    for (alias_buf) |index| {
        try std.testing.expect(index < 4);
        try std.testing.expect(index != 1);
    }

    try table.update(&.{ 0, 10, 0, 0 });
    i = 0;
    while (i < 16) : (i += 1) {
        try std.testing.expectEqual(@as(usize, 1), table.sampleFrom(&engine));
    }

    try std.testing.expectError(error.InvalidParameter, table.update(&.{ 1, 2 }));
    try std.testing.expectError(error.InvalidWeight, table.update(&.{ 0, 0, 0, 0 }));
    try std.testing.expectEqual(@as(usize, 1), table.sampleFrom(&engine));

    try std.testing.expectError(error.InvalidWeight, AliasTable(u32).init(std.testing.allocator, &.{}));
    try std.testing.expectError(error.InvalidWeight, AliasTable(u32).init(std.testing.allocator, &.{ 0, 0 }));
}

test "alias table exposes totals and reconstructs weights" {
    var table = try AliasTable(u32).init(std.testing.allocator, &.{ 1, 0, 5, 3 });
    defer table.deinit();

    try std.testing.expectEqual(@as(usize, 4), table.len());
    try std.testing.expect(!table.isEmpty());
    try std.testing.expectApproxEqAbs(@as(f64, 9), table.totalWeight(), 1e-12);

    var stack_weights: [4]f64 = undefined;
    try table.weightsInto(&stack_weights);
    try std.testing.expectApproxEqAbs(@as(f64, 1), stack_weights[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), stack_weights[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5), stack_weights[2], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), stack_weights[3], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), try table.weightAt(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), try table.weightAt(1), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5), try table.weightAt(2), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), try table.weightAt(3), 1e-12);
    try std.testing.expectError(error.InvalidParameter, table.weightAt(4));
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 9.0), try table.probabilityAt(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), try table.probabilityAt(1), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5.0 / 9.0), try table.probabilityAt(2), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 3.0), try table.probabilityAt(3), 1e-12);
    try std.testing.expectError(error.InvalidParameter, table.probabilityAt(4));
    var stack_probabilities: [4]f64 = undefined;
    try table.probabilitiesInto(&stack_probabilities);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 9.0), stack_probabilities[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), stack_probabilities[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5.0 / 9.0), stack_probabilities[2], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 3.0), stack_probabilities[3], 1e-12);

    var wrong_len: [3]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, table.weightsInto(&wrong_len));
    try std.testing.expectError(error.InvalidLength, table.probabilitiesInto(&wrong_len));

    const owned_weights = try table.weights(std.testing.allocator);
    defer std.testing.allocator.free(owned_weights);
    try std.testing.expectEqualSlices(f64, &stack_weights, owned_weights);
    const owned_probabilities = try table.probabilities(std.testing.allocator);
    defer std.testing.allocator.free(owned_probabilities);
    try std.testing.expectEqualSlices(f64, &stack_probabilities, owned_probabilities);

    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, table.weights(failing.allocator()));
    try std.testing.expect(failing.has_induced_failure);

    try table.update(&.{ 0, 10, 0, 0 });
    try std.testing.expectEqual(@as(usize, 4), table.len());
    try std.testing.expectApproxEqAbs(@as(f64, 10), table.totalWeight(), 1e-12);
    try table.weightsInto(&stack_weights);
    try std.testing.expectApproxEqAbs(@as(f64, 0), stack_weights[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 10), stack_weights[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), stack_weights[2], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), stack_weights[3], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 10), try table.weightAt(1), 1e-12);
}

test "zero-length alias table fills do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_a11b);
    var control = alea.ScalarPrng.init(0x5150_a11b);
    const rng = Rng.init(&engine);

    var table = try AliasTable(u32).init(std.testing.allocator, &.{ 1, 0, 5, 3 });
    defer table.deinit();

    var empty: [0]usize = .{};
    table.fill(rng, &empty);
    try std.testing.expectEqual(control.next(), engine.next());
    table.fillFrom(&engine, &empty);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "alias table update allocation failure preserves table" {
    const alea = @import("root.zig");

    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{});
    var table = try AliasTable(u32).init(failing.allocator(), &.{ 0, 0, 1 });
    defer table.deinit();

    var engine = alea.ScalarPrng.init(0x5150_a11a);
    var control = alea.ScalarPrng.init(0x5150_a11a);
    failing.fail_index = failing.alloc_index;
    try std.testing.expectError(error.OutOfMemory, table.update(&.{ 1, 2, 3 }));
    try std.testing.expect(failing.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var out: [8]usize = undefined;
    table.fillFrom(&engine, &out);
    for (out) |index| try std.testing.expectEqual(@as(usize, 2), index);
}

test "weighted tree init failures clean up" {
    var generic_alloc_fail = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, WeightedTree(u32).init(generic_alloc_fail.allocator(), &.{ 1, 2, 3 }));
    try std.testing.expect(generic_alloc_fail.has_induced_failure);

    var generic_invalid = std.testing.FailingAllocator.init(std.testing.allocator, .{});
    try std.testing.expectError(error.InvalidWeight, WeightedTree(f64).init(generic_invalid.allocator(), &.{
        std.math.floatMax(f64),
        std.math.floatMax(f64),
    }));
    try std.testing.expect(!generic_invalid.has_induced_failure);

    var int_alloc_fail = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, WeightedIntTree(u32).init(int_alloc_fail.allocator(), &.{ 1, 2, 3 }));
    try std.testing.expect(int_alloc_fail.has_induced_failure);

    var int_invalid = std.testing.FailingAllocator.init(std.testing.allocator, .{});
    try std.testing.expectError(error.InvalidWeight, WeightedIntTree(u64).init(int_invalid.allocator(), &.{
        std.math.maxInt(u64),
        1,
    }));
    try std.testing.expect(!int_invalid.has_induced_failure);
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
    try std.testing.expectApproxEqAbs(@as(f64, 1), try tree.weightAt(1), 1e-12);
    try std.testing.expectError(error.InvalidParameter, tree.weightAt(3));
    try std.testing.expectApproxEqAbs(@as(f64, 0.9), try tree.probabilityAt(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.1), try tree.probabilityAt(1), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), try tree.probabilityAt(2), 1e-12);
    try std.testing.expectError(error.InvalidParameter, tree.probabilityAt(3));
    var probabilities_buf: [3]f64 = undefined;
    try tree.probabilitiesInto(&probabilities_buf);
    try std.testing.expectApproxEqAbs(@as(f64, 0.9), probabilities_buf[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.1), probabilities_buf[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), probabilities_buf[2], 1e-12);
    var weights_buf: [3]f64 = undefined;
    try tree.weightsInto(&weights_buf);
    try std.testing.expectApproxEqAbs(@as(f64, 9), weights_buf[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), weights_buf[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), weights_buf[2], 1e-12);
    var wrong_weights_len: [2]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, tree.weightsInto(&wrong_weights_len));
    try std.testing.expectError(error.InvalidLength, tree.probabilitiesInto(&wrong_weights_len));
    const owned_weights = try tree.weights(std.testing.allocator);
    defer std.testing.allocator.free(owned_weights);
    try std.testing.expectEqualSlices(f64, &weights_buf, owned_weights);
    const owned_probabilities = try tree.probabilities(std.testing.allocator);
    defer std.testing.allocator.free(owned_probabilities);
    try std.testing.expectEqualSlices(f64, &probabilities_buf, owned_probabilities);
    var weights_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, tree.weights(weights_alloc.allocator()));
    try std.testing.expect(weights_alloc.has_induced_failure);

    try tree.update(0, 0);
    try tree.update(1, 0);
    try std.testing.expect(!tree.isValid());
    try std.testing.expectError(error.InvalidWeight, tree.sampleChecked(rng));
    try std.testing.expectError(error.InvalidWeight, tree.probabilityAt(0));
    try std.testing.expectError(error.InvalidWeight, tree.probabilitiesInto(&probabilities_buf));

    try tree.push(7);
    var i: usize = 0;
    while (i < 16) : (i += 1) {
        try std.testing.expectEqual(@as(usize, 3), tree.sampleFrom(&engine));
    }
    var tree_buf: [8]usize = undefined;
    try tree.fillCheckedFrom(&engine, &tree_buf);
    for (tree_buf) |index| try std.testing.expectEqual(@as(usize, 3), index);

    try tree.update(2, 5);
    var saw_two = false;
    i = 0;
    while (i < 64) : (i += 1) {
        const index = try tree.sampleCheckedFrom(&engine);
        try std.testing.expect(index == 2 or index == 3);
        saw_two = saw_two or index == 2;
    }
    try std.testing.expect(saw_two);

    try std.testing.expectApproxEqAbs(@as(f64, 7), tree.pop().?, 1e-12);
    try std.testing.expectEqual(@as(usize, 3), tree.len());
    try std.testing.expectEqual(@as(usize, 2), tree.sample(rng));
    try tree.weightsInto(&weights_buf);
    try std.testing.expectApproxEqAbs(@as(f64, 0), weights_buf[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), weights_buf[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5), weights_buf[2], 1e-12);
    try std.testing.expectError(error.InvalidParameter, tree.update(9, 1));

    var empty_tree = try WeightedTree(u32).init(std.testing.allocator, &.{});
    defer empty_tree.deinit();
    try std.testing.expect(empty_tree.isEmpty());
    try std.testing.expect(!empty_tree.isValid());
    try std.testing.expectEqual(@as(?f64, null), empty_tree.pop());
    try std.testing.expectError(error.InvalidParameter, empty_tree.update(0, 1));
    try std.testing.expect(empty_tree.isEmpty());
    try empty_tree.push(6);
    try std.testing.expect(!empty_tree.isEmpty());
    try std.testing.expect(empty_tree.isValid());
    try std.testing.expectApproxEqAbs(@as(f64, 6), empty_tree.totalWeight(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 6), try empty_tree.get(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 6), empty_tree.pop().?, 1e-12);
    try std.testing.expect(empty_tree.isEmpty());
    try std.testing.expect(!empty_tree.isValid());
    try std.testing.expectError(error.InvalidParameter, empty_tree.get(0));
    var empty_probabilities: [0]f64 = .{};
    try empty_tree.probabilitiesInto(&empty_probabilities);

    var single_tree = try WeightedTree(u32).init(std.testing.allocator, &.{4});
    defer single_tree.deinit();
    try std.testing.expectApproxEqAbs(@as(f64, 4), single_tree.pop().?, 1e-12);
    try std.testing.expect(single_tree.isEmpty());
    try std.testing.expect(!single_tree.isValid());
    try std.testing.expectEqual(@as(?f64, null), single_tree.pop());

    var float_tree = try WeightedTree(f64).init(std.testing.allocator, &.{1.0});
    defer float_tree.deinit();
    try std.testing.expectError(error.InvalidWeight, float_tree.push(std.math.nan(f64)));
    try std.testing.expectApproxEqAbs(@as(f64, 1), float_tree.totalWeight(), 1e-12);

    try std.testing.expectError(error.InvalidWeight, WeightedTree(f64).init(std.testing.allocator, &.{
        std.math.floatMax(f64),
        std.math.floatMax(f64),
    }));

    var invalid_total_tree = try WeightedTree(f64).init(std.testing.allocator, &.{std.math.floatMax(f64)});
    defer invalid_total_tree.deinit();
    try std.testing.expectError(error.InvalidWeight, invalid_total_tree.push(std.math.floatMax(f64)));
    try std.testing.expectApproxEqAbs(std.math.floatMax(f64), invalid_total_tree.totalWeight(), std.math.floatMax(f64) * 1e-12);
    try invalid_total_tree.update(0, 0);
    try std.testing.expectError(error.InvalidWeight, invalid_total_tree.update(0, std.math.inf(f64)));
    try std.testing.expectApproxEqAbs(@as(f64, 0), invalid_total_tree.totalWeight(), 1e-12);
}

test "weighted tree push allocation failure preserves tree" {
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{});
    var tree = try WeightedTree(u32).init(failing.allocator(), &.{ 0, 0, 5 });
    defer tree.deinit();

    failing.fail_index = failing.alloc_index;
    try std.testing.expectError(error.OutOfMemory, tree.push(7));
    try std.testing.expect(failing.has_induced_failure);
    try std.testing.expectEqual(@as(usize, 3), tree.len());
    try std.testing.expectApproxEqAbs(@as(f64, 5), tree.totalWeight(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5), try tree.get(2), 1e-12);

    var engine = @import("root.zig").ScalarPrng.init(0x5150_7ee1);
    var out: [8]usize = undefined;
    try tree.fillCheckedFrom(&engine, &out);
    for (out) |index| try std.testing.expectEqual(@as(usize, 2), index);
}

test "zero-length weighted tree fills do not validate or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7ee3);
    var control = alea.ScalarPrng.init(0x5150_7ee3);

    var empty_tree = try WeightedTree(u32).init(std.testing.allocator, &.{});
    defer empty_tree.deinit();
    var empty_buf: [0]usize = .{};
    try empty_tree.fillCheckedFrom(&engine, &empty_buf);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_tree = try WeightedTree(u32).init(std.testing.allocator, &.{ 0, 0 });
    defer invalid_tree.deinit();
    try invalid_tree.fillCheckedFrom(&engine, &empty_buf);
    try std.testing.expectEqual(control.next(), engine.next());

    var one_buf: [1]usize = undefined;
    try std.testing.expectError(error.InvalidWeight, invalid_tree.fillCheckedFrom(&engine, &one_buf));
}

test "weighted int tree supports dynamic updates" {
    const alea = @import("root.zig");
    var engine = alea.Wyhash64.init(46);
    const rng = Rng.init(&engine);

    var tree = try WeightedIntTree(u32).init(std.testing.allocator, &.{ 9, 1, 0 });
    defer tree.deinit();

    try std.testing.expectEqual(@as(usize, 3), tree.len());
    try std.testing.expect(!tree.isEmpty());
    try std.testing.expect(tree.isValid());
    try std.testing.expectEqual(@as(u64, 10), tree.totalWeight());
    try std.testing.expectEqual(@as(u64, 9), try tree.get(0));
    try std.testing.expectEqual(@as(u64, 1), try tree.get(1));
    try std.testing.expectEqual(@as(u64, 0), try tree.get(2));
    try std.testing.expectEqual(@as(u64, 1), try tree.weightAt(1));
    try std.testing.expectError(error.InvalidParameter, tree.weightAt(3));
    try std.testing.expectApproxEqAbs(@as(f64, 0.9), try tree.probabilityAt(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.1), try tree.probabilityAt(1), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), try tree.probabilityAt(2), 1e-12);
    try std.testing.expectError(error.InvalidParameter, tree.probabilityAt(3));
    var probabilities_buf: [3]f64 = undefined;
    try tree.probabilitiesInto(&probabilities_buf);
    try std.testing.expectApproxEqAbs(@as(f64, 0.9), probabilities_buf[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.1), probabilities_buf[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), probabilities_buf[2], 1e-12);
    var weights_buf: [3]u64 = undefined;
    try tree.weightsInto(&weights_buf);
    try std.testing.expectEqualSlices(u64, &.{ 9, 1, 0 }, &weights_buf);
    var wrong_weights_len: [2]u64 = undefined;
    try std.testing.expectError(error.InvalidLength, tree.weightsInto(&wrong_weights_len));
    var wrong_probability_len: [2]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, tree.probabilitiesInto(&wrong_probability_len));
    const owned_weights = try tree.weights(std.testing.allocator);
    defer std.testing.allocator.free(owned_weights);
    try std.testing.expectEqualSlices(u64, &weights_buf, owned_weights);
    const owned_probabilities = try tree.probabilities(std.testing.allocator);
    defer std.testing.allocator.free(owned_probabilities);
    try std.testing.expectEqualSlices(f64, &probabilities_buf, owned_probabilities);
    var weights_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, tree.weights(weights_alloc.allocator()));
    try std.testing.expect(weights_alloc.has_induced_failure);

    try tree.update(0, 0);
    try tree.update(1, 0);
    try std.testing.expect(!tree.isValid());
    try std.testing.expectError(error.InvalidWeight, tree.sampleChecked(rng));
    try std.testing.expectError(error.InvalidWeight, tree.probabilityAt(0));
    try std.testing.expectError(error.InvalidWeight, tree.probabilitiesInto(&probabilities_buf));

    try tree.push(5);
    try std.testing.expectEqual(@as(usize, 4), tree.len());
    try std.testing.expectEqual(@as(u64, 5), tree.totalWeight());
    try std.testing.expectEqual(@as(u64, 5), try tree.get(3));
    var i: usize = 0;
    while (i < 16) : (i += 1) try std.testing.expectEqual(@as(usize, 3), tree.sampleFrom(&engine));
    try std.testing.expectEqual(@as(usize, 3), try tree.sampleCheckedFrom(&engine));
    var tree_buf: [8]usize = undefined;
    try tree.fillCheckedFrom(&engine, &tree_buf);
    for (tree_buf) |index| try std.testing.expectEqual(@as(usize, 3), index);

    try tree.update(2, 5);
    try std.testing.expectEqual(@as(u64, 10), tree.totalWeight());
    const popped = tree.pop().?;
    try std.testing.expectEqual(@as(u64, 5), popped);
    try std.testing.expectEqual(@as(usize, 3), tree.len());
    try std.testing.expectEqual(@as(u64, 5), tree.totalWeight());
    try std.testing.expectEqual(@as(usize, 2), tree.sample(rng));
    try tree.weightsInto(&weights_buf);
    try std.testing.expectEqualSlices(u64, &.{ 0, 0, 5 }, &weights_buf);

    try std.testing.expectError(error.InvalidParameter, tree.update(9, 1));

    var empty_tree = try WeightedIntTree(u32).init(std.testing.allocator, &.{});
    defer empty_tree.deinit();
    try std.testing.expect(empty_tree.isEmpty());
    try std.testing.expect(!empty_tree.isValid());
    try std.testing.expectEqual(@as(?u64, null), empty_tree.pop());
    try std.testing.expectError(error.InvalidParameter, empty_tree.update(0, 1));
    try std.testing.expect(empty_tree.isEmpty());
    try empty_tree.push(6);
    try std.testing.expect(!empty_tree.isEmpty());
    try std.testing.expect(empty_tree.isValid());
    try std.testing.expectEqual(@as(u64, 6), empty_tree.totalWeight());
    try std.testing.expectEqual(@as(u64, 6), try empty_tree.get(0));
    try std.testing.expectEqual(@as(u64, 6), empty_tree.pop().?);
    try std.testing.expect(empty_tree.isEmpty());
    try std.testing.expect(!empty_tree.isValid());
    try std.testing.expectError(error.InvalidParameter, empty_tree.get(0));
    var empty_probabilities: [0]f64 = .{};
    try empty_tree.probabilitiesInto(&empty_probabilities);

    var single_tree = try WeightedIntTree(u32).init(std.testing.allocator, &.{4});
    defer single_tree.deinit();
    try std.testing.expectEqual(@as(u64, 4), single_tree.pop().?);
    try std.testing.expect(single_tree.isEmpty());
    try std.testing.expect(!single_tree.isValid());
    try std.testing.expectEqual(@as(?u64, null), single_tree.pop());

    var overflow_tree = try WeightedIntTree(u64).init(std.testing.allocator, &.{std.math.maxInt(u64)});
    defer overflow_tree.deinit();
    try std.testing.expectError(error.InvalidWeight, overflow_tree.push(1));
    try std.testing.expectEqual(@as(u64, std.math.maxInt(u64)), overflow_tree.totalWeight());

    var update_overflow_tree = try WeightedIntTree(u64).init(std.testing.allocator, &.{ std.math.maxInt(u64), 0 });
    defer update_overflow_tree.deinit();
    try std.testing.expectError(error.InvalidWeight, update_overflow_tree.update(1, 1));
    try std.testing.expectEqual(@as(u64, std.math.maxInt(u64)), update_overflow_tree.totalWeight());

    try std.testing.expectError(error.InvalidWeight, WeightedIntTree(u64).init(std.testing.allocator, &.{
        std.math.maxInt(u64),
        1,
    }));

    const too_large_u128 = @as(u128, std.math.maxInt(u64)) + 1;
    try std.testing.expectError(error.InvalidWeight, WeightedIntTree(u128).init(std.testing.allocator, &.{too_large_u128}));

    var wide_tree = try WeightedIntTree(u128).init(std.testing.allocator, &.{1});
    defer wide_tree.deinit();
    try std.testing.expectError(error.InvalidWeight, wide_tree.push(too_large_u128));
    try std.testing.expectError(error.InvalidWeight, wide_tree.update(0, too_large_u128));
    try std.testing.expectEqual(@as(u64, 1), wide_tree.totalWeight());
}

test "weighted int tree push allocation failure preserves tree" {
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{});
    var tree = try WeightedIntTree(u32).init(failing.allocator(), &.{ 0, 0, 5 });
    defer tree.deinit();

    failing.fail_index = failing.alloc_index;
    try std.testing.expectError(error.OutOfMemory, tree.push(7));
    try std.testing.expect(failing.has_induced_failure);
    try std.testing.expectEqual(@as(usize, 3), tree.len());
    try std.testing.expectEqual(@as(u64, 5), tree.totalWeight());
    try std.testing.expectEqual(@as(u64, 5), try tree.get(2));

    var engine = @import("root.zig").ScalarPrng.init(0x5150_7ee2);
    var out: [8]usize = undefined;
    try tree.fillCheckedFrom(&engine, &out);
    for (out) |index| try std.testing.expectEqual(@as(usize, 2), index);
}

test "zero-length weighted int tree fills do not validate or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7ee4);
    var control = alea.ScalarPrng.init(0x5150_7ee4);

    var empty_tree = try WeightedIntTree(u32).init(std.testing.allocator, &.{});
    defer empty_tree.deinit();
    var empty_buf: [0]usize = .{};
    try empty_tree.fillCheckedFrom(&engine, &empty_buf);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_tree = try WeightedIntTree(u32).init(std.testing.allocator, &.{ 0, 0 });
    defer invalid_tree.deinit();
    try invalid_tree.fillCheckedFrom(&engine, &empty_buf);
    try std.testing.expectEqual(control.next(), engine.next());

    var one_buf: [1]usize = undefined;
    try std.testing.expectError(error.InvalidWeight, invalid_tree.fillCheckedFrom(&engine, &one_buf));
}

test "weighted reusable samplers preserve direct stream shape" {
    const alea = @import("root.zig");

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_aa11);
        var direct_engine = Engine.init(0x5150_aa11);
        const rng = Rng.init(&facade_engine);

        var alias = try AliasTable(u32).init(std.testing.allocator, &.{ 1, 0, 5, 3 });
        defer alias.deinit();
        try std.testing.expectEqual(alias.sample(rng), alias.sampleFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        var alias_buf: [8]usize = undefined;
        var direct_alias_buf: [8]usize = undefined;
        alias.fill(rng, &alias_buf);
        alias.fillFrom(&direct_engine, &direct_alias_buf);
        try std.testing.expectEqualSlices(usize, &alias_buf, &direct_alias_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var tree = try WeightedTree(u32).init(std.testing.allocator, &.{ 1, 0, 5, 3 });
        defer tree.deinit();
        try std.testing.expectEqual(tree.sample(rng), tree.sampleFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        try std.testing.expectEqual(try tree.sampleChecked(rng), try tree.sampleCheckedFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        var tree_buf: [8]usize = undefined;
        var direct_tree_buf: [8]usize = undefined;
        tree.fill(rng, &tree_buf);
        tree.fillFrom(&direct_engine, &direct_tree_buf);
        try std.testing.expectEqualSlices(usize, &tree_buf, &direct_tree_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        try tree.fillChecked(rng, &tree_buf);
        try tree.fillCheckedFrom(&direct_engine, &direct_tree_buf);
        try std.testing.expectEqualSlices(usize, &tree_buf, &direct_tree_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var int_tree = try WeightedIntTree(u32).init(std.testing.allocator, &.{ 1, 0, 5, 3 });
        defer int_tree.deinit();
        try std.testing.expectEqual(int_tree.sample(rng), int_tree.sampleFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        try std.testing.expectEqual(try int_tree.sampleChecked(rng), try int_tree.sampleCheckedFrom(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        var int_tree_buf: [8]usize = undefined;
        var direct_int_tree_buf: [8]usize = undefined;
        int_tree.fill(rng, &int_tree_buf);
        int_tree.fillFrom(&direct_engine, &direct_int_tree_buf);
        try std.testing.expectEqualSlices(usize, &int_tree_buf, &direct_int_tree_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        try int_tree.fillChecked(rng, &int_tree_buf);
        try int_tree.fillCheckedFrom(&direct_engine, &direct_int_tree_buf);
        try std.testing.expectEqualSlices(usize, &int_tree_buf, &direct_int_tree_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
}

test "invalid checked distribution helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d15a);

    try std.testing.expectError(error.InvalidProbability, bernoulliCheckedFrom(&engine, -0.1));
    try std.testing.expectEqual(@as(u64, 0xc8c84e0eb11b6c5c), engine.next());

    try std.testing.expectError(error.InvalidProbability, binomialCheckedFrom(&engine, 10, 1.1));
    try std.testing.expectEqual(@as(u64, 0x6fa8adba01bcb54b), engine.next());

    try std.testing.expectError(error.InvalidProbability, binomialPoissonApproxCheckedFrom(&engine, 10, 1.1));
    try std.testing.expectEqual(@as(u64, 0xecf8465edb82c03b), engine.next());

    try std.testing.expectError(error.InvalidParameter, negativeBinomialCheckedFrom(&engine, 0, 0.5));
    try std.testing.expectEqual(@as(u64, 0xd56d49693f95654f), engine.next());

    try std.testing.expectError(error.InvalidParameter, hypergeometricCheckedFrom(&engine, 10, 11, 1));
    try std.testing.expectEqual(@as(u64, 0xe8ca59451a5ce1b4), engine.next());

    try std.testing.expectError(error.InvalidParameter, poissonCheckedFrom(&engine, std.math.inf(f64)));
    try std.testing.expectEqual(@as(u64, 0x25b1148f9e0f74e6), engine.next());

    var u64_buf: [4]u64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillPoissonCheckedFrom(&engine, &u64_buf, std.math.inf(f64)));
    try std.testing.expectEqual(@as(u64, 0xb446f7886dcf7815), engine.next());

    var f64_buf: [4]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillGammaCheckedFrom(&engine, f64, &f64_buf, 0, 1));
    try std.testing.expectEqual(@as(u64, 0x2b82cf28019809c7), engine.next());

    try std.testing.expectError(error.InvalidParameter, triangularCheckedFrom(&engine, f64, 1, 0, 2));
    try std.testing.expectEqual(@as(u64, 0x55399c665cffeced), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillCauchyCheckedFrom(&engine, f64, &f64_buf, 0, 0));
    try std.testing.expectEqual(@as(u64, 0xffc62ac12a0f359b), engine.next());

    try std.testing.expectError(error.InvalidParameter, inverseGaussianCheckedFrom(&engine, f64, 0, 1));
    try std.testing.expectEqual(@as(u64, 0xa1a16919c0a88685), engine.next());

    try std.testing.expectError(error.InvalidParameter, zipfCheckedFrom(&engine, f64, 0, 1));
    try std.testing.expectEqual(@as(u64, 0x93845468b76116a4), engine.next());

    var tree = try WeightedTree(u32).init(std.testing.allocator, &.{ 0, 0 });
    defer tree.deinit();
    try std.testing.expectError(error.InvalidWeight, tree.sampleCheckedFrom(&engine));
    try std.testing.expectEqual(@as(u64, 0x1ad57bbf42203964), engine.next());

    var int_tree = try WeightedIntTree(u32).init(std.testing.allocator, &.{ 0, 0 });
    defer int_tree.deinit();
    try std.testing.expectError(error.InvalidWeight, int_tree.fillCheckedFrom(&engine, &u64_buf));
    try std.testing.expectEqual(@as(u64, 0xc69be165851d8893), engine.next());
}

test "invalid normal exponential wrapper helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1f5);
    var control = alea.ScalarPrng.init(0x5150_d1f5);

    try std.testing.expectError(error.InvalidParameter, normalCheckedFrom(&engine, f64, 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    var normal_buf: [4]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillNormalCheckedFrom(&engine, f64, &normal_buf, 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, exponentialCheckedFrom(&engine, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    var exponential_buf: [4]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillExponentialCheckedFrom(&engine, f64, &exponential_buf, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid discrete distribution helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1f4);
    var control = alea.ScalarPrng.init(0x5150_d1f4);

    try std.testing.expectError(error.InvalidProbability, negativeBinomialCheckedFrom(&engine, 5, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, geometricFailuresCheckedFrom(&engine, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, geometricCheckedFrom(&engine, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    var buf: [4]u64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillHypergeometricCheckedFrom(&engine, &buf, 10, 11, 1));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "distribution vector helpers preserve support and stream shape" {
    const alea = @import("root.zig");
    var facade_engine = alea.ScalarPrng.init(0x5eed_51d4);
    var direct_engine = alea.ScalarPrng.init(0x5eed_51d4);
    const rng = Rng.init(&facade_engine);

    const bernoulli_vec = vectorBernoulli(rng, @Vector(8, bool), 0.25);
    const direct_bernoulli_vec = vectorBernoulliFrom(&direct_engine, @Vector(8, bool), 0.25);
    try std.testing.expectEqual(bernoulli_vec, direct_bernoulli_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const checked_bernoulli_vec = try vectorBernoulliChecked(rng, @Vector(8, bool), 0.5);
    const direct_checked_bernoulli_vec = try vectorBernoulliCheckedFrom(&direct_engine, @Vector(8, bool), 0.5);
    try std.testing.expectEqual(checked_bernoulli_vec, direct_checked_bernoulli_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_bernoulli_sampler = try VectorBernoulli(@Vector(8, bool)).initRatio(1, 4);
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), vector_bernoulli_sampler.probabilityValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), vector_bernoulli_sampler.expectedValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, 0.1875), vector_bernoulli_sampler.varianceValue(), 1e-15);
    try std.testing.expectEqual(false, vector_bernoulli_sampler.modeValue().?);
    try std.testing.expectEqual(false, vector_bernoulli_sampler.minValue());
    try std.testing.expectEqual(true, vector_bernoulli_sampler.maxValue());
    const sampled_bernoulli_vec = vector_bernoulli_sampler.sample(rng);
    const direct_sampled_bernoulli_vec = vector_bernoulli_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_bernoulli_vec, direct_sampled_bernoulli_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var bernoulli_buf: [3]@Vector(8, bool) = undefined;
    var direct_bernoulli_buf: [3]@Vector(8, bool) = undefined;
    try fillVectorBernoulliChecked(rng, @Vector(8, bool), &bernoulli_buf, 0.25);
    try fillVectorBernoulliCheckedFrom(&direct_engine, @Vector(8, bool), &direct_bernoulli_buf, 0.25);
    try std.testing.expectEqualSlices(@Vector(8, bool), &bernoulli_buf, &direct_bernoulli_buf);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    vector_bernoulli_sampler.fill(rng, &bernoulli_buf);
    vector_bernoulli_sampler.fillFrom(&direct_engine, &direct_bernoulli_buf);
    try std.testing.expectEqualSlices(@Vector(8, bool), &bernoulli_buf, &direct_bernoulli_buf);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const always_true_vec = (try VectorBernoulli(@Vector(8, bool)).init(1)).sample(rng);
    try std.testing.expectEqual(@as(@Vector(8, bool), @splat(true)), always_true_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const binomial_vec = vectorBinomial(rng, @Vector(4, u64), 10, 0.5);
    const direct_binomial_vec = vectorBinomialFrom(&direct_engine, @Vector(4, u64), 10, 0.5);
    try std.testing.expectEqual(binomial_vec, direct_binomial_vec);
    inline for (0..4) |lane| try std.testing.expect(binomial_vec[lane] <= 10);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const checked_binomial_vec = try vectorBinomialChecked(rng, @Vector(4, u64), 10, 0.5);
    const direct_checked_binomial_vec = try vectorBinomialCheckedFrom(&direct_engine, @Vector(4, u64), 10, 0.5);
    try std.testing.expectEqual(checked_binomial_vec, direct_checked_binomial_vec);
    inline for (0..4) |lane| try std.testing.expect(checked_binomial_vec[lane] <= 10);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_binomial_sampler = try VectorBinomial(@Vector(4, u64)).init(10, 0.5);
    try std.testing.expectEqual(@as(u64, 10), vector_binomial_sampler.trialsValue());
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), vector_binomial_sampler.probabilityValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, 5), vector_binomial_sampler.expectedValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, 2.5), vector_binomial_sampler.varianceValue(), 1e-15);
    try std.testing.expectEqual(@as(u64, 0), vector_binomial_sampler.minValue());
    try std.testing.expectEqual(@as(u64, 10), vector_binomial_sampler.maxValue());
    const sampled_binomial_vec = vector_binomial_sampler.sample(rng);
    const direct_sampled_binomial_vec = vector_binomial_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_binomial_vec, direct_sampled_binomial_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_binomial_vec[lane] <= 10);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const always_success_binomial = try VectorBinomial(@Vector(4, u64)).init(10, 1);
    const always_success_vec = always_success_binomial.sample(rng);
    try std.testing.expectEqual(@as(@Vector(4, u64), @splat(10)), always_success_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var binomial_buf: [3]@Vector(4, u64) = undefined;
    var direct_binomial_buf: [3]@Vector(4, u64) = undefined;
    try fillVectorBinomialChecked(rng, @Vector(4, u64), &binomial_buf, 10, 0.5);
    try fillVectorBinomialCheckedFrom(&direct_engine, @Vector(4, u64), &direct_binomial_buf, 10, 0.5);
    try std.testing.expectEqualSlices(@Vector(4, u64), &binomial_buf, &direct_binomial_buf);
    for (binomial_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] <= 10);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    vector_binomial_sampler.fill(rng, &binomial_buf);
    vector_binomial_sampler.fillFrom(&direct_engine, &direct_binomial_buf);
    try std.testing.expectEqualSlices(@Vector(4, u64), &binomial_buf, &direct_binomial_buf);
    for (binomial_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] <= 10);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    always_success_binomial.fill(rng, &binomial_buf);
    for (binomial_buf) |vec| try std.testing.expectEqual(@as(@Vector(4, u64), @splat(10)), vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const negative_binomial_vec = vectorNegativeBinomial(rng, @Vector(4, u64), 5, 0.25);
    const direct_negative_binomial_vec = vectorNegativeBinomialFrom(&direct_engine, @Vector(4, u64), 5, 0.25);
    try std.testing.expectEqual(negative_binomial_vec, direct_negative_binomial_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const checked_negative_binomial_vec = try vectorNegativeBinomialChecked(rng, @Vector(4, u64), 5, 0.25);
    const direct_checked_negative_binomial_vec = try vectorNegativeBinomialCheckedFrom(&direct_engine, @Vector(4, u64), 5, 0.25);
    try std.testing.expectEqual(checked_negative_binomial_vec, direct_checked_negative_binomial_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_negative_binomial_sampler = try VectorNegativeBinomial(@Vector(4, u64)).init(5, 0.25);
    try std.testing.expectEqual(@as(u64, 5), vector_negative_binomial_sampler.successesValue());
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), vector_negative_binomial_sampler.probabilityValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, 15), vector_negative_binomial_sampler.expectedValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, 60), vector_negative_binomial_sampler.varianceValue(), 1e-15);
    try std.testing.expectEqual(@as(u64, 0), vector_negative_binomial_sampler.minValue());
    try std.testing.expect(vector_negative_binomial_sampler.maxValue() == null);
    const sampled_negative_binomial_vec = vector_negative_binomial_sampler.sample(rng);
    const direct_sampled_negative_binomial_vec = vector_negative_binomial_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_negative_binomial_vec, direct_sampled_negative_binomial_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var negative_binomial_buf: [3]@Vector(4, u64) = undefined;
    var direct_negative_binomial_buf: [3]@Vector(4, u64) = undefined;
    try fillVectorNegativeBinomialChecked(rng, @Vector(4, u64), &negative_binomial_buf, 5, 0.25);
    try fillVectorNegativeBinomialCheckedFrom(&direct_engine, @Vector(4, u64), &direct_negative_binomial_buf, 5, 0.25);
    try std.testing.expectEqualSlices(@Vector(4, u64), &negative_binomial_buf, &direct_negative_binomial_buf);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    vector_negative_binomial_sampler.fill(rng, &negative_binomial_buf);
    vector_negative_binomial_sampler.fillFrom(&direct_engine, &direct_negative_binomial_buf);
    try std.testing.expectEqualSlices(@Vector(4, u64), &negative_binomial_buf, &direct_negative_binomial_buf);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const always_success_negative_binomial = try VectorNegativeBinomial(@Vector(4, u64)).init(5, 1);
    const always_success_negative_vec = always_success_negative_binomial.sample(rng);
    try std.testing.expectEqual(@as(@Vector(4, u64), @splat(0)), always_success_negative_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    always_success_negative_binomial.fill(rng, &negative_binomial_buf);
    for (negative_binomial_buf) |vec| try std.testing.expectEqual(@as(@Vector(4, u64), @splat(0)), vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const hypergeometric_vec = vectorHypergeometric(rng, @Vector(4, u64), 100, 30, 10);
    const direct_hypergeometric_vec = vectorHypergeometricFrom(&direct_engine, @Vector(4, u64), 100, 30, 10);
    try std.testing.expectEqual(hypergeometric_vec, direct_hypergeometric_vec);
    inline for (0..4) |lane| try std.testing.expect(hypergeometric_vec[lane] <= 10);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const checked_hypergeometric_vec = try vectorHypergeometricChecked(rng, @Vector(4, u64), 100, 30, 10);
    const direct_checked_hypergeometric_vec = try vectorHypergeometricCheckedFrom(&direct_engine, @Vector(4, u64), 100, 30, 10);
    try std.testing.expectEqual(checked_hypergeometric_vec, direct_checked_hypergeometric_vec);
    inline for (0..4) |lane| try std.testing.expect(checked_hypergeometric_vec[lane] <= 10);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_hypergeometric_sampler = try VectorHypergeometric(@Vector(4, u64)).init(100, 30, 10);
    try std.testing.expectEqual(@as(u64, 100), vector_hypergeometric_sampler.populationValue());
    try std.testing.expectEqual(@as(u64, 30), vector_hypergeometric_sampler.successesValue());
    try std.testing.expectEqual(@as(u64, 10), vector_hypergeometric_sampler.drawsValue());
    try std.testing.expectApproxEqAbs(@as(f64, 3), vector_hypergeometric_sampler.expectedValue(), 1e-15);
    try std.testing.expectEqual(@as(u64, 0), vector_hypergeometric_sampler.minValue());
    try std.testing.expectEqual(@as(u64, 10), vector_hypergeometric_sampler.maxValue());
    const sampled_hypergeometric_vec = vector_hypergeometric_sampler.sample(rng);
    const direct_sampled_hypergeometric_vec = vector_hypergeometric_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_hypergeometric_vec, direct_sampled_hypergeometric_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_hypergeometric_vec[lane] <= 10);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var hypergeometric_buf: [3]@Vector(4, u64) = undefined;
    var direct_hypergeometric_buf: [3]@Vector(4, u64) = undefined;
    try fillVectorHypergeometricChecked(rng, @Vector(4, u64), &hypergeometric_buf, 100, 30, 10);
    try fillVectorHypergeometricCheckedFrom(&direct_engine, @Vector(4, u64), &direct_hypergeometric_buf, 100, 30, 10);
    try std.testing.expectEqualSlices(@Vector(4, u64), &hypergeometric_buf, &direct_hypergeometric_buf);
    for (hypergeometric_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] <= 10);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    vector_hypergeometric_sampler.fill(rng, &hypergeometric_buf);
    vector_hypergeometric_sampler.fillFrom(&direct_engine, &direct_hypergeometric_buf);
    try std.testing.expectEqualSlices(@Vector(4, u64), &hypergeometric_buf, &direct_hypergeometric_buf);
    for (hypergeometric_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] <= 10);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const deterministic_hypergeometric = try VectorHypergeometric(@Vector(4, u64)).init(10, 10, 4);
    const deterministic_vec = deterministic_hypergeometric.sample(rng);
    const direct_deterministic_vec = deterministic_hypergeometric.sampleFrom(&direct_engine);
    try std.testing.expectEqual(deterministic_vec, direct_deterministic_vec);
    try std.testing.expectEqual(@as(@Vector(4, u64), @splat(4)), deterministic_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    deterministic_hypergeometric.fill(rng, &hypergeometric_buf);
    deterministic_hypergeometric.fillFrom(&direct_engine, &direct_hypergeometric_buf);
    try std.testing.expectEqualSlices(@Vector(4, u64), &hypergeometric_buf, &direct_hypergeometric_buf);
    for (hypergeometric_buf) |vec| try std.testing.expectEqual(@as(@Vector(4, u64), @splat(4)), vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const geometric_vec = vectorGeometric(rng, @Vector(4, u64), 0.25);
    const direct_geometric_vec = vectorGeometricFrom(&direct_engine, @Vector(4, u64), 0.25);
    try std.testing.expectEqual(geometric_vec, direct_geometric_vec);
    inline for (0..4) |lane| try std.testing.expect(geometric_vec[lane] >= 1);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const checked_geometric_vec = try vectorGeometricChecked(rng, @Vector(4, u64), 0.25);
    const direct_checked_geometric_vec = try vectorGeometricCheckedFrom(&direct_engine, @Vector(4, u64), 0.25);
    try std.testing.expectEqual(checked_geometric_vec, direct_checked_geometric_vec);
    inline for (0..4) |lane| try std.testing.expect(checked_geometric_vec[lane] >= 1);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_geometric_sampler = try VectorGeometric(@Vector(4, u64)).init(0.25);
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), vector_geometric_sampler.probabilityValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, 4), vector_geometric_sampler.expectedValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, 12), vector_geometric_sampler.varianceValue(), 1e-15);
    try std.testing.expectEqual(@as(u64, 1), vector_geometric_sampler.modeValue());
    try std.testing.expectEqual(@as(u64, 1), vector_geometric_sampler.minValue());
    try std.testing.expect(vector_geometric_sampler.maxValue() == null);
    const sampled_geometric_vec = vector_geometric_sampler.sample(rng);
    const direct_sampled_geometric_vec = vector_geometric_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_geometric_vec, direct_sampled_geometric_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_geometric_vec[lane] >= 1);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const geometric_failures_vec = vectorGeometricFailures(rng, @Vector(4, u64), 0.25);
    const direct_geometric_failures_vec = vectorGeometricFailuresFrom(&direct_engine, @Vector(4, u64), 0.25);
    try std.testing.expectEqual(geometric_failures_vec, direct_geometric_failures_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_geometric_failures_sampler = try VectorGeometricFailures(@Vector(4, u64)).init(0.25);
    try std.testing.expectApproxEqAbs(@as(f64, 3), vector_geometric_failures_sampler.expectedValue(), 1e-15);
    try std.testing.expectEqual(@as(u64, 0), vector_geometric_failures_sampler.modeValue());
    try std.testing.expectEqual(@as(u64, 0), vector_geometric_failures_sampler.minValue());
    const sampled_geometric_failures_vec = vector_geometric_failures_sampler.sample(rng);
    const direct_sampled_geometric_failures_vec = vector_geometric_failures_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_geometric_failures_vec, direct_sampled_geometric_failures_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var geometric_buf: [3]@Vector(4, u64) = undefined;
    var direct_geometric_buf: [3]@Vector(4, u64) = undefined;
    try fillVectorGeometricChecked(rng, @Vector(4, u64), &geometric_buf, 0.25);
    try fillVectorGeometricCheckedFrom(&direct_engine, @Vector(4, u64), &direct_geometric_buf, 0.25);
    try std.testing.expectEqualSlices(@Vector(4, u64), &geometric_buf, &direct_geometric_buf);
    for (geometric_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= 1);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    vector_geometric_sampler.fill(rng, &geometric_buf);
    vector_geometric_sampler.fillFrom(&direct_engine, &direct_geometric_buf);
    try std.testing.expectEqualSlices(@Vector(4, u64), &geometric_buf, &direct_geometric_buf);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var geometric_failures_buf: [3]@Vector(4, u64) = undefined;
    var direct_geometric_failures_buf: [3]@Vector(4, u64) = undefined;
    try fillVectorGeometricFailuresChecked(rng, @Vector(4, u64), &geometric_failures_buf, 0.25);
    try fillVectorGeometricFailuresCheckedFrom(&direct_engine, @Vector(4, u64), &direct_geometric_failures_buf, 0.25);
    try std.testing.expectEqualSlices(@Vector(4, u64), &geometric_failures_buf, &direct_geometric_failures_buf);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    vector_geometric_failures_sampler.fill(rng, &geometric_failures_buf);
    vector_geometric_failures_sampler.fillFrom(&direct_engine, &direct_geometric_failures_buf);
    try std.testing.expectEqualSlices(@Vector(4, u64), &geometric_failures_buf, &direct_geometric_failures_buf);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const standard_geometric_vec = vectorStandardGeometric(rng, @Vector(4, u64));
    const direct_standard_geometric_vec = vectorStandardGeometricFrom(&direct_engine, @Vector(4, u64));
    try std.testing.expectEqual(standard_geometric_vec, direct_standard_geometric_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_standard_geometric_sampler = VectorStandardGeometric(@Vector(4, u64)){};
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), vector_standard_geometric_sampler.probabilityValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, 1), vector_standard_geometric_sampler.expectedValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, 2), vector_standard_geometric_sampler.varianceValue(), 1e-15);
    try std.testing.expectEqual(@as(u64, 0), vector_standard_geometric_sampler.modeValue());
    try std.testing.expectEqual(@as(u64, 0), vector_standard_geometric_sampler.minValue());
    try std.testing.expect(vector_standard_geometric_sampler.maxValue() == null);
    const sampled_standard_geometric_vec = vector_standard_geometric_sampler.sample(rng);
    const direct_sampled_standard_geometric_vec = vector_standard_geometric_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_standard_geometric_vec, direct_sampled_standard_geometric_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var standard_geometric_vector_buf: [3]@Vector(4, u64) = undefined;
    var direct_standard_geometric_vector_buf: [3]@Vector(4, u64) = undefined;
    fillVectorStandardGeometric(rng, @Vector(4, u64), &standard_geometric_vector_buf);
    fillVectorStandardGeometricFrom(&direct_engine, @Vector(4, u64), &direct_standard_geometric_vector_buf);
    try std.testing.expectEqualSlices(@Vector(4, u64), &standard_geometric_vector_buf, &direct_standard_geometric_vector_buf);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_standard_geometric_sampler.fill(rng, &standard_geometric_vector_buf);
    vector_standard_geometric_sampler.fillFrom(&direct_engine, &direct_standard_geometric_vector_buf);
    try std.testing.expectEqualSlices(@Vector(4, u64), &standard_geometric_vector_buf, &direct_standard_geometric_vector_buf);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const always_success_geometric = try VectorGeometric(@Vector(4, u64)).init(1);
    const always_success_geometric_vec = always_success_geometric.sample(rng);
    try std.testing.expectEqual(@as(@Vector(4, u64), @splat(1)), always_success_geometric_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    const always_success_failures = try VectorGeometricFailures(@Vector(4, u64)).init(1);
    const always_success_failures_vec = always_success_failures.sample(rng);
    try std.testing.expectEqual(@as(@Vector(4, u64), @splat(0)), always_success_failures_vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const poisson_vec = vectorPoisson(rng, @Vector(4, u64), 12);
    const direct_poisson_vec = vectorPoissonFrom(&direct_engine, @Vector(4, u64), 12);
    try std.testing.expectEqual(poisson_vec, direct_poisson_vec);
    inline for (0..4) |lane| try std.testing.expect(poisson_vec[lane] < 64);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const checked_poisson_vec = try vectorPoissonChecked(rng, @Vector(4, u64), 12);
    const direct_checked_poisson_vec = try vectorPoissonCheckedFrom(&direct_engine, @Vector(4, u64), 12);
    try std.testing.expectEqual(checked_poisson_vec, direct_checked_poisson_vec);
    inline for (0..4) |lane| try std.testing.expect(checked_poisson_vec[lane] < 64);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_poisson_sampler = try VectorPoisson(@Vector(4, u64)).init(12);
    try std.testing.expectApproxEqAbs(@as(f64, 12), vector_poisson_sampler.lambdaValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 12), vector_poisson_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 12), vector_poisson_sampler.varianceValue(), 1e-12);
    try std.testing.expectEqual(@as(u64, 0), vector_poisson_sampler.minValue());
    try std.testing.expect(vector_poisson_sampler.maxValue() == null);
    const sampled_poisson_vec = vector_poisson_sampler.sample(rng);
    const direct_sampled_poisson_vec = vector_poisson_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_poisson_vec, direct_sampled_poisson_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_poisson_vec[lane] < 64);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const zero_poisson_sampler = try VectorPoisson(@Vector(4, u64)).init(0);
    const before_zero_sample = facade_engine.next();
    const zero_poisson_vec = zero_poisson_sampler.sample(rng);
    try std.testing.expectEqual(@as(@Vector(4, u64), @splat(0)), zero_poisson_vec);
    try std.testing.expectEqual(before_zero_sample, direct_engine.next());

    var poisson_buf: [3]@Vector(4, u64) = undefined;
    var direct_poisson_buf: [3]@Vector(4, u64) = undefined;
    try fillVectorPoissonChecked(rng, @Vector(4, u64), &poisson_buf, 12);
    try fillVectorPoissonCheckedFrom(&direct_engine, @Vector(4, u64), &direct_poisson_buf, 12);
    try std.testing.expectEqualSlices(@Vector(4, u64), &poisson_buf, &direct_poisson_buf);
    for (poisson_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] < 64);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    vector_poisson_sampler.fill(rng, &poisson_buf);
    vector_poisson_sampler.fillFrom(&direct_engine, &direct_poisson_buf);
    try std.testing.expectEqualSlices(@Vector(4, u64), &poisson_buf, &direct_poisson_buf);
    for (poisson_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] < 64);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    zero_poisson_sampler.fill(rng, &poisson_buf);
    for (poisson_buf) |vec| try std.testing.expectEqual(@as(@Vector(4, u64), @splat(0)), vec);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const uniform_vec = vectorUniform(rng, @Vector(4, f32), -1, 2);
    const direct_uniform_vec = vectorUniformFrom(&direct_engine, @Vector(4, f32), -1, 2);
    try std.testing.expectEqual(uniform_vec, direct_uniform_vec);
    inline for (0..4) |lane| try std.testing.expect(uniform_vec[lane] >= -1 and uniform_vec[lane] < 2);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const uniform_int_vec = try vectorUniformChecked(rng, @Vector(4, u16), 3, 9);
    const direct_uniform_int_vec = try vectorUniformCheckedFrom(&direct_engine, @Vector(4, u16), 3, 9);
    try std.testing.expectEqual(uniform_int_vec, direct_uniform_int_vec);
    inline for (0..4) |lane| try std.testing.expect(uniform_int_vec[lane] >= 3 and uniform_int_vec[lane] < 9);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const inclusive_vec = vectorUniformInclusive(rng, @Vector(4, f32), -1, 2);
    const direct_inclusive_vec = vectorUniformInclusiveFrom(&direct_engine, @Vector(4, f32), -1, 2);
    try std.testing.expectEqual(inclusive_vec, direct_inclusive_vec);
    inline for (0..4) |lane| try std.testing.expect(inclusive_vec[lane] >= -1 and inclusive_vec[lane] <= 2);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const inclusive_int_vec = try vectorUniformInclusiveChecked(rng, @Vector(4, i16), -3, 3);
    const direct_inclusive_int_vec = try vectorUniformInclusiveCheckedFrom(&direct_engine, @Vector(4, i16), -3, 3);
    try std.testing.expectEqual(inclusive_int_vec, direct_inclusive_int_vec);
    inline for (0..4) |lane| try std.testing.expect(inclusive_int_vec[lane] >= -3 and inclusive_int_vec[lane] <= 3);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_uniform_sampler = try VectorUniform(@Vector(4, f32)).init(-1, 2);
    try std.testing.expectEqual(@as(f32, -1), vector_uniform_sampler.lowValue());
    try std.testing.expectEqual(@as(f32, 2), vector_uniform_sampler.highValue());
    try std.testing.expect(!vector_uniform_sampler.isInclusive());
    try std.testing.expectApproxEqAbs(@as(f32, 0.5), vector_uniform_sampler.expectedValue(), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 0.75), vector_uniform_sampler.varianceValue(), 1e-6);
    const sampled_uniform_vec = vector_uniform_sampler.sample(rng);
    const direct_sampled_uniform_vec = vector_uniform_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_uniform_vec, direct_sampled_uniform_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_uniform_vec[lane] >= -1 and sampled_uniform_vec[lane] < 2);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_uniform_inclusive_sampler = try VectorUniform(@Vector(4, i16)).initInclusive(-3, 3);
    try std.testing.expect(vector_uniform_inclusive_sampler.isInclusive());
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_uniform_inclusive_sampler.expectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 4), vector_uniform_inclusive_sampler.varianceValue(), 0);
    const sampled_inclusive_vec = vector_uniform_inclusive_sampler.sample(rng);
    const direct_sampled_inclusive_vec = vector_uniform_inclusive_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_inclusive_vec, direct_sampled_inclusive_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_inclusive_vec[lane] >= -3 and sampled_inclusive_vec[lane] <= 3);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    try std.testing.expectEqual(@as(@Vector(4, f64), @splat(0)), (Open01{}).lowValue(@Vector(4, f64)));
    try std.testing.expectEqual(@as(@Vector(4, f64), @splat(1)), (Open01{}).highValue(@Vector(4, f64)));
    try std.testing.expectEqual(@as(@Vector(4, f64), @splat(0.5)), (Open01{}).expectedValue(@Vector(4, f64)));
    try std.testing.expectEqual(@as(@Vector(4, f64), @splat(1.0 / 12.0)), (OpenClosed01{}).varianceValue(@Vector(4, f64)));

    const open_vec = (Open01{}).sample(rng, @Vector(4, f64));
    const direct_open_vec = (Open01{}).sampleFrom(&direct_engine, @Vector(4, f64));
    try std.testing.expectEqual(open_vec, direct_open_vec);
    inline for (0..4) |lane| try std.testing.expect(open_vec[lane] > 0 and open_vec[lane] < 1);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const open_closed_vec = (OpenClosed01{}).sample(rng, @Vector(4, f64));
    const direct_open_closed_vec = (OpenClosed01{}).sampleFrom(&direct_engine, @Vector(4, f64));
    try std.testing.expectEqual(open_closed_vec, direct_open_closed_vec);
    inline for (0..4) |lane| try std.testing.expect(open_closed_vec[lane] > 0 and open_closed_vec[lane] <= 1);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const normal_vec = try vectorNormalChecked(rng, @Vector(4, f64), 1, 2);
    const direct_normal_vec = try vectorNormalCheckedFrom(&direct_engine, @Vector(4, f64), 1, 2);
    try std.testing.expectEqual(normal_vec, direct_normal_vec);
    inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(normal_vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_standard_normal_sampler = VectorStandardNormal(@Vector(4, f64)){};
    try std.testing.expectEqual(@as(f64, 0), vector_standard_normal_sampler.meanValue());
    try std.testing.expectEqual(@as(f64, 1), vector_standard_normal_sampler.stddevValue());
    try std.testing.expect(vector_standard_normal_sampler.minValue() == null);
    const sampled_standard_normal_vec = vector_standard_normal_sampler.sample(rng);
    const direct_sampled_standard_normal_vec = vector_standard_normal_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_standard_normal_vec, direct_sampled_standard_normal_vec);
    inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(sampled_standard_normal_vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_normal_sampler = try VectorNormal(@Vector(4, f64)).init(1, 2);
    try std.testing.expectEqual(@as(f64, 1), vector_normal_sampler.meanValue());
    try std.testing.expectEqual(@as(f64, 2), vector_normal_sampler.stddevValue());
    try std.testing.expectApproxEqAbs(@as(f64, 2), vector_normal_sampler.coefficientOfVariationValue().?, 0);
    const sampled_normal_vec = vector_normal_sampler.sample(rng);
    const direct_sampled_normal_vec = vector_normal_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_normal_vec, direct_sampled_normal_vec);
    inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(sampled_normal_vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const log_normal_vec = try vectorLogNormalChecked(rng, @Vector(4, f64), 0, 0.25);
    const direct_log_normal_vec = try vectorLogNormalCheckedFrom(&direct_engine, @Vector(4, f64), 0, 0.25);
    try std.testing.expectEqual(log_normal_vec, direct_log_normal_vec);
    inline for (0..4) |lane| try std.testing.expect(log_normal_vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_log_normal_sampler = try VectorLogNormal(@Vector(4, f64)).init(0, 0.25);
    try std.testing.expectEqual(@as(f64, 0), vector_log_normal_sampler.meanValue());
    try std.testing.expectEqual(@as(f64, 0.25), vector_log_normal_sampler.stddevValue());
    const sampled_log_normal_vec = vector_log_normal_sampler.sample(rng);
    const direct_sampled_log_normal_vec = vector_log_normal_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_log_normal_vec, direct_sampled_log_normal_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_log_normal_vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const exp_vec = try vectorExponentialChecked(rng, @Vector(8, f32), 2);
    const direct_exp_vec = try vectorExponentialCheckedFrom(&direct_engine, @Vector(8, f32), 2);
    try std.testing.expectEqual(exp_vec, direct_exp_vec);
    inline for (0..8) |lane| try std.testing.expect(exp_vec[lane] >= 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_standard_exp_sampler = VectorStandardExponential(@Vector(8, f32)){};
    try std.testing.expectEqual(@as(f32, 1), vector_standard_exp_sampler.rateValue());
    try std.testing.expectEqual(@as(f32, 0), vector_standard_exp_sampler.minValue());
    const sampled_standard_exp_vec = vector_standard_exp_sampler.sample(rng);
    const direct_sampled_standard_exp_vec = vector_standard_exp_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_standard_exp_vec, direct_sampled_standard_exp_vec);
    inline for (0..8) |lane| try std.testing.expect(sampled_standard_exp_vec[lane] >= 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_exp_sampler = try VectorExponential(@Vector(8, f32)).init(2);
    try std.testing.expectEqual(@as(f32, 2), vector_exp_sampler.rateValue());
    try std.testing.expectEqual(@as(f32, 0.5), vector_exp_sampler.inverseRateValue());
    const sampled_exp_vec = vector_exp_sampler.sample(rng);
    const direct_sampled_exp_vec = vector_exp_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_exp_vec, direct_sampled_exp_vec);
    inline for (0..8) |lane| try std.testing.expect(sampled_exp_vec[lane] >= 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var uniform_buf: [3]@Vector(4, f32) = undefined;
    var direct_uniform_buf: [3]@Vector(4, f32) = undefined;
    try fillVectorUniformChecked(rng, @Vector(4, f32), &uniform_buf, -1, 2);
    try fillVectorUniformCheckedFrom(&direct_engine, @Vector(4, f32), &direct_uniform_buf, -1, 2);
    try std.testing.expectEqualSlices(@Vector(4, f32), &uniform_buf, &direct_uniform_buf);
    for (uniform_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= -1 and vec[lane] < 2);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var inclusive_buf: [3]@Vector(4, f32) = undefined;
    var direct_inclusive_buf: [3]@Vector(4, f32) = undefined;
    try fillVectorUniformInclusiveChecked(rng, @Vector(4, f32), &inclusive_buf, -1, 2);
    try fillVectorUniformInclusiveCheckedFrom(&direct_engine, @Vector(4, f32), &direct_inclusive_buf, -1, 2);
    try std.testing.expectEqualSlices(@Vector(4, f32), &inclusive_buf, &direct_inclusive_buf);
    for (inclusive_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= -1 and vec[lane] <= 2);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    vector_uniform_sampler.fill(rng, &uniform_buf);
    vector_uniform_sampler.fillFrom(&direct_engine, &direct_uniform_buf);
    try std.testing.expectEqualSlices(@Vector(4, f32), &uniform_buf, &direct_uniform_buf);
    for (uniform_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= -1 and vec[lane] < 2);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var open_buf: [3]@Vector(8, f32) = undefined;
    var direct_open_buf: [3]@Vector(8, f32) = undefined;
    (Open01{}).fill(rng, @Vector(8, f32), &open_buf);
    (Open01{}).fillFrom(&direct_engine, @Vector(8, f32), &direct_open_buf);
    try std.testing.expectEqualSlices(@Vector(8, f32), &open_buf, &direct_open_buf);
    for (open_buf) |vec| inline for (0..8) |lane| try std.testing.expect(vec[lane] > 0 and vec[lane] < 1);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var open_closed_buf: [3]@Vector(8, f32) = undefined;
    var direct_open_closed_buf: [3]@Vector(8, f32) = undefined;
    (OpenClosed01{}).fill(rng, @Vector(8, f32), &open_closed_buf);
    (OpenClosed01{}).fillFrom(&direct_engine, @Vector(8, f32), &direct_open_closed_buf);
    try std.testing.expectEqualSlices(@Vector(8, f32), &open_closed_buf, &direct_open_closed_buf);
    for (open_closed_buf) |vec| inline for (0..8) |lane| try std.testing.expect(vec[lane] > 0 and vec[lane] <= 1);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var standard_normal_buf: [3]@Vector(4, f64) = undefined;
    var direct_standard_normal_buf: [3]@Vector(4, f64) = undefined;
    fillVectorStandardNormal(rng, @Vector(4, f64), &standard_normal_buf);
    fillVectorStandardNormalFrom(&direct_engine, @Vector(4, f64), &direct_standard_normal_buf);
    try std.testing.expectEqualSlices(@Vector(4, f64), &standard_normal_buf, &direct_standard_normal_buf);
    for (standard_normal_buf) |vec| inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    vector_standard_normal_sampler.fill(rng, &standard_normal_buf);
    vector_standard_normal_sampler.fillFrom(&direct_engine, &direct_standard_normal_buf);
    try std.testing.expectEqualSlices(@Vector(4, f64), &standard_normal_buf, &direct_standard_normal_buf);
    for (standard_normal_buf) |vec| inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var normal_buf: [3]@Vector(8, f32) = undefined;
    var direct_normal_buf: [3]@Vector(8, f32) = undefined;
    try fillVectorNormalChecked(rng, @Vector(8, f32), &normal_buf, 1, 2);
    try fillVectorNormalCheckedFrom(&direct_engine, @Vector(8, f32), &direct_normal_buf, 1, 2);
    try std.testing.expectEqualSlices(@Vector(8, f32), &normal_buf, &direct_normal_buf);
    for (normal_buf) |vec| inline for (0..8) |lane| try std.testing.expect(std.math.isFinite(vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var log_normal_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_log_normal_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorLogNormalChecked(rng, @Vector(4, f64), &log_normal_buf_vec, 0, 0.25);
    try fillVectorLogNormalCheckedFrom(&direct_engine, @Vector(4, f64), &direct_log_normal_buf_vec, 0, 0.25);
    try std.testing.expectEqualSlices(@Vector(4, f64), &log_normal_buf_vec, &direct_log_normal_buf_vec);
    for (log_normal_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_log_normal_sampler.fill(rng, &log_normal_buf_vec);
    vector_log_normal_sampler.fillFrom(&direct_engine, &direct_log_normal_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &log_normal_buf_vec, &direct_log_normal_buf_vec);
    for (log_normal_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const half_normal_vec = try vectorHalfNormalChecked(rng, @Vector(4, f64), 2);
    const direct_half_normal_vec = try vectorHalfNormalCheckedFrom(&direct_engine, @Vector(4, f64), 2);
    try std.testing.expectEqual(half_normal_vec, direct_half_normal_vec);
    inline for (0..4) |lane| try std.testing.expect(half_normal_vec[lane] >= 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_half_normal_sampler = try VectorHalfNormal(@Vector(4, f64)).init(2);
    try std.testing.expectEqual(@as(f64, 2), vector_half_normal_sampler.scaleValue());
    try std.testing.expectApproxEqAbs(@as(f64, 2) * @sqrt(2.0 / std.math.pi), vector_half_normal_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4) * (1 - 2.0 / std.math.pi), vector_half_normal_sampler.varianceValue(), 1e-12);
    try std.testing.expectEqual(@as(f64, 0), vector_half_normal_sampler.minValue());
    try std.testing.expect(vector_half_normal_sampler.maxValue() == null);
    const sampled_half_normal_vec = vector_half_normal_sampler.sample(rng);
    const direct_sampled_half_normal_vec = vector_half_normal_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_half_normal_vec, direct_sampled_half_normal_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_half_normal_vec[lane] >= 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var half_normal_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_half_normal_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorHalfNormalChecked(rng, @Vector(4, f64), &half_normal_buf_vec, 2);
    try fillVectorHalfNormalCheckedFrom(&direct_engine, @Vector(4, f64), &direct_half_normal_buf_vec, 2);
    try std.testing.expectEqualSlices(@Vector(4, f64), &half_normal_buf_vec, &direct_half_normal_buf_vec);
    for (half_normal_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_half_normal_sampler.fill(rng, &half_normal_buf_vec);
    vector_half_normal_sampler.fillFrom(&direct_engine, &direct_half_normal_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &half_normal_buf_vec, &direct_half_normal_buf_vec);
    for (half_normal_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const gamma_vec = try vectorGammaChecked(rng, @Vector(4, f64), 2, 3);
    const direct_gamma_vec = try vectorGammaCheckedFrom(&direct_engine, @Vector(4, f64), 2, 3);
    try std.testing.expectEqual(gamma_vec, direct_gamma_vec);
    inline for (0..4) |lane| try std.testing.expect(gamma_vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_gamma_sampler = try VectorGamma(@Vector(4, f64)).init(2, 3);
    try std.testing.expectApproxEqAbs(@as(f64, 2), vector_gamma_sampler.shapeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), vector_gamma_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 6), vector_gamma_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 18), vector_gamma_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), vector_gamma_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_gamma_sampler.minValue(), 0);
    try std.testing.expect(vector_gamma_sampler.maxValue() == null);
    const sampled_gamma_vec = vector_gamma_sampler.sample(rng);
    const direct_sampled_gamma_vec = vector_gamma_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_gamma_vec, direct_sampled_gamma_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_gamma_vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var gamma_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_gamma_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorGammaChecked(rng, @Vector(4, f64), &gamma_buf_vec, 2, 3);
    try fillVectorGammaCheckedFrom(&direct_engine, @Vector(4, f64), &direct_gamma_buf_vec, 2, 3);
    try std.testing.expectEqualSlices(@Vector(4, f64), &gamma_buf_vec, &direct_gamma_buf_vec);
    for (gamma_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_gamma_sampler.fill(rng, &gamma_buf_vec);
    vector_gamma_sampler.fillFrom(&direct_engine, &direct_gamma_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &gamma_buf_vec, &direct_gamma_buf_vec);
    for (gamma_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const chi_squared_vec = try vectorChiSquaredChecked(rng, @Vector(4, f64), 4);
    const direct_chi_squared_vec = try vectorChiSquaredCheckedFrom(&direct_engine, @Vector(4, f64), 4);
    try std.testing.expectEqual(chi_squared_vec, direct_chi_squared_vec);
    inline for (0..4) |lane| try std.testing.expect(chi_squared_vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_chi_squared_sampler = try VectorChiSquared(@Vector(4, f64)).init(4);
    try std.testing.expectApproxEqAbs(@as(f64, 4), vector_chi_squared_sampler.dofValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4), vector_chi_squared_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 8), vector_chi_squared_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), vector_chi_squared_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_chi_squared_sampler.minValue(), 0);
    try std.testing.expect(vector_chi_squared_sampler.maxValue() == null);
    const sampled_chi_squared_vec = vector_chi_squared_sampler.sample(rng);
    const direct_sampled_chi_squared_vec = vector_chi_squared_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_chi_squared_vec, direct_sampled_chi_squared_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_chi_squared_vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var chi_squared_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_chi_squared_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorChiSquaredChecked(rng, @Vector(4, f64), &chi_squared_buf_vec, 4);
    try fillVectorChiSquaredCheckedFrom(&direct_engine, @Vector(4, f64), &direct_chi_squared_buf_vec, 4);
    try std.testing.expectEqualSlices(@Vector(4, f64), &chi_squared_buf_vec, &direct_chi_squared_buf_vec);
    for (chi_squared_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_chi_squared_sampler.fill(rng, &chi_squared_buf_vec);
    vector_chi_squared_sampler.fillFrom(&direct_engine, &direct_chi_squared_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &chi_squared_buf_vec, &direct_chi_squared_buf_vec);
    for (chi_squared_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const chi_vec = try vectorChiChecked(rng, @Vector(4, f64), 4);
    const direct_chi_vec = try vectorChiCheckedFrom(&direct_engine, @Vector(4, f64), 4);
    try std.testing.expectEqual(chi_vec, direct_chi_vec);
    inline for (0..4) |lane| try std.testing.expect(chi_vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_chi_sampler = try VectorChi(@Vector(4, f64)).init(4);
    try std.testing.expectApproxEqAbs(@as(f64, 4), vector_chi_sampler.dofValue(), 1e-12);
    try std.testing.expect(vector_chi_sampler.expectedValue() > 0);
    try std.testing.expect(vector_chi_sampler.varianceValue() > 0);
    try std.testing.expectApproxEqAbs(@sqrt(@as(f64, 3)), vector_chi_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_chi_sampler.minValue(), 0);
    try std.testing.expect(vector_chi_sampler.maxValue() == null);
    const sampled_chi_vec = vector_chi_sampler.sample(rng);
    const direct_sampled_chi_vec = vector_chi_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_chi_vec, direct_sampled_chi_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_chi_vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var chi_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_chi_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorChiChecked(rng, @Vector(4, f64), &chi_buf_vec, 4);
    try fillVectorChiCheckedFrom(&direct_engine, @Vector(4, f64), &direct_chi_buf_vec, 4);
    try std.testing.expectEqualSlices(@Vector(4, f64), &chi_buf_vec, &direct_chi_buf_vec);
    for (chi_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_chi_sampler.fill(rng, &chi_buf_vec);
    vector_chi_sampler.fillFrom(&direct_engine, &direct_chi_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &chi_buf_vec, &direct_chi_buf_vec);
    for (chi_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const erlang_vec = try vectorErlangChecked(rng, @Vector(4, f64), 3, 2);
    const direct_erlang_vec = try vectorErlangCheckedFrom(&direct_engine, @Vector(4, f64), 3, 2);
    try std.testing.expectEqual(erlang_vec, direct_erlang_vec);
    inline for (0..4) |lane| try std.testing.expect(erlang_vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_erlang_sampler = try VectorErlang(@Vector(4, f64)).init(3, 2);
    try std.testing.expectEqual(@as(u64, 3), vector_erlang_sampler.shapeValue());
    try std.testing.expectApproxEqAbs(@as(f64, 2), vector_erlang_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 6), vector_erlang_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 12), vector_erlang_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4), vector_erlang_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_erlang_sampler.minValue(), 0);
    try std.testing.expect(vector_erlang_sampler.maxValue() == null);
    const sampled_erlang_vec = vector_erlang_sampler.sample(rng);
    const direct_sampled_erlang_vec = vector_erlang_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_erlang_vec, direct_sampled_erlang_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_erlang_vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var erlang_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_erlang_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorErlangChecked(rng, @Vector(4, f64), &erlang_buf_vec, 3, 2);
    try fillVectorErlangCheckedFrom(&direct_engine, @Vector(4, f64), &direct_erlang_buf_vec, 3, 2);
    try std.testing.expectEqualSlices(@Vector(4, f64), &erlang_buf_vec, &direct_erlang_buf_vec);
    for (erlang_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_erlang_sampler.fill(rng, &erlang_buf_vec);
    vector_erlang_sampler.fillFrom(&direct_engine, &direct_erlang_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &erlang_buf_vec, &direct_erlang_buf_vec);
    for (erlang_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const beta_vec = try vectorBetaChecked(rng, @Vector(4, f64), 2, 5);
    const direct_beta_vec = try vectorBetaCheckedFrom(&direct_engine, @Vector(4, f64), 2, 5);
    try std.testing.expectEqual(beta_vec, direct_beta_vec);
    inline for (0..4) |lane| try std.testing.expect(beta_vec[lane] >= 0 and beta_vec[lane] <= 1);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_beta_sampler = try VectorBeta(@Vector(4, f64)).init(2, 5);
    try std.testing.expectApproxEqAbs(@as(f64, 2), vector_beta_sampler.alphaValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5), vector_beta_sampler.betaValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0 / 7.0), vector_beta_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5.0 / 196.0), vector_beta_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.2), vector_beta_sampler.modeValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_beta_sampler.minValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1), vector_beta_sampler.maxValue(), 0);
    const sampled_beta_vec = vector_beta_sampler.sample(rng);
    const direct_sampled_beta_vec = vector_beta_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_beta_vec, direct_sampled_beta_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_beta_vec[lane] >= 0 and sampled_beta_vec[lane] <= 1);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var beta_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_beta_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorBetaChecked(rng, @Vector(4, f64), &beta_buf_vec, 2, 5);
    try fillVectorBetaCheckedFrom(&direct_engine, @Vector(4, f64), &direct_beta_buf_vec, 2, 5);
    try std.testing.expectEqualSlices(@Vector(4, f64), &beta_buf_vec, &direct_beta_buf_vec);
    for (beta_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= 0 and vec[lane] <= 1);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_beta_sampler.fill(rng, &beta_buf_vec);
    vector_beta_sampler.fillFrom(&direct_engine, &direct_beta_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &beta_buf_vec, &direct_beta_buf_vec);
    for (beta_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= 0 and vec[lane] <= 1);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const fisher_vec = try vectorFisherFChecked(rng, @Vector(4, f64), 5, 20);
    const direct_fisher_vec = try vectorFisherFCheckedFrom(&direct_engine, @Vector(4, f64), 5, 20);
    try std.testing.expectEqual(fisher_vec, direct_fisher_vec);
    inline for (0..4) |lane| try std.testing.expect(fisher_vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_fisher_sampler = try VectorFisherF(@Vector(4, f64)).init(5, 20);
    try std.testing.expectApproxEqAbs(@as(f64, 5), vector_fisher_sampler.d1Value(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 20), vector_fisher_sampler.d2Value(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 10.0 / 9.0), vector_fisher_sampler.expectedValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 115.0 / 162.0), vector_fisher_sampler.varianceValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_fisher_sampler.minValue(), 0);
    try std.testing.expect(vector_fisher_sampler.maxValue() == null);
    const sampled_fisher_vec = vector_fisher_sampler.sample(rng);
    const direct_sampled_fisher_vec = vector_fisher_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_fisher_vec, direct_sampled_fisher_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_fisher_vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var fisher_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_fisher_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorFisherFChecked(rng, @Vector(4, f64), &fisher_buf_vec, 5, 20);
    try fillVectorFisherFCheckedFrom(&direct_engine, @Vector(4, f64), &direct_fisher_buf_vec, 5, 20);
    try std.testing.expectEqualSlices(@Vector(4, f64), &fisher_buf_vec, &direct_fisher_buf_vec);
    for (fisher_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_fisher_sampler.fill(rng, &fisher_buf_vec);
    vector_fisher_sampler.fillFrom(&direct_engine, &direct_fisher_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &fisher_buf_vec, &direct_fisher_buf_vec);
    for (fisher_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const student_vec = try vectorStudentTChecked(rng, @Vector(4, f64), 10);
    const direct_student_vec = try vectorStudentTCheckedFrom(&direct_engine, @Vector(4, f64), 10);
    try std.testing.expectEqual(student_vec, direct_student_vec);
    inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(student_vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_student_sampler = try VectorStudentT(@Vector(4, f64)).init(10);
    try std.testing.expectApproxEqAbs(@as(f64, 10), vector_student_sampler.dofValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_student_sampler.expectedValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.25), vector_student_sampler.varianceValue().?, 1e-12);
    try std.testing.expect(vector_student_sampler.minValue() == null);
    try std.testing.expect(vector_student_sampler.maxValue() == null);
    const sampled_student_vec = vector_student_sampler.sample(rng);
    const direct_sampled_student_vec = vector_student_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_student_vec, direct_sampled_student_vec);
    inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(sampled_student_vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var student_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_student_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorStudentTChecked(rng, @Vector(4, f64), &student_buf_vec, 10);
    try fillVectorStudentTCheckedFrom(&direct_engine, @Vector(4, f64), &direct_student_buf_vec, 10);
    try std.testing.expectEqualSlices(@Vector(4, f64), &student_buf_vec, &direct_student_buf_vec);
    for (student_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_student_sampler.fill(rng, &student_buf_vec);
    vector_student_sampler.fillFrom(&direct_engine, &direct_student_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &student_buf_vec, &direct_student_buf_vec);
    for (student_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const triangular_vec = try vectorTriangularChecked(rng, @Vector(4, f64), -1, 0, 2);
    const direct_triangular_vec = try vectorTriangularCheckedFrom(&direct_engine, @Vector(4, f64), -1, 0, 2);
    try std.testing.expectEqual(triangular_vec, direct_triangular_vec);
    inline for (0..4) |lane| try std.testing.expect(triangular_vec[lane] >= -1 and triangular_vec[lane] <= 2);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_triangular_sampler = try VectorTriangular(@Vector(4, f64)).init(-1, 0, 2);
    try std.testing.expectApproxEqAbs(@as(f64, -1), vector_triangular_sampler.minValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_triangular_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), vector_triangular_sampler.maxValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 3.0), vector_triangular_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 7.0 / 18.0), vector_triangular_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(2.0 - @sqrt(@as(f64, 3)), vector_triangular_sampler.medianValue(), 1e-12);
    const sampled_triangular_vec = vector_triangular_sampler.sample(rng);
    const direct_sampled_triangular_vec = vector_triangular_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_triangular_vec, direct_sampled_triangular_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_triangular_vec[lane] >= -1 and sampled_triangular_vec[lane] <= 2);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var triangular_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_triangular_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorTriangularChecked(rng, @Vector(4, f64), &triangular_buf_vec, -1, 0, 2);
    try fillVectorTriangularCheckedFrom(&direct_engine, @Vector(4, f64), &direct_triangular_buf_vec, -1, 0, 2);
    try std.testing.expectEqualSlices(@Vector(4, f64), &triangular_buf_vec, &direct_triangular_buf_vec);
    for (triangular_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= -1 and vec[lane] <= 2);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_triangular_sampler.fill(rng, &triangular_buf_vec);
    vector_triangular_sampler.fillFrom(&direct_engine, &direct_triangular_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &triangular_buf_vec, &direct_triangular_buf_vec);
    for (triangular_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= -1 and vec[lane] <= 2);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const arcsine_vec = try vectorArcsineChecked(rng, @Vector(4, f64), -1, 3);
    const direct_arcsine_vec = try vectorArcsineCheckedFrom(&direct_engine, @Vector(4, f64), -1, 3);
    try std.testing.expectEqual(arcsine_vec, direct_arcsine_vec);
    inline for (0..4) |lane| try std.testing.expect(arcsine_vec[lane] >= -1 and arcsine_vec[lane] <= 3);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_arcsine_sampler = try VectorArcsine(@Vector(4, f64)).init(-1, 3);
    try std.testing.expectApproxEqAbs(@as(f64, -1), vector_arcsine_sampler.minValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), vector_arcsine_sampler.maxValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), vector_arcsine_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), vector_arcsine_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), vector_arcsine_sampler.medianValue(), 1e-12);
    const sampled_arcsine_vec = vector_arcsine_sampler.sample(rng);
    const direct_sampled_arcsine_vec = vector_arcsine_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_arcsine_vec, direct_sampled_arcsine_vec);
    inline for (0..4) |lane| try std.testing.expect(sampled_arcsine_vec[lane] >= -1 and sampled_arcsine_vec[lane] <= 3);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var arcsine_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_arcsine_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorArcsineChecked(rng, @Vector(4, f64), &arcsine_buf_vec, -1, 3);
    try fillVectorArcsineCheckedFrom(&direct_engine, @Vector(4, f64), &direct_arcsine_buf_vec, -1, 3);
    try std.testing.expectEqualSlices(@Vector(4, f64), &arcsine_buf_vec, &direct_arcsine_buf_vec);
    for (arcsine_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= -1 and vec[lane] <= 3);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_arcsine_sampler.fill(rng, &arcsine_buf_vec);
    vector_arcsine_sampler.fillFrom(&direct_engine, &direct_arcsine_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &arcsine_buf_vec, &direct_arcsine_buf_vec);
    for (arcsine_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= -1 and vec[lane] <= 3);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const cauchy_vec = try vectorCauchyChecked(rng, @Vector(4, f64), 0, 1);
    const direct_cauchy_vec = try vectorCauchyCheckedFrom(&direct_engine, @Vector(4, f64), 0, 1);
    try std.testing.expectEqual(cauchy_vec, direct_cauchy_vec);
    inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(cauchy_vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_cauchy_sampler = try VectorCauchy(@Vector(4, f64)).init(0, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_cauchy_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_cauchy_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), vector_cauchy_sampler.scaleValue(), 1e-12);
    try std.testing.expect(vector_cauchy_sampler.expectedValue() == null);
    try std.testing.expect(vector_cauchy_sampler.varianceValue() == null);
    try std.testing.expect(vector_cauchy_sampler.minValue() == null);
    try std.testing.expect(vector_cauchy_sampler.maxValue() == null);
    const sampled_cauchy_vec = vector_cauchy_sampler.sample(rng);
    const direct_sampled_cauchy_vec = vector_cauchy_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_cauchy_vec, direct_sampled_cauchy_vec);
    inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(sampled_cauchy_vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var cauchy_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_cauchy_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorCauchyChecked(rng, @Vector(4, f64), &cauchy_buf_vec, 0, 1);
    try fillVectorCauchyCheckedFrom(&direct_engine, @Vector(4, f64), &direct_cauchy_buf_vec, 0, 1);
    try std.testing.expectEqualSlices(@Vector(4, f64), &cauchy_buf_vec, &direct_cauchy_buf_vec);
    for (cauchy_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_cauchy_sampler.fill(rng, &cauchy_buf_vec);
    vector_cauchy_sampler.fillFrom(&direct_engine, &direct_cauchy_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &cauchy_buf_vec, &direct_cauchy_buf_vec);
    for (cauchy_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const laplace_vec = try vectorLaplaceChecked(rng, @Vector(4, f64), 0, 1);
    const direct_laplace_vec = try vectorLaplaceCheckedFrom(&direct_engine, @Vector(4, f64), 0, 1);
    try std.testing.expectEqual(laplace_vec, direct_laplace_vec);
    inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(laplace_vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    const vector_laplace_sampler = try VectorLaplace(@Vector(4, f64)).init(0, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_laplace_sampler.locationValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), vector_laplace_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_laplace_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_laplace_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_laplace_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), vector_laplace_sampler.varianceValue(), 1e-12);
    try std.testing.expect(vector_laplace_sampler.minValue() == null);
    try std.testing.expect(vector_laplace_sampler.maxValue() == null);
    const sampled_laplace_vec = vector_laplace_sampler.sample(rng);
    const direct_sampled_laplace_vec = vector_laplace_sampler.sampleFrom(&direct_engine);
    try std.testing.expectEqual(sampled_laplace_vec, direct_sampled_laplace_vec);
    inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(sampled_laplace_vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var laplace_buf_vec: [3]@Vector(4, f64) = undefined;
    var direct_laplace_buf_vec: [3]@Vector(4, f64) = undefined;
    try fillVectorLaplaceChecked(rng, @Vector(4, f64), &laplace_buf_vec, 0, 1);
    try fillVectorLaplaceCheckedFrom(&direct_engine, @Vector(4, f64), &direct_laplace_buf_vec, 0, 1);
    try std.testing.expectEqualSlices(@Vector(4, f64), &laplace_buf_vec, &direct_laplace_buf_vec);
    for (laplace_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    vector_laplace_sampler.fill(rng, &laplace_buf_vec);
    vector_laplace_sampler.fillFrom(&direct_engine, &direct_laplace_buf_vec);
    try std.testing.expectEqualSlices(@Vector(4, f64), &laplace_buf_vec, &direct_laplace_buf_vec);
    for (laplace_buf_vec) |vec| inline for (0..4) |lane| try std.testing.expect(std.math.isFinite(vec[lane]));
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var standard_exp_buf: [3]@Vector(4, f64) = undefined;
    var direct_standard_exp_buf: [3]@Vector(4, f64) = undefined;
    fillVectorStandardExponential(rng, @Vector(4, f64), &standard_exp_buf);
    fillVectorStandardExponentialFrom(&direct_engine, @Vector(4, f64), &direct_standard_exp_buf);
    try std.testing.expectEqualSlices(@Vector(4, f64), &standard_exp_buf, &direct_standard_exp_buf);
    for (standard_exp_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] >= 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    var exp_buf: [3]@Vector(8, f32) = undefined;
    var direct_exp_buf: [3]@Vector(8, f32) = undefined;
    try fillVectorExponentialChecked(rng, @Vector(8, f32), &exp_buf, 2);
    try fillVectorExponentialCheckedFrom(&direct_engine, @Vector(8, f32), &direct_exp_buf, 2);
    try std.testing.expectEqualSlices(@Vector(8, f32), &exp_buf, &direct_exp_buf);
    for (exp_buf) |vec| inline for (0..8) |lane| try std.testing.expect(vec[lane] >= 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

    vector_exp_sampler.fill(rng, &exp_buf);
    vector_exp_sampler.fillFrom(&direct_engine, &direct_exp_buf);
    try std.testing.expectEqualSlices(@Vector(8, f32), &exp_buf, &direct_exp_buf);
    for (exp_buf) |vec| inline for (0..8) |lane| try std.testing.expect(vec[lane] >= 0);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
}

test "invalid distribution vector helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1e7);
    var control = alea.ScalarPrng.init(0x5150_d1e7);

    try std.testing.expectError(error.InvalidProbability, vectorBernoulliCheckedFrom(&engine, @Vector(8, bool), -0.1));
    try std.testing.expectEqual(control.next(), engine.next());

    var bool_buf: [4]@Vector(8, bool) = undefined;
    try std.testing.expectError(error.InvalidProbability, fillVectorBernoulliCheckedFrom(&engine, @Vector(8, bool), &bool_buf, -0.1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, vectorBinomialCheckedFrom(&engine, @Vector(4, u64), 10, 1.1));
    try std.testing.expectEqual(control.next(), engine.next());

    var binomial_buf: [4]@Vector(4, u64) = undefined;
    try std.testing.expectError(error.InvalidProbability, fillVectorBinomialCheckedFrom(&engine, @Vector(4, u64), &binomial_buf, 10, 1.1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorNegativeBinomialCheckedFrom(&engine, @Vector(4, u64), 0, 0.25));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, vectorNegativeBinomialCheckedFrom(&engine, @Vector(4, u64), 5, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    var negative_binomial_buf: [4]@Vector(4, u64) = undefined;
    try std.testing.expectError(error.InvalidProbability, fillVectorNegativeBinomialCheckedFrom(&engine, @Vector(4, u64), &negative_binomial_buf, 5, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorHypergeometricCheckedFrom(&engine, @Vector(4, u64), 10, 11, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    var hypergeometric_buf: [4]@Vector(4, u64) = undefined;
    try std.testing.expectError(error.InvalidParameter, fillVectorHypergeometricCheckedFrom(&engine, @Vector(4, u64), &hypergeometric_buf, 10, 11, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, vectorGeometricCheckedFrom(&engine, @Vector(4, u64), 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, vectorGeometricFailuresCheckedFrom(&engine, @Vector(4, u64), 0));
    try std.testing.expectEqual(control.next(), engine.next());

    var geometric_buf: [4]@Vector(4, u64) = undefined;
    try std.testing.expectError(error.InvalidProbability, fillVectorGeometricCheckedFrom(&engine, @Vector(4, u64), &geometric_buf, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, fillVectorGeometricFailuresCheckedFrom(&engine, @Vector(4, u64), &geometric_buf, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorPoissonCheckedFrom(&engine, @Vector(4, u64), std.math.inf(f64)));
    try std.testing.expectEqual(control.next(), engine.next());

    var poisson_buf: [4]@Vector(4, u64) = undefined;
    try std.testing.expectError(error.InvalidParameter, fillVectorPoissonCheckedFrom(&engine, @Vector(4, u64), &poisson_buf, std.math.inf(f64)));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, vectorUniformCheckedFrom(&engine, @Vector(4, f64), std.math.inf(f64), 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, vectorUniformInclusiveCheckedFrom(&engine, @Vector(4, u16), 4, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorNormalCheckedFrom(&engine, @Vector(4, f64), 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorLogNormalCheckedFrom(&engine, @Vector(4, f64), 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorHalfNormalCheckedFrom(&engine, @Vector(4, f64), 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorGammaCheckedFrom(&engine, @Vector(4, f64), 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorChiSquaredCheckedFrom(&engine, @Vector(4, f64), 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorChiCheckedFrom(&engine, @Vector(4, f64), 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorErlangCheckedFrom(&engine, @Vector(4, f64), 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorBetaCheckedFrom(&engine, @Vector(4, f64), 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorFisherFCheckedFrom(&engine, @Vector(4, f64), 0, 20));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorStudentTCheckedFrom(&engine, @Vector(4, f64), 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorTriangularCheckedFrom(&engine, @Vector(4, f64), 1, 0, 2));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorArcsineCheckedFrom(&engine, @Vector(4, f64), 1, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorCauchyCheckedFrom(&engine, @Vector(4, f64), 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorLaplaceCheckedFrom(&engine, @Vector(4, f64), 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorExponentialCheckedFrom(&engine, @Vector(4, f64), 0));
    try std.testing.expectEqual(control.next(), engine.next());

    var uniform_buf: [4]@Vector(4, f64) = undefined;
    try std.testing.expectError(error.EmptyRange, fillVectorUniformCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, std.math.inf(f64), 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, fillVectorUniformInclusiveCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, std.math.inf(f64), 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorNormalCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorLogNormalCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorHalfNormalCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorGammaCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorChiSquaredCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorChiCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorErlangCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorBetaCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorFisherFCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0, 20));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorStudentTCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorTriangularCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 1, 0, 2));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorArcsineCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 1, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorCauchyCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorLaplaceCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillVectorExponentialCheckedFrom(&engine, @Vector(4, f64), &uniform_buf, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "zero-length distribution vector fills do not validate or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1e8);
    var control = alea.ScalarPrng.init(0x5150_d1e8);
    const rng = Rng.init(&engine);

    var empty: [0]@Vector(4, f64) = .{};
    var empty_bool: [0]@Vector(8, bool) = .{};
    var empty_poisson: [0]@Vector(4, u64) = .{};
    var empty_binomial: [0]@Vector(4, u64) = .{};
    var empty_geometric: [0]@Vector(4, u64) = .{};
    var empty_negative_binomial: [0]@Vector(4, u64) = .{};
    var empty_hypergeometric: [0]@Vector(4, u64) = .{};

    try fillVectorHypergeometricCheckedFrom(&engine, @Vector(4, u64), &empty_hypergeometric, 10, 11, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorHypergeometricChecked(rng, @Vector(4, u64), &empty_hypergeometric, 10, 11, 1);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillVectorNegativeBinomialCheckedFrom(&engine, @Vector(4, u64), &empty_negative_binomial, 0, 0.25);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorNegativeBinomialChecked(rng, @Vector(4, u64), &empty_negative_binomial, 5, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillVectorGeometricCheckedFrom(&engine, @Vector(4, u64), &empty_geometric, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorGeometricChecked(rng, @Vector(4, u64), &empty_geometric, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorGeometricFailuresCheckedFrom(&engine, @Vector(4, u64), &empty_geometric, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorGeometricFailuresChecked(rng, @Vector(4, u64), &empty_geometric, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillVectorBinomialCheckedFrom(&engine, @Vector(4, u64), &empty_binomial, 10, 1.1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorBinomialChecked(rng, @Vector(4, u64), &empty_binomial, 10, 1.1);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillVectorPoissonCheckedFrom(&engine, @Vector(4, u64), &empty_poisson, std.math.inf(f64));
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorPoissonChecked(rng, @Vector(4, u64), &empty_poisson, std.math.inf(f64));
    try std.testing.expectEqual(control.next(), engine.next());

    try fillVectorBernoulliCheckedFrom(&engine, @Vector(8, bool), &empty_bool, -0.1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorBernoulliChecked(rng, @Vector(8, bool), &empty_bool, -0.1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorUniformCheckedFrom(&engine, @Vector(4, f64), &empty, std.math.inf(f64), 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorUniformInclusiveCheckedFrom(&engine, @Vector(4, f64), &empty, std.math.inf(f64), 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorNormalCheckedFrom(&engine, @Vector(4, f64), &empty, 0, -1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorLogNormalCheckedFrom(&engine, @Vector(4, f64), &empty, 0, -1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorHalfNormalCheckedFrom(&engine, @Vector(4, f64), &empty, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorGammaCheckedFrom(&engine, @Vector(4, f64), &empty, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorChiSquaredCheckedFrom(&engine, @Vector(4, f64), &empty, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorChiCheckedFrom(&engine, @Vector(4, f64), &empty, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorErlangCheckedFrom(&engine, @Vector(4, f64), &empty, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorBetaCheckedFrom(&engine, @Vector(4, f64), &empty, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorFisherFCheckedFrom(&engine, @Vector(4, f64), &empty, 0, 20);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorStudentTCheckedFrom(&engine, @Vector(4, f64), &empty, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorTriangularCheckedFrom(&engine, @Vector(4, f64), &empty, 1, 0, 2);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorArcsineCheckedFrom(&engine, @Vector(4, f64), &empty, 1, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorCauchyCheckedFrom(&engine, @Vector(4, f64), &empty, 0, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorLaplaceCheckedFrom(&engine, @Vector(4, f64), &empty, 0, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorExponentialCheckedFrom(&engine, @Vector(4, f64), &empty, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorUniformChecked(rng, @Vector(4, f64), &empty, std.math.inf(f64), 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorUniformInclusiveChecked(rng, @Vector(4, f64), &empty, std.math.inf(f64), 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorNormalChecked(rng, @Vector(4, f64), &empty, 0, -1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorLogNormalChecked(rng, @Vector(4, f64), &empty, 0, -1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorHalfNormalChecked(rng, @Vector(4, f64), &empty, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorGammaChecked(rng, @Vector(4, f64), &empty, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorChiSquaredChecked(rng, @Vector(4, f64), &empty, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorChiChecked(rng, @Vector(4, f64), &empty, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorErlangChecked(rng, @Vector(4, f64), &empty, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorBetaChecked(rng, @Vector(4, f64), &empty, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorFisherFChecked(rng, @Vector(4, f64), &empty, 0, 20);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorStudentTChecked(rng, @Vector(4, f64), &empty, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorTriangularChecked(rng, @Vector(4, f64), &empty, 1, 0, 2);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorArcsineChecked(rng, @Vector(4, f64), &empty, 1, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorCauchyChecked(rng, @Vector(4, f64), &empty, 0, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorLaplaceChecked(rng, @Vector(4, f64), &empty, 0, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorExponentialChecked(rng, @Vector(4, f64), &empty, 0);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid probability distribution fills do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1f3);
    var control = alea.ScalarPrng.init(0x5150_d1f3);

    var bools: [4]bool = undefined;
    try std.testing.expectError(error.InvalidProbability, fillBernoulliCheckedFrom(&engine, &bools, -0.1));
    try std.testing.expectEqual(control.next(), engine.next());

    var ints: [4]u64 = undefined;
    try std.testing.expectError(error.InvalidProbability, fillBinomialCheckedFrom(&engine, &ints, 10, 1.1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, fillNegativeBinomialCheckedFrom(&engine, &ints, 5, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, fillGeometricFailuresCheckedFrom(&engine, &ints, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, fillGeometricCheckedFrom(&engine, &ints, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid distribution facade misc scalars do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1fd1);
    var control = alea.ScalarPrng.init(0x5150_d1fd1);
    const rng = Rng.init(&engine);

    try std.testing.expectError(error.EmptyRange, uniformChecked(rng, u32, 9, 5));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, uniformInclusiveChecked(rng, f64, std.math.inf(f64), 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, poissonChecked(rng, std.math.inf(f64)));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, poissonAhrensDieterChecked(rng, 11));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, geometricFailuresChecked(rng, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, zetaChecked(rng, f64, 1));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid distribution facade discrete scalars do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1fd);
    var control = alea.ScalarPrng.init(0x5150_d1fd);
    const rng = Rng.init(&engine);

    try std.testing.expectError(error.InvalidProbability, bernoulliChecked(rng, -0.1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, binomialChecked(rng, 10, 1.1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, negativeBinomialChecked(rng, 5, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, hypergeometricChecked(rng, 10, 11, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, geometricChecked(rng, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid distribution facade continuous scalars do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1fe);
    var control = alea.ScalarPrng.init(0x5150_d1fe);
    const rng = Rng.init(&engine);

    try std.testing.expectError(error.InvalidParameter, logNormalChecked(rng, f64, 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, halfNormalChecked(rng, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, gammaChecked(rng, f64, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, chiSquaredChecked(rng, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, chiChecked(rng, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, erlangChecked(rng, f64, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, betaChecked(rng, f64, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fisherFChecked(rng, f64, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, studentTChecked(rng, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid distribution facade tail scalars do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1ff);
    var control = alea.ScalarPrng.init(0x5150_d1ff);
    const rng = Rng.init(&engine);

    try std.testing.expectError(error.InvalidParameter, cauchyChecked(rng, f64, 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, triangularChecked(rng, f64, 1, 0, 2));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, arcsineChecked(rng, f64, 1, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, laplaceChecked(rng, f64, 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, paretoChecked(rng, f64, 0, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, logLogisticChecked(rng, f64, 0, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, kumaraswamyChecked(rng, f64, 0, 5));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, powerFunctionChecked(rng, f64, -1, 2, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, rayleighChecked(rng, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, maxwellChecked(rng, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, weibullChecked(rng, f64, 0, 1.5));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, gumbelChecked(rng, f64, 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, frechetChecked(rng, f64, 0, 1, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, skewNormalChecked(rng, f64, 0, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, pertChecked(rng, f64, 0, 2, 1, 4));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, inverseGaussianChecked(rng, f64, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, normalInverseGaussianChecked(rng, f64, 1, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, zipfChecked(rng, f64, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid distribution facade fill helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1fc);
    var control = alea.ScalarPrng.init(0x5150_d1fc);
    const rng = Rng.init(&engine);

    var bools: [4]bool = undefined;
    try std.testing.expectError(error.InvalidProbability, fillBernoulliChecked(rng, &bools, -0.1));
    try std.testing.expectEqual(control.next(), engine.next());

    var int_counts: [4]u64 = undefined;
    try std.testing.expectError(error.InvalidProbability, fillBinomialChecked(rng, &int_counts, 10, 1.1));
    try std.testing.expectEqual(control.next(), engine.next());

    var ints: [4]u32 = undefined;
    try std.testing.expectError(error.EmptyRange, fillUniformChecked(rng, u32, &ints, 9, 5));
    try std.testing.expectEqual(control.next(), engine.next());

    var floats: [4]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillGammaChecked(rng, f64, &floats, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillLogNormalChecked(rng, f64, &floats, 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    var floats32: [4]f32 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillLogNormalApproxF32Checked(rng, &floats32, 0, 0.5));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillHalfNormalChecked(rng, f64, &floats, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillChiSquaredChecked(rng, f64, &floats, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillChiChecked(rng, f64, &floats, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillErlangChecked(rng, f64, &floats, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillBetaChecked(rng, f64, &floats, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillFisherFChecked(rng, f64, &floats, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillStudentTChecked(rng, f64, &floats, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillLogisticChecked(rng, f64, &floats, 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid distribution facade tail fills do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1fc1);
    var control = alea.ScalarPrng.init(0x5150_d1fc1);
    const rng = Rng.init(&engine);

    var out: [4]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillParetoChecked(rng, f64, &out, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillInverseGaussianChecked(rng, f64, &out, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillZetaChecked(rng, f64, &out, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillLogLogisticChecked(rng, f64, &out, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillPowerFunctionChecked(rng, f64, &out, 1, 1, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillWeibullChecked(rng, f64, &out, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillGumbelChecked(rng, f64, &out, 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillFrechetChecked(rng, f64, &out, 0, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillSkewNormalChecked(rng, f64, &out, 0, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillPertChecked(rng, f64, &out, 1, 0, 2, 4));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid distribution facade scalar helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1fb);
    var control = alea.ScalarPrng.init(0x5150_d1fb);
    const rng = Rng.init(&engine);

    try std.testing.expectError(error.InvalidParameter, normalChecked(rng, f64, 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, exponentialChecked(rng, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, logisticChecked(rng, f64, 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid uniform distribution helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1f2);
    var control = alea.ScalarPrng.init(0x5150_d1f2);

    try std.testing.expectError(error.EmptyRange, uniformCheckedFrom(&engine, u32, 9, 5));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, uniformInclusiveCheckedFrom(&engine, f64, std.math.inf(f64), 1));
    try std.testing.expectEqual(control.next(), engine.next());

    var ints: [4]u32 = undefined;
    try std.testing.expectError(error.EmptyRange, fillUniformCheckedFrom(&engine, u32, &ints, 9, 5));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, fillUniformInclusiveCheckedFrom(&engine, u32, &ints, 9, 5));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid poisson ahrens-dieter helper does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1f1);
    var control = alea.ScalarPrng.init(0x5150_d1f1);

    try std.testing.expectError(error.InvalidParameter, poissonAhrensDieterCheckedFrom(&engine, 11));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid remaining tail scalar helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1fa);
    var control = alea.ScalarPrng.init(0x5150_d1fa);

    try std.testing.expectError(error.InvalidParameter, maxwellCheckedFrom(&engine, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, paretoCheckedFrom(&engine, f64, 0, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, weibullCheckedFrom(&engine, f64, 0, 1.5));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, gumbelCheckedFrom(&engine, f64, 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, frechetCheckedFrom(&engine, f64, 0, 1, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, skewNormalCheckedFrom(&engine, f64, 0, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, pertCheckedFrom(&engine, f64, 0, 2, 1, 4));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid inverse and rank scalar helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1f9);
    var control = alea.ScalarPrng.init(0x5150_d1f9);

    try std.testing.expectError(error.InvalidParameter, inverseGaussianCheckedFrom(&engine, f64, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, normalInverseGaussianCheckedFrom(&engine, f64, 1, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, zipfCheckedFrom(&engine, f64, 0, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, zetaCheckedFrom(&engine, f64, 1));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid tail scalar helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1f8);
    var control = alea.ScalarPrng.init(0x5150_d1f8);

    try std.testing.expectError(error.InvalidParameter, logisticCheckedFrom(&engine, f64, 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, logLogisticCheckedFrom(&engine, f64, 0, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, kumaraswamyCheckedFrom(&engine, f64, 0, 5));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, powerFunctionCheckedFrom(&engine, f64, -1, 2, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, rayleighCheckedFrom(&engine, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid bounded scalar helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1f7);
    var control = alea.ScalarPrng.init(0x5150_d1f7);

    try std.testing.expectError(error.InvalidParameter, triangularCheckedFrom(&engine, f64, 1, 0, 2));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, arcsineCheckedFrom(&engine, f64, 1, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, cauchyCheckedFrom(&engine, f64, 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, laplaceCheckedFrom(&engine, f64, 0, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid core continuous scalar helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1f6);
    var control = alea.ScalarPrng.init(0x5150_d1f6);

    try std.testing.expectError(error.InvalidParameter, gammaCheckedFrom(&engine, f64, 0, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, chiSquaredCheckedFrom(&engine, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fisherFCheckedFrom(&engine, f64, 0, 20));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, studentTCheckedFrom(&engine, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid scalar distribution helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1f0);
    var control = alea.ScalarPrng.init(0x5150_d1f0);

    try std.testing.expectError(error.EmptyRange, uniformInclusiveCheckedFrom(&engine, f64, std.math.inf(f64), 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, logNormalCheckedFrom(&engine, f64, 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, logNormalApproxF32CheckedFrom(&engine, 0, 0.5));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, LogNormalApproxF32.init(0.5, 0.25));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, halfNormalCheckedFrom(&engine, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, betaCheckedFrom(&engine, f64, 1, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, zetaCheckedFrom(&engine, f64, 1));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "zero-length skew and pert fills do not validate or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1ea);
    var control = alea.ScalarPrng.init(0x5150_d1ea);
    const rng = Rng.init(&engine);

    var out: [0]f64 = .{};

    try fillSkewNormalCheckedFrom(&engine, f64, &out, 0, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillPertCheckedFrom(&engine, f64, &out, 1, 0, 2, 4);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillSkewNormalChecked(rng, f64, &out, 0, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillPertChecked(rng, f64, &out, 1, 0, 2, 4);
    try std.testing.expectEqual(control.next(), engine.next());

    var one: [1]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillSkewNormalCheckedFrom(&engine, f64, &one, 0, 0, 1));
}

test "zero-length inverse and zeta distribution fills do not validate or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1da);
    var control = alea.ScalarPrng.init(0x5150_d1da);
    const rng = Rng.init(&engine);

    var out: [0]f64 = .{};

    try fillMaxwellCheckedFrom(&engine, f64, &out, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillParetoCheckedFrom(&engine, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillWeibullCheckedFrom(&engine, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillGumbelCheckedFrom(&engine, f64, &out, 0, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillFrechetCheckedFrom(&engine, f64, &out, 0, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillInverseGaussianCheckedFrom(&engine, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillNormalInverseGaussianCheckedFrom(&engine, f64, &out, 1, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillZipfCheckedFrom(&engine, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillZetaCheckedFrom(&engine, f64, &out, 1);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillParetoChecked(rng, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillInverseGaussianChecked(rng, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillZetaChecked(rng, f64, &out, 1);
    try std.testing.expectEqual(control.next(), engine.next());

    var one: [1]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillParetoCheckedFrom(&engine, f64, &one, 0, 1));
}

test "zero-length tail distribution fills do not validate or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1ca);
    var control = alea.ScalarPrng.init(0x5150_d1ca);
    const rng = Rng.init(&engine);

    var out: [0]f64 = .{};

    try fillLogisticCheckedFrom(&engine, f64, &out, 0, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillLogLogisticCheckedFrom(&engine, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillKumaraswamyCheckedFrom(&engine, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillPowerFunctionCheckedFrom(&engine, f64, &out, 1, 1, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillRayleighCheckedFrom(&engine, f64, &out, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillLogisticChecked(rng, f64, &out, 0, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillKumaraswamyChecked(rng, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillRayleighChecked(rng, f64, &out, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    var one: [1]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillLogisticCheckedFrom(&engine, f64, &one, 0, 0));
}

test "zero-length derived distribution fills do not validate or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1ba);
    var control = alea.ScalarPrng.init(0x5150_d1ba);
    const rng = Rng.init(&engine);

    var out: [0]f64 = .{};
    var out32: [0]f32 = .{};

    try fillLogNormalCheckedFrom(&engine, f64, &out, 0, -1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillLogNormalApproxF32CheckedFrom(&engine, &out32, 0, 0.5);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillHalfNormalCheckedFrom(&engine, f64, &out, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillTriangularCheckedFrom(&engine, f64, &out, 1, 0, 2);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillArcsineCheckedFrom(&engine, f64, &out, 1, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillCauchyCheckedFrom(&engine, f64, &out, 0, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillLaplaceCheckedFrom(&engine, f64, &out, 0, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillLogNormalChecked(rng, f64, &out, 0, -1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillLogNormalApproxF32Checked(rng, &out32, 0, 0.5);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillTriangularChecked(rng, f64, &out, 1, 0, 2);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillCauchyChecked(rng, f64, &out, 0, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    var one: [1]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillCauchyCheckedFrom(&engine, f64, &one, 0, 0));
}

test "zero-length core continuous distribution fills do not validate or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d1aa);
    var control = alea.ScalarPrng.init(0x5150_d1aa);
    const rng = Rng.init(&engine);

    var out: [0]f64 = .{};

    try fillGammaCheckedFrom(&engine, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillChiSquaredCheckedFrom(&engine, f64, &out, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillChiCheckedFrom(&engine, f64, &out, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillErlangCheckedFrom(&engine, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillBetaCheckedFrom(&engine, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillFisherFCheckedFrom(&engine, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillStudentTCheckedFrom(&engine, f64, &out, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillGammaChecked(rng, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillBetaChecked(rng, f64, &out, 0, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillStudentTChecked(rng, f64, &out, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    var one: [1]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillGammaCheckedFrom(&engine, f64, &one, 0, 1));
}

test "zero-length discrete distribution fills do not validate or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d19a);
    var control = alea.ScalarPrng.init(0x5150_d19a);
    const rng = Rng.init(&engine);

    var bools: [0]bool = .{};
    var ints: [0]u64 = .{};

    try fillBernoulliCheckedFrom(&engine, &bools, -0.1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillBinomialCheckedFrom(&engine, &ints, 10, 1.1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillNegativeBinomialCheckedFrom(&engine, &ints, 0, 0.5);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillHypergeometricCheckedFrom(&engine, &ints, 10, 11, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillPoissonCheckedFrom(&engine, &ints, std.math.inf(f64));
    try std.testing.expectEqual(control.next(), engine.next());
    try fillGeometricFailuresCheckedFrom(&engine, &ints, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillGeometricCheckedFrom(&engine, &ints, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillBernoulliChecked(rng, &bools, -0.1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillPoissonChecked(rng, &ints, std.math.inf(f64));
    try std.testing.expectEqual(control.next(), engine.next());
    try fillGeometricChecked(rng, &ints, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    var one_bool: [1]bool = undefined;
    try std.testing.expectError(error.InvalidProbability, fillBernoulliCheckedFrom(&engine, &one_bool, -0.1));
}

test "zero-length base distribution fills do not validate or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d18a);
    var control = alea.ScalarPrng.init(0x5150_d18a);
    const rng = Rng.init(&engine);

    var ints: [0]u32 = .{};
    var floats: [0]f64 = .{};

    try fillUniformCheckedFrom(&engine, u32, &ints, 3, 3);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillUniformCheckedFrom(&engine, f64, &floats, std.math.inf(f64), 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillUniformInclusiveCheckedFrom(&engine, u32, &ints, 4, 3);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillUniformInclusiveCheckedFrom(&engine, f64, &floats, std.math.inf(f64), 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillNormalCheckedFrom(&engine, f64, &floats, std.math.inf(f64), 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillExponentialCheckedFrom(&engine, f64, &floats, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillUniformChecked(rng, u32, &ints, 3, 3);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillUniformInclusiveChecked(rng, u32, &ints, 4, 3);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillNormalChecked(rng, f64, &floats, 0, -1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillExponentialChecked(rng, f64, &floats, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    var one_int: [1]u32 = undefined;
    try std.testing.expectError(error.EmptyRange, fillUniformInclusiveCheckedFrom(&engine, u32, &one_int, 4, 3));
}

test "initial multivariate allocation failures do not consume random stream" {
    const alea = @import("root.zig");

    const multinomial = try Multinomial.init(20, &.{ 1.0, 2.0, 3.0 });
    var multinomial_engine = alea.ScalarPrng.init(0x5150_d16a);
    var multinomial_control = alea.ScalarPrng.init(0x5150_d16a);
    var multinomial_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, multinomial.sampleFrom(multinomial_alloc.allocator(), &multinomial_engine));
    try std.testing.expect(multinomial_alloc.has_induced_failure);
    try std.testing.expectEqual(multinomial_control.next(), multinomial_engine.next());

    var multinomial_facade_engine = alea.ScalarPrng.init(0x5150_d16b);
    var multinomial_facade_control = alea.ScalarPrng.init(0x5150_d16b);
    const multinomial_rng = Rng.init(&multinomial_facade_engine);
    var multinomial_facade_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, multinomial.sample(multinomial_facade_alloc.allocator(), multinomial_rng));
    try std.testing.expect(multinomial_facade_alloc.has_induced_failure);
    try std.testing.expectEqual(multinomial_facade_control.next(), multinomial_facade_engine.next());

    const dirichlet = try Dirichlet(f64).init(&.{ 1.0, 2.0, 3.0 });
    var dirichlet_engine = alea.ScalarPrng.init(0x5150_d16c);
    var dirichlet_control = alea.ScalarPrng.init(0x5150_d16c);
    var dirichlet_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, dirichlet.sampleFrom(dirichlet_alloc.allocator(), &dirichlet_engine));
    try std.testing.expect(dirichlet_alloc.has_induced_failure);
    try std.testing.expectEqual(dirichlet_control.next(), dirichlet_engine.next());

    var dirichlet_facade_engine = alea.ScalarPrng.init(0x5150_d16d);
    var dirichlet_facade_control = alea.ScalarPrng.init(0x5150_d16d);
    const dirichlet_rng = Rng.init(&dirichlet_facade_engine);
    var dirichlet_facade_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, dirichlet.sample(dirichlet_facade_alloc.allocator(), dirichlet_rng));
    try std.testing.expect(dirichlet_facade_alloc.has_induced_failure);
    try std.testing.expectEqual(dirichlet_facade_control.next(), dirichlet_facade_engine.next());
}

test "invalid multivariate output lengths do not consume random stream" {
    const alea = @import("root.zig");

    const multinomial = try Multinomial.init(20, &.{ 1.0, 2.0, 3.0 });
    var multinomial_engine = alea.ScalarPrng.init(0x5150_d17a);
    var multinomial_control = alea.ScalarPrng.init(0x5150_d17a);
    var short_counts: [2]u64 = undefined;
    try std.testing.expectError(error.InvalidLength, multinomial.sampleIntoCheckedFrom(&multinomial_engine, &short_counts));
    try std.testing.expectEqual(multinomial_control.next(), multinomial_engine.next());

    var bad_many_counts: [4]u64 = undefined;
    try std.testing.expectError(error.InvalidLength, multinomial.sampleManyIntoCheckedFrom(&multinomial_engine, &bad_many_counts));
    try std.testing.expectEqual(multinomial_control.next(), multinomial_engine.next());

    var multinomial_facade_engine = alea.ScalarPrng.init(0x5150_d17b);
    var multinomial_facade_control = alea.ScalarPrng.init(0x5150_d17b);
    const multinomial_rng = Rng.init(&multinomial_facade_engine);
    try std.testing.expectError(error.InvalidLength, multinomial.sampleIntoChecked(multinomial_rng, &short_counts));
    try std.testing.expectEqual(multinomial_facade_control.next(), multinomial_facade_engine.next());
    try std.testing.expectError(error.InvalidLength, multinomial.sampleManyIntoChecked(multinomial_rng, &bad_many_counts));
    try std.testing.expectEqual(multinomial_facade_control.next(), multinomial_facade_engine.next());

    const dirichlet = try Dirichlet(f64).init(&.{ 1.0, 2.0, 3.0 });
    var dirichlet_engine = alea.ScalarPrng.init(0x5150_d17c);
    var dirichlet_control = alea.ScalarPrng.init(0x5150_d17c);
    var short_simplex: [2]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, dirichlet.sampleIntoCheckedFrom(&dirichlet_engine, &short_simplex));
    try std.testing.expectEqual(dirichlet_control.next(), dirichlet_engine.next());

    var bad_many_simplex: [4]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, dirichlet.sampleManyIntoCheckedFrom(&dirichlet_engine, &bad_many_simplex));
    try std.testing.expectEqual(dirichlet_control.next(), dirichlet_engine.next());

    var dirichlet_facade_engine = alea.ScalarPrng.init(0x5150_d17d);
    var dirichlet_facade_control = alea.ScalarPrng.init(0x5150_d17d);
    const dirichlet_rng = Rng.init(&dirichlet_facade_engine);
    try std.testing.expectError(error.InvalidLength, dirichlet.sampleIntoChecked(dirichlet_rng, &short_simplex));
    try std.testing.expectEqual(dirichlet_facade_control.next(), dirichlet_facade_engine.next());
    try std.testing.expectError(error.InvalidLength, dirichlet.sampleManyIntoChecked(dirichlet_rng, &bad_many_simplex));
    try std.testing.expectEqual(dirichlet_facade_control.next(), dirichlet_facade_engine.next());
}

test "zero-length multivariate batch outputs do not consume random stream" {
    const alea = @import("root.zig");

    const multinomial = try Multinomial.init(20, &.{ 1.0, 2.0, 3.0 });
    var multinomial_engine = alea.ScalarPrng.init(0x5150_d18b);
    var multinomial_control = alea.ScalarPrng.init(0x5150_d18b);
    var empty_counts: [0]u64 = .{};
    try multinomial.sampleManyIntoCheckedFrom(&multinomial_engine, &empty_counts);
    try std.testing.expectEqual(multinomial_control.next(), multinomial_engine.next());

    var multinomial_facade_engine = alea.ScalarPrng.init(0x5150_d18c);
    var multinomial_facade_control = alea.ScalarPrng.init(0x5150_d18c);
    try multinomial.sampleManyIntoChecked(Rng.init(&multinomial_facade_engine), &empty_counts);
    try std.testing.expectEqual(multinomial_facade_control.next(), multinomial_facade_engine.next());

    const dirichlet = try Dirichlet(f64).init(&.{ 1.0, 2.0, 3.0 });
    var dirichlet_engine = alea.ScalarPrng.init(0x5150_d18d);
    var dirichlet_control = alea.ScalarPrng.init(0x5150_d18d);
    var empty_simplex: [0]f64 = .{};
    try dirichlet.sampleManyIntoCheckedFrom(&dirichlet_engine, &empty_simplex);
    try std.testing.expectEqual(dirichlet_control.next(), dirichlet_engine.next());

    var dirichlet_facade_engine = alea.ScalarPrng.init(0x5150_d18e);
    var dirichlet_facade_control = alea.ScalarPrng.init(0x5150_d18e);
    try dirichlet.sampleManyIntoChecked(Rng.init(&dirichlet_facade_engine), &empty_simplex);
    try std.testing.expectEqual(dirichlet_facade_control.next(), dirichlet_facade_engine.next());
}

test "log-normal approximation has stable snapshots" {
    const alea = @import("root.zig");

    var sample_engine = alea.ScalarPrng.init(0x1064);
    const sample = logNormalApproxF32From(&sample_engine, 0, 0.25);
    try std.testing.expectEqual(@as(u32, 0x3fa987ee), @as(u32, @bitCast(sample)));
    try std.testing.expectEqual(@as(u64, 0x8e9892981fa2b6eb), sample_engine.next());

    var checked_engine = alea.ScalarPrng.init(0x1064);
    const checked = try logNormalApproxF32CheckedFrom(&checked_engine, 0, 0.25);
    try std.testing.expectEqual(@as(u32, 0x3fa987ee), @as(u32, @bitCast(checked)));
    try std.testing.expectEqual(@as(u64, 0x8e9892981fa2b6eb), checked_engine.next());

    var fill_engine = alea.ScalarPrng.init(0x1064);
    var buf: [6]f32 = undefined;
    fillLogNormalApproxF32From(&fill_engine, &buf, 0, 0.25);
    const expected_bits = [_]u32{
        0x3fa987ee,
        0x3f829519,
        0x3f276bee,
        0x3f653a10,
        0x3f4bfc87,
        0x3f58edbd,
    };
    inline for (expected_bits, 0..) |bits, i| {
        try std.testing.expectEqual(bits, @as(u32, @bitCast(buf[i])));
    }
    try std.testing.expectEqual(@as(u64, 0x96f2d6a8eb67add4), fill_engine.next());

    var sampler_engine = alea.ScalarPrng.init(0x1064);
    const sampler = try LogNormalApproxF32.init(0, 0.25);
    const sampler_sample = sampler.sampleFrom(&sampler_engine);
    try std.testing.expectEqual(@as(u32, 0x3fa987ee), @as(u32, @bitCast(sampler_sample)));
    try std.testing.expectEqual(@as(u64, 0x8e9892981fa2b6eb), sampler_engine.next());
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

    const direct_value = poissonAhrensDieterFrom(&engine, lambda);
    try std.testing.expect(direct_value < 120);
    const checked_direct_value = try poissonAhrensDieterCheckedFrom(&engine, lambda);
    try std.testing.expect(checked_direct_value < 120);
    try std.testing.expectError(error.InvalidParameter, poissonAhrensDieterCheckedFrom(&engine, 11));

    const mean = sum / @as(f64, @floatFromInt(samples));
    const variance = sum_sq / @as(f64, @floatFromInt(samples)) - mean * mean;
    try std.testing.expect(mean > 59.0 and mean < 61.0);
    try std.testing.expect(variance > 56.0 and variance < 64.0);
}

test "non-uniform samplers can be reused with sample iterators" {
    const alea = @import("root.zig");
    var engine = alea.DefaultPrng.init(66);
    const rng = Rng.init(&engine);
    var direct_engine = alea.ScalarPrng.init(166);

    const uniform_sampler = try Uniform(u32).init(3, 9);
    try std.testing.expectEqual(@as(u32, 3), uniform_sampler.lowValue());
    try std.testing.expectEqual(@as(u32, 9), uniform_sampler.highValue());
    try std.testing.expect(!uniform_sampler.isInclusive());
    try std.testing.expectApproxEqAbs(@as(f64, 5.5), uniform_sampler.expectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 35.0 / 12.0), uniform_sampler.varianceValue(), 0);
    const uniform_value = uniform_sampler.sampleFrom(&direct_engine);
    try std.testing.expect(uniform_value >= 3 and uniform_value < 9);
    var uniform_buf: [8]u32 = undefined;
    uniform_sampler.fill(rng, &uniform_buf);
    for (uniform_buf) |value| try std.testing.expect(value >= 3 and value < 9);
    var direct_uniform_buf: [8]u32 = undefined;
    uniform_sampler.fillFrom(&direct_engine, &direct_uniform_buf);
    const uniform_inclusive_sampler = try Uniform(u32).initInclusive(3, 9);
    try std.testing.expectEqual(@as(u32, 3), uniform_inclusive_sampler.lowValue());
    try std.testing.expectEqual(@as(u32, 9), uniform_inclusive_sampler.highValue());
    try std.testing.expect(uniform_inclusive_sampler.isInclusive());
    try std.testing.expectApproxEqAbs(@as(f64, 6), uniform_inclusive_sampler.expectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 4), uniform_inclusive_sampler.varianceValue(), 0);
    for (direct_uniform_buf) |value| try std.testing.expect(value >= 3 and value < 9);

    const float_uniform = try Uniform(f64).init(1, 3);
    try std.testing.expectApproxEqAbs(@as(f64, 2), float_uniform.expectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 3.0), float_uniform.varianceValue(), 0);
    const inclusive_uniform = try Uniform(u32).initInclusive(3, 9);
    const inclusive_value = inclusive_uniform.sampleFrom(&direct_engine);
    try std.testing.expect(inclusive_value >= 3 and inclusive_value <= 9);
    var inclusive_uniform_buf: [8]u32 = undefined;
    inclusive_uniform.fillFrom(&direct_engine, &inclusive_uniform_buf);
    for (inclusive_uniform_buf) |value| try std.testing.expect(value >= 3 and value <= 9);

    const direct_open = (Open01{}).sampleFrom(&direct_engine, f64);
    try std.testing.expect(direct_open > 0 and direct_open < 1);
    var open01_buf: [8]f64 = undefined;
    try std.testing.expectEqual(@as(f64, 0), (Open01{}).lowValue(f64));
    try std.testing.expectEqual(@as(f64, 1), (Open01{}).highValue(f64));
    try std.testing.expect(!(Open01{}).includesLow());
    try std.testing.expect(!(Open01{}).includesHigh());
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), (Open01{}).expectedValue(f64), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 12.0), (Open01{}).varianceValue(f64), 0);
    (Open01{}).fill(rng, f64, &open01_buf);
    for (open01_buf) |value| try std.testing.expect(value > 0 and value < 1);
    (Open01{}).fillFrom(&direct_engine, f64, &open01_buf);
    for (open01_buf) |value| try std.testing.expect(value > 0 and value < 1);

    const direct_open_closed = (OpenClosed01{}).sampleFrom(&direct_engine, f64);
    try std.testing.expect(direct_open_closed > 0 and direct_open_closed <= 1);
    var open_closed01_buf: [8]f64 = undefined;
    try std.testing.expectEqual(@as(f64, 0), (OpenClosed01{}).lowValue(f64));
    try std.testing.expectEqual(@as(f64, 1), (OpenClosed01{}).highValue(f64));
    try std.testing.expect(!(OpenClosed01{}).includesLow());
    try std.testing.expect((OpenClosed01{}).includesHigh());
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), (OpenClosed01{}).expectedValue(f64), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 12.0), (OpenClosed01{}).varianceValue(f64), 0);
    (OpenClosed01{}).fill(rng, f64, &open_closed01_buf);
    for (open_closed01_buf) |value| try std.testing.expect(value > 0 and value <= 1);
    (OpenClosed01{}).fillFrom(&direct_engine, f64, &open_closed01_buf);
    for (open_closed01_buf) |value| try std.testing.expect(value > 0 and value <= 1);

    var normals = rng.sampleIter(f64, try Normal(f64).init(10, 2));
    try std.testing.expect(normals.next().? > 0);
    const normal_sampler = try Normal(f64).init(10, 2);
    var normal_buf: [8]f64 = undefined;
    normal_sampler.fill(rng, &normal_buf);
    for (normal_buf) |value| try std.testing.expect(std.math.isFinite(value));
    var direct_normal_buf: [8]f64 = undefined;
    normal_sampler.fillFrom(&direct_engine, &direct_normal_buf);
    for (direct_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));
    const normal_cv_sampler = try Normal(f64).initMeanCv(-10, 0.2);
    try std.testing.expectApproxEqAbs(@as(f64, -10), normal_cv_sampler.mean, 0);
    try std.testing.expectApproxEqAbs(@as(f64, 2), normal_cv_sampler.stddev, 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, -7), normal_cv_sampler.fromZScore(1.5), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, -10), normal_cv_sampler.meanValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 2), normal_cv_sampler.stddevValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, -10), normal_cv_sampler.expectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 4), normal_cv_sampler.varianceValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, -10), normal_cv_sampler.medianValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, -10), normal_cv_sampler.modeValue(), 0);
    try std.testing.expect(normal_cv_sampler.minValue() == null);
    try std.testing.expect(normal_cv_sampler.maxValue() == null);
    const degenerate_normal = try Normal(f64).init(3, 0);
    try std.testing.expectApproxEqAbs(@as(f64, 3), degenerate_normal.minValue().?, 0);
    try std.testing.expectApproxEqAbs(@as(f64, 3), degenerate_normal.maxValue().?, 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0.2), normal_cv_sampler.coefficientOfVariationValue().?, 1e-15);
    try std.testing.expect((try Normal(f64).init(0, 0)).coefficientOfVariationValue() == null);

    var exponentials = rng.sampleIter(f64, try Exponential(f64).init(2));
    try std.testing.expect(exponentials.next().? >= 0);
    const exponential_sampler = try Exponential(f64).init(2);
    try std.testing.expectApproxEqAbs(@as(f64, 2), exponential_sampler.rateValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), exponential_sampler.inverseRateValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), exponential_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), exponential_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@log(@as(f64, 2)) / 2.0, exponential_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), exponential_sampler.modeValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0), exponential_sampler.minValue(), 0);
    try std.testing.expect(exponential_sampler.maxValue() == null);
    var exponential_buf: [8]f64 = undefined;
    exponential_sampler.fill(rng, &exponential_buf);
    for (exponential_buf) |value| try std.testing.expect(value >= 0);
    var direct_exponential_buf: [8]f64 = undefined;
    exponential_sampler.fillFrom(&direct_engine, &direct_exponential_buf);
    for (direct_exponential_buf) |value| try std.testing.expect(value >= 0);

    var standard_normals = rng.sampleIter(f64, StandardNormal(f64){});
    try std.testing.expect(std.math.isFinite(standard_normals.next().?));
    try std.testing.expectEqual(@as(f64, 0), (StandardNormal(f64){}).meanValue());
    try std.testing.expectEqual(@as(f64, 1), (StandardNormal(f64){}).stddevValue());
    try std.testing.expectEqual(@as(f64, 0), (StandardNormal(f64){}).expectedValue());
    try std.testing.expectEqual(@as(f64, 1), (StandardNormal(f64){}).varianceValue());
    try std.testing.expectEqual(@as(f64, 0), (StandardNormal(f64){}).medianValue());
    try std.testing.expectEqual(@as(f64, 0), (StandardNormal(f64){}).modeValue());
    try std.testing.expect((StandardNormal(f64){}).minValue() == null);
    try std.testing.expect((StandardNormal(f64){}).maxValue() == null);
    var standard_normal_buf: [8]f64 = undefined;
    fillStandardNormal(rng, f64, &standard_normal_buf);
    for (standard_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));
    var direct_standard_normal_buf: [8]f64 = undefined;
    fillStandardNormalFrom(&direct_engine, f64, &direct_standard_normal_buf);
    for (direct_standard_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));
    (StandardNormal(f64){}).fillFrom(&direct_engine, &direct_standard_normal_buf);
    for (direct_standard_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));

    var standard_exponentials = rng.sampleIter(f64, StandardExponential(f64){});
    try std.testing.expect(standard_exponentials.next().? >= 0);
    try std.testing.expectEqual(@as(f64, 1), (StandardExponential(f64){}).rateValue());
    try std.testing.expectEqual(@as(f64, 1), (StandardExponential(f64){}).inverseRateValue());
    try std.testing.expectEqual(@as(f64, 1), (StandardExponential(f64){}).expectedValue());
    try std.testing.expectEqual(@as(f64, 1), (StandardExponential(f64){}).varianceValue());
    try std.testing.expectEqual(@log(@as(f64, 2)), (StandardExponential(f64){}).medianValue());
    try std.testing.expectEqual(@as(f64, 0), (StandardExponential(f64){}).modeValue());
    try std.testing.expectEqual(@as(f64, 0), (StandardExponential(f64){}).minValue());
    try std.testing.expect((StandardExponential(f64){}).maxValue() == null);
    var standard_exponential_buf: [8]f64 = undefined;
    fillStandardExponential(rng, f64, &standard_exponential_buf);
    for (standard_exponential_buf) |value| try std.testing.expect(value >= 0);
    var direct_standard_exponential_buf: [8]f64 = undefined;
    fillStandardExponentialFrom(&direct_engine, f64, &direct_standard_exponential_buf);
    for (direct_standard_exponential_buf) |value| try std.testing.expect(value >= 0);
    (StandardExponential(f64){}).fillFrom(&direct_engine, &direct_standard_exponential_buf);
    for (direct_standard_exponential_buf) |value| try std.testing.expect(value >= 0);

    var log_normals = rng.sampleIter(f64, try LogNormal(f64).init(0, 0.25));
    try std.testing.expect(log_normals.next().? > 0);
    var log_normal_buf: [8]f64 = undefined;
    fillLogNormal(rng, f64, &log_normal_buf, 0, 0.25);
    for (log_normal_buf) |value| try std.testing.expect(value > 0);
    var direct_log_normal_buf: [8]f64 = undefined;
    fillLogNormalFrom(&direct_engine, f64, &direct_log_normal_buf, 0, 0.25);
    for (direct_log_normal_buf) |value| try std.testing.expect(value > 0);
    try fillLogNormalChecked(rng, f64, &log_normal_buf, 0, 0.25);
    for (log_normal_buf) |value| try std.testing.expect(value > 0);
    try fillLogNormalCheckedFrom(&direct_engine, f64, &direct_log_normal_buf, 0, 0.25);
    for (direct_log_normal_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expectError(error.InvalidParameter, fillLogNormalCheckedFrom(&direct_engine, f64, &direct_log_normal_buf, 0, -1));
    var log_normal_sampler = try LogNormal(f64).init(0, 0.25);
    log_normal_sampler.fillFrom(&direct_engine, &direct_log_normal_buf);
    for (direct_log_normal_buf) |value| try std.testing.expect(value > 0);

    var exact_f32_engine = alea.ScalarPrng.init(0x1064);
    var approx_f32_engine = alea.ScalarPrng.init(0x1064);
    const exact_f32 = logNormalFrom(&exact_f32_engine, f32, 0, 0.25);
    const approx_f32 = logNormalApproxF32From(&approx_f32_engine, 0, 0.25);
    try std.testing.expect(floatDistancePositiveF32(exact_f32, approx_f32) <= 1);
    try std.testing.expectEqual(exact_f32_engine.next(), approx_f32_engine.next());
    try std.testing.expect(try logNormalApproxF32Checked(rng, 0, 0.25) > 0);
    try std.testing.expect(try logNormalApproxF32CheckedFrom(&direct_engine, 0, 0.25) > 0);
    const log_normal_approx_sampler = try LogNormalApproxF32.init(0, 0.25);
    try std.testing.expectEqual(@as(f32, 0), log_normal_approx_sampler.meanValue());
    try std.testing.expectEqual(@as(f32, 0.25), log_normal_approx_sampler.stddevValue());
    try std.testing.expectEqual(LogNormalApproxF32.max_abs_mean, log_normal_approx_sampler.maxAbsMeanValue());
    try std.testing.expectEqual(LogNormalApproxF32.max_stddev, log_normal_approx_sampler.maxStddevValue());
    try std.testing.expect(log_normal_approx_sampler.sample(rng) > 0);
    try std.testing.expect(log_normal_approx_sampler.sampleFrom(&direct_engine) > 0);
    var approx_f32_buf: [8]f32 = undefined;
    var direct_approx_f32_buf: [8]f32 = undefined;
    fillLogNormalApproxF32(rng, &approx_f32_buf, 0, 0.25);
    for (approx_f32_buf) |value| try std.testing.expect(value > 0);
    fillLogNormalApproxF32From(&direct_engine, &direct_approx_f32_buf, 0, 0.25);
    for (direct_approx_f32_buf) |value| try std.testing.expect(value > 0);
    try fillLogNormalApproxF32Checked(rng, &approx_f32_buf, 0, 0.25);
    for (approx_f32_buf) |value| try std.testing.expect(value > 0);
    try fillLogNormalApproxF32CheckedFrom(&direct_engine, &direct_approx_f32_buf, 0, 0.25);
    for (direct_approx_f32_buf) |value| try std.testing.expect(value > 0);
    log_normal_approx_sampler.fill(rng, &approx_f32_buf);
    log_normal_approx_sampler.fillFrom(&direct_engine, &direct_approx_f32_buf);

    const log_normal_zero_cv_sampler = try LogNormal(f64).initMeanCv(0, 0);
    try std.testing.expect(std.math.isNegativeInf(log_normal_zero_cv_sampler.normal_sampler.mean));
    var log_normal_mean_cv_sampler = try LogNormal(f64).initMeanCv(2, 0.5);
    try std.testing.expectApproxEqAbs(@as(f64, 2), log_normal_mean_cv_sampler.fromZScore(0) * @exp(0.5 * log_normal_mean_cv_sampler.logStddev() * log_normal_mean_cv_sampler.logStddev()), 1e-14);
    try std.testing.expect(std.math.isFinite(log_normal_mean_cv_sampler.logMean()));
    try std.testing.expectApproxEqAbs(log_normal_mean_cv_sampler.logMean(), log_normal_mean_cv_sampler.logMeanValue(), 1e-15);
    try std.testing.expect(log_normal_mean_cv_sampler.logStddev() > 0);
    try std.testing.expectApproxEqAbs(log_normal_mean_cv_sampler.logStddev(), log_normal_mean_cv_sampler.logStddevValue(), 1e-15);
    try std.testing.expectApproxEqAbs(@as(f64, 2), log_normal_mean_cv_sampler.linearMeanValue(), 1e-14);
    const log_normal_median = @as(f64, 2) / @sqrt(@as(f64, 1.25));
    try std.testing.expectApproxEqAbs(log_normal_median, log_normal_mean_cv_sampler.medianValue(), 1e-14);
    try std.testing.expectApproxEqAbs(log_normal_median / 1.25, log_normal_mean_cv_sampler.modeValue(), 1e-14);
    try std.testing.expectApproxEqAbs(@as(f64, 2), log_normal_mean_cv_sampler.expectedValue(), 1e-14);
    try std.testing.expectApproxEqAbs(@as(f64, 1), log_normal_mean_cv_sampler.varianceValue(), 1e-14);
    try std.testing.expectApproxEqAbs(@as(f64, 0), log_normal_mean_cv_sampler.minValue(), 0);
    try std.testing.expect(log_normal_mean_cv_sampler.maxValue() == null);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), log_normal_mean_cv_sampler.coefficientOfVariationValue(), 1e-14);
    try std.testing.expectApproxEqAbs(@as(f64, 0), log_normal_zero_cv_sampler.linearMeanValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0), log_normal_zero_cv_sampler.medianValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0), log_normal_zero_cv_sampler.modeValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0), log_normal_zero_cv_sampler.expectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0), log_normal_zero_cv_sampler.varianceValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0), log_normal_zero_cv_sampler.minValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0), log_normal_zero_cv_sampler.maxValue().?, 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0), log_normal_zero_cv_sampler.coefficientOfVariationValue(), 0);
    const log_normal_positive_degenerate = try LogNormal(f64).initMeanCv(2, 0);
    try std.testing.expectApproxEqAbs(@as(f64, 2), log_normal_positive_degenerate.medianValue(), 1e-14);
    try std.testing.expectApproxEqAbs(@as(f64, 2), log_normal_positive_degenerate.modeValue(), 1e-14);
    try std.testing.expectApproxEqAbs(@as(f64, 2), log_normal_positive_degenerate.minValue(), 1e-14);
    try std.testing.expectApproxEqAbs(@as(f64, 2), log_normal_positive_degenerate.maxValue().?, 1e-14);
    log_normal_mean_cv_sampler.fillFrom(&direct_engine, &direct_log_normal_buf);
    for (direct_log_normal_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expect(try logNormalCheckedFrom(&direct_engine, f64, 0, 0.25) > 0);
    try std.testing.expectError(error.InvalidParameter, logNormalCheckedFrom(&direct_engine, f64, 0, -1));

    var half_normals = rng.sampleIter(f64, try HalfNormal(f64).init(2));
    try std.testing.expect(half_normals.next().? >= 0);
    var half_normal_buf: [8]f64 = undefined;
    fillHalfNormal(rng, f64, &half_normal_buf, 2);
    for (half_normal_buf) |value| try std.testing.expect(value >= 0);
    var direct_half_normal_buf: [8]f64 = undefined;
    fillHalfNormalFrom(&direct_engine, f64, &direct_half_normal_buf, 2);
    for (direct_half_normal_buf) |value| try std.testing.expect(value >= 0);
    try fillHalfNormalChecked(rng, f64, &half_normal_buf, 2);
    for (half_normal_buf) |value| try std.testing.expect(value >= 0);
    try fillHalfNormalCheckedFrom(&direct_engine, f64, &direct_half_normal_buf, 2);
    for (direct_half_normal_buf) |value| try std.testing.expect(value >= 0);
    try std.testing.expectError(error.InvalidParameter, fillHalfNormalCheckedFrom(&direct_engine, f64, &direct_half_normal_buf, 0));
    const half_normal_sampler = try HalfNormal(f64).init(2);
    try std.testing.expectApproxEqAbs(@as(f64, 2), half_normal_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2) * @sqrt(2.0 / std.math.pi), half_normal_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4) * (1 - 2.0 / std.math.pi), half_normal_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), half_normal_sampler.minValue(), 0);
    try std.testing.expect(half_normal_sampler.maxValue() == null);
    half_normal_sampler.fillFrom(&direct_engine, &direct_half_normal_buf);
    for (direct_half_normal_buf) |value| try std.testing.expect(value >= 0);
    try std.testing.expect(try halfNormalCheckedFrom(&direct_engine, f64, 2) >= 0);
    try std.testing.expectError(error.InvalidParameter, halfNormalCheckedFrom(&direct_engine, f64, 0));

    var poissons = rng.sampleIter(u64, try Poisson.init(12));
    try std.testing.expect(poissons.next().? < 64);
    var poisson_buf: [8]u64 = undefined;
    fillPoisson(rng, &poisson_buf, 12);
    for (poisson_buf) |value| try std.testing.expect(value < 64);
    var direct_poisson_buf: [8]u64 = undefined;
    fillPoissonFrom(&direct_engine, &direct_poisson_buf, 12);
    for (direct_poisson_buf) |value| try std.testing.expect(value < 64);
    try fillPoissonChecked(rng, &poisson_buf, 12);
    for (poisson_buf) |value| try std.testing.expect(value < 64);
    try fillPoissonCheckedFrom(&direct_engine, &direct_poisson_buf, 12);
    for (direct_poisson_buf) |value| try std.testing.expect(value < 64);
    try std.testing.expectError(error.InvalidParameter, fillPoissonCheckedFrom(&direct_engine, &direct_poisson_buf, std.math.inf(f64)));
    const poisson_sampler = try Poisson.init(12);
    try std.testing.expectApproxEqAbs(@as(f64, 12), poisson_sampler.lambdaValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 12), poisson_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 12), poisson_sampler.varianceValue(), 1e-12);
    try std.testing.expectEqual(@as(u64, 0), poisson_sampler.minValue());
    try std.testing.expect(poisson_sampler.maxValue() == null);
    try std.testing.expectEqual(@as(u64, 0), (try Poisson.init(0)).maxValue().?);
    poisson_sampler.fillFrom(&direct_engine, &direct_poisson_buf);
    for (direct_poisson_buf) |value| try std.testing.expect(value < 64);

    var geometrics = rng.sampleIter(u64, try Geometric.init(0.25));
    try std.testing.expect(geometrics.next().? >= 1);
    try std.testing.expect((try Geometric.init(0.25)).sampleFrom(&direct_engine) >= 1);
    var geometric_buf: [8]u64 = undefined;
    fillGeometric(rng, &geometric_buf, 0.25);
    for (geometric_buf) |value| try std.testing.expect(value >= 1);
    var direct_geometric_buf: [8]u64 = undefined;
    fillGeometricFrom(&direct_engine, &direct_geometric_buf, 0.25);
    for (direct_geometric_buf) |value| try std.testing.expect(value >= 1);
    try fillGeometricChecked(rng, &geometric_buf, 0.25);
    for (geometric_buf) |value| try std.testing.expect(value >= 1);
    try fillGeometricCheckedFrom(&direct_engine, &direct_geometric_buf, 0.25);
    for (direct_geometric_buf) |value| try std.testing.expect(value >= 1);
    try std.testing.expectError(error.InvalidProbability, fillGeometricCheckedFrom(&direct_engine, &direct_geometric_buf, 0));
    const geometric_sampler = try Geometric.init(0.25);
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), geometric_sampler.probabilityValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4), geometric_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 12), geometric_sampler.varianceValue(), 1e-12);
    try std.testing.expectEqual(@as(u64, 1), geometric_sampler.modeValue());
    try std.testing.expectEqual(@as(u64, 1), geometric_sampler.minValue());
    try std.testing.expect(geometric_sampler.maxValue() == null);
    geometric_sampler.fillFrom(&direct_engine, &direct_geometric_buf);
    for (direct_geometric_buf) |value| try std.testing.expect(value >= 1);
    try std.testing.expect(try geometricCheckedFrom(&direct_engine, 0.25) >= 1);
    try std.testing.expectError(error.InvalidProbability, geometricCheckedFrom(&direct_engine, 0));
    var geometric_failures = rng.sampleIter(u64, try GeometricFailures.init(0.25));
    _ = geometric_failures.next().?;
    var geometric_failures_buf: [8]u64 = undefined;
    fillGeometricFailures(rng, &geometric_failures_buf, 0.25);
    fillGeometricFailuresFrom(&direct_engine, &geometric_failures_buf, 0.25);
    try fillGeometricFailuresChecked(rng, &geometric_failures_buf, 1);
    for (geometric_failures_buf) |value| try std.testing.expectEqual(@as(u64, 0), value);
    try fillGeometricFailuresCheckedFrom(&direct_engine, &geometric_failures_buf, 1);
    for (geometric_failures_buf) |value| try std.testing.expectEqual(@as(u64, 0), value);
    try std.testing.expectError(error.InvalidProbability, fillGeometricFailuresCheckedFrom(&direct_engine, &geometric_failures_buf, 0));
    const geometric_failures_sampler = try GeometricFailures.init(0.25);
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), geometric_failures_sampler.probabilityValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), geometric_failures_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 12), geometric_failures_sampler.varianceValue(), 1e-12);
    try std.testing.expectEqual(@as(u64, 0), geometric_failures_sampler.modeValue());
    try std.testing.expectEqual(@as(u64, 0), geometric_failures_sampler.minValue());
    try std.testing.expect(geometric_failures_sampler.maxValue() == null);
    geometric_failures_sampler.fillFrom(&direct_engine, &geometric_failures_buf);
    try std.testing.expectEqual(@as(u64, 0), geometricFailures(rng, 1));
    try std.testing.expect(try geometricFailuresCheckedFrom(&direct_engine, 0.25) < 64);
    try std.testing.expectError(error.InvalidProbability, geometricFailuresCheckedFrom(&direct_engine, 0));
    const always_success_failures = GeometricFailures.init(1) catch unreachable;
    try std.testing.expectEqual(@as(u64, 0), always_success_failures.sample(rng));
    var standard_geometric_buf: [8]u64 = undefined;
    fillStandardGeometric(rng, &standard_geometric_buf);
    fillStandardGeometricFrom(&direct_engine, &standard_geometric_buf);
    const standard_geometric_sampler = StandardGeometric{};
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), standard_geometric_sampler.probabilityValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), standard_geometric_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), standard_geometric_sampler.varianceValue(), 1e-12);
    try std.testing.expectEqual(@as(u64, 0), standard_geometric_sampler.modeValue());
    try std.testing.expectEqual(@as(u64, 0), standard_geometric_sampler.minValue());
    try std.testing.expect(standard_geometric_sampler.maxValue() == null);
    standard_geometric_sampler.fillFrom(&direct_engine, &standard_geometric_buf);
    _ = standardGeometric(rng);
    _ = standard_geometric_sampler.sampleFrom(&direct_engine);

    var gammas = rng.sampleIter(f64, try Gamma(f64).init(2, 3));
    try std.testing.expect(gammas.next().? > 0);
    var gamma_buf: [8]f64 = undefined;
    fillGamma(rng, f64, &gamma_buf, 2, 3);
    for (gamma_buf) |value| try std.testing.expect(value > 0);
    var direct_gamma_buf: [8]f64 = undefined;
    fillGammaFrom(&direct_engine, f64, &direct_gamma_buf, 2, 3);
    for (direct_gamma_buf) |value| try std.testing.expect(value > 0);
    try fillGammaChecked(rng, f64, &gamma_buf, 2, 3);
    for (gamma_buf) |value| try std.testing.expect(value > 0);
    try fillGammaCheckedFrom(&direct_engine, f64, &direct_gamma_buf, 2, 3);
    for (direct_gamma_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expectError(error.InvalidParameter, fillGammaCheckedFrom(&direct_engine, f64, &direct_gamma_buf, 0, 3));
    const gamma_sampler = try Gamma(f64).init(2, 3);
    try std.testing.expectApproxEqAbs(@as(f64, 2), gamma_sampler.shapeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), gamma_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 6), gamma_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 18), gamma_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), gamma_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), gamma_sampler.minValue(), 0);
    try std.testing.expect(gamma_sampler.maxValue() == null);
    gamma_sampler.fillFrom(&direct_engine, &direct_gamma_buf);
    for (direct_gamma_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expect(try gammaCheckedFrom(&direct_engine, f64, 2, 3) > 0);
    try std.testing.expectError(error.InvalidParameter, gammaCheckedFrom(&direct_engine, f64, 0, 3));
    var gamma_shape_one_buf: [8]f64 = undefined;
    fillGammaFrom(&direct_engine, f64, &gamma_shape_one_buf, 1, 3);
    for (gamma_shape_one_buf) |value| try std.testing.expect(value > 0);
    const gamma_shape_one = try Gamma(f64).init(1, 3);
    try std.testing.expect(gamma_shape_one.sampleFrom(&direct_engine) > 0);
    var gamma_shape_half_buf: [8]f64 = undefined;
    fillGammaFrom(&direct_engine, f64, &gamma_shape_half_buf, 0.5, 3);
    for (gamma_shape_half_buf) |value| try std.testing.expect(value >= 0);
    const gamma_shape_half = try Gamma(f64).init(0.5, 3);
    try std.testing.expect(gamma_shape_half.sampleFrom(&direct_engine) >= 0);

    var chi_squared = rng.sampleIter(f64, try ChiSquared(f64).init(4));
    try std.testing.expect(chi_squared.next().? > 0);
    var chi_squared_buf: [8]f64 = undefined;
    fillChiSquared(rng, f64, &chi_squared_buf, 4);
    for (chi_squared_buf) |value| try std.testing.expect(value > 0);
    var direct_chi_squared_buf: [8]f64 = undefined;
    fillChiSquaredFrom(&direct_engine, f64, &direct_chi_squared_buf, 4);
    for (direct_chi_squared_buf) |value| try std.testing.expect(value > 0);
    try fillChiSquaredChecked(rng, f64, &chi_squared_buf, 4);
    for (chi_squared_buf) |value| try std.testing.expect(value > 0);
    try fillChiSquaredCheckedFrom(&direct_engine, f64, &direct_chi_squared_buf, 4);
    for (direct_chi_squared_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expectError(error.InvalidParameter, fillChiSquaredCheckedFrom(&direct_engine, f64, &direct_chi_squared_buf, 0));
    const chi_squared_sampler = try ChiSquared(f64).init(4);
    try std.testing.expectApproxEqAbs(@as(f64, 4), chi_squared_sampler.dofValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4), chi_squared_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 8), chi_squared_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), chi_squared_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), chi_squared_sampler.minValue(), 0);
    try std.testing.expect(chi_squared_sampler.maxValue() == null);
    chi_squared_sampler.fillFrom(&direct_engine, &direct_chi_squared_buf);
    for (direct_chi_squared_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expect(try chiSquaredCheckedFrom(&direct_engine, f64, 4) > 0);
    try std.testing.expectError(error.InvalidParameter, chiSquaredCheckedFrom(&direct_engine, f64, 0));
    var chi_squared_one_buf: [8]f64 = undefined;
    fillChiSquaredFrom(&direct_engine, f64, &chi_squared_one_buf, 1);
    for (chi_squared_one_buf) |value| try std.testing.expect(value >= 0);

    var chis = rng.sampleIter(f64, try Chi(f64).init(4));
    try std.testing.expect(chis.next().? > 0);
    var chi_buf: [8]f64 = undefined;
    fillChi(rng, f64, &chi_buf, 4);
    for (chi_buf) |value| try std.testing.expect(value > 0);
    var direct_chi_buf: [8]f64 = undefined;
    fillChiFrom(&direct_engine, f64, &direct_chi_buf, 4);
    for (direct_chi_buf) |value| try std.testing.expect(value > 0);
    try fillChiChecked(rng, f64, &chi_buf, 4);
    for (chi_buf) |value| try std.testing.expect(value > 0);
    try fillChiCheckedFrom(&direct_engine, f64, &direct_chi_buf, 4);
    for (direct_chi_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expectError(error.InvalidParameter, fillChiCheckedFrom(&direct_engine, f64, &direct_chi_buf, 0));
    var chi_one_buf: [8]f64 = undefined;
    fillChiFrom(&direct_engine, f64, &chi_one_buf, 1);
    for (chi_one_buf) |value| try std.testing.expect(value >= 0);
    const chi_sampler = try Chi(f64).init(4);
    try std.testing.expectApproxEqAbs(@as(f64, 4), chi_sampler.dofValue(), 1e-12);
    const chi_mean = 3.0 * @sqrt(2.0 * std.math.pi) / 4.0;
    try std.testing.expectApproxEqAbs(chi_mean, chi_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(4.0 - chi_mean * chi_mean, chi_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@sqrt(@as(f64, 3)), chi_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), chi_sampler.minValue(), 0);
    try std.testing.expect(chi_sampler.maxValue() == null);
    chi_sampler.fillFrom(&direct_engine, &direct_chi_buf);
    try std.testing.expect(try chiCheckedFrom(&direct_engine, f64, 4) > 0);
    try std.testing.expectError(error.InvalidParameter, chiCheckedFrom(&direct_engine, f64, 0));
    for (direct_chi_buf) |value| try std.testing.expect(value > 0);

    const erlang_vec = try vectorErlangChecked(rng, @Vector(4, f64), 3, 2);
    const direct_erlang_vec = try vectorErlangCheckedFrom(&direct_engine, @Vector(4, f64), 3, 2);
    inline for (0..4) |lane| try std.testing.expect(erlang_vec[lane] > 0);
    inline for (0..4) |lane| try std.testing.expect(direct_erlang_vec[lane] > 0);

    const vector_erlang_sampler = try VectorErlang(@Vector(4, f64)).init(3, 2);
    try std.testing.expectEqual(@as(u64, 3), vector_erlang_sampler.shapeValue());
    try std.testing.expectApproxEqAbs(@as(f64, 2), vector_erlang_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 6), vector_erlang_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 12), vector_erlang_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4), vector_erlang_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), vector_erlang_sampler.minValue(), 0);
    try std.testing.expect(vector_erlang_sampler.maxValue() == null);
    const sampled_erlang_vec = vector_erlang_sampler.sample(rng);
    const direct_sampled_erlang_vec = vector_erlang_sampler.sampleFrom(&direct_engine);
    inline for (0..4) |lane| try std.testing.expect(sampled_erlang_vec[lane] > 0);
    inline for (0..4) |lane| try std.testing.expect(direct_sampled_erlang_vec[lane] > 0);

    var erlang_vec_buf: [3]@Vector(4, f64) = undefined;
    var direct_erlang_vec_buf: [3]@Vector(4, f64) = undefined;
    try fillVectorErlangChecked(rng, @Vector(4, f64), &erlang_vec_buf, 3, 2);
    try fillVectorErlangCheckedFrom(&direct_engine, @Vector(4, f64), &direct_erlang_vec_buf, 3, 2);
    for (erlang_vec_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    for (direct_erlang_vec_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    vector_erlang_sampler.fill(rng, &erlang_vec_buf);
    vector_erlang_sampler.fillFrom(&direct_engine, &direct_erlang_vec_buf);
    for (erlang_vec_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);
    for (direct_erlang_vec_buf) |vec| inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0);

    var erlangs = rng.sampleIter(f64, try Erlang(f64).init(3, 2));
    try std.testing.expect(erlangs.next().? > 0);
    try std.testing.expect(try erlangCheckedFrom(&direct_engine, f64, 3, 2) > 0);
    try std.testing.expectError(error.InvalidParameter, erlangCheckedFrom(&direct_engine, f64, 0, 2));
    var erlang_buf: [8]f64 = undefined;
    fillErlang(rng, f64, &erlang_buf, 3, 2);
    for (erlang_buf) |value| try std.testing.expect(value > 0);
    var direct_erlang_buf: [8]f64 = undefined;
    fillErlangFrom(&direct_engine, f64, &direct_erlang_buf, 3, 2);
    for (direct_erlang_buf) |value| try std.testing.expect(value > 0);
    try fillErlangChecked(rng, f64, &erlang_buf, 3, 2);
    for (erlang_buf) |value| try std.testing.expect(value > 0);
    try fillErlangCheckedFrom(&direct_engine, f64, &direct_erlang_buf, 3, 2);
    for (direct_erlang_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expectError(error.InvalidParameter, fillErlangCheckedFrom(&direct_engine, f64, &direct_erlang_buf, 0, 2));
    const erlang_sampler = try Erlang(f64).init(3, 2);
    try std.testing.expectEqual(@as(u64, 3), erlang_sampler.shapeValue());
    try std.testing.expectApproxEqAbs(@as(f64, 2), erlang_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 6), erlang_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 12), erlang_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4), erlang_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), erlang_sampler.minValue(), 0);
    try std.testing.expect(erlang_sampler.maxValue() == null);
    erlang_sampler.fillFrom(&direct_engine, &direct_erlang_buf);
    for (direct_erlang_buf) |value| try std.testing.expect(value > 0);

    var betas = rng.sampleIter(f64, try Beta(f64).init(2, 5));
    const beta_value = betas.next().?;
    try std.testing.expect(beta_value >= 0 and beta_value <= 1);
    const direct_beta = betaFrom(&direct_engine, f64, 2, 5);
    try std.testing.expect(direct_beta >= 0 and direct_beta <= 1);
    const direct_checked_beta = try betaCheckedFrom(&direct_engine, f64, 2, 5);
    try std.testing.expect(direct_checked_beta >= 0 and direct_checked_beta <= 1);
    try std.testing.expectError(error.InvalidParameter, betaCheckedFrom(&direct_engine, f64, 1, 0));
    var beta_buf: [8]f64 = undefined;
    fillBeta(rng, f64, &beta_buf, 2, 5);
    for (beta_buf) |value| try std.testing.expect(value >= 0 and value <= 1);
    var direct_beta_buf: [8]f64 = undefined;
    fillBetaFrom(&direct_engine, f64, &direct_beta_buf, 2, 5);
    for (direct_beta_buf) |value| try std.testing.expect(value >= 0 and value <= 1);
    try fillBetaChecked(rng, f64, &beta_buf, 2, 5);
    for (beta_buf) |value| try std.testing.expect(value >= 0 and value <= 1);
    try fillBetaCheckedFrom(&direct_engine, f64, &direct_beta_buf, 2, 5);
    for (direct_beta_buf) |value| try std.testing.expect(value >= 0 and value <= 1);
    try std.testing.expectError(error.InvalidParameter, fillBetaCheckedFrom(&direct_engine, f64, &direct_beta_buf, 1, 0));
    const beta_sampler = try Beta(f64).init(2, 5);
    try std.testing.expectApproxEqAbs(@as(f64, 2), beta_sampler.alphaValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5), beta_sampler.betaValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0 / 7.0), beta_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5.0 / 196.0), beta_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.2), beta_sampler.modeValue().?, 1e-12);
    try std.testing.expect((try Beta(f64).init(1, 1)).modeValue() == null);
    try std.testing.expectApproxEqAbs(@as(f64, 0), (try Beta(f64).init(1, 2)).modeValue().?, 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1), (try Beta(f64).init(2, 1)).modeValue().?, 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0), beta_sampler.minValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1), beta_sampler.maxValue(), 0);
    beta_sampler.fillFrom(&direct_engine, &direct_beta_buf);
    for (direct_beta_buf) |value| try std.testing.expect(value >= 0 and value <= 1);
    var beta_unit_buf: [8]f64 = undefined;
    fillBetaFrom(&direct_engine, f64, &beta_unit_buf, 1, 1);
    for (beta_unit_buf) |value| try std.testing.expect(value >= 0 and value < 1);
    var beta_alpha_two_buf: [8]f64 = undefined;
    fillBetaFrom(&direct_engine, f64, &beta_alpha_two_buf, 2, 1);
    for (beta_alpha_two_buf) |value| try std.testing.expect(value > 0 and value <= 1);
    var beta_one_two_buf: [8]f64 = undefined;
    fillBetaFrom(&direct_engine, f64, &beta_one_two_buf, 1, 2);
    for (beta_one_two_buf) |value| try std.testing.expect(value >= 0 and value < 1);

    var fisher = rng.sampleIter(f64, try FisherF(f64).init(5, 20));
    try std.testing.expect(fisher.next().? > 0);
    try std.testing.expect(fisherFFrom(&direct_engine, f64, 5, 20) > 0);
    var fisher_buf: [8]f64 = undefined;
    fillFisherF(rng, f64, &fisher_buf, 5, 20);
    for (fisher_buf) |value| try std.testing.expect(value > 0);
    var direct_fisher_buf: [8]f64 = undefined;
    fillFisherFFrom(&direct_engine, f64, &direct_fisher_buf, 5, 20);
    for (direct_fisher_buf) |value| try std.testing.expect(value > 0);
    try fillFisherFChecked(rng, f64, &fisher_buf, 5, 20);
    for (fisher_buf) |value| try std.testing.expect(value > 0);
    try fillFisherFCheckedFrom(&direct_engine, f64, &direct_fisher_buf, 5, 20);
    for (direct_fisher_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expectError(error.InvalidParameter, fillFisherFCheckedFrom(&direct_engine, f64, &direct_fisher_buf, 0, 20));
    const fisher_sampler = try FisherF(f64).init(5, 20);
    try std.testing.expectApproxEqAbs(@as(f64, 5), fisher_sampler.d1Value(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 20), fisher_sampler.d2Value(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 10.0 / 9.0), fisher_sampler.expectedValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 115.0 / 162.0), fisher_sampler.varianceValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), fisher_sampler.minValue(), 0);
    try std.testing.expect(fisher_sampler.maxValue() == null);
    try std.testing.expect((try FisherF(f64).init(5, 2)).expectedValue() == null);
    try std.testing.expect((try FisherF(f64).init(5, 4)).varianceValue() == null);
    fisher_sampler.fillFrom(&direct_engine, &direct_fisher_buf);
    for (direct_fisher_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expect(try fisherFCheckedFrom(&direct_engine, f64, 5, 20) > 0);
    try std.testing.expectError(error.InvalidParameter, fisherFCheckedFrom(&direct_engine, f64, 0, 20));

    var student = rng.sampleIter(f64, try StudentT(f64).init(10));
    _ = student.next().?;
    try std.testing.expect(std.math.isFinite(studentTFrom(&direct_engine, f64, 10)));
    try std.testing.expect(std.math.isFinite(try studentTCheckedFrom(&direct_engine, f64, 10)));
    try std.testing.expectError(error.InvalidParameter, studentTCheckedFrom(&direct_engine, f64, 0));
    var student_buf: [8]f64 = undefined;
    fillStudentT(rng, f64, &student_buf, 10);
    for (student_buf) |value| try std.testing.expect(std.math.isFinite(value));
    var direct_student_buf: [8]f64 = undefined;
    fillStudentTFrom(&direct_engine, f64, &direct_student_buf, 10);
    for (direct_student_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillStudentTChecked(rng, f64, &student_buf, 10);
    for (student_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillStudentTCheckedFrom(&direct_engine, f64, &direct_student_buf, 10);
    for (direct_student_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try std.testing.expectError(error.InvalidParameter, fillStudentTCheckedFrom(&direct_engine, f64, &direct_student_buf, 0));
    const student_sampler = try StudentT(f64).init(10);
    try std.testing.expectApproxEqAbs(@as(f64, 10), student_sampler.dofValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), student_sampler.expectedValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.25), student_sampler.varianceValue().?, 1e-12);
    try std.testing.expect(student_sampler.minValue() == null);
    try std.testing.expect(student_sampler.maxValue() == null);
    try std.testing.expect((try StudentT(f64).init(1)).expectedValue() == null);
    try std.testing.expect((try StudentT(f64).init(2)).varianceValue() == null);
    student_sampler.fillFrom(&direct_engine, &direct_student_buf);
    for (direct_student_buf) |value| try std.testing.expect(std.math.isFinite(value));

    var triangulars = rng.sampleIter(f64, try Triangular(f64).init(-1, 0, 2));
    const triangular_value = triangulars.next().?;
    try std.testing.expect(triangular_value >= -1 and triangular_value <= 2);
    const direct_triangular = (try Triangular(f64).init(-1, 0, 2)).sampleFrom(&direct_engine);
    try std.testing.expect(direct_triangular >= -1 and direct_triangular <= 2);
    var triangular_buf: [8]f64 = undefined;
    fillTriangular(rng, f64, &triangular_buf, -1, 0, 2);
    for (triangular_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    var direct_triangular_buf: [8]f64 = undefined;
    fillTriangularFrom(&direct_engine, f64, &direct_triangular_buf, -1, 0, 2);
    for (direct_triangular_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    try fillTriangularChecked(rng, f64, &triangular_buf, -1, 0, 2);
    for (triangular_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    try fillTriangularCheckedFrom(&direct_engine, f64, &direct_triangular_buf, -1, 0, 2);
    for (direct_triangular_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    try std.testing.expectError(error.InvalidParameter, fillTriangularCheckedFrom(&direct_engine, f64, &direct_triangular_buf, 1, 0, 2));
    const triangular_sampler = try Triangular(f64).init(-1, 0, 2);
    try std.testing.expectApproxEqAbs(@as(f64, -1), triangular_sampler.minValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), triangular_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), triangular_sampler.maxValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 3.0), triangular_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 7.0 / 18.0), triangular_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(2.0 - @sqrt(@as(f64, 3)), triangular_sampler.medianValue(), 1e-12);
    triangular_sampler.fillFrom(&direct_engine, &direct_triangular_buf);
    for (direct_triangular_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    const direct_checked_triangular = try triangularCheckedFrom(&direct_engine, f64, -1, 0, 2);
    try std.testing.expect(direct_checked_triangular >= -1 and direct_checked_triangular <= 2);
    try std.testing.expectError(error.InvalidParameter, triangularCheckedFrom(&direct_engine, f64, 1, 0, 2));

    var arcsines = rng.sampleIter(f64, try Arcsine(f64).init(-1, 3));
    const arcsine_value = arcsines.next().?;
    try std.testing.expect(arcsine_value >= -1 and arcsine_value <= 3);
    var arcsine_buf: [8]f64 = undefined;
    fillArcsine(rng, f64, &arcsine_buf, -1, 3);
    for (arcsine_buf) |value| try std.testing.expect(value >= -1 and value <= 3);
    var direct_arcsine_buf: [8]f64 = undefined;
    fillArcsineFrom(&direct_engine, f64, &direct_arcsine_buf, -1, 3);
    for (direct_arcsine_buf) |value| try std.testing.expect(value >= -1 and value <= 3);
    try fillArcsineChecked(rng, f64, &arcsine_buf, -1, 3);
    for (arcsine_buf) |value| try std.testing.expect(value >= -1 and value <= 3);
    try fillArcsineCheckedFrom(&direct_engine, f64, &direct_arcsine_buf, -1, 3);
    for (direct_arcsine_buf) |value| try std.testing.expect(value >= -1 and value <= 3);
    try std.testing.expectError(error.InvalidParameter, fillArcsineCheckedFrom(&direct_engine, f64, &direct_arcsine_buf, 1, 1));
    const arcsine_sampler = try Arcsine(f64).init(-1, 3);
    try std.testing.expectApproxEqAbs(@as(f64, -1), arcsine_sampler.minValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), arcsine_sampler.maxValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), arcsine_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), arcsine_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), arcsine_sampler.medianValue(), 1e-12);
    arcsine_sampler.fillFrom(&direct_engine, &direct_arcsine_buf);
    for (direct_arcsine_buf) |value| try std.testing.expect(value >= -1 and value <= 3);
    const direct_checked_arcsine = try arcsineCheckedFrom(&direct_engine, f64, -1, 3);
    try std.testing.expect(direct_checked_arcsine >= -1 and direct_checked_arcsine <= 3);
    try std.testing.expectError(error.InvalidParameter, arcsineCheckedFrom(&direct_engine, f64, 1, 1));

    var cauchys = rng.sampleIter(f64, try Cauchy(f64).init(0, 1));
    _ = cauchys.next().?;
    try std.testing.expect(std.math.isFinite((try Cauchy(f64).init(0, 1)).sampleFrom(&direct_engine)));
    var cauchy_buf: [8]f64 = undefined;
    fillCauchy(rng, f64, &cauchy_buf, 0, 1);
    for (cauchy_buf) |value| try std.testing.expect(std.math.isFinite(value));
    var direct_cauchy_buf: [8]f64 = undefined;
    fillCauchyFrom(&direct_engine, f64, &direct_cauchy_buf, 0, 1);
    for (direct_cauchy_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillCauchyChecked(rng, f64, &cauchy_buf, 0, 1);
    for (cauchy_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillCauchyCheckedFrom(&direct_engine, f64, &direct_cauchy_buf, 0, 1);
    for (direct_cauchy_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try std.testing.expectError(error.InvalidParameter, fillCauchyCheckedFrom(&direct_engine, f64, &direct_cauchy_buf, 0, 0));
    const cauchy_sampler = try Cauchy(f64).init(0, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 0), cauchy_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), cauchy_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), cauchy_sampler.scaleValue(), 1e-12);
    try std.testing.expect(cauchy_sampler.expectedValue() == null);
    try std.testing.expect(cauchy_sampler.varianceValue() == null);
    try std.testing.expect(cauchy_sampler.minValue() == null);
    try std.testing.expect(cauchy_sampler.maxValue() == null);
    cauchy_sampler.fillFrom(&direct_engine, &direct_cauchy_buf);
    for (direct_cauchy_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try std.testing.expect(std.math.isFinite(try cauchyCheckedFrom(&direct_engine, f64, 0, 1)));
    try std.testing.expectError(error.InvalidParameter, cauchyCheckedFrom(&direct_engine, f64, 0, 0));

    var laplaces = rng.sampleIter(f64, try Laplace(f64).init(0, 1));
    try std.testing.expect(std.math.isFinite(laplaces.next().?));
    var laplace_buf: [8]f64 = undefined;
    fillLaplace(rng, f64, &laplace_buf, 0, 1);
    for (laplace_buf) |value| try std.testing.expect(std.math.isFinite(value));
    var direct_laplace_buf: [8]f64 = undefined;
    fillLaplaceFrom(&direct_engine, f64, &direct_laplace_buf, 0, 1);
    for (direct_laplace_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillLaplaceChecked(rng, f64, &laplace_buf, 0, 1);
    for (laplace_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillLaplaceCheckedFrom(&direct_engine, f64, &direct_laplace_buf, 0, 1);
    for (direct_laplace_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try std.testing.expectError(error.InvalidParameter, fillLaplaceCheckedFrom(&direct_engine, f64, &direct_laplace_buf, 0, 0));
    const laplace_sampler = try Laplace(f64).init(0, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 0), laplace_sampler.locationValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), laplace_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), laplace_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), laplace_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), laplace_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), laplace_sampler.varianceValue(), 1e-12);
    try std.testing.expect(laplace_sampler.minValue() == null);
    try std.testing.expect(laplace_sampler.maxValue() == null);
    laplace_sampler.fillFrom(&direct_engine, &direct_laplace_buf);
    for (direct_laplace_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try std.testing.expect(std.math.isFinite(try laplaceCheckedFrom(&direct_engine, f64, 0, 1)));
    try std.testing.expectError(error.InvalidParameter, laplaceCheckedFrom(&direct_engine, f64, 0, 0));

    var logistics = rng.sampleIter(f64, try Logistic(f64).init(0, 1));
    try std.testing.expect(std.math.isFinite(logistics.next().?));
    var logistic_buf: [8]f64 = undefined;
    fillLogistic(rng, f64, &logistic_buf, 0, 1);
    for (logistic_buf) |value| try std.testing.expect(std.math.isFinite(value));
    var direct_logistic_buf: [8]f64 = undefined;
    fillLogisticFrom(&direct_engine, f64, &direct_logistic_buf, 0, 1);
    for (direct_logistic_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillLogisticChecked(rng, f64, &logistic_buf, 0, 1);
    for (logistic_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillLogisticCheckedFrom(&direct_engine, f64, &direct_logistic_buf, 0, 1);
    for (direct_logistic_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try std.testing.expectError(error.InvalidParameter, fillLogisticCheckedFrom(&direct_engine, f64, &direct_logistic_buf, 0, 0));
    const logistic_sampler = try Logistic(f64).init(0, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 0), logistic_sampler.locationValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), logistic_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), logistic_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), logistic_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), logistic_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(std.math.pi * std.math.pi / 3.0, logistic_sampler.varianceValue(), 1e-12);
    try std.testing.expect(logistic_sampler.minValue() == null);
    try std.testing.expect(logistic_sampler.maxValue() == null);
    logistic_sampler.fillFrom(&direct_engine, &direct_logistic_buf);
    for (direct_logistic_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try std.testing.expect(std.math.isFinite(try logisticCheckedFrom(&direct_engine, f64, 0, 1)));
    try std.testing.expectError(error.InvalidParameter, logisticCheckedFrom(&direct_engine, f64, 0, 0));

    var log_logistics = rng.sampleIter(f64, try LogLogistic(f64).init(2, 3));
    try std.testing.expect(log_logistics.next().? > 0);
    var log_logistic_buf: [8]f64 = undefined;
    fillLogLogistic(rng, f64, &log_logistic_buf, 2, 3);
    for (log_logistic_buf) |value| try std.testing.expect(value > 0);
    var direct_log_logistic_buf: [8]f64 = undefined;
    fillLogLogisticFrom(&direct_engine, f64, &direct_log_logistic_buf, 2, 3);
    for (direct_log_logistic_buf) |value| try std.testing.expect(value > 0);
    try fillLogLogisticChecked(rng, f64, &log_logistic_buf, 2, 3);
    for (log_logistic_buf) |value| try std.testing.expect(value > 0);
    try fillLogLogisticCheckedFrom(&direct_engine, f64, &direct_log_logistic_buf, 2, 3);
    for (direct_log_logistic_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expectError(error.InvalidParameter, fillLogLogisticCheckedFrom(&direct_engine, f64, &direct_log_logistic_buf, 0, 3));
    const log_logistic_sampler = try LogLogistic(f64).init(2, 3);
    try std.testing.expectApproxEqAbs(@as(f64, 2), log_logistic_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), log_logistic_sampler.shapeValue(), 1e-12);
    const log_logistic_mean = @as(f64, 4) * std.math.pi / (3 * @sqrt(@as(f64, 3)));
    try std.testing.expectApproxEqAbs(log_logistic_mean, log_logistic_sampler.expectedValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 16) * std.math.pi / (3 * @sqrt(@as(f64, 3))) - log_logistic_mean * log_logistic_mean, log_logistic_sampler.varianceValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), log_logistic_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2) * std.math.pow(f64, 0.5, 1.0 / 3.0), log_logistic_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), log_logistic_sampler.minValue(), 0);
    try std.testing.expect(log_logistic_sampler.maxValue() == null);
    try std.testing.expect((try LogLogistic(f64).init(2, 1)).expectedValue() == null);
    try std.testing.expect((try LogLogistic(f64).init(2, 2)).varianceValue() == null);
    log_logistic_sampler.fillFrom(&direct_engine, &direct_log_logistic_buf);
    for (direct_log_logistic_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expect(try logLogisticCheckedFrom(&direct_engine, f64, 2, 3) > 0);
    try std.testing.expectError(error.InvalidParameter, logLogisticCheckedFrom(&direct_engine, f64, 0, 3));
    var log_logistic_shape_one_buf: [8]f64 = undefined;
    fillLogLogisticFrom(&direct_engine, f64, &log_logistic_shape_one_buf, 2, 1);
    for (log_logistic_shape_one_buf) |value| try std.testing.expect(value > 0 and std.math.isFinite(value));

    var kumaraswamys = rng.sampleIter(f64, try Kumaraswamy(f64).init(2, 5));
    const kumaraswamy_value = kumaraswamys.next().?;
    try std.testing.expect(kumaraswamy_value >= 0 and kumaraswamy_value <= 1);
    var kumaraswamy_buf: [8]f64 = undefined;
    fillKumaraswamy(rng, f64, &kumaraswamy_buf, 2, 5);
    for (kumaraswamy_buf) |value| try std.testing.expect(value >= 0 and value <= 1);
    var direct_kumaraswamy_buf: [8]f64 = undefined;
    fillKumaraswamyFrom(&direct_engine, f64, &direct_kumaraswamy_buf, 2, 5);
    for (direct_kumaraswamy_buf) |value| try std.testing.expect(value >= 0 and value <= 1);
    try fillKumaraswamyChecked(rng, f64, &kumaraswamy_buf, 2, 5);
    for (kumaraswamy_buf) |value| try std.testing.expect(value >= 0 and value <= 1);
    try fillKumaraswamyCheckedFrom(&direct_engine, f64, &direct_kumaraswamy_buf, 2, 5);
    for (direct_kumaraswamy_buf) |value| try std.testing.expect(value >= 0 and value <= 1);
    try std.testing.expectError(error.InvalidParameter, fillKumaraswamyCheckedFrom(&direct_engine, f64, &direct_kumaraswamy_buf, 0, 5));
    const kumaraswamy_sampler = try Kumaraswamy(f64).init(2, 5);
    try std.testing.expectApproxEqAbs(@as(f64, 2), kumaraswamy_sampler.alphaValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5), kumaraswamy_sampler.betaValue(), 1e-12);
    const kumaraswamy_first_moment = 5.0 * @exp(std.math.lgamma(f64, 1.0 + 1.0 / 2.0) + std.math.lgamma(f64, 5.0) - std.math.lgamma(f64, 1.0 + 1.0 / 2.0 + 5.0));
    const kumaraswamy_second_moment = 5.0 * @exp(std.math.lgamma(f64, 1.0 + 2.0 / 2.0) + std.math.lgamma(f64, 5.0) - std.math.lgamma(f64, 1.0 + 2.0 / 2.0 + 5.0));
    try std.testing.expectApproxEqAbs(kumaraswamy_first_moment, kumaraswamy_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(kumaraswamy_second_moment - kumaraswamy_first_moment * kumaraswamy_first_moment, kumaraswamy_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 3.0), kumaraswamy_sampler.modeValue().?, 1e-12);
    try std.testing.expect((try Kumaraswamy(f64).init(1, 1)).modeValue() == null);
    try std.testing.expect((try Kumaraswamy(f64).init(0.5, 0.5)).modeValue() == null);
    try std.testing.expectApproxEqAbs(@as(f64, 0), (try Kumaraswamy(f64).init(1, 5)).modeValue().?, 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1), (try Kumaraswamy(f64).init(2, 1)).modeValue().?, 0);
    try std.testing.expectApproxEqAbs(@sqrt(1.0 - std.math.pow(f64, 0.5, 1.0 / 5.0)), kumaraswamy_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), kumaraswamy_sampler.minValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1), kumaraswamy_sampler.maxValue(), 0);
    kumaraswamy_sampler.fillFrom(&direct_engine, &direct_kumaraswamy_buf);
    for (direct_kumaraswamy_buf) |value| try std.testing.expect(value >= 0 and value <= 1);
    const direct_checked_kumaraswamy = try kumaraswamyCheckedFrom(&direct_engine, f64, 2, 5);
    try std.testing.expect(direct_checked_kumaraswamy >= 0 and direct_checked_kumaraswamy <= 1);
    try std.testing.expectError(error.InvalidParameter, kumaraswamyCheckedFrom(&direct_engine, f64, 0, 5));
    var kumaraswamy_beta_one_buf: [8]f64 = undefined;
    fillKumaraswamyFrom(&direct_engine, f64, &kumaraswamy_beta_one_buf, 2, 1);
    for (kumaraswamy_beta_one_buf) |value| try std.testing.expect(value >= 0 and value <= 1);
    var kumaraswamy_alpha_one_buf: [8]f64 = undefined;
    fillKumaraswamyFrom(&direct_engine, f64, &kumaraswamy_alpha_one_buf, 1, 5);
    for (kumaraswamy_alpha_one_buf) |value| try std.testing.expect(value >= 0 and value <= 1);

    var power_functions = rng.sampleIter(f64, try PowerFunction(f64).init(-1, 2, 3));
    const power_value = power_functions.next().?;
    try std.testing.expect(power_value >= -1 and power_value <= 2);
    var power_function_buf: [8]f64 = undefined;
    fillPowerFunction(rng, f64, &power_function_buf, -1, 2, 3);
    for (power_function_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    var direct_power_function_buf: [8]f64 = undefined;
    fillPowerFunctionFrom(&direct_engine, f64, &direct_power_function_buf, -1, 2, 3);
    for (direct_power_function_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    try fillPowerFunctionChecked(rng, f64, &power_function_buf, -1, 2, 3);
    for (power_function_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    try fillPowerFunctionCheckedFrom(&direct_engine, f64, &direct_power_function_buf, -1, 2, 3);
    for (direct_power_function_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    try std.testing.expectError(error.InvalidParameter, fillPowerFunctionCheckedFrom(&direct_engine, f64, &direct_power_function_buf, -1, 2, 0));
    const power_function_sampler = try PowerFunction(f64).init(-1, 2, 3);
    try std.testing.expectApproxEqAbs(@as(f64, -1), power_function_sampler.minValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), power_function_sampler.maxValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), power_function_sampler.shapeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.25), power_function_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 27.0 / 80.0), power_function_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(-1.0 + 3.0 * std.math.pow(f64, 0.5, 1.0 / 3.0), power_function_sampler.medianValue(), 1e-12);
    power_function_sampler.fillFrom(&direct_engine, &direct_power_function_buf);
    for (direct_power_function_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    const direct_checked_power = try powerFunctionCheckedFrom(&direct_engine, f64, -1, 2, 3);
    try std.testing.expect(direct_checked_power >= -1 and direct_checked_power <= 2);
    try std.testing.expectError(error.InvalidParameter, powerFunctionCheckedFrom(&direct_engine, f64, -1, 2, 0));
    var power_function_shape_one_buf: [8]f64 = undefined;
    fillPowerFunctionFrom(&direct_engine, f64, &power_function_shape_one_buf, -1, 2, 1);
    for (power_function_shape_one_buf) |value| try std.testing.expect(value >= -1 and value < 2);
    var power_function_shape_two_buf: [8]f64 = undefined;
    fillPowerFunctionFrom(&direct_engine, f64, &power_function_shape_two_buf, -1, 2, 2);
    for (power_function_shape_two_buf) |value| try std.testing.expect(value >= -1 and value <= 2);

    var rayleighs = rng.sampleIter(f64, try Rayleigh(f64).init(2));
    try std.testing.expect(rayleighs.next().? >= 0);
    var rayleigh_buf: [8]f64 = undefined;
    fillRayleigh(rng, f64, &rayleigh_buf, 2);
    for (rayleigh_buf) |value| try std.testing.expect(value >= 0);
    var direct_rayleigh_buf: [8]f64 = undefined;
    fillRayleighFrom(&direct_engine, f64, &direct_rayleigh_buf, 2);
    for (direct_rayleigh_buf) |value| try std.testing.expect(value >= 0);
    try fillRayleighChecked(rng, f64, &rayleigh_buf, 2);
    for (rayleigh_buf) |value| try std.testing.expect(value >= 0);
    try fillRayleighCheckedFrom(&direct_engine, f64, &direct_rayleigh_buf, 2);
    for (direct_rayleigh_buf) |value| try std.testing.expect(value >= 0);
    try std.testing.expectError(error.InvalidParameter, fillRayleighCheckedFrom(&direct_engine, f64, &direct_rayleigh_buf, 0));
    const rayleigh_sampler = try Rayleigh(f64).init(2);
    try std.testing.expectApproxEqAbs(@as(f64, 2), rayleigh_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2) * @sqrt(std.math.pi / 2.0), rayleigh_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2) * (4 - std.math.pi), rayleigh_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2) * @sqrt(2.0 * @log(@as(f64, 2))), rayleigh_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), rayleigh_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), rayleigh_sampler.minValue(), 0);
    try std.testing.expect(rayleigh_sampler.maxValue() == null);
    rayleigh_sampler.fillFrom(&direct_engine, &direct_rayleigh_buf);
    for (direct_rayleigh_buf) |value| try std.testing.expect(value >= 0);
    try std.testing.expect(try rayleighCheckedFrom(&direct_engine, f64, 2) >= 0);
    try std.testing.expectError(error.InvalidParameter, rayleighCheckedFrom(&direct_engine, f64, 0));

    var maxwells = rng.sampleIter(f64, try Maxwell(f64).init(2));
    try std.testing.expect(maxwells.next().? >= 0);
    var maxwell_buf: [8]f64 = undefined;
    fillMaxwell(rng, f64, &maxwell_buf, 2);
    for (maxwell_buf) |value| try std.testing.expect(value >= 0);
    var direct_maxwell_buf: [8]f64 = undefined;
    fillMaxwellFrom(&direct_engine, f64, &direct_maxwell_buf, 2);
    for (direct_maxwell_buf) |value| try std.testing.expect(value >= 0);
    try fillMaxwellChecked(rng, f64, &maxwell_buf, 2);
    for (maxwell_buf) |value| try std.testing.expect(value >= 0);
    try fillMaxwellCheckedFrom(&direct_engine, f64, &direct_maxwell_buf, 2);
    for (direct_maxwell_buf) |value| try std.testing.expect(value >= 0);
    try std.testing.expectError(error.InvalidParameter, fillMaxwellCheckedFrom(&direct_engine, f64, &direct_maxwell_buf, 0));
    const maxwell_sampler = try Maxwell(f64).init(2);
    try std.testing.expectApproxEqAbs(@as(f64, 2), maxwell_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4) * @sqrt(2.0 / std.math.pi), maxwell_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4) * (3 * std.math.pi - 8) / std.math.pi, maxwell_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2) * @sqrt(@as(f64, 2)), maxwell_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), maxwell_sampler.minValue(), 0);
    try std.testing.expect(maxwell_sampler.maxValue() == null);
    maxwell_sampler.fillFrom(&direct_engine, &direct_maxwell_buf);
    for (direct_maxwell_buf) |value| try std.testing.expect(value >= 0);
    try std.testing.expect(try maxwellCheckedFrom(&direct_engine, f64, 2) >= 0);
    try std.testing.expectError(error.InvalidParameter, maxwellCheckedFrom(&direct_engine, f64, 0));

    var paretos = rng.sampleIter(f64, try Pareto(f64).init(2, 3));
    try std.testing.expect(paretos.next().? >= 2);
    try std.testing.expect((try Pareto(f64).init(2, 3)).sampleFrom(&direct_engine) >= 2);
    var pareto_buf: [8]f64 = undefined;
    fillPareto(rng, f64, &pareto_buf, 2, 3);
    for (pareto_buf) |value| try std.testing.expect(value >= 2);
    var direct_pareto_buf: [8]f64 = undefined;
    fillParetoFrom(&direct_engine, f64, &direct_pareto_buf, 2, 3);
    for (direct_pareto_buf) |value| try std.testing.expect(value >= 2);
    try fillParetoChecked(rng, f64, &pareto_buf, 2, 3);
    for (pareto_buf) |value| try std.testing.expect(value >= 2);
    try fillParetoCheckedFrom(&direct_engine, f64, &direct_pareto_buf, 2, 3);
    for (direct_pareto_buf) |value| try std.testing.expect(value >= 2);
    try std.testing.expectError(error.InvalidParameter, fillParetoCheckedFrom(&direct_engine, f64, &direct_pareto_buf, 0, 3));
    const pareto_sampler = try Pareto(f64).init(2, 3);
    try std.testing.expectApproxEqAbs(@as(f64, 2), pareto_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), pareto_sampler.shapeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), pareto_sampler.expectedValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), pareto_sampler.varianceValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2) * std.math.pow(f64, 2, 1.0 / 3.0), pareto_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), pareto_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), pareto_sampler.minValue(), 0);
    try std.testing.expect(pareto_sampler.maxValue() == null);
    try std.testing.expect((try Pareto(f64).init(2, 1)).expectedValue() == null);
    try std.testing.expect((try Pareto(f64).init(2, 2)).varianceValue() == null);
    pareto_sampler.fillFrom(&direct_engine, &direct_pareto_buf);
    for (direct_pareto_buf) |value| try std.testing.expect(value >= 2);
    try std.testing.expect(try paretoCheckedFrom(&direct_engine, f64, 2, 3) >= 2);
    try std.testing.expectError(error.InvalidParameter, paretoCheckedFrom(&direct_engine, f64, 0, 3));
    var pareto_shape_one_buf: [8]f64 = undefined;
    fillParetoFrom(&direct_engine, f64, &pareto_shape_one_buf, 2, 1);
    for (pareto_shape_one_buf) |value| try std.testing.expect(value >= 2);

    var weibulls = rng.sampleIter(f64, try Weibull(f64).init(2, 1.5));
    try std.testing.expect(weibulls.next().? >= 0);
    try std.testing.expect((try Weibull(f64).init(2, 1.5)).sampleFrom(&direct_engine) >= 0);
    var weibull_buf: [8]f64 = undefined;
    fillWeibull(rng, f64, &weibull_buf, 2, 1.5);
    for (weibull_buf) |value| try std.testing.expect(value >= 0);
    var direct_weibull_buf: [8]f64 = undefined;
    fillWeibullFrom(&direct_engine, f64, &direct_weibull_buf, 2, 1.5);
    for (direct_weibull_buf) |value| try std.testing.expect(value >= 0);
    try fillWeibullChecked(rng, f64, &weibull_buf, 2, 1.5);
    for (weibull_buf) |value| try std.testing.expect(value >= 0);
    try fillWeibullCheckedFrom(&direct_engine, f64, &direct_weibull_buf, 2, 1.5);
    for (direct_weibull_buf) |value| try std.testing.expect(value >= 0);
    try std.testing.expectError(error.InvalidParameter, fillWeibullCheckedFrom(&direct_engine, f64, &direct_weibull_buf, 0, 1.5));
    const weibull_sampler = try Weibull(f64).init(2, 1.5);
    try std.testing.expectApproxEqAbs(@as(f64, 2), weibull_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.5), weibull_sampler.shapeValue(), 1e-12);
    const weibull_mean_factor = std.math.gamma(f64, 1.0 + 1.0 / 1.5);
    const weibull_second_moment_factor = std.math.gamma(f64, 1.0 + 2.0 / 1.5);
    try std.testing.expectApproxEqAbs(2.0 * weibull_mean_factor, weibull_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(4.0 * (weibull_second_moment_factor - weibull_mean_factor * weibull_mean_factor), weibull_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2) * std.math.pow(f64, @log(@as(f64, 2)), 1.0 / 1.5), weibull_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(2.0 * std.math.pow(f64, (1.5 - 1.0) / 1.5, 1.0 / 1.5), weibull_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), weibull_sampler.minValue(), 0);
    try std.testing.expect(weibull_sampler.maxValue() == null);
    weibull_sampler.fillFrom(&direct_engine, &direct_weibull_buf);
    for (direct_weibull_buf) |value| try std.testing.expect(value >= 0);
    try std.testing.expect(try weibullCheckedFrom(&direct_engine, f64, 2, 1.5) >= 0);
    try std.testing.expectError(error.InvalidParameter, weibullCheckedFrom(&direct_engine, f64, 0, 1.5));
    var weibull_shape_one_buf: [8]f64 = undefined;
    fillWeibullFrom(&direct_engine, f64, &weibull_shape_one_buf, 2, 1);
    for (weibull_shape_one_buf) |value| try std.testing.expect(value >= 0);

    var gumbels = rng.sampleIter(f64, try Gumbel(f64).init(0, 1));
    try std.testing.expect(std.math.isFinite(gumbels.next().?));
    try std.testing.expect(std.math.isFinite((try Gumbel(f64).init(0, 1)).sampleFrom(&direct_engine)));
    var gumbel_buf: [8]f64 = undefined;
    fillGumbel(rng, f64, &gumbel_buf, 0, 1);
    for (gumbel_buf) |value| try std.testing.expect(std.math.isFinite(value));
    var direct_gumbel_buf: [8]f64 = undefined;
    fillGumbelFrom(&direct_engine, f64, &direct_gumbel_buf, 0, 1);
    for (direct_gumbel_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillGumbelChecked(rng, f64, &gumbel_buf, 0, 1);
    for (gumbel_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillGumbelCheckedFrom(&direct_engine, f64, &direct_gumbel_buf, 0, 1);
    for (direct_gumbel_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try std.testing.expectError(error.InvalidParameter, fillGumbelCheckedFrom(&direct_engine, f64, &direct_gumbel_buf, 0, 0));
    const gumbel_sampler = try Gumbel(f64).init(0, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 0), gumbel_sampler.locationValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), gumbel_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5772156649015329), gumbel_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(std.math.pi * std.math.pi / 6.0, gumbel_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(-@log(@log(@as(f64, 2))), gumbel_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), gumbel_sampler.modeValue(), 1e-12);
    try std.testing.expect(gumbel_sampler.minValue() == null);
    try std.testing.expect(gumbel_sampler.maxValue() == null);
    gumbel_sampler.fillFrom(&direct_engine, &direct_gumbel_buf);
    for (direct_gumbel_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try std.testing.expect(std.math.isFinite(try gumbelCheckedFrom(&direct_engine, f64, 0, 1)));
    try std.testing.expectError(error.InvalidParameter, gumbelCheckedFrom(&direct_engine, f64, 0, 0));

    var frechets = rng.sampleIter(f64, try Frechet(f64).init(0, 1, 2));
    try std.testing.expect(frechets.next().? >= 0);
    try std.testing.expect((try Frechet(f64).init(0, 1, 2)).sampleFrom(&direct_engine) >= 0);
    var frechet_buf: [8]f64 = undefined;
    fillFrechet(rng, f64, &frechet_buf, 0, 1, 2);
    for (frechet_buf) |value| try std.testing.expect(value >= 0);
    var direct_frechet_buf: [8]f64 = undefined;
    fillFrechetFrom(&direct_engine, f64, &direct_frechet_buf, 0, 1, 2);
    for (direct_frechet_buf) |value| try std.testing.expect(value >= 0);
    try fillFrechetChecked(rng, f64, &frechet_buf, 0, 1, 2);
    for (frechet_buf) |value| try std.testing.expect(value >= 0);
    try fillFrechetCheckedFrom(&direct_engine, f64, &direct_frechet_buf, 0, 1, 2);
    for (direct_frechet_buf) |value| try std.testing.expect(value >= 0);
    try std.testing.expectError(error.InvalidParameter, fillFrechetCheckedFrom(&direct_engine, f64, &direct_frechet_buf, 0, 1, 0));
    const frechet_sampler = try Frechet(f64).init(0, 1, 2);
    try std.testing.expectApproxEqAbs(@as(f64, 0), frechet_sampler.locationValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), frechet_sampler.scaleValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), frechet_sampler.shapeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@sqrt(std.math.pi), frechet_sampler.expectedValue().?, 1e-12);
    try std.testing.expect(frechet_sampler.varianceValue() == null);
    try std.testing.expectApproxEqAbs(1.0 / @sqrt(@log(@as(f64, 2))), frechet_sampler.medianValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@sqrt(@as(f64, 2.0 / 3.0)), frechet_sampler.modeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), frechet_sampler.minValue(), 0);
    try std.testing.expect(frechet_sampler.maxValue() == null);
    const frechet_finite_moments = try Frechet(f64).init(0, 1, 3);
    const frechet_mean_factor = std.math.gamma(f64, 1.0 - 1.0 / 3.0);
    const frechet_second_moment_factor = std.math.gamma(f64, 1.0 - 2.0 / 3.0);
    try std.testing.expectApproxEqAbs(frechet_mean_factor, frechet_finite_moments.expectedValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(frechet_second_moment_factor - frechet_mean_factor * frechet_mean_factor, frechet_finite_moments.varianceValue().?, 1e-12);
    try std.testing.expect((try Frechet(f64).init(0, 1, 1)).expectedValue() == null);
    frechet_sampler.fillFrom(&direct_engine, &direct_frechet_buf);
    for (direct_frechet_buf) |value| try std.testing.expect(value >= 0);
    try std.testing.expect(try frechetCheckedFrom(&direct_engine, f64, 0, 1, 2) >= 0);
    try std.testing.expectError(error.InvalidParameter, frechetCheckedFrom(&direct_engine, f64, 0, 1, 0));
    var frechet_shape_one_buf: [8]f64 = undefined;
    fillFrechetFrom(&direct_engine, f64, &frechet_shape_one_buf, 0, 1, 1);
    for (frechet_shape_one_buf) |value| try std.testing.expect(value >= 0);

    var skew_normals = rng.sampleIter(f64, try SkewNormal(f64).init(0, 1, 1));
    try std.testing.expect(std.math.isFinite(skew_normals.next().?));
    var skew_normal_buf: [8]f64 = undefined;
    fillSkewNormal(rng, f64, &skew_normal_buf, 0, 1, 1);
    for (skew_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));
    var direct_skew_normal_buf: [8]f64 = undefined;
    fillSkewNormalFrom(&direct_engine, f64, &direct_skew_normal_buf, 0, 1, 1);
    for (direct_skew_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillSkewNormalChecked(rng, f64, &skew_normal_buf, 0, 1, 1);
    for (skew_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillSkewNormalCheckedFrom(&direct_engine, f64, &direct_skew_normal_buf, 0, 1, 1);
    for (direct_skew_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try std.testing.expectError(error.InvalidParameter, fillSkewNormalCheckedFrom(&direct_engine, f64, &direct_skew_normal_buf, 0, 0, 1));
    const skew_normal_sampler = try SkewNormal(f64).init(0, 1, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 0), skew_normal_sampler.locationValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1), skew_normal_sampler.scaleValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1), skew_normal_sampler.shapeValue(), 0);
    const skew_normal_delta = 1.0 / @sqrt(2.0);
    try std.testing.expectApproxEqAbs(skew_normal_delta * @sqrt(2.0 / std.math.pi), skew_normal_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(1.0 - 2.0 * skew_normal_delta * skew_normal_delta / std.math.pi, skew_normal_sampler.varianceValue(), 1e-12);
    try std.testing.expect(skew_normal_sampler.minValue() == null);
    try std.testing.expect(skew_normal_sampler.maxValue() == null);
    skew_normal_sampler.fillFrom(&direct_engine, &direct_skew_normal_buf);
    for (direct_skew_normal_buf) |value| try std.testing.expect(std.math.isFinite(value));

    var perts = rng.sampleIter(f64, try Pert(f64).initDefault(-1, 0, 2));
    const pert_value = perts.next().?;
    try std.testing.expect(pert_value >= -1 and pert_value <= 2);
    const direct_pert = (try Pert(f64).initDefault(-1, 0, 2)).sampleFrom(&direct_engine);
    try std.testing.expect(direct_pert >= -1 and direct_pert <= 2);
    var pert_buf: [8]f64 = undefined;
    fillPert(rng, f64, &pert_buf, -1, 0.5, 2, 4);
    for (pert_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    var direct_pert_buf: [8]f64 = undefined;
    fillPertFrom(&direct_engine, f64, &direct_pert_buf, -1, 0.5, 2, 4);
    for (direct_pert_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    try fillPertChecked(rng, f64, &pert_buf, -1, 0.5, 2, 4);
    for (pert_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    try fillPertCheckedFrom(&direct_engine, f64, &direct_pert_buf, -1, 0.5, 2, 4);
    for (direct_pert_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    try std.testing.expectError(error.InvalidParameter, fillPertCheckedFrom(&direct_engine, f64, &direct_pert_buf, 0, 2, 1, 4));
    const pert_sampler = try Pert(f64).init(-1, 0.5, 2, 4);
    try std.testing.expectApproxEqAbs(@as(f64, -1), pert_sampler.minValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), pert_sampler.maxValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4), pert_sampler.shapeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), pert_sampler.modeValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), pert_sampler.alphaValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), pert_sampler.betaValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), pert_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 9.0 / 28.0), pert_sampler.varianceValue(), 1e-12);
    pert_sampler.fillFrom(&direct_engine, &direct_pert_buf);
    for (direct_pert_buf) |value| try std.testing.expect(value >= -1 and value <= 2);
    const pert_builder = Pert(f64).initRange(-1, 2).withShape(4);
    try std.testing.expectApproxEqAbs(@as(f64, -1), pert_builder.minValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), pert_builder.maxValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4), pert_builder.shapeValue(), 1e-12);
    const pert_builder_mode = try pert_builder.withMode(0.5);
    try std.testing.expectApproxEqAbs(pert_sampler.alpha, pert_builder_mode.alpha, 1e-12);
    try std.testing.expectApproxEqAbs(pert_sampler.beta_param, pert_builder_mode.beta_param, 1e-12);

    var inverse_gaussians = rng.sampleIter(f64, try InverseGaussian(f64).init(1, 2));
    try std.testing.expect(inverse_gaussians.next().? > 0);
    var inverse_gaussian_buf: [8]f64 = undefined;
    fillInverseGaussian(rng, f64, &inverse_gaussian_buf, 1, 2);
    for (inverse_gaussian_buf) |value| try std.testing.expect(value > 0);
    var direct_inverse_gaussian_buf: [8]f64 = undefined;
    fillInverseGaussianFrom(&direct_engine, f64, &direct_inverse_gaussian_buf, 1, 2);
    for (direct_inverse_gaussian_buf) |value| try std.testing.expect(value > 0);
    try fillInverseGaussianChecked(rng, f64, &inverse_gaussian_buf, 1, 2);
    for (inverse_gaussian_buf) |value| try std.testing.expect(value > 0);
    try fillInverseGaussianCheckedFrom(&direct_engine, f64, &direct_inverse_gaussian_buf, 1, 2);
    for (direct_inverse_gaussian_buf) |value| try std.testing.expect(value > 0);
    try std.testing.expectError(error.InvalidParameter, fillInverseGaussianCheckedFrom(&direct_engine, f64, &direct_inverse_gaussian_buf, 0, 2));
    const inverse_gaussian_sampler = try InverseGaussian(f64).init(1, 2);
    try std.testing.expectApproxEqAbs(@as(f64, 1), inverse_gaussian_sampler.meanValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), inverse_gaussian_sampler.shapeValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), inverse_gaussian_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), inverse_gaussian_sampler.varianceValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), inverse_gaussian_sampler.minValue(), 0);
    try std.testing.expect(inverse_gaussian_sampler.maxValue() == null);
    inverse_gaussian_sampler.fillFrom(&direct_engine, &direct_inverse_gaussian_buf);
    for (direct_inverse_gaussian_buf) |value| try std.testing.expect(value > 0);

    var normal_inverse_gaussians = rng.sampleIter(f64, try NormalInverseGaussian(f64).init(2, 1));
    try std.testing.expect(std.math.isFinite(normal_inverse_gaussians.next().?));
    var nig_buf: [8]f64 = undefined;
    fillNormalInverseGaussian(rng, f64, &nig_buf, 2, 1);
    for (nig_buf) |value| try std.testing.expect(std.math.isFinite(value));
    var direct_nig_buf: [8]f64 = undefined;
    fillNormalInverseGaussianFrom(&direct_engine, f64, &direct_nig_buf, 2, 1);
    for (direct_nig_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillNormalInverseGaussianChecked(rng, f64, &nig_buf, 2, 1);
    for (nig_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try fillNormalInverseGaussianCheckedFrom(&direct_engine, f64, &direct_nig_buf, 2, 1);
    for (direct_nig_buf) |value| try std.testing.expect(std.math.isFinite(value));
    try std.testing.expectError(error.InvalidParameter, fillNormalInverseGaussianCheckedFrom(&direct_engine, f64, &direct_nig_buf, 1, 1));
    const nig_sampler = try NormalInverseGaussian(f64).init(2, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 2), nig_sampler.alphaValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), nig_sampler.betaValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@sqrt(@as(f64, 3)), nig_sampler.gammaValue(), 1e-12);
    try std.testing.expectApproxEqAbs(1.0 / @sqrt(@as(f64, 3)), nig_sampler.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(4.0 / (3.0 * @sqrt(@as(f64, 3))), nig_sampler.varianceValue(), 1e-12);
    try std.testing.expect(nig_sampler.minValue() == null);
    try std.testing.expect(nig_sampler.maxValue() == null);
    nig_sampler.fillFrom(&direct_engine, &direct_nig_buf);
    for (direct_nig_buf) |value| try std.testing.expect(std.math.isFinite(value));

    var zipfs = rng.sampleIter(f64, try Zipf(f64).init(10, 1.5));
    const zipf_value = zipfs.next().?;
    try std.testing.expect(zipf_value >= 1 and zipf_value <= 10);
    const direct_zipf = (try Zipf(f64).init(10, 1.5)).sampleFrom(&direct_engine);
    try std.testing.expect(direct_zipf >= 1 and direct_zipf <= 10);
    const zipf_sampler = try Zipf(f64).init(10, 1.5);
    try std.testing.expectApproxEqAbs(@as(f64, 1), zipf_sampler.minValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 10), zipf_sampler.maxValue(), 1e-12);
    var zipf_buf: [8]f64 = undefined;
    zipf_sampler.fill(rng, &zipf_buf);
    for (zipf_buf) |value| try std.testing.expect(value >= 1 and value <= 10);
    var direct_zipf_buf: [8]f64 = undefined;
    zipf_sampler.fillFrom(&direct_engine, &direct_zipf_buf);
    for (direct_zipf_buf) |value| try std.testing.expect(value >= 1 and value <= 10);
    fillZipf(rng, f64, &zipf_buf, 10, 1.5);
    for (zipf_buf) |value| try std.testing.expect(value >= 1 and value <= 10);
    fillZipfFrom(&direct_engine, f64, &direct_zipf_buf, 10, 1.5);
    for (direct_zipf_buf) |value| try std.testing.expect(value >= 1 and value <= 10);
    try fillZipfChecked(rng, f64, &zipf_buf, 10, 1.5);
    for (zipf_buf) |value| try std.testing.expect(value >= 1 and value <= 10);
    try fillZipfCheckedFrom(&direct_engine, f64, &direct_zipf_buf, 10, 1.5);
    for (direct_zipf_buf) |value| try std.testing.expect(value >= 1 and value <= 10);
    try std.testing.expectError(error.InvalidParameter, fillZipfCheckedFrom(&direct_engine, f64, &direct_zipf_buf, 0, 1));

    var zetas = rng.sampleIter(f64, try Zeta(f64).init(3));
    try std.testing.expect(zetas.next().? >= 1);
    try std.testing.expect((try Zeta(f64).init(3)).sampleFrom(&direct_engine) >= 1);
    const zeta_sampler = try Zeta(f64).init(3);
    try std.testing.expectApproxEqAbs(@as(f64, 1), zeta_sampler.minValue(), 0);
    try std.testing.expect(zeta_sampler.maxValue() == null);
    var zeta_buf: [8]f64 = undefined;
    zeta_sampler.fill(rng, &zeta_buf);
    for (zeta_buf) |value| try std.testing.expect(value >= 1);
    var direct_zeta_buf: [8]f64 = undefined;
    zeta_sampler.fillFrom(&direct_engine, &direct_zeta_buf);
    for (direct_zeta_buf) |value| try std.testing.expect(value >= 1);
    fillZeta(rng, f64, &zeta_buf, 3);
    for (zeta_buf) |value| try std.testing.expect(value >= 1);
    fillZetaFrom(&direct_engine, f64, &direct_zeta_buf, 3);
    for (direct_zeta_buf) |value| try std.testing.expect(value >= 1);
    try fillZetaChecked(rng, f64, &zeta_buf, 3);
    for (zeta_buf) |value| try std.testing.expect(value >= 1);
    try fillZetaCheckedFrom(&direct_engine, f64, &direct_zeta_buf, 3);
    for (direct_zeta_buf) |value| try std.testing.expect(value >= 1);
    try std.testing.expectError(error.InvalidParameter, fillZetaCheckedFrom(&direct_engine, f64, &direct_zeta_buf, 1));

    var unit_circles = rng.sampleIter([2]f64, UnitCircle(f64){});
    const unit_circle = unit_circles.next().?;
    try std.testing.expectApproxEqAbs(@as(f64, 1), unit_circle[0] * unit_circle[0] + unit_circle[1] * unit_circle[1], 1e-12);

    var unit_spheres = rng.sampleIter([3]f64, UnitSphere(f64){});
    const unit_sphere = unit_spheres.next().?;
    try std.testing.expectApproxEqAbs(@as(f64, 1), unit_sphere[0] * unit_sphere[0] + unit_sphere[1] * unit_sphere[1] + unit_sphere[2] * unit_sphere[2], 1e-12);

    try std.testing.expectError(error.InvalidParameter, Normal(f64).init(0, -1));
    try std.testing.expectError(error.InvalidParameter, Normal(f64).initMeanCv(0, -1));
    try std.testing.expectError(error.InvalidParameter, Exponential(f64).init(0));
    try std.testing.expectError(error.InvalidParameter, LogNormal(f64).init(0, -1));
    try std.testing.expectError(error.InvalidParameter, LogNormal(f64).initMeanCv(-1, 0.5));
    try std.testing.expectError(error.InvalidParameter, LogNormal(f64).initMeanCv(1, -0.5));
    try std.testing.expectError(error.InvalidParameter, HalfNormal(f64).init(0));
    try std.testing.expectError(error.EmptyRange, Uniform(f64).init(std.math.inf(f64), 1));
    try std.testing.expectError(error.EmptyRange, Uniform(f64).initInclusive(0, std.math.inf(f64)));
    try std.testing.expectError(error.InvalidParameter, Poisson.init(std.math.inf(f64)));
    try std.testing.expectError(error.InvalidProbability, Geometric.init(0));
    try std.testing.expectError(error.InvalidParameter, Gamma(f64).init(0, 1));
    try std.testing.expectError(error.InvalidParameter, ChiSquared(f64).init(0));
    try std.testing.expectError(error.InvalidParameter, Chi(f64).init(0));
    try std.testing.expectError(error.InvalidParameter, Erlang(f64).init(0, 1));
    try std.testing.expectError(error.InvalidParameter, Beta(f64).init(1, 0));
    try std.testing.expectError(error.InvalidParameter, FisherF(f64).init(0, 1));
    try std.testing.expectError(error.InvalidParameter, StudentT(f64).init(0));
    try std.testing.expectError(error.InvalidParameter, Triangular(f64).init(1, 0, 2));
    try std.testing.expectError(error.InvalidParameter, Arcsine(f64).init(1, 1));
    try std.testing.expectError(error.InvalidParameter, Cauchy(f64).init(0, 0));
    try std.testing.expectError(error.InvalidParameter, Laplace(f64).init(0, 0));
    try std.testing.expectError(error.InvalidParameter, Logistic(f64).init(0, 0));
    try std.testing.expectError(error.InvalidParameter, LogLogistic(f64).init(0, 1));
    try std.testing.expectError(error.InvalidParameter, Kumaraswamy(f64).init(0, 1));
    try std.testing.expectError(error.InvalidParameter, PowerFunction(f64).init(0, 1, 0));
    try std.testing.expectError(error.InvalidParameter, Rayleigh(f64).init(0));
    try std.testing.expectError(error.InvalidParameter, Maxwell(f64).init(0));
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
    var direct_engine = alea.ScalarPrng.init(68);
    try std.testing.expect((try Binomial.init(8, 0.5)).sampleFrom(&direct_engine) <= 8);
    var binomial_buf: [8]u64 = undefined;
    fillBinomial(rng, &binomial_buf, 8, 0.5);
    for (binomial_buf) |value| try std.testing.expect(value <= 8);
    fillBinomialFrom(&direct_engine, &binomial_buf, 8, 0.5);
    for (binomial_buf) |value| try std.testing.expect(value <= 8);
    try std.testing.expect(binomialPoissonApprox(rng, 10_000, 0.01) < 200);
    try std.testing.expect(binomialPoissonApproxFrom(&direct_engine, 10_000, 0.01) < 200);
    try std.testing.expect(try binomialPoissonApproxChecked(rng, 10_000, 0.01) < 200);
    try std.testing.expect(try binomialPoissonApproxCheckedFrom(&direct_engine, 10_000, 0.01) < 200);
    try std.testing.expectError(error.InvalidProbability, binomialPoissonApproxCheckedFrom(&direct_engine, 10_000, 1.1));
    try std.testing.expectError(error.InvalidProbability, Binomial.init(1, 1.1));
}

test "multinomial sampler returns category counts" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(70);
    const rng = Rng.init(&engine);

    const dist = try Multinomial.init(100, &.{ 1.0, 2.0, 3.0 });
    try std.testing.expectEqual(@as(u64, 100), dist.trialsValue());
    try std.testing.expectEqualSlices(f64, &.{ 1.0, 2.0, 3.0 }, dist.probabilitiesValue());
    try std.testing.expectApproxEqAbs(@as(f64, 2), try dist.probabilityAt(1), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0 / 6.0), try dist.normalizedProbabilityAt(1), 1e-12);
    var normalized_probabilities: [3]f64 = undefined;
    try dist.normalizedProbabilitiesInto(&normalized_probabilities);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 6.0), normalized_probabilities[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0 / 6.0), normalized_probabilities[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3.0 / 6.0), normalized_probabilities[2], 1e-12);
    var wrong_probability_len: [2]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, dist.normalizedProbabilitiesInto(&wrong_probability_len));
    const owned_probabilities = try dist.normalizedProbabilities(std.testing.allocator);
    defer std.testing.allocator.free(owned_probabilities);
    try std.testing.expectEqualSlices(f64, &normalized_probabilities, owned_probabilities);
    try std.testing.expectApproxEqAbs(@as(f64, 100.0 / 3.0), try dist.expectedCountAt(1), 1e-12);
    var expected_counts: [3]f64 = undefined;
    try dist.expectedCountsInto(&expected_counts);
    try std.testing.expectApproxEqAbs(@as(f64, 100.0 / 6.0), expected_counts[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 100.0 / 3.0), expected_counts[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 50), expected_counts[2], 1e-12);
    var wrong_expected_len: [2]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, dist.expectedCountsInto(&wrong_expected_len));
    const owned_expected_counts = try dist.expectedCounts(std.testing.allocator);
    defer std.testing.allocator.free(owned_expected_counts);
    try std.testing.expectEqualSlices(f64, &expected_counts, owned_expected_counts);
    try std.testing.expectApproxEqAbs(@as(f64, 200.0 / 9.0), try dist.varianceAt(1), 1e-12);
    var multinomial_variances: [3]f64 = undefined;
    try dist.variancesInto(&multinomial_variances);
    try std.testing.expectApproxEqAbs(@as(f64, 125.0 / 9.0), multinomial_variances[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 200.0 / 9.0), multinomial_variances[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 25), multinomial_variances[2], 1e-12);
    var wrong_variances_len: [2]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, dist.variancesInto(&wrong_variances_len));
    const owned_variances = try dist.variances(std.testing.allocator);
    defer std.testing.allocator.free(owned_variances);
    try std.testing.expectEqualSlices(f64, &multinomial_variances, owned_variances);
    try std.testing.expectApproxEqAbs(@as(f64, -100.0 / 18.0), try dist.covarianceAt(0, 1), 1e-12);
    try std.testing.expectApproxEqAbs(try dist.varianceAt(1), try dist.covarianceAt(1, 1), 1e-12);
    var multinomial_covariances: [9]f64 = undefined;
    try dist.covariancesInto(&multinomial_covariances);
    try std.testing.expectApproxEqAbs(@as(f64, 125.0 / 9.0), multinomial_covariances[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, -100.0 / 18.0), multinomial_covariances[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, -25.0 / 3.0), multinomial_covariances[2], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, -100.0 / 18.0), multinomial_covariances[3], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 200.0 / 9.0), multinomial_covariances[4], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, -50.0 / 3.0), multinomial_covariances[5], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, -25.0 / 3.0), multinomial_covariances[6], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, -50.0 / 3.0), multinomial_covariances[7], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 25), multinomial_covariances[8], 1e-12);
    var wrong_covariances_len: [8]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, dist.covariancesInto(&wrong_covariances_len));
    const owned_covariances = try dist.covariances(std.testing.allocator);
    defer std.testing.allocator.free(owned_covariances);
    try std.testing.expectEqualSlices(f64, &multinomial_covariances, owned_covariances);
    try std.testing.expectError(error.InvalidParameter, dist.probabilityAt(3));
    try std.testing.expectError(error.InvalidParameter, dist.normalizedProbabilityAt(3));
    try std.testing.expectError(error.InvalidParameter, dist.expectedCountAt(3));
    try std.testing.expectError(error.InvalidParameter, dist.varianceAt(3));
    try std.testing.expectError(error.InvalidParameter, dist.covarianceAt(0, 3));
    try std.testing.expectEqual(@as(usize, 3), dist.categoryCountValue());
    try std.testing.expectApproxEqAbs(@as(f64, 6), dist.totalProbabilityValue(), 1e-12);
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
    try dist.sampleIntoChecked(rng, &stack_counts);
    total = 0;
    for (stack_counts) |count| total += count;
    try std.testing.expectEqual(@as(u64, 100), total);
    var wrong_counts: [2]u64 = undefined;
    try std.testing.expectError(error.InvalidLength, dist.sampleIntoChecked(rng, &wrong_counts));

    var direct_engine = alea.ScalarPrng.init(70);
    const direct_counts = try dist.sampleFrom(std.testing.allocator, &direct_engine);
    defer std.testing.allocator.free(direct_counts);
    try std.testing.expectEqual(@as(usize, 3), direct_counts.len);
    total = 0;
    for (direct_counts) |count| total += count;
    try std.testing.expectEqual(@as(u64, 100), total);
    dist.sampleIntoFrom(&direct_engine, &stack_counts);
    total = 0;
    for (stack_counts) |count| total += count;
    try std.testing.expectEqual(@as(u64, 100), total);
    try dist.sampleIntoCheckedFrom(&direct_engine, &stack_counts);
    total = 0;
    for (stack_counts) |count| total += count;
    try std.testing.expectEqual(@as(u64, 100), total);
    var many_counts: [9]u64 = undefined;
    dist.sampleManyInto(rng, &many_counts);
    var offset: usize = 0;
    while (offset < many_counts.len) : (offset += 3) {
        total = 0;
        for (many_counts[offset..][0..3]) |count| total += count;
        try std.testing.expectEqual(@as(u64, 100), total);
    }
    try dist.sampleManyIntoChecked(rng, &many_counts);
    offset = 0;
    while (offset < many_counts.len) : (offset += 3) {
        total = 0;
        for (many_counts[offset..][0..3]) |count| total += count;
        try std.testing.expectEqual(@as(u64, 100), total);
    }
    var wrong_many_counts: [8]u64 = undefined;
    try std.testing.expectError(error.InvalidLength, dist.sampleManyIntoChecked(rng, &wrong_many_counts));
    dist.sampleManyIntoFrom(&direct_engine, &many_counts);
    offset = 0;
    while (offset < many_counts.len) : (offset += 3) {
        total = 0;
        for (many_counts[offset..][0..3]) |count| total += count;
        try std.testing.expectEqual(@as(u64, 100), total);
    }
    try dist.sampleManyIntoCheckedFrom(&direct_engine, &many_counts);
    offset = 0;
    while (offset < many_counts.len) : (offset += 3) {
        total = 0;
        for (many_counts[offset..][0..3]) |count| total += count;
        try std.testing.expectEqual(@as(u64, 100), total);
    }

    try std.testing.expectError(error.EmptyRange, Multinomial.init(1, &.{}));
    try std.testing.expectError(error.InvalidProbability, Multinomial.init(1, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectError(error.InvalidProbability, Multinomial.init(1, &.{ 0.0, 0.0 }));
}

test "negative-binomial and hypergeometric samplers have plausible moments" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(71);
    const rng = Rng.init(&engine);

    const nb = try NegativeBinomial.init(5, 0.4);
    try std.testing.expectEqual(@as(u64, 5), nb.successesValue());
    try std.testing.expectApproxEqAbs(@as(f64, 0.4), nb.probabilityValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 7.5), nb.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 18.75), nb.varianceValue(), 1e-12);
    try std.testing.expectEqual(@as(u64, 0), nb.minValue());
    try std.testing.expect(nb.maxValue() == null);
    const hg = try Hypergeometric.init(100, 30, 10);
    try std.testing.expectEqual(@as(u64, 100), hg.populationValue());
    try std.testing.expectEqual(@as(u64, 30), hg.successesValue());
    try std.testing.expectEqual(@as(u64, 10), hg.drawsValue());
    try std.testing.expectApproxEqAbs(@as(f64, 3), hg.expectedValue(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 21.0 / 11.0), hg.varianceValue(), 1e-12);
    try std.testing.expectEqual(@as(u64, 0), hg.minValue());
    try std.testing.expectEqual(@as(u64, 10), hg.maxValue());
    const constrained_hg = try Hypergeometric.init(10, 7, 6);
    try std.testing.expectEqual(@as(u64, 3), constrained_hg.minValue());
    try std.testing.expectEqual(@as(u64, 6), constrained_hg.maxValue());
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

    var direct_engine = alea.ScalarPrng.init(72);
    try std.testing.expect(nb.sampleFrom(&direct_engine) >= 0);
    try std.testing.expect(try negativeBinomialCheckedFrom(&direct_engine, 5, 0.4) < 64);
    try std.testing.expectError(error.InvalidParameter, negativeBinomialCheckedFrom(&direct_engine, 0, 0.4));
    try std.testing.expectError(error.InvalidProbability, negativeBinomialCheckedFrom(&direct_engine, 5, 0));
    try std.testing.expect(hg.sampleFrom(&direct_engine) <= 10);
    try std.testing.expect(try hypergeometricCheckedFrom(&direct_engine, 100, 30, 10) <= 10);
    try std.testing.expectError(error.InvalidParameter, hypergeometricCheckedFrom(&direct_engine, 10, 11, 1));
    var nb_buf: [8]u64 = undefined;
    fillNegativeBinomial(rng, &nb_buf, 5, 0.4);
    for (nb_buf) |value| try std.testing.expect(value < 64);
    fillNegativeBinomialFrom(&direct_engine, &nb_buf, 5, 0.4);
    for (nb_buf) |value| try std.testing.expect(value < 64);
    try fillNegativeBinomialChecked(rng, &nb_buf, 5, 1);
    for (nb_buf) |value| try std.testing.expectEqual(@as(u64, 0), value);
    try fillNegativeBinomialCheckedFrom(&direct_engine, &nb_buf, 5, 1);
    for (nb_buf) |value| try std.testing.expectEqual(@as(u64, 0), value);
    try std.testing.expectError(error.InvalidParameter, fillNegativeBinomialCheckedFrom(&direct_engine, &nb_buf, 0, 0.4));
    try std.testing.expectError(error.InvalidProbability, fillNegativeBinomialCheckedFrom(&direct_engine, &nb_buf, 5, 0));
    nb.fillFrom(&direct_engine, &nb_buf);
    for (nb_buf) |value| try std.testing.expect(value < 64);
    var hg_buf: [8]u64 = undefined;
    fillHypergeometric(rng, &hg_buf, 100, 30, 10);
    for (hg_buf) |value| try std.testing.expect(value <= 10);
    fillHypergeometricFrom(&direct_engine, &hg_buf, 100, 30, 10);
    for (hg_buf) |value| try std.testing.expect(value <= 10);
    try fillHypergeometricChecked(rng, &hg_buf, 100, 30, 10);
    for (hg_buf) |value| try std.testing.expect(value <= 10);
    try fillHypergeometricCheckedFrom(&direct_engine, &hg_buf, 100, 30, 10);
    for (hg_buf) |value| try std.testing.expect(value <= 10);
    try std.testing.expectError(error.InvalidParameter, fillHypergeometricCheckedFrom(&direct_engine, &hg_buf, 10, 11, 1));
    hg.fillFrom(&direct_engine, &hg_buf);
    for (hg_buf) |value| try std.testing.expect(value <= 10);

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

    var direct_engine = alea.ScalarPrng.init(172);
    try std.testing.expect(std.math.isFinite(try skewNormalCheckedFrom(&direct_engine, f64, 0, 1, 1)));
    try std.testing.expectError(error.InvalidParameter, skewNormalCheckedFrom(&direct_engine, f64, 0, 0, 1));
    const direct_checked_pert = try pertCheckedFrom(&direct_engine, f64, -1, 0.5, 2, 4);
    try std.testing.expect(direct_checked_pert >= -1 and direct_checked_pert <= 2);
    try std.testing.expectError(error.InvalidParameter, pertCheckedFrom(&direct_engine, f64, 0, 2, 1, 4));

    const by_mean = try Pert(f64).initMean(-1, 0.5, 2, 4);
    const by_mode = try Pert(f64).init(-1, 0.5, 2, 4);
    const by_builder_mean = try Pert(f64).initRange(-1, 2).withShape(4).withMean(0.5);
    try std.testing.expectApproxEqAbs(by_mode.alpha, by_mean.alpha, 1e-12);
    try std.testing.expectApproxEqAbs(by_mode.beta_param, by_mean.beta_param, 1e-12);
    try std.testing.expectApproxEqAbs(by_mode.alpha, by_builder_mean.alpha, 1e-12);
    try std.testing.expectApproxEqAbs(by_mode.beta_param, by_builder_mean.beta_param, 1e-12);
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

    var direct_engine = alea.ScalarPrng.init(174);
    try std.testing.expect(try inverseGaussianCheckedFrom(&direct_engine, f64, 1, 2) > 0);
    try std.testing.expectError(error.InvalidParameter, inverseGaussianCheckedFrom(&direct_engine, f64, 0, 2));
    try std.testing.expect(std.math.isFinite(try normalInverseGaussianCheckedFrom(&direct_engine, f64, 2, 1)));
    try std.testing.expectError(error.InvalidParameter, normalInverseGaussianCheckedFrom(&direct_engine, f64, 1, 1));
    const direct_zipf = try zipfCheckedFrom(&direct_engine, f64, 10, 1.5);
    try std.testing.expect(direct_zipf >= 1 and direct_zipf <= 10);
    try std.testing.expectError(error.InvalidParameter, zipfCheckedFrom(&direct_engine, f64, 0, 1));
    try std.testing.expect(try zetaCheckedFrom(&direct_engine, f64, 3) >= 1);
    try std.testing.expectError(error.InvalidParameter, zetaCheckedFrom(&direct_engine, f64, 1));

    const zipf_sampler = try Zipf(f64).init(10, 1.5);
    try std.testing.expectApproxEqAbs(@as(f64, 10), zipf_sampler.nValue().?, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.5), zipf_sampler.exponentValue(), 1e-12);
    const harmonic_zipf = try Zipf(f64).init(12, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 12), harmonic_zipf.nValue().?, 1e-12);
    const zeta_sampler = try Zeta(f64).init(3);
    try std.testing.expectApproxEqAbs(@as(f64, 3), zeta_sampler.exponentValue(), 1e-12);

    const high_exponent = try Zipf(f64).init(10, std.math.inf(f64));
    try std.testing.expect(high_exponent.nValue() == null);
    try std.testing.expect(std.math.isInf(high_exponent.exponentValue()));
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

    var circles: [16][2]f64 = undefined;
    fillUnitCircle(rng, f64, &circles);
    for (circles) |circle| {
        try std.testing.expectApproxEqAbs(@as(f64, 1), circle[0] * circle[0] + circle[1] * circle[1], 1e-12);
    }

    var discs: [16][2]f64 = undefined;
    fillUnitDisc(rng, f64, &discs);
    for (discs) |disc| {
        try std.testing.expect(disc[0] * disc[0] + disc[1] * disc[1] <= 1);
    }

    var direct_engine = alea.ScalarPrng.init(73);
    var spheres: [16][3]f64 = undefined;
    fillUnitSphereFrom(&direct_engine, f64, &spheres);
    for (spheres) |sphere| {
        try std.testing.expectApproxEqAbs(@as(f64, 1), sphere[0] * sphere[0] + sphere[1] * sphere[1] + sphere[2] * sphere[2], 1e-12);
    }

    var balls: [16][3]f64 = undefined;
    fillUnitBallFrom(&direct_engine, f64, &balls);
    for (balls) |ball| {
        try std.testing.expect(ball[0] * ball[0] + ball[1] * ball[1] + ball[2] * ball[2] <= 1);
    }

    (UnitCircle(f64){}).fill(rng, &circles);
    (UnitDisc(f64){}).fill(rng, &discs);
    (UnitSphere(f64){}).fillFrom(&direct_engine, &spheres);
    (UnitBall(f64){}).fillFrom(&direct_engine, &balls);

    try std.testing.expectEqual(@as(usize, 2), (UnitCircle(f64){}).dimensionValue());
    try std.testing.expectEqual(@as(f64, 1), (UnitCircle(f64){}).radiusValue());
    try std.testing.expect((UnitCircle(f64){}).isSurface());
    try std.testing.expectApproxEqAbs(@as(f64, 0), (UnitCircle(f64){}).coordinateExpectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), (UnitCircle(f64){}).coordinateVarianceValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1), (UnitCircle(f64){}).radialExpectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0), (UnitCircle(f64){}).radialVarianceValue(), 0);
    try std.testing.expectEqual(@as(usize, 2), (UnitDisc(f64){}).dimensionValue());
    try std.testing.expectEqual(@as(f64, 1), (UnitDisc(f64){}).radiusValue());
    try std.testing.expect(!(UnitDisc(f64){}).isSurface());
    try std.testing.expectApproxEqAbs(@as(f64, 0), (UnitDisc(f64){}).coordinateExpectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), (UnitDisc(f64){}).coordinateVarianceValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0 / 3.0), (UnitDisc(f64){}).radialExpectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 18.0), (UnitDisc(f64){}).radialVarianceValue(), 0);
    try std.testing.expectEqual(@as(usize, 3), (UnitSphere(f64){}).dimensionValue());
    try std.testing.expectEqual(@as(f64, 1), (UnitSphere(f64){}).radiusValue());
    try std.testing.expect((UnitSphere(f64){}).isSurface());
    try std.testing.expectApproxEqAbs(@as(f64, 0), (UnitSphere(f64){}).coordinateExpectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 3.0), (UnitSphere(f64){}).coordinateVarianceValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 1), (UnitSphere(f64){}).radialExpectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0), (UnitSphere(f64){}).radialVarianceValue(), 0);
    try std.testing.expectEqual(@as(usize, 3), (UnitBall(f64){}).dimensionValue());
    try std.testing.expectEqual(@as(f64, 1), (UnitBall(f64){}).radiusValue());
    try std.testing.expect(!(UnitBall(f64){}).isSurface());
    try std.testing.expectApproxEqAbs(@as(f64, 0), (UnitBall(f64){}).coordinateExpectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0.2), (UnitBall(f64){}).coordinateVarianceValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0.75), (UnitBall(f64){}).radialExpectedValue(), 0);
    try std.testing.expectApproxEqAbs(@as(f64, 3.0 / 80.0), (UnitBall(f64){}).radialVarianceValue(), 0);
}

test "dirichlet sampler returns simplex vectors" {
    const alea = @import("root.zig");
    var engine = alea.DefaultPrng.init(68);
    const rng = Rng.init(&engine);

    const dist = try Dirichlet(f64).init(&.{ 1.0, 2.0, 3.0 });
    try std.testing.expectEqualSlices(f64, &.{ 1.0, 2.0, 3.0 }, dist.alphaValues());
    try std.testing.expectApproxEqAbs(@as(f64, 2), try dist.alphaAt(1), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0 / 6.0), try dist.meanAt(1), 1e-12);
    var dirichlet_means: [3]f64 = undefined;
    try dist.meansInto(&dirichlet_means);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 6.0), dirichlet_means[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0 / 6.0), dirichlet_means[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3.0 / 6.0), dirichlet_means[2], 1e-12);
    var wrong_means_len: [2]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, dist.meansInto(&wrong_means_len));
    const owned_means = try dist.means(std.testing.allocator);
    defer std.testing.allocator.free(owned_means);
    try std.testing.expectEqualSlices(f64, &dirichlet_means, owned_means);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0 / 63.0), try dist.varianceAt(1), 1e-12);
    var dirichlet_variances: [3]f64 = undefined;
    try dist.variancesInto(&dirichlet_variances);
    try std.testing.expectApproxEqAbs(@as(f64, 5.0 / 252.0), dirichlet_variances[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0 / 63.0), dirichlet_variances[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 28.0), dirichlet_variances[2], 1e-12);
    var wrong_variances_len: [2]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, dist.variancesInto(&wrong_variances_len));
    const owned_variances = try dist.variances(std.testing.allocator);
    defer std.testing.allocator.free(owned_variances);
    try std.testing.expectEqualSlices(f64, &dirichlet_variances, owned_variances);
    try std.testing.expectApproxEqAbs(@as(f64, -1.0 / 126.0), try dist.covarianceAt(0, 1), 1e-12);
    try std.testing.expectApproxEqAbs(try dist.varianceAt(1), try dist.covarianceAt(1, 1), 1e-12);
    var dirichlet_covariances: [9]f64 = undefined;
    try dist.covariancesInto(&dirichlet_covariances);
    try std.testing.expectApproxEqAbs(@as(f64, 5.0 / 252.0), dirichlet_covariances[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, -1.0 / 126.0), dirichlet_covariances[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, -1.0 / 84.0), dirichlet_covariances[2], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, -1.0 / 126.0), dirichlet_covariances[3], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0 / 63.0), dirichlet_covariances[4], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, -1.0 / 42.0), dirichlet_covariances[5], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, -1.0 / 84.0), dirichlet_covariances[6], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, -1.0 / 42.0), dirichlet_covariances[7], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 28.0), dirichlet_covariances[8], 1e-12);
    var wrong_covariances_len: [8]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, dist.covariancesInto(&wrong_covariances_len));
    const owned_covariances = try dist.covariances(std.testing.allocator);
    defer std.testing.allocator.free(owned_covariances);
    try std.testing.expectEqualSlices(f64, &dirichlet_covariances, owned_covariances);
    try std.testing.expectError(error.InvalidParameter, dist.alphaAt(3));
    try std.testing.expectError(error.InvalidParameter, dist.meanAt(3));
    try std.testing.expectError(error.InvalidParameter, dist.varianceAt(3));
    try std.testing.expectError(error.InvalidParameter, dist.covarianceAt(0, 3));
    try std.testing.expectEqual(@as(usize, 3), dist.dimensionValue());
    try std.testing.expectApproxEqAbs(@as(f64, 6), dist.totalAlphaValue(), 1e-12);
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
    try dist.sampleIntoChecked(rng, &stack_sample);
    stack_total = 0;
    for (stack_sample) |value| stack_total += value;
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), stack_total, 1e-12);
    var wrong_sample: [2]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, dist.sampleIntoChecked(rng, &wrong_sample));

    var direct_engine = alea.ScalarPrng.init(68);
    const direct_sample = try dist.sampleFrom(std.testing.allocator, &direct_engine);
    defer std.testing.allocator.free(direct_sample);
    try std.testing.expectEqual(@as(usize, 3), direct_sample.len);
    stack_total = 0;
    for (direct_sample) |value| stack_total += value;
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), stack_total, 1e-12);
    dist.sampleIntoFrom(&direct_engine, &stack_sample);
    stack_total = 0;
    for (stack_sample) |value| stack_total += value;
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), stack_total, 1e-12);
    try dist.sampleIntoCheckedFrom(&direct_engine, &stack_sample);
    stack_total = 0;
    for (stack_sample) |value| stack_total += value;
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), stack_total, 1e-12);
    var many_samples: [9]f64 = undefined;
    dist.sampleManyInto(rng, &many_samples);
    var offset: usize = 0;
    while (offset < many_samples.len) : (offset += 3) {
        stack_total = 0;
        for (many_samples[offset..][0..3]) |value| stack_total += value;
        try std.testing.expectApproxEqAbs(@as(f64, 1.0), stack_total, 1e-12);
    }
    try dist.sampleManyIntoChecked(rng, &many_samples);
    offset = 0;
    while (offset < many_samples.len) : (offset += 3) {
        stack_total = 0;
        for (many_samples[offset..][0..3]) |value| stack_total += value;
        try std.testing.expectApproxEqAbs(@as(f64, 1.0), stack_total, 1e-12);
    }
    var wrong_many_samples: [8]f64 = undefined;
    try std.testing.expectError(error.InvalidLength, dist.sampleManyIntoChecked(rng, &wrong_many_samples));
    dist.sampleManyIntoFrom(&direct_engine, &many_samples);
    offset = 0;
    while (offset < many_samples.len) : (offset += 3) {
        stack_total = 0;
        for (many_samples[offset..][0..3]) |value| stack_total += value;
        try std.testing.expectApproxEqAbs(@as(f64, 1.0), stack_total, 1e-12);
    }
    try dist.sampleManyIntoCheckedFrom(&direct_engine, &many_samples);
    offset = 0;
    while (offset < many_samples.len) : (offset += 3) {
        stack_total = 0;
        for (many_samples[offset..][0..3]) |value| stack_total += value;
        try std.testing.expectApproxEqAbs(@as(f64, 1.0), stack_total, 1e-12);
    }
}

test "multivariate samplers preserve direct stream shape" {
    const alea = @import("root.zig");

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_d1ce);
        var direct_engine = Engine.init(0x5150_d1ce);
        const rng = Rng.init(&facade_engine);

        const multinomial = try Multinomial.init(40, &.{ 1.0, 2.0, 3.0 });
        const counts = try multinomial.sample(std.testing.allocator, rng);
        defer std.testing.allocator.free(counts);
        const direct_counts = try multinomial.sampleFrom(std.testing.allocator, &direct_engine);
        defer std.testing.allocator.free(direct_counts);
        try std.testing.expectEqualSlices(u64, counts, direct_counts);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var count_buf: [3]u64 = undefined;
        var direct_count_buf: [3]u64 = undefined;
        multinomial.sampleInto(rng, &count_buf);
        multinomial.sampleIntoFrom(&direct_engine, &direct_count_buf);
        try std.testing.expectEqualSlices(u64, &count_buf, &direct_count_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try multinomial.sampleIntoChecked(rng, &count_buf);
        try multinomial.sampleIntoCheckedFrom(&direct_engine, &direct_count_buf);
        try std.testing.expectEqualSlices(u64, &count_buf, &direct_count_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var many_counts: [9]u64 = undefined;
        var direct_many_counts: [9]u64 = undefined;
        multinomial.sampleManyInto(rng, &many_counts);
        multinomial.sampleManyIntoFrom(&direct_engine, &direct_many_counts);
        try std.testing.expectEqualSlices(u64, &many_counts, &direct_many_counts);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try multinomial.sampleManyIntoChecked(rng, &many_counts);
        try multinomial.sampleManyIntoCheckedFrom(&direct_engine, &direct_many_counts);
        try std.testing.expectEqualSlices(u64, &many_counts, &direct_many_counts);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const dirichlet = try Dirichlet(f64).init(&.{ 1.0, 2.0, 3.0 });
        const simplex = try dirichlet.sample(std.testing.allocator, rng);
        defer std.testing.allocator.free(simplex);
        const direct_simplex = try dirichlet.sampleFrom(std.testing.allocator, &direct_engine);
        defer std.testing.allocator.free(direct_simplex);
        try std.testing.expectEqualSlices(f64, simplex, direct_simplex);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var simplex_buf: [3]f64 = undefined;
        var direct_simplex_buf: [3]f64 = undefined;
        dirichlet.sampleInto(rng, &simplex_buf);
        dirichlet.sampleIntoFrom(&direct_engine, &direct_simplex_buf);
        try std.testing.expectEqualSlices(f64, &simplex_buf, &direct_simplex_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try dirichlet.sampleIntoChecked(rng, &simplex_buf);
        try dirichlet.sampleIntoCheckedFrom(&direct_engine, &direct_simplex_buf);
        try std.testing.expectEqualSlices(f64, &simplex_buf, &direct_simplex_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var many_simplex: [9]f64 = undefined;
        var direct_many_simplex: [9]f64 = undefined;
        dirichlet.sampleManyInto(rng, &many_simplex);
        dirichlet.sampleManyIntoFrom(&direct_engine, &direct_many_simplex);
        try std.testing.expectEqualSlices(f64, &many_simplex, &direct_many_simplex);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try dirichlet.sampleManyIntoChecked(rng, &many_simplex);
        try dirichlet.sampleManyIntoCheckedFrom(&direct_engine, &direct_many_simplex);
        try std.testing.expectEqualSlices(f64, &many_simplex, &direct_many_simplex);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
}

test "checked fill helpers preserve valid-parameter stream shape" {
    const alea = @import("root.zig");

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var unchecked = Engine.init(0x5eed_1234);
        var checked = Engine.init(0x5eed_1234);

        var uniform_unchecked: [8]u32 = undefined;
        var uniform_checked: [8]u32 = undefined;
        fillUniformFrom(&unchecked, u32, &uniform_unchecked, 5, 9);
        try fillUniformCheckedFrom(&checked, u32, &uniform_checked, 5, 9);
        try std.testing.expectEqualSlices(u32, &uniform_unchecked, &uniform_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var normal_unchecked: [8]f64 = undefined;
        var normal_checked: [8]f64 = undefined;
        fillNormalFrom(&unchecked, f64, &normal_unchecked, 0, 1);
        try fillNormalCheckedFrom(&checked, f64, &normal_checked, 0, 1);
        try std.testing.expectEqualSlices(f64, &normal_unchecked, &normal_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_log_normal_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_log_normal_checked: [4]@Vector(4, f64) = undefined;
        fillVectorLogNormalFrom(&unchecked, @Vector(4, f64), &vector_log_normal_unchecked, 0, 0.25);
        try fillVectorLogNormalCheckedFrom(&checked, @Vector(4, f64), &vector_log_normal_checked, 0, 0.25);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_log_normal_unchecked, &vector_log_normal_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_half_normal_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_half_normal_checked: [4]@Vector(4, f64) = undefined;
        fillVectorHalfNormalFrom(&unchecked, @Vector(4, f64), &vector_half_normal_unchecked, 2);
        try fillVectorHalfNormalCheckedFrom(&checked, @Vector(4, f64), &vector_half_normal_checked, 2);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_half_normal_unchecked, &vector_half_normal_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_gamma_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_gamma_checked: [4]@Vector(4, f64) = undefined;
        fillVectorGammaFrom(&unchecked, @Vector(4, f64), &vector_gamma_unchecked, 2, 3);
        try fillVectorGammaCheckedFrom(&checked, @Vector(4, f64), &vector_gamma_checked, 2, 3);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_gamma_unchecked, &vector_gamma_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_chi_squared_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_chi_squared_checked: [4]@Vector(4, f64) = undefined;
        fillVectorChiSquaredFrom(&unchecked, @Vector(4, f64), &vector_chi_squared_unchecked, 4);
        try fillVectorChiSquaredCheckedFrom(&checked, @Vector(4, f64), &vector_chi_squared_checked, 4);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_chi_squared_unchecked, &vector_chi_squared_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_chi_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_chi_checked: [4]@Vector(4, f64) = undefined;
        fillVectorChiFrom(&unchecked, @Vector(4, f64), &vector_chi_unchecked, 4);
        try fillVectorChiCheckedFrom(&checked, @Vector(4, f64), &vector_chi_checked, 4);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_chi_unchecked, &vector_chi_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_erlang_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_erlang_checked: [4]@Vector(4, f64) = undefined;
        fillVectorErlangFrom(&unchecked, @Vector(4, f64), &vector_erlang_unchecked, 3, 2);
        try fillVectorErlangCheckedFrom(&checked, @Vector(4, f64), &vector_erlang_checked, 3, 2);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_erlang_unchecked, &vector_erlang_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_beta_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_beta_checked: [4]@Vector(4, f64) = undefined;
        fillVectorBetaFrom(&unchecked, @Vector(4, f64), &vector_beta_unchecked, 2, 5);
        try fillVectorBetaCheckedFrom(&checked, @Vector(4, f64), &vector_beta_checked, 2, 5);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_beta_unchecked, &vector_beta_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_fisher_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_fisher_checked: [4]@Vector(4, f64) = undefined;
        fillVectorFisherFFrom(&unchecked, @Vector(4, f64), &vector_fisher_unchecked, 5, 20);
        try fillVectorFisherFCheckedFrom(&checked, @Vector(4, f64), &vector_fisher_checked, 5, 20);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_fisher_unchecked, &vector_fisher_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_student_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_student_checked: [4]@Vector(4, f64) = undefined;
        fillVectorStudentTFrom(&unchecked, @Vector(4, f64), &vector_student_unchecked, 10);
        try fillVectorStudentTCheckedFrom(&checked, @Vector(4, f64), &vector_student_checked, 10);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_student_unchecked, &vector_student_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_triangular_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_triangular_checked: [4]@Vector(4, f64) = undefined;
        fillVectorTriangularFrom(&unchecked, @Vector(4, f64), &vector_triangular_unchecked, -1, 0, 2);
        try fillVectorTriangularCheckedFrom(&checked, @Vector(4, f64), &vector_triangular_checked, -1, 0, 2);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_triangular_unchecked, &vector_triangular_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_arcsine_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_arcsine_checked: [4]@Vector(4, f64) = undefined;
        fillVectorArcsineFrom(&unchecked, @Vector(4, f64), &vector_arcsine_unchecked, -1, 3);
        try fillVectorArcsineCheckedFrom(&checked, @Vector(4, f64), &vector_arcsine_checked, -1, 3);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_arcsine_unchecked, &vector_arcsine_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_cauchy_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_cauchy_checked: [4]@Vector(4, f64) = undefined;
        fillVectorCauchyFrom(&unchecked, @Vector(4, f64), &vector_cauchy_unchecked, 0, 1);
        try fillVectorCauchyCheckedFrom(&checked, @Vector(4, f64), &vector_cauchy_checked, 0, 1);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_cauchy_unchecked, &vector_cauchy_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_laplace_unchecked: [4]@Vector(4, f64) = undefined;
        var vector_laplace_checked: [4]@Vector(4, f64) = undefined;
        fillVectorLaplaceFrom(&unchecked, @Vector(4, f64), &vector_laplace_unchecked, 0, 1);
        try fillVectorLaplaceCheckedFrom(&checked, @Vector(4, f64), &vector_laplace_checked, 0, 1);
        try std.testing.expectEqualSlices(@Vector(4, f64), &vector_laplace_unchecked, &vector_laplace_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var exponential_unchecked: [8]f64 = undefined;
        var exponential_checked: [8]f64 = undefined;
        fillExponentialFrom(&unchecked, f64, &exponential_unchecked, 2);
        try fillExponentialCheckedFrom(&checked, f64, &exponential_checked, 2);
        try std.testing.expectEqualSlices(f64, &exponential_unchecked, &exponential_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var poisson_unchecked: [8]u64 = undefined;
        var poisson_checked: [8]u64 = undefined;
        fillPoissonFrom(&unchecked, &poisson_unchecked, 12);
        try fillPoissonCheckedFrom(&checked, &poisson_checked, 12);
        try std.testing.expectEqualSlices(u64, &poisson_unchecked, &poisson_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_binomial_unchecked: [4]@Vector(4, u64) = undefined;
        var vector_binomial_checked: [4]@Vector(4, u64) = undefined;
        fillVectorBinomialFrom(&unchecked, @Vector(4, u64), &vector_binomial_unchecked, 10, 0.5);
        try fillVectorBinomialCheckedFrom(&checked, @Vector(4, u64), &vector_binomial_checked, 10, 0.5);
        try std.testing.expectEqualSlices(@Vector(4, u64), &vector_binomial_unchecked, &vector_binomial_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_hypergeometric_unchecked: [4]@Vector(4, u64) = undefined;
        var vector_hypergeometric_checked: [4]@Vector(4, u64) = undefined;
        fillVectorHypergeometricFrom(&unchecked, @Vector(4, u64), &vector_hypergeometric_unchecked, 100, 30, 10);
        try fillVectorHypergeometricCheckedFrom(&checked, @Vector(4, u64), &vector_hypergeometric_checked, 100, 30, 10);
        try std.testing.expectEqualSlices(@Vector(4, u64), &vector_hypergeometric_unchecked, &vector_hypergeometric_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_negative_binomial_unchecked: [4]@Vector(4, u64) = undefined;
        var vector_negative_binomial_checked: [4]@Vector(4, u64) = undefined;
        fillVectorNegativeBinomialFrom(&unchecked, @Vector(4, u64), &vector_negative_binomial_unchecked, 5, 0.25);
        try fillVectorNegativeBinomialCheckedFrom(&checked, @Vector(4, u64), &vector_negative_binomial_checked, 5, 0.25);
        try std.testing.expectEqualSlices(@Vector(4, u64), &vector_negative_binomial_unchecked, &vector_negative_binomial_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_geometric_unchecked: [4]@Vector(4, u64) = undefined;
        var vector_geometric_checked: [4]@Vector(4, u64) = undefined;
        fillVectorGeometricFrom(&unchecked, @Vector(4, u64), &vector_geometric_unchecked, 0.25);
        try fillVectorGeometricCheckedFrom(&checked, @Vector(4, u64), &vector_geometric_checked, 0.25);
        try std.testing.expectEqualSlices(@Vector(4, u64), &vector_geometric_unchecked, &vector_geometric_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_geometric_failures_unchecked: [4]@Vector(4, u64) = undefined;
        var vector_geometric_failures_checked: [4]@Vector(4, u64) = undefined;
        fillVectorGeometricFailuresFrom(&unchecked, @Vector(4, u64), &vector_geometric_failures_unchecked, 0.25);
        try fillVectorGeometricFailuresCheckedFrom(&checked, @Vector(4, u64), &vector_geometric_failures_checked, 0.25);
        try std.testing.expectEqualSlices(@Vector(4, u64), &vector_geometric_failures_unchecked, &vector_geometric_failures_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_poisson_unchecked: [4]@Vector(4, u64) = undefined;
        var vector_poisson_checked: [4]@Vector(4, u64) = undefined;
        fillVectorPoissonFrom(&unchecked, @Vector(4, u64), &vector_poisson_unchecked, 12);
        try fillVectorPoissonCheckedFrom(&checked, @Vector(4, u64), &vector_poisson_checked, 12);
        try std.testing.expectEqualSlices(@Vector(4, u64), &vector_poisson_unchecked, &vector_poisson_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var triangular_unchecked: [8]f64 = undefined;
        var triangular_checked: [8]f64 = undefined;
        fillTriangularFrom(&unchecked, f64, &triangular_unchecked, -1, 0, 2);
        try fillTriangularCheckedFrom(&checked, f64, &triangular_checked, -1, 0, 2);
        try std.testing.expectEqualSlices(f64, &triangular_unchecked, &triangular_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());
    }
}
