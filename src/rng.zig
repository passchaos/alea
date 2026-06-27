const std = @import("std");

const Rng = @This();

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
            for (dest) |*item| item.* = self.uint(T);
        },
        .float => {
            for (dest) |*item| item.* = self.float(T);
        },
        .bool => {
            for (dest) |*item| item.* = self.boolean();
        },
        else => @compileError("alea.Rng.fill supports integer, float, and bool slices"),
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

pub fn ratio(self: Rng, numerator: u32, denominator: u32) bool {
    std.debug.assert(denominator > 0 and numerator <= denominator);
    if (numerator == 0) return false;
    if (numerator == denominator) return true;
    return self.uintLessThan(u32, denominator) < numerator;
}

pub fn uint(self: Rng, comptime T: type) T {
    return uintFrom(self, T);
}

pub fn uintLessThan(self: Rng, comptime T: type, less_than: T) T {
    return uintLessThanFrom(self, T, less_than);
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

pub fn intRangeAtMost(self: Rng, comptime T: type, at_least: T, at_most: T) T {
    return intRangeAtMostFrom(self, T, at_least, at_most);
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
        f32 => @as(f32, @floatFromInt(self.next() >> 40)) * (1.0 / 16777216.0),
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

pub fn normal(self: Rng, comptime T: type, mean: T, stddev: T) T {
    comptime requireFloat(T);
    std.debug.assert(stddev >= 0);
    const open_uniform = self.floatOpen(T);
    const angle_uniform = self.float(T);
    const radius = @sqrt(-2 * @log(open_uniform));
    const theta = @as(T, @floatCast(std.math.tau)) * angle_uniform;
    return mean + stddev * radius * @cos(theta);
}

pub fn exponential(self: Rng, comptime T: type, rate: T) T {
    comptime requireFloat(T);
    std.debug.assert(rate > 0);
    return -@log(self.floatOpen(T)) / rate;
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
    var total: f64 = 0;
    for (weights) |weight| {
        std.debug.assert(weight >= 0);
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

    const tuple = rng.value(struct { u8, bool, f32 });
    try std.testing.expect(tuple[2] < 1.0);

    var buf: [16]u16 = undefined;
    rng.fill(u16, &buf);
    var any_non_zero = false;
    for (buf) |item| any_non_zero = any_non_zero or item != 0;
    try std.testing.expect(any_non_zero);
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
