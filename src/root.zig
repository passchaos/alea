//! Alea is a batteries-included random toolkit for Zig 0.16.
//!
//! The public surface is intentionally split into three layers:
//! - engines for deterministic streams,
//! - `Rng` for ergonomic scalar and collection APIs,
//! - distributions for statistical sampling.

const std = @import("std");

pub const Rng = @import("rng.zig");
pub const Seed = @import("seed.zig");
pub const distributions = @import("distributions.zig");
pub const distr = distributions;
pub const seq = @import("seq.zig");
pub const ascii = @import("ascii.zig");
pub const quality = @import("quality.zig");
pub const SysRng = Rng.SysRng;
pub const SysError = SysRng.Error;
pub const WeightError = seq.WeightError;

pub const SplitMix64 = @import("engines/splitmix64.zig");
pub const Wyhash64 = @import("engines/wyhash64.zig");
pub const Alea4x64 = @import("engines/alea4x64.zig");
pub const Xoshiro256PlusPlus = @import("engines/xoshiro256plusplus.zig");
pub const Xoshiro128PlusPlus = @import("engines/xoshiro128plusplus.zig");
pub const Xoshiro256 = @import("engines/xoshiro256.zig");
pub const Pcg64 = @import("engines/pcg64.zig");
pub const ChaCha = @import("engines/chacha.zig");
pub const ChaCha8Rng = @import("engines/chacha8.zig");
pub const ChaCha20Rng = @import("engines/chacha20.zig");
pub const StepRng = @import("engines/step.zig");

pub const ChaCha12Rng = ChaCha;

pub const DefaultPrng = Xoshiro256;
pub const FastPrng = Alea4x64;
pub const ScalarPrng = Wyhash64;
pub const HashPrng = Wyhash64;
pub const ReproduciblePrng = Pcg64;
pub const SecurePrng = ChaCha;
pub const StdRng = SecurePrng;
pub const SmallRng = Xoshiro256PlusPlus;

pub const rngs = struct {
    pub const StdRng = ChaCha;
    pub const SmallRng = @import("engines/xoshiro256plusplus.zig");
    pub const SysRng = Rng.SysRng;
    pub const SysError = Rng.SysRng.Error;
    pub const ChaCha8Rng = @import("engines/chacha8.zig");
    pub const ChaCha12Rng = ChaCha;
    pub const ChaCha20Rng = @import("engines/chacha20.zig");
    pub const Xoshiro128PlusPlus = @import("engines/xoshiro128plusplus.zig");
    pub const Xoshiro256PlusPlus = @import("engines/xoshiro256plusplus.zig");
};

pub const prelude = struct {
    pub const Rng = @import("rng.zig");
    pub const Seed = @import("seed.zig");
    pub const distributions = @import("distributions.zig");
    pub const seq = @import("seq.zig");
    pub const ascii = @import("ascii.zig");
    pub const StdRng = ChaCha;
    pub const SmallRng = @import("engines/xoshiro256plusplus.zig");
    pub const SysRng = @import("rng.zig").SysRng;
    pub const SysError = @import("rng.zig").SysRng.Error;
    pub const WeightError = @import("seq.zig").WeightError;
};

pub fn default(seed: u64) DefaultPrng {
    return DefaultPrng.init(seed);
}

pub fn defaultSecure(io: std.Io) !DefaultPrng {
    return DefaultPrng.init((try Seed.secure(io)).state);
}

pub fn fast(seed: u64) FastPrng {
    return FastPrng.init(seed);
}

pub fn fastSecure(io: std.Io) !FastPrng {
    return FastPrng.init((try Seed.secure(io)).state);
}

pub fn scalar(seed: u64) ScalarPrng {
    return ScalarPrng.init(seed);
}

pub fn scalarSecure(io: std.Io) !ScalarPrng {
    return ScalarPrng.init((try Seed.secure(io)).state);
}

pub fn hash(seed: u64) HashPrng {
    return HashPrng.init(seed);
}

pub fn hashSecure(io: std.Io) !HashPrng {
    return HashPrng.init((try Seed.secure(io)).state);
}

pub fn reproducible(seed: u64) ReproduciblePrng {
    return ReproduciblePrng.init(seed);
}

pub fn reproducibleSecure(io: std.Io) !ReproduciblePrng {
    return ReproduciblePrng.init((try Seed.secure(io)).state);
}

pub fn secureFromSeed(seed: u64) SecurePrng {
    return SecurePrng.initFromU64(seed);
}

pub fn secure(io: std.Io) !SecurePrng {
    var seed_bytes: [SecurePrng.seed_length]u8 = undefined;
    try std.Io.randomSecure(io, &seed_bytes);
    return SecurePrng.init(seed_bytes);
}

pub fn secureBytes(io: std.Io, out: []u8) !void {
    try std.Io.randomSecure(io, out);
}

pub fn sysRng(io: std.Io) SysRng {
    return SysRng.init(io);
}

pub fn RngReader(comptime Source: type) type {
    return Rng.RngReader(Source);
}

pub fn rngReader(source: anytype, buffer: []u8) RngReader(@TypeOf(source)) {
    return Rng.rngReader(source, buffer);
}

pub fn stepRng(initial: u64, increment: u64) StepRng {
    return StepRng.init(initial, increment);
}

pub fn constRng(value: u64) StepRng {
    return StepRng.constant(value);
}

pub fn makeRng(comptime Engine: type, io: std.Io) !Engine {
    if (comptime Engine == SplitMix64 or Engine == Wyhash64) {
        var seed_bytes: [8]u8 = undefined;
        try std.Io.randomSecure(io, &seed_bytes);
        return Engine.fromSeedBytes(seed_bytes);
    }
    if (comptime Engine == Pcg64 or Engine == Xoshiro128PlusPlus) {
        var seed_bytes: [16]u8 = undefined;
        try std.Io.randomSecure(io, &seed_bytes);
        return Engine.fromSeedBytes(seed_bytes);
    }
    if (comptime Engine == Alea4x64 or Engine == Xoshiro256 or Engine == Xoshiro256PlusPlus) {
        var seed_bytes: [32]u8 = undefined;
        try std.Io.randomSecure(io, &seed_bytes);
        return Engine.fromSeedBytes(seed_bytes);
    }
    if (comptime Engine == ChaCha or Engine == ChaCha8Rng or Engine == ChaCha20Rng) {
        var seed_bytes: [Engine.seed_length]u8 = undefined;
        try std.Io.randomSecure(io, &seed_bytes);
        return Engine.fromSeedBytes(seed_bytes);
    }
    if (comptime Engine == StepRng) {
        var seed_bytes: [16]u8 = undefined;
        try std.Io.randomSecure(io, &seed_bytes);
        return StepRng.fromSeedBytes(seed_bytes);
    }
    @compileError("alea.makeRng supports alea's exported deterministic engines");
}

pub fn RandomIterator(comptime T: type) type {
    return struct {
        const Self = @This();

        engine: SecurePrng,

        pub fn next(self: *Self) ?T {
            return self.nextValue();
        }

        pub fn nextValue(self: *Self) T {
            const random_source = Rng.init(&self.engine);
            return random_source.value(T);
        }

        pub fn fill(self: *Self, dest: []T) void {
            for (dest) |*item| item.* = self.nextValue();
        }

        pub fn sizeHint(_: Self) struct { lower: usize, upper: ?usize } {
            return .{ .lower = std.math.maxInt(usize), .upper = null };
        }
    };
}

pub fn random(comptime T: type, io: std.Io) !T {
    return randomValue(T, io);
}

pub fn randomValue(comptime T: type, io: std.Io) !T {
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.value(T);
}

pub fn randomValueChecked(comptime T: type, io: std.Io) !T {
    if (comptime rootValueTypeHasEmptyEnum(T)) return error.EmptyRange;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.value(T);
}

pub fn randomIter(comptime T: type, io: std.Io) !RandomIterator(T) {
    return .{ .engine = try secure(io) };
}

pub fn randomRange(comptime T: type, io: std.Io, min: T, max: T) !T {
    switch (@typeInfo(T)) {
        .int => {
            std.debug.assert(min < max);
            if (rootExclusiveIntRangeHasSingleValue(T, min, max)) return min;
        },
        .float => {
            std.debug.assert(min <= max);
            if (min == max) return min;
        },
        else => @compileError("alea.randomRange supports integer and floating-point values"),
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.randomRange(T, min, max);
}

pub fn randomRangeChecked(comptime T: type, io: std.Io, min: T, max: T) !T {
    try rootValidateRangeParams(T, min, max);
    switch (@typeInfo(T)) {
        .int => if (rootExclusiveIntRangeHasSingleValue(T, min, max)) return min,
        .float => if (min == max) return min,
        else => unreachable,
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.randomRange(T, min, max);
}

pub fn randomRangeAtMost(comptime T: type, io: std.Io, min: T, max: T) !T {
    comptime if (@typeInfo(T) != .int) @compileError("alea.randomRangeAtMost supports integer values");
    std.debug.assert(min <= max);
    if (min == max) return min;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.randomRangeAtMost(T, min, max);
}

pub fn randomRangeAtMostChecked(comptime T: type, io: std.Io, min: T, max: T) !T {
    try rootValidateRangeAtMostParams(T, min, max);
    if (min == max) return min;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.randomRangeAtMost(T, min, max);
}

pub fn randomBool(io: std.Io, p: f64) !bool {
    std.debug.assert(p >= 0 and p <= 1);
    if (p == 0) return false;
    if (p == 1) return true;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.randomBool(p);
}

pub fn randomBoolChecked(io: std.Io, p: f64) !bool {
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    if (p == 0) return false;
    if (p == 1) return true;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.randomBool(p);
}

pub fn randomRatio(io: std.Io, numerator: u32, denominator: u32) !bool {
    std.debug.assert(denominator > 0 and numerator <= denominator);
    if (numerator == 0) return false;
    if (numerator == denominator) return true;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.randomRatio(numerator, denominator);
}

pub fn randomRatioChecked(io: std.Io, numerator: u32, denominator: u32) !bool {
    if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
    if (numerator == 0) return false;
    if (numerator == denominator) return true;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.randomRatio(numerator, denominator);
}

pub fn fill(comptime T: type, io: std.Io, dest: []T) !void {
    if (dest.len == 0) return;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fill(T, dest);
}

pub fn sample(comptime T: type, io: std.Io, sampler: anytype) !T {
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.sample(T, sampler);
}

pub fn fillSample(comptime T: type, io: std.Io, dest: []T, sampler: anytype) !void {
    if (dest.len == 0) return;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillSample(T, dest, sampler);
}

pub fn sampleBatch(comptime T: type, io: std.Io, allocator: std.mem.Allocator, sampler: anytype, count: usize) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fillSample(T, io, out, sampler);
    return out;
}

pub fn chooseIndex(io: std.Io, length: usize) !?usize {
    if (length == 0) return null;
    if (length == 1) return 0;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.chooseIndex(length);
}

pub fn chooseIndexChecked(io: std.Io, length: usize) !usize {
    if (length == 0) return error.EmptyRange;
    if (length == 1) return 0;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.chooseIndexChecked(length);
}

pub fn fillChooseIndex(io: std.Io, dest: []usize, length: usize) !void {
    if (dest.len == 0) return;
    if (length == 1) {
        @memset(dest, 0);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillChooseIndex(dest, length);
}

pub fn fillChooseIndexChecked(io: std.Io, dest: []usize, length: usize) !void {
    if (dest.len == 0) return;
    if (length == 0) return error.EmptyRange;
    if (length == 1) {
        @memset(dest, 0);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillChooseIndexChecked(dest, length);
}

pub fn chooseIndexBatch(io: std.Io, allocator: std.mem.Allocator, count: usize, length: usize) ![]usize {
    const out = try allocator.alloc(usize, count);
    errdefer allocator.free(out);
    try fillChooseIndex(io, out, length);
    return out;
}

pub fn chooseIndexBatchChecked(io: std.Io, allocator: std.mem.Allocator, count: usize, length: usize) ![]usize {
    if (count == 0) return allocator.alloc(usize, 0);
    const out = try allocator.alloc(usize, count);
    errdefer allocator.free(out);
    try fillChooseIndexChecked(io, out, length);
    return out;
}

pub fn chooseIndexU32(io: std.Io, length: u32) !?u32 {
    if (length == 0) return null;
    if (length == 1) return 0;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.chooseIndexU32(length);
}

pub fn chooseIndexU32Checked(io: std.Io, length: u32) !u32 {
    if (length == 0) return error.EmptyRange;
    if (length == 1) return 0;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try random_source.chooseIndexU32Checked(length);
}

pub fn fillChooseIndexU32(io: std.Io, dest: []u32, length: u32) !void {
    if (dest.len == 0) return;
    if (length == 1) {
        @memset(dest, 0);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillChooseIndexU32(dest, length);
}

pub fn fillChooseIndexU32Checked(io: std.Io, dest: []u32, length: u32) !void {
    if (dest.len == 0) return;
    if (length == 0) return error.EmptyRange;
    if (length == 1) {
        @memset(dest, 0);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillChooseIndexU32Checked(dest, length);
}

pub fn chooseIndexU32Batch(io: std.Io, allocator: std.mem.Allocator, count: usize, length: u32) ![]u32 {
    const out = try allocator.alloc(u32, count);
    errdefer allocator.free(out);
    try fillChooseIndexU32(io, out, length);
    return out;
}

pub fn chooseIndexU32BatchChecked(io: std.Io, allocator: std.mem.Allocator, count: usize, length: u32) ![]u32 {
    if (count == 0) return allocator.alloc(u32, 0);
    const out = try allocator.alloc(u32, count);
    errdefer allocator.free(out);
    try fillChooseIndexU32Checked(io, out, length);
    return out;
}

pub fn choose(comptime T: type, io: std.Io, items: []const T) !?T {
    if (items.len == 0) return null;
    if (items.len == 1) return items[0];
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.choose(T, items);
}

pub fn chooseChecked(comptime T: type, io: std.Io, items: []const T) !T {
    if (items.len == 0) return error.EmptyRange;
    if (items.len == 1) return items[0];
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.chooseChecked(T, items);
}

pub fn fillChoose(comptime T: type, io: std.Io, dest: []T, items: []const T) !void {
    if (dest.len == 0) return;
    if (items.len == 1) {
        @memset(dest, items[0]);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillChoose(T, dest, items);
}

pub fn fillChooseChecked(comptime T: type, io: std.Io, dest: []T, items: []const T) !void {
    if (dest.len == 0) return;
    if (items.len == 0) return error.EmptyRange;
    if (items.len == 1) {
        @memset(dest, items[0]);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillChooseChecked(T, dest, items);
}

pub fn chooseBatch(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fillChoose(T, io, out, items);
    return out;
}

pub fn chooseBatchChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fillChooseChecked(T, io, out, items);
    return out;
}

pub fn shuffle(comptime T: type, io: std.Io, items: []T) !void {
    if (items.len <= 1) return;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    seq.shuffle(random_source, T, items);
}

pub fn partialShuffle(comptime T: type, io: std.Io, items: []T, amount: usize) ![]T {
    const count = @min(amount, items.len);
    if (count == 0) return items[0..0];
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return seq.partialShuffle(random_source, T, items, amount);
}

pub fn partialShuffleChecked(comptime T: type, io: std.Io, items: []T, amount: usize) ![]T {
    if (amount > items.len) return error.InvalidParameter;
    return partialShuffle(T, io, items, amount);
}

pub fn PartialShuffleSplit(comptime T: type) type {
    return seq.PartialShuffleSplit(T);
}

pub fn PartialShuffleTailSplit(comptime T: type) type {
    return seq.PartialShuffleTailSplit(T);
}

pub fn partialShuffleSplit(comptime T: type, io: std.Io, items: []T, amount: usize) !PartialShuffleSplit(T) {
    const selected = try partialShuffle(T, io, items, amount);
    return .{ .selected = selected, .rest = items[selected.len..] };
}

pub fn partialShuffleSplitChecked(comptime T: type, io: std.Io, items: []T, amount: usize) !PartialShuffleSplit(T) {
    if (amount > items.len) return error.InvalidParameter;
    return partialShuffleSplit(T, io, items, amount);
}

pub fn partialShuffleTail(comptime T: type, io: std.Io, items: []T, amount: usize) ![]T {
    const count = @min(amount, items.len);
    if (count == 0) return items[items.len..];
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return seq.partialShuffleTail(random_source, T, items, amount);
}

pub fn partialShuffleTailChecked(comptime T: type, io: std.Io, items: []T, amount: usize) ![]T {
    if (amount > items.len) return error.InvalidParameter;
    return partialShuffleTail(T, io, items, amount);
}

pub fn partialShuffleTailSplit(comptime T: type, io: std.Io, items: []T, amount: usize) !PartialShuffleTailSplit(T) {
    const selected = try partialShuffleTail(T, io, items, amount);
    return .{ .selected = selected, .rest = items[0 .. items.len - selected.len] };
}

pub fn partialShuffleTailSplitChecked(comptime T: type, io: std.Io, items: []T, amount: usize) !PartialShuffleTailSplit(T) {
    if (amount > items.len) return error.InvalidParameter;
    return partialShuffleTailSplit(T, io, items, amount);
}

pub fn weightedIndex(io: std.Io, weights: []const f64) !?usize {
    switch (rootWeightedIndexStateAllowEmpty(weights) catch .random) {
        .empty => return null,
        .single => |index| return index,
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.weightedIndex(weights);
}

pub fn weightedIndexChecked(io: std.Io, weights: []const f64) !?usize {
    switch (try rootWeightedIndexStateAllowEmpty(weights)) {
        .empty => return null,
        .single => |index| return index,
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try random_source.weightedIndexChecked(weights);
}

pub fn fillWeightedIndex(io: std.Io, dest: []?usize, weights: []const f64) !void {
    if (dest.len == 0) return;
    switch (rootWeightedIndexStateAllowEmpty(weights) catch .random) {
        .empty => {
            @memset(dest, @as(?usize, null));
            return;
        },
        .single => |index| {
            @memset(dest, @as(?usize, index));
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillWeightedIndex(dest, weights);
}

pub fn fillWeightedIndexChecked(io: std.Io, dest: []usize, weights: []const f64) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexState(weights)) {
        .single => |index| {
            @memset(dest, index);
            return;
        },
        .random => {},
        .empty => unreachable,
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillWeightedIndexChecked(dest, weights);
}

pub fn weightedIndexBatch(io: std.Io, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]?usize {
    const out = try allocator.alloc(?usize, count);
    errdefer allocator.free(out);
    try fillWeightedIndex(io, out, weights);
    return out;
}

pub fn weightedIndexBatchChecked(io: std.Io, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]usize {
    if (count == 0) return allocator.alloc(usize, 0);
    const out = try allocator.alloc(usize, count);
    errdefer allocator.free(out);
    try fillWeightedIndexChecked(io, out, weights);
    return out;
}

pub fn valueBatch(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fill(T, io, out);
    return out;
}

pub fn valueBatchChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    if (comptime rootValueTypeHasEmptyEnum(T)) return error.EmptyRange;
    return valueBatch(T, io, allocator, count);
}

pub fn fillRange(comptime T: type, io: std.Io, dest: []T, min: T, max: T) !void {
    if (dest.len == 0) return;
    switch (@typeInfo(T)) {
        .int => {
            std.debug.assert(min < max);
            if (rootExclusiveIntRangeHasSingleValue(T, min, max)) {
                @memset(dest, min);
                return;
            }
        },
        .float => {
            std.debug.assert(min <= max);
            if (min == max) {
                @memset(dest, min);
                return;
            }
        },
        else => @compileError("alea.fillRange supports integer and floating-point slices"),
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillRange(T, dest, min, max);
}

pub fn fillRangeChecked(comptime T: type, io: std.Io, dest: []T, min: T, max: T) !void {
    if (dest.len == 0) return;
    try rootValidateRangeParams(T, min, max);
    switch (@typeInfo(T)) {
        .int => {
            if (rootExclusiveIntRangeHasSingleValue(T, min, max)) {
                @memset(dest, min);
                return;
            }
        },
        .float => {
            if (min == max) {
                @memset(dest, min);
                return;
            }
        },
        else => unreachable,
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillRange(T, dest, min, max);
}

pub fn rangeBatch(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, min: T, max: T) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fillRange(T, io, out, min, max);
    return out;
}

pub fn rangeBatchChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, min: T, max: T) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fillRangeChecked(T, io, out, min, max);
    return out;
}

pub fn fillRangeAtMost(comptime T: type, io: std.Io, dest: []T, min: T, max: T) !void {
    comptime if (@typeInfo(T) != .int) @compileError("alea.fillRangeAtMost supports integer slices");
    if (dest.len == 0) return;
    std.debug.assert(min <= max);
    if (min == max) {
        @memset(dest, min);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillRangeAtMost(T, dest, min, max);
}

pub fn fillRangeAtMostChecked(comptime T: type, io: std.Io, dest: []T, min: T, max: T) !void {
    if (dest.len == 0) return;
    try rootValidateRangeAtMostParams(T, min, max);
    if (min == max) {
        @memset(dest, min);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillRangeAtMost(T, dest, min, max);
}

pub fn rangeAtMostBatch(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, min: T, max: T) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fillRangeAtMost(T, io, out, min, max);
    return out;
}

pub fn rangeAtMostBatchChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, min: T, max: T) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fillRangeAtMostChecked(T, io, out, min, max);
    return out;
}

pub fn fillRandomBool(io: std.Io, dest: []bool, p: f64) !void {
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
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillChance(dest, p);
}

pub fn fillRandomBoolChecked(io: std.Io, dest: []bool, p: f64) !void {
    if (dest.len == 0) return;
    if (!(p >= 0 and p <= 1)) return error.InvalidProbability;
    if (p == 0) {
        @memset(dest, false);
        return;
    }
    if (p == 1) {
        @memset(dest, true);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillChance(dest, p);
}

pub fn randomBoolBatch(io: std.Io, allocator: std.mem.Allocator, count: usize, p: f64) ![]bool {
    const out = try allocator.alloc(bool, count);
    errdefer allocator.free(out);
    try fillRandomBool(io, out, p);
    return out;
}

pub fn randomBoolBatchChecked(io: std.Io, allocator: std.mem.Allocator, count: usize, p: f64) ![]bool {
    if (count == 0) return allocator.alloc(bool, 0);
    const out = try allocator.alloc(bool, count);
    errdefer allocator.free(out);
    try fillRandomBoolChecked(io, out, p);
    return out;
}

pub fn fillRandomRatio(io: std.Io, dest: []bool, numerator: u32, denominator: u32) !void {
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
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillRatio(dest, numerator, denominator);
}

pub fn fillRandomRatioChecked(io: std.Io, dest: []bool, numerator: u32, denominator: u32) !void {
    if (dest.len == 0) return;
    if (denominator == 0 or numerator > denominator) return error.InvalidProbability;
    if (numerator == 0) {
        @memset(dest, false);
        return;
    }
    if (numerator == denominator) {
        @memset(dest, true);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillRatio(dest, numerator, denominator);
}

pub fn randomRatioBatch(io: std.Io, allocator: std.mem.Allocator, count: usize, numerator: u32, denominator: u32) ![]bool {
    const out = try allocator.alloc(bool, count);
    errdefer allocator.free(out);
    try fillRandomRatio(io, out, numerator, denominator);
    return out;
}

pub fn randomRatioBatchChecked(io: std.Io, allocator: std.mem.Allocator, count: usize, numerator: u32, denominator: u32) ![]bool {
    if (count == 0) return allocator.alloc(bool, 0);
    const out = try allocator.alloc(bool, count);
    errdefer allocator.free(out);
    try fillRandomRatioChecked(io, out, numerator, denominator);
    return out;
}

pub fn fillOpen(comptime T: type, io: std.Io, dest: []T) !void {
    if (dest.len == 0) return;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillOpen(T, dest);
}

pub fn openBatch(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fillOpen(T, io, out);
    return out;
}

pub fn fillOpenClosed(comptime T: type, io: std.Io, dest: []T) !void {
    if (dest.len == 0) return;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillOpenClosed(T, dest);
}

pub fn openClosedBatch(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize) ![]T {
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fillOpenClosed(T, io, out);
    return out;
}

pub fn durationRangeLessThan(io: std.Io, min: std.Io.Duration, max: std.Io.Duration) !std.Io.Duration {
    std.debug.assert(min.nanoseconds < max.nanoseconds);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.durationRangeLessThan(min, max);
}

pub fn durationRangeLessThanChecked(io: std.Io, min: std.Io.Duration, max: std.Io.Duration) !std.Io.Duration {
    if (min.nanoseconds >= max.nanoseconds) return error.EmptyRange;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.durationRangeLessThan(min, max);
}

pub fn durationRangeLessThanBatch(io: std.Io, allocator: std.mem.Allocator, count: usize, min: std.Io.Duration, max: std.Io.Duration) ![]std.Io.Duration {
    const out = try allocator.alloc(std.Io.Duration, count);
    errdefer allocator.free(out);
    if (count == 0) return out;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    for (out) |*item| item.* = random_source.durationRangeLessThan(min, max);
    return out;
}

pub fn durationRangeLessThanBatchChecked(io: std.Io, allocator: std.mem.Allocator, count: usize, min: std.Io.Duration, max: std.Io.Duration) ![]std.Io.Duration {
    if (count == 0) return allocator.alloc(std.Io.Duration, 0);
    if (min.nanoseconds >= max.nanoseconds) return error.EmptyRange;
    return durationRangeLessThanBatch(io, allocator, count, min, max);
}

pub fn durationRangeAtMost(io: std.Io, min: std.Io.Duration, max: std.Io.Duration) !std.Io.Duration {
    std.debug.assert(min.nanoseconds <= max.nanoseconds);
    if (min.nanoseconds == max.nanoseconds) return min;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.durationRangeAtMost(min, max);
}

pub fn durationRangeAtMostChecked(io: std.Io, min: std.Io.Duration, max: std.Io.Duration) !std.Io.Duration {
    if (min.nanoseconds > max.nanoseconds) return error.EmptyRange;
    if (min.nanoseconds == max.nanoseconds) return min;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.durationRangeAtMost(min, max);
}

pub fn durationRangeAtMostBatch(io: std.Io, allocator: std.mem.Allocator, count: usize, min: std.Io.Duration, max: std.Io.Duration) ![]std.Io.Duration {
    const out = try allocator.alloc(std.Io.Duration, count);
    errdefer allocator.free(out);
    if (count == 0) return out;
    if (min.nanoseconds == max.nanoseconds) {
        @memset(out, min);
        return out;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    for (out) |*item| item.* = random_source.durationRangeAtMost(min, max);
    return out;
}

pub fn durationRangeAtMostBatchChecked(io: std.Io, allocator: std.mem.Allocator, count: usize, min: std.Io.Duration, max: std.Io.Duration) ![]std.Io.Duration {
    if (count == 0) return allocator.alloc(std.Io.Duration, 0);
    if (min.nanoseconds > max.nanoseconds) return error.EmptyRange;
    return durationRangeAtMostBatch(io, allocator, count, min, max);
}

pub fn char(io: std.Io) !u8 {
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return ascii.char(random_source);
}

pub fn string(allocator: std.mem.Allocator, io: std.Io, len: usize) ![]u8 {
    if (len == 0) return allocator.alloc(u8, 0);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return ascii.string(allocator, random_source, len);
}

pub fn sampleString(allocator: std.mem.Allocator, io: std.Io, len: usize) ![]u8 {
    if (len == 0) return allocator.alloc(u8, 0);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return ascii.sampleString(allocator, random_source, len);
}

pub fn appendString(allocator: std.mem.Allocator, io: std.Io, string_buffer: *std.ArrayList(u8), len: usize) !void {
    if (len == 0) return;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try ascii.appendString(allocator, random_source, string_buffer, len);
}

pub fn unicodeScalar(io: std.Io) !u21 {
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return ascii.unicodeScalar(random_source);
}

pub fn unicodeScalarRangeLessThan(io: std.Io, min: u21, less_than: u21) !u21 {
    const fixed = unicodeScalarLessThanFixed(min, less_than) catch null;
    if (fixed) |value| return value;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.unicodeScalarRangeLessThan(min, less_than);
}

pub fn unicodeScalarRangeLessThanChecked(io: std.Io, min: u21, less_than: u21) !u21 {
    const fixed = try unicodeScalarLessThanFixed(min, less_than);
    if (fixed) |value| return value;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.unicodeScalarRangeLessThanChecked(min, less_than);
}

pub fn unicodeScalarRangeAtMost(io: std.Io, min: u21, at_most: u21) !u21 {
    const fixed = unicodeScalarAtMostFixed(min, at_most) catch null;
    if (fixed) |value| return value;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.unicodeScalarRangeAtMost(min, at_most);
}

pub fn unicodeScalarRangeAtMostChecked(io: std.Io, min: u21, at_most: u21) !u21 {
    const fixed = try unicodeScalarAtMostFixed(min, at_most);
    if (fixed) |value| return value;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.unicodeScalarRangeAtMostChecked(min, at_most);
}

pub fn fillUnicodeScalar(io: std.Io, dest: []u21) !void {
    if (dest.len == 0) return;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillUnicodeScalar(dest);
}

pub fn fillUnicodeScalarRangeLessThan(io: std.Io, dest: []u21, min: u21, less_than: u21) !void {
    if (dest.len == 0) return;
    const fixed = unicodeScalarLessThanFixed(min, less_than) catch null;
    if (fixed) |value| {
        @memset(dest, value);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillUnicodeScalarRangeLessThan(dest, min, less_than);
}

pub fn fillUnicodeScalarRangeLessThanChecked(io: std.Io, dest: []u21, min: u21, less_than: u21) !void {
    if (dest.len == 0) return;
    const fixed = try unicodeScalarLessThanFixed(min, less_than);
    if (fixed) |value| {
        @memset(dest, value);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillUnicodeScalarRangeLessThanChecked(dest, min, less_than);
}

pub fn fillUnicodeScalarRangeAtMost(io: std.Io, dest: []u21, min: u21, at_most: u21) !void {
    if (dest.len == 0) return;
    const fixed = unicodeScalarAtMostFixed(min, at_most) catch null;
    if (fixed) |value| {
        @memset(dest, value);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillUnicodeScalarRangeAtMost(dest, min, at_most);
}

pub fn fillUnicodeScalarRangeAtMostChecked(io: std.Io, dest: []u21, min: u21, at_most: u21) !void {
    if (dest.len == 0) return;
    const fixed = try unicodeScalarAtMostFixed(min, at_most);
    if (fixed) |value| {
        @memset(dest, value);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillUnicodeScalarRangeAtMostChecked(dest, min, at_most);
}

pub fn unicodeScalarBatch(io: std.Io, allocator: std.mem.Allocator, count: usize) ![]u21 {
    const out = try allocator.alloc(u21, count);
    errdefer allocator.free(out);
    try fillUnicodeScalar(io, out);
    return out;
}

pub fn unicodeScalarRangeLessThanBatch(io: std.Io, allocator: std.mem.Allocator, count: usize, min: u21, less_than: u21) ![]u21 {
    const out = try allocator.alloc(u21, count);
    errdefer allocator.free(out);
    try fillUnicodeScalarRangeLessThan(io, out, min, less_than);
    return out;
}

pub fn unicodeScalarRangeLessThanBatchChecked(io: std.Io, allocator: std.mem.Allocator, count: usize, min: u21, less_than: u21) ![]u21 {
    if (count == 0) return allocator.alloc(u21, 0);
    const out = try allocator.alloc(u21, count);
    errdefer allocator.free(out);
    try fillUnicodeScalarRangeLessThanChecked(io, out, min, less_than);
    return out;
}

pub fn unicodeScalarRangeAtMostBatch(io: std.Io, allocator: std.mem.Allocator, count: usize, min: u21, at_most: u21) ![]u21 {
    const out = try allocator.alloc(u21, count);
    errdefer allocator.free(out);
    try fillUnicodeScalarRangeAtMost(io, out, min, at_most);
    return out;
}

pub fn unicodeScalarRangeAtMostBatchChecked(io: std.Io, allocator: std.mem.Allocator, count: usize, min: u21, at_most: u21) ![]u21 {
    if (count == 0) return allocator.alloc(u21, 0);
    const out = try allocator.alloc(u21, count);
    errdefer allocator.free(out);
    try fillUnicodeScalarRangeAtMostChecked(io, out, min, at_most);
    return out;
}

pub fn unicodeUtf8Capacity(len: usize) error{OutOfMemory}!usize {
    return ascii.unicodeUtf8Capacity(len);
}

pub fn unicodeUtf8Into(io: std.Io, out: []u8, len: usize) ![]u8 {
    if (len == 0) return out[0..0];
    const capacity = try ascii.unicodeUtf8Capacity(len);
    if (out.len < capacity) return error.NoSpaceLeft;
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return ascii.unicodeUtf8Into(random_source, out, len);
}

pub fn unicodeUtf8Alloc(allocator: std.mem.Allocator, io: std.Io, len: usize) ![]u8 {
    if (len == 0) return allocator.alloc(u8, 0);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return ascii.unicodeUtf8Alloc(allocator, random_source, len);
}

fn unicodeScalarAtMostFixed(min: u21, at_most: u21) !?u21 {
    if (!std.unicode.utf8ValidCodepoint(min) or !std.unicode.utf8ValidCodepoint(at_most)) return error.InvalidParameter;
    if (min > at_most) return error.EmptyRange;
    return if (min == at_most) min else null;
}

fn unicodeScalarLessThanFixed(min: u21, less_than: u21) !?u21 {
    const compressed_min = try rootUnicodeScalarToCompressed(min);
    const compressed_end = try rootUnicodeScalarExclusiveEndToCompressed(less_than);
    if (compressed_min >= compressed_end) return error.EmptyRange;
    return if (compressed_end - compressed_min == 1) rootUnicodeScalarFromCompressed(compressed_min) else null;
}

fn rootUnicodeScalarToCompressed(codepoint: u21) !u21 {
    if (!std.unicode.utf8ValidCodepoint(codepoint)) return error.InvalidParameter;
    return if (codepoint >= 0xE000) codepoint - 0x800 else codepoint;
}

fn rootUnicodeScalarExclusiveEndToCompressed(codepoint: u21) !u21 {
    if (codepoint > 0x11_0000) return error.InvalidParameter;
    if (codepoint == 0x11_0000) return 0x11_0000 - 0x800;
    return rootUnicodeScalarToCompressed(codepoint);
}

fn rootUnicodeScalarFromCompressed(compressed: u21) u21 {
    return if (compressed >= 0xD800) compressed + 0x800 else compressed;
}

const RootWeightedIndexState = union(enum) {
    empty,
    single: usize,
    random,
};

fn rootWeightedIndexStateAllowEmpty(weights: []const f64) !RootWeightedIndexState {
    var positive_index: ?usize = null;
    var positive_count: usize = 0;
    var total: f64 = 0;
    for (weights, 0..) |weight, index| {
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        total += weight;
        if (!std.math.isFinite(total)) return error.InvalidWeight;
        if (weight > 0) {
            positive_index = index;
            positive_count += 1;
        }
    }
    if (total == 0) return .empty;
    if (positive_count == 1) return .{ .single = positive_index.? };
    return .random;
}

fn rootWeightedIndexState(weights: []const f64) !RootWeightedIndexState {
    const state = try rootWeightedIndexStateAllowEmpty(weights);
    return switch (state) {
        .empty => error.EmptyRange,
        else => state,
    };
}

fn rootValueTypeHasEmptyEnum(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .@"enum" => std.enums.values(T).len == 0,
        .array => |array_info| array_info.len != 0 and rootValueTypeHasEmptyEnum(array_info.child),
        .@"struct" => |struct_info| blk: {
            if (!struct_info.is_tuple) break :blk false;
            inline for (struct_info.fields) |field| {
                if (rootValueTypeHasEmptyEnum(field.type)) break :blk true;
            }
            break :blk false;
        },
        else => false,
    };
}

fn rootValidateRangeParams(comptime T: type, min: T, max: T) Rng.Error!void {
    switch (@typeInfo(T)) {
        .int => {
            if (min >= max) return error.EmptyRange;
        },
        .float => {
            if (!(min <= max) or !std.math.isFinite(min) or !std.math.isFinite(max)) return error.EmptyRange;
        },
        else => @compileError("alea checked range helpers support integer and floating-point values"),
    }
}

fn rootValidateRangeAtMostParams(comptime T: type, min: T, max: T) Rng.Error!void {
    switch (@typeInfo(T)) {
        .int => {
            if (min > max) return error.EmptyRange;
        },
        else => @compileError("alea checked inclusive range helpers support integer values"),
    }
}

fn rootExclusiveIntRangeHasSingleValue(comptime T: type, min: T, max: T) bool {
    comptime if (@typeInfo(T) != .int) @compileError("integer range expected");
    const info = @typeInfo(T).int;
    if (info.signedness == .signed) {
        const Unsigned = std.meta.Int(.unsigned, info.bits);
        const lo: Unsigned = @bitCast(min);
        const hi: Unsigned = @bitCast(max);
        return hi -% lo == 1;
    }
    return max - min == 1;
}

pub fn rng(engine: anytype) Rng {
    return Rng.init(engine);
}

test {
    std.testing.refAllDecls(@This());
}

test "root hash constructors mirror HashPrng" {
    const seeded = hash(123);
    const direct = HashPrng.init(123);
    try std.testing.expectEqual(direct.state, seeded.state);
}

test "root Rust-discoverable rng aliases mirror concrete engines" {
    var chacha8_rng = ChaCha8Rng.seedFromU64(0x5150_c08);
    var chacha8_direct = ChaCha8Rng.initFromU64(0x5150_c08);
    try std.testing.expectEqual(chacha8_direct.next(), chacha8_rng.next());

    var chacha12_rng = ChaCha12Rng.seedFromU64(0x5150_c12);
    var chacha_rng = ChaCha.seedFromU64(0x5150_c12);
    try std.testing.expectEqual(chacha_rng.next(), chacha12_rng.next());

    var chacha20_rng = ChaCha20Rng.seedFromU64(0x5150_c20);
    var chacha20_direct = ChaCha20Rng.initFromU64(0x5150_c20);
    try std.testing.expectEqual(chacha20_direct.next(), chacha20_rng.next());

    var std_rng = StdRng.seedFromU64(0x5150_547d);
    var secure_rng = SecurePrng.seedFromU64(0x5150_547d);
    try std.testing.expectEqual(secure_rng.next(), std_rng.next());

    var small_rng = SmallRng.seedFromU64(0x5150_51a1);
    var xoshiro_rng = Xoshiro256PlusPlus.seedFromU64(0x5150_51a1);
    try std.testing.expectEqual(xoshiro_rng.next(), small_rng.next());

    var std_from_seed = StdRng.fromSeed(Seed.fromString("std alias"));
    var secure_from_seed = SecurePrng.fromSeed(Seed.fromString("std alias"));
    try std.testing.expectEqual(secure_from_seed.next(), std_from_seed.next());

    var small_from_seed = SmallRng.fromSeed(Seed.fromString("small alias"));
    var xoshiro_from_seed = Xoshiro256PlusPlus.fromSeed(Seed.fromString("small alias"));
    try std.testing.expectEqual(xoshiro_from_seed.next(), small_from_seed.next());
}

test "root rngs namespace mirrors root aliases" {
    comptime {
        std.debug.assert(rngs.StdRng == StdRng);
        std.debug.assert(rngs.SmallRng == SmallRng);
        std.debug.assert(rngs.SysRng == SysRng);
        std.debug.assert(rngs.SysError == SysError);
        std.debug.assert(rngs.ChaCha8Rng == ChaCha8Rng);
        std.debug.assert(rngs.ChaCha12Rng == ChaCha12Rng);
        std.debug.assert(rngs.ChaCha20Rng == ChaCha20Rng);
        std.debug.assert(rngs.Xoshiro128PlusPlus == Xoshiro128PlusPlus);
        std.debug.assert(rngs.Xoshiro256PlusPlus == Xoshiro256PlusPlus);
    }

    var namespace_std = rngs.StdRng.seedFromU64(0x5150_0277);
    var root_std = StdRng.seedFromU64(0x5150_0277);
    try std.testing.expectEqual(root_std.next(), namespace_std.next());

    var namespace_small = rngs.SmallRng.seedFromU64(0x5150_5277);
    var root_small = SmallRng.seedFromU64(0x5150_5277);
    try std.testing.expectEqual(root_small.next(), namespace_small.next());

    var namespace_chacha20 = rngs.ChaCha20Rng.seedFromU64(0x5150_c277);
    var root_chacha20 = ChaCha20Rng.seedFromU64(0x5150_c277);
    try std.testing.expectEqual(root_chacha20.next(), namespace_chacha20.next());
}

test "root RngReader aliases mirror Rng namespace adapter" {
    comptime std.debug.assert(RngReader(*StepRng) == Rng.RngReader(*StepRng));

    var alias_source = StepRng.init(0xff, 1);
    var direct_source = StepRng.init(0xff, 1);
    var alias_buffer: [7]u8 = undefined;
    var direct_buffer: [7]u8 = undefined;
    var alias_reader = rngReader(&alias_source, &alias_buffer);
    var direct_reader = Rng.rngReader(&direct_source, &direct_buffer);

    var alias_out: [16]u8 = undefined;
    var direct_out: [16]u8 = undefined;
    try alias_reader.readAll(&alias_out);
    try direct_reader.readAll(&direct_out);
    try std.testing.expectEqualSlices(u8, &direct_out, &alias_out);
    try std.testing.expectEqual(direct_source.next(), alias_source.next());
}

test "root prelude namespace mirrors common aliases" {
    comptime {
        std.debug.assert(prelude.Rng == Rng);
        std.debug.assert(prelude.Seed == Seed);
        std.debug.assert(prelude.distributions == distributions);
        std.debug.assert(prelude.seq == seq);
        std.debug.assert(prelude.ascii == ascii);
        std.debug.assert(prelude.StdRng == StdRng);
        std.debug.assert(prelude.SmallRng == SmallRng);
        std.debug.assert(prelude.SysRng == SysRng);
        std.debug.assert(prelude.SysError == SysError);
        std.debug.assert(prelude.WeightError == WeightError);
    }

    var prelude_std = prelude.StdRng.seedFromU64(0x5150_0280);
    var root_std = StdRng.seedFromU64(0x5150_0280);
    try std.testing.expectEqual(root_std.next(), prelude_std.next());

    var prelude_small = prelude.SmallRng.seedFromU64(0x5150_1280);
    var root_small = SmallRng.seedFromU64(0x5150_1280);
    try std.testing.expectEqual(root_small.next(), prelude_small.next());
}

test "root distr alias mirrors distributions module" {
    comptime std.debug.assert(distr == distributions);

    const alias_sampler = try distr.Uniform(u32).new(10, 20);
    const direct_sampler = try distributions.Uniform(u32).new(10, 20);
    var alias_engine = DefaultPrng.init(0x5150_d157);
    var direct_engine = DefaultPrng.init(0x5150_d157);
    try std.testing.expectEqual(direct_sampler.sampleFrom(&direct_engine), alias_sampler.sampleFrom(&alias_engine));
    try std.testing.expectEqual(direct_engine.next(), alias_engine.next());
}

test "root StepRng helpers mirror StepRng constructors" {
    var stepped = stepRng(2, 3);
    var direct = StepRng.init(2, 3);
    try std.testing.expectEqual(direct.next(), stepped.next());
    try std.testing.expectEqual(direct.next(), stepped.next());

    var constant_rng = constRng(0x5150);
    var direct_constant = StepRng.constant(0x5150);
    try std.testing.expectEqual(direct_constant.next(), constant_rng.next());
    try std.testing.expectEqual(direct_constant.next(), constant_rng.next());
}

test "root deterministic constructors have stable snapshots" {
    const seed: u64 = 0x1234_5678_9abc_def0;

    var default_engine = default(seed);
    const direct_default = DefaultPrng.init(seed);
    try std.testing.expectEqual(direct_default.state, default_engine.state);
    try std.testing.expectEqual(@as(u64, 0xe01d6fafc557f1b9), default_engine.next());

    var fast_engine = fast(seed);
    const direct_fast = FastPrng.init(seed);
    try std.testing.expectEqual(direct_fast.state, fast_engine.state);
    try std.testing.expectEqual(@as(u64, 0x99fcbd5e9a7a9f30), fast_engine.next());

    var scalar_engine = scalar(seed);
    const direct_scalar = ScalarPrng.init(seed);
    try std.testing.expectEqual(direct_scalar.state, scalar_engine.state);
    try std.testing.expectEqual(@as(u64, 0x23e3ea9cab36bd5b), scalar_engine.next());

    var hash_engine = hash(seed);
    const direct_hash = HashPrng.init(seed);
    try std.testing.expectEqual(direct_hash.state, hash_engine.state);
    try std.testing.expectEqual(@as(u64, 0x23e3ea9cab36bd5b), hash_engine.next());

    var reproducible_engine = reproducible(seed);
    const direct_reproducible = ReproduciblePrng.init(seed);
    try std.testing.expectEqual(direct_reproducible.state, reproducible_engine.state);
    try std.testing.expectEqual(direct_reproducible.inc, reproducible_engine.inc);
    try std.testing.expectEqual(@as(u64, 0x999c967e7256ef29), reproducible_engine.next());

    var secure_engine = secureFromSeed(seed);
    var direct_secure = SecurePrng.initFromU64(seed);
    var secure_bytes: [16]u8 = undefined;
    var direct_secure_bytes: [16]u8 = undefined;
    secure_engine.fill(&secure_bytes);
    direct_secure.fill(&direct_secure_bytes);
    try std.testing.expectEqualSlices(u8, &direct_secure_bytes, &secure_bytes);
    try std.testing.expectEqualSlices(u8, &.{
        0xf1, 0x1c, 0xd9, 0x81, 0xce, 0x73, 0x82, 0x95,
        0x01, 0x5f, 0xc5, 0x4d, 0x2d, 0x43, 0x88, 0xe8,
    }, &secure_bytes);

    var direct_rng_engine = scalar(seed);
    var wrapper_engine = scalar(seed);
    const wrapper = rng(&wrapper_engine);
    try std.testing.expectEqual(direct_rng_engine.next(), wrapper.next());
}

test "makeRng constructs exported engines from system entropy" {
    const io = std.Io.Threaded.global_single_threaded.io();

    var default_engine = try makeRng(DefaultPrng, io);
    _ = default_engine.next();

    var fast_engine = try makeRng(FastPrng, io);
    _ = fast_engine.next();

    var scalar_engine = try makeRng(ScalarPrng, io);
    _ = scalar_engine.next();

    var reproducible_engine = try makeRng(ReproduciblePrng, io);
    _ = reproducible_engine.next();

    var secure_engine = try makeRng(SecurePrng, io);
    _ = secure_engine.next();

    var xoshiro128_engine = try makeRng(Xoshiro128PlusPlus, io);
    _ = xoshiro128_engine.next();

    var chacha8_engine = try makeRng(ChaCha8Rng, io);
    _ = chacha8_engine.next();

    var chacha20_engine = try makeRng(ChaCha20Rng, io);
    _ = chacha20_engine.next();

    var splitmix_engine = try makeRng(SplitMix64, io);
    _ = splitmix_engine.next();

    var step_engine = try makeRng(StepRng, io);
    _ = step_engine.next();
}

test "root sysRng exposes system entropy source" {
    const io = std.Io.Threaded.global_single_threaded.io();
    const source = sysRng(io);
    var bytes: [8]u8 = undefined;
    try source.tryFillBytes(&bytes);

    var from_alias = SysRng.init(io);
    _ = try from_alias.tryNextU64();

    const sys_error: SysError = error.EntropyUnavailable;
    try std.testing.expectEqual(@as(SysRng.Error, error.EntropyUnavailable), sys_error);
}

test "root WeightError mirrors seq WeightError" {
    const weight_error: WeightError = error.InvalidWeight;
    try std.testing.expectEqual(@as(seq.WeightError, error.InvalidWeight), weight_error);
}

test "root random helpers use explicit system entropy" {
    const io = std.Io.Threaded.global_single_threaded.io();

    _ = try random(u16, io);
    _ = try randomValue(struct { u8, bool }, io);
    _ = try randomValueChecked(u8, io);

    var iter = try randomIter(u8, io);
    const hint = iter.sizeHint();
    try std.testing.expectEqual(std.math.maxInt(usize), hint.lower);
    try std.testing.expectEqual(@as(?usize, null), hint.upper);
    _ = iter.next().?;
    var iter_fill: [3]u8 = undefined;
    iter.fill(&iter_fill);

    const ranged = try randomRange(u8, io, 1, 7);
    try std.testing.expect(ranged >= 1 and ranged < 7);
    const checked_ranged = try randomRangeChecked(i16, io, -5, 5);
    try std.testing.expect(checked_ranged >= -5 and checked_ranged < 5);
    const inclusive = try randomRangeAtMost(u8, io, 1, 6);
    try std.testing.expect(inclusive >= 1 and inclusive <= 6);
    const checked_inclusive = try randomRangeAtMostChecked(i16, io, -5, 5);
    try std.testing.expect(checked_inclusive >= -5 and checked_inclusive <= 5);

    _ = try randomBool(io, 0.25);
    _ = try randomBoolChecked(io, 0.75);
    _ = try randomRatio(io, 3, 8);
    _ = try randomRatioChecked(io, 5, 8);

    var random_bytes: [8]u8 = undefined;
    try fill(u8, io, &random_bytes);
    var random_words: [4]u16 = undefined;
    try fill(u16, io, &random_words);
    const die_sampler = try distributions.Uniform(u8).initInclusive(1, 6);
    const sampled_die = try sample(u8, io, die_sampler);
    try std.testing.expect(sampled_die >= 1 and sampled_die <= 6);
    var sampled_dice: [4]u8 = undefined;
    try fillSample(u8, io, &sampled_dice, die_sampler);
    for (sampled_dice) |value| try std.testing.expect(value >= 1 and value <= 6);
    const sampled_die_batch = try sampleBatch(u8, io, std.testing.allocator, die_sampler, 4);
    defer std.testing.allocator.free(sampled_die_batch);
    for (sampled_die_batch) |value| try std.testing.expect(value >= 1 and value <= 6);
    const colors = [_]u8{ 10, 20, 30, 40 };
    const chosen_index = (try chooseIndex(io, colors.len)).?;
    try std.testing.expect(chosen_index < colors.len);
    const chosen_index_checked = try chooseIndexChecked(io, colors.len);
    try std.testing.expect(chosen_index_checked < colors.len);
    var chosen_indices: [4]usize = undefined;
    try fillChooseIndex(io, &chosen_indices, colors.len);
    for (chosen_indices) |value| try std.testing.expect(value < colors.len);
    try fillChooseIndexChecked(io, &chosen_indices, colors.len);
    for (chosen_indices) |value| try std.testing.expect(value < colors.len);
    const chosen_index_batch = try chooseIndexBatch(io, std.testing.allocator, 4, colors.len);
    defer std.testing.allocator.free(chosen_index_batch);
    for (chosen_index_batch) |value| try std.testing.expect(value < colors.len);
    const chosen_index_batch_checked = try chooseIndexBatchChecked(io, std.testing.allocator, 4, colors.len);
    defer std.testing.allocator.free(chosen_index_batch_checked);
    for (chosen_index_batch_checked) |value| try std.testing.expect(value < colors.len);
    const chosen_index_u32 = (try chooseIndexU32(io, @intCast(colors.len))).?;
    try std.testing.expect(chosen_index_u32 < colors.len);
    const chosen_index_u32_checked = try chooseIndexU32Checked(io, @intCast(colors.len));
    try std.testing.expect(chosen_index_u32_checked < colors.len);
    var chosen_indices_u32: [4]u32 = undefined;
    try fillChooseIndexU32(io, &chosen_indices_u32, @intCast(colors.len));
    for (chosen_indices_u32) |value| try std.testing.expect(value < colors.len);
    try fillChooseIndexU32Checked(io, &chosen_indices_u32, @intCast(colors.len));
    for (chosen_indices_u32) |value| try std.testing.expect(value < colors.len);
    const chosen_index_u32_batch = try chooseIndexU32Batch(io, std.testing.allocator, 4, @intCast(colors.len));
    defer std.testing.allocator.free(chosen_index_u32_batch);
    for (chosen_index_u32_batch) |value| try std.testing.expect(value < colors.len);
    const chosen_index_u32_batch_checked = try chooseIndexU32BatchChecked(io, std.testing.allocator, 4, @intCast(colors.len));
    defer std.testing.allocator.free(chosen_index_u32_batch_checked);
    for (chosen_index_u32_batch_checked) |value| try std.testing.expect(value < colors.len);
    const chosen_value = (try choose(u8, io, &colors)).?;
    try std.testing.expect(std.mem.indexOfScalar(u8, &colors, chosen_value) != null);
    const chosen_value_checked = try chooseChecked(u8, io, &colors);
    try std.testing.expect(std.mem.indexOfScalar(u8, &colors, chosen_value_checked) != null);
    var chosen_values: [4]u8 = undefined;
    try fillChoose(u8, io, &chosen_values, &colors);
    for (chosen_values) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value) != null);
    try fillChooseChecked(u8, io, &chosen_values, &colors);
    for (chosen_values) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value) != null);
    const chosen_value_batch = try chooseBatch(u8, io, std.testing.allocator, 4, &colors);
    defer std.testing.allocator.free(chosen_value_batch);
    for (chosen_value_batch) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value) != null);
    const chosen_value_batch_checked = try chooseBatchChecked(u8, io, std.testing.allocator, 4, &colors);
    defer std.testing.allocator.free(chosen_value_batch_checked);
    for (chosen_value_batch_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value) != null);
    var shuffle_values = [_]u8{ 1, 2, 3, 4 };
    try shuffle(u8, io, &shuffle_values);
    try std.testing.expectEqual(@as(usize, 4), shuffle_values.len);
    var partial_values = [_]u8{ 1, 2, 3, 4 };
    const partial = try partialShuffle(u8, io, &partial_values, 2);
    try std.testing.expectEqual(@as(usize, 2), partial.len);
    var partial_checked_values = [_]u8{ 1, 2, 3, 4 };
    const partial_checked = try partialShuffleChecked(u8, io, &partial_checked_values, 2);
    try std.testing.expectEqual(@as(usize, 2), partial_checked.len);
    var split_values = [_]u8{ 1, 2, 3, 4 };
    const split = try partialShuffleSplit(u8, io, &split_values, 2);
    try std.testing.expectEqual(@as(usize, 2), split.selected.len);
    try std.testing.expectEqual(@as(usize, 2), split.rest.len);
    var split_checked_values = [_]u8{ 1, 2, 3, 4 };
    const split_checked = try partialShuffleSplitChecked(u8, io, &split_checked_values, 2);
    try std.testing.expectEqual(@as(usize, 2), split_checked.selected.len);
    try std.testing.expectEqual(@as(usize, 2), split_checked.rest.len);
    var tail_values = [_]u8{ 1, 2, 3, 4 };
    const tail = try partialShuffleTail(u8, io, &tail_values, 2);
    try std.testing.expectEqual(@as(usize, 2), tail.len);
    var tail_checked_values = [_]u8{ 1, 2, 3, 4 };
    const tail_checked = try partialShuffleTailChecked(u8, io, &tail_checked_values, 2);
    try std.testing.expectEqual(@as(usize, 2), tail_checked.len);
    var tail_split_values = [_]u8{ 1, 2, 3, 4 };
    const tail_split = try partialShuffleTailSplit(u8, io, &tail_split_values, 2);
    try std.testing.expectEqual(@as(usize, 2), tail_split.selected.len);
    try std.testing.expectEqual(@as(usize, 2), tail_split.rest.len);
    var tail_split_checked_values = [_]u8{ 1, 2, 3, 4 };
    const tail_split_checked = try partialShuffleTailSplitChecked(u8, io, &tail_split_checked_values, 2);
    try std.testing.expectEqual(@as(usize, 2), tail_split_checked.selected.len);
    try std.testing.expectEqual(@as(usize, 2), tail_split_checked.rest.len);
    const weights = [_]f64{ 1, 2, 3, 4 };
    const weighted_index_value = (try weightedIndex(io, &weights)).?;
    try std.testing.expect(weighted_index_value < weights.len);
    const weighted_index_checked_value = (try weightedIndexChecked(io, &weights)).?;
    try std.testing.expect(weighted_index_checked_value < weights.len);
    var weighted_index_fill: [4]?usize = undefined;
    try fillWeightedIndex(io, &weighted_index_fill, &weights);
    for (weighted_index_fill) |value| try std.testing.expect(value.? < weights.len);
    var weighted_index_checked_fill: [4]usize = undefined;
    try fillWeightedIndexChecked(io, &weighted_index_checked_fill, &weights);
    for (weighted_index_checked_fill) |value| try std.testing.expect(value < weights.len);
    const weighted_index_batch_values = try weightedIndexBatch(io, std.testing.allocator, 4, &weights);
    defer std.testing.allocator.free(weighted_index_batch_values);
    for (weighted_index_batch_values) |value| try std.testing.expect(value.? < weights.len);
    const weighted_index_batch_checked_values = try weightedIndexBatchChecked(io, std.testing.allocator, 4, &weights);
    defer std.testing.allocator.free(weighted_index_batch_checked_values);
    for (weighted_index_batch_checked_values) |value| try std.testing.expect(value < weights.len);
    const owned_values = try valueBatch(u16, io, std.testing.allocator, 4);
    defer std.testing.allocator.free(owned_values);
    try std.testing.expectEqual(@as(usize, 4), owned_values.len);
    const owned_checked_values = try valueBatchChecked(u16, io, std.testing.allocator, 4);
    defer std.testing.allocator.free(owned_checked_values);
    try std.testing.expectEqual(@as(usize, 4), owned_checked_values.len);
    var random_range_values: [4]u8 = undefined;
    try fillRange(u8, io, &random_range_values, 1, 7);
    for (random_range_values) |value| try std.testing.expect(value >= 1 and value < 7);
    const owned_range_values = try rangeBatch(u8, io, std.testing.allocator, 4, 1, 7);
    defer std.testing.allocator.free(owned_range_values);
    for (owned_range_values) |value| try std.testing.expect(value >= 1 and value < 7);
    var random_checked_range_values: [4]i16 = undefined;
    try fillRangeChecked(i16, io, &random_checked_range_values, -5, 5);
    for (random_checked_range_values) |value| try std.testing.expect(value >= -5 and value < 5);
    const owned_checked_range_values = try rangeBatchChecked(i16, io, std.testing.allocator, 4, -5, 5);
    defer std.testing.allocator.free(owned_checked_range_values);
    for (owned_checked_range_values) |value| try std.testing.expect(value >= -5 and value < 5);
    var random_inclusive_values: [4]u8 = undefined;
    try fillRangeAtMost(u8, io, &random_inclusive_values, 1, 6);
    for (random_inclusive_values) |value| try std.testing.expect(value >= 1 and value <= 6);
    const owned_inclusive_values = try rangeAtMostBatch(u8, io, std.testing.allocator, 4, 1, 6);
    defer std.testing.allocator.free(owned_inclusive_values);
    for (owned_inclusive_values) |value| try std.testing.expect(value >= 1 and value <= 6);
    var random_checked_inclusive_values: [4]i16 = undefined;
    try fillRangeAtMostChecked(i16, io, &random_checked_inclusive_values, -5, 5);
    for (random_checked_inclusive_values) |value| try std.testing.expect(value >= -5 and value <= 5);
    const owned_checked_inclusive_values = try rangeAtMostBatchChecked(i16, io, std.testing.allocator, 4, -5, 5);
    defer std.testing.allocator.free(owned_checked_inclusive_values);
    for (owned_checked_inclusive_values) |value| try std.testing.expect(value >= -5 and value <= 5);
    var random_bool_values: [4]bool = undefined;
    try fillRandomBool(io, &random_bool_values, 0.25);
    try fillRandomBoolChecked(io, &random_bool_values, 0.75);
    const owned_bool_values = try randomBoolBatch(io, std.testing.allocator, 4, 0.25);
    defer std.testing.allocator.free(owned_bool_values);
    try std.testing.expectEqual(@as(usize, 4), owned_bool_values.len);
    const owned_checked_bool_values = try randomBoolBatchChecked(io, std.testing.allocator, 4, 0.75);
    defer std.testing.allocator.free(owned_checked_bool_values);
    try std.testing.expectEqual(@as(usize, 4), owned_checked_bool_values.len);
    try fillRandomRatio(io, &random_bool_values, 3, 8);
    try fillRandomRatioChecked(io, &random_bool_values, 5, 8);
    const owned_ratio_values = try randomRatioBatch(io, std.testing.allocator, 4, 3, 8);
    defer std.testing.allocator.free(owned_ratio_values);
    try std.testing.expectEqual(@as(usize, 4), owned_ratio_values.len);
    const owned_checked_ratio_values = try randomRatioBatchChecked(io, std.testing.allocator, 4, 5, 8);
    defer std.testing.allocator.free(owned_checked_ratio_values);
    try std.testing.expectEqual(@as(usize, 4), owned_checked_ratio_values.len);

    var open_values: [4]f32 = undefined;
    try fillOpen(f32, io, &open_values);
    for (open_values) |value| try std.testing.expect(value > 0 and value < 1);
    const owned_open_values = try openBatch(f64, io, std.testing.allocator, 4);
    defer std.testing.allocator.free(owned_open_values);
    for (owned_open_values) |value| try std.testing.expect(value > 0 and value < 1);
    var open_closed_values: [4]f32 = undefined;
    try fillOpenClosed(f32, io, &open_closed_values);
    for (open_closed_values) |value| try std.testing.expect(value > 0 and value <= 1);
    const owned_open_closed_values = try openClosedBatch(f64, io, std.testing.allocator, 4);
    defer std.testing.allocator.free(owned_open_closed_values);
    for (owned_open_closed_values) |value| try std.testing.expect(value > 0 and value <= 1);

    const duration_min: std.Io.Duration = .{ .nanoseconds = 10 };
    const duration_max: std.Io.Duration = .{ .nanoseconds = 20 };
    const duration_less_than = try durationRangeLessThan(io, duration_min, duration_max);
    try std.testing.expect(duration_less_than.nanoseconds >= duration_min.nanoseconds and duration_less_than.nanoseconds < duration_max.nanoseconds);
    const duration_less_than_checked = try durationRangeLessThanChecked(io, duration_min, duration_max);
    try std.testing.expect(duration_less_than_checked.nanoseconds >= duration_min.nanoseconds and duration_less_than_checked.nanoseconds < duration_max.nanoseconds);
    const duration_less_than_batch = try durationRangeLessThanBatch(io, std.testing.allocator, 4, duration_min, duration_max);
    defer std.testing.allocator.free(duration_less_than_batch);
    for (duration_less_than_batch) |value| try std.testing.expect(value.nanoseconds >= duration_min.nanoseconds and value.nanoseconds < duration_max.nanoseconds);
    const duration_less_than_batch_checked = try durationRangeLessThanBatchChecked(io, std.testing.allocator, 4, duration_min, duration_max);
    defer std.testing.allocator.free(duration_less_than_batch_checked);
    for (duration_less_than_batch_checked) |value| try std.testing.expect(value.nanoseconds >= duration_min.nanoseconds and value.nanoseconds < duration_max.nanoseconds);
    const duration_at_most = try durationRangeAtMost(io, duration_min, duration_max);
    try std.testing.expect(duration_at_most.nanoseconds >= duration_min.nanoseconds and duration_at_most.nanoseconds <= duration_max.nanoseconds);
    const duration_at_most_checked = try durationRangeAtMostChecked(io, duration_min, duration_max);
    try std.testing.expect(duration_at_most_checked.nanoseconds >= duration_min.nanoseconds and duration_at_most_checked.nanoseconds <= duration_max.nanoseconds);
    const duration_at_most_batch = try durationRangeAtMostBatch(io, std.testing.allocator, 4, duration_min, duration_max);
    defer std.testing.allocator.free(duration_at_most_batch);
    for (duration_at_most_batch) |value| try std.testing.expect(value.nanoseconds >= duration_min.nanoseconds and value.nanoseconds <= duration_max.nanoseconds);
    const duration_at_most_batch_checked = try durationRangeAtMostBatchChecked(io, std.testing.allocator, 4, duration_min, duration_max);
    defer std.testing.allocator.free(duration_at_most_batch_checked);
    for (duration_at_most_batch_checked) |value| try std.testing.expect(value.nanoseconds >= duration_min.nanoseconds and value.nanoseconds <= duration_max.nanoseconds);

    _ = try char(io);
    const token = try string(std.testing.allocator, io, 8);
    defer std.testing.allocator.free(token);
    try std.testing.expectEqual(@as(usize, 8), token.len);
    const sampled_token = try sampleString(std.testing.allocator, io, 8);
    defer std.testing.allocator.free(sampled_token);
    try std.testing.expectEqual(@as(usize, 8), sampled_token.len);
    var appended = try std.ArrayList(u8).initCapacity(std.testing.allocator, 16);
    defer appended.deinit(std.testing.allocator);
    try appendString(std.testing.allocator, io, &appended, 8);
    try std.testing.expectEqual(@as(usize, 8), appended.items.len);
    _ = try unicodeScalar(io);
    const ranged_scalar = try unicodeScalarRangeLessThan(io, 0x41, 0x5B);
    try std.testing.expect(ranged_scalar >= 0x41 and ranged_scalar < 0x5B);
    const ranged_scalar_checked = try unicodeScalarRangeLessThanChecked(io, 0x41, 0x5B);
    try std.testing.expect(ranged_scalar_checked >= 0x41 and ranged_scalar_checked < 0x5B);
    const ranged_scalar_at_most = try unicodeScalarRangeAtMost(io, 0x41, 0x5A);
    try std.testing.expect(ranged_scalar_at_most >= 0x41 and ranged_scalar_at_most <= 0x5A);
    const ranged_scalar_at_most_checked = try unicodeScalarRangeAtMostChecked(io, 0x41, 0x5A);
    try std.testing.expect(ranged_scalar_at_most_checked >= 0x41 and ranged_scalar_at_most_checked <= 0x5A);
    var scalar_fill: [4]u21 = undefined;
    try fillUnicodeScalar(io, &scalar_fill);
    for (scalar_fill) |value| try std.testing.expect(std.unicode.utf8ValidCodepoint(value));
    try fillUnicodeScalarRangeLessThan(io, &scalar_fill, 0x41, 0x5B);
    for (scalar_fill) |value| try std.testing.expect(value >= 0x41 and value < 0x5B);
    try fillUnicodeScalarRangeLessThanChecked(io, &scalar_fill, 0x41, 0x5B);
    for (scalar_fill) |value| try std.testing.expect(value >= 0x41 and value < 0x5B);
    try fillUnicodeScalarRangeAtMost(io, &scalar_fill, 0x41, 0x5A);
    for (scalar_fill) |value| try std.testing.expect(value >= 0x41 and value <= 0x5A);
    try fillUnicodeScalarRangeAtMostChecked(io, &scalar_fill, 0x41, 0x5A);
    for (scalar_fill) |value| try std.testing.expect(value >= 0x41 and value <= 0x5A);
    const scalar_batch = try unicodeScalarBatch(io, std.testing.allocator, 4);
    defer std.testing.allocator.free(scalar_batch);
    for (scalar_batch) |value| try std.testing.expect(std.unicode.utf8ValidCodepoint(value));
    const scalar_range_batch = try unicodeScalarRangeLessThanBatch(io, std.testing.allocator, 4, 0x41, 0x5B);
    defer std.testing.allocator.free(scalar_range_batch);
    for (scalar_range_batch) |value| try std.testing.expect(value >= 0x41 and value < 0x5B);
    const scalar_range_batch_checked = try unicodeScalarRangeLessThanBatchChecked(io, std.testing.allocator, 4, 0x41, 0x5B);
    defer std.testing.allocator.free(scalar_range_batch_checked);
    for (scalar_range_batch_checked) |value| try std.testing.expect(value >= 0x41 and value < 0x5B);
    const scalar_at_most_batch = try unicodeScalarRangeAtMostBatch(io, std.testing.allocator, 4, 0x41, 0x5A);
    defer std.testing.allocator.free(scalar_at_most_batch);
    for (scalar_at_most_batch) |value| try std.testing.expect(value >= 0x41 and value <= 0x5A);
    const scalar_at_most_batch_checked = try unicodeScalarRangeAtMostBatchChecked(io, std.testing.allocator, 4, 0x41, 0x5A);
    defer std.testing.allocator.free(scalar_at_most_batch_checked);
    for (scalar_at_most_batch_checked) |value| try std.testing.expect(value >= 0x41 and value <= 0x5A);
    var utf8_buffer: [16]u8 = undefined;
    const utf8_slice = try unicodeUtf8Into(io, &utf8_buffer, 4);
    try std.testing.expect(utf8_slice.len <= utf8_buffer.len);
    const unicode_text = try unicodeUtf8Alloc(std.testing.allocator, io, 4);
    defer std.testing.allocator.free(unicode_text);
    try std.testing.expect(unicode_text.len <= 16);
    try std.testing.expectEqual(@as(usize, 16), try unicodeUtf8Capacity(4));
}

test "root random helpers validate deterministic cases before entropy" {
    const failing = std.Io.failing;
    const EmptyEnum = enum {};

    if (randomValueChecked(EmptyEnum, failing)) |_| {
        return error.TestExpectedError;
    } else |err| {
        try std.testing.expectEqual(error.EmptyRange, err);
    }
    try std.testing.expectEqual(@as(u8, 3), try randomRange(u8, failing, 3, 4));
    try std.testing.expectEqual(@as(u8, 3), try randomRangeChecked(u8, failing, 3, 4));
    try std.testing.expectEqual(@as(f64, 2.5), try randomRange(f64, failing, 2.5, 2.5));
    try std.testing.expectEqual(@as(f64, 2.5), try randomRangeChecked(f64, failing, 2.5, 2.5));
    try std.testing.expectError(error.EmptyRange, randomRangeChecked(u8, failing, 3, 3));
    try std.testing.expectEqual(@as(u8, 5), try randomRangeAtMost(u8, failing, 5, 5));
    try std.testing.expectEqual(@as(u8, 5), try randomRangeAtMostChecked(u8, failing, 5, 5));
    try std.testing.expectError(error.EmptyRange, randomRangeAtMostChecked(u8, failing, 6, 5));
    try std.testing.expectEqual(false, try randomBool(failing, 0));
    try std.testing.expectEqual(false, try randomBoolChecked(failing, 0));
    try std.testing.expectEqual(true, try randomBool(failing, 1));
    try std.testing.expectEqual(true, try randomBoolChecked(failing, 1));
    try std.testing.expectError(error.InvalidProbability, randomBoolChecked(failing, 1.1));
    try std.testing.expectEqual(false, try randomRatio(failing, 0, 7));
    try std.testing.expectEqual(false, try randomRatioChecked(failing, 0, 7));
    try std.testing.expectEqual(true, try randomRatio(failing, 7, 7));
    try std.testing.expectEqual(true, try randomRatioChecked(failing, 7, 7));
    try std.testing.expectError(error.InvalidProbability, randomRatioChecked(failing, 2, 1));

    var empty: [0]u8 = .{};
    try fill(u8, failing, &empty);
    const die_sampler = try distributions.Uniform(u8).initInclusive(1, 6);
    try fillSample(u8, failing, &empty, die_sampler);
    const empty_sample_batch = try sampleBatch(u8, failing, std.testing.allocator, die_sampler, 0);
    defer std.testing.allocator.free(empty_sample_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_sample_batch.len);
    try std.testing.expectEqual(@as(?usize, null), try chooseIndex(failing, 0));
    try std.testing.expectEqual(@as(?usize, 0), try chooseIndex(failing, 1));
    try std.testing.expectEqual(@as(usize, 0), try chooseIndexChecked(failing, 1));
    try std.testing.expectError(error.EmptyRange, chooseIndexChecked(failing, 0));
    var empty_indices: [0]usize = .{};
    try fillChooseIndex(failing, &empty_indices, 0);
    try fillChooseIndexChecked(failing, &empty_indices, 0);
    var fixed_indices: [3]usize = undefined;
    try fillChooseIndex(failing, &fixed_indices, 1);
    try std.testing.expectEqualSlices(usize, &.{ 0, 0, 0 }, &fixed_indices);
    try fillChooseIndexChecked(failing, &fixed_indices, 1);
    try std.testing.expectEqualSlices(usize, &.{ 0, 0, 0 }, &fixed_indices);
    const empty_index_batch = try chooseIndexBatch(failing, std.testing.allocator, 0, 0);
    defer std.testing.allocator.free(empty_index_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_index_batch.len);
    const empty_index_batch_checked = try chooseIndexBatchChecked(failing, std.testing.allocator, 0, 0);
    defer std.testing.allocator.free(empty_index_batch_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_index_batch_checked.len);
    const fixed_index_batch = try chooseIndexBatch(failing, std.testing.allocator, 3, 1);
    defer std.testing.allocator.free(fixed_index_batch);
    try std.testing.expectEqualSlices(usize, &.{ 0, 0, 0 }, fixed_index_batch);
    const fixed_index_batch_checked = try chooseIndexBatchChecked(failing, std.testing.allocator, 3, 1);
    defer std.testing.allocator.free(fixed_index_batch_checked);
    try std.testing.expectEqualSlices(usize, &.{ 0, 0, 0 }, fixed_index_batch_checked);
    try std.testing.expectError(error.EmptyRange, chooseIndexBatchChecked(failing, std.testing.allocator, 3, 0));
    try std.testing.expectEqual(@as(?u32, null), try chooseIndexU32(failing, 0));
    try std.testing.expectEqual(@as(?u32, 0), try chooseIndexU32(failing, 1));
    try std.testing.expectEqual(@as(u32, 0), try chooseIndexU32Checked(failing, 1));
    try std.testing.expectError(error.EmptyRange, chooseIndexU32Checked(failing, 0));
    var empty_indices_u32: [0]u32 = .{};
    try fillChooseIndexU32(failing, &empty_indices_u32, 0);
    try fillChooseIndexU32Checked(failing, &empty_indices_u32, 0);
    var fixed_indices_u32: [3]u32 = undefined;
    try fillChooseIndexU32(failing, &fixed_indices_u32, 1);
    try std.testing.expectEqualSlices(u32, &.{ 0, 0, 0 }, &fixed_indices_u32);
    try fillChooseIndexU32Checked(failing, &fixed_indices_u32, 1);
    try std.testing.expectEqualSlices(u32, &.{ 0, 0, 0 }, &fixed_indices_u32);
    const empty_index_u32_batch = try chooseIndexU32Batch(failing, std.testing.allocator, 0, 0);
    defer std.testing.allocator.free(empty_index_u32_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_index_u32_batch.len);
    const empty_index_u32_batch_checked = try chooseIndexU32BatchChecked(failing, std.testing.allocator, 0, 0);
    defer std.testing.allocator.free(empty_index_u32_batch_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_index_u32_batch_checked.len);
    const fixed_index_u32_batch = try chooseIndexU32Batch(failing, std.testing.allocator, 3, 1);
    defer std.testing.allocator.free(fixed_index_u32_batch);
    try std.testing.expectEqualSlices(u32, &.{ 0, 0, 0 }, fixed_index_u32_batch);
    const fixed_index_u32_batch_checked = try chooseIndexU32BatchChecked(failing, std.testing.allocator, 3, 1);
    defer std.testing.allocator.free(fixed_index_u32_batch_checked);
    try std.testing.expectEqualSlices(u32, &.{ 0, 0, 0 }, fixed_index_u32_batch_checked);
    try std.testing.expectError(error.EmptyRange, chooseIndexU32BatchChecked(failing, std.testing.allocator, 3, 0));
    const singleton = [_]u8{42};
    try std.testing.expectEqual(@as(?u8, null), try choose(u8, failing, &.{}));
    try std.testing.expectEqual(@as(?u8, 42), try choose(u8, failing, &singleton));
    try std.testing.expectEqual(@as(u8, 42), try chooseChecked(u8, failing, &singleton));
    try std.testing.expectError(error.EmptyRange, chooseChecked(u8, failing, &.{}));
    var empty_values: [0]u8 = .{};
    try fillChoose(u8, failing, &empty_values, &.{});
    try fillChooseChecked(u8, failing, &empty_values, &.{});
    var fixed_values: [3]u8 = undefined;
    try fillChoose(u8, failing, &fixed_values, &singleton);
    try std.testing.expectEqualSlices(u8, &.{ 42, 42, 42 }, &fixed_values);
    try fillChooseChecked(u8, failing, &fixed_values, &singleton);
    try std.testing.expectEqualSlices(u8, &.{ 42, 42, 42 }, &fixed_values);
    const empty_choose_batch = try chooseBatch(u8, failing, std.testing.allocator, 0, &.{});
    defer std.testing.allocator.free(empty_choose_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_choose_batch.len);
    const empty_choose_batch_checked = try chooseBatchChecked(u8, failing, std.testing.allocator, 0, &.{});
    defer std.testing.allocator.free(empty_choose_batch_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_choose_batch_checked.len);
    const fixed_choose_batch = try chooseBatch(u8, failing, std.testing.allocator, 3, &singleton);
    defer std.testing.allocator.free(fixed_choose_batch);
    try std.testing.expectEqualSlices(u8, &.{ 42, 42, 42 }, fixed_choose_batch);
    const fixed_choose_batch_checked = try chooseBatchChecked(u8, failing, std.testing.allocator, 3, &singleton);
    defer std.testing.allocator.free(fixed_choose_batch_checked);
    try std.testing.expectEqualSlices(u8, &.{ 42, 42, 42 }, fixed_choose_batch_checked);
    try std.testing.expectError(error.EmptyRange, chooseBatchChecked(u8, failing, std.testing.allocator, 3, &.{}));
    var empty_shuffle: [0]u8 = .{};
    try shuffle(u8, failing, &empty_shuffle);
    try std.testing.expectEqual(@as(usize, 0), (try partialShuffle(u8, failing, &empty_shuffle, 3)).len);
    try std.testing.expectEqual(@as(usize, 0), (try partialShuffleChecked(u8, failing, &empty_shuffle, 0)).len);
    const empty_split = try partialShuffleSplit(u8, failing, &empty_shuffle, 3);
    try std.testing.expectEqual(@as(usize, 0), empty_split.selected.len);
    try std.testing.expectEqual(@as(usize, 0), empty_split.rest.len);
    const empty_split_checked = try partialShuffleSplitChecked(u8, failing, &empty_shuffle, 0);
    try std.testing.expectEqual(@as(usize, 0), empty_split_checked.selected.len);
    try std.testing.expectEqual(@as(usize, 0), empty_split_checked.rest.len);
    const empty_tail = try partialShuffleTail(u8, failing, &empty_shuffle, 3);
    try std.testing.expectEqual(@as(usize, 0), empty_tail.len);
    const empty_tail_checked = try partialShuffleTailChecked(u8, failing, &empty_shuffle, 0);
    try std.testing.expectEqual(@as(usize, 0), empty_tail_checked.len);
    const empty_tail_split = try partialShuffleTailSplit(u8, failing, &empty_shuffle, 3);
    try std.testing.expectEqual(@as(usize, 0), empty_tail_split.selected.len);
    try std.testing.expectEqual(@as(usize, 0), empty_tail_split.rest.len);
    const empty_tail_split_checked = try partialShuffleTailSplitChecked(u8, failing, &empty_shuffle, 0);
    try std.testing.expectEqual(@as(usize, 0), empty_tail_split_checked.selected.len);
    try std.testing.expectEqual(@as(usize, 0), empty_tail_split_checked.rest.len);
    var singleton_shuffle = [_]u8{42};
    try shuffle(u8, failing, &singleton_shuffle);
    try std.testing.expectEqualSlices(u8, &.{42}, &singleton_shuffle);
    try std.testing.expectError(error.InvalidParameter, partialShuffleChecked(u8, failing, &empty_shuffle, 1));
    try std.testing.expectError(error.InvalidParameter, partialShuffleSplitChecked(u8, failing, &empty_shuffle, 1));
    try std.testing.expectError(error.InvalidParameter, partialShuffleTailChecked(u8, failing, &empty_shuffle, 1));
    try std.testing.expectError(error.InvalidParameter, partialShuffleTailSplitChecked(u8, failing, &empty_shuffle, 1));
    const empty_weights = [_]f64{ 0, 0, 0 };
    try std.testing.expectEqual(@as(?usize, null), try weightedIndex(failing, &empty_weights));
    try std.testing.expectEqual(@as(?usize, null), try weightedIndexChecked(failing, &empty_weights));
    var empty_weighted_fill: [3]?usize = undefined;
    try fillWeightedIndex(failing, &empty_weighted_fill, &empty_weights);
    try std.testing.expectEqualSlices(?usize, &.{ null, null, null }, &empty_weighted_fill);
    const empty_weighted_batch = try weightedIndexBatch(failing, std.testing.allocator, 3, &empty_weights);
    defer std.testing.allocator.free(empty_weighted_batch);
    try std.testing.expectEqualSlices(?usize, &.{ null, null, null }, empty_weighted_batch);
    var empty_weighted_checked_fill: [0]usize = .{};
    try fillWeightedIndexChecked(failing, &empty_weighted_checked_fill, &empty_weights);
    const empty_weighted_checked_batch = try weightedIndexBatchChecked(failing, std.testing.allocator, 0, &empty_weights);
    defer std.testing.allocator.free(empty_weighted_checked_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_checked_batch.len);
    try std.testing.expectError(error.EmptyRange, weightedIndexBatchChecked(failing, std.testing.allocator, 3, &empty_weights));
    const single_weight = [_]f64{ 0, 5, 0 };
    try std.testing.expectEqual(@as(?usize, 1), try weightedIndex(failing, &single_weight));
    try std.testing.expectEqual(@as(?usize, 1), try weightedIndexChecked(failing, &single_weight));
    try fillWeightedIndex(failing, &empty_weighted_fill, &single_weight);
    try std.testing.expectEqualSlices(?usize, &.{ 1, 1, 1 }, &empty_weighted_fill);
    var single_weight_checked_fill: [3]usize = undefined;
    try fillWeightedIndexChecked(failing, &single_weight_checked_fill, &single_weight);
    try std.testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, &single_weight_checked_fill);
    const single_weight_batch = try weightedIndexBatch(failing, std.testing.allocator, 3, &single_weight);
    defer std.testing.allocator.free(single_weight_batch);
    try std.testing.expectEqualSlices(?usize, &.{ 1, 1, 1 }, single_weight_batch);
    const single_weight_checked_batch = try weightedIndexBatchChecked(failing, std.testing.allocator, 3, &single_weight);
    defer std.testing.allocator.free(single_weight_checked_batch);
    try std.testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, single_weight_checked_batch);
    try std.testing.expectError(error.InvalidWeight, weightedIndexChecked(failing, &.{ 1, std.math.nan(f64) }));
    try std.testing.expectError(error.InvalidWeight, fillWeightedIndexChecked(failing, &single_weight_checked_fill, &.{ -1, 2 }));
    try fillRange(u8, failing, &empty, 3, 4);
    try fillRangeChecked(u8, failing, &empty, 3, 3);
    try fillRangeAtMost(u8, failing, &empty, 6, 5);
    try fillRangeAtMostChecked(u8, failing, &empty, 6, 5);
    var empty_bool: [0]bool = .{};
    try fillRandomBool(failing, &empty_bool, 0);
    try fillRandomBoolChecked(failing, &empty_bool, 1.1);
    try fillRandomRatio(failing, &empty_bool, 0, 7);
    try fillRandomRatioChecked(failing, &empty_bool, 2, 1);

    const empty_owned = try valueBatch(u8, failing, std.testing.allocator, 0);
    defer std.testing.allocator.free(empty_owned);
    try std.testing.expectEqual(@as(usize, 0), empty_owned.len);
    const empty_checked_owned = try valueBatchChecked(u8, failing, std.testing.allocator, 0);
    defer std.testing.allocator.free(empty_checked_owned);
    try std.testing.expectEqual(@as(usize, 0), empty_checked_owned.len);
    const empty_bad_value_checked = try valueBatchChecked(EmptyEnum, failing, std.testing.allocator, 0);
    defer std.testing.allocator.free(empty_bad_value_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_bad_value_checked.len);
    const empty_bad_range_checked = try rangeBatchChecked(u8, failing, std.testing.allocator, 0, 3, 3);
    defer std.testing.allocator.free(empty_bad_range_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_bad_range_checked.len);
    const empty_bad_inclusive_checked = try rangeAtMostBatchChecked(u8, failing, std.testing.allocator, 0, 6, 5);
    defer std.testing.allocator.free(empty_bad_inclusive_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_bad_inclusive_checked.len);
    const empty_bad_bool_checked = try randomBoolBatchChecked(failing, std.testing.allocator, 0, 1.1);
    defer std.testing.allocator.free(empty_bad_bool_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_bad_bool_checked.len);
    const empty_bad_ratio_checked = try randomRatioBatchChecked(failing, std.testing.allocator, 0, 2, 1);
    defer std.testing.allocator.free(empty_bad_ratio_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_bad_ratio_checked.len);

    var collapsed_exclusive: [3]u8 = undefined;
    try fillRange(u8, failing, &collapsed_exclusive, 3, 4);
    try std.testing.expectEqualSlices(u8, &.{ 3, 3, 3 }, &collapsed_exclusive);
    try fillRangeChecked(u8, failing, &collapsed_exclusive, 3, 4);
    try std.testing.expectEqualSlices(u8, &.{ 3, 3, 3 }, &collapsed_exclusive);
    const collapsed_owned = try rangeBatch(u8, failing, std.testing.allocator, 3, 3, 4);
    defer std.testing.allocator.free(collapsed_owned);
    try std.testing.expectEqualSlices(u8, &.{ 3, 3, 3 }, collapsed_owned);
    const collapsed_checked_owned = try rangeBatchChecked(u8, failing, std.testing.allocator, 3, 3, 4);
    defer std.testing.allocator.free(collapsed_checked_owned);
    try std.testing.expectEqualSlices(u8, &.{ 3, 3, 3 }, collapsed_checked_owned);
    var collapsed_float: [2]f64 = undefined;
    try fillRange(f64, failing, &collapsed_float, 2.5, 2.5);
    try std.testing.expectEqualSlices(f64, &.{ 2.5, 2.5 }, &collapsed_float);
    try fillRangeChecked(f64, failing, &collapsed_float, 2.5, 2.5);
    try std.testing.expectEqualSlices(f64, &.{ 2.5, 2.5 }, &collapsed_float);
    var collapsed_inclusive: [3]u8 = undefined;
    try fillRangeAtMost(u8, failing, &collapsed_inclusive, 5, 5);
    try std.testing.expectEqualSlices(u8, &.{ 5, 5, 5 }, &collapsed_inclusive);
    try fillRangeAtMostChecked(u8, failing, &collapsed_inclusive, 5, 5);
    try std.testing.expectEqualSlices(u8, &.{ 5, 5, 5 }, &collapsed_inclusive);
    const collapsed_inclusive_owned = try rangeAtMostBatch(u8, failing, std.testing.allocator, 3, 5, 5);
    defer std.testing.allocator.free(collapsed_inclusive_owned);
    try std.testing.expectEqualSlices(u8, &.{ 5, 5, 5 }, collapsed_inclusive_owned);
    const collapsed_checked_inclusive_owned = try rangeAtMostBatchChecked(u8, failing, std.testing.allocator, 3, 5, 5);
    defer std.testing.allocator.free(collapsed_checked_inclusive_owned);
    try std.testing.expectEqualSlices(u8, &.{ 5, 5, 5 }, collapsed_checked_inclusive_owned);
    var deterministic_bool: [3]bool = undefined;
    try fillRandomBool(failing, &deterministic_bool, 0);
    try std.testing.expectEqualSlices(bool, &.{ false, false, false }, &deterministic_bool);
    try fillRandomBoolChecked(failing, &deterministic_bool, 1);
    try std.testing.expectEqualSlices(bool, &.{ true, true, true }, &deterministic_bool);
    const deterministic_bool_owned = try randomBoolBatch(failing, std.testing.allocator, 3, 0);
    defer std.testing.allocator.free(deterministic_bool_owned);
    try std.testing.expectEqualSlices(bool, &.{ false, false, false }, deterministic_bool_owned);
    const deterministic_checked_bool_owned = try randomBoolBatchChecked(failing, std.testing.allocator, 3, 1);
    defer std.testing.allocator.free(deterministic_checked_bool_owned);
    try std.testing.expectEqualSlices(bool, &.{ true, true, true }, deterministic_checked_bool_owned);
    try fillRandomRatio(failing, &deterministic_bool, 0, 7);
    try std.testing.expectEqualSlices(bool, &.{ false, false, false }, &deterministic_bool);
    try fillRandomRatioChecked(failing, &deterministic_bool, 7, 7);
    try std.testing.expectEqualSlices(bool, &.{ true, true, true }, &deterministic_bool);
    const deterministic_ratio_owned = try randomRatioBatch(failing, std.testing.allocator, 3, 0, 7);
    defer std.testing.allocator.free(deterministic_ratio_owned);
    try std.testing.expectEqualSlices(bool, &.{ false, false, false }, deterministic_ratio_owned);
    const deterministic_checked_ratio_owned = try randomRatioBatchChecked(failing, std.testing.allocator, 3, 7, 7);
    defer std.testing.allocator.free(deterministic_checked_ratio_owned);
    try std.testing.expectEqualSlices(bool, &.{ true, true, true }, deterministic_checked_ratio_owned);
    var empty_float: [0]f32 = .{};
    try fillOpen(f32, failing, &empty_float);
    try fillOpenClosed(f32, failing, &empty_float);
    const empty_open_owned = try openBatch(f32, failing, std.testing.allocator, 0);
    defer std.testing.allocator.free(empty_open_owned);
    try std.testing.expectEqual(@as(usize, 0), empty_open_owned.len);
    const empty_open_closed_owned = try openClosedBatch(f32, failing, std.testing.allocator, 0);
    defer std.testing.allocator.free(empty_open_closed_owned);
    try std.testing.expectEqual(@as(usize, 0), empty_open_closed_owned.len);
    const duration_min: std.Io.Duration = .{ .nanoseconds = 10 };
    const duration_max: std.Io.Duration = .{ .nanoseconds = 20 };
    const duration_same: std.Io.Duration = .{ .nanoseconds = 15 };
    try std.testing.expectEqual(duration_same, try durationRangeAtMost(failing, duration_same, duration_same));
    try std.testing.expectEqual(duration_same, try durationRangeAtMostChecked(failing, duration_same, duration_same));
    const duration_same_batch = try durationRangeAtMostBatch(failing, std.testing.allocator, 3, duration_same, duration_same);
    defer std.testing.allocator.free(duration_same_batch);
    try std.testing.expectEqualSlices(std.Io.Duration, &.{ duration_same, duration_same, duration_same }, duration_same_batch);
    const duration_same_batch_checked = try durationRangeAtMostBatchChecked(failing, std.testing.allocator, 3, duration_same, duration_same);
    defer std.testing.allocator.free(duration_same_batch_checked);
    try std.testing.expectEqualSlices(std.Io.Duration, &.{ duration_same, duration_same, duration_same }, duration_same_batch_checked);
    const empty_duration_less_than = try durationRangeLessThanBatch(failing, std.testing.allocator, 0, duration_min, duration_max);
    defer std.testing.allocator.free(empty_duration_less_than);
    try std.testing.expectEqual(@as(usize, 0), empty_duration_less_than.len);
    const empty_bad_duration_less_than = try durationRangeLessThanBatchChecked(failing, std.testing.allocator, 0, duration_same, duration_same);
    defer std.testing.allocator.free(empty_bad_duration_less_than);
    try std.testing.expectEqual(@as(usize, 0), empty_bad_duration_less_than.len);
    const empty_duration_at_most = try durationRangeAtMostBatch(failing, std.testing.allocator, 0, duration_min, duration_max);
    defer std.testing.allocator.free(empty_duration_at_most);
    try std.testing.expectEqual(@as(usize, 0), empty_duration_at_most.len);
    const empty_bad_duration_at_most = try durationRangeAtMostBatchChecked(failing, std.testing.allocator, 0, duration_max, duration_min);
    defer std.testing.allocator.free(empty_bad_duration_at_most);
    try std.testing.expectEqual(@as(usize, 0), empty_bad_duration_at_most.len);
    try std.testing.expectError(error.EmptyRange, durationRangeLessThanChecked(failing, duration_same, duration_same));
    try std.testing.expectError(error.EmptyRange, durationRangeAtMostChecked(failing, duration_max, duration_min));
    const empty_string = try string(std.testing.allocator, failing, 0);
    defer std.testing.allocator.free(empty_string);
    try std.testing.expectEqual(@as(usize, 0), empty_string.len);
    const empty_sample_string = try sampleString(std.testing.allocator, failing, 0);
    defer std.testing.allocator.free(empty_sample_string);
    try std.testing.expectEqual(@as(usize, 0), empty_sample_string.len);
    var unchanged = try std.ArrayList(u8).initCapacity(std.testing.allocator, 0);
    defer unchanged.deinit(std.testing.allocator);
    try appendString(std.testing.allocator, failing, &unchanged, 0);
    try std.testing.expectEqual(@as(usize, 0), unchanged.items.len);
    var no_utf8: [0]u8 = .{};
    try std.testing.expectEqualSlices(u8, "", try unicodeUtf8Into(failing, &no_utf8, 0));
    const empty_unicode_text = try unicodeUtf8Alloc(std.testing.allocator, failing, 0);
    defer std.testing.allocator.free(empty_unicode_text);
    try std.testing.expectEqual(@as(usize, 0), empty_unicode_text.len);
    try std.testing.expectError(error.NoSpaceLeft, unicodeUtf8Into(failing, &no_utf8, 1));
    try std.testing.expectEqual(@as(u21, 0x41), try unicodeScalarRangeAtMost(failing, 0x41, 0x41));
    try std.testing.expectEqual(@as(u21, 0x41), try unicodeScalarRangeAtMostChecked(failing, 0x41, 0x41));
    try std.testing.expectEqual(@as(u21, 0x41), try unicodeScalarRangeLessThan(failing, 0x41, 0x42));
    try std.testing.expectEqual(@as(u21, 0x41), try unicodeScalarRangeLessThanChecked(failing, 0x41, 0x42));
    var empty_scalars: [0]u21 = .{};
    try fillUnicodeScalar(failing, &empty_scalars);
    try fillUnicodeScalarRangeLessThan(failing, &empty_scalars, 0x41, 0x41);
    try fillUnicodeScalarRangeLessThanChecked(failing, &empty_scalars, 0x41, 0x41);
    try fillUnicodeScalarRangeAtMost(failing, &empty_scalars, 0x42, 0x41);
    try fillUnicodeScalarRangeAtMostChecked(failing, &empty_scalars, 0x42, 0x41);
    var fixed_scalars: [3]u21 = undefined;
    try fillUnicodeScalarRangeLessThan(failing, &fixed_scalars, 0x41, 0x42);
    try std.testing.expectEqualSlices(u21, &.{ 0x41, 0x41, 0x41 }, &fixed_scalars);
    try fillUnicodeScalarRangeLessThanChecked(failing, &fixed_scalars, 0x41, 0x42);
    try std.testing.expectEqualSlices(u21, &.{ 0x41, 0x41, 0x41 }, &fixed_scalars);
    try fillUnicodeScalarRangeAtMost(failing, &fixed_scalars, 0x41, 0x41);
    try std.testing.expectEqualSlices(u21, &.{ 0x41, 0x41, 0x41 }, &fixed_scalars);
    try fillUnicodeScalarRangeAtMostChecked(failing, &fixed_scalars, 0x41, 0x41);
    try std.testing.expectEqualSlices(u21, &.{ 0x41, 0x41, 0x41 }, &fixed_scalars);
    const empty_scalar_batch = try unicodeScalarBatch(failing, std.testing.allocator, 0);
    defer std.testing.allocator.free(empty_scalar_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_scalar_batch.len);
    const empty_bad_scalar_less_than = try unicodeScalarRangeLessThanBatchChecked(failing, std.testing.allocator, 0, 0x41, 0x41);
    defer std.testing.allocator.free(empty_bad_scalar_less_than);
    try std.testing.expectEqual(@as(usize, 0), empty_bad_scalar_less_than.len);
    const empty_bad_scalar_at_most = try unicodeScalarRangeAtMostBatchChecked(failing, std.testing.allocator, 0, 0x42, 0x41);
    defer std.testing.allocator.free(empty_bad_scalar_at_most);
    try std.testing.expectEqual(@as(usize, 0), empty_bad_scalar_at_most.len);
    const fixed_scalar_less_than_batch = try unicodeScalarRangeLessThanBatch(failing, std.testing.allocator, 3, 0x41, 0x42);
    defer std.testing.allocator.free(fixed_scalar_less_than_batch);
    try std.testing.expectEqualSlices(u21, &.{ 0x41, 0x41, 0x41 }, fixed_scalar_less_than_batch);
    const fixed_scalar_less_than_batch_checked = try unicodeScalarRangeLessThanBatchChecked(failing, std.testing.allocator, 3, 0x41, 0x42);
    defer std.testing.allocator.free(fixed_scalar_less_than_batch_checked);
    try std.testing.expectEqualSlices(u21, &.{ 0x41, 0x41, 0x41 }, fixed_scalar_less_than_batch_checked);
    const fixed_scalar_batch = try unicodeScalarRangeAtMostBatch(failing, std.testing.allocator, 3, 0x41, 0x41);
    defer std.testing.allocator.free(fixed_scalar_batch);
    try std.testing.expectEqualSlices(u21, &.{ 0x41, 0x41, 0x41 }, fixed_scalar_batch);
    const fixed_scalar_batch_checked = try unicodeScalarRangeAtMostBatchChecked(failing, std.testing.allocator, 3, 0x41, 0x41);
    defer std.testing.allocator.free(fixed_scalar_batch_checked);
    try std.testing.expectEqualSlices(u21, &.{ 0x41, 0x41, 0x41 }, fixed_scalar_batch_checked);
    try std.testing.expectError(error.EmptyRange, unicodeScalarRangeLessThanChecked(failing, 0x41, 0x41));
    try std.testing.expectError(error.EmptyRange, unicodeScalarRangeAtMostChecked(failing, 0x42, 0x41));
    try std.testing.expectError(error.InvalidParameter, unicodeScalarRangeAtMostChecked(failing, 0xD800, 0xD800));
    try std.testing.expectError(error.EmptyRange, fillUnicodeScalarRangeLessThanChecked(failing, &fixed_scalars, 0x41, 0x41));
    try std.testing.expectError(error.EmptyRange, fillUnicodeScalarRangeAtMostChecked(failing, &fixed_scalars, 0x42, 0x41));
    try std.testing.expectError(error.EmptyRange, fillRangeChecked(u8, failing, &collapsed_exclusive, 3, 3));
    try std.testing.expectError(error.EmptyRange, fillRangeAtMostChecked(u8, failing, &collapsed_inclusive, 6, 5));
    try std.testing.expectError(error.InvalidProbability, fillRandomBoolChecked(failing, &deterministic_bool, 1.1));
    try std.testing.expectError(error.InvalidProbability, fillRandomRatioChecked(failing, &deterministic_bool, 2, 1));

    try std.testing.expectError(error.EntropyUnavailable, randomValue(u8, failing));
    try std.testing.expectError(error.EntropyUnavailable, randomRangeChecked(u8, failing, 3, 5));
    try std.testing.expectError(error.EntropyUnavailable, randomIter(u8, failing));
    var byte: [1]u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fill(u8, failing, &byte));
    try std.testing.expectError(error.EntropyUnavailable, sample(u8, failing, die_sampler));
    try std.testing.expectError(error.EntropyUnavailable, fillSample(u8, failing, &byte, die_sampler));
    try std.testing.expectError(error.EntropyUnavailable, sampleBatch(u8, failing, std.testing.allocator, die_sampler, 1));
    try std.testing.expectError(error.EntropyUnavailable, chooseIndex(failing, 2));
    var one_index: [1]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseIndex(failing, &one_index, 2));
    try std.testing.expectError(error.EntropyUnavailable, chooseIndexBatch(failing, std.testing.allocator, 1, 2));
    try std.testing.expectError(error.EntropyUnavailable, chooseIndexU32(failing, 2));
    var one_index_u32: [1]u32 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseIndexU32(failing, &one_index_u32, 2));
    try std.testing.expectError(error.EntropyUnavailable, chooseIndexU32Batch(failing, std.testing.allocator, 1, 2));
    try std.testing.expectError(error.EntropyUnavailable, choose(u8, failing, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, fillChoose(u8, failing, &byte, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseBatch(u8, failing, std.testing.allocator, 1, &.{ 1, 2 }));
    var shuffle_pair = [_]u8{ 1, 2 };
    try std.testing.expectError(error.EntropyUnavailable, shuffle(u8, failing, &shuffle_pair));
    try std.testing.expectError(error.EntropyUnavailable, partialShuffle(u8, failing, &shuffle_pair, 1));
    try std.testing.expectError(error.EntropyUnavailable, partialShuffleSplit(u8, failing, &shuffle_pair, 1));
    try std.testing.expectError(error.EntropyUnavailable, partialShuffleTail(u8, failing, &shuffle_pair, 1));
    try std.testing.expectError(error.EntropyUnavailable, partialShuffleTailSplit(u8, failing, &shuffle_pair, 1));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndex(failing, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexChecked(failing, &.{ 1, 2 }));
    var weighted_one: [1]?usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndex(failing, &weighted_one, &.{ 1, 2 }));
    var weighted_checked_one: [1]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndexChecked(failing, &weighted_checked_one, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexBatch(failing, std.testing.allocator, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexBatchChecked(failing, std.testing.allocator, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, valueBatch(u8, failing, std.testing.allocator, 1));
    try std.testing.expectError(error.EntropyUnavailable, fillRange(u8, failing, &byte, 3, 5));
    try std.testing.expectError(error.EntropyUnavailable, rangeBatch(u8, failing, std.testing.allocator, 1, 3, 5));
    try std.testing.expectError(error.EntropyUnavailable, fillRangeAtMost(u8, failing, &byte, 3, 5));
    try std.testing.expectError(error.EntropyUnavailable, rangeAtMostBatch(u8, failing, std.testing.allocator, 1, 3, 5));
    try std.testing.expectError(error.EntropyUnavailable, fillRandomBool(failing, &deterministic_bool, 0.5));
    try std.testing.expectError(error.EntropyUnavailable, randomBoolBatch(failing, std.testing.allocator, 1, 0.5));
    try std.testing.expectError(error.EntropyUnavailable, fillRandomRatio(failing, &deterministic_bool, 1, 2));
    try std.testing.expectError(error.EntropyUnavailable, randomRatioBatch(failing, std.testing.allocator, 1, 1, 2));
    var open_one: [1]f32 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillOpen(f32, failing, &open_one));
    try std.testing.expectError(error.EntropyUnavailable, openBatch(f32, failing, std.testing.allocator, 1));
    try std.testing.expectError(error.EntropyUnavailable, fillOpenClosed(f32, failing, &open_one));
    try std.testing.expectError(error.EntropyUnavailable, openClosedBatch(f32, failing, std.testing.allocator, 1));
    try std.testing.expectError(error.EntropyUnavailable, durationRangeLessThan(failing, duration_min, duration_max));
    try std.testing.expectError(error.EntropyUnavailable, durationRangeLessThanBatch(failing, std.testing.allocator, 1, duration_min, duration_max));
    try std.testing.expectError(error.EntropyUnavailable, durationRangeAtMost(failing, duration_min, duration_max));
    try std.testing.expectError(error.EntropyUnavailable, durationRangeAtMostBatch(failing, std.testing.allocator, 1, duration_min, duration_max));
    try std.testing.expectError(error.EntropyUnavailable, char(failing));
    try std.testing.expectError(error.EntropyUnavailable, string(std.testing.allocator, failing, 1));
    try std.testing.expectError(error.EntropyUnavailable, sampleString(std.testing.allocator, failing, 1));
    try std.testing.expectError(error.EntropyUnavailable, appendString(std.testing.allocator, failing, &unchanged, 1));
    try std.testing.expectError(error.EntropyUnavailable, unicodeScalar(failing));
    try std.testing.expectError(error.EntropyUnavailable, unicodeScalarRangeLessThan(failing, 0x41, 0x5B));
    try std.testing.expectError(error.EntropyUnavailable, unicodeScalarRangeAtMost(failing, 0x41, 0x5A));
    var scalar_one: [1]u21 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillUnicodeScalar(failing, &scalar_one));
    try std.testing.expectError(error.EntropyUnavailable, fillUnicodeScalarRangeLessThan(failing, &scalar_one, 0x41, 0x5B));
    try std.testing.expectError(error.EntropyUnavailable, fillUnicodeScalarRangeAtMost(failing, &scalar_one, 0x41, 0x5A));
    try std.testing.expectError(error.EntropyUnavailable, unicodeScalarBatch(failing, std.testing.allocator, 1));
    try std.testing.expectError(error.EntropyUnavailable, unicodeScalarRangeLessThanBatch(failing, std.testing.allocator, 1, 0x41, 0x5B));
    try std.testing.expectError(error.EntropyUnavailable, unicodeScalarRangeAtMostBatch(failing, std.testing.allocator, 1, 0x41, 0x5A));
    var utf8_buffer: [4]u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, unicodeUtf8Into(failing, &utf8_buffer, 1));
    try std.testing.expectError(error.EntropyUnavailable, unicodeUtf8Alloc(std.testing.allocator, failing, 1));
}

fn engineFromSeed(comptime Engine: type, seed: u64) Engine {
    if (comptime Engine == ChaCha or Engine == ChaCha8Rng or Engine == ChaCha20Rng) return Engine.initFromU64(seed);
    return Engine.init(seed);
}

fn expectFullEngineRawAliases(comptime Engine: type, seed: u64) !void {
    var direct_u64 = engineFromSeed(Engine, seed);
    var alias_u64 = engineFromSeed(Engine, seed);
    try std.testing.expectEqual(direct_u64.next(), alias_u64.nextU64());

    var direct_try_u64 = engineFromSeed(Engine, seed);
    var alias_try_u64 = engineFromSeed(Engine, seed);
    try std.testing.expectEqual(direct_try_u64.next(), try alias_try_u64.tryNextU64());

    var direct_u32 = engineFromSeed(Engine, seed);
    var alias_u32 = engineFromSeed(Engine, seed);
    try std.testing.expectEqual(@as(u32, @truncate(direct_u32.next() >> 32)), alias_u32.nextU32());

    var direct_try_u32 = engineFromSeed(Engine, seed);
    var alias_try_u32 = engineFromSeed(Engine, seed);
    try std.testing.expectEqual(@as(u32, @truncate(direct_try_u32.next() >> 32)), try alias_try_u32.tryNextU32());

    var direct_fill = engineFromSeed(Engine, seed);
    var alias_fill = engineFromSeed(Engine, seed);
    var direct_bytes: [23]u8 = undefined;
    var alias_bytes: [23]u8 = undefined;
    direct_fill.fill(&direct_bytes);
    alias_fill.fillBytes(&alias_bytes);
    try std.testing.expectEqualSlices(u8, &direct_bytes, &alias_bytes);

    var direct_try_fill = engineFromSeed(Engine, seed);
    var alias_try_fill = engineFromSeed(Engine, seed);
    var direct_try_bytes: [23]u8 = undefined;
    var alias_try_bytes: [23]u8 = undefined;
    direct_try_fill.fill(&direct_try_bytes);
    try alias_try_fill.tryFillBytes(&alias_try_bytes);
    try std.testing.expectEqualSlices(u8, &direct_try_bytes, &alias_try_bytes);
}

test "engine raw aliases preserve stream shape" {
    const seed: u64 = 0x5150_f00d_dead_beef;

    inline for (.{ Alea4x64, Wyhash64, Xoshiro256, Xoshiro256PlusPlus, Pcg64, ChaCha, ChaCha8Rng, ChaCha20Rng }) |Engine| {
        try expectFullEngineRawAliases(Engine, seed);
    }

    var splitmix_direct_u64 = SplitMix64.init(seed);
    var splitmix_alias_u64 = SplitMix64.init(seed);
    try std.testing.expectEqual(splitmix_direct_u64.next(), splitmix_alias_u64.nextU64());

    var splitmix_direct_try_u64 = SplitMix64.init(seed);
    var splitmix_alias_try_u64 = SplitMix64.init(seed);
    try std.testing.expectEqual(splitmix_direct_try_u64.next(), try splitmix_alias_try_u64.tryNextU64());

    var splitmix_direct_u32 = SplitMix64.init(seed);
    var splitmix_alias_u32 = SplitMix64.init(seed);
    try std.testing.expectEqual(@as(u32, @truncate(splitmix_direct_u32.next() >> 32)), splitmix_alias_u32.nextU32());

    var splitmix_direct_try_u32 = SplitMix64.init(seed);
    var splitmix_alias_try_u32 = SplitMix64.init(seed);
    try std.testing.expectEqual(@as(u32, @truncate(splitmix_direct_try_u32.next() >> 32)), try splitmix_alias_try_u32.tryNextU32());

    var xoshiro128_direct_u64 = Xoshiro128PlusPlus.init(seed);
    var xoshiro128_alias_u64 = Xoshiro128PlusPlus.init(seed);
    try std.testing.expectEqual(xoshiro128_direct_u64.next(), xoshiro128_alias_u64.nextU64());

    var xoshiro128_direct_try_u64 = Xoshiro128PlusPlus.init(seed);
    var xoshiro128_alias_try_u64 = Xoshiro128PlusPlus.init(seed);
    try std.testing.expectEqual(xoshiro128_direct_try_u64.next(), try xoshiro128_alias_try_u64.tryNextU64());

    var xoshiro128_direct_u32 = Xoshiro128PlusPlus.init(seed);
    var xoshiro128_alias_u32 = Xoshiro128PlusPlus.init(seed);
    try std.testing.expectEqual(xoshiro128_direct_u32.nextU32(), xoshiro128_alias_u32.nextU32());

    var xoshiro128_direct_try_u32 = Xoshiro128PlusPlus.init(seed);
    var xoshiro128_alias_try_u32 = Xoshiro128PlusPlus.init(seed);
    try std.testing.expectEqual(xoshiro128_direct_try_u32.nextU32(), try xoshiro128_alias_try_u32.tryNextU32());

    var xoshiro128_direct_fill = Xoshiro128PlusPlus.init(seed);
    var xoshiro128_alias_fill = Xoshiro128PlusPlus.init(seed);
    var xoshiro128_direct_bytes: [23]u8 = undefined;
    var xoshiro128_alias_bytes: [23]u8 = undefined;
    xoshiro128_direct_fill.fill(&xoshiro128_direct_bytes);
    xoshiro128_alias_fill.fillBytes(&xoshiro128_alias_bytes);
    try std.testing.expectEqualSlices(u8, &xoshiro128_direct_bytes, &xoshiro128_alias_bytes);

    var xoshiro128_direct_try_fill = Xoshiro128PlusPlus.init(seed);
    var xoshiro128_alias_try_fill = Xoshiro128PlusPlus.init(seed);
    var xoshiro128_direct_try_bytes: [23]u8 = undefined;
    var xoshiro128_alias_try_bytes: [23]u8 = undefined;
    xoshiro128_direct_try_fill.fill(&xoshiro128_direct_try_bytes);
    try xoshiro128_alias_try_fill.tryFillBytes(&xoshiro128_alias_try_bytes);
    try std.testing.expectEqualSlices(u8, &xoshiro128_direct_try_bytes, &xoshiro128_alias_try_bytes);
}

fn expectEngineSeedFromU64Alias(comptime Engine: type, seed: u64) !void {
    var direct = engineFromSeed(Engine, seed);
    var alias = Engine.seedFromU64(seed);
    try std.testing.expectEqual(direct.next(), alias.next());
}

test "engine seedFromU64 aliases mirror constructors" {
    const seed: u64 = 0x5150_5eed_1234_5678;

    inline for (.{ SplitMix64, Alea4x64, Wyhash64, Xoshiro256, Xoshiro256PlusPlus, Xoshiro128PlusPlus, Pcg64, ChaCha, ChaCha8Rng, ChaCha20Rng }) |Engine| {
        try expectEngineSeedFromU64Alias(Engine, seed);
    }
}

fn expectEngineFromSeedAlias(comptime Engine: type, seed_value: u64) !void {
    const seed = Seed.init(seed_value);
    var direct = engineFromSeed(Engine, seed_value);
    var alias = Engine.fromSeed(seed);
    try std.testing.expectEqual(direct.next(), alias.next());
}

test "engine fromSeed aliases mirror Seed constructors" {
    const seed: u64 = 0x5150_5eed_f00d_cafe;

    inline for (.{ SplitMix64, Alea4x64, Wyhash64, Xoshiro256, Xoshiro256PlusPlus, Xoshiro128PlusPlus, Pcg64, ChaCha, ChaCha8Rng, ChaCha20Rng }) |Engine| {
        try expectEngineFromSeedAlias(Engine, seed);
    }
}

fn expectEngineFromSeedBytesAlias(comptime Engine: type, seed: anytype) !void {
    var direct = engineFromSeedBytesReference(Engine, seed);
    var alias = Engine.fromSeedBytes(seed);
    try std.testing.expectEqual(direct.next(), alias.next());
}

fn engineFromSeedBytesReference(comptime Engine: type, seed: anytype) Engine {
    if (comptime Engine == SplitMix64) {
        return SplitMix64.init(seedWord(seed, 0));
    }
    if (comptime Engine == Wyhash64) {
        return Wyhash64.fromState(seedWord(seed, 0));
    }
    if (comptime Engine == Alea4x64) {
        return .{ .state = .{ seedWord(seed, 0), seedWord(seed, 1), seedWord(seed, 2), seedWord(seed, 3) } };
    }
    if (comptime Engine == Xoshiro256) {
        const out: Xoshiro256 = .{ .state = .{ seedWord(seed, 0), seedWord(seed, 1), seedWord(seed, 2), seedWord(seed, 3) } };
        if (xoshiro256StateIsZero(out.state)) return Xoshiro256.init(0);
        return out;
    }
    if (comptime Engine == Xoshiro256PlusPlus) {
        const out: Xoshiro256PlusPlus = .{ .state = .{ seedWord(seed, 0), seedWord(seed, 1), seedWord(seed, 2), seedWord(seed, 3) } };
        if (xoshiro256StateIsZero(out.state)) return Xoshiro256PlusPlus.init(0);
        return out;
    }
    if (comptime Engine == Xoshiro128PlusPlus) {
        const out: Xoshiro128PlusPlus = .{ .state = .{ seedWord32(seed, 0), seedWord32(seed, 1), seedWord32(seed, 2), seedWord32(seed, 3) } };
        if (xoshiro128StateIsZero(out.state)) return Xoshiro128PlusPlus.init(0);
        return out;
    }
    if (comptime Engine == Pcg64) {
        return Pcg64.initTwo(seedWord(seed, 0), seedWord(seed, 1));
    }
    if (comptime Engine == ChaCha or Engine == ChaCha8Rng or Engine == ChaCha20Rng) {
        return Engine.init(seed);
    }
    @compileError("unsupported engine");
}

fn seedWord(seed: anytype, comptime index: usize) u64 {
    return std.mem.readInt(u64, seed[index * 8 ..][0..8], .little);
}

fn seedWord32(seed: anytype, comptime index: usize) u32 {
    return std.mem.readInt(u32, seed[index * 4 ..][0..4], .little);
}

fn xoshiro256StateIsZero(state: [4]u64) bool {
    for (state) |word| {
        if (word != 0) return false;
    }
    return true;
}

fn xoshiro128StateIsZero(state: [4]u32) bool {
    for (state) |word| {
        if (word != 0) return false;
    }
    return true;
}

fn patternedSeedBytes(comptime N: usize) [N]u8 {
    var out: [N]u8 = undefined;
    for (&out, 0..) |*byte, i| byte.* = @truncate(i *% 37 +% 11);
    return out;
}

test "engine fromSeedBytes aliases mirror byte seed constructors" {
    const seed8 = patternedSeedBytes(8);
    const seed16 = patternedSeedBytes(16);
    const seed32 = patternedSeedBytes(32);

    try expectEngineFromSeedBytesAlias(SplitMix64, seed8);
    try expectEngineFromSeedBytesAlias(Wyhash64, seed8);
    try expectEngineFromSeedBytesAlias(Pcg64, seed16);
    try expectEngineFromSeedBytesAlias(Xoshiro128PlusPlus, seed16);
    try expectEngineFromSeedBytesAlias(Alea4x64, seed32);
    try expectEngineFromSeedBytesAlias(Xoshiro256, seed32);
    try expectEngineFromSeedBytesAlias(Xoshiro256PlusPlus, seed32);
    try expectEngineFromSeedBytesAlias(ChaCha, seed32);
    try expectEngineFromSeedBytesAlias(ChaCha8Rng, seed32);
    try expectEngineFromSeedBytesAlias(ChaCha20Rng, seed32);

    const zero_seed = [_]u8{0} ** 32;
    var xoshiro_zero_direct = Xoshiro256.init(0);
    var xoshiro_zero_alias = Xoshiro256.fromSeedBytes(zero_seed);
    try std.testing.expectEqual(xoshiro_zero_direct.next(), xoshiro_zero_alias.next());

    var xoshiro_pp_zero_direct = Xoshiro256PlusPlus.init(0);
    var xoshiro_pp_zero_alias = Xoshiro256PlusPlus.fromSeedBytes(zero_seed);
    try std.testing.expectEqual(xoshiro_pp_zero_direct.next(), xoshiro_pp_zero_alias.next());

    const zero_seed16 = [_]u8{0} ** 16;
    var xoshiro128_zero_direct = Xoshiro128PlusPlus.init(0);
    var xoshiro128_zero_alias = Xoshiro128PlusPlus.fromSeedBytes(zero_seed16);
    try std.testing.expectEqual(xoshiro128_zero_direct.next(), xoshiro128_zero_alias.next());
}

fn expectEngineFromRngAlias(comptime Engine: type, seed: u64) !void {
    var direct_source = ScalarPrng.init(seed);
    var alias_source = ScalarPrng.init(seed);
    var direct = engineFromRngReference(Engine, &direct_source);
    var alias = Engine.fromRng(&alias_source);
    try std.testing.expectEqual(direct.next(), alias.next());
    try std.testing.expectEqual(direct_source.next(), alias_source.next());
}

fn expectEngineForkAlias(comptime Engine: type, seed: u64) !void {
    var direct_parent = engineFromSeed(Engine, seed);
    var alias_parent = engineFromSeed(Engine, seed);
    var direct_child = engineFromRngReference(Engine, &direct_parent);
    var alias_child = alias_parent.fork();
    try std.testing.expectEqual(direct_child.next(), alias_child.next());
    try std.testing.expectEqual(direct_parent.next(), alias_parent.next());
}

fn expectEngineTryForkAlias(comptime Engine: type, seed: u64) !void {
    var direct_parent = engineFromSeed(Engine, seed);
    var alias_parent = engineFromSeed(Engine, seed);
    var direct_child = engineFromRngReference(Engine, &direct_parent);
    var alias_child = try alias_parent.tryFork();
    try std.testing.expectEqual(direct_child.next(), alias_child.next());
    try std.testing.expectEqual(direct_parent.next(), alias_parent.next());
}

fn engineFromRngReference(comptime Engine: type, source: anytype) Engine {
    if (comptime Engine == Alea4x64) {
        return .{ .state = .{ source.next(), source.next(), source.next(), source.next() } };
    }
    if (comptime Engine == Xoshiro256) {
        var out: Xoshiro256 = .{ .state = undefined };
        inline for (0..4) |i| out.state[i] = source.next();
        var all_zero = true;
        for (out.state) |word| {
            if (word != 0) {
                all_zero = false;
                break;
            }
        }
        if (all_zero) return Xoshiro256.init(0);
        return out;
    }
    if (comptime Engine == Xoshiro256PlusPlus) {
        var out: Xoshiro256PlusPlus = .{ .state = undefined };
        inline for (0..4) |i| out.state[i] = source.next();
        var all_zero = true;
        for (out.state) |word| {
            if (word != 0) {
                all_zero = false;
                break;
            }
        }
        if (all_zero) return Xoshiro256PlusPlus.init(0);
        return out;
    }
    if (comptime Engine == Pcg64) {
        return Pcg64.initTwo(source.next(), source.next());
    }
    if (comptime Engine == Xoshiro128PlusPlus) {
        const first = source.next();
        const second = source.next();
        const out: Xoshiro128PlusPlus = .{ .state = .{
            @truncate(first),
            @truncate(first >> 32),
            @truncate(second),
            @truncate(second >> 32),
        } };
        if (xoshiro128StateIsZero(out.state)) return Xoshiro128PlusPlus.init(0);
        return out;
    }
    if (comptime Engine == ChaCha or Engine == ChaCha8Rng or Engine == ChaCha20Rng) {
        var key: [Engine.seed_length]u8 = undefined;
        var i: usize = 0;
        while (i < key.len) : (i += 8) {
            var bytes: [8]u8 = undefined;
            std.mem.writeInt(u64, &bytes, source.next(), .little);
            @memcpy(key[i..][0..8], &bytes);
        }
        return Engine.init(key);
    }
    if (comptime Engine == Wyhash64) {
        return Wyhash64.fromState(source.next());
    }
    if (comptime Engine == SplitMix64) {
        return SplitMix64.init(source.next());
    }
    @compileError("unsupported engine");
}

test "engine fromRng and fork aliases consume full seed material" {
    const seed: u64 = 0x5150_f04b_1234_abcd;

    var direct_seed_source = ScalarPrng.init(seed);
    var alias_seed_source = ScalarPrng.init(seed);
    const direct_seed = direct_seed_source.next();
    const alias_seed = Seed.fromRng(&alias_seed_source);
    try std.testing.expectEqual(direct_seed, alias_seed.state);
    try std.testing.expectEqual(direct_seed_source.next(), alias_seed_source.next());

    inline for (.{ SplitMix64, Alea4x64, Wyhash64, Xoshiro256, Xoshiro256PlusPlus, Xoshiro128PlusPlus, Pcg64, ChaCha, ChaCha8Rng, ChaCha20Rng }) |Engine| {
        try expectEngineFromRngAlias(Engine, seed);
        try expectEngineForkAlias(Engine, seed);
        try expectEngineTryForkAlias(Engine, seed);
    }
}

const FallibleSeedSource = struct {
    values: []const u64,
    index: usize = 0,
    fail_after: ?usize = null,

    pub fn tryNext(self: *@This()) error{SeedUnavailable}!u64 {
        if (self.fail_after) |limit| {
            if (self.index >= limit) return error.SeedUnavailable;
        }
        if (self.index >= self.values.len) return error.SeedUnavailable;
        const value = self.values[self.index];
        self.index += 1;
        return value;
    }
};

fn expectEngineTryFromRngAlias(comptime Engine: type, words: []const u64) !void {
    var direct_source = FallibleSeedSource{ .values = words };
    var alias_source = FallibleSeedSource{ .values = words };
    var direct = engineFromFallibleRngReference(Engine, &direct_source) catch unreachable;
    var alias = try Engine.tryFromRng(&alias_source);
    try std.testing.expectEqual(direct.next(), alias.next());
    try std.testing.expectEqual(direct_source.index, alias_source.index);
}

fn expectEngineTryFromRngFailure(comptime Engine: type, words: []const u64, fail_after: usize) !void {
    var source = FallibleSeedSource{ .values = words, .fail_after = fail_after };
    try std.testing.expectError(error.SeedUnavailable, Engine.tryFromRng(&source));
    try std.testing.expectEqual(fail_after, source.index);
}

fn engineFromFallibleRngReference(comptime Engine: type, source: anytype) !Engine {
    if (comptime Engine == Alea4x64) {
        return .{ .state = .{
            try source.tryNext(),
            try source.tryNext(),
            try source.tryNext(),
            try source.tryNext(),
        } };
    }
    if (comptime Engine == Xoshiro256) {
        var out: Xoshiro256 = .{ .state = undefined };
        inline for (0..4) |i| out.state[i] = try source.tryNext();
        if (xoshiro256StateIsZero(out.state)) return Xoshiro256.init(0);
        return out;
    }
    if (comptime Engine == Xoshiro256PlusPlus) {
        var out: Xoshiro256PlusPlus = .{ .state = undefined };
        inline for (0..4) |i| out.state[i] = try source.tryNext();
        if (xoshiro256StateIsZero(out.state)) return Xoshiro256PlusPlus.init(0);
        return out;
    }
    if (comptime Engine == Pcg64) {
        const seed = try source.tryNext();
        const stream = try source.tryNext();
        return Pcg64.initTwo(seed, stream);
    }
    if (comptime Engine == Xoshiro128PlusPlus) {
        const first = try source.tryNext();
        const second = try source.tryNext();
        const out: Xoshiro128PlusPlus = .{ .state = .{
            @truncate(first),
            @truncate(first >> 32),
            @truncate(second),
            @truncate(second >> 32),
        } };
        if (xoshiro128StateIsZero(out.state)) return Xoshiro128PlusPlus.init(0);
        return out;
    }
    if (comptime Engine == ChaCha or Engine == ChaCha8Rng or Engine == ChaCha20Rng) {
        var key: [Engine.seed_length]u8 = undefined;
        var i: usize = 0;
        while (i < key.len) : (i += 8) {
            var bytes: [8]u8 = undefined;
            std.mem.writeInt(u64, &bytes, try source.tryNext(), .little);
            @memcpy(key[i..][0..8], &bytes);
        }
        return Engine.init(key);
    }
    if (comptime Engine == Wyhash64) {
        return Wyhash64.fromState(try source.tryNext());
    }
    if (comptime Engine == SplitMix64) {
        return SplitMix64.init(try source.tryNext());
    }
    @compileError("unsupported engine");
}

test "engine tryFromRng aliases propagate source failures" {
    const words = [_]u64{
        0x0102_0304_0506_0708,
        0x1112_1314_1516_1718,
        0x2122_2324_2526_2728,
        0x3132_3334_3536_3738,
    };

    var direct_seed_source = FallibleSeedSource{ .values = &words };
    const alias_seed = try Seed.tryFromRng(&direct_seed_source);
    try std.testing.expectEqual(words[0], alias_seed.state);
    try std.testing.expectEqual(@as(usize, 1), direct_seed_source.index);

    var failing_seed_source = FallibleSeedSource{ .values = &words, .fail_after = 0 };
    try std.testing.expectError(error.SeedUnavailable, Seed.tryFromRng(&failing_seed_source));
    try std.testing.expectEqual(@as(usize, 0), failing_seed_source.index);

    inline for (.{ SplitMix64, Wyhash64 }) |Engine| {
        try expectEngineTryFromRngAlias(Engine, &words);
        try expectEngineTryFromRngFailure(Engine, &words, 0);
    }

    inline for (.{ Pcg64, Xoshiro128PlusPlus }) |Engine| {
        try expectEngineTryFromRngAlias(Engine, &words);
        try expectEngineTryFromRngFailure(Engine, &words, 1);
    }

    inline for (.{ Alea4x64, Xoshiro256, Xoshiro256PlusPlus, ChaCha, ChaCha8Rng, ChaCha20Rng }) |Engine| {
        try expectEngineTryFromRngAlias(Engine, &words);
        try expectEngineTryFromRngFailure(Engine, &words, 3);
    }
}
