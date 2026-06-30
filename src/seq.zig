const std = @import("std");
const Rng = @import("rng.zig");
const distributions = @import("distributions.zig");

pub const IndexVec = union(enum) {
    u32: []u32,
    usize: []usize,

    pub fn len(self: IndexVec) usize {
        return switch (self) {
            .u32 => |items| items.len,
            .usize => |items| items.len,
        };
    }

    pub fn at(self: IndexVec, index: usize) usize {
        return switch (self) {
            .u32 => |items| items[index],
            .usize => |items| items[index],
        };
    }

    pub fn deinit(self: IndexVec, allocator: std.mem.Allocator) void {
        switch (self) {
            .u32 => |items| allocator.free(items),
            .usize => |items| allocator.free(items),
        }
    }
};

pub const Error = error{
    InvalidParameter,
};

pub fn sampleIndexVec(allocator: std.mem.Allocator, rng: Rng, length: usize, amount: usize) !IndexVec {
    if (amount > length) return error.InvalidParameter;
    return sampleIndexVecFrom(allocator, rng, length, amount);
}

pub fn sampleIndexVecFrom(allocator: std.mem.Allocator, source: anytype, length: usize, amount: usize) !IndexVec {
    std.debug.assert(amount <= length);
    if (length <= std.math.maxInt(u32)) {
        return .{ .u32 = try sampleIndicesU32From(allocator, source, @intCast(length), @intCast(amount)) };
    }
    return .{ .usize = try sampleIndicesLarge(allocator, source, length, amount) };
}

pub fn sampleIndices(allocator: std.mem.Allocator, rng: Rng, length: usize, amount: usize) ![]usize {
    if (amount > length) return error.InvalidParameter;
    return sampleIndicesFrom(allocator, rng, length, amount);
}

pub fn sampleIndicesFrom(allocator: std.mem.Allocator, source: anytype, length: usize, amount: usize) ![]usize {
    std.debug.assert(amount <= length);
    if (amount == 0) return allocator.alloc(usize, 0);
    if (length <= std.math.maxInt(u32)) {
        return sampleIndicesU32AsUsize(allocator, source, @intCast(length), @intCast(amount));
    }
    if (length < 4 * amount and length <= 1_000_000) {
        return sampleInPlace(allocator, source, length, amount);
    }
    if (amount <= 128) {
        return sampleFloyd(allocator, source, length, amount);
    }
    return sampleRejection(allocator, source, length, amount);
}

pub fn sampleIndicesU32(allocator: std.mem.Allocator, rng: Rng, length: u32, amount: u32) ![]u32 {
    if (amount > length) return error.InvalidParameter;
    return sampleIndicesU32From(allocator, rng, length, amount);
}

pub fn sampleIndicesU32From(allocator: std.mem.Allocator, source: anytype, length: u32, amount: u32) ![]u32 {
    std.debug.assert(amount <= length);
    if (amount == 0) return allocator.alloc(u32, 0);

    if (amount < 163) {
        const j: usize = @intFromBool(length >= 500_000);
        const c0 = [_]f32{ 1.6, 8.0 / 45.0 };
        const c1 = [_]f32{ 10.0, 70.0 / 9.0 };
        const amount_fp: f32 = @floatFromInt(amount);
        const m4 = c0[j] * amount_fp;
        if (amount > 11 and @as(f32, @floatFromInt(length)) < (c1[j] + m4) * amount_fp) {
            return sampleInPlaceU32(allocator, source, length, amount);
        }
        return sampleFloydU32(allocator, source, length, amount);
    }

    const c = [_]f32{ 270.0, 330.0 / 9.0 };
    const j: usize = @intFromBool(length >= 500_000);
    if (@as(f32, @floatFromInt(length)) < c[j] * @as(f32, @floatFromInt(amount))) {
        return sampleInPlaceU32(allocator, source, length, amount);
    }
    return sampleRejectionU32(allocator, source, length, amount);
}

fn sampleIndicesU32AsUsize(allocator: std.mem.Allocator, source: anytype, length: u32, amount: u32) ![]usize {
    std.debug.assert(amount <= length);
    if (amount == 0) return allocator.alloc(usize, 0);

    if (amount < 163) {
        const j: usize = @intFromBool(length >= 500_000);
        const c0 = [_]f32{ 1.6, 8.0 / 45.0 };
        const c1 = [_]f32{ 10.0, 70.0 / 9.0 };
        const amount_fp: f32 = @floatFromInt(amount);
        const m4 = c0[j] * amount_fp;
        if (amount > 11 and @as(f32, @floatFromInt(length)) < (c1[j] + m4) * amount_fp) {
            return sampleInPlaceU32AsUsize(allocator, source, length, amount);
        }
        return sampleFloydU32AsUsize(allocator, source, length, amount);
    }

    const c = [_]f32{ 270.0, 330.0 / 9.0 };
    const j: usize = @intFromBool(length >= 500_000);
    if (@as(f32, @floatFromInt(length)) < c[j] * @as(f32, @floatFromInt(amount))) {
        return sampleInPlaceU32AsUsize(allocator, source, length, amount);
    }
    return sampleRejectionU32AsUsize(allocator, source, length, amount);
}

fn sampleIndicesLarge(allocator: std.mem.Allocator, source: anytype, length: usize, amount: usize) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (length < 4 * amount and length <= 1_000_000) {
        return sampleInPlace(allocator, source, length, amount);
    }
    if (amount <= 128) {
        return sampleFloyd(allocator, source, length, amount);
    }
    return sampleRejection(allocator, source, length, amount);
}

pub fn sampleArray(rng: Rng, comptime N: usize, length: usize) ?[N]usize {
    return sampleArrayFrom(rng, N, length);
}

pub fn sampleArrayFrom(source: anytype, comptime N: usize, length: usize) ?[N]usize {
    if (N > length) return null;
    var indices: [N]usize = undefined;

    var i: usize = 0;
    var j = length - N;
    while (j < length) : ({
        j += 1;
        i += 1;
    }) {
        const t = Rng.uintAtMostFrom(source, usize, j);
        var found: ?usize = null;
        for (indices[0..i], 0..) |existing, pos| {
            if (existing == t) {
                found = pos;
                break;
            }
        }
        if (found) |pos| indices[pos] = j;
        indices[i] = t;
    }

    return indices;
}

pub fn chooseMultiple(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]T {
    return chooseMultipleFrom(allocator, rng, T, items, amount);
}

pub fn chooseMultipleFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]T {
    const count = @min(amount, items.len);
    const indices = try sampleIndicesFrom(allocator, source, items.len, count);
    defer allocator.free(indices);

    const out = try allocator.alloc(T, count);
    for (indices, out) |index, *slot| slot.* = items[index];
    return out;
}

pub fn chooseIterator(rng: Rng, comptime T: type, iterator: anytype) ?T {
    return chooseIteratorFrom(rng, T, iterator);
}

pub fn chooseIteratorFrom(source: anytype, comptime T: type, iterator: anytype) ?T {
    var seen: usize = 0;
    var result: ?T = null;

    while (iterator.next()) |item| {
        seen += 1;
        if (Rng.uintLessThanFrom(source, usize, seen) == 0) {
            result = item;
        }
    }

    return result;
}

pub fn sampleIterator(allocator: std.mem.Allocator, rng: Rng, comptime T: type, iterator: anytype, amount: usize) ![]T {
    return sampleIteratorFrom(allocator, rng, T, iterator, amount);
}

pub fn sampleIteratorFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, iterator: anytype, amount: usize) ![]T {
    var reservoir = try std.ArrayList(T).initCapacity(allocator, amount);
    errdefer reservoir.deinit(allocator);
    if (amount == 0) return reservoir.toOwnedSlice(allocator);

    while (reservoir.items.len < amount) {
        const item = iterator.next() orelse return reservoir.toOwnedSlice(allocator);
        try reservoir.append(allocator, item);
    }

    var seen = reservoir.items.len;
    while (iterator.next()) |item| {
        seen += 1;
        const index = Rng.uintLessThanFrom(source, usize, seen);
        if (index < amount) reservoir.items[index] = item;
    }

    return reservoir.toOwnedSlice(allocator);
}

pub fn chooseIteratorWeighted(rng: Rng, comptime T: type, iterator: anytype) !?T {
    return chooseIteratorWeightedFrom(rng, T, iterator);
}

pub fn chooseIteratorWeightedFrom(source: anytype, comptime T: type, iterator: anytype) !?T {
    var total: f64 = 0;
    var result: ?T = null;

    while (iterator.next()) |entry| {
        const weight = weightAsF64(@TypeOf(entry.weight), entry.weight);
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight == 0) continue;

        total += weight;
        if (Rng.floatFrom(source, f64) * total < weight) {
            result = entry.item;
        }
    }

    return result;
}

pub fn sampleIteratorWeighted(allocator: std.mem.Allocator, rng: Rng, comptime T: type, iterator: anytype, amount: usize) ![]T {
    return sampleIteratorWeightedFrom(allocator, rng, T, iterator, amount);
}

pub fn sampleIteratorWeightedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, iterator: anytype, amount: usize) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);

    var heap = WeightedIteratorQueue(T).initContext({});
    defer heap.deinit(allocator);
    try heap.ensureTotalCapacityPrecise(allocator, amount);

    while (iterator.next()) |entry| {
        const weight = weightAsF64(@TypeOf(entry.weight), entry.weight);
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight == 0) continue;

        const candidate = WeightedIteratorCandidate(T){
            .item = entry.item,
            .key = @log(Rng.floatOpenFrom(source, f64)) / weight,
        };

        if (heap.count() < amount) {
            try heap.push(allocator, candidate);
        } else if (heap.peek()) |min_candidate| {
            if (candidate.key > min_candidate.key) {
                _ = heap.pop();
                try heap.push(allocator, candidate);
            }
        }
    }

    const out = try allocator.alloc(T, heap.count());
    errdefer allocator.free(out);
    var i: usize = 0;
    while (heap.pop()) |candidate| : (i += 1) {
        out[i] = candidate.item;
    }
    return out;
}

pub fn sampleWeightedIndices(allocator: std.mem.Allocator, rng: Rng, comptime Weight: type, weights: []const Weight, amount: usize) ![]usize {
    return sampleWeightedIndicesFrom(allocator, rng, Weight, weights, amount);
}

pub fn sampleWeightedIndicesFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, weights: []const Weight, amount: usize) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (weights.len == 0) return error.EmptyInput;

    const limit = @min(amount, weights.len);
    var heap = WeightedCandidateQueue.initContext({});
    defer heap.deinit(allocator);
    try heap.ensureTotalCapacityPrecise(allocator, limit);

    for (weights, 0..) |weight, index| {
        const value = weightAsF64(Weight, weight);
        if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
        if (value == 0) continue;

        const candidate = WeightedCandidate{
            .index = index,
            .key = @log(Rng.floatOpenFrom(source, f64)) / value,
        };

        if (heap.count() < limit) {
            try heap.push(allocator, candidate);
        } else if (heap.peek()) |min_candidate| {
            if (candidate.key > min_candidate.key) {
                _ = heap.pop();
                try heap.push(allocator, candidate);
            }
        }
    }

    const out = try allocator.alloc(usize, heap.count());
    errdefer allocator.free(out);
    var i: usize = 0;
    while (heap.pop()) |candidate| : (i += 1) {
        out[i] = candidate.index;
    }
    return out;
}

pub fn sampleWeighted(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, amount: usize) ![]T {
    return sampleWeightedFrom(allocator, rng, T, Weight, items, weights, amount);
}

pub fn sampleWeightedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, amount: usize) ![]T {
    if (items.len != weights.len) return error.LengthMismatch;
    const count = @min(amount, items.len);
    const indices = try sampleWeightedIndicesFrom(allocator, source, Weight, weights, count);
    defer allocator.free(indices);

    const out = try allocator.alloc(T, indices.len);
    for (indices, out) |index, *slot| slot.* = items[index];
    return out;
}

pub fn Choice(comptime T: type) type {
    return struct {
        const Self = @This();

        items: []const T,

        pub fn init(items: []const T) ?Self {
            if (items.len == 0) return null;
            return .{ .items = items };
        }

        pub fn len(self: Self) usize {
            return self.items.len;
        }

        pub fn sample(self: Self, rng: Rng) *const T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) *const T {
            return &self.items[Rng.uintLessThanFrom(source, usize, self.items.len)];
        }

        pub fn sampleValue(self: Self, rng: Rng) T {
            return self.sample(rng).*;
        }

        pub fn sampleValueFrom(self: Self, source: anytype) T {
            return self.sampleFrom(source).*;
        }

        pub fn fill(self: Self, rng: Rng, dest: []*const T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []*const T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }

        pub fn fillValues(self: Self, rng: Rng, dest: []T) void {
            self.fillValuesFrom(rng, dest);
        }

        pub fn fillValuesFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleValueFrom(source);
        }

        pub fn iter(self: Self, rng: Rng) Rng.SampleIterator(Self, *const T) {
            return rng.sampleIter(*const T, self);
        }

        pub fn iterFrom(self: Self, source: anytype) Rng.SampleIteratorFrom(@TypeOf(source), Self, *const T) {
            return Rng.sampleIterFrom(source, *const T, self);
        }
    };
}

pub fn chooseIter(rng: Rng, comptime T: type, items: []const T) ?Rng.SampleIterator(Choice(T), *const T) {
    const choice = Choice(T).init(items) orelse return null;
    return choice.iter(rng);
}

pub fn WeightedChoice(comptime T: type, comptime Weight: type) type {
    return struct {
        const Self = @This();
        const Table = distributions.AliasTable(Weight);

        items: []const T,
        table: Table,

        pub fn init(allocator: std.mem.Allocator, items: []const T, weights: []const Weight) !Self {
            if (items.len == 0) return error.EmptyInput;
            if (items.len != weights.len) return error.LengthMismatch;
            return .{
                .items = items,
                .table = try Table.init(allocator, weights),
            };
        }

        pub fn deinit(self: *Self) void {
            self.table.deinit();
            self.* = undefined;
        }

        pub fn len(self: Self) usize {
            return self.items.len;
        }

        pub fn sample(self: Self, rng: Rng) *const T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) *const T {
            return &self.items[self.table.sampleFrom(source)];
        }

        pub fn sampleValue(self: Self, rng: Rng) T {
            return self.sampleFrom(rng).*;
        }

        pub fn sampleValueFrom(self: Self, source: anytype) T {
            return self.sampleFrom(source).*;
        }

        pub fn fill(self: Self, rng: Rng, dest: []*const T) void {
            self.fillFrom(rng, dest);
        }

        pub fn fillFrom(self: Self, source: anytype, dest: []*const T) void {
            for (dest) |*item| item.* = self.sampleFrom(source);
        }

        pub fn fillValues(self: Self, rng: Rng, dest: []T) void {
            self.fillValuesFrom(rng, dest);
        }

        pub fn fillValuesFrom(self: Self, source: anytype, dest: []T) void {
            for (dest) |*item| item.* = self.sampleValueFrom(source);
        }

        pub fn iter(self: Self, rng: Rng) Rng.SampleIterator(Self, *const T) {
            return rng.sampleIter(*const T, self);
        }

        pub fn iterFrom(self: Self, source: anytype) Rng.SampleIteratorFrom(@TypeOf(source), Self, *const T) {
            return Rng.sampleIterFrom(source, *const T, self);
        }
    };
}

pub fn partialShuffle(rng: Rng, comptime T: type, items: []T, amount: usize) []T {
    return partialShuffleFrom(rng, T, items, amount);
}

pub fn partialShuffleFrom(source: anytype, comptime T: type, items: []T, amount: usize) []T {
    const count = @min(amount, items.len);
    var i: usize = 0;
    while (i < count) : (i += 1) {
        const j = Rng.intRangeLessThanFrom(source, usize, i, items.len);
        std.mem.swap(T, &items[i], &items[j]);
    }
    return items[0..count];
}

pub fn reservoirSample(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]T {
    return reservoirSampleFrom(allocator, rng, T, items, amount);
}

pub fn reservoirSampleFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]T {
    const count = @min(amount, items.len);
    const out = try allocator.alloc(T, count);
    if (count == 0) return out;

    @memcpy(out, items[0..count]);
    var i = count;
    while (i < items.len) : (i += 1) {
        const j = Rng.uintAtMostFrom(source, usize, i);
        if (j < count) out[j] = items[i];
    }
    return out;
}

fn sampleFloyd(allocator: std.mem.Allocator, source: anytype, length: usize, amount: usize) ![]usize {
    var indices = try std.ArrayList(usize).initCapacity(allocator, amount);
    errdefer indices.deinit(allocator);

    var j = length - amount;
    while (j < length) : (j += 1) {
        const t = Rng.uintAtMostFrom(source, usize, j);
        var found: ?usize = null;
        for (indices.items, 0..) |existing, pos| {
            if (existing == t) {
                found = pos;
                break;
            }
        }
        if (found) |pos| indices.items[pos] = j;
        try indices.append(allocator, t);
    }

    return indices.toOwnedSlice(allocator);
}

fn sampleInPlace(allocator: std.mem.Allocator, source: anytype, length: usize, amount: usize) ![]usize {
    var indices = try std.ArrayList(usize).initCapacity(allocator, length);
    errdefer indices.deinit(allocator);
    var i: usize = 0;
    while (i < length) : (i += 1) try indices.append(allocator, i);

    i = 0;
    while (i < amount) : (i += 1) {
        const j = Rng.intRangeLessThanFrom(source, usize, i, length);
        std.mem.swap(usize, &indices.items[i], &indices.items[j]);
    }
    indices.items.len = amount;
    return indices.toOwnedSlice(allocator);
}

fn sampleRejection(allocator: std.mem.Allocator, source: anytype, length: usize, amount: usize) ![]usize {
    var set = std.AutoHashMap(usize, void).init(allocator);
    defer set.deinit();
    try set.ensureTotalCapacity(@intCast(amount));

    const indices = try allocator.alloc(usize, amount);
    errdefer allocator.free(indices);

    var filled: usize = 0;
    while (filled < amount) {
        const index = Rng.uintLessThanFrom(source, usize, length);
        const entry = try set.getOrPut(index);
        if (!entry.found_existing) {
            indices[filled] = index;
            filled += 1;
        }
    }

    return indices;
}

fn sampleFloydU32(allocator: std.mem.Allocator, source: anytype, length: u32, amount: u32) ![]u32 {
    var indices = try std.ArrayList(u32).initCapacity(allocator, amount);
    errdefer indices.deinit(allocator);

    var j = length - amount;
    while (j < length) : (j += 1) {
        const t = Rng.uintAtMostFrom(source, u32, j);
        var found: ?usize = null;
        for (indices.items, 0..) |existing, pos| {
            if (existing == t) {
                found = pos;
                break;
            }
        }
        if (found) |pos| indices.items[pos] = j;
        try indices.append(allocator, t);
    }

    return indices.toOwnedSlice(allocator);
}

fn sampleFloydU32AsUsize(allocator: std.mem.Allocator, source: anytype, length: u32, amount: u32) ![]usize {
    var indices = try std.ArrayList(usize).initCapacity(allocator, amount);
    errdefer indices.deinit(allocator);

    var j = length - amount;
    while (j < length) : (j += 1) {
        const t = Rng.uintAtMostFrom(source, u32, j);
        const t_usize: usize = t;
        var found: ?usize = null;
        for (indices.items, 0..) |existing, pos| {
            if (existing == t_usize) {
                found = pos;
                break;
            }
        }
        if (found) |pos| indices.items[pos] = j;
        try indices.append(allocator, t_usize);
    }

    return indices.toOwnedSlice(allocator);
}

fn sampleInPlaceU32(allocator: std.mem.Allocator, source: anytype, length: u32, amount: u32) ![]u32 {
    var indices = try std.ArrayList(u32).initCapacity(allocator, length);
    errdefer indices.deinit(allocator);
    var i: u32 = 0;
    while (i < length) : (i += 1) try indices.append(allocator, i);

    i = 0;
    while (i < amount) : (i += 1) {
        const j = Rng.intRangeLessThanFrom(source, u32, i, length);
        std.mem.swap(u32, &indices.items[i], &indices.items[j]);
    }
    indices.items.len = amount;
    return indices.toOwnedSlice(allocator);
}

fn sampleInPlaceU32AsUsize(allocator: std.mem.Allocator, source: anytype, length: u32, amount: u32) ![]usize {
    var indices = try std.ArrayList(usize).initCapacity(allocator, length);
    errdefer indices.deinit(allocator);
    var i: u32 = 0;
    while (i < length) : (i += 1) try indices.append(allocator, i);

    i = 0;
    while (i < amount) : (i += 1) {
        const j = Rng.intRangeLessThanFrom(source, u32, i, length);
        std.mem.swap(usize, &indices.items[i], &indices.items[j]);
    }
    indices.items.len = amount;
    return indices.toOwnedSlice(allocator);
}

fn sampleRejectionU32(allocator: std.mem.Allocator, source: anytype, length: u32, amount: u32) ![]u32 {
    var set = try U32Set.init(allocator, amount);
    defer set.deinit(allocator);
    const indices = try allocator.alloc(u32, amount);
    errdefer allocator.free(indices);

    var filled: usize = 0;
    while (filled < amount) {
        const index = Rng.uintLessThanFrom(source, u32, length);
        if (set.insert(index)) {
            indices[filled] = index;
            filled += 1;
        }
    }

    return indices;
}

fn sampleRejectionU32AsUsize(allocator: std.mem.Allocator, source: anytype, length: u32, amount: u32) ![]usize {
    var set = try U32Set.init(allocator, amount);
    defer set.deinit(allocator);
    const indices = try allocator.alloc(usize, amount);
    errdefer allocator.free(indices);

    var filled: usize = 0;
    while (filled < amount) {
        const index = Rng.uintLessThanFrom(source, u32, length);
        if (set.insert(index)) {
            indices[filled] = index;
            filled += 1;
        }
    }

    return indices;
}

const WeightedCandidate = struct {
    index: usize,
    key: f64,
};

const WeightedCandidateQueue = std.PriorityQueue(WeightedCandidate, void, compareWeightedCandidate);

fn compareWeightedCandidate(_: void, a: WeightedCandidate, b: WeightedCandidate) std.math.Order {
    const key_order = std.math.order(a.key, b.key);
    if (key_order != .eq) return key_order;
    return std.math.order(a.index, b.index);
}

fn WeightedIteratorCandidate(comptime T: type) type {
    return struct {
        item: T,
        key: f64,
    };
}

fn WeightedIteratorQueue(comptime T: type) type {
    return std.PriorityQueue(WeightedIteratorCandidate(T), void, compareWeightedIteratorCandidate(T));
}

fn compareWeightedIteratorCandidate(comptime T: type) fn (void, WeightedIteratorCandidate(T), WeightedIteratorCandidate(T)) std.math.Order {
    return struct {
        fn compare(_: void, a: WeightedIteratorCandidate(T), b: WeightedIteratorCandidate(T)) std.math.Order {
            return std.math.order(a.key, b.key);
        }
    }.compare;
}

fn weightAsF64(comptime Weight: type, weight: Weight) f64 {
    return switch (@typeInfo(Weight)) {
        .int => @floatFromInt(weight),
        .float => @floatCast(weight),
        else => @compileError("weighted sampling weights must be numeric"),
    };
}

const U32Set = struct {
    keys: []u32,
    used: []u8,
    mask: usize,

    fn init(allocator: std.mem.Allocator, capacity_hint: u32) !U32Set {
        var capacity: usize = 1;
        const needed = @max(@as(usize, 8), @as(usize, capacity_hint) * 2);
        while (capacity < needed) capacity <<= 1;

        const keys = try allocator.alloc(u32, capacity);
        errdefer allocator.free(keys);
        const used = try allocator.alloc(u8, capacity);
        @memset(used, 0);
        return .{
            .keys = keys,
            .used = used,
            .mask = capacity - 1,
        };
    }

    fn deinit(self: *U32Set, allocator: std.mem.Allocator) void {
        allocator.free(self.keys);
        allocator.free(self.used);
        self.* = undefined;
    }

    fn insert(self: *U32Set, key: u32) bool {
        var slot = mix(key) & self.mask;
        while (self.used[slot] != 0) : (slot = (slot + 1) & self.mask) {
            if (self.keys[slot] == key) return false;
        }
        self.used[slot] = 1;
        self.keys[slot] = key;
        return true;
    }

    fn mix(key: u32) usize {
        var x = key;
        x ^= x >> 16;
        x *%= 0x7feb352d;
        x ^= x >> 15;
        x *%= 0x846ca68b;
        x ^= x >> 16;
        return x;
    }
};

test "sample indices are distinct and bounded" {
    const alea = @import("root.zig");
    var engine = alea.DefaultPrng.init(333);
    const rng = alea.Rng.init(&engine);

    const indices = try sampleIndices(std.testing.allocator, rng, 10_000, 64);
    defer std.testing.allocator.free(indices);

    var seen = std.AutoHashMap(usize, void).init(std.testing.allocator);
    defer seen.deinit();
    for (indices) |index| {
        try std.testing.expect(index < 10_000);
        const entry = try seen.getOrPut(index);
        try std.testing.expect(!entry.found_existing);
    }

    try std.testing.expectError(error.InvalidParameter, sampleIndices(std.testing.allocator, rng, 3, 4));

    const direct_fixed = sampleArrayFrom(&engine, 4, 32).?;
    for (direct_fixed) |index| try std.testing.expect(index < 32);
}

test "index vec keeps compact backing for u32 lengths" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(334);
    const rng = alea.Rng.init(&engine);

    const indices = try sampleIndexVec(std.testing.allocator, rng, 10_000, 64);
    defer indices.deinit(std.testing.allocator);

    try std.testing.expectEqual(@as(usize, 64), indices.len());
    switch (indices) {
        .u32 => {},
        .usize => return error.ExpectedU32Backing,
    }
    var i: usize = 0;
    while (i < indices.len()) : (i += 1) try std.testing.expect(indices.at(i) < 10_000);
}

test "partial shuffle and reservoir sample respect counts" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(444);
    const rng = alea.Rng.init(&engine);

    var values = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7 };
    const head = partialShuffle(rng, u8, &values, 3);
    try std.testing.expectEqual(@as(usize, 3), head.len);

    var direct_values = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7 };
    const direct_head = partialShuffleFrom(&engine, u8, &direct_values, 3);
    try std.testing.expectEqual(@as(usize, 3), direct_head.len);

    const sampled = try reservoirSample(std.testing.allocator, rng, u8, &values, 4);
    defer std.testing.allocator.free(sampled);
    try std.testing.expectEqual(@as(usize, 4), sampled.len);

    const direct_sampled = try reservoirSampleFrom(std.testing.allocator, &engine, u8, &values, 4);
    defer std.testing.allocator.free(direct_sampled);
    try std.testing.expectEqual(@as(usize, 4), direct_sampled.len);

    const direct_multiple = try chooseMultipleFrom(std.testing.allocator, &engine, u8, &values, 3);
    defer std.testing.allocator.free(direct_multiple);
    try std.testing.expectEqual(@as(usize, 3), direct_multiple.len);
}

test "choice sampler repeatedly samples slice references" {
    const alea = @import("root.zig");
    var engine = alea.DefaultPrng.init(445);
    const rng = alea.Rng.init(&engine);

    const values = [_]u8{ 2, 4, 6, 8 };
    const choice = Choice(u8).init(&values).?;
    try std.testing.expectEqual(@as(usize, 4), choice.len());
    try std.testing.expect(Choice(u8).init(&.{}) == null);

    var iter = choice.iter(rng);
    var i: usize = 0;
    while (i < 32) : (i += 1) {
        const item = iter.next().?;
        try std.testing.expect(item == &values[0] or item == &values[1] or item == &values[2] or item == &values[3]);
    }

    var direct_iter = choice.iterFrom(&engine);
    const direct_iter_item = direct_iter.next().?;
    try std.testing.expect(direct_iter_item == &values[0] or direct_iter_item == &values[1] or direct_iter_item == &values[2] or direct_iter_item == &values[3]);

    var convenience_iter = chooseIter(rng, u8, &values).?;
    const picked = convenience_iter.next().?.*;
    try std.testing.expect(picked == 2 or picked == 4 or picked == 6 or picked == 8);
    var pointer_buf: [8]*const u8 = undefined;
    choice.fill(rng, &pointer_buf);
    for (pointer_buf) |item| try std.testing.expect(item == &values[0] or item == &values[1] or item == &values[2] or item == &values[3]);
    choice.fillFrom(&engine, &pointer_buf);
    for (pointer_buf) |item| try std.testing.expect(item == &values[0] or item == &values[1] or item == &values[2] or item == &values[3]);
    var value_buf: [8]u8 = undefined;
    choice.fillValues(rng, &value_buf);
    for (value_buf) |value| try std.testing.expect(value == 2 or value == 4 or value == 6 or value == 8);
    choice.fillValuesFrom(&engine, &value_buf);
    for (value_buf) |value| try std.testing.expect(value == 2 or value == 4 or value == 6 or value == 8);
    try std.testing.expect(chooseIter(rng, u8, &.{}) == null);
}

test "weighted choice sampler maps alias indexes to items" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(446);
    const rng = alea.Rng.init(&engine);

    const labels = [_][]const u8{ "never", "rare", "often" };
    var choice = try WeightedChoice([]const u8, u32).init(std.testing.allocator, &labels, &.{ 0, 1, 7 });
    defer choice.deinit();

    try std.testing.expectEqual(@as(usize, 3), choice.len());

    var i: usize = 0;
    var saw_often = false;
    while (i < 64) : (i += 1) {
        const item = choice.sample(rng);
        try std.testing.expect(!std.mem.eql(u8, item.*, "never"));
        saw_often = saw_often or std.mem.eql(u8, item.*, "often");
    }
    try std.testing.expect(saw_often);
    const direct_item = choice.sampleFrom(&engine);
    try std.testing.expect(!std.mem.eql(u8, direct_item.*, "never"));
    const direct_value = choice.sampleValueFrom(&engine);
    try std.testing.expect(!std.mem.eql(u8, direct_value, "never"));
    var pointer_buf: [8]*const []const u8 = undefined;
    choice.fillFrom(&engine, &pointer_buf);
    for (pointer_buf) |item| try std.testing.expect(!std.mem.eql(u8, item.*, "never"));
    var value_buf: [8][]const u8 = undefined;
    choice.fillValuesFrom(&engine, &value_buf);
    for (value_buf) |value| try std.testing.expect(!std.mem.eql(u8, value, "never"));

    var iter = choice.iter(rng);
    const picked = iter.next().?.*;
    try std.testing.expect(std.mem.eql(u8, picked, "rare") or std.mem.eql(u8, picked, "often"));

    var direct_iter = choice.iterFrom(&engine);
    const direct_picked = direct_iter.next().?.*;
    try std.testing.expect(std.mem.eql(u8, direct_picked, "rare") or std.mem.eql(u8, direct_picked, "often"));

    try std.testing.expectError(error.EmptyInput, WeightedChoice(u8, u32).init(std.testing.allocator, &.{}, &.{}));
    try std.testing.expectError(error.LengthMismatch, WeightedChoice(u8, u32).init(std.testing.allocator, &.{1}, &.{ 1, 2 }));
}

test "weighted sampling without replacement returns distinct positive-weight items" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(447);
    const rng = alea.Rng.init(&engine);

    const weights = [_]f64{ 0, 1, 5, 0, 9 };
    const indices = try sampleWeightedIndices(std.testing.allocator, rng, f64, &weights, 4);
    defer std.testing.allocator.free(indices);

    try std.testing.expectEqual(@as(usize, 3), indices.len);
    var seen = [_]bool{false} ** weights.len;
    for (indices) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
        try std.testing.expect(!seen[index]);
        seen[index] = true;
    }

    const items = [_]u8{ 10, 20, 30, 40, 50 };
    const sample = try sampleWeighted(std.testing.allocator, rng, u8, f64, &items, &weights, 2);
    defer std.testing.allocator.free(sample);
    try std.testing.expectEqual(@as(usize, 2), sample.len);
    try std.testing.expect(sample[0] != sample[1]);
    for (sample) |item| try std.testing.expect(item == 20 or item == 30 or item == 50);

    const direct_indices = try sampleWeightedIndicesFrom(std.testing.allocator, &engine, f64, &weights, 4);
    defer std.testing.allocator.free(direct_indices);
    try std.testing.expectEqual(@as(usize, 3), direct_indices.len);
    for (direct_indices) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

    const direct_sample = try sampleWeightedFrom(std.testing.allocator, &engine, u8, f64, &items, &weights, 2);
    defer std.testing.allocator.free(direct_sample);
    try std.testing.expectEqual(@as(usize, 2), direct_sample.len);
    for (direct_sample) |item| try std.testing.expect(item == 20 or item == 30 or item == 50);

    try std.testing.expectError(error.EmptyInput, sampleWeightedIndices(std.testing.allocator, rng, u32, &.{}, 1));
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesFrom(std.testing.allocator, &engine, u32, &.{}, 1));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndices(std.testing.allocator, rng, f64, &.{ 1.0, std.math.nan(f64) }, 1));
    try std.testing.expectError(error.LengthMismatch, sampleWeighted(std.testing.allocator, rng, u8, u32, &.{ 1, 2 }, &.{1}, 1));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedFrom(std.testing.allocator, &engine, u8, u32, &.{ 1, 2 }, &.{1}, 1));
}

test "iterator sampling works without collecting first" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(448);
    const rng = alea.Rng.init(&engine);

    const RangeIter = struct {
        next_value: u32,
        end: u32,

        fn next(self: *@This()) ?u32 {
            if (self.next_value >= self.end) return null;
            const value = self.next_value;
            self.next_value += 1;
            return value;
        }
    };

    var choose_iter = RangeIter{ .next_value = 0, .end = 100 };
    const chosen = chooseIterator(rng, u32, &choose_iter).?;
    try std.testing.expect(chosen < 100);
    var direct_choose_iter = RangeIter{ .next_value = 0, .end = 100 };
    const direct_chosen = chooseIteratorFrom(&engine, u32, &direct_choose_iter).?;
    try std.testing.expect(direct_chosen < 100);

    var sample_iter = RangeIter{ .next_value = 0, .end = 100 };
    const sample = try sampleIterator(std.testing.allocator, rng, u32, &sample_iter, 8);
    defer std.testing.allocator.free(sample);
    try std.testing.expectEqual(@as(usize, 8), sample.len);
    for (sample) |item| try std.testing.expect(item < 100);
    var direct_sample_iter = RangeIter{ .next_value = 0, .end = 100 };
    const direct_sample = try sampleIteratorFrom(std.testing.allocator, &engine, u32, &direct_sample_iter, 8);
    defer std.testing.allocator.free(direct_sample);
    try std.testing.expectEqual(@as(usize, 8), direct_sample.len);
    for (direct_sample) |item| try std.testing.expect(item < 100);

    var short_iter = RangeIter{ .next_value = 0, .end = 3 };
    const short = try sampleIterator(std.testing.allocator, rng, u32, &short_iter, 8);
    defer std.testing.allocator.free(short);
    try std.testing.expectEqual(@as(usize, 3), short.len);
}

test "weighted iterator choice works without collecting first" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(449);
    const rng = alea.Rng.init(&engine);

    const Entry = struct {
        item: u8,
        weight: f64,
    };
    const WeightedIter = struct {
        items: []const Entry,
        index: usize = 0,

        fn next(self: *@This()) ?Entry {
            if (self.index >= self.items.len) return null;
            const item = self.items[self.index];
            self.index += 1;
            return item;
        }
    };

    const entries = [_]Entry{
        .{ .item = 1, .weight = 0 },
        .{ .item = 2, .weight = 1 },
        .{ .item = 3, .weight = 5 },
    };
    var iter = WeightedIter{ .items = &entries };
    const picked = (try chooseIteratorWeighted(rng, u8, &iter)).?;
    try std.testing.expect(picked == 2 or picked == 3);
    var direct_iter = WeightedIter{ .items = &entries };
    const direct_picked = (try chooseIteratorWeightedFrom(&engine, u8, &direct_iter)).?;
    try std.testing.expect(direct_picked == 2 or direct_picked == 3);

    var empty_iter = WeightedIter{ .items = &.{} };
    try std.testing.expect((try chooseIteratorWeighted(rng, u8, &empty_iter)) == null);

    const bad_entries = [_]Entry{.{ .item = 1, .weight = std.math.nan(f64) }};
    var bad_iter = WeightedIter{ .items = &bad_entries };
    try std.testing.expectError(error.InvalidWeight, chooseIteratorWeighted(rng, u8, &bad_iter));

    var sample_iter = WeightedIter{ .items = &entries };
    const sample = try sampleIteratorWeighted(std.testing.allocator, rng, u8, &sample_iter, 2);
    defer std.testing.allocator.free(sample);
    try std.testing.expectEqual(@as(usize, 2), sample.len);
    for (sample) |item| try std.testing.expect(item == 2 or item == 3);
    var direct_sample_iter = WeightedIter{ .items = &entries };
    const direct_sample = try sampleIteratorWeightedFrom(std.testing.allocator, &engine, u8, &direct_sample_iter, 2);
    defer std.testing.allocator.free(direct_sample);
    try std.testing.expectEqual(@as(usize, 2), direct_sample.len);
    for (direct_sample) |item| try std.testing.expect(item == 2 or item == 3);
}
