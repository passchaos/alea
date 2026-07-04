const std = @import("std");
const Rng = @import("rng.zig");
const distributions = @import("distributions.zig");

pub const IndexVec = union(enum) {
    u32: []u32,
    usize: []usize,

    pub const Iterator = struct {
        index_vec: IndexVec,
        index: usize = 0,

        pub fn next(self: *Iterator) ?usize {
            if (self.index >= self.index_vec.len()) return null;
            const value = self.index_vec.at(self.index);
            self.index += 1;
            return value;
        }

        pub fn remaining(self: Iterator) usize {
            return self.index_vec.len() - self.index;
        }
    };

    pub fn len(self: IndexVec) usize {
        return switch (self) {
            .u32 => |items| items.len,
            .usize => |items| items.len,
        };
    }

    pub fn isEmpty(self: IndexVec) bool {
        return self.len() == 0;
    }

    pub fn at(self: IndexVec, index: usize) usize {
        return switch (self) {
            .u32 => |items| items[index],
            .usize => |items| items[index],
        };
    }

    pub fn indexOf(self: IndexVec, value: usize) ?usize {
        var index: usize = 0;
        while (index < self.len()) : (index += 1) {
            if (self.at(index) == value) return index;
        }
        return null;
    }

    pub fn contains(self: IndexVec, value: usize) bool {
        return self.indexOf(value) != null;
    }

    pub fn copyInto(self: IndexVec, out: []usize) Error!void {
        if (out.len != self.len()) return error.LengthMismatch;
        switch (self) {
            .u32 => |items| {
                for (items, out) |item, *slot| slot.* = item;
            },
            .usize => |items| @memcpy(out, items),
        }
    }

    pub fn toOwnedSlice(self: IndexVec, allocator: std.mem.Allocator) ![]usize {
        const out = try allocator.alloc(usize, self.len());
        errdefer allocator.free(out);
        try self.copyInto(out);
        return out;
    }

    pub fn iter(self: IndexVec) Iterator {
        return .{ .index_vec = self };
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
    EmptyInput,
    LengthMismatch,
    InvalidWeight,
};

pub fn sampleIndexVec(allocator: std.mem.Allocator, rng: Rng, length: usize, amount: usize) !IndexVec {
    return sampleIndexVecCheckedFrom(allocator, rng, length, amount);
}

pub fn sampleIndexVecCheckedFrom(allocator: std.mem.Allocator, source: anytype, length: usize, amount: usize) !IndexVec {
    if (amount > length) return error.InvalidParameter;
    return sampleIndexVecFrom(allocator, source, length, amount);
}

pub fn sampleIndexVecFrom(allocator: std.mem.Allocator, source: anytype, length: usize, amount: usize) !IndexVec {
    std.debug.assert(amount <= length);
    if (length <= std.math.maxInt(u32)) {
        return .{ .u32 = try sampleIndicesU32From(allocator, source, @intCast(length), @intCast(amount)) };
    }
    return .{ .usize = try sampleIndicesLarge(allocator, source, length, amount) };
}

pub fn sampleIndices(allocator: std.mem.Allocator, rng: Rng, length: usize, amount: usize) ![]usize {
    return sampleIndicesCheckedFrom(allocator, rng, length, amount);
}

pub fn sampleIndicesCheckedFrom(allocator: std.mem.Allocator, source: anytype, length: usize, amount: usize) ![]usize {
    if (amount > length) return error.InvalidParameter;
    return sampleIndicesFrom(allocator, source, length, amount);
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

pub fn sampleIndicesInto(rng: Rng, length: usize, out: []usize) Error!void {
    return sampleIndicesIntoCheckedFrom(rng, length, out);
}

pub fn sampleIndicesIntoChecked(rng: Rng, length: usize, out: []usize) Error!void {
    return sampleIndicesIntoCheckedFrom(rng, length, out);
}

pub fn sampleIndicesIntoCheckedFrom(source: anytype, length: usize, out: []usize) Error!void {
    if (out.len > length) return error.InvalidParameter;
    sampleIndicesIntoFrom(source, length, out);
}

pub fn sampleIndicesIntoFrom(source: anytype, length: usize, out: []usize) void {
    std.debug.assert(out.len <= length);
    if (out.len == 0) return;

    var i: usize = 0;
    var j = length - out.len;
    while (j < length) : ({
        j += 1;
        i += 1;
    }) {
        const t = Rng.uintAtMostFrom(source, usize, j);
        var found: ?usize = null;
        for (out[0..i], 0..) |existing, pos| {
            if (existing == t) {
                found = pos;
                break;
            }
        }
        if (found) |pos| out[pos] = j;
        out[i] = t;
    }
}

pub fn sampleIndicesU32(allocator: std.mem.Allocator, rng: Rng, length: u32, amount: u32) ![]u32 {
    return sampleIndicesU32CheckedFrom(allocator, rng, length, amount);
}

pub fn sampleIndicesU32CheckedFrom(allocator: std.mem.Allocator, source: anytype, length: u32, amount: u32) ![]u32 {
    if (amount > length) return error.InvalidParameter;
    return sampleIndicesU32From(allocator, source, length, amount);
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

pub fn sampleIndicesU32Into(rng: Rng, length: u32, out: []u32) Error!void {
    return sampleIndicesU32IntoCheckedFrom(rng, length, out);
}

pub fn sampleIndicesU32IntoChecked(rng: Rng, length: u32, out: []u32) Error!void {
    return sampleIndicesU32IntoCheckedFrom(rng, length, out);
}

pub fn sampleIndicesU32IntoCheckedFrom(source: anytype, length: u32, out: []u32) Error!void {
    if (out.len > @as(usize, length)) return error.InvalidParameter;
    sampleIndicesU32IntoFrom(source, length, out);
}

pub fn sampleIndicesU32IntoFrom(source: anytype, length: u32, out: []u32) void {
    std.debug.assert(out.len <= @as(usize, length));
    if (out.len == 0) return;

    var i: usize = 0;
    var j: u32 = length - @as(u32, @intCast(out.len));
    while (j < length) : ({
        j += 1;
        i += 1;
    }) {
        const t = Rng.uintAtMostFrom(source, u32, j);
        var found: ?usize = null;
        for (out[0..i], 0..) |existing, pos| {
            if (existing == t) {
                found = pos;
                break;
            }
        }
        if (found) |pos| out[pos] = j;
        out[i] = t;
    }
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

pub fn sampleArrayChecked(rng: Rng, comptime N: usize, length: usize) Error![N]usize {
    return sampleArrayCheckedFrom(rng, N, length);
}

pub fn sampleArrayCheckedFrom(source: anytype, comptime N: usize, length: usize) Error![N]usize {
    if (N > length) return error.InvalidParameter;
    return sampleArrayFrom(source, N, length).?;
}

pub fn sampleArrayFrom(source: anytype, comptime N: usize, length: usize) ?[N]usize {
    if (N > length) return null;
    var indices: [N]usize = undefined;
    if (comptime N == 0) return indices;

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

pub fn chooseMultipleChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]T {
    return chooseMultipleCheckedFrom(allocator, rng, T, items, amount);
}

pub fn chooseMultipleCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]T {
    if (amount > items.len) return error.InvalidParameter;
    return chooseMultipleFrom(allocator, source, T, items, amount);
}

pub fn chooseMultipleFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]T {
    const count = @min(amount, items.len);
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);

    const indices = try sampleIndicesFrom(allocator, source, items.len, count);
    defer allocator.free(indices);

    for (indices, out) |index, *slot| slot.* = items[index];
    return out;
}

pub fn chooseMultipleInto(rng: Rng, comptime T: type, items: []const T, out: []T, scratch_indices: []usize) Error!usize {
    return chooseMultipleIntoFrom(rng, T, items, out, scratch_indices);
}

pub fn chooseMultipleIntoFrom(source: anytype, comptime T: type, items: []const T, out: []T, scratch_indices: []usize) Error!usize {
    const count = @min(out.len, items.len);
    if (count == 0) return 0;
    if (scratch_indices.len < count) return error.LengthMismatch;
    try sampleIndicesIntoCheckedFrom(source, items.len, scratch_indices[0..count]);
    for (scratch_indices[0..count], out[0..count]) |index, *slot| slot.* = items[index];
    return count;
}

pub fn chooseMultipleIntoChecked(rng: Rng, comptime T: type, items: []const T, out: []T, scratch_indices: []usize) Error!void {
    return chooseMultipleIntoCheckedFrom(rng, T, items, out, scratch_indices);
}

pub fn chooseMultipleIntoCheckedFrom(source: anytype, comptime T: type, items: []const T, out: []T, scratch_indices: []usize) Error!void {
    if (out.len > items.len) return error.InvalidParameter;
    if (out.len == 0) return;
    if (scratch_indices.len < out.len) return error.LengthMismatch;
    try sampleIndicesIntoCheckedFrom(source, items.len, scratch_indices[0..out.len]);
    for (scratch_indices[0..out.len], out) |index, *slot| slot.* = items[index];
}

pub fn chooseArray(rng: Rng, comptime T: type, comptime N: usize, items: []const T) ?[N]T {
    return chooseArrayFrom(rng, T, N, items);
}

pub fn chooseArrayChecked(rng: Rng, comptime T: type, comptime N: usize, items: []const T) Error![N]T {
    return chooseArrayCheckedFrom(rng, T, N, items);
}

pub fn chooseArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T) Error![N]T {
    if (N > items.len) return error.InvalidParameter;
    return chooseArrayFrom(source, T, N, items).?;
}

pub fn chooseArrayFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T) ?[N]T {
    const indices = sampleArrayFrom(source, N, items.len) orelse return null;
    var out: [N]T = undefined;
    inline for (0..N) |i| out[i] = items[indices[i]];
    return out;
}

pub fn chooseWeighted(rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight) !?T {
    return chooseWeightedFrom(rng, T, Weight, items, weights);
}

pub fn chooseWeightedChecked(rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight) !T {
    return chooseWeightedCheckedFrom(rng, T, Weight, items, weights);
}

pub fn chooseWeightedCheckedFrom(source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight) !T {
    return (try chooseWeightedFrom(source, T, Weight, items, weights)) orelse error.EmptyInput;
}

pub fn chooseWeightedFrom(source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight) !?T {
    if (items.len != weights.len) return error.LengthMismatch;
    const index = (try weightedIndexGenericFrom(source, Weight, weights)) orelse return null;
    return items[index];
}

pub fn chooseWeightedPtr(rng: Rng, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight) !?*T {
    return chooseWeightedPtrFrom(rng, T, Weight, items, weights);
}

pub fn chooseWeightedPtrChecked(rng: Rng, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight) !*T {
    return chooseWeightedPtrCheckedFrom(rng, T, Weight, items, weights);
}

pub fn chooseWeightedPtrCheckedFrom(source: anytype, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight) !*T {
    return (try chooseWeightedPtrFrom(source, T, Weight, items, weights)) orelse error.EmptyInput;
}

pub fn chooseWeightedPtrFrom(source: anytype, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight) !?*T {
    if (items.len != weights.len) return error.LengthMismatch;
    const index = (try weightedIndexGenericFrom(source, Weight, weights)) orelse return null;
    return &items[index];
}

pub fn chooseIterator(rng: Rng, comptime T: type, iterator: anytype) ?T {
    return chooseIteratorFrom(rng, T, iterator);
}

pub fn chooseIteratorChecked(rng: Rng, comptime T: type, iterator: anytype) Error!T {
    return chooseIteratorCheckedFrom(rng, T, iterator);
}

pub fn chooseIteratorCheckedFrom(source: anytype, comptime T: type, iterator: anytype) Error!T {
    return chooseIteratorFrom(source, T, iterator) orelse error.EmptyInput;
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

pub fn sampleIteratorChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, iterator: anytype, amount: usize) ![]T {
    return sampleIteratorCheckedFrom(allocator, rng, T, iterator, amount);
}

pub fn sampleIteratorCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, iterator: anytype, amount: usize) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);

    const out = try allocator.alloc(T, amount);
    errdefer allocator.free(out);

    var filled: usize = 0;
    while (filled < amount) : (filled += 1) {
        out[filled] = iterator.next() orelse return error.InvalidParameter;
    }

    var seen = amount;
    while (iterator.next()) |item| {
        seen += 1;
        const index = Rng.uintLessThanFrom(source, usize, seen);
        if (index < amount) out[index] = item;
    }

    return out;
}

pub fn sampleIteratorFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, iterator: anytype, amount: usize) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);

    var reservoir = try std.ArrayList(T).initCapacity(allocator, amount);
    errdefer reservoir.deinit(allocator);

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

    return reservoir.toOwnedSliceAssert();
}

pub fn sampleIteratorArray(rng: Rng, comptime T: type, comptime N: usize, iterator: anytype) ?[N]T {
    return sampleIteratorArrayFrom(rng, T, N, iterator);
}

pub fn sampleIteratorArrayFrom(source: anytype, comptime T: type, comptime N: usize, iterator: anytype) ?[N]T {
    var out: [N]T = undefined;
    if (comptime N == 0) return out;

    var filled: usize = 0;
    while (filled < N) : (filled += 1) {
        out[filled] = iterator.next() orelse return null;
    }

    var seen = N;
    while (iterator.next()) |item| {
        seen += 1;
        const index = Rng.uintLessThanFrom(source, usize, seen);
        if (index < N) out[index] = item;
    }

    return out;
}

pub fn sampleIteratorArrayChecked(rng: Rng, comptime T: type, comptime N: usize, iterator: anytype) Error![N]T {
    return sampleIteratorArrayCheckedFrom(rng, T, N, iterator);
}

pub fn sampleIteratorArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, iterator: anytype) Error![N]T {
    return sampleIteratorArrayFrom(source, T, N, iterator) orelse error.InvalidParameter;
}

pub fn sampleIteratorInto(rng: Rng, comptime T: type, iterator: anytype, out: []T) usize {
    return sampleIteratorIntoFrom(rng, T, iterator, out);
}

pub fn sampleIteratorIntoFrom(source: anytype, comptime T: type, iterator: anytype, out: []T) usize {
    if (out.len == 0) return 0;

    var filled: usize = 0;
    while (filled < out.len) : (filled += 1) {
        out[filled] = iterator.next() orelse return filled;
    }

    var seen = out.len;
    while (iterator.next()) |item| {
        seen += 1;
        const index = Rng.uintLessThanFrom(source, usize, seen);
        if (index < out.len) out[index] = item;
    }

    return out.len;
}

pub fn sampleIteratorIntoChecked(rng: Rng, comptime T: type, iterator: anytype, out: []T) Error!void {
    return sampleIteratorIntoCheckedFrom(rng, T, iterator, out);
}

pub fn sampleIteratorIntoCheckedFrom(source: anytype, comptime T: type, iterator: anytype, out: []T) Error!void {
    if (out.len == 0) return;

    var filled: usize = 0;
    while (filled < out.len) : (filled += 1) {
        out[filled] = iterator.next() orelse return error.InvalidParameter;
    }

    var seen = out.len;
    while (iterator.next()) |item| {
        seen += 1;
        const index = Rng.uintLessThanFrom(source, usize, seen);
        if (index < out.len) out[index] = item;
    }
}

pub fn chooseIteratorWeighted(rng: Rng, comptime T: type, iterator: anytype) !?T {
    return chooseIteratorWeightedFrom(rng, T, iterator);
}

pub fn chooseIteratorWeightedChecked(rng: Rng, comptime T: type, iterator: anytype) !T {
    return chooseIteratorWeightedCheckedFrom(rng, T, iterator);
}

pub fn chooseIteratorWeightedCheckedFrom(source: anytype, comptime T: type, iterator: anytype) !T {
    return (try chooseIteratorWeightedFrom(source, T, iterator)) orelse error.EmptyInput;
}

pub fn chooseIteratorWeightedFrom(source: anytype, comptime T: type, iterator: anytype) !?T {
    const Pending = struct {
        item: T,
        weight: f64,
    };
    var total: f64 = 0;
    var result: ?T = null;
    var pending: ?Pending = null;

    while (iterator.next()) |entry| {
        const weight = weightAsF64(@TypeOf(entry.weight), entry.weight);
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight == 0) continue;

        if (pending == null and result == null) {
            pending = .{ .item = entry.item, .weight = weight };
            total = weight;
            continue;
        }

        if (pending) |first| {
            _ = Rng.floatFrom(source, f64);
            result = first.item;
            pending = null;
        }

        total += weight;
        if (!std.math.isFinite(total)) return error.InvalidWeight;
        if (Rng.floatFrom(source, f64) * total < weight) {
            result = entry.item;
        }
    }

    if (pending) |only| return only.item;
    return result;
}

pub fn sampleIteratorWeighted(allocator: std.mem.Allocator, rng: Rng, comptime T: type, iterator: anytype, amount: usize) ![]T {
    return sampleIteratorWeightedFrom(allocator, rng, T, iterator, amount);
}

pub fn sampleIteratorWeightedChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, iterator: anytype, amount: usize) ![]T {
    return sampleIteratorWeightedCheckedFrom(allocator, rng, T, iterator, amount);
}

pub fn sampleIteratorWeightedCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, iterator: anytype, amount: usize) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);
    const Pending = struct {
        item: T,
        weight: f64,
    };

    const out = try allocator.alloc(T, amount);
    errdefer allocator.free(out);

    var heap = WeightedIteratorQueue(T).initContext({});
    defer heap.deinit(allocator);
    try heap.ensureTotalCapacityPrecise(allocator, amount);
    var pending: ?Pending = null;

    while (iterator.next()) |entry| {
        const weight = weightAsF64(@TypeOf(entry.weight), entry.weight);
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight == 0) continue;

        if (pending == null and heap.count() == 0) {
            pending = .{ .item = entry.item, .weight = weight };
            continue;
        }

        if (pending) |first| {
            try heap.push(allocator, .{
                .item = first.item,
                .key = weightedSelectionKeyFrom(source, first.weight),
            });
            pending = null;
        }

        const candidate = WeightedIteratorCandidate(T){
            .item = entry.item,
            .key = weightedSelectionKeyFrom(source, weight),
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

    if (pending) |only| {
        if (amount != 1) return error.InvalidParameter;
        out[0] = only.item;
        return out;
    }

    if (heap.count() != amount) return error.InvalidParameter;
    var i: usize = 0;
    while (heap.pop()) |candidate| : (i += 1) {
        out[i] = candidate.item;
    }
    return out;
}

pub fn sampleIteratorWeightedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, iterator: anytype, amount: usize) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);
    const Pending = struct {
        item: T,
        weight: f64,
    };

    var heap = WeightedIteratorQueue(T).initContext({});
    defer heap.deinit(allocator);
    try heap.ensureTotalCapacityPrecise(allocator, amount);
    var pending: ?Pending = null;

    while (iterator.next()) |entry| {
        const weight = weightAsF64(@TypeOf(entry.weight), entry.weight);
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight == 0) continue;

        if (pending == null and heap.count() == 0) {
            pending = .{ .item = entry.item, .weight = weight };
            continue;
        }

        if (pending) |first| {
            try heap.push(allocator, .{
                .item = first.item,
                .key = weightedSelectionKeyFrom(source, first.weight),
            });
            pending = null;
        }

        const candidate = WeightedIteratorCandidate(T){
            .item = entry.item,
            .key = weightedSelectionKeyFrom(source, weight),
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

    if (pending) |only| {
        const out = try allocator.alloc(T, 1);
        out[0] = only.item;
        return out;
    }

    const out = try allocator.alloc(T, heap.count());
    errdefer allocator.free(out);
    var i: usize = 0;
    while (heap.pop()) |candidate| : (i += 1) {
        out[i] = candidate.item;
    }
    return out;
}

pub fn sampleIteratorWeightedInto(rng: Rng, comptime T: type, iterator: anytype, out: []T, scratch_keys: []f64) !usize {
    return sampleIteratorWeightedIntoFrom(rng, T, iterator, out, scratch_keys);
}

pub fn sampleIteratorWeightedIntoFrom(source: anytype, comptime T: type, iterator: anytype, out: []T, scratch_keys: []f64) !usize {
    if (out.len == 0) return 0;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    return sampleIteratorWeightedIntoCore(source, T, iterator, out, scratch_keys[0..out.len]);
}

pub fn sampleIteratorWeightedIntoChecked(rng: Rng, comptime T: type, iterator: anytype, out: []T, scratch_keys: []f64) !void {
    return sampleIteratorWeightedIntoCheckedFrom(rng, T, iterator, out, scratch_keys);
}

pub fn sampleIteratorWeightedIntoCheckedFrom(source: anytype, comptime T: type, iterator: anytype, out: []T, scratch_keys: []f64) !void {
    if (out.len == 0) return;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    const count = try sampleIteratorWeightedIntoCore(source, T, iterator, out, scratch_keys[0..out.len]);
    if (count != out.len) return error.InvalidParameter;
}

fn sampleIteratorWeightedIntoCore(source: anytype, comptime T: type, iterator: anytype, out: []T, keys: []f64) !usize {
    std.debug.assert(out.len > 0);
    std.debug.assert(keys.len == out.len);
    const Pending = struct {
        item: T,
        weight: f64,
    };

    var count: usize = 0;
    var pending: ?Pending = null;

    while (iterator.next()) |entry| {
        const weight = weightAsF64(@TypeOf(entry.weight), entry.weight);
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight == 0) continue;

        if (pending == null and count == 0) {
            pending = .{ .item = entry.item, .weight = weight };
            continue;
        }

        if (pending) |first| {
            out[0] = first.item;
            keys[0] = weightedSelectionKeyFrom(source, first.weight);
            count = 1;
            pending = null;
        }

        const key = weightedSelectionKeyFrom(source, weight);
        if (count < out.len) {
            out[count] = entry.item;
            keys[count] = key;
            count += 1;
        } else {
            const min_index = minWeightedKeyIndex(keys);
            if (key > keys[min_index]) {
                out[min_index] = entry.item;
                keys[min_index] = key;
            }
        }
    }

    if (pending) |only| {
        out[0] = only.item;
        return 1;
    }
    sortWeightedItemKeyPairs(T, out[0..count], keys[0..count]);
    return count;
}

pub fn sampleIteratorWeightedArray(rng: Rng, comptime T: type, comptime N: usize, iterator: anytype) !?[N]T {
    return sampleIteratorWeightedArrayFrom(rng, T, N, iterator);
}

pub fn sampleIteratorWeightedArrayFrom(source: anytype, comptime T: type, comptime N: usize, iterator: anytype) !?[N]T {
    const candidates = (try sampleIteratorWeightedCandidateArrayFrom(source, T, N, iterator)) orelse return null;
    var out: [N]T = undefined;
    inline for (0..N) |i| out[i] = candidates[i].item;
    return out;
}

pub fn sampleIteratorWeightedArrayChecked(rng: Rng, comptime T: type, comptime N: usize, iterator: anytype) ![N]T {
    return sampleIteratorWeightedArrayCheckedFrom(rng, T, N, iterator);
}

pub fn sampleIteratorWeightedArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, iterator: anytype) ![N]T {
    const candidates = (try sampleIteratorWeightedCandidateArrayFrom(source, T, N, iterator)) orelse return error.InvalidParameter;
    var out: [N]T = undefined;
    inline for (0..N) |i| out[i] = candidates[i].item;
    return out;
}

fn sampleIteratorWeightedCandidateArrayFrom(source: anytype, comptime T: type, comptime N: usize, iterator: anytype) !?[N]WeightedIteratorCandidate(T) {
    if (comptime N == 0) return .{};
    const Pending = struct {
        item: T,
        weight: f64,
    };

    var candidates: [N]WeightedIteratorCandidate(T) = undefined;
    var count: usize = 0;
    var pending: ?Pending = null;

    while (iterator.next()) |entry| {
        const weight = weightAsF64(@TypeOf(entry.weight), entry.weight);
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight == 0) continue;

        if (pending == null and count == 0) {
            pending = .{ .item = entry.item, .weight = weight };
            continue;
        }

        if (pending) |first| {
            candidates[0] = .{
                .item = first.item,
                .key = weightedSelectionKeyFrom(source, first.weight),
            };
            count = 1;
            pending = null;
        }

        const candidate = WeightedIteratorCandidate(T){
            .item = entry.item,
            .key = weightedSelectionKeyFrom(source, weight),
        };
        if (count < N) {
            candidates[count] = candidate;
            count += 1;
        } else {
            const min_index = minWeightedIteratorCandidateIndex(T, candidates[0..]);
            if (compareWeightedIteratorCandidate(T)({}, candidate, candidates[min_index]) == .gt) {
                candidates[min_index] = candidate;
            }
        }
    }

    if (pending) |only| {
        if (comptime N == 1) {
            return .{.{ .item = only.item, .key = 0 }};
        }
        return null;
    }
    if (count < N) return null;
    sortWeightedIteratorCandidates(T, candidates[0..]);
    return candidates;
}

pub fn sampleWeightedIndices(allocator: std.mem.Allocator, rng: Rng, comptime Weight: type, weights: []const Weight, amount: usize) ![]usize {
    return sampleWeightedIndicesFrom(allocator, rng, Weight, weights, amount);
}

pub fn sampleWeightedIndicesChecked(allocator: std.mem.Allocator, rng: Rng, comptime Weight: type, weights: []const Weight, amount: usize) ![]usize {
    return sampleWeightedIndicesCheckedFrom(allocator, rng, Weight, weights, amount);
}

pub fn sampleWeightedIndicesCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, weights: []const Weight, amount: usize) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (amount > weights.len) return error.InvalidParameter;
    const positive = try countPositiveWeights(Weight, weights);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositiveWeightIndexAlloc(allocator, Weight, weights);
    return sampleWeightedIndicesExactFrom(allocator, source, Weight, weights, amount);
}

pub fn sampleWeightedIndicesFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, weights: []const Weight, amount: usize) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (weights.len == 0) return error.EmptyInput;

    const positive = try countPositiveWeights(Weight, weights);
    const count = @min(amount, positive);
    if (count == 0) return allocator.alloc(usize, 0);
    if (positive == 1) return singlePositiveWeightIndexAlloc(allocator, Weight, weights);
    return sampleWeightedIndicesExactFrom(allocator, source, Weight, weights, count);
}

pub fn sampleWeightedIndicesInto(rng: Rng, comptime Weight: type, weights: []const Weight, out: []usize, scratch_keys: []f64) Error!usize {
    return sampleWeightedIndicesIntoFrom(rng, Weight, weights, out, scratch_keys);
}

pub fn sampleWeightedIndicesIntoFrom(source: anytype, comptime Weight: type, weights: []const Weight, out: []usize, scratch_keys: []f64) Error!usize {
    if (out.len == 0) return 0;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (weights.len == 0) return error.EmptyInput;

    const positive = try countPositiveWeights(Weight, weights);
    const count = @min(out.len, positive);
    if (count == 0) return 0;
    if (positive == 1) {
        out[0] = (try singlePositiveWeightIndex(Weight, weights)).?;
        return 1;
    }

    sampleWeightedIndicesIntoExactFrom(source, Weight, weights, out[0..count], scratch_keys[0..count]);
    return count;
}

pub fn sampleWeightedIndicesIntoChecked(rng: Rng, comptime Weight: type, weights: []const Weight, out: []usize, scratch_keys: []f64) Error!void {
    return sampleWeightedIndicesIntoCheckedFrom(rng, Weight, weights, out, scratch_keys);
}

pub fn sampleWeightedIndicesIntoCheckedFrom(source: anytype, comptime Weight: type, weights: []const Weight, out: []usize, scratch_keys: []f64) Error!void {
    if (out.len == 0) return;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > weights.len) return error.InvalidParameter;

    const positive = try countPositiveWeights(Weight, weights);
    if (positive < out.len) return error.InvalidParameter;
    if (positive == 1) {
        out[0] = (try singlePositiveWeightIndex(Weight, weights)).?;
        return;
    }

    sampleWeightedIndicesIntoExactFrom(source, Weight, weights, out, scratch_keys[0..out.len]);
}

pub fn sampleWeightedIndexArray(rng: Rng, comptime Weight: type, comptime N: usize, weights: []const Weight) Error!?[N]usize {
    return sampleWeightedIndexArrayFrom(rng, Weight, N, weights);
}

pub fn sampleWeightedIndexArrayFrom(source: anytype, comptime Weight: type, comptime N: usize, weights: []const Weight) Error!?[N]usize {
    if (comptime N == 0) return .{};
    if (weights.len == 0) return error.EmptyInput;
    return sampleWeightedIndexArrayExactFrom(source, Weight, N, weights);
}

pub fn sampleWeightedIndexArrayChecked(rng: Rng, comptime Weight: type, comptime N: usize, weights: []const Weight) Error![N]usize {
    return sampleWeightedIndexArrayCheckedFrom(rng, Weight, N, weights);
}

pub fn sampleWeightedIndexArrayCheckedFrom(source: anytype, comptime Weight: type, comptime N: usize, weights: []const Weight) Error![N]usize {
    if (comptime N == 0) return .{};
    if (N > weights.len) return error.InvalidParameter;
    return (try sampleWeightedIndexArrayExactFrom(source, Weight, N, weights)) orelse error.InvalidParameter;
}

fn sampleWeightedIndicesIntoExactFrom(source: anytype, comptime Weight: type, weights: []const Weight, out: []usize, keys: []f64) void {
    std.debug.assert(out.len > 0);
    std.debug.assert(keys.len == out.len);

    var count: usize = 0;
    for (weights, 0..) |weight, index| {
        const value = weightAsF64(Weight, weight);
        std.debug.assert(value >= 0 and std.math.isFinite(value));
        if (value == 0) continue;

        const key = weightedSelectionKeyFrom(source, value);
        if (count < out.len) {
            out[count] = index;
            keys[count] = key;
            count += 1;
        } else {
            const min_index = minWeightedKeyIndex(keys);
            if (key > keys[min_index]) {
                out[min_index] = index;
                keys[min_index] = key;
            }
        }
    }
    std.debug.assert(count == out.len);
    sortWeightedIndexKeyPairs(out, keys);
}

fn minWeightedKeyIndex(keys: []const f64) usize {
    std.debug.assert(keys.len > 0);
    var min_index: usize = 0;
    for (keys[1..], 1..) |key, index| {
        if (key < keys[min_index]) min_index = index;
    }
    return min_index;
}

fn sortWeightedIndexKeyPairs(indices: []usize, keys: []f64) void {
    std.debug.assert(indices.len == keys.len);
    var i: usize = 1;
    while (i < indices.len) : (i += 1) {
        var j = i;
        while (j > 0 and keys[j] < keys[j - 1]) : (j -= 1) {
            std.mem.swap(usize, &indices[j], &indices[j - 1]);
            std.mem.swap(f64, &keys[j], &keys[j - 1]);
        }
    }
}

fn sortWeightedItemKeyPairs(comptime T: type, items: []T, keys: []f64) void {
    std.debug.assert(items.len == keys.len);
    var i: usize = 1;
    while (i < items.len) : (i += 1) {
        var j = i;
        while (j > 0 and keys[j] < keys[j - 1]) : (j -= 1) {
            std.mem.swap(T, &items[j], &items[j - 1]);
            std.mem.swap(f64, &keys[j], &keys[j - 1]);
        }
    }
}

fn sampleWeightedIndicesExactFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, weights: []const Weight, amount: usize) ![]usize {
    std.debug.assert(amount > 0);
    std.debug.assert(amount <= weights.len);

    const out = try allocator.alloc(usize, amount);
    errdefer allocator.free(out);

    var heap = WeightedCandidateQueue.initContext({});
    defer heap.deinit(allocator);
    try heap.ensureTotalCapacityPrecise(allocator, amount);

    for (weights, 0..) |weight, index| {
        const value = weightAsF64(Weight, weight);
        if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
        if (value == 0) continue;

        const candidate = WeightedCandidate{
            .index = index,
            .key = weightedSelectionKeyFrom(source, value),
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

    std.debug.assert(heap.count() == amount);
    var i: usize = 0;
    while (heap.pop()) |candidate| : (i += 1) {
        out[i] = candidate.index;
    }
    return out;
}

pub fn sampleWeighted(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, amount: usize) ![]T {
    return sampleWeightedFrom(allocator, rng, T, Weight, items, weights, amount);
}

pub fn sampleWeightedChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, amount: usize) ![]T {
    return sampleWeightedCheckedFrom(allocator, rng, T, Weight, items, weights, amount);
}

pub fn sampleWeightedCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, amount: usize) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    if (amount > items.len) return error.InvalidParameter;
    const positive = try countPositiveWeights(Weight, weights);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositiveWeightItemAlloc(allocator, T, Weight, items, weights);

    const out = try allocator.alloc(T, amount);
    errdefer allocator.free(out);
    const indices = try sampleWeightedIndicesExactFrom(allocator, source, Weight, weights, amount);
    defer allocator.free(indices);

    for (indices, out) |index, *slot| slot.* = items[index];
    return out;
}

pub fn sampleWeightedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, amount: usize) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    if (items.len == 0) return error.EmptyInput;

    const positive = try countPositiveWeights(Weight, weights);
    const count = @min(amount, positive);
    if (count == 0) return allocator.alloc(T, 0);
    if (positive == 1) return singlePositiveWeightItemAlloc(allocator, T, Weight, items, weights);

    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    const indices = try sampleWeightedIndicesExactFrom(allocator, source, Weight, weights, count);
    defer allocator.free(indices);

    for (indices, out) |index, *slot| slot.* = items[index];
    return out;
}

pub fn sampleWeightedInto(rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, out: []T, scratch_indices: []usize, scratch_keys: []f64) !usize {
    return sampleWeightedIntoFrom(rng, T, Weight, items, weights, out, scratch_indices, scratch_keys);
}

pub fn sampleWeightedIntoFrom(source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, out: []T, scratch_indices: []usize, scratch_keys: []f64) !usize {
    if (out.len == 0) return 0;
    if (items.len != weights.len) return error.LengthMismatch;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;

    const count = try sampleWeightedIndicesIntoFrom(source, Weight, weights, scratch_indices[0..out.len], scratch_keys[0..out.len]);
    for (scratch_indices[0..count], out[0..count]) |index, *slot| slot.* = items[index];
    return count;
}

pub fn sampleWeightedIntoChecked(rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, out: []T, scratch_indices: []usize, scratch_keys: []f64) !void {
    return sampleWeightedIntoCheckedFrom(rng, T, Weight, items, weights, out, scratch_indices, scratch_keys);
}

pub fn sampleWeightedIntoCheckedFrom(source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, out: []T, scratch_indices: []usize, scratch_keys: []f64) !void {
    if (out.len == 0) return;
    if (items.len != weights.len) return error.LengthMismatch;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;

    try sampleWeightedIndicesIntoCheckedFrom(source, Weight, weights, scratch_indices[0..out.len], scratch_keys[0..out.len]);
    for (scratch_indices[0..out.len], out) |index, *slot| slot.* = items[index];
}

pub fn sampleWeightedArray(rng: Rng, comptime T: type, comptime Weight: type, comptime N: usize, items: []const T, weights: []const Weight) !?[N]T {
    return sampleWeightedArrayFrom(rng, T, Weight, N, items, weights);
}

pub fn sampleWeightedArrayFrom(source: anytype, comptime T: type, comptime Weight: type, comptime N: usize, items: []const T, weights: []const Weight) !?[N]T {
    if (comptime N == 0) return .{};
    if (items.len != weights.len) return error.LengthMismatch;
    if (items.len == 0) return null;

    const indices = (try sampleWeightedIndexArrayExactFrom(source, Weight, N, weights)) orelse return null;
    var out: [N]T = undefined;
    inline for (0..N) |i| out[i] = items[indices[i]];
    return out;
}

pub fn sampleWeightedArrayChecked(rng: Rng, comptime T: type, comptime Weight: type, comptime N: usize, items: []const T, weights: []const Weight) ![N]T {
    return sampleWeightedArrayCheckedFrom(rng, T, Weight, N, items, weights);
}

pub fn sampleWeightedArrayCheckedFrom(source: anytype, comptime T: type, comptime Weight: type, comptime N: usize, items: []const T, weights: []const Weight) ![N]T {
    if (comptime N == 0) return .{};
    if (items.len != weights.len) return error.LengthMismatch;
    if (N > items.len) return error.InvalidParameter;

    const indices = (try sampleWeightedIndexArrayExactFrom(source, Weight, N, weights)) orelse return error.InvalidParameter;
    var out: [N]T = undefined;
    inline for (0..N) |i| out[i] = items[indices[i]];
    return out;
}

fn sampleWeightedIndexArrayExactFrom(source: anytype, comptime Weight: type, comptime N: usize, weights: []const Weight) Error!?[N]usize {
    if (comptime N == 0) return .{};

    const positive = try countPositiveWeights(Weight, weights);
    if (positive < N) return null;
    if (positive == 1 and comptime N == 1) {
        return .{(try singlePositiveWeightIndex(Weight, weights)).?};
    }

    var candidates: [N]WeightedCandidate = undefined;
    var count: usize = 0;
    for (weights, 0..) |weight, index| {
        const value = weightAsF64(Weight, weight);
        if (value == 0) continue;

        const candidate = WeightedCandidate{
            .index = index,
            .key = weightedSelectionKeyFrom(source, value),
        };
        if (count < N) {
            candidates[count] = candidate;
            count += 1;
        } else {
            const min_index = minWeightedCandidateIndex(candidates[0..]);
            if (compareWeightedCandidate({}, candidate, candidates[min_index]) == .gt) {
                candidates[min_index] = candidate;
            }
        }
    }
    std.debug.assert(count == N);
    sortWeightedCandidates(candidates[0..]);

    var out: [N]usize = undefined;
    inline for (0..N) |i| out[i] = candidates[i].index;
    return out;
}

fn minWeightedCandidateIndex(candidates: []const WeightedCandidate) usize {
    std.debug.assert(candidates.len > 0);
    var min_index: usize = 0;
    for (candidates[1..], 1..) |candidate, index| {
        if (compareWeightedCandidate({}, candidate, candidates[min_index]) == .lt) min_index = index;
    }
    return min_index;
}

fn sortWeightedCandidates(candidates: []WeightedCandidate) void {
    var i: usize = 1;
    while (i < candidates.len) : (i += 1) {
        var j = i;
        while (j > 0 and compareWeightedCandidate({}, candidates[j], candidates[j - 1]) == .lt) : (j -= 1) {
            std.mem.swap(WeightedCandidate, &candidates[j], &candidates[j - 1]);
        }
    }
}

pub fn Choice(comptime T: type) type {
    return struct {
        const Self = @This();

        items: []const T,

        pub fn init(items: []const T) ?Self {
            if (items.len == 0) return null;
            return .{ .items = items };
        }

        pub fn initChecked(items: []const T) Error!Self {
            return init(items) orelse error.EmptyInput;
        }

        pub fn len(self: Self) usize {
            return self.items.len;
        }

        pub fn isEmpty(self: Self) bool {
            return self.len() == 0;
        }

        pub fn itemsValue(self: Self) []const T {
            return self.items;
        }

        pub fn itemAt(self: Self, index: usize) Error!*const T {
            if (index >= self.items.len) return error.InvalidParameter;
            return &self.items[index];
        }

        pub fn probabilityAt(self: Self, index: usize) Error!f64 {
            if (index >= self.items.len) return error.InvalidParameter;
            return 1.0 / @as(f64, @floatFromInt(self.items.len));
        }

        pub fn probabilities(self: Self, allocator: std.mem.Allocator) ![]f64 {
            const out = try allocator.alloc(f64, self.items.len);
            errdefer allocator.free(out);
            try self.probabilitiesInto(out);
            return out;
        }

        pub fn probabilitiesInto(self: Self, out: []f64) Error!void {
            if (out.len != self.items.len) return error.LengthMismatch;
            @memset(out, 1.0 / @as(f64, @floatFromInt(self.items.len)));
        }

        pub fn sample(self: Self, rng: Rng) *const T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) *const T {
            if (self.items.len == 1) return &self.items[0];
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
            if (self.items.len == 1) {
                @memset(dest, &self.items[0]);
                return;
            }
            for (dest) |*item| item.* = self.sampleFrom(source);
        }

        pub fn fillValues(self: Self, rng: Rng, dest: []T) void {
            self.fillValuesFrom(rng, dest);
        }

        pub fn fillValuesFrom(self: Self, source: anytype, dest: []T) void {
            if (self.items.len == 1) {
                @memset(dest, self.items[0]);
                return;
            }
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

pub fn chooseIterChecked(rng: Rng, comptime T: type, items: []const T) Error!Rng.SampleIterator(Choice(T), *const T) {
    const choice = try Choice(T).initChecked(items);
    return choice.iter(rng);
}

pub fn chooseIterFrom(source: anytype, comptime T: type, items: []const T) ?Rng.SampleIteratorFrom(@TypeOf(source), Choice(T), *const T) {
    const choice = Choice(T).init(items) orelse return null;
    return choice.iterFrom(source);
}

pub fn chooseIterCheckedFrom(source: anytype, comptime T: type, items: []const T) Error!Rng.SampleIteratorFrom(@TypeOf(source), Choice(T), *const T) {
    const choice = try Choice(T).initChecked(items);
    return choice.iterFrom(source);
}

pub fn WeightedChoice(comptime T: type, comptime Weight: type) type {
    return struct {
        const Self = @This();
        const Table = distributions.AliasTable(Weight);

        items: []const T,
        table: Table,

        pub fn init(allocator: std.mem.Allocator, items: []const T, input_weights: []const Weight) !Self {
            if (items.len == 0) return error.EmptyInput;
            if (items.len != input_weights.len) return error.LengthMismatch;
            return .{
                .items = items,
                .table = try Table.init(allocator, input_weights),
            };
        }

        pub fn deinit(self: *Self) void {
            self.table.deinit();
            self.* = undefined;
        }

        pub fn len(self: Self) usize {
            return self.items.len;
        }

        pub fn isEmpty(self: Self) bool {
            return self.len() == 0;
        }

        pub fn itemsValue(self: Self) []const T {
            return self.items;
        }

        pub fn itemAt(self: Self, index: usize) Error!*const T {
            if (index >= self.items.len) return error.InvalidParameter;
            return &self.items[index];
        }

        pub fn totalWeight(self: Self) f64 {
            return self.table.totalWeight();
        }

        pub fn weights(self: Self, allocator: std.mem.Allocator) ![]f64 {
            return self.table.weights(allocator);
        }

        pub fn weightsInto(self: Self, out: []f64) Error!void {
            if (out.len != self.items.len) return error.LengthMismatch;
            self.table.weightsInto(out) catch unreachable;
        }

        pub fn probabilities(self: Self, allocator: std.mem.Allocator) ![]f64 {
            return self.table.probabilities(allocator);
        }

        pub fn probabilitiesInto(self: Self, out: []f64) Error!void {
            if (out.len != self.items.len) return error.LengthMismatch;
            self.table.probabilitiesInto(out) catch unreachable;
        }

        pub fn weightAt(self: Self, index: usize) Error!f64 {
            if (index >= self.items.len) return error.InvalidParameter;
            return self.table.weightAt(index) catch unreachable;
        }

        pub fn probabilityAt(self: Self, index: usize) Error!f64 {
            if (index >= self.items.len) return error.InvalidParameter;
            return self.table.probabilityAt(index) catch unreachable;
        }

        pub fn update(self: *Self, input_weights: []const Weight) !void {
            if (input_weights.len != self.items.len) return error.LengthMismatch;
            try self.table.update(input_weights);
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
            if (self.table.constantIndex()) |index| {
                @memset(dest, &self.items[index]);
                return;
            }
            for (dest) |*item| item.* = self.sampleFrom(source);
        }

        pub fn fillValues(self: Self, rng: Rng, dest: []T) void {
            self.fillValuesFrom(rng, dest);
        }

        pub fn fillValuesFrom(self: Self, source: anytype, dest: []T) void {
            if (self.table.constantIndex()) |index| {
                @memset(dest, self.items[index]);
                return;
            }
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

pub fn partialShuffleChecked(rng: Rng, comptime T: type, items: []T, amount: usize) Error![]T {
    return partialShuffleCheckedFrom(rng, T, items, amount);
}

pub fn partialShuffleCheckedFrom(source: anytype, comptime T: type, items: []T, amount: usize) Error![]T {
    if (amount > items.len) return error.InvalidParameter;
    return partialShuffleFrom(source, T, items, amount);
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

pub fn PartialShuffleSplit(comptime T: type) type {
    return struct {
        selected: []T,
        rest: []T,
    };
}

pub fn partialShuffleSplit(rng: Rng, comptime T: type, items: []T, amount: usize) PartialShuffleSplit(T) {
    return partialShuffleSplitFrom(rng, T, items, amount);
}

pub fn partialShuffleSplitChecked(rng: Rng, comptime T: type, items: []T, amount: usize) Error!PartialShuffleSplit(T) {
    return partialShuffleSplitCheckedFrom(rng, T, items, amount);
}

pub fn partialShuffleSplitCheckedFrom(source: anytype, comptime T: type, items: []T, amount: usize) Error!PartialShuffleSplit(T) {
    if (amount > items.len) return error.InvalidParameter;
    return partialShuffleSplitFrom(source, T, items, amount);
}

pub fn partialShuffleSplitFrom(source: anytype, comptime T: type, items: []T, amount: usize) PartialShuffleSplit(T) {
    const selected = partialShuffleFrom(source, T, items, amount);
    return .{ .selected = selected, .rest = items[selected.len..] };
}

pub fn reservoirSample(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]T {
    return reservoirSampleFrom(allocator, rng, T, items, amount);
}

pub fn reservoirSampleChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]T {
    return reservoirSampleCheckedFrom(allocator, rng, T, items, amount);
}

pub fn reservoirSampleCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]T {
    if (amount > items.len) return error.InvalidParameter;
    return reservoirSampleFrom(allocator, source, T, items, amount);
}

pub fn reservoirSampleFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]T {
    const count = @min(amount, items.len);
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try reservoirSampleIntoFrom(source, T, items, out);
    return out;
}

pub fn reservoirSampleInto(rng: Rng, comptime T: type, items: []const T, out: []T) Error!void {
    return reservoirSampleIntoFrom(rng, T, items, out);
}

pub fn reservoirSampleIntoFrom(source: anytype, comptime T: type, items: []const T, out: []T) Error!void {
    if (out.len > items.len) return error.InvalidParameter;
    if (out.len == 0) return;

    @memcpy(out, items[0..out.len]);
    var i = out.len;
    while (i < items.len) : (i += 1) {
        const j = Rng.uintAtMostFrom(source, usize, i);
        if (j < out.len) out[j] = items[i];
    }
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

    return indices.toOwnedSliceAssert();
}

fn sampleInPlace(allocator: std.mem.Allocator, source: anytype, length: usize, amount: usize) ![]usize {
    var indices = try std.ArrayList(usize).initCapacity(allocator, length);
    defer indices.deinit(allocator);
    var i: usize = 0;
    while (i < length) : (i += 1) try indices.append(allocator, i);

    const out: ?[]usize = if (amount == length) null else try allocator.alloc(usize, amount);
    errdefer if (out) |items| allocator.free(items);

    i = 0;
    while (i < amount) : (i += 1) {
        const j = Rng.intRangeLessThanFrom(source, usize, i, length);
        std.mem.swap(usize, &indices.items[i], &indices.items[j]);
    }
    if (out) |items| {
        @memcpy(items, indices.items[0..amount]);
        return items;
    }
    return indices.toOwnedSliceAssert();
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

    return indices.toOwnedSliceAssert();
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

    return indices.toOwnedSliceAssert();
}

fn sampleInPlaceU32(allocator: std.mem.Allocator, source: anytype, length: u32, amount: u32) ![]u32 {
    var indices = try std.ArrayList(u32).initCapacity(allocator, length);
    defer indices.deinit(allocator);
    var i: u32 = 0;
    while (i < length) : (i += 1) try indices.append(allocator, i);

    const out_len: usize = @intCast(amount);
    const out: ?[]u32 = if (amount == length) null else try allocator.alloc(u32, out_len);
    errdefer if (out) |items| allocator.free(items);

    i = 0;
    while (i < amount) : (i += 1) {
        const j = Rng.intRangeLessThanFrom(source, u32, i, length);
        std.mem.swap(u32, &indices.items[i], &indices.items[j]);
    }
    if (out) |items| {
        @memcpy(items, indices.items[0..out_len]);
        return items;
    }
    return indices.toOwnedSliceAssert();
}

fn sampleInPlaceU32AsUsize(allocator: std.mem.Allocator, source: anytype, length: u32, amount: u32) ![]usize {
    var indices = try std.ArrayList(usize).initCapacity(allocator, length);
    defer indices.deinit(allocator);
    var i: u32 = 0;
    while (i < length) : (i += 1) try indices.append(allocator, i);

    const out_len: usize = @intCast(amount);
    const out: ?[]usize = if (amount == length) null else try allocator.alloc(usize, out_len);
    errdefer if (out) |items| allocator.free(items);

    i = 0;
    while (i < amount) : (i += 1) {
        const j = Rng.intRangeLessThanFrom(source, u32, i, length);
        std.mem.swap(usize, &indices.items[i], &indices.items[j]);
    }
    if (out) |items| {
        @memcpy(items, indices.items[0..out_len]);
        return items;
    }
    return indices.toOwnedSliceAssert();
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

fn minWeightedIteratorCandidateIndex(comptime T: type, candidates: []const WeightedIteratorCandidate(T)) usize {
    std.debug.assert(candidates.len > 0);
    const compare = compareWeightedIteratorCandidate(T);
    var min_index: usize = 0;
    for (candidates[1..], 1..) |candidate, index| {
        if (compare({}, candidate, candidates[min_index]) == .lt) min_index = index;
    }
    return min_index;
}

fn sortWeightedIteratorCandidates(comptime T: type, candidates: []WeightedIteratorCandidate(T)) void {
    const compare = compareWeightedIteratorCandidate(T);
    var i: usize = 1;
    while (i < candidates.len) : (i += 1) {
        var j = i;
        while (j > 0 and compare({}, candidates[j], candidates[j - 1]) == .lt) : (j -= 1) {
            std.mem.swap(WeightedIteratorCandidate(T), &candidates[j], &candidates[j - 1]);
        }
    }
}

fn weightAsF64(comptime Weight: type, weight: Weight) f64 {
    return switch (@typeInfo(Weight)) {
        .int => @floatFromInt(weight),
        .float => @floatCast(weight),
        else => @compileError("weighted sampling weights must be numeric"),
    };
}

fn countPositiveWeights(comptime Weight: type, weights: []const Weight) Error!usize {
    var positive: usize = 0;
    for (weights) |weight| {
        const value = weightAsF64(Weight, weight);
        if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
        if (value > 0) positive += 1;
    }
    return positive;
}

fn singlePositiveWeightIndex(comptime Weight: type, weights: []const Weight) Error!?usize {
    var positive_index: ?usize = null;
    var positive: usize = 0;
    for (weights, 0..) |weight, index| {
        const value = weightAsF64(Weight, weight);
        if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
        if (value > 0) {
            positive_index = index;
            positive += 1;
            if (positive > 1) return null;
        }
    }
    return positive_index;
}

fn singlePositiveWeightIndexAlloc(allocator: std.mem.Allocator, comptime Weight: type, weights: []const Weight) ![]usize {
    const index = (try singlePositiveWeightIndex(Weight, weights)).?;
    const out = try allocator.alloc(usize, 1);
    out[0] = index;
    return out;
}

fn singlePositiveWeightItemAlloc(
    allocator: std.mem.Allocator,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    weights: []const Weight,
) ![]T {
    const index = (try singlePositiveWeightIndex(Weight, weights)).?;
    const out = try allocator.alloc(T, 1);
    out[0] = items[index];
    return out;
}

fn weightedSelectionKeyFrom(source: anytype, weight: f64) f64 {
    std.debug.assert(weight > 0 and std.math.isFinite(weight));
    const key = @log(Rng.floatOpenFrom(source, f64)) / weight;
    return if (std.math.isFinite(key)) key else -std.math.floatMax(f64);
}

fn weightedIndexGenericFrom(source: anytype, comptime Weight: type, weights: []const Weight) Error!?usize {
    var total: f64 = 0;
    var positive_index: ?usize = null;
    var positive_count: usize = 0;
    for (weights, 0..) |weight, index| {
        const value = weightAsF64(Weight, weight);
        if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
        total += value;
        if (!std.math.isFinite(total)) return error.InvalidWeight;
        if (value > 0) {
            positive_index = index;
            positive_count += 1;
        }
    }
    if (weights.len == 0 or total == 0) return null;
    if (positive_count == 1) return positive_index.?;

    const point = Rng.floatFrom(source, f64) * total;
    var acc: f64 = 0;
    for (weights, 0..) |weight, index| {
        acc += weightAsF64(Weight, weight);
        if (point < acc) return index;
    }
    return weights.len - 1;
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
    try std.testing.expectError(error.InvalidParameter, sampleIndicesCheckedFrom(std.testing.allocator, &engine, 3, 4));

    const direct_checked_indices = try sampleIndicesCheckedFrom(std.testing.allocator, &engine, 1_000, 16);
    defer std.testing.allocator.free(direct_checked_indices);
    try std.testing.expectEqual(@as(usize, 16), direct_checked_indices.len);

    const direct_checked_u32 = try sampleIndicesU32CheckedFrom(std.testing.allocator, &engine, 1_000, 16);
    defer std.testing.allocator.free(direct_checked_u32);
    try std.testing.expectEqual(@as(usize, 16), direct_checked_u32.len);

    const direct_checked_vec = try sampleIndexVecCheckedFrom(std.testing.allocator, &engine, 1_000, 16);
    defer direct_checked_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 16), direct_checked_vec.len());

    const direct_fixed = sampleArrayFrom(&engine, 4, 32).?;
    for (direct_fixed) |index| try std.testing.expect(index < 32);
    const checked_fixed = try sampleArrayCheckedFrom(&engine, 4, 32);
    for (checked_fixed) |index| try std.testing.expect(index < 32);
}

test "portable index sampling has stable snapshots" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x1234_5678_9abc_def0);
    const rng = alea.Rng.init(&engine);

    const indices = try sampleIndicesU32(std.testing.allocator, rng, 100, 8);
    defer std.testing.allocator.free(indices);
    try std.testing.expectEqualSlices(u32, &.{ 62, 59, 88, 29, 79, 22, 26, 35 }, indices);
    try std.testing.expectEqual(@as(u64, 0x3a7abfece698fa60), engine.next());

    const index_vec = try sampleIndexVec(std.testing.allocator, rng, 100, 8);
    defer index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 8), index_vec.len());
    try std.testing.expect(!index_vec.isEmpty());
    const expected = [_]usize{ 70, 11, 8, 89, 0, 1, 18, 74 };
    for (expected, 0..) |value, i| try std.testing.expectEqual(value, index_vec.at(i));
    try std.testing.expectEqual(@as(?usize, 0), index_vec.indexOf(70));
    try std.testing.expectEqual(@as(?usize, 4), index_vec.indexOf(0));
    try std.testing.expect(index_vec.contains(18));
    try std.testing.expect(!index_vec.contains(99));
    var iter = index_vec.iter();
    try std.testing.expectEqual(@as(usize, expected.len), iter.remaining());
    for (expected, 0..) |value, i| {
        try std.testing.expectEqual(value, iter.next().?);
        try std.testing.expectEqual(expected.len - i - 1, iter.remaining());
    }
    try std.testing.expectEqual(@as(?usize, null), iter.next());
    var copied: [8]usize = undefined;
    try index_vec.copyInto(&copied);
    try std.testing.expectEqualSlices(usize, &expected, &copied);
    var short_copy: [7]usize = undefined;
    try std.testing.expectError(error.LengthMismatch, index_vec.copyInto(&short_copy));
    const owned_copy = try index_vec.toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(owned_copy);
    try std.testing.expectEqualSlices(usize, &expected, owned_copy);
    var failing_copy = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, index_vec.toOwnedSlice(failing_copy.allocator()));
    try std.testing.expect(failing_copy.has_induced_failure);
    try std.testing.expectEqual(@as(u64, 0xe2fc197c64f3dd72), engine.next());
}

test "index vec conversion supports native backing" {
    var backing = [_]usize{ 5, 8, 13 };
    const index_vec = IndexVec{ .usize = &backing };
    try std.testing.expectEqual(@as(usize, 3), index_vec.len());
    try std.testing.expect(!index_vec.isEmpty());
    try std.testing.expectEqual(@as(?usize, 1), index_vec.indexOf(8));
    try std.testing.expect(index_vec.contains(13));
    try std.testing.expect(!index_vec.contains(21));

    var iter = index_vec.iter();
    try std.testing.expectEqual(@as(usize, 3), iter.remaining());
    try std.testing.expectEqual(@as(?usize, 5), iter.next());
    try std.testing.expectEqual(@as(usize, 2), iter.remaining());
    try std.testing.expectEqual(@as(?usize, 8), iter.next());
    try std.testing.expectEqual(@as(usize, 1), iter.remaining());
    try std.testing.expectEqual(@as(?usize, 13), iter.next());
    try std.testing.expectEqual(@as(usize, 0), iter.remaining());
    try std.testing.expectEqual(@as(?usize, null), iter.next());

    var copied: [3]usize = undefined;
    try index_vec.copyInto(&copied);
    try std.testing.expectEqualSlices(usize, &backing, &copied);

    const owned = try index_vec.toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(owned);
    try std.testing.expectEqualSlices(usize, &backing, owned);
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

test "checked index sampling preserves valid-parameter stream shape" {
    const alea = @import("root.zig");

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var unchecked = Engine.init(0x5150_3333);
        var checked = Engine.init(0x5150_3333);

        const indices = try sampleIndicesFrom(std.testing.allocator, &unchecked, 1_000, 16);
        defer std.testing.allocator.free(indices);
        const checked_indices = try sampleIndicesCheckedFrom(std.testing.allocator, &checked, 1_000, 16);
        defer std.testing.allocator.free(checked_indices);
        try std.testing.expectEqualSlices(usize, indices, checked_indices);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const indices_u32 = try sampleIndicesU32From(std.testing.allocator, &unchecked, 1_000, 16);
        defer std.testing.allocator.free(indices_u32);
        const checked_indices_u32 = try sampleIndicesU32CheckedFrom(std.testing.allocator, &checked, 1_000, 16);
        defer std.testing.allocator.free(checked_indices_u32);
        try std.testing.expectEqualSlices(u32, indices_u32, checked_indices_u32);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const index_vec = try sampleIndexVecFrom(std.testing.allocator, &unchecked, 1_000, 16);
        defer index_vec.deinit(std.testing.allocator);
        const checked_index_vec = try sampleIndexVecCheckedFrom(std.testing.allocator, &checked, 1_000, 16);
        defer checked_index_vec.deinit(std.testing.allocator);
        try std.testing.expectEqual(index_vec.len(), checked_index_vec.len());
        var i: usize = 0;
        while (i < index_vec.len()) : (i += 1) {
            try std.testing.expectEqual(index_vec.at(i), checked_index_vec.at(i));
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());
    }
}

test "sampleIndicesInto fills caller-owned index buffers" {
    const alea = @import("root.zig");

    var engine = alea.ScalarPrng.init(0x5150_7901);
    var out: [6]usize = undefined;
    try sampleIndicesIntoCheckedFrom(&engine, 10_000, &out);
    for (out) |index| try std.testing.expect(index < 10_000);

    var empty_engine = alea.ScalarPrng.init(0x5150_7902);
    var empty_control = alea.ScalarPrng.init(0x5150_7902);
    var empty_out: [0]usize = .{};
    try sampleIndicesIntoCheckedFrom(&empty_engine, 10_000, &empty_out);
    sampleIndicesIntoFrom(&empty_engine, 10_000, &empty_out);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "sampleIndicesInto preserves facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_7903);
        var direct_engine = Engine.init(0x5150_7903);
        const rng = Rng.init(&facade_engine);

        var facade_out: [8]usize = undefined;
        var direct_out: [8]usize = undefined;
        try sampleIndicesInto(rng, 10_000, &facade_out);
        try sampleIndicesIntoCheckedFrom(&direct_engine, 10_000, &direct_out);
        try std.testing.expectEqualSlices(usize, &facade_out, &direct_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_7904);
    var invalid_control = alea.ScalarPrng.init(0x5150_7904);
    var invalid_out: [4]usize = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleIndicesIntoCheckedFrom(&invalid_engine, 3, &invalid_out));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "sampleIndicesU32Into fills caller-owned compact index buffers" {
    const alea = @import("root.zig");

    var engine = alea.ScalarPrng.init(0x5150_7911);
    var out: [6]u32 = undefined;
    try sampleIndicesU32IntoCheckedFrom(&engine, 10_000, &out);
    for (out) |index| try std.testing.expect(index < 10_000);

    var empty_engine = alea.ScalarPrng.init(0x5150_7912);
    var empty_control = alea.ScalarPrng.init(0x5150_7912);
    var empty_out: [0]u32 = .{};
    try sampleIndicesU32IntoCheckedFrom(&empty_engine, 10_000, &empty_out);
    sampleIndicesU32IntoFrom(&empty_engine, 10_000, &empty_out);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "sampleIndicesU32Into preserves facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_7913);
        var direct_engine = Engine.init(0x5150_7913);
        const rng = Rng.init(&facade_engine);

        var facade_out: [8]u32 = undefined;
        var direct_out: [8]u32 = undefined;
        try sampleIndicesU32Into(rng, 10_000, &facade_out);
        try sampleIndicesU32IntoCheckedFrom(&direct_engine, 10_000, &direct_out);
        try std.testing.expectEqualSlices(u32, &facade_out, &direct_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_7914);
    var invalid_control = alea.ScalarPrng.init(0x5150_7914);
    var invalid_out: [4]u32 = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleIndicesU32IntoCheckedFrom(&invalid_engine, 3, &invalid_out));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "in-place index output allocation failures do not consume random stream" {
    const alea = @import("root.zig");

    var usize_engine = alea.ScalarPrng.init(0x5150_1d03);
    var usize_control = alea.ScalarPrng.init(0x5150_1d03);
    var usize_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, sampleIndicesFrom(usize_alloc.allocator(), &usize_engine, 20, 12));
    try std.testing.expect(usize_alloc.has_induced_failure);
    try std.testing.expectEqual(usize_control.next(), usize_engine.next());

    var u32_engine = alea.ScalarPrng.init(0x5150_1d04);
    var u32_control = alea.ScalarPrng.init(0x5150_1d04);
    var u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, sampleIndicesU32From(u32_alloc.allocator(), &u32_engine, 20, 12));
    try std.testing.expect(u32_alloc.has_induced_failure);
    try std.testing.expectEqual(u32_control.next(), u32_engine.next());
}

test "exact-capacity index samplers avoid post-sampling ownership allocation" {
    const alea = @import("root.zig");

    var u32_engine = alea.ScalarPrng.init(0x5150_1d01);
    var u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{
        .fail_index = 1,
        .resize_fail_index = 0,
    });
    const indices_u32 = try sampleIndicesU32From(u32_alloc.allocator(), &u32_engine, 1_000, 16);
    defer u32_alloc.allocator().free(indices_u32);
    try std.testing.expectEqual(@as(usize, 16), indices_u32.len);
    try std.testing.expect(!u32_alloc.has_induced_failure);

    var usize_engine = alea.ScalarPrng.init(0x5150_1d02);
    var usize_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{
        .fail_index = 1,
        .resize_fail_index = 0,
    });
    const indices = try sampleIndicesFrom(usize_alloc.allocator(), &usize_engine, 1_000, 16);
    defer usize_alloc.allocator().free(indices);
    try std.testing.expectEqual(@as(usize, 16), indices.len);
    try std.testing.expect(!usize_alloc.has_induced_failure);
}

test "invalid facade index helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_5e0);
    var control = alea.ScalarPrng.init(0x5150_5e0);
    const rng = alea.Rng.init(&engine);

    try std.testing.expectError(error.InvalidParameter, sampleIndices(std.testing.allocator, rng, 3, 4));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleIndicesU32(std.testing.allocator, rng, 3, 4));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleIndexVec(std.testing.allocator, rng, 3, 4));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleArrayChecked(rng, 4, 3));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid facade collection helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_5df);
    var control = alea.ScalarPrng.init(0x5150_5df);
    const rng = alea.Rng.init(&engine);

    try std.testing.expectError(error.InvalidParameter, chooseMultipleChecked(std.testing.allocator, rng, u8, &.{ 1, 2 }, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, chooseArrayChecked(rng, u8, 3, &.{ 1, 2 }));
    try std.testing.expectEqual(control.next(), engine.next());

    var tiny_items = [_]u8{ 1, 2 };
    try std.testing.expectError(error.InvalidParameter, partialShuffleChecked(rng, u8, &tiny_items, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, partialShuffleSplitChecked(rng, u8, &tiny_items, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, reservoirSampleChecked(std.testing.allocator, rng, u8, &.{ 1, 2 }, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    var out: [3]u8 = undefined;
    try std.testing.expectError(error.InvalidParameter, reservoirSampleInto(rng, u8, &.{ 1, 2 }, &out));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid facade weighted sequence helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_5de);
    var control = alea.ScalarPrng.init(0x5150_5de);
    const rng = alea.Rng.init(&engine);

    try std.testing.expectError(error.LengthMismatch, chooseWeightedChecked(rng, u8, u32, &.{ 1, 2 }, &.{1}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidWeight, chooseWeightedChecked(rng, u8, f64, &.{ 1, 2 }, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesChecked(std.testing.allocator, rng, u32, &.{ 1, 2 }, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleWeightedChecked(std.testing.allocator, rng, u8, u32, &.{ 1, 2 }, &.{ 1, 2 }, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesChecked(std.testing.allocator, rng, u32, &.{ 0, 5, 0 }, 2));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid sequence helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_5e1);

    try std.testing.expectError(error.InvalidParameter, sampleIndicesCheckedFrom(std.testing.allocator, &engine, 3, 4));
    try std.testing.expectEqual(@as(u64, 0xf2611037b789ad41), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleIndicesU32CheckedFrom(std.testing.allocator, &engine, 3, 4));
    try std.testing.expectEqual(@as(u64, 0xb46fead74e7345fe), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleIndexVecCheckedFrom(std.testing.allocator, &engine, 3, 4));
    try std.testing.expectEqual(@as(u64, 0x7136283275fc14a7), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleArrayCheckedFrom(&engine, 4, 3));
    try std.testing.expectEqual(@as(u64, 0xc964db7573788751), engine.next());

    try std.testing.expectError(error.InvalidParameter, chooseMultipleCheckedFrom(std.testing.allocator, &engine, u8, &.{ 1, 2 }, 3));
    try std.testing.expectEqual(@as(u64, 0x8ac4bc884c0ac5fc), engine.next());

    var tiny_items = [_]u8{ 1, 2 };
    try std.testing.expectError(error.InvalidParameter, partialShuffleCheckedFrom(&engine, u8, &tiny_items, 3));
    try std.testing.expectEqual(@as(u64, 0x54bf90173d0a647f), engine.next());

    try std.testing.expectError(error.InvalidParameter, reservoirSampleCheckedFrom(std.testing.allocator, &engine, u8, &.{ 1, 2 }, 3));
    try std.testing.expectEqual(@as(u64, 0x3a629804e3b708f), engine.next());

    const EmptyIter = struct {
        fn next(_: *@This()) ?u8 {
            return null;
        }
    };
    var empty_iter = EmptyIter{};
    try std.testing.expectError(error.EmptyInput, chooseIteratorCheckedFrom(&engine, u8, &empty_iter));
    try std.testing.expectEqual(@as(u64, 0x0e732e04fa4e0680), engine.next());

    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesFrom(std.testing.allocator, &engine, u32, &.{}, 1));
    try std.testing.expectEqual(@as(u64, 0x3a0e704844a1b5ea), engine.next());

    try std.testing.expectError(error.EmptyInput, sampleWeightedFrom(std.testing.allocator, &engine, u8, u32, &.{}, &.{}, 1));
    try std.testing.expectEqual(@as(u64, 0xbdd1a3355d5f73fa), engine.next());

    const empty_weighted = try sampleWeightedFrom(std.testing.allocator, &engine, u8, u32, &.{}, &.{1}, 0);
    defer std.testing.allocator.free(empty_weighted);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted.len);
    try std.testing.expectEqual(@as(u64, 0x12f96538e2946977), engine.next());

    try std.testing.expectError(error.LengthMismatch, sampleWeightedFrom(std.testing.allocator, &engine, u8, u32, &.{ 1, 2 }, &.{1}, 1));
    try std.testing.expectEqual(@as(u64, 0x27e8be3f8d5b1983), engine.next());

    const Entry = struct { item: u8, weight: f64 };
    const BadIter = struct {
        items: []const Entry,
        index: usize = 0,

        fn next(self: *@This()) ?Entry {
            if (self.index >= self.items.len) return null;
            const item = self.items[self.index];
            self.index += 1;
            return item;
        }
    };
    const bad_entries = [_]Entry{.{ .item = 1, .weight = std.math.nan(f64) }};
    var bad_choose_iter = BadIter{ .items = &bad_entries };
    try std.testing.expectError(error.InvalidWeight, chooseIteratorWeightedFrom(&engine, u8, &bad_choose_iter));
    try std.testing.expectEqual(@as(u64, 0xf151595c48f020fd), engine.next());

    var bad_sample_iter = BadIter{ .items = &bad_entries };
    try std.testing.expectError(error.InvalidWeight, sampleIteratorWeightedFrom(std.testing.allocator, &engine, u8, &bad_sample_iter, 1));
    try std.testing.expectEqual(@as(u64, 0x979291c5b220befd), engine.next());

    const huge_entries = [_]Entry{
        .{ .item = 1, .weight = std.math.floatMax(f64) },
        .{ .item = 2, .weight = std.math.floatMax(f64) },
    };
    var huge_choose_iter = BadIter{ .items = &huge_entries };
    try std.testing.expectError(error.InvalidWeight, chooseIteratorWeightedFrom(&engine, u8, &huge_choose_iter));
    try std.testing.expectEqual(@as(u64, 0x7dcd2fece6ccdcbf), engine.next());

    var huge_sample_iter = BadIter{ .items = &huge_entries };
    const huge_sample = try sampleIteratorWeightedFrom(std.testing.allocator, &engine, u8, &huge_sample_iter, 2);
    defer std.testing.allocator.free(huge_sample);
    try std.testing.expectEqual(@as(usize, 2), huge_sample.len);
    try std.testing.expectEqual(@as(u64, 0xa06192b916815789), engine.next());
}

test "initial sequence allocation failures do not consume random stream" {
    const alea = @import("root.zig");

    var indices_engine = alea.ScalarPrng.init(0x5150_5e2);
    var indices_control = alea.ScalarPrng.init(0x5150_5e2);
    var indices_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleIndicesFrom(indices_alloc.allocator(), &indices_engine, 1_000, 16));
    try std.testing.expect(indices_alloc.has_induced_failure);
    try std.testing.expectEqual(indices_control.next(), indices_engine.next());

    var indices_u32_engine = alea.ScalarPrng.init(0x5150_5e3);
    var indices_u32_control = alea.ScalarPrng.init(0x5150_5e3);
    var indices_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleIndicesU32From(indices_u32_alloc.allocator(), &indices_u32_engine, 1_000, 16));
    try std.testing.expect(indices_u32_alloc.has_induced_failure);
    try std.testing.expectEqual(indices_u32_control.next(), indices_u32_engine.next());

    var index_vec_engine = alea.ScalarPrng.init(0x5150_5e4);
    var index_vec_control = alea.ScalarPrng.init(0x5150_5e4);
    var index_vec_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleIndexVecFrom(index_vec_alloc.allocator(), &index_vec_engine, 1_000, 16));
    try std.testing.expect(index_vec_alloc.has_induced_failure);
    try std.testing.expectEqual(index_vec_control.next(), index_vec_engine.next());

    const items = [_]u8{ 1, 2, 3, 4, 5, 6 };
    var choose_engine = alea.ScalarPrng.init(0x5150_5e5);
    var choose_control = alea.ScalarPrng.init(0x5150_5e5);
    var choose_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, chooseMultipleFrom(choose_alloc.allocator(), &choose_engine, u8, &items, 3));
    try std.testing.expect(choose_alloc.has_induced_failure);
    try std.testing.expectEqual(choose_control.next(), choose_engine.next());

    var choose_indices_engine = alea.ScalarPrng.init(0x5150_5eb);
    var choose_indices_control = alea.ScalarPrng.init(0x5150_5eb);
    var choose_indices_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, chooseMultipleFrom(choose_indices_alloc.allocator(), &choose_indices_engine, u8, &items, 3));
    try std.testing.expect(choose_indices_alloc.has_induced_failure);
    try std.testing.expectEqual(choose_indices_control.next(), choose_indices_engine.next());

    var reservoir_engine = alea.ScalarPrng.init(0x5150_5e6);
    var reservoir_control = alea.ScalarPrng.init(0x5150_5e6);
    var reservoir_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, reservoirSampleFrom(reservoir_alloc.allocator(), &reservoir_engine, u8, &items, 3));
    try std.testing.expect(reservoir_alloc.has_induced_failure);
    try std.testing.expectEqual(reservoir_control.next(), reservoir_engine.next());

    const ItemIter = struct {
        items: []const u8,
        index: usize = 0,

        fn next(self: *@This()) ?u8 {
            if (self.index >= self.items.len) return null;
            const item = self.items[self.index];
            self.index += 1;
            return item;
        }
    };

    var iterator_engine = alea.ScalarPrng.init(0x5150_5e7);
    var iterator_control = alea.ScalarPrng.init(0x5150_5e7);
    var iterator_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    var iterator = ItemIter{ .items = &items };
    try std.testing.expectError(error.OutOfMemory, sampleIteratorFrom(iterator_alloc.allocator(), &iterator_engine, u8, &iterator, 3));
    try std.testing.expect(iterator_alloc.has_induced_failure);
    try std.testing.expectEqual(@as(usize, 0), iterator.index);
    try std.testing.expectEqual(iterator_control.next(), iterator_engine.next());

    var checked_iterator_engine = alea.ScalarPrng.init(0x5150_5f1);
    var checked_iterator_control = alea.ScalarPrng.init(0x5150_5f1);
    var checked_iterator_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    var checked_iterator = ItemIter{ .items = &items };
    try std.testing.expectError(error.OutOfMemory, sampleIteratorCheckedFrom(checked_iterator_alloc.allocator(), &checked_iterator_engine, u8, &checked_iterator, 3));
    try std.testing.expect(checked_iterator_alloc.has_induced_failure);
    try std.testing.expectEqual(@as(usize, 0), checked_iterator.index);
    try std.testing.expectEqual(checked_iterator_control.next(), checked_iterator_engine.next());

    const Entry = struct { item: u8, weight: f64 };
    const WeightedIter = struct {
        entries: []const Entry,
        index: usize = 0,

        fn next(self: *@This()) ?Entry {
            if (self.index >= self.entries.len) return null;
            const entry = self.entries[self.index];
            self.index += 1;
            return entry;
        }
    };
    const entries = [_]Entry{
        .{ .item = 1, .weight = 1.0 },
        .{ .item = 2, .weight = 2.0 },
        .{ .item = 3, .weight = 3.0 },
    };

    var weighted_iter_engine = alea.ScalarPrng.init(0x5150_5e8);
    var weighted_iter_control = alea.ScalarPrng.init(0x5150_5e8);
    var weighted_iter_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    var weighted_iter = WeightedIter{ .entries = &entries };
    try std.testing.expectError(error.OutOfMemory, sampleIteratorWeightedFrom(weighted_iter_alloc.allocator(), &weighted_iter_engine, u8, &weighted_iter, 2));
    try std.testing.expect(weighted_iter_alloc.has_induced_failure);
    try std.testing.expectEqual(@as(usize, 0), weighted_iter.index);
    try std.testing.expectEqual(weighted_iter_control.next(), weighted_iter_engine.next());

    var checked_weighted_iter_engine = alea.ScalarPrng.init(0x5150_5f2);
    var checked_weighted_iter_control = alea.ScalarPrng.init(0x5150_5f2);
    var checked_weighted_iter_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    var checked_weighted_iter = WeightedIter{ .entries = &entries };
    try std.testing.expectError(error.OutOfMemory, sampleIteratorWeightedCheckedFrom(checked_weighted_iter_alloc.allocator(), &checked_weighted_iter_engine, u8, &checked_weighted_iter, 2));
    try std.testing.expect(checked_weighted_iter_alloc.has_induced_failure);
    try std.testing.expectEqual(@as(usize, 0), checked_weighted_iter.index);
    try std.testing.expectEqual(checked_weighted_iter_control.next(), checked_weighted_iter_engine.next());

    var checked_weighted_iter_heap_engine = alea.ScalarPrng.init(0x5150_5f3);
    var checked_weighted_iter_heap_control = alea.ScalarPrng.init(0x5150_5f3);
    var checked_weighted_iter_heap_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    var checked_weighted_iter_heap = WeightedIter{ .entries = &entries };
    try std.testing.expectError(error.OutOfMemory, sampleIteratorWeightedCheckedFrom(checked_weighted_iter_heap_alloc.allocator(), &checked_weighted_iter_heap_engine, u8, &checked_weighted_iter_heap, 2));
    try std.testing.expect(checked_weighted_iter_heap_alloc.has_induced_failure);
    try std.testing.expectEqual(@as(usize, 0), checked_weighted_iter_heap.index);
    try std.testing.expectEqual(checked_weighted_iter_heap_control.next(), checked_weighted_iter_heap_engine.next());

    const weights = [_]u32{ 1, 2, 3, 4, 5, 6 };
    var weighted_indices_engine = alea.ScalarPrng.init(0x5150_5e9);
    var weighted_indices_control = alea.ScalarPrng.init(0x5150_5e9);
    var weighted_indices_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedIndicesFrom(weighted_indices_alloc.allocator(), &weighted_indices_engine, u32, &weights, 3));
    try std.testing.expect(weighted_indices_alloc.has_induced_failure);
    try std.testing.expectEqual(weighted_indices_control.next(), weighted_indices_engine.next());

    var checked_indices_engine = alea.ScalarPrng.init(0x5150_5ee);
    var checked_indices_control = alea.ScalarPrng.init(0x5150_5ee);
    var checked_indices_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedIndicesCheckedFrom(checked_indices_alloc.allocator(), &checked_indices_engine, u32, &weights, 3));
    try std.testing.expect(checked_indices_alloc.has_induced_failure);
    try std.testing.expectEqual(checked_indices_control.next(), checked_indices_engine.next());

    var checked_indices_heap_engine = alea.ScalarPrng.init(0x5150_5ef);
    var checked_indices_heap_control = alea.ScalarPrng.init(0x5150_5ef);
    var checked_indices_heap_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedIndicesCheckedFrom(checked_indices_heap_alloc.allocator(), &checked_indices_heap_engine, u32, &weights, 3));
    try std.testing.expect(checked_indices_heap_alloc.has_induced_failure);
    try std.testing.expectEqual(checked_indices_heap_control.next(), checked_indices_heap_engine.next());

    var weighted_engine = alea.ScalarPrng.init(0x5150_5ea);
    var weighted_control = alea.ScalarPrng.init(0x5150_5ea);
    var weighted_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedFrom(weighted_alloc.allocator(), &weighted_engine, u8, u32, &items, &weights, 3));
    try std.testing.expect(weighted_alloc.has_induced_failure);
    try std.testing.expectEqual(weighted_control.next(), weighted_engine.next());

    var checked_weighted_engine = alea.ScalarPrng.init(0x5150_5ec);
    var checked_weighted_control = alea.ScalarPrng.init(0x5150_5ec);
    var checked_weighted_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedCheckedFrom(checked_weighted_alloc.allocator(), &checked_weighted_engine, u8, u32, &items, &weights, 3));
    try std.testing.expect(checked_weighted_alloc.has_induced_failure);
    try std.testing.expectEqual(checked_weighted_control.next(), checked_weighted_engine.next());

    var checked_weighted_indices_engine = alea.ScalarPrng.init(0x5150_5ed);
    var checked_weighted_indices_control = alea.ScalarPrng.init(0x5150_5ed);
    var checked_weighted_indices_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedCheckedFrom(checked_weighted_indices_alloc.allocator(), &checked_weighted_indices_engine, u8, u32, &items, &weights, 3));
    try std.testing.expect(checked_weighted_indices_alloc.has_induced_failure);
    try std.testing.expectEqual(checked_weighted_indices_control.next(), checked_weighted_indices_engine.next());

    var checked_weighted_heap_engine = alea.ScalarPrng.init(0x5150_5f0);
    var checked_weighted_heap_control = alea.ScalarPrng.init(0x5150_5f0);
    var checked_weighted_heap_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 2 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedCheckedFrom(checked_weighted_heap_alloc.allocator(), &checked_weighted_heap_engine, u8, u32, &items, &weights, 3));
    try std.testing.expect(checked_weighted_heap_alloc.has_induced_failure);
    try std.testing.expectEqual(checked_weighted_heap_control.next(), checked_weighted_heap_engine.next());
}

test "invalid weighted slice weights do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7720);
    var control = alea.ScalarPrng.init(0x5150_7720);

    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesFrom(std.testing.allocator, &engine, f64, &.{ 1.0, std.math.nan(f64) }, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidWeight, sampleWeightedFrom(std.testing.allocator, &engine, u8, f64, &.{ 1, 2 }, &.{ 1.0, std.math.nan(f64) }, 1));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid checked weighted sample counts do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7711);

    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesCheckedFrom(std.testing.allocator, &engine, u32, &.{ 1, 2 }, 3));
    try std.testing.expectEqual(@as(u64, 0x2b5cdf1348cc04e8), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, u32, &.{ 1, 2 }, &.{ 1, 2 }, 3));
    try std.testing.expectEqual(@as(u64, 0x6b64b54880a566c3), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesCheckedFrom(std.testing.allocator, &engine, u32, &.{ 0, 5, 0 }, 2));
    try std.testing.expectEqual(@as(u64, 0xe0d9da7b539de67e), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, u32, &.{ 1, 2, 3 }, &.{ 0, 5, 0 }, 2));
    try std.testing.expectEqual(@as(u64, 0x5862e0f61b2d9eea), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesCheckedFrom(std.testing.allocator, &engine, u32, &.{ 0, 0, 0 }, 1));
    try std.testing.expectEqual(@as(u64, 0xc859aaa7f585bb63), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, u32, &.{ 1, 2, 3 }, &.{ 0, 0, 0 }, 1));
    try std.testing.expectEqual(@as(u64, 0x2fe6d69480ac1690), engine.next());
}

test "single-positive weighted no-replacement does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7712);
    var control = alea.ScalarPrng.init(0x5150_7712);
    const weights = [_]u32{ 0, 5, 0 };
    const items = [_]u8{ 10, 20, 30 };

    const indices = try sampleWeightedIndicesFrom(std.testing.allocator, &engine, u32, &weights, 2);
    defer std.testing.allocator.free(indices);
    try std.testing.expectEqualSlices(usize, &.{1}, indices);
    try std.testing.expectEqual(control.next(), engine.next());

    const checked_indices = try sampleWeightedIndicesCheckedFrom(std.testing.allocator, &engine, u32, &weights, 1);
    defer std.testing.allocator.free(checked_indices);
    try std.testing.expectEqualSlices(usize, &.{1}, checked_indices);
    try std.testing.expectEqual(control.next(), engine.next());

    const sample = try sampleWeightedFrom(std.testing.allocator, &engine, u8, u32, &items, &weights, 2);
    defer std.testing.allocator.free(sample);
    try std.testing.expectEqualSlices(u8, &.{20}, sample);
    try std.testing.expectEqual(control.next(), engine.next());

    const checked_sample = try sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, u32, &items, &weights, 1);
    defer std.testing.allocator.free(checked_sample);
    try std.testing.expectEqualSlices(u8, &.{20}, checked_sample);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "empty optional iterator choices do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_771c);
    var control = alea.ScalarPrng.init(0x5150_771c);
    const rng = alea.Rng.init(&engine);

    const EmptyIter = struct {
        fn next(_: *@This()) ?u8 {
            return null;
        }
    };
    var iter = EmptyIter{};
    try std.testing.expectEqual(@as(?u8, null), chooseIterator(rng, u8, &iter));
    try std.testing.expectEqual(control.next(), engine.next());

    const Entry = struct { item: u8, weight: f64 };
    const EmptyWeightedIter = struct {
        fn next(_: *@This()) ?Entry {
            return null;
        }
    };
    var weighted_iter = EmptyWeightedIter{};
    try std.testing.expectEqual(@as(?u8, null), try chooseIteratorWeighted(rng, u8, &weighted_iter));
    try std.testing.expectEqual(control.next(), engine.next());

    const ZeroWeightedIter = struct {
        index: usize = 0,
        entries: []const Entry,

        fn next(self: *@This()) ?Entry {
            if (self.index >= self.entries.len) return null;
            const entry = self.entries[self.index];
            self.index += 1;
            return entry;
        }
    };
    const zero_entries = [_]Entry{
        .{ .item = 1, .weight = 0 },
        .{ .item = 2, .weight = 0 },
    };
    var zero_iter = ZeroWeightedIter{ .entries = &zero_entries };
    try std.testing.expectEqual(@as(?u8, null), try chooseIteratorWeighted(rng, u8, &zero_iter));
    try std.testing.expectEqual(control.next(), engine.next());

    const bad_entries = [_]Entry{.{ .item = 1, .weight = std.math.nan(f64) }};
    var bad_iter = ZeroWeightedIter{ .entries = &bad_entries };
    try std.testing.expectError(error.InvalidWeight, chooseIteratorWeighted(rng, u8, &bad_iter));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "empty facade iterator choices do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_771b);
    var control = alea.ScalarPrng.init(0x5150_771b);
    const rng = alea.Rng.init(&engine);

    const EmptyIter = struct {
        fn next(_: *@This()) ?u8 {
            return null;
        }
    };
    var iter = EmptyIter{};
    try std.testing.expectError(error.EmptyInput, chooseIteratorChecked(rng, u8, &iter));
    try std.testing.expectEqual(control.next(), engine.next());

    const Entry = struct { item: u8, weight: f64 };
    const EmptyWeightedIter = struct {
        fn next(_: *@This()) ?Entry {
            return null;
        }
    };
    var weighted_iter = EmptyWeightedIter{};
    try std.testing.expectError(error.EmptyInput, chooseIteratorWeightedChecked(rng, u8, &weighted_iter));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "empty checked weighted iterator choice does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7712);

    const Entry = struct { item: u8, weight: f64 };
    const EmptyWeightedIter = struct {
        items: []const Entry = &.{},

        fn next(_: *@This()) ?Entry {
            return null;
        }
    };

    var iter = EmptyWeightedIter{};
    try std.testing.expectError(error.EmptyInput, chooseIteratorWeightedCheckedFrom(&engine, u8, &iter));
    try std.testing.expectEqual(@as(u64, 0xa3da0a3f0fe6930c), engine.next());

    const BadWeightedIter = struct {
        items: []const Entry,
        index: usize = 0,

        fn next(self: *@This()) ?Entry {
            if (self.index >= self.items.len) return null;
            const item = self.items[self.index];
            self.index += 1;
            return item;
        }
    };
    const bad_entries = [_]Entry{.{ .item = 1, .weight = std.math.nan(f64) }};
    var bad_iter = BadWeightedIter{ .items = &bad_entries };
    try std.testing.expectError(error.InvalidWeight, chooseIteratorWeightedCheckedFrom(&engine, u8, &bad_iter));
    try std.testing.expectEqual(@as(u64, 0xfe72624376fb6a1e), engine.next());

    const zero_entries = [_]Entry{
        .{ .item = 1, .weight = 0 },
        .{ .item = 2, .weight = 0 },
    };
    var zero_iter = BadWeightedIter{ .items = &zero_entries };
    try std.testing.expectError(error.EmptyInput, chooseIteratorWeightedCheckedFrom(&engine, u8, &zero_iter));
    try std.testing.expectEqual(@as(u64, 0x9c8af023645fd559), engine.next());
}

test "single-positive weighted iterator helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_771e);
    var control = alea.ScalarPrng.init(0x5150_771e);

    const Entry = struct { item: u8, weight: f64 };
    const WeightedIter = struct {
        index: usize = 0,
        entries: []const Entry,

        fn next(self: *@This()) ?Entry {
            if (self.index >= self.entries.len) return null;
            const entry = self.entries[self.index];
            self.index += 1;
            return entry;
        }
    };
    const entries = [_]Entry{
        .{ .item = 10, .weight = 0 },
        .{ .item = 20, .weight = 5 },
        .{ .item = 30, .weight = 0 },
    };

    var choose_iter = WeightedIter{ .entries = &entries };
    try std.testing.expectEqual(@as(?u8, 20), try chooseIteratorWeightedFrom(&engine, u8, &choose_iter));
    try std.testing.expectEqual(control.next(), engine.next());

    var checked_choose_iter = WeightedIter{ .entries = &entries };
    try std.testing.expectEqual(@as(u8, 20), try chooseIteratorWeightedCheckedFrom(&engine, u8, &checked_choose_iter));
    try std.testing.expectEqual(control.next(), engine.next());

    var sample_iter = WeightedIter{ .entries = &entries };
    const sample = try sampleIteratorWeightedFrom(std.testing.allocator, &engine, u8, &sample_iter, 3);
    defer std.testing.allocator.free(sample);
    try std.testing.expectEqualSlices(u8, &.{20}, sample);
    try std.testing.expectEqual(control.next(), engine.next());

    var checked_sample_iter = WeightedIter{ .entries = &entries };
    const checked_sample = try sampleIteratorWeightedCheckedFrom(std.testing.allocator, &engine, u8, &checked_sample_iter, 1);
    defer std.testing.allocator.free(checked_sample);
    try std.testing.expectEqualSlices(u8, &.{20}, checked_sample);
    try std.testing.expectEqual(control.next(), engine.next());

    var short_checked_sample_iter = WeightedIter{ .entries = &entries };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedCheckedFrom(std.testing.allocator, &engine, u8, &short_checked_sample_iter, 2));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "rejection index set allocation failures do not consume random stream" {
    const alea = @import("root.zig");

    var u32_first_engine = alea.ScalarPrng.init(0x5150_5f6);
    var u32_first_control = alea.ScalarPrng.init(0x5150_5f6);
    var u32_first_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleIndicesU32From(u32_first_alloc.allocator(), &u32_first_engine, 100_000, 200));
    try std.testing.expect(u32_first_alloc.has_induced_failure);
    try std.testing.expectEqual(u32_first_control.next(), u32_first_engine.next());

    var u32_engine = alea.ScalarPrng.init(0x5150_5f4);
    var u32_control = alea.ScalarPrng.init(0x5150_5f4);
    var u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, sampleIndicesU32From(u32_alloc.allocator(), &u32_engine, 100_000, 200));
    try std.testing.expect(u32_alloc.has_induced_failure);
    try std.testing.expectEqual(u32_control.next(), u32_engine.next());

    var usize_first_engine = alea.ScalarPrng.init(0x5150_5f7);
    var usize_first_control = alea.ScalarPrng.init(0x5150_5f7);
    var usize_first_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleIndicesFrom(usize_first_alloc.allocator(), &usize_first_engine, 100_000, 200));
    try std.testing.expect(usize_first_alloc.has_induced_failure);
    try std.testing.expectEqual(usize_first_control.next(), usize_first_engine.next());

    var usize_engine = alea.ScalarPrng.init(0x5150_5f5);
    var usize_control = alea.ScalarPrng.init(0x5150_5f5);
    var usize_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, sampleIndicesFrom(usize_alloc.allocator(), &usize_engine, 100_000, 200));
    try std.testing.expect(usize_alloc.has_induced_failure);
    try std.testing.expectEqual(usize_control.next(), usize_engine.next());
}

test "short checked iterator samples do not consume past source" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7713);

    const RangeIter = struct {
        next_value: u8 = 0,
        end: u8 = 2,

        fn next(self: *@This()) ?u8 {
            if (self.next_value >= self.end) return null;
            const value = self.next_value;
            self.next_value += 1;
            return value;
        }
    };

    var iter = RangeIter{};
    try std.testing.expectError(error.InvalidParameter, sampleIteratorCheckedFrom(std.testing.allocator, &engine, u8, &iter, 3));
    try std.testing.expectEqual(@as(u64, 0x85840e4ff30d6d3b), engine.next());

    var empty_iter = RangeIter{ .end = 0 };
    const empty = try sampleIteratorCheckedFrom(std.testing.allocator, &engine, u8, &empty_iter, 0);
    defer std.testing.allocator.free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expectEqual(@as(u64, 0x176d099d72bcd05c), engine.next());
}

test "sampleIteratorInto fills caller-owned reservoirs" {
    const alea = @import("root.zig");

    const RangeIter = struct {
        next_value: u8 = 0,
        end: u8,

        fn next(self: *@This()) ?u8 {
            if (self.next_value >= self.end) return null;
            const value = self.next_value;
            self.next_value += 1;
            return value;
        }
    };

    var optional_engine = alea.ScalarPrng.init(0x5150_7820);
    var optional_iter = RangeIter{ .end = 20 };
    var optional_out: [5]u8 = undefined;
    const filled = sampleIteratorIntoFrom(&optional_engine, u8, &optional_iter, &optional_out);
    try std.testing.expectEqual(@as(usize, 5), filled);
    for (optional_out) |item| try std.testing.expect(item < 20);

    var short_engine = alea.ScalarPrng.init(0x5150_7821);
    var short_control = alea.ScalarPrng.init(0x5150_7821);
    var short_iter = RangeIter{ .end = 2 };
    var short_out: [5]u8 = undefined;
    const short_filled = sampleIteratorIntoFrom(&short_engine, u8, &short_iter, &short_out);
    try std.testing.expectEqual(@as(usize, 2), short_filled);
    try std.testing.expectEqualSlices(u8, &.{ 0, 1 }, short_out[0..short_filled]);
    try std.testing.expectEqual(short_control.next(), short_engine.next());

    var checked_engine = alea.ScalarPrng.init(0x5150_7822);
    var checked_iter = RangeIter{ .end = 20 };
    var checked_out: [5]u8 = undefined;
    try sampleIteratorIntoCheckedFrom(&checked_engine, u8, &checked_iter, &checked_out);
    for (checked_out) |item| try std.testing.expect(item < 20);

    var empty_engine = alea.ScalarPrng.init(0x5150_7823);
    var empty_control = alea.ScalarPrng.init(0x5150_7823);
    var empty_iter = RangeIter{ .end = 20 };
    var empty_out: [0]u8 = .{};
    try std.testing.expectEqual(@as(usize, 0), sampleIteratorIntoFrom(&empty_engine, u8, &empty_iter, &empty_out));
    try sampleIteratorIntoCheckedFrom(&empty_engine, u8, &empty_iter, &empty_out);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "sampleIteratorInto checked short streams do not consume randomness" {
    const alea = @import("root.zig");

    const RangeIter = struct {
        next_value: u8 = 0,
        end: u8,

        fn next(self: *@This()) ?u8 {
            if (self.next_value >= self.end) return null;
            const value = self.next_value;
            self.next_value += 1;
            return value;
        }
    };

    var engine = alea.ScalarPrng.init(0x5150_7824);
    var control = alea.ScalarPrng.init(0x5150_7824);
    var iter = RangeIter{ .end = 2 };
    var out: [5]u8 = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleIteratorIntoCheckedFrom(&engine, u8, &iter, &out));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "sampleIteratorArray returns fixed-size iterator samples" {
    const alea = @import("root.zig");

    const RangeIter = struct {
        next_value: u8 = 0,
        end: u8,

        fn next(self: *@This()) ?u8 {
            if (self.next_value >= self.end) return null;
            const value = self.next_value;
            self.next_value += 1;
            return value;
        }
    };

    var optional_engine = alea.ScalarPrng.init(0x5150_7830);
    var optional_iter = RangeIter{ .end = 20 };
    const optional = sampleIteratorArrayFrom(&optional_engine, u8, 5, &optional_iter).?;
    try std.testing.expectEqual(@as(usize, 5), optional.len);
    for (optional) |item| try std.testing.expect(item < 20);

    var checked_engine = alea.ScalarPrng.init(0x5150_7831);
    var checked_iter = RangeIter{ .end = 20 };
    const checked = try sampleIteratorArrayCheckedFrom(&checked_engine, u8, 5, &checked_iter);
    try std.testing.expectEqual(@as(usize, 5), checked.len);
    for (checked) |item| try std.testing.expect(item < 20);

    var short_engine = alea.ScalarPrng.init(0x5150_7832);
    var short_control = alea.ScalarPrng.init(0x5150_7832);
    var short_iter = RangeIter{ .end = 2 };
    try std.testing.expect(sampleIteratorArrayFrom(&short_engine, u8, 5, &short_iter) == null);
    try std.testing.expectEqual(short_control.next(), short_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_7833);
    var empty_control = alea.ScalarPrng.init(0x5150_7833);
    var empty_iter = RangeIter{ .end = 20 };
    const empty = sampleIteratorArrayFrom(&empty_engine, u8, 0, &empty_iter).?;
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expectEqual(@as(usize, 0), empty_iter.next_value);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "sampleIteratorArray preserves facade/direct stream shape and checked short streams do not consume" {
    const alea = @import("root.zig");

    const RangeIter = struct {
        next_value: u8 = 0,
        end: u8,

        fn next(self: *@This()) ?u8 {
            if (self.next_value >= self.end) return null;
            const value = self.next_value;
            self.next_value += 1;
            return value;
        }
    };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_7834);
        var direct_engine = Engine.init(0x5150_7834);
        const rng = Rng.init(&facade_engine);

        var facade_iter = RangeIter{ .end = 20 };
        var direct_iter = RangeIter{ .end = 20 };
        const facade = sampleIteratorArray(rng, u8, 5, &facade_iter).?;
        const direct = sampleIteratorArrayFrom(&direct_engine, u8, 5, &direct_iter).?;
        try std.testing.expectEqualSlices(u8, &facade, &direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_facade_iter = RangeIter{ .end = 20 };
        var checked_direct_iter = RangeIter{ .end = 20 };
        const checked_facade = try sampleIteratorArrayChecked(rng, u8, 5, &checked_facade_iter);
        const checked_direct = try sampleIteratorArrayCheckedFrom(&direct_engine, u8, 5, &checked_direct_iter);
        try std.testing.expectEqualSlices(u8, &checked_facade, &checked_direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var short_engine = alea.ScalarPrng.init(0x5150_7835);
    var short_control = alea.ScalarPrng.init(0x5150_7835);
    var short_iter = RangeIter{ .end = 2 };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorArrayCheckedFrom(&short_engine, u8, 5, &short_iter));
    try std.testing.expectEqual(short_control.next(), short_engine.next());
}

test "zero-count partial shuffle does not mutate or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7719);
    var control = alea.ScalarPrng.init(0x5150_7719);

    var items = [_]u8{ 1, 2, 3, 4 };
    const head = try partialShuffleCheckedFrom(&engine, u8, &items, 0);
    try std.testing.expectEqual(@as(usize, 0), head.len);
    try std.testing.expectEqualSlices(u8, &.{ 1, 2, 3, 4 }, &items);
    try std.testing.expectEqual(control.next(), engine.next());

    const split = try partialShuffleSplitCheckedFrom(&engine, u8, &items, 0);
    try std.testing.expectEqual(@as(usize, 0), split.selected.len);
    try std.testing.expectEqual(@as(usize, items.len), split.rest.len);
    try std.testing.expectEqualSlices(u8, &.{ 1, 2, 3, 4 }, &items);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "zero-count checked index helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_771a);
    var control = alea.ScalarPrng.init(0x5150_771a);

    const indices = try sampleIndicesCheckedFrom(std.testing.allocator, &engine, 0, 0);
    defer std.testing.allocator.free(indices);
    try std.testing.expectEqual(@as(usize, 0), indices.len);
    try std.testing.expectEqual(control.next(), engine.next());

    const indices_u32 = try sampleIndicesU32CheckedFrom(std.testing.allocator, &engine, 0, 0);
    defer std.testing.allocator.free(indices_u32);
    try std.testing.expectEqual(@as(usize, 0), indices_u32.len);
    try std.testing.expectEqual(control.next(), engine.next());

    const fixed = try sampleArrayCheckedFrom(&engine, 0, 0);
    try std.testing.expectEqual(@as(usize, 0), fixed.len);
    try std.testing.expectEqual(control.next(), engine.next());

    const fixed_nonempty_range = try sampleArrayCheckedFrom(&engine, 0, 10);
    try std.testing.expectEqual(@as(usize, 0), fixed_nonempty_range.len);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "zero-count checked sequence helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7717);
    var control = alea.ScalarPrng.init(0x5150_7717);

    const items = [_]u8{ 1, 2, 3, 4 };

    var index_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const index_vec = try sampleIndexVecCheckedFrom(index_alloc.allocator(), &engine, 0, 0);
    defer index_vec.deinit(index_alloc.allocator());
    try std.testing.expectEqual(@as(usize, 0), index_vec.len());
    try std.testing.expect(index_vec.isEmpty());
    var index_iter = index_vec.iter();
    try std.testing.expectEqual(@as(usize, 0), index_iter.remaining());
    try std.testing.expectEqual(@as(?usize, null), index_iter.next());
    const empty_owned = try index_vec.toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(empty_owned);
    try std.testing.expectEqual(@as(usize, 0), empty_owned.len);
    try std.testing.expect(!index_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var choose_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const chosen = try chooseMultipleCheckedFrom(choose_alloc.allocator(), &engine, u8, &items, 0);
    defer choose_alloc.allocator().free(chosen);
    try std.testing.expectEqual(@as(usize, 0), chosen.len);
    try std.testing.expect(!choose_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var reservoir_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const sampled = try reservoirSampleCheckedFrom(reservoir_alloc.allocator(), &engine, u8, &items, 0);
    defer reservoir_alloc.allocator().free(sampled);
    try std.testing.expectEqual(@as(usize, 0), sampled.len);
    try std.testing.expect(!reservoir_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var reservoir_out: [0]u8 = .{};
    try reservoirSampleIntoFrom(&engine, u8, &items, &reservoir_out);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "full iterator reservoir avoids post-sampling ownership allocation" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7718);

    const RangeIter = struct {
        next_value: u8 = 0,
        end: u8 = 16,

        fn next(self: *@This()) ?u8 {
            if (self.next_value >= self.end) return null;
            const value = self.next_value;
            self.next_value += 1;
            return value;
        }
    };

    var iter = RangeIter{};
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{
        .fail_index = 1,
        .resize_fail_index = 0,
    });
    const sample = try sampleIteratorFrom(failing.allocator(), &engine, u8, &iter, 8);
    defer failing.allocator().free(sample);
    try std.testing.expectEqual(@as(usize, 8), sample.len);
    try std.testing.expect(!failing.has_induced_failure);
}

test "zero-count iterator samples do not read iterator or build reservoir" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7715);
    var control = alea.ScalarPrng.init(0x5150_7715);

    const CountingIter = struct {
        calls: usize = 0,

        fn next(self: *@This()) ?u8 {
            self.calls += 1;
            return 42;
        }
    };

    var iter = CountingIter{};
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const sample = try sampleIteratorCheckedFrom(failing.allocator(), &engine, u8, &iter, 0);
    defer failing.allocator().free(sample);
    try std.testing.expectEqual(@as(usize, 0), sample.len);
    try std.testing.expectEqual(@as(usize, 0), iter.calls);
    try std.testing.expect(!failing.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "zero-count weighted iterator samples do not read iterator or build heap" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7716);
    var control = alea.ScalarPrng.init(0x5150_7716);

    const Entry = struct { item: u8, weight: f64 };
    const BadCountingIter = struct {
        calls: usize = 0,

        fn next(self: *@This()) ?Entry {
            self.calls += 1;
            return .{ .item = 42, .weight = std.math.nan(f64) };
        }
    };

    var iter = BadCountingIter{};
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const sample = try sampleIteratorWeightedCheckedFrom(failing.allocator(), &engine, u8, &iter, 0);
    defer failing.allocator().free(sample);
    try std.testing.expectEqual(@as(usize, 0), sample.len);
    try std.testing.expectEqual(@as(usize, 0), iter.calls);
    try std.testing.expect(!failing.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "short checked weighted iterator samples do not consume past source" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_7714);
    var control = alea.ScalarPrng.init(0x5150_7714);

    const Entry = struct { item: u8, weight: f64 };
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
    };
    var iter = WeightedIter{ .items = &entries };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedCheckedFrom(std.testing.allocator, &engine, u8, &iter, 2));
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_iter = WeightedIter{ .items = &.{} };
    const empty = try sampleIteratorWeightedCheckedFrom(std.testing.allocator, &engine, u8, &empty_iter, 0);
    defer std.testing.allocator.free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expectEqual(control.next(), engine.next());
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

    var checked_values = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7 };
    const checked_head = try partialShuffleCheckedFrom(&engine, u8, &checked_values, 3);
    try std.testing.expectEqual(@as(usize, 3), checked_head.len);

    var split_values = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7 };
    const split = partialShuffleSplitFrom(&engine, u8, &split_values, 3);
    try std.testing.expectEqual(@as(usize, 3), split.selected.len);
    try std.testing.expectEqual(@as(usize, 5), split.rest.len);
    try std.testing.expectEqualSlices(u8, split.selected, split_values[0..3]);
    try std.testing.expectEqualSlices(u8, split.rest, split_values[3..]);

    const sampled = try reservoirSample(std.testing.allocator, rng, u8, &values, 4);
    defer std.testing.allocator.free(sampled);
    try std.testing.expectEqual(@as(usize, 4), sampled.len);

    const direct_sampled = try reservoirSampleFrom(std.testing.allocator, &engine, u8, &values, 4);
    defer std.testing.allocator.free(direct_sampled);
    try std.testing.expectEqual(@as(usize, 4), direct_sampled.len);

    const checked_sampled = try reservoirSampleCheckedFrom(std.testing.allocator, &engine, u8, &values, 4);
    defer std.testing.allocator.free(checked_sampled);
    try std.testing.expectEqual(@as(usize, 4), checked_sampled.len);

    var into: [4]u8 = undefined;
    try reservoirSampleIntoFrom(&engine, u8, &values, &into);
    try std.testing.expectEqual(@as(usize, 4), into.len);

    const direct_multiple = try chooseMultipleFrom(std.testing.allocator, &engine, u8, &values, 3);
    defer std.testing.allocator.free(direct_multiple);
    try std.testing.expectEqual(@as(usize, 3), direct_multiple.len);

    const checked_multiple = try chooseMultipleCheckedFrom(std.testing.allocator, &engine, u8, &values, 3);
    defer std.testing.allocator.free(checked_multiple);
    try std.testing.expectEqual(@as(usize, 3), checked_multiple.len);
}

test "chooseArray returns fixed-size item samples" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };

    var optional_engine = alea.ScalarPrng.init(0x5150_a001);
    const optional = chooseArrayFrom(&optional_engine, u8, 3, &items).?;
    try std.testing.expectEqual(@as(usize, 3), optional.len);
    for (optional) |item| try std.testing.expect(std.mem.indexOfScalar(u8, &items, item) != null);

    var checked_engine = alea.ScalarPrng.init(0x5150_a002);
    const checked = try chooseArrayCheckedFrom(&checked_engine, u8, 4, &items);
    try std.testing.expectEqual(@as(usize, 4), checked.len);
    for (checked) |item| try std.testing.expect(std.mem.indexOfScalar(u8, &items, item) != null);

    var facade_engine = alea.ScalarPrng.init(0x5150_a003);
    const rng = Rng.init(&facade_engine);
    const facade = chooseArray(rng, u8, 2, &items).?;
    try std.testing.expectEqual(@as(usize, 2), facade.len);

    const empty = chooseArrayFrom(&facade_engine, u8, 0, &items).?;
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(chooseArrayFrom(&facade_engine, u8, 9, &items) == null);
    try std.testing.expectError(error.InvalidParameter, chooseArrayCheckedFrom(&facade_engine, u8, 9, &items));
}

test "chooseMultipleInto fills caller-owned item buffers" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    var optional_engine = alea.ScalarPrng.init(0x5150_c101);
    var optional_out: [8]u8 = undefined;
    var optional_indices: [8]usize = undefined;
    const filled = try chooseMultipleIntoFrom(&optional_engine, u8, &items, &optional_out, &optional_indices);
    try std.testing.expectEqual(@as(usize, items.len), filled);
    for (optional_out[0..filled]) |item| try std.testing.expect(std.mem.indexOfScalar(u8, &items, item) != null);

    var checked_engine = alea.ScalarPrng.init(0x5150_c102);
    var checked_out: [3]u8 = undefined;
    var checked_indices: [3]usize = undefined;
    try chooseMultipleIntoCheckedFrom(&checked_engine, u8, &items, &checked_out, &checked_indices);
    for (checked_out[0..]) |item| try std.testing.expect(std.mem.indexOfScalar(u8, &items, item) != null);

    var empty_engine = alea.ScalarPrng.init(0x5150_c103);
    var empty_control = alea.ScalarPrng.init(0x5150_c103);
    var empty_out: [0]u8 = .{};
    var empty_indices: [0]usize = .{};
    try std.testing.expectEqual(@as(usize, 0), try chooseMultipleIntoFrom(&empty_engine, u8, &items, &empty_out, &empty_indices));
    try chooseMultipleIntoCheckedFrom(&empty_engine, u8, &items, &empty_out, &empty_indices);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "chooseMultipleInto preserves facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c104);
        var direct_engine = Engine.init(0x5150_c104);
        const rng = Rng.init(&facade_engine);

        var facade_out: [3]u8 = undefined;
        var direct_out: [3]u8 = undefined;
        var facade_indices: [3]usize = undefined;
        var direct_indices: [3]usize = undefined;
        try std.testing.expectEqual(try chooseMultipleInto(rng, u8, &items, &facade_out, &facade_indices), try chooseMultipleIntoFrom(&direct_engine, u8, &items, &direct_out, &direct_indices));
        try std.testing.expectEqualSlices(u8, &facade_out, &direct_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_c105);
    var invalid_control = alea.ScalarPrng.init(0x5150_c105);
    var out: [3]u8 = undefined;
    var short_indices: [2]usize = undefined;
    try std.testing.expectError(error.LengthMismatch, chooseMultipleIntoFrom(&invalid_engine, u8, &items, &out, &short_indices));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var too_many: [6]u8 = undefined;
    var enough_indices: [6]usize = undefined;
    try std.testing.expectError(error.InvalidParameter, chooseMultipleIntoCheckedFrom(&invalid_engine, u8, &items, &too_many, &enough_indices));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "invalid chooseArray helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_a004);
    var control = alea.ScalarPrng.init(0x5150_a004);
    const rng = Rng.init(&engine);

    try std.testing.expectError(error.InvalidParameter, chooseArrayChecked(rng, u8, 4, &.{ 1, 2, 3 }));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, chooseArrayCheckedFrom(&engine, u8, 4, &.{ 1, 2, 3 }));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "chooseWeighted selects values and mutable pointers" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40 };
    const weights = [_]u32{ 0, 2, 6, 3 };

    var value_engine = alea.ScalarPrng.init(0x5150_b001);
    const value = (try chooseWeightedFrom(&value_engine, u8, u32, &items, &weights)).?;
    try std.testing.expect(std.mem.indexOfScalar(u8, &items, value) != null);

    var checked_engine = alea.ScalarPrng.init(0x5150_b002);
    const checked = try chooseWeightedCheckedFrom(&checked_engine, u8, u32, &items, &weights);
    try std.testing.expect(std.mem.indexOfScalar(u8, &items, checked) != null);

    var mutable = items;
    var ptr_engine = alea.ScalarPrng.init(0x5150_b003);
    const ptr = (try chooseWeightedPtrFrom(&ptr_engine, u8, u32, &mutable, &weights)).?;
    ptr.* += 1;
    try std.testing.expect(std.mem.indexOfScalar(u8, &mutable, ptr.*) != null);

    var single_engine = alea.ScalarPrng.init(0x5150_b004);
    var single_control = alea.ScalarPrng.init(0x5150_b004);
    try std.testing.expectEqual(@as(u8, 30), (try chooseWeightedFrom(&single_engine, u8, u32, &items, &.{ 0, 0, 5, 0 })).?);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_b005);
    try std.testing.expect((try chooseWeightedFrom(&empty_engine, u8, u32, &.{}, &.{})) == null);
    try std.testing.expect((try chooseWeightedFrom(&empty_engine, u8, u32, &items, &.{ 0, 0, 0, 0 })) == null);
    try std.testing.expectError(error.EmptyInput, chooseWeightedCheckedFrom(&empty_engine, u8, u32, &items, &.{ 0, 0, 0, 0 }));
}

test "chooseWeighted preserves facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40 };
    const weights = [_]f64{ 1, 2, 6, 3 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_b006);
        var direct_engine = Engine.init(0x5150_b006);
        const rng = Rng.init(&facade_engine);

        const facade = (try chooseWeighted(rng, u8, f64, &items, &weights)).?;
        const direct = (try chooseWeightedFrom(&direct_engine, u8, f64, &items, &weights)).?;
        try std.testing.expectEqual(facade, direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_mutable = items;
        var direct_mutable = items;
        const facade_ptr = (try chooseWeightedPtr(rng, u8, f64, &facade_mutable, &weights)).?;
        const direct_ptr = (try chooseWeightedPtrFrom(&direct_engine, u8, f64, &direct_mutable, &weights)).?;
        try std.testing.expectEqual(@intFromPtr(facade_ptr) - @intFromPtr(&facade_mutable[0]), @intFromPtr(direct_ptr) - @intFromPtr(&direct_mutable[0]));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_b007);
    var invalid_control = alea.ScalarPrng.init(0x5150_b007);
    const invalid_rng = Rng.init(&invalid_engine);
    try std.testing.expectError(error.LengthMismatch, chooseWeighted(invalid_rng, u8, u32, &items, &.{ 1, 2 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrFrom(&invalid_engine, u8, f64, @constCast(&items), &.{ 1.0, std.math.inf(f64), 2.0, 3.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "collection sequence helpers preserve direct stream shape" {
    const alea = @import("root.zig");
    const items = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c012);
        var direct_engine = Engine.init(0x5150_c012);
        const rng = Rng.init(&facade_engine);

        var facade_values = items;
        var direct_values = items;
        const facade_head = partialShuffle(rng, u8, &facade_values, 3);
        const direct_head = partialShuffleFrom(&direct_engine, u8, &direct_values, 3);
        try std.testing.expectEqualSlices(u8, facade_head, direct_head);
        try std.testing.expectEqualSlices(u8, &facade_values, &direct_values);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_split_values = items;
        var direct_split_values = items;
        const facade_split = partialShuffleSplit(rng, u8, &facade_split_values, 3);
        const direct_split = partialShuffleSplitFrom(&direct_engine, u8, &direct_split_values, 3);
        try std.testing.expectEqualSlices(u8, facade_split.selected, direct_split.selected);
        try std.testing.expectEqualSlices(u8, facade_split.rest, direct_split.rest);
        try std.testing.expectEqualSlices(u8, &facade_split_values, &direct_split_values);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const sampled = try reservoirSample(std.testing.allocator, rng, u8, &items, 4);
        defer std.testing.allocator.free(sampled);
        const direct_sampled = try reservoirSampleFrom(std.testing.allocator, &direct_engine, u8, &items, 4);
        defer std.testing.allocator.free(direct_sampled);
        try std.testing.expectEqualSlices(u8, sampled, direct_sampled);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var into: [4]u8 = undefined;
        var direct_into: [4]u8 = undefined;
        try reservoirSampleInto(rng, u8, &items, &into);
        try reservoirSampleIntoFrom(&direct_engine, u8, &items, &direct_into);
        try std.testing.expectEqualSlices(u8, &into, &direct_into);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const multiple = try chooseMultiple(std.testing.allocator, rng, u8, &items, 3);
        defer std.testing.allocator.free(multiple);
        const direct_multiple = try chooseMultipleFrom(std.testing.allocator, &direct_engine, u8, &items, 3);
        defer std.testing.allocator.free(direct_multiple);
        try std.testing.expectEqualSlices(u8, multiple, direct_multiple);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const array = chooseArray(rng, u8, 3, &items).?;
        const direct_array = chooseArrayFrom(&direct_engine, u8, 3, &items).?;
        try std.testing.expectEqualSlices(u8, &array, &direct_array);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const RangeIter = struct {
            next_value: u8 = 0,
            end: u8,

            fn next(self: *@This()) ?u8 {
                if (self.next_value >= self.end) return null;
                const value = self.next_value;
                self.next_value += 1;
                return value;
            }
        };
        var facade_iter = RangeIter{ .end = 20 };
        var direct_iter = RangeIter{ .end = 20 };
        var iterator_into: [5]u8 = undefined;
        var direct_iterator_into: [5]u8 = undefined;
        try std.testing.expectEqual(sampleIteratorInto(rng, u8, &facade_iter, &iterator_into), sampleIteratorIntoFrom(&direct_engine, u8, &direct_iter, &direct_iterator_into));
        try std.testing.expectEqualSlices(u8, &iterator_into, &direct_iterator_into);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
}

test "empty choice iterator helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_c0df);
    var control = alea.ScalarPrng.init(0x5150_c0df);
    const rng = alea.Rng.init(&engine);

    try std.testing.expect(chooseIter(rng, u8, &.{}) == null);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expect(chooseIterFrom(&engine, u8, &.{}) == null);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyInput, chooseIterChecked(rng, u8, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyInput, chooseIterCheckedFrom(&engine, u8, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "choice sampler repeatedly samples slice references" {
    const alea = @import("root.zig");
    var engine = alea.DefaultPrng.init(445);
    const rng = alea.Rng.init(&engine);

    const values = [_]u8{ 2, 4, 6, 8 };
    const choice = Choice(u8).init(&values).?;
    const checked_choice = try Choice(u8).initChecked(&values);
    try std.testing.expectEqual(@as(usize, 4), choice.len());
    try std.testing.expect(!choice.isEmpty());
    try std.testing.expectEqual(@as(usize, 4), checked_choice.len());
    try std.testing.expectEqualSlices(u8, &values, choice.itemsValue());
    try std.testing.expectEqual(&values[2], try choice.itemAt(2));
    try std.testing.expectError(error.InvalidParameter, choice.itemAt(4));
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), try choice.probabilityAt(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0.25), try choice.probabilityAt(3), 1e-12);
    try std.testing.expectError(error.InvalidParameter, choice.probabilityAt(4));
    var choice_probabilities: [4]f64 = undefined;
    try choice.probabilitiesInto(&choice_probabilities);
    for (choice_probabilities) |probability| try std.testing.expectApproxEqAbs(@as(f64, 0.25), probability, 1e-12);
    var wrong_probability_len: [3]f64 = undefined;
    try std.testing.expectError(error.LengthMismatch, choice.probabilitiesInto(&wrong_probability_len));
    const owned_probabilities = try choice.probabilities(std.testing.allocator);
    defer std.testing.allocator.free(owned_probabilities);
    try std.testing.expectEqualSlices(f64, &choice_probabilities, owned_probabilities);
    try std.testing.expect(Choice(u8).init(&.{}) == null);
    try std.testing.expectError(error.EmptyInput, Choice(u8).initChecked(&.{}));

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
    var direct_convenience_iter = chooseIterFrom(&engine, u8, &values).?;
    const direct_picked = direct_convenience_iter.next().?.*;
    try std.testing.expect(direct_picked == 2 or direct_picked == 4 or direct_picked == 6 or direct_picked == 8);
    var checked_iter = try chooseIterChecked(rng, u8, &values);
    const checked_picked = checked_iter.next().?.*;
    try std.testing.expect(checked_picked == 2 or checked_picked == 4 or checked_picked == 6 or checked_picked == 8);
    var checked_direct_iter = try chooseIterCheckedFrom(&engine, u8, &values);
    const checked_direct_picked = checked_direct_iter.next().?.*;
    try std.testing.expect(checked_direct_picked == 2 or checked_direct_picked == 4 or checked_direct_picked == 6 or checked_direct_picked == 8);
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
    try std.testing.expect(chooseIterFrom(&engine, u8, &.{}) == null);
    try std.testing.expectError(error.EmptyInput, chooseIterChecked(rng, u8, &.{}));
    try std.testing.expectError(error.EmptyInput, chooseIterCheckedFrom(&engine, u8, &.{}));
}

test "zero-length choice fills do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_c0de);
    var control = alea.ScalarPrng.init(0x5150_c0de);

    const values = [_]u8{ 2, 4, 6, 8 };
    const choice = Choice(u8).init(&values).?;
    var pointer_buf: [0]*const u8 = .{};
    choice.fillFrom(&engine, &pointer_buf);
    try std.testing.expectEqual(control.next(), engine.next());
    var value_buf: [0]u8 = .{};
    choice.fillValuesFrom(&engine, &value_buf);
    try std.testing.expectEqual(control.next(), engine.next());

    const labels = [_][]const u8{ "never", "rare", "often" };
    var weighted = try WeightedChoice([]const u8, u32).init(std.testing.allocator, &labels, &.{ 0, 1, 7 });
    defer weighted.deinit();
    var weighted_pointer_buf: [0]*const []const u8 = .{};
    weighted.fillFrom(&engine, &weighted_pointer_buf);
    try std.testing.expectEqual(control.next(), engine.next());
    var weighted_value_buf: [0][]const u8 = .{};
    weighted.fillValuesFrom(&engine, &weighted_value_buf);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "single-item choice sampler does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_c0df);
    var control = alea.ScalarPrng.init(0x5150_c0df);

    const values = [_]u8{42};
    const choice = Choice(u8).init(&values).?;

    try std.testing.expectEqual(&values[0], choice.sampleFrom(&engine));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(u8, 42), choice.sampleValueFrom(&engine));
    try std.testing.expectEqual(control.next(), engine.next());

    var pointer_buf: [4]*const u8 = undefined;
    choice.fillFrom(&engine, &pointer_buf);
    for (pointer_buf) |item| try std.testing.expectEqual(&values[0], item);
    try std.testing.expectEqual(control.next(), engine.next());

    var value_buf: [4]u8 = undefined;
    choice.fillValuesFrom(&engine, &value_buf);
    for (value_buf) |item| try std.testing.expectEqual(@as(u8, 42), item);
    try std.testing.expectEqual(control.next(), engine.next());

    var iter = choice.iterFrom(&engine);
    try std.testing.expectEqual(&values[0], iter.next().?);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "weighted choice init allocation failure cleans up" {
    const items = [_]u8{ 1, 2, 3 };
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, WeightedChoice(u8, u32).init(failing.allocator(), &items, &.{ 1, 2, 3 }));
    try std.testing.expect(failing.has_induced_failure);
}

test "weighted choice sampler maps alias indexes to items" {
    const alea = @import("root.zig");
    var engine = alea.FastPrng.init(446);
    const rng = alea.Rng.init(&engine);

    const labels = [_][]const u8{ "never", "rare", "often" };
    var choice = try WeightedChoice([]const u8, u32).init(std.testing.allocator, &labels, &.{ 0, 1, 7 });
    defer choice.deinit();

    try std.testing.expectEqual(@as(usize, 3), choice.len());
    try std.testing.expect(!choice.isEmpty());
    try std.testing.expectEqualSlices([]const u8, &labels, choice.itemsValue());
    try std.testing.expectEqual(&labels[1], try choice.itemAt(1));
    try std.testing.expectError(error.InvalidParameter, choice.itemAt(3));
    try std.testing.expectApproxEqAbs(@as(f64, 8), choice.totalWeight(), 1e-12);
    var reconstructed_weights: [3]f64 = undefined;
    try choice.weightsInto(&reconstructed_weights);
    try std.testing.expectApproxEqAbs(@as(f64, 0), reconstructed_weights[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), reconstructed_weights[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 7), reconstructed_weights[2], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), try choice.weightAt(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), try choice.weightAt(1), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 7), try choice.weightAt(2), 1e-12);
    try std.testing.expectError(error.InvalidParameter, choice.weightAt(3));
    try std.testing.expectApproxEqAbs(@as(f64, 0), try choice.probabilityAt(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 8.0), try choice.probabilityAt(1), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 7.0 / 8.0), try choice.probabilityAt(2), 1e-12);
    try std.testing.expectError(error.InvalidParameter, choice.probabilityAt(3));
    var reconstructed_probabilities: [3]f64 = undefined;
    try choice.probabilitiesInto(&reconstructed_probabilities);
    try std.testing.expectApproxEqAbs(@as(f64, 0), reconstructed_probabilities[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 8.0), reconstructed_probabilities[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 7.0 / 8.0), reconstructed_probabilities[2], 1e-12);
    var wrong_weight_len: [2]f64 = undefined;
    try std.testing.expectError(error.LengthMismatch, choice.weightsInto(&wrong_weight_len));
    try std.testing.expectError(error.LengthMismatch, choice.probabilitiesInto(&wrong_weight_len));
    const owned_weights = try choice.weights(std.testing.allocator);
    defer std.testing.allocator.free(owned_weights);
    try std.testing.expectEqualSlices(f64, &reconstructed_weights, owned_weights);
    const owned_probabilities = try choice.probabilities(std.testing.allocator);
    defer std.testing.allocator.free(owned_probabilities);
    try std.testing.expectEqualSlices(f64, &reconstructed_probabilities, owned_probabilities);

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

    try choice.update(&.{ 0, 0, 5 });
    try std.testing.expectApproxEqAbs(@as(f64, 5), choice.totalWeight(), 1e-12);
    try choice.weightsInto(&reconstructed_weights);
    try std.testing.expectApproxEqAbs(@as(f64, 0), reconstructed_weights[0], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), reconstructed_weights[1], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5), reconstructed_weights[2], 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5), try choice.weightAt(2), 1e-12);
    try std.testing.expect(std.mem.eql(u8, choice.sampleFrom(&engine).*, "often"));
    try std.testing.expectError(error.LengthMismatch, choice.update(&.{ 1, 2 }));
    try std.testing.expectError(error.InvalidWeight, choice.update(&.{ 0, 0, 0 }));
    var after_failed_update: [4][]const u8 = undefined;
    choice.fillValuesFrom(&engine, &after_failed_update);
    for (after_failed_update) |value| try std.testing.expect(std.mem.eql(u8, value, "often"));

    try std.testing.expectError(error.EmptyInput, WeightedChoice(u8, u32).init(std.testing.allocator, &.{}, &.{}));
    try std.testing.expectError(error.LengthMismatch, WeightedChoice(u8, u32).init(std.testing.allocator, &.{1}, &.{ 1, 2 }));

    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, choice.weights(failing.allocator()));
    try std.testing.expect(failing.has_induced_failure);
}

test "single-positive weighted choice does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_0445);
    var control = alea.ScalarPrng.init(0x5150_0445);

    const items = [_]u8{ 10, 20, 30 };
    var choice = try WeightedChoice(u8, u32).init(std.testing.allocator, &items, &.{ 0, 5, 0 });
    defer choice.deinit();

    try std.testing.expectEqual(@as(u8, 20), choice.sampleFrom(&engine).*);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(u8, 20), choice.sampleValueFrom(&engine));
    try std.testing.expectEqual(control.next(), engine.next());

    var pointer_buf: [4]*const u8 = undefined;
    choice.fillFrom(&engine, &pointer_buf);
    for (pointer_buf) |item| try std.testing.expectEqual(@as(u8, 20), item.*);
    try std.testing.expectEqual(control.next(), engine.next());

    var value_buf: [4]u8 = undefined;
    choice.fillValuesFrom(&engine, &value_buf);
    for (value_buf) |item| try std.testing.expectEqual(@as(u8, 20), item);
    try std.testing.expectEqual(control.next(), engine.next());

    try choice.update(&.{ 0, 0, 7 });
    try std.testing.expectEqual(@as(u8, 30), choice.sampleValueFrom(&engine));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "weighted choice update rejects invalid float weights without replacing table" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_0446);

    const items = [_]u8{ 1, 2, 3 };
    var choice = try WeightedChoice(u8, f64).init(std.testing.allocator, &items, &.{ 0, 0, 1 });
    defer choice.deinit();

    try std.testing.expectError(error.InvalidWeight, choice.update(&.{ 0, std.math.nan(f64), 1 }));
    var out: [4]u8 = undefined;
    choice.fillValuesFrom(&engine, &out);
    for (out) |value| try std.testing.expectEqual(@as(u8, 3), value);
}

test "weighted choice update allocation failure preserves table" {
    const alea = @import("root.zig");

    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{});
    const items = [_]u8{ 1, 2, 3 };
    var choice = try WeightedChoice(u8, u32).init(failing.allocator(), &items, &.{ 0, 0, 1 });
    defer choice.deinit();

    var engine = alea.ScalarPrng.init(0x5150_0447);
    var control = alea.ScalarPrng.init(0x5150_0447);
    failing.fail_index = failing.alloc_index;
    try std.testing.expectError(error.OutOfMemory, choice.update(&.{ 1, 2, 3 }));
    try std.testing.expect(failing.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var out: [8]u8 = undefined;
    choice.fillValuesFrom(&engine, &out);
    for (out) |value| try std.testing.expectEqual(@as(u8, 3), value);
}

test "weighted choice length mismatch update does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_0448);

    const items = [_]u8{ 1, 2, 3 };
    var choice = try WeightedChoice(u8, u32).init(std.testing.allocator, &items, &.{ 0, 0, 1 });
    defer choice.deinit();

    try std.testing.expectError(error.LengthMismatch, choice.update(&.{ 1, 2 }));
    try std.testing.expectEqual(@as(u64, 0x591a834aea6177d9), engine.next());
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

    const checked_indices = try sampleWeightedIndicesCheckedFrom(std.testing.allocator, &engine, f64, &weights, 3);
    defer std.testing.allocator.free(checked_indices);
    try std.testing.expectEqual(@as(usize, 3), checked_indices.len);

    const direct_sample = try sampleWeightedFrom(std.testing.allocator, &engine, u8, f64, &items, &weights, 2);
    defer std.testing.allocator.free(direct_sample);
    try std.testing.expectEqual(@as(usize, 2), direct_sample.len);
    for (direct_sample) |item| try std.testing.expect(item == 20 or item == 30 or item == 50);

    const checked_sample = try sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, f64, &items, &weights, 2);
    defer std.testing.allocator.free(checked_sample);
    try std.testing.expectEqual(@as(usize, 2), checked_sample.len);
    for (checked_sample) |item| try std.testing.expect(item == 20 or item == 30 or item == 50);

    const empty_checked_indices = try sampleWeightedIndicesCheckedFrom(std.testing.allocator, &engine, u32, &.{}, 0);
    defer std.testing.allocator.free(empty_checked_indices);
    try std.testing.expectEqual(@as(usize, 0), empty_checked_indices.len);
    const invalid_empty_checked_indices = try sampleWeightedIndicesCheckedFrom(std.testing.allocator, &engine, f64, &.{std.math.nan(f64)}, 0);
    defer std.testing.allocator.free(invalid_empty_checked_indices);
    try std.testing.expectEqual(@as(usize, 0), invalid_empty_checked_indices.len);
    const empty_checked_sample = try sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, u32, &.{}, &.{1}, 0);
    defer std.testing.allocator.free(empty_checked_sample);
    try std.testing.expectEqual(@as(usize, 0), empty_checked_sample.len);
    const invalid_empty_checked_sample = try sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, f64, &.{1}, &.{std.math.nan(f64)}, 0);
    defer std.testing.allocator.free(invalid_empty_checked_sample);
    try std.testing.expectEqual(@as(usize, 0), invalid_empty_checked_sample.len);

    try std.testing.expectError(error.EmptyInput, sampleWeightedIndices(std.testing.allocator, rng, u32, &.{}, 1));
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesFrom(std.testing.allocator, &engine, u32, &.{}, 1));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesChecked(std.testing.allocator, rng, u32, &.{ 1, 2 }, 3));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesCheckedFrom(std.testing.allocator, &engine, u32, &.{ 1, 2 }, 3));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndices(std.testing.allocator, rng, f64, &.{ 1.0, std.math.nan(f64) }, 1));
    try std.testing.expectError(error.LengthMismatch, sampleWeighted(std.testing.allocator, rng, u8, u32, &.{ 1, 2 }, &.{1}, 1));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedFrom(std.testing.allocator, &engine, u8, u32, &.{ 1, 2 }, &.{1}, 1));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, u32, &.{ 1, 2 }, &.{1}, 3));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedChecked(std.testing.allocator, rng, u8, u32, &.{ 1, 2 }, &.{ 1, 2 }, 3));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, u32, &.{ 1, 2 }, &.{ 1, 2 }, 3));
}

test "weighted sampling without replacement preserves direct stream shape" {
    const alea = @import("root.zig");
    const weights = [_]f64{ 0, 1, 5, 0, 9 };
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var unchecked = Engine.init(0x5150_0447);
        var direct = Engine.init(0x5150_0447);

        const rng = Rng.init(&unchecked);
        const indices = try sampleWeightedIndices(std.testing.allocator, rng, f64, &weights, 4);
        defer std.testing.allocator.free(indices);
        const direct_indices = try sampleWeightedIndicesFrom(std.testing.allocator, &direct, f64, &weights, 4);
        defer std.testing.allocator.free(direct_indices);
        try std.testing.expectEqualSlices(usize, indices, direct_indices);
        try std.testing.expectEqual(unchecked.next(), direct.next());

        const sample = try sampleWeighted(std.testing.allocator, rng, u8, f64, &items, &weights, 2);
        defer std.testing.allocator.free(sample);
        const direct_sample = try sampleWeightedFrom(std.testing.allocator, &direct, u8, f64, &items, &weights, 2);
        defer std.testing.allocator.free(direct_sample);
        try std.testing.expectEqualSlices(u8, sample, direct_sample);
        try std.testing.expectEqual(unchecked.next(), direct.next());
    }
}

test "sampleWeightedArray returns fixed-size weighted item samples" {
    const alea = @import("root.zig");
    const weights = [_]u32{ 0, 1, 5, 0, 9 };
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    var optional_engine = alea.ScalarPrng.init(0x5150_ba01);
    const optional = (try sampleWeightedArrayFrom(&optional_engine, u8, u32, 2, &items, &weights)).?;
    try std.testing.expectEqual(@as(usize, 2), optional.len);
    for (optional) |item| try std.testing.expect(item == 20 or item == 30 or item == 50);

    var checked_engine = alea.ScalarPrng.init(0x5150_ba02);
    const checked = try sampleWeightedArrayCheckedFrom(&checked_engine, u8, u32, 3, &items, &weights);
    try std.testing.expectEqual(@as(usize, 3), checked.len);
    for (checked) |item| try std.testing.expect(item == 20 or item == 30 or item == 50);

    var single_engine = alea.ScalarPrng.init(0x5150_ba03);
    var single_control = alea.ScalarPrng.init(0x5150_ba03);
    const single = (try sampleWeightedArrayFrom(&single_engine, u8, u32, 1, &items, &.{ 0, 0, 7, 0, 0 })).?;
    try std.testing.expectEqual(@as(u8, 30), single[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_ba04);
    const empty = try sampleWeightedArrayFrom(&empty_engine, u8, u32, 0, &items, &weights);
    try std.testing.expectEqual(@as(usize, 0), empty.?.len);
    try std.testing.expect((try sampleWeightedArrayFrom(&empty_engine, u8, u32, 4, &items, &weights)) == null);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedArrayCheckedFrom(&empty_engine, u8, u32, 4, &items, &weights));
}

test "sampleWeightedArray preserves facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const weights = [_]f64{ 1, 2, 6, 3 };
    const items = [_]u8{ 10, 20, 30, 40 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_ba05);
        var direct_engine = Engine.init(0x5150_ba05);
        const rng = Rng.init(&facade_engine);

        const facade = (try sampleWeightedArray(rng, u8, f64, 2, &items, &weights)).?;
        const direct = (try sampleWeightedArrayFrom(&direct_engine, u8, f64, 2, &items, &weights)).?;
        try std.testing.expectEqualSlices(u8, &facade, &direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade = try sampleWeightedArrayChecked(rng, u8, f64, 2, &items, &weights);
        const checked_direct = try sampleWeightedArrayCheckedFrom(&direct_engine, u8, f64, 2, &items, &weights);
        try std.testing.expectEqualSlices(u8, &checked_facade, &checked_direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_ba06);
    var invalid_control = alea.ScalarPrng.init(0x5150_ba06);
    const rng = Rng.init(&invalid_engine);
    try std.testing.expectError(error.LengthMismatch, sampleWeightedArray(rng, u8, f64, 2, &items, &.{ 1.0, 2.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedArrayCheckedFrom(&invalid_engine, u8, f64, 2, &items, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "sampleWeightedIndexArray returns fixed-size weighted indexes" {
    const alea = @import("root.zig");
    const weights = [_]u32{ 0, 1, 5, 0, 9 };

    var optional_engine = alea.ScalarPrng.init(0x5150_ba11);
    const optional = (try sampleWeightedIndexArrayFrom(&optional_engine, u32, 2, &weights)).?;
    try std.testing.expectEqual(@as(usize, 2), optional.len);
    for (optional) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

    var checked_engine = alea.ScalarPrng.init(0x5150_ba12);
    const checked = try sampleWeightedIndexArrayCheckedFrom(&checked_engine, u32, 3, &weights);
    try std.testing.expectEqual(@as(usize, 3), checked.len);
    for (checked) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

    var single_engine = alea.ScalarPrng.init(0x5150_ba13);
    var single_control = alea.ScalarPrng.init(0x5150_ba13);
    const single = (try sampleWeightedIndexArrayFrom(&single_engine, u32, 1, &.{ 0, 0, 7, 0, 0 })).?;
    try std.testing.expectEqual(@as(usize, 2), single[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_ba14);
    var empty_control = alea.ScalarPrng.init(0x5150_ba14);
    const empty = try sampleWeightedIndexArrayFrom(&empty_engine, u32, 0, &weights);
    try std.testing.expectEqual(@as(usize, 0), empty.?.len);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
    try std.testing.expect((try sampleWeightedIndexArrayFrom(&empty_engine, u32, 4, &weights)) == null);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayCheckedFrom(&empty_engine, u32, 4, &weights));
}

test "sampleWeightedIndexArray preserves facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const weights = [_]f64{ 1, 2, 6, 3 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_ba15);
        var direct_engine = Engine.init(0x5150_ba15);
        const rng = Rng.init(&facade_engine);

        const facade = (try sampleWeightedIndexArray(rng, f64, 2, &weights)).?;
        const direct = (try sampleWeightedIndexArrayFrom(&direct_engine, f64, 2, &weights)).?;
        try std.testing.expectEqualSlices(usize, &facade, &direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade = try sampleWeightedIndexArrayChecked(rng, f64, 2, &weights);
        const checked_direct = try sampleWeightedIndexArrayCheckedFrom(&direct_engine, f64, 2, &weights);
        try std.testing.expectEqualSlices(usize, &checked_facade, &checked_direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_ba16);
    var invalid_control = alea.ScalarPrng.init(0x5150_ba16);
    const rng = Rng.init(&invalid_engine);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayChecked(rng, f64, 5, &weights));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayCheckedFrom(&invalid_engine, f64, 2, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "sampleWeightedIndicesInto fills caller-owned index buffers" {
    const alea = @import("root.zig");
    const weights = [_]u32{ 0, 1, 5, 0, 9 };

    var optional_engine = alea.ScalarPrng.init(0x5150_ba31);
    var optional_out: [4]usize = undefined;
    var optional_keys: [4]f64 = undefined;
    const filled = try sampleWeightedIndicesIntoFrom(&optional_engine, u32, &weights, &optional_out, &optional_keys);
    try std.testing.expectEqual(@as(usize, 3), filled);
    for (optional_out[0..filled]) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

    var checked_engine = alea.ScalarPrng.init(0x5150_ba32);
    var checked_out: [3]usize = undefined;
    var checked_keys: [3]f64 = undefined;
    try sampleWeightedIndicesIntoCheckedFrom(&checked_engine, u32, &weights, &checked_out, &checked_keys);
    for (checked_out[0..]) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

    var single_engine = alea.ScalarPrng.init(0x5150_ba33);
    var single_control = alea.ScalarPrng.init(0x5150_ba33);
    var single_out: [3]usize = undefined;
    var single_keys: [3]f64 = undefined;
    const single_filled = try sampleWeightedIndicesIntoFrom(&single_engine, u32, &.{ 0, 0, 7, 0, 0 }, &single_out, &single_keys);
    try std.testing.expectEqual(@as(usize, 1), single_filled);
    try std.testing.expectEqual(@as(usize, 2), single_out[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_ba34);
    var empty_control = alea.ScalarPrng.init(0x5150_ba34);
    var empty_out: [0]usize = .{};
    var empty_keys: [0]f64 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesIntoFrom(&empty_engine, u32, &weights, &empty_out, &empty_keys));
    try sampleWeightedIndicesIntoCheckedFrom(&empty_engine, u32, &weights, &empty_out, &empty_keys);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "sampleWeightedIndicesInto preserves facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const weights = [_]f64{ 1, 2, 6, 3 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_ba35);
        var direct_engine = Engine.init(0x5150_ba35);
        const rng = Rng.init(&facade_engine);

        var facade_out: [3]usize = undefined;
        var direct_out: [3]usize = undefined;
        var facade_keys: [3]f64 = undefined;
        var direct_keys: [3]f64 = undefined;
        try std.testing.expectEqual(try sampleWeightedIndicesInto(rng, f64, &weights, &facade_out, &facade_keys), try sampleWeightedIndicesIntoFrom(&direct_engine, f64, &weights, &direct_out, &direct_keys));
        try std.testing.expectEqualSlices(usize, &facade_out, &direct_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_facade_out: [2]usize = undefined;
        var checked_direct_out: [2]usize = undefined;
        var checked_facade_keys: [2]f64 = undefined;
        var checked_direct_keys: [2]f64 = undefined;
        try sampleWeightedIndicesIntoChecked(rng, f64, &weights, &checked_facade_out, &checked_facade_keys);
        try sampleWeightedIndicesIntoCheckedFrom(&direct_engine, f64, &weights, &checked_direct_out, &checked_direct_keys);
        try std.testing.expectEqualSlices(usize, &checked_facade_out, &checked_direct_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_ba36);
    var invalid_control = alea.ScalarPrng.init(0x5150_ba36);
    var out: [2]usize = undefined;
    var short_keys: [1]f64 = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedIndicesIntoFrom(&invalid_engine, f64, &weights, &out, &short_keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    var keys: [2]f64 = undefined;
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesIntoCheckedFrom(&invalid_engine, f64, &.{ 1.0, std.math.nan(f64), 2.0 }, &out, &keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "sampleWeightedInto fills caller-owned item buffers" {
    const alea = @import("root.zig");
    const weights = [_]u32{ 0, 1, 5, 0, 9 };
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    var optional_engine = alea.ScalarPrng.init(0x5150_ba41);
    var optional_out: [4]u8 = undefined;
    var optional_indices: [4]usize = undefined;
    var optional_keys: [4]f64 = undefined;
    const filled = try sampleWeightedIntoFrom(&optional_engine, u8, u32, &items, &weights, &optional_out, &optional_indices, &optional_keys);
    try std.testing.expectEqual(@as(usize, 3), filled);
    for (optional_out[0..filled]) |item| try std.testing.expect(item == 20 or item == 30 or item == 50);

    var checked_engine = alea.ScalarPrng.init(0x5150_ba42);
    var checked_out: [3]u8 = undefined;
    var checked_indices: [3]usize = undefined;
    var checked_keys: [3]f64 = undefined;
    try sampleWeightedIntoCheckedFrom(&checked_engine, u8, u32, &items, &weights, &checked_out, &checked_indices, &checked_keys);
    for (checked_out[0..]) |item| try std.testing.expect(item == 20 or item == 30 or item == 50);

    var single_engine = alea.ScalarPrng.init(0x5150_ba43);
    var single_control = alea.ScalarPrng.init(0x5150_ba43);
    var single_out: [3]u8 = undefined;
    var single_indices: [3]usize = undefined;
    var single_keys: [3]f64 = undefined;
    const single_filled = try sampleWeightedIntoFrom(&single_engine, u8, u32, &items, &.{ 0, 0, 7, 0, 0 }, &single_out, &single_indices, &single_keys);
    try std.testing.expectEqual(@as(usize, 1), single_filled);
    try std.testing.expectEqual(@as(u8, 30), single_out[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_ba44);
    var empty_control = alea.ScalarPrng.init(0x5150_ba44);
    var empty_out: [0]u8 = .{};
    var empty_indices: [0]usize = .{};
    var empty_keys: [0]f64 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIntoFrom(&empty_engine, u8, u32, &items, &weights, &empty_out, &empty_indices, &empty_keys));
    try sampleWeightedIntoCheckedFrom(&empty_engine, u8, u32, &items, &weights, &empty_out, &empty_indices, &empty_keys);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "sampleWeightedInto preserves facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const weights = [_]f64{ 1, 2, 6, 3 };
    const items = [_]u8{ 10, 20, 30, 40 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_ba45);
        var direct_engine = Engine.init(0x5150_ba45);
        const rng = Rng.init(&facade_engine);

        var facade_out: [3]u8 = undefined;
        var direct_out: [3]u8 = undefined;
        var facade_indices: [3]usize = undefined;
        var direct_indices: [3]usize = undefined;
        var facade_keys: [3]f64 = undefined;
        var direct_keys: [3]f64 = undefined;
        try std.testing.expectEqual(try sampleWeightedInto(rng, u8, f64, &items, &weights, &facade_out, &facade_indices, &facade_keys), try sampleWeightedIntoFrom(&direct_engine, u8, f64, &items, &weights, &direct_out, &direct_indices, &direct_keys));
        try std.testing.expectEqualSlices(u8, &facade_out, &direct_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_facade_out: [2]u8 = undefined;
        var checked_direct_out: [2]u8 = undefined;
        var checked_facade_indices: [2]usize = undefined;
        var checked_direct_indices: [2]usize = undefined;
        var checked_facade_keys: [2]f64 = undefined;
        var checked_direct_keys: [2]f64 = undefined;
        try sampleWeightedIntoChecked(rng, u8, f64, &items, &weights, &checked_facade_out, &checked_facade_indices, &checked_facade_keys);
        try sampleWeightedIntoCheckedFrom(&direct_engine, u8, f64, &items, &weights, &checked_direct_out, &checked_direct_indices, &checked_direct_keys);
        try std.testing.expectEqualSlices(u8, &checked_facade_out, &checked_direct_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_ba46);
    var invalid_control = alea.ScalarPrng.init(0x5150_ba46);
    var out: [2]u8 = undefined;
    var indices: [2]usize = undefined;
    var short_indices: [1]usize = undefined;
    var keys: [2]f64 = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedIntoFrom(&invalid_engine, u8, f64, &items, &weights, &out, &short_indices, &keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIntoCheckedFrom(&invalid_engine, u8, f64, &items, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }, &out, &indices, &keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
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

    var checked_choose_iter = RangeIter{ .next_value = 0, .end = 100 };
    const checked_chosen = try chooseIteratorCheckedFrom(&engine, u32, &checked_choose_iter);
    try std.testing.expect(checked_chosen < 100);

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
    var checked_sample_iter = RangeIter{ .next_value = 0, .end = 100 };
    const checked_sample = try sampleIteratorCheckedFrom(std.testing.allocator, &engine, u32, &checked_sample_iter, 8);
    defer std.testing.allocator.free(checked_sample);
    try std.testing.expectEqual(@as(usize, 8), checked_sample.len);
    for (checked_sample) |item| try std.testing.expect(item < 100);

    var short_iter = RangeIter{ .next_value = 0, .end = 3 };
    const short = try sampleIterator(std.testing.allocator, rng, u32, &short_iter, 8);
    defer std.testing.allocator.free(short);
    try std.testing.expectEqual(@as(usize, 3), short.len);
    var short_checked_iter = RangeIter{ .next_value = 0, .end = 3 };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorCheckedFrom(std.testing.allocator, &engine, u32, &short_checked_iter, 8));

    var empty_checked_iter = RangeIter{ .next_value = 0, .end = 0 };
    try std.testing.expectError(error.EmptyInput, chooseIteratorCheckedFrom(&engine, u32, &empty_checked_iter));
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

    var checked_iter = WeightedIter{ .items = &entries };
    const checked_picked = try chooseIteratorWeightedCheckedFrom(&engine, u8, &checked_iter);
    try std.testing.expect(checked_picked == 2 or checked_picked == 3);

    var empty_iter = WeightedIter{ .items = &.{} };
    try std.testing.expect((try chooseIteratorWeighted(rng, u8, &empty_iter)) == null);
    var empty_checked_iter = WeightedIter{ .items = &.{} };
    try std.testing.expectError(error.EmptyInput, chooseIteratorWeightedCheckedFrom(&engine, u8, &empty_checked_iter));

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
    var checked_sample_iter = WeightedIter{ .items = &entries };
    const checked_sample = try sampleIteratorWeightedCheckedFrom(std.testing.allocator, &engine, u8, &checked_sample_iter, 2);
    defer std.testing.allocator.free(checked_sample);
    try std.testing.expectEqual(@as(usize, 2), checked_sample.len);
    for (checked_sample) |item| try std.testing.expect(item == 2 or item == 3);

    var short_weighted_iter = WeightedIter{ .items = entries[0..1] };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedCheckedFrom(std.testing.allocator, &engine, u8, &short_weighted_iter, 2));
}

test "sampleIteratorWeightedArray returns fixed-size weighted iterator samples" {
    const alea = @import("root.zig");

    const Entry = struct { item: u8, weight: f64 };
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
        .{ .item = 10, .weight = 0 },
        .{ .item = 20, .weight = 1 },
        .{ .item = 30, .weight = 5 },
        .{ .item = 40, .weight = 9 },
    };

    var optional_engine = alea.ScalarPrng.init(0x5150_ba21);
    var optional_iter = WeightedIter{ .items = &entries };
    const optional = (try sampleIteratorWeightedArrayFrom(&optional_engine, u8, 2, &optional_iter)).?;
    try std.testing.expectEqual(@as(usize, 2), optional.len);
    for (optional) |item| try std.testing.expect(item == 20 or item == 30 or item == 40);

    var checked_engine = alea.ScalarPrng.init(0x5150_ba22);
    var checked_iter = WeightedIter{ .items = &entries };
    const checked = try sampleIteratorWeightedArrayCheckedFrom(&checked_engine, u8, 3, &checked_iter);
    try std.testing.expectEqual(@as(usize, 3), checked.len);
    for (checked) |item| try std.testing.expect(item == 20 or item == 30 or item == 40);

    var single_engine = alea.ScalarPrng.init(0x5150_ba23);
    var single_control = alea.ScalarPrng.init(0x5150_ba23);
    var single_iter = WeightedIter{ .items = &.{ .{ .item = 7, .weight = 0 }, .{ .item = 8, .weight = 5 } } };
    const single = (try sampleIteratorWeightedArrayFrom(&single_engine, u8, 1, &single_iter)).?;
    try std.testing.expectEqual(@as(u8, 8), single[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_ba24);
    var empty_control = alea.ScalarPrng.init(0x5150_ba24);
    var empty_iter = WeightedIter{ .items = &entries };
    const empty = try sampleIteratorWeightedArrayFrom(&empty_engine, u8, 0, &empty_iter);
    try std.testing.expectEqual(@as(usize, 0), empty.?.len);
    try std.testing.expectEqual(@as(usize, 0), empty_iter.index);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());

    var short_iter = WeightedIter{ .items = &entries };
    try std.testing.expect((try sampleIteratorWeightedArrayFrom(&empty_engine, u8, 4, &short_iter)) == null);
    var short_checked_iter = WeightedIter{ .items = &entries };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedArrayCheckedFrom(&empty_engine, u8, 4, &short_checked_iter));
}

test "sampleIteratorWeightedArray preserves facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");

    const Entry = struct { item: u8, weight: f64 };
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
        .{ .item = 10, .weight = 1 },
        .{ .item = 20, .weight = 2 },
        .{ .item = 30, .weight = 6 },
        .{ .item = 40, .weight = 3 },
    };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_ba25);
        var direct_engine = Engine.init(0x5150_ba25);
        const rng = Rng.init(&facade_engine);

        var facade_iter = WeightedIter{ .items = &entries };
        var direct_iter = WeightedIter{ .items = &entries };
        const facade = (try sampleIteratorWeightedArray(rng, u8, 2, &facade_iter)).?;
        const direct = (try sampleIteratorWeightedArrayFrom(&direct_engine, u8, 2, &direct_iter)).?;
        try std.testing.expectEqualSlices(u8, &facade, &direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_facade_iter = WeightedIter{ .items = &entries };
        var checked_direct_iter = WeightedIter{ .items = &entries };
        const checked_facade = try sampleIteratorWeightedArrayChecked(rng, u8, 2, &checked_facade_iter);
        const checked_direct = try sampleIteratorWeightedArrayCheckedFrom(&direct_engine, u8, 2, &checked_direct_iter);
        try std.testing.expectEqualSlices(u8, &checked_facade, &checked_direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    const bad_entries = [_]Entry{
        .{ .item = 10, .weight = 1 },
        .{ .item = 20, .weight = std.math.nan(f64) },
    };
    var invalid_engine = alea.ScalarPrng.init(0x5150_ba26);
    var invalid_control = alea.ScalarPrng.init(0x5150_ba26);
    var invalid_iter = WeightedIter{ .items = &bad_entries };
    try std.testing.expectError(error.InvalidWeight, sampleIteratorWeightedArrayCheckedFrom(&invalid_engine, u8, 1, &invalid_iter));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "sampleIteratorWeightedInto fills caller-owned buffers" {
    const alea = @import("root.zig");

    const Entry = struct { item: u8, weight: f64 };
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
        .{ .item = 10, .weight = 0 },
        .{ .item = 20, .weight = 1 },
        .{ .item = 30, .weight = 5 },
        .{ .item = 40, .weight = 9 },
    };

    var optional_engine = alea.ScalarPrng.init(0x5150_ba51);
    var optional_iter = WeightedIter{ .items = &entries };
    var optional_out: [4]u8 = undefined;
    var optional_keys: [4]f64 = undefined;
    const filled = try sampleIteratorWeightedIntoFrom(&optional_engine, u8, &optional_iter, &optional_out, &optional_keys);
    try std.testing.expectEqual(@as(usize, 3), filled);
    for (optional_out[0..filled]) |item| try std.testing.expect(item == 20 or item == 30 or item == 40);

    var checked_engine = alea.ScalarPrng.init(0x5150_ba52);
    var checked_iter = WeightedIter{ .items = &entries };
    var checked_out: [3]u8 = undefined;
    var checked_keys: [3]f64 = undefined;
    try sampleIteratorWeightedIntoCheckedFrom(&checked_engine, u8, &checked_iter, &checked_out, &checked_keys);
    for (checked_out[0..]) |item| try std.testing.expect(item == 20 or item == 30 or item == 40);

    var single_engine = alea.ScalarPrng.init(0x5150_ba53);
    var single_control = alea.ScalarPrng.init(0x5150_ba53);
    var single_iter = WeightedIter{ .items = &.{ .{ .item = 7, .weight = 0 }, .{ .item = 8, .weight = 5 } } };
    var single_out: [4]u8 = undefined;
    var single_keys: [4]f64 = undefined;
    const single_filled = try sampleIteratorWeightedIntoFrom(&single_engine, u8, &single_iter, &single_out, &single_keys);
    try std.testing.expectEqual(@as(usize, 1), single_filled);
    try std.testing.expectEqual(@as(u8, 8), single_out[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_ba54);
    var empty_control = alea.ScalarPrng.init(0x5150_ba54);
    var empty_iter = WeightedIter{ .items = &entries };
    var empty_out: [0]u8 = .{};
    var empty_keys: [0]f64 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleIteratorWeightedIntoFrom(&empty_engine, u8, &empty_iter, &empty_out, &empty_keys));
    try sampleIteratorWeightedIntoCheckedFrom(&empty_engine, u8, &empty_iter, &empty_out, &empty_keys);
    try std.testing.expectEqual(@as(usize, 0), empty_iter.index);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "sampleIteratorWeightedInto preserves facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");

    const Entry = struct { item: u8, weight: f64 };
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
        .{ .item = 10, .weight = 1 },
        .{ .item = 20, .weight = 2 },
        .{ .item = 30, .weight = 6 },
        .{ .item = 40, .weight = 3 },
    };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_ba55);
        var direct_engine = Engine.init(0x5150_ba55);
        const rng = Rng.init(&facade_engine);

        var facade_iter = WeightedIter{ .items = &entries };
        var direct_iter = WeightedIter{ .items = &entries };
        var facade_out: [3]u8 = undefined;
        var direct_out: [3]u8 = undefined;
        var facade_keys: [3]f64 = undefined;
        var direct_keys: [3]f64 = undefined;
        try std.testing.expectEqual(try sampleIteratorWeightedInto(rng, u8, &facade_iter, &facade_out, &facade_keys), try sampleIteratorWeightedIntoFrom(&direct_engine, u8, &direct_iter, &direct_out, &direct_keys));
        try std.testing.expectEqualSlices(u8, &facade_out, &direct_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_facade_iter = WeightedIter{ .items = &entries };
        var checked_direct_iter = WeightedIter{ .items = &entries };
        var checked_facade_out: [2]u8 = undefined;
        var checked_direct_out: [2]u8 = undefined;
        var checked_facade_keys: [2]f64 = undefined;
        var checked_direct_keys: [2]f64 = undefined;
        try sampleIteratorWeightedIntoChecked(rng, u8, &checked_facade_iter, &checked_facade_out, &checked_facade_keys);
        try sampleIteratorWeightedIntoCheckedFrom(&direct_engine, u8, &checked_direct_iter, &checked_direct_out, &checked_direct_keys);
        try std.testing.expectEqualSlices(u8, &checked_facade_out, &checked_direct_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    const bad_entries = [_]Entry{
        .{ .item = 10, .weight = 1 },
        .{ .item = 20, .weight = std.math.nan(f64) },
    };
    var invalid_engine = alea.ScalarPrng.init(0x5150_ba56);
    var invalid_control = alea.ScalarPrng.init(0x5150_ba56);
    var invalid_iter = WeightedIter{ .items = &bad_entries };
    var out: [2]u8 = undefined;
    var short_keys: [1]f64 = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleIteratorWeightedIntoFrom(&invalid_engine, u8, &invalid_iter, &out, &short_keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    var keys: [2]f64 = undefined;
    try std.testing.expectError(error.InvalidWeight, sampleIteratorWeightedIntoCheckedFrom(&invalid_engine, u8, &invalid_iter, &out, &keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "iterator sampling preserves direct stream shape" {
    const alea = @import("root.zig");

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
        .{ .item = 4, .weight = 9 },
    };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_0449);
        var direct_engine = Engine.init(0x5150_0449);
        const rng = Rng.init(&facade_engine);

        var choose_iter = RangeIter{ .next_value = 0, .end = 100 };
        var direct_choose_iter = RangeIter{ .next_value = 0, .end = 100 };
        try std.testing.expectEqual(
            chooseIterator(rng, u32, &choose_iter),
            chooseIteratorFrom(&direct_engine, u32, &direct_choose_iter),
        );
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_choose_iter = RangeIter{ .next_value = 0, .end = 100 };
        var direct_checked_choose_iter = RangeIter{ .next_value = 0, .end = 100 };
        try std.testing.expectEqual(
            try chooseIteratorChecked(rng, u32, &checked_choose_iter),
            try chooseIteratorCheckedFrom(&direct_engine, u32, &direct_checked_choose_iter),
        );
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var sample_iter = RangeIter{ .next_value = 0, .end = 100 };
        var direct_sample_iter = RangeIter{ .next_value = 0, .end = 100 };
        const sample = try sampleIterator(std.testing.allocator, rng, u32, &sample_iter, 8);
        defer std.testing.allocator.free(sample);
        const direct_sample = try sampleIteratorFrom(std.testing.allocator, &direct_engine, u32, &direct_sample_iter, 8);
        defer std.testing.allocator.free(direct_sample);
        try std.testing.expectEqualSlices(u32, sample, direct_sample);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_sample_iter = RangeIter{ .next_value = 0, .end = 100 };
        var direct_checked_sample_iter = RangeIter{ .next_value = 0, .end = 100 };
        const checked_sample = try sampleIteratorChecked(std.testing.allocator, rng, u32, &checked_sample_iter, 8);
        defer std.testing.allocator.free(checked_sample);
        const direct_checked_sample = try sampleIteratorCheckedFrom(std.testing.allocator, &direct_engine, u32, &direct_checked_sample_iter, 8);
        defer std.testing.allocator.free(direct_checked_sample);
        try std.testing.expectEqualSlices(u32, checked_sample, direct_checked_sample);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var weighted_iter = WeightedIter{ .items = &entries };
        var direct_weighted_iter = WeightedIter{ .items = &entries };
        try std.testing.expectEqual(
            try chooseIteratorWeighted(rng, u8, &weighted_iter),
            try chooseIteratorWeightedFrom(&direct_engine, u8, &direct_weighted_iter),
        );
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_weighted_iter = WeightedIter{ .items = &entries };
        var direct_checked_weighted_iter = WeightedIter{ .items = &entries };
        try std.testing.expectEqual(
            try chooseIteratorWeightedChecked(rng, u8, &checked_weighted_iter),
            try chooseIteratorWeightedCheckedFrom(&direct_engine, u8, &direct_checked_weighted_iter),
        );
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var weighted_sample_iter = WeightedIter{ .items = &entries };
        var direct_weighted_sample_iter = WeightedIter{ .items = &entries };
        const weighted_sample = try sampleIteratorWeighted(std.testing.allocator, rng, u8, &weighted_sample_iter, 2);
        defer std.testing.allocator.free(weighted_sample);
        const direct_weighted_sample = try sampleIteratorWeightedFrom(std.testing.allocator, &direct_engine, u8, &direct_weighted_sample_iter, 2);
        defer std.testing.allocator.free(direct_weighted_sample);
        try std.testing.expectEqualSlices(u8, weighted_sample, direct_weighted_sample);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_weighted_sample_iter = WeightedIter{ .items = &entries };
        var direct_checked_weighted_sample_iter = WeightedIter{ .items = &entries };
        const checked_weighted_sample = try sampleIteratorWeightedChecked(std.testing.allocator, rng, u8, &checked_weighted_sample_iter, 2);
        defer std.testing.allocator.free(checked_weighted_sample);
        const direct_checked_weighted_sample = try sampleIteratorWeightedCheckedFrom(std.testing.allocator, &direct_engine, u8, &direct_checked_weighted_sample_iter, 2);
        defer std.testing.allocator.free(direct_checked_weighted_sample);
        try std.testing.expectEqualSlices(u8, checked_weighted_sample, direct_checked_weighted_sample);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
}
