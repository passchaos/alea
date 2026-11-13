const std = @import("std");

pub const SizeHint = struct {
    lower: usize,
    upper: ?usize,
};

pub const IndexVec = union(enum) {
    u32: []u32,
    usize: []usize,

    pub fn fromOwnedSlice(items: []usize) IndexVec {
        return .{ .usize = items };
    }

    pub fn fromOwnedU32Slice(items: []u32) IndexVec {
        return .{ .u32 = items };
    }

    pub fn clone(self: IndexVec, allocator: std.mem.Allocator) !IndexVec {
        return switch (self) {
            .u32 => |items| .{ .u32 = try allocator.dupe(u32, items) },
            .usize => |items| .{ .usize = try allocator.dupe(usize, items) },
        };
    }

    pub const IntoIterator = struct {
        index_vec: IndexVec,
        allocator: std.mem.Allocator,
        index: usize = 0,

        pub fn next(self: *IntoIterator) ?usize {
            return switch (self.index_vec) {
                .u32 => |items| {
                    if (self.index >= items.len) return null;
                    const value: usize = items[self.index];
                    self.index += 1;
                    return value;
                },
                .usize => |items| {
                    if (self.index >= items.len) return null;
                    const value = items[self.index];
                    self.index += 1;
                    return value;
                },
            };
        }

        pub fn remaining(self: IntoIterator) usize {
            return self.index_vec.len() - self.index;
        }

        pub fn len(self: IntoIterator) usize {
            return self.remaining();
        }

        pub fn sizeHint(self: IntoIterator) SizeHint {
            const length = self.remaining();
            return .{ .lower = length, .upper = length };
        }

        pub fn fill(self: *IntoIterator, dest: []usize) usize {
            const count = @min(dest.len, self.remaining());
            const start = self.index;
            const end = start + count;
            switch (self.index_vec) {
                .u32 => |items| {
                    for (items[start..end], dest[0..count]) |item, *slot| slot.* = item;
                },
                .usize => |items| std.mem.copyForwards(usize, dest[0..count], items[start..end]),
            }
            self.index = end;
            return count;
        }

        pub fn deinit(self: IntoIterator) void {
            self.index_vec.deinit(self.allocator);
        }
    };

    pub const Iterator = struct {
        index_vec: IndexVec,
        index: usize = 0,

        pub fn next(self: *Iterator) ?usize {
            return switch (self.index_vec) {
                .u32 => |items| {
                    if (self.index >= items.len) return null;
                    const value: usize = items[self.index];
                    self.index += 1;
                    return value;
                },
                .usize => |items| {
                    if (self.index >= items.len) return null;
                    const value = items[self.index];
                    self.index += 1;
                    return value;
                },
            };
        }

        pub fn remaining(self: Iterator) usize {
            return self.index_vec.len() - self.index;
        }

        pub fn len(self: Iterator) usize {
            return self.remaining();
        }

        pub fn sizeHint(self: Iterator) SizeHint {
            const length = self.remaining();
            return .{ .lower = length, .upper = length };
        }

        pub fn fill(self: *Iterator, dest: []usize) usize {
            const count = @min(dest.len, self.remaining());
            const start = self.index;
            const end = start + count;
            switch (self.index_vec) {
                .u32 => |items| {
                    for (items[start..end], dest[0..count]) |item, *slot| slot.* = item;
                },
                .usize => |items| std.mem.copyForwards(usize, dest[0..count], items[start..end]),
            }
            self.index = end;
            return count;
        }
    };

    pub fn ValueIterator(comptime T: type) type {
        return struct {
            index_iter: Iterator,
            items: []const T,

            pub fn next(self: *@This()) ?T {
                const item_index = self.index_iter.next() orelse return null;
                return self.items[item_index];
            }

            pub fn remaining(self: @This()) usize {
                return self.index_iter.remaining();
            }

            pub fn len(self: @This()) usize {
                return self.remaining();
            }

            pub fn sizeHint(self: @This()) SizeHint {
                return self.index_iter.sizeHint();
            }

            pub fn fill(self: *@This(), dest: []T) usize {
                var indices_buf: [64]usize = undefined;
                var filled: usize = 0;
                while (filled < dest.len) {
                    const chunk_len = @min(dest.len - filled, indices_buf.len);
                    const count = self.index_iter.fill(indices_buf[0..chunk_len]);
                    for (indices_buf[0..count], dest[filled..][0..count]) |item_index, *slot| slot.* = self.items[item_index];
                    filled += count;
                    if (count < chunk_len) break;
                }
                return filled;
            }
        };
    }

    pub fn PtrIterator(comptime T: type) type {
        return struct {
            index_iter: Iterator,
            items: []const T,

            pub fn next(self: *@This()) ?*const T {
                const item_index = self.index_iter.next() orelse return null;
                return &self.items[item_index];
            }

            pub fn remaining(self: @This()) usize {
                return self.index_iter.remaining();
            }

            pub fn len(self: @This()) usize {
                return self.remaining();
            }

            pub fn sizeHint(self: @This()) SizeHint {
                return self.index_iter.sizeHint();
            }

            pub fn fill(self: *@This(), dest: []*const T) usize {
                var indices_buf: [64]usize = undefined;
                var filled: usize = 0;
                while (filled < dest.len) {
                    const chunk_len = @min(dest.len - filled, indices_buf.len);
                    const count = self.index_iter.fill(indices_buf[0..chunk_len]);
                    for (indices_buf[0..count], dest[filled..][0..count]) |item_index, *slot| slot.* = &self.items[item_index];
                    filled += count;
                    if (count < chunk_len) break;
                }
                return filled;
            }
        };
    }

    pub fn MutPtrIterator(comptime T: type) type {
        return struct {
            index_iter: Iterator,
            items: []T,

            pub fn next(self: *@This()) ?*T {
                const item_index = self.index_iter.next() orelse return null;
                return &self.items[item_index];
            }

            pub fn remaining(self: @This()) usize {
                return self.index_iter.remaining();
            }

            pub fn len(self: @This()) usize {
                return self.remaining();
            }

            pub fn sizeHint(self: @This()) SizeHint {
                return self.index_iter.sizeHint();
            }

            pub fn fill(self: *@This(), dest: []*T) usize {
                var indices_buf: [64]usize = undefined;
                var filled: usize = 0;
                while (filled < dest.len) {
                    const chunk_len = @min(dest.len - filled, indices_buf.len);
                    const count = self.index_iter.fill(indices_buf[0..chunk_len]);
                    for (indices_buf[0..count], dest[filled..][0..count]) |item_index, *slot| slot.* = &self.items[item_index];
                    filled += count;
                    if (count < chunk_len) break;
                }
                return filled;
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

    pub fn at(self: IndexVec, position: usize) usize {
        return switch (self) {
            .u32 => |items| items[position],
            .usize => |items| items[position],
        };
    }

    pub fn index(self: IndexVec, position: usize) usize {
        return self.at(position);
    }

    pub fn get(self: IndexVec, position: usize) ?usize {
        if (position >= self.len()) return null;
        return self.at(position);
    }

    pub fn indexOf(self: IndexVec, value: usize) ?usize {
        return switch (self) {
            .u32 => |items| {
                if (value > std.math.maxInt(u32)) return null;
                const needle: u32 = @intCast(value);
                for (items, 0..) |item, position| {
                    if (item == needle) return position;
                }
                return null;
            },
            .usize => |items| {
                for (items, 0..) |item, position| {
                    if (item == value) return position;
                }
                return null;
            },
        };
    }

    pub fn contains(self: IndexVec, value: usize) bool {
        return self.indexOf(value) != null;
    }

    pub fn eql(self: IndexVec, other: IndexVec) bool {
        if (self.len() != other.len()) return false;
        switch (self) {
            .u32 => |self_items| switch (other) {
                .u32 => |other_items| return std.mem.eql(u32, self_items, other_items),
                .usize => |other_items| {
                    for (self_items, other_items) |self_item, other_item| {
                        if (@as(usize, self_item) != other_item) return false;
                    }
                    return true;
                },
            },
            .usize => |self_items| switch (other) {
                .u32 => |other_items| {
                    for (self_items, other_items) |self_item, other_item| {
                        if (self_item != @as(usize, other_item)) return false;
                    }
                    return true;
                },
                .usize => |other_items| return std.mem.eql(usize, self_items, other_items),
            },
        }
    }

    pub fn validateItems(self: IndexVec, item_len: usize) Error!void {
        switch (self) {
            .u32 => |items| {
                if (item_len > std.math.maxInt(u32)) return;
                const upper: u32 = @intCast(item_len);
                for (items) |item| {
                    if (item >= upper) return error.InvalidParameter;
                }
            },
            .usize => |items| {
                for (items) |item| {
                    if (item >= item_len) return error.InvalidParameter;
                }
            },
        }
    }

    pub fn validateDistinctItems(self: IndexVec, item_len: usize) Error!void {
        switch (self) {
            .u32 => |items| {
                if (item_len <= std.math.maxInt(u32)) {
                    const upper: u32 = @intCast(item_len);
                    for (items) |item| {
                        if (item >= upper) return error.InvalidParameter;
                    }
                }
                for (items, 0..) |item, position| {
                    for (items[position + 1 ..]) |other| {
                        if (item == other) return error.InvalidParameter;
                    }
                }
            },
            .usize => |items| {
                for (items, 0..) |item, position| {
                    if (item >= item_len) return error.InvalidParameter;
                    for (items[position + 1 ..]) |other| {
                        if (item == other) return error.InvalidParameter;
                    }
                }
            },
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
                for (items) |item| {
                    if (item > std.math.maxInt(u32)) return error.InvalidParameter;
                }
                for (items, out) |item, *slot| slot.* = @intCast(item);
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
        if (self == .usize) {
            for (self.usize) |item| {
                if (item > std.math.maxInt(u32)) return error.InvalidParameter;
            }
        }
        const out = try allocator.alloc(u32, self.len());
        errdefer allocator.free(out);
        try self.copyIntoU32(out);
        return out;
    }

    pub fn intoOwnedSlice(self: IndexVec, allocator: std.mem.Allocator) ![]usize {
        switch (self) {
            .usize => |items| return items,
            .u32 => |items| {
                const out = try allocator.alloc(usize, items.len);
                errdefer allocator.free(out);
                for (items, out) |item, *slot| slot.* = item;
                allocator.free(items);
                return out;
            },
        }
    }

    pub fn intoVec(self: IndexVec, allocator: std.mem.Allocator) ![]usize {
        return self.intoOwnedSlice(allocator);
    }

    pub fn intoOwnedU32Slice(self: IndexVec, allocator: std.mem.Allocator) ![]u32 {
        switch (self) {
            .u32 => |items| return items,
            .usize => |items| {
                for (items) |item| {
                    if (item > std.math.maxInt(u32)) return error.InvalidParameter;
                }
                const out = try allocator.alloc(u32, items.len);
                errdefer allocator.free(out);
                for (items, out) |item, *slot| slot.* = @intCast(item);
                allocator.free(items);
                return out;
            },
        }
    }

    pub fn values(self: IndexVec, comptime T: type, items: []const T) ValueIterator(T) {
        return .{ .index_iter = self.iter(), .items = items };
    }

    pub fn valuesChecked(self: IndexVec, comptime T: type, items: []const T) Error!ValueIterator(T) {
        try self.validateItems(items.len);
        if (self.len() != 0 and comptime valueTypeHasEmptyEnum(T)) return error.EmptyInput;
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
        if (out.len != 0 and comptime valueTypeHasEmptyEnum(T)) return error.EmptyInput;
        switch (self) {
            .u32 => |indices| for (indices, out) |item_index, *slot| {
                slot.* = items[item_index];
            },
            .usize => |indices| for (indices, out) |item_index, *slot| {
                slot.* = items[item_index];
            },
        }
    }

    pub fn valuesIntoChecked(self: IndexVec, comptime T: type, items: []const T, out: []T) Error!void {
        try self.validateItems(items.len);
        try self.valuesInto(T, items, out);
    }

    pub fn valuesOwned(self: IndexVec, allocator: std.mem.Allocator, comptime T: type, items: []const T) ![]T {
        if (self.len() == 0) return allocator.alloc(T, 0);
        if (comptime valueTypeHasEmptyEnum(T)) return error.EmptyInput;
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
        switch (self) {
            .u32 => |indices| for (indices, out) |item_index, *slot| {
                slot.* = &items[item_index];
            },
            .usize => |indices| for (indices, out) |item_index, *slot| {
                slot.* = &items[item_index];
            },
        }
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
        switch (self) {
            .u32 => |indices| for (indices, out) |item_index, *slot| {
                slot.* = &items[item_index];
            },
            .usize => |indices| for (indices, out) |item_index, *slot| {
                slot.* = &items[item_index];
            },
        }
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

    pub fn intoIter(self: IndexVec, allocator: std.mem.Allocator) IntoIterator {
        return .{ .index_vec = self, .allocator = allocator };
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
pub const WeightError = Error;

fn valueTypeHasEmptyEnum(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .@"enum" => std.enums.values(T).len == 0,
        .array => |array_info| array_info.len != 0 and valueTypeHasEmptyEnum(array_info.child),
        .@"struct" => |struct_info| blk: {
            inline for (struct_info.fields) |field| {
                if (valueTypeHasEmptyEnum(field.type)) break :blk true;
            }
            break :blk false;
        },
        else => false,
    };
}
