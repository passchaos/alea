const std = @import("std");
const std_ziggurat = std.Random.ziggurat;

const Rng = @This();

const norm_ziggurat_ratio = blk: {
    var out: [256]f64 = undefined;
    for (&out, 0..) |*item, i| item.* = std_ziggurat.NormDist.x[i + 1] / std_ziggurat.NormDist.x[i];
    break :blk out;
};

const exp_ziggurat_ratio = blk: {
    var out: [256]f64 = undefined;
    for (&out, 0..) |*item, i| item.* = std_ziggurat.ExpDist.x[i + 1] / std_ziggurat.ExpDist.x[i];
    break :blk out;
};

const exp_ziggurat_mantissa_threshold = blk: {
    var out: [256]u64 = undefined;
    for (&out, 0..) |*item, i| {
        const threshold_ratio = std_ziggurat.ExpDist.x[i + 1] / std_ziggurat.ExpDist.x[i];
        item.* = @intFromFloat(@ceil(threshold_ratio * @as(f64, @floatFromInt(@as(u64, 1) << 52)) - 0.5));
    }
    break :blk out;
};

pub const Error = error{
    EmptyRange,
    InvalidProbability,
    InvalidParameter,
    InvalidWeight,
};

ptr: *anyopaque,
nextFn: *const fn (ptr: *anyopaque) u64,
fillFn: *const fn (ptr: *anyopaque, buf: []u8) void,

pub fn init(pointer: anytype) Rng {
    const Ptr = @TypeOf(pointer);
    comptime {
        const info = @typeInfo(Ptr);
        if (info != .pointer or info.pointer.size != .one) {
            @compileError("Rng.init expects a single-item pointer to an engine");
        }
        const Child = info.pointer.child;
        if (!@hasDecl(Child, "next")) {
            @compileError(@typeName(Child) ++ " must expose pub fn next(*Self) u64");
        }
        if (!@hasDecl(Child, "fill")) {
            @compileError(@typeName(Child) ++ " must expose pub fn fill(*Self, []u8) void");
        }
    }

    const gen = struct {
        fn next(ptr: *anyopaque) u64 {
            const self: Ptr = @ptrCast(@alignCast(ptr));
            return self.next();
        }

        fn fill(ptr: *anyopaque, buf: []u8) void {
            const self: Ptr = @ptrCast(@alignCast(ptr));
            self.fill(buf);
        }
    };

    return .{
        .ptr = pointer,
        .nextFn = gen.next,
        .fillFn = gen.fill,
    };
}

pub fn fromRandom(random_source: *std.Random) Rng {
    const gen = struct {
        fn next(ptr: *anyopaque) u64 {
            const source: *std.Random = @ptrCast(@alignCast(ptr));
            return source.int(u64);
        }

        fn fill(ptr: *anyopaque, buf: []u8) void {
            const source: *std.Random = @ptrCast(@alignCast(ptr));
            source.bytes(buf);
        }
    };

    return .{
        .ptr = random_source,
        .nextFn = gen.next,
        .fillFn = gen.fill,
    };
}

pub fn random(self: Rng) std.Random {
    return .{
        .ptr = self.ptr,
        .fillFn = self.fillFn,
    };
}

pub fn value(self: Rng, comptime T: type) T {
    return valueFrom(self, T);
}

pub fn valueFrom(source: anytype, comptime T: type) T {
    return switch (@typeInfo(T)) {
        .bool => booleanFrom(source),
        .int => uintFrom(source, T),
        .float => floatFrom(source, T),
        .vector => vectorFrom(source, T),
        .@"enum" => enumValueFrom(source, T),
        .array => |array_info| blk: {
            var out: T = undefined;
            for (&out) |*item| item.* = valueFrom(source, array_info.child);
            break :blk out;
        },
        .@"struct" => |struct_info| blk: {
            if (struct_info.is_tuple) {
                var out: T = undefined;
                inline for (struct_info.fields) |field| {
                    @field(out, field.name) = valueFrom(source, field.type);
                }
                break :blk out;
            }
            @compileError("alea.Rng.value only auto-samples tuples, arrays, bools, ints, floats, and enums");
        },
        else => @compileError("alea.Rng.value does not support " ++ @typeName(T)),
    };
}

pub fn valueIter(self: Rng, comptime T: type) ValueIterator(T) {
    return .{ .rng = self };
}

pub fn valueIterFrom(source: anytype, comptime T: type) ValueIteratorFrom(@TypeOf(source), T) {
    return .{ .source = source };
}

pub fn randomIter(self: Rng, comptime T: type) ValueIterator(T) {
    return self.valueIter(T);
}

pub fn randomIterFrom(source: anytype, comptime T: type) ValueIteratorFrom(@TypeOf(source), T) {
    return valueIterFrom(source, T);
}

pub fn sampleIter(self: Rng, comptime T: type, sampler: anytype) SampleIterator(@TypeOf(sampler), T) {
    return .{
        .rng = self,
        .sampler = sampler,
    };
}

pub fn sampleIterFrom(source: anytype, comptime T: type, sampler: anytype) SampleIteratorFrom(@TypeOf(source), @TypeOf(sampler), T) {
    return .{
        .source = source,
        .sampler = sampler,
    };
}

pub fn bytes(self: Rng, buf: []u8) void {
    self.fillFn(self.ptr, buf);
}

pub fn fill(self: Rng, comptime T: type, dest: []T) void {
    fillFrom(self, T, dest);
}

pub fn fillFrom(source: anytype, comptime T: type, dest: []T) void {
    switch (@typeInfo(T)) {
        .int => {
            if (T == u8) {
                fillBytesFrom(source, dest);
                return;
            }
            fillIntsFrom(source, T, dest);
        },
        .float => {
            fillFloatsFrom(source, T, dest);
        },
        .bool => {
            fillBoolsFrom(source, dest);
        },
        .vector => {
            fillVectorFrom(source, T, dest);
        },
        else => @compileError("alea.Rng.fillFrom supports integer, float, bool, and vector slices"),
    }
}

pub fn fillRange(self: Rng, comptime T: type, dest: []T, min: T, max: T) void {
    fillRangeFrom(self, T, dest, min, max);
}

pub fn fillRangeFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) void {
    switch (@typeInfo(T)) {
        .int => {
            std.debug.assert(min < max);
            for (dest) |*item| item.* = intRangeLessThanFrom(source, T, min, max);
        },
        .float => {
            std.debug.assert(min <= max);
            fillFloatRangeFrom(source, T, dest, min, max);
        },
        else => @compileError("alea.Rng.fillRangeFrom supports integer and floating-point slices"),
    }
}

pub fn fillRangeChecked(self: Rng, comptime T: type, dest: []T, min: T, max: T) Error!void {
    return fillRangeCheckedFrom(self, T, dest, min, max);
}

pub fn fillRangeCheckedFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) Error!void {
    switch (@typeInfo(T)) {
        .int => {
            if (min >= max) return error.EmptyRange;
        },
        .float => {
            if (!(min <= max) or !std.math.isFinite(min) or !std.math.isFinite(max)) return error.EmptyRange;
        },
        else => @compileError("alea.Rng.fillRangeChecked supports integer and floating-point slices"),
    }
    fillRangeFrom(source, T, dest, min, max);
}

pub fn fillOpen(self: Rng, comptime T: type, dest: []T) void {
    fillOpenFrom(self, T, dest);
}

pub fn fillOpenFrom(source: anytype, comptime T: type, dest: []T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => fillOpenF32From(source, dest),
        f64 => fillOpenF64From(source, dest),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

pub fn fillOpenClosed(self: Rng, comptime T: type, dest: []T) void {
    fillOpenClosedFrom(self, T, dest);
}

pub fn fillOpenClosedFrom(source: anytype, comptime T: type, dest: []T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => fillOpenClosedF32From(source, dest),
        f64 => fillOpenClosedF64From(source, dest),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

pub fn fillChance(self: Rng, dest: []bool, p: f64) void {
    fillChanceFrom(self, dest, p);
}

pub fn fillChanceFrom(source: anytype, dest: []bool, p: f64) void {
    std.debug.assert(p >= 0 and p <= 1);
    if (p == 0) {
        @memset(dest, false);
        return;
    }
    if (p == 1) {
        @memset(dest, true);
        return;
    }
    if (p == 0.5) {
        fillBoolsFrom(source, dest);
        return;
    }
    if (p == 0.25) {
        fillChanceQuarterFrom(source, dest);
        return;
    }

    const threshold = probabilityThreshold(p);
    for (dest) |*item| item.* = nextFrom(source) < threshold;
}

pub fn fillChanceChecked(self: Rng, dest: []bool, p: f64) Error!void {
    return fillChanceCheckedFrom(self, dest, p);
}

pub fn fillChanceCheckedFrom(source: anytype, dest: []bool, p: f64) Error!void {
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    fillChanceFrom(source, dest, p);
}

pub fn fillRatio(self: Rng, dest: []bool, numerator: u32, denominator: u32) void {
    fillRatioFrom(self, dest, numerator, denominator);
}

pub fn fillRatioFrom(source: anytype, dest: []bool, numerator: u32, denominator: u32) void {
    std.debug.assert(denominator > 0 and numerator <= denominator);
    if (numerator == 0) {
        @memset(dest, false);
        return;
    }
    if (numerator == denominator) {
        @memset(dest, true);
        return;
    }
    if (denominator == 2 and numerator == 1) {
        fillBoolsFrom(source, dest);
        return;
    }
    if (denominator == 4 and numerator == 1) {
        fillChanceQuarterFrom(source, dest);
        return;
    }
    if (std.math.isPowerOfTwo(denominator)) {
        fillRatioPowerOfTwoFrom(source, dest, numerator, denominator);
        return;
    }
    for (dest) |*item| item.* = uintLessThanFrom(source, u32, denominator) < numerator;
}

pub fn fillRatioChecked(self: Rng, dest: []bool, numerator: u32, denominator: u32) Error!void {
    return fillRatioCheckedFrom(self, dest, numerator, denominator);
}

pub fn fillRatioCheckedFrom(source: anytype, dest: []bool, numerator: u32, denominator: u32) Error!void {
    if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
    fillRatioFrom(source, dest, numerator, denominator);
}

pub fn fillVectorRange(self: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    fillVectorRangeFrom(self, VectorType, dest, min, max);
}

pub fn fillVectorOpen(self: Rng, comptime VectorType: type, dest: []VectorType) void {
    fillVectorOpenFrom(self, VectorType, dest);
}

pub fn fillVectorOpenClosed(self: Rng, comptime VectorType: type, dest: []VectorType) void {
    fillVectorOpenClosedFrom(self, VectorType, dest);
}

pub fn fillVectorFrom(source: anytype, comptime VectorType: type, dest: []VectorType) void {
    _ = vectorInfo(VectorType);
    for (dest) |*item| item.* = vectorFrom(source, VectorType);
}

pub fn fillVectorOpenFrom(source: anytype, comptime VectorType: type, dest: []VectorType) void {
    _ = vectorInfo(VectorType);
    for (dest) |*item| item.* = vectorOpenFrom(source, VectorType);
}

pub fn fillVectorOpenClosedFrom(source: anytype, comptime VectorType: type, dest: []VectorType) void {
    _ = vectorInfo(VectorType);
    for (dest) |*item| item.* = vectorOpenClosedFrom(source, VectorType);
}

pub fn fillVectorRangeFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    _ = vectorInfo(VectorType);
    for (dest) |*item| item.* = vectorRangeFrom(source, VectorType, min, max);
}

pub fn fillVectorRangeChecked(self: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    return fillVectorRangeCheckedFrom(self, VectorType, dest, min, max);
}

pub fn fillVectorRangeCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    const info = vectorInfo(VectorType);
    switch (@typeInfo(info.child)) {
        .int => {
            if (min >= max) return error.EmptyRange;
        },
        .float => {
            if (!(min <= max) or !std.math.isFinite(min) or !std.math.isFinite(max)) return error.EmptyRange;
        },
        else => @compileError("Rng.fillVectorRangeChecked supports integer and floating-point vectors"),
    }
    fillVectorRangeFrom(source, VectorType, dest, min, max);
}

pub fn fillVectorChance(self: Rng, comptime VectorType: type, dest: []VectorType, p: f64) void {
    fillVectorChanceFrom(self, VectorType, dest, p);
}

pub fn fillVectorChanceFrom(source: anytype, comptime VectorType: type, dest: []VectorType, p: f64) void {
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("Rng.fillVectorChance expects a bool vector");
    std.debug.assert(p >= 0 and p <= 1);
    for (dest) |*item| item.* = vectorChanceFrom(source, VectorType, p);
}

pub fn fillVectorChanceChecked(self: Rng, comptime VectorType: type, dest: []VectorType, p: f64) Error!void {
    return fillVectorChanceCheckedFrom(self, VectorType, dest, p);
}

pub fn fillVectorChanceCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, p: f64) Error!void {
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    fillVectorChanceFrom(source, VectorType, dest, p);
}

pub fn fillVectorRatio(self: Rng, comptime VectorType: type, dest: []VectorType, numerator: u32, denominator: u32) void {
    fillVectorRatioFrom(self, VectorType, dest, numerator, denominator);
}

pub fn fillVectorRatioFrom(source: anytype, comptime VectorType: type, dest: []VectorType, numerator: u32, denominator: u32) void {
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("Rng.fillVectorRatio expects a bool vector");
    std.debug.assert(denominator > 0 and numerator <= denominator);
    for (dest) |*item| item.* = vectorRatioFrom(source, VectorType, numerator, denominator);
}

pub fn fillVectorRatioChecked(self: Rng, comptime VectorType: type, dest: []VectorType, numerator: u32, denominator: u32) Error!void {
    return fillVectorRatioCheckedFrom(self, VectorType, dest, numerator, denominator);
}

pub fn fillVectorRatioCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, numerator: u32, denominator: u32) Error!void {
    if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
    fillVectorRatioFrom(source, VectorType, dest, numerator, denominator);
}

pub fn fillVectorStandardNormal(self: Rng, comptime VectorType: type, dest: []VectorType) void {
    fillVectorStandardNormalFrom(self, VectorType, dest);
}

pub fn fillVectorStandardNormalFrom(source: anytype, comptime VectorType: type, dest: []VectorType) void {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    for (dest) |*item| item.* = vectorStandardNormalFrom(source, VectorType);
}

pub fn fillVectorNormal(self: Rng, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) void {
    fillVectorNormalFrom(self, VectorType, dest, mean, stddev);
}

pub fn fillVectorNormalFrom(source: anytype, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) void {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    std.debug.assert(stddev >= 0);
    if (info.child == f32 or info.child == f64) {
        fillVectorNormalScalarFrom(source, VectorType, dest, mean, stddev);
        return;
    }
    for (dest) |*item| item.* = vectorNormalFrom(source, VectorType, mean, stddev);
}

pub fn fillVectorNormalChecked(self: Rng, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!void {
    return fillVectorNormalCheckedFrom(self, VectorType, dest, mean, stddev);
}

pub fn fillVectorNormalCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!void {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    if (!std.math.isFinite(mean) or !(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
    fillVectorNormalFrom(source, VectorType, dest, mean, stddev);
}

pub fn fillVectorExponential(self: Rng, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) void {
    fillVectorExponentialFrom(self, VectorType, dest, rate);
}

pub fn fillVectorExponentialFrom(source: anytype, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) void {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    std.debug.assert(rate > 0);
    if (info.child == f32 or info.child == f64) {
        fillVectorExponentialScalarFrom(source, VectorType, dest, rate);
        return;
    }
    for (dest) |*item| item.* = vectorExponentialFrom(source, VectorType, rate);
}

pub fn fillVectorExponentialChecked(self: Rng, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) Error!void {
    return fillVectorExponentialCheckedFrom(self, VectorType, dest, rate);
}

pub fn fillVectorExponentialCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) Error!void {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    if (!(rate > 0) or !std.math.isFinite(rate)) return error.InvalidParameter;
    fillVectorExponentialFrom(source, VectorType, dest, rate);
}

pub fn fillVectorStandardExponential(self: Rng, comptime VectorType: type, dest: []VectorType) void {
    fillVectorStandardExponentialFrom(self, VectorType, dest);
}

pub fn fillVectorStandardExponentialFrom(source: anytype, comptime VectorType: type, dest: []VectorType) void {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    for (dest) |*item| item.* = vectorStandardExponentialFrom(source, VectorType);
}

pub fn fillNormal(self: Rng, comptime T: type, dest: []T, mean: T, stddev: T) void {
    fillNormalFrom(self, T, dest, mean, stddev);
}

pub fn fillNormalFrom(source: anytype, comptime T: type, dest: []T, mean: T, stddev: T) void {
    comptime requireFloat(T);
    std.debug.assert(stddev >= 0);
    if (mean == 0 and stddev == 1) {
        for (dest) |*item| item.* = standardNormalFastFrom(source, T);
        return;
    }

    for (dest) |*item| item.* = standardNormalFastFrom(source, T);
    normalAffineInPlace(T, dest, mean, stddev);
}

pub fn fillNormalChecked(self: Rng, comptime T: type, dest: []T, mean: T, stddev: T) Error!void {
    return fillNormalCheckedFrom(self, T, dest, mean, stddev);
}

pub fn fillNormalCheckedFrom(source: anytype, comptime T: type, dest: []T, mean: T, stddev: T) Error!void {
    comptime requireFloat(T);
    if (!std.math.isFinite(mean) or !(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
    fillNormalFrom(source, T, dest, mean, stddev);
}

pub fn fillExponential(self: Rng, comptime T: type, dest: []T, rate: T) void {
    fillExponentialFrom(self, T, dest, rate);
}

pub fn fillExponentialFrom(source: anytype, comptime T: type, dest: []T, rate: T) void {
    comptime requireFloat(T);
    std.debug.assert(rate > 0);
    for (dest) |*item| item.* = exponentialFastFrom(source, T, rate);
}

pub fn fillExponentialChecked(self: Rng, comptime T: type, dest: []T, rate: T) Error!void {
    return fillExponentialCheckedFrom(self, T, dest, rate);
}

pub fn fillExponentialCheckedFrom(source: anytype, comptime T: type, dest: []T, rate: T) Error!void {
    comptime requireFloat(T);
    if (!(rate > 0) or !std.math.isFinite(rate)) return error.InvalidParameter;
    fillExponentialFrom(source, T, dest, rate);
}

pub fn fillSample(self: Rng, comptime T: type, dest: []T, sampler: anytype) void {
    var local_sampler = sampler;
    if (comptime samplerCanFill(@TypeOf(sampler), T)) {
        if (comptime samplerFillTakesType(@TypeOf(local_sampler))) {
            local_sampler.fill(self, T, dest);
        } else {
            local_sampler.fill(self, dest);
        }
        return;
    }
    for (dest) |*item| {
        item.* = if (comptime samplerSampleTakesType(@TypeOf(local_sampler)))
            local_sampler.sample(self, T)
        else
            local_sampler.sample(self);
    }
}

pub fn fillSampleFrom(source: anytype, comptime T: type, dest: []T, sampler: anytype) void {
    var local_sampler = sampler;
    if (comptime samplerCanFillFrom(@TypeOf(sampler), @TypeOf(source), T)) {
        if (comptime samplerFillFromTakesType(@TypeOf(local_sampler))) {
            local_sampler.fillFrom(source, T, dest);
        } else {
            local_sampler.fillFrom(source, dest);
        }
        return;
    }
    for (dest) |*item| {
        item.* = if (comptime samplerSampleFromTakesType(@TypeOf(local_sampler)))
            local_sampler.sampleFrom(source, T)
        else
            local_sampler.sampleFrom(source);
    }
}

fn sampleWith(comptime T: type, sampler: anytype, rng: Rng) T {
    var local_sampler = sampler;
    return if (comptime samplerSampleTakesType(@TypeOf(local_sampler)))
        local_sampler.sample(rng, T)
    else
        local_sampler.sample(rng);
}

fn sampleFromWith(comptime T: type, sampler: anytype, source: anytype) T {
    var local_sampler = sampler;
    return if (comptime samplerSampleFromTakesType(@TypeOf(local_sampler)))
        local_sampler.sampleFrom(source, T)
    else
        local_sampler.sampleFrom(source);
}

fn samplerCanFill(comptime Sampler: type, comptime T: type) bool {
    const Base = samplerBaseType(Sampler);
    if (!@hasDecl(Base, "fill")) return false;
    const info = @typeInfo(@TypeOf(@field(Base, "fill"))).@"fn";
    if (!samplerFirstParamCompatible(Sampler, info) or
        info.params[1].type == null or info.params[1].type.? != Rng)
    {
        return false;
    }
    if (samplerFillTakesType(Sampler)) return true;
    if (info.is_generic or info.params.len != 3) return false;
    return sliceParamChild(info.params[2].type) == T;
}

fn samplerCanFillFrom(comptime Sampler: type, comptime Source: type, comptime T: type) bool {
    const Base = samplerBaseType(Sampler);
    if (!@hasDecl(Base, "fillFrom")) return false;
    const info = @typeInfo(@TypeOf(@field(Base, "fillFrom"))).@"fn";
    if (!samplerFirstParamCompatible(Sampler, info)) return false;
    const source_type = info.params[1].type;
    if (source_type != null and source_type.? != Source) return false;
    if (samplerFillFromTakesType(Sampler)) return true;
    if (info.params.len != 3) return false;
    return sliceParamChild(info.params[2].type) == T;
}

fn samplerSampleTakesType(comptime Sampler: type) bool {
    const Base = samplerBaseType(Sampler);
    if (!@hasDecl(Base, "sample")) return false;
    const info = @typeInfo(@TypeOf(@field(Base, "sample"))).@"fn";
    return samplerFirstParamCompatible(Sampler, info) and
        info.params.len == 3 and info.params[1].type != null and info.params[1].type.? == Rng and
        info.params[2].type != null and info.params[2].type.? == type;
}

fn samplerSampleFromTakesType(comptime Sampler: type) bool {
    const Base = samplerBaseType(Sampler);
    if (!@hasDecl(Base, "sampleFrom")) return false;
    const info = @typeInfo(@TypeOf(@field(Base, "sampleFrom"))).@"fn";
    return samplerFirstParamCompatible(Sampler, info) and
        info.params.len == 3 and info.params[2].type != null and info.params[2].type.? == type;
}

fn samplerFillTakesType(comptime Sampler: type) bool {
    const Base = samplerBaseType(Sampler);
    if (!@hasDecl(Base, "fill")) return false;
    const info = @typeInfo(@TypeOf(@field(Base, "fill"))).@"fn";
    return samplerFirstParamCompatible(Sampler, info) and
        info.params.len == 4 and info.params[1].type != null and info.params[1].type.? == Rng and
        info.params[2].type != null and info.params[2].type.? == type;
}

fn samplerFillFromTakesType(comptime Sampler: type) bool {
    const Base = samplerBaseType(Sampler);
    if (!@hasDecl(Base, "fillFrom")) return false;
    const info = @typeInfo(@TypeOf(@field(Base, "fillFrom"))).@"fn";
    return samplerFirstParamCompatible(Sampler, info) and
        info.params.len == 4 and info.params[2].type != null and info.params[2].type.? == type;
}

fn samplerFirstParamCompatible(comptime Sampler: type, comptime info: std.builtin.Type.Fn) bool {
    if (info.params.len == 0 or info.params[0].type == null) return false;
    const First = info.params[0].type.?;
    if (First == Sampler) return true;
    const sampler_info = @typeInfo(Sampler);
    if (sampler_info != .pointer and @typeInfo(First) == .pointer) {
        const FirstPointer = @typeInfo(First).pointer;
        return FirstPointer.size == .one and FirstPointer.child == Sampler;
    }
    if (sampler_info == .pointer) {
        const Pointer = sampler_info.pointer;
        if (First == Pointer.child) return true;
        if (@typeInfo(First) == .pointer) {
            const FirstPointer = @typeInfo(First).pointer;
            return FirstPointer.size == .one and FirstPointer.child == Pointer.child and
                (FirstPointer.is_const or !Pointer.is_const);
        }
    }
    return false;
}

fn samplerBaseType(comptime Sampler: type) type {
    return switch (@typeInfo(Sampler)) {
        .pointer => |pointer| pointer.child,
        else => Sampler,
    };
}

fn sliceParamChild(comptime ParamType: ?type) ?type {
    const Slice = ParamType orelse return null;
    const info = @typeInfo(Slice);
    if (info != .pointer or info.pointer.size != .slice) return null;
    return info.pointer.child;
}

fn fillBools(self: Rng, dest: []bool) void {
    fillBoolsFrom(self, dest);
}

fn fillBytesFrom(source: anytype, buf: []u8) void {
    if (@TypeOf(source) == Rng) {
        source.bytes(buf);
    } else {
        source.fill(buf);
    }
}

fn sourceCanFillBytes(comptime Source: type) bool {
    if (Source == Rng) return true;
    const info = @typeInfo(Source);
    if (info == .pointer and info.pointer.size == .one) {
        return @hasDecl(info.pointer.child, "fill");
    }
    return @hasDecl(Source, "fill");
}

fn fillBoolsFrom(source: anytype, dest: []bool) void {
    var i: usize = 0;
    while (i < dest.len) {
        var bits = nextFrom(source);
        var lane: usize = 0;
        const take = @min(@as(usize, 64), dest.len - i);
        while (lane < take) : (lane += 1) {
            dest[i + lane] = @as(i64, @bitCast(bits)) < 0;
            bits <<= 1;
        }
        i += take;
    }
}

fn fillChanceQuarterFrom(source: anytype, dest: []bool) void {
    var i: usize = 0;
    while (i < dest.len) {
        var bits = nextFrom(source);
        var lane: usize = 0;
        const take = @min(@as(usize, 32), dest.len - i);
        while (lane < take) : (lane += 1) {
            dest[i + lane] = (bits & 0b11) == 0;
            bits >>= 2;
        }
        i += take;
    }
}

fn fillRatioPowerOfTwoFrom(source: anytype, dest: []bool, numerator: u32, denominator: u32) void {
    const bits_per_sample = std.math.log2_int(u32, denominator);
    const samples_per_word = 64 / @as(usize, bits_per_sample);
    const mask = @as(u64, denominator - 1);

    var i: usize = 0;
    while (i < dest.len) {
        var bits = nextFrom(source);
        var lane: usize = 0;
        const take = @min(samples_per_word, dest.len - i);
        while (lane < take) : (lane += 1) {
            dest[i + lane] = @as(u32, @intCast(bits & mask)) < numerator;
            bits >>= @intCast(bits_per_sample);
        }
        i += take;
    }
}

fn fillInts(self: Rng, comptime T: type, dest: []T) void {
    fillIntsFrom(self, T, dest);
}

fn fillIntsFrom(source: anytype, comptime T: type, dest: []T) void {
    comptime requireInt(T);
    const info = @typeInfo(T).int;
    if (info.bits == 0) {
        @memset(dest, 0);
        return;
    }
    if (info.bits > 64) {
        for (dest) |*item| item.* = uintFrom(source, T);
        return;
    }

    const Unsigned = std.meta.Int(.unsigned, info.bits);
    const lanes_per_word = @max(1, 64 / info.bits);
    const mask = if (info.bits == 64) std.math.maxInt(u64) else (@as(u64, 1) << @intCast(info.bits)) - 1;

    var i: usize = 0;
    while (i < dest.len) {
        var bits = nextFrom(source);
        var lane: usize = 0;
        while (lane < lanes_per_word and i < dest.len) : (lane += 1) {
            const raw: Unsigned = @intCast(bits & mask);
            dest[i] = @bitCast(raw);
            i += 1;
            if (info.bits != 64) bits >>= @intCast(info.bits);
        }
    }
}

fn fillFloats(self: Rng, comptime T: type, dest: []T) void {
    fillFloatsFrom(self, T, dest);
}

fn fillFloatsFrom(source: anytype, comptime T: type, dest: []T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => fillF32From(source, dest),
        f64 => {
            fillF64From(source, dest);
        },
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn fillF32From(source: anytype, dest: []f32) void {
    const VectorType = @Vector(8, f32);

    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        const vec = vectorF32From(source, VectorType);
        inline for (0..8) |lane| dest[i + lane] = vec[lane];
    }

    while (i < dest.len) {
        const bits = nextFrom(source);
        dest[i] = f32FromBits(@truncate(bits >> 40));
        i += 1;
        if (i < dest.len) {
            dest[i] = f32FromBits(@truncate(bits >> 16));
            i += 1;
        }
    }
}

fn fillOpenF32From(source: anytype, dest: []f32) void {
    const VectorType = @Vector(8, f32);

    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        const vec = vectorOpenF32From(source, VectorType);
        inline for (0..8) |lane| dest[i + lane] = vec[lane];
    }

    while (i < dest.len) {
        const bits = nextFrom(source);
        dest[i] = f32OpenFromBits(@truncate(bits >> 40));
        i += 1;
        if (i < dest.len) {
            dest[i] = f32OpenFromBits(@truncate(bits >> 16));
            i += 1;
        }
    }
}

fn fillOpenClosedF32From(source: anytype, dest: []f32) void {
    const VectorType = @Vector(8, f32);

    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        const vec = vectorOpenClosedF32From(source, VectorType);
        inline for (0..8) |lane| dest[i + lane] = vec[lane];
    }

    while (i < dest.len) {
        const bits = nextFrom(source);
        dest[i] = (@as(f32, @floatFromInt(@as(u24, @truncate(bits >> 40)))) + 1.0) * (1.0 / 16777216.0);
        i += 1;
        if (i < dest.len) {
            dest[i] = (@as(f32, @floatFromInt(@as(u24, @truncate(bits >> 16)))) + 1.0) * (1.0 / 16777216.0);
            i += 1;
        }
    }
}

fn fillF64From(source: anytype, dest: []f64) void {
    const VectorType = @Vector(4, f64);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const vec = vectorF64From(source, VectorType);
        inline for (0..4) |lane| dest[i + lane] = vec[lane];
    }

    while (i < dest.len) : (i += 1) dest[i] = floatFrom(source, f64);
}

fn fillOpenF64From(source: anytype, dest: []f64) void {
    const VectorType = @Vector(4, f64);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const vec = vectorOpenF64From(source, VectorType);
        inline for (0..4) |lane| dest[i + lane] = vec[lane];
    }

    while (i < dest.len) : (i += 1) dest[i] = floatOpenFrom(source, f64);
}

fn fillOpenClosedF64From(source: anytype, dest: []f64) void {
    if (comptime sourceCanFillBytes(@TypeOf(source))) {
        const buffer_len = 128;
        var raw_words: [buffer_len]u64 = undefined;

        var i: usize = 0;
        while (i < dest.len) {
            const take = @min(dest.len - i, raw_words.len);
            fillBytesFrom(source, std.mem.sliceAsBytes(raw_words[0..take]));

            var lane: usize = 0;
            while (lane < take) : (lane += 1) {
                const raw = std.mem.littleToNative(u64, raw_words[lane]);
                dest[i + lane] = f64OpenClosedFromRaw(raw);
            }
            i += take;
        }
    } else {
        for (dest) |*item| item.* = floatOpenClosedFrom(source, f64);
    }
}

fn fillFloatRange(self: Rng, comptime T: type, dest: []T, min: T, max: T) void {
    fillFloatRangeFrom(self, T, dest, min, max);
}

fn fillFloatRangeFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => fillRangeF32From(source, dest, min, max),
        f64 => fillRangeF64From(source, dest, min, max),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn fillRangeF32From(source: anytype, dest: []f32, min: f32, max: f32) void {
    const VectorType = @Vector(8, f32);
    const min_vec: VectorType = @splat(min);
    const width_vec: VectorType = @splat(max - min);

    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        const vec = min_vec + width_vec * vectorF32From(source, VectorType);
        inline for (0..8) |lane| dest[i + lane] = vec[lane];
    }

    const width = max - min;
    while (i < dest.len) : (i += 1) dest[i] = min + width * floatFrom(source, f32);
}

fn fillRangeF64From(source: anytype, dest: []f64, min: f64, max: f64) void {
    const VectorType = @Vector(4, f64);
    const min_vec: VectorType = @splat(min);
    const width_vec: VectorType = @splat(max - min);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const vec = min_vec + width_vec * vectorF64From(source, VectorType);
        inline for (0..4) |lane| dest[i + lane] = vec[lane];
    }

    const width = max - min;
    while (i < dest.len) : (i += 1) dest[i] = min + width * floatFrom(source, f64);
}

pub fn next(self: Rng) u64 {
    return self.nextFn(self.ptr);
}

pub fn boolean(self: Rng) bool {
    return booleanFrom(self);
}

pub fn booleanFrom(source: anytype) bool {
    return (@as(i64, @bitCast(nextFrom(source))) < 0);
}

pub fn chance(self: Rng, p: f64) bool {
    return chanceFrom(self, p);
}

pub fn chanceFrom(source: anytype, p: f64) bool {
    std.debug.assert(p >= 0 and p <= 1);
    if (p == 0) return false;
    if (p == 1) return true;
    return nextFrom(source) < probabilityThreshold(p);
}

pub fn chanceChecked(self: Rng, p: f64) Error!bool {
    return chanceCheckedFrom(self, p);
}

pub fn chanceCheckedFrom(source: anytype, p: f64) Error!bool {
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    return chanceFrom(source, p);
}

pub fn ratio(self: Rng, numerator: u32, denominator: u32) bool {
    return ratioFrom(self, numerator, denominator);
}

pub fn ratioFrom(source: anytype, numerator: u32, denominator: u32) bool {
    std.debug.assert(denominator > 0 and numerator <= denominator);
    if (numerator == 0) return false;
    if (numerator == denominator) return true;
    return uintLessThanFrom(source, u32, denominator) < numerator;
}

pub fn ratioChecked(self: Rng, numerator: u32, denominator: u32) Error!bool {
    return ratioCheckedFrom(self, numerator, denominator);
}

pub fn ratioCheckedFrom(source: anytype, numerator: u32, denominator: u32) Error!bool {
    if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
    return ratioFrom(source, numerator, denominator);
}

pub fn uint(self: Rng, comptime T: type) T {
    return uintFrom(self, T);
}

pub fn uintLessThan(self: Rng, comptime T: type, less_than: T) T {
    return uintLessThanFrom(self, T, less_than);
}

pub fn uintLessThanChecked(self: Rng, comptime T: type, less_than: T) Error!T {
    return uintLessThanCheckedFrom(self, T, less_than);
}

pub fn uintLessThanCheckedFrom(source: anytype, comptime T: type, less_than: T) Error!T {
    if (less_than == 0) return error.EmptyRange;
    return uintLessThanFrom(source, T, less_than);
}

pub fn uintAtMost(self: Rng, comptime T: type, at_most: T) T {
    return uintAtMostFrom(self, T, at_most);
}

pub fn uintFrom(source: anytype, comptime T: type) T {
    comptime requireInt(T);
    const info = @typeInfo(T).int;
    const Unsigned = std.meta.Int(.unsigned, info.bits);
    const bits_value = uintBitsFrom(source, Unsigned, info.bits);
    return @bitCast(bits_value);
}

pub fn uintLessThanFrom(source: anytype, comptime T: type, less_than: T) T {
    comptime requireUnsigned(T);
    std.debug.assert(less_than > 0);

    const bits = @typeInfo(T).int.bits;
    if (bits == 0) unreachable;

    var x = uintFrom(source, T);
    var m = std.math.mulWide(T, x, less_than);
    var l: T = @truncate(m);
    if (l < less_than) {
        var threshold = -%less_than;
        if (threshold >= less_than) {
            threshold -= less_than;
            if (threshold >= less_than) {
                threshold %= less_than;
            }
        }

        while (l < threshold) {
            x = uintFrom(source, T);
            m = std.math.mulWide(T, x, less_than);
            l = @truncate(m);
        }
    }

    return @intCast(m >> bits);
}

pub fn uintAtMostFrom(source: anytype, comptime T: type, at_most: T) T {
    comptime requireUnsigned(T);
    if (at_most == std.math.maxInt(T)) return uintFrom(source, T);
    return uintLessThanFrom(source, T, at_most + 1);
}

pub fn intRangeLessThan(self: Rng, comptime T: type, at_least: T, less_than: T) T {
    return intRangeLessThanFrom(self, T, at_least, less_than);
}

pub fn intRangeLessThanChecked(self: Rng, comptime T: type, at_least: T, less_than: T) Error!T {
    return intRangeLessThanCheckedFrom(self, T, at_least, less_than);
}

pub fn intRangeLessThanCheckedFrom(source: anytype, comptime T: type, at_least: T, less_than: T) Error!T {
    if (at_least >= less_than) return error.EmptyRange;
    return intRangeLessThanFrom(source, T, at_least, less_than);
}

pub fn intRangeAtMost(self: Rng, comptime T: type, at_least: T, at_most: T) T {
    return intRangeAtMostFrom(self, T, at_least, at_most);
}

pub fn intRangeAtMostChecked(self: Rng, comptime T: type, at_least: T, at_most: T) Error!T {
    return intRangeAtMostCheckedFrom(self, T, at_least, at_most);
}

pub fn intRangeAtMostCheckedFrom(source: anytype, comptime T: type, at_least: T, at_most: T) Error!T {
    if (at_least > at_most) return error.EmptyRange;
    return intRangeAtMostFrom(source, T, at_least, at_most);
}

pub fn intRangeLessThanFrom(source: anytype, comptime T: type, at_least: T, less_than: T) T {
    comptime requireInt(T);
    std.debug.assert(at_least < less_than);

    const info = @typeInfo(T).int;
    if (info.signedness == .signed) {
        const Unsigned = std.meta.Int(.unsigned, info.bits);
        const lo: Unsigned = @bitCast(at_least);
        const hi: Unsigned = @bitCast(less_than);
        const result = lo +% uintLessThanFrom(source, Unsigned, hi -% lo);
        return @bitCast(result);
    }

    return at_least + uintLessThanFrom(source, T, less_than - at_least);
}

pub fn intRangeAtMostFrom(source: anytype, comptime T: type, at_least: T, at_most: T) T {
    comptime requireInt(T);
    std.debug.assert(at_least <= at_most);

    const info = @typeInfo(T).int;
    if (info.signedness == .signed) {
        const Unsigned = std.meta.Int(.unsigned, info.bits);
        const lo: Unsigned = @bitCast(at_least);
        const hi: Unsigned = @bitCast(at_most);
        const result = lo +% uintAtMostFrom(source, Unsigned, hi -% lo);
        return @bitCast(result);
    }

    return at_least + uintAtMostFrom(source, T, at_most - at_least);
}

pub fn float(self: Rng, comptime T: type) T {
    comptime requireFloat(T);
    return switch (T) {
        f32 => f32FromBits(@truncate(self.next() >> 40)),
        f64 => @as(f64, @floatFromInt(self.next() >> 11)) * (1.0 / 9007199254740992.0),
        else => @compileError("alea supports f32 and f64 floats"),
    };
}

pub fn floatOpen(self: Rng, comptime T: type) T {
    return floatOpenFrom(self, T);
}

pub fn floatOpenClosed(self: Rng, comptime T: type) T {
    return floatOpenClosedFrom(self, T);
}

pub fn floatRange(self: Rng, comptime T: type, min: T, max: T) T {
    return floatRangeFrom(self, T, min, max);
}

pub fn floatRangeChecked(self: Rng, comptime T: type, min: T, max: T) Error!T {
    return floatRangeCheckedFrom(self, T, min, max);
}

pub fn floatRangeCheckedFrom(source: anytype, comptime T: type, min: T, max: T) Error!T {
    if (!(min <= max) or !std.math.isFinite(min) or !std.math.isFinite(max)) return error.EmptyRange;
    return floatRangeFrom(source, T, min, max);
}

pub fn vector(self: Rng, comptime VectorType: type) VectorType {
    return vectorFrom(self, VectorType);
}

pub fn vectorFrom(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    return switch (@typeInfo(info.child)) {
        .bool => vectorBoolsFrom(source, VectorType),
        .int => vectorIntsFrom(source, VectorType),
        .float => switch (info.child) {
            f32 => vectorF32From(source, VectorType),
            f64 => vectorF64From(source, VectorType),
            else => @compileError("alea supports f32 and f64 float vectors"),
        },
        else => @compileError("alea.Rng.vector supports bool, integer, and floating-point vectors"),
    };
}

pub fn vectorRange(self: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    return vectorRangeFrom(self, VectorType, min, max);
}

pub fn vectorOpen(self: Rng, comptime VectorType: type) VectorType {
    return vectorOpenFrom(self, VectorType);
}

pub fn vectorOpenClosed(self: Rng, comptime VectorType: type) VectorType {
    return vectorOpenClosedFrom(self, VectorType);
}

pub fn vectorOpenFrom(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    if (info.child == f32) return vectorOpenF32From(source, VectorType);
    if (info.child == f64) return vectorOpenF64From(source, VectorType);
    var out: VectorType = undefined;
    inline for (0..info.len) |i| out[i] = floatOpenFrom(source, info.child);
    return out;
}

pub fn vectorOpenClosedFrom(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    if (info.child == f32) return vectorOpenClosedF32From(source, VectorType);
    if (info.child == f64) return vectorOpenClosedF64From(source, VectorType);
    var out: VectorType = undefined;
    inline for (0..info.len) |i| out[i] = floatOpenClosedFrom(source, info.child);
    return out;
}

pub fn vectorRangeFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    const info = vectorInfo(VectorType);
    switch (@typeInfo(info.child)) {
        .int => {
            std.debug.assert(min < max);
            var out: VectorType = undefined;
            inline for (0..info.len) |i| out[i] = intRangeLessThanFrom(source, info.child, min, max);
            return out;
        },
        .float => {
            std.debug.assert(min <= max);
            return @as(VectorType, @splat(min)) + (@as(VectorType, @splat(max)) - @as(VectorType, @splat(min))) * vectorFrom(source, VectorType);
        },
        else => @compileError("Rng.vectorRange supports integer and floating-point vectors"),
    }
}

pub fn vectorRangeChecked(self: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    return vectorRangeCheckedFrom(self, VectorType, min, max);
}

pub fn vectorRangeCheckedFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    const info = vectorInfo(VectorType);
    switch (@typeInfo(info.child)) {
        .int => {
            if (min >= max) return error.EmptyRange;
        },
        .float => {
            if (!(min <= max) or !std.math.isFinite(min) or !std.math.isFinite(max)) return error.EmptyRange;
        },
        else => @compileError("Rng.vectorRangeChecked supports integer and floating-point vectors"),
    }
    return vectorRangeFrom(source, VectorType, min, max);
}

pub fn vectorChance(self: Rng, comptime VectorType: type, p: f64) VectorType {
    return vectorChanceFrom(self, VectorType, p);
}

pub fn vectorChanceFrom(source: anytype, comptime VectorType: type, p: f64) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("Rng.vectorChance expects a bool vector");
    std.debug.assert(p >= 0 and p <= 1);
    if (p == 0) return @splat(false);
    if (p == 1) return @splat(true);
    if (p == 0.5) return vectorBoolsFrom(source, VectorType);
    if (p == 0.25) return vectorChanceQuarterFrom(source, VectorType);

    const threshold = probabilityThreshold(p);
    var out: VectorType = undefined;
    inline for (0..info.len) |i| out[i] = nextFrom(source) < threshold;
    return out;
}

pub fn vectorChanceChecked(self: Rng, comptime VectorType: type, p: f64) Error!VectorType {
    return vectorChanceCheckedFrom(self, VectorType, p);
}

pub fn vectorChanceCheckedFrom(source: anytype, comptime VectorType: type, p: f64) Error!VectorType {
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    return vectorChanceFrom(source, VectorType, p);
}

pub fn vectorRatio(self: Rng, comptime VectorType: type, numerator: u32, denominator: u32) VectorType {
    return vectorRatioFrom(self, VectorType, numerator, denominator);
}

pub fn vectorRatioFrom(source: anytype, comptime VectorType: type, numerator: u32, denominator: u32) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("Rng.vectorRatio expects a bool vector");
    std.debug.assert(denominator > 0 and numerator <= denominator);
    if (numerator == 0) return @splat(false);
    if (numerator == denominator) return @splat(true);
    if (denominator == 2 and numerator == 1) return vectorBoolsFrom(source, VectorType);
    if (denominator == 4 and numerator == 1) return vectorChanceQuarterFrom(source, VectorType);
    if (std.math.isPowerOfTwo(denominator)) return vectorRatioPowerOfTwoFrom(source, VectorType, numerator, denominator);

    var out: VectorType = undefined;
    inline for (0..info.len) |i| out[i] = uintLessThanFrom(source, u32, denominator) < numerator;
    return out;
}

pub fn vectorRatioChecked(self: Rng, comptime VectorType: type, numerator: u32, denominator: u32) Error!VectorType {
    return vectorRatioCheckedFrom(self, VectorType, numerator, denominator);
}

pub fn vectorRatioCheckedFrom(source: anytype, comptime VectorType: type, numerator: u32, denominator: u32) Error!VectorType {
    if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
    return vectorRatioFrom(source, VectorType, numerator, denominator);
}

pub fn vectorStandardNormal(self: Rng, comptime VectorType: type) VectorType {
    return vectorStandardNormalFrom(self, VectorType);
}

pub fn vectorStandardNormalFrom(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    var out: VectorType = undefined;
    inline for (0..info.len) |lane| out[lane] = standardNormalFastFrom(source, info.child);
    return out;
}

pub fn vectorNormal(self: Rng, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) VectorType {
    return vectorNormalFrom(self, VectorType, mean, stddev);
}

pub fn vectorNormalChecked(self: Rng, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!VectorType {
    return vectorNormalCheckedFrom(self, VectorType, mean, stddev);
}

pub fn vectorNormalCheckedFrom(source: anytype, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!VectorType {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    if (!std.math.isFinite(mean) or !(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
    return vectorNormalFrom(source, VectorType, mean, stddev);
}

pub fn vectorNormalFrom(source: anytype, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) VectorType {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    std.debug.assert(stddev >= 0);
    if (info.child == f32 or info.child == f64) return vectorNormalScalarFrom(source, VectorType, mean, stddev);
    var out: VectorType = undefined;
    var std_random = randomFrom(source);
    inline for (0..info.len) |i| out[i] = mean + stddev * std_random.floatNorm(info.child);
    return out;
}

pub fn vectorExponential(self: Rng, comptime VectorType: type, rate: vectorChild(VectorType)) VectorType {
    return vectorExponentialFrom(self, VectorType, rate);
}

pub fn vectorExponentialChecked(self: Rng, comptime VectorType: type, rate: vectorChild(VectorType)) Error!VectorType {
    return vectorExponentialCheckedFrom(self, VectorType, rate);
}

pub fn vectorExponentialCheckedFrom(source: anytype, comptime VectorType: type, rate: vectorChild(VectorType)) Error!VectorType {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    if (!(rate > 0) or !std.math.isFinite(rate)) return error.InvalidParameter;
    return vectorExponentialFrom(source, VectorType, rate);
}

pub fn vectorExponentialFrom(source: anytype, comptime VectorType: type, rate: vectorChild(VectorType)) VectorType {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    std.debug.assert(rate > 0);
    if (info.child == f32 or info.child == f64) return vectorExponentialScalarFrom(source, VectorType, rate);
    var out: VectorType = undefined;
    var std_random = randomFrom(source);
    inline for (0..info.len) |i| out[i] = std_random.floatExp(info.child) / rate;
    return out;
}

pub fn vectorStandardExponential(self: Rng, comptime VectorType: type) VectorType {
    return vectorStandardExponentialFrom(self, VectorType);
}

pub fn vectorStandardExponentialFrom(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    var out: VectorType = undefined;
    inline for (0..info.len) |lane| out[lane] = standardExponentialFastFrom(source, info.child);
    return out;
}

pub fn durationRangeLessThan(self: Rng, min: std.Io.Duration, max: std.Io.Duration) std.Io.Duration {
    return durationRangeLessThanFrom(self, min, max);
}

pub fn durationRangeLessThanFrom(source: anytype, min: std.Io.Duration, max: std.Io.Duration) std.Io.Duration {
    std.debug.assert(min.nanoseconds < max.nanoseconds);
    return .{ .nanoseconds = intRangeLessThanFrom(source, i96, min.nanoseconds, max.nanoseconds) };
}

pub fn durationRangeAtMost(self: Rng, min: std.Io.Duration, max: std.Io.Duration) std.Io.Duration {
    return durationRangeAtMostFrom(self, min, max);
}

pub fn durationRangeAtMostFrom(source: anytype, min: std.Io.Duration, max: std.Io.Duration) std.Io.Duration {
    std.debug.assert(min.nanoseconds <= max.nanoseconds);
    return .{ .nanoseconds = intRangeAtMostFrom(source, i96, min.nanoseconds, max.nanoseconds) };
}

pub fn durationRangeLessThanChecked(self: Rng, min: std.Io.Duration, max: std.Io.Duration) Error!std.Io.Duration {
    return durationRangeLessThanCheckedFrom(self, min, max);
}

pub fn durationRangeLessThanCheckedFrom(source: anytype, min: std.Io.Duration, max: std.Io.Duration) Error!std.Io.Duration {
    if (min.nanoseconds >= max.nanoseconds) return error.EmptyRange;
    return durationRangeLessThanFrom(source, min, max);
}

pub fn durationRangeAtMostChecked(self: Rng, min: std.Io.Duration, max: std.Io.Duration) Error!std.Io.Duration {
    return durationRangeAtMostCheckedFrom(self, min, max);
}

pub fn durationRangeAtMostCheckedFrom(source: anytype, min: std.Io.Duration, max: std.Io.Duration) Error!std.Io.Duration {
    if (min.nanoseconds > max.nanoseconds) return error.EmptyRange;
    return durationRangeAtMostFrom(source, min, max);
}

pub fn unicodeScalar(self: Rng) u21 {
    return unicodeScalarFrom(self);
}

pub fn unicodeScalarFrom(source: anytype) u21 {
    const gap_size = 0xDFFF - 0xD800 + 1;
    var scalar = intRangeLessThanFrom(source, u21, gap_size, 0x11_0000);
    if (scalar <= 0xDFFF) scalar -= gap_size;
    return scalar;
}

pub fn normal(self: Rng, comptime T: type, mean: T, stddev: T) T {
    return normalFastFrom(self, T, mean, stddev);
}

pub fn normalChecked(self: Rng, comptime T: type, mean: T, stddev: T) Error!T {
    return normalCheckedFrom(self, T, mean, stddev);
}

pub fn normalCheckedFrom(source: anytype, comptime T: type, mean: T, stddev: T) Error!T {
    comptime requireFloat(T);
    if (!std.math.isFinite(mean) or !(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
    return normalFastFrom(source, T, mean, stddev);
}

pub inline fn standardNormalFastFrom(source: anytype, comptime T: type) T {
    comptime requireFloat(T);
    return switch (T) {
        f64 => normalZigguratF64(source),
        f32 => @as(f32, @floatCast(normalZigguratF64(source))),
        else => @compileError("alea supports f32 and f64 normal"),
    };
}

pub inline fn normalFastFrom(source: anytype, comptime T: type, mean: T, stddev: T) T {
    comptime requireFloat(T);
    std.debug.assert(stddev >= 0);
    return mean + stddev * standardNormalFastFrom(source, T);
}

pub fn exponential(self: Rng, comptime T: type, rate: T) T {
    return exponentialFastFrom(self, T, rate);
}

pub fn exponentialChecked(self: Rng, comptime T: type, rate: T) Error!T {
    return exponentialCheckedFrom(self, T, rate);
}

pub fn exponentialCheckedFrom(source: anytype, comptime T: type, rate: T) Error!T {
    comptime requireFloat(T);
    if (!(rate > 0) or !std.math.isFinite(rate)) return error.InvalidParameter;
    return exponentialFastFrom(source, T, rate);
}

pub inline fn standardExponentialFastFrom(source: anytype, comptime T: type) T {
    comptime requireFloat(T);
    return switch (T) {
        f64 => exponentialZigguratF64(source),
        f32 => @as(f32, @floatCast(exponentialZigguratF64(source))),
        else => @compileError("alea supports f32 and f64 exponential"),
    };
}

pub inline fn exponentialFastFrom(source: anytype, comptime T: type, rate: T) T {
    comptime requireFloat(T);
    std.debug.assert(rate > 0);
    return standardExponentialFastFrom(source, T) / rate;
}

pub fn enumValue(self: Rng, comptime EnumType: type) EnumType {
    return enumValueFrom(self, EnumType);
}

pub fn enumValueChecked(self: Rng, comptime EnumType: type) Error!EnumType {
    return enumValueCheckedFrom(self, EnumType);
}

pub fn enumValueCheckedFrom(source: anytype, comptime EnumType: type) Error!EnumType {
    comptime {
        if (@typeInfo(EnumType) != .@"enum") @compileError("enumValue expects an enum type");
    }
    const values = comptime std.enums.values(EnumType);
    if (comptime values.len == 0) return error.EmptyRange;
    return enumValueFrom(source, EnumType);
}

pub fn enumValueFrom(source: anytype, comptime EnumType: type) EnumType {
    comptime {
        if (@typeInfo(EnumType) != .@"enum") @compileError("enumValue expects an enum type");
    }
    const values = comptime std.enums.values(EnumType);
    comptime std.debug.assert(values.len > 0);
    if (values.len == 1) return values[0];
    return values[uintLessThanFrom(source, usize, values.len)];
}

pub fn shuffle(self: Rng, comptime T: type, items: []T) void {
    shuffleFrom(self, T, items);
}

pub fn shuffleFrom(source: anytype, comptime T: type, items: []T) void {
    if (items.len < 2) return;
    var i = items.len - 1;
    while (i > 0) : (i -= 1) {
        const j = uintAtMostFrom(source, usize, i);
        std.mem.swap(T, &items[i], &items[j]);
    }
}

pub fn choose(self: Rng, comptime T: type, items: []const T) ?T {
    return chooseFrom(self, T, items);
}

pub fn chooseChecked(self: Rng, comptime T: type, items: []const T) Error!T {
    return chooseCheckedFrom(self, T, items);
}

pub fn chooseCheckedFrom(source: anytype, comptime T: type, items: []const T) Error!T {
    return chooseFrom(source, T, items) orelse error.EmptyRange;
}

pub fn chooseFrom(source: anytype, comptime T: type, items: []const T) ?T {
    if (items.len == 0) return null;
    return items[uintLessThanFrom(source, usize, items.len)];
}

pub fn choosePtr(self: Rng, comptime T: type, items: []T) ?*T {
    return choosePtrFrom(self, T, items);
}

pub fn choosePtrChecked(self: Rng, comptime T: type, items: []T) Error!*T {
    return choosePtrCheckedFrom(self, T, items);
}

pub fn choosePtrCheckedFrom(source: anytype, comptime T: type, items: []T) Error!*T {
    return choosePtrFrom(source, T, items) orelse error.EmptyRange;
}

pub fn choosePtrFrom(source: anytype, comptime T: type, items: []T) ?*T {
    if (items.len == 0) return null;
    return &items[uintLessThanFrom(source, usize, items.len)];
}

pub fn weightedIndex(self: Rng, weights: []const f64) ?usize {
    return weightedIndexFrom(self, weights);
}

pub fn weightedIndexFrom(source: anytype, weights: []const f64) ?usize {
    return weightedIndexCheckedFrom(source, weights) catch unreachable;
}

pub fn weightedIndexChecked(self: Rng, weights: []const f64) Error!?usize {
    return weightedIndexCheckedFrom(self, weights);
}

pub fn weightedIndexCheckedFrom(source: anytype, weights: []const f64) Error!?usize {
    var total: f64 = 0;
    for (weights) |weight| {
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        total += weight;
        if (!std.math.isFinite(total)) return error.InvalidWeight;
    }
    if (weights.len == 0 or total == 0) return null;

    const point = floatFrom(source, f64) * total;
    var acc: f64 = 0;
    for (weights, 0..) |weight, i| {
        acc += weight;
        if (point < acc) return i;
    }
    return weights.len - 1;
}

pub fn sampleWithoutReplacement(self: Rng, comptime T: type, allocator: std.mem.Allocator, items: []const T, count: usize) ![]T {
    std.debug.assert(count <= items.len);
    return sampleWithoutReplacementFrom(self, T, allocator, items, count);
}

pub fn sampleWithoutReplacementFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, items: []const T, count: usize) ![]T {
    std.debug.assert(count <= items.len);
    return sampleWithoutReplacementCheckedFrom(source, T, allocator, items, count) catch unreachable;
}

pub fn sampleWithoutReplacementChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, items: []const T, count: usize) ![]T {
    return sampleWithoutReplacementCheckedFrom(self, T, allocator, items, count);
}

pub fn sampleWithoutReplacementCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, items: []const T, count: usize) ![]T {
    if (count > items.len) return error.InvalidParameter;
    var pool = try std.ArrayList(T).initCapacity(allocator, items.len);
    defer pool.deinit(allocator);
    try pool.appendSlice(allocator, items);

    var out = try std.ArrayList(T).initCapacity(allocator, count);
    errdefer out.deinit(allocator);

    while (out.items.len < count) {
        const index = uintLessThanFrom(source, usize, pool.items.len);
        try out.append(allocator, pool.swapRemove(index));
    }

    return out.toOwnedSlice(allocator);
}

pub fn ValueIterator(comptime T: type) type {
    return struct {
        const Self = @This();

        rng: Rng,

        pub fn next(self: *Self) ?T {
            return self.nextValue();
        }

        pub fn nextValue(self: *Self) T {
            return self.rng.value(T);
        }

        pub fn fill(self: *Self, dest: []T) void {
            if (comptime valueIteratorCanFill(T)) {
                self.rng.fill(T, dest);
                return;
            }
            for (dest) |*item| item.* = self.nextValue();
        }
    };
}

pub fn ValueIteratorFrom(comptime Source: type, comptime T: type) type {
    return struct {
        const Self = @This();

        source: Source,

        pub fn next(self: *Self) ?T {
            return self.nextValue();
        }

        pub fn nextValue(self: *Self) T {
            return valueFrom(self.source, T);
        }

        pub fn fill(self: *Self, dest: []T) void {
            if (comptime valueIteratorCanFill(T)) {
                fillFrom(self.source, T, dest);
                return;
            }
            for (dest) |*item| item.* = self.nextValue();
        }
    };
}

fn valueIteratorCanFill(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .int => @typeInfo(T).int.bits == 64,
        .float => T == f64,
        .vector => vectorValueIteratorCanFill(T),
        else => false,
    };
}

fn vectorValueIteratorCanFill(comptime T: type) bool {
    const info = vectorInfo(T);
    return switch (@typeInfo(info.child)) {
        .int => @typeInfo(info.child).int.bits == 64,
        .float => info.child == f64,
        else => false,
    };
}

pub fn SampleIterator(comptime Sampler: type, comptime T: type) type {
    return struct {
        const Self = @This();

        rng: Rng,
        sampler: Sampler,

        pub fn next(self: *Self) ?T {
            return self.nextValue();
        }

        pub fn nextValue(self: *Self) T {
            return sampleWith(T, self.sampler, self.rng);
        }

        pub fn fill(self: *Self, dest: []T) void {
            fillSample(self.rng, T, dest, self.sampler);
        }
    };
}

pub fn SampleIteratorFrom(comptime Source: type, comptime Sampler: type, comptime T: type) type {
    return struct {
        const Self = @This();

        source: Source,
        sampler: Sampler,

        pub fn next(self: *Self) ?T {
            return self.nextValue();
        }

        pub fn nextValue(self: *Self) T {
            return sampleFromWith(T, self.sampler, self.source);
        }

        pub fn fill(self: *Self, dest: []T) void {
            fillSampleFrom(self.source, T, dest, self.sampler);
        }
    };
}

fn uintBits(self: Rng, comptime T: type, comptime bits: comptime_int) T {
    return uintBitsFrom(self, T, bits);
}

fn uintBitsFrom(source: anytype, comptime T: type, comptime bits: comptime_int) T {
    comptime requireUnsigned(T);
    if (bits == 0) return 0;

    var remaining: usize = bits;
    var shift: usize = 0;
    var result: T = 0;

    while (remaining > 0) {
        const take = @min(remaining, 64);
        const mask = if (take == 64) std.math.maxInt(u64) else (@as(u64, 1) << @intCast(take)) - 1;
        const part = nextFrom(source) & mask;
        result |= @as(T, @intCast(part)) << @intCast(shift);
        remaining -= take;
        shift += take;
    }

    return result;
}

pub inline fn nextFrom(source: anytype) u64 {
    return source.next();
}

fn randomFrom(source: anytype) std.Random {
    return source.random();
}

inline fn normalZigguratF64(source: anytype) f64 {
    const tables = std_ziggurat.NormDist;
    while (true) {
        const bits = nextFrom(source);
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;

        if (@abs(u) < norm_ziggurat_ratio[i]) {
            @branchHint(.likely);
            return u * tables.x[i];
        }
        const x = u * tables.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return normalZigguratZeroCase(source, u);
        }
        if (tables.f[i + 1] + (tables.f[i] - tables.f[i + 1]) * floatFrom(source, f64) < @exp(-x * x / 2.0)) return x;
    }
}

fn normalZigguratZeroCase(source: anytype, u: f64) f64 {
    var x: f64 = 1;
    var y: f64 = 0;
    while (-2.0 * y < x * x) {
        x = @log(floatOpenFrom(source, f64)) / std_ziggurat.norm_r;
        y = @log(floatOpenFrom(source, f64));
    }
    return if (u < 0) x - std_ziggurat.norm_r else std_ziggurat.norm_r - x;
}

inline fn exponentialZigguratF64(source: anytype) f64 {
    const tables = std_ziggurat.ExpDist;
    while (true) {
        const bits = nextFrom(source);
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);

        if (mantissa < exp_ziggurat_mantissa_threshold[i]) {
            @branchHint(.likely);
            return u * tables.x[i];
        }
        const x = u * tables.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return std_ziggurat.exp_r - @log(floatOpenFrom(source, f64));
        }
        if (tables.f[i + 1] + (tables.f[i] - tables.f[i + 1]) * floatFrom(source, f64) < @exp(-x)) return x;
    }
}

fn requireInt(comptime T: type) void {
    if (@typeInfo(T) != .int) @compileError("expected integer type, found " ++ @typeName(T));
}

fn requireUnsigned(comptime T: type) void {
    requireInt(T);
    if (@typeInfo(T).int.signedness != .unsigned) {
        @compileError("expected unsigned integer type, found " ++ @typeName(T));
    }
}

fn requireFloat(comptime T: type) void {
    if (@typeInfo(T) != .float) @compileError("expected float type, found " ++ @typeName(T));
}

fn vectorInfo(comptime VectorType: type) @TypeOf(@typeInfo(VectorType).vector) {
    const info = @typeInfo(VectorType);
    if (info != .vector) @compileError("expected vector type, found " ++ @typeName(VectorType));
    return info.vector;
}

fn vectorChild(comptime VectorType: type) type {
    return vectorInfo(VectorType).child;
}

fn vectorScalarFrom(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    var out: VectorType = undefined;
    inline for (0..info.len) |i| {
        out[i] = switch (@typeInfo(info.child)) {
            .bool => nextFrom(source) & 1 != 0,
            .int => uintFrom(source, info.child),
            .float => floatFrom(source, info.child),
            else => @compileError("unsupported scalar vector child"),
        };
    }
    return out;
}

fn vectorBoolsFrom(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("vectorBools expects a bool vector");

    var out: VectorType = undefined;
    var bits: u64 = 0;
    inline for (0..info.len) |i| {
        if (i % 64 == 0) bits = nextFrom(source);
        out[i] = @as(i64, @bitCast(bits)) < 0;
        bits <<= 1;
    }
    return out;
}

fn vectorChanceQuarterFrom(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("vectorChanceQuarterFrom expects a bool vector");

    var out: VectorType = undefined;
    var bits: u64 = 0;
    inline for (0..info.len) |i| {
        if (i % 32 == 0) bits = nextFrom(source);
        out[i] = (bits & 0b11) == 0;
        bits >>= 2;
    }
    return out;
}

fn vectorRatioPowerOfTwoFrom(source: anytype, comptime VectorType: type, numerator: u32, denominator: u32) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("vectorRatioPowerOfTwoFrom expects a bool vector");

    const bits_per_sample = std.math.log2_int(u32, denominator);
    const samples_per_word = 64 / @as(usize, bits_per_sample);
    const mask = @as(u64, denominator - 1);

    var out: VectorType = undefined;
    var bits: u64 = 0;
    inline for (0..info.len) |i| {
        if (i % samples_per_word == 0) bits = nextFrom(source);
        out[i] = @as(u32, @intCast(bits & mask)) < numerator;
        bits >>= @intCast(bits_per_sample);
    }
    return out;
}

fn vectorIntsFrom(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    comptime requireInt(info.child);
    const int_info = @typeInfo(info.child).int;
    if (int_info.bits == 0) return @splat(0);
    if (int_info.bits > 64) return vectorScalarFrom(source, VectorType);

    const Unsigned = std.meta.Int(.unsigned, int_info.bits);
    const lanes_per_word = @max(1, 64 / int_info.bits);
    const mask = if (int_info.bits == 64) std.math.maxInt(u64) else (@as(u64, 1) << @intCast(int_info.bits)) - 1;

    var out: VectorType = undefined;
    var bits: u64 = 0;
    inline for (0..info.len) |i| {
        if (i % lanes_per_word == 0) bits = nextFrom(source);
        const raw: Unsigned = @intCast(bits & mask);
        out[i] = @bitCast(raw);
        if (int_info.bits != 64) bits >>= @intCast(int_info.bits);
    }
    return out;
}

fn vectorF32From(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != f32) @compileError("vectorF32 expects a f32 vector");

    var out: VectorType = undefined;
    var bits: u64 = 0;
    inline for (0..info.len) |i| {
        if (i % 2 == 0) bits = nextFrom(source);
        out[i] = if (i % 2 == 0)
            f32FromBits(@truncate(bits >> 40))
        else
            f32FromBits(@truncate(bits >> 16));
    }
    return out;
}

fn vectorF64From(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != f64) @compileError("vectorF64From expects an f64 vector");

    const RawVector = @Vector(info.len, u64);
    var raw: RawVector = undefined;
    inline for (0..info.len) |i| raw[i] = f64UnitBitsFromRaw(nextFrom(source));
    return @as(VectorType, @bitCast(raw)) - @as(VectorType, @splat(1.0));
}

fn vectorOpenF32From(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != f32) @compileError("vectorOpenF32From expects an f32 vector");

    var out: VectorType = undefined;
    var bits: u64 = 0;
    inline for (0..info.len) |i| {
        if (i % 2 == 0) bits = nextFrom(source);
        const raw: u24 = if (i % 2 == 0)
            @truncate(bits >> 40)
        else
            @truncate(bits >> 16);
        out[i] = f32OpenFromBits(raw);
    }
    return out;
}

fn vectorOpenF64From(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != f64) @compileError("vectorOpenF64From expects an f64 vector");

    const RawVector = @Vector(info.len, u64);
    var raw: RawVector = undefined;
    inline for (0..info.len) |i| raw[i] = f64UnitOpenBitsFromRaw(nextFrom(source));
    return @as(VectorType, @bitCast(raw)) - @as(VectorType, @splat(1.0 - std.math.floatEps(f64) / 2.0));
}

fn vectorOpenClosedF32From(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != f32) @compileError("vectorOpenClosedF32From expects an f32 vector");

    var out: VectorType = undefined;
    var bits: u64 = 0;
    inline for (0..info.len) |i| {
        if (i % 2 == 0) bits = nextFrom(source);
        const raw: u24 = if (i % 2 == 0)
            @truncate(bits >> 40)
        else
            @truncate(bits >> 16);
        out[i] = (@as(f32, @floatFromInt(raw)) + 1.0) * (1.0 / 16777216.0);
    }
    return out;
}

fn vectorOpenClosedF64From(source: anytype, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != f64) @compileError("vectorOpenClosedF64From expects an f64 vector");

    const RawVector = @Vector(info.len, u64);
    var raw: RawVector = undefined;
    inline for (0..info.len) |i| raw[i] = nextFrom(source) >> 11;
    return (@as(VectorType, @floatFromInt(raw)) + @as(VectorType, @splat(1))) *
        @as(VectorType, @splat(1.0 / 9007199254740992.0));
}

fn fillVectorNormalScalarFrom(source: anytype, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) void {
    const info = vectorInfo(VectorType);
    if (info.child != f32 and info.child != f64) @compileError("fillVectorNormalScalarFrom expects a float vector");

    for (dest) |*item| item.* = vectorNormalScalarFrom(source, VectorType, mean, stddev);
}

fn fillVectorExponentialScalarFrom(source: anytype, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) void {
    const info = vectorInfo(VectorType);
    if (info.child != f32 and info.child != f64) @compileError("fillVectorExponentialScalarFrom expects a float vector");

    for (dest) |*item| item.* = vectorExponentialScalarFrom(source, VectorType, rate);
}

fn normalAffineInPlace(comptime T: type, dest: []T, mean: T, stddev: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => normalAffineInPlaceVector(T, @Vector(8, f32), dest, mean, stddev),
        f64 => normalAffineInPlaceVector(T, @Vector(4, f64), dest, mean, stddev),
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn normalAffineInPlaceVector(comptime T: type, comptime VectorType: type, dest: []T, mean: T, stddev: T) void {
    const len = @typeInfo(VectorType).vector.len;
    const mean_vec: VectorType = @splat(mean);
    const stddev_vec: VectorType = @splat(stddev);

    var i: usize = 0;
    while (i + len <= dest.len) : (i += len) {
        var vec: VectorType = undefined;
        inline for (0..len) |lane| vec[lane] = dest[i + lane];
        vec = mean_vec + stddev_vec * vec;
        inline for (0..len) |lane| dest[i + lane] = vec[lane];
    }

    while (i < dest.len) : (i += 1) dest[i] = mean + stddev * dest[i];
}

fn vectorNormalScalarFrom(source: anytype, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != f32 and info.child != f64) @compileError("vectorNormalScalarFrom expects a float vector");

    var out: VectorType = undefined;
    inline for (0..info.len) |lane| out[lane] = normalFastFrom(source, info.child, mean, stddev);
    return out;
}

fn vectorExponentialScalarFrom(source: anytype, comptime VectorType: type, rate: vectorChild(VectorType)) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != f32 and info.child != f64) @compileError("vectorExponentialScalarFrom expects a float vector");

    var out: VectorType = undefined;
    inline for (0..info.len) |lane| out[lane] = exponentialFastFrom(source, info.child, rate);
    return out;
}

fn f32FromBits(bits: u24) f32 {
    return @as(f32, @floatFromInt(bits)) * (1.0 / 16777216.0);
}

fn f32OpenFromBits(bits: u24) f32 {
    const non_zero = if (bits == 0) @as(u24, 1) else bits;
    return @as(f32, @floatFromInt(non_zero)) * (1.0 / 16777216.0);
}

fn f64UnitBitsFromRaw(raw: u64) u64 {
    return (@as(u64, 0x3ff) << 52) | (raw >> 12);
}

fn f64FromRaw(raw: u64) f64 {
    return @as(f64, @bitCast(f64UnitBitsFromRaw(raw))) - 1.0;
}

fn f64UnitOpenBitsFromRaw(raw: u64) u64 {
    return (@as(u64, 0x3ff) << 52) | (raw >> 12);
}

fn f64OpenFromRaw(raw: u64) f64 {
    return @as(f64, @bitCast(f64UnitOpenBitsFromRaw(raw))) - (1.0 - std.math.floatEps(f64) / 2.0);
}

fn f64OpenClosedFromRaw(raw: u64) f64 {
    return (@as(f64, @floatFromInt(raw >> 11)) + 1.0) * (1.0 / 9007199254740992.0);
}

pub fn floatFrom(source: anytype, comptime T: type) T {
    comptime requireFloat(T);
    return switch (T) {
        f32 => f32FromBits(@truncate(nextFrom(source) >> 40)),
        f64 => f64FromRaw(nextFrom(source)),
        else => @compileError("alea supports f32 and f64 floats"),
    };
}

pub fn floatOpenFrom(source: anytype, comptime T: type) T {
    comptime requireFloat(T);
    return switch (T) {
        f32 => f32OpenFromBits(@truncate(nextFrom(source) >> 40)),
        f64 => f64OpenFromRaw(nextFrom(source)),
        else => @compileError("alea supports f32 and f64 floats"),
    };
}

pub fn floatOpenClosedFrom(source: anytype, comptime T: type) T {
    comptime requireFloat(T);
    return switch (T) {
        f32 => (@as(f32, @floatFromInt(nextFrom(source) >> 40)) + 1.0) * (1.0 / 16777216.0),
        f64 => f64OpenClosedFromRaw(nextFrom(source)),
        else => @compileError("alea supports f32 and f64 floats"),
    };
}

pub fn floatRangeFrom(source: anytype, comptime T: type, min: T, max: T) T {
    comptime requireFloat(T);
    std.debug.assert(min <= max);
    return min + (max - min) * floatFrom(source, T);
}

pub fn probabilityThreshold(p: f64) u64 {
    std.debug.assert(p >= 0 and p <= 1);
    if (p <= 0) return 0;
    if (p >= 1) return std.math.maxInt(u64);
    const scale = 0x1.0p64;
    const threshold = @floor(p * scale);
    if (threshold >= scale) return std.math.maxInt(u64);
    return @intFromFloat(threshold);
}

test "rng facade covers scalar APIs" {
    const Xoshiro256 = @import("engines/xoshiro256.zig");
    var engine = Xoshiro256.init(7);
    const rng = Rng.init(&engine);

    try std.testing.expect(rng.uintLessThan(u32, 10) < 10);
    try std.testing.expect(rng.intRangeLessThan(i32, -5, 5) >= -5);
    try std.testing.expect(rng.float(f64) < 1.0);
    try std.testing.expect(rng.floatOpen(f64) > 0.0);
    try std.testing.expect(Rng.floatOpenFrom(&engine, f64) > 0.0);
    _ = Rng.booleanFrom(&engine);
    const direct_open_closed = Rng.floatOpenClosedFrom(&engine, f64);
    try std.testing.expect(direct_open_closed > 0.0 and direct_open_closed <= 1.0);
    const direct_float_range = Rng.floatRangeFrom(&engine, f64, -1, 1);
    try std.testing.expect(direct_float_range >= -1 and direct_float_range < 1);
    try std.testing.expect(rng.chance(1));
    try std.testing.expect(Rng.chanceFrom(&engine, 1));
    try std.testing.expect(!rng.ratio(0, 7));
    try std.testing.expect(Rng.ratioFrom(&engine, 1, 1));
    try std.testing.expect(rng.chance(1.0 - std.math.floatEps(f64) / 2.0));
    try std.testing.expect(try rng.chanceChecked(0.5) or true);
    try std.testing.expect(try Rng.chanceCheckedFrom(&engine, 1));
    try std.testing.expect(try Rng.ratioCheckedFrom(&engine, 1, 1));
    try std.testing.expect(try Rng.uintLessThanCheckedFrom(&engine, u32, 10) < 10);
    try std.testing.expect(try Rng.intRangeLessThanCheckedFrom(&engine, i32, -5, 5) >= -5);
    try std.testing.expect(try Rng.intRangeAtMostCheckedFrom(&engine, i32, -5, 5) <= 5);
    try std.testing.expect(try Rng.floatRangeCheckedFrom(&engine, f64, -1, 1) >= -1);
    try std.testing.expectError(error.InvalidProbability, rng.chanceChecked(1.1));
    try std.testing.expectError(error.InvalidProbability, Rng.chanceCheckedFrom(&engine, 1.1));
    var empty_bool_buf: [0]bool = .{};
    try std.testing.expectError(error.InvalidProbability, rng.fillChanceChecked(&empty_bool_buf, 1.1));
    try std.testing.expectError(error.InvalidProbability, rng.fillRatioChecked(&empty_bool_buf, 2, 1));
    try std.testing.expectError(error.InvalidProbability, rng.vectorChanceChecked(@Vector(4, bool), -0.1));
    try std.testing.expectError(error.InvalidProbability, rng.vectorRatioChecked(@Vector(4, bool), 2, 1));
    try std.testing.expectError(error.InvalidProbability, rng.ratioChecked(2, 1));
    try std.testing.expectError(error.InvalidProbability, Rng.ratioCheckedFrom(&engine, 2, 1));
    try std.testing.expectError(error.EmptyRange, rng.uintLessThanChecked(u32, 0));
    try std.testing.expectError(error.EmptyRange, Rng.uintLessThanCheckedFrom(&engine, u32, 0));
    try std.testing.expectError(error.EmptyRange, rng.intRangeLessThanChecked(u32, 3, 3));
    try std.testing.expectError(error.EmptyRange, Rng.intRangeLessThanCheckedFrom(&engine, u32, 3, 3));
    try std.testing.expectError(error.EmptyRange, rng.intRangeAtMostChecked(u32, 4, 3));
    try std.testing.expectError(error.EmptyRange, Rng.intRangeAtMostCheckedFrom(&engine, u32, 4, 3));
    try std.testing.expectError(error.EmptyRange, rng.floatRangeChecked(f64, std.math.inf(f64), 1));
    try std.testing.expectError(error.EmptyRange, Rng.floatRangeCheckedFrom(&engine, f64, std.math.inf(f64), 1));
    const duration = rng.durationRangeAtMost(.fromMilliseconds(10), .fromMilliseconds(20));
    try std.testing.expect(duration.nanoseconds >= std.time.ns_per_ms * 10);
    try std.testing.expect(duration.nanoseconds <= std.time.ns_per_ms * 20);
    const direct_duration = Rng.durationRangeAtMostFrom(&engine, .fromMilliseconds(10), .fromMilliseconds(20));
    try std.testing.expect(direct_duration.nanoseconds >= std.time.ns_per_ms * 10);
    try std.testing.expect(direct_duration.nanoseconds <= std.time.ns_per_ms * 20);
    const checked_direct_duration = try Rng.durationRangeLessThanCheckedFrom(&engine, .fromMilliseconds(10), .fromMilliseconds(20));
    try std.testing.expect(checked_direct_duration.nanoseconds >= std.time.ns_per_ms * 10);
    try std.testing.expect(checked_direct_duration.nanoseconds < std.time.ns_per_ms * 20);
    try std.testing.expectError(error.EmptyRange, rng.durationRangeLessThanChecked(.fromSeconds(2), .fromSeconds(1)));
    try std.testing.expectError(error.EmptyRange, Rng.durationRangeLessThanCheckedFrom(&engine, .fromSeconds(2), .fromSeconds(1)));
    try std.testing.expectError(error.EmptyRange, Rng.durationRangeAtMostCheckedFrom(&engine, .fromSeconds(2), .fromSeconds(1)));

    const tuple = rng.value(struct { u8, bool, f32 });
    try std.testing.expect(tuple[2] < 1.0);

    const direct_tuple = Rng.valueFrom(&engine, struct { u8, bool, f32 });
    try std.testing.expect(direct_tuple[2] >= 0 and direct_tuple[2] < 1.0);

    const direct_array = Rng.valueFrom(&engine, [4]u16);
    var any_direct_array_non_zero = false;
    for (direct_array) |item| any_direct_array_non_zero = any_direct_array_non_zero or item != 0;
    try std.testing.expect(any_direct_array_non_zero);

    const scalar = rng.unicodeScalar();
    try std.testing.expect(scalar < 0xD800 or scalar > 0xDFFF);
    try std.testing.expect(scalar < 0x11_0000);
    const direct_scalar = Rng.unicodeScalarFrom(&engine);
    try std.testing.expect(direct_scalar < 0xD800 or direct_scalar > 0xDFFF);
    try std.testing.expect(direct_scalar < 0x11_0000);

    var buf: [16]u16 = undefined;
    rng.fill(u16, &buf);
    var any_non_zero = false;
    for (buf) |item| any_non_zero = any_non_zero or item != 0;
    try std.testing.expect(any_non_zero);

    var u32_buf: [16]u32 = undefined;
    rng.fill(u32, &u32_buf);
    var any_u32_non_zero = false;
    for (u32_buf) |item| any_u32_non_zero = any_u32_non_zero or item != 0;
    try std.testing.expect(any_u32_non_zero);

    var direct_u32_buf: [16]u32 = undefined;
    Rng.fillFrom(&engine, u32, &direct_u32_buf);
    var any_direct_u32_non_zero = false;
    for (direct_u32_buf) |item| any_direct_u32_non_zero = any_direct_u32_non_zero or item != 0;
    try std.testing.expect(any_direct_u32_non_zero);

    var bool_buf: [128]bool = undefined;
    rng.fill(bool, &bool_buf);
    var saw_true = false;
    var saw_false = false;
    for (bool_buf) |item| {
        saw_true = saw_true or item;
        saw_false = saw_false or !item;
    }
    try std.testing.expect(saw_true and saw_false);

    var chance_buf: [64]bool = undefined;
    rng.fillChance(&chance_buf, 0);
    for (chance_buf) |item| try std.testing.expect(!item);
    Rng.fillChanceFrom(&engine, &chance_buf, 1);
    for (chance_buf) |item| try std.testing.expect(item);
    try Rng.fillChanceCheckedFrom(&engine, &chance_buf, 0);
    for (chance_buf) |item| try std.testing.expect(!item);
    rng.fillRatio(&chance_buf, 0, 1);
    for (chance_buf) |item| try std.testing.expect(!item);
    Rng.fillRatioFrom(&engine, &chance_buf, 1, 1);
    for (chance_buf) |item| try std.testing.expect(item);
    try Rng.fillRatioCheckedFrom(&engine, &chance_buf, 0, 1);
    for (chance_buf) |item| try std.testing.expect(!item);

    var ranged_buf: [16]i16 = undefined;
    rng.fillRange(i16, &ranged_buf, -20, 20);
    for (ranged_buf) |item| try std.testing.expect(item >= -20 and item < 20);

    var ranged_float_buf: [16]f32 = undefined;
    try rng.fillRangeChecked(f32, &ranged_float_buf, -1, 1);
    for (ranged_float_buf) |item| try std.testing.expect(item >= -1 and item < 1);

    var direct_checked_ranged_float_buf: [16]f32 = undefined;
    try Rng.fillRangeCheckedFrom(&engine, f32, &direct_checked_ranged_float_buf, -1, 1);
    for (direct_checked_ranged_float_buf) |item| try std.testing.expect(item >= -1 and item < 1);

    var open_float_buf: [17]f32 = undefined;
    rng.fillOpen(f32, &open_float_buf);
    for (open_float_buf) |item| try std.testing.expect(item > 0 and item < 1);

    var direct_open_float_buf: [17]f32 = undefined;
    Rng.fillOpenFrom(&engine, f32, &direct_open_float_buf);
    for (direct_open_float_buf) |item| try std.testing.expect(item > 0 and item < 1);

    var open_closed_float_buf: [17]f32 = undefined;
    rng.fillOpenClosed(f32, &open_closed_float_buf);
    for (open_closed_float_buf) |item| try std.testing.expect(item > 0 and item <= 1);

    var direct_open_closed_float_buf: [17]f32 = undefined;
    Rng.fillOpenClosedFrom(&engine, f32, &direct_open_closed_float_buf);
    for (direct_open_closed_float_buf) |item| try std.testing.expect(item > 0 and item <= 1);

    var f32_buf: [17]f32 = undefined;
    rng.fill(f32, &f32_buf);
    for (f32_buf) |item| try std.testing.expect(item >= 0 and item < 1);

    var f64_buf: [17]f64 = undefined;
    rng.fill(f64, &f64_buf);
    for (f64_buf) |item| try std.testing.expect(item >= 0 and item < 1);

    var direct_f64_buf: [17]f64 = undefined;
    Rng.fillFrom(&engine, f64, &direct_f64_buf);
    for (direct_f64_buf) |item| try std.testing.expect(item >= 0 and item < 1);

    var open_f64_buf: [17]f64 = undefined;
    rng.fillOpen(f64, &open_f64_buf);
    for (open_f64_buf) |item| try std.testing.expect(item > 0 and item < 1);

    var open_closed_f64_buf: [17]f64 = undefined;
    Rng.fillOpenClosedFrom(&engine, f64, &open_closed_f64_buf);
    for (open_closed_f64_buf) |item| try std.testing.expect(item > 0 and item <= 1);

    var ranged_f64_buf: [17]f64 = undefined;
    rng.fillRange(f64, &ranged_f64_buf, -1, 1);
    for (ranged_f64_buf) |item| try std.testing.expect(item >= -1 and item < 1);

    var direct_ranged_f64_buf: [17]f64 = undefined;
    Rng.fillRangeFrom(&engine, f64, &direct_ranged_f64_buf, -1, 1);
    for (direct_ranged_f64_buf) |item| try std.testing.expect(item >= -1 and item < 1);

    var normal_buf: [16]f64 = undefined;
    try rng.fillNormalChecked(f64, &normal_buf, 0, 1);
    for (normal_buf) |item| try std.testing.expect(std.math.isFinite(item));

    var direct_normal_buf: [16]f64 = undefined;
    Rng.fillNormalFrom(&engine, f64, &direct_normal_buf, 0, 1);
    for (direct_normal_buf) |item| try std.testing.expect(std.math.isFinite(item));

    var direct_checked_normal_buf: [16]f64 = undefined;
    try Rng.fillNormalCheckedFrom(&engine, f64, &direct_checked_normal_buf, 0, 1);
    for (direct_checked_normal_buf) |item| try std.testing.expect(std.math.isFinite(item));

    var normal_f32_buf: [33]f32 = undefined;
    try rng.fillNormalChecked(f32, &normal_f32_buf, 0, 1);
    for (normal_f32_buf) |item| try std.testing.expect(std.math.isFinite(item));

    var exp_buf: [16]f64 = undefined;
    try rng.fillExponentialChecked(f64, &exp_buf, 2);
    for (exp_buf) |item| try std.testing.expect(item >= 0);

    var direct_exp_buf: [16]f64 = undefined;
    Rng.fillExponentialFrom(&engine, f64, &direct_exp_buf, 2);
    for (direct_exp_buf) |item| try std.testing.expect(item >= 0);

    var direct_checked_exp_buf: [16]f64 = undefined;
    try Rng.fillExponentialCheckedFrom(&engine, f64, &direct_checked_exp_buf, 2);
    for (direct_checked_exp_buf) |item| try std.testing.expect(item >= 0);

    var exp_f32_buf: [17]f32 = undefined;
    try rng.fillExponentialChecked(f32, &exp_f32_buf, 2);
    for (exp_f32_buf) |item| try std.testing.expect(item >= 0);

    const alea = @import("root.zig");
    var poisson_buf: [16]u64 = undefined;
    rng.fillSample(u64, &poisson_buf, try alea.distributions.Poisson.init(8));
    for (poisson_buf) |item| try std.testing.expect(item < 64);

    var direct_poisson_buf: [16]u64 = undefined;
    Rng.fillSampleFrom(&engine, u64, &direct_poisson_buf, try alea.distributions.Poisson.init(8));
    for (direct_poisson_buf) |item| try std.testing.expect(item < 64);

    var normal_sampler = try alea.distributions.Normal(f64).init(0, 1);
    var sample_buf: [16]f64 = undefined;
    rng.fillSample(f64, &sample_buf, &normal_sampler);
    for (sample_buf) |item| try std.testing.expect(std.math.isFinite(item));

    const uvec = rng.value(@Vector(4, u16));
    var any_vec_non_zero = false;
    inline for (0..4) |i| any_vec_non_zero = any_vec_non_zero or uvec[i] != 0;
    try std.testing.expect(any_vec_non_zero);

    const direct_uvec = Rng.vectorFrom(&engine, @Vector(4, u16));
    inline for (0..4) |i| _ = direct_uvec[i];

    const ivec = rng.value(@Vector(8, i16));
    inline for (0..8) |i| _ = ivec[i];

    const bvec = rng.value(@Vector(64, bool));
    var vector_saw_true = false;
    var vector_saw_false = false;
    inline for (0..64) |i| {
        vector_saw_true = vector_saw_true or bvec[i];
        vector_saw_false = vector_saw_false or !bvec[i];
    }
    try std.testing.expect(vector_saw_true and vector_saw_false);

    const false_vec = rng.vectorChance(@Vector(8, bool), 0);
    inline for (0..8) |i| try std.testing.expect(!false_vec[i]);
    const true_vec = Rng.vectorChanceFrom(&engine, @Vector(8, bool), 1);
    inline for (0..8) |i| try std.testing.expect(true_vec[i]);
    const false_ratio_vec = rng.vectorRatio(@Vector(8, bool), 0, 1);
    inline for (0..8) |i| try std.testing.expect(!false_ratio_vec[i]);
    const true_ratio_vec = Rng.vectorRatioFrom(&engine, @Vector(8, bool), 1, 1);
    inline for (0..8) |i| try std.testing.expect(true_ratio_vec[i]);

    const fvec = rng.value(@Vector(4, f32));
    inline for (0..4) |i| try std.testing.expect(fvec[i] >= 0 and fvec[i] < 1);

    const open_fvec = rng.vectorOpen(@Vector(4, f32));
    inline for (0..4) |i| try std.testing.expect(open_fvec[i] > 0 and open_fvec[i] < 1);

    const direct_open_closed_fvec = Rng.vectorOpenClosedFrom(&engine, @Vector(4, f32));
    inline for (0..4) |i| try std.testing.expect(direct_open_closed_fvec[i] > 0 and direct_open_closed_fvec[i] <= 1);

    var vec_buf: [8]@Vector(8, f32) = undefined;
    rng.fill(@Vector(8, f32), &vec_buf);
    for (vec_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] >= 0 and vec[i] < 1);

    var direct_vec_buf: [4]@Vector(8, f32) = undefined;
    Rng.fillVectorFrom(&engine, @Vector(8, f32), &direct_vec_buf);
    for (direct_vec_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] >= 0 and vec[i] < 1);

    var vec_open_buf: [4]@Vector(8, f32) = undefined;
    rng.fillVectorOpen(@Vector(8, f32), &vec_open_buf);
    for (vec_open_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] > 0 and vec[i] < 1);

    var direct_vec_open_buf: [4]@Vector(8, f32) = undefined;
    Rng.fillVectorOpenFrom(&engine, @Vector(8, f32), &direct_vec_open_buf);
    for (direct_vec_open_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] > 0 and vec[i] < 1);

    var vec_open_closed_buf: [4]@Vector(8, f32) = undefined;
    rng.fillVectorOpenClosed(@Vector(8, f32), &vec_open_closed_buf);
    for (vec_open_closed_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] > 0 and vec[i] <= 1);

    var direct_vec_open_closed_buf: [4]@Vector(8, f32) = undefined;
    Rng.fillVectorOpenClosedFrom(&engine, @Vector(8, f32), &direct_vec_open_closed_buf);
    for (direct_vec_open_closed_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] > 0 and vec[i] <= 1);

    var vec_range_buf: [8]@Vector(8, f32) = undefined;
    try rng.fillVectorRangeChecked(@Vector(8, f32), &vec_range_buf, -1, 1);
    for (vec_range_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] >= -1 and vec[i] < 1);

    var direct_checked_vec_range_buf: [4]@Vector(8, f32) = undefined;
    try Rng.fillVectorRangeCheckedFrom(&engine, @Vector(8, f32), &direct_checked_vec_range_buf, -1, 1);
    for (direct_checked_vec_range_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] >= -1 and vec[i] < 1);

    var direct_vec_range_buf: [4]@Vector(8, f32) = undefined;
    Rng.fillVectorRangeFrom(&engine, @Vector(8, f32), &direct_vec_range_buf, -1, 1);
    for (direct_vec_range_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] >= -1 and vec[i] < 1);

    var vec_f64_buf: [4]@Vector(4, f64) = undefined;
    rng.fill(@Vector(4, f64), &vec_f64_buf);
    for (vec_f64_buf) |vec| inline for (0..4) |i| try std.testing.expect(vec[i] >= 0 and vec[i] < 1);

    var vec_open_f64_buf: [4]@Vector(4, f64) = undefined;
    rng.fillVectorOpen(@Vector(4, f64), &vec_open_f64_buf);
    for (vec_open_f64_buf) |vec| inline for (0..4) |i| try std.testing.expect(vec[i] > 0 and vec[i] < 1);

    var direct_vec_open_f64_buf: [4]@Vector(4, f64) = undefined;
    Rng.fillVectorOpenFrom(&engine, @Vector(4, f64), &direct_vec_open_f64_buf);
    for (direct_vec_open_f64_buf) |vec| inline for (0..4) |i| try std.testing.expect(vec[i] > 0 and vec[i] < 1);

    var vec_open_closed_f64_buf: [4]@Vector(4, f64) = undefined;
    rng.fillVectorOpenClosed(@Vector(4, f64), &vec_open_closed_f64_buf);
    for (vec_open_closed_f64_buf) |vec| inline for (0..4) |i| try std.testing.expect(vec[i] > 0 and vec[i] <= 1);

    var direct_vec_open_closed_f64_buf: [4]@Vector(4, f64) = undefined;
    Rng.fillVectorOpenClosedFrom(&engine, @Vector(4, f64), &direct_vec_open_closed_f64_buf);
    for (direct_vec_open_closed_f64_buf) |vec| inline for (0..4) |i| try std.testing.expect(vec[i] > 0 and vec[i] <= 1);

    var vec_range_f64_buf: [4]@Vector(4, f64) = undefined;
    Rng.fillVectorRangeFrom(&engine, @Vector(4, f64), &vec_range_f64_buf, -1, 1);
    for (vec_range_f64_buf) |vec| inline for (0..4) |i| try std.testing.expect(vec[i] >= -1 and vec[i] < 1);

    var vec_chance_buf: [4]@Vector(8, bool) = undefined;
    try rng.fillVectorChanceChecked(@Vector(8, bool), &vec_chance_buf, 0);
    for (vec_chance_buf) |vec| inline for (0..8) |i| try std.testing.expect(!vec[i]);
    Rng.fillVectorChanceFrom(&engine, @Vector(8, bool), &vec_chance_buf, 1);
    for (vec_chance_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i]);

    try Rng.fillVectorChanceCheckedFrom(&engine, @Vector(8, bool), &vec_chance_buf, 0);
    for (vec_chance_buf) |vec| inline for (0..8) |i| try std.testing.expect(!vec[i]);

    var vec_ratio_buf: [4]@Vector(8, bool) = undefined;
    try rng.fillVectorRatioChecked(@Vector(8, bool), &vec_ratio_buf, 0, 1);
    for (vec_ratio_buf) |vec| inline for (0..8) |i| try std.testing.expect(!vec[i]);
    Rng.fillVectorRatioFrom(&engine, @Vector(8, bool), &vec_ratio_buf, 1, 1);
    for (vec_ratio_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i]);
    try Rng.fillVectorRatioCheckedFrom(&engine, @Vector(8, bool), &vec_ratio_buf, 0, 1);
    for (vec_ratio_buf) |vec| inline for (0..8) |i| try std.testing.expect(!vec[i]);
    try std.testing.expectError(error.InvalidProbability, rng.fillVectorRatioChecked(@Vector(8, bool), &vec_ratio_buf, 2, 1));

    var vec_standard_normal_buf: [4]@Vector(8, f32) = undefined;
    rng.fillVectorStandardNormal(@Vector(8, f32), &vec_standard_normal_buf);
    for (vec_standard_normal_buf) |vec| inline for (0..8) |i| try std.testing.expect(std.math.isFinite(vec[i]));

    var vec_normal_buf: [8]@Vector(8, f32) = undefined;
    try rng.fillVectorNormalChecked(@Vector(8, f32), &vec_normal_buf, 0, 1);
    for (vec_normal_buf) |vec| inline for (0..8) |i| try std.testing.expect(std.math.isFinite(vec[i]));

    var direct_vec_standard_normal_buf: [4]@Vector(8, f32) = undefined;
    Rng.fillVectorStandardNormalFrom(&engine, @Vector(8, f32), &direct_vec_standard_normal_buf);
    for (direct_vec_standard_normal_buf) |vec| inline for (0..8) |i| try std.testing.expect(std.math.isFinite(vec[i]));

    var direct_vec_normal_buf: [4]@Vector(8, f32) = undefined;
    Rng.fillVectorNormalFrom(&engine, @Vector(8, f32), &direct_vec_normal_buf, 0, 1);
    for (direct_vec_normal_buf) |vec| inline for (0..8) |i| try std.testing.expect(std.math.isFinite(vec[i]));

    var direct_checked_vec_normal_buf: [4]@Vector(8, f32) = undefined;
    try Rng.fillVectorNormalCheckedFrom(&engine, @Vector(8, f32), &direct_checked_vec_normal_buf, 0, 1);
    for (direct_checked_vec_normal_buf) |vec| inline for (0..8) |i| try std.testing.expect(std.math.isFinite(vec[i]));

    var vec_standard_exp_buf: [4]@Vector(8, f32) = undefined;
    rng.fillVectorStandardExponential(@Vector(8, f32), &vec_standard_exp_buf);
    for (vec_standard_exp_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] >= 0);

    var vec_exp_buf: [8]@Vector(8, f32) = undefined;
    try rng.fillVectorExponentialChecked(@Vector(8, f32), &vec_exp_buf, 2);
    for (vec_exp_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] >= 0);

    var direct_vec_standard_exp_buf: [4]@Vector(8, f32) = undefined;
    Rng.fillVectorStandardExponentialFrom(&engine, @Vector(8, f32), &direct_vec_standard_exp_buf);
    for (direct_vec_standard_exp_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] >= 0);

    var direct_vec_exp_buf: [4]@Vector(8, f32) = undefined;
    Rng.fillVectorExponentialFrom(&engine, @Vector(8, f32), &direct_vec_exp_buf, 2);
    for (direct_vec_exp_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] >= 0);

    var direct_checked_vec_exp_buf: [4]@Vector(8, f32) = undefined;
    try Rng.fillVectorExponentialCheckedFrom(&engine, @Vector(8, f32), &direct_checked_vec_exp_buf, 2);
    for (direct_checked_vec_exp_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] >= 0);

    const ranged_i = rng.vectorRange(@Vector(4, i32), -10, 10);
    inline for (0..4) |i| try std.testing.expect(ranged_i[i] >= -10 and ranged_i[i] < 10);

    const direct_ranged_i = Rng.vectorRangeFrom(&engine, @Vector(4, i32), -10, 10);
    inline for (0..4) |i| try std.testing.expect(direct_ranged_i[i] >= -10 and direct_ranged_i[i] < 10);

    const ranged_f = rng.vectorRange(@Vector(4, f64), -1, 2);
    inline for (0..4) |i| try std.testing.expect(ranged_f[i] >= -1 and ranged_f[i] < 2);

    const direct_checked_ranged_f = try Rng.vectorRangeCheckedFrom(&engine, @Vector(4, f64), -1, 2);
    inline for (0..4) |i| try std.testing.expect(direct_checked_ranged_f[i] >= -1 and direct_checked_ranged_f[i] < 2);

    const direct_checked_false_chance_vec = try Rng.vectorChanceCheckedFrom(&engine, @Vector(8, bool), 0);
    inline for (0..8) |i| try std.testing.expect(!direct_checked_false_chance_vec[i]);

    const direct_checked_false_ratio_vec = try Rng.vectorRatioCheckedFrom(&engine, @Vector(8, bool), 0, 1);
    inline for (0..8) |i| try std.testing.expect(!direct_checked_false_ratio_vec[i]);

    const normals = rng.vectorNormal(@Vector(4, f64), 0, 1);
    inline for (0..4) |i| try std.testing.expect(std.math.isFinite(normals[i]));

    const standard_normals = rng.vectorStandardNormal(@Vector(4, f64));
    inline for (0..4) |i| try std.testing.expect(std.math.isFinite(standard_normals[i]));

    const direct_standard_normals = Rng.vectorStandardNormalFrom(&engine, @Vector(4, f64));
    inline for (0..4) |i| try std.testing.expect(std.math.isFinite(direct_standard_normals[i]));

    const fast_normal = Rng.normalFastFrom(&engine, f64, 0, 1);
    try std.testing.expect(std.math.isFinite(fast_normal));
    const checked_normal = try rng.normalChecked(f64, 0, 1);
    try std.testing.expect(std.math.isFinite(checked_normal));
    const direct_checked_normal = try Rng.normalCheckedFrom(&engine, f64, 0, 1);
    try std.testing.expect(std.math.isFinite(direct_checked_normal));

    const TailSource = struct {
        index: usize = 0,

        fn next(self: *@This()) u64 {
            const values = [_]u64{
                0,
                0,
                @as(u64, 1) << 63,
            };
            const next_value = if (self.index < values.len) values[self.index] else @as(u64, 1) << 63;
            self.index += 1;
            return next_value;
        }
    };
    var tail_source = TailSource{};
    const tail_normal = Rng.standardNormalFastFrom(&tail_source, f64);
    try std.testing.expect(std.math.isFinite(tail_normal));

    const ExpTailSource = struct {
        index: usize = 0,

        fn next(self: *@This()) u64 {
            const values = [_]u64{
                ((@as(u64, 1) << 52) - 1) << 12,
                0,
            };
            const next_value = if (self.index < values.len) values[self.index] else @as(u64, 1) << 63;
            self.index += 1;
            return next_value;
        }
    };
    var exp_tail_source = ExpTailSource{};
    const tail_exponential = Rng.standardExponentialFastFrom(&exp_tail_source, f64);
    try std.testing.expect(std.math.isFinite(tail_exponential));

    const vector_normals_f32 = rng.vectorNormal(@Vector(8, f32), 0, 1);
    inline for (0..8) |i| try std.testing.expect(std.math.isFinite(vector_normals_f32[i]));

    const checked_vector_normals_f32 = try rng.vectorNormalChecked(@Vector(8, f32), 0, 1);
    inline for (0..8) |i| try std.testing.expect(std.math.isFinite(checked_vector_normals_f32[i]));

    const direct_checked_vector_normals_f32 = try Rng.vectorNormalCheckedFrom(&engine, @Vector(8, f32), 0, 1);
    inline for (0..8) |i| try std.testing.expect(std.math.isFinite(direct_checked_vector_normals_f32[i]));

    const vector_standard_normals_f32 = rng.vectorStandardNormal(@Vector(8, f32));
    inline for (0..8) |i| try std.testing.expect(std.math.isFinite(vector_standard_normals_f32[i]));

    const exponentials = rng.vectorExponential(@Vector(4, f64), 2);
    inline for (0..4) |i| try std.testing.expect(exponentials[i] >= 0);

    const checked_exponential = try rng.exponentialChecked(f64, 2);
    try std.testing.expect(checked_exponential >= 0);
    const direct_checked_exponential = try Rng.exponentialCheckedFrom(&engine, f64, 2);
    try std.testing.expect(direct_checked_exponential >= 0);

    const checked_exponentials = try rng.vectorExponentialChecked(@Vector(4, f64), 2);
    inline for (0..4) |i| try std.testing.expect(checked_exponentials[i] >= 0);

    const direct_checked_exponentials = try Rng.vectorExponentialCheckedFrom(&engine, @Vector(4, f64), 2);
    inline for (0..4) |i| try std.testing.expect(direct_checked_exponentials[i] >= 0);

    const standard_exponentials = rng.vectorStandardExponential(@Vector(4, f64));
    inline for (0..4) |i| try std.testing.expect(standard_exponentials[i] >= 0);

    const direct_standard_exponentials = Rng.vectorStandardExponentialFrom(&engine, @Vector(4, f64));
    inline for (0..4) |i| try std.testing.expect(direct_standard_exponentials[i] >= 0);

    const vector_exp_f32 = rng.vectorExponential(@Vector(8, f32), 2);
    inline for (0..8) |i| try std.testing.expect(vector_exp_f32[i] >= 0);

    const vector_standard_exp_f32 = rng.vectorStandardExponential(@Vector(8, f32));
    inline for (0..8) |i| try std.testing.expect(vector_standard_exp_f32[i] >= 0);

    try std.testing.expectError(error.EmptyRange, rng.vectorRangeChecked(@Vector(4, u32), 3, 3));
    try std.testing.expectError(error.EmptyRange, rng.vectorRangeChecked(@Vector(4, f64), std.math.inf(f64), 1));
    try std.testing.expectError(error.EmptyRange, Rng.vectorRangeCheckedFrom(&engine, @Vector(4, f64), std.math.inf(f64), 1));
    try std.testing.expectError(error.InvalidProbability, Rng.vectorChanceCheckedFrom(&engine, @Vector(8, bool), -0.1));
    try std.testing.expectError(error.InvalidProbability, Rng.vectorRatioCheckedFrom(&engine, @Vector(8, bool), 2, 1));
    try std.testing.expectError(error.EmptyRange, rng.fillVectorRangeChecked(@Vector(8, f32), &vec_range_buf, 2, 1));
    try std.testing.expectError(error.EmptyRange, Rng.fillVectorRangeCheckedFrom(&engine, @Vector(8, f32), &vec_range_buf, 2, 1));
    try std.testing.expectError(error.InvalidProbability, Rng.fillVectorChanceCheckedFrom(&engine, @Vector(8, bool), &vec_chance_buf, -0.1));
    try std.testing.expectError(error.InvalidProbability, Rng.fillVectorRatioCheckedFrom(&engine, @Vector(8, bool), &vec_ratio_buf, 2, 1));
    try std.testing.expectError(error.InvalidParameter, rng.fillVectorNormalChecked(@Vector(8, f32), &vec_normal_buf, 0, -1));
    try std.testing.expectError(error.InvalidParameter, rng.fillVectorExponentialChecked(@Vector(8, f32), &vec_exp_buf, 0));
    try std.testing.expectError(error.InvalidParameter, Rng.fillVectorNormalCheckedFrom(&engine, @Vector(8, f32), &vec_normal_buf, 0, -1));
    try std.testing.expectError(error.InvalidParameter, Rng.fillVectorExponentialCheckedFrom(&engine, @Vector(8, f32), &vec_exp_buf, 0));
    try std.testing.expectError(error.InvalidParameter, rng.vectorNormalChecked(@Vector(4, f64), 0, -1));
    try std.testing.expectError(error.InvalidParameter, rng.vectorNormalChecked(@Vector(4, f64), std.math.inf(f64), 1));
    try std.testing.expectError(error.InvalidParameter, rng.vectorExponentialChecked(@Vector(4, f64), 0));
    try std.testing.expectError(error.InvalidParameter, rng.vectorExponentialChecked(@Vector(4, f64), std.math.inf(f64)));
    try std.testing.expectError(error.InvalidParameter, Rng.vectorNormalCheckedFrom(&engine, @Vector(4, f64), 0, -1));
    try std.testing.expectError(error.InvalidParameter, Rng.vectorExponentialCheckedFrom(&engine, @Vector(4, f64), 0));
    try std.testing.expectError(error.EmptyRange, rng.fillRangeChecked(u32, &.{}, 3, 3));
    try std.testing.expectError(error.EmptyRange, Rng.fillRangeCheckedFrom(&engine, u32, &.{}, 3, 3));
    try std.testing.expectError(error.InvalidProbability, Rng.fillChanceCheckedFrom(&engine, &.{}, -0.1));
    try std.testing.expectError(error.InvalidProbability, Rng.fillRatioCheckedFrom(&engine, &.{}, 2, 1));
    try std.testing.expectError(error.InvalidParameter, rng.fillNormalChecked(f64, &normal_buf, 0, -1));
    try std.testing.expectError(error.InvalidParameter, rng.fillExponentialChecked(f64, &exp_buf, 0));
    try std.testing.expectError(error.InvalidParameter, Rng.fillNormalCheckedFrom(&engine, f64, &normal_buf, 0, -1));
    try std.testing.expectError(error.InvalidParameter, Rng.fillExponentialCheckedFrom(&engine, f64, &exp_buf, 0));
    try std.testing.expectError(error.InvalidParameter, rng.normalChecked(f64, 0, -1));
    try std.testing.expectError(error.InvalidParameter, Rng.normalCheckedFrom(&engine, f64, std.math.inf(f64), 1));
    try std.testing.expectError(error.InvalidParameter, rng.exponentialChecked(f64, 0));
    try std.testing.expectError(error.InvalidParameter, Rng.exponentialCheckedFrom(&engine, f64, std.math.inf(f64)));
}

test "scalar sampling has stable snapshots" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x1234_5678_9abc_def0);
    const rng = Rng.init(&engine);

    try std.testing.expectEqual(false, rng.boolean());
    try std.testing.expectEqual(@as(u32, 0xa3125278), rng.uint(u32));
    try std.testing.expectEqual(@as(u32, 933), rng.uintLessThan(u32, 1000));
    try std.testing.expectEqual(@as(u32, 304), rng.uintAtMost(u32, 1000));
    try std.testing.expectEqual(@as(i32, 31), rng.intRangeLessThan(i32, -50, 50));
    try std.testing.expectEqual(@as(i32, -27), rng.intRangeAtMost(i32, -50, 50));
    try std.testing.expectEqual(@as(f64, 0.60790881637282410), rng.float(f64));
    try std.testing.expectEqual(@as(f64, 0.87537592843999900), rng.floatOpen(f64));
    try std.testing.expectEqual(@as(f64, 0.22843551191053635), rng.floatOpenClosed(f64));
    try std.testing.expectEqual(@as(f64, 0.96357471251905120), rng.floatRange(f64, -1, 1));
    try std.testing.expectEqual(false, rng.chance(0.25));
    try std.testing.expectEqual(true, rng.ratio(3, 8));
    try std.testing.expectEqual(@as(u64, 0x43178923ee65cac3), engine.next());
}

test "byte fill has stable snapshots" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x1234_5678_9abc_def0);
    const rng = Rng.init(&engine);

    var bytes_buf: [16]u8 = undefined;
    rng.bytes(&bytes_buf);
    try std.testing.expectEqualSlices(u8, &.{
        0x5b, 0xbd, 0x36, 0xab, 0x9c, 0xea, 0xe3, 0x23,
        0x78, 0x52, 0x12, 0xa3, 0x3c, 0xa3, 0x9d, 0x63,
    }, &bytes_buf);

    var fill_buf: [16]u8 = undefined;
    rng.fill(u8, &fill_buf);
    try std.testing.expectEqualSlices(u8, &.{
        0xd8, 0x32, 0xda, 0xee, 0x77, 0x79, 0x30, 0x88,
        0xd9, 0xdd, 0xc7, 0x4d, 0xb2, 0x3a, 0xa6, 0xd1,
    }, &fill_buf);
    try std.testing.expectEqual(@as(u64, 0x931a772dd193d170), engine.next());
}

test "open-closed f64 fill preserves facade stream shape" {
    const alea = @import("root.zig");
    var facade_engine = alea.FastPrng.init(0xf642);
    var direct_engine = alea.FastPrng.init(0xf642);
    const rng = Rng.init(&facade_engine);

    var facade_values: [200]f64 = undefined;
    var direct_values: [200]f64 = undefined;
    rng.fillOpenClosed(f64, &facade_values);
    fillOpenClosedFrom(&direct_engine, f64, &direct_values);
    try std.testing.expectEqualSlices(f64, &facade_values, &direct_values);
    try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
}

test "value and vector sampling have stable snapshots" {
    const alea = @import("root.zig");
    const ValueType = struct { u8, bool, f32 };
    var engine = alea.ScalarPrng.init(0x1234_5678_9abc_def0);
    const rng = Rng.init(&engine);

    const tuple = rng.value(ValueType);
    try std.testing.expectEqual(@as(u8, 91), tuple[0]);
    try std.testing.expectEqual(false, tuple[1]);
    try std.testing.expectEqual(@as(f32, 0.531989630), tuple[2]);

    try std.testing.expectEqual(@Vector(4, u16){ 56793, 19911, 15026, 53670 }, rng.vector(@Vector(4, u16)));
    try std.testing.expectEqual(@Vector(4, f32){ 0.5746226, 0.1789791, 0.014100373, 0.23528028 }, rng.vector(@Vector(4, f32)));
    try std.testing.expectEqual(@Vector(4, f32){ 0.6079088, 0.5205912, 0.8753759, 0.03263837 }, rng.vectorOpen(@Vector(4, f32)));
    try std.testing.expectEqual(@Vector(4, f32){ 0.22843552, 0.92539364, 0.9817874, 0.54203504 }, rng.vectorOpenClosed(@Vector(4, f32)));
    try std.testing.expectEqual(@Vector(4, i32){ -8, -9, 8, -10 }, rng.vectorRange(@Vector(4, i32), -10, 10));
    try std.testing.expectEqual(@Vector(4, f32){ 1.8454661, -0.5662591, 0.5891118, 0.549078 }, rng.vectorRange(@Vector(4, f32), -1, 2));
    try std.testing.expectEqual(@Vector(8, bool){ false, false, false, false, false, false, false, false }, rng.vectorChance(@Vector(8, bool), 0.25));
    try std.testing.expectEqual(@Vector(8, bool){ true, false, false, false, false, false, false, false }, rng.vectorRatio(@Vector(8, bool), 3, 8));
    try std.testing.expectEqual(@as(u64, 0x931f893ca11f58de), engine.next());
}

test "duration range sampling has stable snapshots" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x1234_5678_9abc_def0);
    const rng = Rng.init(&engine);
    const min = std.Io.Duration.fromMilliseconds(10);
    const max = std.Io.Duration.fromMilliseconds(20);

    try std.testing.expectEqual(@as(i96, 16_369_983), rng.durationRangeLessThan(min, max).nanoseconds);
    try std.testing.expectEqual(@as(i96, 13_038_310), rng.durationRangeAtMost(min, max).nanoseconds);
    try std.testing.expectEqual(@as(i96, 12_317_639), (try rng.durationRangeLessThanChecked(min, max)).nanoseconds);
    try std.testing.expectEqual(@as(i96, 13_554_320), (try rng.durationRangeAtMostChecked(min, max)).nanoseconds);
    try std.testing.expectEqual(@as(u64, 0x3a7abfece698fa60), engine.next());
}

test "shuffle and sampling keep item set" {
    const Wyhash64 = @import("engines/wyhash64.zig");
    var engine = Wyhash64.init(9);
    const rng = Rng.init(&engine);
    const SmallEnum = enum { a, b, c };
    const EmptyEnum = enum {};
    var values = [_]u8{ 1, 2, 3, 4, 5 };
    rng.shuffle(u8, &values);

    var sum: u32 = 0;
    for (values) |item| sum += item;
    try std.testing.expectEqual(@as(u32, 15), sum);

    var direct_values = [_]u8{ 1, 2, 3, 4, 5 };
    Rng.shuffleFrom(&engine, u8, &direct_values);
    var direct_sum: u32 = 0;
    for (direct_values) |item| direct_sum += item;
    try std.testing.expectEqual(@as(u32, 15), direct_sum);

    const chosen = Rng.chooseFrom(&engine, u8, &values).?;
    try std.testing.expect(chosen >= 1 and chosen <= 5);
    const checked_chosen = try Rng.chooseCheckedFrom(&engine, u8, &values);
    try std.testing.expect(checked_chosen >= 1 and checked_chosen <= 5);

    const chosen_ptr = Rng.choosePtrFrom(&engine, u8, &values).?;
    try std.testing.expect(chosen_ptr.* >= 1 and chosen_ptr.* <= 5);
    const checked_chosen_ptr = try Rng.choosePtrCheckedFrom(&engine, u8, &values);
    try std.testing.expect(checked_chosen_ptr.* >= 1 and checked_chosen_ptr.* <= 5);

    const enum_value = try Rng.enumValueCheckedFrom(&engine, SmallEnum);
    try std.testing.expect(enum_value == .a or enum_value == .b or enum_value == .c);
    if (Rng.enumValueCheckedFrom(&engine, EmptyEnum)) |_| {
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }

    const weighted = Rng.weightedIndexFrom(&engine, &.{ 0.0, 1.0, 3.0 }).?;
    try std.testing.expect(weighted == 1 or weighted == 2);

    const sample = try rng.sampleWithoutReplacement(u8, std.testing.allocator, &values, 3);
    defer std.testing.allocator.free(sample);
    try std.testing.expectEqual(@as(usize, 3), sample.len);

    const direct_sample = try Rng.sampleWithoutReplacementFrom(&engine, u8, std.testing.allocator, &values, 3);
    defer std.testing.allocator.free(direct_sample);
    try std.testing.expectEqual(@as(usize, 3), direct_sample.len);

    try std.testing.expectError(error.InvalidParameter, rng.sampleWithoutReplacementChecked(u8, std.testing.allocator, &values, 99));
    try std.testing.expectError(error.InvalidParameter, Rng.sampleWithoutReplacementCheckedFrom(&engine, u8, std.testing.allocator, &values, 99));
    try std.testing.expectError(error.InvalidWeight, rng.weightedIndexChecked(&.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectError(error.InvalidWeight, Rng.weightedIndexCheckedFrom(&engine, &.{ 1.0, std.math.nan(f64) }));
}

test "checked fill helpers preserve valid-parameter stream shape" {
    const alea = @import("root.zig");

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var unchecked = Engine.init(0x5eed_5150);
        var checked = Engine.init(0x5eed_5150);

        var range_unchecked: [8]u32 = undefined;
        var range_checked: [8]u32 = undefined;
        fillRangeFrom(&unchecked, u32, &range_unchecked, 5, 9);
        try fillRangeCheckedFrom(&checked, u32, &range_checked, 5, 9);
        try std.testing.expectEqualSlices(u32, &range_unchecked, &range_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var chance_unchecked: [16]bool = undefined;
        var chance_checked: [16]bool = undefined;
        fillChanceFrom(&unchecked, &chance_unchecked, 0.25);
        try fillChanceCheckedFrom(&checked, &chance_checked, 0.25);
        try std.testing.expectEqualSlices(bool, &chance_unchecked, &chance_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var ratio_unchecked: [16]bool = undefined;
        var ratio_checked: [16]bool = undefined;
        fillRatioFrom(&unchecked, &ratio_unchecked, 3, 8);
        try fillRatioCheckedFrom(&checked, &ratio_checked, 3, 8);
        try std.testing.expectEqualSlices(bool, &ratio_unchecked, &ratio_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var normal_unchecked: [8]f64 = undefined;
        var normal_checked: [8]f64 = undefined;
        fillNormalFrom(&unchecked, f64, &normal_unchecked, 0, 1);
        try fillNormalCheckedFrom(&checked, f64, &normal_checked, 0, 1);
        try std.testing.expectEqualSlices(f64, &normal_unchecked, &normal_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var exponential_unchecked: [8]f64 = undefined;
        var exponential_checked: [8]f64 = undefined;
        fillExponentialFrom(&unchecked, f64, &exponential_unchecked, 2);
        try fillExponentialCheckedFrom(&checked, f64, &exponential_checked, 2);
        try std.testing.expectEqualSlices(f64, &exponential_unchecked, &exponential_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_range_unchecked: [4]@Vector(8, f32) = undefined;
        var vector_range_checked: [4]@Vector(8, f32) = undefined;
        fillVectorRangeFrom(&unchecked, @Vector(8, f32), &vector_range_unchecked, -1, 1);
        try fillVectorRangeCheckedFrom(&checked, @Vector(8, f32), &vector_range_checked, -1, 1);
        try std.testing.expectEqualSlices(@Vector(8, f32), &vector_range_unchecked, &vector_range_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_chance_unchecked: [4]@Vector(8, bool) = undefined;
        var vector_chance_checked: [4]@Vector(8, bool) = undefined;
        fillVectorChanceFrom(&unchecked, @Vector(8, bool), &vector_chance_unchecked, 0.25);
        try fillVectorChanceCheckedFrom(&checked, @Vector(8, bool), &vector_chance_checked, 0.25);
        try std.testing.expectEqualSlices(@Vector(8, bool), &vector_chance_unchecked, &vector_chance_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_ratio_unchecked: [4]@Vector(8, bool) = undefined;
        var vector_ratio_checked: [4]@Vector(8, bool) = undefined;
        fillVectorRatioFrom(&unchecked, @Vector(8, bool), &vector_ratio_unchecked, 3, 8);
        try fillVectorRatioCheckedFrom(&checked, @Vector(8, bool), &vector_ratio_checked, 3, 8);
        try std.testing.expectEqualSlices(@Vector(8, bool), &vector_ratio_unchecked, &vector_ratio_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_normal_unchecked: [4]@Vector(8, f32) = undefined;
        var vector_normal_checked: [4]@Vector(8, f32) = undefined;
        fillVectorNormalFrom(&unchecked, @Vector(8, f32), &vector_normal_unchecked, 0, 1);
        try fillVectorNormalCheckedFrom(&checked, @Vector(8, f32), &vector_normal_checked, 0, 1);
        try std.testing.expectEqualSlices(@Vector(8, f32), &vector_normal_unchecked, &vector_normal_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_exponential_unchecked: [4]@Vector(8, f32) = undefined;
        var vector_exponential_checked: [4]@Vector(8, f32) = undefined;
        fillVectorExponentialFrom(&unchecked, @Vector(8, f32), &vector_exponential_unchecked, 2);
        try fillVectorExponentialCheckedFrom(&checked, @Vector(8, f32), &vector_exponential_checked, 2);
        try std.testing.expectEqualSlices(@Vector(8, f32), &vector_exponential_unchecked, &vector_exponential_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());
    }
}

test "checked weighted sampling preserves valid-parameter stream shape" {
    const alea = @import("root.zig");
    const weights = [_]f64{ 1, 2, 3, 4 };
    const items = [_]u8{ 10, 20, 30, 40 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var unchecked = Engine.init(0x5150_4477);
        var checked = Engine.init(0x5150_4477);

        const weighted = weightedIndexFrom(&unchecked, &weights);
        const checked_weighted = try weightedIndexCheckedFrom(&checked, &weights);
        try std.testing.expectEqual(weighted, checked_weighted);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const sample = try sampleWithoutReplacementFrom(&unchecked, u8, std.testing.allocator, &items, 3);
        defer std.testing.allocator.free(sample);
        const checked_sample = try sampleWithoutReplacementCheckedFrom(&checked, u8, std.testing.allocator, &items, 3);
        defer std.testing.allocator.free(checked_sample);
        try std.testing.expectEqualSlices(u8, sample, checked_sample);
        try std.testing.expectEqual(unchecked.next(), checked.next());
    }
}

test "invalid checked helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_bad);

    try std.testing.expectError(error.InvalidProbability, chanceCheckedFrom(&engine, -0.1));
    try std.testing.expectEqual(@as(u64, 0x9ccf0caa836c3975), engine.next());

    try std.testing.expectError(error.InvalidProbability, ratioCheckedFrom(&engine, 2, 1));
    try std.testing.expectEqual(@as(u64, 0x6a422e0bc228f676), engine.next());

    try std.testing.expectError(error.EmptyRange, uintLessThanCheckedFrom(&engine, u32, 0));
    try std.testing.expectEqual(@as(u64, 0x16f941763a3b5c32), engine.next());

    try std.testing.expectError(error.EmptyRange, intRangeLessThanCheckedFrom(&engine, u32, 3, 3));
    try std.testing.expectEqual(@as(u64, 0xba4d054547a7f857), engine.next());

    try std.testing.expectError(error.EmptyRange, floatRangeCheckedFrom(&engine, f64, std.math.inf(f64), 1));
    try std.testing.expectEqual(@as(u64, 0x52050e6daf1ffc3d), engine.next());

    try std.testing.expectError(error.EmptyRange, durationRangeLessThanCheckedFrom(&engine, .fromSeconds(2), .fromSeconds(1)));
    try std.testing.expectEqual(@as(u64, 0x1d69e48242c57737), engine.next());

    try std.testing.expectError(error.InvalidParameter, normalCheckedFrom(&engine, f64, std.math.inf(f64), 1));
    try std.testing.expectEqual(@as(u64, 0x9900c6c9195b42f9), engine.next());

    var f64_buf: [4]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillNormalCheckedFrom(&engine, f64, &f64_buf, 0, -1));
    try std.testing.expectEqual(@as(u64, 0x32ac91fd8b7e3970), engine.next());

    var bool_buf: [8]bool = undefined;
    try std.testing.expectError(error.InvalidProbability, fillRatioCheckedFrom(&engine, &bool_buf, 2, 1));
    try std.testing.expectEqual(@as(u64, 0x8a9c3d610f339467), engine.next());

    try std.testing.expectError(error.EmptyRange, vectorRangeCheckedFrom(&engine, @Vector(4, f64), std.math.inf(f64), 1));
    try std.testing.expectEqual(@as(u64, 0xfedbe66623c1adc2), engine.next());

    var vec_buf: [2]@Vector(4, f64) = undefined;
    try std.testing.expectError(error.EmptyRange, fillVectorRangeCheckedFrom(&engine, @Vector(4, f64), &vec_buf, std.math.inf(f64), 1));
    try std.testing.expectEqual(@as(u64, 0xa360fbcd83acd8d7), engine.next());

    try std.testing.expectError(error.EmptyRange, chooseCheckedFrom(&engine, u8, &.{}));
    try std.testing.expectEqual(@as(u64, 0x8a685176c49005b1), engine.next());

    var empty_items: [0]u8 = .{};
    try std.testing.expectError(error.EmptyRange, choosePtrCheckedFrom(&engine, u8, &empty_items));
    try std.testing.expectEqual(@as(u64, 0xf6aed2fe799c54ee), engine.next());

    try std.testing.expectError(error.InvalidWeight, weightedIndexCheckedFrom(&engine, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectEqual(@as(u64, 0xd3ab62c69321f758), engine.next());

    try std.testing.expectError(error.InvalidWeight, weightedIndexCheckedFrom(&engine, &.{ std.math.floatMax(f64), std.math.floatMax(f64) }));
    try std.testing.expectEqual(@as(u64, 0x1832e3ae643b1913), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleWithoutReplacementCheckedFrom(&engine, u8, std.testing.allocator, &.{ 1, 2 }, 3));
    try std.testing.expectEqual(@as(u64, 0x1e449ba06e4ee306), engine.next());
}

test "collection helpers preserve direct stream shape" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c011);
        var direct_engine = Engine.init(0x5150_c011);
        const rng = Rng.init(&facade_engine);

        try std.testing.expectEqual(rng.choose(u8, &items), Rng.chooseFrom(&direct_engine, u8, &items));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        try std.testing.expectEqual(try rng.chooseChecked(u8, &items), try Rng.chooseCheckedFrom(&direct_engine, u8, &items));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const Enum = enum { a, b, c };
        try std.testing.expectEqual(try rng.enumValueChecked(Enum), try Rng.enumValueCheckedFrom(&direct_engine, Enum));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_items = items;
        var direct_items = items;
        const facade_ptr = rng.choosePtr(u8, &facade_items).?;
        const direct_ptr = Rng.choosePtrFrom(&direct_engine, u8, &direct_items).?;
        try std.testing.expectEqual(facade_ptr.*, direct_ptr.*);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        const checked_facade_ptr = try rng.choosePtrChecked(u8, &facade_items);
        const checked_direct_ptr = try Rng.choosePtrCheckedFrom(&direct_engine, u8, &direct_items);
        try std.testing.expectEqual(checked_facade_ptr.*, checked_direct_ptr.*);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_shuffle = items;
        var direct_shuffle = items;
        rng.shuffle(u8, &facade_shuffle);
        Rng.shuffleFrom(&direct_engine, u8, &direct_shuffle);
        try std.testing.expectEqualSlices(u8, &facade_shuffle, &direct_shuffle);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
}

test "value and iterator helpers preserve direct stream shape" {
    const alea = @import("root.zig");
    const ValueType = struct { u8, bool, f32 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_0a1e);
        var direct_engine = Engine.init(0x5150_0a1e);
        const rng = Rng.init(&facade_engine);

        try std.testing.expectEqual(rng.value(ValueType), valueFrom(&direct_engine, ValueType));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_bytes: [16]u8 = undefined;
        var direct_bytes: [16]u8 = undefined;
        rng.fill(u8, &facade_bytes);
        fillFrom(&direct_engine, u8, &direct_bytes);
        try std.testing.expectEqualSlices(u8, &facade_bytes, &direct_bytes);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_vectors: [4]@Vector(4, u16) = undefined;
        var direct_vectors: [4]@Vector(4, u16) = undefined;
        rng.fill(@Vector(4, u16), &facade_vectors);
        fillFrom(&direct_engine, @Vector(4, u16), &direct_vectors);
        try std.testing.expectEqualSlices(@Vector(4, u16), &facade_vectors, &direct_vectors);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var value_iter = rng.valueIter(ValueType);
        var direct_value_iter = valueIterFrom(&direct_engine, ValueType);
        try std.testing.expectEqual(value_iter.nextValue(), direct_value_iter.nextValue());
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var random_iter = rng.randomIter(u16);
        var direct_random_iter = randomIterFrom(&direct_engine, u16);
        var random_buf: [8]u16 = undefined;
        var direct_random_buf: [8]u16 = undefined;
        random_iter.fill(&random_buf);
        direct_random_iter.fill(&direct_random_buf);
        try std.testing.expectEqualSlices(u16, &random_buf, &direct_random_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const die = try alea.distributions.Uniform(u8).initInclusive(1, 6);
        var sample_iter = rng.sampleIter(u8, die);
        var direct_sample_iter = sampleIterFrom(&direct_engine, u8, die);
        var sample_buf: [8]u8 = undefined;
        var direct_sample_buf: [8]u8 = undefined;
        sample_iter.fill(&sample_buf);
        direct_sample_iter.fill(&direct_sample_buf);
        try std.testing.expectEqualSlices(u8, &sample_buf, &direct_sample_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
}

test "value and sampler iterators produce unbounded samples" {
    const alea = @import("root.zig");
    var engine = alea.Xoshiro256.init(123);
    const rng = Rng.init(&engine);

    var values = rng.valueIter(u16);
    const first = values.next().?;
    const second = values.nextValue();
    try std.testing.expect(first != second);

    var direct_values = Rng.valueIterFrom(&engine, u16);
    const direct_first = direct_values.next().?;
    const direct_second = direct_values.nextValue();
    try std.testing.expect(direct_first != direct_second);

    var bool_iter = rng.randomIter(bool);
    var bools: [8]bool = undefined;
    bool_iter.fill(&bools);

    var direct_bool_iter = Rng.valueIterFrom(&engine, bool);
    var direct_bools: [8]bool = undefined;
    direct_bool_iter.fill(&direct_bools);

    var direct_random_iter = Rng.randomIterFrom(&engine, bool);
    var direct_random_bools: [8]bool = undefined;
    direct_random_iter.fill(&direct_random_bools);

    var tuple_iter = rng.valueIter(struct { u8, bool, f32 });
    const tuple = tuple_iter.nextValue();
    try std.testing.expect(tuple[2] >= 0 and tuple[2] < 1);

    var direct_tuple_iter = Rng.valueIterFrom(&engine, struct { u8, bool, f32 });
    const direct_tuple = direct_tuple_iter.nextValue();
    try std.testing.expect(direct_tuple[2] >= 0 and direct_tuple[2] < 1);

    const die = try alea.distributions.Uniform(u8).initInclusive(1, 6);
    var rolls = rng.sampleIter(u8, die);
    var i: usize = 0;
    while (i < 16) : (i += 1) {
        const roll = rolls.next().?;
        try std.testing.expect(roll >= 1 and roll <= 6);
    }

    var direct_rolls = Rng.sampleIterFrom(&engine, u8, die);
    var direct_roll_buf: [16]u8 = undefined;
    direct_rolls.fill(&direct_roll_buf);
    for (direct_roll_buf) |roll| try std.testing.expect(roll >= 1 and roll <= 6);

    var open_iter = rng.sampleIter(f64, alea.distributions.Open01{});
    const open_value = open_iter.nextValue();
    try std.testing.expect(open_value > 0 and open_value < 1);

    var direct_open_iter = Rng.sampleIterFrom(&engine, f64, alea.distributions.Open01{});
    const direct_open_value = direct_open_iter.nextValue();
    try std.testing.expect(direct_open_value > 0 and direct_open_value < 1);

    var open_fill_iter = rng.sampleIter(f64, alea.distributions.Open01{});
    var open_fill_buf: [8]f64 = undefined;
    open_fill_iter.fill(&open_fill_buf);
    for (open_fill_buf) |item| try std.testing.expect(item > 0 and item < 1);

    var direct_open_closed_fill_iter = Rng.sampleIterFrom(&engine, f64, alea.distributions.OpenClosed01{});
    var direct_open_closed_fill_buf: [8]f64 = undefined;
    direct_open_closed_fill_iter.fill(&direct_open_closed_fill_buf);
    for (direct_open_closed_fill_buf) |item| try std.testing.expect(item > 0 and item <= 1);
}

test "sample iterator fill delegates to sampler bulk fill policy" {
    const alea = @import("root.zig");

    var open_iter_engine = alea.ScalarPrng.init(0x5a1e);
    const open_rng = Rng.init(&open_iter_engine);
    var open_direct_engine = alea.ScalarPrng.init(0x5a1e);
    const open_dist = alea.distributions.Open01{};
    var open_iter = open_rng.sampleIter(f64, open_dist);
    var open_iter_fill: [8]f64 = undefined;
    var open_direct_fill: [8]f64 = undefined;
    open_iter.fill(&open_iter_fill);
    open_dist.fillFrom(&open_direct_engine, f64, &open_direct_fill);
    try std.testing.expectEqualSlices(f64, &open_direct_fill, &open_iter_fill);
    try std.testing.expectEqual(open_direct_engine.next(), open_iter_engine.next());

    var open_closed_iter_engine = alea.ScalarPrng.init(0x5a1e);
    var open_closed_direct_engine = alea.ScalarPrng.init(0x5a1e);
    const open_closed_dist = alea.distributions.OpenClosed01{};
    var open_closed_iter = sampleIterFrom(&open_closed_iter_engine, f64, open_closed_dist);
    var open_closed_iter_fill: [8]f64 = undefined;
    var open_closed_direct_fill: [8]f64 = undefined;
    open_closed_iter.fill(&open_closed_iter_fill);
    open_closed_dist.fillFrom(&open_closed_direct_engine, f64, &open_closed_direct_fill);
    try std.testing.expectEqualSlices(f64, &open_closed_direct_fill, &open_closed_iter_fill);
    try std.testing.expectEqual(open_closed_direct_engine.next(), open_closed_iter_engine.next());
}

test "value iterator fill preserves scalar fallback where bulk fill packs draws" {
    const alea = @import("root.zig");

    var bool_iter_engine = alea.ScalarPrng.init(0x17e8);
    const bool_rng = Rng.init(&bool_iter_engine);
    var bool_loop_engine = alea.ScalarPrng.init(0x17e8);
    const bool_loop_rng = Rng.init(&bool_loop_engine);
    var bool_iter = bool_rng.valueIter(bool);
    var bool_fill: [8]bool = undefined;
    var bool_loop: [8]bool = undefined;
    bool_iter.fill(&bool_fill);
    var i: usize = 0;
    while (i < bool_loop.len) : (i += 1) bool_loop[i] = bool_loop_rng.value(bool);
    try std.testing.expectEqualSlices(bool, &bool_loop, &bool_fill);
    try std.testing.expectEqual(bool_loop_engine.next(), bool_iter_engine.next());

    var direct_bool_iter_engine = alea.ScalarPrng.init(0x17e8);
    var direct_bool_loop_engine = alea.ScalarPrng.init(0x17e8);
    var direct_bool_iter = valueIterFrom(&direct_bool_iter_engine, bool);
    var direct_bool_fill: [8]bool = undefined;
    var direct_bool_loop: [8]bool = undefined;
    direct_bool_iter.fill(&direct_bool_fill);
    i = 0;
    while (i < direct_bool_loop.len) : (i += 1) direct_bool_loop[i] = valueFrom(&direct_bool_loop_engine, bool);
    try std.testing.expectEqualSlices(bool, &direct_bool_loop, &direct_bool_fill);
    try std.testing.expectEqual(direct_bool_loop_engine.next(), direct_bool_iter_engine.next());

    var f32_iter_engine = alea.ScalarPrng.init(0x17e8);
    const f32_rng = Rng.init(&f32_iter_engine);
    var f32_loop_engine = alea.ScalarPrng.init(0x17e8);
    const f32_loop_rng = Rng.init(&f32_loop_engine);
    var f32_iter = f32_rng.valueIter(f32);
    var f32_fill: [8]f32 = undefined;
    var f32_loop: [8]f32 = undefined;
    f32_iter.fill(&f32_fill);
    i = 0;
    while (i < f32_loop.len) : (i += 1) f32_loop[i] = f32_loop_rng.value(f32);
    try std.testing.expectEqualSlices(f32, &f32_loop, &f32_fill);
    try std.testing.expectEqual(f32_loop_engine.next(), f32_iter_engine.next());

    var direct_f32_iter_engine = alea.ScalarPrng.init(0x17e8);
    var direct_f32_loop_engine = alea.ScalarPrng.init(0x17e8);
    var direct_f32_iter = valueIterFrom(&direct_f32_iter_engine, f32);
    var direct_f32_fill: [8]f32 = undefined;
    var direct_f32_loop: [8]f32 = undefined;
    direct_f32_iter.fill(&direct_f32_fill);
    i = 0;
    while (i < direct_f32_loop.len) : (i += 1) direct_f32_loop[i] = valueFrom(&direct_f32_loop_engine, f32);
    try std.testing.expectEqualSlices(f32, &direct_f32_loop, &direct_f32_fill);
    try std.testing.expectEqual(direct_f32_loop_engine.next(), direct_f32_iter_engine.next());

    var u32_iter_engine = alea.ScalarPrng.init(0x17e8);
    const u32_rng = Rng.init(&u32_iter_engine);
    var u32_loop_engine = alea.ScalarPrng.init(0x17e8);
    const u32_loop_rng = Rng.init(&u32_loop_engine);
    var u32_iter = u32_rng.valueIter(u32);
    var u32_fill: [8]u32 = undefined;
    var u32_loop: [8]u32 = undefined;
    u32_iter.fill(&u32_fill);
    i = 0;
    while (i < u32_loop.len) : (i += 1) u32_loop[i] = u32_loop_rng.value(u32);
    try std.testing.expectEqualSlices(u32, &u32_loop, &u32_fill);
    try std.testing.expectEqual(u32_loop_engine.next(), u32_iter_engine.next());

    var direct_u32_iter_engine = alea.ScalarPrng.init(0x17e8);
    var direct_u32_loop_engine = alea.ScalarPrng.init(0x17e8);
    var direct_u32_iter = valueIterFrom(&direct_u32_iter_engine, u32);
    var direct_u32_fill: [8]u32 = undefined;
    var direct_u32_loop: [8]u32 = undefined;
    direct_u32_iter.fill(&direct_u32_fill);
    i = 0;
    while (i < direct_u32_loop.len) : (i += 1) direct_u32_loop[i] = valueFrom(&direct_u32_loop_engine, u32);
    try std.testing.expectEqualSlices(u32, &direct_u32_loop, &direct_u32_fill);
    try std.testing.expectEqual(direct_u32_loop_engine.next(), direct_u32_iter_engine.next());
}

test "value iterator fill delegates stream-compatible bulk fills" {
    const alea = @import("root.zig");

    var f64_iter_engine = alea.ScalarPrng.init(0x17e9);
    const f64_rng = Rng.init(&f64_iter_engine);
    var f64_direct_engine = alea.ScalarPrng.init(0x17e9);
    var f64_iter = f64_rng.valueIter(f64);
    var f64_iter_fill: [8]f64 = undefined;
    var f64_direct_fill: [8]f64 = undefined;
    f64_iter.fill(&f64_iter_fill);
    fillFrom(&f64_direct_engine, f64, &f64_direct_fill);
    try std.testing.expectEqualSlices(f64, &f64_direct_fill, &f64_iter_fill);
    try std.testing.expectEqual(f64_direct_engine.next(), f64_iter_engine.next());

    var f64_from_engine = alea.ScalarPrng.init(0x17e9);
    var f64_from_direct_engine = alea.ScalarPrng.init(0x17e9);
    var f64_from_iter = valueIterFrom(&f64_from_engine, f64);
    var f64_from_iter_fill: [8]f64 = undefined;
    var f64_from_direct_fill: [8]f64 = undefined;
    f64_from_iter.fill(&f64_from_iter_fill);
    fillFrom(&f64_from_direct_engine, f64, &f64_from_direct_fill);
    try std.testing.expectEqualSlices(f64, &f64_from_direct_fill, &f64_from_iter_fill);
    try std.testing.expectEqual(f64_from_direct_engine.next(), f64_from_engine.next());

    var u64_iter_engine = alea.ScalarPrng.init(0x17e9);
    const u64_rng = Rng.init(&u64_iter_engine);
    var u64_direct_engine = alea.ScalarPrng.init(0x17e9);
    var u64_iter = u64_rng.valueIter(u64);
    var u64_iter_fill: [8]u64 = undefined;
    var u64_direct_fill: [8]u64 = undefined;
    u64_iter.fill(&u64_iter_fill);
    fillFrom(&u64_direct_engine, u64, &u64_direct_fill);
    try std.testing.expectEqualSlices(u64, &u64_direct_fill, &u64_iter_fill);
    try std.testing.expectEqual(u64_direct_engine.next(), u64_iter_engine.next());

    var u64_from_engine = alea.ScalarPrng.init(0x17e9);
    var u64_from_direct_engine = alea.ScalarPrng.init(0x17e9);
    var u64_from_iter = valueIterFrom(&u64_from_engine, u64);
    var u64_from_iter_fill: [8]u64 = undefined;
    var u64_from_direct_fill: [8]u64 = undefined;
    u64_from_iter.fill(&u64_from_iter_fill);
    fillFrom(&u64_from_direct_engine, u64, &u64_from_direct_fill);
    try std.testing.expectEqualSlices(u64, &u64_from_direct_fill, &u64_from_iter_fill);
    try std.testing.expectEqual(u64_from_direct_engine.next(), u64_from_engine.next());

    var vec_iter_engine = alea.ScalarPrng.init(0x17e9);
    const vec_rng = Rng.init(&vec_iter_engine);
    var vec_direct_engine = alea.ScalarPrng.init(0x17e9);
    var vec_iter = vec_rng.valueIter(@Vector(4, f64));
    var vec_iter_fill: [4]@Vector(4, f64) = undefined;
    var vec_direct_fill: [4]@Vector(4, f64) = undefined;
    vec_iter.fill(&vec_iter_fill);
    fillFrom(&vec_direct_engine, @Vector(4, f64), &vec_direct_fill);
    try std.testing.expectEqualSlices(@Vector(4, f64), &vec_direct_fill, &vec_iter_fill);
    try std.testing.expectEqual(vec_direct_engine.next(), vec_iter_engine.next());

    var vec_from_engine = alea.ScalarPrng.init(0x17e9);
    var vec_from_direct_engine = alea.ScalarPrng.init(0x17e9);
    var vec_from_iter = valueIterFrom(&vec_from_engine, @Vector(4, f64));
    var vec_from_iter_fill: [4]@Vector(4, f64) = undefined;
    var vec_from_direct_fill: [4]@Vector(4, f64) = undefined;
    vec_from_iter.fill(&vec_from_iter_fill);
    fillFrom(&vec_from_direct_engine, @Vector(4, f64), &vec_from_direct_fill);
    try std.testing.expectEqualSlices(@Vector(4, f64), &vec_from_direct_fill, &vec_from_iter_fill);
    try std.testing.expectEqual(vec_from_direct_engine.next(), vec_from_engine.next());
}
