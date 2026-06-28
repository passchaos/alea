const std = @import("std");

const Rng = @This();

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
    return switch (@typeInfo(T)) {
        .bool => self.boolean(),
        .int => self.uint(T),
        .float => self.float(T),
        .vector => self.vector(T),
        .@"enum" => self.enumValue(T),
        .array => |array_info| blk: {
            var out: T = undefined;
            for (&out) |*item| item.* = self.value(array_info.child);
            break :blk out;
        },
        .@"struct" => |struct_info| blk: {
            if (struct_info.is_tuple) {
                var out: T = undefined;
                inline for (struct_info.fields) |field| {
                    @field(out, field.name) = self.value(field.type);
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

pub fn randomIter(self: Rng, comptime T: type) ValueIterator(T) {
    return self.valueIter(T);
}

pub fn sampleIter(self: Rng, comptime T: type, sampler: anytype) SampleIterator(@TypeOf(sampler), T) {
    return .{
        .rng = self,
        .sampler = sampler,
    };
}

pub fn bytes(self: Rng, buf: []u8) void {
    self.fillFn(self.ptr, buf);
}

pub fn fill(self: Rng, comptime T: type, dest: []T) void {
    switch (@typeInfo(T)) {
        .int => {
            if (T == u8) {
                self.bytes(dest);
                return;
            }
            self.fillInts(T, dest);
        },
        .float => {
            self.fillFloats(T, dest);
        },
        .bool => {
            self.fillBools(dest);
        },
        .vector => {
            for (dest) |*item| item.* = self.vector(T);
        },
        else => @compileError("alea.Rng.fill supports integer, float, bool, and vector slices"),
    }
}

pub fn fillRange(self: Rng, comptime T: type, dest: []T, min: T, max: T) void {
    switch (@typeInfo(T)) {
        .int => {
            std.debug.assert(min < max);
            for (dest) |*item| item.* = self.intRangeLessThan(T, min, max);
        },
        .float => {
            std.debug.assert(min <= max);
            self.fillFloatRange(T, dest, min, max);
        },
        else => @compileError("alea.Rng.fillRange supports integer and floating-point slices"),
    }
}

pub fn fillRangeChecked(self: Rng, comptime T: type, dest: []T, min: T, max: T) Error!void {
    switch (@typeInfo(T)) {
        .int => {
            if (min >= max) return error.EmptyRange;
        },
        .float => {
            if (!(min <= max) or !std.math.isFinite(min) or !std.math.isFinite(max)) return error.EmptyRange;
        },
        else => @compileError("alea.Rng.fillRangeChecked supports integer and floating-point slices"),
    }
    self.fillRange(T, dest, min, max);
}

pub fn fillNormal(self: Rng, comptime T: type, dest: []T, mean: T, stddev: T) void {
    comptime requireFloat(T);
    std.debug.assert(stddev >= 0);
    if (T == f32) {
        self.fillNormalF32(dest, mean, stddev);
        return;
    }
    for (dest) |*item| item.* = self.normal(T, mean, stddev);
}

pub fn fillNormalChecked(self: Rng, comptime T: type, dest: []T, mean: T, stddev: T) Error!void {
    comptime requireFloat(T);
    if (!std.math.isFinite(mean) or !(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
    self.fillNormal(T, dest, mean, stddev);
}

pub fn fillExponential(self: Rng, comptime T: type, dest: []T, rate: T) void {
    comptime requireFloat(T);
    std.debug.assert(rate > 0);
    if (T == f32) {
        self.fillExponentialF32(dest, rate);
        return;
    }
    for (dest) |*item| item.* = self.exponential(T, rate);
}

pub fn fillExponentialChecked(self: Rng, comptime T: type, dest: []T, rate: T) Error!void {
    comptime requireFloat(T);
    if (!(rate > 0) or !std.math.isFinite(rate)) return error.InvalidParameter;
    self.fillExponential(T, dest, rate);
}

pub fn fillSample(self: Rng, comptime T: type, dest: []T, sampler: anytype) void {
    var local_sampler = sampler;
    for (dest) |*item| item.* = local_sampler.sample(self);
}

fn fillBools(self: Rng, dest: []bool) void {
    var i: usize = 0;
    while (i < dest.len) {
        var bits = self.next();
        var lane: usize = 0;
        const take = @min(@as(usize, 64), dest.len - i);
        while (lane < take) : (lane += 1) {
            dest[i + lane] = @as(i64, @bitCast(bits)) < 0;
            bits <<= 1;
        }
        i += take;
    }
}

fn fillInts(self: Rng, comptime T: type, dest: []T) void {
    comptime requireInt(T);
    const info = @typeInfo(T).int;
    if (info.bits == 0) {
        @memset(dest, 0);
        return;
    }
    if (info.bits > 64) {
        for (dest) |*item| item.* = self.uint(T);
        return;
    }

    const Unsigned = std.meta.Int(.unsigned, info.bits);
    const lanes_per_word = @max(1, 64 / info.bits);
    const mask = if (info.bits == 64) std.math.maxInt(u64) else (@as(u64, 1) << @intCast(info.bits)) - 1;

    var i: usize = 0;
    while (i < dest.len) {
        var bits = self.next();
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
    comptime requireFloat(T);
    switch (T) {
        f32 => {
            var i: usize = 0;
            while (i < dest.len) {
                const bits = self.next();
                dest[i] = f32FromBits(@truncate(bits >> 40));
                i += 1;
                if (i < dest.len) {
                    dest[i] = f32FromBits(@truncate(bits >> 16));
                    i += 1;
                }
            }
        },
        f64 => {
            for (dest) |*item| item.* = self.float(f64);
        },
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

fn fillFloatRange(self: Rng, comptime T: type, dest: []T, min: T, max: T) void {
    comptime requireFloat(T);
    switch (T) {
        f32 => {
            self.fill(f32, dest);
            const width = max - min;
            for (dest) |*item| item.* = min + width * item.*;
        },
        f64 => {
            for (dest) |*item| item.* = self.floatRange(f64, min, max);
        },
        else => @compileError("alea supports f32 and f64 floats"),
    }
}

pub fn next(self: Rng) u64 {
    return self.nextFn(self.ptr);
}

pub fn boolean(self: Rng) bool {
    return (@as(i64, @bitCast(self.next())) < 0);
}

pub fn chance(self: Rng, p: f64) bool {
    std.debug.assert(p >= 0 and p <= 1);
    if (p == 0) return false;
    if (p == 1) return true;
    return self.next() < probabilityThreshold(p);
}

pub fn chanceChecked(self: Rng, p: f64) Error!bool {
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    return self.chance(p);
}

pub fn ratio(self: Rng, numerator: u32, denominator: u32) bool {
    std.debug.assert(denominator > 0 and numerator <= denominator);
    if (numerator == 0) return false;
    if (numerator == denominator) return true;
    return self.uintLessThan(u32, denominator) < numerator;
}

pub fn ratioChecked(self: Rng, numerator: u32, denominator: u32) Error!bool {
    if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
    return self.ratio(numerator, denominator);
}

pub fn uint(self: Rng, comptime T: type) T {
    return uintFrom(self, T);
}

pub fn uintLessThan(self: Rng, comptime T: type, less_than: T) T {
    return uintLessThanFrom(self, T, less_than);
}

pub fn uintLessThanChecked(self: Rng, comptime T: type, less_than: T) Error!T {
    if (less_than == 0) return error.EmptyRange;
    return self.uintLessThan(T, less_than);
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
    if (at_least >= less_than) return error.EmptyRange;
    return self.intRangeLessThan(T, at_least, less_than);
}

pub fn intRangeAtMost(self: Rng, comptime T: type, at_least: T, at_most: T) T {
    return intRangeAtMostFrom(self, T, at_least, at_most);
}

pub fn intRangeAtMostChecked(self: Rng, comptime T: type, at_least: T, at_most: T) Error!T {
    if (at_least > at_most) return error.EmptyRange;
    return self.intRangeAtMost(T, at_least, at_most);
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
    comptime requireFloat(T);
    return switch (T) {
        f32 => blk: {
            const fraction: u32 = @truncate(self.next() >> 41);
            const bits = (@as(u32, 127) << 23) | fraction;
            break :blk @as(f32, @bitCast(bits)) - (1.0 - std.math.floatEps(f32) / 2.0);
        },
        f64 => blk: {
            const fraction = self.next() >> 12;
            const bits = (@as(u64, 1023) << 52) | fraction;
            break :blk @as(f64, @bitCast(bits)) - (1.0 - std.math.floatEps(f64) / 2.0);
        },
        else => @compileError("alea supports f32 and f64 floats"),
    };
}

pub fn floatOpenClosed(self: Rng, comptime T: type) T {
    comptime requireFloat(T);
    return switch (T) {
        f32 => (@as(f32, @floatFromInt(self.next() >> 40)) + 1.0) * (1.0 / 16777216.0),
        f64 => (@as(f64, @floatFromInt(self.next() >> 11)) + 1.0) * (1.0 / 9007199254740992.0),
        else => @compileError("alea supports f32 and f64 floats"),
    };
}

pub fn floatRange(self: Rng, comptime T: type, min: T, max: T) T {
    std.debug.assert(min <= max);
    return min + (max - min) * self.float(T);
}

pub fn floatRangeChecked(self: Rng, comptime T: type, min: T, max: T) Error!T {
    if (!(min <= max) or !std.math.isFinite(min) or !std.math.isFinite(max)) return error.EmptyRange;
    return self.floatRange(T, min, max);
}

pub fn vector(self: Rng, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    return switch (@typeInfo(info.child)) {
        .bool => self.vectorBools(VectorType),
        .int => self.vectorInts(VectorType),
        .float => switch (info.child) {
            f32 => self.vectorF32(VectorType),
            f64 => self.vectorScalar(VectorType),
            else => @compileError("alea supports f32 and f64 float vectors"),
        },
        else => @compileError("alea.Rng.vector supports bool, integer, and floating-point vectors"),
    };
}

pub fn vectorRange(self: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    const info = vectorInfo(VectorType);
    switch (@typeInfo(info.child)) {
        .int => {
            std.debug.assert(min < max);
            var out: VectorType = undefined;
            inline for (0..info.len) |i| out[i] = self.intRangeLessThan(info.child, min, max);
            return out;
        },
        .float => {
            std.debug.assert(min <= max);
            return @as(VectorType, @splat(min)) + (@as(VectorType, @splat(max)) - @as(VectorType, @splat(min))) * self.vector(VectorType);
        },
        else => @compileError("Rng.vectorRange supports integer and floating-point vectors"),
    }
}

pub fn vectorRangeChecked(self: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
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
    return self.vectorRange(VectorType, min, max);
}

pub fn vectorNormal(self: Rng, comptime VectorType: type, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) VectorType {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    std.debug.assert(stddev >= 0);
    if (info.child == f32) return self.vectorNormalF32(VectorType, mean, stddev);
    var out: VectorType = undefined;
    inline for (0..info.len) |i| out[i] = self.normal(info.child, mean, stddev);
    return out;
}

pub fn vectorExponential(self: Rng, comptime VectorType: type, rate: vectorChild(VectorType)) VectorType {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    std.debug.assert(rate > 0);
    if (info.child == f32) {
        const uniform = self.vector(VectorType);
        return -@log(@as(VectorType, @splat(1)) - uniform) / @as(VectorType, @splat(rate));
    }
    var out: VectorType = undefined;
    inline for (0..info.len) |i| out[i] = self.exponential(info.child, rate);
    return out;
}

pub fn durationRangeLessThan(self: Rng, min: std.Io.Duration, max: std.Io.Duration) std.Io.Duration {
    std.debug.assert(min.nanoseconds < max.nanoseconds);
    return .{ .nanoseconds = self.intRangeLessThan(i96, min.nanoseconds, max.nanoseconds) };
}

pub fn durationRangeAtMost(self: Rng, min: std.Io.Duration, max: std.Io.Duration) std.Io.Duration {
    std.debug.assert(min.nanoseconds <= max.nanoseconds);
    return .{ .nanoseconds = self.intRangeAtMost(i96, min.nanoseconds, max.nanoseconds) };
}

pub fn durationRangeLessThanChecked(self: Rng, min: std.Io.Duration, max: std.Io.Duration) Error!std.Io.Duration {
    if (min.nanoseconds >= max.nanoseconds) return error.EmptyRange;
    return self.durationRangeLessThan(min, max);
}

pub fn durationRangeAtMostChecked(self: Rng, min: std.Io.Duration, max: std.Io.Duration) Error!std.Io.Duration {
    if (min.nanoseconds > max.nanoseconds) return error.EmptyRange;
    return self.durationRangeAtMost(min, max);
}

pub fn unicodeScalar(self: Rng) u21 {
    const gap_size = 0xDFFF - 0xD800 + 1;
    var scalar = self.intRangeLessThan(u21, gap_size, 0x11_0000);
    if (scalar <= 0xDFFF) scalar -= gap_size;
    return scalar;
}

pub fn normal(self: Rng, comptime T: type, mean: T, stddev: T) T {
    comptime requireFloat(T);
    std.debug.assert(stddev >= 0);
    return mean + stddev * self.random().floatNorm(T);
}

pub fn exponential(self: Rng, comptime T: type, rate: T) T {
    comptime requireFloat(T);
    std.debug.assert(rate > 0);
    return self.random().floatExp(T) / rate;
}

pub fn enumValue(self: Rng, comptime EnumType: type) EnumType {
    comptime {
        if (@typeInfo(EnumType) != .@"enum") @compileError("enumValue expects an enum type");
    }
    const values = comptime std.enums.values(EnumType);
    comptime std.debug.assert(values.len > 0);
    if (values.len == 1) return values[0];
    return values[self.uintLessThan(usize, values.len)];
}

pub fn shuffle(self: Rng, comptime T: type, items: []T) void {
    if (items.len < 2) return;
    var i = items.len - 1;
    while (i > 0) : (i -= 1) {
        const j = self.uintAtMost(usize, i);
        std.mem.swap(T, &items[i], &items[j]);
    }
}

pub fn choose(self: Rng, comptime T: type, items: []const T) ?T {
    if (items.len == 0) return null;
    return items[self.uintLessThan(usize, items.len)];
}

pub fn choosePtr(self: Rng, comptime T: type, items: []T) ?*T {
    if (items.len == 0) return null;
    return &items[self.uintLessThan(usize, items.len)];
}

pub fn weightedIndex(self: Rng, weights: []const f64) ?usize {
    return self.weightedIndexChecked(weights) catch unreachable;
}

pub fn weightedIndexChecked(self: Rng, weights: []const f64) Error!?usize {
    var total: f64 = 0;
    for (weights) |weight| {
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        total += weight;
    }
    if (weights.len == 0 or total == 0) return null;

    const point = self.float(f64) * total;
    var acc: f64 = 0;
    for (weights, 0..) |weight, i| {
        acc += weight;
        if (point < acc) return i;
    }
    return weights.len - 1;
}

pub fn sampleWithoutReplacement(self: Rng, comptime T: type, allocator: std.mem.Allocator, items: []const T, count: usize) ![]T {
    std.debug.assert(count <= items.len);
    return self.sampleWithoutReplacementChecked(T, allocator, items, count) catch unreachable;
}

pub fn sampleWithoutReplacementChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, items: []const T, count: usize) ![]T {
    if (count > items.len) return error.InvalidParameter;
    var pool = try std.ArrayList(T).initCapacity(allocator, items.len);
    defer pool.deinit(allocator);
    try pool.appendSlice(allocator, items);

    var out = try std.ArrayList(T).initCapacity(allocator, count);
    errdefer out.deinit(allocator);

    while (out.items.len < count) {
        const index = self.uintLessThan(usize, pool.items.len);
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
            for (dest) |*item| item.* = self.nextValue();
        }
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
            return self.sampler.sample(self.rng);
        }

        pub fn fill(self: *Self, dest: []T) void {
            for (dest) |*item| item.* = self.nextValue();
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

fn nextFrom(source: anytype) u64 {
    return source.next();
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

fn vectorScalar(self: Rng, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    var out: VectorType = undefined;
    inline for (0..info.len) |i| {
        out[i] = self.value(info.child);
    }
    return out;
}

fn vectorBools(self: Rng, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("vectorBools expects a bool vector");

    var out: VectorType = undefined;
    var bits: u64 = 0;
    inline for (0..info.len) |i| {
        if (i % 64 == 0) bits = self.next();
        out[i] = @as(i64, @bitCast(bits)) < 0;
        bits <<= 1;
    }
    return out;
}

fn vectorInts(self: Rng, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    comptime requireInt(info.child);
    const int_info = @typeInfo(info.child).int;
    if (int_info.bits == 0) return @splat(0);
    if (int_info.bits > 64) return self.vectorScalar(VectorType);

    const Unsigned = std.meta.Int(.unsigned, int_info.bits);
    const lanes_per_word = @max(1, 64 / int_info.bits);
    const mask = if (int_info.bits == 64) std.math.maxInt(u64) else (@as(u64, 1) << @intCast(int_info.bits)) - 1;

    var out: VectorType = undefined;
    var bits: u64 = 0;
    inline for (0..info.len) |i| {
        if (i % lanes_per_word == 0) bits = self.next();
        const raw: Unsigned = @intCast(bits & mask);
        out[i] = @bitCast(raw);
        if (int_info.bits != 64) bits >>= @intCast(int_info.bits);
    }
    return out;
}

fn vectorF32(self: Rng, comptime VectorType: type) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != f32) @compileError("vectorF32 expects a f32 vector");

    var out: VectorType = undefined;
    var bits: u64 = 0;
    inline for (0..info.len) |i| {
        if (i % 2 == 0) bits = self.next();
        out[i] = if (i % 2 == 0)
            f32FromBits(@truncate(bits >> 40))
        else
            f32FromBits(@truncate(bits >> 16));
    }
    return out;
}

fn vectorNormalF32(self: Rng, comptime VectorType: type, mean: f32, stddev: f32) VectorType {
    const info = vectorInfo(VectorType);
    if (info.child != f32) @compileError("vectorNormalF32 expects a f32 vector");

    const one: VectorType = @splat(1);
    const tau: VectorType = @splat(@as(f32, @floatCast(std.math.tau)));
    const uniform_radius = one - self.vector(VectorType);
    const uniform_angle = self.vector(VectorType);
    const radius = @sqrt(@as(VectorType, @splat(-2)) * @log(uniform_radius));
    const theta = tau * uniform_angle;
    return @as(VectorType, @splat(mean)) + @as(VectorType, @splat(stddev)) * radius * @cos(theta);
}

fn fillNormalF32(self: Rng, dest: []f32, mean: f32, stddev: f32) void {
    const Vec = @Vector(8, f32);
    const mean_vec: Vec = @splat(mean);
    const stddev_vec: Vec = @splat(stddev);
    const one: Vec = @splat(1);
    const tau: Vec = @splat(@as(f32, @floatCast(std.math.tau)));

    var i: usize = 0;
    while (i + 16 <= dest.len) : (i += 16) {
        const uniform_radius = one - self.vector(Vec);
        const uniform_angle = self.vector(Vec);
        const radius = @sqrt(@as(Vec, @splat(-2)) * @log(uniform_radius));
        const theta = tau * uniform_angle;
        const z0 = mean_vec + stddev_vec * radius * @cos(theta);
        const z1 = mean_vec + stddev_vec * radius * @sin(theta);
        inline for (0..8) |lane| {
            dest[i + lane] = z0[lane];
            dest[i + 8 + lane] = z1[lane];
        }
    }

    while (i + 8 <= dest.len) : (i += 8) {
        const normal_vec = self.vectorNormal(Vec, mean, stddev);
        inline for (0..8) |lane| dest[i + lane] = normal_vec[lane];
    }

    while (i < dest.len) : (i += 1) dest[i] = self.normal(f32, mean, stddev);
}

fn fillExponentialF32(self: Rng, dest: []f32, rate: f32) void {
    const Vec = @Vector(8, f32);
    var i: usize = 0;
    while (i + 8 <= dest.len) : (i += 8) {
        const samples = self.vectorExponential(Vec, rate);
        inline for (0..8) |lane| dest[i + lane] = samples[lane];
    }

    while (i < dest.len) : (i += 1) dest[i] = self.exponential(f32, rate);
}

fn f32FromBits(bits: u24) f32 {
    return @as(f32, @floatFromInt(bits)) * (1.0 / 16777216.0);
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
    try std.testing.expect(rng.chance(1));
    try std.testing.expect(!rng.ratio(0, 7));
    try std.testing.expect(rng.chance(1.0 - std.math.floatEps(f64) / 2.0));
    try std.testing.expect(try rng.chanceChecked(0.5) or true);
    try std.testing.expectError(error.InvalidProbability, rng.chanceChecked(1.1));
    try std.testing.expectError(error.InvalidProbability, rng.ratioChecked(2, 1));
    try std.testing.expectError(error.EmptyRange, rng.uintLessThanChecked(u32, 0));
    try std.testing.expectError(error.EmptyRange, rng.intRangeLessThanChecked(u32, 3, 3));
    try std.testing.expectError(error.EmptyRange, rng.intRangeAtMostChecked(u32, 4, 3));
    try std.testing.expectError(error.EmptyRange, rng.floatRangeChecked(f64, std.math.inf(f64), 1));
    const duration = rng.durationRangeAtMost(.fromMilliseconds(10), .fromMilliseconds(20));
    try std.testing.expect(duration.nanoseconds >= std.time.ns_per_ms * 10);
    try std.testing.expect(duration.nanoseconds <= std.time.ns_per_ms * 20);
    try std.testing.expectError(error.EmptyRange, rng.durationRangeLessThanChecked(.fromSeconds(2), .fromSeconds(1)));

    const tuple = rng.value(struct { u8, bool, f32 });
    try std.testing.expect(tuple[2] < 1.0);

    const scalar = rng.unicodeScalar();
    try std.testing.expect(scalar < 0xD800 or scalar > 0xDFFF);
    try std.testing.expect(scalar < 0x11_0000);

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

    var bool_buf: [128]bool = undefined;
    rng.fill(bool, &bool_buf);
    var saw_true = false;
    var saw_false = false;
    for (bool_buf) |item| {
        saw_true = saw_true or item;
        saw_false = saw_false or !item;
    }
    try std.testing.expect(saw_true and saw_false);

    var ranged_buf: [16]i16 = undefined;
    rng.fillRange(i16, &ranged_buf, -20, 20);
    for (ranged_buf) |item| try std.testing.expect(item >= -20 and item < 20);

    var ranged_float_buf: [16]f32 = undefined;
    try rng.fillRangeChecked(f32, &ranged_float_buf, -1, 1);
    for (ranged_float_buf) |item| try std.testing.expect(item >= -1 and item < 1);

    var f32_buf: [17]f32 = undefined;
    rng.fill(f32, &f32_buf);
    for (f32_buf) |item| try std.testing.expect(item >= 0 and item < 1);

    var normal_buf: [16]f64 = undefined;
    try rng.fillNormalChecked(f64, &normal_buf, 0, 1);
    for (normal_buf) |item| try std.testing.expect(std.math.isFinite(item));

    var normal_f32_buf: [33]f32 = undefined;
    try rng.fillNormalChecked(f32, &normal_f32_buf, 0, 1);
    for (normal_f32_buf) |item| try std.testing.expect(std.math.isFinite(item));

    var exp_buf: [16]f64 = undefined;
    try rng.fillExponentialChecked(f64, &exp_buf, 2);
    for (exp_buf) |item| try std.testing.expect(item >= 0);

    var exp_f32_buf: [17]f32 = undefined;
    try rng.fillExponentialChecked(f32, &exp_f32_buf, 2);
    for (exp_f32_buf) |item| try std.testing.expect(item >= 0);

    const alea = @import("root.zig");
    var poisson_buf: [16]u64 = undefined;
    rng.fillSample(u64, &poisson_buf, try alea.distributions.Poisson.init(8));
    for (poisson_buf) |item| try std.testing.expect(item < 64);

    var normal_sampler = try alea.distributions.Normal(f64).init(0, 1);
    var sample_buf: [16]f64 = undefined;
    rng.fillSample(f64, &sample_buf, &normal_sampler);
    for (sample_buf) |item| try std.testing.expect(std.math.isFinite(item));

    const uvec = rng.value(@Vector(4, u16));
    var any_vec_non_zero = false;
    inline for (0..4) |i| any_vec_non_zero = any_vec_non_zero or uvec[i] != 0;
    try std.testing.expect(any_vec_non_zero);

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

    const fvec = rng.value(@Vector(4, f32));
    inline for (0..4) |i| try std.testing.expect(fvec[i] >= 0 and fvec[i] < 1);

    var vec_buf: [8]@Vector(8, f32) = undefined;
    rng.fill(@Vector(8, f32), &vec_buf);
    for (vec_buf) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] >= 0 and vec[i] < 1);

    const ranged_i = rng.vectorRange(@Vector(4, i32), -10, 10);
    inline for (0..4) |i| try std.testing.expect(ranged_i[i] >= -10 and ranged_i[i] < 10);

    const ranged_f = rng.vectorRange(@Vector(4, f64), -1, 2);
    inline for (0..4) |i| try std.testing.expect(ranged_f[i] >= -1 and ranged_f[i] < 2);

    const normals = rng.vectorNormal(@Vector(4, f64), 0, 1);
    inline for (0..4) |i| try std.testing.expect(std.math.isFinite(normals[i]));

    const vector_normals_f32 = rng.vectorNormal(@Vector(8, f32), 0, 1);
    inline for (0..8) |i| try std.testing.expect(std.math.isFinite(vector_normals_f32[i]));

    const exponentials = rng.vectorExponential(@Vector(4, f64), 2);
    inline for (0..4) |i| try std.testing.expect(exponentials[i] >= 0);

    const vector_exp_f32 = rng.vectorExponential(@Vector(8, f32), 2);
    inline for (0..8) |i| try std.testing.expect(vector_exp_f32[i] >= 0);

    try std.testing.expectError(error.EmptyRange, rng.vectorRangeChecked(@Vector(4, u32), 3, 3));
    try std.testing.expectError(error.EmptyRange, rng.vectorRangeChecked(@Vector(4, f64), std.math.inf(f64), 1));
    try std.testing.expectError(error.EmptyRange, rng.fillRangeChecked(u32, &.{}, 3, 3));
    try std.testing.expectError(error.InvalidParameter, rng.fillNormalChecked(f64, &normal_buf, 0, -1));
    try std.testing.expectError(error.InvalidParameter, rng.fillExponentialChecked(f64, &exp_buf, 0));
}

test "shuffle and sampling keep item set" {
    const Wyhash64 = @import("engines/wyhash64.zig");
    var engine = Wyhash64.init(9);
    const rng = Rng.init(&engine);
    var values = [_]u8{ 1, 2, 3, 4, 5 };
    rng.shuffle(u8, &values);

    var sum: u32 = 0;
    for (values) |item| sum += item;
    try std.testing.expectEqual(@as(u32, 15), sum);

    const sample = try rng.sampleWithoutReplacement(u8, std.testing.allocator, &values, 3);
    defer std.testing.allocator.free(sample);
    try std.testing.expectEqual(@as(usize, 3), sample.len);
    try std.testing.expectError(error.InvalidParameter, rng.sampleWithoutReplacementChecked(u8, std.testing.allocator, &values, 99));
    try std.testing.expectError(error.InvalidWeight, rng.weightedIndexChecked(&.{ 1.0, std.math.nan(f64) }));
}

test "value and sampler iterators produce unbounded samples" {
    const alea = @import("root.zig");
    var engine = alea.Xoshiro256.init(123);
    const rng = Rng.init(&engine);

    var values = rng.valueIter(u16);
    const first = values.next().?;
    const second = values.nextValue();
    try std.testing.expect(first != second);

    var bool_iter = rng.randomIter(bool);
    var bools: [8]bool = undefined;
    bool_iter.fill(&bools);

    var tuple_iter = rng.valueIter(struct { u8, bool, f32 });
    const tuple = tuple_iter.nextValue();
    try std.testing.expect(tuple[2] >= 0 and tuple[2] < 1);

    const die = try alea.distributions.Uniform(u8).initInclusive(1, 6);
    var rolls = rng.sampleIter(u8, die);
    var i: usize = 0;
    while (i < 16) : (i += 1) {
        const roll = rolls.next().?;
        try std.testing.expect(roll >= 1 and roll <= 6);
    }
}
