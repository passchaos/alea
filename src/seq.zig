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

    pub fn ValueIterator(comptime T: type) type {
        return struct {
            index_iter: Iterator,
            items: []const T,

            pub fn next(self: *@This()) ?T {
                const index = self.index_iter.next() orelse return null;
                return self.items[index];
            }

            pub fn remaining(self: @This()) usize {
                return self.index_iter.remaining();
            }
        };
    }

    pub fn PtrIterator(comptime T: type) type {
        return struct {
            index_iter: Iterator,
            items: []const T,

            pub fn next(self: *@This()) ?*const T {
                const index = self.index_iter.next() orelse return null;
                return &self.items[index];
            }

            pub fn remaining(self: @This()) usize {
                return self.index_iter.remaining();
            }
        };
    }

    pub fn MutPtrIterator(comptime T: type) type {
        return struct {
            index_iter: Iterator,
            items: []T,

            pub fn next(self: *@This()) ?*T {
                const index = self.index_iter.next() orelse return null;
                return &self.items[index];
            }

            pub fn remaining(self: @This()) usize {
                return self.index_iter.remaining();
            }
        };
    }

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

    pub fn validateItems(self: IndexVec, item_len: usize) Error!void {
        var index: usize = 0;
        while (index < self.len()) : (index += 1) {
            if (self.at(index) >= item_len) return error.InvalidParameter;
        }
    }

    pub fn validateDistinctItems(self: IndexVec, item_len: usize) Error!void {
        try self.validateItems(item_len);
        var index: usize = 0;
        while (index < self.len()) : (index += 1) {
            var other = index + 1;
            while (other < self.len()) : (other += 1) {
                if (self.at(index) == self.at(other)) return error.InvalidParameter;
            }
        }
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

    pub fn copyIntoU32(self: IndexVec, out: []u32) Error!void {
        if (out.len != self.len()) return error.LengthMismatch;
        switch (self) {
            .u32 => |items| @memcpy(out, items),
            .usize => |items| {
                for (items, out) |item, *slot| {
                    if (item > std.math.maxInt(u32)) return error.InvalidParameter;
                    slot.* = @intCast(item);
                }
            },
        }
    }

    pub fn toOwnedSlice(self: IndexVec, allocator: std.mem.Allocator) ![]usize {
        const out = try allocator.alloc(usize, self.len());
        errdefer allocator.free(out);
        try self.copyInto(out);
        return out;
    }

    pub fn toOwnedU32Slice(self: IndexVec, allocator: std.mem.Allocator) ![]u32 {
        const out = try allocator.alloc(u32, self.len());
        errdefer allocator.free(out);
        try self.copyIntoU32(out);
        return out;
    }

    pub fn values(self: IndexVec, comptime T: type, items: []const T) ValueIterator(T) {
        return .{ .index_iter = self.iter(), .items = items };
    }

    pub fn valuesChecked(self: IndexVec, comptime T: type, items: []const T) Error!ValueIterator(T) {
        try self.validateItems(items.len);
        return self.values(T, items);
    }

    pub fn ptrs(self: IndexVec, comptime T: type, items: []const T) PtrIterator(T) {
        return .{ .index_iter = self.iter(), .items = items };
    }

    pub fn ptrsChecked(self: IndexVec, comptime T: type, items: []const T) Error!PtrIterator(T) {
        try self.validateItems(items.len);
        return self.ptrs(T, items);
    }

    pub fn mutPtrs(self: IndexVec, comptime T: type, items: []T) MutPtrIterator(T) {
        return .{ .index_iter = self.iter(), .items = items };
    }

    pub fn mutPtrsChecked(self: IndexVec, comptime T: type, items: []T) Error!MutPtrIterator(T) {
        try self.validateDistinctItems(items.len);
        return self.mutPtrs(T, items);
    }

    pub fn valuesInto(self: IndexVec, comptime T: type, items: []const T, out: []T) Error!void {
        if (out.len != self.len()) return error.LengthMismatch;
        var index: usize = 0;
        while (index < self.len()) : (index += 1) out[index] = items[self.at(index)];
    }

    pub fn valuesIntoChecked(self: IndexVec, comptime T: type, items: []const T, out: []T) Error!void {
        try self.validateItems(items.len);
        try self.valuesInto(T, items, out);
    }

    pub fn valuesOwned(self: IndexVec, allocator: std.mem.Allocator, comptime T: type, items: []const T) ![]T {
        const out = try allocator.alloc(T, self.len());
        errdefer allocator.free(out);
        try self.valuesInto(T, items, out);
        return out;
    }

    pub fn valuesOwnedChecked(self: IndexVec, allocator: std.mem.Allocator, comptime T: type, items: []const T) ![]T {
        try self.validateItems(items.len);
        return self.valuesOwned(allocator, T, items);
    }

    pub fn ptrsInto(self: IndexVec, comptime T: type, items: []const T, out: []*const T) Error!void {
        if (out.len != self.len()) return error.LengthMismatch;
        var index: usize = 0;
        while (index < self.len()) : (index += 1) out[index] = &items[self.at(index)];
    }

    pub fn ptrsIntoChecked(self: IndexVec, comptime T: type, items: []const T, out: []*const T) Error!void {
        try self.validateItems(items.len);
        try self.ptrsInto(T, items, out);
    }

    pub fn ptrsOwned(self: IndexVec, allocator: std.mem.Allocator, comptime T: type, items: []const T) ![]*const T {
        const out = try allocator.alloc(*const T, self.len());
        errdefer allocator.free(out);
        try self.ptrsInto(T, items, out);
        return out;
    }

    pub fn ptrsOwnedChecked(self: IndexVec, allocator: std.mem.Allocator, comptime T: type, items: []const T) ![]*const T {
        try self.validateItems(items.len);
        return self.ptrsOwned(allocator, T, items);
    }

    pub fn mutPtrsInto(self: IndexVec, comptime T: type, items: []T, out: []*T) Error!void {
        if (out.len != self.len()) return error.LengthMismatch;
        var index: usize = 0;
        while (index < self.len()) : (index += 1) out[index] = &items[self.at(index)];
    }

    pub fn mutPtrsIntoChecked(self: IndexVec, comptime T: type, items: []T, out: []*T) Error!void {
        try self.validateDistinctItems(items.len);
        try self.mutPtrsInto(T, items, out);
    }

    pub fn mutPtrsOwned(self: IndexVec, allocator: std.mem.Allocator, comptime T: type, items: []T) ![]*T {
        const out = try allocator.alloc(*T, self.len());
        errdefer allocator.free(out);
        try self.mutPtrsInto(T, items, out);
        return out;
    }

    pub fn mutPtrsOwnedChecked(self: IndexVec, allocator: std.mem.Allocator, comptime T: type, items: []T) ![]*T {
        try self.validateDistinctItems(items.len);
        return self.mutPtrsOwned(allocator, T, items);
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

pub fn sampleArrayU32(rng: Rng, comptime N: usize, length: u32) ?[N]u32 {
    return sampleArrayU32From(rng, N, length);
}

pub fn sampleArrayU32Checked(rng: Rng, comptime N: usize, length: u32) Error![N]u32 {
    return sampleArrayU32CheckedFrom(rng, N, length);
}

pub fn sampleArrayU32CheckedFrom(source: anytype, comptime N: usize, length: u32) Error![N]u32 {
    if (N > @as(usize, length)) return error.InvalidParameter;
    return sampleArrayU32From(source, N, length).?;
}

pub fn sampleArrayU32From(source: anytype, comptime N: usize, length: u32) ?[N]u32 {
    if (N > @as(usize, length)) return null;
    var indices: [N]u32 = undefined;
    if (comptime N == 0) return indices;

    var i: usize = 0;
    var j: u32 = length - @as(u32, @intCast(N));
    while (j < length) : ({
        j += 1;
        i += 1;
    }) {
        const t = Rng.uintAtMostFrom(source, u32, j);
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

pub fn sampleItems(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]T {
    return sampleItemsFrom(allocator, rng, T, items, amount);
}

pub fn sampleItemsFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]T {
    return chooseMultipleFrom(allocator, source, T, items, amount);
}

pub fn chooseMultipleChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]T {
    return chooseMultipleCheckedFrom(allocator, rng, T, items, amount);
}

pub fn sampleItemsChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]T {
    return sampleItemsCheckedFrom(allocator, rng, T, items, amount);
}

pub fn sampleItemsCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]T {
    return chooseMultipleCheckedFrom(allocator, source, T, items, amount);
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

pub fn chooseMultiplePtrs(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]*const T {
    return chooseMultiplePtrsFrom(allocator, rng, T, items, amount);
}

pub fn samplePtrs(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]*const T {
    return samplePtrsFrom(allocator, rng, T, items, amount);
}

pub fn samplePtrsFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]*const T {
    return chooseMultiplePtrsFrom(allocator, source, T, items, amount);
}

pub fn chooseMultiplePtrsChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]*const T {
    return chooseMultiplePtrsCheckedFrom(allocator, rng, T, items, amount);
}

pub fn samplePtrsChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]*const T {
    return samplePtrsCheckedFrom(allocator, rng, T, items, amount);
}

pub fn samplePtrsCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]*const T {
    return chooseMultiplePtrsCheckedFrom(allocator, source, T, items, amount);
}

pub fn chooseMultiplePtrsCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]*const T {
    if (amount > items.len) return error.InvalidParameter;
    return chooseMultiplePtrsFrom(allocator, source, T, items, amount);
}

pub fn chooseMultiplePtrsFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]*const T {
    const count = @min(amount, items.len);
    const out = try allocator.alloc(*const T, count);
    errdefer allocator.free(out);

    const indices = try sampleIndicesFrom(allocator, source, items.len, count);
    defer allocator.free(indices);

    for (indices, out) |index, *slot| slot.* = &items[index];
    return out;
}

pub fn chooseMultipleMutPtrs(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []T, amount: usize) ![]*T {
    return chooseMultipleMutPtrsFrom(allocator, rng, T, items, amount);
}

pub fn sampleMutPtrs(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []T, amount: usize) ![]*T {
    return sampleMutPtrsFrom(allocator, rng, T, items, amount);
}

pub fn sampleMutPtrsFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []T, amount: usize) ![]*T {
    return chooseMultipleMutPtrsFrom(allocator, source, T, items, amount);
}

pub fn chooseMultipleMutPtrsChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []T, amount: usize) ![]*T {
    return chooseMultipleMutPtrsCheckedFrom(allocator, rng, T, items, amount);
}

pub fn sampleMutPtrsChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []T, amount: usize) ![]*T {
    return sampleMutPtrsCheckedFrom(allocator, rng, T, items, amount);
}

pub fn sampleMutPtrsCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []T, amount: usize) ![]*T {
    return chooseMultipleMutPtrsCheckedFrom(allocator, source, T, items, amount);
}

pub fn chooseMultipleMutPtrsCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []T, amount: usize) ![]*T {
    if (amount > items.len) return error.InvalidParameter;
    return chooseMultipleMutPtrsFrom(allocator, source, T, items, amount);
}

pub fn chooseMultipleMutPtrsFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []T, amount: usize) ![]*T {
    const count = @min(amount, items.len);
    const out = try allocator.alloc(*T, count);
    errdefer allocator.free(out);

    const indices = try sampleIndicesFrom(allocator, source, items.len, count);
    defer allocator.free(indices);

    for (indices, out) |index, *slot| slot.* = &items[index];
    return out;
}

pub fn chooseMultipleInto(rng: Rng, comptime T: type, items: []const T, out: []T, scratch_indices: []usize) Error!usize {
    return chooseMultipleIntoFrom(rng, T, items, out, scratch_indices);
}

pub fn sampleItemsInto(rng: Rng, comptime T: type, items: []const T, out: []T, scratch_indices: []usize) Error!usize {
    return sampleItemsIntoFrom(rng, T, items, out, scratch_indices);
}

pub fn sampleItemsIntoFrom(source: anytype, comptime T: type, items: []const T, out: []T, scratch_indices: []usize) Error!usize {
    return chooseMultipleIntoFrom(source, T, items, out, scratch_indices);
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

pub fn sampleItemsIntoChecked(rng: Rng, comptime T: type, items: []const T, out: []T, scratch_indices: []usize) Error!void {
    return sampleItemsIntoCheckedFrom(rng, T, items, out, scratch_indices);
}

pub fn sampleItemsIntoCheckedFrom(source: anytype, comptime T: type, items: []const T, out: []T, scratch_indices: []usize) Error!void {
    return chooseMultipleIntoCheckedFrom(source, T, items, out, scratch_indices);
}

pub fn chooseMultipleIntoCheckedFrom(source: anytype, comptime T: type, items: []const T, out: []T, scratch_indices: []usize) Error!void {
    if (out.len > items.len) return error.InvalidParameter;
    if (out.len == 0) return;
    if (scratch_indices.len < out.len) return error.LengthMismatch;
    try sampleIndicesIntoCheckedFrom(source, items.len, scratch_indices[0..out.len]);
    for (scratch_indices[0..out.len], out) |index, *slot| slot.* = items[index];
}

pub fn chooseMultiplePtrsInto(rng: Rng, comptime T: type, items: []const T, out: []*const T, scratch_indices: []usize) Error!usize {
    return chooseMultiplePtrsIntoFrom(rng, T, items, out, scratch_indices);
}

pub fn samplePtrsInto(rng: Rng, comptime T: type, items: []const T, out: []*const T, scratch_indices: []usize) Error!usize {
    return samplePtrsIntoFrom(rng, T, items, out, scratch_indices);
}

pub fn samplePtrsIntoFrom(source: anytype, comptime T: type, items: []const T, out: []*const T, scratch_indices: []usize) Error!usize {
    return chooseMultiplePtrsIntoFrom(source, T, items, out, scratch_indices);
}

pub fn chooseMultiplePtrsIntoFrom(source: anytype, comptime T: type, items: []const T, out: []*const T, scratch_indices: []usize) Error!usize {
    const count = @min(out.len, items.len);
    if (count == 0) return 0;
    if (scratch_indices.len < count) return error.LengthMismatch;
    try sampleIndicesIntoCheckedFrom(source, items.len, scratch_indices[0..count]);
    for (scratch_indices[0..count], out[0..count]) |index, *slot| slot.* = &items[index];
    return count;
}

pub fn chooseMultiplePtrsIntoChecked(rng: Rng, comptime T: type, items: []const T, out: []*const T, scratch_indices: []usize) Error!void {
    return chooseMultiplePtrsIntoCheckedFrom(rng, T, items, out, scratch_indices);
}

pub fn samplePtrsIntoChecked(rng: Rng, comptime T: type, items: []const T, out: []*const T, scratch_indices: []usize) Error!void {
    return samplePtrsIntoCheckedFrom(rng, T, items, out, scratch_indices);
}

pub fn samplePtrsIntoCheckedFrom(source: anytype, comptime T: type, items: []const T, out: []*const T, scratch_indices: []usize) Error!void {
    return chooseMultiplePtrsIntoCheckedFrom(source, T, items, out, scratch_indices);
}

pub fn chooseMultiplePtrsIntoCheckedFrom(source: anytype, comptime T: type, items: []const T, out: []*const T, scratch_indices: []usize) Error!void {
    if (out.len > items.len) return error.InvalidParameter;
    if (out.len == 0) return;
    if (scratch_indices.len < out.len) return error.LengthMismatch;
    try sampleIndicesIntoCheckedFrom(source, items.len, scratch_indices[0..out.len]);
    for (scratch_indices[0..out.len], out) |index, *slot| slot.* = &items[index];
}

pub fn chooseMultipleMutPtrsInto(rng: Rng, comptime T: type, items: []T, out: []*T, scratch_indices: []usize) Error!usize {
    return chooseMultipleMutPtrsIntoFrom(rng, T, items, out, scratch_indices);
}

pub fn sampleMutPtrsInto(rng: Rng, comptime T: type, items: []T, out: []*T, scratch_indices: []usize) Error!usize {
    return sampleMutPtrsIntoFrom(rng, T, items, out, scratch_indices);
}

pub fn sampleMutPtrsIntoFrom(source: anytype, comptime T: type, items: []T, out: []*T, scratch_indices: []usize) Error!usize {
    return chooseMultipleMutPtrsIntoFrom(source, T, items, out, scratch_indices);
}

pub fn chooseMultipleMutPtrsIntoFrom(source: anytype, comptime T: type, items: []T, out: []*T, scratch_indices: []usize) Error!usize {
    const count = @min(out.len, items.len);
    if (count == 0) return 0;
    if (scratch_indices.len < count) return error.LengthMismatch;
    try sampleIndicesIntoCheckedFrom(source, items.len, scratch_indices[0..count]);
    for (scratch_indices[0..count], out[0..count]) |index, *slot| slot.* = &items[index];
    return count;
}

pub fn chooseMultipleMutPtrsIntoChecked(rng: Rng, comptime T: type, items: []T, out: []*T, scratch_indices: []usize) Error!void {
    return chooseMultipleMutPtrsIntoCheckedFrom(rng, T, items, out, scratch_indices);
}

pub fn sampleMutPtrsIntoChecked(rng: Rng, comptime T: type, items: []T, out: []*T, scratch_indices: []usize) Error!void {
    return sampleMutPtrsIntoCheckedFrom(rng, T, items, out, scratch_indices);
}

pub fn sampleMutPtrsIntoCheckedFrom(source: anytype, comptime T: type, items: []T, out: []*T, scratch_indices: []usize) Error!void {
    return chooseMultipleMutPtrsIntoCheckedFrom(source, T, items, out, scratch_indices);
}

pub fn chooseMultipleMutPtrsIntoCheckedFrom(source: anytype, comptime T: type, items: []T, out: []*T, scratch_indices: []usize) Error!void {
    if (out.len > items.len) return error.InvalidParameter;
    if (out.len == 0) return;
    if (scratch_indices.len < out.len) return error.LengthMismatch;
    try sampleIndicesIntoCheckedFrom(source, items.len, scratch_indices[0..out.len]);
    for (scratch_indices[0..out.len], out) |index, *slot| slot.* = &items[index];
}

pub fn chooseArray(rng: Rng, comptime T: type, comptime N: usize, items: []const T) ?[N]T {
    return chooseArrayFrom(rng, T, N, items);
}

pub fn sampleItemsArray(rng: Rng, comptime T: type, comptime N: usize, items: []const T) ?[N]T {
    return sampleItemsArrayFrom(rng, T, N, items);
}

pub fn sampleItemsArrayFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T) ?[N]T {
    return chooseArrayFrom(source, T, N, items);
}

pub fn chooseArrayChecked(rng: Rng, comptime T: type, comptime N: usize, items: []const T) Error![N]T {
    return chooseArrayCheckedFrom(rng, T, N, items);
}

pub fn sampleItemsArrayChecked(rng: Rng, comptime T: type, comptime N: usize, items: []const T) Error![N]T {
    return sampleItemsArrayCheckedFrom(rng, T, N, items);
}

pub fn sampleItemsArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T) Error![N]T {
    return chooseArrayCheckedFrom(source, T, N, items);
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

pub fn choosePtrArray(rng: Rng, comptime T: type, comptime N: usize, items: []const T) ?[N]*const T {
    return choosePtrArrayFrom(rng, T, N, items);
}

pub fn samplePtrArray(rng: Rng, comptime T: type, comptime N: usize, items: []const T) ?[N]*const T {
    return samplePtrArrayFrom(rng, T, N, items);
}

pub fn samplePtrArrayFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T) ?[N]*const T {
    return choosePtrArrayFrom(source, T, N, items);
}

pub fn choosePtrArrayChecked(rng: Rng, comptime T: type, comptime N: usize, items: []const T) Error![N]*const T {
    return choosePtrArrayCheckedFrom(rng, T, N, items);
}

pub fn samplePtrArrayChecked(rng: Rng, comptime T: type, comptime N: usize, items: []const T) Error![N]*const T {
    return samplePtrArrayCheckedFrom(rng, T, N, items);
}

pub fn samplePtrArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T) Error![N]*const T {
    return choosePtrArrayCheckedFrom(source, T, N, items);
}

pub fn choosePtrArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T) Error![N]*const T {
    if (N > items.len) return error.InvalidParameter;
    return choosePtrArrayFrom(source, T, N, items).?;
}

pub fn choosePtrArrayFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T) ?[N]*const T {
    const indices = sampleArrayFrom(source, N, items.len) orelse return null;
    var out: [N]*const T = undefined;
    inline for (0..N) |i| out[i] = &items[indices[i]];
    return out;
}

pub fn chooseMutPtrArray(rng: Rng, comptime T: type, comptime N: usize, items: []T) ?[N]*T {
    return chooseMutPtrArrayFrom(rng, T, N, items);
}

pub fn sampleMutPtrArray(rng: Rng, comptime T: type, comptime N: usize, items: []T) ?[N]*T {
    return sampleMutPtrArrayFrom(rng, T, N, items);
}

pub fn sampleMutPtrArrayFrom(source: anytype, comptime T: type, comptime N: usize, items: []T) ?[N]*T {
    return chooseMutPtrArrayFrom(source, T, N, items);
}

pub fn chooseMutPtrArrayChecked(rng: Rng, comptime T: type, comptime N: usize, items: []T) Error![N]*T {
    return chooseMutPtrArrayCheckedFrom(rng, T, N, items);
}

pub fn sampleMutPtrArrayChecked(rng: Rng, comptime T: type, comptime N: usize, items: []T) Error![N]*T {
    return sampleMutPtrArrayCheckedFrom(rng, T, N, items);
}

pub fn sampleMutPtrArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, items: []T) Error![N]*T {
    return chooseMutPtrArrayCheckedFrom(source, T, N, items);
}

pub fn chooseMutPtrArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, items: []T) Error![N]*T {
    if (N > items.len) return error.InvalidParameter;
    return chooseMutPtrArrayFrom(source, T, N, items).?;
}

pub fn chooseMutPtrArrayFrom(source: anytype, comptime T: type, comptime N: usize, items: []T) ?[N]*T {
    const indices = sampleArrayFrom(source, N, items.len) orelse return null;
    var out: [N]*T = undefined;
    inline for (0..N) |i| out[i] = &items[indices[i]];
    return out;
}

pub fn weightedIndex(rng: Rng, comptime Weight: type, weights: []const Weight) ?usize {
    return weightedIndexFrom(rng, Weight, weights);
}

pub fn weightedIndexFrom(source: anytype, comptime Weight: type, weights: []const Weight) ?usize {
    return weightedIndexCheckedFrom(source, Weight, weights) catch unreachable;
}

pub fn weightedIndexChecked(rng: Rng, comptime Weight: type, weights: []const Weight) Error!?usize {
    return weightedIndexCheckedFrom(rng, Weight, weights);
}

pub fn weightedIndexCheckedFrom(source: anytype, comptime Weight: type, weights: []const Weight) Error!?usize {
    return weightedIndexGenericFrom(source, Weight, weights);
}

pub fn fillWeightedIndex(rng: Rng, comptime Weight: type, dest: []?usize, weights: []const Weight) Error!void {
    return fillWeightedIndexFrom(rng, Weight, dest, weights);
}

pub fn fillWeightedIndexFrom(source: anytype, comptime Weight: type, dest: []?usize, weights: []const Weight) Error!void {
    if (dest.len == 0) return;
    const validation = try validateWeightedIndexWeightsAllowEmpty(Weight, weights);
    if (validation.total == 0) {
        @memset(dest, null);
        return;
    }
    if (validation.single_positive) |index| {
        @memset(dest, @as(?usize, index));
        return;
    }
    for (dest) |*item| item.* = weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total);
}

pub fn fillWeightedIndexChecked(rng: Rng, comptime Weight: type, dest: []usize, weights: []const Weight) Error!void {
    return fillWeightedIndexCheckedFrom(rng, Weight, dest, weights);
}

pub fn fillWeightedIndexCheckedFrom(source: anytype, comptime Weight: type, dest: []usize, weights: []const Weight) Error!void {
    if (dest.len == 0) return;
    const validation = try validateWeightedIndexWeights(Weight, weights);
    if (validation.single_positive) |index| {
        @memset(dest, index);
        return;
    }
    for (dest) |*item| item.* = weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total);
}

pub fn weightedIndexBatch(allocator: std.mem.Allocator, rng: Rng, comptime Weight: type, count: usize, weights: []const Weight) ![]?usize {
    return weightedIndexBatchFrom(allocator, rng, Weight, count, weights);
}

pub fn weightedIndexBatchFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, count: usize, weights: []const Weight) ![]?usize {
    if (count == 0) return allocator.alloc(?usize, 0);
    const validation = try validateWeightedIndexWeightsAllowEmpty(Weight, weights);
    const out = try allocator.alloc(?usize, count);
    errdefer allocator.free(out);
    if (validation.total == 0) {
        @memset(out, null);
        return out;
    }
    if (validation.single_positive) |index| {
        @memset(out, @as(?usize, index));
        return out;
    }
    for (out) |*item| item.* = weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total);
    return out;
}

pub fn weightedIndexBatchChecked(allocator: std.mem.Allocator, rng: Rng, comptime Weight: type, count: usize, weights: []const Weight) ![]usize {
    return weightedIndexBatchCheckedFrom(allocator, rng, Weight, count, weights);
}

pub fn weightedIndexBatchCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, count: usize, weights: []const Weight) ![]usize {
    if (count == 0) return allocator.alloc(usize, 0);
    const validation = try validateWeightedIndexWeights(Weight, weights);
    const out = try allocator.alloc(usize, count);
    errdefer allocator.free(out);
    if (validation.single_positive) |index| {
        @memset(out, index);
        return out;
    }
    for (out) |*item| item.* = weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total);
    return out;
}

pub fn weightedIndexU32(rng: Rng, comptime Weight: type, weights: []const Weight) Error!?u32 {
    return weightedIndexU32From(rng, Weight, weights);
}

pub fn weightedIndexU32From(source: anytype, comptime Weight: type, weights: []const Weight) Error!?u32 {
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const index = try weightedIndexGenericFrom(source, Weight, weights) orelse return null;
    return @intCast(index);
}

pub fn weightedIndexU32Checked(rng: Rng, comptime Weight: type, weights: []const Weight) Error!?u32 {
    return weightedIndexU32CheckedFrom(rng, Weight, weights);
}

pub fn weightedIndexU32CheckedFrom(source: anytype, comptime Weight: type, weights: []const Weight) Error!?u32 {
    return weightedIndexU32From(source, Weight, weights);
}

pub fn fillWeightedIndexU32(rng: Rng, comptime Weight: type, dest: []?u32, weights: []const Weight) Error!void {
    return fillWeightedIndexU32From(rng, Weight, dest, weights);
}

pub fn fillWeightedIndexU32From(source: anytype, comptime Weight: type, dest: []?u32, weights: []const Weight) Error!void {
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    if (dest.len == 0) return;
    const validation = try validateWeightedIndexWeightsAllowEmpty(Weight, weights);
    if (validation.total == 0) {
        @memset(dest, null);
        return;
    }
    if (validation.single_positive) |index| {
        @memset(dest, @as(?u32, @intCast(index)));
        return;
    }
    for (dest) |*item| item.* = @intCast(weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total));
}

pub fn fillWeightedIndexU32Checked(rng: Rng, comptime Weight: type, dest: []u32, weights: []const Weight) Error!void {
    return fillWeightedIndexU32CheckedFrom(rng, Weight, dest, weights);
}

pub fn fillWeightedIndexU32CheckedFrom(source: anytype, comptime Weight: type, dest: []u32, weights: []const Weight) Error!void {
    if (dest.len == 0) return;
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(Weight, weights);
    if (validation.single_positive) |index| {
        @memset(dest, @intCast(index));
        return;
    }
    for (dest) |*item| item.* = @intCast(weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total));
}

pub fn weightedIndexU32Batch(allocator: std.mem.Allocator, rng: Rng, comptime Weight: type, count: usize, weights: []const Weight) ![]?u32 {
    return weightedIndexU32BatchFrom(allocator, rng, Weight, count, weights);
}

pub fn weightedIndexU32BatchFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, count: usize, weights: []const Weight) ![]?u32 {
    if (count == 0) return allocator.alloc(?u32, 0);
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeightsAllowEmpty(Weight, weights);
    const out = try allocator.alloc(?u32, count);
    errdefer allocator.free(out);
    if (validation.total == 0) {
        @memset(out, null);
        return out;
    }
    if (validation.single_positive) |index| {
        @memset(out, @as(?u32, @intCast(index)));
        return out;
    }
    for (out) |*item| item.* = @intCast(weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total));
    return out;
}

pub fn weightedIndexU32BatchChecked(allocator: std.mem.Allocator, rng: Rng, comptime Weight: type, count: usize, weights: []const Weight) ![]u32 {
    return weightedIndexU32BatchCheckedFrom(allocator, rng, Weight, count, weights);
}

pub fn weightedIndexU32BatchCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, count: usize, weights: []const Weight) ![]u32 {
    if (count == 0) return allocator.alloc(u32, 0);
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(Weight, weights);
    const out = try allocator.alloc(u32, count);
    errdefer allocator.free(out);
    if (validation.single_positive) |index| {
        @memset(out, @intCast(index));
        return out;
    }
    for (out) |*item| item.* = @intCast(weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total));
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

pub fn chooseWeightedBy(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !?T {
    return chooseWeightedByFrom(rng, T, Weight, items, weightFn);
}

pub fn chooseWeightedByChecked(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !T {
    return chooseWeightedByCheckedFrom(rng, T, Weight, items, weightFn);
}

pub fn chooseWeightedByCheckedFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !T {
    return (try chooseWeightedByFrom(source, T, Weight, items, weightFn)) orelse error.EmptyInput;
}

pub fn chooseWeightedByFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !?T {
    const index = (try weightedIndexByFrom(source, T, Weight, items, weightFn)) orelse return null;
    return items[index];
}

pub fn fillChooseWeighted(rng: Rng, comptime T: type, comptime Weight: type, dest: []?T, items: []const T, weights: []const Weight) !void {
    return fillChooseWeightedFrom(rng, T, Weight, dest, items, weights);
}

pub fn fillChooseWeightedFrom(source: anytype, comptime T: type, comptime Weight: type, dest: []?T, items: []const T, weights: []const Weight) !void {
    if (items.len != weights.len) return error.LengthMismatch;
    if (dest.len == 0) return;
    const validation = try validateWeightedIndexWeightsAllowEmpty(Weight, weights);
    if (validation.total == 0) {
        @memset(dest, null);
        return;
    }
    if (validation.single_positive) |index| {
        @memset(dest, @as(?T, items[index]));
        return;
    }
    for (dest) |*item| item.* = items[weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total)];
}

pub fn fillChooseWeightedChecked(rng: Rng, comptime T: type, comptime Weight: type, dest: []T, items: []const T, weights: []const Weight) !void {
    return fillChooseWeightedCheckedFrom(rng, T, Weight, dest, items, weights);
}

pub fn fillChooseWeightedCheckedFrom(source: anytype, comptime T: type, comptime Weight: type, dest: []T, items: []const T, weights: []const Weight) !void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.LengthMismatch;
    const validation = try validateWeightedIndexWeights(Weight, weights);
    if (validation.single_positive) |index| {
        @memset(dest, items[index]);
        return;
    }
    for (dest) |*item| item.* = items[weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total)];
}

pub fn chooseWeightedBatch(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, count: usize, items: []const T, weights: []const Weight) ![]?T {
    return chooseWeightedBatchFrom(allocator, rng, T, Weight, count, items, weights);
}

pub fn chooseWeightedBatchFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, count: usize, items: []const T, weights: []const Weight) ![]?T {
    if (count == 0) return allocator.alloc(?T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    const validation = try validateWeightedIndexWeightsAllowEmpty(Weight, weights);
    const out = try allocator.alloc(?T, count);
    errdefer allocator.free(out);
    if (validation.total == 0) {
        @memset(out, null);
        return out;
    }
    if (validation.single_positive) |index| {
        @memset(out, @as(?T, items[index]));
        return out;
    }
    for (out) |*item| item.* = items[weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total)];
    return out;
}

pub fn chooseWeightedBatchChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, count: usize, items: []const T, weights: []const Weight) ![]T {
    return chooseWeightedBatchCheckedFrom(allocator, rng, T, Weight, count, items, weights);
}

pub fn chooseWeightedBatchCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, count: usize, items: []const T, weights: []const Weight) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    const validation = try validateWeightedIndexWeights(Weight, weights);
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    if (validation.single_positive) |index| {
        @memset(out, items[index]);
        return out;
    }
    for (out) |*item| item.* = items[weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total)];
    return out;
}

pub fn chooseWeightedConstPtr(rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight) !?*const T {
    return chooseWeightedConstPtrFrom(rng, T, Weight, items, weights);
}

pub fn chooseWeightedConstPtrChecked(rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight) !*const T {
    return chooseWeightedConstPtrCheckedFrom(rng, T, Weight, items, weights);
}

pub fn chooseWeightedConstPtrCheckedFrom(source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight) !*const T {
    return (try chooseWeightedConstPtrFrom(source, T, Weight, items, weights)) orelse error.EmptyInput;
}

pub fn chooseWeightedConstPtrFrom(source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight) !?*const T {
    if (items.len != weights.len) return error.LengthMismatch;
    const index = (try weightedIndexGenericFrom(source, Weight, weights)) orelse return null;
    return &items[index];
}

pub fn chooseWeightedConstPtrBy(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !?*const T {
    return chooseWeightedConstPtrByFrom(rng, T, Weight, items, weightFn);
}

pub fn chooseWeightedConstPtrByChecked(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !*const T {
    return chooseWeightedConstPtrByCheckedFrom(rng, T, Weight, items, weightFn);
}

pub fn chooseWeightedConstPtrByCheckedFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !*const T {
    return (try chooseWeightedConstPtrByFrom(source, T, Weight, items, weightFn)) orelse error.EmptyInput;
}

pub fn chooseWeightedConstPtrByFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !?*const T {
    const index = (try weightedIndexByFrom(source, T, Weight, items, weightFn)) orelse return null;
    return &items[index];
}

pub fn fillChooseWeightedConstPtr(rng: Rng, comptime T: type, comptime Weight: type, dest: []?*const T, items: []const T, weights: []const Weight) !void {
    return fillChooseWeightedConstPtrFrom(rng, T, Weight, dest, items, weights);
}

pub fn fillChooseWeightedConstPtrFrom(source: anytype, comptime T: type, comptime Weight: type, dest: []?*const T, items: []const T, weights: []const Weight) !void {
    if (items.len != weights.len) return error.LengthMismatch;
    if (dest.len == 0) return;
    const validation = try validateWeightedIndexWeightsAllowEmpty(Weight, weights);
    if (validation.total == 0) {
        @memset(dest, null);
        return;
    }
    if (validation.single_positive) |index| {
        @memset(dest, @as(?*const T, &items[index]));
        return;
    }
    for (dest) |*item| item.* = &items[weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total)];
}

pub fn fillChooseWeightedConstPtrChecked(rng: Rng, comptime T: type, comptime Weight: type, dest: []*const T, items: []const T, weights: []const Weight) !void {
    return fillChooseWeightedConstPtrCheckedFrom(rng, T, Weight, dest, items, weights);
}

pub fn fillChooseWeightedConstPtrCheckedFrom(source: anytype, comptime T: type, comptime Weight: type, dest: []*const T, items: []const T, weights: []const Weight) !void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.LengthMismatch;
    const validation = try validateWeightedIndexWeights(Weight, weights);
    if (validation.single_positive) |index| {
        @memset(dest, &items[index]);
        return;
    }
    for (dest) |*item| item.* = &items[weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total)];
}

pub fn chooseWeightedConstPtrBatch(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, count: usize, items: []const T, weights: []const Weight) ![]?*const T {
    return chooseWeightedConstPtrBatchFrom(allocator, rng, T, Weight, count, items, weights);
}

pub fn chooseWeightedConstPtrBatchFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, count: usize, items: []const T, weights: []const Weight) ![]?*const T {
    if (count == 0) return allocator.alloc(?*const T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    const validation = try validateWeightedIndexWeightsAllowEmpty(Weight, weights);
    const out = try allocator.alloc(?*const T, count);
    errdefer allocator.free(out);
    if (validation.total == 0) {
        @memset(out, null);
        return out;
    }
    if (validation.single_positive) |index| {
        @memset(out, @as(?*const T, &items[index]));
        return out;
    }
    for (out) |*item| item.* = &items[weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total)];
    return out;
}

pub fn chooseWeightedConstPtrBatchChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, count: usize, items: []const T, weights: []const Weight) ![]*const T {
    return chooseWeightedConstPtrBatchCheckedFrom(allocator, rng, T, Weight, count, items, weights);
}

pub fn chooseWeightedConstPtrBatchCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, count: usize, items: []const T, weights: []const Weight) ![]*const T {
    if (count == 0) return allocator.alloc(*const T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    const validation = try validateWeightedIndexWeights(Weight, weights);
    const out = try allocator.alloc(*const T, count);
    errdefer allocator.free(out);
    if (validation.single_positive) |index| {
        @memset(out, &items[index]);
        return out;
    }
    for (out) |*item| item.* = &items[weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total)];
    return out;
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

pub fn chooseWeightedPtrBy(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    comptime weightFn: fn (*const T) Weight,
) !?*T {
    return chooseWeightedPtrByFrom(rng, T, Weight, items, weightFn);
}

pub fn chooseWeightedPtrByChecked(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    comptime weightFn: fn (*const T) Weight,
) !*T {
    return chooseWeightedPtrByCheckedFrom(rng, T, Weight, items, weightFn);
}

pub fn chooseWeightedPtrByCheckedFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    comptime weightFn: fn (*const T) Weight,
) !*T {
    return (try chooseWeightedPtrByFrom(source, T, Weight, items, weightFn)) orelse error.EmptyInput;
}

pub fn chooseWeightedPtrByFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    comptime weightFn: fn (*const T) Weight,
) !?*T {
    const index = (try weightedIndexByFrom(source, T, Weight, items, weightFn)) orelse return null;
    return &items[index];
}

pub fn fillChooseWeightedPtr(rng: Rng, comptime T: type, comptime Weight: type, dest: []?*T, items: []T, weights: []const Weight) !void {
    return fillChooseWeightedPtrFrom(rng, T, Weight, dest, items, weights);
}

pub fn fillChooseWeightedPtrFrom(source: anytype, comptime T: type, comptime Weight: type, dest: []?*T, items: []T, weights: []const Weight) !void {
    if (items.len != weights.len) return error.LengthMismatch;
    if (dest.len == 0) return;
    const validation = try validateWeightedIndexWeightsAllowEmpty(Weight, weights);
    if (validation.total == 0) {
        @memset(dest, null);
        return;
    }
    if (validation.single_positive) |index| {
        @memset(dest, @as(?*T, &items[index]));
        return;
    }
    for (dest) |*item| item.* = &items[weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total)];
}

pub fn fillChooseWeightedPtrChecked(rng: Rng, comptime T: type, comptime Weight: type, dest: []*T, items: []T, weights: []const Weight) !void {
    return fillChooseWeightedPtrCheckedFrom(rng, T, Weight, dest, items, weights);
}

pub fn fillChooseWeightedPtrCheckedFrom(source: anytype, comptime T: type, comptime Weight: type, dest: []*T, items: []T, weights: []const Weight) !void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.LengthMismatch;
    const validation = try validateWeightedIndexWeights(Weight, weights);
    if (validation.single_positive) |index| {
        @memset(dest, &items[index]);
        return;
    }
    for (dest) |*item| item.* = &items[weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total)];
}

pub fn chooseWeightedPtrBatch(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, count: usize, items: []T, weights: []const Weight) ![]?*T {
    return chooseWeightedPtrBatchFrom(allocator, rng, T, Weight, count, items, weights);
}

pub fn chooseWeightedPtrBatchFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, count: usize, items: []T, weights: []const Weight) ![]?*T {
    if (count == 0) return allocator.alloc(?*T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    const validation = try validateWeightedIndexWeightsAllowEmpty(Weight, weights);
    const out = try allocator.alloc(?*T, count);
    errdefer allocator.free(out);
    if (validation.total == 0) {
        @memset(out, null);
        return out;
    }
    if (validation.single_positive) |index| {
        @memset(out, @as(?*T, &items[index]));
        return out;
    }
    for (out) |*item| item.* = &items[weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total)];
    return out;
}

pub fn chooseWeightedPtrBatchChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, count: usize, items: []T, weights: []const Weight) ![]*T {
    return chooseWeightedPtrBatchCheckedFrom(allocator, rng, T, Weight, count, items, weights);
}

pub fn chooseWeightedPtrBatchCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, count: usize, items: []T, weights: []const Weight) ![]*T {
    if (count == 0) return allocator.alloc(*T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    const validation = try validateWeightedIndexWeights(Weight, weights);
    const out = try allocator.alloc(*T, count);
    errdefer allocator.free(out);
    if (validation.single_positive) |index| {
        @memset(out, &items[index]);
        return out;
    }
    for (out) |*item| item.* = &items[weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total)];
    return out;
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

pub fn chooseIteratorStable(rng: Rng, comptime T: type, iterator: anytype) ?T {
    return chooseIteratorStableFrom(rng, T, iterator);
}

pub fn chooseIteratorStableChecked(rng: Rng, comptime T: type, iterator: anytype) Error!T {
    return chooseIteratorStableCheckedFrom(rng, T, iterator);
}

pub fn chooseIteratorStableCheckedFrom(source: anytype, comptime T: type, iterator: anytype) Error!T {
    return chooseIteratorStableFrom(source, T, iterator) orelse error.EmptyInput;
}

pub fn chooseIteratorStableFrom(source: anytype, comptime T: type, iterator: anytype) ?T {
    return chooseIteratorFrom(source, T, iterator);
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

pub fn sampleIteratorFill(rng: Rng, comptime T: type, iterator: anytype, out: []T) usize {
    return sampleIteratorFillFrom(rng, T, iterator, out);
}

pub fn sampleIteratorFillFrom(source: anytype, comptime T: type, iterator: anytype, out: []T) usize {
    return sampleIteratorIntoFrom(source, T, iterator, out);
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

pub fn sampleIteratorFillChecked(rng: Rng, comptime T: type, iterator: anytype, out: []T) Error!void {
    return sampleIteratorFillCheckedFrom(rng, T, iterator, out);
}

pub fn sampleIteratorFillCheckedFrom(source: anytype, comptime T: type, iterator: anytype, out: []T) Error!void {
    return sampleIteratorIntoCheckedFrom(source, T, iterator, out);
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

pub fn sampleWeightedIndicesU32(allocator: std.mem.Allocator, rng: Rng, comptime Weight: type, weights: []const Weight, amount: usize) ![]u32 {
    return sampleWeightedIndicesU32From(allocator, rng, Weight, weights, amount);
}

pub fn sampleWeightedIndicesU32From(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, weights: []const Weight, amount: usize) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    if (weights.len == 0) return error.EmptyInput;
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;

    const positive = try countPositiveWeights(Weight, weights);
    const count = @min(amount, positive);
    if (count == 0) return allocator.alloc(u32, 0);
    if (positive == 1) return singlePositiveWeightIndexU32Alloc(allocator, Weight, weights);
    return sampleWeightedIndicesU32ExactFrom(allocator, source, Weight, weights, count);
}

pub fn sampleWeightedIndicesU32Checked(allocator: std.mem.Allocator, rng: Rng, comptime Weight: type, weights: []const Weight, amount: usize) ![]u32 {
    return sampleWeightedIndicesU32CheckedFrom(allocator, rng, Weight, weights, amount);
}

pub fn sampleWeightedIndicesU32CheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, weights: []const Weight, amount: usize) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    if (amount > weights.len or weights.len > std.math.maxInt(u32)) return error.InvalidParameter;

    const positive = try countPositiveWeights(Weight, weights);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositiveWeightIndexU32Alloc(allocator, Weight, weights);
    return sampleWeightedIndicesU32ExactFrom(allocator, source, Weight, weights, amount);
}

pub fn sampleWeightedIndexVec(allocator: std.mem.Allocator, rng: Rng, comptime Weight: type, weights: []const Weight, amount: usize) !IndexVec {
    return sampleWeightedIndexVecFrom(allocator, rng, Weight, weights, amount);
}

pub fn sampleWeightedIndexVecFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, weights: []const Weight, amount: usize) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (weights.len == 0) return error.EmptyInput;

    const positive = try countPositiveWeights(Weight, weights);
    const count = @min(amount, positive);
    if (count == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (positive == 1) return singlePositiveWeightIndexVecAlloc(allocator, Weight, weights);
    return sampleWeightedIndexVecExactFrom(allocator, source, Weight, weights, count);
}

pub fn sampleWeightedIndexVecChecked(allocator: std.mem.Allocator, rng: Rng, comptime Weight: type, weights: []const Weight, amount: usize) !IndexVec {
    return sampleWeightedIndexVecCheckedFrom(allocator, rng, Weight, weights, amount);
}

pub fn sampleWeightedIndexVecCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, weights: []const Weight, amount: usize) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (amount > weights.len) return error.InvalidParameter;

    const positive = try countPositiveWeights(Weight, weights);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositiveWeightIndexVecAlloc(allocator, Weight, weights);
    return sampleWeightedIndexVecExactFrom(allocator, source, Weight, weights, amount);
}

pub fn sampleWeightedIndicesByIndex(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) ![]usize {
    return sampleWeightedIndicesByIndexFrom(allocator, rng, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndicesByIndexChecked(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) ![]usize {
    return sampleWeightedIndicesByIndexCheckedFrom(allocator, rng, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndicesByIndexCheckedFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (amount > length) return error.InvalidParameter;

    const positive = try countPositiveIndicesBy(Weight, length, weightFn);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositiveIndexByAlloc(allocator, Weight, length, weightFn);
    return sampleWeightedIndicesByIndexExactFrom(allocator, source, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndicesByIndexFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (length == 0) return error.EmptyInput;

    const positive = try countPositiveIndicesBy(Weight, length, weightFn);
    const count = @min(amount, positive);
    if (count == 0) return allocator.alloc(usize, 0);
    if (positive == 1) return singlePositiveIndexByAlloc(allocator, Weight, length, weightFn);
    return sampleWeightedIndicesByIndexExactFrom(allocator, source, Weight, length, count, weightFn);
}

pub fn sampleWeightedIndicesU32ByIndex(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) ![]u32 {
    return sampleWeightedIndicesU32ByIndexFrom(allocator, rng, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndicesU32ByIndexChecked(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) ![]u32 {
    return sampleWeightedIndicesU32ByIndexCheckedFrom(allocator, rng, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndicesU32ByIndexCheckedFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    if (amount > length or length > std.math.maxInt(u32)) return error.InvalidParameter;

    const positive = try countPositiveIndicesBy(Weight, length, weightFn);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositiveIndexU32ByAlloc(allocator, Weight, length, weightFn);
    return sampleWeightedIndicesU32ByIndexExactFrom(allocator, source, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndicesU32ByIndexFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    if (length == 0) return error.EmptyInput;
    if (length > std.math.maxInt(u32)) return error.InvalidParameter;

    const positive = try countPositiveIndicesBy(Weight, length, weightFn);
    const count = @min(amount, positive);
    if (count == 0) return allocator.alloc(u32, 0);
    if (positive == 1) return singlePositiveIndexU32ByAlloc(allocator, Weight, length, weightFn);
    return sampleWeightedIndicesU32ByIndexExactFrom(allocator, source, Weight, length, count, weightFn);
}

pub fn sampleWeightedIndexVecByIndex(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) !IndexVec {
    return sampleWeightedIndexVecByIndexFrom(allocator, rng, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndexVecByIndexChecked(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) !IndexVec {
    return sampleWeightedIndexVecByIndexCheckedFrom(allocator, rng, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndexVecByIndexCheckedFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (amount > length) return error.InvalidParameter;

    const positive = try countPositiveIndicesBy(Weight, length, weightFn);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositiveIndexVecByAlloc(allocator, Weight, length, weightFn);
    return sampleWeightedIndexVecByIndexExactFrom(allocator, source, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndexVecByIndexFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (length == 0) return error.EmptyInput;

    const positive = try countPositiveIndicesBy(Weight, length, weightFn);
    const count = @min(amount, positive);
    if (count == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (positive == 1) return singlePositiveIndexVecByAlloc(allocator, Weight, length, weightFn);
    return sampleWeightedIndexVecByIndexExactFrom(allocator, source, Weight, length, count, weightFn);
}

pub fn sampleWeightedIndicesBy(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]usize {
    return sampleWeightedIndicesByFrom(allocator, rng, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndicesByChecked(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]usize {
    return sampleWeightedIndicesByCheckedFrom(allocator, rng, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndicesByCheckedFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (amount > items.len) return error.InvalidParameter;
    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositiveItemIndexByAlloc(allocator, T, Weight, items, weightFn);
    return sampleWeightedIndicesByExactFrom(allocator, source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndicesByFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (items.len == 0) return error.EmptyInput;

    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    const count = @min(amount, positive);
    if (count == 0) return allocator.alloc(usize, 0);
    if (positive == 1) return singlePositiveItemIndexByAlloc(allocator, T, Weight, items, weightFn);
    return sampleWeightedIndicesByExactFrom(allocator, source, T, Weight, items, count, weightFn);
}

pub fn sampleWeightedIndicesU32By(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]u32 {
    return sampleWeightedIndicesU32ByFrom(allocator, rng, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndicesU32ByChecked(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]u32 {
    return sampleWeightedIndicesU32ByCheckedFrom(allocator, rng, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndicesU32ByCheckedFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    if (amount > items.len or items.len > std.math.maxInt(u32)) return error.InvalidParameter;

    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositiveItemIndexU32ByAlloc(allocator, T, Weight, items, weightFn);
    return sampleWeightedIndicesU32ByExactFrom(allocator, source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndicesU32ByFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    if (items.len == 0) return error.EmptyInput;
    if (items.len > std.math.maxInt(u32)) return error.InvalidParameter;

    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    const count = @min(amount, positive);
    if (count == 0) return allocator.alloc(u32, 0);
    if (positive == 1) return singlePositiveItemIndexU32ByAlloc(allocator, T, Weight, items, weightFn);
    return sampleWeightedIndicesU32ByExactFrom(allocator, source, T, Weight, items, count, weightFn);
}

pub fn sampleWeightedIndexVecBy(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) !IndexVec {
    return sampleWeightedIndexVecByFrom(allocator, rng, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndexVecByChecked(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) !IndexVec {
    return sampleWeightedIndexVecByCheckedFrom(allocator, rng, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndexVecByCheckedFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (amount > items.len) return error.InvalidParameter;

    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositiveItemIndexVecByAlloc(allocator, T, Weight, items, weightFn);
    return sampleWeightedIndexVecByExactFrom(allocator, source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndexVecByFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (items.len == 0) return error.EmptyInput;

    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    const count = @min(amount, positive);
    if (count == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (positive == 1) return singlePositiveItemIndexVecByAlloc(allocator, T, Weight, items, weightFn);
    return sampleWeightedIndexVecByExactFrom(allocator, source, T, Weight, items, count, weightFn);
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

pub fn sampleWeightedIndicesU32Into(rng: Rng, comptime Weight: type, weights: []const Weight, out: []u32, scratch_keys: []f64) Error!usize {
    return sampleWeightedIndicesU32IntoFrom(rng, Weight, weights, out, scratch_keys);
}

pub fn sampleWeightedIndicesU32IntoFrom(source: anytype, comptime Weight: type, weights: []const Weight, out: []u32, scratch_keys: []f64) Error!usize {
    if (out.len == 0) return 0;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (weights.len == 0) return error.EmptyInput;
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;

    const positive = try countPositiveWeights(Weight, weights);
    const count = @min(out.len, positive);
    if (count == 0) return 0;
    if (positive == 1) {
        out[0] = @intCast((try singlePositiveWeightIndex(Weight, weights)).?);
        return 1;
    }

    sampleWeightedIndicesU32IntoExactFrom(source, Weight, weights, out[0..count], scratch_keys[0..count]);
    return count;
}

pub fn sampleWeightedIndicesU32IntoChecked(rng: Rng, comptime Weight: type, weights: []const Weight, out: []u32, scratch_keys: []f64) Error!void {
    return sampleWeightedIndicesU32IntoCheckedFrom(rng, Weight, weights, out, scratch_keys);
}

pub fn sampleWeightedIndicesU32IntoCheckedFrom(source: anytype, comptime Weight: type, weights: []const Weight, out: []u32, scratch_keys: []f64) Error!void {
    if (out.len == 0) return;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > weights.len or weights.len > std.math.maxInt(u32)) return error.InvalidParameter;

    const positive = try countPositiveWeights(Weight, weights);
    if (positive < out.len) return error.InvalidParameter;
    if (positive == 1) {
        out[0] = @intCast((try singlePositiveWeightIndex(Weight, weights)).?);
        return;
    }

    sampleWeightedIndicesU32IntoExactFrom(source, Weight, weights, out, scratch_keys[0..out.len]);
}

pub fn sampleWeightedIndicesByIndexInto(
    rng: Rng,
    comptime Weight: type,
    length: usize,
    out: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (usize) Weight,
) Error!usize {
    return sampleWeightedIndicesByIndexIntoFrom(rng, Weight, length, out, scratch_keys, weightFn);
}

pub fn sampleWeightedIndicesByIndexIntoFrom(
    source: anytype,
    comptime Weight: type,
    length: usize,
    out: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (usize) Weight,
) Error!usize {
    if (out.len == 0) return 0;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (length == 0) return error.EmptyInput;

    const positive = try countPositiveIndicesBy(Weight, length, weightFn);
    const count = @min(out.len, positive);
    if (count == 0) return 0;
    if (positive == 1) {
        out[0] = (try singlePositiveIndexBy(Weight, length, weightFn)).?;
        return 1;
    }

    sampleWeightedIndicesByIndexIntoExactFrom(source, Weight, length, out[0..count], scratch_keys[0..count], weightFn);
    return count;
}

pub fn sampleWeightedIndicesByIndexIntoChecked(
    rng: Rng,
    comptime Weight: type,
    length: usize,
    out: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (usize) Weight,
) Error!void {
    return sampleWeightedIndicesByIndexIntoCheckedFrom(rng, Weight, length, out, scratch_keys, weightFn);
}

pub fn sampleWeightedIndicesByIndexIntoCheckedFrom(
    source: anytype,
    comptime Weight: type,
    length: usize,
    out: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (usize) Weight,
) Error!void {
    if (out.len == 0) return;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > length) return error.InvalidParameter;

    const positive = try countPositiveIndicesBy(Weight, length, weightFn);
    if (positive < out.len) return error.InvalidParameter;
    if (positive == 1) {
        out[0] = (try singlePositiveIndexBy(Weight, length, weightFn)).?;
        return;
    }

    sampleWeightedIndicesByIndexIntoExactFrom(source, Weight, length, out, scratch_keys[0..out.len], weightFn);
}

pub fn sampleWeightedIndicesU32ByIndexInto(
    rng: Rng,
    comptime Weight: type,
    length: usize,
    out: []u32,
    scratch_keys: []f64,
    comptime weightFn: fn (usize) Weight,
) Error!usize {
    return sampleWeightedIndicesU32ByIndexIntoFrom(rng, Weight, length, out, scratch_keys, weightFn);
}

pub fn sampleWeightedIndicesU32ByIndexIntoFrom(
    source: anytype,
    comptime Weight: type,
    length: usize,
    out: []u32,
    scratch_keys: []f64,
    comptime weightFn: fn (usize) Weight,
) Error!usize {
    if (out.len == 0) return 0;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (length == 0) return error.EmptyInput;
    if (length > std.math.maxInt(u32)) return error.InvalidParameter;

    const positive = try countPositiveIndicesBy(Weight, length, weightFn);
    const count = @min(out.len, positive);
    if (count == 0) return 0;
    if (positive == 1) {
        out[0] = @intCast((try singlePositiveIndexBy(Weight, length, weightFn)).?);
        return 1;
    }

    sampleWeightedIndicesU32ByIndexIntoExactFrom(source, Weight, length, out[0..count], scratch_keys[0..count], weightFn);
    return count;
}

pub fn sampleWeightedIndicesU32ByIndexIntoChecked(
    rng: Rng,
    comptime Weight: type,
    length: usize,
    out: []u32,
    scratch_keys: []f64,
    comptime weightFn: fn (usize) Weight,
) Error!void {
    return sampleWeightedIndicesU32ByIndexIntoCheckedFrom(rng, Weight, length, out, scratch_keys, weightFn);
}

pub fn sampleWeightedIndicesU32ByIndexIntoCheckedFrom(
    source: anytype,
    comptime Weight: type,
    length: usize,
    out: []u32,
    scratch_keys: []f64,
    comptime weightFn: fn (usize) Weight,
) Error!void {
    if (out.len == 0) return;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > length or length > std.math.maxInt(u32)) return error.InvalidParameter;

    const positive = try countPositiveIndicesBy(Weight, length, weightFn);
    if (positive < out.len) return error.InvalidParameter;
    if (positive == 1) {
        out[0] = @intCast((try singlePositiveIndexBy(Weight, length, weightFn)).?);
        return;
    }

    sampleWeightedIndicesU32ByIndexIntoExactFrom(source, Weight, length, out, scratch_keys[0..out.len], weightFn);
}

pub fn sampleWeightedIndicesByInto(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) Error!usize {
    return sampleWeightedIndicesByIntoFrom(rng, T, Weight, items, out, scratch_keys, weightFn);
}

pub fn sampleWeightedIndicesByIntoFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) Error!usize {
    if (out.len == 0) return 0;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (items.len == 0) return error.EmptyInput;

    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    const count = @min(out.len, positive);
    if (count == 0) return 0;
    if (positive == 1) {
        out[0] = (try singlePositiveItemIndexBy(T, Weight, items, weightFn)).?;
        return 1;
    }

    sampleWeightedIndicesByIntoExactFrom(source, T, Weight, items, out[0..count], scratch_keys[0..count], weightFn);
    return count;
}

pub fn sampleWeightedIndicesByIntoChecked(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) Error!void {
    return sampleWeightedIndicesByIntoCheckedFrom(rng, T, Weight, items, out, scratch_keys, weightFn);
}

pub fn sampleWeightedIndicesByIntoCheckedFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) Error!void {
    if (out.len == 0) return;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > items.len) return error.InvalidParameter;

    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    if (positive < out.len) return error.InvalidParameter;
    if (positive == 1) {
        out[0] = (try singlePositiveItemIndexBy(T, Weight, items, weightFn)).?;
        return;
    }

    sampleWeightedIndicesByIntoExactFrom(source, T, Weight, items, out, scratch_keys[0..out.len], weightFn);
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

pub fn sampleWeightedIndexArrayU32(rng: Rng, comptime Weight: type, comptime N: usize, weights: []const Weight) Error!?[N]u32 {
    return sampleWeightedIndexArrayU32From(rng, Weight, N, weights);
}

pub fn sampleWeightedIndexArrayU32From(source: anytype, comptime Weight: type, comptime N: usize, weights: []const Weight) Error!?[N]u32 {
    if (comptime N == 0) return .{};
    if (weights.len == 0) return error.EmptyInput;
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    return sampleWeightedIndexArrayU32ExactFrom(source, Weight, N, weights);
}

pub fn sampleWeightedIndexArrayU32Checked(rng: Rng, comptime Weight: type, comptime N: usize, weights: []const Weight) Error![N]u32 {
    return sampleWeightedIndexArrayU32CheckedFrom(rng, Weight, N, weights);
}

pub fn sampleWeightedIndexArrayU32CheckedFrom(source: anytype, comptime Weight: type, comptime N: usize, weights: []const Weight) Error![N]u32 {
    if (comptime N == 0) return .{};
    if (N > weights.len or weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    return (try sampleWeightedIndexArrayU32ExactFrom(source, Weight, N, weights)) orelse error.InvalidParameter;
}

pub fn sampleWeightedIndexArrayByIndex(
    rng: Rng,
    comptime Weight: type,
    comptime N: usize,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) Error!?[N]usize {
    return sampleWeightedIndexArrayByIndexFrom(rng, Weight, N, length, weightFn);
}

pub fn sampleWeightedIndexArrayByIndexFrom(
    source: anytype,
    comptime Weight: type,
    comptime N: usize,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) Error!?[N]usize {
    if (comptime N == 0) return .{};
    if (length == 0) return error.EmptyInput;
    return sampleWeightedIndexArrayByIndexExactFrom(source, Weight, N, length, weightFn);
}

pub fn sampleWeightedIndexArrayByIndexChecked(
    rng: Rng,
    comptime Weight: type,
    comptime N: usize,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) Error![N]usize {
    return sampleWeightedIndexArrayByIndexCheckedFrom(rng, Weight, N, length, weightFn);
}

pub fn sampleWeightedIndexArrayByIndexCheckedFrom(
    source: anytype,
    comptime Weight: type,
    comptime N: usize,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) Error![N]usize {
    if (comptime N == 0) return .{};
    if (N > length) return error.InvalidParameter;
    return (try sampleWeightedIndexArrayByIndexExactFrom(source, Weight, N, length, weightFn)) orelse error.InvalidParameter;
}

pub fn sampleWeightedIndexArrayU32ByIndex(
    rng: Rng,
    comptime Weight: type,
    comptime N: usize,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) Error!?[N]u32 {
    return sampleWeightedIndexArrayU32ByIndexFrom(rng, Weight, N, length, weightFn);
}

pub fn sampleWeightedIndexArrayU32ByIndexFrom(
    source: anytype,
    comptime Weight: type,
    comptime N: usize,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) Error!?[N]u32 {
    if (comptime N == 0) return .{};
    if (length == 0) return error.EmptyInput;
    if (length > std.math.maxInt(u32)) return error.InvalidParameter;
    return sampleWeightedIndexArrayU32ByIndexExactFrom(source, Weight, N, length, weightFn);
}

pub fn sampleWeightedIndexArrayU32ByIndexChecked(
    rng: Rng,
    comptime Weight: type,
    comptime N: usize,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) Error![N]u32 {
    return sampleWeightedIndexArrayU32ByIndexCheckedFrom(rng, Weight, N, length, weightFn);
}

pub fn sampleWeightedIndexArrayU32ByIndexCheckedFrom(
    source: anytype,
    comptime Weight: type,
    comptime N: usize,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) Error![N]u32 {
    if (comptime N == 0) return .{};
    if (N > length or length > std.math.maxInt(u32)) return error.InvalidParameter;
    return (try sampleWeightedIndexArrayU32ByIndexExactFrom(source, Weight, N, length, weightFn)) orelse error.InvalidParameter;
}

pub fn sampleWeightedIndexArrayBy(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error!?[N]usize {
    return sampleWeightedIndexArrayByFrom(rng, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedIndexArrayByFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error!?[N]usize {
    if (comptime N == 0) return .{};
    if (items.len == 0) return error.EmptyInput;
    return sampleWeightedIndexArrayByExactFrom(source, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedIndexArrayByChecked(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error![N]usize {
    return sampleWeightedIndexArrayByCheckedFrom(rng, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedIndexArrayByCheckedFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error![N]usize {
    if (comptime N == 0) return .{};
    if (N > items.len) return error.InvalidParameter;
    return (try sampleWeightedIndexArrayByExactFrom(source, T, Weight, N, items, weightFn)) orelse error.InvalidParameter;
}

pub fn sampleWeightedIndexArrayU32By(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error!?[N]u32 {
    return sampleWeightedIndexArrayU32ByFrom(rng, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedIndexArrayU32ByFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error!?[N]u32 {
    if (comptime N == 0) return .{};
    if (items.len == 0) return error.EmptyInput;
    if (items.len > std.math.maxInt(u32)) return error.InvalidParameter;
    return sampleWeightedIndexArrayU32ByExactFrom(source, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedIndexArrayU32ByChecked(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error![N]u32 {
    return sampleWeightedIndexArrayU32ByCheckedFrom(rng, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedIndexArrayU32ByCheckedFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error![N]u32 {
    if (comptime N == 0) return .{};
    if (N > items.len or items.len > std.math.maxInt(u32)) return error.InvalidParameter;
    return (try sampleWeightedIndexArrayU32ByExactFrom(source, T, Weight, N, items, weightFn)) orelse error.InvalidParameter;
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

fn sampleWeightedIndicesU32IntoExactFrom(source: anytype, comptime Weight: type, weights: []const Weight, out: []u32, keys: []f64) void {
    std.debug.assert(out.len > 0);
    std.debug.assert(keys.len == out.len);
    std.debug.assert(weights.len <= std.math.maxInt(u32));

    var count: usize = 0;
    for (weights, 0..) |weight, index| {
        const value = weightAsF64(Weight, weight);
        std.debug.assert(value >= 0 and std.math.isFinite(value));
        if (value == 0) continue;

        const key = weightedSelectionKeyFrom(source, value);
        if (count < out.len) {
            out[count] = @intCast(index);
            keys[count] = key;
            count += 1;
        } else {
            const min_index = minWeightedKeyIndex(keys);
            if (key > keys[min_index]) {
                out[min_index] = @intCast(index);
                keys[min_index] = key;
            }
        }
    }
    std.debug.assert(count == out.len);
    sortWeightedU32IndexKeyPairs(out, keys);
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

fn sortWeightedU32IndexKeyPairs(indices: []u32, keys: []f64) void {
    std.debug.assert(indices.len == keys.len);
    var i: usize = 1;
    while (i < indices.len) : (i += 1) {
        var j = i;
        while (j > 0 and keys[j] < keys[j - 1]) : (j -= 1) {
            std.mem.swap(u32, &indices[j], &indices[j - 1]);
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

fn sampleWeightedIndicesU32ExactFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, weights: []const Weight, amount: usize) ![]u32 {
    std.debug.assert(amount > 0);
    std.debug.assert(amount <= weights.len);
    std.debug.assert(weights.len <= std.math.maxInt(u32));

    const out = try allocator.alloc(u32, amount);
    errdefer allocator.free(out);
    const keys = try allocator.alloc(f64, amount);
    defer allocator.free(keys);

    sampleWeightedIndicesU32IntoExactFrom(source, Weight, weights, out, keys);
    return out;
}

fn sampleWeightedIndexVecExactFrom(allocator: std.mem.Allocator, source: anytype, comptime Weight: type, weights: []const Weight, amount: usize) !IndexVec {
    std.debug.assert(amount > 0);
    std.debug.assert(amount <= weights.len);

    if (weights.len <= std.math.maxInt(u32)) {
        const out = try allocator.alloc(u32, amount);
        errdefer allocator.free(out);
        const keys = try allocator.alloc(f64, amount);
        defer allocator.free(keys);

        sampleWeightedIndicesU32IntoExactFrom(source, Weight, weights, out, keys);
        return .{ .u32 = out };
    }

    const out = try allocator.alloc(usize, amount);
    errdefer allocator.free(out);
    const keys = try allocator.alloc(f64, amount);
    defer allocator.free(keys);

    sampleWeightedIndicesIntoExactFrom(source, Weight, weights, out, keys);
    return .{ .usize = out };
}

fn sampleWeightedIndicesByIndexExactFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) ![]usize {
    std.debug.assert(amount > 0);
    std.debug.assert(amount <= length);

    const out = try allocator.alloc(usize, amount);
    errdefer allocator.free(out);
    const keys = try allocator.alloc(f64, amount);
    defer allocator.free(keys);

    sampleWeightedIndicesByIndexIntoExactFrom(source, Weight, length, out, keys, weightFn);
    return out;
}

fn sampleWeightedIndicesU32ByIndexExactFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) ![]u32 {
    std.debug.assert(amount > 0);
    std.debug.assert(amount <= length);
    std.debug.assert(length <= std.math.maxInt(u32));

    const out = try allocator.alloc(u32, amount);
    errdefer allocator.free(out);
    const keys = try allocator.alloc(f64, amount);
    defer allocator.free(keys);

    sampleWeightedIndicesU32ByIndexIntoExactFrom(source, Weight, length, out, keys, weightFn);
    return out;
}

fn sampleWeightedIndexVecByIndexExactFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime Weight: type,
    length: usize,
    amount: usize,
    comptime weightFn: fn (usize) Weight,
) !IndexVec {
    std.debug.assert(amount > 0);
    std.debug.assert(amount <= length);

    if (length <= std.math.maxInt(u32)) {
        const out = try allocator.alloc(u32, amount);
        errdefer allocator.free(out);
        const keys = try allocator.alloc(f64, amount);
        defer allocator.free(keys);

        sampleWeightedIndicesU32ByIndexIntoExactFrom(source, Weight, length, out, keys, weightFn);
        return .{ .u32 = out };
    }

    const out = try allocator.alloc(usize, amount);
    errdefer allocator.free(out);
    const keys = try allocator.alloc(f64, amount);
    defer allocator.free(keys);

    sampleWeightedIndicesByIndexIntoExactFrom(source, Weight, length, out, keys, weightFn);
    return .{ .usize = out };
}

fn sampleWeightedIndicesByExactFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]usize {
    std.debug.assert(amount > 0);
    std.debug.assert(amount <= items.len);

    const out = try allocator.alloc(usize, amount);
    errdefer allocator.free(out);
    const keys = try allocator.alloc(f64, amount);
    defer allocator.free(keys);

    sampleWeightedIndicesByIntoExactFrom(source, T, Weight, items, out, keys, weightFn);
    return out;
}

fn sampleWeightedIndicesU32ByExactFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]u32 {
    std.debug.assert(amount > 0);
    std.debug.assert(amount <= items.len);
    std.debug.assert(items.len <= std.math.maxInt(u32));

    const out = try allocator.alloc(u32, amount);
    errdefer allocator.free(out);
    const keys = try allocator.alloc(f64, amount);
    defer allocator.free(keys);
    const indices = try allocator.alloc(usize, amount);
    defer allocator.free(indices);

    sampleWeightedIndicesByIntoExactFrom(source, T, Weight, items, indices, keys, weightFn);
    for (indices, out) |index, *slot| slot.* = @intCast(index);
    return out;
}

fn sampleWeightedIndexVecByExactFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) !IndexVec {
    std.debug.assert(amount > 0);
    std.debug.assert(amount <= items.len);

    if (items.len <= std.math.maxInt(u32)) {
        const out = try allocator.alloc(u32, amount);
        errdefer allocator.free(out);
        const keys = try allocator.alloc(f64, amount);
        defer allocator.free(keys);
        const indices = try allocator.alloc(usize, amount);
        defer allocator.free(indices);

        sampleWeightedIndicesByIntoExactFrom(source, T, Weight, items, indices, keys, weightFn);
        for (indices, out) |index, *slot| slot.* = @intCast(index);
        return .{ .u32 = out };
    }

    const out = try allocator.alloc(usize, amount);
    errdefer allocator.free(out);
    const keys = try allocator.alloc(f64, amount);
    defer allocator.free(keys);

    sampleWeightedIndicesByIntoExactFrom(source, T, Weight, items, out, keys, weightFn);
    return .{ .usize = out };
}

fn sampleWeightedIndicesByIntoExactFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []usize,
    keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) void {
    std.debug.assert(out.len > 0);
    std.debug.assert(keys.len == out.len);

    var count: usize = 0;
    for (items, 0..) |*item, index| {
        const value = weightAsF64(Weight, weightFn(item));
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

fn sampleWeightedIndicesByIndexIntoExactFrom(
    source: anytype,
    comptime Weight: type,
    length: usize,
    out: []usize,
    keys: []f64,
    comptime weightFn: fn (usize) Weight,
) void {
    std.debug.assert(out.len > 0);
    std.debug.assert(keys.len == out.len);

    var count: usize = 0;
    var index: usize = 0;
    while (index < length) : (index += 1) {
        const value = weightAsF64(Weight, weightFn(index));
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

fn sampleWeightedIndicesU32ByIndexIntoExactFrom(
    source: anytype,
    comptime Weight: type,
    length: usize,
    out: []u32,
    keys: []f64,
    comptime weightFn: fn (usize) Weight,
) void {
    std.debug.assert(out.len > 0);
    std.debug.assert(keys.len == out.len);
    std.debug.assert(length <= std.math.maxInt(u32));

    var count: usize = 0;
    var index: usize = 0;
    while (index < length) : (index += 1) {
        const value = weightAsF64(Weight, weightFn(index));
        std.debug.assert(value >= 0 and std.math.isFinite(value));
        if (value == 0) continue;

        const key = weightedSelectionKeyFrom(source, value);
        if (count < out.len) {
            out[count] = @intCast(index);
            keys[count] = key;
            count += 1;
        } else {
            const min_index = minWeightedKeyIndex(keys);
            if (key > keys[min_index]) {
                out[min_index] = @intCast(index);
                keys[min_index] = key;
            }
        }
    }
    std.debug.assert(count == out.len);
    sortWeightedU32IndexKeyPairs(out, keys);
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

pub fn sampleWeightedBy(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]T {
    return sampleWeightedByFrom(allocator, rng, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedByChecked(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]T {
    return sampleWeightedByCheckedFrom(allocator, rng, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedByCheckedFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);
    if (amount > items.len) return error.InvalidParameter;
    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositiveItemByAlloc(allocator, T, Weight, items, weightFn);

    const out = try allocator.alloc(T, amount);
    errdefer allocator.free(out);
    const indices = try sampleWeightedIndicesByExactFrom(allocator, source, T, Weight, items, amount, weightFn);
    defer allocator.free(indices);

    for (indices, out) |index, *slot| slot.* = items[index];
    return out;
}

pub fn sampleWeightedByFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);
    if (items.len == 0) return error.EmptyInput;

    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    const count = @min(amount, positive);
    if (count == 0) return allocator.alloc(T, 0);
    if (positive == 1) return singlePositiveItemByAlloc(allocator, T, Weight, items, weightFn);

    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    const indices = try sampleWeightedIndicesByExactFrom(allocator, source, T, Weight, items, count, weightFn);
    defer allocator.free(indices);

    for (indices, out) |index, *slot| slot.* = items[index];
    return out;
}

pub fn sampleWeightedPtrsBy(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]*const T {
    return sampleWeightedPtrsByFrom(allocator, rng, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedPtrsByChecked(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]*const T {
    return sampleWeightedPtrsByCheckedFrom(allocator, rng, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedPtrsByCheckedFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]*const T {
    if (amount == 0) return allocator.alloc(*const T, 0);
    if (amount > items.len) return error.InvalidParameter;
    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositivePtrByAlloc(allocator, T, Weight, items, weightFn);
    return sampleWeightedPtrsByExactFrom(allocator, source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedPtrsByFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]*const T {
    if (amount == 0) return allocator.alloc(*const T, 0);
    if (items.len == 0) return error.EmptyInput;

    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    const count = @min(amount, positive);
    if (count == 0) return allocator.alloc(*const T, 0);
    if (positive == 1) return singlePositivePtrByAlloc(allocator, T, Weight, items, weightFn);
    return sampleWeightedPtrsByExactFrom(allocator, source, T, Weight, items, count, weightFn);
}

pub fn sampleWeightedMutPtrsBy(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]*T {
    return sampleWeightedMutPtrsByFrom(allocator, rng, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedMutPtrsByChecked(
    allocator: std.mem.Allocator,
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]*T {
    return sampleWeightedMutPtrsByCheckedFrom(allocator, rng, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedMutPtrsByCheckedFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]*T {
    if (amount == 0) return allocator.alloc(*T, 0);
    if (amount > items.len) return error.InvalidParameter;
    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) return singlePositiveMutPtrByAlloc(allocator, T, Weight, items, weightFn);
    return sampleWeightedMutPtrsByExactFrom(allocator, source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedMutPtrsByFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]*T {
    if (amount == 0) return allocator.alloc(*T, 0);
    if (items.len == 0) return error.EmptyInput;

    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    const count = @min(amount, positive);
    if (count == 0) return allocator.alloc(*T, 0);
    if (positive == 1) return singlePositiveMutPtrByAlloc(allocator, T, Weight, items, weightFn);
    return sampleWeightedMutPtrsByExactFrom(allocator, source, T, Weight, items, count, weightFn);
}

fn sampleWeightedPtrsByExactFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]*const T {
    const out = try allocator.alloc(*const T, amount);
    errdefer allocator.free(out);

    const indices = try sampleWeightedIndicesByExactFrom(allocator, source, T, Weight, items, amount, weightFn);
    defer allocator.free(indices);

    for (indices, out) |index, *slot| slot.* = &items[index];
    return out;
}

fn sampleWeightedMutPtrsByExactFrom(
    allocator: std.mem.Allocator,
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    amount: usize,
    comptime weightFn: fn (*const T) Weight,
) ![]*T {
    const out = try allocator.alloc(*T, amount);
    errdefer allocator.free(out);

    const indices = try sampleWeightedIndicesByExactFrom(allocator, source, T, Weight, items, amount, weightFn);
    defer allocator.free(indices);

    for (indices, out) |index, *slot| slot.* = &items[index];
    return out;
}

pub fn sampleWeightedPtrs(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, amount: usize) ![]*const T {
    return sampleWeightedPtrsFrom(allocator, rng, T, Weight, items, weights, amount);
}

pub fn sampleWeightedPtrsChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, amount: usize) ![]*const T {
    return sampleWeightedPtrsCheckedFrom(allocator, rng, T, Weight, items, weights, amount);
}

pub fn sampleWeightedPtrsCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, amount: usize) ![]*const T {
    if (amount == 0) return allocator.alloc(*const T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    if (amount > items.len) return error.InvalidParameter;
    const positive = try countPositiveWeights(Weight, weights);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) {
        const index = (try singlePositiveWeightIndex(Weight, weights)).?;
        const out = try allocator.alloc(*const T, 1);
        out[0] = &items[index];
        return out;
    }
    return sampleWeightedPtrsExactFrom(allocator, source, T, Weight, items, weights, amount);
}

pub fn sampleWeightedPtrsFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, amount: usize) ![]*const T {
    if (amount == 0) return allocator.alloc(*const T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    if (items.len == 0) return error.EmptyInput;

    const positive = try countPositiveWeights(Weight, weights);
    const count = @min(amount, positive);
    if (count == 0) return allocator.alloc(*const T, 0);
    if (positive == 1) {
        const index = (try singlePositiveWeightIndex(Weight, weights)).?;
        const out = try allocator.alloc(*const T, 1);
        out[0] = &items[index];
        return out;
    }
    return sampleWeightedPtrsExactFrom(allocator, source, T, Weight, items, weights, count);
}

pub fn sampleWeightedMutPtrs(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight, amount: usize) ![]*T {
    return sampleWeightedMutPtrsFrom(allocator, rng, T, Weight, items, weights, amount);
}

pub fn sampleWeightedMutPtrsChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight, amount: usize) ![]*T {
    return sampleWeightedMutPtrsCheckedFrom(allocator, rng, T, Weight, items, weights, amount);
}

pub fn sampleWeightedMutPtrsCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight, amount: usize) ![]*T {
    if (amount == 0) return allocator.alloc(*T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    if (amount > items.len) return error.InvalidParameter;
    const positive = try countPositiveWeights(Weight, weights);
    if (positive < amount) return error.InvalidParameter;
    if (positive == 1 and amount == 1) {
        const index = (try singlePositiveWeightIndex(Weight, weights)).?;
        const out = try allocator.alloc(*T, 1);
        out[0] = &items[index];
        return out;
    }
    return sampleWeightedMutPtrsExactFrom(allocator, source, T, Weight, items, weights, amount);
}

pub fn sampleWeightedMutPtrsFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight, amount: usize) ![]*T {
    if (amount == 0) return allocator.alloc(*T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    if (items.len == 0) return error.EmptyInput;

    const positive = try countPositiveWeights(Weight, weights);
    const count = @min(amount, positive);
    if (count == 0) return allocator.alloc(*T, 0);
    if (positive == 1) {
        const index = (try singlePositiveWeightIndex(Weight, weights)).?;
        const out = try allocator.alloc(*T, 1);
        out[0] = &items[index];
        return out;
    }
    return sampleWeightedMutPtrsExactFrom(allocator, source, T, Weight, items, weights, count);
}

fn sampleWeightedPtrsExactFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, amount: usize) ![]*const T {
    const out = try allocator.alloc(*const T, amount);
    errdefer allocator.free(out);

    const indices = try sampleWeightedIndicesExactFrom(allocator, source, Weight, weights, amount);
    defer allocator.free(indices);

    for (indices, out) |index, *slot| slot.* = &items[index];
    return out;
}

fn sampleWeightedMutPtrsExactFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight, amount: usize) ![]*T {
    const out = try allocator.alloc(*T, amount);
    errdefer allocator.free(out);

    const indices = try sampleWeightedIndicesExactFrom(allocator, source, Weight, weights, amount);
    defer allocator.free(indices);

    for (indices, out) |index, *slot| slot.* = &items[index];
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

pub fn sampleWeightedByInto(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []T,
    scratch_indices: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) !usize {
    return sampleWeightedByIntoFrom(rng, T, Weight, items, out, scratch_indices, scratch_keys, weightFn);
}

pub fn sampleWeightedByIntoFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []T,
    scratch_indices: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) !usize {
    if (out.len == 0) return 0;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;

    const count = try sampleWeightedIndicesByIntoFrom(source, T, Weight, items, scratch_indices[0..out.len], scratch_keys[0..out.len], weightFn);
    for (scratch_indices[0..count], out[0..count]) |index, *slot| slot.* = items[index];
    return count;
}

pub fn sampleWeightedByIntoChecked(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []T,
    scratch_indices: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) !void {
    return sampleWeightedByIntoCheckedFrom(rng, T, Weight, items, out, scratch_indices, scratch_keys, weightFn);
}

pub fn sampleWeightedByIntoCheckedFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []T,
    scratch_indices: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) !void {
    if (out.len == 0) return;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;

    try sampleWeightedIndicesByIntoCheckedFrom(source, T, Weight, items, scratch_indices[0..out.len], scratch_keys[0..out.len], weightFn);
    for (scratch_indices[0..out.len], out) |index, *slot| slot.* = items[index];
}

pub fn sampleWeightedPtrsInto(rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, out: []*const T, scratch_indices: []usize, scratch_keys: []f64) !usize {
    return sampleWeightedPtrsIntoFrom(rng, T, Weight, items, weights, out, scratch_indices, scratch_keys);
}

pub fn sampleWeightedPtrsIntoFrom(source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, out: []*const T, scratch_indices: []usize, scratch_keys: []f64) !usize {
    if (out.len == 0) return 0;
    if (items.len != weights.len) return error.LengthMismatch;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;

    const count = try sampleWeightedIndicesIntoFrom(source, Weight, weights, scratch_indices[0..out.len], scratch_keys[0..out.len]);
    for (scratch_indices[0..count], out[0..count]) |index, *slot| slot.* = &items[index];
    return count;
}

pub fn sampleWeightedPtrsIntoChecked(rng: Rng, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, out: []*const T, scratch_indices: []usize, scratch_keys: []f64) !void {
    return sampleWeightedPtrsIntoCheckedFrom(rng, T, Weight, items, weights, out, scratch_indices, scratch_keys);
}

pub fn sampleWeightedPtrsIntoCheckedFrom(source: anytype, comptime T: type, comptime Weight: type, items: []const T, weights: []const Weight, out: []*const T, scratch_indices: []usize, scratch_keys: []f64) !void {
    if (out.len == 0) return;
    if (items.len != weights.len) return error.LengthMismatch;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;

    try sampleWeightedIndicesIntoCheckedFrom(source, Weight, weights, scratch_indices[0..out.len], scratch_keys[0..out.len]);
    for (scratch_indices[0..out.len], out) |index, *slot| slot.* = &items[index];
}

pub fn sampleWeightedPtrsByInto(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []*const T,
    scratch_indices: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) !usize {
    return sampleWeightedPtrsByIntoFrom(rng, T, Weight, items, out, scratch_indices, scratch_keys, weightFn);
}

pub fn sampleWeightedPtrsByIntoFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []*const T,
    scratch_indices: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) !usize {
    if (out.len == 0) return 0;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;

    const count = try sampleWeightedIndicesByIntoFrom(source, T, Weight, items, scratch_indices[0..out.len], scratch_keys[0..out.len], weightFn);
    for (scratch_indices[0..count], out[0..count]) |index, *slot| slot.* = &items[index];
    return count;
}

pub fn sampleWeightedPtrsByIntoChecked(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []*const T,
    scratch_indices: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) !void {
    return sampleWeightedPtrsByIntoCheckedFrom(rng, T, Weight, items, out, scratch_indices, scratch_keys, weightFn);
}

pub fn sampleWeightedPtrsByIntoCheckedFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    out: []*const T,
    scratch_indices: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) !void {
    if (out.len == 0) return;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;

    try sampleWeightedIndicesByIntoCheckedFrom(source, T, Weight, items, scratch_indices[0..out.len], scratch_keys[0..out.len], weightFn);
    for (scratch_indices[0..out.len], out) |index, *slot| slot.* = &items[index];
}

pub fn sampleWeightedMutPtrsInto(rng: Rng, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight, out: []*T, scratch_indices: []usize, scratch_keys: []f64) !usize {
    return sampleWeightedMutPtrsIntoFrom(rng, T, Weight, items, weights, out, scratch_indices, scratch_keys);
}

pub fn sampleWeightedMutPtrsIntoFrom(source: anytype, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight, out: []*T, scratch_indices: []usize, scratch_keys: []f64) !usize {
    if (out.len == 0) return 0;
    if (items.len != weights.len) return error.LengthMismatch;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;

    const count = try sampleWeightedIndicesIntoFrom(source, Weight, weights, scratch_indices[0..out.len], scratch_keys[0..out.len]);
    for (scratch_indices[0..count], out[0..count]) |index, *slot| slot.* = &items[index];
    return count;
}

pub fn sampleWeightedMutPtrsIntoChecked(rng: Rng, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight, out: []*T, scratch_indices: []usize, scratch_keys: []f64) !void {
    return sampleWeightedMutPtrsIntoCheckedFrom(rng, T, Weight, items, weights, out, scratch_indices, scratch_keys);
}

pub fn sampleWeightedMutPtrsIntoCheckedFrom(source: anytype, comptime T: type, comptime Weight: type, items: []T, weights: []const Weight, out: []*T, scratch_indices: []usize, scratch_keys: []f64) !void {
    if (out.len == 0) return;
    if (items.len != weights.len) return error.LengthMismatch;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;

    try sampleWeightedIndicesIntoCheckedFrom(source, Weight, weights, scratch_indices[0..out.len], scratch_keys[0..out.len]);
    for (scratch_indices[0..out.len], out) |index, *slot| slot.* = &items[index];
}

pub fn sampleWeightedMutPtrsByInto(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    out: []*T,
    scratch_indices: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) !usize {
    return sampleWeightedMutPtrsByIntoFrom(rng, T, Weight, items, out, scratch_indices, scratch_keys, weightFn);
}

pub fn sampleWeightedMutPtrsByIntoFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    out: []*T,
    scratch_indices: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) !usize {
    if (out.len == 0) return 0;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;

    const count = try sampleWeightedIndicesByIntoFrom(source, T, Weight, items, scratch_indices[0..out.len], scratch_keys[0..out.len], weightFn);
    for (scratch_indices[0..count], out[0..count]) |index, *slot| slot.* = &items[index];
    return count;
}

pub fn sampleWeightedMutPtrsByIntoChecked(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    out: []*T,
    scratch_indices: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) !void {
    return sampleWeightedMutPtrsByIntoCheckedFrom(rng, T, Weight, items, out, scratch_indices, scratch_keys, weightFn);
}

pub fn sampleWeightedMutPtrsByIntoCheckedFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    out: []*T,
    scratch_indices: []usize,
    scratch_keys: []f64,
    comptime weightFn: fn (*const T) Weight,
) !void {
    if (out.len == 0) return;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;

    try sampleWeightedIndicesByIntoCheckedFrom(source, T, Weight, items, scratch_indices[0..out.len], scratch_keys[0..out.len], weightFn);
    for (scratch_indices[0..out.len], out) |index, *slot| slot.* = &items[index];
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

pub fn sampleWeightedArrayBy(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !?[N]T {
    return sampleWeightedArrayByFrom(rng, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedArrayByFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !?[N]T {
    const indices = (try sampleWeightedIndexArrayByFrom(source, T, Weight, N, items, weightFn)) orelse return null;
    var out: [N]T = undefined;
    inline for (0..N) |i| out[i] = items[indices[i]];
    return out;
}

pub fn sampleWeightedArrayByChecked(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) ![N]T {
    return sampleWeightedArrayByCheckedFrom(rng, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedArrayByCheckedFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) ![N]T {
    const indices = try sampleWeightedIndexArrayByCheckedFrom(source, T, Weight, N, items, weightFn);
    var out: [N]T = undefined;
    inline for (0..N) |i| out[i] = items[indices[i]];
    return out;
}

pub fn sampleWeightedPtrArray(rng: Rng, comptime T: type, comptime Weight: type, comptime N: usize, items: []const T, weights: []const Weight) !?[N]*const T {
    return sampleWeightedPtrArrayFrom(rng, T, Weight, N, items, weights);
}

pub fn sampleWeightedPtrArrayFrom(source: anytype, comptime T: type, comptime Weight: type, comptime N: usize, items: []const T, weights: []const Weight) !?[N]*const T {
    if (comptime N == 0) return .{};
    if (items.len != weights.len) return error.LengthMismatch;
    if (items.len == 0) return null;

    const indices = (try sampleWeightedIndexArrayExactFrom(source, Weight, N, weights)) orelse return null;
    var out: [N]*const T = undefined;
    inline for (0..N) |i| out[i] = &items[indices[i]];
    return out;
}

pub fn sampleWeightedPtrArrayChecked(rng: Rng, comptime T: type, comptime Weight: type, comptime N: usize, items: []const T, weights: []const Weight) ![N]*const T {
    return sampleWeightedPtrArrayCheckedFrom(rng, T, Weight, N, items, weights);
}

pub fn sampleWeightedPtrArrayCheckedFrom(source: anytype, comptime T: type, comptime Weight: type, comptime N: usize, items: []const T, weights: []const Weight) ![N]*const T {
    if (comptime N == 0) return .{};
    if (items.len != weights.len) return error.LengthMismatch;
    if (N > items.len) return error.InvalidParameter;

    const indices = (try sampleWeightedIndexArrayExactFrom(source, Weight, N, weights)) orelse return error.InvalidParameter;
    var out: [N]*const T = undefined;
    inline for (0..N) |i| out[i] = &items[indices[i]];
    return out;
}

pub fn sampleWeightedPtrArrayBy(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !?[N]*const T {
    return sampleWeightedPtrArrayByFrom(rng, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedPtrArrayByFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !?[N]*const T {
    const indices = (try sampleWeightedIndexArrayByFrom(source, T, Weight, N, items, weightFn)) orelse return null;
    var out: [N]*const T = undefined;
    inline for (0..N) |i| out[i] = &items[indices[i]];
    return out;
}

pub fn sampleWeightedPtrArrayByChecked(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) ![N]*const T {
    return sampleWeightedPtrArrayByCheckedFrom(rng, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedPtrArrayByCheckedFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) ![N]*const T {
    const indices = try sampleWeightedIndexArrayByCheckedFrom(source, T, Weight, N, items, weightFn);
    var out: [N]*const T = undefined;
    inline for (0..N) |i| out[i] = &items[indices[i]];
    return out;
}

pub fn sampleWeightedMutPtrArray(rng: Rng, comptime T: type, comptime Weight: type, comptime N: usize, items: []T, weights: []const Weight) !?[N]*T {
    return sampleWeightedMutPtrArrayFrom(rng, T, Weight, N, items, weights);
}

pub fn sampleWeightedMutPtrArrayFrom(source: anytype, comptime T: type, comptime Weight: type, comptime N: usize, items: []T, weights: []const Weight) !?[N]*T {
    if (comptime N == 0) return .{};
    if (items.len != weights.len) return error.LengthMismatch;
    if (items.len == 0) return null;

    const indices = (try sampleWeightedIndexArrayExactFrom(source, Weight, N, weights)) orelse return null;
    var out: [N]*T = undefined;
    inline for (0..N) |i| out[i] = &items[indices[i]];
    return out;
}

pub fn sampleWeightedMutPtrArrayChecked(rng: Rng, comptime T: type, comptime Weight: type, comptime N: usize, items: []T, weights: []const Weight) ![N]*T {
    return sampleWeightedMutPtrArrayCheckedFrom(rng, T, Weight, N, items, weights);
}

pub fn sampleWeightedMutPtrArrayCheckedFrom(source: anytype, comptime T: type, comptime Weight: type, comptime N: usize, items: []T, weights: []const Weight) ![N]*T {
    if (comptime N == 0) return .{};
    if (items.len != weights.len) return error.LengthMismatch;
    if (N > items.len) return error.InvalidParameter;

    const indices = (try sampleWeightedIndexArrayExactFrom(source, Weight, N, weights)) orelse return error.InvalidParameter;
    var out: [N]*T = undefined;
    inline for (0..N) |i| out[i] = &items[indices[i]];
    return out;
}

pub fn sampleWeightedMutPtrArrayBy(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []T,
    comptime weightFn: fn (*const T) Weight,
) !?[N]*T {
    return sampleWeightedMutPtrArrayByFrom(rng, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedMutPtrArrayByFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []T,
    comptime weightFn: fn (*const T) Weight,
) !?[N]*T {
    const indices = (try sampleWeightedIndexArrayByFrom(source, T, Weight, N, items, weightFn)) orelse return null;
    var out: [N]*T = undefined;
    inline for (0..N) |i| out[i] = &items[indices[i]];
    return out;
}

pub fn sampleWeightedMutPtrArrayByChecked(
    rng: Rng,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []T,
    comptime weightFn: fn (*const T) Weight,
) ![N]*T {
    return sampleWeightedMutPtrArrayByCheckedFrom(rng, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedMutPtrArrayByCheckedFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []T,
    comptime weightFn: fn (*const T) Weight,
) ![N]*T {
    const indices = try sampleWeightedIndexArrayByCheckedFrom(source, T, Weight, N, items, weightFn);
    var out: [N]*T = undefined;
    inline for (0..N) |i| out[i] = &items[indices[i]];
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

fn sampleWeightedIndexArrayU32ExactFrom(source: anytype, comptime Weight: type, comptime N: usize, weights: []const Weight) Error!?[N]u32 {
    if (comptime N == 0) return .{};
    std.debug.assert(weights.len <= std.math.maxInt(u32));

    const positive = try countPositiveWeights(Weight, weights);
    if (positive < N) return null;
    if (positive == 1 and comptime N == 1) {
        return .{@intCast((try singlePositiveWeightIndex(Weight, weights)).?)};
    }

    var candidates: [N]WeightedU32Candidate = undefined;
    var count: usize = 0;
    for (weights, 0..) |weight, index| {
        const value = weightAsF64(Weight, weight);
        if (value == 0) continue;

        const candidate = WeightedU32Candidate{
            .index = @intCast(index),
            .key = weightedSelectionKeyFrom(source, value),
        };
        if (count < N) {
            candidates[count] = candidate;
            count += 1;
        } else {
            const min_index = minWeightedU32CandidateIndex(candidates[0..]);
            if (compareWeightedU32Candidate({}, candidate, candidates[min_index]) == .gt) {
                candidates[min_index] = candidate;
            }
        }
    }
    std.debug.assert(count == N);
    sortWeightedU32Candidates(candidates[0..]);

    var out: [N]u32 = undefined;
    inline for (0..N) |i| out[i] = candidates[i].index;
    return out;
}

fn sampleWeightedIndexArrayByExactFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error!?[N]usize {
    if (comptime N == 0) return .{};

    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    if (positive < N) return null;
    if (positive == 1 and comptime N == 1) {
        return .{(try singlePositiveItemIndexBy(T, Weight, items, weightFn)).?};
    }

    var candidates: [N]WeightedCandidate = undefined;
    var count: usize = 0;
    for (items, 0..) |*item, index| {
        const value = weightAsF64(Weight, weightFn(item));
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

fn sampleWeightedIndexArrayU32ByExactFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    comptime N: usize,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error!?[N]u32 {
    if (comptime N == 0) return .{};
    std.debug.assert(items.len <= std.math.maxInt(u32));

    const positive = try countPositiveItemsBy(T, Weight, items, weightFn);
    if (positive < N) return null;
    if (positive == 1 and comptime N == 1) {
        return .{@intCast((try singlePositiveItemIndexBy(T, Weight, items, weightFn)).?)};
    }

    var candidates: [N]WeightedU32Candidate = undefined;
    var count: usize = 0;
    for (items, 0..) |*item, index| {
        const value = weightAsF64(Weight, weightFn(item));
        if (value == 0) continue;

        const candidate = WeightedU32Candidate{
            .index = @intCast(index),
            .key = weightedSelectionKeyFrom(source, value),
        };
        if (count < N) {
            candidates[count] = candidate;
            count += 1;
        } else {
            const min_index = minWeightedU32CandidateIndex(candidates[0..]);
            if (compareWeightedU32Candidate({}, candidate, candidates[min_index]) == .gt) {
                candidates[min_index] = candidate;
            }
        }
    }
    std.debug.assert(count == N);
    sortWeightedU32Candidates(candidates[0..]);

    var out: [N]u32 = undefined;
    inline for (0..N) |i| out[i] = candidates[i].index;
    return out;
}

fn sampleWeightedIndexArrayByIndexExactFrom(
    source: anytype,
    comptime Weight: type,
    comptime N: usize,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) Error!?[N]usize {
    if (comptime N == 0) return .{};

    const positive = try countPositiveIndicesBy(Weight, length, weightFn);
    if (positive < N) return null;
    if (positive == 1 and comptime N == 1) {
        return .{(try singlePositiveIndexBy(Weight, length, weightFn)).?};
    }

    var candidates: [N]WeightedCandidate = undefined;
    var count: usize = 0;
    var index: usize = 0;
    while (index < length) : (index += 1) {
        const value = weightAsF64(Weight, weightFn(index));
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

fn sampleWeightedIndexArrayU32ByIndexExactFrom(
    source: anytype,
    comptime Weight: type,
    comptime N: usize,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) Error!?[N]u32 {
    if (comptime N == 0) return .{};
    std.debug.assert(length <= std.math.maxInt(u32));

    const positive = try countPositiveIndicesBy(Weight, length, weightFn);
    if (positive < N) return null;
    if (positive == 1 and comptime N == 1) {
        return .{@intCast((try singlePositiveIndexBy(Weight, length, weightFn)).?)};
    }

    var candidates: [N]WeightedU32Candidate = undefined;
    var count: usize = 0;
    var index: usize = 0;
    while (index < length) : (index += 1) {
        const value = weightAsF64(Weight, weightFn(index));
        if (value == 0) continue;

        const candidate = WeightedU32Candidate{
            .index = @intCast(index),
            .key = weightedSelectionKeyFrom(source, value),
        };
        if (count < N) {
            candidates[count] = candidate;
            count += 1;
        } else {
            const min_index = minWeightedU32CandidateIndex(candidates[0..]);
            if (compareWeightedU32Candidate({}, candidate, candidates[min_index]) == .gt) {
                candidates[min_index] = candidate;
            }
        }
    }
    std.debug.assert(count == N);
    sortWeightedU32Candidates(candidates[0..]);

    var out: [N]u32 = undefined;
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

fn minWeightedU32CandidateIndex(candidates: []const WeightedU32Candidate) usize {
    std.debug.assert(candidates.len > 0);
    var min_index: usize = 0;
    for (candidates[1..], 1..) |candidate, index| {
        if (compareWeightedU32Candidate({}, candidate, candidates[min_index]) == .lt) min_index = index;
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

fn sortWeightedU32Candidates(candidates: []WeightedU32Candidate) void {
    var i: usize = 1;
    while (i < candidates.len) : (i += 1) {
        var j = i;
        while (j > 0 and compareWeightedU32Candidate({}, candidates[j], candidates[j - 1]) == .lt) : (j -= 1) {
            std.mem.swap(WeightedU32Candidate, &candidates[j], &candidates[j - 1]);
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
            return &self.items[self.sampleIndexFrom(source)];
        }

        pub fn sampleIndex(self: Self, rng: Rng) usize {
            return self.sampleIndexFrom(rng);
        }

        pub fn sampleIndexFrom(self: Self, source: anytype) usize {
            if (self.items.len == 1) return 0;
            return Rng.uintLessThanFrom(source, usize, self.items.len);
        }

        pub fn sampleIndexU32(self: Self, rng: Rng) Error!u32 {
            return self.sampleIndexU32From(rng);
        }

        pub fn sampleIndexU32From(self: Self, source: anytype) Error!u32 {
            if (self.items.len > std.math.maxInt(u32)) return error.InvalidParameter;
            if (self.items.len == 1) return 0;
            return Rng.uintLessThanFrom(source, u32, @intCast(self.items.len));
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

        pub fn ptrs(self: Self, allocator: std.mem.Allocator, rng: Rng, amount: usize) ![]*const T {
            return self.ptrsFrom(allocator, rng, amount);
        }

        pub fn ptrsFrom(self: Self, allocator: std.mem.Allocator, source: anytype, amount: usize) ![]*const T {
            const out = try allocator.alloc(*const T, amount);
            errdefer allocator.free(out);
            self.fillFrom(source, out);
            return out;
        }

        pub fn values(self: Self, allocator: std.mem.Allocator, rng: Rng, amount: usize) ![]T {
            return self.valuesFrom(allocator, rng, amount);
        }

        pub fn valuesFrom(self: Self, allocator: std.mem.Allocator, source: anytype, amount: usize) ![]T {
            const out = try allocator.alloc(T, amount);
            errdefer allocator.free(out);
            self.fillValuesFrom(source, out);
            return out;
        }

        pub fn fillIndices(self: Self, rng: Rng, dest: []usize) void {
            self.fillIndicesFrom(rng, dest);
        }

        pub fn fillIndicesFrom(self: Self, source: anytype, dest: []usize) void {
            if (self.items.len == 1) {
                @memset(dest, 0);
                return;
            }
            for (dest) |*index| index.* = Rng.uintLessThanFrom(source, usize, self.items.len);
        }

        pub fn fillIndicesU32(self: Self, rng: Rng, dest: []u32) Error!void {
            return self.fillIndicesU32From(rng, dest);
        }

        pub fn fillIndicesU32From(self: Self, source: anytype, dest: []u32) Error!void {
            if (self.items.len > std.math.maxInt(u32)) return error.InvalidParameter;
            if (self.items.len == 1) {
                @memset(dest, 0);
                return;
            }
            const item_len_u32: u32 = @intCast(self.items.len);
            for (dest) |*index| index.* = Rng.uintLessThanFrom(source, u32, item_len_u32);
        }

        pub fn indices(self: Self, allocator: std.mem.Allocator, rng: Rng, amount: usize) ![]usize {
            return self.indicesFrom(allocator, rng, amount);
        }

        pub fn indicesFrom(self: Self, allocator: std.mem.Allocator, source: anytype, amount: usize) ![]usize {
            const out = try allocator.alloc(usize, amount);
            errdefer allocator.free(out);
            self.fillIndicesFrom(source, out);
            return out;
        }

        pub fn indicesU32(self: Self, allocator: std.mem.Allocator, rng: Rng, amount: usize) ![]u32 {
            return self.indicesU32From(allocator, rng, amount);
        }

        pub fn indicesU32From(self: Self, allocator: std.mem.Allocator, source: anytype, amount: usize) ![]u32 {
            const out = try allocator.alloc(u32, amount);
            errdefer allocator.free(out);
            try self.fillIndicesU32From(source, out);
            return out;
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

        pub fn initBy(
            allocator: std.mem.Allocator,
            items: []const T,
            comptime weightFn: fn (*const T) Weight,
        ) !Self {
            if (items.len == 0) return error.EmptyInput;
            const input_weights = try weightsFromItems(allocator, items, weightFn);
            defer allocator.free(input_weights);
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

        pub fn updateBy(self: *Self, comptime weightFn: fn (*const T) Weight) !void {
            const input_weights = try weightsFromItems(self.table.allocator, self.items, weightFn);
            defer self.table.allocator.free(input_weights);
            try self.table.update(input_weights);
        }

        pub fn sample(self: Self, rng: Rng) *const T {
            return self.sampleFrom(rng);
        }

        pub fn sampleFrom(self: Self, source: anytype) *const T {
            return &self.items[self.sampleIndexFrom(source)];
        }

        pub fn sampleIndex(self: Self, rng: Rng) usize {
            return self.sampleIndexFrom(rng);
        }

        pub fn sampleIndexFrom(self: Self, source: anytype) usize {
            return self.table.sampleFrom(source);
        }

        pub fn sampleIndexU32(self: Self, rng: Rng) Error!u32 {
            return self.sampleIndexU32From(rng);
        }

        pub fn sampleIndexU32From(self: Self, source: anytype) Error!u32 {
            if (self.items.len > std.math.maxInt(u32)) return error.InvalidParameter;
            return @intCast(self.sampleIndexFrom(source));
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

        pub fn ptrs(self: Self, allocator: std.mem.Allocator, rng: Rng, amount: usize) ![]*const T {
            return self.ptrsFrom(allocator, rng, amount);
        }

        pub fn ptrsFrom(self: Self, allocator: std.mem.Allocator, source: anytype, amount: usize) ![]*const T {
            const out = try allocator.alloc(*const T, amount);
            errdefer allocator.free(out);
            self.fillFrom(source, out);
            return out;
        }

        pub fn values(self: Self, allocator: std.mem.Allocator, rng: Rng, amount: usize) ![]T {
            return self.valuesFrom(allocator, rng, amount);
        }

        pub fn valuesFrom(self: Self, allocator: std.mem.Allocator, source: anytype, amount: usize) ![]T {
            const out = try allocator.alloc(T, amount);
            errdefer allocator.free(out);
            self.fillValuesFrom(source, out);
            return out;
        }

        pub fn fillIndices(self: Self, rng: Rng, dest: []usize) void {
            self.fillIndicesFrom(rng, dest);
        }

        pub fn fillIndicesFrom(self: Self, source: anytype, dest: []usize) void {
            if (self.table.constantIndex()) |index| {
                @memset(dest, index);
                return;
            }
            for (dest) |*index| index.* = self.table.sampleFrom(source);
        }

        pub fn fillIndicesU32(self: Self, rng: Rng, dest: []u32) Error!void {
            return self.fillIndicesU32From(rng, dest);
        }

        pub fn fillIndicesU32From(self: Self, source: anytype, dest: []u32) Error!void {
            if (self.items.len > std.math.maxInt(u32)) return error.InvalidParameter;
            if (self.table.constantIndex()) |index| {
                @memset(dest, @intCast(index));
                return;
            }
            for (dest) |*index| index.* = @intCast(self.table.sampleFrom(source));
        }

        pub fn indices(self: Self, allocator: std.mem.Allocator, rng: Rng, amount: usize) ![]usize {
            return self.indicesFrom(allocator, rng, amount);
        }

        pub fn indicesFrom(self: Self, allocator: std.mem.Allocator, source: anytype, amount: usize) ![]usize {
            const out = try allocator.alloc(usize, amount);
            errdefer allocator.free(out);
            self.fillIndicesFrom(source, out);
            return out;
        }

        pub fn indicesU32(self: Self, allocator: std.mem.Allocator, rng: Rng, amount: usize) ![]u32 {
            return self.indicesU32From(allocator, rng, amount);
        }

        pub fn indicesU32From(self: Self, allocator: std.mem.Allocator, source: anytype, amount: usize) ![]u32 {
            if (self.items.len > std.math.maxInt(u32)) return error.InvalidParameter;
            const out = try allocator.alloc(u32, amount);
            errdefer allocator.free(out);
            try self.fillIndicesU32From(source, out);
            return out;
        }

        pub fn iter(self: Self, rng: Rng) Rng.SampleIterator(Self, *const T) {
            return rng.sampleIter(*const T, self);
        }

        pub fn iterFrom(self: Self, source: anytype) Rng.SampleIteratorFrom(@TypeOf(source), Self, *const T) {
            return Rng.sampleIterFrom(source, *const T, self);
        }

        fn weightsFromItems(
            allocator: std.mem.Allocator,
            items: []const T,
            comptime weightFn: fn (*const T) Weight,
        ) ![]Weight {
            const out = try allocator.alloc(Weight, items.len);
            errdefer allocator.free(out);
            for (items, out) |*item, *slot| slot.* = weightFn(item);
            return out;
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

pub fn reservoirSamplePtrs(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]*const T {
    return reservoirSamplePtrsFrom(allocator, rng, T, items, amount);
}

pub fn reservoirSamplePtrsChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []const T, amount: usize) ![]*const T {
    return reservoirSamplePtrsCheckedFrom(allocator, rng, T, items, amount);
}

pub fn reservoirSamplePtrsCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]*const T {
    if (amount > items.len) return error.InvalidParameter;
    return reservoirSamplePtrsFrom(allocator, source, T, items, amount);
}

pub fn reservoirSamplePtrsFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []const T, amount: usize) ![]*const T {
    const count = @min(amount, items.len);
    const out = try allocator.alloc(*const T, count);
    errdefer allocator.free(out);
    reservoirSamplePtrsFillFrom(source, T, items, out);
    return out;
}

pub fn reservoirSampleMutPtrs(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []T, amount: usize) ![]*T {
    return reservoirSampleMutPtrsFrom(allocator, rng, T, items, amount);
}

pub fn reservoirSampleMutPtrsChecked(allocator: std.mem.Allocator, rng: Rng, comptime T: type, items: []T, amount: usize) ![]*T {
    return reservoirSampleMutPtrsCheckedFrom(allocator, rng, T, items, amount);
}

pub fn reservoirSampleMutPtrsCheckedFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []T, amount: usize) ![]*T {
    if (amount > items.len) return error.InvalidParameter;
    return reservoirSampleMutPtrsFrom(allocator, source, T, items, amount);
}

pub fn reservoirSampleMutPtrsFrom(allocator: std.mem.Allocator, source: anytype, comptime T: type, items: []T, amount: usize) ![]*T {
    const count = @min(amount, items.len);
    const out = try allocator.alloc(*T, count);
    errdefer allocator.free(out);
    reservoirSampleMutPtrsFillFrom(source, T, items, out);
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

pub fn reservoirSamplePtrsInto(rng: Rng, comptime T: type, items: []const T, out: []*const T) Error!void {
    return reservoirSamplePtrsIntoFrom(rng, T, items, out);
}

pub fn reservoirSamplePtrsIntoFrom(source: anytype, comptime T: type, items: []const T, out: []*const T) Error!void {
    if (out.len > items.len) return error.InvalidParameter;
    reservoirSamplePtrsFillFrom(source, T, items, out);
}

pub fn reservoirSampleMutPtrsInto(rng: Rng, comptime T: type, items: []T, out: []*T) Error!void {
    return reservoirSampleMutPtrsIntoFrom(rng, T, items, out);
}

pub fn reservoirSampleMutPtrsIntoFrom(source: anytype, comptime T: type, items: []T, out: []*T) Error!void {
    if (out.len > items.len) return error.InvalidParameter;
    reservoirSampleMutPtrsFillFrom(source, T, items, out);
}

fn reservoirSamplePtrsFillFrom(source: anytype, comptime T: type, items: []const T, out: []*const T) void {
    if (out.len == 0) return;

    for (items[0..out.len], out) |*item, *slot| slot.* = item;
    var i = out.len;
    while (i < items.len) : (i += 1) {
        const j = Rng.uintAtMostFrom(source, usize, i);
        if (j < out.len) out[j] = &items[i];
    }
}

fn reservoirSampleMutPtrsFillFrom(source: anytype, comptime T: type, items: []T, out: []*T) void {
    if (out.len == 0) return;

    for (items[0..out.len], out) |*item, *slot| slot.* = item;
    var i = out.len;
    while (i < items.len) : (i += 1) {
        const j = Rng.uintAtMostFrom(source, usize, i);
        if (j < out.len) out[j] = &items[i];
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

const WeightedU32Candidate = struct {
    index: u32,
    key: f64,
};

fn compareWeightedU32Candidate(_: void, a: WeightedU32Candidate, b: WeightedU32Candidate) std.math.Order {
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

fn singlePositiveWeightIndexU32Alloc(allocator: std.mem.Allocator, comptime Weight: type, weights: []const Weight) ![]u32 {
    const index = (try singlePositiveWeightIndex(Weight, weights)).?;
    const out = try allocator.alloc(u32, 1);
    out[0] = @intCast(index);
    return out;
}

fn singlePositiveWeightIndexVecAlloc(allocator: std.mem.Allocator, comptime Weight: type, weights: []const Weight) !IndexVec {
    const index = (try singlePositiveWeightIndex(Weight, weights)).?;
    if (weights.len <= std.math.maxInt(u32)) {
        const out = try allocator.alloc(u32, 1);
        out[0] = @intCast(index);
        return .{ .u32 = out };
    }
    const out = try allocator.alloc(usize, 1);
    out[0] = index;
    return .{ .usize = out };
}

fn countPositiveIndicesBy(
    comptime Weight: type,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) Error!usize {
    var positive: usize = 0;
    var index: usize = 0;
    while (index < length) : (index += 1) {
        const value = weightAsF64(Weight, weightFn(index));
        if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
        if (value > 0) positive += 1;
    }
    return positive;
}

fn singlePositiveIndexBy(
    comptime Weight: type,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) Error!?usize {
    var positive_index: ?usize = null;
    var positive: usize = 0;
    var index: usize = 0;
    while (index < length) : (index += 1) {
        const value = weightAsF64(Weight, weightFn(index));
        if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
        if (value > 0) {
            positive_index = index;
            positive += 1;
            if (positive > 1) return null;
        }
    }
    return positive_index;
}

fn singlePositiveIndexByAlloc(
    allocator: std.mem.Allocator,
    comptime Weight: type,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) ![]usize {
    const index = (try singlePositiveIndexBy(Weight, length, weightFn)).?;
    const out = try allocator.alloc(usize, 1);
    out[0] = index;
    return out;
}

fn singlePositiveIndexU32ByAlloc(
    allocator: std.mem.Allocator,
    comptime Weight: type,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) ![]u32 {
    const index = (try singlePositiveIndexBy(Weight, length, weightFn)).?;
    const out = try allocator.alloc(u32, 1);
    out[0] = @intCast(index);
    return out;
}

fn singlePositiveIndexVecByAlloc(
    allocator: std.mem.Allocator,
    comptime Weight: type,
    length: usize,
    comptime weightFn: fn (usize) Weight,
) !IndexVec {
    const index = (try singlePositiveIndexBy(Weight, length, weightFn)).?;
    if (length <= std.math.maxInt(u32)) {
        const out = try allocator.alloc(u32, 1);
        out[0] = @intCast(index);
        return .{ .u32 = out };
    }
    const out = try allocator.alloc(usize, 1);
    out[0] = index;
    return .{ .usize = out };
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

fn countPositiveItemsBy(
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error!usize {
    var positive: usize = 0;
    for (items) |*item| {
        const value = weightAsF64(Weight, weightFn(item));
        if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
        if (value > 0) positive += 1;
    }
    return positive;
}

fn singlePositiveItemIndexBy(
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error!?usize {
    var positive_index: ?usize = null;
    var positive: usize = 0;
    for (items, 0..) |*item, index| {
        const value = weightAsF64(Weight, weightFn(item));
        if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
        if (value > 0) {
            positive_index = index;
            positive += 1;
            if (positive > 1) return null;
        }
    }
    return positive_index;
}

fn singlePositiveItemIndexByAlloc(
    allocator: std.mem.Allocator,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) ![]usize {
    const index = (try singlePositiveItemIndexBy(T, Weight, items, weightFn)).?;
    const out = try allocator.alloc(usize, 1);
    out[0] = index;
    return out;
}

fn singlePositiveItemIndexU32ByAlloc(
    allocator: std.mem.Allocator,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) ![]u32 {
    const index = (try singlePositiveItemIndexBy(T, Weight, items, weightFn)).?;
    const out = try allocator.alloc(u32, 1);
    out[0] = @intCast(index);
    return out;
}

fn singlePositiveItemIndexVecByAlloc(
    allocator: std.mem.Allocator,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) !IndexVec {
    const index = (try singlePositiveItemIndexBy(T, Weight, items, weightFn)).?;
    if (items.len <= std.math.maxInt(u32)) {
        const out = try allocator.alloc(u32, 1);
        out[0] = @intCast(index);
        return .{ .u32 = out };
    }
    const out = try allocator.alloc(usize, 1);
    out[0] = index;
    return .{ .usize = out };
}

fn singlePositiveItemByAlloc(
    allocator: std.mem.Allocator,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) ![]T {
    const index = (try singlePositiveItemIndexBy(T, Weight, items, weightFn)).?;
    const out = try allocator.alloc(T, 1);
    out[0] = items[index];
    return out;
}

fn singlePositivePtrByAlloc(
    allocator: std.mem.Allocator,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) ![]*const T {
    const index = (try singlePositiveItemIndexBy(T, Weight, items, weightFn)).?;
    const out = try allocator.alloc(*const T, 1);
    out[0] = &items[index];
    return out;
}

fn singlePositiveMutPtrByAlloc(
    allocator: std.mem.Allocator,
    comptime T: type,
    comptime Weight: type,
    items: []T,
    comptime weightFn: fn (*const T) Weight,
) ![]*T {
    const index = (try singlePositiveItemIndexBy(T, Weight, items, weightFn)).?;
    const out = try allocator.alloc(*T, 1);
    out[0] = &items[index];
    return out;
}

fn weightedSelectionKeyFrom(source: anytype, weight: f64) f64 {
    std.debug.assert(weight > 0 and std.math.isFinite(weight));
    const key = @log(Rng.floatOpenFrom(source, f64)) / weight;
    return if (std.math.isFinite(key)) key else -std.math.floatMax(f64);
}

const WeightedIndexValidation = struct {
    total: f64,
    single_positive: ?usize,
};

fn validateWeightedIndexWeights(comptime Weight: type, weights: []const Weight) Error!WeightedIndexValidation {
    const validation = try validateWeightedIndexWeightsAllowEmpty(Weight, weights);
    if (validation.total == 0) return error.EmptyInput;
    return validation;
}

fn validateWeightedIndexWeightsAllowEmpty(comptime Weight: type, weights: []const Weight) Error!WeightedIndexValidation {
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
    return .{ .total = total, .single_positive = if (positive_count == 1) positive_index else null };
}

fn weightedIndexGenericFrom(source: anytype, comptime Weight: type, weights: []const Weight) Error!?usize {
    const validation = try validateWeightedIndexWeightsAllowEmpty(Weight, weights);
    if (validation.total == 0) return null;
    if (validation.single_positive) |index| return index;
    return weightedIndexGenericFromPrevalidated(source, Weight, weights, validation.total);
}

fn weightedIndexGenericFromPrevalidated(source: anytype, comptime Weight: type, weights: []const Weight, total: f64) usize {
    const point = Rng.floatFrom(source, f64) * total;
    var acc: f64 = 0;
    for (weights, 0..) |weight, index| {
        acc += weightAsF64(Weight, weight);
        if (point < acc) return index;
    }
    return weights.len - 1;
}

fn weightedIndexByFrom(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error!?usize {
    const validation = try validateWeightedIndexByAllowEmpty(T, Weight, items, weightFn);
    if (validation.total == 0) return null;
    if (validation.single_positive) |index| return index;
    return weightedIndexByFromPrevalidated(source, T, Weight, items, weightFn, validation.total);
}

fn validateWeightedIndexByAllowEmpty(
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
) Error!WeightedIndexValidation {
    var total: f64 = 0;
    var positive_index: ?usize = null;
    var positive_count: usize = 0;
    for (items, 0..) |*item, index| {
        const value = weightAsF64(Weight, weightFn(item));
        if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
        total += value;
        if (!std.math.isFinite(total)) return error.InvalidWeight;
        if (value > 0) {
            positive_index = index;
            positive_count += 1;
        }
    }
    return .{ .total = total, .single_positive = if (positive_count == 1) positive_index else null };
}

fn weightedIndexByFromPrevalidated(
    source: anytype,
    comptime T: type,
    comptime Weight: type,
    items: []const T,
    comptime weightFn: fn (*const T) Weight,
    total: f64,
) usize {
    const point = Rng.floatFrom(source, f64) * total;
    var acc: f64 = 0;
    for (items, 0..) |*item, index| {
        acc += weightAsF64(Weight, weightFn(item));
        if (point < acc) return index;
    }
    return items.len - 1;
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
    const direct_fixed_u32 = sampleArrayU32From(&engine, 4, 32).?;
    for (direct_fixed_u32) |index| try std.testing.expect(index < 32);
    const checked_fixed_u32 = try sampleArrayU32CheckedFrom(&engine, 4, 32);
    for (checked_fixed_u32) |index| try std.testing.expect(index < 32);
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
    var copied_u32: [8]u32 = undefined;
    try index_vec.copyIntoU32(&copied_u32);
    try std.testing.expectEqualSlices(u32, &.{ 70, 11, 8, 89, 0, 1, 18, 74 }, &copied_u32);
    var short_copy: [7]usize = undefined;
    try std.testing.expectError(error.LengthMismatch, index_vec.copyInto(&short_copy));
    var short_copy_u32: [7]u32 = undefined;
    try std.testing.expectError(error.LengthMismatch, index_vec.copyIntoU32(&short_copy_u32));
    const owned_copy = try index_vec.toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(owned_copy);
    try std.testing.expectEqualSlices(usize, &expected, owned_copy);
    const owned_copy_u32 = try index_vec.toOwnedU32Slice(std.testing.allocator);
    defer std.testing.allocator.free(owned_copy_u32);
    try std.testing.expectEqualSlices(u32, &.{ 70, 11, 8, 89, 0, 1, 18, 74 }, owned_copy_u32);
    var failing_copy = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, index_vec.toOwnedSlice(failing_copy.allocator()));
    try std.testing.expect(failing_copy.has_induced_failure);
    var failing_copy_u32 = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, index_vec.toOwnedU32Slice(failing_copy_u32.allocator()));
    try std.testing.expect(failing_copy_u32.has_induced_failure);
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
    var copied_u32: [3]u32 = undefined;
    try index_vec.copyIntoU32(&copied_u32);
    try std.testing.expectEqualSlices(u32, &.{ 5, 8, 13 }, &copied_u32);

    const owned = try index_vec.toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(owned);
    try std.testing.expectEqualSlices(usize, &backing, owned);
    const owned_u32 = try index_vec.toOwnedU32Slice(std.testing.allocator);
    defer std.testing.allocator.free(owned_u32);
    try std.testing.expectEqualSlices(u32, &.{ 5, 8, 13 }, owned_u32);

    var too_large_backing = [_]usize{ 1, std.math.maxInt(u32) + 1 };
    const too_large = IndexVec{ .usize = &too_large_backing };
    var too_large_out: [2]u32 = undefined;
    try std.testing.expectError(error.InvalidParameter, too_large.copyIntoU32(&too_large_out));
    try std.testing.expectError(error.InvalidParameter, too_large.toOwnedU32Slice(std.testing.allocator));
}

test "index vec maps sampled indexes to slice items" {
    const labels = [_][]const u8{ "ant", "bee", "cat", "dog", "eel", "fox" };
    var backing = [_]usize{ 4, 1, 5 };
    const index_vec = IndexVec{ .usize = &backing };

    var values = index_vec.values([]const u8, &labels);
    try std.testing.expectEqual(@as(usize, 3), values.remaining());
    try std.testing.expectEqualStrings("eel", values.next().?);
    try std.testing.expectEqualStrings("bee", values.next().?);
    try std.testing.expectEqualStrings("fox", values.next().?);
    try std.testing.expectEqual(@as(?[]const u8, null), values.next());

    var ptrs = try index_vec.ptrsChecked([]const u8, &labels);
    try std.testing.expectEqualStrings("eel", ptrs.next().?.*);
    try std.testing.expectEqualStrings("bee", ptrs.next().?.*);
    try std.testing.expectEqualStrings("fox", ptrs.next().?.*);
    try std.testing.expectEqual(@as(?*const []const u8, null), ptrs.next());

    var compact_backing = [_]u32{ 0, 2, 3 };
    const compact = IndexVec{ .u32 = &compact_backing };
    var compact_values = try compact.valuesChecked([]const u8, &labels);
    try std.testing.expectEqualStrings("ant", compact_values.next().?);
    try std.testing.expectEqualStrings("cat", compact_values.next().?);
    try std.testing.expectEqualStrings("dog", compact_values.next().?);
    var compact_mapped_values: [3][]const u8 = undefined;
    try compact.valuesIntoChecked([]const u8, &labels, &compact_mapped_values);
    try std.testing.expectEqualStrings("ant", compact_mapped_values[0]);
    try std.testing.expectEqualStrings("cat", compact_mapped_values[1]);
    try std.testing.expectEqualStrings("dog", compact_mapped_values[2]);
    var compact_mapped_ptrs: [3]*const []const u8 = undefined;
    try compact.ptrsIntoChecked([]const u8, &labels, &compact_mapped_ptrs);
    try std.testing.expectEqualStrings("ant", compact_mapped_ptrs[0].*);
    try std.testing.expectEqualStrings("cat", compact_mapped_ptrs[1].*);
    try std.testing.expectEqualStrings("dog", compact_mapped_ptrs[2].*);

    var mapped_values: [3][]const u8 = undefined;
    try index_vec.valuesIntoChecked([]const u8, &labels, &mapped_values);
    try std.testing.expectEqualStrings("eel", mapped_values[0]);
    try std.testing.expectEqualStrings("bee", mapped_values[1]);
    try std.testing.expectEqualStrings("fox", mapped_values[2]);
    const owned_values = try index_vec.valuesOwnedChecked(std.testing.allocator, []const u8, &labels);
    defer std.testing.allocator.free(owned_values);
    try std.testing.expectEqualStrings("eel", owned_values[0]);
    try std.testing.expectEqualStrings("bee", owned_values[1]);
    try std.testing.expectEqualStrings("fox", owned_values[2]);
    var failing_values = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, index_vec.valuesOwnedChecked(failing_values.allocator(), []const u8, &labels));
    try std.testing.expect(failing_values.has_induced_failure);
    var short_values: [2][]const u8 = undefined;
    try std.testing.expectError(error.LengthMismatch, index_vec.valuesInto([]const u8, &labels, &short_values));

    var mapped_ptrs: [3]*const []const u8 = undefined;
    try index_vec.ptrsIntoChecked([]const u8, &labels, &mapped_ptrs);
    try std.testing.expectEqualStrings("eel", mapped_ptrs[0].*);
    try std.testing.expectEqualStrings("bee", mapped_ptrs[1].*);
    try std.testing.expectEqualStrings("fox", mapped_ptrs[2].*);
    const owned_ptrs = try index_vec.ptrsOwnedChecked(std.testing.allocator, []const u8, &labels);
    defer std.testing.allocator.free(owned_ptrs);
    try std.testing.expectEqualStrings("eel", owned_ptrs[0].*);
    try std.testing.expectEqualStrings("bee", owned_ptrs[1].*);
    try std.testing.expectEqualStrings("fox", owned_ptrs[2].*);
    var failing_ptrs = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, index_vec.ptrsOwnedChecked(failing_ptrs.allocator(), []const u8, &labels));
    try std.testing.expect(failing_ptrs.has_induced_failure);
    var short_ptrs: [2]*const []const u8 = undefined;
    try std.testing.expectError(error.LengthMismatch, index_vec.ptrsInto([]const u8, &labels, &short_ptrs));

    var numbers = [_]u8{ 10, 20, 30, 40, 50, 60 };
    var mut_ptrs = try index_vec.mutPtrsChecked(u8, &numbers);
    try std.testing.expectEqual(@as(usize, 3), mut_ptrs.remaining());
    mut_ptrs.next().?.* += 1;
    mut_ptrs.next().?.* += 2;
    mut_ptrs.next().?.* += 3;
    try std.testing.expectEqual(@as(?*u8, null), mut_ptrs.next());
    try std.testing.expectEqualSlices(u8, &.{ 10, 22, 30, 40, 51, 63 }, &numbers);

    var compact_mut_ptrs: [3]*u8 = undefined;
    try compact.mutPtrsIntoChecked(u8, &numbers, &compact_mut_ptrs);
    compact_mut_ptrs[0].* += 4;
    compact_mut_ptrs[1].* += 5;
    compact_mut_ptrs[2].* += 6;
    try std.testing.expectEqualSlices(u8, &.{ 14, 22, 35, 46, 51, 63 }, &numbers);

    var short_mut_ptrs: [2]*u8 = undefined;
    try std.testing.expectError(error.LengthMismatch, index_vec.mutPtrsInto(u8, &numbers, &short_mut_ptrs));
    var duplicate_backing = [_]usize{ 1, 1 };
    const duplicate = IndexVec{ .usize = &duplicate_backing };
    try std.testing.expectError(error.InvalidParameter, duplicate.validateDistinctItems(numbers.len));
    try std.testing.expectError(error.InvalidParameter, duplicate.mutPtrsChecked(u8, &numbers));
    try std.testing.expectError(error.InvalidParameter, duplicate.mutPtrsIntoChecked(u8, &numbers, short_mut_ptrs[0..2]));
    try std.testing.expectError(error.InvalidParameter, duplicate.mutPtrsOwnedChecked(std.testing.allocator, u8, &numbers));

    var invalid_backing = [_]usize{ 1, labels.len };
    const invalid = IndexVec{ .usize = &invalid_backing };
    try std.testing.expectError(error.InvalidParameter, invalid.validateItems(labels.len));
    try std.testing.expectError(error.InvalidParameter, invalid.validateDistinctItems(labels.len));
    try std.testing.expectError(error.InvalidParameter, invalid.valuesChecked([]const u8, &labels));
    try std.testing.expectError(error.InvalidParameter, invalid.ptrsChecked([]const u8, &labels));
    try std.testing.expectError(error.InvalidParameter, invalid.valuesIntoChecked([]const u8, &labels, mapped_values[0..2]));
    try std.testing.expectError(error.InvalidParameter, invalid.ptrsIntoChecked([]const u8, &labels, mapped_ptrs[0..2]));
    try std.testing.expectError(error.InvalidParameter, invalid.valuesOwnedChecked(std.testing.allocator, []const u8, &labels));
    try std.testing.expectError(error.InvalidParameter, invalid.ptrsOwnedChecked(std.testing.allocator, []const u8, &labels));
    try std.testing.expectError(error.InvalidParameter, invalid.mutPtrsChecked(u8, &numbers));
    try std.testing.expectError(error.InvalidParameter, invalid.mutPtrsIntoChecked(u8, &numbers, short_mut_ptrs[0..2]));
    try std.testing.expectError(error.InvalidParameter, invalid.mutPtrsOwnedChecked(std.testing.allocator, u8, &numbers));
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

test "sampleArrayU32 returns fixed-size compact index arrays" {
    const alea = @import("root.zig");

    var optional_engine = alea.ScalarPrng.init(0x5150_c001);
    const optional = sampleArrayU32From(&optional_engine, 4, 32).?;
    try std.testing.expectEqual(@as(usize, 4), optional.len);
    for (optional) |index| try std.testing.expect(index < 32);

    var checked_engine = alea.ScalarPrng.init(0x5150_c002);
    const checked = try sampleArrayU32CheckedFrom(&checked_engine, 4, 32);
    try std.testing.expectEqual(@as(usize, 4), checked.len);
    for (checked) |index| try std.testing.expect(index < 32);

    var empty_engine = alea.ScalarPrng.init(0x5150_c003);
    var empty_control = alea.ScalarPrng.init(0x5150_c003);
    const empty = sampleArrayU32From(&empty_engine, 0, 32).?;
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
    try std.testing.expect(sampleArrayU32From(&empty_engine, 4, 3) == null);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "sampleArrayU32 preserves facade/direct stream shape" {
    const alea = @import("root.zig");

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c004);
        var direct_engine = Engine.init(0x5150_c004);
        const rng = Rng.init(&facade_engine);

        const facade = sampleArrayU32(rng, 5, 64).?;
        const direct = sampleArrayU32From(&direct_engine, 5, 64).?;
        try std.testing.expectEqualSlices(u32, &facade, &direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade = try sampleArrayU32Checked(rng, 5, 64);
        const checked_direct = try sampleArrayU32CheckedFrom(&direct_engine, 5, 64);
        try std.testing.expectEqualSlices(u32, &checked_facade, &checked_direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
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

    try std.testing.expectError(error.InvalidParameter, sampleArrayU32Checked(rng, 4, 3));
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

    const index_vec = try sampleWeightedIndexVecFrom(std.testing.allocator, &engine, u32, &weights, 2);
    defer index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 1), index_vec.len());
    try std.testing.expectEqual(@as(usize, 1), index_vec.at(0));
    try std.testing.expectEqual(control.next(), engine.next());

    const indices_u32 = try sampleWeightedIndicesU32From(std.testing.allocator, &engine, u32, &weights, 2);
    defer std.testing.allocator.free(indices_u32);
    try std.testing.expectEqualSlices(u32, &.{1}, indices_u32);
    try std.testing.expectEqual(control.next(), engine.next());

    var u32_out: [3]u32 = undefined;
    var u32_keys: [3]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedIndicesU32IntoFrom(&engine, u32, &weights, &u32_out, &u32_keys));
    try std.testing.expectEqual(@as(u32, 1), u32_out[0]);
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

test "sampleIteratorFill aliases caller-owned iterator reservoirs" {
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
        var facade_engine = Engine.init(0x5150_c911);
        var direct_engine = Engine.init(0x5150_c911);
        const rng = Rng.init(&facade_engine);

        var facade_iter = RangeIter{ .end = 20 };
        var direct_iter = RangeIter{ .end = 20 };
        var facade_out: [5]u8 = undefined;
        var direct_out: [5]u8 = undefined;
        try std.testing.expectEqual(sampleIteratorFill(rng, u8, &facade_iter, &facade_out), sampleIteratorIntoFrom(&direct_engine, u8, &direct_iter, &direct_out));
        try std.testing.expectEqualSlices(u8, &facade_out, &direct_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_facade_iter = RangeIter{ .end = 20 };
        var checked_direct_iter = RangeIter{ .end = 20 };
        var checked_facade_out: [5]u8 = undefined;
        var checked_direct_out: [5]u8 = undefined;
        try sampleIteratorFillChecked(rng, u8, &checked_facade_iter, &checked_facade_out);
        try sampleIteratorIntoCheckedFrom(&direct_engine, u8, &checked_direct_iter, &checked_direct_out);
        try std.testing.expectEqualSlices(u8, &checked_facade_out, &checked_direct_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var short_engine = alea.ScalarPrng.init(0x5150_c912);
    var short_control = alea.ScalarPrng.init(0x5150_c912);
    var short_iter = RangeIter{ .end = 2 };
    var short_out: [5]u8 = undefined;
    try std.testing.expectEqual(@as(usize, 2), sampleIteratorFillFrom(&short_engine, u8, &short_iter, &short_out));
    try std.testing.expectEqual(short_control.next(), short_engine.next());

    var invalid_iter = RangeIter{ .end = 2 };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorFillCheckedFrom(&short_engine, u8, &invalid_iter, &short_out));
    try std.testing.expectEqual(short_control.next(), short_engine.next());
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

    const fixed_u32 = try sampleArrayU32CheckedFrom(&engine, 0, 0);
    try std.testing.expectEqual(@as(usize, 0), fixed_u32.len);
    try std.testing.expectEqual(control.next(), engine.next());

    const fixed_nonempty_range = try sampleArrayCheckedFrom(&engine, 0, 10);
    try std.testing.expectEqual(@as(usize, 0), fixed_nonempty_range.len);
    try std.testing.expectEqual(control.next(), engine.next());

    const fixed_u32_nonempty_range = try sampleArrayU32CheckedFrom(&engine, 0, 10);
    try std.testing.expectEqual(@as(usize, 0), fixed_u32_nonempty_range.len);
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
    const empty_owned_u32 = try index_vec.toOwnedU32Slice(std.testing.allocator);
    defer std.testing.allocator.free(empty_owned_u32);
    try std.testing.expectEqual(@as(usize, 0), empty_owned_u32.len);
    const empty_values = try index_vec.valuesOwnedChecked(std.testing.allocator, u8, &items);
    defer std.testing.allocator.free(empty_values);
    try std.testing.expectEqual(@as(usize, 0), empty_values.len);
    const empty_ptrs = try index_vec.ptrsOwnedChecked(std.testing.allocator, u8, &items);
    defer std.testing.allocator.free(empty_ptrs);
    try std.testing.expectEqual(@as(usize, 0), empty_ptrs.len);
    var mutable_items = items;
    const empty_mut_ptrs = try index_vec.mutPtrsOwnedChecked(std.testing.allocator, u8, &mutable_items);
    defer std.testing.allocator.free(empty_mut_ptrs);
    try std.testing.expectEqual(@as(usize, 0), empty_mut_ptrs.len);
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

test "choose pointer arrays return fixed-size pointer samples" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };

    var optional_engine = alea.ScalarPrng.init(0x5150_a101);
    const optional = choosePtrArrayFrom(&optional_engine, u8, 3, &items).?;
    try std.testing.expectEqual(@as(usize, 3), optional.len);
    for (optional) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
        try std.testing.expect(index < items.len);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var checked_engine = alea.ScalarPrng.init(0x5150_a102);
    const checked = try choosePtrArrayCheckedFrom(&checked_engine, u8, 4, &items);
    try std.testing.expectEqual(@as(usize, 4), checked.len);
    for (checked) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
        try std.testing.expect(index < items.len);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var mutable = items;
    var mut_engine = alea.ScalarPrng.init(0x5150_a103);
    const mut_ptrs = try chooseMutPtrArrayCheckedFrom(&mut_engine, u8, 4, &mutable);
    try std.testing.expectEqual(@as(usize, 4), mut_ptrs.len);
    var expected = items;
    for (mut_ptrs) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&mutable[0]), @sizeOf(u8));
        try std.testing.expect(index < mutable.len);
        try std.testing.expectEqual(&mutable[index], ptr);
        ptr.* += 1;
        expected[index] += 1;
    }
    try std.testing.expectEqualSlices(u8, &expected, &mutable);

    var facade_engine = alea.ScalarPrng.init(0x5150_a104);
    const rng = Rng.init(&facade_engine);
    const facade = choosePtrArray(rng, u8, 2, &items).?;
    try std.testing.expectEqual(@as(usize, 2), facade.len);

    const empty = choosePtrArrayFrom(&facade_engine, u8, 0, &items).?;
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(choosePtrArrayFrom(&facade_engine, u8, 9, &items) == null);
    try std.testing.expectError(error.InvalidParameter, choosePtrArrayCheckedFrom(&facade_engine, u8, 9, &items));
    try std.testing.expect(chooseMutPtrArrayFrom(&facade_engine, u8, 9, &mutable) == null);
    try std.testing.expectError(error.InvalidParameter, chooseMutPtrArrayCheckedFrom(&facade_engine, u8, 9, &mutable));
}

test "fixed-size slice sample aliases mirror chooseArray workflows" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_a105);
        var direct_engine = Engine.init(0x5150_a105);
        const rng = Rng.init(&facade_engine);

        const facade = sampleItemsArray(rng, u8, 3, &items).?;
        const direct = chooseArrayFrom(&direct_engine, u8, 3, &items).?;
        try std.testing.expectEqualSlices(u8, &direct, &facade);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_ptrs = samplePtrArray(rng, u8, 3, &items).?;
        const direct_ptrs = choosePtrArrayFrom(&direct_engine, u8, 3, &items).?;
        for (facade_ptrs, direct_ptrs) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            try std.testing.expectEqual(direct_index, facade_index);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_items = items;
        var direct_items = items;
        const facade_mut_ptrs = sampleMutPtrArray(rng, u8, 3, &facade_items).?;
        const direct_mut_ptrs = chooseMutPtrArrayFrom(&direct_engine, u8, 3, &direct_items).?;
        for (facade_mut_ptrs, direct_mut_ptrs) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&facade_items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&direct_items[0]), @sizeOf(u8));
            try std.testing.expectEqual(direct_index, facade_index);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var checked_engine = alea.ScalarPrng.init(0x5150_a106);
    const checked = try sampleItemsArrayCheckedFrom(&checked_engine, u8, 4, &items);
    try std.testing.expectEqual(@as(usize, 4), checked.len);
    const checked_ptrs = try samplePtrArrayCheckedFrom(&checked_engine, u8, 4, &items);
    try std.testing.expectEqual(@as(usize, 4), checked_ptrs.len);
    var mutable = items;
    const checked_mut_ptrs = try sampleMutPtrArrayCheckedFrom(&checked_engine, u8, 4, &mutable);
    try std.testing.expectEqual(@as(usize, 4), checked_mut_ptrs.len);

    var invalid_engine = alea.ScalarPrng.init(0x5150_a107);
    var invalid_control = alea.ScalarPrng.init(0x5150_a107);
    try std.testing.expect(sampleItemsArrayFrom(&invalid_engine, u8, 9, &items) == null);
    try std.testing.expect(samplePtrArrayFrom(&invalid_engine, u8, 9, &items) == null);
    try std.testing.expect(sampleMutPtrArrayFrom(&invalid_engine, u8, 9, &mutable) == null);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleItemsArrayCheckedFrom(&invalid_engine, u8, 9, &items));
    try std.testing.expectError(error.InvalidParameter, samplePtrArrayCheckedFrom(&invalid_engine, u8, 9, &items));
    try std.testing.expectError(error.InvalidParameter, sampleMutPtrArrayCheckedFrom(&invalid_engine, u8, 9, &mutable));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    const empty = sampleItemsArrayFrom(&invalid_engine, u8, 0, &items).?;
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "reservoir pointer slices allocate reservoir pointer samples" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };

    var optional_engine = alea.ScalarPrng.init(0x5150_d101);
    const optional = try reservoirSamplePtrsFrom(std.testing.allocator, &optional_engine, u8, &items, 10);
    defer std.testing.allocator.free(optional);
    try std.testing.expectEqual(@as(usize, items.len), optional.len);
    for (optional) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
        try std.testing.expect(index < items.len);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var checked_engine = alea.ScalarPrng.init(0x5150_d102);
    const checked = try reservoirSamplePtrsCheckedFrom(std.testing.allocator, &checked_engine, u8, &items, 4);
    defer std.testing.allocator.free(checked);
    try std.testing.expectEqual(@as(usize, 4), checked.len);
    for (checked) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
        try std.testing.expect(index < items.len);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var mutable = items;
    var mut_engine = alea.ScalarPrng.init(0x5150_d103);
    const mut_ptrs = try reservoirSampleMutPtrsCheckedFrom(std.testing.allocator, &mut_engine, u8, &mutable, 4);
    defer std.testing.allocator.free(mut_ptrs);
    var expected = items;
    for (mut_ptrs) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&mutable[0]), @sizeOf(u8));
        try std.testing.expect(index < mutable.len);
        try std.testing.expectEqual(&mutable[index], ptr);
        ptr.* += 1;
        expected[index] += 1;
    }
    try std.testing.expectEqualSlices(u8, &expected, &mutable);

    var empty_engine = alea.ScalarPrng.init(0x5150_d104);
    var empty_control = alea.ScalarPrng.init(0x5150_d104);
    const empty = try reservoirSamplePtrsFrom(std.testing.allocator, &empty_engine, u8, &items, 0);
    defer std.testing.allocator.free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "reservoir pointer slices preserve stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_d105);
        var direct_engine = Engine.init(0x5150_d105);
        const rng = Rng.init(&facade_engine);

        const facade = try reservoirSamplePtrs(std.testing.allocator, rng, u8, &items, 4);
        defer std.testing.allocator.free(facade);
        const direct = try reservoirSamplePtrsFrom(std.testing.allocator, &direct_engine, u8, &items, 4);
        defer std.testing.allocator.free(direct);
        for (facade, direct) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            try std.testing.expectEqual(facade_index, direct_index);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_items = items;
        var direct_items = items;
        const facade_mut = try reservoirSampleMutPtrs(std.testing.allocator, rng, u8, &facade_items, 4);
        defer std.testing.allocator.free(facade_mut);
        const direct_mut = try reservoirSampleMutPtrsFrom(std.testing.allocator, &direct_engine, u8, &direct_items, 4);
        defer std.testing.allocator.free(direct_mut);
        for (facade_mut, direct_mut) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&facade_items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&direct_items[0]), @sizeOf(u8));
            try std.testing.expectEqual(facade_index, direct_index);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_d106);
    var invalid_control = alea.ScalarPrng.init(0x5150_d106);
    try std.testing.expectError(error.InvalidParameter, reservoirSamplePtrsCheckedFrom(std.testing.allocator, &invalid_engine, u8, &items, 9));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var mutable_items = items;
    try std.testing.expectError(error.InvalidParameter, reservoirSampleMutPtrsCheckedFrom(std.testing.allocator, &invalid_engine, u8, &mutable_items, 9));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, reservoirSamplePtrsFrom(failing.allocator(), &invalid_engine, u8, &items, 4));
    try std.testing.expect(failing.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "reservoir pointer buffers fill caller-owned reservoir pointer outputs" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };

    var ptr_engine = alea.ScalarPrng.init(0x5150_d201);
    var ptrs: [4]*const u8 = undefined;
    try reservoirSamplePtrsIntoFrom(&ptr_engine, u8, &items, &ptrs);
    for (ptrs) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
        try std.testing.expect(index < items.len);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var mutable = items;
    var mut_engine = alea.ScalarPrng.init(0x5150_d202);
    var mut_ptrs: [4]*u8 = undefined;
    try reservoirSampleMutPtrsIntoFrom(&mut_engine, u8, &mutable, &mut_ptrs);
    var expected = items;
    for (mut_ptrs) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&mutable[0]), @sizeOf(u8));
        try std.testing.expect(index < mutable.len);
        try std.testing.expectEqual(&mutable[index], ptr);
        ptr.* += 1;
        expected[index] += 1;
    }
    try std.testing.expectEqualSlices(u8, &expected, &mutable);

    var empty_engine = alea.ScalarPrng.init(0x5150_d203);
    var empty_control = alea.ScalarPrng.init(0x5150_d203);
    var empty_ptrs: [0]*const u8 = .{};
    try reservoirSamplePtrsIntoFrom(&empty_engine, u8, &items, &empty_ptrs);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "reservoir pointer buffers preserve stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50, 60, 70, 80 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_d204);
        var direct_engine = Engine.init(0x5150_d204);
        const rng = Rng.init(&facade_engine);

        var facade_ptrs: [4]*const u8 = undefined;
        var direct_ptrs: [4]*const u8 = undefined;
        try reservoirSamplePtrsInto(rng, u8, &items, &facade_ptrs);
        try reservoirSamplePtrsIntoFrom(&direct_engine, u8, &items, &direct_ptrs);
        for (facade_ptrs, direct_ptrs) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            try std.testing.expectEqual(facade_index, direct_index);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_items = items;
        var direct_items = items;
        var facade_mut_ptrs: [4]*u8 = undefined;
        var direct_mut_ptrs: [4]*u8 = undefined;
        try reservoirSampleMutPtrsInto(rng, u8, &facade_items, &facade_mut_ptrs);
        try reservoirSampleMutPtrsIntoFrom(&direct_engine, u8, &direct_items, &direct_mut_ptrs);
        for (facade_mut_ptrs, direct_mut_ptrs) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&facade_items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&direct_items[0]), @sizeOf(u8));
            try std.testing.expectEqual(facade_index, direct_index);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_d205);
    var invalid_control = alea.ScalarPrng.init(0x5150_d205);
    var too_many: [9]*const u8 = undefined;
    try std.testing.expectError(error.InvalidParameter, reservoirSamplePtrsIntoFrom(&invalid_engine, u8, &items, &too_many));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var mutable_items = items;
    var too_many_mut: [9]*u8 = undefined;
    try std.testing.expectError(error.InvalidParameter, reservoirSampleMutPtrsIntoFrom(&invalid_engine, u8, &mutable_items, &too_many_mut));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "chooseMultiple pointer slices allocate pointer subsets" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    var optional_engine = alea.ScalarPrng.init(0x5150_c301);
    const optional = try chooseMultiplePtrsFrom(std.testing.allocator, &optional_engine, u8, &items, 8);
    defer std.testing.allocator.free(optional);
    try std.testing.expectEqual(@as(usize, items.len), optional.len);
    for (optional) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
        try std.testing.expect(index < items.len);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var checked_engine = alea.ScalarPrng.init(0x5150_c302);
    const checked = try chooseMultiplePtrsCheckedFrom(std.testing.allocator, &checked_engine, u8, &items, 3);
    defer std.testing.allocator.free(checked);
    try std.testing.expectEqual(@as(usize, 3), checked.len);
    for (checked) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
        try std.testing.expect(index < items.len);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var mutable = items;
    var mut_engine = alea.ScalarPrng.init(0x5150_c303);
    const mut_ptrs = try chooseMultipleMutPtrsCheckedFrom(std.testing.allocator, &mut_engine, u8, &mutable, 3);
    defer std.testing.allocator.free(mut_ptrs);
    var expected = items;
    for (mut_ptrs) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&mutable[0]), @sizeOf(u8));
        try std.testing.expect(index < mutable.len);
        try std.testing.expectEqual(&mutable[index], ptr);
        ptr.* += 1;
        expected[index] += 1;
    }
    try std.testing.expectEqualSlices(u8, &expected, &mutable);

    var empty_engine = alea.ScalarPrng.init(0x5150_c304);
    var empty_control = alea.ScalarPrng.init(0x5150_c304);
    const empty = try chooseMultiplePtrsFrom(std.testing.allocator, &empty_engine, u8, &items, 0);
    defer std.testing.allocator.free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "chooseMultiple pointer slices preserve stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c305);
        var direct_engine = Engine.init(0x5150_c305);
        const rng = Rng.init(&facade_engine);

        const facade = try chooseMultiplePtrs(std.testing.allocator, rng, u8, &items, 3);
        defer std.testing.allocator.free(facade);
        const direct = try chooseMultiplePtrsFrom(std.testing.allocator, &direct_engine, u8, &items, 3);
        defer std.testing.allocator.free(direct);
        for (facade, direct) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            try std.testing.expectEqual(facade_index, direct_index);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_items = items;
        var direct_items = items;
        const facade_mut = try chooseMultipleMutPtrs(std.testing.allocator, rng, u8, &facade_items, 3);
        defer std.testing.allocator.free(facade_mut);
        const direct_mut = try chooseMultipleMutPtrsFrom(std.testing.allocator, &direct_engine, u8, &direct_items, 3);
        defer std.testing.allocator.free(direct_mut);
        for (facade_mut, direct_mut) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&facade_items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&direct_items[0]), @sizeOf(u8));
            try std.testing.expectEqual(facade_index, direct_index);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_c306);
    var invalid_control = alea.ScalarPrng.init(0x5150_c306);
    try std.testing.expectError(error.InvalidParameter, chooseMultiplePtrsCheckedFrom(std.testing.allocator, &invalid_engine, u8, &items, 6));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var mutable_items = items;
    try std.testing.expectError(error.InvalidParameter, chooseMultipleMutPtrsCheckedFrom(std.testing.allocator, &invalid_engine, u8, &mutable_items, 6));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var out_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, chooseMultiplePtrsFrom(out_alloc.allocator(), &invalid_engine, u8, &items, 3));
    try std.testing.expect(out_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var index_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, chooseMultiplePtrsFrom(index_alloc.allocator(), &invalid_engine, u8, &items, 3));
    try std.testing.expect(index_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "slice sampleItems aliases mirror allocation-returning chooseMultiple workflows" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c307);
        var direct_engine = Engine.init(0x5150_c307);
        const rng = Rng.init(&facade_engine);

        const facade = try sampleItems(std.testing.allocator, rng, u8, &items, 3);
        defer std.testing.allocator.free(facade);
        const direct = try chooseMultipleFrom(std.testing.allocator, &direct_engine, u8, &items, 3);
        defer std.testing.allocator.free(direct);
        try std.testing.expectEqualSlices(u8, direct, facade);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var ptr_facade_engine = Engine.init(0x5150_c308);
        var ptr_direct_engine = Engine.init(0x5150_c308);
        const ptr_rng = Rng.init(&ptr_facade_engine);
        const ptr_facade = try samplePtrs(std.testing.allocator, ptr_rng, u8, &items, 3);
        defer std.testing.allocator.free(ptr_facade);
        const ptr_direct = try chooseMultiplePtrsFrom(std.testing.allocator, &ptr_direct_engine, u8, &items, 3);
        defer std.testing.allocator.free(ptr_direct);
        for (ptr_facade, ptr_direct) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            try std.testing.expectEqual(direct_index, facade_index);
        }
        try std.testing.expectEqual(ptr_facade_engine.next(), ptr_direct_engine.next());

        var mut_facade_engine = Engine.init(0x5150_c309);
        var mut_direct_engine = Engine.init(0x5150_c309);
        const mut_rng = Rng.init(&mut_facade_engine);
        var facade_items = items;
        var direct_items = items;
        const mut_facade = try sampleMutPtrs(std.testing.allocator, mut_rng, u8, &facade_items, 3);
        defer std.testing.allocator.free(mut_facade);
        const mut_direct = try chooseMultipleMutPtrsFrom(std.testing.allocator, &mut_direct_engine, u8, &direct_items, 3);
        defer std.testing.allocator.free(mut_direct);
        for (mut_facade, mut_direct) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&facade_items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&direct_items[0]), @sizeOf(u8));
            try std.testing.expectEqual(direct_index, facade_index);
        }
        try std.testing.expectEqual(mut_facade_engine.next(), mut_direct_engine.next());
    }

    var checked_engine = alea.ScalarPrng.init(0x5150_c30a);
    const checked = try sampleItemsCheckedFrom(std.testing.allocator, &checked_engine, u8, &items, 3);
    defer std.testing.allocator.free(checked);
    try std.testing.expectEqual(@as(usize, 3), checked.len);

    var invalid_engine = alea.ScalarPrng.init(0x5150_c30b);
    var invalid_control = alea.ScalarPrng.init(0x5150_c30b);
    try std.testing.expectError(error.InvalidParameter, sampleItemsCheckedFrom(std.testing.allocator, &invalid_engine, u8, &items, 6));
    try std.testing.expectError(error.InvalidParameter, samplePtrsCheckedFrom(std.testing.allocator, &invalid_engine, u8, &items, 6));
    var mutable = items;
    try std.testing.expectError(error.InvalidParameter, sampleMutPtrsCheckedFrom(std.testing.allocator, &invalid_engine, u8, &mutable, 6));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_c30c);
    var empty_control = alea.ScalarPrng.init(0x5150_c30c);
    const empty = try sampleItemsFrom(std.testing.allocator, &empty_engine, u8, &items, 0);
    defer std.testing.allocator.free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
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

test "slice sampleItemsInto aliases mirror caller-owned chooseMultiple workflows" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c10a);
        var direct_engine = Engine.init(0x5150_c10a);
        const rng = Rng.init(&facade_engine);

        var facade_out: [3]u8 = undefined;
        var direct_out: [3]u8 = undefined;
        var facade_indices: [3]usize = undefined;
        var direct_indices: [3]usize = undefined;
        try std.testing.expectEqual(
            try sampleItemsInto(rng, u8, &items, &facade_out, &facade_indices),
            try chooseMultipleIntoFrom(&direct_engine, u8, &items, &direct_out, &direct_indices),
        );
        try std.testing.expectEqualSlices(u8, &direct_out, &facade_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var ptr_facade_engine = Engine.init(0x5150_c10b);
        var ptr_direct_engine = Engine.init(0x5150_c10b);
        const ptr_rng = Rng.init(&ptr_facade_engine);
        var facade_ptrs: [3]*const u8 = undefined;
        var direct_ptrs: [3]*const u8 = undefined;
        var facade_ptr_indices: [3]usize = undefined;
        var direct_ptr_indices: [3]usize = undefined;
        try std.testing.expectEqual(
            try samplePtrsInto(ptr_rng, u8, &items, &facade_ptrs, &facade_ptr_indices),
            try chooseMultiplePtrsIntoFrom(&ptr_direct_engine, u8, &items, &direct_ptrs, &direct_ptr_indices),
        );
        for (facade_ptrs, direct_ptrs) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            try std.testing.expectEqual(direct_index, facade_index);
        }
        try std.testing.expectEqual(ptr_facade_engine.next(), ptr_direct_engine.next());

        var mut_facade_engine = Engine.init(0x5150_c10c);
        var mut_direct_engine = Engine.init(0x5150_c10c);
        const mut_rng = Rng.init(&mut_facade_engine);
        var facade_items = items;
        var direct_items = items;
        var facade_mut_ptrs: [3]*u8 = undefined;
        var direct_mut_ptrs: [3]*u8 = undefined;
        var facade_mut_indices: [3]usize = undefined;
        var direct_mut_indices: [3]usize = undefined;
        try std.testing.expectEqual(
            try sampleMutPtrsInto(mut_rng, u8, &facade_items, &facade_mut_ptrs, &facade_mut_indices),
            try chooseMultipleMutPtrsIntoFrom(&mut_direct_engine, u8, &direct_items, &direct_mut_ptrs, &direct_mut_indices),
        );
        for (facade_mut_ptrs, direct_mut_ptrs) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&facade_items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&direct_items[0]), @sizeOf(u8));
            try std.testing.expectEqual(direct_index, facade_index);
        }
        try std.testing.expectEqual(mut_facade_engine.next(), mut_direct_engine.next());
    }

    var checked_engine = alea.ScalarPrng.init(0x5150_c10d);
    var checked_out: [3]u8 = undefined;
    var checked_indices: [3]usize = undefined;
    try sampleItemsIntoCheckedFrom(&checked_engine, u8, &items, &checked_out, &checked_indices);

    var invalid_engine = alea.ScalarPrng.init(0x5150_c10e);
    var invalid_control = alea.ScalarPrng.init(0x5150_c10e);
    var out: [3]u8 = undefined;
    var short_indices: [2]usize = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleItemsIntoFrom(&invalid_engine, u8, &items, &out, &short_indices));
    var too_many: [6]u8 = undefined;
    var enough_indices: [6]usize = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleItemsIntoCheckedFrom(&invalid_engine, u8, &items, &too_many, &enough_indices));
    var ptrs: [6]*const u8 = undefined;
    try std.testing.expectError(error.InvalidParameter, samplePtrsIntoCheckedFrom(&invalid_engine, u8, &items, &ptrs, &enough_indices));
    var mutable = items;
    var mut_ptrs: [6]*u8 = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleMutPtrsIntoCheckedFrom(&invalid_engine, u8, &mutable, &mut_ptrs, &enough_indices));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_c10f);
    var empty_control = alea.ScalarPrng.init(0x5150_c10f);
    var empty_out: [0]u8 = .{};
    var empty_indices: [0]usize = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleItemsIntoFrom(&empty_engine, u8, &items, &empty_out, &empty_indices));
    try sampleItemsIntoCheckedFrom(&empty_engine, u8, &items, &empty_out, &empty_indices);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "chooseMultiple pointer buffers fill caller-owned pointer outputs" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    var optional_engine = alea.ScalarPrng.init(0x5150_c201);
    var optional_ptrs: [8]*const u8 = undefined;
    var optional_indices: [8]usize = undefined;
    const filled = try chooseMultiplePtrsIntoFrom(&optional_engine, u8, &items, &optional_ptrs, &optional_indices);
    try std.testing.expectEqual(@as(usize, items.len), filled);
    for (optional_indices[0..filled], optional_ptrs[0..filled]) |index, ptr| {
        try std.testing.expectEqual(&items[index], ptr);
    }

    var checked_engine = alea.ScalarPrng.init(0x5150_c202);
    var checked_ptrs: [3]*const u8 = undefined;
    var checked_indices: [3]usize = undefined;
    try chooseMultiplePtrsIntoCheckedFrom(&checked_engine, u8, &items, &checked_ptrs, &checked_indices);
    for (checked_indices[0..], checked_ptrs[0..]) |index, ptr| {
        try std.testing.expectEqual(&items[index], ptr);
    }

    var mutable = items;
    var mut_engine = alea.ScalarPrng.init(0x5150_c203);
    var mut_ptrs: [3]*u8 = undefined;
    var mut_indices: [3]usize = undefined;
    try chooseMultipleMutPtrsIntoCheckedFrom(&mut_engine, u8, &mutable, &mut_ptrs, &mut_indices);
    var expected = items;
    for (mut_indices[0..], mut_ptrs[0..]) |index, ptr| {
        try std.testing.expectEqual(&mutable[index], ptr);
        ptr.* += 1;
        expected[index] += 1;
    }
    try std.testing.expectEqualSlices(u8, &expected, &mutable);

    var empty_engine = alea.ScalarPrng.init(0x5150_c204);
    var empty_control = alea.ScalarPrng.init(0x5150_c204);
    var empty_ptrs: [0]*const u8 = .{};
    var empty_indices: [0]usize = .{};
    try std.testing.expectEqual(@as(usize, 0), try chooseMultiplePtrsIntoFrom(&empty_engine, u8, &items, &empty_ptrs, &empty_indices));
    try chooseMultiplePtrsIntoCheckedFrom(&empty_engine, u8, &items, &empty_ptrs, &empty_indices);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "chooseMultiple pointer buffers preserve stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c205);
        var direct_engine = Engine.init(0x5150_c205);
        const rng = Rng.init(&facade_engine);

        var facade_ptrs: [3]*const u8 = undefined;
        var direct_ptrs: [3]*const u8 = undefined;
        var facade_indices: [3]usize = undefined;
        var direct_indices: [3]usize = undefined;
        try std.testing.expectEqual(try chooseMultiplePtrsInto(rng, u8, &items, &facade_ptrs, &facade_indices), try chooseMultiplePtrsIntoFrom(&direct_engine, u8, &items, &direct_ptrs, &direct_indices));
        try std.testing.expectEqualSlices(usize, &facade_indices, &direct_indices);
        for (facade_indices[0..], facade_ptrs[0..], direct_ptrs[0..]) |index, facade_ptr, direct_ptr| {
            try std.testing.expectEqual(&items[index], facade_ptr);
            try std.testing.expectEqual(&items[index], direct_ptr);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_items = items;
        var direct_items = items;
        var facade_mut_ptrs: [3]*u8 = undefined;
        var direct_mut_ptrs: [3]*u8 = undefined;
        try std.testing.expectEqual(try chooseMultipleMutPtrsInto(rng, u8, &facade_items, &facade_mut_ptrs, &facade_indices), try chooseMultipleMutPtrsIntoFrom(&direct_engine, u8, &direct_items, &direct_mut_ptrs, &direct_indices));
        try std.testing.expectEqualSlices(usize, &facade_indices, &direct_indices);
        for (facade_indices[0..], facade_mut_ptrs[0..], direct_mut_ptrs[0..]) |index, facade_ptr, direct_ptr| {
            try std.testing.expectEqual(&facade_items[index], facade_ptr);
            try std.testing.expectEqual(&direct_items[index], direct_ptr);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_c206);
    var invalid_control = alea.ScalarPrng.init(0x5150_c206);
    var ptrs: [3]*const u8 = undefined;
    var short_indices: [2]usize = undefined;
    try std.testing.expectError(error.LengthMismatch, chooseMultiplePtrsIntoFrom(&invalid_engine, u8, &items, &ptrs, &short_indices));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var too_many_ptrs: [6]*const u8 = undefined;
    var enough_indices: [6]usize = undefined;
    try std.testing.expectError(error.InvalidParameter, chooseMultiplePtrsIntoCheckedFrom(&invalid_engine, u8, &items, &too_many_ptrs, &enough_indices));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var mutable_items = items;
    var mut_ptrs: [3]*u8 = undefined;
    try std.testing.expectError(error.LengthMismatch, chooseMultipleMutPtrsIntoFrom(&invalid_engine, u8, &mutable_items, &mut_ptrs, &short_indices));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var too_many_mut_ptrs: [6]*u8 = undefined;
    try std.testing.expectError(error.InvalidParameter, chooseMultipleMutPtrsIntoCheckedFrom(&invalid_engine, u8, &mutable_items, &too_many_mut_ptrs, &enough_indices));
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

    try std.testing.expectError(error.InvalidParameter, choosePtrArrayChecked(rng, u8, 4, &.{ 1, 2, 3 }));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, choosePtrArrayCheckedFrom(&engine, u8, 4, &.{ 1, 2, 3 }));
    try std.testing.expectEqual(control.next(), engine.next());

    var mutable = [_]u8{ 1, 2, 3 };
    try std.testing.expectError(error.InvalidParameter, chooseMutPtrArrayChecked(rng, u8, 4, &mutable));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, chooseMutPtrArrayCheckedFrom(&engine, u8, 4, &mutable));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "generic weightedIndex selects indexes" {
    const alea = @import("root.zig");
    const weights = [_]u32{ 0, 2, 6, 3 };

    var index_engine = alea.ScalarPrng.init(0x5150_c701);
    const index = weightedIndexFrom(&index_engine, u32, &weights).?;
    try std.testing.expect(index == 1 or index == 2 or index == 3);

    var checked_engine = alea.ScalarPrng.init(0x5150_c702);
    const checked = (try weightedIndexCheckedFrom(&checked_engine, u32, &weights)).?;
    try std.testing.expect(checked == 1 or checked == 2 or checked == 3);

    var u32_engine = alea.ScalarPrng.init(0x5150_c707);
    const index_u32 = (try weightedIndexU32From(&u32_engine, u32, &weights)).?;
    try std.testing.expect(index_u32 == 1 or index_u32 == 2 or index_u32 == 3);

    var checked_u32_engine = alea.ScalarPrng.init(0x5150_c708);
    const checked_u32 = (try weightedIndexU32CheckedFrom(&checked_u32_engine, u32, &weights)).?;
    try std.testing.expect(checked_u32 == 1 or checked_u32 == 2 or checked_u32 == 3);

    var fill_engine = alea.ScalarPrng.init(0x5150_c70a);
    var filled: [8]?usize = undefined;
    try fillWeightedIndexFrom(&fill_engine, u32, &filled, &weights);
    for (filled) |sample_index| try std.testing.expect(sample_index.? == 1 or sample_index.? == 2 or sample_index.? == 3);

    var fill_checked_engine = alea.ScalarPrng.init(0x5150_c70b);
    var filled_checked: [8]usize = undefined;
    try fillWeightedIndexCheckedFrom(&fill_checked_engine, u32, &filled_checked, &weights);
    for (filled_checked) |sample_index| try std.testing.expect(sample_index == 1 or sample_index == 2 or sample_index == 3);

    var fill_u32_engine = alea.ScalarPrng.init(0x5150_c70c);
    var filled_u32: [8]?u32 = undefined;
    try fillWeightedIndexU32From(&fill_u32_engine, u32, &filled_u32, &weights);
    for (filled_u32) |sample_index| try std.testing.expect(sample_index.? == 1 or sample_index.? == 2 or sample_index.? == 3);

    var fill_u32_checked_engine = alea.ScalarPrng.init(0x5150_c70d);
    var filled_u32_checked: [8]u32 = undefined;
    try fillWeightedIndexU32CheckedFrom(&fill_u32_checked_engine, u32, &filled_u32_checked, &weights);
    for (filled_u32_checked) |sample_index| try std.testing.expect(sample_index == 1 or sample_index == 2 or sample_index == 3);

    var batch_engine = alea.ScalarPrng.init(0x5150_c70e);
    const batch = try weightedIndexBatchFrom(std.testing.allocator, &batch_engine, u32, 8, &weights);
    defer std.testing.allocator.free(batch);
    for (batch) |sample_index| try std.testing.expect(sample_index.? == 1 or sample_index.? == 2 or sample_index.? == 3);

    var batch_checked_engine = alea.ScalarPrng.init(0x5150_c70f);
    const batch_checked = try weightedIndexBatchCheckedFrom(std.testing.allocator, &batch_checked_engine, u32, 8, &weights);
    defer std.testing.allocator.free(batch_checked);
    for (batch_checked) |sample_index| try std.testing.expect(sample_index == 1 or sample_index == 2 or sample_index == 3);

    var batch_u32_engine = alea.ScalarPrng.init(0x5150_c710);
    const batch_u32 = try weightedIndexU32BatchFrom(std.testing.allocator, &batch_u32_engine, u32, 8, &weights);
    defer std.testing.allocator.free(batch_u32);
    for (batch_u32) |sample_index| try std.testing.expect(sample_index.? == 1 or sample_index.? == 2 or sample_index.? == 3);

    var batch_u32_checked_engine = alea.ScalarPrng.init(0x5150_c711);
    const batch_u32_checked = try weightedIndexU32BatchCheckedFrom(std.testing.allocator, &batch_u32_checked_engine, u32, 8, &weights);
    defer std.testing.allocator.free(batch_u32_checked);
    for (batch_u32_checked) |sample_index| try std.testing.expect(sample_index == 1 or sample_index == 2 or sample_index == 3);

    var single_engine = alea.ScalarPrng.init(0x5150_c703);
    var single_control = alea.ScalarPrng.init(0x5150_c703);
    try std.testing.expectEqual(@as(?usize, 2), weightedIndexFrom(&single_engine, u32, &.{ 0, 0, 5, 0 }));
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var single_u32_engine = alea.ScalarPrng.init(0x5150_c709);
    var single_u32_control = alea.ScalarPrng.init(0x5150_c709);
    try std.testing.expectEqual(@as(?u32, 2), try weightedIndexU32From(&single_u32_engine, u32, &.{ 0, 0, 5, 0 }));
    try std.testing.expectEqual(single_u32_control.next(), single_u32_engine.next());

    var single_fill: [5]usize = undefined;
    try fillWeightedIndexCheckedFrom(&single_engine, u32, &single_fill, &.{ 0, 0, 5, 0 });
    for (single_fill) |sample_index| try std.testing.expectEqual(@as(usize, 2), sample_index);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var single_fill_u32: [5]u32 = undefined;
    try fillWeightedIndexU32CheckedFrom(&single_u32_engine, u32, &single_fill_u32, &.{ 0, 0, 5, 0 });
    for (single_fill_u32) |sample_index| try std.testing.expectEqual(@as(u32, 2), sample_index);
    try std.testing.expectEqual(single_u32_control.next(), single_u32_engine.next());

    const single_batch = try weightedIndexBatchCheckedFrom(std.testing.allocator, &single_engine, u32, 5, &.{ 0, 0, 5, 0 });
    defer std.testing.allocator.free(single_batch);
    for (single_batch) |sample_index| try std.testing.expectEqual(@as(usize, 2), sample_index);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    const single_batch_u32 = try weightedIndexU32BatchCheckedFrom(std.testing.allocator, &single_u32_engine, u32, 5, &.{ 0, 0, 5, 0 });
    defer std.testing.allocator.free(single_batch_u32);
    for (single_batch_u32) |sample_index| try std.testing.expectEqual(@as(u32, 2), sample_index);
    try std.testing.expectEqual(single_u32_control.next(), single_u32_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_c704);
    try std.testing.expectEqual(@as(?usize, null), weightedIndexFrom(&empty_engine, u32, &.{}));
    try std.testing.expectEqual(@as(?usize, null), weightedIndexFrom(&empty_engine, u32, &.{ 0, 0, 0, 0 }));
    try std.testing.expectEqual(@as(?usize, null), try weightedIndexCheckedFrom(&empty_engine, u32, &.{ 0, 0, 0, 0 }));
    try std.testing.expectEqual(@as(?u32, null), try weightedIndexU32From(&empty_engine, u32, &.{}));
    try std.testing.expectEqual(@as(?u32, null), try weightedIndexU32CheckedFrom(&empty_engine, u32, &.{ 0, 0, 0, 0 }));

    var empty_out: [4]?usize = undefined;
    try fillWeightedIndexFrom(&empty_engine, u32, &empty_out, &.{ 0, 0, 0, 0 });
    for (empty_out) |sample_index| try std.testing.expectEqual(@as(?usize, null), sample_index);

    var empty_u32_out: [4]?u32 = undefined;
    try fillWeightedIndexU32From(&empty_engine, u32, &empty_u32_out, &.{ 0, 0, 0, 0 });
    for (empty_u32_out) |sample_index| try std.testing.expectEqual(@as(?u32, null), sample_index);
}

test "generic weightedIndex preserves facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const weights = [_]u32{ 1, 2, 6, 3 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c705);
        var direct_engine = Engine.init(0x5150_c705);
        const rng = Rng.init(&facade_engine);

        try std.testing.expectEqual(weightedIndex(rng, u32, &weights), weightedIndexFrom(&direct_engine, u32, &weights));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try std.testing.expectEqual(try weightedIndexChecked(rng, u32, &weights), try weightedIndexCheckedFrom(&direct_engine, u32, &weights));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try std.testing.expectEqual(try weightedIndexU32(rng, u32, &weights), try weightedIndexU32From(&direct_engine, u32, &weights));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try std.testing.expectEqual(try weightedIndexU32Checked(rng, u32, &weights), try weightedIndexU32CheckedFrom(&direct_engine, u32, &weights));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_fill: [8]?usize = undefined;
        var direct_fill: [8]usize = undefined;
        try fillWeightedIndex(rng, u32, &facade_fill, &weights);
        try fillWeightedIndexCheckedFrom(&direct_engine, u32, &direct_fill, &weights);
        for (facade_fill, direct_fill) |optional, checked| {
            try std.testing.expectEqual(optional.?, checked);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_fill_u32: [8]?u32 = undefined;
        var direct_fill_u32: [8]u32 = undefined;
        try fillWeightedIndexU32(rng, u32, &facade_fill_u32, &weights);
        try fillWeightedIndexU32CheckedFrom(&direct_engine, u32, &direct_fill_u32, &weights);
        for (facade_fill_u32, direct_fill_u32) |optional, checked| {
            try std.testing.expectEqual(optional.?, checked);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_batch = try weightedIndexBatch(std.testing.allocator, rng, u32, 8, &weights);
        defer std.testing.allocator.free(facade_batch);
        const direct_batch = try weightedIndexBatchCheckedFrom(std.testing.allocator, &direct_engine, u32, 8, &weights);
        defer std.testing.allocator.free(direct_batch);
        for (facade_batch, direct_batch) |optional, checked| {
            try std.testing.expectEqual(optional.?, checked);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_batch_u32 = try weightedIndexU32Batch(std.testing.allocator, rng, u32, 8, &weights);
        defer std.testing.allocator.free(facade_batch_u32);
        const direct_batch_u32 = try weightedIndexU32BatchCheckedFrom(std.testing.allocator, &direct_engine, u32, 8, &weights);
        defer std.testing.allocator.free(direct_batch_u32);
        for (facade_batch_u32, direct_batch_u32) |optional, checked| {
            try std.testing.expectEqual(optional.?, checked);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_c706);
    var invalid_control = alea.ScalarPrng.init(0x5150_c706);
    const invalid_rng = Rng.init(&invalid_engine);
    try std.testing.expectError(error.InvalidWeight, weightedIndexChecked(invalid_rng, f64, &.{ 1.0, std.math.nan(f64), 2.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, weightedIndexCheckedFrom(&invalid_engine, f64, &.{ 1.0, std.math.inf(f64), 2.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32CheckedFrom(&invalid_engine, f64, &.{ 1.0, std.math.nan(f64), 2.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var empty_fill: [0]usize = .{};
    try fillWeightedIndexChecked(invalid_rng, f64, &empty_fill, &.{ 1.0, std.math.nan(f64) });
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var empty_fill_u32: [0]u32 = .{};
    try fillWeightedIndexU32CheckedFrom(&invalid_engine, f64, &empty_fill_u32, &.{ 1.0, std.math.nan(f64) });
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var one_fill: [1]usize = undefined;
    try std.testing.expectError(error.EmptyInput, fillWeightedIndexCheckedFrom(&invalid_engine, u32, &one_fill, &.{}));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var one_fill_u32: [1]u32 = undefined;
    try std.testing.expectError(error.EmptyInput, fillWeightedIndexU32CheckedFrom(&invalid_engine, u32, &one_fill_u32, &.{ 0, 0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var invalid_weight_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexBatchCheckedFrom(invalid_weight_alloc.allocator(), &invalid_engine, f64, 4, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expect(!invalid_weight_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var invalid_weight_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32BatchCheckedFrom(invalid_weight_u32_alloc.allocator(), &invalid_engine, f64, 4, &.{ 1.0, std.math.inf(f64) }));
    try std.testing.expect(!invalid_weight_u32_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var no_positive_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, weightedIndexBatchCheckedFrom(no_positive_alloc.allocator(), &invalid_engine, u32, 4, &.{ 0, 0 }));
    try std.testing.expect(!no_positive_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var no_positive_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, weightedIndexU32BatchCheckedFrom(no_positive_u32_alloc.allocator(), &invalid_engine, u32, 4, &.{ 0, 0 }));
    try std.testing.expect(!no_positive_u32_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var zero_count_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const zero_count = try weightedIndexBatchCheckedFrom(zero_count_alloc.allocator(), &invalid_engine, f64, 0, &.{std.math.nan(f64)});
    defer zero_count_alloc.allocator().free(zero_count);
    try std.testing.expectEqual(@as(usize, 0), zero_count.len);
    try std.testing.expect(!zero_count_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var weighted_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, weightedIndexBatchCheckedFrom(weighted_alloc.allocator(), &invalid_engine, u32, 4, &weights));
    try std.testing.expect(weighted_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var weighted_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, weightedIndexU32BatchCheckedFrom(weighted_u32_alloc.allocator(), &invalid_engine, u32, 4, &weights));
    try std.testing.expect(weighted_u32_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
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

    var fill_engine = alea.ScalarPrng.init(0x5150_b00a);
    var filled: [8]?u8 = undefined;
    try fillChooseWeightedFrom(&fill_engine, u8, u32, &filled, &items, &weights);
    for (filled) |sample| try std.testing.expect(std.mem.indexOfScalar(u8, &items, sample.?) != null);

    var fill_checked_engine = alea.ScalarPrng.init(0x5150_b00b);
    var filled_checked: [8]u8 = undefined;
    try fillChooseWeightedCheckedFrom(&fill_checked_engine, u8, u32, &filled_checked, &items, &weights);
    for (filled_checked) |sample| try std.testing.expect(std.mem.indexOfScalar(u8, &items, sample) != null);

    var batch_engine = alea.ScalarPrng.init(0x5150_b00c);
    const batch = try chooseWeightedBatchFrom(std.testing.allocator, &batch_engine, u8, u32, 8, &items, &weights);
    defer std.testing.allocator.free(batch);
    for (batch) |sample| try std.testing.expect(std.mem.indexOfScalar(u8, &items, sample.?) != null);

    var batch_checked_engine = alea.ScalarPrng.init(0x5150_b00d);
    const batch_checked = try chooseWeightedBatchCheckedFrom(std.testing.allocator, &batch_checked_engine, u8, u32, 8, &items, &weights);
    defer std.testing.allocator.free(batch_checked);
    for (batch_checked) |sample| try std.testing.expect(std.mem.indexOfScalar(u8, &items, sample) != null);

    var const_ptr_engine = alea.ScalarPrng.init(0x5150_b008);
    const const_ptr = (try chooseWeightedConstPtrFrom(&const_ptr_engine, u8, u32, &items, &weights)).?;
    try std.testing.expect(std.mem.indexOfScalar(u8, &items, const_ptr.*) != null);
    var checked_const_ptr_engine = alea.ScalarPrng.init(0x5150_b009);
    const checked_const_ptr = try chooseWeightedConstPtrCheckedFrom(&checked_const_ptr_engine, u8, u32, &items, &weights);
    try std.testing.expect(std.mem.indexOfScalar(u8, &items, checked_const_ptr.*) != null);

    var fill_const_ptr_engine = alea.ScalarPrng.init(0x5150_b00e);
    var filled_const_ptrs: [8]?*const u8 = undefined;
    try fillChooseWeightedConstPtrFrom(&fill_const_ptr_engine, u8, u32, &filled_const_ptrs, &items, &weights);
    for (filled_const_ptrs) |sample| try std.testing.expect(std.mem.indexOfScalar(u8, &items, sample.?.*) != null);

    var fill_const_ptr_checked_engine = alea.ScalarPrng.init(0x5150_b00f);
    var filled_const_ptrs_checked: [8]*const u8 = undefined;
    try fillChooseWeightedConstPtrCheckedFrom(&fill_const_ptr_checked_engine, u8, u32, &filled_const_ptrs_checked, &items, &weights);
    for (filled_const_ptrs_checked) |sample| try std.testing.expect(std.mem.indexOfScalar(u8, &items, sample.*) != null);

    var const_ptr_batch_engine = alea.ScalarPrng.init(0x5150_b010);
    const const_ptr_batch = try chooseWeightedConstPtrBatchFrom(std.testing.allocator, &const_ptr_batch_engine, u8, u32, 8, &items, &weights);
    defer std.testing.allocator.free(const_ptr_batch);
    for (const_ptr_batch) |sample| try std.testing.expect(std.mem.indexOfScalar(u8, &items, sample.?.*) != null);

    var const_ptr_batch_checked_engine = alea.ScalarPrng.init(0x5150_b011);
    const const_ptr_batch_checked = try chooseWeightedConstPtrBatchCheckedFrom(std.testing.allocator, &const_ptr_batch_checked_engine, u8, u32, 8, &items, &weights);
    defer std.testing.allocator.free(const_ptr_batch_checked);
    for (const_ptr_batch_checked) |sample| try std.testing.expect(std.mem.indexOfScalar(u8, &items, sample.*) != null);

    var mutable = items;
    var ptr_engine = alea.ScalarPrng.init(0x5150_b003);
    const ptr = (try chooseWeightedPtrFrom(&ptr_engine, u8, u32, &mutable, &weights)).?;
    ptr.* += 1;
    try std.testing.expect(std.mem.indexOfScalar(u8, &mutable, ptr.*) != null);

    var fill_ptr_items = items;
    var fill_ptr_engine = alea.ScalarPrng.init(0x5150_b012);
    var filled_ptrs: [8]?*u8 = undefined;
    try fillChooseWeightedPtrFrom(&fill_ptr_engine, u8, u32, &filled_ptrs, &fill_ptr_items, &weights);
    for (filled_ptrs) |sample| try std.testing.expect(std.mem.indexOfScalar(u8, &fill_ptr_items, sample.?.*) != null);

    var fill_ptr_checked_items = items;
    var fill_ptr_checked_engine = alea.ScalarPrng.init(0x5150_b013);
    var filled_ptrs_checked: [8]*u8 = undefined;
    try fillChooseWeightedPtrCheckedFrom(&fill_ptr_checked_engine, u8, u32, &filled_ptrs_checked, &fill_ptr_checked_items, &weights);
    for (filled_ptrs_checked) |sample| try std.testing.expect(std.mem.indexOfScalar(u8, &fill_ptr_checked_items, sample.*) != null);

    var ptr_batch_items = items;
    var ptr_batch_engine = alea.ScalarPrng.init(0x5150_b014);
    const ptr_batch = try chooseWeightedPtrBatchFrom(std.testing.allocator, &ptr_batch_engine, u8, u32, 8, &ptr_batch_items, &weights);
    defer std.testing.allocator.free(ptr_batch);
    for (ptr_batch) |sample| try std.testing.expect(std.mem.indexOfScalar(u8, &ptr_batch_items, sample.?.*) != null);

    var ptr_batch_checked_items = items;
    var ptr_batch_checked_engine = alea.ScalarPrng.init(0x5150_b015);
    const ptr_batch_checked = try chooseWeightedPtrBatchCheckedFrom(std.testing.allocator, &ptr_batch_checked_engine, u8, u32, 8, &ptr_batch_checked_items, &weights);
    defer std.testing.allocator.free(ptr_batch_checked);
    for (ptr_batch_checked) |sample| try std.testing.expect(std.mem.indexOfScalar(u8, &ptr_batch_checked_items, sample.*) != null);

    var single_engine = alea.ScalarPrng.init(0x5150_b004);
    var single_control = alea.ScalarPrng.init(0x5150_b004);
    try std.testing.expectEqual(@as(u8, 30), (try chooseWeightedFrom(&single_engine, u8, u32, &items, &.{ 0, 0, 5, 0 })).?);
    try std.testing.expectEqual(&items[2], (try chooseWeightedConstPtrFrom(&single_engine, u8, u32, &items, &.{ 0, 0, 5, 0 })).?);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var single_fill: [5]u8 = undefined;
    try fillChooseWeightedCheckedFrom(&single_engine, u8, u32, &single_fill, &items, &.{ 0, 0, 5, 0 });
    for (single_fill) |sample| try std.testing.expectEqual(@as(u8, 30), sample);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    const single_batch = try chooseWeightedBatchCheckedFrom(std.testing.allocator, &single_engine, u8, u32, 5, &items, &.{ 0, 0, 5, 0 });
    defer std.testing.allocator.free(single_batch);
    for (single_batch) |sample| try std.testing.expectEqual(@as(u8, 30), sample);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var single_const_ptr_fill: [5]*const u8 = undefined;
    try fillChooseWeightedConstPtrCheckedFrom(&single_engine, u8, u32, &single_const_ptr_fill, &items, &.{ 0, 0, 5, 0 });
    for (single_const_ptr_fill) |sample| try std.testing.expectEqual(@as(u8, 30), sample.*);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    const single_const_ptr_batch = try chooseWeightedConstPtrBatchCheckedFrom(std.testing.allocator, &single_engine, u8, u32, 5, &items, &.{ 0, 0, 5, 0 });
    defer std.testing.allocator.free(single_const_ptr_batch);
    for (single_const_ptr_batch) |sample| try std.testing.expectEqual(@as(u8, 30), sample.*);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var single_mutable = items;
    var single_ptr_fill: [5]*u8 = undefined;
    try fillChooseWeightedPtrCheckedFrom(&single_engine, u8, u32, &single_ptr_fill, &single_mutable, &.{ 0, 0, 5, 0 });
    for (single_ptr_fill) |sample| try std.testing.expectEqual(@as(u8, 30), sample.*);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    const single_ptr_batch = try chooseWeightedPtrBatchCheckedFrom(std.testing.allocator, &single_engine, u8, u32, 5, &single_mutable, &.{ 0, 0, 5, 0 });
    defer std.testing.allocator.free(single_ptr_batch);
    for (single_ptr_batch) |sample| try std.testing.expectEqual(@as(u8, 30), sample.*);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_b005);
    try std.testing.expect((try chooseWeightedFrom(&empty_engine, u8, u32, &.{}, &.{})) == null);
    try std.testing.expect((try chooseWeightedConstPtrFrom(&empty_engine, u8, u32, &.{}, &.{})) == null);
    try std.testing.expect((try chooseWeightedFrom(&empty_engine, u8, u32, &items, &.{ 0, 0, 0, 0 })) == null);
    try std.testing.expect((try chooseWeightedConstPtrFrom(&empty_engine, u8, u32, &items, &.{ 0, 0, 0, 0 })) == null);
    try std.testing.expectError(error.EmptyInput, chooseWeightedCheckedFrom(&empty_engine, u8, u32, &items, &.{ 0, 0, 0, 0 }));
    try std.testing.expectError(error.EmptyInput, chooseWeightedConstPtrCheckedFrom(&empty_engine, u8, u32, &items, &.{ 0, 0, 0, 0 }));

    var empty_values: [4]?u8 = undefined;
    try fillChooseWeightedFrom(&empty_engine, u8, u32, &empty_values, &items, &.{ 0, 0, 0, 0 });
    for (empty_values) |sample| try std.testing.expectEqual(@as(?u8, null), sample);

    var empty_const_ptrs: [4]?*const u8 = undefined;
    try fillChooseWeightedConstPtrFrom(&empty_engine, u8, u32, &empty_const_ptrs, &items, &.{ 0, 0, 0, 0 });
    for (empty_const_ptrs) |sample| try std.testing.expectEqual(@as(?*const u8, null), sample);

    var empty_mutable = items;
    var empty_ptrs: [4]?*u8 = undefined;
    try fillChooseWeightedPtrFrom(&empty_engine, u8, u32, &empty_ptrs, &empty_mutable, &.{ 0, 0, 0, 0 });
    for (empty_ptrs) |sample| try std.testing.expectEqual(@as(?*u8, null), sample);
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

        var facade_fill: [8]?u8 = undefined;
        var direct_fill: [8]u8 = undefined;
        try fillChooseWeighted(rng, u8, f64, &facade_fill, &items, &weights);
        try fillChooseWeightedCheckedFrom(&direct_engine, u8, f64, &direct_fill, &items, &weights);
        for (facade_fill, direct_fill) |optional, checked_value| {
            try std.testing.expectEqual(optional.?, checked_value);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_batch = try chooseWeightedBatch(std.testing.allocator, rng, u8, f64, 8, &items, &weights);
        defer std.testing.allocator.free(facade_batch);
        const direct_batch = try chooseWeightedBatchCheckedFrom(std.testing.allocator, &direct_engine, u8, f64, 8, &items, &weights);
        defer std.testing.allocator.free(direct_batch);
        for (facade_batch, direct_batch) |optional, checked_value| {
            try std.testing.expectEqual(optional.?, checked_value);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_const_ptr = (try chooseWeightedConstPtr(rng, u8, f64, &items, &weights)).?;
        const direct_const_ptr = (try chooseWeightedConstPtrFrom(&direct_engine, u8, f64, &items, &weights)).?;
        try std.testing.expectEqual(@intFromPtr(facade_const_ptr) - @intFromPtr(&items[0]), @intFromPtr(direct_const_ptr) - @intFromPtr(&items[0]));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade_const_ptr = try chooseWeightedConstPtrChecked(rng, u8, f64, &items, &weights);
        const checked_direct_const_ptr = try chooseWeightedConstPtrCheckedFrom(&direct_engine, u8, f64, &items, &weights);
        try std.testing.expectEqual(@intFromPtr(checked_facade_const_ptr) - @intFromPtr(&items[0]), @intFromPtr(checked_direct_const_ptr) - @intFromPtr(&items[0]));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_const_ptrs: [8]?*const u8 = undefined;
        var direct_const_ptrs: [8]*const u8 = undefined;
        try fillChooseWeightedConstPtr(rng, u8, f64, &facade_const_ptrs, &items, &weights);
        try fillChooseWeightedConstPtrCheckedFrom(&direct_engine, u8, f64, &direct_const_ptrs, &items, &weights);
        for (facade_const_ptrs, direct_const_ptrs) |optional, checked_ptr| {
            try std.testing.expectEqual(@intFromPtr(optional.?) - @intFromPtr(&items[0]), @intFromPtr(checked_ptr) - @intFromPtr(&items[0]));
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_const_ptr_batch = try chooseWeightedConstPtrBatch(std.testing.allocator, rng, u8, f64, 8, &items, &weights);
        defer std.testing.allocator.free(facade_const_ptr_batch);
        const direct_const_ptr_batch = try chooseWeightedConstPtrBatchCheckedFrom(std.testing.allocator, &direct_engine, u8, f64, 8, &items, &weights);
        defer std.testing.allocator.free(direct_const_ptr_batch);
        for (facade_const_ptr_batch, direct_const_ptr_batch) |optional, checked_ptr| {
            try std.testing.expectEqual(@intFromPtr(optional.?) - @intFromPtr(&items[0]), @intFromPtr(checked_ptr) - @intFromPtr(&items[0]));
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_mutable = items;
        var direct_mutable = items;
        const facade_ptr = (try chooseWeightedPtr(rng, u8, f64, &facade_mutable, &weights)).?;
        const direct_ptr = (try chooseWeightedPtrFrom(&direct_engine, u8, f64, &direct_mutable, &weights)).?;
        try std.testing.expectEqual(@intFromPtr(facade_ptr) - @intFromPtr(&facade_mutable[0]), @intFromPtr(direct_ptr) - @intFromPtr(&direct_mutable[0]));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_ptr_items = items;
        var direct_ptr_items = items;
        var facade_ptrs: [8]?*u8 = undefined;
        var direct_ptrs: [8]*u8 = undefined;
        try fillChooseWeightedPtr(rng, u8, f64, &facade_ptrs, &facade_ptr_items, &weights);
        try fillChooseWeightedPtrCheckedFrom(&direct_engine, u8, f64, &direct_ptrs, &direct_ptr_items, &weights);
        for (facade_ptrs, direct_ptrs) |optional, checked_ptr| {
            try std.testing.expectEqual(@intFromPtr(optional.?) - @intFromPtr(&facade_ptr_items[0]), @intFromPtr(checked_ptr) - @intFromPtr(&direct_ptr_items[0]));
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_ptr_batch_items = items;
        var direct_ptr_batch_items = items;
        const facade_ptr_batch = try chooseWeightedPtrBatch(std.testing.allocator, rng, u8, f64, 8, &facade_ptr_batch_items, &weights);
        defer std.testing.allocator.free(facade_ptr_batch);
        const direct_ptr_batch = try chooseWeightedPtrBatchCheckedFrom(std.testing.allocator, &direct_engine, u8, f64, 8, &direct_ptr_batch_items, &weights);
        defer std.testing.allocator.free(direct_ptr_batch);
        for (facade_ptr_batch, direct_ptr_batch) |optional, checked_ptr| {
            try std.testing.expectEqual(@intFromPtr(optional.?) - @intFromPtr(&facade_ptr_batch_items[0]), @intFromPtr(checked_ptr) - @intFromPtr(&direct_ptr_batch_items[0]));
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_b007);
    var invalid_control = alea.ScalarPrng.init(0x5150_b007);
    const invalid_rng = Rng.init(&invalid_engine);
    try std.testing.expectError(error.LengthMismatch, chooseWeighted(invalid_rng, u8, u32, &items, &.{ 1, 2 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    var one_checked_value: [1]u8 = undefined;
    try std.testing.expectError(error.LengthMismatch, fillChooseWeightedChecked(invalid_rng, u8, u32, &one_checked_value, &items, &.{ 1, 2 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.LengthMismatch, chooseWeightedConstPtr(invalid_rng, u8, u32, &items, &.{ 1, 2 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    var one_checked_const_ptr: [1]*const u8 = undefined;
    try std.testing.expectError(error.LengthMismatch, fillChooseWeightedConstPtrChecked(invalid_rng, u8, u32, &one_checked_const_ptr, &items, &.{ 1, 2 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    var invalid_mutable = items;
    var one_checked_ptr: [1]*u8 = undefined;
    try std.testing.expectError(error.LengthMismatch, fillChooseWeightedPtrChecked(invalid_rng, u8, u32, &one_checked_ptr, &invalid_mutable, &.{ 1, 2 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrFrom(&invalid_engine, u8, f64, @constCast(&items), &.{ 1.0, std.math.inf(f64), 2.0, 3.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrFrom(&invalid_engine, u8, f64, &items, &.{ 1.0, std.math.inf(f64), 2.0, 3.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var empty_fill: [0]u8 = .{};
    try fillChooseWeightedCheckedFrom(&invalid_engine, u8, f64, &empty_fill, &items, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 });
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var invalid_weight_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatchCheckedFrom(invalid_weight_alloc.allocator(), &invalid_engine, u8, f64, 4, &items, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }));
    try std.testing.expect(!invalid_weight_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var invalid_weight_const_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatchCheckedFrom(invalid_weight_const_ptr_alloc.allocator(), &invalid_engine, u8, f64, 4, &items, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }));
    try std.testing.expect(!invalid_weight_const_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var invalid_weight_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatchCheckedFrom(invalid_weight_ptr_alloc.allocator(), &invalid_engine, u8, f64, 4, &invalid_mutable, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }));
    try std.testing.expect(!invalid_weight_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var no_positive_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, chooseWeightedBatchCheckedFrom(no_positive_alloc.allocator(), &invalid_engine, u8, u32, 4, &items, &.{ 0, 0, 0, 0 }));
    try std.testing.expect(!no_positive_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var no_positive_const_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, chooseWeightedConstPtrBatchCheckedFrom(no_positive_const_ptr_alloc.allocator(), &invalid_engine, u8, u32, 4, &items, &.{ 0, 0, 0, 0 }));
    try std.testing.expect(!no_positive_const_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var no_positive_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, chooseWeightedPtrBatchCheckedFrom(no_positive_ptr_alloc.allocator(), &invalid_engine, u8, u32, 4, &invalid_mutable, &.{ 0, 0, 0, 0 }));
    try std.testing.expect(!no_positive_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var zero_count_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const zero_count = try chooseWeightedBatchCheckedFrom(zero_count_alloc.allocator(), &invalid_engine, u8, f64, 0, &items, &.{std.math.nan(f64)});
    defer zero_count_alloc.allocator().free(zero_count);
    try std.testing.expectEqual(@as(usize, 0), zero_count.len);
    try std.testing.expect(!zero_count_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var zero_count_const_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const zero_count_const_ptr = try chooseWeightedConstPtrBatchCheckedFrom(zero_count_const_ptr_alloc.allocator(), &invalid_engine, u8, f64, 0, &items, &.{std.math.nan(f64)});
    defer zero_count_const_ptr_alloc.allocator().free(zero_count_const_ptr);
    try std.testing.expectEqual(@as(usize, 0), zero_count_const_ptr.len);
    try std.testing.expect(!zero_count_const_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var zero_count_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const zero_count_ptr = try chooseWeightedPtrBatchCheckedFrom(zero_count_ptr_alloc.allocator(), &invalid_engine, u8, f64, 0, &invalid_mutable, &.{std.math.nan(f64)});
    defer zero_count_ptr_alloc.allocator().free(zero_count_ptr);
    try std.testing.expectEqual(@as(usize, 0), zero_count_ptr.len);
    try std.testing.expect(!zero_count_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var weighted_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, chooseWeightedBatchCheckedFrom(weighted_alloc.allocator(), &invalid_engine, u8, f64, 4, &items, &weights));
    try std.testing.expect(weighted_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var weighted_const_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, chooseWeightedConstPtrBatchCheckedFrom(weighted_const_ptr_alloc.allocator(), &invalid_engine, u8, f64, 4, &items, &weights));
    try std.testing.expect(weighted_const_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var weighted_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, chooseWeightedPtrBatchCheckedFrom(weighted_ptr_alloc.allocator(), &invalid_engine, u8, f64, 4, &invalid_mutable, &weights));
    try std.testing.expect(weighted_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "chooseWeightedBy selects values and pointers from item accessors" {
    const alea = @import("root.zig");
    const Entry = struct {
        label: []const u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .label = "never", .weight = 0 },
        .{ .label = "rare", .weight = 1 },
        .{ .label = "often", .weight = 7 },
    };

    var value_engine = alea.ScalarPrng.init(0x5150_c715);
    const value = (try chooseWeightedByFrom(&value_engine, Entry, u32, &entries, Entry.weightOf)).?;
    try std.testing.expect(value.weight > 0);

    var checked_engine = alea.ScalarPrng.init(0x5150_c716);
    const checked_value = try chooseWeightedByCheckedFrom(&checked_engine, Entry, u32, &entries, Entry.weightOf);
    try std.testing.expect(checked_value.weight > 0);

    var const_ptr_engine = alea.ScalarPrng.init(0x5150_c717);
    const const_ptr = (try chooseWeightedConstPtrByFrom(&const_ptr_engine, Entry, u32, &entries, Entry.weightOf)).?;
    try std.testing.expect(const_ptr.weight > 0);
    try std.testing.expect(!std.mem.eql(u8, const_ptr.label, "never"));

    var checked_const_ptr_engine = alea.ScalarPrng.init(0x5150_c718);
    const checked_const_ptr = try chooseWeightedConstPtrByCheckedFrom(&checked_const_ptr_engine, Entry, u32, &entries, Entry.weightOf);
    try std.testing.expect(checked_const_ptr.weight > 0);
    try std.testing.expect(!std.mem.eql(u8, checked_const_ptr.label, "never"));

    var ptr_items = entries;
    var ptr_engine = alea.ScalarPrng.init(0x5150_c719);
    const ptr = (try chooseWeightedPtrByFrom(&ptr_engine, Entry, u32, &ptr_items, Entry.weightOf)).?;
    try std.testing.expect(ptr.weight > 0);
    ptr.label = "selected";
    try std.testing.expect(std.mem.eql(u8, ptr.label, "selected"));

    var checked_ptr_items = entries;
    var checked_ptr_engine = alea.ScalarPrng.init(0x5150_c71a);
    const checked_ptr = try chooseWeightedPtrByCheckedFrom(&checked_ptr_engine, Entry, u32, &checked_ptr_items, Entry.weightOf);
    try std.testing.expect(checked_ptr.weight > 0);
    checked_ptr.label = "checked";
    try std.testing.expect(std.mem.eql(u8, checked_ptr.label, "checked"));
}

test "chooseWeightedBy preserves facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const Entry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .value = 10, .weight = 1 },
        .{ .value = 20, .weight = 2 },
        .{ .value = 30, .weight = 6 },
        .{ .value = 40, .weight = 3 },
    };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c71b);
        var direct_engine = Engine.init(0x5150_c71b);
        const rng = Rng.init(&facade_engine);

        const facade = (try chooseWeightedBy(rng, Entry, f64, &entries, Entry.weightOf)).?;
        const direct = (try chooseWeightedByFrom(&direct_engine, Entry, f64, &entries, Entry.weightOf)).?;
        try std.testing.expectEqual(facade.value, direct.value);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked = try chooseWeightedByChecked(rng, Entry, f64, &entries, Entry.weightOf);
        const direct_checked = try chooseWeightedByCheckedFrom(&direct_engine, Entry, f64, &entries, Entry.weightOf);
        try std.testing.expectEqual(facade_checked.value, direct_checked.value);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_const_ptr = (try chooseWeightedConstPtrBy(rng, Entry, f64, &entries, Entry.weightOf)).?;
        const direct_const_ptr = (try chooseWeightedConstPtrByFrom(&direct_engine, Entry, f64, &entries, Entry.weightOf)).?;
        try std.testing.expectEqual(@intFromPtr(facade_const_ptr) - @intFromPtr(&entries[0]), @intFromPtr(direct_const_ptr) - @intFromPtr(&entries[0]));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_const_ptr = try chooseWeightedConstPtrByChecked(rng, Entry, f64, &entries, Entry.weightOf);
        const direct_checked_const_ptr = try chooseWeightedConstPtrByCheckedFrom(&direct_engine, Entry, f64, &entries, Entry.weightOf);
        try std.testing.expectEqual(@intFromPtr(facade_checked_const_ptr) - @intFromPtr(&entries[0]), @intFromPtr(direct_checked_const_ptr) - @intFromPtr(&entries[0]));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_ptr_items = entries;
        var direct_ptr_items = entries;
        const facade_ptr = (try chooseWeightedPtrBy(rng, Entry, f64, &facade_ptr_items, Entry.weightOf)).?;
        const direct_ptr = (try chooseWeightedPtrByFrom(&direct_engine, Entry, f64, &direct_ptr_items, Entry.weightOf)).?;
        try std.testing.expectEqual(@intFromPtr(facade_ptr) - @intFromPtr(&facade_ptr_items[0]), @intFromPtr(direct_ptr) - @intFromPtr(&direct_ptr_items[0]));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_checked_ptr_items = entries;
        var direct_checked_ptr_items = entries;
        const facade_checked_ptr = try chooseWeightedPtrByChecked(rng, Entry, f64, &facade_checked_ptr_items, Entry.weightOf);
        const direct_checked_ptr = try chooseWeightedPtrByCheckedFrom(&direct_engine, Entry, f64, &direct_checked_ptr_items, Entry.weightOf);
        try std.testing.expectEqual(@intFromPtr(facade_checked_ptr) - @intFromPtr(&facade_checked_ptr_items[0]), @intFromPtr(direct_checked_ptr) - @intFromPtr(&direct_checked_ptr_items[0]));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    const SingleEntry = struct {
        value: u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }
    };
    const single_entries = [_]SingleEntry{
        .{ .value = 1, .weight = 0 },
        .{ .value = 2, .weight = 9 },
        .{ .value = 3, .weight = 0 },
    };
    var single_engine = alea.ScalarPrng.init(0x5150_c71c);
    var single_control = alea.ScalarPrng.init(0x5150_c71c);
    try std.testing.expectEqual(@as(u8, 2), (try chooseWeightedByFrom(&single_engine, SingleEntry, u32, &single_entries, SingleEntry.weightOf)).?.value);
    try std.testing.expectEqual(single_control.next(), single_engine.next());
    try std.testing.expectEqual(@as(u8, 2), (try chooseWeightedConstPtrByFrom(&single_engine, SingleEntry, u32, &single_entries, SingleEntry.weightOf)).?.value);
    try std.testing.expectEqual(single_control.next(), single_engine.next());
    var single_mutable = single_entries;
    try std.testing.expectEqual(@as(u8, 2), (try chooseWeightedPtrByFrom(&single_engine, SingleEntry, u32, &single_mutable, SingleEntry.weightOf)).?.value);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    const BadEntry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const empty_entries = [_]BadEntry{};
    const zero_entries = [_]BadEntry{ .{ .value = 1, .weight = 0 }, .{ .value = 2, .weight = 0 } };
    const bad_entries = [_]BadEntry{ .{ .value = 1, .weight = 1 }, .{ .value = 2, .weight = std.math.nan(f64) } };

    var invalid_engine = alea.ScalarPrng.init(0x5150_c71d);
    var invalid_control = alea.ScalarPrng.init(0x5150_c71d);
    try std.testing.expectEqual(@as(?BadEntry, null), try chooseWeightedByFrom(&invalid_engine, BadEntry, f64, &empty_entries, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectEqual(@as(?*const BadEntry, null), try chooseWeightedConstPtrByFrom(&invalid_engine, BadEntry, f64, &zero_entries, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    var zero_mutable = zero_entries;
    try std.testing.expectEqual(@as(?*BadEntry, null), try chooseWeightedPtrByFrom(&invalid_engine, BadEntry, f64, &zero_mutable, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.EmptyInput, chooseWeightedByCheckedFrom(&invalid_engine, BadEntry, f64, &empty_entries, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, chooseWeightedByFrom(&invalid_engine, BadEntry, f64, &bad_entries, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrByCheckedFrom(&invalid_engine, BadEntry, f64, &bad_entries, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    var bad_mutable = bad_entries;
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrByCheckedFrom(&invalid_engine, BadEntry, f64, &bad_mutable, BadEntry.weightOf));
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

        const ptr_array = choosePtrArray(rng, u8, 3, &items).?;
        const direct_ptr_array = choosePtrArrayFrom(&direct_engine, u8, 3, &items).?;
        for (ptr_array, direct_ptr_array) |ptr, direct_ptr| {
            const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            try std.testing.expectEqual(index, direct_index);
            try std.testing.expectEqual(&items[index], ptr);
            try std.testing.expectEqual(&items[direct_index], direct_ptr);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var mutable_items = items;
        var direct_mutable_items = items;
        const mut_ptr_array = chooseMutPtrArray(rng, u8, 3, &mutable_items).?;
        const direct_mut_ptr_array = chooseMutPtrArrayFrom(&direct_engine, u8, 3, &direct_mutable_items).?;
        for (mut_ptr_array, direct_mut_ptr_array) |ptr, direct_ptr| {
            const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&mutable_items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&direct_mutable_items[0]), @sizeOf(u8));
            try std.testing.expectEqual(index, direct_index);
            try std.testing.expectEqual(&mutable_items[index], ptr);
            try std.testing.expectEqual(&direct_mutable_items[direct_index], direct_ptr);
        }
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
    const owned_ptrs = try choice.ptrsFrom(std.testing.allocator, &engine, 8);
    defer std.testing.allocator.free(owned_ptrs);
    try std.testing.expectEqual(@as(usize, 8), owned_ptrs.len);
    for (owned_ptrs) |item| try std.testing.expect(item == &values[0] or item == &values[1] or item == &values[2] or item == &values[3]);
    var value_buf: [8]u8 = undefined;
    choice.fillValues(rng, &value_buf);
    for (value_buf) |value| try std.testing.expect(value == 2 or value == 4 or value == 6 or value == 8);
    choice.fillValuesFrom(&engine, &value_buf);
    for (value_buf) |value| try std.testing.expect(value == 2 or value == 4 or value == 6 or value == 8);
    const owned_values = try choice.valuesFrom(std.testing.allocator, &engine, 8);
    defer std.testing.allocator.free(owned_values);
    try std.testing.expectEqual(@as(usize, 8), owned_values.len);
    for (owned_values) |value| try std.testing.expect(value == 2 or value == 4 or value == 6 or value == 8);
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
    var index_buf: [0]usize = .{};
    choice.fillIndicesFrom(&engine, &index_buf);
    try std.testing.expectEqual(control.next(), engine.next());
    var index_u32_buf: [0]u32 = .{};
    try choice.fillIndicesU32From(&engine, &index_u32_buf);
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
    var weighted_index_buf: [0]usize = .{};
    weighted.fillIndicesFrom(&engine, &weighted_index_buf);
    try std.testing.expectEqual(control.next(), engine.next());
    var weighted_index_u32_buf: [0]u32 = .{};
    try weighted.fillIndicesU32From(&engine, &weighted_index_u32_buf);
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

    try std.testing.expectEqual(@as(usize, 0), choice.sampleIndexFrom(&engine));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(u32, 0), try choice.sampleIndexU32From(&engine));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(u8, 42), choice.sampleValueFrom(&engine));
    try std.testing.expectEqual(control.next(), engine.next());

    var pointer_buf: [4]*const u8 = undefined;
    choice.fillFrom(&engine, &pointer_buf);
    for (pointer_buf) |item| try std.testing.expectEqual(&values[0], item);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_ptrs = try choice.ptrsFrom(std.testing.allocator, &engine, 4);
    defer std.testing.allocator.free(owned_ptrs);
    for (owned_ptrs) |item| try std.testing.expectEqual(&values[0], item);
    try std.testing.expectEqual(control.next(), engine.next());

    var value_buf: [4]u8 = undefined;
    choice.fillValuesFrom(&engine, &value_buf);
    for (value_buf) |item| try std.testing.expectEqual(@as(u8, 42), item);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_values = try choice.valuesFrom(std.testing.allocator, &engine, 4);
    defer std.testing.allocator.free(owned_values);
    for (owned_values) |item| try std.testing.expectEqual(@as(u8, 42), item);
    try std.testing.expectEqual(control.next(), engine.next());

    var index_buf: [4]usize = undefined;
    choice.fillIndicesFrom(&engine, &index_buf);
    for (index_buf) |index| try std.testing.expectEqual(@as(usize, 0), index);
    try std.testing.expectEqual(control.next(), engine.next());

    var index_u32_buf: [4]u32 = undefined;
    try choice.fillIndicesU32From(&engine, &index_u32_buf);
    for (index_u32_buf) |index| try std.testing.expectEqual(@as(u32, 0), index);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_indices = try choice.indicesFrom(std.testing.allocator, &engine, 4);
    defer std.testing.allocator.free(owned_indices);
    for (owned_indices) |index| try std.testing.expectEqual(@as(usize, 0), index);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_indices_u32 = try choice.indicesU32From(std.testing.allocator, &engine, 4);
    defer std.testing.allocator.free(owned_indices_u32);
    for (owned_indices_u32) |index| try std.testing.expectEqual(@as(u32, 0), index);
    try std.testing.expectEqual(control.next(), engine.next());

    var iter = choice.iterFrom(&engine);
    try std.testing.expectEqual(&values[0], iter.next().?);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "choice owned value and pointer allocation failure does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_c084);
    var control = alea.ScalarPrng.init(0x5150_c084);

    const values = [_]u8{ 2, 4, 6, 8 };
    const choice = Choice(u8).init(&values).?;

    var ptrs_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, choice.ptrsFrom(ptrs_alloc.allocator(), &engine, 4));
    try std.testing.expect(ptrs_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var values_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, choice.valuesFrom(values_alloc.allocator(), &engine, 4));
    try std.testing.expect(values_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "weighted choice init allocation failure cleans up" {
    const items = [_]u8{ 1, 2, 3 };
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, WeightedChoice(u8, u32).init(failing.allocator(), &items, &.{ 1, 2, 3 }));
    try std.testing.expect(failing.has_induced_failure);
}

test "weighted choice accessor initialization and update use item weights" {
    const alea = @import("root.zig");
    const Entry = struct {
        label: []const u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }

        fn updatedWeight(item: *const @This()) u32 {
            if (std.mem.eql(u8, item.label, "rare")) return 0;
            if (std.mem.eql(u8, item.label, "often")) return 0;
            return 5;
        }
    };
    const entries = [_]Entry{
        .{ .label = "never", .weight = 0 },
        .{ .label = "rare", .weight = 1 },
        .{ .label = "often", .weight = 7 },
    };

    var choice = try WeightedChoice(Entry, u32).initBy(std.testing.allocator, &entries, Entry.weightOf);
    defer choice.deinit();

    try std.testing.expectEqual(@as(usize, 3), choice.len());
    try std.testing.expectApproxEqAbs(@as(f64, 8), choice.totalWeight(), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 0), try choice.weightAt(0), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 1), try choice.weightAt(1), 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 7), try choice.weightAt(2), 1e-12);

    var engine = alea.ScalarPrng.init(0x5150_c881);
    var saw_often = false;
    var i: usize = 0;
    while (i < 32) : (i += 1) {
        const item = choice.sampleFrom(&engine);
        try std.testing.expect(!std.mem.eql(u8, item.label, "never"));
        saw_often = saw_often or std.mem.eql(u8, item.label, "often");
    }
    try std.testing.expect(saw_often);

    try choice.updateBy(Entry.updatedWeight);
    try std.testing.expectApproxEqAbs(@as(f64, 5), choice.totalWeight(), 1e-12);
    try std.testing.expectEqual(@as(usize, 0), choice.sampleIndexFrom(&engine));
    try std.testing.expect(std.mem.eql(u8, choice.sampleFrom(&engine).label, "never"));
}

test "weighted choice accessor invalid and allocation paths preserve table" {
    const alea = @import("root.zig");
    const Entry = struct {
        label: []const u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }

        fn invalidWeight(item: *const @This()) f64 {
            if (std.mem.eql(u8, item.label, "rare")) return std.math.nan(f64);
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .label = "never", .weight = 0 },
        .{ .label = "rare", .weight = 1 },
        .{ .label = "often", .weight = 7 },
    };

    try std.testing.expectError(error.EmptyInput, WeightedChoice(Entry, f64).initBy(std.testing.allocator, &.{}, Entry.weightOf));
    try std.testing.expectError(error.InvalidWeight, WeightedChoice(Entry, f64).initBy(std.testing.allocator, &entries, Entry.invalidWeight));

    var choice = try WeightedChoice(Entry, f64).initBy(std.testing.allocator, &entries, Entry.weightOf);
    defer choice.deinit();
    var engine = alea.ScalarPrng.init(0x5150_c882);
    var control = alea.ScalarPrng.init(0x5150_c882);

    try std.testing.expectError(error.InvalidWeight, choice.updateBy(Entry.invalidWeight));
    try std.testing.expectEqual(control.next(), engine.next());
    try std.testing.expectApproxEqAbs(@as(f64, 8), choice.totalWeight(), 1e-12);
    var out: [4]Entry = undefined;
    choice.fillValuesFrom(&engine, &out);
    for (out) |item| try std.testing.expect(!std.mem.eql(u8, item.label, "never"));

    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{});
    var failing_choice = try WeightedChoice(Entry, f64).initBy(failing.allocator(), &entries, Entry.weightOf);
    defer failing_choice.deinit();
    failing.fail_index = failing.alloc_index;
    try std.testing.expectError(error.OutOfMemory, failing_choice.updateBy(Entry.weightOf));
    try std.testing.expect(failing.has_induced_failure);
    try std.testing.expectApproxEqAbs(@as(f64, 8), failing_choice.totalWeight(), 1e-12);
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
    const direct_index = choice.sampleIndexFrom(&engine);
    try std.testing.expect(direct_index == 1 or direct_index == 2);
    const direct_index_u32 = try choice.sampleIndexU32From(&engine);
    try std.testing.expect(direct_index_u32 == 1 or direct_index_u32 == 2);
    const direct_value = choice.sampleValueFrom(&engine);
    try std.testing.expect(!std.mem.eql(u8, direct_value, "never"));
    var pointer_buf: [8]*const []const u8 = undefined;
    choice.fillFrom(&engine, &pointer_buf);
    for (pointer_buf) |item| try std.testing.expect(!std.mem.eql(u8, item.*, "never"));
    const owned_ptrs = try choice.ptrsFrom(std.testing.allocator, &engine, 8);
    defer std.testing.allocator.free(owned_ptrs);
    try std.testing.expectEqual(@as(usize, 8), owned_ptrs.len);
    for (owned_ptrs) |item| try std.testing.expect(!std.mem.eql(u8, item.*, "never"));
    var value_buf: [8][]const u8 = undefined;
    choice.fillValuesFrom(&engine, &value_buf);
    for (value_buf) |value| try std.testing.expect(!std.mem.eql(u8, value, "never"));
    const owned_values = try choice.valuesFrom(std.testing.allocator, &engine, 8);
    defer std.testing.allocator.free(owned_values);
    try std.testing.expectEqual(@as(usize, 8), owned_values.len);
    for (owned_values) |value| try std.testing.expect(!std.mem.eql(u8, value, "never"));
    var index_buf: [8]usize = undefined;
    choice.fillIndicesFrom(&engine, &index_buf);
    for (index_buf) |index| {
        try std.testing.expect(index == 1 or index == 2);
        try std.testing.expect(!std.mem.eql(u8, labels[index], "never"));
    }
    var index_u32_buf: [8]u32 = undefined;
    try choice.fillIndicesU32From(&engine, &index_u32_buf);
    for (index_u32_buf) |index| {
        try std.testing.expect(index == 1 or index == 2);
        try std.testing.expect(!std.mem.eql(u8, labels[index], "never"));
    }
    const owned_indices = try choice.indicesFrom(std.testing.allocator, &engine, 8);
    defer std.testing.allocator.free(owned_indices);
    try std.testing.expectEqual(@as(usize, 8), owned_indices.len);
    for (owned_indices) |index| {
        try std.testing.expect(index == 1 or index == 2);
        try std.testing.expect(!std.mem.eql(u8, labels[index], "never"));
    }
    const owned_indices_u32 = try choice.indicesU32From(std.testing.allocator, &engine, 8);
    defer std.testing.allocator.free(owned_indices_u32);
    try std.testing.expectEqual(@as(usize, 8), owned_indices_u32.len);
    for (owned_indices_u32) |index| {
        try std.testing.expect(index == 1 or index == 2);
        try std.testing.expect(!std.mem.eql(u8, labels[index], "never"));
    }

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

    try std.testing.expectEqual(@as(usize, 1), choice.sampleIndexFrom(&engine));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(u32, 1), try choice.sampleIndexU32From(&engine));
    try std.testing.expectEqual(control.next(), engine.next());

    var pointer_buf: [4]*const u8 = undefined;
    choice.fillFrom(&engine, &pointer_buf);
    for (pointer_buf) |item| try std.testing.expectEqual(@as(u8, 20), item.*);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_ptrs = try choice.ptrsFrom(std.testing.allocator, &engine, 4);
    defer std.testing.allocator.free(owned_ptrs);
    for (owned_ptrs) |item| try std.testing.expectEqual(@as(u8, 20), item.*);
    try std.testing.expectEqual(control.next(), engine.next());

    var value_buf: [4]u8 = undefined;
    choice.fillValuesFrom(&engine, &value_buf);
    for (value_buf) |item| try std.testing.expectEqual(@as(u8, 20), item);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_values = try choice.valuesFrom(std.testing.allocator, &engine, 4);
    defer std.testing.allocator.free(owned_values);
    for (owned_values) |item| try std.testing.expectEqual(@as(u8, 20), item);
    try std.testing.expectEqual(control.next(), engine.next());

    var index_buf: [4]usize = undefined;
    choice.fillIndicesFrom(&engine, &index_buf);
    for (index_buf) |index| try std.testing.expectEqual(@as(usize, 1), index);
    try std.testing.expectEqual(control.next(), engine.next());

    var index_u32_buf: [4]u32 = undefined;
    try choice.fillIndicesU32From(&engine, &index_u32_buf);
    for (index_u32_buf) |index| try std.testing.expectEqual(@as(u32, 1), index);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_indices = try choice.indicesFrom(std.testing.allocator, &engine, 4);
    defer std.testing.allocator.free(owned_indices);
    for (owned_indices) |index| try std.testing.expectEqual(@as(usize, 1), index);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_indices_u32 = try choice.indicesU32From(std.testing.allocator, &engine, 4);
    defer std.testing.allocator.free(owned_indices_u32);
    for (owned_indices_u32) |index| try std.testing.expectEqual(@as(u32, 1), index);
    try std.testing.expectEqual(control.next(), engine.next());

    try choice.update(&.{ 0, 0, 7 });
    try std.testing.expectEqual(@as(u8, 30), choice.sampleValueFrom(&engine));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "weighted choice owned batch allocation failure does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_0483);
    var control = alea.ScalarPrng.init(0x5150_0483);

    const items = [_]u8{ 10, 20, 30 };
    var choice = try WeightedChoice(u8, u32).init(std.testing.allocator, &items, &.{ 1, 2, 3 });
    defer choice.deinit();

    var ptrs_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, choice.ptrsFrom(ptrs_alloc.allocator(), &engine, 4));
    try std.testing.expect(ptrs_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var values_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, choice.valuesFrom(values_alloc.allocator(), &engine, 4));
    try std.testing.expect(values_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var indices_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, choice.indicesFrom(indices_alloc.allocator(), &engine, 4));
    try std.testing.expect(indices_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var indices_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, choice.indicesU32From(indices_u32_alloc.allocator(), &engine, 4));
    try std.testing.expect(indices_u32_alloc.has_induced_failure);
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

    const index_vec = try sampleWeightedIndexVecFrom(std.testing.allocator, &engine, f64, &weights, 4);
    defer index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 3), index_vec.len());
    switch (index_vec) {
        .u32 => {},
        .usize => return error.TestExpectedEqual,
    }
    var index_vec_iter = index_vec.iter();
    while (index_vec_iter.next()) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

    const indices_u32 = try sampleWeightedIndicesU32From(std.testing.allocator, &engine, f64, &weights, 4);
    defer std.testing.allocator.free(indices_u32);
    try std.testing.expectEqual(@as(usize, 3), indices_u32.len);
    for (indices_u32) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

    var u32_out: [4]u32 = undefined;
    var u32_keys: [4]f64 = undefined;
    const u32_count = try sampleWeightedIndicesU32IntoFrom(&engine, f64, &weights, &u32_out, &u32_keys);
    try std.testing.expectEqual(@as(usize, 3), u32_count);
    for (u32_out[0..u32_count]) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

    const checked_indices = try sampleWeightedIndicesCheckedFrom(std.testing.allocator, &engine, f64, &weights, 3);
    defer std.testing.allocator.free(checked_indices);
    try std.testing.expectEqual(@as(usize, 3), checked_indices.len);

    const checked_index_vec = try sampleWeightedIndexVecCheckedFrom(std.testing.allocator, &engine, f64, &weights, 3);
    defer checked_index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 3), checked_index_vec.len());

    const checked_indices_u32 = try sampleWeightedIndicesU32CheckedFrom(std.testing.allocator, &engine, f64, &weights, 3);
    defer std.testing.allocator.free(checked_indices_u32);
    try std.testing.expectEqual(@as(usize, 3), checked_indices_u32.len);

    var checked_u32_out: [3]u32 = undefined;
    var checked_u32_keys: [3]f64 = undefined;
    try sampleWeightedIndicesU32IntoCheckedFrom(&engine, f64, &weights, &checked_u32_out, &checked_u32_keys);
    for (checked_u32_out[0..]) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

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
    const empty_checked_index_vec = try sampleWeightedIndexVecCheckedFrom(std.testing.allocator, &engine, f64, &.{std.math.nan(f64)}, 0);
    defer empty_checked_index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 0), empty_checked_index_vec.len());
    const empty_indices_u32 = try sampleWeightedIndicesU32From(std.testing.allocator, &engine, f64, &.{std.math.nan(f64)}, 0);
    defer std.testing.allocator.free(empty_indices_u32);
    try std.testing.expectEqual(@as(usize, 0), empty_indices_u32.len);
    const empty_checked_indices_u32 = try sampleWeightedIndicesU32CheckedFrom(std.testing.allocator, &engine, f64, &.{std.math.nan(f64)}, 0);
    defer std.testing.allocator.free(empty_checked_indices_u32);
    try std.testing.expectEqual(@as(usize, 0), empty_checked_indices_u32.len);
    var empty_u32_out: [0]u32 = .{};
    var empty_u32_keys: [0]f64 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesU32IntoFrom(&engine, f64, &.{std.math.nan(f64)}, &empty_u32_out, &empty_u32_keys));
    try sampleWeightedIndicesU32IntoCheckedFrom(&engine, f64, &.{std.math.nan(f64)}, &empty_u32_out, &empty_u32_keys);
    const empty_checked_sample = try sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, u32, &.{}, &.{1}, 0);
    defer std.testing.allocator.free(empty_checked_sample);
    try std.testing.expectEqual(@as(usize, 0), empty_checked_sample.len);
    const invalid_empty_checked_sample = try sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, f64, &.{1}, &.{std.math.nan(f64)}, 0);
    defer std.testing.allocator.free(invalid_empty_checked_sample);
    try std.testing.expectEqual(@as(usize, 0), invalid_empty_checked_sample.len);

    try std.testing.expectError(error.EmptyInput, sampleWeightedIndices(std.testing.allocator, rng, u32, &.{}, 1));
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesFrom(std.testing.allocator, &engine, u32, &.{}, 1));
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndexVecFrom(std.testing.allocator, &engine, u32, &.{}, 1));
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesU32From(std.testing.allocator, &engine, u32, &.{}, 1));
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesU32IntoFrom(&engine, u32, &.{}, &u32_out, &u32_keys));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesChecked(std.testing.allocator, rng, u32, &.{ 1, 2 }, 3));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesCheckedFrom(std.testing.allocator, &engine, u32, &.{ 1, 2 }, 3));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexVecCheckedFrom(std.testing.allocator, &engine, u32, &.{ 1, 2 }, 3));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32CheckedFrom(std.testing.allocator, &engine, u32, &.{ 1, 2 }, 3));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32IntoCheckedFrom(&engine, u32, &.{ 1, 2 }, &checked_u32_out, &checked_u32_keys));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndices(std.testing.allocator, rng, f64, &.{ 1.0, std.math.nan(f64) }, 1));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexVecFrom(std.testing.allocator, &engine, f64, &.{ 1.0, std.math.nan(f64) }, 1));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesU32From(std.testing.allocator, &engine, f64, &.{ 1.0, std.math.nan(f64) }, 1));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesU32IntoFrom(&engine, f64, &.{ 1.0, std.math.nan(f64) }, &u32_out, &u32_keys));
    try std.testing.expectError(error.LengthMismatch, sampleWeighted(std.testing.allocator, rng, u8, u32, &.{ 1, 2 }, &.{1}, 1));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedFrom(std.testing.allocator, &engine, u8, u32, &.{ 1, 2 }, &.{1}, 1));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, u32, &.{ 1, 2 }, &.{1}, 3));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedChecked(std.testing.allocator, rng, u8, u32, &.{ 1, 2 }, &.{ 1, 2 }, 3));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedCheckedFrom(std.testing.allocator, &engine, u8, u32, &.{ 1, 2 }, &.{ 1, 2 }, 3));
}

test "index-weighted no-replacement samples support length weight functions" {
    const alea = @import("root.zig");
    const IndexWeight = struct {
        fn weightOf(index: usize) f64 {
            return switch (index) {
                1 => 1,
                3 => 9,
                6 => 4,
                else => 0,
            };
        }

        fn single(index: usize) u32 {
            return if (index == 4) 7 else 0;
        }

        fn sparse(index: usize) u32 {
            return if (index == 2) 1 else 0;
        }

        fn invalid(index: usize) f64 {
            return if (index == 2) std.math.nan(f64) else 1;
        }
    };

    var engine = alea.ScalarPrng.init(0x5150_f125);

    const indices = try sampleWeightedIndicesByIndexFrom(std.testing.allocator, &engine, f64, 8, 4, IndexWeight.weightOf);
    defer std.testing.allocator.free(indices);
    try std.testing.expectEqual(@as(usize, 3), indices.len);
    var seen = [_]bool{false} ** 8;
    for (indices) |index| {
        try std.testing.expect(index == 1 or index == 3 or index == 6);
        try std.testing.expect(!seen[index]);
        seen[index] = true;
    }

    const checked_indices = try sampleWeightedIndicesByIndexCheckedFrom(std.testing.allocator, &engine, f64, 8, 2, IndexWeight.weightOf);
    defer std.testing.allocator.free(checked_indices);
    try std.testing.expectEqual(@as(usize, 2), checked_indices.len);
    for (checked_indices) |index| try std.testing.expect(index == 1 or index == 3 or index == 6);

    const indices_u32 = try sampleWeightedIndicesU32ByIndexFrom(std.testing.allocator, &engine, f64, 8, 4, IndexWeight.weightOf);
    defer std.testing.allocator.free(indices_u32);
    try std.testing.expectEqual(@as(usize, 3), indices_u32.len);
    for (indices_u32) |index| try std.testing.expect(index == 1 or index == 3 or index == 6);

    const checked_indices_u32 = try sampleWeightedIndicesU32ByIndexCheckedFrom(std.testing.allocator, &engine, f64, 8, 2, IndexWeight.weightOf);
    defer std.testing.allocator.free(checked_indices_u32);
    try std.testing.expectEqual(@as(usize, 2), checked_indices_u32.len);
    for (checked_indices_u32) |index| try std.testing.expect(index == 1 or index == 3 or index == 6);

    const index_vec = try sampleWeightedIndexVecByIndexFrom(std.testing.allocator, &engine, f64, 8, 4, IndexWeight.weightOf);
    defer index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 3), index_vec.len());
    switch (index_vec) {
        .u32 => {},
        .usize => return error.TestExpectedEqual,
    }
    var iter = index_vec.iter();
    while (iter.next()) |index| try std.testing.expect(index == 1 or index == 3 or index == 6);

    const checked_index_vec = try sampleWeightedIndexVecByIndexCheckedFrom(std.testing.allocator, &engine, f64, 8, 2, IndexWeight.weightOf);
    defer checked_index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 2), checked_index_vec.len());

    const index_array = (try sampleWeightedIndexArrayByIndexFrom(&engine, f64, 2, 8, IndexWeight.weightOf)).?;
    for (index_array) |index| try std.testing.expect(index == 1 or index == 3 or index == 6);

    const checked_index_array = try sampleWeightedIndexArrayByIndexCheckedFrom(&engine, f64, 2, 8, IndexWeight.weightOf);
    for (checked_index_array) |index| try std.testing.expect(index == 1 or index == 3 or index == 6);

    const index_array_u32 = (try sampleWeightedIndexArrayU32ByIndexFrom(&engine, f64, 2, 8, IndexWeight.weightOf)).?;
    for (index_array_u32) |index| try std.testing.expect(index == 1 or index == 3 or index == 6);

    const checked_index_array_u32 = try sampleWeightedIndexArrayU32ByIndexCheckedFrom(&engine, f64, 2, 8, IndexWeight.weightOf);
    for (checked_index_array_u32) |index| try std.testing.expect(index == 1 or index == 3 or index == 6);

    var into: [4]usize = undefined;
    var into_keys: [4]f64 = undefined;
    const into_count = try sampleWeightedIndicesByIndexIntoFrom(&engine, f64, 8, &into, &into_keys, IndexWeight.weightOf);
    try std.testing.expectEqual(@as(usize, 3), into_count);
    for (into[0..into_count]) |index| try std.testing.expect(index == 1 or index == 3 or index == 6);

    var checked_into: [2]usize = undefined;
    var checked_into_keys: [2]f64 = undefined;
    try sampleWeightedIndicesByIndexIntoCheckedFrom(&engine, f64, 8, &checked_into, &checked_into_keys, IndexWeight.weightOf);
    for (checked_into[0..]) |index| try std.testing.expect(index == 1 or index == 3 or index == 6);

    var into_u32: [4]u32 = undefined;
    var into_u32_keys: [4]f64 = undefined;
    const into_u32_count = try sampleWeightedIndicesU32ByIndexIntoFrom(&engine, f64, 8, &into_u32, &into_u32_keys, IndexWeight.weightOf);
    try std.testing.expectEqual(@as(usize, 3), into_u32_count);
    for (into_u32[0..into_u32_count]) |index| try std.testing.expect(index == 1 or index == 3 or index == 6);

    var checked_into_u32: [2]u32 = undefined;
    var checked_into_u32_keys: [2]f64 = undefined;
    try sampleWeightedIndicesU32ByIndexIntoCheckedFrom(&engine, f64, 8, &checked_into_u32, &checked_into_u32_keys, IndexWeight.weightOf);
    for (checked_into_u32[0..]) |index| try std.testing.expect(index == 1 or index == 3 or index == 6);

    var no_consume_engine = alea.ScalarPrng.init(0x5150_f127);
    var no_consume_control = alea.ScalarPrng.init(0x5150_f127);

    const single_indices = try sampleWeightedIndicesByIndexFrom(std.testing.allocator, &no_consume_engine, u32, 8, 8, IndexWeight.single);
    defer std.testing.allocator.free(single_indices);
    try std.testing.expectEqualSlices(usize, &.{4}, single_indices);
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());

    const single_indices_u32 = try sampleWeightedIndicesU32ByIndexCheckedFrom(std.testing.allocator, &no_consume_engine, u32, 8, 1, IndexWeight.single);
    defer std.testing.allocator.free(single_indices_u32);
    try std.testing.expectEqualSlices(u32, &.{4}, single_indices_u32);
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());

    const single_index_vec = try sampleWeightedIndexVecByIndexFrom(std.testing.allocator, &no_consume_engine, u32, 8, 8, IndexWeight.single);
    defer single_index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 1), single_index_vec.len());
    try std.testing.expectEqual(@as(usize, 4), single_index_vec.at(0));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());

    const single_index_array = (try sampleWeightedIndexArrayByIndexFrom(&no_consume_engine, u32, 1, 8, IndexWeight.single)).?;
    try std.testing.expectEqual(@as(usize, 4), single_index_array[0]);
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());

    const single_index_array_u32 = try sampleWeightedIndexArrayU32ByIndexCheckedFrom(&no_consume_engine, u32, 1, 8, IndexWeight.single);
    try std.testing.expectEqual(@as(u32, 4), single_index_array_u32[0]);
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());

    const empty = try sampleWeightedIndicesByIndexFrom(std.testing.allocator, &no_consume_engine, f64, 8, 0, IndexWeight.invalid);
    defer std.testing.allocator.free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());

    const empty_array = try sampleWeightedIndexArrayByIndexFrom(&no_consume_engine, f64, 0, 8, IndexWeight.invalid);
    try std.testing.expectEqual(@as(usize, 0), empty_array.?.len);
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());

    var empty_into: [0]usize = .{};
    var empty_keys: [0]f64 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesByIndexIntoFrom(&no_consume_engine, f64, 8, &empty_into, &empty_keys, IndexWeight.invalid));
    try sampleWeightedIndicesByIndexIntoCheckedFrom(&no_consume_engine, f64, 8, &empty_into, &empty_keys, IndexWeight.invalid);
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());

    var empty_u32_into: [0]u32 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesU32ByIndexIntoFrom(&no_consume_engine, f64, 8, &empty_u32_into, &empty_keys, IndexWeight.invalid));
    try sampleWeightedIndicesU32ByIndexIntoCheckedFrom(&no_consume_engine, f64, 8, &empty_u32_into, &empty_keys, IndexWeight.invalid);
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());

    var single_into: [2]usize = undefined;
    var single_keys: [2]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedIndicesByIndexIntoFrom(&no_consume_engine, u32, 8, &single_into, &single_keys, IndexWeight.single));
    try std.testing.expectEqual(@as(usize, 4), single_into[0]);
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());

    var single_u32_into: [1]u32 = undefined;
    var single_u32_keys: [1]f64 = undefined;
    try sampleWeightedIndicesU32ByIndexIntoCheckedFrom(&no_consume_engine, u32, 8, &single_u32_into, &single_u32_keys, IndexWeight.single);
    try std.testing.expectEqual(@as(u32, 4), single_u32_into[0]);
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());

    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesByIndexFrom(std.testing.allocator, &no_consume_engine, u32, 0, 1, IndexWeight.single));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndexArrayByIndexFrom(&no_consume_engine, u32, 1, 0, IndexWeight.single));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesByIndexIntoFrom(&no_consume_engine, u32, 0, single_into[0..1], single_keys[0..1], IndexWeight.single));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByIndexCheckedFrom(std.testing.allocator, &no_consume_engine, u32, 2, 3, IndexWeight.single));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayByIndexCheckedFrom(&no_consume_engine, u32, 3, 2, IndexWeight.single));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    var too_many_into: [3]usize = undefined;
    var too_many_keys: [3]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByIndexIntoCheckedFrom(&no_consume_engine, u32, 2, &too_many_into, &too_many_keys, IndexWeight.single));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByIndexCheckedFrom(std.testing.allocator, &no_consume_engine, u32, 8, 2, IndexWeight.sparse));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayByIndexCheckedFrom(&no_consume_engine, u32, 2, 8, IndexWeight.sparse));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByIndexIntoCheckedFrom(&no_consume_engine, u32, 8, single_into[0..2], single_keys[0..2], IndexWeight.sparse));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByIndexIntoFrom(&no_consume_engine, u32, @as(usize, std.math.maxInt(u32)) + 1, single_u32_into[0..1], single_u32_keys[0..1], IndexWeight.single));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32ByIndexFrom(&no_consume_engine, u32, 1, @as(usize, std.math.maxInt(u32)) + 1, IndexWeight.single));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesByIndexFrom(std.testing.allocator, &no_consume_engine, f64, 8, 2, IndexWeight.invalid));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayByIndexFrom(&no_consume_engine, f64, 2, 8, IndexWeight.invalid));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesByIndexIntoFrom(&no_consume_engine, f64, 8, single_into[0..2], single_keys[0..2], IndexWeight.invalid));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
    try std.testing.expectError(error.LengthMismatch, sampleWeightedIndicesByIndexIntoFrom(&no_consume_engine, u32, 8, single_into[0..2], single_keys[0..1], IndexWeight.single));
    try std.testing.expectEqual(no_consume_control.next(), no_consume_engine.next());
}

test "index-weighted no-replacement samples preserve direct stream shape" {
    const alea = @import("root.zig");
    const IndexWeight = struct {
        fn weightOf(index: usize) u32 {
            return switch (index) {
                0 => 1,
                2 => 4,
                5 => 2,
                6 => 8,
                else => 0,
            };
        }
    };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_f126);
        var direct_engine = Engine.init(0x5150_f126);
        const rng = Rng.init(&facade_engine);

        const facade_indices = try sampleWeightedIndicesByIndex(std.testing.allocator, rng, u32, 8, 3, IndexWeight.weightOf);
        defer std.testing.allocator.free(facade_indices);
        const direct_indices = try sampleWeightedIndicesByIndexFrom(std.testing.allocator, &direct_engine, u32, 8, 3, IndexWeight.weightOf);
        defer std.testing.allocator.free(direct_indices);
        try std.testing.expectEqualSlices(usize, direct_indices, facade_indices);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_indices_u32 = try sampleWeightedIndicesU32ByIndex(std.testing.allocator, rng, u32, 8, 3, IndexWeight.weightOf);
        defer std.testing.allocator.free(facade_indices_u32);
        const direct_indices_u32 = try sampleWeightedIndicesU32ByIndexFrom(std.testing.allocator, &direct_engine, u32, 8, 3, IndexWeight.weightOf);
        defer std.testing.allocator.free(direct_indices_u32);
        try std.testing.expectEqualSlices(u32, direct_indices_u32, facade_indices_u32);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_vec = try sampleWeightedIndexVecByIndex(std.testing.allocator, rng, u32, 8, 3, IndexWeight.weightOf);
        defer facade_vec.deinit(std.testing.allocator);
        const direct_vec = try sampleWeightedIndexVecByIndexFrom(std.testing.allocator, &direct_engine, u32, 8, 3, IndexWeight.weightOf);
        defer direct_vec.deinit(std.testing.allocator);
        try std.testing.expectEqual(facade_vec.len(), direct_vec.len());
        var index: usize = 0;
        while (index < facade_vec.len()) : (index += 1) {
            try std.testing.expectEqual(direct_vec.at(index), facade_vec.at(index));
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_out: [3]usize = undefined;
        var direct_out: [3]usize = undefined;
        var facade_keys: [3]f64 = undefined;
        var direct_keys: [3]f64 = undefined;
        try std.testing.expectEqual(
            try sampleWeightedIndicesByIndexInto(rng, u32, 8, &facade_out, &facade_keys, IndexWeight.weightOf),
            try sampleWeightedIndicesByIndexIntoFrom(&direct_engine, u32, 8, &direct_out, &direct_keys, IndexWeight.weightOf),
        );
        try std.testing.expectEqualSlices(usize, &direct_out, &facade_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_out_u32: [3]u32 = undefined;
        var direct_out_u32: [3]u32 = undefined;
        var facade_u32_keys: [3]f64 = undefined;
        var direct_u32_keys: [3]f64 = undefined;
        try std.testing.expectEqual(
            try sampleWeightedIndicesU32ByIndexInto(rng, u32, 8, &facade_out_u32, &facade_u32_keys, IndexWeight.weightOf),
            try sampleWeightedIndicesU32ByIndexIntoFrom(&direct_engine, u32, 8, &direct_out_u32, &direct_u32_keys, IndexWeight.weightOf),
        );
        try std.testing.expectEqualSlices(u32, &direct_out_u32, &facade_out_u32);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
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

        const indices_u32 = try sampleWeightedIndicesU32(std.testing.allocator, rng, f64, &weights, 4);
        defer std.testing.allocator.free(indices_u32);
        const direct_indices_u32 = try sampleWeightedIndicesU32From(std.testing.allocator, &direct, f64, &weights, 4);
        defer std.testing.allocator.free(direct_indices_u32);
        try std.testing.expectEqualSlices(u32, indices_u32, direct_indices_u32);
        try std.testing.expectEqual(unchecked.next(), direct.next());

        const sample = try sampleWeighted(std.testing.allocator, rng, u8, f64, &items, &weights, 2);
        defer std.testing.allocator.free(sample);
        const direct_sample = try sampleWeightedFrom(std.testing.allocator, &direct, u8, f64, &items, &weights, 2);
        defer std.testing.allocator.free(direct_sample);
        try std.testing.expectEqualSlices(u8, sample, direct_sample);
        try std.testing.expectEqual(unchecked.next(), direct.next());
    }
}

test "accessor weighted no-replacement samples allocate values and pointers" {
    const alea = @import("root.zig");
    const Entry = struct {
        value: u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .value = 10, .weight = 0 },
        .{ .value = 20, .weight = 1 },
        .{ .value = 30, .weight = 5 },
        .{ .value = 40, .weight = 0 },
        .{ .value = 50, .weight = 9 },
    };

    var value_engine = alea.ScalarPrng.init(0x5150_c721);
    const values = try sampleWeightedByFrom(std.testing.allocator, &value_engine, Entry, u32, &entries, 5, Entry.weightOf);
    defer std.testing.allocator.free(values);
    try std.testing.expectEqual(@as(usize, 3), values.len);
    for (values) |item| try std.testing.expect(item.weight > 0);

    var checked_value_engine = alea.ScalarPrng.init(0x5150_c722);
    const checked_values = try sampleWeightedByCheckedFrom(std.testing.allocator, &checked_value_engine, Entry, u32, &entries, 3, Entry.weightOf);
    defer std.testing.allocator.free(checked_values);
    try std.testing.expectEqual(@as(usize, 3), checked_values.len);
    for (checked_values) |item| try std.testing.expect(item.weight > 0);

    var ptr_engine = alea.ScalarPrng.init(0x5150_c723);
    const ptrs = try sampleWeightedPtrsByFrom(std.testing.allocator, &ptr_engine, Entry, u32, &entries, 5, Entry.weightOf);
    defer std.testing.allocator.free(ptrs);
    try std.testing.expectEqual(@as(usize, 3), ptrs.len);
    for (ptrs, 0..) |ptr, i| {
        try std.testing.expect(ptr.weight > 0);
        for (ptrs[0..i]) |seen| try std.testing.expect(ptr != seen);
    }

    var checked_ptr_engine = alea.ScalarPrng.init(0x5150_c724);
    const checked_ptrs = try sampleWeightedPtrsByCheckedFrom(std.testing.allocator, &checked_ptr_engine, Entry, u32, &entries, 3, Entry.weightOf);
    defer std.testing.allocator.free(checked_ptrs);
    try std.testing.expectEqual(@as(usize, 3), checked_ptrs.len);
    for (checked_ptrs, 0..) |ptr, i| {
        try std.testing.expect(ptr.weight > 0);
        for (checked_ptrs[0..i]) |seen| try std.testing.expect(ptr != seen);
    }

    var mutable_entries = entries;
    var mut_engine = alea.ScalarPrng.init(0x5150_c725);
    const mut_ptrs = try sampleWeightedMutPtrsByCheckedFrom(std.testing.allocator, &mut_engine, Entry, u32, &mutable_entries, 3, Entry.weightOf);
    defer std.testing.allocator.free(mut_ptrs);
    try std.testing.expectEqual(@as(usize, 3), mut_ptrs.len);
    for (mut_ptrs, 0..) |ptr, i| {
        try std.testing.expect(ptr.weight > 0);
        for (mut_ptrs[0..i]) |seen| try std.testing.expect(ptr != seen);
        ptr.value += 1;
    }
    var changed_positive: usize = 0;
    for (mutable_entries, entries) |after, before| {
        if (before.weight > 0) {
            try std.testing.expectEqual(before.value + 1, after.value);
            changed_positive += 1;
        } else {
            try std.testing.expectEqual(before.value, after.value);
        }
    }
    try std.testing.expectEqual(@as(usize, 3), changed_positive);

    const SingleEntry = struct {
        value: u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }
    };
    const single_entries = [_]SingleEntry{
        .{ .value = 1, .weight = 0 },
        .{ .value = 2, .weight = 7 },
        .{ .value = 3, .weight = 0 },
    };
    var single_engine = alea.ScalarPrng.init(0x5150_c726);
    var single_control = alea.ScalarPrng.init(0x5150_c726);
    const single_values = try sampleWeightedByFrom(std.testing.allocator, &single_engine, SingleEntry, u32, &single_entries, 3, SingleEntry.weightOf);
    defer std.testing.allocator.free(single_values);
    try std.testing.expectEqual(@as(usize, 1), single_values.len);
    try std.testing.expectEqual(@as(u8, 2), single_values[0].value);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    const single_ptrs = try sampleWeightedPtrsByFrom(std.testing.allocator, &single_engine, SingleEntry, u32, &single_entries, 3, SingleEntry.weightOf);
    defer std.testing.allocator.free(single_ptrs);
    try std.testing.expectEqual(@as(usize, 1), single_ptrs.len);
    try std.testing.expectEqual(&single_entries[1], single_ptrs[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var single_mutable = single_entries;
    const single_mut_ptrs = try sampleWeightedMutPtrsByFrom(std.testing.allocator, &single_engine, SingleEntry, u32, &single_mutable, 3, SingleEntry.weightOf);
    defer std.testing.allocator.free(single_mut_ptrs);
    try std.testing.expectEqual(@as(usize, 1), single_mut_ptrs.len);
    try std.testing.expectEqual(&single_mutable[1], single_mut_ptrs[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    const BadEntry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const bad_entries = [_]BadEntry{.{ .value = 1, .weight = std.math.nan(f64) }};
    var empty_engine = alea.ScalarPrng.init(0x5150_c727);
    var empty_control = alea.ScalarPrng.init(0x5150_c727);
    const empty = try sampleWeightedByFrom(std.testing.allocator, &empty_engine, BadEntry, f64, &bad_entries, 0, BadEntry.weightOf);
    defer std.testing.allocator.free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "accessor weighted no-replacement samples preserve stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const Entry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .value = 10, .weight = 1 },
        .{ .value = 20, .weight = 2 },
        .{ .value = 30, .weight = 6 },
        .{ .value = 40, .weight = 3 },
    };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c728);
        var direct_engine = Engine.init(0x5150_c728);
        const rng = Rng.init(&facade_engine);

        const facade = try sampleWeightedBy(std.testing.allocator, rng, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(facade);
        const direct = try sampleWeightedByFrom(std.testing.allocator, &direct_engine, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(direct);
        for (facade, direct) |facade_item, direct_item| try std.testing.expectEqual(facade_item.value, direct_item.value);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade = try sampleWeightedByChecked(std.testing.allocator, rng, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(checked_facade);
        const checked_direct = try sampleWeightedByCheckedFrom(std.testing.allocator, &direct_engine, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(checked_direct);
        for (checked_facade, checked_direct) |facade_item, direct_item| try std.testing.expectEqual(facade_item.value, direct_item.value);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_ptrs = try sampleWeightedPtrsBy(std.testing.allocator, rng, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(facade_ptrs);
        const direct_ptrs = try sampleWeightedPtrsByFrom(std.testing.allocator, &direct_engine, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(direct_ptrs);
        for (facade_ptrs, direct_ptrs) |facade_ptr, direct_ptr| {
            try std.testing.expectEqual(@intFromPtr(facade_ptr) - @intFromPtr(&entries[0]), @intFromPtr(direct_ptr) - @intFromPtr(&entries[0]));
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade_ptrs = try sampleWeightedPtrsByChecked(std.testing.allocator, rng, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(checked_facade_ptrs);
        const checked_direct_ptrs = try sampleWeightedPtrsByCheckedFrom(std.testing.allocator, &direct_engine, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(checked_direct_ptrs);
        for (checked_facade_ptrs, checked_direct_ptrs) |facade_ptr, direct_ptr| {
            try std.testing.expectEqual(@intFromPtr(facade_ptr) - @intFromPtr(&entries[0]), @intFromPtr(direct_ptr) - @intFromPtr(&entries[0]));
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_mutable = entries;
        var direct_mutable = entries;
        const facade_mut_ptrs = try sampleWeightedMutPtrsBy(std.testing.allocator, rng, Entry, f64, &facade_mutable, 3, Entry.weightOf);
        defer std.testing.allocator.free(facade_mut_ptrs);
        const direct_mut_ptrs = try sampleWeightedMutPtrsByFrom(std.testing.allocator, &direct_engine, Entry, f64, &direct_mutable, 3, Entry.weightOf);
        defer std.testing.allocator.free(direct_mut_ptrs);
        for (facade_mut_ptrs, direct_mut_ptrs) |facade_ptr, direct_ptr| {
            try std.testing.expectEqual(@intFromPtr(facade_ptr) - @intFromPtr(&facade_mutable[0]), @intFromPtr(direct_ptr) - @intFromPtr(&direct_mutable[0]));
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_facade_mutable = entries;
        var checked_direct_mutable = entries;
        const checked_facade_mut_ptrs = try sampleWeightedMutPtrsByChecked(std.testing.allocator, rng, Entry, f64, &checked_facade_mutable, 3, Entry.weightOf);
        defer std.testing.allocator.free(checked_facade_mut_ptrs);
        const checked_direct_mut_ptrs = try sampleWeightedMutPtrsByCheckedFrom(std.testing.allocator, &direct_engine, Entry, f64, &checked_direct_mutable, 3, Entry.weightOf);
        defer std.testing.allocator.free(checked_direct_mut_ptrs);
        for (checked_facade_mut_ptrs, checked_direct_mut_ptrs) |facade_ptr, direct_ptr| {
            try std.testing.expectEqual(@intFromPtr(facade_ptr) - @intFromPtr(&checked_facade_mutable[0]), @intFromPtr(direct_ptr) - @intFromPtr(&checked_direct_mutable[0]));
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    const BadEntry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const empty_entries = [_]BadEntry{};
    const zero_entries = [_]BadEntry{
        .{ .value = 1, .weight = 0 },
        .{ .value = 2, .weight = 0 },
    };
    const bad_entries = [_]BadEntry{
        .{ .value = 1, .weight = 1 },
        .{ .value = 2, .weight = std.math.inf(f64) },
    };

    var invalid_engine = alea.ScalarPrng.init(0x5150_c729);
    var invalid_control = alea.ScalarPrng.init(0x5150_c729);
    try std.testing.expectError(error.EmptyInput, sampleWeightedByFrom(std.testing.allocator, &invalid_engine, BadEntry, f64, &empty_entries, 1, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedByCheckedFrom(std.testing.allocator, &invalid_engine, Entry, f64, &entries, 5, Entry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedByCheckedFrom(std.testing.allocator, &invalid_engine, BadEntry, f64, &zero_entries, 1, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedByFrom(std.testing.allocator, &invalid_engine, BadEntry, f64, &bad_entries, 1, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrsByCheckedFrom(std.testing.allocator, &invalid_engine, BadEntry, f64, &bad_entries, 1, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    var bad_mutable = bad_entries;
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrsByCheckedFrom(std.testing.allocator, &invalid_engine, BadEntry, f64, &bad_mutable, 1, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var out_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedByFrom(out_alloc.allocator(), &invalid_engine, Entry, f64, &entries, 3, Entry.weightOf));
    try std.testing.expect(out_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var indices_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedByFrom(indices_alloc.allocator(), &invalid_engine, Entry, f64, &entries, 3, Entry.weightOf));
    try std.testing.expect(indices_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "accessor weighted index samples allocate usize u32 and IndexVec results" {
    const alea = @import("root.zig");
    const Entry = struct {
        value: u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .value = 10, .weight = 0 },
        .{ .value = 20, .weight = 1 },
        .{ .value = 30, .weight = 5 },
        .{ .value = 40, .weight = 0 },
        .{ .value = 50, .weight = 9 },
    };

    var indices_engine = alea.ScalarPrng.init(0x5150_c741);
    const indices = try sampleWeightedIndicesByFrom(std.testing.allocator, &indices_engine, Entry, u32, &entries, 5, Entry.weightOf);
    defer std.testing.allocator.free(indices);
    try std.testing.expectEqual(@as(usize, 3), indices.len);
    for (indices) |index| {
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expect(entries[index].weight > 0);
    }

    var checked_indices_engine = alea.ScalarPrng.init(0x5150_c742);
    const checked_indices = try sampleWeightedIndicesByCheckedFrom(std.testing.allocator, &checked_indices_engine, Entry, u32, &entries, 3, Entry.weightOf);
    defer std.testing.allocator.free(checked_indices);
    try std.testing.expectEqual(@as(usize, 3), checked_indices.len);
    for (checked_indices) |index| try std.testing.expect(entries[index].weight > 0);

    var u32_engine = alea.ScalarPrng.init(0x5150_c743);
    const indices_u32 = try sampleWeightedIndicesU32ByFrom(std.testing.allocator, &u32_engine, Entry, u32, &entries, 5, Entry.weightOf);
    defer std.testing.allocator.free(indices_u32);
    try std.testing.expectEqual(@as(usize, 3), indices_u32.len);
    for (indices_u32) |index| try std.testing.expect(entries[index].weight > 0);

    var checked_u32_engine = alea.ScalarPrng.init(0x5150_c744);
    const checked_u32 = try sampleWeightedIndicesU32ByCheckedFrom(std.testing.allocator, &checked_u32_engine, Entry, u32, &entries, 3, Entry.weightOf);
    defer std.testing.allocator.free(checked_u32);
    try std.testing.expectEqual(@as(usize, 3), checked_u32.len);
    for (checked_u32) |index| try std.testing.expect(entries[index].weight > 0);

    var index_vec_engine = alea.ScalarPrng.init(0x5150_c745);
    const index_vec = try sampleWeightedIndexVecByFrom(std.testing.allocator, &index_vec_engine, Entry, u32, &entries, 5, Entry.weightOf);
    defer index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 3), index_vec.len());
    var i: usize = 0;
    while (i < index_vec.len()) : (i += 1) try std.testing.expect(entries[index_vec.at(i)].weight > 0);

    var checked_index_vec_engine = alea.ScalarPrng.init(0x5150_c746);
    const checked_index_vec = try sampleWeightedIndexVecByCheckedFrom(std.testing.allocator, &checked_index_vec_engine, Entry, u32, &entries, 3, Entry.weightOf);
    defer checked_index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 3), checked_index_vec.len());
    i = 0;
    while (i < checked_index_vec.len()) : (i += 1) try std.testing.expect(entries[checked_index_vec.at(i)].weight > 0);

    const SingleEntry = struct {
        value: u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }
    };
    const single_entries = [_]SingleEntry{
        .{ .value = 1, .weight = 0 },
        .{ .value = 2, .weight = 7 },
        .{ .value = 3, .weight = 0 },
    };
    var single_engine = alea.ScalarPrng.init(0x5150_c747);
    var single_control = alea.ScalarPrng.init(0x5150_c747);
    const single_indices = try sampleWeightedIndicesByFrom(std.testing.allocator, &single_engine, SingleEntry, u32, &single_entries, 3, SingleEntry.weightOf);
    defer std.testing.allocator.free(single_indices);
    try std.testing.expectEqualSlices(usize, &.{1}, single_indices);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    const single_u32 = try sampleWeightedIndicesU32ByFrom(std.testing.allocator, &single_engine, SingleEntry, u32, &single_entries, 3, SingleEntry.weightOf);
    defer std.testing.allocator.free(single_u32);
    try std.testing.expectEqualSlices(u32, &.{1}, single_u32);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    const single_index_vec = try sampleWeightedIndexVecByFrom(std.testing.allocator, &single_engine, SingleEntry, u32, &single_entries, 3, SingleEntry.weightOf);
    defer single_index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 1), single_index_vec.len());
    try std.testing.expectEqual(@as(usize, 1), single_index_vec.at(0));
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    const EmptyEntry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    var empty_engine = alea.ScalarPrng.init(0x5150_c748);
    var empty_control = alea.ScalarPrng.init(0x5150_c748);
    const empty_indices = try sampleWeightedIndicesByFrom(std.testing.allocator, &empty_engine, EmptyEntry, f64, &.{.{ .value = 1, .weight = std.math.nan(f64) }}, 0, EmptyEntry.weightOf);
    defer std.testing.allocator.free(empty_indices);
    try std.testing.expectEqual(@as(usize, 0), empty_indices.len);
    const empty_u32 = try sampleWeightedIndicesU32ByFrom(std.testing.allocator, &empty_engine, EmptyEntry, f64, &.{.{ .value = 1, .weight = std.math.nan(f64) }}, 0, EmptyEntry.weightOf);
    defer std.testing.allocator.free(empty_u32);
    try std.testing.expectEqual(@as(usize, 0), empty_u32.len);
    const empty_vec = try sampleWeightedIndexVecByFrom(std.testing.allocator, &empty_engine, EmptyEntry, f64, &.{.{ .value = 1, .weight = std.math.nan(f64) }}, 0, EmptyEntry.weightOf);
    defer empty_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 0), empty_vec.len());
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "accessor weighted index samples preserve stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const Entry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .value = 10, .weight = 1 },
        .{ .value = 20, .weight = 2 },
        .{ .value = 30, .weight = 6 },
        .{ .value = 40, .weight = 3 },
    };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c749);
        var direct_engine = Engine.init(0x5150_c749);
        const rng = Rng.init(&facade_engine);

        const facade_indices = try sampleWeightedIndicesBy(std.testing.allocator, rng, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(facade_indices);
        const direct_indices = try sampleWeightedIndicesByFrom(std.testing.allocator, &direct_engine, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(direct_indices);
        try std.testing.expectEqualSlices(usize, facade_indices, direct_indices);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade_indices = try sampleWeightedIndicesByChecked(std.testing.allocator, rng, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(checked_facade_indices);
        const checked_direct_indices = try sampleWeightedIndicesByCheckedFrom(std.testing.allocator, &direct_engine, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(checked_direct_indices);
        try std.testing.expectEqualSlices(usize, checked_facade_indices, checked_direct_indices);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_u32 = try sampleWeightedIndicesU32By(std.testing.allocator, rng, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(facade_u32);
        const direct_u32 = try sampleWeightedIndicesU32ByFrom(std.testing.allocator, &direct_engine, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(direct_u32);
        try std.testing.expectEqualSlices(u32, facade_u32, direct_u32);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade_u32 = try sampleWeightedIndicesU32ByChecked(std.testing.allocator, rng, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(checked_facade_u32);
        const checked_direct_u32 = try sampleWeightedIndicesU32ByCheckedFrom(std.testing.allocator, &direct_engine, Entry, f64, &entries, 3, Entry.weightOf);
        defer std.testing.allocator.free(checked_direct_u32);
        try std.testing.expectEqualSlices(u32, checked_facade_u32, checked_direct_u32);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_vec = try sampleWeightedIndexVecBy(std.testing.allocator, rng, Entry, f64, &entries, 3, Entry.weightOf);
        defer facade_vec.deinit(std.testing.allocator);
        const direct_vec = try sampleWeightedIndexVecByFrom(std.testing.allocator, &direct_engine, Entry, f64, &entries, 3, Entry.weightOf);
        defer direct_vec.deinit(std.testing.allocator);
        try std.testing.expectEqual(facade_vec.len(), direct_vec.len());
        var index: usize = 0;
        while (index < facade_vec.len()) : (index += 1) try std.testing.expectEqual(facade_vec.at(index), direct_vec.at(index));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade_vec = try sampleWeightedIndexVecByChecked(std.testing.allocator, rng, Entry, f64, &entries, 3, Entry.weightOf);
        defer checked_facade_vec.deinit(std.testing.allocator);
        const checked_direct_vec = try sampleWeightedIndexVecByCheckedFrom(std.testing.allocator, &direct_engine, Entry, f64, &entries, 3, Entry.weightOf);
        defer checked_direct_vec.deinit(std.testing.allocator);
        try std.testing.expectEqual(checked_facade_vec.len(), checked_direct_vec.len());
        index = 0;
        while (index < checked_facade_vec.len()) : (index += 1) try std.testing.expectEqual(checked_facade_vec.at(index), checked_direct_vec.at(index));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    const BadEntry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const empty_entries = [_]BadEntry{};
    const zero_entries = [_]BadEntry{
        .{ .value = 1, .weight = 0 },
        .{ .value = 2, .weight = 0 },
    };
    const bad_entries = [_]BadEntry{
        .{ .value = 1, .weight = 1 },
        .{ .value = 2, .weight = std.math.nan(f64) },
    };

    var invalid_engine = alea.ScalarPrng.init(0x5150_c74a);
    var invalid_control = alea.ScalarPrng.init(0x5150_c74a);
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesByFrom(std.testing.allocator, &invalid_engine, BadEntry, f64, &empty_entries, 1, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByCheckedFrom(std.testing.allocator, &invalid_engine, Entry, f64, &entries, 5, Entry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByCheckedFrom(std.testing.allocator, &invalid_engine, BadEntry, f64, &zero_entries, 1, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesByFrom(std.testing.allocator, &invalid_engine, BadEntry, f64, &bad_entries, 1, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesU32ByCheckedFrom(std.testing.allocator, &invalid_engine, BadEntry, f64, &bad_entries, 1, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexVecByCheckedFrom(std.testing.allocator, &invalid_engine, BadEntry, f64, &bad_entries, 1, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var indices_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedIndicesByFrom(indices_alloc.allocator(), &invalid_engine, Entry, f64, &entries, 3, Entry.weightOf));
    try std.testing.expect(indices_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedIndicesU32ByFrom(u32_alloc.allocator(), &invalid_engine, Entry, f64, &entries, 3, Entry.weightOf));
    try std.testing.expect(u32_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var vec_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedIndexVecByFrom(vec_alloc.allocator(), &invalid_engine, Entry, f64, &entries, 3, Entry.weightOf));
    try std.testing.expect(vec_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "accessor weighted caller-owned buffers fill values indexes and pointers" {
    const alea = @import("root.zig");
    const Entry = struct {
        value: u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .value = 10, .weight = 0 },
        .{ .value = 20, .weight = 1 },
        .{ .value = 30, .weight = 5 },
        .{ .value = 40, .weight = 0 },
        .{ .value = 50, .weight = 9 },
    };

    var index_engine = alea.ScalarPrng.init(0x5150_c731);
    var indexes: [5]usize = undefined;
    var index_keys: [5]f64 = undefined;
    const index_count = try sampleWeightedIndicesByIntoFrom(&index_engine, Entry, u32, &entries, &indexes, &index_keys, Entry.weightOf);
    try std.testing.expectEqual(@as(usize, 3), index_count);
    for (indexes[0..index_count]) |index| {
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expect(entries[index].weight > 0);
    }

    var checked_index_engine = alea.ScalarPrng.init(0x5150_c732);
    var checked_indexes: [3]usize = undefined;
    var checked_index_keys: [3]f64 = undefined;
    try sampleWeightedIndicesByIntoCheckedFrom(&checked_index_engine, Entry, u32, &entries, &checked_indexes, &checked_index_keys, Entry.weightOf);
    for (checked_indexes[0..]) |index| {
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expect(entries[index].weight > 0);
    }

    var value_engine = alea.ScalarPrng.init(0x5150_c733);
    var values: [5]Entry = undefined;
    var value_indexes: [5]usize = undefined;
    var value_keys: [5]f64 = undefined;
    const value_count = try sampleWeightedByIntoFrom(&value_engine, Entry, u32, &entries, &values, &value_indexes, &value_keys, Entry.weightOf);
    try std.testing.expectEqual(@as(usize, 3), value_count);
    for (values[0..value_count]) |item| try std.testing.expect(item.weight > 0);

    var checked_value_engine = alea.ScalarPrng.init(0x5150_c734);
    var checked_values: [3]Entry = undefined;
    var checked_value_indexes: [3]usize = undefined;
    var checked_value_keys: [3]f64 = undefined;
    try sampleWeightedByIntoCheckedFrom(&checked_value_engine, Entry, u32, &entries, &checked_values, &checked_value_indexes, &checked_value_keys, Entry.weightOf);
    for (checked_values[0..]) |item| try std.testing.expect(item.weight > 0);

    var ptr_engine = alea.ScalarPrng.init(0x5150_c735);
    var ptrs: [5]*const Entry = undefined;
    var ptr_indexes: [5]usize = undefined;
    var ptr_keys: [5]f64 = undefined;
    const ptr_count = try sampleWeightedPtrsByIntoFrom(&ptr_engine, Entry, u32, &entries, &ptrs, &ptr_indexes, &ptr_keys, Entry.weightOf);
    try std.testing.expectEqual(@as(usize, 3), ptr_count);
    for (ptr_indexes[0..ptr_count], ptrs[0..ptr_count]) |index, ptr| {
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expectEqual(&entries[index], ptr);
    }

    var checked_ptr_engine = alea.ScalarPrng.init(0x5150_c736);
    var checked_ptrs: [3]*const Entry = undefined;
    var checked_ptr_indexes: [3]usize = undefined;
    var checked_ptr_keys: [3]f64 = undefined;
    try sampleWeightedPtrsByIntoCheckedFrom(&checked_ptr_engine, Entry, u32, &entries, &checked_ptrs, &checked_ptr_indexes, &checked_ptr_keys, Entry.weightOf);
    for (checked_ptr_indexes[0..], checked_ptrs[0..]) |index, ptr| {
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expectEqual(&entries[index], ptr);
    }

    var mutable_entries = entries;
    var mut_engine = alea.ScalarPrng.init(0x5150_c737);
    var mut_ptrs: [3]*Entry = undefined;
    var mut_indexes: [3]usize = undefined;
    var mut_keys: [3]f64 = undefined;
    try sampleWeightedMutPtrsByIntoCheckedFrom(&mut_engine, Entry, u32, &mutable_entries, &mut_ptrs, &mut_indexes, &mut_keys, Entry.weightOf);
    for (mut_indexes[0..], mut_ptrs[0..]) |index, ptr| {
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expectEqual(&mutable_entries[index], ptr);
        ptr.value += 1;
    }
    for (mutable_entries, entries) |after, before| {
        if (before.weight > 0) {
            try std.testing.expectEqual(before.value + 1, after.value);
        } else {
            try std.testing.expectEqual(before.value, after.value);
        }
    }

    const SingleEntry = struct {
        value: u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }
    };
    const single_entries = [_]SingleEntry{
        .{ .value = 1, .weight = 0 },
        .{ .value = 2, .weight = 7 },
        .{ .value = 3, .weight = 0 },
    };
    var single_engine = alea.ScalarPrng.init(0x5150_c738);
    var single_control = alea.ScalarPrng.init(0x5150_c738);
    var single_out: [3]SingleEntry = undefined;
    var single_indices: [3]usize = undefined;
    var single_keys: [3]f64 = undefined;
    const single_count = try sampleWeightedByIntoFrom(&single_engine, SingleEntry, u32, &single_entries, &single_out, &single_indices, &single_keys, SingleEntry.weightOf);
    try std.testing.expectEqual(@as(usize, 1), single_count);
    try std.testing.expectEqual(@as(usize, 1), single_indices[0]);
    try std.testing.expectEqual(@as(u8, 2), single_out[0].value);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_c739);
    var empty_control = alea.ScalarPrng.init(0x5150_c739);
    const EmptyEntry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    var empty_values: [0]EmptyEntry = .{};
    var empty_indexes: [0]usize = .{};
    var empty_keys: [0]f64 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedByIntoFrom(&empty_engine, EmptyEntry, f64, &.{.{ .value = 1, .weight = std.math.nan(f64) }}, &empty_values, &empty_indexes, &empty_keys, EmptyEntry.weightOf));
    try sampleWeightedByIntoCheckedFrom(&empty_engine, EmptyEntry, f64, &.{.{ .value = 1, .weight = std.math.nan(f64) }}, &empty_values, &empty_indexes, &empty_keys, EmptyEntry.weightOf);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "accessor weighted caller-owned buffers preserve stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const Entry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .value = 10, .weight = 1 },
        .{ .value = 20, .weight = 2 },
        .{ .value = 30, .weight = 6 },
        .{ .value = 40, .weight = 3 },
    };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c73a);
        var direct_engine = Engine.init(0x5150_c73a);
        const rng = Rng.init(&facade_engine);

        var facade_indexes: [3]usize = undefined;
        var direct_indexes: [3]usize = undefined;
        var facade_index_keys: [3]f64 = undefined;
        var direct_index_keys: [3]f64 = undefined;
        try std.testing.expectEqual(try sampleWeightedIndicesByInto(rng, Entry, f64, &entries, &facade_indexes, &facade_index_keys, Entry.weightOf), try sampleWeightedIndicesByIntoFrom(&direct_engine, Entry, f64, &entries, &direct_indexes, &direct_index_keys, Entry.weightOf));
        try std.testing.expectEqualSlices(usize, &facade_indexes, &direct_indexes);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_facade_indexes: [3]usize = undefined;
        var checked_direct_indexes: [3]usize = undefined;
        var checked_facade_index_keys: [3]f64 = undefined;
        var checked_direct_index_keys: [3]f64 = undefined;
        try sampleWeightedIndicesByIntoChecked(rng, Entry, f64, &entries, &checked_facade_indexes, &checked_facade_index_keys, Entry.weightOf);
        try sampleWeightedIndicesByIntoCheckedFrom(&direct_engine, Entry, f64, &entries, &checked_direct_indexes, &checked_direct_index_keys, Entry.weightOf);
        try std.testing.expectEqualSlices(usize, &checked_facade_indexes, &checked_direct_indexes);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_values: [3]Entry = undefined;
        var direct_values: [3]Entry = undefined;
        var facade_value_indexes: [3]usize = undefined;
        var direct_value_indexes: [3]usize = undefined;
        var facade_value_keys: [3]f64 = undefined;
        var direct_value_keys: [3]f64 = undefined;
        try std.testing.expectEqual(try sampleWeightedByInto(rng, Entry, f64, &entries, &facade_values, &facade_value_indexes, &facade_value_keys, Entry.weightOf), try sampleWeightedByIntoFrom(&direct_engine, Entry, f64, &entries, &direct_values, &direct_value_indexes, &direct_value_keys, Entry.weightOf));
        for (facade_values, direct_values) |facade_item, direct_item| try std.testing.expectEqual(facade_item.value, direct_item.value);
        try std.testing.expectEqualSlices(usize, &facade_value_indexes, &direct_value_indexes);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_facade_values: [3]Entry = undefined;
        var checked_direct_values: [3]Entry = undefined;
        var checked_facade_value_indexes: [3]usize = undefined;
        var checked_direct_value_indexes: [3]usize = undefined;
        var checked_facade_value_keys: [3]f64 = undefined;
        var checked_direct_value_keys: [3]f64 = undefined;
        try sampleWeightedByIntoChecked(rng, Entry, f64, &entries, &checked_facade_values, &checked_facade_value_indexes, &checked_facade_value_keys, Entry.weightOf);
        try sampleWeightedByIntoCheckedFrom(&direct_engine, Entry, f64, &entries, &checked_direct_values, &checked_direct_value_indexes, &checked_direct_value_keys, Entry.weightOf);
        for (checked_facade_values, checked_direct_values) |facade_item, direct_item| try std.testing.expectEqual(facade_item.value, direct_item.value);
        try std.testing.expectEqualSlices(usize, &checked_facade_value_indexes, &checked_direct_value_indexes);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_ptrs: [3]*const Entry = undefined;
        var direct_ptrs: [3]*const Entry = undefined;
        var facade_ptr_indexes: [3]usize = undefined;
        var direct_ptr_indexes: [3]usize = undefined;
        var facade_ptr_keys: [3]f64 = undefined;
        var direct_ptr_keys: [3]f64 = undefined;
        try std.testing.expectEqual(try sampleWeightedPtrsByInto(rng, Entry, f64, &entries, &facade_ptrs, &facade_ptr_indexes, &facade_ptr_keys, Entry.weightOf), try sampleWeightedPtrsByIntoFrom(&direct_engine, Entry, f64, &entries, &direct_ptrs, &direct_ptr_indexes, &direct_ptr_keys, Entry.weightOf));
        for (facade_ptrs, direct_ptrs) |facade_ptr, direct_ptr| {
            try std.testing.expectEqual(@intFromPtr(facade_ptr) - @intFromPtr(&entries[0]), @intFromPtr(direct_ptr) - @intFromPtr(&entries[0]));
        }
        try std.testing.expectEqualSlices(usize, &facade_ptr_indexes, &direct_ptr_indexes);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_facade_ptrs: [3]*const Entry = undefined;
        var checked_direct_ptrs: [3]*const Entry = undefined;
        var checked_facade_ptr_indexes: [3]usize = undefined;
        var checked_direct_ptr_indexes: [3]usize = undefined;
        var checked_facade_ptr_keys: [3]f64 = undefined;
        var checked_direct_ptr_keys: [3]f64 = undefined;
        try sampleWeightedPtrsByIntoChecked(rng, Entry, f64, &entries, &checked_facade_ptrs, &checked_facade_ptr_indexes, &checked_facade_ptr_keys, Entry.weightOf);
        try sampleWeightedPtrsByIntoCheckedFrom(&direct_engine, Entry, f64, &entries, &checked_direct_ptrs, &checked_direct_ptr_indexes, &checked_direct_ptr_keys, Entry.weightOf);
        for (checked_facade_ptrs, checked_direct_ptrs) |facade_ptr, direct_ptr| {
            try std.testing.expectEqual(@intFromPtr(facade_ptr) - @intFromPtr(&entries[0]), @intFromPtr(direct_ptr) - @intFromPtr(&entries[0]));
        }
        try std.testing.expectEqualSlices(usize, &checked_facade_ptr_indexes, &checked_direct_ptr_indexes);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_mutable = entries;
        var direct_mutable = entries;
        var facade_mut_ptrs: [3]*Entry = undefined;
        var direct_mut_ptrs: [3]*Entry = undefined;
        var facade_mut_indexes: [3]usize = undefined;
        var direct_mut_indexes: [3]usize = undefined;
        var facade_mut_keys: [3]f64 = undefined;
        var direct_mut_keys: [3]f64 = undefined;
        try std.testing.expectEqual(try sampleWeightedMutPtrsByInto(rng, Entry, f64, &facade_mutable, &facade_mut_ptrs, &facade_mut_indexes, &facade_mut_keys, Entry.weightOf), try sampleWeightedMutPtrsByIntoFrom(&direct_engine, Entry, f64, &direct_mutable, &direct_mut_ptrs, &direct_mut_indexes, &direct_mut_keys, Entry.weightOf));
        for (facade_mut_ptrs, direct_mut_ptrs) |facade_ptr, direct_ptr| {
            try std.testing.expectEqual(@intFromPtr(facade_ptr) - @intFromPtr(&facade_mutable[0]), @intFromPtr(direct_ptr) - @intFromPtr(&direct_mutable[0]));
        }
        try std.testing.expectEqualSlices(usize, &facade_mut_indexes, &direct_mut_indexes);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_facade_mutable = entries;
        var checked_direct_mutable = entries;
        var checked_facade_mut_ptrs: [3]*Entry = undefined;
        var checked_direct_mut_ptrs: [3]*Entry = undefined;
        var checked_facade_mut_indexes: [3]usize = undefined;
        var checked_direct_mut_indexes: [3]usize = undefined;
        var checked_facade_mut_keys: [3]f64 = undefined;
        var checked_direct_mut_keys: [3]f64 = undefined;
        try sampleWeightedMutPtrsByIntoChecked(rng, Entry, f64, &checked_facade_mutable, &checked_facade_mut_ptrs, &checked_facade_mut_indexes, &checked_facade_mut_keys, Entry.weightOf);
        try sampleWeightedMutPtrsByIntoCheckedFrom(&direct_engine, Entry, f64, &checked_direct_mutable, &checked_direct_mut_ptrs, &checked_direct_mut_indexes, &checked_direct_mut_keys, Entry.weightOf);
        for (checked_facade_mut_ptrs, checked_direct_mut_ptrs) |facade_ptr, direct_ptr| {
            try std.testing.expectEqual(@intFromPtr(facade_ptr) - @intFromPtr(&checked_facade_mutable[0]), @intFromPtr(direct_ptr) - @intFromPtr(&checked_direct_mutable[0]));
        }
        try std.testing.expectEqualSlices(usize, &checked_facade_mut_indexes, &checked_direct_mut_indexes);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    const BadEntry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const empty_entries = [_]BadEntry{};
    const bad_entries = [_]BadEntry{
        .{ .value = 1, .weight = 1 },
        .{ .value = 2, .weight = std.math.nan(f64) },
    };
    var invalid_engine = alea.ScalarPrng.init(0x5150_c73b);
    var invalid_control = alea.ScalarPrng.init(0x5150_c73b);
    var out: [2]Entry = undefined;
    var bad_out: [2]BadEntry = undefined;
    var out_ptrs: [2]*const BadEntry = undefined;
    var out_mut_ptrs: [2]*BadEntry = undefined;
    var indexes: [2]usize = undefined;
    var keys: [2]f64 = undefined;
    var short_indexes: [1]usize = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedByIntoFrom(&invalid_engine, Entry, f64, &entries, &out, &short_indexes, &keys, Entry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesByIntoFrom(&invalid_engine, BadEntry, f64, &empty_entries, &indexes, &keys, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedByIntoFrom(&invalid_engine, BadEntry, f64, &bad_entries, &bad_out, &indexes, &keys, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrsByIntoCheckedFrom(&invalid_engine, BadEntry, f64, &bad_entries, &out_ptrs, &indexes, &keys, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    var bad_mutable = bad_entries;
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrsByIntoCheckedFrom(&invalid_engine, BadEntry, f64, &bad_mutable, &out_mut_ptrs, &indexes, &keys, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "accessor weighted item arrays return fixed-size values and pointers" {
    const alea = @import("root.zig");
    const Entry = struct {
        value: u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .value = 10, .weight = 0 },
        .{ .value = 20, .weight = 1 },
        .{ .value = 30, .weight = 5 },
        .{ .value = 40, .weight = 0 },
        .{ .value = 50, .weight = 9 },
    };

    var value_engine = alea.ScalarPrng.init(0x5150_c761);
    const values = (try sampleWeightedArrayByFrom(&value_engine, Entry, u32, 2, &entries, Entry.weightOf)).?;
    try std.testing.expectEqual(@as(usize, 2), values.len);
    for (values) |item| try std.testing.expect(item.weight > 0);

    var checked_value_engine = alea.ScalarPrng.init(0x5150_c762);
    const checked_values = try sampleWeightedArrayByCheckedFrom(&checked_value_engine, Entry, u32, 3, &entries, Entry.weightOf);
    try std.testing.expectEqual(@as(usize, 3), checked_values.len);
    for (checked_values) |item| try std.testing.expect(item.weight > 0);

    var ptr_engine = alea.ScalarPrng.init(0x5150_c763);
    const ptrs = (try sampleWeightedPtrArrayByFrom(&ptr_engine, Entry, u32, 2, &entries, Entry.weightOf)).?;
    try std.testing.expectEqual(@as(usize, 2), ptrs.len);
    for (ptrs) |ptr| try std.testing.expect(ptr.weight > 0);

    var checked_ptr_engine = alea.ScalarPrng.init(0x5150_c764);
    const checked_ptrs = try sampleWeightedPtrArrayByCheckedFrom(&checked_ptr_engine, Entry, u32, 3, &entries, Entry.weightOf);
    try std.testing.expectEqual(@as(usize, 3), checked_ptrs.len);
    for (checked_ptrs) |ptr| try std.testing.expect(ptr.weight > 0);

    var mutable_entries = entries;
    var mut_engine = alea.ScalarPrng.init(0x5150_c765);
    const mut_ptrs = try sampleWeightedMutPtrArrayByCheckedFrom(&mut_engine, Entry, u32, 3, &mutable_entries, Entry.weightOf);
    try std.testing.expectEqual(@as(usize, 3), mut_ptrs.len);
    for (mut_ptrs) |ptr| {
        try std.testing.expect(ptr.weight > 0);
        ptr.value += 1;
    }
    for (mutable_entries, entries) |after, before| {
        if (before.weight > 0) {
            try std.testing.expectEqual(before.value + 1, after.value);
        } else {
            try std.testing.expectEqual(before.value, after.value);
        }
    }

    const SingleEntry = struct {
        value: u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }
    };
    const single_entries = [_]SingleEntry{
        .{ .value = 1, .weight = 0 },
        .{ .value = 2, .weight = 7 },
        .{ .value = 3, .weight = 0 },
    };
    var single_engine = alea.ScalarPrng.init(0x5150_c766);
    var single_control = alea.ScalarPrng.init(0x5150_c766);
    const single_value = (try sampleWeightedArrayByFrom(&single_engine, SingleEntry, u32, 1, &single_entries, SingleEntry.weightOf)).?;
    try std.testing.expectEqual(@as(u8, 2), single_value[0].value);
    try std.testing.expectEqual(single_control.next(), single_engine.next());
    const single_ptr = (try sampleWeightedPtrArrayByFrom(&single_engine, SingleEntry, u32, 1, &single_entries, SingleEntry.weightOf)).?;
    try std.testing.expectEqual(&single_entries[1], single_ptr[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    const EmptyEntry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    var empty_engine = alea.ScalarPrng.init(0x5150_c767);
    var empty_control = alea.ScalarPrng.init(0x5150_c767);
    const empty = try sampleWeightedArrayByFrom(&empty_engine, EmptyEntry, f64, 0, &.{.{ .value = 1, .weight = std.math.nan(f64) }}, EmptyEntry.weightOf);
    try std.testing.expectEqual(@as(usize, 0), empty.?.len);
    const empty_ptr = try sampleWeightedPtrArrayByFrom(&empty_engine, EmptyEntry, f64, 0, &.{.{ .value = 1, .weight = std.math.nan(f64) }}, EmptyEntry.weightOf);
    try std.testing.expectEqual(@as(usize, 0), empty_ptr.?.len);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
    try std.testing.expect((try sampleWeightedArrayByFrom(&empty_engine, Entry, u32, 4, &entries, Entry.weightOf)) == null);
    try std.testing.expect((try sampleWeightedPtrArrayByFrom(&empty_engine, Entry, u32, 4, &entries, Entry.weightOf)) == null);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedArrayByCheckedFrom(&empty_engine, Entry, u32, 4, &entries, Entry.weightOf));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrArrayByCheckedFrom(&empty_engine, Entry, u32, 4, &entries, Entry.weightOf));
}

test "accessor weighted item arrays preserve stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const Entry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .value = 10, .weight = 1 },
        .{ .value = 20, .weight = 2 },
        .{ .value = 30, .weight = 6 },
        .{ .value = 40, .weight = 3 },
    };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c768);
        var direct_engine = Engine.init(0x5150_c768);
        const rng = Rng.init(&facade_engine);

        const facade = (try sampleWeightedArrayBy(rng, Entry, f64, 2, &entries, Entry.weightOf)).?;
        const direct = (try sampleWeightedArrayByFrom(&direct_engine, Entry, f64, 2, &entries, Entry.weightOf)).?;
        for (facade, direct) |facade_item, direct_item| try std.testing.expectEqual(facade_item.value, direct_item.value);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade = try sampleWeightedArrayByChecked(rng, Entry, f64, 2, &entries, Entry.weightOf);
        const checked_direct = try sampleWeightedArrayByCheckedFrom(&direct_engine, Entry, f64, 2, &entries, Entry.weightOf);
        for (checked_facade, checked_direct) |facade_item, direct_item| try std.testing.expectEqual(facade_item.value, direct_item.value);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_ptr = (try sampleWeightedPtrArrayBy(rng, Entry, f64, 2, &entries, Entry.weightOf)).?;
        const direct_ptr = (try sampleWeightedPtrArrayByFrom(&direct_engine, Entry, f64, 2, &entries, Entry.weightOf)).?;
        for (facade_ptr, direct_ptr) |facade_item, direct_item| {
            try std.testing.expectEqual(@intFromPtr(facade_item) - @intFromPtr(&entries[0]), @intFromPtr(direct_item) - @intFromPtr(&entries[0]));
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_mutable = entries;
        var direct_mutable = entries;
        const facade_mut_ptr = (try sampleWeightedMutPtrArrayBy(rng, Entry, f64, 2, &facade_mutable, Entry.weightOf)).?;
        const direct_mut_ptr = (try sampleWeightedMutPtrArrayByFrom(&direct_engine, Entry, f64, 2, &direct_mutable, Entry.weightOf)).?;
        for (facade_mut_ptr, direct_mut_ptr) |facade_item, direct_item| {
            try std.testing.expectEqual(@intFromPtr(facade_item) - @intFromPtr(&facade_mutable[0]), @intFromPtr(direct_item) - @intFromPtr(&direct_mutable[0]));
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    const BadEntry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const bad_entries = [_]BadEntry{
        .{ .value = 1, .weight = 1 },
        .{ .value = 2, .weight = std.math.nan(f64) },
    };
    var invalid_engine = alea.ScalarPrng.init(0x5150_c769);
    var invalid_control = alea.ScalarPrng.init(0x5150_c769);
    const rng = Rng.init(&invalid_engine);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedArrayByChecked(rng, Entry, f64, 5, &entries, Entry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedArrayByCheckedFrom(&invalid_engine, BadEntry, f64, 2, &bad_entries, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrArrayByCheckedFrom(&invalid_engine, BadEntry, f64, 2, &bad_entries, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    var bad_mutable = bad_entries;
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrArrayByCheckedFrom(&invalid_engine, BadEntry, f64, 2, &bad_mutable, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
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

test "sampleWeighted pointer arrays return fixed-size weighted pointers" {
    const alea = @import("root.zig");
    const weights = [_]u32{ 0, 1, 5, 0, 9 };
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    var optional_engine = alea.ScalarPrng.init(0x5150_ba11);
    const optional = (try sampleWeightedPtrArrayFrom(&optional_engine, u8, u32, 2, &items, &weights)).?;
    try std.testing.expectEqual(@as(usize, 2), optional.len);
    for (optional) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var checked_engine = alea.ScalarPrng.init(0x5150_ba12);
    const checked = try sampleWeightedPtrArrayCheckedFrom(&checked_engine, u8, u32, 3, &items, &weights);
    try std.testing.expectEqual(@as(usize, 3), checked.len);
    for (checked) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var mutable = items;
    var mut_engine = alea.ScalarPrng.init(0x5150_ba13);
    const mut_ptrs = try sampleWeightedMutPtrArrayCheckedFrom(&mut_engine, u8, u32, 3, &mutable, &weights);
    try std.testing.expectEqual(@as(usize, 3), mut_ptrs.len);
    var expected = items;
    for (mut_ptrs) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&mutable[0]), @sizeOf(u8));
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expectEqual(&mutable[index], ptr);
        ptr.* += 1;
        expected[index] += 1;
    }
    try std.testing.expectEqualSlices(u8, &expected, &mutable);

    var single_engine = alea.ScalarPrng.init(0x5150_ba14);
    var single_control = alea.ScalarPrng.init(0x5150_ba14);
    const single = (try sampleWeightedPtrArrayFrom(&single_engine, u8, u32, 1, &items, &.{ 0, 0, 7, 0, 0 })).?;
    try std.testing.expectEqual(&items[2], single[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_ba15);
    const empty = try sampleWeightedPtrArrayFrom(&empty_engine, u8, u32, 0, &items, &weights);
    try std.testing.expectEqual(@as(usize, 0), empty.?.len);
    try std.testing.expect((try sampleWeightedPtrArrayFrom(&empty_engine, u8, u32, 4, &items, &weights)) == null);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrArrayCheckedFrom(&empty_engine, u8, u32, 4, &items, &weights));
    try std.testing.expect((try sampleWeightedMutPtrArrayFrom(&empty_engine, u8, u32, 4, &mutable, &weights)) == null);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrArrayCheckedFrom(&empty_engine, u8, u32, 4, &mutable, &weights));
}

test "sampleWeighted pointer arrays preserve facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const weights = [_]f64{ 1, 2, 6, 3 };
    const items = [_]u8{ 10, 20, 30, 40 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_ba16);
        var direct_engine = Engine.init(0x5150_ba16);
        const rng = Rng.init(&facade_engine);

        const facade = (try sampleWeightedPtrArray(rng, u8, f64, 2, &items, &weights)).?;
        const direct = (try sampleWeightedPtrArrayFrom(&direct_engine, u8, f64, 2, &items, &weights)).?;
        for (facade, direct) |ptr, direct_ptr| {
            const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            try std.testing.expectEqual(index, direct_index);
            try std.testing.expectEqual(&items[index], ptr);
            try std.testing.expectEqual(&items[direct_index], direct_ptr);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_items = items;
        var direct_items = items;
        const mut_facade = (try sampleWeightedMutPtrArray(rng, u8, f64, 2, &facade_items, &weights)).?;
        const mut_direct = (try sampleWeightedMutPtrArrayFrom(&direct_engine, u8, f64, 2, &direct_items, &weights)).?;
        for (mut_facade, mut_direct) |ptr, direct_ptr| {
            const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&facade_items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&direct_items[0]), @sizeOf(u8));
            try std.testing.expectEqual(index, direct_index);
            try std.testing.expectEqual(&facade_items[index], ptr);
            try std.testing.expectEqual(&direct_items[direct_index], direct_ptr);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade = try sampleWeightedPtrArrayChecked(rng, u8, f64, 2, &items, &weights);
        const checked_direct = try sampleWeightedPtrArrayCheckedFrom(&direct_engine, u8, f64, 2, &items, &weights);
        for (checked_facade, checked_direct) |ptr, direct_ptr| {
            const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            try std.testing.expectEqual(index, direct_index);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_mut_facade = try sampleWeightedMutPtrArrayChecked(rng, u8, f64, 2, &facade_items, &weights);
        const checked_mut_direct = try sampleWeightedMutPtrArrayCheckedFrom(&direct_engine, u8, f64, 2, &direct_items, &weights);
        for (checked_mut_facade, checked_mut_direct) |ptr, direct_ptr| {
            const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&facade_items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&direct_items[0]), @sizeOf(u8));
            try std.testing.expectEqual(index, direct_index);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_ba17);
    var invalid_control = alea.ScalarPrng.init(0x5150_ba17);
    const rng = Rng.init(&invalid_engine);
    try std.testing.expectError(error.LengthMismatch, sampleWeightedPtrArray(rng, u8, f64, 2, &items, &.{ 1.0, 2.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var mutable_items = items;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedMutPtrArray(rng, u8, f64, 2, &mutable_items, &.{ 1.0, 2.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrArrayCheckedFrom(&invalid_engine, u8, f64, 2, &items, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrArrayCheckedFrom(&invalid_engine, u8, f64, 2, &mutable_items, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "sampleWeighted pointer buffers fill caller-owned pointer outputs" {
    const alea = @import("root.zig");
    const weights = [_]u32{ 0, 1, 5, 0, 9 };
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    var optional_engine = alea.ScalarPrng.init(0x5150_bd01);
    var optional_ptrs: [5]*const u8 = undefined;
    var optional_indices: [5]usize = undefined;
    var optional_keys: [5]f64 = undefined;
    const filled = try sampleWeightedPtrsIntoFrom(&optional_engine, u8, u32, &items, &weights, &optional_ptrs, &optional_indices, &optional_keys);
    try std.testing.expectEqual(@as(usize, 3), filled);
    for (optional_indices[0..filled], optional_ptrs[0..filled]) |index, ptr| {
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var checked_engine = alea.ScalarPrng.init(0x5150_bd02);
    var checked_ptrs: [3]*const u8 = undefined;
    var checked_indices: [3]usize = undefined;
    var checked_keys: [3]f64 = undefined;
    try sampleWeightedPtrsIntoCheckedFrom(&checked_engine, u8, u32, &items, &weights, &checked_ptrs, &checked_indices, &checked_keys);
    for (checked_indices[0..], checked_ptrs[0..]) |index, ptr| {
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var mutable = items;
    var mut_engine = alea.ScalarPrng.init(0x5150_bd03);
    var mut_ptrs: [3]*u8 = undefined;
    var mut_indices: [3]usize = undefined;
    var mut_keys: [3]f64 = undefined;
    try sampleWeightedMutPtrsIntoCheckedFrom(&mut_engine, u8, u32, &mutable, &weights, &mut_ptrs, &mut_indices, &mut_keys);
    var expected = items;
    for (mut_indices[0..], mut_ptrs[0..]) |index, ptr| {
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expectEqual(&mutable[index], ptr);
        ptr.* += 1;
        expected[index] += 1;
    }
    try std.testing.expectEqualSlices(u8, &expected, &mutable);

    var single_engine = alea.ScalarPrng.init(0x5150_bd04);
    var single_control = alea.ScalarPrng.init(0x5150_bd04);
    var single_ptrs: [3]*const u8 = undefined;
    var single_indices: [3]usize = undefined;
    var single_keys: [3]f64 = undefined;
    const single_count = try sampleWeightedPtrsIntoFrom(&single_engine, u8, u32, &items, &.{ 0, 0, 7, 0, 0 }, &single_ptrs, &single_indices, &single_keys);
    try std.testing.expectEqual(@as(usize, 1), single_count);
    try std.testing.expectEqual(@as(usize, 2), single_indices[0]);
    try std.testing.expectEqual(&items[2], single_ptrs[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_bd05);
    var empty_control = alea.ScalarPrng.init(0x5150_bd05);
    var empty_ptrs: [0]*const u8 = .{};
    var empty_indices: [0]usize = .{};
    var empty_keys: [0]f64 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedPtrsIntoFrom(&empty_engine, u8, u32, &items, &weights, &empty_ptrs, &empty_indices, &empty_keys));
    try sampleWeightedPtrsIntoCheckedFrom(&empty_engine, u8, u32, &items, &weights, &empty_ptrs, &empty_indices, &empty_keys);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "sampleWeighted pointer buffers preserve facade/direct stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const weights = [_]f64{ 1, 2, 6, 3 };
    const items = [_]u8{ 10, 20, 30, 40 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_bd06);
        var direct_engine = Engine.init(0x5150_bd06);
        const rng = Rng.init(&facade_engine);

        var facade_ptrs: [3]*const u8 = undefined;
        var direct_ptrs: [3]*const u8 = undefined;
        var facade_indices: [3]usize = undefined;
        var direct_indices: [3]usize = undefined;
        var facade_keys: [3]f64 = undefined;
        var direct_keys: [3]f64 = undefined;
        try std.testing.expectEqual(try sampleWeightedPtrsInto(rng, u8, f64, &items, &weights, &facade_ptrs, &facade_indices, &facade_keys), try sampleWeightedPtrsIntoFrom(&direct_engine, u8, f64, &items, &weights, &direct_ptrs, &direct_indices, &direct_keys));
        try std.testing.expectEqualSlices(usize, &facade_indices, &direct_indices);
        for (facade_indices[0..], facade_ptrs[0..], direct_ptrs[0..]) |index, facade_ptr, direct_ptr| {
            try std.testing.expectEqual(&items[index], facade_ptr);
            try std.testing.expectEqual(&items[index], direct_ptr);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_items = items;
        var direct_items = items;
        var facade_mut_ptrs: [3]*u8 = undefined;
        var direct_mut_ptrs: [3]*u8 = undefined;
        try std.testing.expectEqual(try sampleWeightedMutPtrsInto(rng, u8, f64, &facade_items, &weights, &facade_mut_ptrs, &facade_indices, &facade_keys), try sampleWeightedMutPtrsIntoFrom(&direct_engine, u8, f64, &direct_items, &weights, &direct_mut_ptrs, &direct_indices, &direct_keys));
        try std.testing.expectEqualSlices(usize, &facade_indices, &direct_indices);
        for (facade_indices[0..], facade_mut_ptrs[0..], direct_mut_ptrs[0..]) |index, facade_ptr, direct_ptr| {
            try std.testing.expectEqual(&facade_items[index], facade_ptr);
            try std.testing.expectEqual(&direct_items[index], direct_ptr);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_bd07);
    var invalid_control = alea.ScalarPrng.init(0x5150_bd07);
    const rng = Rng.init(&invalid_engine);
    var out: [3]*const u8 = undefined;
    var indices: [3]usize = undefined;
    var keys: [3]f64 = undefined;
    var short_indices: [2]usize = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedPtrsIntoFrom(&invalid_engine, u8, f64, &items, &weights, &out, &short_indices, &keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.LengthMismatch, sampleWeightedPtrsInto(rng, u8, f64, &items, &.{ 1.0, 2.0 }, &out, &indices, &keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrsIntoCheckedFrom(&invalid_engine, u8, f64, &items, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }, &out, &indices, &keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var mutable_items = items;
    var mut_out: [3]*u8 = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedMutPtrsIntoFrom(&invalid_engine, u8, f64, &mutable_items, &weights, &mut_out, &short_indices, &keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.LengthMismatch, sampleWeightedMutPtrsInto(rng, u8, f64, &mutable_items, &.{ 1.0, 2.0 }, &mut_out, &indices, &keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrsIntoCheckedFrom(&invalid_engine, u8, f64, &mutable_items, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }, &mut_out, &indices, &keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "accessor weighted index arrays return fixed-size indexes" {
    const alea = @import("root.zig");
    const Entry = struct {
        value: u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .value = 10, .weight = 0 },
        .{ .value = 20, .weight = 1 },
        .{ .value = 30, .weight = 5 },
        .{ .value = 40, .weight = 0 },
        .{ .value = 50, .weight = 9 },
    };

    var optional_engine = alea.ScalarPrng.init(0x5150_c751);
    const optional = (try sampleWeightedIndexArrayByFrom(&optional_engine, Entry, u32, 2, &entries, Entry.weightOf)).?;
    try std.testing.expectEqual(@as(usize, 2), optional.len);
    for (optional) |index| try std.testing.expect(entries[index].weight > 0);

    var checked_engine = alea.ScalarPrng.init(0x5150_c752);
    const checked = try sampleWeightedIndexArrayByCheckedFrom(&checked_engine, Entry, u32, 3, &entries, Entry.weightOf);
    try std.testing.expectEqual(@as(usize, 3), checked.len);
    for (checked) |index| try std.testing.expect(entries[index].weight > 0);

    var optional_u32_engine = alea.ScalarPrng.init(0x5150_c753);
    const optional_u32 = (try sampleWeightedIndexArrayU32ByFrom(&optional_u32_engine, Entry, u32, 2, &entries, Entry.weightOf)).?;
    try std.testing.expectEqual(@as(usize, 2), optional_u32.len);
    for (optional_u32) |index| try std.testing.expect(entries[index].weight > 0);

    var checked_u32_engine = alea.ScalarPrng.init(0x5150_c754);
    const checked_u32 = try sampleWeightedIndexArrayU32ByCheckedFrom(&checked_u32_engine, Entry, u32, 3, &entries, Entry.weightOf);
    try std.testing.expectEqual(@as(usize, 3), checked_u32.len);
    for (checked_u32) |index| try std.testing.expect(entries[index].weight > 0);

    const SingleEntry = struct {
        value: u8,
        weight: u32,

        fn weightOf(item: *const @This()) u32 {
            return item.weight;
        }
    };
    const single_entries = [_]SingleEntry{
        .{ .value = 1, .weight = 0 },
        .{ .value = 2, .weight = 7 },
        .{ .value = 3, .weight = 0 },
    };
    var single_engine = alea.ScalarPrng.init(0x5150_c755);
    var single_control = alea.ScalarPrng.init(0x5150_c755);
    const single = (try sampleWeightedIndexArrayByFrom(&single_engine, SingleEntry, u32, 1, &single_entries, SingleEntry.weightOf)).?;
    try std.testing.expectEqual(@as(usize, 1), single[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());
    const single_u32 = (try sampleWeightedIndexArrayU32ByFrom(&single_engine, SingleEntry, u32, 1, &single_entries, SingleEntry.weightOf)).?;
    try std.testing.expectEqual(@as(u32, 1), single_u32[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    const EmptyEntry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    var empty_engine = alea.ScalarPrng.init(0x5150_c756);
    var empty_control = alea.ScalarPrng.init(0x5150_c756);
    const empty = try sampleWeightedIndexArrayByFrom(&empty_engine, EmptyEntry, f64, 0, &.{.{ .value = 1, .weight = std.math.nan(f64) }}, EmptyEntry.weightOf);
    try std.testing.expectEqual(@as(usize, 0), empty.?.len);
    const empty_u32 = try sampleWeightedIndexArrayU32ByFrom(&empty_engine, EmptyEntry, f64, 0, &.{.{ .value = 1, .weight = std.math.nan(f64) }}, EmptyEntry.weightOf);
    try std.testing.expectEqual(@as(usize, 0), empty_u32.?.len);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
    try std.testing.expect((try sampleWeightedIndexArrayByFrom(&empty_engine, Entry, u32, 4, &entries, Entry.weightOf)) == null);
    try std.testing.expect((try sampleWeightedIndexArrayU32ByFrom(&empty_engine, Entry, u32, 4, &entries, Entry.weightOf)) == null);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayByCheckedFrom(&empty_engine, Entry, u32, 4, &entries, Entry.weightOf));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32ByCheckedFrom(&empty_engine, Entry, u32, 4, &entries, Entry.weightOf));
}

test "accessor weighted index arrays preserve stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const Entry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const entries = [_]Entry{
        .{ .value = 10, .weight = 1 },
        .{ .value = 20, .weight = 2 },
        .{ .value = 30, .weight = 6 },
        .{ .value = 40, .weight = 3 },
    };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c757);
        var direct_engine = Engine.init(0x5150_c757);
        const rng = Rng.init(&facade_engine);

        const facade = (try sampleWeightedIndexArrayBy(rng, Entry, f64, 2, &entries, Entry.weightOf)).?;
        const direct = (try sampleWeightedIndexArrayByFrom(&direct_engine, Entry, f64, 2, &entries, Entry.weightOf)).?;
        try std.testing.expectEqualSlices(usize, &facade, &direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade = try sampleWeightedIndexArrayByChecked(rng, Entry, f64, 2, &entries, Entry.weightOf);
        const checked_direct = try sampleWeightedIndexArrayByCheckedFrom(&direct_engine, Entry, f64, 2, &entries, Entry.weightOf);
        try std.testing.expectEqualSlices(usize, &checked_facade, &checked_direct);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_u32 = (try sampleWeightedIndexArrayU32By(rng, Entry, f64, 2, &entries, Entry.weightOf)).?;
        const direct_u32 = (try sampleWeightedIndexArrayU32ByFrom(&direct_engine, Entry, f64, 2, &entries, Entry.weightOf)).?;
        try std.testing.expectEqualSlices(u32, &facade_u32, &direct_u32);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade_u32 = try sampleWeightedIndexArrayU32ByChecked(rng, Entry, f64, 2, &entries, Entry.weightOf);
        const checked_direct_u32 = try sampleWeightedIndexArrayU32ByCheckedFrom(&direct_engine, Entry, f64, 2, &entries, Entry.weightOf);
        try std.testing.expectEqualSlices(u32, &checked_facade_u32, &checked_direct_u32);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    const BadEntry = struct {
        value: u8,
        weight: f64,

        fn weightOf(item: *const @This()) f64 {
            return item.weight;
        }
    };
    const bad_entries = [_]BadEntry{
        .{ .value = 1, .weight = 1 },
        .{ .value = 2, .weight = std.math.nan(f64) },
    };
    var invalid_engine = alea.ScalarPrng.init(0x5150_c758);
    var invalid_control = alea.ScalarPrng.init(0x5150_c758);
    const rng = Rng.init(&invalid_engine);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayByChecked(rng, Entry, f64, 5, &entries, Entry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32ByChecked(rng, Entry, f64, 5, &entries, Entry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayByCheckedFrom(&invalid_engine, BadEntry, f64, 2, &bad_entries, BadEntry.weightOf));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayU32ByCheckedFrom(&invalid_engine, BadEntry, f64, 2, &bad_entries, BadEntry.weightOf));
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

    var optional_u32_engine = alea.ScalarPrng.init(0x5150_ba17);
    const optional_u32 = (try sampleWeightedIndexArrayU32From(&optional_u32_engine, u32, 2, &weights)).?;
    try std.testing.expectEqual(@as(usize, 2), optional_u32.len);
    for (optional_u32) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

    var checked_u32_engine = alea.ScalarPrng.init(0x5150_ba18);
    const checked_u32 = try sampleWeightedIndexArrayU32CheckedFrom(&checked_u32_engine, u32, 3, &weights);
    try std.testing.expectEqual(@as(usize, 3), checked_u32.len);
    for (checked_u32) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

    var single_engine = alea.ScalarPrng.init(0x5150_ba13);
    var single_control = alea.ScalarPrng.init(0x5150_ba13);
    const single = (try sampleWeightedIndexArrayFrom(&single_engine, u32, 1, &.{ 0, 0, 7, 0, 0 })).?;
    try std.testing.expectEqual(@as(usize, 2), single[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var single_u32_engine = alea.ScalarPrng.init(0x5150_ba19);
    var single_u32_control = alea.ScalarPrng.init(0x5150_ba19);
    const single_u32 = (try sampleWeightedIndexArrayU32From(&single_u32_engine, u32, 1, &.{ 0, 0, 7, 0, 0 })).?;
    try std.testing.expectEqual(@as(u32, 2), single_u32[0]);
    try std.testing.expectEqual(single_u32_control.next(), single_u32_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_ba14);
    var empty_control = alea.ScalarPrng.init(0x5150_ba14);
    const empty = try sampleWeightedIndexArrayFrom(&empty_engine, u32, 0, &weights);
    try std.testing.expectEqual(@as(usize, 0), empty.?.len);
    const empty_u32 = try sampleWeightedIndexArrayU32From(&empty_engine, u32, 0, &weights);
    try std.testing.expectEqual(@as(usize, 0), empty_u32.?.len);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
    try std.testing.expect((try sampleWeightedIndexArrayFrom(&empty_engine, u32, 4, &weights)) == null);
    try std.testing.expect((try sampleWeightedIndexArrayU32From(&empty_engine, u32, 4, &weights)) == null);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayCheckedFrom(&empty_engine, u32, 4, &weights));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32CheckedFrom(&empty_engine, u32, 4, &weights));
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

        const facade_u32 = (try sampleWeightedIndexArrayU32(rng, f64, 2, &weights)).?;
        const direct_u32 = (try sampleWeightedIndexArrayU32From(&direct_engine, f64, 2, &weights)).?;
        try std.testing.expectEqualSlices(u32, &facade_u32, &direct_u32);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const checked_facade_u32 = try sampleWeightedIndexArrayU32Checked(rng, f64, 2, &weights);
        const checked_direct_u32 = try sampleWeightedIndexArrayU32CheckedFrom(&direct_engine, f64, 2, &weights);
        try std.testing.expectEqualSlices(u32, &checked_facade_u32, &checked_direct_u32);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_ba16);
    var invalid_control = alea.ScalarPrng.init(0x5150_ba16);
    const rng = Rng.init(&invalid_engine);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayChecked(rng, f64, 5, &weights));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32Checked(rng, f64, 5, &weights));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayCheckedFrom(&invalid_engine, f64, 2, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayU32CheckedFrom(&invalid_engine, f64, 2, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }));
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

    var optional_u32_engine = alea.ScalarPrng.init(0x5150_ba37);
    var optional_u32_out: [4]u32 = undefined;
    var optional_u32_keys: [4]f64 = undefined;
    const u32_filled = try sampleWeightedIndicesU32IntoFrom(&optional_u32_engine, u32, &weights, &optional_u32_out, &optional_u32_keys);
    try std.testing.expectEqual(@as(usize, 3), u32_filled);
    for (optional_u32_out[0..u32_filled]) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

    var checked_u32_engine = alea.ScalarPrng.init(0x5150_ba38);
    var checked_u32_out: [3]u32 = undefined;
    var checked_u32_keys: [3]f64 = undefined;
    try sampleWeightedIndicesU32IntoCheckedFrom(&checked_u32_engine, u32, &weights, &checked_u32_out, &checked_u32_keys);
    for (checked_u32_out[0..]) |index| {
        try std.testing.expect(index < weights.len);
        try std.testing.expect(weights[index] > 0);
    }

    var single_u32_engine = alea.ScalarPrng.init(0x5150_ba39);
    var single_u32_control = alea.ScalarPrng.init(0x5150_ba39);
    var single_u32_out: [3]u32 = undefined;
    var single_u32_keys: [3]f64 = undefined;
    const single_u32_filled = try sampleWeightedIndicesU32IntoFrom(&single_u32_engine, u32, &.{ 0, 0, 7, 0, 0 }, &single_u32_out, &single_u32_keys);
    try std.testing.expectEqual(@as(usize, 1), single_u32_filled);
    try std.testing.expectEqual(@as(u32, 2), single_u32_out[0]);
    try std.testing.expectEqual(single_u32_control.next(), single_u32_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_ba34);
    var empty_control = alea.ScalarPrng.init(0x5150_ba34);
    var empty_out: [0]usize = .{};
    var empty_keys: [0]f64 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesIntoFrom(&empty_engine, u32, &weights, &empty_out, &empty_keys));
    try sampleWeightedIndicesIntoCheckedFrom(&empty_engine, u32, &weights, &empty_out, &empty_keys);
    var empty_u32_out: [0]u32 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesU32IntoFrom(&empty_engine, u32, &weights, &empty_u32_out, &empty_keys));
    try sampleWeightedIndicesU32IntoCheckedFrom(&empty_engine, u32, &weights, &empty_u32_out, &empty_keys);
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

        var facade_u32_out: [3]u32 = undefined;
        var direct_u32_out: [3]u32 = undefined;
        var facade_u32_keys: [3]f64 = undefined;
        var direct_u32_keys: [3]f64 = undefined;
        try std.testing.expectEqual(try sampleWeightedIndicesU32Into(rng, f64, &weights, &facade_u32_out, &facade_u32_keys), try sampleWeightedIndicesU32IntoFrom(&direct_engine, f64, &weights, &direct_u32_out, &direct_u32_keys));
        try std.testing.expectEqualSlices(u32, &facade_u32_out, &direct_u32_out);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var checked_facade_u32_out: [2]u32 = undefined;
        var checked_direct_u32_out: [2]u32 = undefined;
        var checked_facade_u32_keys: [2]f64 = undefined;
        var checked_direct_u32_keys: [2]f64 = undefined;
        try sampleWeightedIndicesU32IntoChecked(rng, f64, &weights, &checked_facade_u32_out, &checked_facade_u32_keys);
        try sampleWeightedIndicesU32IntoCheckedFrom(&direct_engine, f64, &weights, &checked_direct_u32_out, &checked_direct_u32_keys);
        try std.testing.expectEqualSlices(u32, &checked_facade_u32_out, &checked_direct_u32_out);
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
    var u32_out: [2]u32 = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedIndicesU32IntoFrom(&invalid_engine, f64, &weights, &u32_out, &short_keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesU32IntoCheckedFrom(&invalid_engine, f64, &.{ 1.0, std.math.nan(f64), 2.0 }, &u32_out, &keys));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());
}

test "sampleWeighted pointer slices allocate weighted pointer subsets" {
    const alea = @import("root.zig");
    const weights = [_]u32{ 0, 1, 5, 0, 9 };
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    var optional_engine = alea.ScalarPrng.init(0x5150_be01);
    const optional = try sampleWeightedPtrsFrom(std.testing.allocator, &optional_engine, u8, u32, &items, &weights, 5);
    defer std.testing.allocator.free(optional);
    try std.testing.expectEqual(@as(usize, 3), optional.len);
    for (optional) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var checked_engine = alea.ScalarPrng.init(0x5150_be02);
    const checked = try sampleWeightedPtrsCheckedFrom(std.testing.allocator, &checked_engine, u8, u32, &items, &weights, 3);
    defer std.testing.allocator.free(checked);
    try std.testing.expectEqual(@as(usize, 3), checked.len);
    for (checked) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expectEqual(&items[index], ptr);
    }

    var mutable = items;
    var mut_engine = alea.ScalarPrng.init(0x5150_be03);
    const mut_ptrs = try sampleWeightedMutPtrsCheckedFrom(std.testing.allocator, &mut_engine, u8, u32, &mutable, &weights, 3);
    defer std.testing.allocator.free(mut_ptrs);
    var expected = items;
    for (mut_ptrs) |ptr| {
        const index = @divExact(@intFromPtr(ptr) - @intFromPtr(&mutable[0]), @sizeOf(u8));
        try std.testing.expect(index == 1 or index == 2 or index == 4);
        try std.testing.expectEqual(&mutable[index], ptr);
        ptr.* += 1;
        expected[index] += 1;
    }
    try std.testing.expectEqualSlices(u8, &expected, &mutable);

    var single_engine = alea.ScalarPrng.init(0x5150_be04);
    var single_control = alea.ScalarPrng.init(0x5150_be04);
    const single = try sampleWeightedPtrsFrom(std.testing.allocator, &single_engine, u8, u32, &items, &.{ 0, 0, 7, 0, 0 }, 3);
    defer std.testing.allocator.free(single);
    try std.testing.expectEqual(@as(usize, 1), single.len);
    try std.testing.expectEqual(&items[2], single[0]);
    try std.testing.expectEqual(single_control.next(), single_engine.next());

    var empty_engine = alea.ScalarPrng.init(0x5150_be05);
    var empty_control = alea.ScalarPrng.init(0x5150_be05);
    const empty = try sampleWeightedPtrsFrom(std.testing.allocator, &empty_engine, u8, u32, &items, &weights, 0);
    defer std.testing.allocator.free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
}

test "sampleWeighted pointer slices preserve stream shape and invalid paths do not consume" {
    const alea = @import("root.zig");
    const weights = [_]f64{ 1, 2, 6, 3 };
    const items = [_]u8{ 10, 20, 30, 40 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_be06);
        var direct_engine = Engine.init(0x5150_be06);
        const rng = Rng.init(&facade_engine);

        const facade = try sampleWeightedPtrs(std.testing.allocator, rng, u8, f64, &items, &weights, 3);
        defer std.testing.allocator.free(facade);
        const direct = try sampleWeightedPtrsFrom(std.testing.allocator, &direct_engine, u8, f64, &items, &weights, 3);
        defer std.testing.allocator.free(direct);
        for (facade, direct) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&items[0]), @sizeOf(u8));
            try std.testing.expectEqual(facade_index, direct_index);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_items = items;
        var direct_items = items;
        const facade_mut = try sampleWeightedMutPtrs(std.testing.allocator, rng, u8, f64, &facade_items, &weights, 3);
        defer std.testing.allocator.free(facade_mut);
        const direct_mut = try sampleWeightedMutPtrsFrom(std.testing.allocator, &direct_engine, u8, f64, &direct_items, &weights, 3);
        defer std.testing.allocator.free(direct_mut);
        for (facade_mut, direct_mut) |facade_ptr, direct_ptr| {
            const facade_index = @divExact(@intFromPtr(facade_ptr) - @intFromPtr(&facade_items[0]), @sizeOf(u8));
            const direct_index = @divExact(@intFromPtr(direct_ptr) - @intFromPtr(&direct_items[0]), @sizeOf(u8));
            try std.testing.expectEqual(facade_index, direct_index);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }

    var invalid_engine = alea.ScalarPrng.init(0x5150_be07);
    var invalid_control = alea.ScalarPrng.init(0x5150_be07);
    try std.testing.expectError(error.LengthMismatch, sampleWeightedPtrsFrom(std.testing.allocator, &invalid_engine, u8, f64, &items, &.{ 1.0, 2.0 }, 2));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var mutable_items = items;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedMutPtrsFrom(std.testing.allocator, &invalid_engine, u8, f64, &mutable_items, &.{ 1.0, 2.0 }, 2));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrsCheckedFrom(std.testing.allocator, &invalid_engine, u8, f64, &items, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }, 2));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrsCheckedFrom(std.testing.allocator, &invalid_engine, u8, f64, &mutable_items, &.{ 1.0, std.math.nan(f64), 2.0, 3.0 }, 2));
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var out_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedPtrsFrom(out_alloc.allocator(), &invalid_engine, u8, f64, &items, &weights, 2));
    try std.testing.expect(out_alloc.has_induced_failure);
    try std.testing.expectEqual(invalid_control.next(), invalid_engine.next());

    var index_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, sampleWeightedPtrsFrom(index_alloc.allocator(), &invalid_engine, u8, f64, &items, &weights, 2));
    try std.testing.expect(index_alloc.has_induced_failure);
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

test "stable iterator choice aliases reservoir selection" {
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

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var stable_engine = Engine.init(0x5150_c901);
        var direct_engine = Engine.init(0x5150_c901);
        const rng = Rng.init(&stable_engine);

        var stable_iter = RangeIter{ .next_value = 0, .end = 100 };
        var direct_iter = RangeIter{ .next_value = 0, .end = 100 };
        try std.testing.expectEqual(chooseIteratorStable(rng, u32, &stable_iter), chooseIteratorFrom(&direct_engine, u32, &direct_iter));
        try std.testing.expectEqual(stable_engine.next(), direct_engine.next());

        var checked_iter = RangeIter{ .next_value = 0, .end = 100 };
        var checked_direct_iter = RangeIter{ .next_value = 0, .end = 100 };
        try std.testing.expectEqual(try chooseIteratorStableChecked(rng, u32, &checked_iter), try chooseIteratorCheckedFrom(&direct_engine, u32, &checked_direct_iter));
        try std.testing.expectEqual(stable_engine.next(), direct_engine.next());
    }

    var empty_engine = alea.ScalarPrng.init(0x5150_c902);
    var empty_control = alea.ScalarPrng.init(0x5150_c902);
    var empty_iter = RangeIter{ .next_value = 0, .end = 0 };
    try std.testing.expectEqual(@as(?u32, null), chooseIteratorStableFrom(&empty_engine, u32, &empty_iter));
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
    var checked_empty_iter = RangeIter{ .next_value = 0, .end = 0 };
    try std.testing.expectError(error.EmptyInput, chooseIteratorStableCheckedFrom(&empty_engine, u32, &checked_empty_iter));
    try std.testing.expectEqual(empty_control.next(), empty_engine.next());
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
