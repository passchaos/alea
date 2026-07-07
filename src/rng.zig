const std = @import("std");
const std_ziggurat = std.Random.ziggurat;

const Rng = @This();

const IteratorSizeHint = struct {
    lower: usize,
    upper: ?usize,
};

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
    NonFinite,
    InvalidProbability,
    InvalidParameter,
    InvalidWeight,
};

ptr: *anyopaque,
nextFn: *const fn (ptr: *anyopaque) u64,
nextU32Fn: *const fn (ptr: *anyopaque) u32,
fillFn: *const fn (ptr: *anyopaque, buf: []u8) void,

pub const SysRng = struct {
    io: std.Io,

    pub const Error = std.Io.RandomSecureError;

    pub fn init(io: std.Io) SysRng {
        return .{ .io = io };
    }

    pub fn reader(self: SysRng, buffer: []u8) RngReader(SysRng) {
        return rngReader(self, buffer);
    }

    pub fn tryNext(self: SysRng) SysRng.Error!u64 {
        return self.tryNextU64();
    }

    pub fn tryNextU64(self: SysRng) SysRng.Error!u64 {
        var word_bytes: [8]u8 = undefined;
        try self.tryFillBytes(&word_bytes);
        return std.mem.readInt(u64, &word_bytes, .little);
    }

    pub fn tryNextU32(self: SysRng) SysRng.Error!u32 {
        var word_bytes: [4]u8 = undefined;
        try self.tryFillBytes(&word_bytes);
        return std.mem.readInt(u32, &word_bytes, .little);
    }

    pub fn tryFillBytes(self: SysRng, out: []u8) SysRng.Error!void {
        return std.Io.randomSecure(self.io, out);
    }
};

pub fn init(pointer: anytype) Rng {
    const Ptr = @TypeOf(pointer);
    const ptr_info = @typeInfo(Ptr);
    comptime {
        if (ptr_info != .pointer or ptr_info.pointer.size != .one) {
            @compileError("Rng.init expects a single-item pointer to an engine");
        }
        const Child = ptr_info.pointer.child;
        if (!@hasDecl(Child, "next")) {
            @compileError(@typeName(Child) ++ " must expose pub fn next(*Self) u64");
        }
        if (!@hasDecl(Child, "fill")) {
            @compileError(@typeName(Child) ++ " must expose pub fn fill(*Self, []u8) void");
        }
    }
    const Child = ptr_info.pointer.child;

    const gen = struct {
        fn next(ptr: *anyopaque) u64 {
            const self: Ptr = @ptrCast(@alignCast(ptr));
            return self.next();
        }

        fn nextU32(ptr: *anyopaque) u32 {
            const self: Ptr = @ptrCast(@alignCast(ptr));
            if (comptime @hasDecl(Child, "nextU32")) return self.nextU32();
            return @truncate(self.next() >> 32);
        }

        fn fill(ptr: *anyopaque, buf: []u8) void {
            const self: Ptr = @ptrCast(@alignCast(ptr));
            self.fill(buf);
        }
    };

    return .{
        .ptr = pointer,
        .nextFn = gen.next,
        .nextU32Fn = gen.nextU32,
        .fillFn = gen.fill,
    };
}

pub fn fromRandom(random_source: *std.Random) Rng {
    const gen = struct {
        fn next(ptr: *anyopaque) u64 {
            const source: *std.Random = @ptrCast(@alignCast(ptr));
            return source.int(u64);
        }

        fn nextU32(ptr: *anyopaque) u32 {
            const source: *std.Random = @ptrCast(@alignCast(ptr));
            return @truncate(source.int(u64) >> 32);
        }

        fn fill(ptr: *anyopaque, buf: []u8) void {
            const source: *std.Random = @ptrCast(@alignCast(ptr));
            source.bytes(buf);
        }
    };

    return .{
        .ptr = random_source,
        .nextFn = gen.next,
        .nextU32Fn = gen.nextU32,
        .fillFn = gen.fill,
    };
}

pub fn random(self: Rng) std.Random {
    return .{
        .ptr = self.ptr,
        .fillFn = self.fillFn,
    };
}

pub fn reader(self: Rng, buffer: []u8) RngReader(Rng) {
    return RngReader(Rng).init(self, buffer);
}

pub fn readerFrom(source: anytype, buffer: []u8) RngReader(@TypeOf(source)) {
    return RngReader(@TypeOf(source)).init(source, buffer);
}

pub fn RngReader(comptime Source: type) type {
    return struct {
        const Self = @This();

        source: Source,
        interface: std.Io.Reader,
        err: ?anyerror = null,

        pub fn init(source: Source, buffer: []u8) Self {
            return .{
                .source = source,
                .interface = .{
                    .vtable = &.{
                        .stream = stream,
                        .discard = discard,
                        .readVec = readVec,
                    },
                    .buffer = buffer,
                    .seek = 0,
                    .end = 0,
                },
            };
        }

        pub fn reader(self: *Self) *std.Io.Reader {
            return &self.interface;
        }

        pub fn read(self: *Self, out: []u8) std.Io.Reader.ShortError!usize {
            return self.interface.readSliceShort(out);
        }

        pub fn readAll(self: *Self, out: []u8) std.Io.Reader.Error!void {
            return self.interface.readSliceAll(out);
        }

        pub fn lastError(self: *const Self) ?anyerror {
            return self.err;
        }

        fn stream(io_r: *std.Io.Reader, io_w: *std.Io.Writer, limit: std.Io.Limit) std.Io.Reader.StreamError!usize {
            if (limit == .nothing) return 0;
            const dest = limit.slice(try io_w.writableSliceGreedy(1));
            const self: *Self = @alignCast(@fieldParentPtr("interface", io_r));
            fillSourceBytes(self, dest) catch return error.ReadFailed;
            io_w.advance(dest.len);
            return dest.len;
        }

        fn discard(io_r: *std.Io.Reader, limit: std.Io.Limit) std.Io.Reader.Error!usize {
            if (limit == .nothing) return 0;
            const self: *Self = @alignCast(@fieldParentPtr("interface", io_r));
            const amount = limit.toInt() orelse @max(@as(usize, 64), io_r.buffer.len);
            var remaining = amount;
            var scratch: [64]u8 = undefined;
            while (remaining != 0) {
                const n = @min(remaining, scratch.len);
                fillSourceBytes(self, scratch[0..n]) catch return error.ReadFailed;
                remaining -= n;
            }
            return amount;
        }

        fn readVec(io_r: *std.Io.Reader, data: [][]u8) std.Io.Reader.Error!usize {
            const self: *Self = @alignCast(@fieldParentPtr("interface", io_r));
            if (data[0].len == 0) {
                const dest = io_r.buffer[io_r.end..];
                if (dest.len == 0) return error.ReadFailed;
                fillSourceBytes(self, dest) catch return error.ReadFailed;
                io_r.end += dest.len;
                return 0;
            }

            var total: usize = 0;
            for (data) |dest| {
                if (dest.len == 0) continue;
                fillSourceBytes(self, dest) catch return error.ReadFailed;
                total += dest.len;
            }
            return total;
        }

        fn fillSourceBytes(self: *Self, out: []u8) !void {
            self.err = null;
            if (comptime isSinglePointer(Source)) {
                fillSourceBytesFrom(self.source, out) catch |err| {
                    self.err = err;
                    return err;
                };
            } else {
                fillSourceBytesFrom(&self.source, out) catch |err| {
                    self.err = err;
                    return err;
                };
            }
        }

        fn isSinglePointer(comptime T: type) bool {
            const info = @typeInfo(T);
            return info == .pointer and info.pointer.size == .one;
        }
    };
}

pub fn rngReader(source: anytype, buffer: []u8) RngReader(@TypeOf(source)) {
    return RngReader(@TypeOf(source)).init(source, buffer);
}

pub fn value(self: Rng, comptime T: type) T {
    return valueFrom(self, T);
}

pub fn randomValue(self: Rng, comptime T: type) T {
    return value(self, T);
}

pub fn valueChecked(self: Rng, comptime T: type) Error!T {
    return valueCheckedFrom(self, T);
}

pub fn randomValueChecked(self: Rng, comptime T: type) Error!T {
    return valueChecked(self, T);
}

pub fn valueCheckedFrom(source: anytype, comptime T: type) Error!T {
    if (comptime valueTypeHasEmptyEnum(T)) return error.EmptyRange;
    return valueCheckedFromPrevalidated(source, T);
}

pub fn randomValueCheckedFrom(source: anytype, comptime T: type) Error!T {
    return valueCheckedFrom(source, T);
}

pub fn valueBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize) ![]T {
    return valueBatchFrom(self, T, allocator, count);
}

pub fn valueBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    var iter = valueIterFrom(source, T);
    iter.fill(out);
    return out;
}

pub fn valueBatchChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize) ![]T {
    return valueBatchCheckedFrom(self, T, allocator, count);
}

pub fn valueBatchCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    if (comptime valueTypeHasEmptyEnum(T)) return error.EmptyRange;
    return valueBatchFrom(source, T, allocator, count);
}

fn valueCheckedFromPrevalidated(source: anytype, comptime T: type) T {
    return switch (@typeInfo(T)) {
        .bool, .int, .float, .vector => valueFrom(source, T),
        .@"enum" => valueFrom(source, T),
        .array => |array_info| blk: {
            var out: T = undefined;
            for (&out) |*item| item.* = valueCheckedFromPrevalidated(source, array_info.child);
            break :blk out;
        },
        .@"struct" => |struct_info| blk: {
            if (struct_info.is_tuple) {
                var out: T = undefined;
                inline for (struct_info.fields) |field| {
                    @field(out, field.name) = valueCheckedFromPrevalidated(source, field.type);
                }
                break :blk out;
            }
            @compileError("alea.Rng.valueChecked only auto-samples tuples, arrays, bools, ints, floats, and enums");
        },
        else => @compileError("alea.Rng.valueChecked does not support " ++ @typeName(T)),
    };
}

fn valueTypeHasEmptyEnum(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .@"enum" => std.enums.values(T).len == 0,
        .array => |array_info| array_info.len != 0 and valueTypeHasEmptyEnum(array_info.child),
        .@"struct" => |struct_info| blk: {
            if (!struct_info.is_tuple) break :blk false;
            inline for (struct_info.fields) |field| {
                if (valueTypeHasEmptyEnum(field.type)) break :blk true;
            }
            break :blk false;
        },
        else => false,
    };
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

pub fn randomValueFrom(source: anytype, comptime T: type) T {
    return valueFrom(source, T);
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

pub fn sample(self: Rng, comptime T: type, sampler: anytype) T {
    return sampleWith(T, sampler, self);
}

pub fn sampleFrom(source: anytype, comptime T: type, sampler: anytype) T {
    return sampleFromWith(T, sampler, source);
}

pub fn sampleBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, sampler: anytype, count: usize) ![]T {
    return sampleBatchFrom(self, T, allocator, sampler, count);
}

pub fn sampleBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, sampler: anytype, count: usize) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    fillSampleFrom(source, T, out, sampler);
    return out;
}

pub fn bytes(self: Rng, buf: []u8) void {
    self.fillFn(self.ptr, buf);
}

pub fn fillBytes(self: Rng, buf: []u8) void {
    self.bytes(buf);
}

pub fn tryFillBytes(self: Rng, buf: []u8) !void {
    self.fillBytes(buf);
}

pub fn tryFillBytesFrom(source: anytype, buf: []u8) !void {
    if (@TypeOf(source) == Rng) {
        try source.tryFillBytes(buf);
    } else if (comptime sourceCanTryFillBytes(@TypeOf(source))) {
        try source.tryFillBytes(buf);
    } else {
        fillBytesFrom(source, buf);
    }
}

pub fn bytesAlloc(self: Rng, allocator: std.mem.Allocator, count: usize) ![]u8 {
    return bytesAllocFrom(self, allocator, count);
}

pub fn bytesAllocFrom(source: anytype, allocator: std.mem.Allocator, count: usize) ![]u8 {
    const out = try allocator.alloc(u8, count);
    errdefer allocator.free(out);
    fillBytesFrom(source, out);
    return out;
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

pub fn fillRangeAtMost(self: Rng, comptime T: type, dest: []T, min: T, max: T) void {
    fillRangeAtMostFrom(self, T, dest, min, max);
}

pub fn rangeAtMostBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, min: T, max: T) ![]T {
    return rangeAtMostBatchFrom(self, T, allocator, count, min, max);
}

pub fn rangeAtMostBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, min: T, max: T) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    try validateRangeAtMostParams(T, min, max);
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    fillRangeAtMostFrom(source, T, out, min, max);
    return out;
}

pub fn rangeAtMostBatchChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, min: T, max: T) ![]T {
    return rangeAtMostBatchCheckedFrom(self, T, allocator, count, min, max);
}

pub fn rangeAtMostBatchCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, min: T, max: T) ![]T {
    return rangeAtMostBatchFrom(source, T, allocator, count, min, max);
}

pub fn fillRangeAtMostFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) void {
    if (dest.len == 0) return;
    switch (@typeInfo(T)) {
        .int => {
            std.debug.assert(min <= max);
            if (min == max) {
                @memset(dest, min);
                return;
            }
            for (dest) |*item| item.* = intRangeAtMostFrom(source, T, min, max);
        },
        else => @compileError("alea.Rng.fillRangeAtMostFrom supports integer slices"),
    }
}

pub fn fillRangeAtMostChecked(self: Rng, comptime T: type, dest: []T, min: T, max: T) Error!void {
    return fillRangeAtMostCheckedFrom(self, T, dest, min, max);
}

pub fn fillRangeAtMostCheckedFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) Error!void {
    if (dest.len == 0) return;
    try validateRangeAtMostParams(T, min, max);
    fillRangeAtMostFrom(source, T, dest, min, max);
}

pub fn fillUintLessThan(self: Rng, comptime T: type, dest: []T, less_than: T) void {
    fillUintLessThanFrom(self, T, dest, less_than);
}

pub fn uintLessThanBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, less_than: T) ![]T {
    return uintLessThanBatchFrom(self, T, allocator, count, less_than);
}

pub fn uintLessThanBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, less_than: T) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    comptime requireUnsigned(T);
    if (less_than == 0) return error.EmptyRange;
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    fillUintLessThanFrom(source, T, out, less_than);
    return out;
}

pub fn uintLessThanBatchChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, less_than: T) ![]T {
    return uintLessThanBatchCheckedFrom(self, T, allocator, count, less_than);
}

pub fn uintLessThanBatchCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, less_than: T) ![]T {
    return uintLessThanBatchFrom(source, T, allocator, count, less_than);
}

pub fn fillUintLessThanFrom(source: anytype, comptime T: type, dest: []T, less_than: T) void {
    if (dest.len == 0) return;
    comptime requireUnsigned(T);
    std.debug.assert(less_than > 0);
    if (less_than == 1) {
        @memset(dest, 0);
        return;
    }
    for (dest) |*item| item.* = uintLessThanFrom(source, T, less_than);
}

pub fn fillUintLessThanChecked(self: Rng, comptime T: type, dest: []T, less_than: T) Error!void {
    return fillUintLessThanCheckedFrom(self, T, dest, less_than);
}

pub fn fillUintLessThanCheckedFrom(source: anytype, comptime T: type, dest: []T, less_than: T) Error!void {
    if (dest.len == 0) return;
    comptime requireUnsigned(T);
    if (less_than == 0) return error.EmptyRange;
    fillUintLessThanFrom(source, T, dest, less_than);
}

pub fn fillUintAtMost(self: Rng, comptime T: type, dest: []T, at_most: T) void {
    fillUintAtMostFrom(self, T, dest, at_most);
}

pub fn uintAtMostBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, at_most: T) ![]T {
    return uintAtMostBatchFrom(self, T, allocator, count, at_most);
}

pub fn uintAtMostBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, at_most: T) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    fillUintAtMostFrom(source, T, out, at_most);
    return out;
}

pub fn fillUintAtMostFrom(source: anytype, comptime T: type, dest: []T, at_most: T) void {
    comptime requireUnsigned(T);
    if (at_most == 0) {
        @memset(dest, 0);
        return;
    }
    if (at_most == std.math.maxInt(T)) {
        fillIntsFrom(source, T, dest);
        return;
    }
    fillUintLessThanFrom(source, T, dest, at_most + 1);
}

pub fn rangeBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, min: T, max: T) ![]T {
    return rangeBatchFrom(self, T, allocator, count, min, max);
}

pub fn rangeBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, min: T, max: T) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    try validateRangeParams(T, min, max);
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    fillRangeFrom(source, T, out, min, max);
    return out;
}

pub fn rangeBatchChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, min: T, max: T) ![]T {
    return rangeBatchCheckedFrom(self, T, allocator, count, min, max);
}

pub fn rangeBatchCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, min: T, max: T) ![]T {
    return rangeBatchFrom(source, T, allocator, count, min, max);
}

pub fn fillRangeFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) void {
    if (dest.len == 0) return;
    switch (@typeInfo(T)) {
        .int => {
            std.debug.assert(min < max);
            if (exclusiveIntRangeHasSingleValue(T, min, max)) {
                @memset(dest, min);
                return;
            }
            for (dest) |*item| item.* = intRangeLessThanFrom(source, T, min, max);
        },
        .float => {
            std.debug.assert(min <= max);
            if (min == max) {
                @memset(dest, min);
                return;
            }
            fillFloatRangeFrom(source, T, dest, min, max);
        },
        else => @compileError("alea.Rng.fillRangeFrom supports integer and floating-point slices"),
    }
}

pub fn fillRangeChecked(self: Rng, comptime T: type, dest: []T, min: T, max: T) Error!void {
    return fillRangeCheckedFrom(self, T, dest, min, max);
}

pub fn fillRangeCheckedFrom(source: anytype, comptime T: type, dest: []T, min: T, max: T) Error!void {
    if (dest.len == 0) return;
    try validateRangeParams(T, min, max);
    fillRangeFrom(source, T, dest, min, max);
}

fn validateRangeParams(comptime T: type, min: T, max: T) Error!void {
    switch (@typeInfo(T)) {
        .int => {
            if (min >= max) return error.EmptyRange;
        },
        .float => {
            try validateFloatRangeParams(T, min, max, true);
        },
        else => @compileError("alea.Rng.fillRangeChecked supports integer and floating-point slices"),
    }
}

fn validateFloatRangeParams(comptime T: type, min: T, max: T, comptime allow_equal: bool) Error!void {
    requireFloat(T);
    if (!std.math.isFinite(min) or !std.math.isFinite(max)) return error.NonFinite;
    if (allow_equal) {
        if (min > max) return error.EmptyRange;
    } else if (min >= max) return error.EmptyRange;
    if (!std.math.isFinite(max - min)) return error.NonFinite;
}

fn validateRangeAtMostParams(comptime T: type, min: T, max: T) Error!void {
    switch (@typeInfo(T)) {
        .int => {
            if (min > max) return error.EmptyRange;
        },
        else => @compileError("alea.Rng.fillRangeAtMostChecked supports integer slices"),
    }
}

pub fn fillOpen(self: Rng, comptime T: type, dest: []T) void {
    fillOpenFrom(self, T, dest);
}

pub fn openBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize) ![]T {
    return openBatchFrom(self, T, allocator, count);
}

pub fn openBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    fillOpenFrom(source, T, out);
    return out;
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

pub fn openClosedBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize) ![]T {
    return openClosedBatchFrom(self, T, allocator, count);
}

pub fn openClosedBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    fillOpenClosedFrom(source, T, out);
    return out;
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

pub fn chanceBatch(self: Rng, allocator: std.mem.Allocator, count: usize, p: f64) ![]bool {
    return chanceBatchFrom(self, allocator, count, p);
}

pub fn chanceBatchFrom(source: anytype, allocator: std.mem.Allocator, count: usize, p: f64) ![]bool {
    if (count == 0) return allocator.alloc(bool, 0);
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    const out = try allocator.alloc(bool, count);
    errdefer allocator.free(out);
    fillChanceFrom(source, out, p);
    return out;
}

pub fn chanceBatchChecked(self: Rng, allocator: std.mem.Allocator, count: usize, p: f64) ![]bool {
    return chanceBatchCheckedFrom(self, allocator, count, p);
}

pub fn chanceBatchCheckedFrom(source: anytype, allocator: std.mem.Allocator, count: usize, p: f64) ![]bool {
    return chanceBatchFrom(source, allocator, count, p);
}

pub fn fillChanceFrom(source: anytype, dest: []bool, p: f64) void {
    if (dest.len == 0) return;
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
    if (dest.len == 0) return;
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    fillChanceFrom(source, dest, p);
}

pub fn fillRatio(self: Rng, dest: []bool, numerator: u32, denominator: u32) void {
    fillRatioFrom(self, dest, numerator, denominator);
}

pub fn ratioBatch(self: Rng, allocator: std.mem.Allocator, count: usize, numerator: u32, denominator: u32) ![]bool {
    return ratioBatchFrom(self, allocator, count, numerator, denominator);
}

pub fn ratioBatchFrom(source: anytype, allocator: std.mem.Allocator, count: usize, numerator: u32, denominator: u32) ![]bool {
    if (count == 0) return allocator.alloc(bool, 0);
    if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
    const out = try allocator.alloc(bool, count);
    errdefer allocator.free(out);
    fillRatioFrom(source, out, numerator, denominator);
    return out;
}

pub fn ratioBatchChecked(self: Rng, allocator: std.mem.Allocator, count: usize, numerator: u32, denominator: u32) ![]bool {
    return ratioBatchCheckedFrom(self, allocator, count, numerator, denominator);
}

pub fn ratioBatchCheckedFrom(source: anytype, allocator: std.mem.Allocator, count: usize, numerator: u32, denominator: u32) ![]bool {
    return ratioBatchFrom(source, allocator, count, numerator, denominator);
}

pub fn fillRatioFrom(source: anytype, dest: []bool, numerator: u32, denominator: u32) void {
    if (dest.len == 0) return;
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
    if (dest.len == 0) return;
    if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
    fillRatioFrom(source, dest, numerator, denominator);
}

pub fn fillVectorRange(self: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    fillVectorRangeFrom(self, VectorType, dest, min, max);
}

pub fn fillVectorRangeAtMost(self: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    fillVectorRangeAtMostFrom(self, VectorType, dest, min, max);
}

pub fn vectorRangeBatch(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, min: vectorChild(VectorType), max: vectorChild(VectorType)) ![]VectorType {
    return vectorRangeBatchFrom(self, VectorType, allocator, count, min, max);
}

pub fn vectorRangeAtMostBatch(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, min: vectorChild(VectorType), max: vectorChild(VectorType)) ![]VectorType {
    return vectorRangeAtMostBatchFrom(self, VectorType, allocator, count, min, max);
}

pub fn vectorRangeBatchFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, min: vectorChild(VectorType), max: vectorChild(VectorType)) ![]VectorType {
    const out = try allocator.alloc(VectorType, count);
    errdefer allocator.free(out);
    fillVectorRangeFrom(source, VectorType, out, min, max);
    return out;
}

pub fn vectorRangeAtMostBatchFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, min: vectorChild(VectorType), max: vectorChild(VectorType)) ![]VectorType {
    const out = try allocator.alloc(VectorType, count);
    errdefer allocator.free(out);
    fillVectorRangeAtMostFrom(source, VectorType, out, min, max);
    return out;
}

pub fn fillVectorOpen(self: Rng, comptime VectorType: type, dest: []VectorType) void {
    fillVectorOpenFrom(self, VectorType, dest);
}

pub fn vectorOpenBatch(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize) ![]VectorType {
    return vectorOpenBatchFrom(self, VectorType, allocator, count);
}

pub fn vectorOpenBatchFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize) ![]VectorType {
    const out = try allocator.alloc(VectorType, count);
    errdefer allocator.free(out);
    fillVectorOpenFrom(source, VectorType, out);
    return out;
}

pub fn fillVectorOpenClosed(self: Rng, comptime VectorType: type, dest: []VectorType) void {
    fillVectorOpenClosedFrom(self, VectorType, dest);
}

pub fn vectorOpenClosedBatch(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize) ![]VectorType {
    return vectorOpenClosedBatchFrom(self, VectorType, allocator, count);
}

pub fn vectorOpenClosedBatchFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize) ![]VectorType {
    const out = try allocator.alloc(VectorType, count);
    errdefer allocator.free(out);
    fillVectorOpenClosedFrom(source, VectorType, out);
    return out;
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
    if (dest.len == 0) return;
    const info = vectorInfo(VectorType);
    if (@typeInfo(info.child) == .int and exclusiveIntRangeHasSingleValue(info.child, min, max)) {
        @memset(dest, @as(VectorType, @splat(min)));
        return;
    }
    if (@typeInfo(info.child) == .float and min == max) {
        @memset(dest, @as(VectorType, @splat(min)));
        return;
    }
    for (dest) |*item| item.* = vectorRangeFrom(source, VectorType, min, max);
}

pub fn fillVectorRangeAtMostFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) void {
    if (dest.len == 0) return;
    const info = vectorInfo(VectorType);
    if (@typeInfo(info.child) != .int) @compileError("Rng.fillVectorRangeAtMostFrom supports integer vectors");
    std.debug.assert(min <= max);
    if (min == max) {
        @memset(dest, @as(VectorType, @splat(min)));
        return;
    }
    for (dest) |*item| item.* = vectorRangeAtMostFrom(source, VectorType, min, max);
}

pub fn fillVectorRangeChecked(self: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    return fillVectorRangeCheckedFrom(self, VectorType, dest, min, max);
}

pub fn fillVectorRangeAtMostChecked(self: Rng, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    return fillVectorRangeAtMostCheckedFrom(self, VectorType, dest, min, max);
}

pub fn vectorRangeBatchChecked(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, min: vectorChild(VectorType), max: vectorChild(VectorType)) ![]VectorType {
    return vectorRangeBatchCheckedFrom(self, VectorType, allocator, count, min, max);
}

pub fn vectorRangeAtMostBatchChecked(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, min: vectorChild(VectorType), max: vectorChild(VectorType)) ![]VectorType {
    return vectorRangeAtMostBatchCheckedFrom(self, VectorType, allocator, count, min, max);
}

pub fn vectorRangeBatchCheckedFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, min: vectorChild(VectorType), max: vectorChild(VectorType)) ![]VectorType {
    if (count == 0) return allocator.alloc(VectorType, 0);
    const info = vectorInfo(VectorType);
    switch (@typeInfo(info.child)) {
        .int => {
            if (min >= max) return error.EmptyRange;
        },
        .float => {
            try validateFloatRangeParams(info.child, min, max, true);
        },
        else => @compileError("Rng.vectorRangeBatchChecked supports integer and floating-point vectors"),
    }
    return vectorRangeBatchFrom(source, VectorType, allocator, count, min, max);
}

pub fn vectorRangeAtMostBatchCheckedFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, min: vectorChild(VectorType), max: vectorChild(VectorType)) ![]VectorType {
    if (count == 0) return allocator.alloc(VectorType, 0);
    const info = vectorInfo(VectorType);
    if (@typeInfo(info.child) != .int) @compileError("Rng.vectorRangeAtMostBatchChecked supports integer vectors");
    if (min > max) return error.EmptyRange;
    return vectorRangeAtMostBatchFrom(source, VectorType, allocator, count, min, max);
}

pub fn fillVectorRangeCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    const info = vectorInfo(VectorType);
    if (dest.len == 0) return;
    switch (@typeInfo(info.child)) {
        .int => {
            if (min >= max) return error.EmptyRange;
        },
        .float => {
            try validateFloatRangeParams(info.child, min, max, true);
        },
        else => @compileError("Rng.fillVectorRangeChecked supports integer and floating-point vectors"),
    }
    fillVectorRangeFrom(source, VectorType, dest, min, max);
}

pub fn fillVectorRangeAtMostCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!void {
    if (dest.len == 0) return;
    const info = vectorInfo(VectorType);
    if (@typeInfo(info.child) != .int) @compileError("Rng.fillVectorRangeAtMostChecked supports integer vectors");
    if (min > max) return error.EmptyRange;
    fillVectorRangeAtMostFrom(source, VectorType, dest, min, max);
}

pub fn fillVectorChance(self: Rng, comptime VectorType: type, dest: []VectorType, p: f64) void {
    fillVectorChanceFrom(self, VectorType, dest, p);
}

pub fn vectorChanceBatch(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, p: f64) ![]VectorType {
    return vectorChanceBatchFrom(self, VectorType, allocator, count, p);
}

pub fn vectorChanceBatchFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, p: f64) ![]VectorType {
    const out = try allocator.alloc(VectorType, count);
    errdefer allocator.free(out);
    fillVectorChanceFrom(source, VectorType, out, p);
    return out;
}

pub fn fillVectorChanceFrom(source: anytype, comptime VectorType: type, dest: []VectorType, p: f64) void {
    if (dest.len == 0) return;
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("Rng.fillVectorChance expects a bool vector");
    std.debug.assert(p >= 0 and p <= 1);
    if (p == 0) {
        @memset(dest, @as(VectorType, @splat(false)));
        return;
    }
    if (p == 1) {
        @memset(dest, @as(VectorType, @splat(true)));
        return;
    }
    for (dest) |*item| item.* = vectorChanceFrom(source, VectorType, p);
}

pub fn fillVectorChanceChecked(self: Rng, comptime VectorType: type, dest: []VectorType, p: f64) Error!void {
    return fillVectorChanceCheckedFrom(self, VectorType, dest, p);
}

pub fn vectorChanceBatchChecked(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, p: f64) ![]VectorType {
    return vectorChanceBatchCheckedFrom(self, VectorType, allocator, count, p);
}

pub fn vectorChanceBatchCheckedFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, p: f64) ![]VectorType {
    if (count == 0) return allocator.alloc(VectorType, 0);
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("Rng.vectorChanceBatchChecked expects a bool vector");
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    return vectorChanceBatchFrom(source, VectorType, allocator, count, p);
}

pub fn fillVectorChanceCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, p: f64) Error!void {
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("Rng.fillVectorChanceChecked expects a bool vector");
    if (dest.len == 0) return;
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    fillVectorChanceFrom(source, VectorType, dest, p);
}

pub fn fillVectorRatio(self: Rng, comptime VectorType: type, dest: []VectorType, numerator: u32, denominator: u32) void {
    fillVectorRatioFrom(self, VectorType, dest, numerator, denominator);
}

pub fn vectorRatioBatch(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, numerator: u32, denominator: u32) ![]VectorType {
    return vectorRatioBatchFrom(self, VectorType, allocator, count, numerator, denominator);
}

pub fn vectorRatioBatchFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, numerator: u32, denominator: u32) ![]VectorType {
    const out = try allocator.alloc(VectorType, count);
    errdefer allocator.free(out);
    fillVectorRatioFrom(source, VectorType, out, numerator, denominator);
    return out;
}

pub fn fillVectorRatioFrom(source: anytype, comptime VectorType: type, dest: []VectorType, numerator: u32, denominator: u32) void {
    if (dest.len == 0) return;
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("Rng.fillVectorRatio expects a bool vector");
    std.debug.assert(denominator > 0 and numerator <= denominator);
    if (numerator == 0) {
        @memset(dest, @as(VectorType, @splat(false)));
        return;
    }
    if (numerator == denominator) {
        @memset(dest, @as(VectorType, @splat(true)));
        return;
    }
    for (dest) |*item| item.* = vectorRatioFrom(source, VectorType, numerator, denominator);
}

pub fn fillVectorRatioChecked(self: Rng, comptime VectorType: type, dest: []VectorType, numerator: u32, denominator: u32) Error!void {
    return fillVectorRatioCheckedFrom(self, VectorType, dest, numerator, denominator);
}

pub fn vectorRatioBatchChecked(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, numerator: u32, denominator: u32) ![]VectorType {
    return vectorRatioBatchCheckedFrom(self, VectorType, allocator, count, numerator, denominator);
}

pub fn vectorRatioBatchCheckedFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, numerator: u32, denominator: u32) ![]VectorType {
    if (count == 0) return allocator.alloc(VectorType, 0);
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("Rng.vectorRatioBatchChecked expects a bool vector");
    if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
    return vectorRatioBatchFrom(source, VectorType, allocator, count, numerator, denominator);
}

pub fn fillVectorRatioCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, numerator: u32, denominator: u32) Error!void {
    const info = vectorInfo(VectorType);
    if (info.child != bool) @compileError("Rng.fillVectorRatioChecked expects a bool vector");
    if (dest.len == 0) return;
    if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
    fillVectorRatioFrom(source, VectorType, dest, numerator, denominator);
}

pub fn fillStandardNormal(self: Rng, comptime T: type, dest: []T) void {
    fillStandardNormalFrom(self, T, dest);
}

pub fn standardNormalBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize) ![]T {
    return standardNormalBatchFrom(self, T, allocator, count);
}

pub fn standardNormalBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    fillStandardNormalFrom(source, T, out);
    return out;
}

pub fn fillStandardNormalFrom(source: anytype, comptime T: type, dest: []T) void {
    comptime requireFloat(T);
    for (dest) |*item| item.* = standardNormalFastFrom(source, T);
}

pub fn fillVectorStandardNormal(self: Rng, comptime VectorType: type, dest: []VectorType) void {
    fillVectorStandardNormalFrom(self, VectorType, dest);
}

pub fn vectorStandardNormalBatch(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize) ![]VectorType {
    return vectorStandardNormalBatchFrom(self, VectorType, allocator, count);
}

pub fn vectorStandardNormalBatchFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize) ![]VectorType {
    const out = try allocator.alloc(VectorType, count);
    errdefer allocator.free(out);
    fillVectorStandardNormalFrom(source, VectorType, out);
    return out;
}

pub fn fillVectorStandardNormalFrom(source: anytype, comptime VectorType: type, dest: []VectorType) void {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    for (dest) |*item| item.* = vectorStandardNormalFrom(source, VectorType);
}

pub fn fillVectorNormal(self: Rng, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) void {
    fillVectorNormalFrom(self, VectorType, dest, mean, stddev);
}

pub fn vectorNormalBatch(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) ![]VectorType {
    return vectorNormalBatchFrom(self, VectorType, allocator, count, mean, stddev);
}

pub fn vectorNormalBatchFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) ![]VectorType {
    if (count == 0) return allocator.alloc(VectorType, 0);
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    if (!std.math.isFinite(mean) or !(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
    const out = try allocator.alloc(VectorType, count);
    errdefer allocator.free(out);
    fillVectorNormalFrom(source, VectorType, out, mean, stddev);
    return out;
}

pub fn fillVectorNormalFrom(source: anytype, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) void {
    if (dest.len == 0) return;
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    std.debug.assert(stddev >= 0);
    if (stddev == 0) {
        @memset(dest, @as(VectorType, @splat(mean)));
        return;
    }
    if (info.child == f32 or info.child == f64) {
        if (comptime @TypeOf(source) != Rng) {
            if (mean == 0 and stddev == 1) {
                fillVectorStandardNormalFrom(source, VectorType, dest);
                return;
            }
        }
        fillVectorNormalScalarFrom(source, VectorType, dest, mean, stddev);
        return;
    }
    for (dest) |*item| item.* = vectorNormalFrom(source, VectorType, mean, stddev);
}

pub fn fillVectorNormalChecked(self: Rng, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!void {
    return fillVectorNormalCheckedFrom(self, VectorType, dest, mean, stddev);
}

pub fn vectorNormalBatchChecked(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) ![]VectorType {
    return vectorNormalBatchCheckedFrom(self, VectorType, allocator, count, mean, stddev);
}

pub fn vectorNormalBatchCheckedFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) ![]VectorType {
    if (count == 0) return allocator.alloc(VectorType, 0);
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    if (!std.math.isFinite(mean) or !(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
    return vectorNormalBatchFrom(source, VectorType, allocator, count, mean, stddev);
}

pub fn fillVectorNormalCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, mean: vectorChild(VectorType), stddev: vectorChild(VectorType)) Error!void {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    if (dest.len == 0) return;
    if (!std.math.isFinite(mean) or !(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
    fillVectorNormalFrom(source, VectorType, dest, mean, stddev);
}

pub fn fillVectorExponential(self: Rng, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) void {
    fillVectorExponentialFrom(self, VectorType, dest, rate);
}

pub fn vectorExponentialBatch(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, rate: vectorChild(VectorType)) ![]VectorType {
    return vectorExponentialBatchFrom(self, VectorType, allocator, count, rate);
}

pub fn vectorExponentialBatchFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, rate: vectorChild(VectorType)) ![]VectorType {
    if (count == 0) return allocator.alloc(VectorType, 0);
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    if (!(rate > 0) or (!std.math.isFinite(rate) and rate != std.math.inf(info.child))) return error.InvalidParameter;
    const out = try allocator.alloc(VectorType, count);
    errdefer allocator.free(out);
    fillVectorExponentialFrom(source, VectorType, out, rate);
    return out;
}

pub fn fillVectorExponentialFrom(source: anytype, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) void {
    if (dest.len == 0) return;
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    std.debug.assert(rate > 0 and (std.math.isFinite(rate) or rate == std.math.inf(info.child)));
    if (rate == std.math.inf(info.child)) {
        @memset(dest, @as(VectorType, @splat(0)));
        return;
    }
    if (info.child == f32 or info.child == f64) {
        fillVectorExponentialScalarFrom(source, VectorType, dest, rate);
        return;
    }
    for (dest) |*item| item.* = vectorExponentialFrom(source, VectorType, rate);
}

pub fn fillVectorExponentialChecked(self: Rng, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) Error!void {
    return fillVectorExponentialCheckedFrom(self, VectorType, dest, rate);
}

pub fn vectorExponentialBatchChecked(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, rate: vectorChild(VectorType)) ![]VectorType {
    return vectorExponentialBatchCheckedFrom(self, VectorType, allocator, count, rate);
}

pub fn vectorExponentialBatchCheckedFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize, rate: vectorChild(VectorType)) ![]VectorType {
    if (count == 0) return allocator.alloc(VectorType, 0);
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    if (!(rate > 0) or (!std.math.isFinite(rate) and rate != std.math.inf(info.child))) return error.InvalidParameter;
    return vectorExponentialBatchFrom(source, VectorType, allocator, count, rate);
}

pub fn fillVectorExponentialCheckedFrom(source: anytype, comptime VectorType: type, dest: []VectorType, rate: vectorChild(VectorType)) Error!void {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    if (dest.len == 0) return;
    if (!(rate > 0) or (!std.math.isFinite(rate) and rate != std.math.inf(info.child))) return error.InvalidParameter;
    fillVectorExponentialFrom(source, VectorType, dest, rate);
}

pub fn fillStandardExponential(self: Rng, comptime T: type, dest: []T) void {
    fillStandardExponentialFrom(self, T, dest);
}

pub fn standardExponentialBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize) ![]T {
    return standardExponentialBatchFrom(self, T, allocator, count);
}

pub fn standardExponentialBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    fillStandardExponentialFrom(source, T, out);
    return out;
}

pub fn fillStandardExponentialFrom(source: anytype, comptime T: type, dest: []T) void {
    comptime requireFloat(T);
    for (dest) |*item| item.* = standardExponentialFastFrom(source, T);
}

pub fn fillVectorStandardExponential(self: Rng, comptime VectorType: type, dest: []VectorType) void {
    fillVectorStandardExponentialFrom(self, VectorType, dest);
}

pub fn vectorStandardExponentialBatch(self: Rng, comptime VectorType: type, allocator: std.mem.Allocator, count: usize) ![]VectorType {
    return vectorStandardExponentialBatchFrom(self, VectorType, allocator, count);
}

pub fn vectorStandardExponentialBatchFrom(source: anytype, comptime VectorType: type, allocator: std.mem.Allocator, count: usize) ![]VectorType {
    const out = try allocator.alloc(VectorType, count);
    errdefer allocator.free(out);
    fillVectorStandardExponentialFrom(source, VectorType, out);
    return out;
}

pub fn fillVectorStandardExponentialFrom(source: anytype, comptime VectorType: type, dest: []VectorType) void {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    for (dest) |*item| item.* = vectorStandardExponentialFrom(source, VectorType);
}

pub fn fillNormal(self: Rng, comptime T: type, dest: []T, mean: T, stddev: T) void {
    fillNormalFrom(self, T, dest, mean, stddev);
}

pub fn normalBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, mean: T, stddev: T) ![]T {
    return normalBatchFrom(self, T, allocator, count, mean, stddev);
}

pub fn normalBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, mean: T, stddev: T) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    comptime requireFloat(T);
    if (!std.math.isFinite(mean) or !(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    fillNormalFrom(source, T, out, mean, stddev);
    return out;
}

pub fn normalBatchChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, mean: T, stddev: T) ![]T {
    return normalBatchCheckedFrom(self, T, allocator, count, mean, stddev);
}

pub fn normalBatchCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, mean: T, stddev: T) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    comptime requireFloat(T);
    if (!std.math.isFinite(mean) or !(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
    return normalBatchFrom(source, T, allocator, count, mean, stddev);
}

pub fn fillNormalFrom(source: anytype, comptime T: type, dest: []T, mean: T, stddev: T) void {
    if (dest.len == 0) return;
    comptime requireFloat(T);
    std.debug.assert(stddev >= 0);
    if (stddev == 0) {
        @memset(dest, mean);
        return;
    }
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
    if (dest.len == 0) return;
    if (!std.math.isFinite(mean) or !(stddev >= 0) or !std.math.isFinite(stddev)) return error.InvalidParameter;
    fillNormalFrom(source, T, dest, mean, stddev);
}

pub fn fillExponential(self: Rng, comptime T: type, dest: []T, rate: T) void {
    fillExponentialFrom(self, T, dest, rate);
}

pub fn exponentialBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, rate: T) ![]T {
    return exponentialBatchFrom(self, T, allocator, count, rate);
}

pub fn exponentialBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, rate: T) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    comptime requireFloat(T);
    if (!(rate > 0) or (!std.math.isFinite(rate) and rate != std.math.inf(T))) return error.InvalidParameter;
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    fillExponentialFrom(source, T, out, rate);
    return out;
}

pub fn exponentialBatchChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, rate: T) ![]T {
    return exponentialBatchCheckedFrom(self, T, allocator, count, rate);
}

pub fn exponentialBatchCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, rate: T) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    comptime requireFloat(T);
    if (!(rate > 0) or (!std.math.isFinite(rate) and rate != std.math.inf(T))) return error.InvalidParameter;
    return exponentialBatchFrom(source, T, allocator, count, rate);
}

pub fn fillExponentialFrom(source: anytype, comptime T: type, dest: []T, rate: T) void {
    if (dest.len == 0) return;
    comptime requireFloat(T);
    std.debug.assert(rate > 0 and (std.math.isFinite(rate) or rate == std.math.inf(T)));
    if (rate == std.math.inf(T)) {
        @memset(dest, 0);
        return;
    }
    for (dest) |*item| item.* = exponentialFastFrom(source, T, rate);
}

pub fn fillExponentialChecked(self: Rng, comptime T: type, dest: []T, rate: T) Error!void {
    return fillExponentialCheckedFrom(self, T, dest, rate);
}

pub fn fillExponentialCheckedFrom(source: anytype, comptime T: type, dest: []T, rate: T) Error!void {
    comptime requireFloat(T);
    if (dest.len == 0) return;
    if (!(rate > 0) or (!std.math.isFinite(rate) and rate != std.math.inf(T))) return error.InvalidParameter;
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

pub fn fillBytesFrom(source: anytype, buf: []u8) void {
    if (@TypeOf(source) == Rng) {
        source.bytes(buf);
    } else {
        source.fill(buf);
    }
}

fn fillSourceBytesFrom(source: anytype, buf: []u8) !void {
    if (comptime sourceCanTryFillBytes(@TypeOf(source))) {
        return source.tryFillBytes(buf);
    }
    if (comptime sourceCanFillBytes(@TypeOf(source))) {
        fillBytesFrom(source, buf);
        return;
    }

    var i: usize = 0;
    while (i < buf.len) {
        const word = try tryNextU64From(source);
        var word_bytes: [8]u8 = undefined;
        std.mem.writeInt(u64, &word_bytes, word, .little);
        const n = @min(8, buf.len - i);
        @memcpy(buf[i..][0..n], word_bytes[0..n]);
        i += n;
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

fn sourceCanTryFillBytes(comptime Source: type) bool {
    if (Source == Rng) return true;
    const info = @typeInfo(Source);
    if (info == .pointer and info.pointer.size == .one) {
        return @hasDecl(info.pointer.child, "tryFillBytes");
    }
    return @hasDecl(Source, "tryFillBytes");
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

pub fn nextU64(self: Rng) u64 {
    return self.next();
}

pub fn tryNextU64(self: Rng) !u64 {
    return self.nextU64();
}

pub fn tryNextU64From(source: anytype) !u64 {
    if (@TypeOf(source) == Rng) return source.tryNextU64();
    if (comptime sourceCanTryNextU64(@TypeOf(source))) return source.tryNextU64();
    if (comptime sourceCanTryNext(@TypeOf(source))) return source.tryNext();
    return nextFrom(source);
}

pub fn nextU64From(source: anytype) u64 {
    return nextFrom(source);
}

pub fn nextU32(self: Rng) u32 {
    return self.nextU32Fn(self.ptr);
}

pub fn tryNextU32(self: Rng) !u32 {
    return self.nextU32();
}

pub fn tryNextU32From(source: anytype) !u32 {
    if (@TypeOf(source) == Rng) return source.tryNextU32();
    if (comptime sourceCanTryNextU32(@TypeOf(source))) return source.tryNextU32();
    return @truncate((try tryNextU64From(source)) >> 32);
}

pub fn nextU32From(source: anytype) u32 {
    if (@TypeOf(source) == Rng) return source.nextU32();
    if (comptime sourceCanNextU32(@TypeOf(source))) return source.nextU32();
    return @truncate(nextFrom(source) >> 32);
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

pub fn randomBool(self: Rng, p: f64) bool {
    return chance(self, p);
}

pub fn chanceFrom(source: anytype, p: f64) bool {
    std.debug.assert(p >= 0 and p <= 1);
    if (p == 0) return false;
    if (p == 1) return true;
    return nextFrom(source) < probabilityThreshold(p);
}

pub fn randomBoolFrom(source: anytype, p: f64) bool {
    return chanceFrom(source, p);
}

pub fn chanceChecked(self: Rng, p: f64) Error!bool {
    return chanceCheckedFrom(self, p);
}

pub fn randomBoolChecked(self: Rng, p: f64) Error!bool {
    return chanceChecked(self, p);
}

pub fn chanceCheckedFrom(source: anytype, p: f64) Error!bool {
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    return chanceFrom(source, p);
}

pub fn randomBoolCheckedFrom(source: anytype, p: f64) Error!bool {
    return chanceCheckedFrom(source, p);
}

pub fn ratio(self: Rng, numerator: u32, denominator: u32) bool {
    return ratioFrom(self, numerator, denominator);
}

pub fn randomRatio(self: Rng, numerator: u32, denominator: u32) bool {
    return ratio(self, numerator, denominator);
}

pub fn ratioFrom(source: anytype, numerator: u32, denominator: u32) bool {
    std.debug.assert(denominator > 0 and numerator <= denominator);
    if (numerator == 0) return false;
    if (numerator == denominator) return true;
    return uintLessThanFrom(source, u32, denominator) < numerator;
}

pub fn randomRatioFrom(source: anytype, numerator: u32, denominator: u32) bool {
    return ratioFrom(source, numerator, denominator);
}

pub fn ratioChecked(self: Rng, numerator: u32, denominator: u32) Error!bool {
    return ratioCheckedFrom(self, numerator, denominator);
}

pub fn randomRatioChecked(self: Rng, numerator: u32, denominator: u32) Error!bool {
    return ratioChecked(self, numerator, denominator);
}

pub fn ratioCheckedFrom(source: anytype, numerator: u32, denominator: u32) Error!bool {
    if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
    return ratioFrom(source, numerator, denominator);
}

pub fn randomRatioCheckedFrom(source: anytype, numerator: u32, denominator: u32) Error!bool {
    return ratioCheckedFrom(source, numerator, denominator);
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
    if (less_than == 1) return 0;

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
    if (at_most == 0) return 0;
    if (at_most == std.math.maxInt(T)) return uintFrom(source, T);
    return uintLessThanFrom(source, T, at_most + 1);
}

pub fn intRangeLessThan(self: Rng, comptime T: type, at_least: T, less_than: T) T {
    return intRangeLessThanFrom(self, T, at_least, less_than);
}

pub fn randomRange(self: Rng, comptime T: type, min: T, max: T) T {
    return rangeFrom(self, T, min, max);
}

pub fn randomRangeFrom(source: anytype, comptime T: type, min: T, max: T) T {
    return rangeFrom(source, T, min, max);
}

pub fn randomRangeChecked(self: Rng, comptime T: type, min: T, max: T) Error!T {
    return rangeCheckedFrom(self, T, min, max);
}

pub fn randomRangeCheckedFrom(source: anytype, comptime T: type, min: T, max: T) Error!T {
    return rangeCheckedFrom(source, T, min, max);
}

pub fn randomRangeAtMost(self: Rng, comptime T: type, min: T, max: T) T {
    return rangeAtMostFrom(self, T, min, max);
}

pub fn randomRangeAtMostFrom(source: anytype, comptime T: type, min: T, max: T) T {
    return rangeAtMostFrom(source, T, min, max);
}

pub fn randomRangeAtMostChecked(self: Rng, comptime T: type, min: T, max: T) Error!T {
    return rangeAtMostCheckedFrom(self, T, min, max);
}

pub fn randomRangeAtMostCheckedFrom(source: anytype, comptime T: type, min: T, max: T) Error!T {
    return rangeAtMostCheckedFrom(source, T, min, max);
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
    if (exclusiveIntRangeHasSingleValue(T, at_least, less_than)) return at_least;

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
    if (at_least == at_most) return at_least;

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

fn rangeFrom(source: anytype, comptime T: type, min: T, max: T) T {
    return switch (@typeInfo(T)) {
        .int => intRangeLessThanFrom(source, T, min, max),
        .float => floatRangeFrom(source, T, min, max),
        else => @compileError("Rng.rangeFrom supports integer and floating-point types"),
    };
}

fn rangeCheckedFrom(source: anytype, comptime T: type, min: T, max: T) Error!T {
    return switch (@typeInfo(T)) {
        .int => intRangeLessThanCheckedFrom(source, T, min, max),
        .float => floatRangeCheckedFrom(source, T, min, max),
        else => @compileError("Rng.rangeCheckedFrom supports integer and floating-point types"),
    };
}

fn rangeAtMostFrom(source: anytype, comptime T: type, min: T, max: T) T {
    return switch (@typeInfo(T)) {
        .int => intRangeAtMostFrom(source, T, min, max),
        else => @compileError("Rng.rangeAtMostFrom supports integer types"),
    };
}

fn rangeAtMostCheckedFrom(source: anytype, comptime T: type, min: T, max: T) Error!T {
    return switch (@typeInfo(T)) {
        .int => intRangeAtMostCheckedFrom(source, T, min, max),
        else => @compileError("Rng.rangeAtMostCheckedFrom supports integer types"),
    };
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
    try validateFloatRangeParams(T, min, max, true);
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

pub fn vectorRangeAtMost(self: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    return vectorRangeAtMostFrom(self, VectorType, min, max);
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
            if (exclusiveIntRangeHasSingleValue(info.child, min, max)) return @splat(min);
            var out: VectorType = undefined;
            inline for (0..info.len) |i| out[i] = intRangeLessThanFrom(source, info.child, min, max);
            return out;
        },
        .float => {
            std.debug.assert(min <= max);
            if (min == max) return @splat(min);
            return @as(VectorType, @splat(min)) + (@as(VectorType, @splat(max)) - @as(VectorType, @splat(min))) * vectorFrom(source, VectorType);
        },
        else => @compileError("Rng.vectorRange supports integer and floating-point vectors"),
    }
}

pub fn vectorRangeAtMostFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) VectorType {
    const info = vectorInfo(VectorType);
    if (@typeInfo(info.child) != .int) @compileError("Rng.vectorRangeAtMost supports integer vectors");
    std.debug.assert(min <= max);
    if (min == max) return @splat(min);
    var out: VectorType = undefined;
    inline for (0..info.len) |i| out[i] = intRangeAtMostFrom(source, info.child, min, max);
    return out;
}

fn exclusiveIntRangeHasSingleValue(comptime T: type, min: T, max: T) bool {
    comptime requireInt(T);
    const info = @typeInfo(T).int;
    if (info.signedness == .signed) {
        const Unsigned = std.meta.Int(.unsigned, info.bits);
        const lo: Unsigned = @bitCast(min);
        const hi: Unsigned = @bitCast(max);
        return hi -% lo == 1;
    }
    return max - min == 1;
}

pub fn vectorRangeChecked(self: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    return vectorRangeCheckedFrom(self, VectorType, min, max);
}

pub fn vectorRangeAtMostChecked(self: Rng, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    return vectorRangeAtMostCheckedFrom(self, VectorType, min, max);
}

pub fn vectorRangeCheckedFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    const info = vectorInfo(VectorType);
    switch (@typeInfo(info.child)) {
        .int => {
            if (min >= max) return error.EmptyRange;
        },
        .float => {
            try validateFloatRangeParams(info.child, min, max, true);
        },
        else => @compileError("Rng.vectorRangeChecked supports integer and floating-point vectors"),
    }
    return vectorRangeFrom(source, VectorType, min, max);
}

pub fn vectorRangeAtMostCheckedFrom(source: anytype, comptime VectorType: type, min: vectorChild(VectorType), max: vectorChild(VectorType)) Error!VectorType {
    const info = vectorInfo(VectorType);
    if (@typeInfo(info.child) != .int) @compileError("Rng.vectorRangeAtMostChecked supports integer vectors");
    if (min > max) return error.EmptyRange;
    return vectorRangeAtMostFrom(source, VectorType, min, max);
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
    if (stddev == 0) return @splat(mean);
    if (info.child == f32 or info.child == f64) {
        if (comptime @TypeOf(source) != Rng) {
            if (mean == 0 and stddev == 1) return vectorStandardNormalFrom(source, VectorType);
        }
        return vectorNormalScalarFrom(source, VectorType, mean, stddev);
    }
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
    if (!(rate > 0) or (!std.math.isFinite(rate) and rate != std.math.inf(info.child))) return error.InvalidParameter;
    return vectorExponentialFrom(source, VectorType, rate);
}

pub fn vectorExponentialFrom(source: anytype, comptime VectorType: type, rate: vectorChild(VectorType)) VectorType {
    const info = vectorInfo(VectorType);
    comptime requireFloat(info.child);
    std.debug.assert(rate > 0 and (std.math.isFinite(rate) or rate == std.math.inf(info.child)));
    if (rate == std.math.inf(info.child)) return @splat(0);
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

pub fn durationRangeLessThanBatch(self: Rng, allocator: std.mem.Allocator, count: usize, min: std.Io.Duration, max: std.Io.Duration) ![]std.Io.Duration {
    return durationRangeLessThanBatchFrom(self, allocator, count, min, max);
}

pub fn durationRangeLessThanBatchFrom(source: anytype, allocator: std.mem.Allocator, count: usize, min: std.Io.Duration, max: std.Io.Duration) ![]std.Io.Duration {
    const out = try allocator.alloc(std.Io.Duration, count);
    errdefer allocator.free(out);
    for (out) |*item| item.* = durationRangeLessThanFrom(source, min, max);
    return out;
}

pub fn durationRangeLessThanFrom(source: anytype, min: std.Io.Duration, max: std.Io.Duration) std.Io.Duration {
    std.debug.assert(min.nanoseconds < max.nanoseconds);
    return .{ .nanoseconds = intRangeLessThanFrom(source, i96, min.nanoseconds, max.nanoseconds) };
}

pub fn durationRangeAtMost(self: Rng, min: std.Io.Duration, max: std.Io.Duration) std.Io.Duration {
    return durationRangeAtMostFrom(self, min, max);
}

pub fn durationRangeAtMostBatch(self: Rng, allocator: std.mem.Allocator, count: usize, min: std.Io.Duration, max: std.Io.Duration) ![]std.Io.Duration {
    return durationRangeAtMostBatchFrom(self, allocator, count, min, max);
}

pub fn durationRangeAtMostBatchFrom(source: anytype, allocator: std.mem.Allocator, count: usize, min: std.Io.Duration, max: std.Io.Duration) ![]std.Io.Duration {
    const out = try allocator.alloc(std.Io.Duration, count);
    errdefer allocator.free(out);
    for (out) |*item| item.* = durationRangeAtMostFrom(source, min, max);
    return out;
}

pub fn durationRangeAtMostFrom(source: anytype, min: std.Io.Duration, max: std.Io.Duration) std.Io.Duration {
    std.debug.assert(min.nanoseconds <= max.nanoseconds);
    return .{ .nanoseconds = intRangeAtMostFrom(source, i96, min.nanoseconds, max.nanoseconds) };
}

pub fn durationRangeLessThanChecked(self: Rng, min: std.Io.Duration, max: std.Io.Duration) Error!std.Io.Duration {
    return durationRangeLessThanCheckedFrom(self, min, max);
}

pub fn durationRangeLessThanBatchChecked(self: Rng, allocator: std.mem.Allocator, count: usize, min: std.Io.Duration, max: std.Io.Duration) ![]std.Io.Duration {
    return durationRangeLessThanBatchCheckedFrom(self, allocator, count, min, max);
}

pub fn durationRangeLessThanBatchCheckedFrom(source: anytype, allocator: std.mem.Allocator, count: usize, min: std.Io.Duration, max: std.Io.Duration) ![]std.Io.Duration {
    if (count == 0) return allocator.alloc(std.Io.Duration, 0);
    if (min.nanoseconds >= max.nanoseconds) return error.EmptyRange;
    return durationRangeLessThanBatchFrom(source, allocator, count, min, max);
}

pub fn durationRangeLessThanCheckedFrom(source: anytype, min: std.Io.Duration, max: std.Io.Duration) Error!std.Io.Duration {
    if (min.nanoseconds >= max.nanoseconds) return error.EmptyRange;
    return durationRangeLessThanFrom(source, min, max);
}

pub fn durationRangeAtMostChecked(self: Rng, min: std.Io.Duration, max: std.Io.Duration) Error!std.Io.Duration {
    return durationRangeAtMostCheckedFrom(self, min, max);
}

pub fn durationRangeAtMostBatchChecked(self: Rng, allocator: std.mem.Allocator, count: usize, min: std.Io.Duration, max: std.Io.Duration) ![]std.Io.Duration {
    return durationRangeAtMostBatchCheckedFrom(self, allocator, count, min, max);
}

pub fn durationRangeAtMostBatchCheckedFrom(source: anytype, allocator: std.mem.Allocator, count: usize, min: std.Io.Duration, max: std.Io.Duration) ![]std.Io.Duration {
    if (count == 0) return allocator.alloc(std.Io.Duration, 0);
    if (min.nanoseconds > max.nanoseconds) return error.EmptyRange;
    return durationRangeAtMostBatchFrom(source, allocator, count, min, max);
}

pub fn durationRangeAtMostCheckedFrom(source: anytype, min: std.Io.Duration, max: std.Io.Duration) Error!std.Io.Duration {
    if (min.nanoseconds > max.nanoseconds) return error.EmptyRange;
    return durationRangeAtMostFrom(source, min, max);
}

pub fn unicodeScalar(self: Rng) u21 {
    return unicodeScalarFrom(self);
}

pub fn unicodeScalarRangeLessThan(self: Rng, min: u21, less_than: u21) u21 {
    return unicodeScalarRangeLessThanFrom(self, min, less_than);
}

pub fn unicodeScalarRangeAtMost(self: Rng, min: u21, at_most: u21) u21 {
    return unicodeScalarRangeAtMostFrom(self, min, at_most);
}

pub fn unicodeScalarRangeLessThanChecked(self: Rng, min: u21, less_than: u21) Error!u21 {
    return unicodeScalarRangeLessThanCheckedFrom(self, min, less_than);
}

pub fn unicodeScalarRangeAtMostChecked(self: Rng, min: u21, at_most: u21) Error!u21 {
    return unicodeScalarRangeAtMostCheckedFrom(self, min, at_most);
}

pub fn fillUnicodeScalar(self: Rng, dest: []u21) void {
    fillUnicodeScalarFrom(self, dest);
}

pub fn fillUnicodeScalarRangeLessThan(self: Rng, dest: []u21, min: u21, less_than: u21) void {
    fillUnicodeScalarRangeLessThanFrom(self, dest, min, less_than);
}

pub fn fillUnicodeScalarRangeAtMost(self: Rng, dest: []u21, min: u21, at_most: u21) void {
    fillUnicodeScalarRangeAtMostFrom(self, dest, min, at_most);
}

pub fn fillUnicodeScalarRangeLessThanChecked(self: Rng, dest: []u21, min: u21, less_than: u21) Error!void {
    return fillUnicodeScalarRangeLessThanCheckedFrom(self, dest, min, less_than);
}

pub fn fillUnicodeScalarRangeAtMostChecked(self: Rng, dest: []u21, min: u21, at_most: u21) Error!void {
    return fillUnicodeScalarRangeAtMostCheckedFrom(self, dest, min, at_most);
}

pub fn unicodeScalarBatch(self: Rng, allocator: std.mem.Allocator, count: usize) ![]u21 {
    return unicodeScalarBatchFrom(self, allocator, count);
}

pub fn unicodeScalarRangeLessThanBatch(self: Rng, allocator: std.mem.Allocator, count: usize, min: u21, less_than: u21) ![]u21 {
    return unicodeScalarRangeLessThanBatchFrom(self, allocator, count, min, less_than);
}

pub fn unicodeScalarRangeAtMostBatch(self: Rng, allocator: std.mem.Allocator, count: usize, min: u21, at_most: u21) ![]u21 {
    return unicodeScalarRangeAtMostBatchFrom(self, allocator, count, min, at_most);
}

pub fn unicodeScalarRangeLessThanBatchChecked(self: Rng, allocator: std.mem.Allocator, count: usize, min: u21, less_than: u21) ![]u21 {
    return unicodeScalarRangeLessThanBatchCheckedFrom(self, allocator, count, min, less_than);
}

pub fn unicodeScalarRangeAtMostBatchChecked(self: Rng, allocator: std.mem.Allocator, count: usize, min: u21, at_most: u21) ![]u21 {
    return unicodeScalarRangeAtMostBatchCheckedFrom(self, allocator, count, min, at_most);
}

pub fn unicodeScalarBatchFrom(source: anytype, allocator: std.mem.Allocator, count: usize) ![]u21 {
    const out = try allocator.alloc(u21, count);
    errdefer allocator.free(out);
    fillUnicodeScalarFrom(source, out);
    return out;
}

pub fn unicodeScalarRangeLessThanBatchFrom(source: anytype, allocator: std.mem.Allocator, count: usize, min: u21, less_than: u21) ![]u21 {
    const out = try allocator.alloc(u21, count);
    errdefer allocator.free(out);
    fillUnicodeScalarRangeLessThanFrom(source, out, min, less_than);
    return out;
}

pub fn unicodeScalarRangeAtMostBatchFrom(source: anytype, allocator: std.mem.Allocator, count: usize, min: u21, at_most: u21) ![]u21 {
    const out = try allocator.alloc(u21, count);
    errdefer allocator.free(out);
    fillUnicodeScalarRangeAtMostFrom(source, out, min, at_most);
    return out;
}

pub fn unicodeScalarRangeLessThanBatchCheckedFrom(source: anytype, allocator: std.mem.Allocator, count: usize, min: u21, less_than: u21) ![]u21 {
    if (count == 0) return allocator.alloc(u21, 0);
    _ = try unicodeScalarExclusiveRange(min, less_than);
    return unicodeScalarRangeLessThanBatchFrom(source, allocator, count, min, less_than);
}

pub fn unicodeScalarRangeAtMostBatchCheckedFrom(source: anytype, allocator: std.mem.Allocator, count: usize, min: u21, at_most: u21) ![]u21 {
    if (count == 0) return allocator.alloc(u21, 0);
    _ = try unicodeScalarInclusiveRange(min, at_most);
    return unicodeScalarRangeAtMostBatchFrom(source, allocator, count, min, at_most);
}

pub fn unicodeScalarFrom(source: anytype) u21 {
    const gap_size = 0xDFFF - 0xD800 + 1;
    var scalar = intRangeLessThanFrom(source, u21, gap_size, 0x11_0000);
    if (scalar <= 0xDFFF) scalar -= gap_size;
    return scalar;
}

pub fn unicodeScalarRangeLessThanFrom(source: anytype, min: u21, less_than: u21) u21 {
    const range = unicodeScalarExclusiveRange(min, less_than) catch unreachable;
    if (exclusiveIntRangeHasSingleValue(u21, range.min, range.end)) return unicodeScalarFromCompressed(range.min);
    return unicodeScalarFromCompressed(intRangeLessThanFrom(source, u21, range.min, range.end));
}

pub fn unicodeScalarRangeAtMostFrom(source: anytype, min: u21, at_most: u21) u21 {
    const range = unicodeScalarInclusiveRange(min, at_most) catch unreachable;
    if (range.min == range.max) return unicodeScalarFromCompressed(range.min);
    return unicodeScalarFromCompressed(intRangeAtMostFrom(source, u21, range.min, range.max));
}

pub fn unicodeScalarRangeLessThanCheckedFrom(source: anytype, min: u21, less_than: u21) Error!u21 {
    _ = try unicodeScalarExclusiveRange(min, less_than);
    return unicodeScalarRangeLessThanFrom(source, min, less_than);
}

pub fn unicodeScalarRangeAtMostCheckedFrom(source: anytype, min: u21, at_most: u21) Error!u21 {
    _ = try unicodeScalarInclusiveRange(min, at_most);
    return unicodeScalarRangeAtMostFrom(source, min, at_most);
}

pub fn fillUnicodeScalarFrom(source: anytype, dest: []u21) void {
    for (dest) |*item| item.* = unicodeScalarFrom(source);
}

pub fn fillUnicodeScalarRangeLessThanFrom(source: anytype, dest: []u21, min: u21, less_than: u21) void {
    const range = unicodeScalarExclusiveRange(min, less_than) catch unreachable;
    if (exclusiveIntRangeHasSingleValue(u21, range.min, range.end)) {
        @memset(dest, unicodeScalarFromCompressed(range.min));
        return;
    }
    for (dest) |*item| item.* = unicodeScalarFromCompressed(intRangeLessThanFrom(source, u21, range.min, range.end));
}

pub fn fillUnicodeScalarRangeAtMostFrom(source: anytype, dest: []u21, min: u21, at_most: u21) void {
    const range = unicodeScalarInclusiveRange(min, at_most) catch unreachable;
    if (range.min == range.max) {
        @memset(dest, unicodeScalarFromCompressed(range.min));
        return;
    }
    for (dest) |*item| item.* = unicodeScalarFromCompressed(intRangeAtMostFrom(source, u21, range.min, range.max));
}

pub fn fillUnicodeScalarRangeLessThanCheckedFrom(source: anytype, dest: []u21, min: u21, less_than: u21) Error!void {
    if (dest.len == 0) return;
    _ = try unicodeScalarExclusiveRange(min, less_than);
    fillUnicodeScalarRangeLessThanFrom(source, dest, min, less_than);
}

pub fn fillUnicodeScalarRangeAtMostCheckedFrom(source: anytype, dest: []u21, min: u21, at_most: u21) Error!void {
    if (dest.len == 0) return;
    _ = try unicodeScalarInclusiveRange(min, at_most);
    fillUnicodeScalarRangeAtMostFrom(source, dest, min, at_most);
}

const UnicodeScalarExclusiveRange = struct {
    min: u21,
    end: u21,
};

const UnicodeScalarInclusiveRange = struct {
    min: u21,
    max: u21,
};

fn unicodeScalarExclusiveRange(min: u21, less_than: u21) Error!UnicodeScalarExclusiveRange {
    const compressed_min = try unicodeScalarToCompressed(min);
    const compressed_end = try unicodeScalarExclusiveEndToCompressed(less_than);
    if (compressed_min >= compressed_end) return error.EmptyRange;
    return .{ .min = compressed_min, .end = compressed_end };
}

fn unicodeScalarInclusiveRange(min: u21, at_most: u21) Error!UnicodeScalarInclusiveRange {
    const compressed_min = try unicodeScalarToCompressed(min);
    const compressed_max = try unicodeScalarToCompressed(at_most);
    if (compressed_min > compressed_max) return error.EmptyRange;
    return .{ .min = compressed_min, .max = compressed_max };
}

fn unicodeScalarToCompressed(scalar: u21) Error!u21 {
    if (!isUnicodeScalar(scalar)) return error.InvalidParameter;
    return if (scalar >= 0xE000) scalar - 0x800 else scalar;
}

fn unicodeScalarExclusiveEndToCompressed(scalar: u21) Error!u21 {
    if (scalar > 0x11_0000) return error.InvalidParameter;
    if (scalar == 0x11_0000) return 0x11_0000 - 0x800;
    return unicodeScalarToCompressed(scalar);
}

fn unicodeScalarFromCompressed(compressed: u21) u21 {
    std.debug.assert(compressed < 0x11_0000 - 0x800);
    return if (compressed >= 0xD800) compressed + 0x800 else compressed;
}

fn isUnicodeScalar(scalar: u21) bool {
    return scalar < 0x11_0000 and !(scalar >= 0xD800 and scalar <= 0xDFFF);
}

pub fn normal(self: Rng, comptime T: type, mean: T, stddev: T) T {
    return normalFastFrom(self, T, mean, stddev);
}

pub fn standardNormal(self: Rng, comptime T: type) T {
    return standardNormalFrom(self, T);
}

pub fn standardNormalFrom(source: anytype, comptime T: type) T {
    return standardNormalFastFrom(source, T);
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
    if (stddev == 0) return mean;
    return mean + stddev * standardNormalFastFrom(source, T);
}

pub fn exponential(self: Rng, comptime T: type, rate: T) T {
    return exponentialFastFrom(self, T, rate);
}

pub fn standardExponential(self: Rng, comptime T: type) T {
    return standardExponentialFrom(self, T);
}

pub fn standardExponentialFrom(source: anytype, comptime T: type) T {
    return standardExponentialFastFrom(source, T);
}

pub fn exponentialChecked(self: Rng, comptime T: type, rate: T) Error!T {
    return exponentialCheckedFrom(self, T, rate);
}

pub fn exponentialCheckedFrom(source: anytype, comptime T: type, rate: T) Error!T {
    comptime requireFloat(T);
    if (!(rate > 0) or (!std.math.isFinite(rate) and rate != std.math.inf(T))) return error.InvalidParameter;
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
    std.debug.assert(rate > 0 and (std.math.isFinite(rate) or rate == std.math.inf(T)));
    if (rate == std.math.inf(T)) return 0;
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

pub fn fillChoose(self: Rng, comptime T: type, dest: []T, items: []const T) void {
    fillChooseFrom(self, T, dest, items);
}

pub fn chooseValueArray(self: Rng, comptime T: type, comptime N: usize, items: []const T) ?[N]T {
    return chooseValueArrayFrom(self, T, N, items);
}

pub fn chooseValueArrayFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T) ?[N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    if (items.len == 0) return null;
    fillChooseFrom(source, T, &out, items);
    return out;
}

pub fn chooseValueArrayChecked(self: Rng, comptime T: type, comptime N: usize, items: []const T) Error![N]T {
    return chooseValueArrayCheckedFrom(self, T, N, items);
}

pub fn chooseValueArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T) Error![N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    if (items.len == 0) return error.EmptyRange;
    fillChooseFrom(source, T, &out, items);
    return out;
}

pub fn chooseBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T) ![]T {
    return chooseBatchFrom(self, T, allocator, count, items);
}

pub fn chooseBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    if (items.len == 0) return error.EmptyRange;
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    fillChooseFrom(source, T, out, items);
    return out;
}

pub fn fillChooseChecked(self: Rng, comptime T: type, dest: []T, items: []const T) Error!void {
    return fillChooseCheckedFrom(self, T, dest, items);
}

pub fn chooseBatchChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T) ![]T {
    return chooseBatchCheckedFrom(self, T, allocator, count, items);
}

pub fn chooseBatchCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    if (items.len == 0) return error.EmptyRange;
    return chooseBatchFrom(source, T, allocator, count, items);
}

pub fn chooseCheckedFrom(source: anytype, comptime T: type, items: []const T) Error!T {
    return chooseFrom(source, T, items) orelse error.EmptyRange;
}

pub fn chooseFrom(source: anytype, comptime T: type, items: []const T) ?T {
    if (items.len == 0) return null;
    if (items.len == 1) return items[0];
    return items[uintLessThanFrom(source, usize, items.len)];
}

pub fn fillChooseFrom(source: anytype, comptime T: type, dest: []T, items: []const T) void {
    if (dest.len == 0) return;
    std.debug.assert(items.len > 0);
    if (items.len == 1) {
        @memset(dest, items[0]);
        return;
    }
    for (dest) |*item| item.* = items[uintLessThanFrom(source, usize, items.len)];
}

pub fn fillChooseCheckedFrom(source: anytype, comptime T: type, dest: []T, items: []const T) Error!void {
    if (dest.len == 0) return;
    if (items.len == 0) return error.EmptyRange;
    fillChooseFrom(source, T, dest, items);
}

pub fn chooseIndex(self: Rng, length: usize) ?usize {
    return chooseIndexFrom(self, length);
}

pub fn chooseIndexArray(self: Rng, comptime N: usize, length: usize) ?[N]usize {
    return chooseIndexArrayFrom(self, N, length);
}

pub fn chooseIndexArrayFrom(source: anytype, comptime N: usize, length: usize) ?[N]usize {
    var out: [N]usize = undefined;
    if (N == 0) return out;
    if (length == 0) return null;
    fillChooseIndexFrom(source, &out, length);
    return out;
}

pub fn chooseIndexArrayChecked(self: Rng, comptime N: usize, length: usize) Error![N]usize {
    return chooseIndexArrayCheckedFrom(self, N, length);
}

pub fn chooseIndexArrayCheckedFrom(source: anytype, comptime N: usize, length: usize) Error![N]usize {
    var out: [N]usize = undefined;
    if (N == 0) return out;
    if (length == 0) return error.EmptyRange;
    fillChooseIndexFrom(source, &out, length);
    return out;
}

pub fn chooseIndexBatch(self: Rng, allocator: std.mem.Allocator, count: usize, length: usize) ![]usize {
    return chooseIndexBatchFrom(self, allocator, count, length);
}

pub fn chooseIndexBatchFrom(source: anytype, allocator: std.mem.Allocator, count: usize, length: usize) ![]usize {
    if (count == 0) return allocator.alloc(usize, 0);
    if (length == 0) return error.EmptyRange;
    const out = try allocator.alloc(usize, count);
    errdefer allocator.free(out);
    fillChooseIndexFrom(source, out, length);
    return out;
}

pub fn chooseIndexChecked(self: Rng, length: usize) Error!usize {
    return chooseIndexCheckedFrom(self, length);
}

pub fn chooseIndexBatchChecked(self: Rng, allocator: std.mem.Allocator, count: usize, length: usize) ![]usize {
    return chooseIndexBatchCheckedFrom(self, allocator, count, length);
}

pub fn chooseIndexBatchCheckedFrom(source: anytype, allocator: std.mem.Allocator, count: usize, length: usize) ![]usize {
    if (count == 0) return allocator.alloc(usize, 0);
    if (length == 0) return error.EmptyRange;
    return chooseIndexBatchFrom(source, allocator, count, length);
}

pub fn chooseIndexCheckedFrom(source: anytype, length: usize) Error!usize {
    return chooseIndexFrom(source, length) orelse error.EmptyRange;
}

pub fn chooseIndexFrom(source: anytype, length: usize) ?usize {
    if (length == 0) return null;
    if (length == 1) return 0;
    return uintLessThanFrom(source, usize, length);
}

pub fn fillChooseIndex(self: Rng, dest: []usize, length: usize) void {
    fillChooseIndexFrom(self, dest, length);
}

pub fn fillChooseIndexFrom(source: anytype, dest: []usize, length: usize) void {
    if (dest.len == 0) return;
    std.debug.assert(length > 0);
    if (length == 1) {
        @memset(dest, 0);
        return;
    }
    fillUintLessThanFrom(source, usize, dest, length);
}

pub fn fillChooseIndexChecked(self: Rng, dest: []usize, length: usize) Error!void {
    return fillChooseIndexCheckedFrom(self, dest, length);
}

pub fn fillChooseIndexCheckedFrom(source: anytype, dest: []usize, length: usize) Error!void {
    if (dest.len == 0) return;
    if (length == 0) return error.EmptyRange;
    fillChooseIndexFrom(source, dest, length);
}

pub fn chooseIndexU32(self: Rng, length: u32) ?u32 {
    return chooseIndexU32From(self, length);
}

pub fn chooseIndexArrayU32(self: Rng, comptime N: usize, length: u32) ?[N]u32 {
    return chooseIndexArrayU32From(self, N, length);
}

pub fn chooseIndexArrayU32From(source: anytype, comptime N: usize, length: u32) ?[N]u32 {
    var out: [N]u32 = undefined;
    if (N == 0) return out;
    if (length == 0) return null;
    fillChooseIndexU32From(source, &out, length);
    return out;
}

pub fn chooseIndexArrayU32Checked(self: Rng, comptime N: usize, length: u32) Error![N]u32 {
    return chooseIndexArrayU32CheckedFrom(self, N, length);
}

pub fn chooseIndexArrayU32CheckedFrom(source: anytype, comptime N: usize, length: u32) Error![N]u32 {
    var out: [N]u32 = undefined;
    if (N == 0) return out;
    if (length == 0) return error.EmptyRange;
    fillChooseIndexU32From(source, &out, length);
    return out;
}

pub fn chooseIndexU32Batch(self: Rng, allocator: std.mem.Allocator, count: usize, length: u32) ![]u32 {
    return chooseIndexU32BatchFrom(self, allocator, count, length);
}

pub fn chooseIndexU32BatchFrom(source: anytype, allocator: std.mem.Allocator, count: usize, length: u32) ![]u32 {
    if (count == 0) return allocator.alloc(u32, 0);
    if (length == 0) return error.EmptyRange;
    const out = try allocator.alloc(u32, count);
    errdefer allocator.free(out);
    fillChooseIndexU32From(source, out, length);
    return out;
}

pub fn chooseIndexU32Checked(self: Rng, length: u32) Error!u32 {
    return chooseIndexU32CheckedFrom(self, length);
}

pub fn chooseIndexU32BatchChecked(self: Rng, allocator: std.mem.Allocator, count: usize, length: u32) ![]u32 {
    return chooseIndexU32BatchCheckedFrom(self, allocator, count, length);
}

pub fn chooseIndexU32BatchCheckedFrom(source: anytype, allocator: std.mem.Allocator, count: usize, length: u32) ![]u32 {
    if (count == 0) return allocator.alloc(u32, 0);
    if (length == 0) return error.EmptyRange;
    return chooseIndexU32BatchFrom(source, allocator, count, length);
}

pub fn chooseIndexU32CheckedFrom(source: anytype, length: u32) Error!u32 {
    return chooseIndexU32From(source, length) orelse error.EmptyRange;
}

pub fn chooseIndexU32From(source: anytype, length: u32) ?u32 {
    if (length == 0) return null;
    if (length == 1) return 0;
    return uintLessThanFrom(source, u32, length);
}

pub fn fillChooseIndexU32(self: Rng, dest: []u32, length: u32) void {
    fillChooseIndexU32From(self, dest, length);
}

pub fn fillChooseIndexU32From(source: anytype, dest: []u32, length: u32) void {
    if (dest.len == 0) return;
    std.debug.assert(length > 0);
    if (length == 1) {
        @memset(dest, 0);
        return;
    }
    fillUintLessThanFrom(source, u32, dest, length);
}

pub fn fillChooseIndexU32Checked(self: Rng, dest: []u32, length: u32) Error!void {
    return fillChooseIndexU32CheckedFrom(self, dest, length);
}

pub fn fillChooseIndexU32CheckedFrom(source: anytype, dest: []u32, length: u32) Error!void {
    if (dest.len == 0) return;
    if (length == 0) return error.EmptyRange;
    fillChooseIndexU32From(source, dest, length);
}

pub fn chooseConstPtr(self: Rng, comptime T: type, items: []const T) ?*const T {
    return chooseConstPtrFrom(self, T, items);
}

pub fn chooseConstPtrArray(self: Rng, comptime T: type, comptime N: usize, items: []const T) ?[N]*const T {
    return chooseConstPtrArrayFrom(self, T, N, items);
}

pub fn chooseConstPtrArrayFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T) ?[N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    if (items.len == 0) return null;
    fillChooseConstPtrFrom(source, T, &out, items);
    return out;
}

pub fn chooseConstPtrArrayChecked(self: Rng, comptime T: type, comptime N: usize, items: []const T) Error![N]*const T {
    return chooseConstPtrArrayCheckedFrom(self, T, N, items);
}

pub fn chooseConstPtrArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T) Error![N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    if (items.len == 0) return error.EmptyRange;
    fillChooseConstPtrFrom(source, T, &out, items);
    return out;
}

pub fn fillChooseConstPtr(self: Rng, comptime T: type, dest: []*const T, items: []const T) void {
    fillChooseConstPtrFrom(self, T, dest, items);
}

pub fn chooseConstPtrBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T) ![]*const T {
    return chooseConstPtrBatchFrom(self, T, allocator, count, items);
}

pub fn chooseConstPtrBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T) ![]*const T {
    if (count == 0) return allocator.alloc(*const T, 0);
    if (items.len == 0) return error.EmptyRange;
    const out = try allocator.alloc(*const T, count);
    errdefer allocator.free(out);
    fillChooseConstPtrFrom(source, T, out, items);
    return out;
}

pub fn chooseConstPtrChecked(self: Rng, comptime T: type, items: []const T) Error!*const T {
    return chooseConstPtrCheckedFrom(self, T, items);
}

pub fn fillChooseConstPtrChecked(self: Rng, comptime T: type, dest: []*const T, items: []const T) Error!void {
    return fillChooseConstPtrCheckedFrom(self, T, dest, items);
}

pub fn chooseConstPtrBatchChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T) ![]*const T {
    return chooseConstPtrBatchCheckedFrom(self, T, allocator, count, items);
}

pub fn chooseConstPtrBatchCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T) ![]*const T {
    if (count == 0) return allocator.alloc(*const T, 0);
    if (items.len == 0) return error.EmptyRange;
    return chooseConstPtrBatchFrom(source, T, allocator, count, items);
}

pub fn chooseConstPtrCheckedFrom(source: anytype, comptime T: type, items: []const T) Error!*const T {
    return chooseConstPtrFrom(source, T, items) orelse error.EmptyRange;
}

pub fn chooseConstPtrFrom(source: anytype, comptime T: type, items: []const T) ?*const T {
    if (items.len == 0) return null;
    if (items.len == 1) return &items[0];
    return &items[uintLessThanFrom(source, usize, items.len)];
}

pub fn fillChooseConstPtrFrom(source: anytype, comptime T: type, dest: []*const T, items: []const T) void {
    if (dest.len == 0) return;
    std.debug.assert(items.len > 0);
    if (items.len == 1) {
        @memset(dest, &items[0]);
        return;
    }
    for (dest) |*item| item.* = &items[uintLessThanFrom(source, usize, items.len)];
}

pub fn fillChooseConstPtrCheckedFrom(source: anytype, comptime T: type, dest: []*const T, items: []const T) Error!void {
    if (dest.len == 0) return;
    if (items.len == 0) return error.EmptyRange;
    fillChooseConstPtrFrom(source, T, dest, items);
}

pub fn choosePtr(self: Rng, comptime T: type, items: []T) ?*T {
    return choosePtrFrom(self, T, items);
}

pub fn choosePtrArray(self: Rng, comptime T: type, comptime N: usize, items: []T) ?[N]*T {
    return choosePtrArrayFrom(self, T, N, items);
}

pub fn choosePtrArrayFrom(source: anytype, comptime T: type, comptime N: usize, items: []T) ?[N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    if (items.len == 0) return null;
    fillChoosePtrFrom(source, T, &out, items);
    return out;
}

pub fn choosePtrArrayChecked(self: Rng, comptime T: type, comptime N: usize, items: []T) Error![N]*T {
    return choosePtrArrayCheckedFrom(self, T, N, items);
}

pub fn choosePtrArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, items: []T) Error![N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    if (items.len == 0) return error.EmptyRange;
    fillChoosePtrFrom(source, T, &out, items);
    return out;
}

pub fn fillChoosePtr(self: Rng, comptime T: type, dest: []*T, items: []T) void {
    fillChoosePtrFrom(self, T, dest, items);
}

pub fn choosePtrBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []T) ![]*T {
    return choosePtrBatchFrom(self, T, allocator, count, items);
}

pub fn choosePtrBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []T) ![]*T {
    if (count == 0) return allocator.alloc(*T, 0);
    if (items.len == 0) return error.EmptyRange;
    const out = try allocator.alloc(*T, count);
    errdefer allocator.free(out);
    fillChoosePtrFrom(source, T, out, items);
    return out;
}

pub fn choosePtrChecked(self: Rng, comptime T: type, items: []T) Error!*T {
    return choosePtrCheckedFrom(self, T, items);
}

pub fn fillChoosePtrChecked(self: Rng, comptime T: type, dest: []*T, items: []T) Error!void {
    return fillChoosePtrCheckedFrom(self, T, dest, items);
}

pub fn choosePtrBatchChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []T) ![]*T {
    return choosePtrBatchCheckedFrom(self, T, allocator, count, items);
}

pub fn choosePtrBatchCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []T) ![]*T {
    if (count == 0) return allocator.alloc(*T, 0);
    if (items.len == 0) return error.EmptyRange;
    return choosePtrBatchFrom(source, T, allocator, count, items);
}

pub fn choosePtrCheckedFrom(source: anytype, comptime T: type, items: []T) Error!*T {
    return choosePtrFrom(source, T, items) orelse error.EmptyRange;
}

pub fn choosePtrFrom(source: anytype, comptime T: type, items: []T) ?*T {
    if (items.len == 0) return null;
    if (items.len == 1) return &items[0];
    return &items[uintLessThanFrom(source, usize, items.len)];
}

pub fn fillChoosePtrFrom(source: anytype, comptime T: type, dest: []*T, items: []T) void {
    if (dest.len == 0) return;
    std.debug.assert(items.len > 0);
    if (items.len == 1) {
        @memset(dest, &items[0]);
        return;
    }
    for (dest) |*item| item.* = &items[uintLessThanFrom(source, usize, items.len)];
}

pub fn fillChoosePtrCheckedFrom(source: anytype, comptime T: type, dest: []*T, items: []T) Error!void {
    if (dest.len == 0) return;
    if (items.len == 0) return error.EmptyRange;
    fillChoosePtrFrom(source, T, dest, items);
}

pub fn weightedIndex(self: Rng, weights: []const f64) ?usize {
    return weightedIndexFrom(self, weights);
}

pub fn fillWeightedIndex(self: Rng, dest: []?usize, weights: []const f64) void {
    fillWeightedIndexFrom(self, dest, weights);
}

pub fn weightedIndexBatch(self: Rng, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]?usize {
    return weightedIndexBatchFrom(self, allocator, count, weights);
}

pub fn weightedIndexArray(self: Rng, comptime N: usize, weights: []const f64) ?[N]usize {
    return weightedIndexArrayFrom(self, N, weights);
}

pub fn weightedIndexArrayFrom(source: anytype, comptime N: usize, weights: []const f64) ?[N]usize {
    var out: [N]usize = undefined;
    if (N == 0) return out;
    const validation = validateWeightedIndexWeightsAllowEmpty(weights) catch unreachable;
    if (validation.total == 0) return null;
    if (validation.single_positive) |index| {
        @memset(out[0..], index);
        return out;
    }
    for (&out) |*item| item.* = weightedIndexCheckedFromPrevalidated(source, weights, validation.total);
    return out;
}

pub fn weightedIndexBatchFrom(source: anytype, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]?usize {
    if (count == 0) return allocator.alloc(?usize, 0);
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    const out = try allocator.alloc(?usize, count);
    errdefer allocator.free(out);
    if (validation.total == 0) {
        @memset(out, @as(?usize, null));
        return out;
    }
    if (validation.single_positive) |index| {
        @memset(out, @as(?usize, index));
        return out;
    }
    for (out) |*item| item.* = weightedIndexCheckedFromPrevalidated(source, weights, validation.total);
    return out;
}

pub fn fillWeightedIndexFrom(source: anytype, dest: []?usize, weights: []const f64) void {
    if (dest.len == 0) return;
    const validation = validateWeightedIndexWeightsAllowEmpty(weights) catch unreachable;
    if (validation.total == 0) {
        @memset(dest, @as(?usize, null));
        return;
    }
    if (validation.single_positive) |index| {
        @memset(dest, @as(?usize, index));
        return;
    }
    for (dest) |*item| item.* = weightedIndexCheckedFromPrevalidated(source, weights, validation.total);
}

pub fn weightedIndexFrom(source: anytype, weights: []const f64) ?usize {
    return weightedIndexCheckedFrom(source, weights) catch unreachable;
}

pub fn weightedIndexChecked(self: Rng, weights: []const f64) Error!?usize {
    return weightedIndexCheckedFrom(self, weights);
}

pub fn fillWeightedIndexChecked(self: Rng, dest: []usize, weights: []const f64) Error!void {
    return fillWeightedIndexCheckedFrom(self, dest, weights);
}

pub fn weightedIndexArrayChecked(self: Rng, comptime N: usize, weights: []const f64) Error![N]usize {
    return weightedIndexArrayCheckedFrom(self, N, weights);
}

pub fn weightedIndexArrayCheckedFrom(source: anytype, comptime N: usize, weights: []const f64) Error![N]usize {
    var out: [N]usize = undefined;
    if (N == 0) return out;
    const validation = try validateWeightedIndexWeights(weights);
    if (validation.single_positive) |index| {
        @memset(out[0..], index);
        return out;
    }
    for (&out) |*item| item.* = weightedIndexCheckedFromPrevalidated(source, weights, validation.total);
    return out;
}

pub fn weightedIndexBatchChecked(self: Rng, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]usize {
    return weightedIndexBatchCheckedFrom(self, allocator, count, weights);
}

pub fn weightedIndexBatchCheckedFrom(source: anytype, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]usize {
    if (count == 0) return allocator.alloc(usize, 0);
    const validation = try validateWeightedIndexWeights(weights);
    const index = validation.single_positive orelse {
        const out = try allocator.alloc(usize, count);
        errdefer allocator.free(out);
        for (out) |*item| item.* = weightedIndexCheckedFromPrevalidated(source, weights, validation.total);
        return out;
    };
    const out = try allocator.alloc(usize, count);
    @memset(out, index);
    return out;
}

pub fn fillWeightedIndexCheckedFrom(source: anytype, dest: []usize, weights: []const f64) Error!void {
    if (dest.len == 0) return;
    const validation = try validateWeightedIndexWeights(weights);
    if (validation.single_positive) |index| {
        @memset(dest, index);
        return;
    }
    for (dest) |*item| item.* = weightedIndexCheckedFromPrevalidated(source, weights, validation.total);
}

pub fn weightedIndexCheckedFrom(source: anytype, weights: []const f64) Error!?usize {
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    if (validation.total == 0) return null;
    if (validation.single_positive) |index| return index;
    return weightedIndexCheckedFromPrevalidated(source, weights, validation.total);
}

const WeightedIndexValidation = struct {
    total: f64,
    single_positive: ?usize,
};

fn validateWeightedIndexWeights(weights: []const f64) Error!WeightedIndexValidation {
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    if (validation.total == 0) return error.EmptyRange;
    return validation;
}

fn validateWeightedIndexWeightsAllowEmpty(weights: []const f64) Error!WeightedIndexValidation {
    var total: f64 = 0;
    var positive_index: ?usize = null;
    var positive_count: usize = 0;
    for (weights, 0..) |weight, index| {
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        total += weight;
        if (!std.math.isFinite(total)) return error.InvalidWeight;
        if (weight > 0) {
            positive_index = index;
            positive_count += 1;
        }
    }
    return .{ .total = total, .single_positive = if (positive_count == 1) positive_index else null };
}

fn weightedIndexCheckedFromPrevalidated(source: anytype, weights: []const f64, total: f64) usize {
    const point = floatFrom(source, f64) * total;
    var acc: f64 = 0;
    for (weights, 0..) |weight, i| {
        acc += weight;
        if (point < acc) return i;
    }
    return weights.len - 1;
}

pub fn weightedIndexU32(self: Rng, weights: []const f64) Error!?u32 {
    return weightedIndexU32From(self, weights);
}

pub fn fillWeightedIndexU32(self: Rng, dest: []?u32, weights: []const f64) Error!void {
    return fillWeightedIndexU32From(self, dest, weights);
}

pub fn weightedIndexU32Array(self: Rng, comptime N: usize, weights: []const f64) Error!?[N]u32 {
    return weightedIndexU32ArrayFrom(self, N, weights);
}

pub fn weightedIndexU32ArrayFrom(source: anytype, comptime N: usize, weights: []const f64) Error!?[N]u32 {
    var out: [N]u32 = undefined;
    if (N == 0) return out;
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    if (validation.total == 0) return null;
    if (validation.single_positive) |index| {
        @memset(out[0..], @intCast(index));
        return out;
    }
    for (&out) |*item| item.* = @intCast(weightedIndexCheckedFromPrevalidated(source, weights, validation.total));
    return out;
}

pub fn weightedIndexU32Batch(self: Rng, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]?u32 {
    return weightedIndexU32BatchFrom(self, allocator, count, weights);
}

pub fn weightedIndexU32BatchFrom(source: anytype, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]?u32 {
    if (count == 0) return allocator.alloc(?u32, 0);
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    const out = try allocator.alloc(?u32, count);
    errdefer allocator.free(out);
    if (validation.total == 0) {
        @memset(out, @as(?u32, null));
        return out;
    }
    if (validation.single_positive) |index| {
        @memset(out, @as(?u32, @intCast(index)));
        return out;
    }
    for (out) |*item| item.* = @intCast(weightedIndexCheckedFromPrevalidated(source, weights, validation.total));
    return out;
}

pub fn weightedIndexU32From(source: anytype, weights: []const f64) Error!?u32 {
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const index = try weightedIndexCheckedFrom(source, weights) orelse return null;
    return @intCast(index);
}

pub fn weightedIndexU32Checked(self: Rng, weights: []const f64) Error!?u32 {
    return weightedIndexU32CheckedFrom(self, weights);
}

pub fn fillWeightedIndexU32Checked(self: Rng, dest: []u32, weights: []const f64) Error!void {
    return fillWeightedIndexU32CheckedFrom(self, dest, weights);
}

pub fn weightedIndexU32ArrayChecked(self: Rng, comptime N: usize, weights: []const f64) Error![N]u32 {
    return weightedIndexU32ArrayCheckedFrom(self, N, weights);
}

pub fn weightedIndexU32ArrayCheckedFrom(source: anytype, comptime N: usize, weights: []const f64) Error![N]u32 {
    var out: [N]u32 = undefined;
    if (N == 0) return out;
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(weights);
    if (validation.single_positive) |index| {
        @memset(out[0..], @intCast(index));
        return out;
    }
    for (&out) |*item| item.* = @intCast(weightedIndexCheckedFromPrevalidated(source, weights, validation.total));
    return out;
}

pub fn weightedIndexU32BatchChecked(self: Rng, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]u32 {
    return weightedIndexU32BatchCheckedFrom(self, allocator, count, weights);
}

pub fn weightedIndexU32BatchCheckedFrom(source: anytype, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]u32 {
    if (count == 0) return allocator.alloc(u32, 0);
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(weights);
    const index = validation.single_positive orelse {
        const out = try allocator.alloc(u32, count);
        errdefer allocator.free(out);
        for (out) |*item| item.* = @intCast(weightedIndexCheckedFromPrevalidated(source, weights, validation.total));
        return out;
    };
    const out = try allocator.alloc(u32, count);
    @memset(out, @intCast(index));
    return out;
}

pub fn fillWeightedIndexU32From(source: anytype, dest: []?u32, weights: []const f64) Error!void {
    if (dest.len == 0) return;
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    if (validation.total == 0) {
        @memset(dest, @as(?u32, null));
        return;
    }
    if (validation.single_positive) |index| {
        @memset(dest, @as(?u32, @intCast(index)));
        return;
    }
    for (dest) |*item| item.* = @intCast(weightedIndexCheckedFromPrevalidated(source, weights, validation.total));
}

pub fn fillWeightedIndexU32CheckedFrom(source: anytype, dest: []u32, weights: []const f64) Error!void {
    if (dest.len == 0) return;
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(weights);
    if (validation.single_positive) |index| {
        @memset(dest, @intCast(index));
        return;
    }
    for (dest) |*item| item.* = @intCast(weightedIndexCheckedFromPrevalidated(source, weights, validation.total));
}

pub fn weightedIndexU32CheckedFrom(source: anytype, weights: []const f64) Error!?u32 {
    return weightedIndexU32From(source, weights);
}

pub fn chooseWeighted(self: Rng, comptime T: type, items: []const T, weights: []const f64) Error!?T {
    return chooseWeightedFrom(self, T, items, weights);
}

pub fn chooseWeightedFrom(source: anytype, comptime T: type, items: []const T, weights: []const f64) Error!?T {
    if (items.len != weights.len) return error.InvalidParameter;
    const index = try weightedIndexCheckedFrom(source, weights) orelse return null;
    return items[index];
}

pub fn chooseWeightedValueArray(self: Rng, comptime T: type, comptime N: usize, items: []const T, weights: []const f64) Error!?[N]T {
    return chooseWeightedValueArrayFrom(self, T, N, items, weights);
}

pub fn chooseWeightedValueArrayFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T, weights: []const f64) Error!?[N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    if (validation.total == 0) return null;
    if (validation.single_positive) |index| {
        @memset(out[0..], items[index]);
        return out;
    }
    for (&out) |*item| item.* = items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
    return out;
}

pub fn fillChooseWeighted(self: Rng, comptime T: type, dest: []?T, items: []const T, weights: []const f64) Error!void {
    return fillChooseWeightedFrom(self, T, dest, items, weights);
}

pub fn fillChooseWeightedFrom(source: anytype, comptime T: type, dest: []?T, items: []const T, weights: []const f64) Error!void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    if (validation.total == 0) {
        @memset(dest, @as(?T, null));
        return;
    }
    if (validation.single_positive) |index| {
        @memset(dest, @as(?T, items[index]));
        return;
    }
    for (dest) |*item| item.* = items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
}

pub fn chooseWeightedBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T, weights: []const f64) ![]?T {
    return chooseWeightedBatchFrom(self, T, allocator, count, items, weights);
}

pub fn chooseWeightedBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T, weights: []const f64) ![]?T {
    if (count == 0) return allocator.alloc(?T, 0);
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    const out = try allocator.alloc(?T, count);
    errdefer allocator.free(out);
    if (validation.total == 0) {
        @memset(out, @as(?T, null));
        return out;
    }
    if (validation.single_positive) |index| {
        @memset(out, @as(?T, items[index]));
        return out;
    }
    for (out) |*item| item.* = items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
    return out;
}

pub fn fillChooseWeightedChecked(self: Rng, comptime T: type, dest: []T, items: []const T, weights: []const f64) Error!void {
    return fillChooseWeightedCheckedFrom(self, T, dest, items, weights);
}

pub fn chooseWeightedValueArrayChecked(self: Rng, comptime T: type, comptime N: usize, items: []const T, weights: []const f64) Error![N]T {
    return chooseWeightedValueArrayCheckedFrom(self, T, N, items, weights);
}

pub fn chooseWeightedValueArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T, weights: []const f64) Error![N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(weights);
    if (validation.single_positive) |index| {
        @memset(out[0..], items[index]);
        return out;
    }
    for (&out) |*item| item.* = items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
    return out;
}

pub fn fillChooseWeightedCheckedFrom(source: anytype, comptime T: type, dest: []T, items: []const T, weights: []const f64) Error!void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(weights);
    if (validation.single_positive) |index| {
        @memset(dest, items[index]);
        return;
    }
    for (dest) |*item| item.* = items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
}

pub fn chooseWeightedBatchChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T, weights: []const f64) ![]T {
    return chooseWeightedBatchCheckedFrom(self, T, allocator, count, items, weights);
}

pub fn chooseWeightedBatchCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T, weights: []const f64) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(weights);
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    if (validation.single_positive) |index| {
        @memset(out, items[index]);
        return out;
    }
    for (out) |*item| item.* = items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
    return out;
}

pub fn chooseWeightedConstPtr(self: Rng, comptime T: type, items: []const T, weights: []const f64) Error!?*const T {
    return chooseWeightedConstPtrFrom(self, T, items, weights);
}

pub fn chooseWeightedConstPtrFrom(source: anytype, comptime T: type, items: []const T, weights: []const f64) Error!?*const T {
    if (items.len != weights.len) return error.InvalidParameter;
    const index = try weightedIndexCheckedFrom(source, weights) orelse return null;
    return &items[index];
}

pub fn chooseWeightedConstPtrArray(self: Rng, comptime T: type, comptime N: usize, items: []const T, weights: []const f64) Error!?[N]*const T {
    return chooseWeightedConstPtrArrayFrom(self, T, N, items, weights);
}

pub fn chooseWeightedConstPtrArrayFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T, weights: []const f64) Error!?[N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    if (validation.total == 0) return null;
    if (validation.single_positive) |index| {
        @memset(out[0..], &items[index]);
        return out;
    }
    for (&out) |*item| item.* = &items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
    return out;
}

pub fn fillChooseWeightedConstPtr(self: Rng, comptime T: type, dest: []?*const T, items: []const T, weights: []const f64) Error!void {
    return fillChooseWeightedConstPtrFrom(self, T, dest, items, weights);
}

pub fn fillChooseWeightedConstPtrFrom(source: anytype, comptime T: type, dest: []?*const T, items: []const T, weights: []const f64) Error!void {
    if (items.len != weights.len) return error.InvalidParameter;
    if (dest.len == 0) return;
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    if (validation.total == 0) {
        @memset(dest, null);
        return;
    }
    if (validation.single_positive) |index| {
        @memset(dest, @as(?*const T, &items[index]));
        return;
    }
    for (dest) |*item| item.* = &items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
}

pub fn chooseWeightedConstPtrBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T, weights: []const f64) ![]?*const T {
    return chooseWeightedConstPtrBatchFrom(self, T, allocator, count, items, weights);
}

pub fn chooseWeightedConstPtrBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T, weights: []const f64) ![]?*const T {
    if (count == 0) return allocator.alloc(?*const T, 0);
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    const out = try allocator.alloc(?*const T, count);
    errdefer allocator.free(out);
    if (validation.total == 0) {
        @memset(out, @as(?*const T, null));
        return out;
    }
    if (validation.single_positive) |index| {
        @memset(out, @as(?*const T, &items[index]));
        return out;
    }
    for (out) |*item| item.* = &items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
    return out;
}

pub fn chooseWeightedConstPtrChecked(self: Rng, comptime T: type, items: []const T, weights: []const f64) Error!*const T {
    return chooseWeightedConstPtrCheckedFrom(self, T, items, weights);
}

pub fn chooseWeightedConstPtrArrayChecked(self: Rng, comptime T: type, comptime N: usize, items: []const T, weights: []const f64) Error![N]*const T {
    return chooseWeightedConstPtrArrayCheckedFrom(self, T, N, items, weights);
}

pub fn chooseWeightedConstPtrArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, items: []const T, weights: []const f64) Error![N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(weights);
    if (validation.single_positive) |index| {
        @memset(out[0..], &items[index]);
        return out;
    }
    for (&out) |*item| item.* = &items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
    return out;
}

pub fn chooseWeightedConstPtrCheckedFrom(source: anytype, comptime T: type, items: []const T, weights: []const f64) Error!*const T {
    return (try chooseWeightedConstPtrFrom(source, T, items, weights)) orelse error.EmptyRange;
}

pub fn fillChooseWeightedConstPtrChecked(self: Rng, comptime T: type, dest: []*const T, items: []const T, weights: []const f64) Error!void {
    return fillChooseWeightedConstPtrCheckedFrom(self, T, dest, items, weights);
}

pub fn fillChooseWeightedConstPtrCheckedFrom(source: anytype, comptime T: type, dest: []*const T, items: []const T, weights: []const f64) Error!void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(weights);
    if (validation.single_positive) |index| {
        @memset(dest, &items[index]);
        return;
    }
    for (dest) |*item| item.* = &items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
}

pub fn chooseWeightedConstPtrBatchChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T, weights: []const f64) ![]*const T {
    return chooseWeightedConstPtrBatchCheckedFrom(self, T, allocator, count, items, weights);
}

pub fn chooseWeightedConstPtrBatchCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []const T, weights: []const f64) ![]*const T {
    if (count == 0) return allocator.alloc(*const T, 0);
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(weights);
    const out = try allocator.alloc(*const T, count);
    errdefer allocator.free(out);
    if (validation.single_positive) |index| {
        @memset(out, &items[index]);
        return out;
    }
    for (out) |*item| item.* = &items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
    return out;
}

pub fn chooseWeightedPtr(self: Rng, comptime T: type, items: []T, weights: []const f64) Error!?*T {
    return chooseWeightedPtrFrom(self, T, items, weights);
}

pub fn chooseWeightedPtrFrom(source: anytype, comptime T: type, items: []T, weights: []const f64) Error!?*T {
    if (items.len != weights.len) return error.InvalidParameter;
    const index = try weightedIndexCheckedFrom(source, weights) orelse return null;
    return &items[index];
}

pub fn chooseWeightedPtrArray(self: Rng, comptime T: type, comptime N: usize, items: []T, weights: []const f64) Error!?[N]*T {
    return chooseWeightedPtrArrayFrom(self, T, N, items, weights);
}

pub fn chooseWeightedPtrArrayFrom(source: anytype, comptime T: type, comptime N: usize, items: []T, weights: []const f64) Error!?[N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    if (validation.total == 0) return null;
    if (validation.single_positive) |index| {
        @memset(out[0..], &items[index]);
        return out;
    }
    for (&out) |*item| item.* = &items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
    return out;
}

pub fn fillChooseWeightedPtr(self: Rng, comptime T: type, dest: []?*T, items: []T, weights: []const f64) Error!void {
    return fillChooseWeightedPtrFrom(self, T, dest, items, weights);
}

pub fn fillChooseWeightedPtrFrom(source: anytype, comptime T: type, dest: []?*T, items: []T, weights: []const f64) Error!void {
    if (items.len != weights.len) return error.InvalidParameter;
    if (dest.len == 0) return;
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    if (validation.total == 0) {
        @memset(dest, null);
        return;
    }
    if (validation.single_positive) |index| {
        @memset(dest, @as(?*T, &items[index]));
        return;
    }
    for (dest) |*item| item.* = &items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
}

pub fn chooseWeightedPtrBatch(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []T, weights: []const f64) ![]?*T {
    return chooseWeightedPtrBatchFrom(self, T, allocator, count, items, weights);
}

pub fn chooseWeightedPtrBatchFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []T, weights: []const f64) ![]?*T {
    if (count == 0) return allocator.alloc(?*T, 0);
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeightsAllowEmpty(weights);
    const out = try allocator.alloc(?*T, count);
    errdefer allocator.free(out);
    if (validation.total == 0) {
        @memset(out, @as(?*T, null));
        return out;
    }
    if (validation.single_positive) |index| {
        @memset(out, @as(?*T, &items[index]));
        return out;
    }
    for (out) |*item| item.* = &items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
    return out;
}

pub fn chooseWeightedPtrChecked(self: Rng, comptime T: type, items: []T, weights: []const f64) Error!*T {
    return chooseWeightedPtrCheckedFrom(self, T, items, weights);
}

pub fn chooseWeightedPtrArrayChecked(self: Rng, comptime T: type, comptime N: usize, items: []T, weights: []const f64) Error![N]*T {
    return chooseWeightedPtrArrayCheckedFrom(self, T, N, items, weights);
}

pub fn chooseWeightedPtrArrayCheckedFrom(source: anytype, comptime T: type, comptime N: usize, items: []T, weights: []const f64) Error![N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(weights);
    if (validation.single_positive) |index| {
        @memset(out[0..], &items[index]);
        return out;
    }
    for (&out) |*item| item.* = &items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
    return out;
}

pub fn chooseWeightedPtrCheckedFrom(source: anytype, comptime T: type, items: []T, weights: []const f64) Error!*T {
    return (try chooseWeightedPtrFrom(source, T, items, weights)) orelse error.EmptyRange;
}

pub fn fillChooseWeightedPtrChecked(self: Rng, comptime T: type, dest: []*T, items: []T, weights: []const f64) Error!void {
    return fillChooseWeightedPtrCheckedFrom(self, T, dest, items, weights);
}

pub fn fillChooseWeightedPtrCheckedFrom(source: anytype, comptime T: type, dest: []*T, items: []T, weights: []const f64) Error!void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(weights);
    if (validation.single_positive) |index| {
        @memset(dest, &items[index]);
        return;
    }
    for (dest) |*item| item.* = &items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
}

pub fn chooseWeightedPtrBatchChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []T, weights: []const f64) ![]*T {
    return chooseWeightedPtrBatchCheckedFrom(self, T, allocator, count, items, weights);
}

pub fn chooseWeightedPtrBatchCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, count: usize, items: []T, weights: []const f64) ![]*T {
    if (count == 0) return allocator.alloc(*T, 0);
    if (items.len != weights.len) return error.InvalidParameter;
    const validation = try validateWeightedIndexWeights(weights);
    const out = try allocator.alloc(*T, count);
    errdefer allocator.free(out);
    if (validation.single_positive) |index| {
        @memset(out, &items[index]);
        return out;
    }
    for (out) |*item| item.* = &items[weightedIndexCheckedFromPrevalidated(source, weights, validation.total)];
    return out;
}

pub fn sampleWithoutReplacement(self: Rng, comptime T: type, allocator: std.mem.Allocator, items: []const T, count: usize) ![]T {
    if (count > items.len) return error.InvalidParameter;
    return sampleWithoutReplacementFrom(self, T, allocator, items, count);
}

pub fn sampleWithoutReplacementFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, items: []const T, count: usize) ![]T {
    if (count > items.len) return error.InvalidParameter;
    return try sampleWithoutReplacementCheckedFrom(source, T, allocator, items, count);
}

pub fn sampleWithoutReplacementChecked(self: Rng, comptime T: type, allocator: std.mem.Allocator, items: []const T, count: usize) ![]T {
    return sampleWithoutReplacementCheckedFrom(self, T, allocator, items, count);
}

pub fn sampleWithoutReplacementCheckedFrom(source: anytype, comptime T: type, allocator: std.mem.Allocator, items: []const T, count: usize) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
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

    return out.toOwnedSliceAssert();
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

        pub fn sizeHint(_: Self) IteratorSizeHint {
            return unboundedSizeHint();
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

        pub fn sizeHint(_: Self) IteratorSizeHint {
            return unboundedSizeHint();
        }
    };
}

fn unboundedSizeHint() IteratorSizeHint {
    return .{ .lower = std.math.maxInt(usize), .upper = null };
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

        pub fn sizeHint(_: Self) IteratorSizeHint {
            return unboundedSizeHint();
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

        pub fn sizeHint(_: Self) IteratorSizeHint {
            return unboundedSizeHint();
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

fn sourceCanTryNext(comptime Source: type) bool {
    if (Source == Rng) return true;
    const info = @typeInfo(Source);
    if (info == .pointer and info.pointer.size == .one) {
        return @hasDecl(info.pointer.child, "tryNext");
    }
    return @hasDecl(Source, "tryNext");
}

fn sourceCanTryNextU64(comptime Source: type) bool {
    if (Source == Rng) return true;
    const info = @typeInfo(Source);
    if (info == .pointer and info.pointer.size == .one) {
        return @hasDecl(info.pointer.child, "tryNextU64");
    }
    return @hasDecl(Source, "tryNextU64");
}

fn sourceCanTryNextU32(comptime Source: type) bool {
    if (Source == Rng) return true;
    const info = @typeInfo(Source);
    if (info == .pointer and info.pointer.size == .one) {
        return @hasDecl(info.pointer.child, "tryNextU32");
    }
    return @hasDecl(Source, "tryNextU32");
}

fn sourceCanNextU32(comptime Source: type) bool {
    if (Source == Rng) return true;
    const info = @typeInfo(Source);
    if (info == .pointer and info.pointer.size == .one) {
        return @hasDecl(info.pointer.child, "nextU32");
    }
    return @hasDecl(Source, "nextU32");
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
    return @mulAdd(f64, @as(f64, @floatFromInt(raw >> 11)), 1.0 / 9007199254740992.0, 1.0 / 9007199254740992.0);
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
    if (min == max) return min;
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

test "rng direct raw aliases dispatch source native nextU32" {
    const NativeU32Source = struct {
        next_called: bool = false,
        next_u32_called: bool = false,

        fn next(self: *@This()) u64 {
            self.next_called = true;
            return 0xaaaa_bbbb_cccc_dddd;
        }

        fn nextU32(self: *@This()) u32 {
            self.next_u32_called = true;
            return 0x1234_5678;
        }

        fn fill(self: *@This(), out: []u8) void {
            var i: usize = 0;
            while (i < out.len) {
                const word = self.next();
                var word_bytes: [8]u8 = undefined;
                std.mem.writeInt(u64, &word_bytes, word, .little);
                const n = @min(8, out.len - i);
                @memcpy(out[i..][0..n], word_bytes[0..n]);
                i += n;
            }
        }
    };

    var source = NativeU32Source{};
    try std.testing.expectEqual(@as(u32, 0x1234_5678), Rng.nextU32From(&source));
    try std.testing.expect(!source.next_called);
    try std.testing.expect(source.next_u32_called);

    var facade_source = NativeU32Source{};
    const rng = Rng.init(&facade_source);
    try std.testing.expectEqual(@as(u32, 0x1234_5678), rng.nextU32());
    try std.testing.expect(!facade_source.next_called);
    try std.testing.expect(facade_source.next_u32_called);
}

test "rng facade covers scalar APIs" {
    const Xoshiro256 = @import("engines/xoshiro256.zig");
    var engine = Xoshiro256.init(7);
    const rng = Rng.init(&engine);

    _ = rng.nextU64();
    _ = rng.nextU32();
    _ = try rng.tryNextU64();
    _ = try rng.tryNextU32();
    _ = Rng.nextU64From(&engine);
    _ = Rng.nextU32From(&engine);
    _ = try Rng.tryNextU64From(&engine);
    _ = try Rng.tryNextU32From(&engine);
    var raw_bytes: [7]u8 = undefined;
    try rng.tryFillBytes(&raw_bytes);
    try Rng.tryFillBytesFrom(&engine, &raw_bytes);
    _ = rng.randomValue(u64);
    _ = Rng.randomValueFrom(&engine, u32);
    _ = try rng.randomValueChecked(bool);
    _ = try Rng.randomValueCheckedFrom(&engine, f64);
    try std.testing.expect(rng.uintLessThan(u32, 10) < 10);
    try std.testing.expect(rng.intRangeLessThan(i32, -5, 5) >= -5);
    try std.testing.expect(rng.randomRange(i32, -5, 5) >= -5);
    try std.testing.expect(Rng.randomRangeFrom(&engine, u32, 3, 7) < 7);
    try std.testing.expect(rng.randomRangeAtMost(i32, -5, 5) <= 5);
    try std.testing.expect(Rng.randomRangeAtMostFrom(&engine, u32, 3, 7) <= 7);
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
    try std.testing.expect(rng.randomBool(1));
    try std.testing.expect(Rng.randomBoolFrom(&engine, 1));
    try std.testing.expect(!rng.ratio(0, 7));
    try std.testing.expect(Rng.ratioFrom(&engine, 1, 1));
    try std.testing.expect(!rng.randomRatio(0, 7));
    try std.testing.expect(Rng.randomRatioFrom(&engine, 1, 1));
    try std.testing.expect(rng.chance(1.0 - std.math.floatEps(f64) / 2.0));
    try std.testing.expect(try rng.chanceChecked(0.5) or true);
    _ = try rng.randomBoolChecked(0.5);
    try std.testing.expect(try Rng.chanceCheckedFrom(&engine, 1));
    try std.testing.expect(try Rng.randomBoolCheckedFrom(&engine, 1));
    try std.testing.expect(try Rng.ratioCheckedFrom(&engine, 1, 1));
    try std.testing.expect(try rng.randomRatioChecked(1, 1));
    try std.testing.expect(try Rng.randomRatioCheckedFrom(&engine, 1, 1));
    try std.testing.expect(try Rng.uintLessThanCheckedFrom(&engine, u32, 10) < 10);
    try std.testing.expect(try Rng.intRangeLessThanCheckedFrom(&engine, i32, -5, 5) >= -5);
    try std.testing.expect(try Rng.intRangeAtMostCheckedFrom(&engine, i32, -5, 5) <= 5);
    try std.testing.expect(try Rng.floatRangeCheckedFrom(&engine, f64, -1, 1) >= -1);
    try std.testing.expect(try rng.randomRangeChecked(i32, -5, 5) < 5);
    try std.testing.expect(try Rng.randomRangeCheckedFrom(&engine, f64, -1, 1) < 1);
    try std.testing.expect(try rng.randomRangeAtMostChecked(i32, -5, 5) <= 5);
    try std.testing.expect(try Rng.randomRangeAtMostCheckedFrom(&engine, u32, 3, 7) <= 7);
    try std.testing.expectError(error.InvalidProbability, rng.chanceChecked(1.1));
    try std.testing.expectError(error.InvalidProbability, Rng.chanceCheckedFrom(&engine, 1.1));
    try std.testing.expectError(error.InvalidProbability, rng.randomBoolChecked(1.1));
    try std.testing.expectError(error.InvalidProbability, Rng.randomBoolCheckedFrom(&engine, 1.1));
    var empty_bool_buf: [0]bool = .{};
    try rng.fillChanceChecked(&empty_bool_buf, 1.1);
    try rng.fillRatioChecked(&empty_bool_buf, 2, 1);
    try std.testing.expectError(error.InvalidProbability, rng.vectorChanceChecked(@Vector(4, bool), -0.1));
    try std.testing.expectError(error.InvalidProbability, rng.vectorRatioChecked(@Vector(4, bool), 2, 1));
    try std.testing.expectError(error.InvalidProbability, rng.ratioChecked(2, 1));
    try std.testing.expectError(error.InvalidProbability, Rng.ratioCheckedFrom(&engine, 2, 1));
    try std.testing.expectError(error.InvalidProbability, rng.randomRatioChecked(2, 1));
    try std.testing.expectError(error.InvalidProbability, Rng.randomRatioCheckedFrom(&engine, 2, 1));
    try std.testing.expectError(error.EmptyRange, rng.uintLessThanChecked(u32, 0));
    try std.testing.expectError(error.EmptyRange, Rng.uintLessThanCheckedFrom(&engine, u32, 0));
    try std.testing.expectError(error.EmptyRange, rng.intRangeLessThanChecked(u32, 3, 3));
    try std.testing.expectError(error.EmptyRange, Rng.intRangeLessThanCheckedFrom(&engine, u32, 3, 3));
    try std.testing.expectError(error.EmptyRange, rng.randomRangeChecked(u32, 3, 3));
    try std.testing.expectError(error.NonFinite, Rng.randomRangeCheckedFrom(&engine, f64, std.math.inf(f64), 1));
    try std.testing.expectError(error.EmptyRange, rng.intRangeAtMostChecked(u32, 4, 3));
    try std.testing.expectError(error.EmptyRange, Rng.intRangeAtMostCheckedFrom(&engine, u32, 4, 3));
    try std.testing.expectError(error.EmptyRange, rng.randomRangeAtMostChecked(u32, 4, 3));
    try std.testing.expectError(error.EmptyRange, Rng.randomRangeAtMostCheckedFrom(&engine, u32, 4, 3));
    try std.testing.expectError(error.NonFinite, rng.floatRangeChecked(f64, std.math.inf(f64), 1));
    try std.testing.expectError(error.NonFinite, Rng.floatRangeCheckedFrom(&engine, f64, std.math.inf(f64), 1));
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

    var unicode_scalar_buf: [8]u21 = undefined;
    rng.fillUnicodeScalar(&unicode_scalar_buf);
    for (unicode_scalar_buf) |item| {
        try std.testing.expect(item < 0xD800 or item > 0xDFFF);
        try std.testing.expect(item < 0x11_0000);
    }

    var direct_unicode_scalar_buf: [8]u21 = undefined;
    Rng.fillUnicodeScalarFrom(&engine, &direct_unicode_scalar_buf);
    for (direct_unicode_scalar_buf) |item| {
        try std.testing.expect(item < 0xD800 or item > 0xDFFF);
        try std.testing.expect(item < 0x11_0000);
    }

    const unicode_scalar_owned = try rng.unicodeScalarBatch(std.testing.allocator, 8);
    defer std.testing.allocator.free(unicode_scalar_owned);
    for (unicode_scalar_owned) |item| {
        try std.testing.expect(item < 0xD800 or item > 0xDFFF);
        try std.testing.expect(item < 0x11_0000);
    }

    const ranged_scalar = try rng.unicodeScalarRangeLessThanChecked(0xD7F0, 0xE010);
    try std.testing.expect(ranged_scalar >= 0xD7F0 and ranged_scalar < 0xE010);
    try std.testing.expect(isUnicodeScalar(ranged_scalar));

    var ranged_unicode_scalar_buf: [8]u21 = undefined;
    try rng.fillUnicodeScalarRangeAtMostChecked(&ranged_unicode_scalar_buf, 0x41, 0x5A);
    for (ranged_unicode_scalar_buf) |item| try std.testing.expect(item >= 0x41 and item <= 0x5A);

    const ranged_unicode_scalar_owned = try Rng.unicodeScalarRangeLessThanBatchCheckedFrom(&engine, std.testing.allocator, 8, 0xD7F0, 0xE010);
    defer std.testing.allocator.free(ranged_unicode_scalar_owned);
    for (ranged_unicode_scalar_owned) |item| {
        try std.testing.expect(item >= 0xD7F0 and item < 0xE010);
        try std.testing.expect(isUnicodeScalar(item));
    }

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

    const standard_normal = rng.standardNormal(f64);
    try std.testing.expect(std.math.isFinite(standard_normal));
    const direct_standard_normal = Rng.standardNormalFrom(&engine, f32);
    try std.testing.expect(std.math.isFinite(direct_standard_normal));

    var standard_normal_buf: [16]f64 = undefined;
    rng.fillStandardNormal(f64, &standard_normal_buf);
    for (standard_normal_buf) |item| try std.testing.expect(std.math.isFinite(item));

    var direct_standard_normal_buf: [16]f64 = undefined;
    Rng.fillStandardNormalFrom(&engine, f64, &direct_standard_normal_buf);
    for (direct_standard_normal_buf) |item| try std.testing.expect(std.math.isFinite(item));

    const standard_normal_owned = try rng.standardNormalBatch(f64, std.testing.allocator, 8);
    defer std.testing.allocator.free(standard_normal_owned);
    for (standard_normal_owned) |item| try std.testing.expect(std.math.isFinite(item));

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

    const standard_exponential = rng.standardExponential(f64);
    try std.testing.expect(standard_exponential >= 0);
    const direct_standard_exponential = Rng.standardExponentialFrom(&engine, f32);
    try std.testing.expect(direct_standard_exponential >= 0);

    var standard_exp_buf: [16]f64 = undefined;
    rng.fillStandardExponential(f64, &standard_exp_buf);
    for (standard_exp_buf) |item| try std.testing.expect(item >= 0);

    var direct_standard_exp_buf: [16]f64 = undefined;
    Rng.fillStandardExponentialFrom(&engine, f64, &direct_standard_exp_buf);
    for (direct_standard_exp_buf) |item| try std.testing.expect(item >= 0);

    const standard_exponential_owned = try rng.standardExponentialBatch(f64, std.testing.allocator, 8);
    defer std.testing.allocator.free(standard_exponential_owned);
    for (standard_exponential_owned) |item| try std.testing.expect(item >= 0);

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

    const vec_standard_normal_owned = try rng.vectorStandardNormalBatch(@Vector(8, f32), std.testing.allocator, 4);
    defer std.testing.allocator.free(vec_standard_normal_owned);
    for (vec_standard_normal_owned) |vec| inline for (0..8) |i| try std.testing.expect(std.math.isFinite(vec[i]));

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

    const vec_standard_exponential_owned = try rng.vectorStandardExponentialBatch(@Vector(8, f32), std.testing.allocator, 4);
    defer std.testing.allocator.free(vec_standard_exponential_owned);
    for (vec_standard_exponential_owned) |vec| inline for (0..8) |i| try std.testing.expect(vec[i] >= 0);

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
    try std.testing.expectError(error.NonFinite, rng.vectorRangeChecked(@Vector(4, f64), std.math.inf(f64), 1));
    try std.testing.expectError(error.NonFinite, Rng.vectorRangeCheckedFrom(&engine, @Vector(4, f64), std.math.inf(f64), 1));
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
    try std.testing.expectError(error.InvalidParameter, rng.vectorExponentialChecked(@Vector(4, f64), std.math.nan(f64)));
    try std.testing.expectError(error.InvalidParameter, Rng.vectorNormalCheckedFrom(&engine, @Vector(4, f64), 0, -1));
    try std.testing.expectError(error.InvalidParameter, Rng.vectorExponentialCheckedFrom(&engine, @Vector(4, f64), 0));
    try rng.fillRangeChecked(u32, &.{}, 3, 3);
    try Rng.fillRangeCheckedFrom(&engine, u32, &.{}, 3, 3);
    try Rng.fillChanceCheckedFrom(&engine, &.{}, -0.1);
    try Rng.fillRatioCheckedFrom(&engine, &.{}, 2, 1);
    try std.testing.expectError(error.InvalidParameter, rng.fillNormalChecked(f64, &normal_buf, 0, -1));
    try std.testing.expectError(error.InvalidParameter, rng.fillExponentialChecked(f64, &exp_buf, 0));
    try std.testing.expectError(error.InvalidParameter, Rng.fillNormalCheckedFrom(&engine, f64, &normal_buf, 0, -1));
    try std.testing.expectError(error.InvalidParameter, Rng.fillExponentialCheckedFrom(&engine, f64, &exp_buf, 0));
    try std.testing.expectError(error.InvalidParameter, rng.normalChecked(f64, 0, -1));
    try std.testing.expectError(error.InvalidParameter, Rng.normalCheckedFrom(&engine, f64, std.math.inf(f64), 1));
    try std.testing.expectError(error.InvalidParameter, rng.exponentialChecked(f64, 0));
    try std.testing.expectError(error.InvalidParameter, Rng.exponentialCheckedFrom(&engine, f64, std.math.nan(f64)));
}

test "rng direct try raw aliases propagate source failures" {
    const FallibleSource = struct {
        words: []const u64,
        index: usize = 0,
        fail_after: ?usize = null,

        fn next(self: *@This()) u64 {
            const word = self.words[self.index];
            self.index += 1;
            return word;
        }

        fn fill(self: *@This(), out: []u8) void {
            var i: usize = 0;
            while (i < out.len) {
                const word = self.next();
                var word_bytes: [8]u8 = undefined;
                std.mem.writeInt(u64, &word_bytes, word, .little);
                const n = @min(8, out.len - i);
                @memcpy(out[i..][0..n], word_bytes[0..n]);
                i += n;
            }
        }

        fn tryNext(self: *@This()) error{NoSeed}!u64 {
            if (self.fail_after) |limit| {
                if (self.index >= limit) return error.NoSeed;
            }
            if (self.index >= self.words.len) return error.NoSeed;
            return self.next();
        }

        fn tryFillBytes(self: *@This(), out: []u8) error{NoSeed}!void {
            var i: usize = 0;
            while (i < out.len) {
                const word = try self.tryNext();
                var word_bytes: [8]u8 = undefined;
                std.mem.writeInt(u64, &word_bytes, word, .little);
                const n = @min(8, out.len - i);
                @memcpy(out[i..][0..n], word_bytes[0..n]);
                i += n;
            }
        }
    };

    const words = [_]u64{
        0x0123_4567_89ab_cdef,
        0xfedc_ba98_7654_3210,
    };

    var ok_u64 = FallibleSource{ .words = &words };
    try std.testing.expectEqual(words[0], try Rng.tryNextU64From(&ok_u64));
    try std.testing.expectEqual(@as(usize, 1), ok_u64.index);

    var ok_u32 = FallibleSource{ .words = &words };
    try std.testing.expectEqual(@as(u32, @truncate(words[0] >> 32)), try Rng.tryNextU32From(&ok_u32));
    try std.testing.expectEqual(@as(usize, 1), ok_u32.index);

    var ok_fill = FallibleSource{ .words = &words };
    var buf: [12]u8 = undefined;
    try Rng.tryFillBytesFrom(&ok_fill, &buf);
    var expected: [12]u8 = undefined;
    std.mem.writeInt(u64, expected[0..8], words[0], .little);
    std.mem.writeInt(u32, expected[8..12], @truncate(words[1]), .little);
    try std.testing.expectEqualSlices(u8, &expected, &buf);
    try std.testing.expectEqual(@as(usize, 2), ok_fill.index);

    var fail_next = FallibleSource{ .words = &words, .fail_after = 0 };
    try std.testing.expectError(error.NoSeed, Rng.tryNextU64From(&fail_next));
    try std.testing.expectEqual(@as(usize, 0), fail_next.index);

    var fail_fill = FallibleSource{ .words = &words, .fail_after = 1 };
    try std.testing.expectError(error.NoSeed, Rng.tryFillBytesFrom(&fail_fill, &buf));
    try std.testing.expectEqual(@as(usize, 1), fail_fill.index);
}

test "rng reader adapter streams deterministic bytes" {
    const StepSource = struct {
        value: u64,
        increment: u64,

        fn next(self: *@This()) u64 {
            const word = self.value;
            self.value +%= self.increment;
            return word;
        }
    };

    var source = StepSource{ .value = 255, .increment = 1 };
    var reader_buffer: [8]u8 = undefined;
    var adapter = rngReader(&source, &reader_buffer);

    var out: [24]u8 = undefined;
    try adapter.readAll(&out);

    try std.testing.expectEqualSlices(u8, &.{
        255, 0, 0, 0, 0, 0, 0, 0,
        0,   1, 0, 0, 0, 0, 0, 0,
        1,   1, 0, 0, 0, 0, 0, 0,
    }, &out);
    try std.testing.expectEqual(@as(u64, 258), source.value);
    try std.testing.expectEqual(@as(?anyerror, null), adapter.lastError());

    const owned_source = StepSource{ .value = 255, .increment = 1 };
    var owned_reader_buffer: [8]u8 = undefined;
    var owned_adapter = rngReader(owned_source, &owned_reader_buffer);
    var owned_out: [24]u8 = undefined;
    try owned_adapter.reader().readSliceAll(&owned_out);
    try std.testing.expectEqualSlices(u8, &out, &owned_out);
    try std.testing.expectEqual(@as(u64, 255), owned_source.value);
    try std.testing.expectEqual(@as(u64, 258), owned_adapter.source.value);

    var reader_from_source = StepSource{ .value = 255, .increment = 1 };
    var reader_from_buffer: [8]u8 = undefined;
    var reader_from_adapter = readerFrom(&reader_from_source, &reader_from_buffer);
    var reader_from_out: [24]u8 = undefined;
    try reader_from_adapter.readAll(&reader_from_out);
    try std.testing.expectEqualSlices(u8, &out, &reader_from_out);
}

test "rng reader adapter integrates with Io stream and discard" {
    const alea = @import("root.zig");

    var stream_engine = alea.ScalarPrng.init(0x5eed);
    var direct_engine = alea.ScalarPrng.init(0x5eed);
    var reader_buffer: [16]u8 = undefined;
    var adapter = Rng.init(&stream_engine).reader(&reader_buffer);

    var written: [19]u8 = undefined;
    var writer = std.Io.Writer.fixed(&written);
    try std.testing.expectEqual(@as(usize, 19), try adapter.reader().stream(&writer, .limited(19)));

    var expected: [19]u8 = undefined;
    direct_engine.fill(&expected);
    try std.testing.expectEqualSlices(u8, &expected, &written);

    try std.testing.expectEqual(@as(usize, 5), try adapter.reader().discard(.limited(5)));
    var skipped: [5]u8 = undefined;
    direct_engine.fill(&skipped);

    var after_skip: [7]u8 = undefined;
    try adapter.readAll(&after_skip);
    var expected_after_skip: [7]u8 = undefined;
    direct_engine.fill(&expected_after_skip);
    try std.testing.expectEqualSlices(u8, &expected_after_skip, &after_skip);
}

test "rng reader adapter propagates fallible sources" {
    const FallibleSource = struct {
        words: []const u64,
        index: usize = 0,
        fail_after: ?usize = null,

        fn tryNext(self: *@This()) error{NoSeed}!u64 {
            if (self.fail_after) |limit| {
                if (self.index >= limit) return error.NoSeed;
            }
            if (self.index >= self.words.len) return error.NoSeed;
            const word = self.words[self.index];
            self.index += 1;
            return word;
        }
    };

    const words = [_]u64{
        0x0123_4567_89ab_cdef,
        0xfedc_ba98_7654_3210,
    };

    var source = FallibleSource{ .words = &words, .fail_after = 1 };
    var reader_buffer: [8]u8 = undefined;
    var adapter = rngReader(&source, &reader_buffer);
    var out: [12]u8 = undefined;
    try std.testing.expectError(error.ReadFailed, adapter.readAll(&out));
    try std.testing.expectEqual(error.NoSeed, adapter.lastError().?);
    try std.testing.expectEqual(@as(usize, 1), source.index);
}

test "sys rng source uses Io entropy and propagates failures" {
    const io = std.Io.Threaded.global_single_threaded.io();
    const sys = SysRng.init(io);

    var entropy_bytes: [16]u8 = undefined;
    try sys.tryFillBytes(&entropy_bytes);
    _ = try sys.tryNextU64();
    _ = try sys.tryNextU32();

    var direct_bytes: [8]u8 = undefined;
    try tryFillBytesFrom(sys, &direct_bytes);

    var borrowed_sys = SysRng.init(io);
    var borrowed_bytes: [8]u8 = undefined;
    try tryFillBytesFrom(&borrowed_sys, &borrowed_bytes);

    var reader_buffer: [8]u8 = undefined;
    var adapter = sys.reader(&reader_buffer);
    var reader_bytes: [8]u8 = undefined;
    try adapter.readAll(&reader_bytes);

    const failing = SysRng.init(std.Io.failing);
    try std.testing.expectError(error.EntropyUnavailable, failing.tryFillBytes(&entropy_bytes));
    try std.testing.expectError(error.EntropyUnavailable, failing.tryNextU64());
    try std.testing.expectError(error.EntropyUnavailable, failing.tryNextU32());
    try std.testing.expectError(error.EntropyUnavailable, tryFillBytesFrom(failing, &direct_bytes));

    var failing_reader_buffer: [8]u8 = undefined;
    var failing_reader = failing.reader(&failing_reader_buffer);
    try std.testing.expectError(error.ReadFailed, failing_reader.readAll(&reader_bytes));
    try std.testing.expectEqual(error.EntropyUnavailable, failing_reader.lastError().?);
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

test "owned strict interval batches preserve fill stream shape" {
    const alea = @import("root.zig");
    inline for (.{ alea.ScalarPrng, alea.FastPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_0888);
        var direct_engine = Engine.init(0x5150_0888);
        const rng = Rng.init(&facade_engine);

        const open_values = try rng.openBatch(f64, std.testing.allocator, 32);
        defer std.testing.allocator.free(open_values);
        var direct_open_values: [32]f64 = undefined;
        fillOpenFrom(&direct_engine, f64, &direct_open_values);
        try std.testing.expectEqualSlices(f64, &direct_open_values, open_values);
        for (open_values) |draw| try std.testing.expect(draw > 0 and draw < 1);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const open_closed_values = try rng.openClosedBatch(f32, std.testing.allocator, 32);
        defer std.testing.allocator.free(open_closed_values);
        var direct_open_closed_values: [32]f32 = undefined;
        fillOpenClosedFrom(&direct_engine, f32, &direct_open_closed_values);
        try std.testing.expectEqualSlices(f32, &direct_open_closed_values, open_closed_values);
        for (open_closed_values) |draw| try std.testing.expect(draw > 0 and draw <= 1);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
}

test "owned vector strict interval batches preserve fill stream shape" {
    const alea = @import("root.zig");
    inline for (.{ alea.ScalarPrng, alea.FastPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_0930);
        var direct_engine = Engine.init(0x5150_0930);
        const rng = Rng.init(&facade_engine);

        const open_values = try rng.vectorOpenBatch(@Vector(8, f32), std.testing.allocator, 8);
        defer std.testing.allocator.free(open_values);
        var direct_open_values: [8]@Vector(8, f32) = undefined;
        fillVectorOpenFrom(&direct_engine, @Vector(8, f32), &direct_open_values);
        try std.testing.expectEqualSlices(@Vector(8, f32), &direct_open_values, open_values);
        for (open_values) |vec| {
            inline for (0..8) |lane| try std.testing.expect(vec[lane] > 0 and vec[lane] < 1);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const open_closed_values = try rng.vectorOpenClosedBatch(@Vector(4, f64), std.testing.allocator, 8);
        defer std.testing.allocator.free(open_closed_values);
        var direct_open_closed_values: [8]@Vector(4, f64) = undefined;
        fillVectorOpenClosedFrom(&direct_engine, @Vector(4, f64), &direct_open_closed_values);
        try std.testing.expectEqualSlices(@Vector(4, f64), &direct_open_closed_values, open_closed_values);
        for (open_closed_values) |vec| {
            inline for (0..4) |lane| try std.testing.expect(vec[lane] > 0 and vec[lane] <= 1);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
}

test "owned strict interval batches allocate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_0889);
    var control = alea.ScalarPrng.init(0x5150_0889);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.openBatch(f32, empty_alloc.allocator(), 0);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var open_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.openBatch(f64, open_alloc.allocator(), 8));
    try std.testing.expect(open_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var open_closed_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, openClosedBatchFrom(&engine, f32, open_closed_alloc.allocator(), 8));
    try std.testing.expect(open_closed_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned vector strict interval batches allocate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_0931);
    var control = alea.ScalarPrng.init(0x5150_0931);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.vectorOpenBatch(@Vector(8, f32), empty_alloc.allocator(), 0);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var open_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.vectorOpenBatch(@Vector(8, f32), open_alloc.allocator(), 8));
    try std.testing.expect(open_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var open_closed_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, vectorOpenClosedBatchFrom(&engine, @Vector(4, f64), open_closed_alloc.allocator(), 8));
    try std.testing.expect(open_closed_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
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

test "unicode scalar fills and batches preserve scalar stream shape" {
    const alea = @import("root.zig");

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var manual = Engine.init(0x5150_97a0);
        var filled = Engine.init(0x5150_97a0);

        var manual_buf: [8]u21 = undefined;
        for (&manual_buf) |*item| item.* = unicodeScalarFrom(&manual);

        var filled_buf: [8]u21 = undefined;
        fillUnicodeScalarFrom(&filled, &filled_buf);

        try std.testing.expectEqualSlices(u21, &manual_buf, &filled_buf);
        try std.testing.expectEqual(manual.next(), filled.next());

        var owned_manual = Engine.init(0x5150_97a1);
        var owned = Engine.init(0x5150_97a1);
        var owned_manual_buf: [8]u21 = undefined;
        for (&owned_manual_buf) |*item| item.* = unicodeScalarFrom(&owned_manual);

        const owned_buf = try unicodeScalarBatchFrom(&owned, std.testing.allocator, 8);
        defer std.testing.allocator.free(owned_buf);

        try std.testing.expectEqualSlices(u21, &owned_manual_buf, owned_buf);
        try std.testing.expectEqual(owned_manual.next(), owned.next());
    }
}

test "unicode scalar range helpers preserve checked stream shape" {
    const alea = @import("root.zig");

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var unchecked = Engine.init(0x5150_98a0);
        var checked = Engine.init(0x5150_98a0);

        var less_than_unchecked: [16]u21 = undefined;
        var less_than_checked: [16]u21 = undefined;
        fillUnicodeScalarRangeLessThanFrom(&unchecked, &less_than_unchecked, 0xD7F0, 0xE010);
        try fillUnicodeScalarRangeLessThanCheckedFrom(&checked, &less_than_checked, 0xD7F0, 0xE010);
        try std.testing.expectEqualSlices(u21, &less_than_unchecked, &less_than_checked);
        for (less_than_unchecked) |draw| {
            try std.testing.expect(draw >= 0xD7F0 and draw < 0xE010);
            try std.testing.expect(draw < 0xD800 or draw > 0xDFFF);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const less_than_owned = try unicodeScalarRangeLessThanBatchFrom(&unchecked, std.testing.allocator, 16, 0xD7F0, 0xE010);
        defer std.testing.allocator.free(less_than_owned);
        const less_than_checked_owned = try unicodeScalarRangeLessThanBatchCheckedFrom(&checked, std.testing.allocator, 16, 0xD7F0, 0xE010);
        defer std.testing.allocator.free(less_than_checked_owned);
        try std.testing.expectEqualSlices(u21, less_than_owned, less_than_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var at_most_unchecked: [16]u21 = undefined;
        var at_most_checked: [16]u21 = undefined;
        fillUnicodeScalarRangeAtMostFrom(&unchecked, &at_most_unchecked, 0x41, 0x5A);
        try fillUnicodeScalarRangeAtMostCheckedFrom(&checked, &at_most_checked, 0x41, 0x5A);
        try std.testing.expectEqualSlices(u21, &at_most_unchecked, &at_most_checked);
        for (at_most_unchecked) |draw| try std.testing.expect(draw >= 0x41 and draw <= 0x5A);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const at_most_owned = try unicodeScalarRangeAtMostBatchFrom(&unchecked, std.testing.allocator, 16, 0x41, 0x5A);
        defer std.testing.allocator.free(at_most_owned);
        const at_most_checked_owned = try unicodeScalarRangeAtMostBatchCheckedFrom(&checked, std.testing.allocator, 16, 0x41, 0x5A);
        defer std.testing.allocator.free(at_most_checked_owned);
        try std.testing.expectEqualSlices(u21, at_most_owned, at_most_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());
    }
}

test "unicode scalar ranges handle surrogate gap and degenerate ranges" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_98a2);
    var control = alea.ScalarPrng.init(0x5150_98a2);
    const rng = Rng.init(&engine);

    try std.testing.expectEqual(@as(u21, 0x41), rng.unicodeScalarRangeLessThan(0x41, 0x42));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(u21, 0xE000), try unicodeScalarRangeAtMostCheckedFrom(&engine, 0xE000, 0xE000));
    try std.testing.expectEqual(control.next(), engine.next());

    var gap_engine = alea.ScalarPrng.init(0x5150_98a4);
    const gap_rng = Rng.init(&gap_engine);
    var gap_crossing: [64]u21 = undefined;
    gap_rng.fillUnicodeScalarRangeLessThan(&gap_crossing, 0xD7F0, 0xE010);
    for (gap_crossing) |draw| {
        try std.testing.expect(draw >= 0xD7F0 and draw < 0xE010);
        try std.testing.expect(isUnicodeScalar(draw));
    }

    var degenerate: [5]u21 = undefined;
    try fillUnicodeScalarRangeAtMostCheckedFrom(&engine, &degenerate, 0x10FFFF, 0x10FFFF);
    for (degenerate) |draw| try std.testing.expectEqual(@as(u21, 0x10FFFF), draw);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid unicode scalar ranges do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_98a3);
    var control = alea.ScalarPrng.init(0x5150_98a3);
    const rng = Rng.init(&engine);

    try std.testing.expectError(error.InvalidParameter, rng.unicodeScalarRangeLessThanChecked(0xD800, 0xE000));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, unicodeScalarRangeLessThanCheckedFrom(&engine, 0x41, 0x41));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, rng.unicodeScalarRangeAtMostChecked(0x41, 0xD800));
    try std.testing.expectEqual(control.next(), engine.next());

    var out: [4]u21 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillUnicodeScalarRangeLessThanCheckedFrom(&engine, &out, 0xD800, 0xE000));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.fillUnicodeScalarRangeAtMostChecked(&out, 0x5A, 0x41));
    try std.testing.expectEqual(control.next(), engine.next());
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

test "owned duration range batches preserve checked stream shape" {
    const alea = @import("root.zig");
    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var unchecked = Engine.init(0x5150_d901);
        var checked = Engine.init(0x5150_d901);
        const min = std.Io.Duration.fromMilliseconds(10);
        const max = std.Io.Duration.fromMilliseconds(20);

        const less_than = try durationRangeLessThanBatchFrom(&unchecked, std.testing.allocator, 8, min, max);
        defer std.testing.allocator.free(less_than);
        const checked_less_than = try durationRangeLessThanBatchCheckedFrom(&checked, std.testing.allocator, 8, min, max);
        defer std.testing.allocator.free(checked_less_than);
        try std.testing.expectEqualSlices(std.Io.Duration, less_than, checked_less_than);
        for (less_than) |draw| {
            try std.testing.expect(draw.nanoseconds >= min.nanoseconds);
            try std.testing.expect(draw.nanoseconds < max.nanoseconds);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const at_most = try durationRangeAtMostBatchFrom(&unchecked, std.testing.allocator, 8, min, max);
        defer std.testing.allocator.free(at_most);
        const checked_at_most = try durationRangeAtMostBatchCheckedFrom(&checked, std.testing.allocator, 8, min, max);
        defer std.testing.allocator.free(checked_at_most);
        try std.testing.expectEqualSlices(std.Io.Duration, at_most, checked_at_most);
        for (at_most) |draw| {
            try std.testing.expect(draw.nanoseconds >= min.nanoseconds);
            try std.testing.expect(draw.nanoseconds <= max.nanoseconds);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());
    }
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

    const chosen_index = Rng.chooseIndexFrom(&engine, values.len).?;
    try std.testing.expect(chosen_index < values.len);
    const checked_chosen_index = try Rng.chooseIndexCheckedFrom(&engine, values.len);
    try std.testing.expect(checked_chosen_index < values.len);
    const chosen_index_u32 = Rng.chooseIndexU32From(&engine, @intCast(values.len)).?;
    try std.testing.expect(chosen_index_u32 < values.len);
    const checked_chosen_index_u32 = try Rng.chooseIndexU32CheckedFrom(&engine, @intCast(values.len));
    try std.testing.expect(checked_chosen_index_u32 < values.len);

    const chosen_const_ptr = Rng.chooseConstPtrFrom(&engine, u8, &values).?;
    try std.testing.expect(chosen_const_ptr.* >= 1 and chosen_const_ptr.* <= 5);
    const checked_chosen_const_ptr = try Rng.chooseConstPtrCheckedFrom(&engine, u8, &values);
    try std.testing.expect(checked_chosen_const_ptr.* >= 1 and checked_chosen_const_ptr.* <= 5);

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

    const sampled_items = try rng.sampleWithoutReplacement(u8, std.testing.allocator, &values, 3);
    defer std.testing.allocator.free(sampled_items);
    try std.testing.expectEqual(@as(usize, 3), sampled_items.len);

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
    const ValueType = struct { u16, bool, f64 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var unchecked = Engine.init(0x5eed_5150);
        var checked = Engine.init(0x5eed_5150);

        const value_unchecked = valueFrom(&unchecked, ValueType);
        const value_checked = try valueCheckedFrom(&checked, ValueType);
        try std.testing.expectEqual(value_unchecked, value_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const EmptyEnum = enum {};
        const ZeroEmptyArrayTuple = struct { u8, [0]EmptyEnum };
        const zero_unchecked = valueFrom(&unchecked, ZeroEmptyArrayTuple);
        const zero_checked = try valueCheckedFrom(&checked, ZeroEmptyArrayTuple);
        try std.testing.expectEqual(zero_unchecked[0], zero_checked[0]);
        try std.testing.expectEqual(@as(usize, 0), zero_checked[1].len);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const LateZeroEmptyArrayTuple = struct { u8, [0]EmptyEnum, f32 };
        const late_zero_unchecked = valueFrom(&unchecked, LateZeroEmptyArrayTuple);
        const late_zero_checked = try valueCheckedFrom(&checked, LateZeroEmptyArrayTuple);
        try std.testing.expectEqual(late_zero_unchecked[0], late_zero_checked[0]);
        try std.testing.expectEqual(@as(usize, 0), late_zero_checked[1].len);
        try std.testing.expectEqual(late_zero_unchecked[2], late_zero_checked[2]);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var range_unchecked: [8]u32 = undefined;
        var range_checked: [8]u32 = undefined;
        fillRangeFrom(&unchecked, u32, &range_unchecked, 5, 9);
        try fillRangeCheckedFrom(&checked, u32, &range_checked, 5, 9);
        try std.testing.expectEqualSlices(u32, &range_unchecked, &range_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const range_owned = try rangeBatchFrom(&unchecked, u32, std.testing.allocator, 8, 5, 9);
        defer std.testing.allocator.free(range_owned);
        const range_checked_owned = try rangeBatchCheckedFrom(&checked, u32, std.testing.allocator, 8, 5, 9);
        defer std.testing.allocator.free(range_checked_owned);
        try std.testing.expectEqualSlices(u32, range_owned, range_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var range_at_most_unchecked: [8]i32 = undefined;
        var range_at_most_checked: [8]i32 = undefined;
        fillRangeAtMostFrom(&unchecked, i32, &range_at_most_unchecked, -5, 5);
        try fillRangeAtMostCheckedFrom(&checked, i32, &range_at_most_checked, -5, 5);
        try std.testing.expectEqualSlices(i32, &range_at_most_unchecked, &range_at_most_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const range_at_most_owned = try rangeAtMostBatchFrom(&unchecked, i32, std.testing.allocator, 8, -5, 5);
        defer std.testing.allocator.free(range_at_most_owned);
        const range_at_most_checked_owned = try rangeAtMostBatchCheckedFrom(&checked, i32, std.testing.allocator, 8, -5, 5);
        defer std.testing.allocator.free(range_at_most_checked_owned);
        try std.testing.expectEqualSlices(i32, range_at_most_owned, range_at_most_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var uint_less_unchecked: [8]u32 = undefined;
        var uint_less_checked: [8]u32 = undefined;
        fillUintLessThanFrom(&unchecked, u32, &uint_less_unchecked, 1000);
        try fillUintLessThanCheckedFrom(&checked, u32, &uint_less_checked, 1000);
        try std.testing.expectEqualSlices(u32, &uint_less_unchecked, &uint_less_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const uint_less_owned = try uintLessThanBatchFrom(&unchecked, u32, std.testing.allocator, 8, 1000);
        defer std.testing.allocator.free(uint_less_owned);
        const uint_less_checked_owned = try uintLessThanBatchCheckedFrom(&checked, u32, std.testing.allocator, 8, 1000);
        defer std.testing.allocator.free(uint_less_checked_owned);
        try std.testing.expectEqualSlices(u32, uint_less_owned, uint_less_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var uint_at_most_unchecked: [8]u32 = undefined;
        fillUintAtMostFrom(&unchecked, u32, &uint_at_most_unchecked, 999);
        try fillUintLessThanCheckedFrom(&checked, u32, &uint_less_checked, 1000);
        try std.testing.expectEqualSlices(u32, &uint_at_most_unchecked, &uint_less_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const uint_at_most_owned = try uintAtMostBatchFrom(&unchecked, u32, std.testing.allocator, 8, 999);
        defer std.testing.allocator.free(uint_at_most_owned);
        const uint_at_most_checked_owned = try uintLessThanBatchCheckedFrom(&checked, u32, std.testing.allocator, 8, 1000);
        defer std.testing.allocator.free(uint_at_most_checked_owned);
        try std.testing.expectEqualSlices(u32, uint_at_most_owned, uint_at_most_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var chance_unchecked: [16]bool = undefined;
        var chance_checked: [16]bool = undefined;
        fillChanceFrom(&unchecked, &chance_unchecked, 0.25);
        try fillChanceCheckedFrom(&checked, &chance_checked, 0.25);
        try std.testing.expectEqualSlices(bool, &chance_unchecked, &chance_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const chance_owned = try chanceBatchFrom(&unchecked, std.testing.allocator, 16, 0.25);
        defer std.testing.allocator.free(chance_owned);
        const chance_checked_owned = try chanceBatchCheckedFrom(&checked, std.testing.allocator, 16, 0.25);
        defer std.testing.allocator.free(chance_checked_owned);
        try std.testing.expectEqualSlices(bool, chance_owned, chance_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var ratio_unchecked: [16]bool = undefined;
        var ratio_checked: [16]bool = undefined;
        fillRatioFrom(&unchecked, &ratio_unchecked, 3, 8);
        try fillRatioCheckedFrom(&checked, &ratio_checked, 3, 8);
        try std.testing.expectEqualSlices(bool, &ratio_unchecked, &ratio_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const ratio_owned = try ratioBatchFrom(&unchecked, std.testing.allocator, 16, 3, 8);
        defer std.testing.allocator.free(ratio_owned);
        const ratio_checked_owned = try ratioBatchCheckedFrom(&checked, std.testing.allocator, 16, 3, 8);
        defer std.testing.allocator.free(ratio_checked_owned);
        try std.testing.expectEqualSlices(bool, ratio_owned, ratio_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var normal_unchecked: [8]f64 = undefined;
        var normal_checked: [8]f64 = undefined;
        fillNormalFrom(&unchecked, f64, &normal_unchecked, 0, 1);
        try fillNormalCheckedFrom(&checked, f64, &normal_checked, 0, 1);
        try std.testing.expectEqualSlices(f64, &normal_unchecked, &normal_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var standard_normal_unchecked: [8]f64 = undefined;
        var standard_normal_checked: [8]f64 = undefined;
        fillStandardNormalFrom(&unchecked, f64, &standard_normal_unchecked);
        try fillNormalCheckedFrom(&checked, f64, &standard_normal_checked, 0, 1);
        try std.testing.expectEqualSlices(f64, &standard_normal_unchecked, &standard_normal_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const normal_owned = try normalBatchFrom(&unchecked, f64, std.testing.allocator, 8, 0, 1);
        defer std.testing.allocator.free(normal_owned);
        const normal_checked_owned = try normalBatchCheckedFrom(&checked, f64, std.testing.allocator, 8, 0, 1);
        defer std.testing.allocator.free(normal_checked_owned);
        try std.testing.expectEqualSlices(f64, normal_owned, normal_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const standard_normal_owned = try standardNormalBatchFrom(&unchecked, f64, std.testing.allocator, 8);
        defer std.testing.allocator.free(standard_normal_owned);
        const standard_normal_checked_owned = try normalBatchCheckedFrom(&checked, f64, std.testing.allocator, 8, 0, 1);
        defer std.testing.allocator.free(standard_normal_checked_owned);
        try std.testing.expectEqualSlices(f64, standard_normal_owned, standard_normal_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var exponential_unchecked: [8]f64 = undefined;
        var exponential_checked: [8]f64 = undefined;
        fillExponentialFrom(&unchecked, f64, &exponential_unchecked, 1);
        try fillExponentialCheckedFrom(&checked, f64, &exponential_checked, 1);
        try std.testing.expectEqualSlices(f64, &exponential_unchecked, &exponential_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var standard_exponential_unchecked: [8]f64 = undefined;
        var standard_exponential_checked: [8]f64 = undefined;
        fillStandardExponentialFrom(&unchecked, f64, &standard_exponential_unchecked);
        try fillExponentialCheckedFrom(&checked, f64, &standard_exponential_checked, 1);
        try std.testing.expectEqualSlices(f64, &standard_exponential_unchecked, &standard_exponential_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const exponential_owned = try exponentialBatchFrom(&unchecked, f64, std.testing.allocator, 8, 1);
        defer std.testing.allocator.free(exponential_owned);
        const exponential_checked_owned = try exponentialBatchCheckedFrom(&checked, f64, std.testing.allocator, 8, 1);
        defer std.testing.allocator.free(exponential_checked_owned);
        try std.testing.expectEqualSlices(f64, exponential_owned, exponential_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const standard_exponential_owned = try standardExponentialBatchFrom(&unchecked, f64, std.testing.allocator, 8);
        defer std.testing.allocator.free(standard_exponential_owned);
        const standard_exponential_checked_owned = try exponentialBatchCheckedFrom(&checked, f64, std.testing.allocator, 8, 1);
        defer std.testing.allocator.free(standard_exponential_checked_owned);
        try std.testing.expectEqualSlices(f64, standard_exponential_owned, standard_exponential_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_range_unchecked: [4]@Vector(8, f32) = undefined;
        var vector_range_checked: [4]@Vector(8, f32) = undefined;
        fillVectorRangeFrom(&unchecked, @Vector(8, f32), &vector_range_unchecked, -1, 1);
        try fillVectorRangeCheckedFrom(&checked, @Vector(8, f32), &vector_range_checked, -1, 1);
        try std.testing.expectEqualSlices(@Vector(8, f32), &vector_range_unchecked, &vector_range_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const vector_range_owned = try vectorRangeBatchFrom(&unchecked, @Vector(8, f32), std.testing.allocator, 4, -1, 1);
        defer std.testing.allocator.free(vector_range_owned);
        const vector_range_checked_owned = try vectorRangeBatchCheckedFrom(&checked, @Vector(8, f32), std.testing.allocator, 4, -1, 1);
        defer std.testing.allocator.free(vector_range_checked_owned);
        try std.testing.expectEqualSlices(@Vector(8, f32), vector_range_owned, vector_range_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_range_at_most_unchecked: [4]@Vector(8, i32) = undefined;
        var vector_range_at_most_checked: [4]@Vector(8, i32) = undefined;
        fillVectorRangeAtMostFrom(&unchecked, @Vector(8, i32), &vector_range_at_most_unchecked, -5, 5);
        try fillVectorRangeAtMostCheckedFrom(&checked, @Vector(8, i32), &vector_range_at_most_checked, -5, 5);
        try std.testing.expectEqualSlices(@Vector(8, i32), &vector_range_at_most_unchecked, &vector_range_at_most_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const vector_range_at_most_owned = try vectorRangeAtMostBatchFrom(&unchecked, @Vector(8, i32), std.testing.allocator, 4, -5, 5);
        defer std.testing.allocator.free(vector_range_at_most_owned);
        const vector_range_at_most_checked_owned = try vectorRangeAtMostBatchCheckedFrom(&checked, @Vector(8, i32), std.testing.allocator, 4, -5, 5);
        defer std.testing.allocator.free(vector_range_at_most_checked_owned);
        try std.testing.expectEqualSlices(@Vector(8, i32), vector_range_at_most_owned, vector_range_at_most_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_chance_unchecked: [4]@Vector(8, bool) = undefined;
        var vector_chance_checked: [4]@Vector(8, bool) = undefined;
        fillVectorChanceFrom(&unchecked, @Vector(8, bool), &vector_chance_unchecked, 0.25);
        try fillVectorChanceCheckedFrom(&checked, @Vector(8, bool), &vector_chance_checked, 0.25);
        try std.testing.expectEqualSlices(@Vector(8, bool), &vector_chance_unchecked, &vector_chance_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const vector_chance_owned = try vectorChanceBatchFrom(&unchecked, @Vector(8, bool), std.testing.allocator, 4, 0.25);
        defer std.testing.allocator.free(vector_chance_owned);
        const vector_chance_checked_owned = try vectorChanceBatchCheckedFrom(&checked, @Vector(8, bool), std.testing.allocator, 4, 0.25);
        defer std.testing.allocator.free(vector_chance_checked_owned);
        try std.testing.expectEqualSlices(@Vector(8, bool), vector_chance_owned, vector_chance_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_ratio_unchecked: [4]@Vector(8, bool) = undefined;
        var vector_ratio_checked: [4]@Vector(8, bool) = undefined;
        fillVectorRatioFrom(&unchecked, @Vector(8, bool), &vector_ratio_unchecked, 3, 8);
        try fillVectorRatioCheckedFrom(&checked, @Vector(8, bool), &vector_ratio_checked, 3, 8);
        try std.testing.expectEqualSlices(@Vector(8, bool), &vector_ratio_unchecked, &vector_ratio_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const vector_ratio_owned = try vectorRatioBatchFrom(&unchecked, @Vector(8, bool), std.testing.allocator, 4, 3, 8);
        defer std.testing.allocator.free(vector_ratio_owned);
        const vector_ratio_checked_owned = try vectorRatioBatchCheckedFrom(&checked, @Vector(8, bool), std.testing.allocator, 4, 3, 8);
        defer std.testing.allocator.free(vector_ratio_checked_owned);
        try std.testing.expectEqualSlices(@Vector(8, bool), vector_ratio_owned, vector_ratio_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_normal_unchecked: [4]@Vector(8, f32) = undefined;
        var vector_normal_checked: [4]@Vector(8, f32) = undefined;
        fillVectorNormalFrom(&unchecked, @Vector(8, f32), &vector_normal_unchecked, 0, 1);
        try fillVectorNormalCheckedFrom(&checked, @Vector(8, f32), &vector_normal_checked, 0, 1);
        try std.testing.expectEqualSlices(@Vector(8, f32), &vector_normal_unchecked, &vector_normal_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_standard_normal_unchecked: [4]@Vector(8, f32) = undefined;
        var vector_standard_normal_checked: [4]@Vector(8, f32) = undefined;
        fillVectorStandardNormalFrom(&unchecked, @Vector(8, f32), &vector_standard_normal_unchecked);
        try fillVectorNormalCheckedFrom(&checked, @Vector(8, f32), &vector_standard_normal_checked, 0, 1);
        try std.testing.expectEqualSlices(@Vector(8, f32), &vector_standard_normal_unchecked, &vector_standard_normal_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const vector_normal_owned = try vectorNormalBatchFrom(&unchecked, @Vector(8, f32), std.testing.allocator, 4, 0, 1);
        defer std.testing.allocator.free(vector_normal_owned);
        const vector_normal_checked_owned = try vectorNormalBatchCheckedFrom(&checked, @Vector(8, f32), std.testing.allocator, 4, 0, 1);
        defer std.testing.allocator.free(vector_normal_checked_owned);
        try std.testing.expectEqualSlices(@Vector(8, f32), vector_normal_owned, vector_normal_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const vector_standard_normal_owned = try vectorStandardNormalBatchFrom(&unchecked, @Vector(8, f32), std.testing.allocator, 4);
        defer std.testing.allocator.free(vector_standard_normal_owned);
        const vector_standard_normal_checked_owned = try vectorNormalBatchCheckedFrom(&checked, @Vector(8, f32), std.testing.allocator, 4, 0, 1);
        defer std.testing.allocator.free(vector_standard_normal_checked_owned);
        try std.testing.expectEqualSlices(@Vector(8, f32), vector_standard_normal_owned, vector_standard_normal_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_exponential_unchecked: [4]@Vector(8, f32) = undefined;
        var vector_exponential_checked: [4]@Vector(8, f32) = undefined;
        fillVectorExponentialFrom(&unchecked, @Vector(8, f32), &vector_exponential_unchecked, 1);
        try fillVectorExponentialCheckedFrom(&checked, @Vector(8, f32), &vector_exponential_checked, 1);
        try std.testing.expectEqualSlices(@Vector(8, f32), &vector_exponential_unchecked, &vector_exponential_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var vector_standard_exponential_unchecked: [4]@Vector(8, f32) = undefined;
        var vector_standard_exponential_checked: [4]@Vector(8, f32) = undefined;
        fillVectorStandardExponentialFrom(&unchecked, @Vector(8, f32), &vector_standard_exponential_unchecked);
        try fillVectorExponentialCheckedFrom(&checked, @Vector(8, f32), &vector_standard_exponential_checked, 1);
        try std.testing.expectEqualSlices(@Vector(8, f32), &vector_standard_exponential_unchecked, &vector_standard_exponential_checked);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const vector_exponential_owned = try vectorExponentialBatchFrom(&unchecked, @Vector(8, f32), std.testing.allocator, 4, 1);
        defer std.testing.allocator.free(vector_exponential_owned);
        const vector_exponential_checked_owned = try vectorExponentialBatchCheckedFrom(&checked, @Vector(8, f32), std.testing.allocator, 4, 1);
        defer std.testing.allocator.free(vector_exponential_checked_owned);
        try std.testing.expectEqualSlices(@Vector(8, f32), vector_exponential_owned, vector_exponential_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const vector_standard_exponential_owned = try vectorStandardExponentialBatchFrom(&unchecked, @Vector(8, f32), std.testing.allocator, 4);
        defer std.testing.allocator.free(vector_standard_exponential_owned);
        const vector_standard_exponential_checked_owned = try vectorExponentialBatchCheckedFrom(&checked, @Vector(8, f32), std.testing.allocator, 4, 1);
        defer std.testing.allocator.free(vector_standard_exponential_checked_owned);
        try std.testing.expectEqualSlices(@Vector(8, f32), vector_standard_exponential_owned, vector_standard_exponential_checked_owned);
        try std.testing.expectEqual(unchecked.next(), checked.next());
    }
}

test "checked weighted sampling preserves valid-parameter stream shape" {
    const alea = @import("root.zig");
    const weights = [_]f64{ 1, 2, 3, 4 };
    const items = [_]u8{ 10, 20, 30, 40 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_4478);
        var direct_engine = Engine.init(0x5150_4478);
        const rng = Rng.init(&facade_engine);

        const facade_weighted_index_array = rng.weightedIndexArray(8, &weights).?;
        const direct_weighted_index_array = weightedIndexArrayFrom(&direct_engine, 8, &weights).?;
        try std.testing.expectEqualSlices(usize, &facade_weighted_index_array, &direct_weighted_index_array);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_weighted_index_array = try rng.weightedIndexArrayChecked(8, &weights);
        const direct_checked_weighted_index_array = try weightedIndexArrayCheckedFrom(&direct_engine, 8, &weights);
        try std.testing.expectEqualSlices(usize, &facade_checked_weighted_index_array, &direct_checked_weighted_index_array);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_weighted_u32_array = (try rng.weightedIndexU32Array(8, &weights)).?;
        const direct_weighted_u32_array = (try weightedIndexU32ArrayFrom(&direct_engine, 8, &weights)).?;
        try std.testing.expectEqualSlices(u32, &facade_weighted_u32_array, &direct_weighted_u32_array);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_weighted_u32_array = try rng.weightedIndexU32ArrayChecked(8, &weights);
        const direct_checked_weighted_u32_array = try weightedIndexU32ArrayCheckedFrom(&direct_engine, 8, &weights);
        try std.testing.expectEqualSlices(u32, &facade_checked_weighted_u32_array, &direct_checked_weighted_u32_array);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_weighted_value_array = (try rng.chooseWeightedValueArray(u8, 8, &items, &weights)).?;
        const direct_weighted_value_array = (try chooseWeightedValueArrayFrom(&direct_engine, u8, 8, &items, &weights)).?;
        try std.testing.expectEqualSlices(u8, &facade_weighted_value_array, &direct_weighted_value_array);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_weighted_value_array = try rng.chooseWeightedValueArrayChecked(u8, 8, &items, &weights);
        const direct_checked_weighted_value_array = try chooseWeightedValueArrayCheckedFrom(&direct_engine, u8, 8, &items, &weights);
        try std.testing.expectEqualSlices(u8, &facade_checked_weighted_value_array, &direct_checked_weighted_value_array);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_weighted_const_ptr_array = (try rng.chooseWeightedConstPtrArray(u8, 8, &items, &weights)).?;
        const direct_weighted_const_ptr_array = (try chooseWeightedConstPtrArrayFrom(&direct_engine, u8, 8, &items, &weights)).?;
        for (facade_weighted_const_ptr_array, direct_weighted_const_ptr_array) |facade_item, direct_item| {
            try std.testing.expectEqual(facade_item.*, direct_item.*);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_weighted_const_ptr_array = try rng.chooseWeightedConstPtrArrayChecked(u8, 8, &items, &weights);
        const direct_checked_weighted_const_ptr_array = try chooseWeightedConstPtrArrayCheckedFrom(&direct_engine, u8, 8, &items, &weights);
        for (facade_checked_weighted_const_ptr_array, direct_checked_weighted_const_ptr_array) |facade_item, direct_item| {
            try std.testing.expectEqual(facade_item.*, direct_item.*);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_mut_items = items;
        var direct_mut_items = items;
        const facade_weighted_ptr_array = (try rng.chooseWeightedPtrArray(u8, 8, &facade_mut_items, &weights)).?;
        const direct_weighted_ptr_array = (try chooseWeightedPtrArrayFrom(&direct_engine, u8, 8, &direct_mut_items, &weights)).?;
        for (facade_weighted_ptr_array, direct_weighted_ptr_array) |facade_item, direct_item| {
            try std.testing.expectEqual(facade_item.*, direct_item.*);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_weighted_ptr_array = try rng.chooseWeightedPtrArrayChecked(u8, 8, &facade_mut_items, &weights);
        const direct_checked_weighted_ptr_array = try chooseWeightedPtrArrayCheckedFrom(&direct_engine, u8, 8, &direct_mut_items, &weights);
        for (facade_checked_weighted_ptr_array, direct_checked_weighted_ptr_array) |facade_item, direct_item| {
            try std.testing.expectEqual(facade_item.*, direct_item.*);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var unchecked = Engine.init(0x5150_4477);
        var checked = Engine.init(0x5150_4477);

        const weighted = weightedIndexFrom(&unchecked, &weights);
        const checked_weighted = try weightedIndexCheckedFrom(&checked, &weights);
        try std.testing.expectEqual(weighted, checked_weighted);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const weighted_u32 = try weightedIndexU32From(&unchecked, &weights);
        const checked_weighted_u32 = try weightedIndexU32CheckedFrom(&checked, &weights);
        try std.testing.expectEqual(weighted_u32, checked_weighted_u32);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const weighted_value = try chooseWeightedFrom(&unchecked, u8, &items, &weights);
        const checked_weighted_value = try Rng.init(&checked).chooseWeighted(u8, &items, &weights);
        try std.testing.expectEqual(weighted_value, checked_weighted_value);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var weighted_values_unchecked: [8]?u8 = undefined;
        var weighted_values_checked: [8]u8 = undefined;
        try fillChooseWeightedFrom(&unchecked, u8, &weighted_values_unchecked, &items, &weights);
        try fillChooseWeightedCheckedFrom(&checked, u8, &weighted_values_checked, &items, &weights);
        for (weighted_values_unchecked, weighted_values_checked) |optional, checked_value| {
            try std.testing.expectEqual(optional.?, checked_value);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const weighted_values_owned = try chooseWeightedBatchFrom(&unchecked, u8, std.testing.allocator, 8, &items, &weights);
        defer std.testing.allocator.free(weighted_values_owned);
        const weighted_values_checked_owned = try chooseWeightedBatchCheckedFrom(&checked, u8, std.testing.allocator, 8, &items, &weights);
        defer std.testing.allocator.free(weighted_values_checked_owned);
        for (weighted_values_owned, weighted_values_checked_owned) |optional, checked_value| {
            try std.testing.expectEqual(optional.?, checked_value);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const weighted_value_array = (try chooseWeightedValueArrayFrom(&unchecked, u8, 8, &items, &weights)).?;
        const checked_weighted_value_array = try chooseWeightedValueArrayCheckedFrom(&checked, u8, 8, &items, &weights);
        try std.testing.expectEqualSlices(u8, &weighted_value_array, &checked_weighted_value_array);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const weighted_const_ptr = try chooseWeightedConstPtrFrom(&unchecked, u8, &items, &weights);
        const checked_weighted_const_ptr = try chooseWeightedConstPtrCheckedFrom(&checked, u8, &items, &weights);
        try std.testing.expectEqual(weighted_const_ptr.?.*, checked_weighted_const_ptr.*);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var weighted_const_ptrs_unchecked: [8]?*const u8 = undefined;
        var weighted_const_ptrs_checked: [8]*const u8 = undefined;
        try fillChooseWeightedConstPtrFrom(&unchecked, u8, &weighted_const_ptrs_unchecked, &items, &weights);
        try fillChooseWeightedConstPtrCheckedFrom(&checked, u8, &weighted_const_ptrs_checked, &items, &weights);
        for (weighted_const_ptrs_unchecked, weighted_const_ptrs_checked) |optional, checked_ptr| {
            try std.testing.expectEqual(optional.?.*, checked_ptr.*);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const weighted_const_ptrs_owned = try chooseWeightedConstPtrBatchFrom(&unchecked, u8, std.testing.allocator, 8, &items, &weights);
        defer std.testing.allocator.free(weighted_const_ptrs_owned);
        const weighted_const_ptrs_checked_owned = try chooseWeightedConstPtrBatchCheckedFrom(&checked, u8, std.testing.allocator, 8, &items, &weights);
        defer std.testing.allocator.free(weighted_const_ptrs_checked_owned);
        for (weighted_const_ptrs_owned, weighted_const_ptrs_checked_owned) |optional, checked_ptr| {
            try std.testing.expectEqual(optional.?.*, checked_ptr.*);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const weighted_const_ptr_array = (try chooseWeightedConstPtrArrayFrom(&unchecked, u8, 8, &items, &weights)).?;
        const checked_weighted_const_ptr_array = try chooseWeightedConstPtrArrayCheckedFrom(&checked, u8, 8, &items, &weights);
        for (weighted_const_ptr_array, checked_weighted_const_ptr_array) |optional, checked_ptr| {
            try std.testing.expectEqual(optional.*, checked_ptr.*);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var weighted_mut_items_unchecked = items;
        var weighted_mut_items_checked = items;
        const weighted_ptr = try chooseWeightedPtrFrom(&unchecked, u8, &weighted_mut_items_unchecked, &weights);
        const checked_weighted_ptr = try chooseWeightedPtrCheckedFrom(&checked, u8, &weighted_mut_items_checked, &weights);
        try std.testing.expectEqual(weighted_ptr.?.*, checked_weighted_ptr.*);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var weighted_ptrs_unchecked_items = items;
        var weighted_ptrs_checked_items = items;
        var weighted_ptrs_unchecked: [8]?*u8 = undefined;
        var weighted_ptrs_checked: [8]*u8 = undefined;
        try fillChooseWeightedPtrFrom(&unchecked, u8, &weighted_ptrs_unchecked, &weighted_ptrs_unchecked_items, &weights);
        try fillChooseWeightedPtrCheckedFrom(&checked, u8, &weighted_ptrs_checked, &weighted_ptrs_checked_items, &weights);
        for (weighted_ptrs_unchecked, weighted_ptrs_checked) |optional, checked_ptr| {
            try std.testing.expectEqual(optional.?.*, checked_ptr.*);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var weighted_ptrs_owned_items = items;
        var weighted_ptrs_checked_owned_items = items;
        const weighted_ptrs_owned = try chooseWeightedPtrBatchFrom(&unchecked, u8, std.testing.allocator, 8, &weighted_ptrs_owned_items, &weights);
        defer std.testing.allocator.free(weighted_ptrs_owned);
        const weighted_ptrs_checked_owned = try chooseWeightedPtrBatchCheckedFrom(&checked, u8, std.testing.allocator, 8, &weighted_ptrs_checked_owned_items, &weights);
        defer std.testing.allocator.free(weighted_ptrs_checked_owned);
        for (weighted_ptrs_owned, weighted_ptrs_checked_owned) |optional, checked_ptr| {
            try std.testing.expectEqual(optional.?.*, checked_ptr.*);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var weighted_ptr_array_items = items;
        var weighted_ptr_checked_array_items = items;
        const weighted_ptr_array = (try chooseWeightedPtrArrayFrom(&unchecked, u8, 8, &weighted_ptr_array_items, &weights)).?;
        const checked_weighted_ptr_array = try chooseWeightedPtrArrayCheckedFrom(&checked, u8, 8, &weighted_ptr_checked_array_items, &weights);
        for (weighted_ptr_array, checked_weighted_ptr_array) |optional, checked_ptr| {
            try std.testing.expectEqual(optional.*, checked_ptr.*);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var weighted_indices_u32_unchecked: [8]?u32 = undefined;
        var weighted_indices_u32_checked: [8]u32 = undefined;
        try fillWeightedIndexU32From(&unchecked, &weighted_indices_u32_unchecked, &weights);
        try fillWeightedIndexU32CheckedFrom(&checked, &weighted_indices_u32_checked, &weights);
        for (weighted_indices_u32_unchecked, weighted_indices_u32_checked) |optional, checked_index| {
            try std.testing.expectEqual(optional.?, checked_index);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const weighted_u32_owned = try weightedIndexU32BatchFrom(&unchecked, std.testing.allocator, 8, &weights);
        defer std.testing.allocator.free(weighted_u32_owned);
        const weighted_u32_checked_owned = try weightedIndexU32BatchCheckedFrom(&checked, std.testing.allocator, 8, &weights);
        defer std.testing.allocator.free(weighted_u32_checked_owned);
        for (weighted_u32_owned, weighted_u32_checked_owned) |optional, checked_index| {
            try std.testing.expectEqual(optional.?, checked_index);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const weighted_u32_array = (try weightedIndexU32ArrayFrom(&unchecked, 8, &weights)).?;
        const checked_weighted_u32_array = try weightedIndexU32ArrayCheckedFrom(&checked, 8, &weights);
        try std.testing.expectEqualSlices(u32, &weighted_u32_array, &checked_weighted_u32_array);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        var weighted_indices_unchecked: [8]?usize = undefined;
        var weighted_indices_checked: [8]usize = undefined;
        fillWeightedIndexFrom(&unchecked, &weighted_indices_unchecked, &weights);
        try fillWeightedIndexCheckedFrom(&checked, &weighted_indices_checked, &weights);
        for (weighted_indices_unchecked, weighted_indices_checked) |optional, checked_index| {
            try std.testing.expectEqual(optional.?, checked_index);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const weighted_owned = try weightedIndexBatchFrom(&unchecked, std.testing.allocator, 8, &weights);
        defer std.testing.allocator.free(weighted_owned);
        const weighted_checked_owned = try weightedIndexBatchCheckedFrom(&checked, std.testing.allocator, 8, &weights);
        defer std.testing.allocator.free(weighted_checked_owned);
        for (weighted_owned, weighted_checked_owned) |optional, checked_index| {
            try std.testing.expectEqual(optional.?, checked_index);
        }
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const weighted_index_array = weightedIndexArrayFrom(&unchecked, 8, &weights).?;
        const checked_weighted_index_array = try weightedIndexArrayCheckedFrom(&checked, 8, &weights);
        try std.testing.expectEqualSlices(usize, &weighted_index_array, &checked_weighted_index_array);
        try std.testing.expectEqual(unchecked.next(), checked.next());

        const sampled_items = try sampleWithoutReplacementFrom(&unchecked, u8, std.testing.allocator, &items, 3);
        defer std.testing.allocator.free(sampled_items);
        const checked_sample = try sampleWithoutReplacementCheckedFrom(&checked, u8, std.testing.allocator, &items, 3);
        defer std.testing.allocator.free(checked_sample);
        try std.testing.expectEqualSlices(u8, sampled_items, checked_sample);
        try std.testing.expectEqual(unchecked.next(), checked.next());
    }
}

test "invalid facade value helpers do not consume random stream" {
    const alea = @import("root.zig");
    const EmptyEnum = enum {};
    const NestedEmptyEnum = struct { u64, EmptyEnum };

    var engine = alea.ScalarPrng.init(0x5150_ba2);
    var control = alea.ScalarPrng.init(0x5150_ba2);
    const rng = Rng.init(&engine);

    if (rng.enumValueChecked(EmptyEnum)) |_| {
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }
    try std.testing.expectEqual(control.next(), engine.next());

    if (rng.valueChecked(EmptyEnum)) |_| {
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }
    try std.testing.expectEqual(control.next(), engine.next());

    if (rng.randomValueChecked(EmptyEnum)) |_| {
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }
    try std.testing.expectEqual(control.next(), engine.next());

    if (rng.valueChecked(NestedEmptyEnum)) |_| {
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid checked helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_bad);
    const EmptyEnum = enum {};
    const NestedEmptyEnum = struct { EmptyEnum };
    const LateNestedEmptyEnum = struct { u64, EmptyEnum };

    try std.testing.expectError(error.InvalidProbability, chanceCheckedFrom(&engine, -0.1));
    try std.testing.expectEqual(@as(u64, 0x9ccf0caa836c3975), engine.next());

    try std.testing.expectError(error.InvalidProbability, ratioCheckedFrom(&engine, 2, 1));
    try std.testing.expectEqual(@as(u64, 0x6a422e0bc228f676), engine.next());

    try std.testing.expectError(error.EmptyRange, uintLessThanCheckedFrom(&engine, u32, 0));
    try std.testing.expectEqual(@as(u64, 0x16f941763a3b5c32), engine.next());

    try std.testing.expectError(error.EmptyRange, intRangeLessThanCheckedFrom(&engine, u32, 3, 3));
    try std.testing.expectEqual(@as(u64, 0xba4d054547a7f857), engine.next());

    try std.testing.expectError(error.NonFinite, floatRangeCheckedFrom(&engine, f64, std.math.inf(f64), 1));
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

    try std.testing.expectError(error.NonFinite, vectorRangeCheckedFrom(&engine, @Vector(4, f64), std.math.inf(f64), 1));
    try std.testing.expectEqual(@as(u64, 0xfedbe66623c1adc2), engine.next());

    var vec_buf: [2]@Vector(4, f64) = undefined;
    try std.testing.expectError(error.NonFinite, fillVectorRangeCheckedFrom(&engine, @Vector(4, f64), &vec_buf, std.math.inf(f64), 1));
    try std.testing.expectEqual(@as(u64, 0xa360fbcd83acd8d7), engine.next());

    try std.testing.expectError(error.EmptyRange, chooseCheckedFrom(&engine, u8, &.{}));
    try std.testing.expectEqual(@as(u64, 0x8a685176c49005b1), engine.next());

    try std.testing.expectError(error.EmptyRange, chooseConstPtrCheckedFrom(&engine, u8, &.{}));

    var empty_items: [0]u8 = .{};
    try std.testing.expectError(error.EmptyRange, choosePtrCheckedFrom(&engine, u8, &empty_items));
    try std.testing.expectEqual(@as(u64, 0xf6aed2fe799c54ee), engine.next());

    if (enumValueCheckedFrom(&engine, EmptyEnum)) |_| {
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }
    try std.testing.expectEqual(@as(u64, 0xd3ab62c69321f758), engine.next());

    if (valueCheckedFrom(&engine, EmptyEnum)) |_| {
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }
    try std.testing.expectEqual(@as(u64, 0x1832e3ae643b1913), engine.next());

    const empty_enum_array = try valueCheckedFrom(&engine, [0]EmptyEnum);
    try std.testing.expectEqual(@as(usize, 0), empty_enum_array.len);
    try std.testing.expectEqual(@as(u64, 0x1e449ba06e4ee306), engine.next());

    const empty_void_array = try valueCheckedFrom(&engine, [0]void);
    try std.testing.expectEqual(@as(usize, 0), empty_void_array.len);
    try std.testing.expectEqual(@as(u64, 0xa05fd0d145ac28f5), engine.next());

    if (valueCheckedFrom(&engine, [2]EmptyEnum)) |_| {
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }
    try std.testing.expectEqual(@as(u64, 0x709790abbb828191), engine.next());

    if (valueCheckedFrom(&engine, NestedEmptyEnum)) |_| {
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }
    try std.testing.expectEqual(@as(u64, 0x3956218e7dd11342), engine.next());

    if (valueCheckedFrom(&engine, LateNestedEmptyEnum)) |_| {
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }
    try std.testing.expectEqual(@as(u64, 0xdbf744335ced8b7d), engine.next());

    try std.testing.expectError(error.InvalidWeight, weightedIndexCheckedFrom(&engine, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectEqual(@as(u64, 0x4a25e952d381d57c), engine.next());

    try std.testing.expectEqual(@as(?usize, null), try weightedIndexCheckedFrom(&engine, &.{}));
    try std.testing.expectEqual(@as(u64, 0xb6ab229c8fe7505b), engine.next());

    try std.testing.expectEqual(@as(?usize, null), try weightedIndexCheckedFrom(&engine, &.{ 0.0, 0.0 }));
    try std.testing.expectEqual(@as(u64, 0x9ed0fe54839ae4f3), engine.next());

    try std.testing.expectError(error.InvalidWeight, weightedIndexCheckedFrom(&engine, &.{ std.math.floatMax(f64), std.math.floatMax(f64) }));
    try std.testing.expectEqual(@as(u64, 0x25bad2ea3ddc339c), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleWithoutReplacementCheckedFrom(&engine, u8, std.testing.allocator, &.{ 1, 2 }, 3));
    try std.testing.expectEqual(@as(u64, 0x1f96d05125db1460), engine.next());
}

test "invalid scalar exponential helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba8);
    var control = alea.ScalarPrng.init(0x5150_ba8);

    try std.testing.expectError(error.InvalidParameter, exponentialCheckedFrom(&engine, f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    var buf: [4]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillExponentialCheckedFrom(&engine, f64, &buf, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid vector probability helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_bab);
    var control = alea.ScalarPrng.init(0x5150_bab);

    try std.testing.expectError(error.InvalidProbability, vectorChanceCheckedFrom(&engine, @Vector(8, bool), -0.1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, vectorRatioCheckedFrom(&engine, @Vector(8, bool), 2, 1));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "degenerate vector probability fills do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_bad);
    var control = alea.ScalarPrng.init(0x5150_bad);
    const rng = Rng.init(&engine);

    var vec_bools: [3]@Vector(8, bool) = undefined;
    fillVectorChanceFrom(&engine, @Vector(8, bool), &vec_bools, 0);
    for (vec_bools) |vec_sample| try std.testing.expectEqual(@as(@Vector(8, bool), @splat(false)), vec_sample);
    try std.testing.expectEqual(control.next(), engine.next());

    try rng.fillVectorChanceChecked(@Vector(8, bool), &vec_bools, 1);
    for (vec_bools) |vec_sample| try std.testing.expectEqual(@as(@Vector(8, bool), @splat(true)), vec_sample);
    try std.testing.expectEqual(control.next(), engine.next());

    fillVectorRatioFrom(&engine, @Vector(8, bool), &vec_bools, 0, 7);
    for (vec_bools) |vec_sample| try std.testing.expectEqual(@as(@Vector(8, bool), @splat(false)), vec_sample);
    try std.testing.expectEqual(control.next(), engine.next());

    try rng.fillVectorRatioChecked(@Vector(8, bool), &vec_bools, 7, 7);
    for (vec_bools) |vec_sample| try std.testing.expectEqual(@as(@Vector(8, bool), @splat(true)), vec_sample);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid vector distribution helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_baa);
    var control = alea.ScalarPrng.init(0x5150_baa);

    try std.testing.expectError(error.InvalidParameter, vectorNormalCheckedFrom(&engine, @Vector(4, f64), 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, vectorExponentialCheckedFrom(&engine, @Vector(4, f64), 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid integer at-most range does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba9);
    var control = alea.ScalarPrng.init(0x5150_ba9);

    try std.testing.expectError(error.EmptyRange, intRangeAtMostCheckedFrom(&engine, u32, 4, 3));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid facade vector helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba0);
    var control = alea.ScalarPrng.init(0x5150_ba0);
    const rng = Rng.init(&engine);

    try std.testing.expectError(error.InvalidProbability, rng.vectorChanceChecked(@Vector(8, bool), -0.1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, rng.vectorRatioChecked(@Vector(8, bool), 2, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, rng.vectorNormalChecked(@Vector(4, f64), 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, rng.vectorExponentialChecked(@Vector(4, f64), 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid facade duration ranges do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba1);
    var control = alea.ScalarPrng.init(0x5150_ba1);
    const rng = Rng.init(&engine);

    try std.testing.expectError(error.EmptyRange, rng.durationRangeLessThanChecked(.fromSeconds(2), .fromSeconds(1)));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.durationRangeAtMostChecked(.fromSeconds(2), .fromSeconds(1)));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid duration at-most range does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_bac);
    var control = alea.ScalarPrng.init(0x5150_bac);

    try std.testing.expectError(error.EmptyRange, durationRangeAtMostCheckedFrom(&engine, .fromSeconds(2), .fromSeconds(1)));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned duration range batches allocate and validate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_d902);
    var control = alea.ScalarPrng.init(0x5150_d902);
    const rng = Rng.init(&engine);

    const min = std.Io.Duration.fromSeconds(2);
    const max = std.Io.Duration.fromSeconds(1);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.durationRangeLessThanBatchChecked(empty_alloc.allocator(), 0, min, max);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_less_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.durationRangeLessThanBatchChecked(invalid_less_alloc.allocator(), 8, min, max));
    try std.testing.expect(!invalid_less_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_at_most_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, durationRangeAtMostBatchCheckedFrom(&engine, invalid_at_most_alloc.allocator(), 8, min, max));
    try std.testing.expect(!invalid_at_most_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.durationRangeAtMostBatchChecked(alloc.allocator(), 8, max, min));
    try std.testing.expect(alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "zero-count sample without replacement does not build pool or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_baf);
    var control = alea.ScalarPrng.init(0x5150_baf);

    const items = [_]u8{ 1, 2, 3, 4 };
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const sampled_items = try sampleWithoutReplacementCheckedFrom(&engine, u8, failing.allocator(), &items, 0);
    defer failing.allocator().free(sampled_items);
    try std.testing.expectEqual(@as(usize, 0), sampled_items.len);
    try std.testing.expect(!failing.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    const empty_sample = try sampleWithoutReplacementCheckedFrom(&engine, u8, std.testing.allocator, &.{}, 0);
    defer std.testing.allocator.free(empty_sample);
    try std.testing.expectEqual(@as(usize, 0), empty_sample.len);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, sampleWithoutReplacementCheckedFrom(&engine, u8, std.testing.allocator, &items, items.len + 1));
}

test "invalid unchecked sample without replacement fails before allocation and stream use" {
    const alea = @import("root.zig");
    const items = [_]u8{ 1, 2, 3, 4 };

    var method_engine = alea.ScalarPrng.init(0x5150_bb3);
    var method_control = alea.ScalarPrng.init(0x5150_bb3);
    const rng = Rng.init(&method_engine);
    var method_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, rng.sampleWithoutReplacement(u8, method_alloc.allocator(), &items, items.len + 1));
    try std.testing.expect(!method_alloc.has_induced_failure);
    try std.testing.expectEqual(method_control.next(), method_engine.next());

    var direct_engine = alea.ScalarPrng.init(0x5150_bb4);
    var direct_control = alea.ScalarPrng.init(0x5150_bb4);
    var direct_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, sampleWithoutReplacementFrom(&direct_engine, u8, direct_alloc.allocator(), &items, items.len + 1));
    try std.testing.expect(!direct_alloc.has_induced_failure);
    try std.testing.expectEqual(direct_control.next(), direct_engine.next());
}

test "sample without replacement avoids post-sampling ownership allocation" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_bb2);
    const items = [_]u8{ 1, 2, 3, 4 };

    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{
        .fail_index = 2,
        .resize_fail_index = 0,
    });
    const sampled_items = try sampleWithoutReplacementCheckedFrom(&engine, u8, failing.allocator(), &items, 3);
    defer failing.allocator().free(sampled_items);
    try std.testing.expectEqual(@as(usize, 3), sampled_items.len);
    try std.testing.expect(!failing.has_induced_failure);
}

test "sample without replacement allocation failures do not consume random stream" {
    const alea = @import("root.zig");
    const items = [_]u8{ 1, 2, 3, 4 };

    var first_engine = alea.ScalarPrng.init(0x5150_bb0);
    var first_control = alea.ScalarPrng.init(0x5150_bb0);
    var first_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleWithoutReplacementCheckedFrom(&first_engine, u8, first_alloc.allocator(), &items, 2));
    try std.testing.expect(first_alloc.has_induced_failure);
    try std.testing.expectEqual(first_control.next(), first_engine.next());

    var second_engine = alea.ScalarPrng.init(0x5150_bb1);
    var second_control = alea.ScalarPrng.init(0x5150_bb1);
    var second_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, sampleWithoutReplacementCheckedFrom(&second_engine, u8, second_alloc.allocator(), &items, 2));
    try std.testing.expect(second_alloc.has_induced_failure);
    try std.testing.expectEqual(second_control.next(), second_engine.next());
}

test "invalid facade range helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba5);
    var control = alea.ScalarPrng.init(0x5150_ba5);
    const rng = Rng.init(&engine);

    var empty_ints: [0]u32 = .{};
    rng.fillRange(u32, &empty_ints, 3, 3);
    try std.testing.expectEqual(control.next(), engine.next());
    rng.fillRangeAtMost(u32, &empty_ints, 4, 3);
    try std.testing.expectEqual(control.next(), engine.next());
    rng.fillUintLessThan(u32, &empty_ints, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_floats: [0]f64 = .{};
    rng.fillRange(f64, &empty_floats, std.math.nan(f64), 1);
    try std.testing.expectEqual(control.next(), engine.next());
    rng.fillNormal(f64, &empty_floats, std.math.inf(f64), -1);
    try std.testing.expectEqual(control.next(), engine.next());
    rng.fillExponential(f64, &empty_floats, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_bools: [0]bool = .{};
    rng.fillChance(&empty_bools, -0.1);
    try std.testing.expectEqual(control.next(), engine.next());
    rng.fillRatio(&empty_bools, 2, 1);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.uintLessThanChecked(u32, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.intRangeLessThanChecked(u32, 3, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.intRangeAtMostChecked(u32, 4, 3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.NonFinite, rng.floatRangeChecked(f64, std.math.inf(f64), 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.NonFinite, rng.vectorRangeChecked(@Vector(4, f64), std.math.inf(f64), 1));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned range batches allocate and validate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_8720);
    var control = alea.ScalarPrng.init(0x5150_8720);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.rangeBatchChecked(u32, empty_alloc.allocator(), 0, 3, 3);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.rangeBatchChecked(u32, invalid_alloc.allocator(), 4, 3, 3));
    try std.testing.expect(!invalid_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.rangeBatch(u32, invalid_unchecked_alloc.allocator(), 4, 3, 3));
    try std.testing.expect(!invalid_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_inclusive_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty_inclusive = try rng.rangeAtMostBatchChecked(u32, empty_inclusive_alloc.allocator(), 0, 4, 3);
    defer empty_inclusive_alloc.allocator().free(empty_inclusive);
    try std.testing.expectEqual(@as(usize, 0), empty_inclusive.len);
    try std.testing.expect(!empty_inclusive_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_inclusive_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.rangeAtMostBatchChecked(u32, invalid_inclusive_alloc.allocator(), 4, 4, 3));
    try std.testing.expect(!invalid_inclusive_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_inclusive_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rangeAtMostBatchFrom(&engine, u32, invalid_inclusive_unchecked_alloc.allocator(), 4, 4, 3));
    try std.testing.expect(!invalid_inclusive_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.NonFinite, rangeBatchCheckedFrom(&engine, f64, std.testing.allocator, 4, std.math.inf(f64), 1));
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_float_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.NonFinite, rangeBatchFrom(&engine, f64, invalid_float_unchecked_alloc.allocator(), 4, std.math.inf(f64), 1));
    try std.testing.expect(!invalid_float_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.rangeBatchChecked(u16, alloc.allocator(), 4, 10, 20));
    try std.testing.expect(alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var inclusive_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rangeAtMostBatchCheckedFrom(&engine, i32, inclusive_alloc.allocator(), 4, -10, 20));
    try std.testing.expect(inclusive_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned vector range batches allocate and validate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_9220);
    var control = alea.ScalarPrng.init(0x5150_9220);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.vectorRangeBatchChecked(@Vector(4, u32), empty_alloc.allocator(), 0, 3, 3);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_int_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.vectorRangeBatchChecked(@Vector(4, u32), invalid_int_alloc.allocator(), 4, 3, 3));
    try std.testing.expect(!invalid_int_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_inclusive_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty_inclusive = try rng.vectorRangeAtMostBatchChecked(@Vector(4, u32), empty_inclusive_alloc.allocator(), 0, 4, 3);
    defer empty_inclusive_alloc.allocator().free(empty_inclusive);
    try std.testing.expectEqual(@as(usize, 0), empty_inclusive.len);
    try std.testing.expect(!empty_inclusive_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_inclusive_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.vectorRangeAtMostBatchChecked(@Vector(4, u32), invalid_inclusive_alloc.allocator(), 4, 4, 3));
    try std.testing.expect(!invalid_inclusive_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_float_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.NonFinite, vectorRangeBatchCheckedFrom(&engine, @Vector(4, f64), invalid_float_alloc.allocator(), 4, std.math.inf(f64), 1));
    try std.testing.expect(!invalid_float_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.vectorRangeBatchChecked(@Vector(8, f32), alloc.allocator(), 4, -1, 1));
    try std.testing.expect(alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var inclusive_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, vectorRangeAtMostBatchCheckedFrom(&engine, @Vector(8, i32), inclusive_alloc.allocator(), 4, -10, 20));
    try std.testing.expect(inclusive_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "degenerate range helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba4);
    var control = alea.ScalarPrng.init(0x5150_ba4);
    const rng = Rng.init(&engine);

    try std.testing.expectEqual(@as(u32, 0), uintLessThanFrom(&engine, u32, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    var uint_less: [5]u32 = undefined;
    rng.fillUintLessThan(u32, &uint_less, 1);
    for (uint_less) |draw| try std.testing.expectEqual(@as(u32, 0), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_uint_less = try uintLessThanBatchCheckedFrom(&engine, u32, std.testing.allocator, 5, 1);
    defer std.testing.allocator.free(owned_uint_less);
    for (owned_uint_less) |draw| try std.testing.expectEqual(@as(u32, 0), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(u32, 0), uintAtMostFrom(&engine, u32, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    var uint_at_most: [5]u32 = undefined;
    fillUintAtMostFrom(&engine, u32, &uint_at_most, 0);
    for (uint_at_most) |draw| try std.testing.expectEqual(@as(u32, 0), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_uint_at_most = try rng.uintAtMostBatch(u32, std.testing.allocator, 5, 0);
    defer std.testing.allocator.free(owned_uint_at_most);
    for (owned_uint_at_most) |draw| try std.testing.expectEqual(@as(u32, 0), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(u32, 7), intRangeAtMostFrom(&engine, u32, 7, 7));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(u32, 8), intRangeLessThanFrom(&engine, u32, 8, 9));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(i32, -5), try rng.intRangeAtMostChecked(i32, -5, -5));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(i32, -4), try rng.intRangeLessThanChecked(i32, -4, -3));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(std.Io.Duration.fromSeconds(3), durationRangeAtMostFrom(&engine, .fromSeconds(3), .fromSeconds(3)));
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_duration = try rng.durationRangeAtMostBatch(std.testing.allocator, 5, .fromSeconds(3), .fromSeconds(3));
    defer std.testing.allocator.free(owned_duration);
    for (owned_duration) |draw| try std.testing.expectEqual(std.Io.Duration.fromSeconds(3), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(f64, 2.5), rng.floatRange(f64, 2.5, 2.5));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(f32, -1.25), try floatRangeCheckedFrom(&engine, f32, -1.25, -1.25));
    try std.testing.expectEqual(control.next(), engine.next());

    var ints: [5]u32 = undefined;
    fillRangeFrom(&engine, u32, &ints, 10, 11);
    for (ints) |draw| try std.testing.expectEqual(@as(u32, 10), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_ints = try rangeBatchCheckedFrom(&engine, u32, std.testing.allocator, 5, 10, 11);
    defer std.testing.allocator.free(owned_ints);
    for (owned_ints) |draw| try std.testing.expectEqual(@as(u32, 10), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    var signed_ints: [5]i32 = undefined;
    try rng.fillRangeChecked(i32, &signed_ints, -12, -11);
    for (signed_ints) |draw| try std.testing.expectEqual(@as(i32, -12), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    var inclusive_signed_ints: [5]i32 = undefined;
    rng.fillRangeAtMost(i32, &inclusive_signed_ints, -12, -12);
    for (inclusive_signed_ints) |draw| try std.testing.expectEqual(@as(i32, -12), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_inclusive_signed_ints = try rangeAtMostBatchCheckedFrom(&engine, i32, std.testing.allocator, 5, -12, -12);
    defer std.testing.allocator.free(owned_inclusive_signed_ints);
    for (owned_inclusive_signed_ints) |draw| try std.testing.expectEqual(@as(i32, -12), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    var floats: [5]f64 = undefined;
    fillRangeFrom(&engine, f64, &floats, 4.75, 4.75);
    for (floats) |draw| try std.testing.expectEqual(@as(f64, 4.75), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_floats = try rng.rangeBatch(f64, std.testing.allocator, 5, 4.75, 4.75);
    defer std.testing.allocator.free(owned_floats);
    for (owned_floats) |draw| try std.testing.expectEqual(@as(f64, 4.75), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try rng.fillRangeChecked(f64, &floats, -3.5, -3.5);
    for (floats) |draw| try std.testing.expectEqual(@as(f64, -3.5), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(@Vector(4, u32), @splat(13)), vectorRangeFrom(&engine, @Vector(4, u32), 13, 14));
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_vec_ints = try vectorRangeBatchCheckedFrom(&engine, @Vector(4, u32), std.testing.allocator, 3, 13, 14);
    defer std.testing.allocator.free(owned_vec_ints);
    for (owned_vec_ints) |draw| try std.testing.expectEqual(@as(@Vector(4, u32), @splat(13)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(@Vector(4, i32), @splat(-14)), try rng.vectorRangeChecked(@Vector(4, i32), -14, -13));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(@Vector(4, f64), @splat(6.25)), vectorRangeFrom(&engine, @Vector(4, f64), 6.25, 6.25));
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_vec_floats = try rng.vectorRangeBatch(@Vector(4, f64), std.testing.allocator, 3, 6.25, 6.25);
    defer std.testing.allocator.free(owned_vec_floats);
    for (owned_vec_floats) |draw| try std.testing.expectEqual(@as(@Vector(4, f64), @splat(6.25)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(@Vector(8, f32), @splat(-2.5)), try rng.vectorRangeChecked(@Vector(8, f32), -2.5, -2.5));
    try std.testing.expectEqual(control.next(), engine.next());

    var vec_ints: [3]@Vector(4, u32) = undefined;
    fillVectorRangeFrom(&engine, @Vector(4, u32), &vec_ints, 15, 16);
    for (vec_ints) |draw| try std.testing.expectEqual(@as(@Vector(4, u32), @splat(15)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    var vec_signed_ints: [3]@Vector(4, i32) = undefined;
    try rng.fillVectorRangeChecked(@Vector(4, i32), &vec_signed_ints, -16, -15);
    for (vec_signed_ints) |draw| try std.testing.expectEqual(@as(@Vector(4, i32), @splat(-16)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    var vec_inclusive_signed_ints: [3]@Vector(4, i32) = undefined;
    rng.fillVectorRangeAtMost(@Vector(4, i32), &vec_inclusive_signed_ints, -16, -16);
    for (vec_inclusive_signed_ints) |draw| try std.testing.expectEqual(@as(@Vector(4, i32), @splat(-16)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_vec_inclusive_signed_ints = try vectorRangeAtMostBatchCheckedFrom(&engine, @Vector(4, i32), std.testing.allocator, 3, -16, -16);
    defer std.testing.allocator.free(owned_vec_inclusive_signed_ints);
    for (owned_vec_inclusive_signed_ints) |draw| try std.testing.expectEqual(@as(@Vector(4, i32), @splat(-16)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    var vec_floats: [3]@Vector(4, f64) = undefined;
    fillVectorRangeFrom(&engine, @Vector(4, f64), &vec_floats, 9.125, 9.125);
    for (vec_floats) |draw| try std.testing.expectEqual(@as(@Vector(4, f64), @splat(9.125)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try rng.fillVectorRangeChecked(@Vector(4, f64), &vec_floats, -8.25, -8.25);
    for (vec_floats) |draw| try std.testing.expectEqual(@as(@Vector(4, f64), @splat(-8.25)), draw);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid facade scalar helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba6);
    var control = alea.ScalarPrng.init(0x5150_ba6);
    const rng = Rng.init(&engine);

    try std.testing.expectError(error.InvalidProbability, rng.chanceChecked(1.1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, rng.ratioChecked(2, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, rng.normalChecked(f64, 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, rng.exponentialChecked(f64, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "degenerate exponential helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba5);
    var control = alea.ScalarPrng.init(0x5150_ba5);
    const rng = Rng.init(&engine);

    try std.testing.expectEqual(@as(f64, 0), rng.exponential(f64, std.math.inf(f64)));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(f64, 0), exponentialFastFrom(&engine, f64, std.math.inf(f64)));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(f64, 0), try rng.exponentialChecked(f64, std.math.inf(f64)));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(f64, 0), try exponentialCheckedFrom(&engine, f64, std.math.inf(f64)));
    try std.testing.expectEqual(control.next(), engine.next());

    var out: [5]f64 = undefined;
    rng.fillExponential(f64, &out, std.math.inf(f64));
    for (out) |draw| try std.testing.expectEqual(@as(f64, 0), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    fillExponentialFrom(&engine, f64, &out, std.math.inf(f64));
    for (out) |draw| try std.testing.expectEqual(@as(f64, 0), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try rng.fillExponentialChecked(f64, &out, std.math.inf(f64));
    for (out) |draw| try std.testing.expectEqual(@as(f64, 0), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillExponentialCheckedFrom(&engine, f64, &out, std.math.inf(f64));
    for (out) |draw| try std.testing.expectEqual(@as(f64, 0), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(@Vector(4, f64), @splat(0)), rng.vectorExponential(@Vector(4, f64), std.math.inf(f64)));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(@Vector(4, f64), @splat(0)), vectorExponentialFrom(&engine, @Vector(4, f64), std.math.inf(f64)));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(@Vector(4, f64), @splat(0)), try rng.vectorExponentialChecked(@Vector(4, f64), std.math.inf(f64)));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(@Vector(4, f64), @splat(0)), try vectorExponentialCheckedFrom(&engine, @Vector(4, f64), std.math.inf(f64)));
    try std.testing.expectEqual(control.next(), engine.next());

    var vec_out: [3]@Vector(8, f32) = undefined;
    rng.fillVectorExponential(@Vector(8, f32), &vec_out, std.math.inf(f32));
    for (vec_out) |draw| try std.testing.expectEqual(@as(@Vector(8, f32), @splat(0)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    fillVectorExponentialFrom(&engine, @Vector(8, f32), &vec_out, std.math.inf(f32));
    for (vec_out) |draw| try std.testing.expectEqual(@as(@Vector(8, f32), @splat(0)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try rng.fillVectorExponentialChecked(@Vector(8, f32), &vec_out, std.math.inf(f32));
    for (vec_out) |draw| try std.testing.expectEqual(@as(@Vector(8, f32), @splat(0)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillVectorExponentialCheckedFrom(&engine, @Vector(8, f32), &vec_out, std.math.inf(f32));
    for (vec_out) |draw| try std.testing.expectEqual(@as(@Vector(8, f32), @splat(0)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const vector_owned = try rng.vectorExponentialBatch(@Vector(8, f32), std.testing.allocator, 3, std.math.inf(f32));
    defer std.testing.allocator.free(vector_owned);
    for (vector_owned) |draw| try std.testing.expectEqual(@as(@Vector(8, f32), @splat(0)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const vector_checked_owned = try vectorExponentialBatchCheckedFrom(&engine, @Vector(4, f64), std.testing.allocator, 3, std.math.inf(f64));
    defer std.testing.allocator.free(vector_checked_owned);
    for (vector_checked_owned) |draw| try std.testing.expectEqual(@as(@Vector(4, f64), @splat(0)), draw);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "degenerate normal helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba8);
    var control = alea.ScalarPrng.init(0x5150_ba8);
    const rng = Rng.init(&engine);

    try std.testing.expectEqual(@as(f64, 3.5), rng.normal(f64, 3.5, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(f64, -2.25), normalFastFrom(&engine, f64, -2.25, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(f64, 4.75), try rng.normalChecked(f64, 4.75, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    var out: [5]f64 = undefined;
    rng.fillNormal(f64, &out, -7.125, 0);
    for (out) |draw| try std.testing.expectEqual(@as(f64, -7.125), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillNormalCheckedFrom(&engine, f64, &out, 9.5, 0);
    for (out) |draw| try std.testing.expectEqual(@as(f64, 9.5), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned = try rng.normalBatch(f64, std.testing.allocator, 5, -3.25, 0);
    defer std.testing.allocator.free(owned);
    for (owned) |draw| try std.testing.expectEqual(@as(f64, -3.25), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const checked_owned = try normalBatchCheckedFrom(&engine, f64, std.testing.allocator, 5, 6.25, 0);
    defer std.testing.allocator.free(checked_owned);
    for (checked_owned) |draw| try std.testing.expectEqual(@as(f64, 6.25), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(@Vector(4, f64), @splat(2.25)), rng.vectorNormal(@Vector(4, f64), 2.25, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(@Vector(4, f64), @splat(-3.5)), try vectorNormalCheckedFrom(&engine, @Vector(4, f64), -3.5, 0));
    try std.testing.expectEqual(control.next(), engine.next());
    var vec_out: [3]@Vector(8, f32) = undefined;
    rng.fillVectorNormal(@Vector(8, f32), &vec_out, -1.5, 0);
    for (vec_out) |vec_sample| try std.testing.expectEqual(@as(@Vector(8, f32), @splat(-1.5)), vec_sample);
    try std.testing.expectEqual(control.next(), engine.next());

    try fillVectorNormalCheckedFrom(&engine, @Vector(8, f32), &vec_out, 4.5, 0);
    for (vec_out) |vec_sample| try std.testing.expectEqual(@as(@Vector(8, f32), @splat(4.5)), vec_sample);
    try std.testing.expectEqual(control.next(), engine.next());

    const vector_owned = try rng.vectorNormalBatch(@Vector(8, f32), std.testing.allocator, 3, -2.5, 0);
    defer std.testing.allocator.free(vector_owned);
    for (vector_owned) |vec_sample| try std.testing.expectEqual(@as(@Vector(8, f32), @splat(-2.5)), vec_sample);
    try std.testing.expectEqual(control.next(), engine.next());

    const vector_checked_owned = try vectorNormalBatchCheckedFrom(&engine, @Vector(4, f64), std.testing.allocator, 3, 7.25, 0);
    defer std.testing.allocator.free(vector_checked_owned);
    for (vector_checked_owned) |vec_sample| try std.testing.expectEqual(@as(@Vector(4, f64), @splat(7.25)), vec_sample);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "degenerate exponential owned batches do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba9);
    var control = alea.ScalarPrng.init(0x5150_ba9);
    const rng = Rng.init(&engine);

    const owned = try rng.exponentialBatch(f64, std.testing.allocator, 5, std.math.inf(f64));
    defer std.testing.allocator.free(owned);
    for (owned) |draw| try std.testing.expectEqual(@as(f64, 0), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const checked_owned = try exponentialBatchCheckedFrom(&engine, f32, std.testing.allocator, 5, std.math.inf(f32));
    defer std.testing.allocator.free(checked_owned);
    for (checked_owned) |draw| try std.testing.expectEqual(@as(f32, 0), draw);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid facade checked fills do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba7);
    var control = alea.ScalarPrng.init(0x5150_ba7);
    const rng = Rng.init(&engine);

    var empty_vec_ints: [0]@Vector(4, u32) = .{};
    rng.fillVectorRange(@Vector(4, u32), &empty_vec_ints, 3, 3);
    try std.testing.expectEqual(control.next(), engine.next());
    rng.fillVectorRangeAtMost(@Vector(4, u32), &empty_vec_ints, 4, 3);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_vec_floats: [0]@Vector(8, f32) = .{};
    rng.fillVectorRange(@Vector(8, f32), &empty_vec_floats, std.math.nan(f32), 1);
    try std.testing.expectEqual(control.next(), engine.next());
    rng.fillVectorNormal(@Vector(8, f32), &empty_vec_floats, std.math.inf(f32), -1);
    try std.testing.expectEqual(control.next(), engine.next());
    rng.fillVectorExponential(@Vector(8, f32), &empty_vec_floats, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_vec_bools: [0]@Vector(8, bool) = .{};
    rng.fillVectorChance(@Vector(8, bool), &empty_vec_bools, -0.1);
    try std.testing.expectEqual(control.next(), engine.next());
    rng.fillVectorRatio(@Vector(8, bool), &empty_vec_bools, 2, 1);
    try std.testing.expectEqual(control.next(), engine.next());

    var floats: [4]f64 = undefined;
    try std.testing.expectError(error.NonFinite, rng.fillRangeChecked(f64, &floats, std.math.inf(f64), 1));
    try std.testing.expectEqual(control.next(), engine.next());

    var bools: [8]bool = undefined;
    try std.testing.expectError(error.InvalidProbability, rng.fillChanceChecked(&bools, -0.1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, rng.fillRatioChecked(&bools, 2, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, rng.fillNormalChecked(f64, &floats, 0, -1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, rng.fillExponentialChecked(f64, &floats, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    var vec_bools: [2]@Vector(8, bool) = undefined;
    try std.testing.expectError(error.InvalidProbability, rng.fillVectorChanceChecked(@Vector(8, bool), &vec_bools, -0.1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidProbability, rng.fillVectorRatioChecked(@Vector(8, bool), &vec_bools, 2, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    var vec_floats: [2]@Vector(8, f32) = undefined;
    try std.testing.expectError(error.InvalidParameter, rng.fillVectorExponentialChecked(@Vector(8, f32), &vec_floats, 0));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned normal and exponential batches allocate and validate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_90a0);
    var control = alea.ScalarPrng.init(0x5150_90a0);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.normalBatchChecked(f64, empty_alloc.allocator(), 0, std.math.inf(f64), -1);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_normal_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, rng.normalBatchChecked(f64, invalid_normal_alloc.allocator(), 8, 0, -1));
    try std.testing.expect(!invalid_normal_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_normal_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, rng.normalBatch(f64, invalid_normal_unchecked_alloc.allocator(), 8, std.math.inf(f64), -1));
    try std.testing.expect(!invalid_normal_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_exponential_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, exponentialBatchCheckedFrom(&engine, f64, invalid_exponential_alloc.allocator(), 8, 0));
    try std.testing.expect(!invalid_exponential_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_exponential_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, exponentialBatchFrom(&engine, f64, invalid_exponential_unchecked_alloc.allocator(), 8, 0));
    try std.testing.expect(!invalid_exponential_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var normal_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.normalBatchChecked(f64, normal_alloc.allocator(), 8, 0, 1));
    try std.testing.expect(normal_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var exponential_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, exponentialBatchFrom(&engine, f64, exponential_alloc.allocator(), 8, 2));
    try std.testing.expect(exponential_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned bounded uint batches allocate and validate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_99a0);
    var control = alea.ScalarPrng.init(0x5150_99a0);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.uintLessThanBatchChecked(u32, empty_alloc.allocator(), 0, 0);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.uintLessThanBatchChecked(u32, invalid_alloc.allocator(), 8, 0));
    try std.testing.expect(!invalid_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.uintLessThanBatch(u32, invalid_unchecked_alloc.allocator(), 8, 0));
    try std.testing.expect(!invalid_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var less_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, uintLessThanBatchCheckedFrom(&engine, u32, less_alloc.allocator(), 8, 1000));
    try std.testing.expect(less_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var at_most_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.uintAtMostBatch(u32, at_most_alloc.allocator(), 8, 1000));
    try std.testing.expect(at_most_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned vector normal and exponential batches allocate and validate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_95a0);
    var control = alea.ScalarPrng.init(0x5150_95a0);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.vectorNormalBatchChecked(@Vector(8, f32), empty_alloc.allocator(), 0, std.math.inf(f32), -1);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_normal_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, rng.vectorNormalBatchChecked(@Vector(8, f32), invalid_normal_alloc.allocator(), 4, 0, -1));
    try std.testing.expect(!invalid_normal_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_normal_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, rng.vectorNormalBatch(@Vector(8, f32), invalid_normal_unchecked_alloc.allocator(), 4, std.math.inf(f32), -1));
    try std.testing.expect(!invalid_normal_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_exponential_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, vectorExponentialBatchCheckedFrom(&engine, @Vector(4, f64), invalid_exponential_alloc.allocator(), 4, 0));
    try std.testing.expect(!invalid_exponential_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_exponential_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, vectorExponentialBatchFrom(&engine, @Vector(4, f64), invalid_exponential_unchecked_alloc.allocator(), 4, 0));
    try std.testing.expect(!invalid_exponential_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var normal_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.vectorNormalBatchChecked(@Vector(8, f32), normal_alloc.allocator(), 4, 0, 1));
    try std.testing.expect(normal_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var exponential_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, vectorExponentialBatchFrom(&engine, @Vector(4, f64), exponential_alloc.allocator(), 4, 2));
    try std.testing.expect(exponential_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned standard normal and exponential batches allocate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_96a0);
    var control = alea.ScalarPrng.init(0x5150_96a0);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.standardNormalBatch(f64, empty_alloc.allocator(), 0);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var normal_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.standardNormalBatch(f64, normal_alloc.allocator(), 8));
    try std.testing.expect(normal_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var exponential_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, standardExponentialBatchFrom(&engine, f64, exponential_alloc.allocator(), 8));
    try std.testing.expect(exponential_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned unicode scalar batches allocate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_97a2);
    var control = alea.ScalarPrng.init(0x5150_97a2);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.unicodeScalarBatch(empty_alloc.allocator(), 0);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, unicodeScalarBatchFrom(&engine, alloc.allocator(), 8));
    try std.testing.expect(alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned vector standard normal and exponential batches allocate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_96a1);
    var control = alea.ScalarPrng.init(0x5150_96a1);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.vectorStandardNormalBatch(@Vector(8, f32), empty_alloc.allocator(), 0);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var normal_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.vectorStandardNormalBatch(@Vector(8, f32), normal_alloc.allocator(), 4));
    try std.testing.expect(normal_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var exponential_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, vectorStandardExponentialBatchFrom(&engine, @Vector(4, f64), exponential_alloc.allocator(), 4));
    try std.testing.expect(exponential_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned probability batches allocate and validate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_89a0);
    var control = alea.ScalarPrng.init(0x5150_89a0);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.chanceBatchChecked(empty_alloc.allocator(), 0, -0.1);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_chance_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidProbability, rng.chanceBatchChecked(invalid_chance_alloc.allocator(), 8, -0.1));
    try std.testing.expect(!invalid_chance_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_chance_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidProbability, rng.chanceBatch(invalid_chance_unchecked_alloc.allocator(), 8, -0.1));
    try std.testing.expect(!invalid_chance_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_ratio_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidProbability, ratioBatchCheckedFrom(&engine, invalid_ratio_alloc.allocator(), 8, 2, 1));
    try std.testing.expect(!invalid_ratio_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_ratio_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidProbability, ratioBatchFrom(&engine, invalid_ratio_unchecked_alloc.allocator(), 8, 2, 1));
    try std.testing.expect(!invalid_ratio_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var chance_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.chanceBatchChecked(chance_alloc.allocator(), 8, 0.25));
    try std.testing.expect(chance_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var ratio_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, ratioBatchFrom(&engine, ratio_alloc.allocator(), 8, 3, 8));
    try std.testing.expect(ratio_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned vector probability batches allocate and validate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_94a0);
    var control = alea.ScalarPrng.init(0x5150_94a0);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.vectorChanceBatchChecked(@Vector(8, bool), empty_alloc.allocator(), 0, -0.1);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_chance_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidProbability, rng.vectorChanceBatchChecked(@Vector(8, bool), invalid_chance_alloc.allocator(), 4, -0.1));
    try std.testing.expect(!invalid_chance_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_ratio_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidProbability, vectorRatioBatchCheckedFrom(&engine, @Vector(8, bool), invalid_ratio_alloc.allocator(), 4, 2, 1));
    try std.testing.expect(!invalid_ratio_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var chance_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.vectorChanceBatchChecked(@Vector(8, bool), chance_alloc.allocator(), 4, 0.25));
    try std.testing.expect(chance_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var ratio_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, vectorRatioBatchFrom(&engine, @Vector(8, bool), ratio_alloc.allocator(), 4, 3, 8));
    try std.testing.expect(ratio_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "degenerate owned probability batches do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_89a1);
    var control = alea.ScalarPrng.init(0x5150_89a1);
    const rng = Rng.init(&engine);

    const all_false = try rng.chanceBatchChecked(std.testing.allocator, 8, 0);
    defer std.testing.allocator.free(all_false);
    for (all_false) |draw| try std.testing.expect(!draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const all_true = try chanceBatchCheckedFrom(&engine, std.testing.allocator, 8, 1);
    defer std.testing.allocator.free(all_true);
    for (all_true) |draw| try std.testing.expect(draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const ratio_false = try rng.ratioBatchChecked(std.testing.allocator, 8, 0, 7);
    defer std.testing.allocator.free(ratio_false);
    for (ratio_false) |draw| try std.testing.expect(!draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const ratio_true = try ratioBatchCheckedFrom(&engine, std.testing.allocator, 8, 7, 7);
    defer std.testing.allocator.free(ratio_true);
    for (ratio_true) |draw| try std.testing.expect(draw);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "degenerate owned vector probability batches do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_94a1);
    var control = alea.ScalarPrng.init(0x5150_94a1);
    const rng = Rng.init(&engine);

    const all_false = try rng.vectorChanceBatchChecked(@Vector(8, bool), std.testing.allocator, 4, 0);
    defer std.testing.allocator.free(all_false);
    for (all_false) |draw| try std.testing.expectEqual(@as(@Vector(8, bool), @splat(false)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const all_true = try vectorChanceBatchCheckedFrom(&engine, @Vector(8, bool), std.testing.allocator, 4, 1);
    defer std.testing.allocator.free(all_true);
    for (all_true) |draw| try std.testing.expectEqual(@as(@Vector(8, bool), @splat(true)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const ratio_false = try rng.vectorRatioBatchChecked(@Vector(8, bool), std.testing.allocator, 4, 0, 7);
    defer std.testing.allocator.free(ratio_false);
    for (ratio_false) |draw| try std.testing.expectEqual(@as(@Vector(8, bool), @splat(false)), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const ratio_true = try vectorRatioBatchCheckedFrom(&engine, @Vector(8, bool), std.testing.allocator, 4, 7, 7);
    defer std.testing.allocator.free(ratio_true);
    for (ratio_true) |draw| try std.testing.expectEqual(@as(@Vector(8, bool), @splat(true)), draw);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "zero-length checked fills do not validate or consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_bae);
    var control = alea.ScalarPrng.init(0x5150_bae);
    const rng = Rng.init(&engine);

    var scalar_int: [0]u32 = .{};
    var scalar_float: [0]f64 = .{};
    var bools: [0]bool = .{};
    var vec_f32: [0]@Vector(8, f32) = .{};
    var vec_bool: [0]@Vector(8, bool) = .{};

    try rng.fillRangeChecked(u32, &scalar_int, 3, 3);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillRangeCheckedFrom(&engine, f64, &scalar_float, std.math.inf(f64), 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillChanceCheckedFrom(&engine, &bools, -0.1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillRatioCheckedFrom(&engine, &bools, 2, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try rng.fillNormalChecked(f64, &scalar_float, std.math.inf(f64), 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillExponentialCheckedFrom(&engine, f64, &scalar_float, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try rng.fillVectorRangeChecked(@Vector(8, f32), &vec_f32, 2, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorChanceCheckedFrom(&engine, @Vector(8, bool), &vec_bool, -0.1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorRatioCheckedFrom(&engine, @Vector(8, bool), &vec_bool, 2, 1);
    try std.testing.expectEqual(control.next(), engine.next());
    try rng.fillVectorNormalChecked(@Vector(8, f32), &vec_f32, 0, -1);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillVectorExponentialCheckedFrom(&engine, @Vector(8, f32), &vec_f32, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try fillUnicodeScalarRangeLessThanCheckedFrom(&engine, @as([]u21, &.{}), 0xD800, 0xE000);
    try std.testing.expectEqual(control.next(), engine.next());

    var one_int: [1]u32 = undefined;
    try std.testing.expectError(error.EmptyRange, fillRangeCheckedFrom(&engine, u32, &one_int, 3, 3));
}

test "negative weighted index does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_b9f);
    var control = alea.ScalarPrng.init(0x5150_b9f);

    try std.testing.expectError(error.InvalidWeight, weightedIndexCheckedFrom(&engine, &.{ 1.0, -1.0 }));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "single-positive weighted index does not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_b9e);
    var control = alea.ScalarPrng.init(0x5150_b9e);
    const rng = Rng.init(&engine);

    try std.testing.expectEqual(@as(?usize, 2), weightedIndexFrom(&engine, &.{ 0.0, 0.0, 3.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?usize, 1), try rng.weightedIndexChecked(&.{ 0.0, 5.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_indices: [5]usize = undefined;
    try rng.fillWeightedIndexChecked(&weighted_indices, &.{ 0.0, 5.0, 0.0 });
    for (weighted_indices) |draw| try std.testing.expectEqual(@as(usize, 1), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_weighted_indices = try weightedIndexBatchCheckedFrom(&engine, std.testing.allocator, 5, &.{ 0.0, 0.0, 7.0 });
    defer std.testing.allocator.free(owned_weighted_indices);
    for (owned_weighted_indices) |draw| try std.testing.expectEqual(@as(usize, 2), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const weighted_index_array = try rng.weightedIndexArrayChecked(5, &.{ 0.0, 5.0, 0.0 });
    for (weighted_index_array) |draw| try std.testing.expectEqual(@as(usize, 1), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const direct_weighted_index_array = weightedIndexArrayFrom(&engine, 5, &.{ 0.0, 0.0, 7.0 }).?;
    for (direct_weighted_index_array) |draw| try std.testing.expectEqual(@as(usize, 2), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const labels = [_]u8{ 10, 20, 30 };
    var weighted_values: [5]u8 = undefined;
    try rng.fillChooseWeightedChecked(u8, &weighted_values, &labels, &.{ 0.0, 5.0, 0.0 });
    for (weighted_values) |draw| try std.testing.expectEqual(@as(u8, 20), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_weighted_values = try chooseWeightedBatchCheckedFrom(&engine, u8, std.testing.allocator, 5, &labels, &.{ 0.0, 0.0, 7.0 });
    defer std.testing.allocator.free(owned_weighted_values);
    for (owned_weighted_values) |draw| try std.testing.expectEqual(@as(u8, 30), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const weighted_value_array = try rng.chooseWeightedValueArrayChecked(u8, 5, &labels, &.{ 0.0, 5.0, 0.0 });
    for (weighted_value_array) |draw| try std.testing.expectEqual(@as(u8, 20), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const direct_weighted_value_array = (try chooseWeightedValueArrayFrom(&engine, u8, 5, &labels, &.{ 0.0, 0.0, 7.0 })).?;
    for (direct_weighted_value_array) |draw| try std.testing.expectEqual(@as(u8, 30), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_const_ptrs: [5]*const u8 = undefined;
    try rng.fillChooseWeightedConstPtrChecked(u8, &weighted_const_ptrs, &labels, &.{ 0.0, 5.0, 0.0 });
    for (weighted_const_ptrs) |draw| try std.testing.expectEqual(@as(u8, 20), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_weighted_const_ptrs = try chooseWeightedConstPtrBatchCheckedFrom(&engine, u8, std.testing.allocator, 5, &labels, &.{ 0.0, 0.0, 7.0 });
    defer std.testing.allocator.free(owned_weighted_const_ptrs);
    for (owned_weighted_const_ptrs) |draw| try std.testing.expectEqual(@as(u8, 30), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    const weighted_const_ptr_array = try rng.chooseWeightedConstPtrArrayChecked(u8, 5, &labels, &.{ 0.0, 5.0, 0.0 });
    for (weighted_const_ptr_array) |draw| try std.testing.expectEqual(@as(u8, 20), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    const direct_weighted_const_ptr_array = (try chooseWeightedConstPtrArrayFrom(&engine, u8, 5, &labels, &.{ 0.0, 0.0, 7.0 })).?;
    for (direct_weighted_const_ptr_array) |draw| try std.testing.expectEqual(@as(u8, 30), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    var mutable_labels = [_]u8{ 10, 20, 30 };
    var weighted_ptrs: [5]*u8 = undefined;
    try rng.fillChooseWeightedPtrChecked(u8, &weighted_ptrs, &mutable_labels, &.{ 0.0, 5.0, 0.0 });
    for (weighted_ptrs) |draw| try std.testing.expectEqual(@as(u8, 20), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_weighted_ptrs = try chooseWeightedPtrBatchCheckedFrom(&engine, u8, std.testing.allocator, 5, &mutable_labels, &.{ 0.0, 0.0, 7.0 });
    defer std.testing.allocator.free(owned_weighted_ptrs);
    for (owned_weighted_ptrs) |draw| try std.testing.expectEqual(@as(u8, 30), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    const weighted_ptr_array = try rng.chooseWeightedPtrArrayChecked(u8, 5, &mutable_labels, &.{ 0.0, 5.0, 0.0 });
    for (weighted_ptr_array) |draw| try std.testing.expectEqual(@as(u8, 20), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    const direct_weighted_ptr_array = (try chooseWeightedPtrArrayFrom(&engine, u8, 5, &mutable_labels, &.{ 0.0, 0.0, 7.0 })).?;
    for (direct_weighted_ptr_array) |draw| try std.testing.expectEqual(@as(u8, 30), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?u32, 1), try weightedIndexU32From(&engine, &.{ 0.0, 5.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?u32, 1), try rng.weightedIndexU32Checked(&.{ 0.0, 5.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_u32_indices: [5]u32 = undefined;
    try rng.fillWeightedIndexU32Checked(&weighted_u32_indices, &.{ 0.0, 5.0, 0.0 });
    for (weighted_u32_indices) |draw| try std.testing.expectEqual(@as(u32, 1), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_weighted_u32_indices = try weightedIndexU32BatchCheckedFrom(&engine, std.testing.allocator, 5, &.{ 0.0, 0.0, 7.0 });
    defer std.testing.allocator.free(owned_weighted_u32_indices);
    for (owned_weighted_u32_indices) |draw| try std.testing.expectEqual(@as(u32, 2), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const weighted_u32_index_array = try rng.weightedIndexU32ArrayChecked(5, &.{ 0.0, 5.0, 0.0 });
    for (weighted_u32_index_array) |draw| try std.testing.expectEqual(@as(u32, 1), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const direct_weighted_u32_index_array = (try weightedIndexU32ArrayFrom(&engine, 5, &.{ 0.0, 0.0, 7.0 })).?;
    for (direct_weighted_u32_index_array) |draw| try std.testing.expectEqual(@as(u32, 2), draw);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid facade weighted helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba3);
    var control = alea.ScalarPrng.init(0x5150_ba3);
    const rng = Rng.init(&engine);

    try std.testing.expectError(error.InvalidWeight, rng.weightedIndexChecked(&.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_out: [0]usize = .{};
    try rng.fillWeightedIndexChecked(&weighted_out, &.{});
    try std.testing.expectEqual(control.next(), engine.next());

    const empty_weighted_array = try rng.weightedIndexArrayChecked(0, &.{std.math.nan(f64)});
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_array.len);
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_value_out: [0]u8 = .{};
    try rng.fillChooseWeightedChecked(u8, &weighted_value_out, &.{}, &.{});
    try std.testing.expectEqual(control.next(), engine.next());

    const empty_weighted_value_array = try chooseWeightedValueArrayCheckedFrom(&engine, u8, 0, &.{1}, &.{std.math.nan(f64)});
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_value_array.len);
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_const_ptr_out: [0]*const u8 = .{};
    try rng.fillChooseWeightedConstPtrChecked(u8, &weighted_const_ptr_out, &.{}, &.{});
    try std.testing.expectEqual(control.next(), engine.next());

    const empty_weighted_const_ptr_array = try rng.chooseWeightedConstPtrArrayChecked(u8, 0, &.{1}, &.{std.math.nan(f64)});
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_const_ptr_array.len);
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_ptr_out: [0]*u8 = .{};
    var empty_weighted_ptr_items: [0]u8 = .{};
    try rng.fillChooseWeightedPtrChecked(u8, &weighted_ptr_out, &empty_weighted_ptr_items, &.{});
    try std.testing.expectEqual(control.next(), engine.next());

    var unchecked_weighted_out: [0]?usize = .{};
    fillWeightedIndexFrom(&engine, &unchecked_weighted_out, &.{});
    try std.testing.expectEqual(control.next(), engine.next());

    var unchecked_weighted_value_out: [0]?u8 = .{};
    try fillChooseWeightedFrom(&engine, u8, &unchecked_weighted_value_out, &.{}, &.{});
    try std.testing.expectEqual(control.next(), engine.next());

    var unchecked_weighted_const_ptr_out: [0]?*const u8 = .{};
    try fillChooseWeightedConstPtrFrom(&engine, u8, &unchecked_weighted_const_ptr_out, &.{}, &.{});
    try std.testing.expectEqual(control.next(), engine.next());

    var unchecked_weighted_ptr_out: [0]?*u8 = .{};
    try fillChooseWeightedPtrFrom(&engine, u8, &unchecked_weighted_ptr_out, &empty_weighted_ptr_items, &.{});
    try std.testing.expectEqual(control.next(), engine.next());

    var unchecked_weighted_u32_out: [0]?u32 = .{};
    try fillWeightedIndexU32From(&engine, &unchecked_weighted_u32_out, &.{});
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_zero_ptr_items = [_]u8{1};
    const empty_weighted_ptr_array = try chooseWeightedPtrArrayCheckedFrom(&engine, u8, 0, &invalid_zero_ptr_items, &.{std.math.nan(f64)});
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_ptr_array.len);
    try std.testing.expectEqual(control.next(), engine.next());

    var one_weighted_out: [1]usize = undefined;
    try std.testing.expectError(error.EmptyRange, fillWeightedIndexCheckedFrom(&engine, &one_weighted_out, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expect(weightedIndexArrayFrom(&engine, 1, &.{}) == null);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.weightedIndexArrayChecked(1, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    var one_weighted_value_out: [1]u8 = undefined;
    try std.testing.expectError(error.EmptyRange, fillChooseWeightedCheckedFrom(&engine, u8, &one_weighted_value_out, &.{}, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[1]u8, null), try rng.chooseWeightedValueArray(u8, 1, &.{}, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, chooseWeightedValueArrayCheckedFrom(&engine, u8, 1, &.{}, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    var one_weighted_const_ptr_out: [1]*const u8 = undefined;
    try std.testing.expectError(error.EmptyRange, fillChooseWeightedConstPtrCheckedFrom(&engine, u8, &one_weighted_const_ptr_out, &.{}, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[1]*const u8, null), try rng.chooseWeightedConstPtrArray(u8, 1, &.{}, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, chooseWeightedConstPtrArrayCheckedFrom(&engine, u8, 1, &.{}, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    var one_weighted_ptr_out: [1]*u8 = undefined;
    try std.testing.expectError(error.EmptyRange, fillChooseWeightedPtrCheckedFrom(&engine, u8, &one_weighted_ptr_out, &empty_weighted_ptr_items, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[1]*u8, null), try rng.chooseWeightedPtrArray(u8, 1, &empty_weighted_ptr_items, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, chooseWeightedPtrArrayCheckedFrom(&engine, u8, 1, &empty_weighted_ptr_items, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillChooseWeightedCheckedFrom(&engine, u8, &one_weighted_value_out, &.{1}, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, rng.chooseWeightedValueArrayChecked(u8, 1, &.{1}, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, fillChooseWeightedConstPtrCheckedFrom(&engine, u8, &one_weighted_const_ptr_out, &.{1}, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, chooseWeightedConstPtrArrayCheckedFrom(&engine, u8, 1, &.{1}, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    var one_weighted_ptr_item = [_]u8{1};
    try std.testing.expectError(error.InvalidParameter, fillChooseWeightedPtrCheckedFrom(&engine, u8, &one_weighted_ptr_out, &one_weighted_ptr_item, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidParameter, rng.chooseWeightedPtrArrayChecked(u8, 1, &one_weighted_ptr_item, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_weight_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexBatchCheckedFrom(&engine, invalid_weight_alloc.allocator(), 5, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expect(!invalid_weight_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidWeight, weightedIndexArrayCheckedFrom(&engine, 5, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_weight_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexBatchFrom(&engine, invalid_weight_unchecked_alloc.allocator(), 5, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expect(!invalid_weight_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_weight_u32_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32BatchFrom(&engine, invalid_weight_u32_unchecked_alloc.allocator(), 5, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expect(!invalid_weight_u32_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    const no_positive_batch = try weightedIndexBatchFrom(&engine, std.testing.allocator, 5, &.{ 0.0, 0.0 });
    defer std.testing.allocator.free(no_positive_batch);
    try std.testing.expectEqualSlices(?usize, &.{ null, null, null, null, null }, no_positive_batch);
    try std.testing.expectEqual(control.next(), engine.next());

    const no_positive_u32_batch = try weightedIndexU32BatchFrom(&engine, std.testing.allocator, 5, &.{ 0.0, 0.0 });
    defer std.testing.allocator.free(no_positive_u32_batch);
    try std.testing.expectEqualSlices(?u32, &.{ null, null, null, null, null }, no_positive_u32_batch);
    try std.testing.expectEqual(control.next(), engine.next());

    const single_weighted_batch = try weightedIndexBatchFrom(&engine, std.testing.allocator, 5, &.{ 0.0, 7.0, 0.0 });
    defer std.testing.allocator.free(single_weighted_batch);
    try std.testing.expectEqualSlices(?usize, &.{ 1, 1, 1, 1, 1 }, single_weighted_batch);
    try std.testing.expectEqual(control.next(), engine.next());

    const single_weighted_u32_batch = try weightedIndexU32BatchFrom(&engine, std.testing.allocator, 5, &.{ 0.0, 7.0, 0.0 });
    defer std.testing.allocator.free(single_weighted_u32_batch);
    try std.testing.expectEqualSlices(?u32, &.{ 1, 1, 1, 1, 1 }, single_weighted_u32_batch);
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_ptr_items = [_]u8{ 1, 2 };
    var invalid_weight_value_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatchCheckedFrom(&engine, u8, invalid_weight_value_alloc.allocator(), 5, &.{ 1, 2 }, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expect(!invalid_weight_value_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_weight_value_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatchFrom(&engine, u8, invalid_weight_value_unchecked_alloc.allocator(), 5, &.{ 1, 2 }, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expect(!invalid_weight_value_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_weight_const_ptr_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatchFrom(&engine, u8, invalid_weight_const_ptr_unchecked_alloc.allocator(), 5, &.{ 1, 2 }, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expect(!invalid_weight_const_ptr_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_weight_ptr_unchecked_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatchFrom(&engine, u8, invalid_weight_ptr_unchecked_alloc.allocator(), 5, &weighted_ptr_items, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expect(!invalid_weight_ptr_unchecked_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    const no_positive_values = try chooseWeightedBatchFrom(&engine, u8, std.testing.allocator, 3, &.{ 1, 2 }, &.{ 0.0, 0.0 });
    defer std.testing.allocator.free(no_positive_values);
    try std.testing.expectEqualSlices(?u8, &.{ null, null, null }, no_positive_values);
    try std.testing.expectEqual(control.next(), engine.next());

    const single_weighted_values = try chooseWeightedBatchFrom(&engine, u8, std.testing.allocator, 3, &.{ 4, 9 }, &.{ 0.0, 2.0 });
    defer std.testing.allocator.free(single_weighted_values);
    try std.testing.expectEqualSlices(?u8, &.{ 9, 9, 9 }, single_weighted_values);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidWeight, chooseWeightedValueArrayCheckedFrom(&engine, u8, 5, &.{ 1, 2 }, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_weight_const_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatchCheckedFrom(&engine, u8, invalid_weight_const_ptr_alloc.allocator(), 5, &.{ 1, 2 }, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expect(!invalid_weight_const_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidWeight, rng.chooseWeightedConstPtrArrayChecked(u8, 5, &.{ 1, 2 }, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_weight_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatchCheckedFrom(&engine, u8, invalid_weight_ptr_alloc.allocator(), 5, &weighted_ptr_items, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expect(!invalid_weight_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrArrayCheckedFrom(&engine, u8, 5, &weighted_ptr_items, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_weight_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty_weighted = try rng.weightedIndexBatchChecked(empty_weight_alloc.allocator(), 0, &.{});
    defer empty_weight_alloc.allocator().free(empty_weighted);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted.len);
    try std.testing.expect(!empty_weight_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var no_positive_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.weightedIndexBatchChecked(no_positive_alloc.allocator(), 5, &.{ 0.0, 0.0 }));
    try std.testing.expect(!no_positive_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expect(weightedIndexArrayFrom(&engine, 5, &.{ 0.0, 0.0 }) == null);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.weightedIndexArrayChecked(5, &.{ 0.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    var no_positive_value_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.chooseWeightedBatchChecked(u8, no_positive_value_alloc.allocator(), 5, &.{ 1, 2 }, &.{ 0.0, 0.0 }));
    try std.testing.expect(!no_positive_value_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[5]u8, null), try chooseWeightedValueArrayFrom(&engine, u8, 5, &.{ 1, 2 }, &.{ 0.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.chooseWeightedValueArrayChecked(u8, 5, &.{ 1, 2 }, &.{ 0.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    var no_positive_const_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.chooseWeightedConstPtrBatchChecked(u8, no_positive_const_ptr_alloc.allocator(), 5, &.{ 1, 2 }, &.{ 0.0, 0.0 }));
    try std.testing.expect(!no_positive_const_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[5]*const u8, null), try chooseWeightedConstPtrArrayFrom(&engine, u8, 5, &.{ 1, 2 }, &.{ 0.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.chooseWeightedConstPtrArrayChecked(u8, 5, &.{ 1, 2 }, &.{ 0.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    var no_positive_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.chooseWeightedPtrBatchChecked(u8, no_positive_ptr_alloc.allocator(), 5, &weighted_ptr_items, &.{ 0.0, 0.0 }));
    try std.testing.expect(!no_positive_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[5]*u8, null), try chooseWeightedPtrArrayFrom(&engine, u8, 5, &weighted_ptr_items, &.{ 0.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.chooseWeightedPtrArrayChecked(u8, 5, &weighted_ptr_items, &.{ 0.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.weightedIndexBatchChecked(weighted_alloc.allocator(), 5, &.{ 1.0, 2.0 }));
    try std.testing.expect(weighted_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_value_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.chooseWeightedBatchChecked(u8, weighted_value_alloc.allocator(), 5, &.{ 1, 2 }, &.{ 1.0, 2.0 }));
    try std.testing.expect(weighted_value_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_const_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.chooseWeightedConstPtrBatchChecked(u8, weighted_const_ptr_alloc.allocator(), 5, &.{ 1, 2 }, &.{ 1.0, 2.0 }));
    try std.testing.expect(weighted_const_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.chooseWeightedPtrBatchChecked(u8, weighted_ptr_alloc.allocator(), 5, &weighted_ptr_items, &.{ 1.0, 2.0 }));
    try std.testing.expect(weighted_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidWeight, rng.weightedIndexU32Checked(&.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_u32_out: [0]u32 = .{};
    try rng.fillWeightedIndexU32Checked(&weighted_u32_out, &.{});
    try std.testing.expectEqual(control.next(), engine.next());

    const empty_weighted_u32_array = try weightedIndexU32ArrayCheckedFrom(&engine, 0, &.{std.math.nan(f64)});
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_u32_array.len);
    try std.testing.expectEqual(control.next(), engine.next());

    var one_weighted_u32_out: [1]u32 = undefined;
    try std.testing.expectError(error.EmptyRange, fillWeightedIndexU32CheckedFrom(&engine, &one_weighted_u32_out, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[1]u32, null), try rng.weightedIndexU32Array(1, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, weightedIndexU32ArrayCheckedFrom(&engine, 1, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_weight_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32BatchCheckedFrom(&engine, invalid_weight_u32_alloc.allocator(), 5, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expect(!invalid_weight_u32_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.InvalidWeight, rng.weightedIndexU32ArrayChecked(5, &.{ 1.0, std.math.nan(f64) }));
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_weight_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty_weighted_u32 = try rng.weightedIndexU32BatchChecked(empty_weight_u32_alloc.allocator(), 0, &.{});
    defer empty_weight_u32_alloc.allocator().free(empty_weighted_u32);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_u32.len);
    try std.testing.expect(!empty_weight_u32_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var no_positive_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.weightedIndexU32BatchChecked(no_positive_u32_alloc.allocator(), 5, &.{ 0.0, 0.0 }));
    try std.testing.expect(!no_positive_u32_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[5]u32, null), try weightedIndexU32ArrayFrom(&engine, 5, &.{ 0.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.weightedIndexU32ArrayChecked(5, &.{ 0.0, 0.0 }));
    try std.testing.expectEqual(control.next(), engine.next());

    var weighted_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.weightedIndexU32BatchChecked(weighted_u32_alloc.allocator(), 5, &.{ 1.0, 2.0 }));
    try std.testing.expect(weighted_u32_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    const items = [_]u8{ 1, 2 };
    try std.testing.expectError(error.InvalidParameter, rng.sampleWithoutReplacementChecked(u8, std.testing.allocator, &items, 3));
    try std.testing.expectEqual(control.next(), engine.next());
}

test "invalid facade choice helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba4);
    var control = alea.ScalarPrng.init(0x5150_ba4);
    const rng = Rng.init(&engine);

    try std.testing.expectError(error.EmptyRange, rng.chooseChecked(u8, &.{}));
    try std.testing.expectEqual(control.next(), engine.next());

    var empty: [0]u8 = .{};
    try std.testing.expectError(error.EmptyRange, rng.choosePtrChecked(u8, &empty));
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_const_ptrs: [0]*const u8 = .{};
    rng.fillChooseConstPtr(u8, &empty_const_ptrs, &empty);
    try std.testing.expectEqual(control.next(), engine.next());
    try rng.fillChooseConstPtrChecked(u8, &empty_const_ptrs, &empty);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_mut_ptrs: [0]*u8 = .{};
    rng.fillChoosePtr(u8, &empty_mut_ptrs, &empty);
    try std.testing.expectEqual(control.next(), engine.next());
    try rng.fillChoosePtrChecked(u8, &empty_mut_ptrs, &empty);
    try std.testing.expectEqual(control.next(), engine.next());

    var one_const_ptr: [1]*const u8 = undefined;
    try std.testing.expectError(error.EmptyRange, fillChooseConstPtrCheckedFrom(&engine, u8, &one_const_ptr, &empty));
    try std.testing.expectEqual(control.next(), engine.next());

    var one_mut_ptr: [1]*u8 = undefined;
    try std.testing.expectError(error.EmptyRange, fillChoosePtrCheckedFrom(&engine, u8, &one_mut_ptr, &empty));
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_const_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty_const_ptr_batch = try rng.chooseConstPtrBatchChecked(u8, empty_const_ptr_alloc.allocator(), 0, &empty);
    defer empty_const_ptr_alloc.allocator().free(empty_const_ptr_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_const_ptr_batch.len);
    try std.testing.expect(!empty_const_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_const_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, chooseConstPtrBatchCheckedFrom(&engine, u8, invalid_const_ptr_alloc.allocator(), 8, &empty));
    try std.testing.expect(!invalid_const_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_mut_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, choosePtrBatchCheckedFrom(&engine, u8, invalid_mut_ptr_alloc.allocator(), 8, &empty));
    try std.testing.expect(!invalid_mut_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_values: [0]u8 = .{};
    rng.fillChoose(u8, &empty_values, &empty);
    try std.testing.expectEqual(control.next(), engine.next());
    try rng.fillChooseChecked(u8, &empty_values, &empty);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[1]u8, null), rng.chooseValueArray(u8, 1, &empty));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.chooseValueArrayChecked(u8, 1, &empty));
    try std.testing.expectEqual(control.next(), engine.next());

    const empty_value_array = try rng.chooseValueArrayChecked(u8, 0, &empty);
    try std.testing.expectEqual(@as(usize, 0), empty_value_array.len);
    try std.testing.expectEqual(control.next(), engine.next());

    var one_value: [1]u8 = undefined;
    try std.testing.expectError(error.EmptyRange, fillChooseCheckedFrom(&engine, u8, &one_value, &empty));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[1]*const u8, null), rng.chooseConstPtrArray(u8, 1, &empty));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.chooseConstPtrArrayChecked(u8, 1, &empty));
    try std.testing.expectEqual(control.next(), engine.next());

    const empty_const_ptr_array = try rng.chooseConstPtrArrayChecked(u8, 0, &empty);
    try std.testing.expectEqual(@as(usize, 0), empty_const_ptr_array.len);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[1]*u8, null), rng.choosePtrArray(u8, 1, &empty));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.choosePtrArrayChecked(u8, 1, &empty));
    try std.testing.expectEqual(control.next(), engine.next());

    const empty_mut_ptr_array = try rng.choosePtrArrayChecked(u8, 0, &empty);
    try std.testing.expectEqual(@as(usize, 0), empty_mut_ptr_array.len);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_value_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty_value_batch = try rng.chooseBatchChecked(u8, empty_value_alloc.allocator(), 0, &empty);
    defer empty_value_alloc.allocator().free(empty_value_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_value_batch.len);
    try std.testing.expect(!empty_value_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_value_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, chooseBatchCheckedFrom(&engine, u8, invalid_value_alloc.allocator(), 8, &empty));
    try std.testing.expect(!invalid_value_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_unchecked_value_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, chooseBatchFrom(&engine, u8, invalid_unchecked_value_alloc.allocator(), 8, &empty));
    try std.testing.expect(!invalid_unchecked_value_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_unchecked_const_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, chooseConstPtrBatchFrom(&engine, u8, invalid_unchecked_const_ptr_alloc.allocator(), 8, &empty));
    try std.testing.expect(!invalid_unchecked_const_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_unchecked_mut_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, choosePtrBatchFrom(&engine, u8, invalid_unchecked_mut_ptr_alloc.allocator(), 8, &empty));
    try std.testing.expect(!invalid_unchecked_mut_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_unchecked_index_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, chooseIndexBatchFrom(&engine, invalid_unchecked_index_alloc.allocator(), 8, 0));
    try std.testing.expect(!invalid_unchecked_index_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_unchecked_index_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, chooseIndexU32BatchFrom(&engine, invalid_unchecked_index_u32_alloc.allocator(), 8, 0));
    try std.testing.expect(!invalid_unchecked_index_u32_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    const non_empty = [_]u8{ 1, 2, 3 };
    var const_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.chooseConstPtrBatchChecked(u8, const_ptr_alloc.allocator(), 8, &non_empty));
    try std.testing.expect(const_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var mutable_non_empty = [_]u8{ 1, 2, 3 };
    var mut_ptr_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.choosePtrBatchChecked(u8, mut_ptr_alloc.allocator(), 8, &mutable_non_empty));
    try std.testing.expect(mut_ptr_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var value_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.chooseBatchChecked(u8, value_alloc.allocator(), 8, &non_empty));
    try std.testing.expect(value_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "single-item choice helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba4c);
    var control = alea.ScalarPrng.init(0x5150_ba4c);
    const rng = Rng.init(&engine);

    try std.testing.expectEqual(@as(?usize, 0), chooseIndexFrom(&engine, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(usize, 0), try rng.chooseIndexChecked(1));
    try std.testing.expectEqual(control.next(), engine.next());

    const single_index_array = try rng.chooseIndexArrayChecked(5, 1);
    try std.testing.expectEqualSlices(usize, &.{ 0, 0, 0, 0, 0 }, &single_index_array);
    try std.testing.expectEqual(control.next(), engine.next());

    const single_indices = try rng.chooseIndexBatchChecked(std.testing.allocator, 5, 1);
    defer std.testing.allocator.free(single_indices);
    for (single_indices) |draw| try std.testing.expectEqual(@as(usize, 0), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?u32, 0), chooseIndexU32From(&engine, 1));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(u32, 0), try rng.chooseIndexU32Checked(1));
    try std.testing.expectEqual(control.next(), engine.next());

    const single_u32_index_array = try rng.chooseIndexArrayU32Checked(5, 1);
    try std.testing.expectEqualSlices(u32, &.{ 0, 0, 0, 0, 0 }, &single_u32_index_array);
    try std.testing.expectEqual(control.next(), engine.next());

    const single_u32_indices = try chooseIndexU32BatchCheckedFrom(&engine, std.testing.allocator, 5, 1);
    defer std.testing.allocator.free(single_u32_indices);
    for (single_u32_indices) |draw| try std.testing.expectEqual(@as(u32, 0), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const items = [_]u8{42};
    try std.testing.expectEqual(@as(?u8, 42), chooseFrom(&engine, u8, &items));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(&items[0], chooseConstPtrFrom(&engine, u8, &items).?);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(&items[0], try rng.chooseConstPtrChecked(u8, &items));
    try std.testing.expectEqual(control.next(), engine.next());

    var chosen_const_ptrs: [5]*const u8 = undefined;
    try rng.fillChooseConstPtrChecked(u8, &chosen_const_ptrs, &items);
    for (chosen_const_ptrs) |draw| try std.testing.expectEqual(@as(u8, 42), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    const single_const_ptr_array = try rng.chooseConstPtrArrayChecked(u8, 5, &items);
    for (single_const_ptr_array) |draw| try std.testing.expectEqual(@as(u8, 42), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_chosen_const_ptrs = try chooseConstPtrBatchCheckedFrom(&engine, u8, std.testing.allocator, 5, &items);
    defer std.testing.allocator.free(owned_chosen_const_ptrs);
    for (owned_chosen_const_ptrs) |draw| try std.testing.expectEqual(@as(u8, 42), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(u8, 42), try rng.chooseChecked(u8, &items));
    try std.testing.expectEqual(control.next(), engine.next());

    var chosen_values: [5]u8 = undefined;
    try rng.fillChooseChecked(u8, &chosen_values, &items);
    for (chosen_values) |draw| try std.testing.expectEqual(@as(u8, 42), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    const single_value_array = try rng.chooseValueArrayChecked(u8, 5, &items);
    try std.testing.expectEqualSlices(u8, &.{ 42, 42, 42, 42, 42 }, &single_value_array);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_chosen_values = try chooseBatchCheckedFrom(&engine, u8, std.testing.allocator, 5, &items);
    defer std.testing.allocator.free(owned_chosen_values);
    for (owned_chosen_values) |draw| try std.testing.expectEqual(@as(u8, 42), draw);
    try std.testing.expectEqual(control.next(), engine.next());

    var mutable_items = [_]u8{99};
    try std.testing.expectEqual(&mutable_items[0], choosePtrFrom(&engine, u8, &mutable_items).?);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(&mutable_items[0], try rng.choosePtrChecked(u8, &mutable_items));
    try std.testing.expectEqual(control.next(), engine.next());

    var chosen_mut_ptrs: [5]*u8 = undefined;
    try rng.fillChoosePtrChecked(u8, &chosen_mut_ptrs, &mutable_items);
    for (chosen_mut_ptrs) |draw| try std.testing.expectEqual(@as(u8, 99), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    const single_mut_ptr_array = try rng.choosePtrArrayChecked(u8, 5, &mutable_items);
    for (single_mut_ptr_array) |draw| try std.testing.expectEqual(@as(u8, 99), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());

    const owned_chosen_mut_ptrs = try choosePtrBatchCheckedFrom(&engine, u8, std.testing.allocator, 5, &mutable_items);
    defer std.testing.allocator.free(owned_chosen_mut_ptrs);
    for (owned_chosen_mut_ptrs) |draw| try std.testing.expectEqual(@as(u8, 99), draw.*);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "empty index choice helpers do not consume random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba4d);
    var control = alea.ScalarPrng.init(0x5150_ba4d);
    const rng = Rng.init(&engine);

    try std.testing.expectEqual(@as(?usize, null), chooseIndexFrom(&engine, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, chooseIndexCheckedFrom(&engine, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.chooseIndexChecked(0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[1]usize, null), rng.chooseIndexArray(1, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.chooseIndexArrayChecked(1, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    const empty_array = try rng.chooseIndexArrayChecked(0, 0);
    try std.testing.expectEqual(@as(usize, 0), empty_array.len);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_indexes: [0]usize = .{};
    rng.fillChooseIndex(&empty_indexes, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try rng.fillChooseIndexChecked(&empty_indexes, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.chooseIndexBatchChecked(empty_alloc.allocator(), 0, 0);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, rng.chooseIndexBatchChecked(invalid_alloc.allocator(), 8, 0));
    try std.testing.expect(!invalid_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?u32, null), chooseIndexU32From(&engine, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, chooseIndexU32CheckedFrom(&engine, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.chooseIndexU32Checked(0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectEqual(@as(?[1]u32, null), rng.chooseIndexArrayU32(1, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    try std.testing.expectError(error.EmptyRange, rng.chooseIndexArrayU32Checked(1, 0));
    try std.testing.expectEqual(control.next(), engine.next());

    const empty_array_u32 = try rng.chooseIndexArrayU32Checked(0, 0);
    try std.testing.expectEqual(@as(usize, 0), empty_array_u32.len);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_indexes_u32: [0]u32 = .{};
    rng.fillChooseIndexU32(&empty_indexes_u32, 0);
    try std.testing.expectEqual(control.next(), engine.next());
    try rng.fillChooseIndexU32Checked(&empty_indexes_u32, 0);
    try std.testing.expectEqual(control.next(), engine.next());

    var empty_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty_u32 = try rng.chooseIndexU32BatchChecked(empty_u32_alloc.allocator(), 0, 0);
    defer empty_u32_alloc.allocator().free(empty_u32);
    try std.testing.expectEqual(@as(usize, 0), empty_u32.len);
    try std.testing.expect(!empty_u32_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var invalid_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, chooseIndexU32BatchCheckedFrom(&engine, invalid_u32_alloc.allocator(), 8, 0));
    try std.testing.expect(!invalid_u32_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var index_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.chooseIndexBatchChecked(index_alloc.allocator(), 8, 5));
    try std.testing.expect(index_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var index_u32_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, chooseIndexU32BatchFrom(&engine, index_u32_alloc.allocator(), 8, 5));
    try std.testing.expect(index_u32_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "collection helpers preserve direct stream shape" {
    const alea = @import("root.zig");
    const items = [_]u8{ 10, 20, 30, 40, 50 };

    inline for (.{ alea.ScalarPrng, alea.DefaultPrng }) |Engine| {
        var facade_engine = Engine.init(0x5150_c011);
        var direct_engine = Engine.init(0x5150_c011);
        const rng = Rng.init(&facade_engine);

        try std.testing.expectEqual(rng.chooseIndex(items.len), Rng.chooseIndexFrom(&direct_engine, items.len));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        try std.testing.expectEqual(try rng.chooseIndexChecked(items.len), try Rng.chooseIndexCheckedFrom(&direct_engine, items.len));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        try std.testing.expectEqual(rng.chooseIndexU32(@intCast(items.len)), Rng.chooseIndexU32From(&direct_engine, @intCast(items.len)));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        try std.testing.expectEqual(try rng.chooseIndexU32Checked(@intCast(items.len)), try Rng.chooseIndexU32CheckedFrom(&direct_engine, @intCast(items.len)));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_array = rng.chooseIndexArray(8, items.len).?;
        const direct_array = Rng.chooseIndexArrayFrom(&direct_engine, 8, items.len).?;
        try std.testing.expectEqualSlices(usize, &facade_array, &direct_array);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_array = try rng.chooseIndexArrayChecked(8, items.len);
        const direct_checked_array = try Rng.chooseIndexArrayCheckedFrom(&direct_engine, 8, items.len);
        try std.testing.expectEqualSlices(usize, &facade_checked_array, &direct_checked_array);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_array_u32 = rng.chooseIndexArrayU32(8, @intCast(items.len)).?;
        const direct_array_u32 = Rng.chooseIndexArrayU32From(&direct_engine, 8, @intCast(items.len)).?;
        try std.testing.expectEqualSlices(u32, &facade_array_u32, &direct_array_u32);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_array_u32 = try rng.chooseIndexArrayU32Checked(8, @intCast(items.len));
        const direct_checked_array_u32 = try Rng.chooseIndexArrayU32CheckedFrom(&direct_engine, 8, @intCast(items.len));
        try std.testing.expectEqualSlices(u32, &facade_checked_array_u32, &direct_checked_array_u32);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_indices = try rng.chooseIndexBatch(std.testing.allocator, 8, items.len);
        defer std.testing.allocator.free(facade_indices);
        const direct_indices = try Rng.chooseIndexBatchFrom(&direct_engine, std.testing.allocator, 8, items.len);
        defer std.testing.allocator.free(direct_indices);
        try std.testing.expectEqualSlices(usize, facade_indices, direct_indices);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_indices = try rng.chooseIndexBatchChecked(std.testing.allocator, 8, items.len);
        defer std.testing.allocator.free(facade_checked_indices);
        const direct_checked_indices = try Rng.chooseIndexBatchCheckedFrom(&direct_engine, std.testing.allocator, 8, items.len);
        defer std.testing.allocator.free(direct_checked_indices);
        try std.testing.expectEqualSlices(usize, facade_checked_indices, direct_checked_indices);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_u32_indices = try rng.chooseIndexU32Batch(std.testing.allocator, 8, @intCast(items.len));
        defer std.testing.allocator.free(facade_u32_indices);
        const direct_u32_indices = try Rng.chooseIndexU32BatchFrom(&direct_engine, std.testing.allocator, 8, @intCast(items.len));
        defer std.testing.allocator.free(direct_u32_indices);
        try std.testing.expectEqualSlices(u32, facade_u32_indices, direct_u32_indices);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_u32_indices = try rng.chooseIndexU32BatchChecked(std.testing.allocator, 8, @intCast(items.len));
        defer std.testing.allocator.free(facade_checked_u32_indices);
        const direct_checked_u32_indices = try Rng.chooseIndexU32BatchCheckedFrom(&direct_engine, std.testing.allocator, 8, @intCast(items.len));
        defer std.testing.allocator.free(direct_checked_u32_indices);
        try std.testing.expectEqualSlices(u32, facade_checked_u32_indices, direct_checked_u32_indices);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try std.testing.expectEqual(rng.choose(u8, &items), Rng.chooseFrom(&direct_engine, u8, &items));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        try std.testing.expectEqual(try rng.chooseChecked(u8, &items), try Rng.chooseCheckedFrom(&direct_engine, u8, &items));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_values: [8]u8 = undefined;
        var direct_values: [8]u8 = undefined;
        rng.fillChoose(u8, &facade_values, &items);
        Rng.fillChooseFrom(&direct_engine, u8, &direct_values, &items);
        try std.testing.expectEqualSlices(u8, &facade_values, &direct_values);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_value_array = rng.chooseValueArray(u8, 8, &items).?;
        const direct_value_array = Rng.chooseValueArrayFrom(&direct_engine, u8, 8, &items).?;
        try std.testing.expectEqualSlices(u8, &facade_value_array, &direct_value_array);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_value_array = try rng.chooseValueArrayChecked(u8, 8, &items);
        const direct_checked_value_array = try Rng.chooseValueArrayCheckedFrom(&direct_engine, u8, 8, &items);
        try std.testing.expectEqualSlices(u8, &facade_checked_value_array, &direct_checked_value_array);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_owned_values = try rng.chooseBatch(u8, std.testing.allocator, 8, &items);
        defer std.testing.allocator.free(facade_owned_values);
        const direct_owned_values = try Rng.chooseBatchFrom(&direct_engine, u8, std.testing.allocator, 8, &items);
        defer std.testing.allocator.free(direct_owned_values);
        try std.testing.expectEqualSlices(u8, facade_owned_values, direct_owned_values);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_values = try rng.chooseBatchChecked(u8, std.testing.allocator, 8, &items);
        defer std.testing.allocator.free(facade_checked_values);
        const direct_checked_values = try Rng.chooseBatchCheckedFrom(&direct_engine, u8, std.testing.allocator, 8, &items);
        defer std.testing.allocator.free(direct_checked_values);
        try std.testing.expectEqualSlices(u8, facade_checked_values, direct_checked_values);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_const_ptr = rng.chooseConstPtr(u8, &items).?;
        const direct_const_ptr = Rng.chooseConstPtrFrom(&direct_engine, u8, &items).?;
        try std.testing.expectEqual(facade_const_ptr.*, direct_const_ptr.*);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        const checked_facade_const_ptr = try rng.chooseConstPtrChecked(u8, &items);
        const checked_direct_const_ptr = try Rng.chooseConstPtrCheckedFrom(&direct_engine, u8, &items);
        try std.testing.expectEqual(checked_facade_const_ptr.*, checked_direct_const_ptr.*);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_const_ptrs: [8]*const u8 = undefined;
        var direct_const_ptrs: [8]*const u8 = undefined;
        rng.fillChooseConstPtr(u8, &facade_const_ptrs, &items);
        Rng.fillChooseConstPtrFrom(&direct_engine, u8, &direct_const_ptrs, &items);
        for (facade_const_ptrs, direct_const_ptrs) |facade_item, direct_item| {
            try std.testing.expectEqual(facade_item.*, direct_item.*);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_const_ptr_array = rng.chooseConstPtrArray(u8, 8, &items).?;
        const direct_const_ptr_array = Rng.chooseConstPtrArrayFrom(&direct_engine, u8, 8, &items).?;
        for (facade_const_ptr_array, direct_const_ptr_array) |facade_item, direct_item| {
            try std.testing.expectEqual(facade_item.*, direct_item.*);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_const_ptr_array = try rng.chooseConstPtrArrayChecked(u8, 8, &items);
        const direct_checked_const_ptr_array = try Rng.chooseConstPtrArrayCheckedFrom(&direct_engine, u8, 8, &items);
        for (facade_checked_const_ptr_array, direct_checked_const_ptr_array) |facade_item, direct_item| {
            try std.testing.expectEqual(facade_item.*, direct_item.*);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_owned_const_ptrs = try rng.chooseConstPtrBatch(u8, std.testing.allocator, 8, &items);
        defer std.testing.allocator.free(facade_owned_const_ptrs);
        const direct_owned_const_ptrs = try Rng.chooseConstPtrBatchFrom(&direct_engine, u8, std.testing.allocator, 8, &items);
        defer std.testing.allocator.free(direct_owned_const_ptrs);
        for (facade_owned_const_ptrs, direct_owned_const_ptrs) |facade_item, direct_item| {
            try std.testing.expectEqual(facade_item.*, direct_item.*);
        }
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

        var facade_mut_ptrs: [8]*u8 = undefined;
        var direct_mut_ptrs: [8]*u8 = undefined;
        rng.fillChoosePtr(u8, &facade_mut_ptrs, &facade_items);
        Rng.fillChoosePtrFrom(&direct_engine, u8, &direct_mut_ptrs, &direct_items);
        for (facade_mut_ptrs, direct_mut_ptrs) |facade_item, direct_item| {
            try std.testing.expectEqual(facade_item.*, direct_item.*);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_mut_ptr_array = rng.choosePtrArray(u8, 8, &facade_items).?;
        const direct_mut_ptr_array = Rng.choosePtrArrayFrom(&direct_engine, u8, 8, &direct_items).?;
        for (facade_mut_ptr_array, direct_mut_ptr_array) |facade_item, direct_item| {
            try std.testing.expectEqual(facade_item.*, direct_item.*);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_checked_mut_ptr_array = try rng.choosePtrArrayChecked(u8, 8, &facade_items);
        const direct_checked_mut_ptr_array = try Rng.choosePtrArrayCheckedFrom(&direct_engine, u8, 8, &direct_items);
        for (facade_checked_mut_ptr_array, direct_checked_mut_ptr_array) |facade_item, direct_item| {
            try std.testing.expectEqual(facade_item.*, direct_item.*);
        }
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const facade_owned_mut_ptrs = try rng.choosePtrBatch(u8, std.testing.allocator, 8, &facade_items);
        defer std.testing.allocator.free(facade_owned_mut_ptrs);
        const direct_owned_mut_ptrs = try Rng.choosePtrBatchFrom(&direct_engine, u8, std.testing.allocator, 8, &direct_items);
        defer std.testing.allocator.free(direct_owned_mut_ptrs);
        for (facade_owned_mut_ptrs, direct_owned_mut_ptrs) |facade_item, direct_item| {
            try std.testing.expectEqual(facade_item.*, direct_item.*);
        }
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

        try std.testing.expectEqual(rng.nextU64(), Rng.nextU64From(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
        try std.testing.expectEqual(rng.nextU32(), Rng.nextU32From(&direct_engine));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        try std.testing.expectEqual(rng.value(ValueType), valueFrom(&direct_engine, ValueType));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_bytes: [16]u8 = undefined;
        var direct_bytes: [16]u8 = undefined;
        rng.fill(u8, &facade_bytes);
        fillFrom(&direct_engine, u8, &direct_bytes);
        try std.testing.expectEqualSlices(u8, &facade_bytes, &direct_bytes);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var facade_fill_bytes: [13]u8 = undefined;
        var direct_fill_bytes: [13]u8 = undefined;
        rng.fillBytes(&facade_fill_bytes);
        fillBytesFrom(&direct_engine, &direct_fill_bytes);
        try std.testing.expectEqualSlices(u8, &facade_fill_bytes, &direct_fill_bytes);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const owned_bytes = try rng.bytesAlloc(std.testing.allocator, 16);
        defer std.testing.allocator.free(owned_bytes);
        const direct_owned_bytes = try bytesAllocFrom(&direct_engine, std.testing.allocator, 16);
        defer std.testing.allocator.free(direct_owned_bytes);
        try std.testing.expectEqualSlices(u8, owned_bytes, direct_owned_bytes);
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
        try std.testing.expectEqual(rng.sample(u8, die), sampleFrom(&direct_engine, u8, die));
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        var sample_iter = rng.sampleIter(u8, die);
        var direct_sample_iter = sampleIterFrom(&direct_engine, u8, die);
        var sample_buf: [8]u8 = undefined;
        var direct_sample_buf: [8]u8 = undefined;
        sample_iter.fill(&sample_buf);
        direct_sample_iter.fill(&direct_sample_buf);
        try std.testing.expectEqualSlices(u8, &sample_buf, &direct_sample_buf);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const owned_values = try rng.valueBatch(u16, std.testing.allocator, 8);
        defer std.testing.allocator.free(owned_values);
        const direct_owned_values = try valueBatchFrom(&direct_engine, u16, std.testing.allocator, 8);
        defer std.testing.allocator.free(direct_owned_values);
        try std.testing.expectEqualSlices(u16, owned_values, direct_owned_values);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());

        const owned_rolls = try rng.sampleBatch(u8, std.testing.allocator, die, 8);
        defer std.testing.allocator.free(owned_rolls);
        const direct_owned_rolls = try sampleBatchFrom(&direct_engine, u8, std.testing.allocator, die, 8);
        defer std.testing.allocator.free(direct_owned_rolls);
        try std.testing.expectEqualSlices(u8, owned_rolls, direct_owned_rolls);
        try std.testing.expectEqual(facade_engine.next(), direct_engine.next());
    }
}

test "owned byte buffers allocate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_ba86);
    var control = alea.ScalarPrng.init(0x5150_ba86);
    const rng = Rng.init(&engine);

    var empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.bytesAlloc(empty_alloc.allocator(), 0);
    defer empty_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!empty_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var facade_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.bytesAlloc(facade_alloc.allocator(), 16));
    try std.testing.expect(facade_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var direct_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, bytesAllocFrom(&engine, direct_alloc.allocator(), 16));
    try std.testing.expect(direct_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned value and sampler batches allocate before consuming random stream" {
    const alea = @import("root.zig");
    var engine = alea.ScalarPrng.init(0x5150_0a85);
    var control = alea.ScalarPrng.init(0x5150_0a85);
    const rng = Rng.init(&engine);
    const die = try alea.distributions.Uniform(u8).initInclusive(1, 6);

    var values_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.valueBatch(u16, values_alloc.allocator(), 8));
    try std.testing.expect(values_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var samples_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, rng.sampleBatch(u8, samples_alloc.allocator(), die, 8));
    try std.testing.expect(samples_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var direct_values_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, valueBatchFrom(&engine, u16, direct_values_alloc.allocator(), 8));
    try std.testing.expect(direct_values_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    var direct_samples_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.OutOfMemory, sampleBatchFrom(&engine, u8, direct_samples_alloc.allocator(), die, 8));
    try std.testing.expect(direct_samples_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());
}

test "owned checked values validate empty enums before consuming random stream" {
    const alea = @import("root.zig");
    const Empty = enum {};
    var engine = alea.ScalarPrng.init(0x5150_0a86);
    var control = alea.ScalarPrng.init(0x5150_0a86);
    const rng = Rng.init(&engine);

    var zero_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const empty = try rng.valueBatchChecked(Empty, zero_alloc.allocator(), 0);
    defer zero_alloc.allocator().free(empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);
    try std.testing.expect(!zero_alloc.has_induced_failure);
    try std.testing.expectEqual(control.next(), engine.next());

    if (rng.valueBatchChecked(Empty, std.testing.allocator, 1)) |unexpected| {
        defer std.testing.allocator.free(unexpected);
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }
    try std.testing.expectEqual(control.next(), engine.next());

    if (valueBatchCheckedFrom(&engine, Empty, std.testing.allocator, 1)) |unexpected| {
        defer std.testing.allocator.free(unexpected);
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }
    try std.testing.expectEqual(control.next(), engine.next());
}

test "value and sampler iterators produce unbounded samples" {
    const alea = @import("root.zig");
    var engine = alea.Xoshiro256.init(123);
    const rng = Rng.init(&engine);

    var values = rng.valueIter(u16);
    var value_hint = values.sizeHint();
    try std.testing.expectEqual(std.math.maxInt(usize), value_hint.lower);
    try std.testing.expectEqual(@as(?usize, null), value_hint.upper);
    const first = values.next().?;
    const second = values.nextValue();
    try std.testing.expect(first != second);
    value_hint = values.sizeHint();
    try std.testing.expectEqual(std.math.maxInt(usize), value_hint.lower);
    try std.testing.expectEqual(@as(?usize, null), value_hint.upper);

    var direct_values = Rng.valueIterFrom(&engine, u16);
    var direct_value_hint = direct_values.sizeHint();
    try std.testing.expectEqual(std.math.maxInt(usize), direct_value_hint.lower);
    try std.testing.expectEqual(@as(?usize, null), direct_value_hint.upper);
    const direct_first = direct_values.next().?;
    const direct_second = direct_values.nextValue();
    try std.testing.expect(direct_first != direct_second);
    direct_value_hint = direct_values.sizeHint();
    try std.testing.expectEqual(std.math.maxInt(usize), direct_value_hint.lower);
    try std.testing.expectEqual(@as(?usize, null), direct_value_hint.upper);

    var bool_iter = rng.randomIter(bool);
    const bool_hint = bool_iter.sizeHint();
    try std.testing.expectEqual(std.math.maxInt(usize), bool_hint.lower);
    try std.testing.expectEqual(@as(?usize, null), bool_hint.upper);
    var bools: [8]bool = undefined;
    bool_iter.fill(&bools);

    var direct_bool_iter = Rng.valueIterFrom(&engine, bool);
    var direct_bools: [8]bool = undefined;
    direct_bool_iter.fill(&direct_bools);

    var direct_random_iter = Rng.randomIterFrom(&engine, bool);
    const direct_random_hint = direct_random_iter.sizeHint();
    try std.testing.expectEqual(std.math.maxInt(usize), direct_random_hint.lower);
    try std.testing.expectEqual(@as(?usize, null), direct_random_hint.upper);
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
    var roll_hint = rolls.sizeHint();
    try std.testing.expectEqual(std.math.maxInt(usize), roll_hint.lower);
    try std.testing.expectEqual(@as(?usize, null), roll_hint.upper);
    var i: usize = 0;
    while (i < 16) : (i += 1) {
        const roll = rolls.next().?;
        try std.testing.expect(roll >= 1 and roll <= 6);
    }
    roll_hint = rolls.sizeHint();
    try std.testing.expectEqual(std.math.maxInt(usize), roll_hint.lower);
    try std.testing.expectEqual(@as(?usize, null), roll_hint.upper);

    var direct_rolls = Rng.sampleIterFrom(&engine, u8, die);
    var direct_roll_hint = direct_rolls.sizeHint();
    try std.testing.expectEqual(std.math.maxInt(usize), direct_roll_hint.lower);
    try std.testing.expectEqual(@as(?usize, null), direct_roll_hint.upper);
    var direct_roll_buf: [16]u8 = undefined;
    direct_rolls.fill(&direct_roll_buf);
    for (direct_roll_buf) |roll| try std.testing.expect(roll >= 1 and roll <= 6);
    direct_roll_hint = direct_rolls.sizeHint();
    try std.testing.expectEqual(std.math.maxInt(usize), direct_roll_hint.lower);
    try std.testing.expectEqual(@as(?usize, null), direct_roll_hint.upper);

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
