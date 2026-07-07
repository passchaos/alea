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
pub const IndexVec = seq.IndexVec;

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
    if (length == 0) return error.EmptyRange;
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
    if (count == 0) return allocator.alloc(usize, 0);
    if (length == 0) return error.EmptyRange;
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

pub fn chooseIndexArray(io: std.Io, comptime N: usize, length: usize) !?[N]usize {
    var out: [N]usize = undefined;
    if (N == 0) return out;
    if (length == 0) return null;
    try fillChooseIndex(io, &out, length);
    return out;
}

pub fn chooseIndexArrayChecked(io: std.Io, comptime N: usize, length: usize) ![N]usize {
    var out: [N]usize = undefined;
    if (N == 0) return out;
    if (length == 0) return error.EmptyRange;
    try fillChooseIndexChecked(io, &out, length);
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
    if (length == 0) return error.EmptyRange;
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
    if (count == 0) return allocator.alloc(u32, 0);
    if (length == 0) return error.EmptyRange;
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

pub fn chooseIndexArrayU32(io: std.Io, comptime N: usize, length: u32) !?[N]u32 {
    var out: [N]u32 = undefined;
    if (N == 0) return out;
    if (length == 0) return null;
    try fillChooseIndexU32(io, &out, length);
    return out;
}

pub fn chooseIndexArrayU32Checked(io: std.Io, comptime N: usize, length: u32) ![N]u32 {
    var out: [N]u32 = undefined;
    if (N == 0) return out;
    if (length == 0) return error.EmptyRange;
    try fillChooseIndexU32Checked(io, &out, length);
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
    if (items.len == 0) return error.EmptyRange;
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
    if (count == 0) return allocator.alloc(T, 0);
    if (items.len == 0) return error.EmptyRange;
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

pub fn chooseValueArray(comptime T: type, io: std.Io, comptime N: usize, items: []const T) !?[N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    if (items.len == 0) return null;
    try fillChoose(T, io, &out, items);
    return out;
}

pub fn chooseValueArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []const T) ![N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    if (items.len == 0) return error.EmptyRange;
    try fillChooseChecked(T, io, &out, items);
    return out;
}

pub fn chooseRepeatedValueArray(comptime T: type, io: std.Io, comptime N: usize, items: []const T) !?[N]T {
    return chooseValueArray(T, io, N, items);
}

pub fn chooseRepeatedValueArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []const T) ![N]T {
    return chooseValueArrayChecked(T, io, N, items);
}

pub fn chooseConstPtr(comptime T: type, io: std.Io, items: []const T) !?*const T {
    if (items.len == 0) return null;
    if (items.len == 1) return &items[0];
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.chooseConstPtr(T, items);
}

pub fn chooseConstPtrChecked(comptime T: type, io: std.Io, items: []const T) !*const T {
    if (items.len == 0) return error.EmptyRange;
    if (items.len == 1) return &items[0];
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try random_source.chooseConstPtrChecked(T, items);
}

pub fn fillChooseConstPtr(comptime T: type, io: std.Io, dest: []*const T, items: []const T) !void {
    if (dest.len == 0) return;
    if (items.len == 0) return error.EmptyRange;
    if (items.len == 1) {
        @memset(dest, &items[0]);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillChooseConstPtr(T, dest, items);
}

pub fn fillChooseConstPtrChecked(comptime T: type, io: std.Io, dest: []*const T, items: []const T) !void {
    if (dest.len == 0) return;
    if (items.len == 0) return error.EmptyRange;
    if (items.len == 1) {
        @memset(dest, &items[0]);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillChooseConstPtrChecked(T, dest, items);
}

pub fn chooseConstPtrBatch(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T) ![]*const T {
    if (count == 0) return allocator.alloc(*const T, 0);
    if (items.len == 0) return error.EmptyRange;
    const out = try allocator.alloc(*const T, count);
    errdefer allocator.free(out);
    try fillChooseConstPtr(T, io, out, items);
    return out;
}

pub fn chooseConstPtrBatchChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T) ![]*const T {
    if (count == 0) return allocator.alloc(*const T, 0);
    const out = try allocator.alloc(*const T, count);
    errdefer allocator.free(out);
    try fillChooseConstPtrChecked(T, io, out, items);
    return out;
}

pub fn chooseConstPtrArray(comptime T: type, io: std.Io, comptime N: usize, items: []const T) !?[N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    if (items.len == 0) return null;
    try fillChooseConstPtr(T, io, &out, items);
    return out;
}

pub fn chooseConstPtrArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []const T) ![N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    if (items.len == 0) return error.EmptyRange;
    try fillChooseConstPtrChecked(T, io, &out, items);
    return out;
}

pub fn chooseRepeatedConstPtrArray(comptime T: type, io: std.Io, comptime N: usize, items: []const T) !?[N]*const T {
    return chooseConstPtrArray(T, io, N, items);
}

pub fn chooseRepeatedConstPtrArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []const T) ![N]*const T {
    return chooseConstPtrArrayChecked(T, io, N, items);
}

pub fn choosePtr(comptime T: type, io: std.Io, items: []T) !?*T {
    if (items.len == 0) return null;
    if (items.len == 1) return &items[0];
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return random_source.choosePtr(T, items);
}

pub fn choosePtrChecked(comptime T: type, io: std.Io, items: []T) !*T {
    if (items.len == 0) return error.EmptyRange;
    if (items.len == 1) return &items[0];
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try random_source.choosePtrChecked(T, items);
}

pub fn fillChoosePtr(comptime T: type, io: std.Io, dest: []*T, items: []T) !void {
    if (dest.len == 0) return;
    if (items.len == 0) return error.EmptyRange;
    if (items.len == 1) {
        @memset(dest, &items[0]);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillChoosePtr(T, dest, items);
}

pub fn fillChoosePtrChecked(comptime T: type, io: std.Io, dest: []*T, items: []T) !void {
    if (dest.len == 0) return;
    if (items.len == 0) return error.EmptyRange;
    if (items.len == 1) {
        @memset(dest, &items[0]);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillChoosePtrChecked(T, dest, items);
}

pub fn choosePtrBatch(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []T) ![]*T {
    if (count == 0) return allocator.alloc(*T, 0);
    if (items.len == 0) return error.EmptyRange;
    const out = try allocator.alloc(*T, count);
    errdefer allocator.free(out);
    try fillChoosePtr(T, io, out, items);
    return out;
}

pub fn choosePtrBatchChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []T) ![]*T {
    if (count == 0) return allocator.alloc(*T, 0);
    const out = try allocator.alloc(*T, count);
    errdefer allocator.free(out);
    try fillChoosePtrChecked(T, io, out, items);
    return out;
}

pub fn choosePtrArray(comptime T: type, io: std.Io, comptime N: usize, items: []T) !?[N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    if (items.len == 0) return null;
    try fillChoosePtr(T, io, &out, items);
    return out;
}

pub fn choosePtrArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []T) ![N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    if (items.len == 0) return error.EmptyRange;
    try fillChoosePtrChecked(T, io, &out, items);
    return out;
}

pub fn chooseRepeatedPtrArray(comptime T: type, io: std.Io, comptime N: usize, items: []T) !?[N]*T {
    return choosePtrArray(T, io, N, items);
}

pub fn chooseRepeatedPtrArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []T) ![N]*T {
    return choosePtrArrayChecked(T, io, N, items);
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

pub fn sampleWithoutReplacement(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, count: usize) ![]T {
    std.debug.assert(count <= items.len);
    return try sampleWithoutReplacementChecked(T, io, allocator, items, count);
}

pub fn sampleWithoutReplacementChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, count: usize) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    if (count > items.len) return error.InvalidParameter;
    if (count == items.len) return allocator.dupe(T, items);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try random_source.sampleWithoutReplacementChecked(T, allocator, items, count);
}

pub fn sampleItemsArray(comptime T: type, io: std.Io, comptime N: usize, items: []const T) !?[N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    if (N > items.len) return null;
    if (N == items.len) {
        for (&out, 0..) |*slot, index| slot.* = items[index];
        return out;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return seq.sampleItemsArray(random_source, T, N, items);
}

pub fn sampleItemsArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []const T) ![N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    if (N > items.len) return error.InvalidParameter;
    if (N == items.len) {
        for (&out, 0..) |*slot, index| slot.* = items[index];
        return out;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleItemsArrayChecked(random_source, T, N, items);
}

pub fn chooseArray(comptime T: type, io: std.Io, comptime N: usize, items: []const T) !?[N]T {
    return try sampleItemsArray(T, io, N, items);
}

pub fn chooseArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []const T) ![N]T {
    return try sampleItemsArrayChecked(T, io, N, items);
}

pub fn samplePtrArray(comptime T: type, io: std.Io, comptime N: usize, items: []const T) !?[N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    if (N > items.len) return null;
    if (N == items.len) {
        for (&out, 0..) |*slot, index| slot.* = &items[index];
        return out;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return seq.samplePtrArray(random_source, T, N, items);
}

pub fn samplePtrArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []const T) ![N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    if (N > items.len) return error.InvalidParameter;
    if (N == items.len) {
        for (&out, 0..) |*slot, index| slot.* = &items[index];
        return out;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.samplePtrArrayChecked(random_source, T, N, items);
}

pub fn sampleMutPtrArray(comptime T: type, io: std.Io, comptime N: usize, items: []T) !?[N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    if (N > items.len) return null;
    if (N == items.len) {
        for (&out, 0..) |*slot, index| slot.* = &items[index];
        return out;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return seq.sampleMutPtrArray(random_source, T, N, items);
}

pub fn sampleMutPtrArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []T) ![N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    if (N > items.len) return error.InvalidParameter;
    if (N == items.len) {
        for (&out, 0..) |*slot, index| slot.* = &items[index];
        return out;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleMutPtrArrayChecked(random_source, T, N, items);
}

pub fn samplePtrs(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) ![]*const T {
    std.debug.assert(amount <= items.len);
    return try samplePtrsChecked(T, io, allocator, items, amount);
}

pub fn samplePtrsChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) ![]*const T {
    if (amount == 0) return allocator.alloc(*const T, 0);
    if (amount > items.len) return error.InvalidParameter;
    if (amount == items.len) return try rootPtrSliceAll(T, allocator, items);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.samplePtrsChecked(allocator, random_source, T, items, amount);
}

pub fn sampleMutPtrs(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []T, amount: usize) ![]*T {
    std.debug.assert(amount <= items.len);
    return try sampleMutPtrsChecked(T, io, allocator, items, amount);
}

pub fn sampleMutPtrsChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []T, amount: usize) ![]*T {
    if (amount == 0) return allocator.alloc(*T, 0);
    if (amount > items.len) return error.InvalidParameter;
    if (amount == items.len) return try rootMutPtrSliceAll(T, allocator, items);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleMutPtrsChecked(allocator, random_source, T, items, amount);
}

pub fn sampleItemsInto(comptime T: type, io: std.Io, items: []const T, out: []T, scratch_indices: []usize) !usize {
    const count = @min(out.len, items.len);
    if (count == 0) return 0;
    if (scratch_indices.len < count) return error.LengthMismatch;
    if (count == items.len) return rootItemsIntoPrefix(T, items, out, count);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleItemsInto(random_source, T, items, out, scratch_indices);
}

pub fn sampleItemsIntoChecked(comptime T: type, io: std.Io, items: []const T, out: []T, scratch_indices: []usize) !void {
    if (out.len > items.len) return error.InvalidParameter;
    if (out.len == 0) return;
    if (scratch_indices.len < out.len) return error.LengthMismatch;
    if (out.len == items.len) {
        _ = rootItemsIntoPrefix(T, items, out, out.len);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleItemsIntoChecked(random_source, T, items, out, scratch_indices);
}

pub fn samplePtrsInto(comptime T: type, io: std.Io, items: []const T, out: []*const T, scratch_indices: []usize) !usize {
    const count = @min(out.len, items.len);
    if (count == 0) return 0;
    if (scratch_indices.len < count) return error.LengthMismatch;
    if (count == items.len) return rootPtrsIntoPrefix(T, items, out, count);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.samplePtrsInto(random_source, T, items, out, scratch_indices);
}

pub fn samplePtrsIntoChecked(comptime T: type, io: std.Io, items: []const T, out: []*const T, scratch_indices: []usize) !void {
    if (out.len > items.len) return error.InvalidParameter;
    if (out.len == 0) return;
    if (scratch_indices.len < out.len) return error.LengthMismatch;
    if (out.len == items.len) {
        _ = rootPtrsIntoPrefix(T, items, out, out.len);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.samplePtrsIntoChecked(random_source, T, items, out, scratch_indices);
}

pub fn sampleMutPtrsInto(comptime T: type, io: std.Io, items: []T, out: []*T, scratch_indices: []usize) !usize {
    const count = @min(out.len, items.len);
    if (count == 0) return 0;
    if (scratch_indices.len < count) return error.LengthMismatch;
    if (count == items.len) return rootMutPtrsIntoPrefix(T, items, out, count);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleMutPtrsInto(random_source, T, items, out, scratch_indices);
}

pub fn sampleMutPtrsIntoChecked(comptime T: type, io: std.Io, items: []T, out: []*T, scratch_indices: []usize) !void {
    if (out.len > items.len) return error.InvalidParameter;
    if (out.len == 0) return;
    if (scratch_indices.len < out.len) return error.LengthMismatch;
    if (out.len == items.len) {
        _ = rootMutPtrsIntoPrefix(T, items, out, out.len);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleMutPtrsIntoChecked(random_source, T, items, out, scratch_indices);
}

pub fn chooseMultiple(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) ![]T {
    const count = @min(amount, items.len);
    if (count == 0) return allocator.alloc(T, 0);
    if (count == items.len) return allocator.dupe(T, items);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.chooseMultiple(allocator, random_source, T, items, amount);
}

pub fn chooseMultipleChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) ![]T {
    return sampleWithoutReplacementChecked(T, io, allocator, items, amount);
}

pub fn chooseMultiplePtrs(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) ![]*const T {
    const count = @min(amount, items.len);
    if (count == 0) return allocator.alloc(*const T, 0);
    if (count == items.len) return try rootPtrSliceAll(T, allocator, items);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.chooseMultiplePtrs(allocator, random_source, T, items, amount);
}

pub fn chooseMultiplePtrsChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) ![]*const T {
    return samplePtrsChecked(T, io, allocator, items, amount);
}

pub fn chooseMultipleMutPtrs(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []T, amount: usize) ![]*T {
    const count = @min(amount, items.len);
    if (count == 0) return allocator.alloc(*T, 0);
    if (count == items.len) return try rootMutPtrSliceAll(T, allocator, items);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.chooseMultipleMutPtrs(allocator, random_source, T, items, amount);
}

pub fn chooseMultipleMutPtrsChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []T, amount: usize) ![]*T {
    return sampleMutPtrsChecked(T, io, allocator, items, amount);
}

pub fn chooseMultipleInto(comptime T: type, io: std.Io, items: []const T, out: []T, scratch_indices: []usize) !usize {
    return sampleItemsInto(T, io, items, out, scratch_indices);
}

pub fn chooseMultipleIntoChecked(comptime T: type, io: std.Io, items: []const T, out: []T, scratch_indices: []usize) !void {
    try sampleItemsIntoChecked(T, io, items, out, scratch_indices);
}

pub fn chooseMultiplePtrsInto(comptime T: type, io: std.Io, items: []const T, out: []*const T, scratch_indices: []usize) !usize {
    return samplePtrsInto(T, io, items, out, scratch_indices);
}

pub fn chooseMultiplePtrsIntoChecked(comptime T: type, io: std.Io, items: []const T, out: []*const T, scratch_indices: []usize) !void {
    try samplePtrsIntoChecked(T, io, items, out, scratch_indices);
}

pub fn chooseMultipleMutPtrsInto(comptime T: type, io: std.Io, items: []T, out: []*T, scratch_indices: []usize) !usize {
    return sampleMutPtrsInto(T, io, items, out, scratch_indices);
}

pub fn chooseMultipleMutPtrsIntoChecked(comptime T: type, io: std.Io, items: []T, out: []*T, scratch_indices: []usize) !void {
    try sampleMutPtrsIntoChecked(T, io, items, out, scratch_indices);
}

pub fn sampleItemsIter(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) !seq.SampledValueIterator(T) {
    std.debug.assert(amount <= items.len);
    return try sampleItemsIterChecked(T, io, allocator, items, amount);
}

pub fn sampleItemsIterChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) !seq.SampledValueIterator(T) {
    if (amount > items.len) return error.InvalidParameter;
    if (amount == 0) {
        const index_vec: IndexVec = .{ .u32 = try allocator.alloc(u32, 0) };
        return .{ .items = items, .index_iter = index_vec.intoIter(allocator) };
    }
    if (amount == items.len) {
        const index_vec = try rootIndexVecAll(allocator, items.len);
        return .{ .items = items, .index_iter = index_vec.intoIter(allocator) };
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleItemsIterChecked(allocator, random_source, T, items, amount);
}

pub fn samplePtrsIter(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) !seq.SampledPtrIterator(T) {
    std.debug.assert(amount <= items.len);
    return try samplePtrsIterChecked(T, io, allocator, items, amount);
}

pub fn samplePtrsIterChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) !seq.SampledPtrIterator(T) {
    if (amount > items.len) return error.InvalidParameter;
    if (amount == 0) {
        const index_vec: IndexVec = .{ .u32 = try allocator.alloc(u32, 0) };
        return .{ .items = items, .index_iter = index_vec.intoIter(allocator) };
    }
    if (amount == items.len) {
        const index_vec = try rootIndexVecAll(allocator, items.len);
        return .{ .items = items, .index_iter = index_vec.intoIter(allocator) };
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.samplePtrsIterChecked(allocator, random_source, T, items, amount);
}

pub fn sampleMutPtrsIter(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []T, amount: usize) !seq.SampledMutPtrIterator(T) {
    std.debug.assert(amount <= items.len);
    return try sampleMutPtrsIterChecked(T, io, allocator, items, amount);
}

pub fn sampleMutPtrsIterChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []T, amount: usize) !seq.SampledMutPtrIterator(T) {
    if (amount > items.len) return error.InvalidParameter;
    if (amount == 0) {
        const index_vec: IndexVec = .{ .u32 = try allocator.alloc(u32, 0) };
        return .{ .items = items, .index_iter = index_vec.intoIter(allocator) };
    }
    if (amount == items.len) {
        const index_vec = try rootIndexVecAll(allocator, items.len);
        return .{ .items = items, .index_iter = index_vec.intoIter(allocator) };
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleMutPtrsIterChecked(allocator, random_source, T, items, amount);
}

pub fn reservoirSample(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) ![]T {
    const count = @min(amount, items.len);
    if (count == 0) return allocator.alloc(T, 0);
    if (count == items.len) return allocator.dupe(T, items);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.reservoirSample(allocator, random_source, T, items, amount);
}

pub fn reservoirSampleChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) ![]T {
    if (amount > items.len) return error.InvalidParameter;
    return try reservoirSample(T, io, allocator, items, amount);
}

pub fn reservoirSamplePtrs(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) ![]*const T {
    const count = @min(amount, items.len);
    if (count == 0) return allocator.alloc(*const T, 0);
    if (count == items.len) return try rootPtrSliceAll(T, allocator, items);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.reservoirSamplePtrs(allocator, random_source, T, items, amount);
}

pub fn reservoirSamplePtrsChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize) ![]*const T {
    if (amount > items.len) return error.InvalidParameter;
    return try reservoirSamplePtrs(T, io, allocator, items, amount);
}

pub fn reservoirSampleMutPtrs(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []T, amount: usize) ![]*T {
    const count = @min(amount, items.len);
    if (count == 0) return allocator.alloc(*T, 0);
    if (count == items.len) return try rootMutPtrSliceAll(T, allocator, items);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.reservoirSampleMutPtrs(allocator, random_source, T, items, amount);
}

pub fn reservoirSampleMutPtrsChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, items: []T, amount: usize) ![]*T {
    if (amount > items.len) return error.InvalidParameter;
    return try reservoirSampleMutPtrs(T, io, allocator, items, amount);
}

pub fn reservoirSampleInto(comptime T: type, io: std.Io, items: []const T, out: []T) !void {
    try reservoirSampleIntoChecked(T, io, items, out);
}

pub fn reservoirSampleIntoChecked(comptime T: type, io: std.Io, items: []const T, out: []T) !void {
    if (out.len > items.len) return error.InvalidParameter;
    if (out.len == 0) return;
    if (out.len == items.len) {
        _ = rootItemsIntoPrefix(T, items, out, out.len);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.reservoirSampleInto(random_source, T, items, out);
}

pub fn reservoirSamplePtrsInto(comptime T: type, io: std.Io, items: []const T, out: []*const T) !void {
    try reservoirSamplePtrsIntoChecked(T, io, items, out);
}

pub fn reservoirSamplePtrsIntoChecked(comptime T: type, io: std.Io, items: []const T, out: []*const T) !void {
    if (out.len > items.len) return error.InvalidParameter;
    if (out.len == 0) return;
    if (out.len == items.len) {
        _ = rootPtrsIntoPrefix(T, items, out, out.len);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.reservoirSamplePtrsInto(random_source, T, items, out);
}

pub fn reservoirSampleMutPtrsInto(comptime T: type, io: std.Io, items: []T, out: []*T) !void {
    try reservoirSampleMutPtrsIntoChecked(T, io, items, out);
}

pub fn reservoirSampleMutPtrsIntoChecked(comptime T: type, io: std.Io, items: []T, out: []*T) !void {
    if (out.len > items.len) return error.InvalidParameter;
    if (out.len == 0) return;
    if (out.len == items.len) {
        _ = rootMutPtrsIntoPrefix(T, items, out, out.len);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.reservoirSampleMutPtrsInto(random_source, T, items, out);
}

pub fn sampleIndexVec(io: std.Io, allocator: std.mem.Allocator, length: usize, amount: usize) !IndexVec {
    std.debug.assert(amount <= length);
    return try sampleIndexVecChecked(io, allocator, length, amount);
}

pub fn sampleIndexVecChecked(io: std.Io, allocator: std.mem.Allocator, length: usize, amount: usize) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (amount > length) return error.InvalidParameter;
    if (amount == length and length <= 1024) return try rootIndexVecAll(allocator, length);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleIndexVecCheckedFrom(allocator, random_source, length, amount);
}

pub fn sampleArray(io: std.Io, comptime N: usize, length: usize) !?[N]usize {
    if (N == 0) return .{};
    if (N > length) return null;
    if (N == length and length <= 1024) return rootIndexArrayAll(N);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return seq.sampleArray(random_source, N, length);
}

pub fn sampleArrayChecked(io: std.Io, comptime N: usize, length: usize) ![N]usize {
    if (N == 0) return .{};
    if (N > length) return error.InvalidParameter;
    if (N == length and length <= 1024) return rootIndexArrayAll(N);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleArrayChecked(random_source, N, length);
}

pub fn sampleArrayU32(io: std.Io, comptime N: usize, length: u32) !?[N]u32 {
    if (N == 0) return .{};
    if (N > @as(usize, length)) return null;
    if (N == @as(usize, length) and length <= 1024) return rootIndexArrayAllU32(N);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return seq.sampleArrayU32(random_source, N, length);
}

pub fn sampleArrayU32Checked(io: std.Io, comptime N: usize, length: u32) ![N]u32 {
    if (N == 0) return .{};
    if (N > @as(usize, length)) return error.InvalidParameter;
    if (N == @as(usize, length) and length <= 1024) return rootIndexArrayAllU32(N);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleArrayU32Checked(random_source, N, length);
}

pub fn sampleIndices(io: std.Io, allocator: std.mem.Allocator, length: usize, amount: usize) ![]usize {
    std.debug.assert(amount <= length);
    return try sampleIndicesChecked(io, allocator, length, amount);
}

pub fn sampleIndicesChecked(io: std.Io, allocator: std.mem.Allocator, length: usize, amount: usize) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (amount > length) return error.InvalidParameter;
    if (amount == length and length <= 1024) {
        const out = try allocator.alloc(usize, length);
        for (out, 0..) |*item, index| item.* = index;
        return out;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleIndicesCheckedFrom(allocator, random_source, length, amount);
}

pub fn sampleIndicesInto(io: std.Io, length: usize, out: []usize) !void {
    if (out.len == 0) return;
    std.debug.assert(out.len <= length);
    if (out.len == length and length <= 1024) {
        for (out, 0..) |*item, index| item.* = index;
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    seq.sampleIndicesInto(random_source, length, out) catch unreachable;
}

pub fn sampleIndicesIntoChecked(io: std.Io, length: usize, out: []usize) !void {
    if (out.len == 0) return;
    if (out.len > length) return error.InvalidParameter;
    if (out.len == length and length <= 1024) {
        for (out, 0..) |*item, index| item.* = index;
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleIndicesIntoChecked(random_source, length, out);
}

pub fn sampleIndicesU32(io: std.Io, allocator: std.mem.Allocator, length: u32, amount: u32) ![]u32 {
    std.debug.assert(amount <= length);
    return try sampleIndicesU32Checked(io, allocator, length, amount);
}

pub fn sampleIndicesU32Checked(io: std.Io, allocator: std.mem.Allocator, length: u32, amount: u32) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    if (amount > length) return error.InvalidParameter;
    if (amount == length and length <= 1024) {
        const out = try allocator.alloc(u32, length);
        for (out, 0..) |*item, index| item.* = @intCast(index);
        return out;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleIndicesU32CheckedFrom(allocator, random_source, length, amount);
}

pub fn sampleIndicesU32Into(io: std.Io, length: u32, out: []u32) !void {
    if (out.len == 0) return;
    std.debug.assert(out.len <= @as(usize, length));
    if (out.len == @as(usize, length) and length <= 1024) {
        for (out, 0..) |*item, index| item.* = @intCast(index);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    seq.sampleIndicesU32Into(random_source, length, out) catch unreachable;
}

pub fn sampleIndicesU32IntoChecked(io: std.Io, length: u32, out: []u32) !void {
    if (out.len == 0) return;
    if (out.len > @as(usize, length)) return error.InvalidParameter;
    if (out.len == @as(usize, length) and length <= 1024) {
        for (out, 0..) |*item, index| item.* = @intCast(index);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleIndicesU32IntoChecked(random_source, length, out);
}

pub fn sampleWeightedIndices(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, weights: []const Weight, amount: usize) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndices(allocator, random_source, Weight, weights, amount);
}

pub fn sampleWeightedIndicesChecked(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, weights: []const Weight, amount: usize) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesChecked(allocator, random_source, Weight, weights, amount);
}

pub fn sampleWeightedIndicesU32(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, weights: []const Weight, amount: usize) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesU32(allocator, random_source, Weight, weights, amount);
}

pub fn sampleWeightedIndicesU32Checked(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, weights: []const Weight, amount: usize) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesU32Checked(allocator, random_source, Weight, weights, amount);
}

pub fn sampleWeightedIndicesBy(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize, comptime weightFn: fn (*const T) Weight) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    const count = @min(amount, state.count);
    if (count == 0) return allocator.alloc(usize, 0);
    if (state.count == 1) return rootSingleIndexAlloc(allocator, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesBy(allocator, random_source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndicesByChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize, comptime weightFn: fn (*const T) Weight) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (amount > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1 and amount == 1) return rootSingleIndexAlloc(allocator, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesByChecked(allocator, random_source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndicesByIndex(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, length: usize, amount: usize, comptime weightFn: fn (usize) Weight) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (length == 0) return error.EmptyInput;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    const count = @min(amount, state.count);
    if (count == 0) return allocator.alloc(usize, 0);
    if (state.count == 1) return rootSingleIndexAlloc(allocator, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesByIndex(allocator, random_source, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndicesByIndexChecked(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, length: usize, amount: usize, comptime weightFn: fn (usize) Weight) ![]usize {
    if (amount == 0) return allocator.alloc(usize, 0);
    if (amount > length) return error.InvalidParameter;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1 and amount == 1) return rootSingleIndexAlloc(allocator, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesByIndexChecked(allocator, random_source, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndicesU32ByIndex(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, length: usize, amount: usize, comptime weightFn: fn (usize) Weight) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    if (length > std.math.maxInt(u32)) return error.InvalidParameter;
    if (length == 0) return error.EmptyInput;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    const count = @min(amount, state.count);
    if (count == 0) return allocator.alloc(u32, 0);
    if (state.count == 1) return rootSingleIndexU32Alloc(allocator, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesU32ByIndex(allocator, random_source, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndicesU32ByIndexChecked(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, length: usize, amount: usize, comptime weightFn: fn (usize) Weight) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    if (length > std.math.maxInt(u32) or amount > length) return error.InvalidParameter;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1 and amount == 1) return rootSingleIndexU32Alloc(allocator, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesU32ByIndexChecked(allocator, random_source, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndexVecByIndex(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, length: usize, amount: usize, comptime weightFn: fn (usize) Weight) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (length == 0) return error.EmptyInput;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    const count = @min(amount, state.count);
    if (count == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (state.count == 1) return try rootIndexVecSingle(allocator, length, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexVecByIndex(allocator, random_source, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndexVecByIndexChecked(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, length: usize, amount: usize, comptime weightFn: fn (usize) Weight) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (amount > length) return error.InvalidParameter;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1 and amount == 1) return try rootIndexVecSingle(allocator, length, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexVecByIndexChecked(allocator, random_source, Weight, length, amount, weightFn);
}

pub fn sampleWeightedIndicesU32By(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize, comptime weightFn: fn (*const T) Weight) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    if (items.len > std.math.maxInt(u32)) return error.InvalidParameter;
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    const count = @min(amount, state.count);
    if (count == 0) return allocator.alloc(u32, 0);
    if (state.count == 1) return rootSingleIndexU32Alloc(allocator, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesU32By(allocator, random_source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndicesU32ByChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize, comptime weightFn: fn (*const T) Weight) ![]u32 {
    if (amount == 0) return allocator.alloc(u32, 0);
    if (items.len > std.math.maxInt(u32) or amount > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1 and amount == 1) return rootSingleIndexU32Alloc(allocator, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesU32ByChecked(allocator, random_source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndexVecBy(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize, comptime weightFn: fn (*const T) Weight) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    const count = @min(amount, state.count);
    if (count == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (state.count == 1) return try rootIndexVecSingle(allocator, items.len, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexVecBy(allocator, random_source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndexVecByChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize, comptime weightFn: fn (*const T) Weight) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (amount > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1 and amount == 1) return try rootIndexVecSingle(allocator, items.len, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexVecByChecked(allocator, random_source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedIndexVec(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, weights: []const Weight, amount: usize) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (weights.len == 0) return error.EmptyInput;
    const state = try rootPositiveWeightState(Weight, weights);
    const count = @min(amount, state.count);
    if (count == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (state.count == 1) return try rootIndexVecSingle(allocator, weights.len, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexVec(allocator, random_source, Weight, weights, amount);
}

pub fn sampleWeightedIndexVecChecked(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, weights: []const Weight, amount: usize) !IndexVec {
    if (amount == 0) return .{ .u32 = try allocator.alloc(u32, 0) };
    if (amount > weights.len) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1) return try rootIndexVecSingle(allocator, weights.len, state.single_index.?);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexVecChecked(allocator, random_source, Weight, weights, amount);
}

pub fn sampleWeightedIndicesInto(comptime Weight: type, io: std.Io, weights: []const Weight, out: []usize, scratch_keys: []f64) !usize {
    if (out.len == 0) return 0;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (weights.len == 0) return error.EmptyInput;
    const state = try rootPositiveWeightState(Weight, weights);
    const count = @min(out.len, state.count);
    if (count == 0) return 0;
    if (state.count == 1) {
        out[0] = state.single_index.?;
        return 1;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesInto(random_source, Weight, weights, out, scratch_keys);
}

pub fn sampleWeightedIndicesIntoChecked(comptime Weight: type, io: std.Io, weights: []const Weight, out: []usize, scratch_keys: []f64) !void {
    if (out.len == 0) return;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > weights.len) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < out.len) return error.InvalidParameter;
    if (state.count == 1) {
        out[0] = state.single_index.?;
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleWeightedIndicesIntoChecked(random_source, Weight, weights, out, scratch_keys);
}

pub fn sampleWeightedIndicesU32Into(comptime Weight: type, io: std.Io, weights: []const Weight, out: []u32, scratch_keys: []f64) !usize {
    if (out.len == 0) return 0;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (weights.len == 0) return error.EmptyInput;
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    const count = @min(out.len, state.count);
    if (count == 0) return 0;
    if (state.count == 1) {
        out[0] = @intCast(state.single_index.?);
        return 1;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesU32Into(random_source, Weight, weights, out, scratch_keys);
}

pub fn sampleWeightedIndicesU32IntoChecked(comptime Weight: type, io: std.Io, weights: []const Weight, out: []u32, scratch_keys: []f64) !void {
    if (out.len == 0) return;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > weights.len or weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < out.len) return error.InvalidParameter;
    if (state.count == 1) {
        out[0] = @intCast(state.single_index.?);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleWeightedIndicesU32IntoChecked(random_source, Weight, weights, out, scratch_keys);
}

pub fn sampleWeightedIndexArray(comptime Weight: type, io: std.Io, comptime N: usize, weights: []const Weight) !?[N]usize {
    if (N == 0) return .{};
    if (weights.len == 0) return error.EmptyInput;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < N) return null;
    if (comptime N == 1) {
        if (state.count == 1) return .{state.single_index.?};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexArray(random_source, Weight, N, weights);
}

pub fn sampleWeightedIndexArrayChecked(comptime Weight: type, io: std.Io, comptime N: usize, weights: []const Weight) ![N]usize {
    if (N == 0) return .{};
    if (N > weights.len) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < N) return error.InvalidParameter;
    if (comptime N == 1) {
        if (state.count == 1) return .{state.single_index.?};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexArrayChecked(random_source, Weight, N, weights);
}

pub fn sampleWeightedIndexArrayU32(comptime Weight: type, io: std.Io, comptime N: usize, weights: []const Weight) !?[N]u32 {
    if (N == 0) return .{};
    if (weights.len == 0) return error.EmptyInput;
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < N) return null;
    if (comptime N == 1) {
        if (state.count == 1) return .{@intCast(state.single_index.?)};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexArrayU32(random_source, Weight, N, weights);
}

pub fn sampleWeightedIndexArrayU32Checked(comptime Weight: type, io: std.Io, comptime N: usize, weights: []const Weight) ![N]u32 {
    if (N == 0) return .{};
    if (N > weights.len or weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < N) return error.InvalidParameter;
    if (comptime N == 1) {
        if (state.count == 1) return .{@intCast(state.single_index.?)};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexArrayU32Checked(random_source, Weight, N, weights);
}

pub fn sampleWeightedIndexArrayBy(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) !?[N]usize {
    if (N == 0) return .{};
    if (items.len == 0) return null;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < N) return null;
    if (comptime N == 1) {
        if (state.count == 1) return .{state.single_index.?};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexArrayBy(random_source, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedIndexArrayByChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![N]usize {
    if (N == 0) return .{};
    if (N > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < N) return error.InvalidParameter;
    if (comptime N == 1) {
        if (state.count == 1) return .{state.single_index.?};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexArrayByChecked(random_source, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedIndexArrayU32By(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) !?[N]u32 {
    if (N == 0) return .{};
    if (items.len > std.math.maxInt(u32)) return error.InvalidParameter;
    if (items.len == 0) return null;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < N) return null;
    if (comptime N == 1) {
        if (state.count == 1) return .{@intCast(state.single_index.?)};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexArrayU32By(random_source, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedIndexArrayU32ByChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![N]u32 {
    if (N == 0) return .{};
    if (items.len > std.math.maxInt(u32) or N > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < N) return error.InvalidParameter;
    if (comptime N == 1) {
        if (state.count == 1) return .{@intCast(state.single_index.?)};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexArrayU32ByChecked(random_source, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedIndexArrayByIndex(comptime Weight: type, io: std.Io, comptime N: usize, length: usize, comptime weightFn: fn (usize) Weight) !?[N]usize {
    if (N == 0) return .{};
    if (length == 0) return null;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    if (state.count < N) return null;
    if (comptime N == 1) {
        if (state.count == 1) return .{state.single_index.?};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexArrayByIndex(random_source, Weight, N, length, weightFn);
}

pub fn sampleWeightedIndexArrayByIndexChecked(comptime Weight: type, io: std.Io, comptime N: usize, length: usize, comptime weightFn: fn (usize) Weight) ![N]usize {
    if (N == 0) return .{};
    if (N > length) return error.InvalidParameter;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    if (state.count < N) return error.InvalidParameter;
    if (comptime N == 1) {
        if (state.count == 1) return .{state.single_index.?};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexArrayByIndexChecked(random_source, Weight, N, length, weightFn);
}

pub fn sampleWeightedIndexArrayU32ByIndex(comptime Weight: type, io: std.Io, comptime N: usize, length: usize, comptime weightFn: fn (usize) Weight) !?[N]u32 {
    if (N == 0) return .{};
    if (length > std.math.maxInt(u32)) return error.InvalidParameter;
    if (length == 0) return null;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    if (state.count < N) return null;
    if (comptime N == 1) {
        if (state.count == 1) return .{@intCast(state.single_index.?)};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexArrayU32ByIndex(random_source, Weight, N, length, weightFn);
}

pub fn sampleWeightedIndexArrayU32ByIndexChecked(comptime Weight: type, io: std.Io, comptime N: usize, length: usize, comptime weightFn: fn (usize) Weight) ![N]u32 {
    if (N == 0) return .{};
    if (length > std.math.maxInt(u32) or N > length) return error.InvalidParameter;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    if (state.count < N) return error.InvalidParameter;
    if (comptime N == 1) {
        if (state.count == 1) return .{@intCast(state.single_index.?)};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndexArrayU32ByIndexChecked(random_source, Weight, N, length, weightFn);
}

pub fn sampleWeightedArrayBy(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) !?[N]T {
    if (N == 0) return .{};
    if (items.len == 0) return null;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < N) return null;
    if (comptime N == 1) {
        if (state.count == 1) return .{items[state.single_index.?]};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedArrayBy(random_source, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedArrayByChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![N]T {
    if (N == 0) return .{};
    if (N > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < N) return error.InvalidParameter;
    if (comptime N == 1) {
        if (state.count == 1) return .{items[state.single_index.?]};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedArrayByChecked(random_source, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedPtrArrayBy(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) !?[N]*const T {
    if (N == 0) return .{};
    if (items.len == 0) return null;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < N) return null;
    if (comptime N == 1) {
        if (state.count == 1) return .{&items[state.single_index.?]};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedPtrArrayBy(random_source, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedPtrArrayByChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![N]*const T {
    if (N == 0) return .{};
    if (N > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < N) return error.InvalidParameter;
    if (comptime N == 1) {
        if (state.count == 1) return .{&items[state.single_index.?]};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedPtrArrayByChecked(random_source, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedMutPtrArrayBy(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []T, comptime weightFn: fn (*const T) Weight) !?[N]*T {
    if (N == 0) return .{};
    if (items.len == 0) return null;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < N) return null;
    if (comptime N == 1) {
        if (state.count == 1) return .{&items[state.single_index.?]};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedMutPtrArrayBy(random_source, T, Weight, N, items, weightFn);
}

pub fn sampleWeightedMutPtrArrayByChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []T, comptime weightFn: fn (*const T) Weight) ![N]*T {
    if (N == 0) return .{};
    if (N > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < N) return error.InvalidParameter;
    if (comptime N == 1) {
        if (state.count == 1) return .{&items[state.single_index.?]};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedMutPtrArrayByChecked(random_source, T, Weight, N, items, weightFn);
}

pub fn sampleWeighted(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, weights: []const Weight, amount: usize) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveWeightState(Weight, weights);
    const count = @min(amount, state.count);
    if (count == 0) return allocator.alloc(T, 0);
    if (state.count == 1) return rootSingleItemByAlloc(T, allocator, items[state.single_index.?]);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeighted(allocator, random_source, T, Weight, items, weights, amount);
}

pub fn sampleWeightedChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, weights: []const Weight, amount: usize) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    if (amount > items.len) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1 and amount == 1) return rootSingleItemByAlloc(T, allocator, items[state.single_index.?]);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedChecked(allocator, random_source, T, Weight, items, weights, amount);
}

pub fn sampleWeightedBy(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize, comptime weightFn: fn (*const T) Weight) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    const count = @min(amount, state.count);
    if (count == 0) return allocator.alloc(T, 0);
    if (state.count == 1) return rootSingleItemByAlloc(T, allocator, items[state.single_index.?]);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedBy(allocator, random_source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedByChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize, comptime weightFn: fn (*const T) Weight) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);
    if (amount > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1 and amount == 1) return rootSingleItemByAlloc(T, allocator, items[state.single_index.?]);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedByChecked(allocator, random_source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedPtrsBy(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize, comptime weightFn: fn (*const T) Weight) ![]*const T {
    if (amount == 0) return allocator.alloc(*const T, 0);
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    const count = @min(amount, state.count);
    if (count == 0) return allocator.alloc(*const T, 0);
    if (state.count == 1) return rootSingleConstPtrByAlloc(T, allocator, &items[state.single_index.?]);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedPtrsBy(allocator, random_source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedPtrsByChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, amount: usize, comptime weightFn: fn (*const T) Weight) ![]*const T {
    if (amount == 0) return allocator.alloc(*const T, 0);
    if (amount > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1 and amount == 1) return rootSingleConstPtrByAlloc(T, allocator, &items[state.single_index.?]);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedPtrsByChecked(allocator, random_source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedMutPtrsBy(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []T, amount: usize, comptime weightFn: fn (*const T) Weight) ![]*T {
    if (amount == 0) return allocator.alloc(*T, 0);
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    const count = @min(amount, state.count);
    if (count == 0) return allocator.alloc(*T, 0);
    if (state.count == 1) return rootSingleMutPtrByAlloc(T, allocator, &items[state.single_index.?]);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedMutPtrsBy(allocator, random_source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedMutPtrsByChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []T, amount: usize, comptime weightFn: fn (*const T) Weight) ![]*T {
    if (amount == 0) return allocator.alloc(*T, 0);
    if (amount > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1 and amount == 1) return rootSingleMutPtrByAlloc(T, allocator, &items[state.single_index.?]);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedMutPtrsByChecked(allocator, random_source, T, Weight, items, amount, weightFn);
}

pub fn sampleWeightedByInto(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, out: []T, scratch_indices: []usize, scratch_keys: []f64, comptime weightFn: fn (*const T) Weight) !usize {
    if (out.len == 0) return 0;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    const count = @min(out.len, state.count);
    if (count == 0) return 0;
    if (state.count == 1) {
        out[0] = items[state.single_index.?];
        return 1;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedByInto(random_source, T, Weight, items, out, scratch_indices, scratch_keys, weightFn);
}

pub fn sampleWeightedByIntoChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, out: []T, scratch_indices: []usize, scratch_keys: []f64, comptime weightFn: fn (*const T) Weight) !void {
    if (out.len == 0) return;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < out.len) return error.InvalidParameter;
    if (state.count == 1) {
        out[0] = items[state.single_index.?];
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleWeightedByIntoChecked(random_source, T, Weight, items, out, scratch_indices, scratch_keys, weightFn);
}

pub fn sampleWeightedPtrsByInto(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, out: []*const T, scratch_indices: []usize, scratch_keys: []f64, comptime weightFn: fn (*const T) Weight) !usize {
    if (out.len == 0) return 0;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    const count = @min(out.len, state.count);
    if (count == 0) return 0;
    if (state.count == 1) {
        out[0] = &items[state.single_index.?];
        return 1;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedPtrsByInto(random_source, T, Weight, items, out, scratch_indices, scratch_keys, weightFn);
}

pub fn sampleWeightedPtrsByIntoChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, out: []*const T, scratch_indices: []usize, scratch_keys: []f64, comptime weightFn: fn (*const T) Weight) !void {
    if (out.len == 0) return;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < out.len) return error.InvalidParameter;
    if (state.count == 1) {
        out[0] = &items[state.single_index.?];
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleWeightedPtrsByIntoChecked(random_source, T, Weight, items, out, scratch_indices, scratch_keys, weightFn);
}

pub fn sampleWeightedMutPtrsByInto(comptime T: type, comptime Weight: type, io: std.Io, items: []T, out: []*T, scratch_indices: []usize, scratch_keys: []f64, comptime weightFn: fn (*const T) Weight) !usize {
    if (out.len == 0) return 0;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    const count = @min(out.len, state.count);
    if (count == 0) return 0;
    if (state.count == 1) {
        out[0] = &items[state.single_index.?];
        return 1;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedMutPtrsByInto(random_source, T, Weight, items, out, scratch_indices, scratch_keys, weightFn);
}

pub fn sampleWeightedMutPtrsByIntoChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []T, out: []*T, scratch_indices: []usize, scratch_keys: []f64, comptime weightFn: fn (*const T) Weight) !void {
    if (out.len == 0) return;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < out.len) return error.InvalidParameter;
    if (state.count == 1) {
        out[0] = &items[state.single_index.?];
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleWeightedMutPtrsByIntoChecked(random_source, T, Weight, items, out, scratch_indices, scratch_keys, weightFn);
}

pub fn sampleWeightedIndicesByInto(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, out: []usize, scratch_keys: []f64, comptime weightFn: fn (*const T) Weight) !usize {
    if (out.len == 0) return 0;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    const count = @min(out.len, state.count);
    if (count == 0) return 0;
    if (state.count == 1) {
        out[0] = state.single_index.?;
        return 1;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesByInto(random_source, T, Weight, items, out, scratch_keys, weightFn);
}

pub fn sampleWeightedIndicesByIntoChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, out: []usize, scratch_keys: []f64, comptime weightFn: fn (*const T) Weight) !void {
    if (out.len == 0) return;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > items.len) return error.InvalidParameter;
    const state = try rootPositiveItemStateBy(T, Weight, items, weightFn);
    if (state.count < out.len) return error.InvalidParameter;
    if (state.count == 1) {
        out[0] = state.single_index.?;
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleWeightedIndicesByIntoChecked(random_source, T, Weight, items, out, scratch_keys, weightFn);
}

pub fn sampleWeightedIndicesByIndexInto(comptime Weight: type, io: std.Io, length: usize, out: []usize, scratch_keys: []f64, comptime weightFn: fn (usize) Weight) !usize {
    if (out.len == 0) return 0;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (length == 0) return error.EmptyInput;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    const count = @min(out.len, state.count);
    if (count == 0) return 0;
    if (state.count == 1) {
        out[0] = state.single_index.?;
        return 1;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesByIndexInto(random_source, Weight, length, out, scratch_keys, weightFn);
}

pub fn sampleWeightedIndicesByIndexIntoChecked(comptime Weight: type, io: std.Io, length: usize, out: []usize, scratch_keys: []f64, comptime weightFn: fn (usize) Weight) !void {
    if (out.len == 0) return;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > length) return error.InvalidParameter;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    if (state.count < out.len) return error.InvalidParameter;
    if (state.count == 1) {
        out[0] = state.single_index.?;
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleWeightedIndicesByIndexIntoChecked(random_source, Weight, length, out, scratch_keys, weightFn);
}

pub fn sampleWeightedIndicesU32ByIndexInto(comptime Weight: type, io: std.Io, length: usize, out: []u32, scratch_keys: []f64, comptime weightFn: fn (usize) Weight) !usize {
    if (out.len == 0) return 0;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (length > std.math.maxInt(u32)) return error.InvalidParameter;
    if (length == 0) return error.EmptyInput;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    const count = @min(out.len, state.count);
    if (count == 0) return 0;
    if (state.count == 1) {
        out[0] = @intCast(state.single_index.?);
        return 1;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedIndicesU32ByIndexInto(random_source, Weight, length, out, scratch_keys, weightFn);
}

pub fn sampleWeightedIndicesU32ByIndexIntoChecked(comptime Weight: type, io: std.Io, length: usize, out: []u32, scratch_keys: []f64, comptime weightFn: fn (usize) Weight) !void {
    if (out.len == 0) return;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    if (length > std.math.maxInt(u32) or out.len > length) return error.InvalidParameter;
    const state = try rootPositiveIndexStateByIndex(Weight, length, weightFn);
    if (state.count < out.len) return error.InvalidParameter;
    if (state.count == 1) {
        out[0] = @intCast(state.single_index.?);
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleWeightedIndicesU32ByIndexIntoChecked(random_source, Weight, length, out, scratch_keys, weightFn);
}

pub fn sampleWeightedInto(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, weights: []const Weight, out: []T, scratch_indices: []usize, scratch_keys: []f64) !usize {
    if (out.len == 0) return 0;
    if (items.len != weights.len) return error.LengthMismatch;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;
    if (weights.len == 0) return error.EmptyInput;
    const state = try rootPositiveWeightState(Weight, weights);
    const count = @min(out.len, state.count);
    if (count == 0) return 0;
    if (state.count == 1) {
        out[0] = items[state.single_index.?];
        return 1;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedInto(random_source, T, Weight, items, weights, out, scratch_indices, scratch_keys);
}

pub fn sampleWeightedIntoChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, weights: []const Weight, out: []T, scratch_indices: []usize, scratch_keys: []f64) !void {
    if (out.len == 0) return;
    if (items.len != weights.len) return error.LengthMismatch;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > items.len) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < out.len) return error.InvalidParameter;
    if (state.count == 1) {
        out[0] = items[state.single_index.?];
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleWeightedIntoChecked(random_source, T, Weight, items, weights, out, scratch_indices, scratch_keys);
}

pub fn sampleWeightedPtrsInto(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, weights: []const Weight, out: []*const T, scratch_indices: []usize, scratch_keys: []f64) !usize {
    if (out.len == 0) return 0;
    if (items.len != weights.len) return error.LengthMismatch;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;
    if (weights.len == 0) return error.EmptyInput;
    const state = try rootPositiveWeightState(Weight, weights);
    const count = @min(out.len, state.count);
    if (count == 0) return 0;
    if (state.count == 1) {
        out[0] = &items[state.single_index.?];
        return 1;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedPtrsInto(random_source, T, Weight, items, weights, out, scratch_indices, scratch_keys);
}

pub fn sampleWeightedPtrsIntoChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, weights: []const Weight, out: []*const T, scratch_indices: []usize, scratch_keys: []f64) !void {
    if (out.len == 0) return;
    if (items.len != weights.len) return error.LengthMismatch;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > items.len) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < out.len) return error.InvalidParameter;
    if (state.count == 1) {
        out[0] = &items[state.single_index.?];
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleWeightedPtrsIntoChecked(random_source, T, Weight, items, weights, out, scratch_indices, scratch_keys);
}

pub fn sampleWeightedMutPtrsInto(comptime T: type, comptime Weight: type, io: std.Io, items: []T, weights: []const Weight, out: []*T, scratch_indices: []usize, scratch_keys: []f64) !usize {
    if (out.len == 0) return 0;
    if (items.len != weights.len) return error.LengthMismatch;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;
    if (weights.len == 0) return error.EmptyInput;
    const state = try rootPositiveWeightState(Weight, weights);
    const count = @min(out.len, state.count);
    if (count == 0) return 0;
    if (state.count == 1) {
        out[0] = &items[state.single_index.?];
        return 1;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedMutPtrsInto(random_source, T, Weight, items, weights, out, scratch_indices, scratch_keys);
}

pub fn sampleWeightedMutPtrsIntoChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []T, weights: []const Weight, out: []*T, scratch_indices: []usize, scratch_keys: []f64) !void {
    if (out.len == 0) return;
    if (items.len != weights.len) return error.LengthMismatch;
    if (scratch_indices.len < out.len or scratch_keys.len < out.len) return error.LengthMismatch;
    if (out.len > items.len) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < out.len) return error.InvalidParameter;
    if (state.count == 1) {
        out[0] = &items[state.single_index.?];
        return;
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.sampleWeightedMutPtrsIntoChecked(random_source, T, Weight, items, weights, out, scratch_indices, scratch_keys);
}

pub fn sampleWeightedArray(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, weights: []const Weight) !?[N]T {
    if (N == 0) return .{};
    if (items.len != weights.len) return error.LengthMismatch;
    if (items.len == 0) return null;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < N) return null;
    if (comptime N == 1) {
        if (state.count == 1) return .{items[state.single_index.?]};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedArray(random_source, T, Weight, N, items, weights);
}

pub fn sampleWeightedArrayChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, weights: []const Weight) ![N]T {
    if (N == 0) return .{};
    if (items.len != weights.len) return error.LengthMismatch;
    if (N > items.len) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < N) return error.InvalidParameter;
    if (comptime N == 1) {
        if (state.count == 1) return .{items[state.single_index.?]};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedArrayChecked(random_source, T, Weight, N, items, weights);
}

pub fn sampleWeightedPtrs(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, weights: []const Weight, amount: usize) ![]*const T {
    if (amount == 0) return allocator.alloc(*const T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveWeightState(Weight, weights);
    const count = @min(amount, state.count);
    if (count == 0) return allocator.alloc(*const T, 0);
    if (state.count == 1) return rootSingleConstPtrByAlloc(T, allocator, &items[state.single_index.?]);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedPtrs(allocator, random_source, T, Weight, items, weights, amount);
}

pub fn sampleWeightedPtrsChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []const T, weights: []const Weight, amount: usize) ![]*const T {
    if (amount == 0) return allocator.alloc(*const T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    if (amount > items.len) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1 and amount == 1) return rootSingleConstPtrByAlloc(T, allocator, &items[state.single_index.?]);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedPtrsChecked(allocator, random_source, T, Weight, items, weights, amount);
}

pub fn sampleWeightedPtrArray(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, weights: []const Weight) !?[N]*const T {
    if (N == 0) return .{};
    if (items.len != weights.len) return error.LengthMismatch;
    if (items.len == 0) return null;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < N) return null;
    if (comptime N == 1) {
        if (state.count == 1) return .{&items[state.single_index.?]};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedPtrArray(random_source, T, Weight, N, items, weights);
}

pub fn sampleWeightedPtrArrayChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, weights: []const Weight) ![N]*const T {
    if (N == 0) return .{};
    if (items.len != weights.len) return error.LengthMismatch;
    if (N > items.len) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < N) return error.InvalidParameter;
    if (comptime N == 1) {
        if (state.count == 1) return .{&items[state.single_index.?]};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedPtrArrayChecked(random_source, T, Weight, N, items, weights);
}

pub fn sampleWeightedMutPtrs(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []T, weights: []const Weight, amount: usize) ![]*T {
    if (amount == 0) return allocator.alloc(*T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    if (items.len == 0) return error.EmptyInput;
    const state = try rootPositiveWeightState(Weight, weights);
    const count = @min(amount, state.count);
    if (count == 0) return allocator.alloc(*T, 0);
    if (state.count == 1) return rootSingleMutPtrByAlloc(T, allocator, &items[state.single_index.?]);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedMutPtrs(allocator, random_source, T, Weight, items, weights, amount);
}

pub fn sampleWeightedMutPtrsChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, items: []T, weights: []const Weight, amount: usize) ![]*T {
    if (amount == 0) return allocator.alloc(*T, 0);
    if (items.len != weights.len) return error.LengthMismatch;
    if (amount > items.len) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < amount) return error.InvalidParameter;
    if (state.count == 1 and amount == 1) return rootSingleMutPtrByAlloc(T, allocator, &items[state.single_index.?]);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedMutPtrsChecked(allocator, random_source, T, Weight, items, weights, amount);
}

pub fn sampleWeightedMutPtrArray(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []T, weights: []const Weight) !?[N]*T {
    if (N == 0) return .{};
    if (items.len != weights.len) return error.LengthMismatch;
    if (items.len == 0) return null;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < N) return null;
    if (comptime N == 1) {
        if (state.count == 1) return .{&items[state.single_index.?]};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedMutPtrArray(random_source, T, Weight, N, items, weights);
}

pub fn sampleWeightedMutPtrArrayChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []T, weights: []const Weight) ![N]*T {
    if (N == 0) return .{};
    if (items.len != weights.len) return error.LengthMismatch;
    if (N > items.len) return error.InvalidParameter;
    const state = try rootPositiveWeightState(Weight, weights);
    if (state.count < N) return error.InvalidParameter;
    if (comptime N == 1) {
        if (state.count == 1) return .{&items[state.single_index.?]};
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.sampleWeightedMutPtrArrayChecked(random_source, T, Weight, N, items, weights);
}

pub fn chooseIterator(comptime T: type, io: std.Io, iterator: anytype) !?T {
    return try rootChooseIterator(T, io, iterator, .reservoir);
}

pub fn chooseIteratorChecked(comptime T: type, io: std.Io, iterator: anytype) !T {
    return (try chooseIterator(T, io, iterator)) orelse error.EmptyInput;
}

pub fn chooseIteratorHinted(comptime T: type, io: std.Io, iterator: anytype) !?T {
    return try rootChooseIterator(T, io, iterator, .hinted);
}

pub fn chooseIteratorHintedChecked(comptime T: type, io: std.Io, iterator: anytype) !T {
    return (try chooseIteratorHinted(T, io, iterator)) orelse error.EmptyInput;
}

pub fn chooseIteratorStable(comptime T: type, io: std.Io, iterator: anytype) !?T {
    return try chooseIterator(T, io, iterator);
}

pub fn chooseIteratorStableChecked(comptime T: type, io: std.Io, iterator: anytype) !T {
    return try chooseIteratorChecked(T, io, iterator);
}

pub fn chooseIteratorWeighted(comptime T: type, io: std.Io, iterator: anytype) !?T {
    const Pending = struct {
        item: T,
        weight: f64,
    };

    var pending: ?Pending = null;
    var result: ?T = null;
    var total: f64 = 0;
    var engine: ?SecurePrng = null;

    while (iterator.next()) |entry| {
        const weight = rootWeightAsF64(@TypeOf(entry.weight), entry.weight);
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight == 0) continue;

        if (pending == null and result == null) {
            pending = .{ .item = entry.item, .weight = weight };
            total = weight;
            continue;
        }

        if (engine == null) engine = try secure(io);
        const random_source = Rng.init(&engine.?);

        if (pending) |first| {
            _ = random_source.float(f64);
            result = first.item;
            pending = null;
        }

        total += weight;
        if (!std.math.isFinite(total)) return error.InvalidWeight;
        if (random_source.float(f64) * total < weight) result = entry.item;
    }

    if (pending) |only| return only.item;
    return result;
}

pub fn chooseIteratorWeightedChecked(comptime T: type, io: std.Io, iterator: anytype) !T {
    return (try chooseIteratorWeighted(T, io, iterator)) orelse error.EmptyInput;
}

pub fn sampleIterator(comptime T: type, io: std.Io, allocator: std.mem.Allocator, iterator: anytype, amount: usize) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);

    var reservoir = try std.ArrayList(T).initCapacity(allocator, amount);
    errdefer reservoir.deinit(allocator);

    while (reservoir.items.len < amount) {
        const item = iterator.next() orelse return reservoir.toOwnedSlice(allocator);
        try reservoir.append(allocator, item);
    }

    var seen = reservoir.items.len;
    var engine: ?SecurePrng = null;
    while (iterator.next()) |item| {
        seen += 1;
        if (engine == null) engine = try secure(io);
        const random_source = Rng.init(&engine.?);
        const index = random_source.uintLessThan(usize, seen);
        if (index < amount) reservoir.items[index] = item;
    }

    return reservoir.toOwnedSliceAssert();
}

pub fn sampleIteratorChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, iterator: anytype, amount: usize) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);

    const out = try allocator.alloc(T, amount);
    errdefer allocator.free(out);

    var filled: usize = 0;
    while (filled < amount) : (filled += 1) {
        out[filled] = iterator.next() orelse return error.InvalidParameter;
    }

    var seen = amount;
    var engine: ?SecurePrng = null;
    while (iterator.next()) |item| {
        seen += 1;
        if (engine == null) engine = try secure(io);
        const random_source = Rng.init(&engine.?);
        const index = random_source.uintLessThan(usize, seen);
        if (index < amount) out[index] = item;
    }

    return out;
}

pub fn sampleIteratorInto(comptime T: type, io: std.Io, iterator: anytype, out: []T) !usize {
    if (out.len == 0) return 0;

    var filled: usize = 0;
    while (filled < out.len) : (filled += 1) {
        out[filled] = iterator.next() orelse return filled;
    }

    var seen = out.len;
    var engine: ?SecurePrng = null;
    while (iterator.next()) |item| {
        seen += 1;
        if (engine == null) engine = try secure(io);
        const random_source = Rng.init(&engine.?);
        const index = random_source.uintLessThan(usize, seen);
        if (index < out.len) out[index] = item;
    }

    return out.len;
}

pub fn sampleIteratorFill(comptime T: type, io: std.Io, iterator: anytype, out: []T) !usize {
    return sampleIteratorInto(T, io, iterator, out);
}

pub fn sampleIteratorIntoChecked(comptime T: type, io: std.Io, iterator: anytype, out: []T) !void {
    const filled = try sampleIteratorInto(T, io, iterator, out);
    if (filled != out.len) return error.InvalidParameter;
}

pub fn sampleIteratorFillChecked(comptime T: type, io: std.Io, iterator: anytype, out: []T) !void {
    try sampleIteratorIntoChecked(T, io, iterator, out);
}

pub fn sampleIteratorArray(comptime T: type, io: std.Io, comptime N: usize, iterator: anytype) !?[N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    const filled = try sampleIteratorInto(T, io, iterator, &out);
    return if (filled == N) out else null;
}

pub fn sampleIteratorArrayChecked(comptime T: type, io: std.Io, comptime N: usize, iterator: anytype) ![N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    try sampleIteratorIntoChecked(T, io, iterator, &out);
    return out;
}

pub fn sampleIteratorWeighted(comptime T: type, io: std.Io, allocator: std.mem.Allocator, iterator: anytype, amount: usize) ![]T {
    return try rootSampleIteratorWeightedAlloc(T, io, allocator, iterator, amount, false);
}

pub fn sampleIteratorWeightedChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, iterator: anytype, amount: usize) ![]T {
    return try rootSampleIteratorWeightedAlloc(T, io, allocator, iterator, amount, true);
}

pub fn sampleIteratorWeightedInto(comptime T: type, io: std.Io, iterator: anytype, out: []T, scratch_keys: []f64) !usize {
    if (out.len == 0) return 0;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    return try rootSampleIteratorWeightedInto(T, io, iterator, out, scratch_keys[0..out.len], false);
}

pub fn sampleIteratorWeightedIntoChecked(comptime T: type, io: std.Io, iterator: anytype, out: []T, scratch_keys: []f64) !void {
    if (out.len == 0) return;
    if (scratch_keys.len < out.len) return error.LengthMismatch;
    const count = try rootSampleIteratorWeightedInto(T, io, iterator, out, scratch_keys[0..out.len], true);
    std.debug.assert(count == out.len);
}

pub fn sampleIteratorWeightedArray(comptime T: type, io: std.Io, comptime N: usize, iterator: anytype) !?[N]T {
    const candidates = (try rootSampleIteratorWeightedCandidateArray(T, io, N, iterator)) orelse return null;
    var out: [N]T = undefined;
    inline for (0..N) |i| out[i] = candidates[i].item;
    return out;
}

pub fn sampleIteratorWeightedArrayChecked(comptime T: type, io: std.Io, comptime N: usize, iterator: anytype) ![N]T {
    const candidates = (try rootSampleIteratorWeightedCandidateArray(T, io, N, iterator)) orelse return error.InvalidParameter;
    var out: [N]T = undefined;
    inline for (0..N) |i| out[i] = candidates[i].item;
    return out;
}

pub fn weightedIndex(io: std.Io, weights: []const f64) !?usize {
    switch (try rootWeightedIndexStateAllowEmpty(weights)) {
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
    switch (try rootWeightedIndexStateAllowEmpty(weights)) {
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
    if (count == 0) return allocator.alloc(?usize, 0);
    switch (try rootWeightedIndexStateAllowEmpty(weights)) {
        .empty => {
            const out = try allocator.alloc(?usize, count);
            @memset(out, @as(?usize, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?usize, count);
            @memset(out, @as(?usize, index));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?usize, count);
    errdefer allocator.free(out);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    random_source.fillWeightedIndex(out, weights);
    return out;
}

pub fn weightedIndexBatchChecked(io: std.Io, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]usize {
    if (count == 0) return allocator.alloc(usize, 0);
    switch (try rootWeightedIndexState(weights)) {
        .single => |index| {
            const out = try allocator.alloc(usize, count);
            @memset(out, index);
            return out;
        },
        .random => {},
        .empty => unreachable,
    }
    const out = try allocator.alloc(usize, count);
    errdefer allocator.free(out);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillWeightedIndexChecked(out, weights);
    return out;
}

pub fn weightedIndexArray(io: std.Io, comptime N: usize, weights: []const f64) !?[N]usize {
    var out: [N]usize = undefined;
    if (N == 0) return out;
    var nullable: [N]?usize = undefined;
    try fillWeightedIndex(io, &nullable, weights);
    for (nullable, 0..) |value, i| out[i] = value orelse return null;
    return out;
}

pub fn weightedIndexArrayChecked(io: std.Io, comptime N: usize, weights: []const f64) ![N]usize {
    var out: [N]usize = undefined;
    if (N == 0) return out;
    try fillWeightedIndexChecked(io, &out, weights);
    return out;
}

pub fn weightedIndexU32(io: std.Io, weights: []const f64) !?u32 {
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    switch (try rootWeightedIndexStateAllowEmpty(weights)) {
        .empty => return null,
        .single => |index| return @intCast(index),
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try random_source.weightedIndexU32(weights);
}

pub fn weightedIndexU32Checked(io: std.Io, weights: []const f64) !?u32 {
    return weightedIndexU32(io, weights);
}

pub fn weightedIndexByIndex(comptime Weight: type, io: std.Io, length: usize, comptime weightFn: fn (usize) Weight) !?usize {
    switch (try rootWeightedIndexStateByIndex(Weight, length, weightFn)) {
        .empty => return null,
        .single => |index| return index,
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.weightedIndexByIndex(random_source, Weight, length, weightFn);
}

pub fn weightedIndexByIndexChecked(comptime Weight: type, io: std.Io, length: usize, comptime weightFn: fn (usize) Weight) !usize {
    return (try weightedIndexByIndex(Weight, io, length, weightFn)) orelse error.EmptyInput;
}

pub fn weightedIndexBy(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, comptime weightFn: fn (*const T) Weight) !?usize {
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return null,
        .single => |index| return index,
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.weightedIndexBy(random_source, T, Weight, items, weightFn);
}

pub fn weightedIndexByChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, comptime weightFn: fn (*const T) Weight) !usize {
    return (try weightedIndexBy(T, Weight, io, items, weightFn)) orelse error.EmptyInput;
}

pub fn weightedIndexU32By(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, comptime weightFn: fn (*const T) Weight) !?u32 {
    if (items.len > std.math.maxInt(u32)) return error.InvalidParameter;
    const index = try weightedIndexBy(T, Weight, io, items, weightFn) orelse return null;
    return @intCast(index);
}

pub fn weightedIndexU32ByChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, comptime weightFn: fn (*const T) Weight) !u32 {
    return (try weightedIndexU32By(T, Weight, io, items, weightFn)) orelse error.EmptyInput;
}

pub fn weightedIndexU32ByIndex(comptime Weight: type, io: std.Io, length: usize, comptime weightFn: fn (usize) Weight) !?u32 {
    if (length > std.math.maxInt(u32)) return error.InvalidParameter;
    const index = try weightedIndexByIndex(Weight, io, length, weightFn) orelse return null;
    return @intCast(index);
}

pub fn weightedIndexU32ByIndexChecked(comptime Weight: type, io: std.Io, length: usize, comptime weightFn: fn (usize) Weight) !u32 {
    return (try weightedIndexU32ByIndex(Weight, io, length, weightFn)) orelse error.EmptyInput;
}

pub fn fillWeightedIndexBy(comptime T: type, comptime Weight: type, io: std.Io, dest: []?usize, items: []const T, comptime weightFn: fn (*const T) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
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
    try seq.fillWeightedIndexBy(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillWeightedIndexByChecked(comptime T: type, comptime Weight: type, io: std.Io, dest: []usize, items: []const T, comptime weightFn: fn (*const T) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(dest, index);
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillWeightedIndexByChecked(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillWeightedIndexU32By(comptime T: type, comptime Weight: type, io: std.Io, dest: []?u32, items: []const T, comptime weightFn: fn (*const T) Weight) !void {
    if (items.len > std.math.maxInt(u32)) return error.InvalidParameter;
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => {
            @memset(dest, @as(?u32, null));
            return;
        },
        .single => |index| {
            @memset(dest, @as(?u32, @intCast(index)));
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillWeightedIndexU32By(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillWeightedIndexU32ByChecked(comptime T: type, comptime Weight: type, io: std.Io, dest: []u32, items: []const T, comptime weightFn: fn (*const T) Weight) !void {
    if (items.len > std.math.maxInt(u32)) return error.InvalidParameter;
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(dest, @intCast(index));
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillWeightedIndexU32ByChecked(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillWeightedIndexByIndex(comptime Weight: type, io: std.Io, dest: []?usize, length: usize, comptime weightFn: fn (usize) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateByIndex(Weight, length, weightFn)) {
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
    try seq.fillWeightedIndexByIndex(random_source, Weight, dest, length, weightFn);
}

pub fn fillWeightedIndexByIndexChecked(comptime Weight: type, io: std.Io, dest: []usize, length: usize, comptime weightFn: fn (usize) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateByIndex(Weight, length, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(dest, index);
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillWeightedIndexByIndexChecked(random_source, Weight, dest, length, weightFn);
}

pub fn fillWeightedIndexU32ByIndex(comptime Weight: type, io: std.Io, dest: []?u32, length: usize, comptime weightFn: fn (usize) Weight) !void {
    if (length > std.math.maxInt(u32)) return error.InvalidParameter;
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateByIndex(Weight, length, weightFn)) {
        .empty => {
            @memset(dest, @as(?u32, null));
            return;
        },
        .single => |index| {
            @memset(dest, @as(?u32, @intCast(index)));
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillWeightedIndexU32ByIndex(random_source, Weight, dest, length, weightFn);
}

pub fn fillWeightedIndexU32ByIndexChecked(comptime Weight: type, io: std.Io, dest: []u32, length: usize, comptime weightFn: fn (usize) Weight) !void {
    if (length > std.math.maxInt(u32)) return error.InvalidParameter;
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateByIndex(Weight, length, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(dest, @intCast(index));
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillWeightedIndexU32ByIndexChecked(random_source, Weight, dest, length, weightFn);
}

pub fn weightedIndexBatchBy(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![]?usize {
    if (count == 0) return allocator.alloc(?usize, 0);
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => {
            const out = try allocator.alloc(?usize, count);
            @memset(out, @as(?usize, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?usize, count);
            @memset(out, @as(?usize, index));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?usize, count);
    errdefer allocator.free(out);
    try fillWeightedIndexBy(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn weightedIndexBatchByChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![]usize {
    if (count == 0) return allocator.alloc(usize, 0);
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            const out = try allocator.alloc(usize, count);
            @memset(out, index);
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(usize, count);
    errdefer allocator.free(out);
    try fillWeightedIndexByChecked(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn weightedIndexU32BatchBy(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![]?u32 {
    if (count == 0) return allocator.alloc(?u32, 0);
    if (items.len > std.math.maxInt(u32)) return error.InvalidParameter;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => {
            const out = try allocator.alloc(?u32, count);
            @memset(out, @as(?u32, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?u32, count);
            @memset(out, @as(?u32, @intCast(index)));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?u32, count);
    errdefer allocator.free(out);
    try fillWeightedIndexU32By(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn weightedIndexU32BatchByChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![]u32 {
    if (count == 0) return allocator.alloc(u32, 0);
    if (items.len > std.math.maxInt(u32)) return error.InvalidParameter;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            const out = try allocator.alloc(u32, count);
            @memset(out, @intCast(index));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(u32, count);
    errdefer allocator.free(out);
    try fillWeightedIndexU32ByChecked(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn weightedIndexBatchByIndex(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, length: usize, comptime weightFn: fn (usize) Weight) ![]?usize {
    const out = try allocator.alloc(?usize, count);
    errdefer allocator.free(out);
    try fillWeightedIndexByIndex(Weight, io, out, length, weightFn);
    return out;
}

pub fn weightedIndexBatchByIndexChecked(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, length: usize, comptime weightFn: fn (usize) Weight) ![]usize {
    if (count == 0) return allocator.alloc(usize, 0);
    const out = try allocator.alloc(usize, count);
    errdefer allocator.free(out);
    try fillWeightedIndexByIndexChecked(Weight, io, out, length, weightFn);
    return out;
}

pub fn weightedIndexU32BatchByIndex(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, length: usize, comptime weightFn: fn (usize) Weight) ![]?u32 {
    if (count == 0) return allocator.alloc(?u32, 0);
    const out = try allocator.alloc(?u32, count);
    errdefer allocator.free(out);
    try fillWeightedIndexU32ByIndex(Weight, io, out, length, weightFn);
    return out;
}

pub fn weightedIndexU32BatchByIndexChecked(comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, length: usize, comptime weightFn: fn (usize) Weight) ![]u32 {
    if (count == 0) return allocator.alloc(u32, 0);
    const out = try allocator.alloc(u32, count);
    errdefer allocator.free(out);
    try fillWeightedIndexU32ByIndexChecked(Weight, io, out, length, weightFn);
    return out;
}

pub fn weightedIndexArrayBy(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) !?[N]usize {
    var out: [N]usize = undefined;
    if (N == 0) return out;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return null,
        .single => |index| {
            @memset(out[0..], index);
            return out;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.weightedIndexArrayBy(random_source, T, Weight, N, items, weightFn);
}

pub fn weightedIndexArrayByChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![N]usize {
    var out: [N]usize = undefined;
    if (N == 0) return out;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(out[0..], index);
            return out;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.weightedIndexArrayByChecked(random_source, T, Weight, N, items, weightFn);
}

pub fn weightedIndexU32ArrayBy(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) !?[N]u32 {
    var out: [N]u32 = undefined;
    if (N == 0) return out;
    if (items.len > std.math.maxInt(u32)) return error.InvalidParameter;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return null,
        .single => |index| {
            @memset(out[0..], @intCast(index));
            return out;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.weightedIndexU32ArrayBy(random_source, T, Weight, N, items, weightFn);
}

pub fn weightedIndexU32ArrayByChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![N]u32 {
    var out: [N]u32 = undefined;
    if (N == 0) return out;
    if (items.len > std.math.maxInt(u32)) return error.InvalidParameter;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(out[0..], @intCast(index));
            return out;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.weightedIndexU32ArrayByChecked(random_source, T, Weight, N, items, weightFn);
}

pub fn weightedIndexArrayByIndex(comptime Weight: type, io: std.Io, comptime N: usize, length: usize, comptime weightFn: fn (usize) Weight) !?[N]usize {
    var out: [N]usize = undefined;
    if (N == 0) return out;
    switch (try rootWeightedIndexStateByIndex(Weight, length, weightFn)) {
        .empty => return null,
        .single => |index| {
            @memset(out[0..], index);
            return out;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.weightedIndexArrayByIndex(random_source, Weight, N, length, weightFn);
}

pub fn weightedIndexArrayByIndexChecked(comptime Weight: type, io: std.Io, comptime N: usize, length: usize, comptime weightFn: fn (usize) Weight) ![N]usize {
    var out: [N]usize = undefined;
    if (N == 0) return out;
    switch (try rootWeightedIndexStateByIndex(Weight, length, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(out[0..], index);
            return out;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.weightedIndexArrayByIndexChecked(random_source, Weight, N, length, weightFn);
}

pub fn weightedIndexU32ArrayByIndex(comptime Weight: type, io: std.Io, comptime N: usize, length: usize, comptime weightFn: fn (usize) Weight) !?[N]u32 {
    var out: [N]u32 = undefined;
    if (N == 0) return out;
    if (length > std.math.maxInt(u32)) return error.InvalidParameter;
    switch (try rootWeightedIndexStateByIndex(Weight, length, weightFn)) {
        .empty => return null,
        .single => |index| {
            @memset(out[0..], @intCast(index));
            return out;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.weightedIndexU32ArrayByIndex(random_source, Weight, N, length, weightFn);
}

pub fn weightedIndexU32ArrayByIndexChecked(comptime Weight: type, io: std.Io, comptime N: usize, length: usize, comptime weightFn: fn (usize) Weight) ![N]u32 {
    var out: [N]u32 = undefined;
    if (N == 0) return out;
    if (length > std.math.maxInt(u32)) return error.InvalidParameter;
    switch (try rootWeightedIndexStateByIndex(Weight, length, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(out[0..], @intCast(index));
            return out;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    return try seq.weightedIndexU32ArrayByIndexChecked(random_source, Weight, N, length, weightFn);
}

pub fn fillWeightedIndexU32(io: std.Io, dest: []?u32, weights: []const f64) !void {
    if (dest.len == 0) return;
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    switch (try rootWeightedIndexStateAllowEmpty(weights)) {
        .empty => {
            @memset(dest, @as(?u32, null));
            return;
        },
        .single => |index| {
            @memset(dest, @as(?u32, @intCast(index)));
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillWeightedIndexU32(dest, weights);
}

pub fn fillWeightedIndexU32Checked(io: std.Io, dest: []u32, weights: []const f64) !void {
    if (dest.len == 0) return;
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    switch (try rootWeightedIndexState(weights)) {
        .single => |index| {
            @memset(dest, @intCast(index));
            return;
        },
        .random => {},
        .empty => unreachable,
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillWeightedIndexU32Checked(dest, weights);
}

pub fn weightedIndexU32Batch(io: std.Io, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]?u32 {
    if (count == 0) return allocator.alloc(?u32, 0);
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    switch (try rootWeightedIndexStateAllowEmpty(weights)) {
        .empty => {
            const out = try allocator.alloc(?u32, count);
            @memset(out, @as(?u32, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?u32, count);
            @memset(out, @as(?u32, @intCast(index)));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?u32, count);
    errdefer allocator.free(out);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillWeightedIndexU32(out, weights);
    return out;
}

pub fn weightedIndexU32BatchChecked(io: std.Io, allocator: std.mem.Allocator, count: usize, weights: []const f64) ![]u32 {
    if (count == 0) return allocator.alloc(u32, 0);
    if (weights.len > std.math.maxInt(u32)) return error.InvalidParameter;
    switch (try rootWeightedIndexState(weights)) {
        .single => |index| {
            const out = try allocator.alloc(u32, count);
            @memset(out, @intCast(index));
            return out;
        },
        .random => {},
        .empty => unreachable,
    }
    const out = try allocator.alloc(u32, count);
    errdefer allocator.free(out);
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try random_source.fillWeightedIndexU32Checked(out, weights);
    return out;
}

pub fn weightedIndexU32Array(io: std.Io, comptime N: usize, weights: []const f64) !?[N]u32 {
    var out: [N]u32 = undefined;
    if (N == 0) return out;
    var nullable: [N]?u32 = undefined;
    try fillWeightedIndexU32(io, &nullable, weights);
    for (nullable, 0..) |value, i| out[i] = value orelse return null;
    return out;
}

pub fn weightedIndexU32ArrayChecked(io: std.Io, comptime N: usize, weights: []const f64) ![N]u32 {
    var out: [N]u32 = undefined;
    if (N == 0) return out;
    try fillWeightedIndexU32Checked(io, &out, weights);
    return out;
}

pub fn chooseWeighted(comptime T: type, io: std.Io, items: []const T, weights: []const f64) !?T {
    if (items.len != weights.len) return error.InvalidParameter;
    const index = try weightedIndexChecked(io, weights) orelse return null;
    return items[index];
}

pub fn chooseWeightedChecked(comptime T: type, io: std.Io, items: []const T, weights: []const f64) !T {
    if (items.len != weights.len) return error.InvalidParameter;
    const index = try weightedIndexChecked(io, weights) orelse return error.EmptyRange;
    return items[index];
}

pub fn chooseWeightedBy(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, comptime weightFn: fn (*const T) Weight) !?T {
    const index = try weightedIndexBy(T, Weight, io, items, weightFn) orelse return null;
    return items[index];
}

pub fn chooseWeightedByChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, comptime weightFn: fn (*const T) Weight) !T {
    return (try chooseWeightedBy(T, Weight, io, items, weightFn)) orelse error.EmptyInput;
}

pub fn chooseWeightedConstPtrBy(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, comptime weightFn: fn (*const T) Weight) !?*const T {
    const index = try weightedIndexBy(T, Weight, io, items, weightFn) orelse return null;
    return &items[index];
}

pub fn chooseWeightedConstPtrByChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, comptime weightFn: fn (*const T) Weight) !*const T {
    return (try chooseWeightedConstPtrBy(T, Weight, io, items, weightFn)) orelse error.EmptyInput;
}

pub fn chooseWeightedPtrBy(comptime T: type, comptime Weight: type, io: std.Io, items: []T, comptime weightFn: fn (*const T) Weight) !?*T {
    const index = try weightedIndexBy(T, Weight, io, items, weightFn) orelse return null;
    return &items[index];
}

pub fn chooseWeightedPtrByChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []T, comptime weightFn: fn (*const T) Weight) !*T {
    return (try chooseWeightedPtrBy(T, Weight, io, items, weightFn)) orelse error.EmptyInput;
}

pub fn chooseWeightedByIndex(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, comptime weightFn: fn (usize) Weight) !?T {
    const index = try weightedIndexByIndex(Weight, io, items.len, weightFn) orelse return null;
    return items[index];
}

pub fn chooseWeightedByIndexChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, comptime weightFn: fn (usize) Weight) !T {
    return (try chooseWeightedByIndex(T, Weight, io, items, weightFn)) orelse error.EmptyInput;
}

pub fn chooseWeightedConstPtrByIndex(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, comptime weightFn: fn (usize) Weight) !?*const T {
    const index = try weightedIndexByIndex(Weight, io, items.len, weightFn) orelse return null;
    return &items[index];
}

pub fn chooseWeightedConstPtrByIndexChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []const T, comptime weightFn: fn (usize) Weight) !*const T {
    return (try chooseWeightedConstPtrByIndex(T, Weight, io, items, weightFn)) orelse error.EmptyInput;
}

pub fn chooseWeightedPtrByIndex(comptime T: type, comptime Weight: type, io: std.Io, items: []T, comptime weightFn: fn (usize) Weight) !?*T {
    const index = try weightedIndexByIndex(Weight, io, items.len, weightFn) orelse return null;
    return &items[index];
}

pub fn chooseWeightedPtrByIndexChecked(comptime T: type, comptime Weight: type, io: std.Io, items: []T, comptime weightFn: fn (usize) Weight) !*T {
    return (try chooseWeightedPtrByIndex(T, Weight, io, items, weightFn)) orelse error.EmptyInput;
}

pub fn fillChooseWeightedBy(comptime T: type, comptime Weight: type, io: std.Io, dest: []?T, items: []const T, comptime weightFn: fn (*const T) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => {
            @memset(dest, @as(?T, null));
            return;
        },
        .single => |index| {
            @memset(dest, @as(?T, items[index]));
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillChooseWeightedBy(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillChooseWeightedByChecked(comptime T: type, comptime Weight: type, io: std.Io, dest: []T, items: []const T, comptime weightFn: fn (*const T) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(dest, items[index]);
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillChooseWeightedByChecked(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillChooseWeightedByIndex(comptime T: type, comptime Weight: type, io: std.Io, dest: []?T, items: []const T, comptime weightFn: fn (usize) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateByIndex(Weight, items.len, weightFn)) {
        .empty => {
            @memset(dest, @as(?T, null));
            return;
        },
        .single => |index| {
            @memset(dest, @as(?T, items[index]));
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillChooseWeightedByIndex(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillChooseWeightedByIndexChecked(comptime T: type, comptime Weight: type, io: std.Io, dest: []T, items: []const T, comptime weightFn: fn (usize) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateByIndex(Weight, items.len, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(dest, items[index]);
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillChooseWeightedByIndexChecked(random_source, T, Weight, dest, items, weightFn);
}

pub fn chooseWeightedBatchByIndex(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, comptime weightFn: fn (usize) Weight) ![]?T {
    if (count == 0) return allocator.alloc(?T, 0);
    switch (try rootWeightedIndexStateByIndex(Weight, items.len, weightFn)) {
        .empty => {
            const out = try allocator.alloc(?T, count);
            @memset(out, @as(?T, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?T, count);
            @memset(out, @as(?T, items[index]));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedByIndex(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn chooseWeightedBatchByIndexChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, comptime weightFn: fn (usize) Weight) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    switch (try rootWeightedIndexStateByIndex(Weight, items.len, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            const out = try allocator.alloc(T, count);
            @memset(out, items[index]);
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedByIndexChecked(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn chooseWeightedBatchBy(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![]?T {
    if (count == 0) return allocator.alloc(?T, 0);
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => {
            const out = try allocator.alloc(?T, count);
            @memset(out, @as(?T, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?T, count);
            @memset(out, @as(?T, items[index]));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedBy(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn chooseWeightedBatchByChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            const out = try allocator.alloc(T, count);
            @memset(out, items[index]);
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedByChecked(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn chooseWeightedValueArrayBy(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) !?[N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    var nullable: [N]?T = undefined;
    try fillChooseWeightedBy(T, Weight, io, &nullable, items, weightFn);
    for (nullable, 0..) |value, i| out[i] = value orelse return null;
    return out;
}

pub fn chooseWeightedValueArrayByChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    try fillChooseWeightedByChecked(T, Weight, io, &out, items, weightFn);
    return out;
}

pub fn chooseWeightedValueArrayByIndex(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (usize) Weight) !?[N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    var nullable: [N]?T = undefined;
    try fillChooseWeightedByIndex(T, Weight, io, &nullable, items, weightFn);
    for (nullable, 0..) |value, i| out[i] = value orelse return null;
    return out;
}

pub fn chooseWeightedValueArrayByIndexChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (usize) Weight) ![N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    try fillChooseWeightedByIndexChecked(T, Weight, io, &out, items, weightFn);
    return out;
}

pub fn fillChooseWeightedConstPtrBy(comptime T: type, comptime Weight: type, io: std.Io, dest: []?*const T, items: []const T, comptime weightFn: fn (*const T) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => {
            @memset(dest, @as(?*const T, null));
            return;
        },
        .single => |index| {
            @memset(dest, @as(?*const T, &items[index]));
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillChooseWeightedConstPtrBy(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillChooseWeightedConstPtrByChecked(comptime T: type, comptime Weight: type, io: std.Io, dest: []*const T, items: []const T, comptime weightFn: fn (*const T) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(dest, &items[index]);
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillChooseWeightedConstPtrByChecked(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillChooseWeightedPtrBy(comptime T: type, comptime Weight: type, io: std.Io, dest: []?*T, items: []T, comptime weightFn: fn (*const T) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => {
            @memset(dest, @as(?*T, null));
            return;
        },
        .single => |index| {
            @memset(dest, @as(?*T, &items[index]));
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillChooseWeightedPtrBy(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillChooseWeightedPtrByChecked(comptime T: type, comptime Weight: type, io: std.Io, dest: []*T, items: []T, comptime weightFn: fn (*const T) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(dest, &items[index]);
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillChooseWeightedPtrByChecked(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillChooseWeightedConstPtrByIndex(comptime T: type, comptime Weight: type, io: std.Io, dest: []?*const T, items: []const T, comptime weightFn: fn (usize) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateByIndex(Weight, items.len, weightFn)) {
        .empty => {
            @memset(dest, @as(?*const T, null));
            return;
        },
        .single => |index| {
            @memset(dest, @as(?*const T, &items[index]));
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillChooseWeightedConstPtrByIndex(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillChooseWeightedConstPtrByIndexChecked(comptime T: type, comptime Weight: type, io: std.Io, dest: []*const T, items: []const T, comptime weightFn: fn (usize) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateByIndex(Weight, items.len, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(dest, &items[index]);
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillChooseWeightedConstPtrByIndexChecked(random_source, T, Weight, dest, items, weightFn);
}

pub fn chooseWeightedConstPtrBatchByIndex(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, comptime weightFn: fn (usize) Weight) ![]?*const T {
    if (count == 0) return allocator.alloc(?*const T, 0);
    switch (try rootWeightedIndexStateByIndex(Weight, items.len, weightFn)) {
        .empty => {
            const out = try allocator.alloc(?*const T, count);
            @memset(out, @as(?*const T, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?*const T, count);
            @memset(out, @as(?*const T, &items[index]));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?*const T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedConstPtrByIndex(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn chooseWeightedConstPtrBatchByIndexChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, comptime weightFn: fn (usize) Weight) ![]*const T {
    if (count == 0) return allocator.alloc(*const T, 0);
    switch (try rootWeightedIndexStateByIndex(Weight, items.len, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            const out = try allocator.alloc(*const T, count);
            @memset(out, &items[index]);
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(*const T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedConstPtrByIndexChecked(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn chooseWeightedConstPtrBatchBy(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![]?*const T {
    if (count == 0) return allocator.alloc(?*const T, 0);
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => {
            const out = try allocator.alloc(?*const T, count);
            @memset(out, @as(?*const T, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?*const T, count);
            @memset(out, @as(?*const T, &items[index]));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?*const T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedConstPtrBy(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn chooseWeightedConstPtrBatchByChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![]*const T {
    if (count == 0) return allocator.alloc(*const T, 0);
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            const out = try allocator.alloc(*const T, count);
            @memset(out, &items[index]);
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(*const T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedConstPtrByChecked(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn chooseWeightedConstPtrArrayBy(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) !?[N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    var nullable: [N]?*const T = undefined;
    try fillChooseWeightedConstPtrBy(T, Weight, io, &nullable, items, weightFn);
    for (nullable, 0..) |ptr, i| out[i] = ptr orelse return null;
    return out;
}

pub fn chooseWeightedConstPtrArrayByChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (*const T) Weight) ![N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    try fillChooseWeightedConstPtrByChecked(T, Weight, io, &out, items, weightFn);
    return out;
}

pub fn chooseWeightedConstPtrArrayByIndex(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (usize) Weight) !?[N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    var nullable: [N]?*const T = undefined;
    try fillChooseWeightedConstPtrByIndex(T, Weight, io, &nullable, items, weightFn);
    for (nullable, 0..) |ptr, i| out[i] = ptr orelse return null;
    return out;
}

pub fn chooseWeightedConstPtrArrayByIndexChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []const T, comptime weightFn: fn (usize) Weight) ![N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    try fillChooseWeightedConstPtrByIndexChecked(T, Weight, io, &out, items, weightFn);
    return out;
}

pub fn fillChooseWeightedPtrByIndex(comptime T: type, comptime Weight: type, io: std.Io, dest: []?*T, items: []T, comptime weightFn: fn (usize) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateByIndex(Weight, items.len, weightFn)) {
        .empty => {
            @memset(dest, @as(?*T, null));
            return;
        },
        .single => |index| {
            @memset(dest, @as(?*T, &items[index]));
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillChooseWeightedPtrByIndex(random_source, T, Weight, dest, items, weightFn);
}

pub fn fillChooseWeightedPtrByIndexChecked(comptime T: type, comptime Weight: type, io: std.Io, dest: []*T, items: []T, comptime weightFn: fn (usize) Weight) !void {
    if (dest.len == 0) return;
    switch (try rootWeightedIndexStateByIndex(Weight, items.len, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            @memset(dest, &items[index]);
            return;
        },
        .random => {},
    }
    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    try seq.fillChooseWeightedPtrByIndexChecked(random_source, T, Weight, dest, items, weightFn);
}

pub fn chooseWeightedPtrBatchByIndex(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []T, comptime weightFn: fn (usize) Weight) ![]?*T {
    if (count == 0) return allocator.alloc(?*T, 0);
    switch (try rootWeightedIndexStateByIndex(Weight, items.len, weightFn)) {
        .empty => {
            const out = try allocator.alloc(?*T, count);
            @memset(out, @as(?*T, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?*T, count);
            @memset(out, @as(?*T, &items[index]));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?*T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedPtrByIndex(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn chooseWeightedPtrBatchByIndexChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []T, comptime weightFn: fn (usize) Weight) ![]*T {
    if (count == 0) return allocator.alloc(*T, 0);
    switch (try rootWeightedIndexStateByIndex(Weight, items.len, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            const out = try allocator.alloc(*T, count);
            @memset(out, &items[index]);
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(*T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedPtrByIndexChecked(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn chooseWeightedPtrBatchBy(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []T, comptime weightFn: fn (*const T) Weight) ![]?*T {
    if (count == 0) return allocator.alloc(?*T, 0);
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => {
            const out = try allocator.alloc(?*T, count);
            @memset(out, @as(?*T, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?*T, count);
            @memset(out, @as(?*T, &items[index]));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?*T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedPtrBy(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn chooseWeightedPtrBatchByChecked(comptime T: type, comptime Weight: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []T, comptime weightFn: fn (*const T) Weight) ![]*T {
    if (count == 0) return allocator.alloc(*T, 0);
    switch (try rootWeightedIndexStateBy(T, Weight, items, weightFn)) {
        .empty => return error.EmptyInput,
        .single => |index| {
            const out = try allocator.alloc(*T, count);
            @memset(out, &items[index]);
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(*T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedPtrByChecked(T, Weight, io, out, items, weightFn);
    return out;
}

pub fn chooseWeightedPtrArrayBy(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []T, comptime weightFn: fn (*const T) Weight) !?[N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    var nullable: [N]?*T = undefined;
    try fillChooseWeightedPtrBy(T, Weight, io, &nullable, items, weightFn);
    for (nullable, 0..) |ptr, i| out[i] = ptr orelse return null;
    return out;
}

pub fn chooseWeightedPtrArrayByChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []T, comptime weightFn: fn (*const T) Weight) ![N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    try fillChooseWeightedPtrByChecked(T, Weight, io, &out, items, weightFn);
    return out;
}

pub fn chooseWeightedPtrArrayByIndex(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []T, comptime weightFn: fn (usize) Weight) !?[N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    var nullable: [N]?*T = undefined;
    try fillChooseWeightedPtrByIndex(T, Weight, io, &nullable, items, weightFn);
    for (nullable, 0..) |ptr, i| out[i] = ptr orelse return null;
    return out;
}

pub fn chooseWeightedPtrArrayByIndexChecked(comptime T: type, comptime Weight: type, io: std.Io, comptime N: usize, items: []T, comptime weightFn: fn (usize) Weight) ![N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    try fillChooseWeightedPtrByIndexChecked(T, Weight, io, &out, items, weightFn);
    return out;
}

pub fn fillChooseWeighted(comptime T: type, io: std.Io, dest: []?T, items: []const T, weights: []const f64) !void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.InvalidParameter;
    var indices: [64]?usize = undefined;
    if (dest.len <= indices.len) {
        try fillWeightedIndex(io, indices[0..dest.len], weights);
        for (dest, indices[0..dest.len]) |*item, index| item.* = if (index) |i| items[i] else null;
        return;
    }
    for (dest) |*item| item.* = try chooseWeighted(T, io, items, weights);
}

pub fn fillChooseWeightedChecked(comptime T: type, io: std.Io, dest: []T, items: []const T, weights: []const f64) !void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.InvalidParameter;
    var indices: [64]usize = undefined;
    if (dest.len <= indices.len) {
        try fillWeightedIndexChecked(io, indices[0..dest.len], weights);
        for (dest, indices[0..dest.len]) |*item, index| item.* = items[index];
        return;
    }
    for (dest) |*item| item.* = try chooseWeightedChecked(T, io, items, weights);
}

pub fn chooseWeightedBatch(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, weights: []const f64) ![]?T {
    if (count == 0) return allocator.alloc(?T, 0);
    if (items.len != weights.len) return error.InvalidParameter;
    switch (try rootWeightedIndexStateAllowEmpty(weights)) {
        .empty => {
            const out = try allocator.alloc(?T, count);
            @memset(out, @as(?T, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?T, count);
            @memset(out, @as(?T, items[index]));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?T, count);
    errdefer allocator.free(out);
    try fillChooseWeighted(T, io, out, items, weights);
    return out;
}

pub fn chooseWeightedBatchChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, weights: []const f64) ![]T {
    if (count == 0) return allocator.alloc(T, 0);
    if (items.len != weights.len) return error.InvalidParameter;
    switch (try rootWeightedIndexState(weights)) {
        .single => |index| {
            const out = try allocator.alloc(T, count);
            @memset(out, items[index]);
            return out;
        },
        .random => {},
        .empty => unreachable,
    }
    const out = try allocator.alloc(T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedChecked(T, io, out, items, weights);
    return out;
}

pub fn chooseWeightedValueArray(comptime T: type, io: std.Io, comptime N: usize, items: []const T, weights: []const f64) !?[N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    if (items.len != weights.len) return error.InvalidParameter;
    const indices = try weightedIndexArray(io, N, weights) orelse return null;
    for (&out, indices) |*item, index| item.* = items[index];
    return out;
}

pub fn chooseWeightedValueArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []const T, weights: []const f64) ![N]T {
    var out: [N]T = undefined;
    if (N == 0) return out;
    if (items.len != weights.len) return error.InvalidParameter;
    const indices = try weightedIndexArrayChecked(io, N, weights);
    for (&out, indices) |*item, index| item.* = items[index];
    return out;
}

pub fn chooseWeightedConstPtr(comptime T: type, io: std.Io, items: []const T, weights: []const f64) !?*const T {
    if (items.len != weights.len) return error.InvalidParameter;
    const index = try weightedIndexChecked(io, weights) orelse return null;
    return &items[index];
}

pub fn chooseWeightedConstPtrChecked(comptime T: type, io: std.Io, items: []const T, weights: []const f64) !*const T {
    if (items.len != weights.len) return error.InvalidParameter;
    const index = try weightedIndexChecked(io, weights) orelse return error.EmptyRange;
    return &items[index];
}

pub fn fillChooseWeightedConstPtr(comptime T: type, io: std.Io, dest: []?*const T, items: []const T, weights: []const f64) !void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.InvalidParameter;
    var indices: [64]?usize = undefined;
    if (dest.len <= indices.len) {
        try fillWeightedIndex(io, indices[0..dest.len], weights);
        for (dest, indices[0..dest.len]) |*item, index| item.* = if (index) |i| &items[i] else null;
        return;
    }
    for (dest) |*item| item.* = try chooseWeightedConstPtr(T, io, items, weights);
}

pub fn fillChooseWeightedConstPtrChecked(comptime T: type, io: std.Io, dest: []*const T, items: []const T, weights: []const f64) !void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.InvalidParameter;
    var indices: [64]usize = undefined;
    if (dest.len <= indices.len) {
        try fillWeightedIndexChecked(io, indices[0..dest.len], weights);
        for (dest, indices[0..dest.len]) |*item, index| item.* = &items[index];
        return;
    }
    for (dest) |*item| item.* = try chooseWeightedConstPtrChecked(T, io, items, weights);
}

pub fn chooseWeightedConstPtrBatch(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, weights: []const f64) ![]?*const T {
    if (count == 0) return allocator.alloc(?*const T, 0);
    if (items.len != weights.len) return error.InvalidParameter;
    switch (try rootWeightedIndexStateAllowEmpty(weights)) {
        .empty => {
            const out = try allocator.alloc(?*const T, count);
            @memset(out, @as(?*const T, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?*const T, count);
            @memset(out, @as(?*const T, &items[index]));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?*const T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedConstPtr(T, io, out, items, weights);
    return out;
}

pub fn chooseWeightedConstPtrBatchChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []const T, weights: []const f64) ![]*const T {
    if (count == 0) return allocator.alloc(*const T, 0);
    if (items.len != weights.len) return error.InvalidParameter;
    switch (try rootWeightedIndexState(weights)) {
        .single => |index| {
            const out = try allocator.alloc(*const T, count);
            @memset(out, &items[index]);
            return out;
        },
        .random => {},
        .empty => unreachable,
    }
    const out = try allocator.alloc(*const T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedConstPtrChecked(T, io, out, items, weights);
    return out;
}

pub fn chooseWeightedConstPtrArray(comptime T: type, io: std.Io, comptime N: usize, items: []const T, weights: []const f64) !?[N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    if (items.len != weights.len) return error.InvalidParameter;
    const indices = try weightedIndexArray(io, N, weights) orelse return null;
    for (&out, indices) |*item, index| item.* = &items[index];
    return out;
}

pub fn chooseWeightedConstPtrArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []const T, weights: []const f64) ![N]*const T {
    var out: [N]*const T = undefined;
    if (N == 0) return out;
    if (items.len != weights.len) return error.InvalidParameter;
    const indices = try weightedIndexArrayChecked(io, N, weights);
    for (&out, indices) |*item, index| item.* = &items[index];
    return out;
}

pub fn chooseWeightedPtr(comptime T: type, io: std.Io, items: []T, weights: []const f64) !?*T {
    if (items.len != weights.len) return error.InvalidParameter;
    const index = try weightedIndexChecked(io, weights) orelse return null;
    return &items[index];
}

pub fn chooseWeightedPtrChecked(comptime T: type, io: std.Io, items: []T, weights: []const f64) !*T {
    if (items.len != weights.len) return error.InvalidParameter;
    const index = try weightedIndexChecked(io, weights) orelse return error.EmptyRange;
    return &items[index];
}

pub fn fillChooseWeightedPtr(comptime T: type, io: std.Io, dest: []?*T, items: []T, weights: []const f64) !void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.InvalidParameter;
    var indices: [64]?usize = undefined;
    if (dest.len <= indices.len) {
        try fillWeightedIndex(io, indices[0..dest.len], weights);
        for (dest, indices[0..dest.len]) |*item, index| item.* = if (index) |i| &items[i] else null;
        return;
    }
    for (dest) |*item| item.* = try chooseWeightedPtr(T, io, items, weights);
}

pub fn fillChooseWeightedPtrChecked(comptime T: type, io: std.Io, dest: []*T, items: []T, weights: []const f64) !void {
    if (dest.len == 0) return;
    if (items.len != weights.len) return error.InvalidParameter;
    var indices: [64]usize = undefined;
    if (dest.len <= indices.len) {
        try fillWeightedIndexChecked(io, indices[0..dest.len], weights);
        for (dest, indices[0..dest.len]) |*item, index| item.* = &items[index];
        return;
    }
    for (dest) |*item| item.* = try chooseWeightedPtrChecked(T, io, items, weights);
}

pub fn chooseWeightedPtrBatch(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []T, weights: []const f64) ![]?*T {
    if (count == 0) return allocator.alloc(?*T, 0);
    if (items.len != weights.len) return error.InvalidParameter;
    switch (try rootWeightedIndexStateAllowEmpty(weights)) {
        .empty => {
            const out = try allocator.alloc(?*T, count);
            @memset(out, @as(?*T, null));
            return out;
        },
        .single => |index| {
            const out = try allocator.alloc(?*T, count);
            @memset(out, @as(?*T, &items[index]));
            return out;
        },
        .random => {},
    }
    const out = try allocator.alloc(?*T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedPtr(T, io, out, items, weights);
    return out;
}

pub fn chooseWeightedPtrBatchChecked(comptime T: type, io: std.Io, allocator: std.mem.Allocator, count: usize, items: []T, weights: []const f64) ![]*T {
    if (count == 0) return allocator.alloc(*T, 0);
    if (items.len != weights.len) return error.InvalidParameter;
    switch (try rootWeightedIndexState(weights)) {
        .single => |index| {
            const out = try allocator.alloc(*T, count);
            @memset(out, &items[index]);
            return out;
        },
        .random => {},
        .empty => unreachable,
    }
    const out = try allocator.alloc(*T, count);
    errdefer allocator.free(out);
    try fillChooseWeightedPtrChecked(T, io, out, items, weights);
    return out;
}

pub fn chooseWeightedPtrArray(comptime T: type, io: std.Io, comptime N: usize, items: []T, weights: []const f64) !?[N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    if (items.len != weights.len) return error.InvalidParameter;
    const indices = try weightedIndexArray(io, N, weights) orelse return null;
    for (&out, indices) |*item, index| item.* = &items[index];
    return out;
}

pub fn chooseWeightedPtrArrayChecked(comptime T: type, io: std.Io, comptime N: usize, items: []T, weights: []const f64) ![N]*T {
    var out: [N]*T = undefined;
    if (N == 0) return out;
    if (items.len != weights.len) return error.InvalidParameter;
    const indices = try weightedIndexArrayChecked(io, N, weights);
    for (&out, indices) |*item, index| item.* = &items[index];
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

const RootIteratorChoiceMode = enum { reservoir, hinted };

fn rootChooseIterator(comptime T: type, io: std.Io, iterator: anytype, mode: RootIteratorChoiceMode) !?T {
    if (mode == .hinted) {
        if (rootIteratorExactRemaining(iterator)) |remaining| {
            if (remaining == 0) return null;
            const first = iterator.next() orelse return null;
            if (remaining == 1) return first;

            var engine = try secure(io);
            const random_source = Rng.init(&engine);
            if (random_source.uintLessThan(usize, remaining) == 0) return first;

            var index: usize = 1;
            while (index < remaining) : (index += 1) {
                const item = iterator.next() orelse return null;
                if (random_source.uintLessThan(usize, remaining - index) == 0) return item;
            }
            return null;
        }
    }

    var first = iterator.next() orelse return null;
    var seen: usize = 1;
    const second = iterator.next() orelse return first;

    var engine = try secure(io);
    const random_source = Rng.init(&engine);
    if (random_source.uintLessThan(usize, 2) == 0) first = second;
    seen = 2;

    while (iterator.next()) |item| {
        seen += 1;
        if (random_source.uintLessThan(usize, seen) == 0) first = item;
    }

    return first;
}

fn rootIteratorExactRemaining(iterator: anytype) ?usize {
    const Iterator = switch (@typeInfo(@TypeOf(iterator))) {
        .pointer => |pointer| pointer.child,
        else => @TypeOf(iterator),
    };
    if (comptime @hasDecl(Iterator, "sizeHint")) {
        const hint = iterator.sizeHint();
        if (hint.upper) |upper| {
            if (upper == hint.lower) return upper;
        }
    }
    if (comptime @hasDecl(Iterator, "len")) return iterator.len();
    if (comptime @hasDecl(Iterator, "remaining")) return iterator.remaining();
    return null;
}

fn rootWeightAsF64(comptime Weight: type, weight: Weight) f64 {
    return switch (@typeInfo(Weight)) {
        .float => @floatCast(weight),
        .comptime_float => @as(f64, weight),
        .int, .comptime_int => @floatFromInt(weight),
        else => @compileError("weight must be numeric"),
    };
}

fn RootWeightedIteratorCandidate(comptime T: type) type {
    return struct {
        item: T,
        key: f64,
    };
}

fn rootWeightedIteratorKey(random_source: Rng, weight: f64) f64 {
    std.debug.assert(weight > 0 and std.math.isFinite(weight));
    const key = @log(random_source.floatOpen(f64)) / weight;
    return if (std.math.isFinite(key)) key else -std.math.floatMax(f64);
}

fn rootCompareWeightedIteratorCandidate(comptime T: type, a: RootWeightedIteratorCandidate(T), b: RootWeightedIteratorCandidate(T)) std.math.Order {
    return std.math.order(a.key, b.key);
}

fn rootCompareWeightedIteratorCandidateContext(comptime T: type) fn (void, RootWeightedIteratorCandidate(T), RootWeightedIteratorCandidate(T)) std.math.Order {
    return struct {
        fn compare(_: void, a: RootWeightedIteratorCandidate(T), b: RootWeightedIteratorCandidate(T)) std.math.Order {
            return rootCompareWeightedIteratorCandidate(T, a, b);
        }
    }.compare;
}

fn RootWeightedIteratorQueue(comptime T: type) type {
    return std.PriorityQueue(RootWeightedIteratorCandidate(T), void, rootCompareWeightedIteratorCandidateContext(T));
}

fn rootMinWeightedIteratorCandidateIndex(comptime T: type, candidates: []const RootWeightedIteratorCandidate(T)) usize {
    std.debug.assert(candidates.len > 0);
    var min_index: usize = 0;
    for (candidates[1..], 1..) |candidate, index| {
        if (rootCompareWeightedIteratorCandidate(T, candidate, candidates[min_index]) == .lt) min_index = index;
    }
    return min_index;
}

fn rootSortWeightedIteratorCandidates(comptime T: type, candidates: []RootWeightedIteratorCandidate(T)) void {
    var i: usize = 1;
    while (i < candidates.len) : (i += 1) {
        var j = i;
        while (j > 0 and rootCompareWeightedIteratorCandidate(T, candidates[j], candidates[j - 1]) == .lt) : (j -= 1) {
            std.mem.swap(RootWeightedIteratorCandidate(T), &candidates[j], &candidates[j - 1]);
        }
    }
}

fn rootMinWeightedKeyIndex(keys: []const f64) usize {
    std.debug.assert(keys.len > 0);
    var min_index: usize = 0;
    for (keys[1..], 1..) |key, index| {
        if (key < keys[min_index]) min_index = index;
    }
    return min_index;
}

fn rootSortWeightedItemKeyPairs(comptime T: type, items: []T, keys: []f64) void {
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

fn rootSampleIteratorWeightedInto(comptime T: type, io: std.Io, iterator: anytype, out: []T, keys: []f64, comptime checked: bool) !usize {
    std.debug.assert(out.len > 0);
    std.debug.assert(keys.len == out.len);

    var count: usize = 0;
    var engine: ?SecurePrng = null;

    while (iterator.next()) |entry| {
        const weight = rootWeightAsF64(@TypeOf(entry.weight), entry.weight);
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight == 0) continue;

        if (engine == null and count < out.len) {
            out[count] = entry.item;
            keys[count] = weight;
            count += 1;
            continue;
        }

        if (engine == null) {
            engine = try secure(io);
            const random_source = Rng.init(&engine.?);
            for (keys[0..count]) |*key| key.* = rootWeightedIteratorKey(random_source, key.*);
        }

        const random_source = Rng.init(&engine.?);
        const key = rootWeightedIteratorKey(random_source, weight);
        if (count < out.len) {
            out[count] = entry.item;
            keys[count] = key;
            count += 1;
        } else {
            const min_index = rootMinWeightedKeyIndex(keys[0..count]);
            if (key > keys[min_index]) {
                out[min_index] = entry.item;
                keys[min_index] = key;
            }
        }
    }

    if (count == 0) {
        if (checked) return error.InvalidParameter;
        return 0;
    }
    if (engine == null) {
        if (count == 1) {
            if (checked and count != out.len) return error.InvalidParameter;
            return count;
        }
        if (checked and count != out.len) return error.InvalidParameter;
        engine = try secure(io);
        const random_source = Rng.init(&engine.?);
        for (keys[0..count]) |*key| key.* = rootWeightedIteratorKey(random_source, key.*);
    }

    if (checked and count != out.len) return error.InvalidParameter;
    rootSortWeightedItemKeyPairs(T, out[0..count], keys[0..count]);
    return count;
}

fn rootSampleIteratorWeightedAlloc(comptime T: type, io: std.Io, allocator: std.mem.Allocator, iterator: anytype, amount: usize, comptime checked: bool) ![]T {
    if (amount == 0) return allocator.alloc(T, 0);
    const Pending = struct {
        item: T,
        weight: f64,
    };

    const pending = try allocator.alloc(Pending, amount);
    defer allocator.free(pending);

    var heap = RootWeightedIteratorQueue(T).initContext({});
    defer heap.deinit(allocator);

    var pending_count: usize = 0;
    var engine: ?SecurePrng = null;

    while (iterator.next()) |entry| {
        const weight = rootWeightAsF64(@TypeOf(entry.weight), entry.weight);
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight == 0) continue;

        if (engine == null and pending_count < amount) {
            pending[pending_count] = .{ .item = entry.item, .weight = weight };
            pending_count += 1;
            continue;
        }

        if (engine == null) {
            engine = try secure(io);
            try heap.ensureTotalCapacityPrecise(allocator, amount);
            const random_source = Rng.init(&engine.?);
            for (pending[0..pending_count]) |stored| {
                try heap.push(allocator, .{
                    .item = stored.item,
                    .key = rootWeightedIteratorKey(random_source, stored.weight),
                });
            }
        }

        const random_source = Rng.init(&engine.?);
        const candidate = RootWeightedIteratorCandidate(T){
            .item = entry.item,
            .key = rootWeightedIteratorKey(random_source, weight),
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

    if (engine == null) {
        if (pending_count == 0) {
            if (checked) return error.InvalidParameter;
            return allocator.alloc(T, 0);
        }
        if (pending_count == 1) {
            if (checked and amount != 1) return error.InvalidParameter;
            return rootSingleItemByAlloc(T, allocator, pending[0].item);
        }
        if (checked and pending_count < amount) return error.InvalidParameter;

        engine = try secure(io);
        try heap.ensureTotalCapacityPrecise(allocator, amount);
        const random_source = Rng.init(&engine.?);
        for (pending[0..pending_count]) |stored| {
            try heap.push(allocator, .{
                .item = stored.item,
                .key = rootWeightedIteratorKey(random_source, stored.weight),
            });
        }
    }

    if (checked and heap.count() != amount) return error.InvalidParameter;
    const out = try allocator.alloc(T, heap.count());
    errdefer allocator.free(out);
    var i: usize = 0;
    while (heap.pop()) |candidate| : (i += 1) {
        out[i] = candidate.item;
    }
    return out;
}

fn rootSampleIteratorWeightedCandidateArray(comptime T: type, io: std.Io, comptime N: usize, iterator: anytype) !?[N]RootWeightedIteratorCandidate(T) {
    if (N == 0) return .{};
    const Pending = struct {
        item: T,
        weight: f64,
    };

    var pending: [N]Pending = undefined;
    var candidates: [N]RootWeightedIteratorCandidate(T) = undefined;
    var count: usize = 0;
    var engine: ?SecurePrng = null;

    while (iterator.next()) |entry| {
        const weight = rootWeightAsF64(@TypeOf(entry.weight), entry.weight);
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight == 0) continue;

        if (engine == null and count < N) {
            pending[count] = .{ .item = entry.item, .weight = weight };
            count += 1;
            continue;
        }

        if (engine == null) {
            engine = try secure(io);
            const random_source = Rng.init(&engine.?);
            for (pending[0..count], 0..) |stored, index| {
                candidates[index] = .{
                    .item = stored.item,
                    .key = rootWeightedIteratorKey(random_source, stored.weight),
                };
            }
        }

        const random_source = Rng.init(&engine.?);
        const candidate = RootWeightedIteratorCandidate(T){
            .item = entry.item,
            .key = rootWeightedIteratorKey(random_source, weight),
        };
        if (count < N) {
            candidates[count] = candidate;
            count += 1;
        } else {
            const min_index = rootMinWeightedIteratorCandidateIndex(T, candidates[0..]);
            if (rootCompareWeightedIteratorCandidate(T, candidate, candidates[min_index]) == .gt) {
                candidates[min_index] = candidate;
            }
        }
    }

    if (count < N) return null;
    if (engine == null) {
        if (comptime N == 1) return .{.{ .item = pending[0].item, .key = 0 }};
        engine = try secure(io);
        const random_source = Rng.init(&engine.?);
        for (pending[0..count], 0..) |stored, index| {
            candidates[index] = .{
                .item = stored.item,
                .key = rootWeightedIteratorKey(random_source, stored.weight),
            };
        }
    }
    rootSortWeightedIteratorCandidates(T, candidates[0..]);
    return candidates;
}

const RootPositiveWeightState = struct {
    count: usize,
    single_index: ?usize,
};

fn rootPositiveWeightState(comptime Weight: type, weights: []const Weight) !RootPositiveWeightState {
    var state = RootPositiveWeightState{ .count = 0, .single_index = null };
    for (weights, 0..) |weight, index| {
        const value = rootWeightAsF64(Weight, weight);
        if (!(value >= 0) or !std.math.isFinite(value)) return error.InvalidWeight;
        if (value > 0) {
            state.count += 1;
            state.single_index = if (state.count == 1) index else null;
        }
    }
    return state;
}

fn rootIndexVecAll(allocator: std.mem.Allocator, length: usize) !IndexVec {
    if (length <= std.math.maxInt(u32)) {
        const out = try allocator.alloc(u32, length);
        for (out, 0..) |*item, index| item.* = @intCast(index);
        return .{ .u32 = out };
    }
    const out = try allocator.alloc(usize, length);
    for (out, 0..) |*item, index| item.* = index;
    return .{ .usize = out };
}

fn rootPtrSliceAll(comptime T: type, allocator: std.mem.Allocator, items: []const T) ![]*const T {
    const out = try allocator.alloc(*const T, items.len);
    for (out, 0..) |*slot, index| slot.* = &items[index];
    return out;
}

fn rootMutPtrSliceAll(comptime T: type, allocator: std.mem.Allocator, items: []T) ![]*T {
    const out = try allocator.alloc(*T, items.len);
    for (out, 0..) |*slot, index| slot.* = &items[index];
    return out;
}

fn rootItemsIntoPrefix(comptime T: type, items: []const T, out: []T, count: usize) usize {
    for (out[0..count], 0..) |*slot, index| slot.* = items[index];
    return count;
}

fn rootPtrsIntoPrefix(comptime T: type, items: []const T, out: []*const T, count: usize) usize {
    for (out[0..count], 0..) |*slot, index| slot.* = &items[index];
    return count;
}

fn rootMutPtrsIntoPrefix(comptime T: type, items: []T, out: []*T, count: usize) usize {
    for (out[0..count], 0..) |*slot, index| slot.* = &items[index];
    return count;
}

fn rootIndexArrayAll(comptime N: usize) [N]usize {
    var out: [N]usize = undefined;
    for (&out, 0..) |*item, index| item.* = index;
    return out;
}

fn rootIndexArrayAllU32(comptime N: usize) [N]u32 {
    var out: [N]u32 = undefined;
    for (&out, 0..) |*item, index| item.* = @intCast(index);
    return out;
}

fn rootIndexVecSingle(allocator: std.mem.Allocator, length: usize, index: usize) !IndexVec {
    if (length <= std.math.maxInt(u32)) {
        const out = try allocator.alloc(u32, 1);
        out[0] = @intCast(index);
        return .{ .u32 = out };
    }
    const out = try allocator.alloc(usize, 1);
    out[0] = index;
    return .{ .usize = out };
}

fn rootSingleIndexAlloc(allocator: std.mem.Allocator, index: usize) ![]usize {
    const out = try allocator.alloc(usize, 1);
    out[0] = index;
    return out;
}

fn rootSingleIndexU32Alloc(allocator: std.mem.Allocator, index: usize) ![]u32 {
    const out = try allocator.alloc(u32, 1);
    out[0] = @intCast(index);
    return out;
}

const RootWeightedIndexState = union(enum) {
    empty,
    single: usize,
    random,
};

fn rootWeightedIndexStateByIndex(comptime Weight: type, length: usize, comptime weightFn: fn (usize) Weight) !RootWeightedIndexState {
    var positive_index: ?usize = null;
    var positive_count: usize = 0;
    var total: f64 = 0;
    var index: usize = 0;
    while (index < length) : (index += 1) {
        const weight = rootWeightAsF64(Weight, weightFn(index));
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

fn rootWeightedIndexStateBy(comptime T: type, comptime Weight: type, items: []const T, comptime weightFn: fn (*const T) Weight) !RootWeightedIndexState {
    var positive_index: ?usize = null;
    var positive_count: usize = 0;
    var total: f64 = 0;
    for (items, 0..) |*item, index| {
        const weight = rootWeightAsF64(Weight, weightFn(item));
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

const RootPositiveItemState = struct {
    count: usize,
    single_index: ?usize,
};

fn rootPositiveItemStateBy(comptime T: type, comptime Weight: type, items: []const T, comptime weightFn: fn (*const T) Weight) !RootPositiveItemState {
    var state: RootPositiveItemState = .{ .count = 0, .single_index = null };
    for (items, 0..) |*item, index| {
        const weight = rootWeightAsF64(Weight, weightFn(item));
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight > 0) {
            state.count += 1;
            state.single_index = if (state.count == 1) index else null;
        }
    }
    return state;
}

fn rootPositiveIndexStateByIndex(comptime Weight: type, length: usize, comptime weightFn: fn (usize) Weight) !RootPositiveItemState {
    var state: RootPositiveItemState = .{ .count = 0, .single_index = null };
    var index: usize = 0;
    while (index < length) : (index += 1) {
        const weight = rootWeightAsF64(Weight, weightFn(index));
        if (!(weight >= 0) or !std.math.isFinite(weight)) return error.InvalidWeight;
        if (weight > 0) {
            state.count += 1;
            state.single_index = if (state.count == 1) index else null;
        }
    }
    return state;
}

fn rootSingleItemByAlloc(comptime T: type, allocator: std.mem.Allocator, item: T) ![]T {
    const out = try allocator.alloc(T, 1);
    out[0] = item;
    return out;
}

fn rootSingleConstPtrByAlloc(comptime T: type, allocator: std.mem.Allocator, item: *const T) ![]*const T {
    const out = try allocator.alloc(*const T, 1);
    out[0] = item;
    return out;
}

fn rootSingleMutPtrByAlloc(comptime T: type, allocator: std.mem.Allocator, item: *T) ![]*T {
    const out = try allocator.alloc(*T, 1);
    out[0] = item;
    return out;
}

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
    const chosen_index_array = (try chooseIndexArray(io, 4, colors.len)).?;
    for (chosen_index_array) |value| try std.testing.expect(value < colors.len);
    const chosen_index_array_checked = try chooseIndexArrayChecked(io, 4, colors.len);
    for (chosen_index_array_checked) |value| try std.testing.expect(value < colors.len);
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
    const chosen_index_array_u32 = (try chooseIndexArrayU32(io, 4, @intCast(colors.len))).?;
    for (chosen_index_array_u32) |value| try std.testing.expect(value < colors.len);
    const chosen_index_array_u32_checked = try chooseIndexArrayU32Checked(io, 4, @intCast(colors.len));
    for (chosen_index_array_u32_checked) |value| try std.testing.expect(value < colors.len);
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
    const chosen_value_array = (try chooseValueArray(u8, io, 4, &colors)).?;
    for (chosen_value_array) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value) != null);
    const chosen_value_array_checked = try chooseValueArrayChecked(u8, io, 4, &colors);
    for (chosen_value_array_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value) != null);
    const chosen_const_ptr = (try chooseConstPtr(u8, io, &colors)).?;
    try std.testing.expect(std.mem.indexOfScalar(u8, &colors, chosen_const_ptr.*) != null);
    const chosen_const_ptr_checked = try chooseConstPtrChecked(u8, io, &colors);
    try std.testing.expect(std.mem.indexOfScalar(u8, &colors, chosen_const_ptr_checked.*) != null);
    var chosen_const_ptrs: [4]*const u8 = undefined;
    try fillChooseConstPtr(u8, io, &chosen_const_ptrs, &colors);
    for (chosen_const_ptrs) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value.*) != null);
    try fillChooseConstPtrChecked(u8, io, &chosen_const_ptrs, &colors);
    for (chosen_const_ptrs) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value.*) != null);
    const chosen_const_ptr_batch = try chooseConstPtrBatch(u8, io, std.testing.allocator, 4, &colors);
    defer std.testing.allocator.free(chosen_const_ptr_batch);
    for (chosen_const_ptr_batch) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value.*) != null);
    const chosen_const_ptr_batch_checked = try chooseConstPtrBatchChecked(u8, io, std.testing.allocator, 4, &colors);
    defer std.testing.allocator.free(chosen_const_ptr_batch_checked);
    for (chosen_const_ptr_batch_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value.*) != null);
    const chosen_const_ptr_array = (try chooseConstPtrArray(u8, io, 4, &colors)).?;
    for (chosen_const_ptr_array) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value.*) != null);
    const chosen_const_ptr_array_checked = try chooseConstPtrArrayChecked(u8, io, 4, &colors);
    for (chosen_const_ptr_array_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value.*) != null);
    var mutable_colors = colors;
    const chosen_ptr = (try choosePtr(u8, io, &mutable_colors)).?;
    try std.testing.expect(std.mem.indexOfScalar(u8, &colors, chosen_ptr.*) != null);
    const chosen_ptr_checked = try choosePtrChecked(u8, io, &mutable_colors);
    try std.testing.expect(std.mem.indexOfScalar(u8, &colors, chosen_ptr_checked.*) != null);
    var chosen_ptrs: [4]*u8 = undefined;
    try fillChoosePtr(u8, io, &chosen_ptrs, &mutable_colors);
    for (chosen_ptrs) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value.*) != null);
    try fillChoosePtrChecked(u8, io, &chosen_ptrs, &mutable_colors);
    for (chosen_ptrs) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value.*) != null);
    const chosen_ptr_batch = try choosePtrBatch(u8, io, std.testing.allocator, 4, &mutable_colors);
    defer std.testing.allocator.free(chosen_ptr_batch);
    for (chosen_ptr_batch) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value.*) != null);
    const chosen_ptr_batch_checked = try choosePtrBatchChecked(u8, io, std.testing.allocator, 4, &mutable_colors);
    defer std.testing.allocator.free(chosen_ptr_batch_checked);
    for (chosen_ptr_batch_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value.*) != null);
    const chosen_ptr_array = (try choosePtrArray(u8, io, 4, &mutable_colors)).?;
    for (chosen_ptr_array) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value.*) != null);
    const chosen_ptr_array_checked = try choosePtrArrayChecked(u8, io, 4, &mutable_colors);
    for (chosen_ptr_array_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &colors, value.*) != null);
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
    const no_replacement_items = [_]u8{ 10, 20, 30, 40 };
    const no_replacement = try sampleWithoutReplacement(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer std.testing.allocator.free(no_replacement);
    try std.testing.expectEqual(@as(usize, 3), no_replacement.len);
    for (no_replacement) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const no_replacement_checked = try sampleWithoutReplacementChecked(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer std.testing.allocator.free(no_replacement_checked);
    try std.testing.expectEqual(@as(usize, 3), no_replacement_checked.len);
    for (no_replacement_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const choose_multiple = try chooseMultiple(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer std.testing.allocator.free(choose_multiple);
    try std.testing.expectEqual(@as(usize, 3), choose_multiple.len);
    for (choose_multiple) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const choose_multiple_checked = try chooseMultipleChecked(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer std.testing.allocator.free(choose_multiple_checked);
    try std.testing.expectEqual(@as(usize, 3), choose_multiple_checked.len);
    for (choose_multiple_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const no_replacement_array = (try sampleItemsArray(u8, io, 3, &no_replacement_items)).?;
    for (no_replacement_array) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const no_replacement_array_checked = try sampleItemsArrayChecked(u8, io, 3, &no_replacement_items);
    for (no_replacement_array_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const no_replacement_choose_array = (try chooseArray(u8, io, 3, &no_replacement_items)).?;
    for (no_replacement_choose_array) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const no_replacement_choose_array_checked = try chooseArrayChecked(u8, io, 3, &no_replacement_items);
    for (no_replacement_choose_array_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const no_replacement_ptr_array = (try samplePtrArray(u8, io, 3, &no_replacement_items)).?;
    for (no_replacement_ptr_array) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const no_replacement_ptr_array_checked = try samplePtrArrayChecked(u8, io, 3, &no_replacement_items);
    for (no_replacement_ptr_array_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const no_replacement_ptrs = try samplePtrs(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer std.testing.allocator.free(no_replacement_ptrs);
    try std.testing.expectEqual(@as(usize, 3), no_replacement_ptrs.len);
    for (no_replacement_ptrs) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const no_replacement_ptrs_checked = try samplePtrsChecked(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer std.testing.allocator.free(no_replacement_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 3), no_replacement_ptrs_checked.len);
    for (no_replacement_ptrs_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const choose_multiple_ptrs = try chooseMultiplePtrs(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer std.testing.allocator.free(choose_multiple_ptrs);
    try std.testing.expectEqual(@as(usize, 3), choose_multiple_ptrs.len);
    for (choose_multiple_ptrs) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const choose_multiple_ptrs_checked = try chooseMultiplePtrsChecked(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer std.testing.allocator.free(choose_multiple_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 3), choose_multiple_ptrs_checked.len);
    for (choose_multiple_ptrs_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    var no_replacement_mut_items = no_replacement_items;
    const no_replacement_mut_ptr_array = (try sampleMutPtrArray(u8, io, 3, &no_replacement_mut_items)).?;
    for (no_replacement_mut_ptr_array) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const no_replacement_mut_ptr_array_checked = try sampleMutPtrArrayChecked(u8, io, 3, &no_replacement_mut_items);
    for (no_replacement_mut_ptr_array_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const no_replacement_mut_ptrs = try sampleMutPtrs(u8, io, std.testing.allocator, &no_replacement_mut_items, 3);
    defer std.testing.allocator.free(no_replacement_mut_ptrs);
    try std.testing.expectEqual(@as(usize, 3), no_replacement_mut_ptrs.len);
    for (no_replacement_mut_ptrs) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const no_replacement_mut_ptrs_checked = try sampleMutPtrsChecked(u8, io, std.testing.allocator, &no_replacement_mut_items, 3);
    defer std.testing.allocator.free(no_replacement_mut_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 3), no_replacement_mut_ptrs_checked.len);
    for (no_replacement_mut_ptrs_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const choose_multiple_mut_ptrs = try chooseMultipleMutPtrs(u8, io, std.testing.allocator, &no_replacement_mut_items, 3);
    defer std.testing.allocator.free(choose_multiple_mut_ptrs);
    try std.testing.expectEqual(@as(usize, 3), choose_multiple_mut_ptrs.len);
    for (choose_multiple_mut_ptrs) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const choose_multiple_mut_ptrs_checked = try chooseMultipleMutPtrsChecked(u8, io, std.testing.allocator, &no_replacement_mut_items, 3);
    defer std.testing.allocator.free(choose_multiple_mut_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 3), choose_multiple_mut_ptrs_checked.len);
    for (choose_multiple_mut_ptrs_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    var no_replacement_values_into: [3]u8 = undefined;
    var no_replacement_value_indices: [3]usize = undefined;
    try std.testing.expectEqual(@as(usize, 3), try sampleItemsInto(u8, io, &no_replacement_items, &no_replacement_values_into, &no_replacement_value_indices));
    for (no_replacement_values_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    try sampleItemsIntoChecked(u8, io, &no_replacement_items, &no_replacement_values_into, &no_replacement_value_indices);
    for (no_replacement_values_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    try std.testing.expectEqual(@as(usize, 3), try chooseMultipleInto(u8, io, &no_replacement_items, &no_replacement_values_into, &no_replacement_value_indices));
    for (no_replacement_values_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    try chooseMultipleIntoChecked(u8, io, &no_replacement_items, &no_replacement_values_into, &no_replacement_value_indices);
    for (no_replacement_values_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    var no_replacement_ptrs_into: [3]*const u8 = undefined;
    var no_replacement_ptr_indices: [3]usize = undefined;
    try std.testing.expectEqual(@as(usize, 3), try samplePtrsInto(u8, io, &no_replacement_items, &no_replacement_ptrs_into, &no_replacement_ptr_indices));
    for (no_replacement_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    try samplePtrsIntoChecked(u8, io, &no_replacement_items, &no_replacement_ptrs_into, &no_replacement_ptr_indices);
    for (no_replacement_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    try std.testing.expectEqual(@as(usize, 3), try chooseMultiplePtrsInto(u8, io, &no_replacement_items, &no_replacement_ptrs_into, &no_replacement_ptr_indices));
    for (no_replacement_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    try chooseMultiplePtrsIntoChecked(u8, io, &no_replacement_items, &no_replacement_ptrs_into, &no_replacement_ptr_indices);
    for (no_replacement_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    var no_replacement_mut_ptrs_into: [3]*u8 = undefined;
    var no_replacement_mut_ptr_indices: [3]usize = undefined;
    try std.testing.expectEqual(@as(usize, 3), try sampleMutPtrsInto(u8, io, &no_replacement_mut_items, &no_replacement_mut_ptrs_into, &no_replacement_mut_ptr_indices));
    for (no_replacement_mut_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    try sampleMutPtrsIntoChecked(u8, io, &no_replacement_mut_items, &no_replacement_mut_ptrs_into, &no_replacement_mut_ptr_indices);
    for (no_replacement_mut_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    try std.testing.expectEqual(@as(usize, 3), try chooseMultipleMutPtrsInto(u8, io, &no_replacement_mut_items, &no_replacement_mut_ptrs_into, &no_replacement_mut_ptr_indices));
    for (no_replacement_mut_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    try chooseMultipleMutPtrsIntoChecked(u8, io, &no_replacement_mut_items, &no_replacement_mut_ptrs_into, &no_replacement_mut_ptr_indices);
    for (no_replacement_mut_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    var no_replacement_values_iter = try sampleItemsIter(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer no_replacement_values_iter.deinit();
    try std.testing.expectEqual(@as(usize, 3), no_replacement_values_iter.len());
    var no_replacement_values_iter_out: [3]u8 = undefined;
    try std.testing.expectEqual(@as(usize, 3), no_replacement_values_iter.fill(&no_replacement_values_iter_out));
    for (no_replacement_values_iter_out) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    var no_replacement_values_iter_checked = try sampleItemsIterChecked(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer no_replacement_values_iter_checked.deinit();
    try std.testing.expectEqual(@as(usize, 3), no_replacement_values_iter_checked.len());
    var no_replacement_values_iter_checked_out: [3]u8 = undefined;
    try std.testing.expectEqual(@as(usize, 3), no_replacement_values_iter_checked.fill(&no_replacement_values_iter_checked_out));
    for (no_replacement_values_iter_checked_out) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    var no_replacement_ptrs_iter = try samplePtrsIter(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer no_replacement_ptrs_iter.deinit();
    try std.testing.expectEqual(@as(usize, 3), no_replacement_ptrs_iter.len());
    var no_replacement_ptrs_iter_out: [3]*const u8 = undefined;
    try std.testing.expectEqual(@as(usize, 3), no_replacement_ptrs_iter.fill(&no_replacement_ptrs_iter_out));
    for (no_replacement_ptrs_iter_out) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    var no_replacement_ptrs_iter_checked = try samplePtrsIterChecked(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer no_replacement_ptrs_iter_checked.deinit();
    try std.testing.expectEqual(@as(usize, 3), no_replacement_ptrs_iter_checked.len());
    var no_replacement_ptrs_iter_checked_out: [3]*const u8 = undefined;
    try std.testing.expectEqual(@as(usize, 3), no_replacement_ptrs_iter_checked.fill(&no_replacement_ptrs_iter_checked_out));
    for (no_replacement_ptrs_iter_checked_out) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    var no_replacement_mut_ptrs_iter = try sampleMutPtrsIter(u8, io, std.testing.allocator, &no_replacement_mut_items, 3);
    defer no_replacement_mut_ptrs_iter.deinit();
    try std.testing.expectEqual(@as(usize, 3), no_replacement_mut_ptrs_iter.len());
    var no_replacement_mut_ptrs_iter_out: [3]*u8 = undefined;
    try std.testing.expectEqual(@as(usize, 3), no_replacement_mut_ptrs_iter.fill(&no_replacement_mut_ptrs_iter_out));
    for (no_replacement_mut_ptrs_iter_out) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    var no_replacement_mut_ptrs_iter_checked = try sampleMutPtrsIterChecked(u8, io, std.testing.allocator, &no_replacement_mut_items, 3);
    defer no_replacement_mut_ptrs_iter_checked.deinit();
    try std.testing.expectEqual(@as(usize, 3), no_replacement_mut_ptrs_iter_checked.len());
    var no_replacement_mut_ptrs_iter_checked_out: [3]*u8 = undefined;
    try std.testing.expectEqual(@as(usize, 3), no_replacement_mut_ptrs_iter_checked.fill(&no_replacement_mut_ptrs_iter_checked_out));
    for (no_replacement_mut_ptrs_iter_checked_out) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const reservoir_values = try reservoirSample(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer std.testing.allocator.free(reservoir_values);
    try std.testing.expectEqual(@as(usize, 3), reservoir_values.len);
    for (reservoir_values) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const reservoir_values_checked = try reservoirSampleChecked(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer std.testing.allocator.free(reservoir_values_checked);
    try std.testing.expectEqual(@as(usize, 3), reservoir_values_checked.len);
    for (reservoir_values_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    var reservoir_values_into: [3]u8 = undefined;
    try reservoirSampleInto(u8, io, &no_replacement_items, &reservoir_values_into);
    for (reservoir_values_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    try reservoirSampleIntoChecked(u8, io, &no_replacement_items, &reservoir_values_into);
    for (reservoir_values_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const reservoir_ptrs = try reservoirSamplePtrs(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer std.testing.allocator.free(reservoir_ptrs);
    try std.testing.expectEqual(@as(usize, 3), reservoir_ptrs.len);
    for (reservoir_ptrs) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const reservoir_ptrs_checked = try reservoirSamplePtrsChecked(u8, io, std.testing.allocator, &no_replacement_items, 3);
    defer std.testing.allocator.free(reservoir_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 3), reservoir_ptrs_checked.len);
    for (reservoir_ptrs_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    var reservoir_ptrs_into: [3]*const u8 = undefined;
    try reservoirSamplePtrsInto(u8, io, &no_replacement_items, &reservoir_ptrs_into);
    for (reservoir_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    try reservoirSamplePtrsIntoChecked(u8, io, &no_replacement_items, &reservoir_ptrs_into);
    for (reservoir_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const reservoir_mut_ptrs = try reservoirSampleMutPtrs(u8, io, std.testing.allocator, &no_replacement_mut_items, 3);
    defer std.testing.allocator.free(reservoir_mut_ptrs);
    try std.testing.expectEqual(@as(usize, 3), reservoir_mut_ptrs.len);
    for (reservoir_mut_ptrs) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const reservoir_mut_ptrs_checked = try reservoirSampleMutPtrsChecked(u8, io, std.testing.allocator, &no_replacement_mut_items, 3);
    defer std.testing.allocator.free(reservoir_mut_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 3), reservoir_mut_ptrs_checked.len);
    for (reservoir_mut_ptrs_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    var reservoir_mut_ptrs_into: [3]*u8 = undefined;
    try reservoirSampleMutPtrsInto(u8, io, &no_replacement_mut_items, &reservoir_mut_ptrs_into);
    for (reservoir_mut_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    try reservoirSampleMutPtrsIntoChecked(u8, io, &no_replacement_mut_items, &reservoir_mut_ptrs_into);
    for (reservoir_mut_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.*) != null);
    const index_vec = try sampleIndexVec(io, std.testing.allocator, no_replacement_items.len, 3);
    defer index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 3), index_vec.len());
    var index_vec_iter = index_vec.iter();
    while (index_vec_iter.next()) |value| try std.testing.expect(value < no_replacement_items.len);
    const index_vec_checked = try sampleIndexVecChecked(io, std.testing.allocator, no_replacement_items.len, 3);
    defer index_vec_checked.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 3), index_vec_checked.len());
    var index_vec_checked_iter = index_vec_checked.iter();
    while (index_vec_checked_iter.next()) |value| try std.testing.expect(value < no_replacement_items.len);
    const index_array = (try sampleArray(io, 3, no_replacement_items.len)).?;
    for (index_array) |value| try std.testing.expect(value < no_replacement_items.len);
    const index_array_checked = try sampleArrayChecked(io, 3, no_replacement_items.len);
    for (index_array_checked) |value| try std.testing.expect(value < no_replacement_items.len);
    const index_array_u32 = (try sampleArrayU32(io, 3, @intCast(no_replacement_items.len))).?;
    for (index_array_u32) |value| try std.testing.expect(value < no_replacement_items.len);
    const index_array_u32_checked = try sampleArrayU32Checked(io, 3, @intCast(no_replacement_items.len));
    for (index_array_u32_checked) |value| try std.testing.expect(value < no_replacement_items.len);
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
    const weighted_index_array_values = (try weightedIndexArray(io, 4, &weights)).?;
    for (weighted_index_array_values) |value| try std.testing.expect(value < weights.len);
    const weighted_index_array_checked_values = try weightedIndexArrayChecked(io, 4, &weights);
    for (weighted_index_array_checked_values) |value| try std.testing.expect(value < weights.len);
    const weighted_index_u32_value = (try weightedIndexU32(io, &weights)).?;
    try std.testing.expect(weighted_index_u32_value < weights.len);
    const weighted_index_u32_checked_value = (try weightedIndexU32Checked(io, &weights)).?;
    try std.testing.expect(weighted_index_u32_checked_value < weights.len);
    const RootIndexWeight = struct {
        fn weight(index: usize) f64 {
            return @floatFromInt(index + 1);
        }
    };
    const weighted_index_by_index_value = (try weightedIndexByIndex(f64, io, weights.len, RootIndexWeight.weight)).?;
    try std.testing.expect(weighted_index_by_index_value < weights.len);
    const weighted_index_by_index_checked_value = try weightedIndexByIndexChecked(f64, io, weights.len, RootIndexWeight.weight);
    try std.testing.expect(weighted_index_by_index_checked_value < weights.len);
    const RootItemWeight = struct {
        const Entry = struct {
            item: u8,
            weight: f64,
        };

        fn weight(entry: *const Entry) f64 {
            return entry.weight;
        }
    };
    const weighted_index_by_items = [_]RootItemWeight.Entry{
        .{ .item = 10, .weight = 1 },
        .{ .item = 20, .weight = 2 },
        .{ .item = 30, .weight = 3 },
        .{ .item = 40, .weight = 4 },
    };
    const weighted_index_by_value = (try weightedIndexBy(RootItemWeight.Entry, f64, io, &weighted_index_by_items, RootItemWeight.weight)).?;
    try std.testing.expect(weighted_index_by_value < weighted_index_by_items.len);
    const weighted_index_by_checked_value = try weightedIndexByChecked(RootItemWeight.Entry, f64, io, &weighted_index_by_items, RootItemWeight.weight);
    try std.testing.expect(weighted_index_by_checked_value < weighted_index_by_items.len);
    const weighted_index_u32_by_value = (try weightedIndexU32By(RootItemWeight.Entry, f64, io, &weighted_index_by_items, RootItemWeight.weight)).?;
    try std.testing.expect(weighted_index_u32_by_value < weighted_index_by_items.len);
    const weighted_index_u32_by_checked_value = try weightedIndexU32ByChecked(RootItemWeight.Entry, f64, io, &weighted_index_by_items, RootItemWeight.weight);
    try std.testing.expect(weighted_index_u32_by_checked_value < weighted_index_by_items.len);
    var weighted_index_by_fill: [4]?usize = undefined;
    try fillWeightedIndexBy(RootItemWeight.Entry, f64, io, &weighted_index_by_fill, &weighted_index_by_items, RootItemWeight.weight);
    for (weighted_index_by_fill) |index| try std.testing.expect(index.? < weighted_index_by_items.len);
    var weighted_index_by_checked_fill: [4]usize = undefined;
    try fillWeightedIndexByChecked(RootItemWeight.Entry, f64, io, &weighted_index_by_checked_fill, &weighted_index_by_items, RootItemWeight.weight);
    for (weighted_index_by_checked_fill) |index| try std.testing.expect(index < weighted_index_by_items.len);
    var weighted_index_u32_by_fill: [4]?u32 = undefined;
    try fillWeightedIndexU32By(RootItemWeight.Entry, f64, io, &weighted_index_u32_by_fill, &weighted_index_by_items, RootItemWeight.weight);
    for (weighted_index_u32_by_fill) |index| try std.testing.expect(index.? < weighted_index_by_items.len);
    var weighted_index_u32_by_checked_fill: [4]u32 = undefined;
    try fillWeightedIndexU32ByChecked(RootItemWeight.Entry, f64, io, &weighted_index_u32_by_checked_fill, &weighted_index_by_items, RootItemWeight.weight);
    for (weighted_index_u32_by_checked_fill) |index| try std.testing.expect(index < weighted_index_by_items.len);
    const weighted_index_by_batch_values = try weightedIndexBatchBy(RootItemWeight.Entry, f64, io, std.testing.allocator, 4, &weighted_index_by_items, RootItemWeight.weight);
    defer std.testing.allocator.free(weighted_index_by_batch_values);
    for (weighted_index_by_batch_values) |index| try std.testing.expect(index.? < weighted_index_by_items.len);
    const weighted_index_by_batch_checked_values = try weightedIndexBatchByChecked(RootItemWeight.Entry, f64, io, std.testing.allocator, 4, &weighted_index_by_items, RootItemWeight.weight);
    defer std.testing.allocator.free(weighted_index_by_batch_checked_values);
    for (weighted_index_by_batch_checked_values) |index| try std.testing.expect(index < weighted_index_by_items.len);
    const weighted_index_u32_by_batch_values = try weightedIndexU32BatchBy(RootItemWeight.Entry, f64, io, std.testing.allocator, 4, &weighted_index_by_items, RootItemWeight.weight);
    defer std.testing.allocator.free(weighted_index_u32_by_batch_values);
    for (weighted_index_u32_by_batch_values) |index| try std.testing.expect(index.? < weighted_index_by_items.len);
    const weighted_index_u32_by_batch_checked_values = try weightedIndexU32BatchByChecked(RootItemWeight.Entry, f64, io, std.testing.allocator, 4, &weighted_index_by_items, RootItemWeight.weight);
    defer std.testing.allocator.free(weighted_index_u32_by_batch_checked_values);
    for (weighted_index_u32_by_batch_checked_values) |index| try std.testing.expect(index < weighted_index_by_items.len);
    const weighted_index_by_array_values = (try weightedIndexArrayBy(RootItemWeight.Entry, f64, io, 4, &weighted_index_by_items, RootItemWeight.weight)).?;
    for (weighted_index_by_array_values) |index| try std.testing.expect(index < weighted_index_by_items.len);
    const weighted_index_by_array_checked_values = try weightedIndexArrayByChecked(RootItemWeight.Entry, f64, io, 4, &weighted_index_by_items, RootItemWeight.weight);
    for (weighted_index_by_array_checked_values) |index| try std.testing.expect(index < weighted_index_by_items.len);
    const weighted_index_u32_by_array_values = (try weightedIndexU32ArrayBy(RootItemWeight.Entry, f64, io, 4, &weighted_index_by_items, RootItemWeight.weight)).?;
    for (weighted_index_u32_by_array_values) |index| try std.testing.expect(index < weighted_index_by_items.len);
    const weighted_index_u32_by_array_checked_values = try weightedIndexU32ArrayByChecked(RootItemWeight.Entry, f64, io, 4, &weighted_index_by_items, RootItemWeight.weight);
    for (weighted_index_u32_by_array_checked_values) |index| try std.testing.expect(index < weighted_index_by_items.len);
    const weighted_value_by = (try chooseWeightedBy(RootItemWeight.Entry, f64, io, &weighted_index_by_items, RootItemWeight.weight)).?;
    try std.testing.expect(weighted_value_by.item >= 10 and weighted_value_by.item <= 40);
    const weighted_value_by_checked = try chooseWeightedByChecked(RootItemWeight.Entry, f64, io, &weighted_index_by_items, RootItemWeight.weight);
    try std.testing.expect(weighted_value_by_checked.item >= 10 and weighted_value_by_checked.item <= 40);
    const weighted_const_ptr_by = (try chooseWeightedConstPtrBy(RootItemWeight.Entry, f64, io, &weighted_index_by_items, RootItemWeight.weight)).?;
    try std.testing.expect(weighted_const_ptr_by.item >= 10 and weighted_const_ptr_by.item <= 40);
    const weighted_const_ptr_by_checked = try chooseWeightedConstPtrByChecked(RootItemWeight.Entry, f64, io, &weighted_index_by_items, RootItemWeight.weight);
    try std.testing.expect(weighted_const_ptr_by_checked.item >= 10 and weighted_const_ptr_by_checked.item <= 40);
    var weighted_index_by_mut_items = weighted_index_by_items;
    const weighted_mut_ptr_by = (try chooseWeightedPtrBy(RootItemWeight.Entry, f64, io, &weighted_index_by_mut_items, RootItemWeight.weight)).?;
    try std.testing.expect(weighted_mut_ptr_by.item >= 10 and weighted_mut_ptr_by.item <= 40);
    const weighted_mut_ptr_by_checked = try chooseWeightedPtrByChecked(RootItemWeight.Entry, f64, io, &weighted_index_by_mut_items, RootItemWeight.weight);
    try std.testing.expect(weighted_mut_ptr_by_checked.item >= 10 and weighted_mut_ptr_by_checked.item <= 40);
    var weighted_const_ptr_by_fill: [4]?*const RootItemWeight.Entry = undefined;
    try fillChooseWeightedConstPtrBy(RootItemWeight.Entry, f64, io, &weighted_const_ptr_by_fill, &weighted_index_by_items, RootItemWeight.weight);
    for (weighted_const_ptr_by_fill) |ptr| try std.testing.expect(ptr.?.item >= 10 and ptr.?.item <= 40);
    var weighted_const_ptr_by_checked_fill: [4]*const RootItemWeight.Entry = undefined;
    try fillChooseWeightedConstPtrByChecked(RootItemWeight.Entry, f64, io, &weighted_const_ptr_by_checked_fill, &weighted_index_by_items, RootItemWeight.weight);
    for (weighted_const_ptr_by_checked_fill) |ptr| try std.testing.expect(ptr.item >= 10 and ptr.item <= 40);
    var weighted_mut_ptr_by_fill_items = weighted_index_by_items;
    var weighted_mut_ptr_by_fill: [4]?*RootItemWeight.Entry = undefined;
    try fillChooseWeightedPtrBy(RootItemWeight.Entry, f64, io, &weighted_mut_ptr_by_fill, &weighted_mut_ptr_by_fill_items, RootItemWeight.weight);
    for (weighted_mut_ptr_by_fill) |ptr| try std.testing.expect(ptr.?.item >= 10 and ptr.?.item <= 40);
    var weighted_mut_ptr_by_checked_fill: [4]*RootItemWeight.Entry = undefined;
    try fillChooseWeightedPtrByChecked(RootItemWeight.Entry, f64, io, &weighted_mut_ptr_by_checked_fill, &weighted_mut_ptr_by_fill_items, RootItemWeight.weight);
    for (weighted_mut_ptr_by_checked_fill) |ptr| try std.testing.expect(ptr.item >= 10 and ptr.item <= 40);
    var weighted_mut_ptr_by_array_items = weighted_index_by_items;
    const weighted_mut_ptr_by_array = (try chooseWeightedPtrArrayBy(RootItemWeight.Entry, f64, io, 4, &weighted_mut_ptr_by_array_items, RootItemWeight.weight)).?;
    for (weighted_mut_ptr_by_array) |ptr| try std.testing.expect(ptr.item >= 10 and ptr.item <= 40);
    const weighted_mut_ptr_by_checked_array = try chooseWeightedPtrArrayByChecked(RootItemWeight.Entry, f64, io, 4, &weighted_mut_ptr_by_array_items, RootItemWeight.weight);
    for (weighted_mut_ptr_by_checked_array) |ptr| try std.testing.expect(ptr.item >= 10 and ptr.item <= 40);
    var weighted_value_by_fill: [4]?RootItemWeight.Entry = undefined;
    try fillChooseWeightedBy(RootItemWeight.Entry, f64, io, &weighted_value_by_fill, &weighted_index_by_items, RootItemWeight.weight);
    for (weighted_value_by_fill) |value| try std.testing.expect(value.?.item >= 10 and value.?.item <= 40);
    var weighted_value_by_checked_fill: [4]RootItemWeight.Entry = undefined;
    try fillChooseWeightedByChecked(RootItemWeight.Entry, f64, io, &weighted_value_by_checked_fill, &weighted_index_by_items, RootItemWeight.weight);
    for (weighted_value_by_checked_fill) |value| try std.testing.expect(value.item >= 10 and value.item <= 40);
    const weighted_value_by_batch = try chooseWeightedBatchBy(RootItemWeight.Entry, f64, io, std.testing.allocator, 4, &weighted_index_by_items, RootItemWeight.weight);
    defer std.testing.allocator.free(weighted_value_by_batch);
    for (weighted_value_by_batch) |value| try std.testing.expect(value.?.item >= 10 and value.?.item <= 40);
    const weighted_value_by_checked_batch = try chooseWeightedBatchByChecked(RootItemWeight.Entry, f64, io, std.testing.allocator, 4, &weighted_index_by_items, RootItemWeight.weight);
    defer std.testing.allocator.free(weighted_value_by_checked_batch);
    for (weighted_value_by_checked_batch) |value| try std.testing.expect(value.item >= 10 and value.item <= 40);
    const weighted_value_by_array = (try chooseWeightedValueArrayBy(RootItemWeight.Entry, f64, io, 4, &weighted_index_by_items, RootItemWeight.weight)).?;
    for (weighted_value_by_array) |value| try std.testing.expect(value.item >= 10 and value.item <= 40);
    const weighted_value_by_checked_array = try chooseWeightedValueArrayByChecked(RootItemWeight.Entry, f64, io, 4, &weighted_index_by_items, RootItemWeight.weight);
    for (weighted_value_by_checked_array) |value| try std.testing.expect(value.item >= 10 and value.item <= 40);
    const weighted_const_ptr_by_array = (try chooseWeightedConstPtrArrayBy(RootItemWeight.Entry, f64, io, 4, &weighted_index_by_items, RootItemWeight.weight)).?;
    for (weighted_const_ptr_by_array) |ptr| try std.testing.expect(ptr.item >= 10 and ptr.item <= 40);
    const weighted_const_ptr_by_checked_array = try chooseWeightedConstPtrArrayByChecked(RootItemWeight.Entry, f64, io, 4, &weighted_index_by_items, RootItemWeight.weight);
    for (weighted_const_ptr_by_checked_array) |ptr| try std.testing.expect(ptr.item >= 10 and ptr.item <= 40);
    const weighted_index_u32_by_index_value = (try weightedIndexU32ByIndex(f64, io, weights.len, RootIndexWeight.weight)).?;
    try std.testing.expect(weighted_index_u32_by_index_value < weights.len);
    const weighted_index_u32_by_index_checked_value = try weightedIndexU32ByIndexChecked(f64, io, weights.len, RootIndexWeight.weight);
    try std.testing.expect(weighted_index_u32_by_index_checked_value < weights.len);
    const weighted_value_by_index = (try chooseWeightedByIndex(u8, f64, io, &no_replacement_items, RootIndexWeight.weight)).?;
    try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, weighted_value_by_index) != null);
    const weighted_value_by_index_checked = try chooseWeightedByIndexChecked(u8, f64, io, &no_replacement_items, RootIndexWeight.weight);
    try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, weighted_value_by_index_checked) != null);
    var weighted_value_by_index_fill: [4]?u8 = undefined;
    try fillChooseWeightedByIndex(u8, f64, io, &weighted_value_by_index_fill, &no_replacement_items, RootIndexWeight.weight);
    for (weighted_value_by_index_fill) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.?) != null);
    var weighted_value_by_index_checked_fill: [4]u8 = undefined;
    try fillChooseWeightedByIndexChecked(u8, f64, io, &weighted_value_by_index_checked_fill, &no_replacement_items, RootIndexWeight.weight);
    for (weighted_value_by_index_checked_fill) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const weighted_value_by_index_batch = try chooseWeightedBatchByIndex(u8, f64, io, std.testing.allocator, 4, &no_replacement_items, RootIndexWeight.weight);
    defer std.testing.allocator.free(weighted_value_by_index_batch);
    for (weighted_value_by_index_batch) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value.?) != null);
    const weighted_value_by_index_checked_batch = try chooseWeightedBatchByIndexChecked(u8, f64, io, std.testing.allocator, 4, &no_replacement_items, RootIndexWeight.weight);
    defer std.testing.allocator.free(weighted_value_by_index_checked_batch);
    for (weighted_value_by_index_checked_batch) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const weighted_value_array_by_index = (try chooseWeightedValueArrayByIndex(u8, f64, io, 4, &no_replacement_items, RootIndexWeight.weight)).?;
    for (weighted_value_array_by_index) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const weighted_value_array_by_index_checked = try chooseWeightedValueArrayByIndexChecked(u8, f64, io, 4, &no_replacement_items, RootIndexWeight.weight);
    for (weighted_value_array_by_index_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, value) != null);
    const weighted_const_ptr_by_index = (try chooseWeightedConstPtrByIndex(u8, f64, io, &no_replacement_items, RootIndexWeight.weight)).?;
    try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, weighted_const_ptr_by_index.*) != null);
    const weighted_const_ptr_by_index_checked = try chooseWeightedConstPtrByIndexChecked(u8, f64, io, &no_replacement_items, RootIndexWeight.weight);
    try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, weighted_const_ptr_by_index_checked.*) != null);
    var weighted_const_ptr_by_index_fill: [4]?*const u8 = undefined;
    try fillChooseWeightedConstPtrByIndex(u8, f64, io, &weighted_const_ptr_by_index_fill, &no_replacement_items, RootIndexWeight.weight);
    for (weighted_const_ptr_by_index_fill) |ptr| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, ptr.?.*) != null);
    var weighted_const_ptr_by_index_checked_fill: [4]*const u8 = undefined;
    try fillChooseWeightedConstPtrByIndexChecked(u8, f64, io, &weighted_const_ptr_by_index_checked_fill, &no_replacement_items, RootIndexWeight.weight);
    for (weighted_const_ptr_by_index_checked_fill) |ptr| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, ptr.*) != null);
    const weighted_const_ptr_by_index_batch = try chooseWeightedConstPtrBatchByIndex(u8, f64, io, std.testing.allocator, 4, &no_replacement_items, RootIndexWeight.weight);
    defer std.testing.allocator.free(weighted_const_ptr_by_index_batch);
    for (weighted_const_ptr_by_index_batch) |ptr| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, ptr.?.*) != null);
    const weighted_const_ptr_by_index_checked_batch = try chooseWeightedConstPtrBatchByIndexChecked(u8, f64, io, std.testing.allocator, 4, &no_replacement_items, RootIndexWeight.weight);
    defer std.testing.allocator.free(weighted_const_ptr_by_index_checked_batch);
    for (weighted_const_ptr_by_index_checked_batch) |ptr| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, ptr.*) != null);
    const weighted_const_ptr_array_by_index = (try chooseWeightedConstPtrArrayByIndex(u8, f64, io, 4, &no_replacement_items, RootIndexWeight.weight)).?;
    for (weighted_const_ptr_array_by_index) |ptr| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, ptr.*) != null);
    const weighted_const_ptr_array_by_index_checked = try chooseWeightedConstPtrArrayByIndexChecked(u8, f64, io, 4, &no_replacement_items, RootIndexWeight.weight);
    for (weighted_const_ptr_array_by_index_checked) |ptr| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, ptr.*) != null);
    var weighted_mut_choice_items = no_replacement_items;
    const weighted_mut_ptr_by_index = (try chooseWeightedPtrByIndex(u8, f64, io, &weighted_mut_choice_items, RootIndexWeight.weight)).?;
    try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, weighted_mut_ptr_by_index.*) != null);
    const weighted_mut_ptr_by_index_checked = try chooseWeightedPtrByIndexChecked(u8, f64, io, &weighted_mut_choice_items, RootIndexWeight.weight);
    try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, weighted_mut_ptr_by_index_checked.*) != null);
    var weighted_mut_ptr_by_index_fill: [4]?*u8 = undefined;
    try fillChooseWeightedPtrByIndex(u8, f64, io, &weighted_mut_ptr_by_index_fill, &weighted_mut_choice_items, RootIndexWeight.weight);
    for (weighted_mut_ptr_by_index_fill) |ptr| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, ptr.?.*) != null);
    var weighted_mut_ptr_by_index_checked_fill: [4]*u8 = undefined;
    try fillChooseWeightedPtrByIndexChecked(u8, f64, io, &weighted_mut_ptr_by_index_checked_fill, &weighted_mut_choice_items, RootIndexWeight.weight);
    for (weighted_mut_ptr_by_index_checked_fill) |ptr| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, ptr.*) != null);
    const weighted_mut_ptr_by_index_batch = try chooseWeightedPtrBatchByIndex(u8, f64, io, std.testing.allocator, 4, &weighted_mut_choice_items, RootIndexWeight.weight);
    defer std.testing.allocator.free(weighted_mut_ptr_by_index_batch);
    for (weighted_mut_ptr_by_index_batch) |ptr| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, ptr.?.*) != null);
    const weighted_mut_ptr_by_index_checked_batch = try chooseWeightedPtrBatchByIndexChecked(u8, f64, io, std.testing.allocator, 4, &weighted_mut_choice_items, RootIndexWeight.weight);
    defer std.testing.allocator.free(weighted_mut_ptr_by_index_checked_batch);
    for (weighted_mut_ptr_by_index_checked_batch) |ptr| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, ptr.*) != null);
    const weighted_mut_ptr_array_by_index = (try chooseWeightedPtrArrayByIndex(u8, f64, io, 4, &weighted_mut_choice_items, RootIndexWeight.weight)).?;
    for (weighted_mut_ptr_array_by_index) |ptr| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, ptr.*) != null);
    const weighted_mut_ptr_array_by_index_checked = try chooseWeightedPtrArrayByIndexChecked(u8, f64, io, 4, &weighted_mut_choice_items, RootIndexWeight.weight);
    for (weighted_mut_ptr_array_by_index_checked) |ptr| try std.testing.expect(std.mem.indexOfScalar(u8, &no_replacement_items, ptr.*) != null);
    var weighted_index_by_index_fill: [4]?usize = undefined;
    try fillWeightedIndexByIndex(f64, io, &weighted_index_by_index_fill, weights.len, RootIndexWeight.weight);
    for (weighted_index_by_index_fill) |value| try std.testing.expect(value.? < weights.len);
    var weighted_index_by_index_checked_fill: [4]usize = undefined;
    try fillWeightedIndexByIndexChecked(f64, io, &weighted_index_by_index_checked_fill, weights.len, RootIndexWeight.weight);
    for (weighted_index_by_index_checked_fill) |value| try std.testing.expect(value < weights.len);
    var weighted_index_u32_by_index_fill: [4]?u32 = undefined;
    try fillWeightedIndexU32ByIndex(f64, io, &weighted_index_u32_by_index_fill, weights.len, RootIndexWeight.weight);
    for (weighted_index_u32_by_index_fill) |value| try std.testing.expect(value.? < weights.len);
    var weighted_index_u32_by_index_checked_fill: [4]u32 = undefined;
    try fillWeightedIndexU32ByIndexChecked(f64, io, &weighted_index_u32_by_index_checked_fill, weights.len, RootIndexWeight.weight);
    for (weighted_index_u32_by_index_checked_fill) |value| try std.testing.expect(value < weights.len);
    const weighted_index_by_index_batch_values = try weightedIndexBatchByIndex(f64, io, std.testing.allocator, 4, weights.len, RootIndexWeight.weight);
    defer std.testing.allocator.free(weighted_index_by_index_batch_values);
    for (weighted_index_by_index_batch_values) |value| try std.testing.expect(value.? < weights.len);
    const weighted_index_by_index_batch_checked_values = try weightedIndexBatchByIndexChecked(f64, io, std.testing.allocator, 4, weights.len, RootIndexWeight.weight);
    defer std.testing.allocator.free(weighted_index_by_index_batch_checked_values);
    for (weighted_index_by_index_batch_checked_values) |value| try std.testing.expect(value < weights.len);
    const weighted_index_u32_by_index_batch_values = try weightedIndexU32BatchByIndex(f64, io, std.testing.allocator, 4, weights.len, RootIndexWeight.weight);
    defer std.testing.allocator.free(weighted_index_u32_by_index_batch_values);
    for (weighted_index_u32_by_index_batch_values) |value| try std.testing.expect(value.? < weights.len);
    const weighted_index_u32_by_index_batch_checked_values = try weightedIndexU32BatchByIndexChecked(f64, io, std.testing.allocator, 4, weights.len, RootIndexWeight.weight);
    defer std.testing.allocator.free(weighted_index_u32_by_index_batch_checked_values);
    for (weighted_index_u32_by_index_batch_checked_values) |value| try std.testing.expect(value < weights.len);
    const weighted_index_array_by_index_values = (try weightedIndexArrayByIndex(f64, io, 4, weights.len, RootIndexWeight.weight)).?;
    for (weighted_index_array_by_index_values) |value| try std.testing.expect(value < weights.len);
    const weighted_index_array_by_index_checked_values = try weightedIndexArrayByIndexChecked(f64, io, 4, weights.len, RootIndexWeight.weight);
    for (weighted_index_array_by_index_checked_values) |value| try std.testing.expect(value < weights.len);
    const weighted_index_u32_array_by_index_values = (try weightedIndexU32ArrayByIndex(f64, io, 4, weights.len, RootIndexWeight.weight)).?;
    for (weighted_index_u32_array_by_index_values) |value| try std.testing.expect(value < weights.len);
    const weighted_index_u32_array_by_index_checked_values = try weightedIndexU32ArrayByIndexChecked(f64, io, 4, weights.len, RootIndexWeight.weight);
    for (weighted_index_u32_array_by_index_checked_values) |value| try std.testing.expect(value < weights.len);
    var weighted_index_u32_fill: [4]?u32 = undefined;
    try fillWeightedIndexU32(io, &weighted_index_u32_fill, &weights);
    for (weighted_index_u32_fill) |value| try std.testing.expect(value.? < weights.len);
    var weighted_index_u32_checked_fill: [4]u32 = undefined;
    try fillWeightedIndexU32Checked(io, &weighted_index_u32_checked_fill, &weights);
    for (weighted_index_u32_checked_fill) |value| try std.testing.expect(value < weights.len);
    const weighted_index_u32_batch_values = try weightedIndexU32Batch(io, std.testing.allocator, 4, &weights);
    defer std.testing.allocator.free(weighted_index_u32_batch_values);
    for (weighted_index_u32_batch_values) |value| try std.testing.expect(value.? < weights.len);
    const weighted_index_u32_batch_checked_values = try weightedIndexU32BatchChecked(io, std.testing.allocator, 4, &weights);
    defer std.testing.allocator.free(weighted_index_u32_batch_checked_values);
    for (weighted_index_u32_batch_checked_values) |value| try std.testing.expect(value < weights.len);
    const weighted_index_u32_array_values = (try weightedIndexU32Array(io, 4, &weights)).?;
    for (weighted_index_u32_array_values) |value| try std.testing.expect(value < weights.len);
    const weighted_index_u32_array_checked_values = try weightedIndexU32ArrayChecked(io, 4, &weights);
    for (weighted_index_u32_array_checked_values) |value| try std.testing.expect(value < weights.len);
    var weighted_sample_indices_into: [2]usize = undefined;
    var weighted_sample_keys: [2]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 2), try sampleWeightedIndicesInto(f64, io, &weights, &weighted_sample_indices_into, &weighted_sample_keys));
    try std.testing.expect(weighted_sample_indices_into[0] != weighted_sample_indices_into[1]);
    for (weighted_sample_indices_into) |value| try std.testing.expect(value < weights.len);
    try sampleWeightedIndicesIntoChecked(f64, io, &weights, &weighted_sample_indices_into, &weighted_sample_keys);
    try std.testing.expect(weighted_sample_indices_into[0] != weighted_sample_indices_into[1]);
    for (weighted_sample_indices_into) |value| try std.testing.expect(value < weights.len);
    const weighted_sample_index_array = (try sampleWeightedIndexArray(f64, io, 2, &weights)).?;
    try std.testing.expect(weighted_sample_index_array[0] != weighted_sample_index_array[1]);
    for (weighted_sample_index_array) |value| try std.testing.expect(value < weights.len);
    const weighted_sample_index_array_checked = try sampleWeightedIndexArrayChecked(f64, io, 2, &weights);
    try std.testing.expect(weighted_sample_index_array_checked[0] != weighted_sample_index_array_checked[1]);
    for (weighted_sample_index_array_checked) |value| try std.testing.expect(value < weights.len);
    const weighted_index_vec = try sampleWeightedIndexVec(f64, io, std.testing.allocator, &weights, 2);
    defer weighted_index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 2), weighted_index_vec.len());
    var weighted_index_vec_iter = weighted_index_vec.iter();
    while (weighted_index_vec_iter.next()) |value| try std.testing.expect(value < weights.len);
    const weighted_index_vec_checked = try sampleWeightedIndexVecChecked(f64, io, std.testing.allocator, &weights, 2);
    defer weighted_index_vec_checked.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 2), weighted_index_vec_checked.len());
    var weighted_index_vec_checked_iter = weighted_index_vec_checked.iter();
    while (weighted_index_vec_checked_iter.next()) |value| try std.testing.expect(value < weights.len);
    var weighted_sample_indices_u32_into: [2]u32 = undefined;
    var weighted_sample_u32_keys: [2]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 2), try sampleWeightedIndicesU32Into(f64, io, &weights, &weighted_sample_indices_u32_into, &weighted_sample_u32_keys));
    try std.testing.expect(weighted_sample_indices_u32_into[0] != weighted_sample_indices_u32_into[1]);
    for (weighted_sample_indices_u32_into) |value| try std.testing.expect(value < weights.len);
    try sampleWeightedIndicesU32IntoChecked(f64, io, &weights, &weighted_sample_indices_u32_into, &weighted_sample_u32_keys);
    try std.testing.expect(weighted_sample_indices_u32_into[0] != weighted_sample_indices_u32_into[1]);
    for (weighted_sample_indices_u32_into) |value| try std.testing.expect(value < weights.len);
    const weighted_sample_index_array_u32 = (try sampleWeightedIndexArrayU32(f64, io, 2, &weights)).?;
    try std.testing.expect(weighted_sample_index_array_u32[0] != weighted_sample_index_array_u32[1]);
    for (weighted_sample_index_array_u32) |value| try std.testing.expect(value < weights.len);
    const weighted_sample_index_array_u32_checked = try sampleWeightedIndexArrayU32Checked(f64, io, 2, &weights);
    try std.testing.expect(weighted_sample_index_array_u32_checked[0] != weighted_sample_index_array_u32_checked[1]);
    for (weighted_sample_index_array_u32_checked) |value| try std.testing.expect(value < weights.len);
    const weighted_items = [_]u8{ 10, 20, 30, 40 };
    var weighted_sample_values_into: [2]u8 = undefined;
    var weighted_sample_value_indices: [2]usize = undefined;
    var weighted_sample_value_keys: [2]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 2), try sampleWeightedInto(u8, f64, io, &weighted_items, &weights, &weighted_sample_values_into, &weighted_sample_value_indices, &weighted_sample_value_keys));
    try std.testing.expect(weighted_sample_values_into[0] != weighted_sample_values_into[1]);
    for (weighted_sample_values_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value) != null);
    try sampleWeightedIntoChecked(u8, f64, io, &weighted_items, &weights, &weighted_sample_values_into, &weighted_sample_value_indices, &weighted_sample_value_keys);
    try std.testing.expect(weighted_sample_values_into[0] != weighted_sample_values_into[1]);
    for (weighted_sample_values_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value) != null);
    var weighted_sample_ptrs_into: [2]*const u8 = undefined;
    var weighted_sample_ptr_indices: [2]usize = undefined;
    var weighted_sample_ptr_keys: [2]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 2), try sampleWeightedPtrsInto(u8, f64, io, &weighted_items, &weights, &weighted_sample_ptrs_into, &weighted_sample_ptr_indices, &weighted_sample_ptr_keys));
    try std.testing.expect(weighted_sample_ptrs_into[0] != weighted_sample_ptrs_into[1]);
    for (weighted_sample_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    try sampleWeightedPtrsIntoChecked(u8, f64, io, &weighted_items, &weights, &weighted_sample_ptrs_into, &weighted_sample_ptr_indices, &weighted_sample_ptr_keys);
    try std.testing.expect(weighted_sample_ptrs_into[0] != weighted_sample_ptrs_into[1]);
    for (weighted_sample_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    var weighted_sample_mut_ptr_items = weighted_items;
    var weighted_sample_mut_ptrs_into: [2]*u8 = undefined;
    var weighted_sample_mut_ptr_indices: [2]usize = undefined;
    var weighted_sample_mut_ptr_keys: [2]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 2), try sampleWeightedMutPtrsInto(u8, f64, io, &weighted_sample_mut_ptr_items, &weights, &weighted_sample_mut_ptrs_into, &weighted_sample_mut_ptr_indices, &weighted_sample_mut_ptr_keys));
    try std.testing.expect(weighted_sample_mut_ptrs_into[0] != weighted_sample_mut_ptrs_into[1]);
    for (weighted_sample_mut_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    try sampleWeightedMutPtrsIntoChecked(u8, f64, io, &weighted_sample_mut_ptr_items, &weights, &weighted_sample_mut_ptrs_into, &weighted_sample_mut_ptr_indices, &weighted_sample_mut_ptr_keys);
    try std.testing.expect(weighted_sample_mut_ptrs_into[0] != weighted_sample_mut_ptrs_into[1]);
    for (weighted_sample_mut_ptrs_into) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    var weighted_mut_nr_items = weighted_items;
    const weighted_mut_ptrs = try sampleWeightedMutPtrs(u8, f64, io, std.testing.allocator, &weighted_mut_nr_items, &weights, 2);
    defer std.testing.allocator.free(weighted_mut_ptrs);
    try std.testing.expectEqual(@as(usize, 2), weighted_mut_ptrs.len);
    try std.testing.expect(weighted_mut_ptrs[0] != weighted_mut_ptrs[1]);
    for (weighted_mut_ptrs) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    var weighted_mut_nr_checked_items = weighted_items;
    const weighted_mut_ptrs_checked = try sampleWeightedMutPtrsChecked(u8, f64, io, std.testing.allocator, &weighted_mut_nr_checked_items, &weights, 2);
    defer std.testing.allocator.free(weighted_mut_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 2), weighted_mut_ptrs_checked.len);
    try std.testing.expect(weighted_mut_ptrs_checked[0] != weighted_mut_ptrs_checked[1]);
    for (weighted_mut_ptrs_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    var weighted_mut_array_items = weighted_items;
    const weighted_mut_ptr_array = (try sampleWeightedMutPtrArray(u8, f64, io, 2, &weighted_mut_array_items, &weights)).?;
    try std.testing.expect(weighted_mut_ptr_array[0] != weighted_mut_ptr_array[1]);
    for (weighted_mut_ptr_array) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    var weighted_mut_array_checked_items = weighted_items;
    const weighted_mut_ptr_array_checked = try sampleWeightedMutPtrArrayChecked(u8, f64, io, 2, &weighted_mut_array_checked_items, &weights);
    try std.testing.expect(weighted_mut_ptr_array_checked[0] != weighted_mut_ptr_array_checked[1]);
    for (weighted_mut_ptr_array_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    const weighted_choice_value = (try chooseWeighted(u8, io, &weighted_items, &weights)).?;
    try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, weighted_choice_value) != null);
    const weighted_choice_checked_value = try chooseWeightedChecked(u8, io, &weighted_items, &weights);
    try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, weighted_choice_checked_value) != null);
    var weighted_choice_fill: [4]?u8 = undefined;
    try fillChooseWeighted(u8, io, &weighted_choice_fill, &weighted_items, &weights);
    for (weighted_choice_fill) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.?) != null);
    var weighted_choice_checked_fill: [4]u8 = undefined;
    try fillChooseWeightedChecked(u8, io, &weighted_choice_checked_fill, &weighted_items, &weights);
    for (weighted_choice_checked_fill) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value) != null);
    const weighted_choice_batch = try chooseWeightedBatch(u8, io, std.testing.allocator, 4, &weighted_items, &weights);
    defer std.testing.allocator.free(weighted_choice_batch);
    for (weighted_choice_batch) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.?) != null);
    const weighted_choice_batch_checked = try chooseWeightedBatchChecked(u8, io, std.testing.allocator, 4, &weighted_items, &weights);
    defer std.testing.allocator.free(weighted_choice_batch_checked);
    for (weighted_choice_batch_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value) != null);
    const weighted_choice_array = (try chooseWeightedValueArray(u8, io, 4, &weighted_items, &weights)).?;
    for (weighted_choice_array) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value) != null);
    const weighted_choice_array_checked = try chooseWeightedValueArrayChecked(u8, io, 4, &weighted_items, &weights);
    for (weighted_choice_array_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value) != null);
    const weighted_choice_const_ptr = (try chooseWeightedConstPtr(u8, io, &weighted_items, &weights)).?;
    try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, weighted_choice_const_ptr.*) != null);
    const weighted_choice_const_ptr_checked = try chooseWeightedConstPtrChecked(u8, io, &weighted_items, &weights);
    try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, weighted_choice_const_ptr_checked.*) != null);
    var weighted_choice_const_ptr_fill: [4]?*const u8 = undefined;
    try fillChooseWeightedConstPtr(u8, io, &weighted_choice_const_ptr_fill, &weighted_items, &weights);
    for (weighted_choice_const_ptr_fill) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.?.*) != null);
    var weighted_choice_const_ptr_checked_fill: [4]*const u8 = undefined;
    try fillChooseWeightedConstPtrChecked(u8, io, &weighted_choice_const_ptr_checked_fill, &weighted_items, &weights);
    for (weighted_choice_const_ptr_checked_fill) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    const weighted_choice_const_ptr_batch = try chooseWeightedConstPtrBatch(u8, io, std.testing.allocator, 4, &weighted_items, &weights);
    defer std.testing.allocator.free(weighted_choice_const_ptr_batch);
    for (weighted_choice_const_ptr_batch) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.?.*) != null);
    const weighted_choice_const_ptr_batch_checked = try chooseWeightedConstPtrBatchChecked(u8, io, std.testing.allocator, 4, &weighted_items, &weights);
    defer std.testing.allocator.free(weighted_choice_const_ptr_batch_checked);
    for (weighted_choice_const_ptr_batch_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    const weighted_choice_const_ptr_array = (try chooseWeightedConstPtrArray(u8, io, 4, &weighted_items, &weights)).?;
    for (weighted_choice_const_ptr_array) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    const weighted_choice_const_ptr_array_checked = try chooseWeightedConstPtrArrayChecked(u8, io, 4, &weighted_items, &weights);
    for (weighted_choice_const_ptr_array_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    var weighted_mut_items = weighted_items;
    const weighted_choice_ptr = (try chooseWeightedPtr(u8, io, &weighted_mut_items, &weights)).?;
    try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, weighted_choice_ptr.*) != null);
    const weighted_choice_ptr_checked = try chooseWeightedPtrChecked(u8, io, &weighted_mut_items, &weights);
    try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, weighted_choice_ptr_checked.*) != null);
    var weighted_choice_ptr_fill: [4]?*u8 = undefined;
    try fillChooseWeightedPtr(u8, io, &weighted_choice_ptr_fill, &weighted_mut_items, &weights);
    for (weighted_choice_ptr_fill) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.?.*) != null);
    var weighted_choice_ptr_checked_fill: [4]*u8 = undefined;
    try fillChooseWeightedPtrChecked(u8, io, &weighted_choice_ptr_checked_fill, &weighted_mut_items, &weights);
    for (weighted_choice_ptr_checked_fill) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    const weighted_choice_ptr_batch = try chooseWeightedPtrBatch(u8, io, std.testing.allocator, 4, &weighted_mut_items, &weights);
    defer std.testing.allocator.free(weighted_choice_ptr_batch);
    for (weighted_choice_ptr_batch) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.?.*) != null);
    const weighted_choice_ptr_batch_checked = try chooseWeightedPtrBatchChecked(u8, io, std.testing.allocator, 4, &weighted_mut_items, &weights);
    defer std.testing.allocator.free(weighted_choice_ptr_batch_checked);
    for (weighted_choice_ptr_batch_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    const weighted_choice_ptr_array = (try chooseWeightedPtrArray(u8, io, 4, &weighted_mut_items, &weights)).?;
    for (weighted_choice_ptr_array) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
    const weighted_choice_ptr_array_checked = try chooseWeightedPtrArrayChecked(u8, io, 4, &weighted_mut_items, &weights);
    for (weighted_choice_ptr_array_checked) |value| try std.testing.expect(std.mem.indexOfScalar(u8, &weighted_items, value.*) != null);
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
    const RootSampleIter = struct {
        next_value: u8 = 0,
        pub fn next(self: *@This()) ?u8 {
            if (self.next_value == 8) return null;
            const value = self.next_value;
            self.next_value += 1;
            return value;
        }
    };
    var sample_iter = RootSampleIter{};
    var sample_iter_out: [4]u8 = undefined;
    try std.testing.expectEqual(@as(usize, 4), try sampleIteratorInto(u8, io, &sample_iter, &sample_iter_out));
    var sample_fill_iter = RootSampleIter{};
    var sample_fill_out: [4]u8 = undefined;
    try std.testing.expectEqual(@as(usize, 4), try sampleIteratorFill(u8, io, &sample_fill_iter, &sample_fill_out));
    var sample_fill_checked_iter = RootSampleIter{};
    try sampleIteratorFillChecked(u8, io, &sample_fill_checked_iter, &sample_fill_out);
    const RootWeightedSampleIter = struct {
        const Entry = struct { item: u8, weight: f64 };
        items: []const Entry,
        index: usize = 0,
        pub fn next(self: *@This()) ?Entry {
            if (self.index == self.items.len) return null;
            const value = self.items[self.index];
            self.index += 1;
            return value;
        }
    };
    const weighted_sample_entries = [_]RootWeightedSampleIter.Entry{
        .{ .item = 1, .weight = 1 },
        .{ .item = 2, .weight = 2 },
        .{ .item = 3, .weight = 3 },
    };
    var weighted_sample_iter = RootWeightedSampleIter{ .items = &weighted_sample_entries };
    const weighted_sample = try sampleIteratorWeighted(u8, io, std.testing.allocator, &weighted_sample_iter, 2);
    defer std.testing.allocator.free(weighted_sample);
    try std.testing.expectEqual(@as(usize, 2), weighted_sample.len);
}

test "root random helpers validate deterministic cases before entropy" {
    @setEvalBranchQuota(4000);
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
    var empty_index_fill_nonempty: [1]usize = undefined;
    try std.testing.expectError(error.EmptyRange, fillChooseIndex(failing, &empty_index_fill_nonempty, 0));
    const empty_index_batch_zero = try chooseIndexBatch(failing, std.testing.allocator, 0, 0);
    defer std.testing.allocator.free(empty_index_batch_zero);
    try std.testing.expectEqual(@as(usize, 0), empty_index_batch_zero.len);
    try std.testing.expectError(error.EmptyRange, chooseIndexBatch(failing, std.testing.allocator, 1, 0));
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
    try std.testing.expect((try chooseIndexArray(failing, 0, 0)) != null);
    try std.testing.expectEqual(@as(?[3]usize, null), try chooseIndexArray(failing, 3, 0));
    try std.testing.expectError(error.EmptyRange, chooseIndexArrayChecked(failing, 3, 0));
    try std.testing.expectEqualSlices(usize, &.{ 0, 0, 0 }, &(try chooseIndexArrayChecked(failing, 3, 1)));
    try std.testing.expectEqual(@as(?u32, null), try chooseIndexU32(failing, 0));
    var empty_index_u32_fill_nonempty: [1]u32 = undefined;
    try std.testing.expectError(error.EmptyRange, fillChooseIndexU32(failing, &empty_index_u32_fill_nonempty, 0));
    const empty_index_u32_batch_zero = try chooseIndexU32Batch(failing, std.testing.allocator, 0, 0);
    defer std.testing.allocator.free(empty_index_u32_batch_zero);
    try std.testing.expectEqual(@as(usize, 0), empty_index_u32_batch_zero.len);
    try std.testing.expectError(error.EmptyRange, chooseIndexU32Batch(failing, std.testing.allocator, 1, 0));
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
    try std.testing.expect((try chooseIndexArrayU32(failing, 0, 0)) != null);
    try std.testing.expectEqual(@as(?[3]u32, null), try chooseIndexArrayU32(failing, 3, 0));
    try std.testing.expectError(error.EmptyRange, chooseIndexArrayU32Checked(failing, 3, 0));
    try std.testing.expectEqualSlices(u32, &.{ 0, 0, 0 }, &(try chooseIndexArrayU32Checked(failing, 3, 1)));
    const singleton = [_]u8{42};
    try std.testing.expectEqual(@as(?u8, null), try choose(u8, failing, &.{}));
    try std.testing.expectEqual(@as(?u8, 42), try choose(u8, failing, &singleton));
    try std.testing.expectEqual(@as(u8, 42), try chooseChecked(u8, failing, &singleton));
    try std.testing.expectError(error.EmptyRange, chooseChecked(u8, failing, &.{}));
    var empty_values: [0]u8 = .{};
    try fillChoose(u8, failing, &empty_values, &.{});
    try fillChooseChecked(u8, failing, &empty_values, &.{});
    var empty_values_nonempty: [1]u8 = undefined;
    try std.testing.expectError(error.EmptyRange, fillChoose(u8, failing, &empty_values_nonempty, &.{}));
    var fixed_values: [3]u8 = undefined;
    try fillChoose(u8, failing, &fixed_values, &singleton);
    try std.testing.expectEqualSlices(u8, &.{ 42, 42, 42 }, &fixed_values);
    try fillChooseChecked(u8, failing, &fixed_values, &singleton);
    try std.testing.expectEqualSlices(u8, &.{ 42, 42, 42 }, &fixed_values);
    const empty_choose_batch = try chooseBatch(u8, failing, std.testing.allocator, 0, &.{});
    defer std.testing.allocator.free(empty_choose_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_choose_batch.len);
    try std.testing.expectError(error.EmptyRange, chooseBatch(u8, failing, std.testing.allocator, 1, &.{}));
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
    try std.testing.expect((try chooseValueArray(u8, failing, 0, &.{})) != null);
    try std.testing.expectEqual(@as(?[3]u8, null), try chooseValueArray(u8, failing, 3, &.{}));
    try std.testing.expectError(error.EmptyRange, chooseValueArrayChecked(u8, failing, 3, &.{}));
    try std.testing.expectEqualSlices(u8, &.{ 42, 42, 42 }, &(try chooseValueArrayChecked(u8, failing, 3, &singleton)));
    try std.testing.expect((try chooseRepeatedValueArray(u8, failing, 0, &.{})) != null);
    try std.testing.expectEqual(@as(?[3]u8, null), try chooseRepeatedValueArray(u8, failing, 3, &.{}));
    try std.testing.expectError(error.EmptyRange, chooseRepeatedValueArrayChecked(u8, failing, 3, &.{}));
    try std.testing.expectEqualSlices(u8, &.{ 42, 42, 42 }, &(try chooseRepeatedValueArrayChecked(u8, failing, 3, &singleton)));
    try std.testing.expect((try chooseConstPtrArray(u8, failing, 0, &.{})) != null);
    try std.testing.expectEqual(@as(?*const u8, null), try chooseConstPtr(u8, failing, &.{}));
    try std.testing.expectEqual(@as(*const u8, &singleton[0]), (try chooseConstPtr(u8, failing, &singleton)).?);
    try std.testing.expectEqual(@as(*const u8, &singleton[0]), try chooseConstPtrChecked(u8, failing, &singleton));
    try std.testing.expectError(error.EmptyRange, chooseConstPtrChecked(u8, failing, &.{}));
    var empty_const_ptrs: [0]*const u8 = .{};
    try fillChooseConstPtr(u8, failing, &empty_const_ptrs, &.{});
    try fillChooseConstPtrChecked(u8, failing, &empty_const_ptrs, &.{});
    var empty_const_ptrs_nonempty: [1]*const u8 = undefined;
    try std.testing.expectError(error.EmptyRange, fillChooseConstPtr(u8, failing, &empty_const_ptrs_nonempty, &.{}));
    var fixed_const_ptrs: [3]*const u8 = undefined;
    try fillChooseConstPtr(u8, failing, &fixed_const_ptrs, &singleton);
    for (fixed_const_ptrs) |value| try std.testing.expectEqual(&singleton[0], value);
    try fillChooseConstPtrChecked(u8, failing, &fixed_const_ptrs, &singleton);
    for (fixed_const_ptrs) |value| try std.testing.expectEqual(&singleton[0], value);
    const empty_const_ptr_batch = try chooseConstPtrBatch(u8, failing, std.testing.allocator, 0, &.{});
    defer std.testing.allocator.free(empty_const_ptr_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_const_ptr_batch.len);
    try std.testing.expectError(error.EmptyRange, chooseConstPtrBatch(u8, failing, std.testing.allocator, 1, &.{}));
    const empty_const_ptr_batch_checked = try chooseConstPtrBatchChecked(u8, failing, std.testing.allocator, 0, &.{});
    defer std.testing.allocator.free(empty_const_ptr_batch_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_const_ptr_batch_checked.len);
    const fixed_const_ptr_batch = try chooseConstPtrBatch(u8, failing, std.testing.allocator, 3, &singleton);
    defer std.testing.allocator.free(fixed_const_ptr_batch);
    for (fixed_const_ptr_batch) |value| try std.testing.expectEqual(&singleton[0], value);
    const fixed_const_ptr_batch_checked = try chooseConstPtrBatchChecked(u8, failing, std.testing.allocator, 3, &singleton);
    defer std.testing.allocator.free(fixed_const_ptr_batch_checked);
    for (fixed_const_ptr_batch_checked) |value| try std.testing.expectEqual(&singleton[0], value);
    try std.testing.expectEqual(@as(?[3]*const u8, null), try chooseConstPtrArray(u8, failing, 3, &.{}));
    try std.testing.expectError(error.EmptyRange, chooseConstPtrArrayChecked(u8, failing, 3, &.{}));
    const fixed_const_ptr_array = (try chooseConstPtrArray(u8, failing, 3, &singleton)).?;
    for (fixed_const_ptr_array) |value| try std.testing.expectEqual(&singleton[0], value);
    const fixed_const_ptr_array_checked = try chooseConstPtrArrayChecked(u8, failing, 3, &singleton);
    for (fixed_const_ptr_array_checked) |value| try std.testing.expectEqual(&singleton[0], value);
    try std.testing.expect((try chooseRepeatedConstPtrArray(u8, failing, 0, &.{})) != null);
    try std.testing.expectEqual(@as(?[3]*const u8, null), try chooseRepeatedConstPtrArray(u8, failing, 3, &.{}));
    try std.testing.expectError(error.EmptyRange, chooseRepeatedConstPtrArrayChecked(u8, failing, 3, &.{}));
    const fixed_repeated_const_ptr_array = (try chooseRepeatedConstPtrArray(u8, failing, 3, &singleton)).?;
    for (fixed_repeated_const_ptr_array) |value| try std.testing.expectEqual(&singleton[0], value);
    const fixed_repeated_const_ptr_array_checked = try chooseRepeatedConstPtrArrayChecked(u8, failing, 3, &singleton);
    for (fixed_repeated_const_ptr_array_checked) |value| try std.testing.expectEqual(&singleton[0], value);
    try std.testing.expectError(error.EmptyRange, chooseConstPtrBatchChecked(u8, failing, std.testing.allocator, 3, &.{}));
    var mutable_singleton = [_]u8{42};
    try std.testing.expect((try choosePtrArray(u8, failing, 0, &mutable_singleton)) != null);
    try std.testing.expectEqual(@as(?*u8, null), try choosePtr(u8, failing, &.{}));
    try std.testing.expectEqual(&mutable_singleton[0], (try choosePtr(u8, failing, &mutable_singleton)).?);
    try std.testing.expectEqual(&mutable_singleton[0], try choosePtrChecked(u8, failing, &mutable_singleton));
    try std.testing.expectError(error.EmptyRange, choosePtrChecked(u8, failing, &.{}));
    var empty_ptrs: [0]*u8 = .{};
    try fillChoosePtr(u8, failing, &empty_ptrs, &.{});
    try fillChoosePtrChecked(u8, failing, &empty_ptrs, &.{});
    var empty_ptrs_nonempty: [1]*u8 = undefined;
    try std.testing.expectError(error.EmptyRange, fillChoosePtr(u8, failing, &empty_ptrs_nonempty, &.{}));
    var fixed_ptrs: [3]*u8 = undefined;
    try fillChoosePtr(u8, failing, &fixed_ptrs, &mutable_singleton);
    for (fixed_ptrs) |value| try std.testing.expectEqual(&mutable_singleton[0], value);
    try fillChoosePtrChecked(u8, failing, &fixed_ptrs, &mutable_singleton);
    for (fixed_ptrs) |value| try std.testing.expectEqual(&mutable_singleton[0], value);
    const empty_ptr_batch = try choosePtrBatch(u8, failing, std.testing.allocator, 0, &.{});
    defer std.testing.allocator.free(empty_ptr_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_ptr_batch.len);
    try std.testing.expectError(error.EmptyRange, choosePtrBatch(u8, failing, std.testing.allocator, 1, &.{}));
    const empty_ptr_batch_checked = try choosePtrBatchChecked(u8, failing, std.testing.allocator, 0, &.{});
    defer std.testing.allocator.free(empty_ptr_batch_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_ptr_batch_checked.len);
    const fixed_ptr_batch = try choosePtrBatch(u8, failing, std.testing.allocator, 3, &mutable_singleton);
    defer std.testing.allocator.free(fixed_ptr_batch);
    for (fixed_ptr_batch) |value| try std.testing.expectEqual(&mutable_singleton[0], value);
    const fixed_ptr_batch_checked = try choosePtrBatchChecked(u8, failing, std.testing.allocator, 3, &mutable_singleton);
    defer std.testing.allocator.free(fixed_ptr_batch_checked);
    for (fixed_ptr_batch_checked) |value| try std.testing.expectEqual(&mutable_singleton[0], value);
    try std.testing.expectEqual(@as(?[3]*u8, null), try choosePtrArray(u8, failing, 3, &.{}));
    try std.testing.expectError(error.EmptyRange, choosePtrArrayChecked(u8, failing, 3, &.{}));
    const fixed_ptr_array = (try choosePtrArray(u8, failing, 3, &mutable_singleton)).?;
    for (fixed_ptr_array) |value| try std.testing.expectEqual(&mutable_singleton[0], value);
    const fixed_ptr_array_checked = try choosePtrArrayChecked(u8, failing, 3, &mutable_singleton);
    for (fixed_ptr_array_checked) |value| try std.testing.expectEqual(&mutable_singleton[0], value);
    try std.testing.expect((try chooseRepeatedPtrArray(u8, failing, 0, &mutable_singleton)) != null);
    try std.testing.expectEqual(@as(?[3]*u8, null), try chooseRepeatedPtrArray(u8, failing, 3, &.{}));
    try std.testing.expectError(error.EmptyRange, chooseRepeatedPtrArrayChecked(u8, failing, 3, &.{}));
    const fixed_repeated_ptr_array = (try chooseRepeatedPtrArray(u8, failing, 3, &mutable_singleton)).?;
    for (fixed_repeated_ptr_array) |value| try std.testing.expectEqual(&mutable_singleton[0], value);
    const fixed_repeated_ptr_array_checked = try chooseRepeatedPtrArrayChecked(u8, failing, 3, &mutable_singleton);
    for (fixed_repeated_ptr_array_checked) |value| try std.testing.expectEqual(&mutable_singleton[0], value);
    try std.testing.expectError(error.EmptyRange, choosePtrBatchChecked(u8, failing, std.testing.allocator, 3, &.{}));
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
    const sample_items = [_]u8{ 10, 20, 30 };
    const empty_without_replacement = try sampleWithoutReplacement(u8, failing, std.testing.allocator, &sample_items, 0);
    defer std.testing.allocator.free(empty_without_replacement);
    try std.testing.expectEqual(@as(usize, 0), empty_without_replacement.len);
    const empty_without_replacement_checked = try sampleWithoutReplacementChecked(u8, failing, std.testing.allocator, &sample_items, 0);
    defer std.testing.allocator.free(empty_without_replacement_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_without_replacement_checked.len);
    const all_without_replacement = try sampleWithoutReplacement(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer std.testing.allocator.free(all_without_replacement);
    try std.testing.expectEqualSlices(u8, &sample_items, all_without_replacement);
    const all_without_replacement_checked = try sampleWithoutReplacementChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer std.testing.allocator.free(all_without_replacement_checked);
    try std.testing.expectEqualSlices(u8, &sample_items, all_without_replacement_checked);
    try std.testing.expectError(error.InvalidParameter, sampleWithoutReplacementChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len + 1));
    const empty_choose_multiple = try chooseMultiple(u8, failing, std.testing.allocator, &sample_items, 0);
    defer std.testing.allocator.free(empty_choose_multiple);
    try std.testing.expectEqual(@as(usize, 0), empty_choose_multiple.len);
    const empty_choose_multiple_checked = try chooseMultipleChecked(u8, failing, std.testing.allocator, &sample_items, 0);
    defer std.testing.allocator.free(empty_choose_multiple_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_choose_multiple_checked.len);
    const all_choose_multiple = try chooseMultiple(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer std.testing.allocator.free(all_choose_multiple);
    try std.testing.expectEqualSlices(u8, &sample_items, all_choose_multiple);
    const all_choose_multiple_checked = try chooseMultipleChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer std.testing.allocator.free(all_choose_multiple_checked);
    try std.testing.expectEqualSlices(u8, &sample_items, all_choose_multiple_checked);
    try std.testing.expectError(error.InvalidParameter, chooseMultipleChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len + 1));
    try std.testing.expect((try sampleItemsArray(u8, failing, 0, &sample_items)) != null);
    try std.testing.expectEqual(@as(usize, 0), (try sampleItemsArrayChecked(u8, failing, 0, &sample_items)).len);
    try std.testing.expectEqualSlices(u8, &sample_items, &(try sampleItemsArray(u8, failing, 3, &sample_items)).?);
    try std.testing.expectEqualSlices(u8, &sample_items, &(try sampleItemsArrayChecked(u8, failing, 3, &sample_items)));
    try std.testing.expectEqual(@as(?[4]u8, null), try sampleItemsArray(u8, failing, 4, &sample_items));
    try std.testing.expectError(error.InvalidParameter, sampleItemsArrayChecked(u8, failing, 4, &sample_items));
    try std.testing.expect((try chooseArray(u8, failing, 0, &sample_items)) != null);
    try std.testing.expectEqual(@as(usize, 0), (try chooseArrayChecked(u8, failing, 0, &sample_items)).len);
    try std.testing.expectEqualSlices(u8, &sample_items, &(try chooseArray(u8, failing, 3, &sample_items)).?);
    try std.testing.expectEqualSlices(u8, &sample_items, &(try chooseArrayChecked(u8, failing, 3, &sample_items)));
    try std.testing.expectEqual(@as(?[4]u8, null), try chooseArray(u8, failing, 4, &sample_items));
    try std.testing.expectError(error.InvalidParameter, chooseArrayChecked(u8, failing, 4, &sample_items));
    try std.testing.expect((try samplePtrArray(u8, failing, 0, &sample_items)) != null);
    try std.testing.expectEqual(@as(usize, 0), (try samplePtrArrayChecked(u8, failing, 0, &sample_items)).len);
    const all_ptr_array = (try samplePtrArray(u8, failing, 3, &sample_items)).?;
    for (all_ptr_array, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    const all_ptr_array_checked = try samplePtrArrayChecked(u8, failing, 3, &sample_items);
    for (all_ptr_array_checked, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    try std.testing.expectEqual(@as(?[4]*const u8, null), try samplePtrArray(u8, failing, 4, &sample_items));
    try std.testing.expectError(error.InvalidParameter, samplePtrArrayChecked(u8, failing, 4, &sample_items));
    const empty_sample_ptrs = try samplePtrs(u8, failing, std.testing.allocator, &sample_items, 0);
    defer std.testing.allocator.free(empty_sample_ptrs);
    try std.testing.expectEqual(@as(usize, 0), empty_sample_ptrs.len);
    const empty_sample_ptrs_checked = try samplePtrsChecked(u8, failing, std.testing.allocator, &sample_items, 0);
    defer std.testing.allocator.free(empty_sample_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_sample_ptrs_checked.len);
    const all_ptrs = try samplePtrs(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer std.testing.allocator.free(all_ptrs);
    for (all_ptrs, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    const all_ptrs_checked = try samplePtrsChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer std.testing.allocator.free(all_ptrs_checked);
    for (all_ptrs_checked, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    try std.testing.expectError(error.InvalidParameter, samplePtrsChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len + 1));
    const empty_choose_multiple_ptrs = try chooseMultiplePtrs(u8, failing, std.testing.allocator, &sample_items, 0);
    defer std.testing.allocator.free(empty_choose_multiple_ptrs);
    try std.testing.expectEqual(@as(usize, 0), empty_choose_multiple_ptrs.len);
    const empty_choose_multiple_ptrs_checked = try chooseMultiplePtrsChecked(u8, failing, std.testing.allocator, &sample_items, 0);
    defer std.testing.allocator.free(empty_choose_multiple_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_choose_multiple_ptrs_checked.len);
    const all_choose_multiple_ptrs = try chooseMultiplePtrs(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer std.testing.allocator.free(all_choose_multiple_ptrs);
    for (all_choose_multiple_ptrs, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    const all_choose_multiple_ptrs_checked = try chooseMultiplePtrsChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer std.testing.allocator.free(all_choose_multiple_ptrs_checked);
    for (all_choose_multiple_ptrs_checked, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    try std.testing.expectError(error.InvalidParameter, chooseMultiplePtrsChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len + 1));
    var mutable_sample_items = sample_items;
    try std.testing.expect((try sampleMutPtrArray(u8, failing, 0, &mutable_sample_items)) != null);
    try std.testing.expectEqual(@as(usize, 0), (try sampleMutPtrArrayChecked(u8, failing, 0, &mutable_sample_items)).len);
    const all_mut_ptr_array = (try sampleMutPtrArray(u8, failing, 3, &mutable_sample_items)).?;
    for (all_mut_ptr_array, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    const all_mut_ptr_array_checked = try sampleMutPtrArrayChecked(u8, failing, 3, &mutable_sample_items);
    for (all_mut_ptr_array_checked, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    try std.testing.expectEqual(@as(?[4]*u8, null), try sampleMutPtrArray(u8, failing, 4, &mutable_sample_items));
    try std.testing.expectError(error.InvalidParameter, sampleMutPtrArrayChecked(u8, failing, 4, &mutable_sample_items));
    const empty_sample_mut_ptrs = try sampleMutPtrs(u8, failing, std.testing.allocator, &mutable_sample_items, 0);
    defer std.testing.allocator.free(empty_sample_mut_ptrs);
    try std.testing.expectEqual(@as(usize, 0), empty_sample_mut_ptrs.len);
    const empty_sample_mut_ptrs_checked = try sampleMutPtrsChecked(u8, failing, std.testing.allocator, &mutable_sample_items, 0);
    defer std.testing.allocator.free(empty_sample_mut_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_sample_mut_ptrs_checked.len);
    const all_mut_ptrs = try sampleMutPtrs(u8, failing, std.testing.allocator, &mutable_sample_items, mutable_sample_items.len);
    defer std.testing.allocator.free(all_mut_ptrs);
    for (all_mut_ptrs, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    const all_mut_ptrs_checked = try sampleMutPtrsChecked(u8, failing, std.testing.allocator, &mutable_sample_items, mutable_sample_items.len);
    defer std.testing.allocator.free(all_mut_ptrs_checked);
    for (all_mut_ptrs_checked, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    try std.testing.expectError(error.InvalidParameter, sampleMutPtrsChecked(u8, failing, std.testing.allocator, &mutable_sample_items, mutable_sample_items.len + 1));
    const empty_choose_multiple_mut_ptrs = try chooseMultipleMutPtrs(u8, failing, std.testing.allocator, &mutable_sample_items, 0);
    defer std.testing.allocator.free(empty_choose_multiple_mut_ptrs);
    try std.testing.expectEqual(@as(usize, 0), empty_choose_multiple_mut_ptrs.len);
    const empty_choose_multiple_mut_ptrs_checked = try chooseMultipleMutPtrsChecked(u8, failing, std.testing.allocator, &mutable_sample_items, 0);
    defer std.testing.allocator.free(empty_choose_multiple_mut_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_choose_multiple_mut_ptrs_checked.len);
    const all_choose_multiple_mut_ptrs = try chooseMultipleMutPtrs(u8, failing, std.testing.allocator, &mutable_sample_items, mutable_sample_items.len);
    defer std.testing.allocator.free(all_choose_multiple_mut_ptrs);
    for (all_choose_multiple_mut_ptrs, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    const all_choose_multiple_mut_ptrs_checked = try chooseMultipleMutPtrsChecked(u8, failing, std.testing.allocator, &mutable_sample_items, mutable_sample_items.len);
    defer std.testing.allocator.free(all_choose_multiple_mut_ptrs_checked);
    for (all_choose_multiple_mut_ptrs_checked, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    try std.testing.expectError(error.InvalidParameter, chooseMultipleMutPtrsChecked(u8, failing, std.testing.allocator, &mutable_sample_items, mutable_sample_items.len + 1));
    var empty_values_into: [0]u8 = .{};
    var empty_values_scratch: [0]usize = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleItemsInto(u8, failing, &sample_items, &empty_values_into, &empty_values_scratch));
    try sampleItemsIntoChecked(u8, failing, &sample_items, &empty_values_into, &empty_values_scratch);
    try std.testing.expectEqual(@as(usize, 0), try chooseMultipleInto(u8, failing, &sample_items, &empty_values_into, &empty_values_scratch));
    try chooseMultipleIntoChecked(u8, failing, &sample_items, &empty_values_into, &empty_values_scratch);
    var all_values_into: [3]u8 = undefined;
    var all_values_scratch: [3]usize = undefined;
    try std.testing.expectEqual(@as(usize, 3), try sampleItemsInto(u8, failing, &sample_items, &all_values_into, &all_values_scratch));
    try std.testing.expectEqualSlices(u8, &sample_items, &all_values_into);
    try sampleItemsIntoChecked(u8, failing, &sample_items, &all_values_into, &all_values_scratch);
    try std.testing.expectEqualSlices(u8, &sample_items, &all_values_into);
    try std.testing.expectEqual(@as(usize, 3), try chooseMultipleInto(u8, failing, &sample_items, &all_values_into, &all_values_scratch));
    try std.testing.expectEqualSlices(u8, &sample_items, &all_values_into);
    try chooseMultipleIntoChecked(u8, failing, &sample_items, &all_values_into, &all_values_scratch);
    try std.testing.expectEqualSlices(u8, &sample_items, &all_values_into);
    var too_many_values_into: [4]u8 = undefined;
    var too_many_values_scratch: [4]usize = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleItemsIntoChecked(u8, failing, &sample_items, &too_many_values_into, &too_many_values_scratch));
    try std.testing.expectError(error.InvalidParameter, chooseMultipleIntoChecked(u8, failing, &sample_items, &too_many_values_into, &too_many_values_scratch));
    var one_value_into: [1]u8 = undefined;
    var empty_value_scratch: [0]usize = .{};
    try std.testing.expectError(error.LengthMismatch, sampleItemsInto(u8, failing, &sample_items, &one_value_into, &empty_value_scratch));
    try std.testing.expectError(error.LengthMismatch, sampleItemsIntoChecked(u8, failing, &sample_items, &one_value_into, &empty_value_scratch));
    try std.testing.expectError(error.LengthMismatch, chooseMultipleInto(u8, failing, &sample_items, &one_value_into, &empty_value_scratch));
    try std.testing.expectError(error.LengthMismatch, chooseMultipleIntoChecked(u8, failing, &sample_items, &one_value_into, &empty_value_scratch));
    var empty_ptrs_into: [0]*const u8 = .{};
    var empty_ptrs_scratch: [0]usize = .{};
    try std.testing.expectEqual(@as(usize, 0), try samplePtrsInto(u8, failing, &sample_items, &empty_ptrs_into, &empty_ptrs_scratch));
    try samplePtrsIntoChecked(u8, failing, &sample_items, &empty_ptrs_into, &empty_ptrs_scratch);
    try std.testing.expectEqual(@as(usize, 0), try chooseMultiplePtrsInto(u8, failing, &sample_items, &empty_ptrs_into, &empty_ptrs_scratch));
    try chooseMultiplePtrsIntoChecked(u8, failing, &sample_items, &empty_ptrs_into, &empty_ptrs_scratch);
    var all_ptrs_into: [3]*const u8 = undefined;
    var all_ptrs_scratch: [3]usize = undefined;
    try std.testing.expectEqual(@as(usize, 3), try samplePtrsInto(u8, failing, &sample_items, &all_ptrs_into, &all_ptrs_scratch));
    for (all_ptrs_into, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    try samplePtrsIntoChecked(u8, failing, &sample_items, &all_ptrs_into, &all_ptrs_scratch);
    for (all_ptrs_into, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    try std.testing.expectEqual(@as(usize, 3), try chooseMultiplePtrsInto(u8, failing, &sample_items, &all_ptrs_into, &all_ptrs_scratch));
    for (all_ptrs_into, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    try chooseMultiplePtrsIntoChecked(u8, failing, &sample_items, &all_ptrs_into, &all_ptrs_scratch);
    for (all_ptrs_into, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    var too_many_ptrs_into: [4]*const u8 = undefined;
    var too_many_ptrs_scratch: [4]usize = undefined;
    try std.testing.expectError(error.InvalidParameter, samplePtrsIntoChecked(u8, failing, &sample_items, &too_many_ptrs_into, &too_many_ptrs_scratch));
    try std.testing.expectError(error.InvalidParameter, chooseMultiplePtrsIntoChecked(u8, failing, &sample_items, &too_many_ptrs_into, &too_many_ptrs_scratch));
    var one_ptr_into: [1]*const u8 = undefined;
    var empty_ptr_scratch: [0]usize = .{};
    try std.testing.expectError(error.LengthMismatch, samplePtrsInto(u8, failing, &sample_items, &one_ptr_into, &empty_ptr_scratch));
    try std.testing.expectError(error.LengthMismatch, samplePtrsIntoChecked(u8, failing, &sample_items, &one_ptr_into, &empty_ptr_scratch));
    try std.testing.expectError(error.LengthMismatch, chooseMultiplePtrsInto(u8, failing, &sample_items, &one_ptr_into, &empty_ptr_scratch));
    try std.testing.expectError(error.LengthMismatch, chooseMultiplePtrsIntoChecked(u8, failing, &sample_items, &one_ptr_into, &empty_ptr_scratch));
    var empty_mut_ptrs_into: [0]*u8 = .{};
    var empty_mut_ptrs_scratch: [0]usize = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleMutPtrsInto(u8, failing, &mutable_sample_items, &empty_mut_ptrs_into, &empty_mut_ptrs_scratch));
    try sampleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &empty_mut_ptrs_into, &empty_mut_ptrs_scratch);
    try std.testing.expectEqual(@as(usize, 0), try chooseMultipleMutPtrsInto(u8, failing, &mutable_sample_items, &empty_mut_ptrs_into, &empty_mut_ptrs_scratch));
    try chooseMultipleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &empty_mut_ptrs_into, &empty_mut_ptrs_scratch);
    var all_mut_ptrs_into: [3]*u8 = undefined;
    var all_mut_ptrs_scratch: [3]usize = undefined;
    try std.testing.expectEqual(@as(usize, 3), try sampleMutPtrsInto(u8, failing, &mutable_sample_items, &all_mut_ptrs_into, &all_mut_ptrs_scratch));
    for (all_mut_ptrs_into, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    try sampleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &all_mut_ptrs_into, &all_mut_ptrs_scratch);
    for (all_mut_ptrs_into, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    try std.testing.expectEqual(@as(usize, 3), try chooseMultipleMutPtrsInto(u8, failing, &mutable_sample_items, &all_mut_ptrs_into, &all_mut_ptrs_scratch));
    for (all_mut_ptrs_into, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    try chooseMultipleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &all_mut_ptrs_into, &all_mut_ptrs_scratch);
    for (all_mut_ptrs_into, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    var too_many_mut_ptrs_into: [4]*u8 = undefined;
    var too_many_mut_ptrs_scratch: [4]usize = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &too_many_mut_ptrs_into, &too_many_mut_ptrs_scratch));
    try std.testing.expectError(error.InvalidParameter, chooseMultipleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &too_many_mut_ptrs_into, &too_many_mut_ptrs_scratch));
    var one_mut_ptr_into: [1]*u8 = undefined;
    var empty_mut_ptr_scratch: [0]usize = .{};
    try std.testing.expectError(error.LengthMismatch, sampleMutPtrsInto(u8, failing, &mutable_sample_items, &one_mut_ptr_into, &empty_mut_ptr_scratch));
    try std.testing.expectError(error.LengthMismatch, sampleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &one_mut_ptr_into, &empty_mut_ptr_scratch));
    try std.testing.expectError(error.LengthMismatch, chooseMultipleMutPtrsInto(u8, failing, &mutable_sample_items, &one_mut_ptr_into, &empty_mut_ptr_scratch));
    try std.testing.expectError(error.LengthMismatch, chooseMultipleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &one_mut_ptr_into, &empty_mut_ptr_scratch));
    var empty_values_iter = try sampleItemsIter(u8, failing, std.testing.allocator, &sample_items, 0);
    defer empty_values_iter.deinit();
    try std.testing.expectEqual(@as(usize, 0), empty_values_iter.len());
    var empty_values_iter_checked = try sampleItemsIterChecked(u8, failing, std.testing.allocator, &sample_items, 0);
    defer empty_values_iter_checked.deinit();
    try std.testing.expectEqual(@as(usize, 0), empty_values_iter_checked.len());
    var all_values_iter = try sampleItemsIter(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer all_values_iter.deinit();
    try std.testing.expectEqual(@as(usize, 3), all_values_iter.len());
    var all_values_iter_out: [3]u8 = undefined;
    try std.testing.expectEqual(@as(usize, 3), all_values_iter.fill(&all_values_iter_out));
    try std.testing.expectEqualSlices(u8, &sample_items, &all_values_iter_out);
    var all_values_iter_checked = try sampleItemsIterChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer all_values_iter_checked.deinit();
    try std.testing.expectEqual(@as(usize, 3), all_values_iter_checked.len());
    var all_values_iter_checked_out: [3]u8 = undefined;
    try std.testing.expectEqual(@as(usize, 3), all_values_iter_checked.fill(&all_values_iter_checked_out));
    try std.testing.expectEqualSlices(u8, &sample_items, &all_values_iter_checked_out);
    try std.testing.expectError(error.InvalidParameter, sampleItemsIterChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len + 1));
    var empty_ptrs_iter = try samplePtrsIter(u8, failing, std.testing.allocator, &sample_items, 0);
    defer empty_ptrs_iter.deinit();
    try std.testing.expectEqual(@as(usize, 0), empty_ptrs_iter.len());
    var empty_ptrs_iter_checked = try samplePtrsIterChecked(u8, failing, std.testing.allocator, &sample_items, 0);
    defer empty_ptrs_iter_checked.deinit();
    try std.testing.expectEqual(@as(usize, 0), empty_ptrs_iter_checked.len());
    var all_ptrs_iter = try samplePtrsIter(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer all_ptrs_iter.deinit();
    try std.testing.expectEqual(@as(usize, 3), all_ptrs_iter.len());
    var all_ptrs_iter_out: [3]*const u8 = undefined;
    try std.testing.expectEqual(@as(usize, 3), all_ptrs_iter.fill(&all_ptrs_iter_out));
    for (all_ptrs_iter_out, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    var all_ptrs_iter_checked = try samplePtrsIterChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer all_ptrs_iter_checked.deinit();
    try std.testing.expectEqual(@as(usize, 3), all_ptrs_iter_checked.len());
    var all_ptrs_iter_checked_out: [3]*const u8 = undefined;
    try std.testing.expectEqual(@as(usize, 3), all_ptrs_iter_checked.fill(&all_ptrs_iter_checked_out));
    for (all_ptrs_iter_checked_out, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    try std.testing.expectError(error.InvalidParameter, samplePtrsIterChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len + 1));
    var empty_mut_ptrs_iter = try sampleMutPtrsIter(u8, failing, std.testing.allocator, &mutable_sample_items, 0);
    defer empty_mut_ptrs_iter.deinit();
    try std.testing.expectEqual(@as(usize, 0), empty_mut_ptrs_iter.len());
    var empty_mut_ptrs_iter_checked = try sampleMutPtrsIterChecked(u8, failing, std.testing.allocator, &mutable_sample_items, 0);
    defer empty_mut_ptrs_iter_checked.deinit();
    try std.testing.expectEqual(@as(usize, 0), empty_mut_ptrs_iter_checked.len());
    var all_mut_ptrs_iter = try sampleMutPtrsIter(u8, failing, std.testing.allocator, &mutable_sample_items, mutable_sample_items.len);
    defer all_mut_ptrs_iter.deinit();
    try std.testing.expectEqual(@as(usize, 3), all_mut_ptrs_iter.len());
    var all_mut_ptrs_iter_out: [3]*u8 = undefined;
    try std.testing.expectEqual(@as(usize, 3), all_mut_ptrs_iter.fill(&all_mut_ptrs_iter_out));
    for (all_mut_ptrs_iter_out, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    var all_mut_ptrs_iter_checked = try sampleMutPtrsIterChecked(u8, failing, std.testing.allocator, &mutable_sample_items, mutable_sample_items.len);
    defer all_mut_ptrs_iter_checked.deinit();
    try std.testing.expectEqual(@as(usize, 3), all_mut_ptrs_iter_checked.len());
    var all_mut_ptrs_iter_checked_out: [3]*u8 = undefined;
    try std.testing.expectEqual(@as(usize, 3), all_mut_ptrs_iter_checked.fill(&all_mut_ptrs_iter_checked_out));
    for (all_mut_ptrs_iter_checked_out, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    try std.testing.expectError(error.InvalidParameter, sampleMutPtrsIterChecked(u8, failing, std.testing.allocator, &mutable_sample_items, mutable_sample_items.len + 1));
    const empty_reservoir = try reservoirSample(u8, failing, std.testing.allocator, &sample_items, 0);
    defer std.testing.allocator.free(empty_reservoir);
    try std.testing.expectEqual(@as(usize, 0), empty_reservoir.len);
    const empty_reservoir_checked = try reservoirSampleChecked(u8, failing, std.testing.allocator, &sample_items, 0);
    defer std.testing.allocator.free(empty_reservoir_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_reservoir_checked.len);
    const all_reservoir = try reservoirSample(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer std.testing.allocator.free(all_reservoir);
    try std.testing.expectEqualSlices(u8, &sample_items, all_reservoir);
    const all_reservoir_checked = try reservoirSampleChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer std.testing.allocator.free(all_reservoir_checked);
    try std.testing.expectEqualSlices(u8, &sample_items, all_reservoir_checked);
    try std.testing.expectError(error.InvalidParameter, reservoirSampleChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len + 1));
    var empty_reservoir_into: [0]u8 = .{};
    try reservoirSampleInto(u8, failing, &sample_items, &empty_reservoir_into);
    try reservoirSampleIntoChecked(u8, failing, &sample_items, &empty_reservoir_into);
    var all_reservoir_into: [3]u8 = undefined;
    try reservoirSampleInto(u8, failing, &sample_items, &all_reservoir_into);
    try std.testing.expectEqualSlices(u8, &sample_items, &all_reservoir_into);
    try reservoirSampleIntoChecked(u8, failing, &sample_items, &all_reservoir_into);
    try std.testing.expectEqualSlices(u8, &sample_items, &all_reservoir_into);
    var too_many_reservoir_into: [4]u8 = undefined;
    try std.testing.expectError(error.InvalidParameter, reservoirSampleIntoChecked(u8, failing, &sample_items, &too_many_reservoir_into));
    const empty_reservoir_ptrs = try reservoirSamplePtrs(u8, failing, std.testing.allocator, &sample_items, 0);
    defer std.testing.allocator.free(empty_reservoir_ptrs);
    try std.testing.expectEqual(@as(usize, 0), empty_reservoir_ptrs.len);
    const empty_reservoir_ptrs_checked = try reservoirSamplePtrsChecked(u8, failing, std.testing.allocator, &sample_items, 0);
    defer std.testing.allocator.free(empty_reservoir_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_reservoir_ptrs_checked.len);
    const all_reservoir_ptrs = try reservoirSamplePtrs(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer std.testing.allocator.free(all_reservoir_ptrs);
    for (all_reservoir_ptrs, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    const all_reservoir_ptrs_checked = try reservoirSamplePtrsChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len);
    defer std.testing.allocator.free(all_reservoir_ptrs_checked);
    for (all_reservoir_ptrs_checked, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    try std.testing.expectError(error.InvalidParameter, reservoirSamplePtrsChecked(u8, failing, std.testing.allocator, &sample_items, sample_items.len + 1));
    var empty_reservoir_ptrs_into: [0]*const u8 = .{};
    try reservoirSamplePtrsInto(u8, failing, &sample_items, &empty_reservoir_ptrs_into);
    try reservoirSamplePtrsIntoChecked(u8, failing, &sample_items, &empty_reservoir_ptrs_into);
    var all_reservoir_ptrs_into: [3]*const u8 = undefined;
    try reservoirSamplePtrsInto(u8, failing, &sample_items, &all_reservoir_ptrs_into);
    for (all_reservoir_ptrs_into, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    try reservoirSamplePtrsIntoChecked(u8, failing, &sample_items, &all_reservoir_ptrs_into);
    for (all_reservoir_ptrs_into, 0..) |value, index| try std.testing.expectEqual(&sample_items[index], value);
    var too_many_reservoir_ptrs_into: [4]*const u8 = undefined;
    try std.testing.expectError(error.InvalidParameter, reservoirSamplePtrsIntoChecked(u8, failing, &sample_items, &too_many_reservoir_ptrs_into));
    const empty_reservoir_mut_ptrs = try reservoirSampleMutPtrs(u8, failing, std.testing.allocator, &mutable_sample_items, 0);
    defer std.testing.allocator.free(empty_reservoir_mut_ptrs);
    try std.testing.expectEqual(@as(usize, 0), empty_reservoir_mut_ptrs.len);
    const empty_reservoir_mut_ptrs_checked = try reservoirSampleMutPtrsChecked(u8, failing, std.testing.allocator, &mutable_sample_items, 0);
    defer std.testing.allocator.free(empty_reservoir_mut_ptrs_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_reservoir_mut_ptrs_checked.len);
    const all_reservoir_mut_ptrs = try reservoirSampleMutPtrs(u8, failing, std.testing.allocator, &mutable_sample_items, mutable_sample_items.len);
    defer std.testing.allocator.free(all_reservoir_mut_ptrs);
    for (all_reservoir_mut_ptrs, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    const all_reservoir_mut_ptrs_checked = try reservoirSampleMutPtrsChecked(u8, failing, std.testing.allocator, &mutable_sample_items, mutable_sample_items.len);
    defer std.testing.allocator.free(all_reservoir_mut_ptrs_checked);
    for (all_reservoir_mut_ptrs_checked, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    try std.testing.expectError(error.InvalidParameter, reservoirSampleMutPtrsChecked(u8, failing, std.testing.allocator, &mutable_sample_items, mutable_sample_items.len + 1));
    var empty_reservoir_mut_ptrs_into: [0]*u8 = .{};
    try reservoirSampleMutPtrsInto(u8, failing, &mutable_sample_items, &empty_reservoir_mut_ptrs_into);
    try reservoirSampleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &empty_reservoir_mut_ptrs_into);
    var all_reservoir_mut_ptrs_into: [3]*u8 = undefined;
    try reservoirSampleMutPtrsInto(u8, failing, &mutable_sample_items, &all_reservoir_mut_ptrs_into);
    for (all_reservoir_mut_ptrs_into, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    try reservoirSampleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &all_reservoir_mut_ptrs_into);
    for (all_reservoir_mut_ptrs_into, 0..) |value, index| try std.testing.expectEqual(&mutable_sample_items[index], value);
    var too_many_reservoir_mut_ptrs_into: [4]*u8 = undefined;
    try std.testing.expectError(error.InvalidParameter, reservoirSampleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &too_many_reservoir_mut_ptrs_into));
    const empty_index_vec = try sampleIndexVec(failing, std.testing.allocator, 5, 0);
    defer empty_index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 0), empty_index_vec.len());
    const empty_index_vec_checked = try sampleIndexVecChecked(failing, std.testing.allocator, 5, 0);
    defer empty_index_vec_checked.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 0), empty_index_vec_checked.len());
    const all_index_vec = try sampleIndexVec(failing, std.testing.allocator, 3, 3);
    defer all_index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 3), all_index_vec.len());
    try std.testing.expectEqual(@as(usize, 0), all_index_vec.at(0));
    try std.testing.expectEqual(@as(usize, 1), all_index_vec.at(1));
    try std.testing.expectEqual(@as(usize, 2), all_index_vec.at(2));
    const all_index_vec_checked = try sampleIndexVecChecked(failing, std.testing.allocator, 3, 3);
    defer all_index_vec_checked.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 3), all_index_vec_checked.len());
    try std.testing.expectEqual(@as(usize, 0), all_index_vec_checked.at(0));
    try std.testing.expectEqual(@as(usize, 1), all_index_vec_checked.at(1));
    try std.testing.expectEqual(@as(usize, 2), all_index_vec_checked.at(2));
    try std.testing.expectError(error.InvalidParameter, sampleIndexVecChecked(failing, std.testing.allocator, 3, 4));
    try std.testing.expect((try sampleArray(failing, 0, 0)) != null);
    try std.testing.expectEqual(@as(usize, 0), (try sampleArrayChecked(failing, 0, 0)).len);
    try std.testing.expectEqualSlices(usize, &.{ 0, 1, 2 }, &(try sampleArray(failing, 3, 3)).?);
    try std.testing.expectEqualSlices(usize, &.{ 0, 1, 2 }, &(try sampleArrayChecked(failing, 3, 3)));
    try std.testing.expectEqual(@as(?[4]usize, null), try sampleArray(failing, 4, 3));
    try std.testing.expectError(error.InvalidParameter, sampleArrayChecked(failing, 4, 3));
    try std.testing.expect((try sampleArrayU32(failing, 0, 0)) != null);
    try std.testing.expectEqual(@as(usize, 0), (try sampleArrayU32Checked(failing, 0, 0)).len);
    try std.testing.expectEqualSlices(u32, &.{ 0, 1, 2 }, &(try sampleArrayU32(failing, 3, 3)).?);
    try std.testing.expectEqualSlices(u32, &.{ 0, 1, 2 }, &(try sampleArrayU32Checked(failing, 3, 3)));
    try std.testing.expectEqual(@as(?[4]u32, null), try sampleArrayU32(failing, 4, 3));
    try std.testing.expectError(error.InvalidParameter, sampleArrayU32Checked(failing, 4, 3));
    const empty_sample_indices = try sampleIndices(failing, std.testing.allocator, 5, 0);
    defer std.testing.allocator.free(empty_sample_indices);
    try std.testing.expectEqual(@as(usize, 0), empty_sample_indices.len);
    const empty_sample_indices_checked = try sampleIndicesChecked(failing, std.testing.allocator, 5, 0);
    defer std.testing.allocator.free(empty_sample_indices_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_sample_indices_checked.len);
    const all_sample_indices = try sampleIndices(failing, std.testing.allocator, 3, 3);
    defer std.testing.allocator.free(all_sample_indices);
    try std.testing.expectEqualSlices(usize, &.{ 0, 1, 2 }, all_sample_indices);
    const all_sample_indices_checked = try sampleIndicesChecked(failing, std.testing.allocator, 3, 3);
    defer std.testing.allocator.free(all_sample_indices_checked);
    try std.testing.expectEqualSlices(usize, &.{ 0, 1, 2 }, all_sample_indices_checked);
    var empty_indices_into: [0]usize = .{};
    try sampleIndicesInto(failing, 0, &empty_indices_into);
    try sampleIndicesIntoChecked(failing, 0, &empty_indices_into);
    var all_indices_into: [3]usize = undefined;
    try sampleIndicesInto(failing, 3, &all_indices_into);
    try std.testing.expectEqualSlices(usize, &.{ 0, 1, 2 }, &all_indices_into);
    try sampleIndicesIntoChecked(failing, 3, &all_indices_into);
    try std.testing.expectEqualSlices(usize, &.{ 0, 1, 2 }, &all_indices_into);
    try std.testing.expectError(error.InvalidParameter, sampleIndicesChecked(failing, std.testing.allocator, 3, 4));
    var too_many_indices: [4]usize = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleIndicesIntoChecked(failing, 3, &too_many_indices));
    const empty_sample_indices_u32 = try sampleIndicesU32(failing, std.testing.allocator, 5, 0);
    defer std.testing.allocator.free(empty_sample_indices_u32);
    try std.testing.expectEqual(@as(usize, 0), empty_sample_indices_u32.len);
    const empty_sample_indices_u32_checked = try sampleIndicesU32Checked(failing, std.testing.allocator, 5, 0);
    defer std.testing.allocator.free(empty_sample_indices_u32_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_sample_indices_u32_checked.len);
    const all_sample_indices_u32 = try sampleIndicesU32(failing, std.testing.allocator, 3, 3);
    defer std.testing.allocator.free(all_sample_indices_u32);
    try std.testing.expectEqualSlices(u32, &.{ 0, 1, 2 }, all_sample_indices_u32);
    const all_sample_indices_u32_checked = try sampleIndicesU32Checked(failing, std.testing.allocator, 3, 3);
    defer std.testing.allocator.free(all_sample_indices_u32_checked);
    try std.testing.expectEqualSlices(u32, &.{ 0, 1, 2 }, all_sample_indices_u32_checked);
    var empty_indices_u32_into: [0]u32 = .{};
    try sampleIndicesU32Into(failing, 0, &empty_indices_u32_into);
    try sampleIndicesU32IntoChecked(failing, 0, &empty_indices_u32_into);
    var all_indices_u32_into: [3]u32 = undefined;
    try sampleIndicesU32Into(failing, 3, &all_indices_u32_into);
    try std.testing.expectEqualSlices(u32, &.{ 0, 1, 2 }, &all_indices_u32_into);
    try sampleIndicesU32IntoChecked(failing, 3, &all_indices_u32_into);
    try std.testing.expectEqualSlices(u32, &.{ 0, 1, 2 }, &all_indices_u32_into);
    try std.testing.expectError(error.InvalidParameter, sampleIndicesU32Checked(failing, std.testing.allocator, 3, 4));
    const empty_weighted_nr = try sampleWeightedIndices(f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, 0);
    defer std.testing.allocator.free(empty_weighted_nr);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_nr.len);
    const empty_weighted_nr_checked = try sampleWeightedIndicesChecked(f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, 0);
    defer std.testing.allocator.free(empty_weighted_nr_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_nr_checked.len);
    const empty_weighted_nr_u32 = try sampleWeightedIndicesU32(f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, 0);
    defer std.testing.allocator.free(empty_weighted_nr_u32);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_nr_u32.len);
    const empty_weighted_index_vec = try sampleWeightedIndexVec(f64, failing, std.testing.allocator, &.{-1}, 0);
    defer empty_weighted_index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_index_vec.len());
    const empty_weighted_index_vec_checked = try sampleWeightedIndexVecChecked(f64, failing, std.testing.allocator, &.{-1}, 0);
    defer empty_weighted_index_vec_checked.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_index_vec_checked.len());
    const zero_weighted_index_vec = try sampleWeightedIndexVec(f64, failing, std.testing.allocator, &.{ 0, 0, 0 }, 2);
    defer zero_weighted_index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_index_vec.len());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexVecChecked(f64, failing, std.testing.allocator, &.{ 0, 0, 0 }, 2));
    const single_weighted_index_vec = try sampleWeightedIndexVec(f64, failing, std.testing.allocator, &.{ 0, 5, 0 }, 3);
    defer single_weighted_index_vec.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 1), single_weighted_index_vec.len());
    try std.testing.expectEqual(@as(usize, 1), single_weighted_index_vec.at(0));
    const single_weighted_index_vec_checked = try sampleWeightedIndexVecChecked(f64, failing, std.testing.allocator, &.{ 0, 5, 0 }, 1);
    defer single_weighted_index_vec_checked.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 1), single_weighted_index_vec_checked.len());
    try std.testing.expectEqual(@as(usize, 1), single_weighted_index_vec_checked.at(0));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexVecChecked(f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, 4));
    var empty_weighted_indices_into: [0]usize = .{};
    var empty_weighted_keys: [0]f64 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesInto(f64, failing, &.{-1}, &empty_weighted_indices_into, &empty_weighted_keys));
    try sampleWeightedIndicesIntoChecked(f64, failing, &.{-1}, &empty_weighted_indices_into, &empty_weighted_keys);
    var empty_weighted_indices_u32_into: [0]u32 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesU32Into(f64, failing, &.{-1}, &empty_weighted_indices_u32_into, &empty_weighted_keys));
    try sampleWeightedIndicesU32IntoChecked(f64, failing, &.{-1}, &empty_weighted_indices_u32_into, &empty_weighted_keys);
    var weighted_indices_into_bad_scratch: [2]usize = undefined;
    var weighted_indices_one_key: [1]f64 = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedIndicesInto(f64, failing, &.{ 1, 2, 3 }, &weighted_indices_into_bad_scratch, &weighted_indices_one_key));
    var weighted_indices_too_many: [4]usize = undefined;
    var weighted_indices_keys_four: [4]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesIntoChecked(f64, failing, &.{ 1, 2, 3 }, &weighted_indices_too_many, &weighted_indices_keys_four));
    var weighted_indices_zero: [2]usize = undefined;
    var weighted_indices_keys_two: [2]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesInto(f64, failing, &.{ 0, 0, 0 }, &weighted_indices_zero, &weighted_indices_keys_two));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesIntoChecked(f64, failing, &.{ 0, 0, 0 }, &weighted_indices_zero, &weighted_indices_keys_two));
    var weighted_indices_single: [1]usize = undefined;
    var weighted_indices_single_key: [1]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedIndicesInto(f64, failing, &.{ 0, 5, 0 }, &weighted_indices_single, &weighted_indices_single_key));
    try std.testing.expectEqual(@as(usize, 1), weighted_indices_single[0]);
    try sampleWeightedIndicesIntoChecked(f64, failing, &.{ 0, 5, 0 }, &weighted_indices_single, &weighted_indices_single_key);
    try std.testing.expectEqual(@as(usize, 1), weighted_indices_single[0]);
    try std.testing.expect((try sampleWeightedIndexArray(f64, failing, 0, &.{-1})) != null);
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedIndexArrayChecked(f64, failing, 0, &.{-1})).len);
    try std.testing.expectEqual(@as(?[2]usize, null), try sampleWeightedIndexArray(f64, failing, 2, &.{ 0, 0, 0 }));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayChecked(f64, failing, 2, &.{ 0, 0, 0 }));
    try std.testing.expectEqualSlices(usize, &.{1}, &(try sampleWeightedIndexArray(f64, failing, 1, &.{ 0, 5, 0 })).?);
    try std.testing.expectEqualSlices(usize, &.{1}, &(try sampleWeightedIndexArrayChecked(f64, failing, 1, &.{ 0, 5, 0 })));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayChecked(f64, failing, 4, &.{ 1, 2, 3 }));
    var weighted_indices_u32_bad_scratch: [2]u32 = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedIndicesU32Into(f64, failing, &.{ 1, 2, 3 }, &weighted_indices_u32_bad_scratch, &weighted_indices_one_key));
    var weighted_indices_u32_too_many: [4]u32 = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32IntoChecked(f64, failing, &.{ 1, 2, 3 }, &weighted_indices_u32_too_many, &weighted_indices_keys_four));
    var weighted_indices_u32_zero: [2]u32 = undefined;
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesU32Into(f64, failing, &.{ 0, 0, 0 }, &weighted_indices_u32_zero, &weighted_indices_keys_two));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32IntoChecked(f64, failing, &.{ 0, 0, 0 }, &weighted_indices_u32_zero, &weighted_indices_keys_two));
    var weighted_indices_u32_single: [1]u32 = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedIndicesU32Into(f64, failing, &.{ 0, 5, 0 }, &weighted_indices_u32_single, &weighted_indices_single_key));
    try std.testing.expectEqual(@as(u32, 1), weighted_indices_u32_single[0]);
    try sampleWeightedIndicesU32IntoChecked(f64, failing, &.{ 0, 5, 0 }, &weighted_indices_u32_single, &weighted_indices_single_key);
    try std.testing.expectEqual(@as(u32, 1), weighted_indices_u32_single[0]);
    try std.testing.expect((try sampleWeightedIndexArrayU32(f64, failing, 0, &.{-1})) != null);
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedIndexArrayU32Checked(f64, failing, 0, &.{-1})).len);
    try std.testing.expectEqual(@as(?[2]u32, null), try sampleWeightedIndexArrayU32(f64, failing, 2, &.{ 0, 0, 0 }));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32Checked(f64, failing, 2, &.{ 0, 0, 0 }));
    try std.testing.expectEqualSlices(u32, &.{1}, &(try sampleWeightedIndexArrayU32(f64, failing, 1, &.{ 0, 5, 0 })).?);
    try std.testing.expectEqualSlices(u32, &.{1}, &(try sampleWeightedIndexArrayU32Checked(f64, failing, 1, &.{ 0, 5, 0 })));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32Checked(f64, failing, 4, &.{ 1, 2, 3 }));
    var empty_weighted_values_into: [0]u8 = .{};
    var empty_weighted_value_indices: [0]usize = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedInto(u8, f64, failing, &.{1}, &.{-1}, &empty_weighted_values_into, &empty_weighted_value_indices, &empty_weighted_keys));
    try sampleWeightedIntoChecked(u8, f64, failing, &.{1}, &.{-1}, &empty_weighted_values_into, &empty_weighted_value_indices, &empty_weighted_keys);
    var weighted_values_bad_scratch: [2]u8 = undefined;
    var weighted_values_one_index: [1]usize = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedInto(u8, f64, failing, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }, &weighted_values_bad_scratch, &weighted_values_one_index, &weighted_indices_one_key));
    var weighted_values_too_many: [4]u8 = undefined;
    var weighted_values_indices_four: [4]usize = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIntoChecked(u8, f64, failing, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }, &weighted_values_too_many, &weighted_values_indices_four, &weighted_indices_keys_four));
    var weighted_values_zero: [2]u8 = undefined;
    var weighted_values_indices_two: [2]usize = undefined;
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedInto(u8, f64, failing, &.{ 1, 2, 3 }, &.{ 0, 0, 0 }, &weighted_values_zero, &weighted_values_indices_two, &weighted_indices_keys_two));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIntoChecked(u8, f64, failing, &.{ 1, 2, 3 }, &.{ 0, 0, 0 }, &weighted_values_zero, &weighted_values_indices_two, &weighted_indices_keys_two));
    var weighted_values_single: [1]u8 = undefined;
    var weighted_values_single_index: [1]usize = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedInto(u8, f64, failing, &.{ 10, 20, 30 }, &.{ 0, 5, 0 }, &weighted_values_single, &weighted_values_single_index, &weighted_indices_single_key));
    try std.testing.expectEqual(@as(u8, 20), weighted_values_single[0]);
    try sampleWeightedIntoChecked(u8, f64, failing, &.{ 10, 20, 30 }, &.{ 0, 5, 0 }, &weighted_values_single, &weighted_values_single_index, &weighted_indices_single_key);
    try std.testing.expectEqual(@as(u8, 20), weighted_values_single[0]);
    var empty_weighted_ptrs_into: [0]*const u8 = .{};
    var empty_weighted_ptr_indices: [0]usize = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedPtrsInto(u8, f64, failing, &.{1}, &.{-1}, &empty_weighted_ptrs_into, &empty_weighted_ptr_indices, &empty_weighted_keys));
    try sampleWeightedPtrsIntoChecked(u8, f64, failing, &.{1}, &.{-1}, &empty_weighted_ptrs_into, &empty_weighted_ptr_indices, &empty_weighted_keys);
    var weighted_ptrs_bad_scratch: [2]*const u8 = undefined;
    var weighted_ptrs_one_index: [1]usize = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedPtrsInto(u8, f64, failing, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }, &weighted_ptrs_bad_scratch, &weighted_ptrs_one_index, &weighted_indices_one_key));
    var weighted_ptrs_too_many: [4]*const u8 = undefined;
    var weighted_ptr_indices_four: [4]usize = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrsIntoChecked(u8, f64, failing, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }, &weighted_ptrs_too_many, &weighted_ptr_indices_four, &weighted_indices_keys_four));
    var weighted_ptrs_zero: [2]*const u8 = undefined;
    var weighted_ptrs_indices_two: [2]usize = undefined;
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedPtrsInto(u8, f64, failing, &.{ 1, 2, 3 }, &.{ 0, 0, 0 }, &weighted_ptrs_zero, &weighted_ptrs_indices_two, &weighted_indices_keys_two));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrsIntoChecked(u8, f64, failing, &.{ 1, 2, 3 }, &.{ 0, 0, 0 }, &weighted_ptrs_zero, &weighted_ptrs_indices_two, &weighted_indices_keys_two));
    const weighted_ptr_single_items = [_]u8{ 10, 20, 30 };
    var weighted_ptrs_single: [1]*const u8 = undefined;
    var weighted_ptrs_single_index: [1]usize = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedPtrsInto(u8, f64, failing, &weighted_ptr_single_items, &.{ 0, 5, 0 }, &weighted_ptrs_single, &weighted_ptrs_single_index, &weighted_indices_single_key));
    try std.testing.expectEqual(&weighted_ptr_single_items[1], weighted_ptrs_single[0]);
    try sampleWeightedPtrsIntoChecked(u8, f64, failing, &weighted_ptr_single_items, &.{ 0, 5, 0 }, &weighted_ptrs_single, &weighted_ptrs_single_index, &weighted_indices_single_key);
    try std.testing.expectEqual(&weighted_ptr_single_items[1], weighted_ptrs_single[0]);
    var empty_weighted_mut_ptr_items = [_]u8{1};
    var empty_weighted_mut_ptrs_into: [0]*u8 = .{};
    var empty_weighted_mut_ptr_indices: [0]usize = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedMutPtrsInto(u8, f64, failing, &empty_weighted_mut_ptr_items, &.{-1}, &empty_weighted_mut_ptrs_into, &empty_weighted_mut_ptr_indices, &empty_weighted_keys));
    try sampleWeightedMutPtrsIntoChecked(u8, f64, failing, &empty_weighted_mut_ptr_items, &.{-1}, &empty_weighted_mut_ptrs_into, &empty_weighted_mut_ptr_indices, &empty_weighted_keys);
    var weighted_mut_ptr_items = [_]u8{ 1, 2, 3 };
    var weighted_mut_ptrs_bad_scratch: [2]*u8 = undefined;
    var weighted_mut_ptrs_one_index: [1]usize = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedMutPtrsInto(u8, f64, failing, &weighted_mut_ptr_items, &.{ 1, 2, 3 }, &weighted_mut_ptrs_bad_scratch, &weighted_mut_ptrs_one_index, &weighted_indices_one_key));
    var weighted_mut_ptrs_too_many: [4]*u8 = undefined;
    var weighted_mut_ptr_indices_four: [4]usize = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrsIntoChecked(u8, f64, failing, &weighted_mut_ptr_items, &.{ 1, 2, 3 }, &weighted_mut_ptrs_too_many, &weighted_mut_ptr_indices_four, &weighted_indices_keys_four));
    var weighted_mut_ptrs_zero: [2]*u8 = undefined;
    var weighted_mut_ptrs_indices_two: [2]usize = undefined;
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedMutPtrsInto(u8, f64, failing, &weighted_mut_ptr_items, &.{ 0, 0, 0 }, &weighted_mut_ptrs_zero, &weighted_mut_ptrs_indices_two, &weighted_indices_keys_two));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrsIntoChecked(u8, f64, failing, &weighted_mut_ptr_items, &.{ 0, 0, 0 }, &weighted_mut_ptrs_zero, &weighted_mut_ptrs_indices_two, &weighted_indices_keys_two));
    var weighted_mut_ptr_single_items = [_]u8{ 10, 20, 30 };
    var weighted_mut_ptrs_single: [1]*u8 = undefined;
    var weighted_mut_ptrs_single_index: [1]usize = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedMutPtrsInto(u8, f64, failing, &weighted_mut_ptr_single_items, &.{ 0, 5, 0 }, &weighted_mut_ptrs_single, &weighted_mut_ptrs_single_index, &weighted_indices_single_key));
    try std.testing.expectEqual(&weighted_mut_ptr_single_items[1], weighted_mut_ptrs_single[0]);
    try sampleWeightedMutPtrsIntoChecked(u8, f64, failing, &weighted_mut_ptr_single_items, &.{ 0, 5, 0 }, &weighted_mut_ptrs_single, &weighted_mut_ptrs_single_index, &weighted_indices_single_key);
    try std.testing.expectEqual(&weighted_mut_ptr_single_items[1], weighted_mut_ptrs_single[0]);
    const empty_weighted_values_nr = try sampleWeighted(u8, f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }, 0);
    defer std.testing.allocator.free(empty_weighted_values_nr);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_values_nr.len);
    const zero_weighted_values_nr = try sampleWeighted(u8, f64, failing, std.testing.allocator, &.{ 10, 20, 30 }, &.{ 0, 0, 0 }, 2);
    defer std.testing.allocator.free(zero_weighted_values_nr);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_values_nr.len);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedChecked(u8, f64, failing, std.testing.allocator, &.{ 10, 20, 30 }, &.{ 0, 0, 0 }, 2));
    const single_weighted_values_nr = try sampleWeighted(u8, f64, failing, std.testing.allocator, &.{ 10, 20, 30 }, &.{ 0, 5, 0 }, 2);
    defer std.testing.allocator.free(single_weighted_values_nr);
    try std.testing.expectEqualSlices(u8, &.{20}, single_weighted_values_nr);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedChecked(u8, f64, failing, std.testing.allocator, &.{ 10, 20, 30 }, &.{ 0, 5, 0 }, 2));
    const single_weighted_values_checked_nr = try sampleWeightedChecked(u8, f64, failing, std.testing.allocator, &.{ 10, 20, 30 }, &.{ 0, 5, 0 }, 1);
    defer std.testing.allocator.free(single_weighted_values_checked_nr);
    try std.testing.expectEqualSlices(u8, &.{20}, single_weighted_values_checked_nr);
    try std.testing.expectError(error.InvalidWeight, sampleWeighted(u8, f64, failing, std.testing.allocator, &.{ 10, 20, 30 }, &.{ std.math.nan(f64), 1, 1 }, 2));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedChecked(u8, f64, failing, std.testing.allocator, &.{ 10, 20, 30 }, &.{ std.math.nan(f64), 1, 1 }, 2));
    try std.testing.expectError(error.LengthMismatch, sampleWeighted(u8, f64, failing, std.testing.allocator, &.{ 10, 20, 30 }, &.{ 1, 2 }, 2));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedChecked(u8, f64, failing, std.testing.allocator, &.{ 10, 20, 30 }, &.{ 1, 2 }, 2));
    try std.testing.expect((try sampleWeightedArray(u8, f64, failing, 0, &.{ 1, 2, 3 }, &.{ 1, 2, 3 })) != null);
    try std.testing.expectError(error.LengthMismatch, sampleWeightedArray(u8, f64, failing, 2, &.{ 1, 2, 3 }, &.{ 1, 2 }));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedArrayChecked(u8, f64, failing, 2, &.{ 1, 2, 3 }, &.{ 1, 2 }));
    try std.testing.expectEqual(@as(?[2]u8, null), try sampleWeightedArray(u8, f64, failing, 2, &.{ 10, 20, 30 }, &.{ 0, 0, 0 }));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedArrayChecked(u8, f64, failing, 2, &.{ 10, 20, 30 }, &.{ 0, 0, 0 }));
    try std.testing.expectEqualSlices(u8, &.{20}, &(try sampleWeightedArray(u8, f64, failing, 1, &.{ 10, 20, 30 }, &.{ 0, 5, 0 })).?);
    try std.testing.expectEqualSlices(u8, &.{20}, &(try sampleWeightedArrayChecked(u8, f64, failing, 1, &.{ 10, 20, 30 }, &.{ 0, 5, 0 })));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedArrayChecked(u8, f64, failing, 2, &.{ 10, 20, 30 }, &.{ 0, 5, 0 }));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedArray(u8, f64, failing, 2, &.{ 10, 20, 30 }, &.{ std.math.nan(f64), 1, 1 }));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedArrayChecked(u8, f64, failing, 2, &.{ 10, 20, 30 }, &.{ std.math.nan(f64), 1, 1 }));
    const empty_weighted_ptrs_nr = try sampleWeightedPtrs(u8, f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }, 0);
    defer std.testing.allocator.free(empty_weighted_ptrs_nr);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_ptrs_nr.len);
    try std.testing.expectError(error.LengthMismatch, sampleWeightedPtrs(u8, f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, &.{ 1, 2 }, 2));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedPtrsChecked(u8, f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, &.{ 1, 2 }, 2));
    const weighted_ptr_nr_items = [_]u8{ 10, 20, 30 };
    const zero_weighted_ptrs_nr = try sampleWeightedPtrs(u8, f64, failing, std.testing.allocator, &weighted_ptr_nr_items, &.{ 0, 0, 0 }, 2);
    defer std.testing.allocator.free(zero_weighted_ptrs_nr);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_ptrs_nr.len);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrsChecked(u8, f64, failing, std.testing.allocator, &weighted_ptr_nr_items, &.{ 0, 0, 0 }, 2));
    const single_weighted_ptrs_nr = try sampleWeightedPtrs(u8, f64, failing, std.testing.allocator, &weighted_ptr_nr_items, &.{ 0, 5, 0 }, 2);
    defer std.testing.allocator.free(single_weighted_ptrs_nr);
    try std.testing.expectEqual(@as(usize, 1), single_weighted_ptrs_nr.len);
    try std.testing.expectEqual(&weighted_ptr_nr_items[1], single_weighted_ptrs_nr[0]);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrsChecked(u8, f64, failing, std.testing.allocator, &weighted_ptr_nr_items, &.{ 0, 5, 0 }, 2));
    const single_weighted_ptrs_checked_nr = try sampleWeightedPtrsChecked(u8, f64, failing, std.testing.allocator, &weighted_ptr_nr_items, &.{ 0, 5, 0 }, 1);
    defer std.testing.allocator.free(single_weighted_ptrs_checked_nr);
    try std.testing.expectEqual(&weighted_ptr_nr_items[1], single_weighted_ptrs_checked_nr[0]);
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrs(u8, f64, failing, std.testing.allocator, &weighted_ptr_nr_items, &.{ std.math.nan(f64), 1, 1 }, 2));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrsChecked(u8, f64, failing, std.testing.allocator, &weighted_ptr_nr_items, &.{ std.math.nan(f64), 1, 1 }, 2));
    try std.testing.expect((try sampleWeightedPtrArray(u8, f64, failing, 0, &.{ 1, 2, 3 }, &.{ 1, 2, 3 })) != null);
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedPtrArrayChecked(u8, f64, failing, 0, &.{ 1, 2, 3 }, &.{ 1, 2, 3 })).len);
    try std.testing.expectError(error.LengthMismatch, sampleWeightedPtrArray(u8, f64, failing, 2, &.{ 1, 2, 3 }, &.{ 1, 2 }));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedPtrArrayChecked(u8, f64, failing, 2, &.{ 1, 2, 3 }, &.{ 1, 2 }));
    try std.testing.expectEqual(@as(?[2]*const u8, null), try sampleWeightedPtrArray(u8, f64, failing, 2, &weighted_ptr_nr_items, &.{ 0, 0, 0 }));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrArrayChecked(u8, f64, failing, 2, &weighted_ptr_nr_items, &.{ 0, 0, 0 }));
    const single_weighted_ptr_array_nr = (try sampleWeightedPtrArray(u8, f64, failing, 1, &weighted_ptr_nr_items, &.{ 0, 5, 0 })).?;
    try std.testing.expectEqual(&weighted_ptr_nr_items[1], single_weighted_ptr_array_nr[0]);
    const single_weighted_ptr_array_checked_nr = try sampleWeightedPtrArrayChecked(u8, f64, failing, 1, &weighted_ptr_nr_items, &.{ 0, 5, 0 });
    try std.testing.expectEqual(&weighted_ptr_nr_items[1], single_weighted_ptr_array_checked_nr[0]);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrArrayChecked(u8, f64, failing, 2, &weighted_ptr_nr_items, &.{ 0, 5, 0 }));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrArray(u8, f64, failing, 2, &weighted_ptr_nr_items, &.{ std.math.nan(f64), 1, 1 }));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrArrayChecked(u8, f64, failing, 2, &weighted_ptr_nr_items, &.{ std.math.nan(f64), 1, 1 }));
    var weighted_mut_nr_items = [_]u8{ 1, 2, 3 };
    const empty_weighted_mut_ptrs_nr = try sampleWeightedMutPtrs(u8, f64, failing, std.testing.allocator, &weighted_mut_nr_items, &.{ 1, 2, 3 }, 0);
    defer std.testing.allocator.free(empty_weighted_mut_ptrs_nr);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_mut_ptrs_nr.len);
    const empty_weighted_mut_ptrs_nr_checked = try sampleWeightedMutPtrsChecked(u8, f64, failing, std.testing.allocator, &weighted_mut_nr_items, &.{ 1, 2, 3 }, 0);
    defer std.testing.allocator.free(empty_weighted_mut_ptrs_nr_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_mut_ptrs_nr_checked.len);
    var weighted_mut_ptr_nr_items_extra = [_]u8{ 10, 20, 30 };
    try std.testing.expectError(error.LengthMismatch, sampleWeightedMutPtrs(u8, f64, failing, std.testing.allocator, &weighted_mut_ptr_nr_items_extra, &.{ 1, 2 }, 2));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedMutPtrsChecked(u8, f64, failing, std.testing.allocator, &weighted_mut_ptr_nr_items_extra, &.{ 1, 2 }, 2));
    const zero_weighted_mut_ptrs_nr = try sampleWeightedMutPtrs(u8, f64, failing, std.testing.allocator, &weighted_mut_ptr_nr_items_extra, &.{ 0, 0, 0 }, 2);
    defer std.testing.allocator.free(zero_weighted_mut_ptrs_nr);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_mut_ptrs_nr.len);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrsChecked(u8, f64, failing, std.testing.allocator, &weighted_mut_ptr_nr_items_extra, &.{ 0, 0, 0 }, 2));
    const single_weighted_mut_ptrs_nr = try sampleWeightedMutPtrs(u8, f64, failing, std.testing.allocator, &weighted_mut_ptr_nr_items_extra, &.{ 0, 5, 0 }, 2);
    defer std.testing.allocator.free(single_weighted_mut_ptrs_nr);
    try std.testing.expectEqual(@as(usize, 1), single_weighted_mut_ptrs_nr.len);
    try std.testing.expectEqual(&weighted_mut_ptr_nr_items_extra[1], single_weighted_mut_ptrs_nr[0]);
    single_weighted_mut_ptrs_nr[0].* = 47;
    try std.testing.expectEqual(@as(u8, 47), weighted_mut_ptr_nr_items_extra[1]);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrsChecked(u8, f64, failing, std.testing.allocator, &weighted_mut_ptr_nr_items_extra, &.{ 0, 5, 0 }, 2));
    var weighted_mut_ptr_nr_items_checked_extra = [_]u8{ 10, 20, 30 };
    const single_weighted_mut_ptrs_checked_nr = try sampleWeightedMutPtrsChecked(u8, f64, failing, std.testing.allocator, &weighted_mut_ptr_nr_items_checked_extra, &.{ 0, 5, 0 }, 1);
    defer std.testing.allocator.free(single_weighted_mut_ptrs_checked_nr);
    try std.testing.expectEqual(&weighted_mut_ptr_nr_items_checked_extra[1], single_weighted_mut_ptrs_checked_nr[0]);
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrs(u8, f64, failing, std.testing.allocator, &weighted_mut_ptr_nr_items_extra, &.{ std.math.nan(f64), 1, 1 }, 2));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrsChecked(u8, f64, failing, std.testing.allocator, &weighted_mut_ptr_nr_items_extra, &.{ std.math.nan(f64), 1, 1 }, 2));
    try std.testing.expect((try sampleWeightedMutPtrArray(u8, f64, failing, 0, &weighted_mut_nr_items, &.{ 1, 2, 3 })) != null);
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedMutPtrArrayChecked(u8, f64, failing, 0, &weighted_mut_nr_items, &.{ 1, 2, 3 })).len);
    try std.testing.expectError(error.LengthMismatch, sampleWeightedMutPtrArray(u8, f64, failing, 2, &weighted_mut_ptr_nr_items_extra, &.{ 1, 2 }));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedMutPtrArrayChecked(u8, f64, failing, 2, &weighted_mut_ptr_nr_items_extra, &.{ 1, 2 }));
    try std.testing.expectEqual(@as(?[2]*u8, null), try sampleWeightedMutPtrArray(u8, f64, failing, 2, &weighted_mut_ptr_nr_items_extra, &.{ 0, 0, 0 }));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrArrayChecked(u8, f64, failing, 2, &weighted_mut_ptr_nr_items_extra, &.{ 0, 0, 0 }));
    var weighted_mut_ptr_array_items_extra = [_]u8{ 10, 20, 30 };
    const single_weighted_mut_ptr_array_nr = (try sampleWeightedMutPtrArray(u8, f64, failing, 1, &weighted_mut_ptr_array_items_extra, &.{ 0, 5, 0 })).?;
    try std.testing.expectEqual(&weighted_mut_ptr_array_items_extra[1], single_weighted_mut_ptr_array_nr[0]);
    single_weighted_mut_ptr_array_nr[0].* = 49;
    try std.testing.expectEqual(@as(u8, 49), weighted_mut_ptr_array_items_extra[1]);
    var weighted_mut_ptr_array_checked_items_extra = [_]u8{ 10, 20, 30 };
    const single_weighted_mut_ptr_array_checked_nr = try sampleWeightedMutPtrArrayChecked(u8, f64, failing, 1, &weighted_mut_ptr_array_checked_items_extra, &.{ 0, 5, 0 });
    try std.testing.expectEqual(&weighted_mut_ptr_array_checked_items_extra[1], single_weighted_mut_ptr_array_checked_nr[0]);
    single_weighted_mut_ptr_array_checked_nr[0].* = 51;
    try std.testing.expectEqual(@as(u8, 51), weighted_mut_ptr_array_checked_items_extra[1]);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrArrayChecked(u8, f64, failing, 2, &weighted_mut_ptr_array_checked_items_extra, &.{ 0, 5, 0 }));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrArray(u8, f64, failing, 2, &weighted_mut_ptr_array_checked_items_extra, &.{ std.math.nan(f64), 1, 1 }));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrArrayChecked(u8, f64, failing, 2, &weighted_mut_ptr_array_checked_items_extra, &.{ std.math.nan(f64), 1, 1 }));
    const SliceIter = struct {
        items: []const u8,
        index: usize = 0,

        fn next(self: *@This()) ?u8 {
            if (self.index >= self.items.len) return null;
            const value = self.items[self.index];
            self.index += 1;
            return value;
        }

        fn remaining(self: @This()) usize {
            return self.items.len - self.index;
        }
    };
    var empty_iter = SliceIter{ .items = &.{} };
    try std.testing.expectEqual(@as(?u8, null), try chooseIterator(u8, failing, &empty_iter));
    var empty_iter_checked = SliceIter{ .items = &.{} };
    try std.testing.expectError(error.EmptyInput, chooseIteratorChecked(u8, failing, &empty_iter_checked));
    var singleton_iter = SliceIter{ .items = &.{42} };
    try std.testing.expectEqual(@as(?u8, 42), try chooseIterator(u8, failing, &singleton_iter));
    var singleton_iter_checked = SliceIter{ .items = &.{42} };
    try std.testing.expectEqual(@as(u8, 42), try chooseIteratorChecked(u8, failing, &singleton_iter_checked));
    var hinted_singleton = SliceIter{ .items = &.{77} };
    try std.testing.expectEqual(@as(?u8, 77), try chooseIteratorHinted(u8, failing, &hinted_singleton));
    var stable_singleton = SliceIter{ .items = &.{88} };
    try std.testing.expectEqual(@as(?u8, 88), try chooseIteratorStable(u8, failing, &stable_singleton));
    const empty_weights = [_]f64{ 0, 0, 0 };
    try std.testing.expectEqual(@as(?usize, null), try weightedIndex(failing, &empty_weights));
    try std.testing.expectEqual(@as(?usize, null), try weightedIndexChecked(failing, &empty_weights));
    var empty_weighted_fill: [3]?usize = undefined;
    try fillWeightedIndex(failing, &empty_weighted_fill, &empty_weights);
    try std.testing.expectEqualSlices(?usize, &.{ null, null, null }, &empty_weighted_fill);
    const empty_weighted_batch = try weightedIndexBatch(failing, std.testing.allocator, 3, &empty_weights);
    defer std.testing.allocator.free(empty_weighted_batch);
    try std.testing.expectEqualSlices(?usize, &.{ null, null, null }, empty_weighted_batch);
    try std.testing.expect((try weightedIndexArray(failing, 0, &empty_weights)) != null);
    try std.testing.expectEqual(@as(?[3]usize, null), try weightedIndexArray(failing, 3, &empty_weights));
    var empty_weighted_checked_fill: [0]usize = .{};
    try fillWeightedIndexChecked(failing, &empty_weighted_checked_fill, &empty_weights);
    try std.testing.expectEqual(@as(usize, 0), (try weightedIndexArrayChecked(failing, 0, &empty_weights)).len);
    try std.testing.expectError(error.EmptyRange, weightedIndexArrayChecked(failing, 3, &empty_weights));
    const empty_weighted_checked_batch = try weightedIndexBatchChecked(failing, std.testing.allocator, 0, &empty_weights);
    defer std.testing.allocator.free(empty_weighted_checked_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_checked_batch.len);
    try std.testing.expectError(error.EmptyRange, weightedIndexBatchChecked(failing, std.testing.allocator, 3, &empty_weights));
    var weighted_invalid_fill: [1]?usize = undefined;
    try std.testing.expectError(error.InvalidWeight, weightedIndex(failing, &.{ std.math.nan(f64), 1 }));
    try std.testing.expectError(error.InvalidWeight, fillWeightedIndex(failing, &weighted_invalid_fill, &.{ -1, 2 }));
    var weighted_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexBatch(failing, weighted_invalid_alloc.allocator(), 3, &.{ std.math.nan(f64), 1 }));
    var weighted_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexBatchChecked(failing, weighted_checked_invalid_alloc.allocator(), 3, &.{ std.math.nan(f64), 1 }));
    const empty_weighted_invalid_batch = try weightedIndexBatch(failing, std.testing.allocator, 0, &.{ std.math.nan(f64), 1 });
    defer std.testing.allocator.free(empty_weighted_invalid_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_invalid_batch.len);
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
    try std.testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, &(try weightedIndexArray(failing, 3, &single_weight)).?);
    try std.testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, &(try weightedIndexArrayChecked(failing, 3, &single_weight)));
    const RootByIndexWeights = struct {
        fn zero(index: usize) f64 {
            _ = index;
            return 0;
        }
        fn single(index: usize) f64 {
            return if (index == 1) 5 else 0;
        }
        fn invalid(index: usize) f64 {
            return if (index == 0) std.math.nan(f64) else 1;
        }
        fn weight(index: usize) f64 {
            return @floatFromInt(index + 1);
        }
    };
    try std.testing.expectEqual(@as(?usize, null), try weightedIndexByIndex(f64, failing, 0, RootByIndexWeights.single));
    try std.testing.expectEqual(@as(?usize, null), try weightedIndexByIndex(f64, failing, 3, RootByIndexWeights.zero));
    try std.testing.expectError(error.EmptyInput, weightedIndexByIndexChecked(f64, failing, 3, RootByIndexWeights.zero));
    try std.testing.expectEqual(@as(?usize, 1), try weightedIndexByIndex(f64, failing, 3, RootByIndexWeights.single));
    try std.testing.expectEqual(@as(usize, 1), try weightedIndexByIndexChecked(f64, failing, 3, RootByIndexWeights.single));
    try std.testing.expectError(error.InvalidWeight, weightedIndexByIndex(f64, failing, 3, RootByIndexWeights.invalid));
    try std.testing.expectEqual(@as(?u32, null), try weightedIndexU32ByIndex(f64, failing, 3, RootByIndexWeights.zero));
    try std.testing.expectError(error.EmptyInput, weightedIndexU32ByIndexChecked(f64, failing, 3, RootByIndexWeights.zero));
    try std.testing.expectEqual(@as(?u32, 1), try weightedIndexU32ByIndex(f64, failing, 3, RootByIndexWeights.single));
    try std.testing.expectEqual(@as(u32, 1), try weightedIndexU32ByIndexChecked(f64, failing, 3, RootByIndexWeights.single));
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32ByIndexChecked(f64, failing, 3, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidParameter, weightedIndexU32ByIndex(f64, failing, @as(usize, std.math.maxInt(u32)) + 1, RootByIndexWeights.single));
    const empty_weighted_indices_by_index = try sampleWeightedIndicesByIndex(f64, failing, std.testing.allocator, 3, 0, RootByIndexWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_indices_by_index);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_indices_by_index.len);
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesByIndex(f64, failing, std.testing.allocator, 0, 1, RootByIndexWeights.single));
    const zero_weighted_indices_by_index = try sampleWeightedIndicesByIndex(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.zero);
    defer std.testing.allocator.free(zero_weighted_indices_by_index);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_indices_by_index.len);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByIndexChecked(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.zero));
    const single_weighted_indices_by_index = try sampleWeightedIndicesByIndex(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.single);
    defer std.testing.allocator.free(single_weighted_indices_by_index);
    try std.testing.expectEqualSlices(usize, &.{1}, single_weighted_indices_by_index);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByIndexChecked(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.single));
    const single_weighted_indices_by_index_checked = try sampleWeightedIndicesByIndexChecked(f64, failing, std.testing.allocator, 3, 1, RootByIndexWeights.single);
    defer std.testing.allocator.free(single_weighted_indices_by_index_checked);
    try std.testing.expectEqualSlices(usize, &.{1}, single_weighted_indices_by_index_checked);
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesByIndex(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesByIndexChecked(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.invalid));
    const empty_weighted_indices_u32_by_index = try sampleWeightedIndicesU32ByIndex(f64, failing, std.testing.allocator, 3, 0, RootByIndexWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_indices_u32_by_index);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_indices_u32_by_index.len);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByIndex(f64, failing, std.testing.allocator, @as(usize, std.math.maxInt(u32)) + 1, 1, RootByIndexWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByIndexChecked(f64, failing, std.testing.allocator, @as(usize, std.math.maxInt(u32)) + 1, 1, RootByIndexWeights.single));
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesU32ByIndex(f64, failing, std.testing.allocator, 0, 1, RootByIndexWeights.single));
    const zero_weighted_indices_u32_by_index = try sampleWeightedIndicesU32ByIndex(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.zero);
    defer std.testing.allocator.free(zero_weighted_indices_u32_by_index);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_indices_u32_by_index.len);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByIndexChecked(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.zero));
    const single_weighted_indices_u32_by_index = try sampleWeightedIndicesU32ByIndex(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.single);
    defer std.testing.allocator.free(single_weighted_indices_u32_by_index);
    try std.testing.expectEqualSlices(u32, &.{1}, single_weighted_indices_u32_by_index);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByIndexChecked(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.single));
    const single_weighted_indices_u32_by_index_checked = try sampleWeightedIndicesU32ByIndexChecked(f64, failing, std.testing.allocator, 3, 1, RootByIndexWeights.single);
    defer std.testing.allocator.free(single_weighted_indices_u32_by_index_checked);
    try std.testing.expectEqualSlices(u32, &.{1}, single_weighted_indices_u32_by_index_checked);
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesU32ByIndex(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesU32ByIndexChecked(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.invalid));
    const empty_weighted_index_vec_by_index = try sampleWeightedIndexVecByIndex(f64, failing, std.testing.allocator, 3, 0, RootByIndexWeights.invalid);
    defer empty_weighted_index_vec_by_index.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_index_vec_by_index.len());
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndexVecByIndex(f64, failing, std.testing.allocator, 0, 1, RootByIndexWeights.single));
    const zero_weighted_index_vec_by_index = try sampleWeightedIndexVecByIndex(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.zero);
    defer zero_weighted_index_vec_by_index.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_index_vec_by_index.len());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexVecByIndexChecked(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.zero));
    const single_weighted_index_vec_by_index = try sampleWeightedIndexVecByIndex(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.single);
    defer single_weighted_index_vec_by_index.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 1), single_weighted_index_vec_by_index.len());
    try std.testing.expectEqual(@as(usize, 1), single_weighted_index_vec_by_index.at(0));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexVecByIndexChecked(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.single));
    const single_weighted_index_vec_by_index_checked = try sampleWeightedIndexVecByIndexChecked(f64, failing, std.testing.allocator, 3, 1, RootByIndexWeights.single);
    defer single_weighted_index_vec_by_index_checked.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 1), single_weighted_index_vec_by_index_checked.len());
    try std.testing.expectEqual(@as(usize, 1), single_weighted_index_vec_by_index_checked.at(0));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexVecByIndex(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexVecByIndexChecked(f64, failing, std.testing.allocator, 3, 2, RootByIndexWeights.invalid));
    var empty_weighted_indices_by_index_into: [0]usize = .{};
    var empty_weighted_by_index_keys_into: [0]f64 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesByIndexInto(f64, failing, 3, &empty_weighted_indices_by_index_into, &empty_weighted_by_index_keys_into, RootByIndexWeights.invalid));
    try sampleWeightedIndicesByIndexIntoChecked(f64, failing, 3, &empty_weighted_indices_by_index_into, &empty_weighted_by_index_keys_into, RootByIndexWeights.invalid);
    var weighted_indices_by_index_bad_scratch: [2]usize = undefined;
    var weighted_indices_by_index_short_keys: [1]f64 = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedIndicesByIndexInto(f64, failing, 3, &weighted_indices_by_index_bad_scratch, &weighted_indices_by_index_short_keys, RootByIndexWeights.weight));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedIndicesByIndexIntoChecked(f64, failing, 3, &weighted_indices_by_index_bad_scratch, &weighted_indices_by_index_short_keys, RootByIndexWeights.weight));
    var weighted_indices_by_index_one: [1]usize = undefined;
    var weighted_indices_by_index_one_key: [1]f64 = undefined;
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesByIndexInto(f64, failing, 0, &weighted_indices_by_index_one, &weighted_indices_by_index_one_key, RootByIndexWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByIndexIntoChecked(f64, failing, 0, &weighted_indices_by_index_one, &weighted_indices_by_index_one_key, RootByIndexWeights.single));
    var weighted_indices_by_index_zero: [2]usize = undefined;
    var weighted_indices_by_index_two_keys: [2]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesByIndexInto(f64, failing, 3, &weighted_indices_by_index_zero, &weighted_indices_by_index_two_keys, RootByIndexWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByIndexIntoChecked(f64, failing, 3, &weighted_indices_by_index_zero, &weighted_indices_by_index_two_keys, RootByIndexWeights.zero));
    var weighted_indices_by_index_single: [2]usize = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedIndicesByIndexInto(f64, failing, 3, &weighted_indices_by_index_single, &weighted_indices_by_index_two_keys, RootByIndexWeights.single));
    try std.testing.expectEqual(@as(usize, 1), weighted_indices_by_index_single[0]);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByIndexIntoChecked(f64, failing, 3, &weighted_indices_by_index_single, &weighted_indices_by_index_two_keys, RootByIndexWeights.single));
    try sampleWeightedIndicesByIndexIntoChecked(f64, failing, 3, &weighted_indices_by_index_one, &weighted_indices_by_index_one_key, RootByIndexWeights.single);
    try std.testing.expectEqual(@as(usize, 1), weighted_indices_by_index_one[0]);
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesByIndexInto(f64, failing, 3, &weighted_indices_by_index_zero, &weighted_indices_by_index_two_keys, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesByIndexIntoChecked(f64, failing, 3, &weighted_indices_by_index_zero, &weighted_indices_by_index_two_keys, RootByIndexWeights.invalid));
    var empty_weighted_indices_u32_by_index_into: [0]u32 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesU32ByIndexInto(f64, failing, 3, &empty_weighted_indices_u32_by_index_into, &empty_weighted_by_index_keys_into, RootByIndexWeights.invalid));
    try sampleWeightedIndicesU32ByIndexIntoChecked(f64, failing, 3, &empty_weighted_indices_u32_by_index_into, &empty_weighted_by_index_keys_into, RootByIndexWeights.invalid);
    var weighted_indices_u32_by_index_bad_scratch: [2]u32 = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedIndicesU32ByIndexInto(f64, failing, 3, &weighted_indices_u32_by_index_bad_scratch, &weighted_indices_by_index_short_keys, RootByIndexWeights.weight));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedIndicesU32ByIndexIntoChecked(f64, failing, 3, &weighted_indices_u32_by_index_bad_scratch, &weighted_indices_by_index_short_keys, RootByIndexWeights.weight));
    var weighted_indices_u32_by_index_one: [1]u32 = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByIndexInto(f64, failing, @as(usize, std.math.maxInt(u32)) + 1, &weighted_indices_u32_by_index_one, &weighted_indices_by_index_one_key, RootByIndexWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByIndexIntoChecked(f64, failing, @as(usize, std.math.maxInt(u32)) + 1, &weighted_indices_u32_by_index_one, &weighted_indices_by_index_one_key, RootByIndexWeights.single));
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesU32ByIndexInto(f64, failing, 0, &weighted_indices_u32_by_index_one, &weighted_indices_by_index_one_key, RootByIndexWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByIndexIntoChecked(f64, failing, 0, &weighted_indices_u32_by_index_one, &weighted_indices_by_index_one_key, RootByIndexWeights.single));
    var weighted_indices_u32_by_index_zero: [2]u32 = undefined;
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesU32ByIndexInto(f64, failing, 3, &weighted_indices_u32_by_index_zero, &weighted_indices_by_index_two_keys, RootByIndexWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByIndexIntoChecked(f64, failing, 3, &weighted_indices_u32_by_index_zero, &weighted_indices_by_index_two_keys, RootByIndexWeights.zero));
    var weighted_indices_u32_by_index_single: [2]u32 = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedIndicesU32ByIndexInto(f64, failing, 3, &weighted_indices_u32_by_index_single, &weighted_indices_by_index_two_keys, RootByIndexWeights.single));
    try std.testing.expectEqual(@as(u32, 1), weighted_indices_u32_by_index_single[0]);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByIndexIntoChecked(f64, failing, 3, &weighted_indices_u32_by_index_single, &weighted_indices_by_index_two_keys, RootByIndexWeights.single));
    try sampleWeightedIndicesU32ByIndexIntoChecked(f64, failing, 3, &weighted_indices_u32_by_index_one, &weighted_indices_by_index_one_key, RootByIndexWeights.single);
    try std.testing.expectEqual(@as(u32, 1), weighted_indices_u32_by_index_one[0]);
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesU32ByIndexInto(f64, failing, 3, &weighted_indices_u32_by_index_zero, &weighted_indices_by_index_two_keys, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesU32ByIndexIntoChecked(f64, failing, 3, &weighted_indices_u32_by_index_zero, &weighted_indices_by_index_two_keys, RootByIndexWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedIndexArrayByIndex(f64, failing, 0, 3, RootByIndexWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedIndexArrayByIndexChecked(f64, failing, 0, 3, RootByIndexWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[2]usize, null), try sampleWeightedIndexArrayByIndex(f64, failing, 2, 3, RootByIndexWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayByIndexChecked(f64, failing, 2, 3, RootByIndexWeights.zero));
    try std.testing.expectEqualSlices(usize, &.{1}, &(try sampleWeightedIndexArrayByIndex(f64, failing, 1, 3, RootByIndexWeights.single)).?);
    try std.testing.expectEqualSlices(usize, &.{1}, &(try sampleWeightedIndexArrayByIndexChecked(f64, failing, 1, 3, RootByIndexWeights.single)));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayByIndexChecked(f64, failing, 2, 3, RootByIndexWeights.single));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayByIndex(f64, failing, 2, 3, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayByIndexChecked(f64, failing, 2, 3, RootByIndexWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedIndexArrayU32ByIndex(f64, failing, 0, 3, RootByIndexWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedIndexArrayU32ByIndexChecked(f64, failing, 0, 3, RootByIndexWeights.invalid)).len);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32ByIndex(f64, failing, 1, @as(usize, std.math.maxInt(u32)) + 1, RootByIndexWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32ByIndexChecked(f64, failing, 1, @as(usize, std.math.maxInt(u32)) + 1, RootByIndexWeights.single));
    try std.testing.expectEqual(@as(?[2]u32, null), try sampleWeightedIndexArrayU32ByIndex(f64, failing, 2, 3, RootByIndexWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32ByIndexChecked(f64, failing, 2, 3, RootByIndexWeights.zero));
    try std.testing.expectEqualSlices(u32, &.{1}, &(try sampleWeightedIndexArrayU32ByIndex(f64, failing, 1, 3, RootByIndexWeights.single)).?);
    try std.testing.expectEqualSlices(u32, &.{1}, &(try sampleWeightedIndexArrayU32ByIndexChecked(f64, failing, 1, 3, RootByIndexWeights.single)));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32ByIndexChecked(f64, failing, 2, 3, RootByIndexWeights.single));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayU32ByIndex(f64, failing, 2, 3, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayU32ByIndexChecked(f64, failing, 2, 3, RootByIndexWeights.invalid));
    const RootItemWeights = struct {
        const Entry = struct {
            item: u8,
            weight: f64,
        };

        fn zero(entry: *const Entry) f64 {
            _ = entry;
            return 0;
        }
        fn single(entry: *const Entry) f64 {
            return if (entry.item == 20) 5 else 0;
        }
        fn invalid(entry: *const Entry) f64 {
            return if (entry.item == 10) std.math.nan(f64) else 1;
        }
        fn weight(entry: *const Entry) f64 {
            return entry.weight;
        }
    };
    const weighted_by_items = [_]RootItemWeights.Entry{
        .{ .item = 10, .weight = 1 },
        .{ .item = 20, .weight = 2 },
        .{ .item = 30, .weight = 3 },
    };
    var weighted_by_mut_sample_items = weighted_by_items;
    const empty_weighted_by_indices_nr = try sampleWeightedIndicesBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 0, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_by_indices_nr);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_by_indices_nr.len);
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &.{}, 1, RootItemWeights.single));
    const zero_weighted_by_indices_nr = try sampleWeightedIndicesBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.zero);
    defer std.testing.allocator.free(zero_weighted_by_indices_nr);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_by_indices_nr.len);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.zero));
    const single_weighted_by_indices_nr = try sampleWeightedIndicesBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_by_indices_nr);
    try std.testing.expectEqualSlices(usize, &.{1}, single_weighted_by_indices_nr);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.single));
    const single_weighted_by_checked_indices_nr = try sampleWeightedIndicesByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 1, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_by_checked_indices_nr);
    try std.testing.expectEqualSlices(usize, &.{1}, single_weighted_by_checked_indices_nr);
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.invalid));
    const empty_weighted_by_indices_u32_nr = try sampleWeightedIndicesU32By(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 0, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_by_indices_u32_nr);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_by_indices_u32_nr.len);
    const huge_weighted_by_sample_items = @as([*]const RootItemWeights.Entry, @ptrFromInt(0x1000))[0 .. @as(usize, std.math.maxInt(u32)) + 1];
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32By(RootItemWeights.Entry, f64, failing, std.testing.allocator, huge_weighted_by_sample_items, 1, RootItemWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, huge_weighted_by_sample_items, 1, RootItemWeights.single));
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesU32By(RootItemWeights.Entry, f64, failing, std.testing.allocator, &.{}, 1, RootItemWeights.single));
    const zero_weighted_by_indices_u32_nr = try sampleWeightedIndicesU32By(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.zero);
    defer std.testing.allocator.free(zero_weighted_by_indices_u32_nr);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_by_indices_u32_nr.len);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.zero));
    const single_weighted_by_indices_u32_nr = try sampleWeightedIndicesU32By(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_by_indices_u32_nr);
    try std.testing.expectEqualSlices(u32, &.{1}, single_weighted_by_indices_u32_nr);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesU32ByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.single));
    const single_weighted_by_checked_indices_u32_nr = try sampleWeightedIndicesU32ByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 1, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_by_checked_indices_u32_nr);
    try std.testing.expectEqualSlices(u32, &.{1}, single_weighted_by_checked_indices_u32_nr);
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesU32By(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesU32ByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.invalid));
    const empty_weighted_by_index_vec_nr = try sampleWeightedIndexVecBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 0, RootItemWeights.invalid);
    defer empty_weighted_by_index_vec_nr.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_by_index_vec_nr.len());
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndexVecBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &.{}, 1, RootItemWeights.single));
    const zero_weighted_by_index_vec_nr = try sampleWeightedIndexVecBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.zero);
    defer zero_weighted_by_index_vec_nr.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_by_index_vec_nr.len());
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexVecByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.zero));
    const single_weighted_by_index_vec_nr = try sampleWeightedIndexVecBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.single);
    defer single_weighted_by_index_vec_nr.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 1), single_weighted_by_index_vec_nr.len());
    try std.testing.expectEqual(@as(usize, 1), single_weighted_by_index_vec_nr.at(0));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexVecByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.single));
    const single_weighted_by_checked_index_vec_nr = try sampleWeightedIndexVecByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 1, RootItemWeights.single);
    defer single_weighted_by_checked_index_vec_nr.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(usize, 1), single_weighted_by_checked_index_vec_nr.len());
    try std.testing.expectEqual(@as(usize, 1), single_weighted_by_checked_index_vec_nr.at(0));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexVecBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexVecByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedIndexArrayBy(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedIndexArrayByChecked(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[2]usize, null), try sampleWeightedIndexArrayBy(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectEqualSlices(usize, &.{1}, &(try sampleWeightedIndexArrayBy(RootItemWeights.Entry, f64, failing, 1, &weighted_by_items, RootItemWeights.single)).?);
    try std.testing.expectEqualSlices(usize, &.{1}, &(try sampleWeightedIndexArrayByChecked(RootItemWeights.Entry, f64, failing, 1, &weighted_by_items, RootItemWeights.single)));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.single));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayBy(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedIndexArrayU32By(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedIndexArrayU32ByChecked(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).len);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32By(RootItemWeights.Entry, f64, failing, 1, huge_weighted_by_sample_items, RootItemWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32ByChecked(RootItemWeights.Entry, f64, failing, 1, huge_weighted_by_sample_items, RootItemWeights.single));
    try std.testing.expectEqual(@as(?[2]u32, null), try sampleWeightedIndexArrayU32By(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32ByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectEqualSlices(u32, &.{1}, &(try sampleWeightedIndexArrayU32By(RootItemWeights.Entry, f64, failing, 1, &weighted_by_items, RootItemWeights.single)).?);
    try std.testing.expectEqualSlices(u32, &.{1}, &(try sampleWeightedIndexArrayU32ByChecked(RootItemWeights.Entry, f64, failing, 1, &weighted_by_items, RootItemWeights.single)));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndexArrayU32ByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.single));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayU32By(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndexArrayU32ByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedArrayBy(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedArrayByChecked(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[2]RootItemWeights.Entry, null), try sampleWeightedArrayBy(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedArrayByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectEqual(@as(u8, 20), (try sampleWeightedArrayBy(RootItemWeights.Entry, f64, failing, 1, &weighted_by_items, RootItemWeights.single)).?[0].item);
    try std.testing.expectEqual(@as(u8, 20), (try sampleWeightedArrayByChecked(RootItemWeights.Entry, f64, failing, 1, &weighted_by_items, RootItemWeights.single))[0].item);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedArrayByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.single));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedArrayBy(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedArrayByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedPtrArrayBy(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[2]*const RootItemWeights.Entry, null), try sampleWeightedPtrArrayBy(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectEqual(&weighted_by_items[1], (try sampleWeightedPtrArrayBy(RootItemWeights.Entry, f64, failing, 1, &weighted_by_items, RootItemWeights.single)).?[0]);
    try std.testing.expectEqual(&weighted_by_items[1], (try sampleWeightedPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 1, &weighted_by_items, RootItemWeights.single))[0]);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.single));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrArrayBy(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_by_items, RootItemWeights.invalid));
    var weighted_mut_ptr_array_by_items = weighted_by_items;
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedMutPtrArrayBy(RootItemWeights.Entry, f64, failing, 0, &weighted_mut_ptr_array_by_items, RootItemWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try sampleWeightedMutPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 0, &weighted_mut_ptr_array_by_items, RootItemWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[2]*RootItemWeights.Entry, null), try sampleWeightedMutPtrArrayBy(RootItemWeights.Entry, f64, failing, 2, &weighted_mut_ptr_array_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_mut_ptr_array_by_items, RootItemWeights.zero));
    const single_weighted_mut_ptr_array_by = (try sampleWeightedMutPtrArrayBy(RootItemWeights.Entry, f64, failing, 1, &weighted_mut_ptr_array_by_items, RootItemWeights.single)).?;
    try std.testing.expectEqual(&weighted_mut_ptr_array_by_items[1], single_weighted_mut_ptr_array_by[0]);
    single_weighted_mut_ptr_array_by[0].item = 46;
    try std.testing.expectEqual(@as(u8, 46), weighted_mut_ptr_array_by_items[1].item);
    var weighted_mut_ptr_array_checked_by_items = weighted_by_items;
    try std.testing.expectEqual(&weighted_mut_ptr_array_checked_by_items[1], (try sampleWeightedMutPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 1, &weighted_mut_ptr_array_checked_by_items, RootItemWeights.single))[0]);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_mut_ptr_array_checked_by_items, RootItemWeights.single));
    var weighted_mut_ptr_array_invalid_by_items = weighted_by_items;
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrArrayBy(RootItemWeights.Entry, f64, failing, 2, &weighted_mut_ptr_array_invalid_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 2, &weighted_mut_ptr_array_invalid_by_items, RootItemWeights.invalid));
    const empty_weighted_by_values_nr = try sampleWeightedBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 0, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_by_values_nr);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_by_values_nr.len);
    const empty_weighted_by_ptrs_nr = try sampleWeightedPtrsBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 0, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_by_ptrs_nr);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_by_ptrs_nr.len);
    const empty_weighted_by_mut_ptrs_nr = try sampleWeightedMutPtrsBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_mut_sample_items, 0, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_by_mut_ptrs_nr);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_by_mut_ptrs_nr.len);
    try std.testing.expectError(error.EmptyInput, sampleWeightedBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &.{}, 1, RootItemWeights.single));
    try std.testing.expectError(error.EmptyInput, sampleWeightedPtrsBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &.{}, 1, RootItemWeights.single));
    var empty_weighted_by_mut_sample_items: [0]RootItemWeights.Entry = .{};
    try std.testing.expectError(error.EmptyInput, sampleWeightedMutPtrsBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &empty_weighted_by_mut_sample_items, 1, RootItemWeights.single));
    const zero_weighted_by_values_nr = try sampleWeightedBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.zero);
    defer std.testing.allocator.free(zero_weighted_by_values_nr);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_by_values_nr.len);
    const zero_weighted_by_ptrs_nr = try sampleWeightedPtrsBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.zero);
    defer std.testing.allocator.free(zero_weighted_by_ptrs_nr);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_by_ptrs_nr.len);
    var zero_weighted_by_mut_sample_items = weighted_by_items;
    const zero_weighted_by_mut_ptrs_nr = try sampleWeightedMutPtrsBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &zero_weighted_by_mut_sample_items, 2, RootItemWeights.zero);
    defer std.testing.allocator.free(zero_weighted_by_mut_ptrs_nr);
    try std.testing.expectEqual(@as(usize, 0), zero_weighted_by_mut_ptrs_nr.len);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrsByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrsByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &zero_weighted_by_mut_sample_items, 2, RootItemWeights.zero));
    const single_weighted_by_values_nr = try sampleWeightedBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_by_values_nr);
    try std.testing.expectEqual(@as(usize, 1), single_weighted_by_values_nr.len);
    try std.testing.expectEqual(@as(u8, 20), single_weighted_by_values_nr[0].item);
    const single_weighted_by_ptrs_nr = try sampleWeightedPtrsBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_by_ptrs_nr);
    try std.testing.expectEqual(@as(usize, 1), single_weighted_by_ptrs_nr.len);
    try std.testing.expectEqual(&weighted_by_items[1], single_weighted_by_ptrs_nr[0]);
    var single_weighted_by_mut_sample_items = weighted_by_items;
    const single_weighted_by_mut_ptrs_nr = try sampleWeightedMutPtrsBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &single_weighted_by_mut_sample_items, 2, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_by_mut_ptrs_nr);
    try std.testing.expectEqual(@as(usize, 1), single_weighted_by_mut_ptrs_nr.len);
    try std.testing.expectEqual(&single_weighted_by_mut_sample_items[1], single_weighted_by_mut_ptrs_nr[0]);
    single_weighted_by_mut_ptrs_nr[0].item = 44;
    try std.testing.expectEqual(@as(u8, 44), single_weighted_by_mut_sample_items[1].item);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrsByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrsByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &single_weighted_by_mut_sample_items, 2, RootItemWeights.single));
    const single_weighted_by_checked_values_nr = try sampleWeightedByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 1, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_by_checked_values_nr);
    try std.testing.expectEqual(@as(u8, 20), single_weighted_by_checked_values_nr[0].item);
    const single_weighted_by_checked_ptrs_nr = try sampleWeightedPtrsByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 1, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_by_checked_ptrs_nr);
    try std.testing.expectEqual(&weighted_by_items[1], single_weighted_by_checked_ptrs_nr[0]);
    var single_weighted_by_mut_checked_sample_items = weighted_by_items;
    const single_weighted_by_checked_mut_ptrs_nr = try sampleWeightedMutPtrsByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &single_weighted_by_mut_checked_sample_items, 1, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_by_checked_mut_ptrs_nr);
    try std.testing.expectEqual(&single_weighted_by_mut_checked_sample_items[1], single_weighted_by_checked_mut_ptrs_nr[0]);
    try std.testing.expectError(error.InvalidWeight, sampleWeightedBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrsBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrsByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &weighted_by_items, 2, RootItemWeights.invalid));
    var invalid_weighted_by_mut_sample_items = weighted_by_items;
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrsBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, &invalid_weighted_by_mut_sample_items, 2, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrsByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, &invalid_weighted_by_mut_sample_items, 2, RootItemWeights.invalid));
    var empty_weighted_by_values_into: [0]RootItemWeights.Entry = .{};
    var empty_weighted_by_indices_into: [0]usize = .{};
    var empty_weighted_by_keys_into: [0]f64 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &empty_weighted_by_values_into, &empty_weighted_by_indices_into, &empty_weighted_by_keys_into, RootItemWeights.invalid));
    try sampleWeightedByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &empty_weighted_by_values_into, &empty_weighted_by_indices_into, &empty_weighted_by_keys_into, RootItemWeights.invalid);
    var weighted_by_values_bad_scratch: [2]RootItemWeights.Entry = undefined;
    var weighted_by_values_short_index: [1]usize = undefined;
    var weighted_by_values_two_keys: [2]f64 = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_values_bad_scratch, &weighted_by_values_short_index, &weighted_by_values_two_keys, RootItemWeights.weight));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_values_bad_scratch, &weighted_by_values_short_index, &weighted_by_values_two_keys, RootItemWeights.weight));
    var weighted_by_values_one: [1]RootItemWeights.Entry = undefined;
    var weighted_by_values_one_index: [1]usize = undefined;
    var weighted_by_values_one_key: [1]f64 = undefined;
    try std.testing.expectError(error.EmptyInput, sampleWeightedByInto(RootItemWeights.Entry, f64, failing, &.{}, &weighted_by_values_one, &weighted_by_values_one_index, &weighted_by_values_one_key, RootItemWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedByIntoChecked(RootItemWeights.Entry, f64, failing, &.{}, &weighted_by_values_one, &weighted_by_values_one_index, &weighted_by_values_one_key, RootItemWeights.single));
    var weighted_by_values_zero: [2]RootItemWeights.Entry = undefined;
    var weighted_by_values_two_indices: [2]usize = undefined;
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_values_zero, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_values_zero, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.zero));
    var weighted_by_values_single: [2]RootItemWeights.Entry = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_values_single, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.single));
    try std.testing.expectEqual(@as(u8, 20), weighted_by_values_single[0].item);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_values_single, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.single));
    try sampleWeightedByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_values_one, &weighted_by_values_one_index, &weighted_by_values_one_key, RootItemWeights.single);
    try std.testing.expectEqual(@as(u8, 20), weighted_by_values_one[0].item);
    try std.testing.expectError(error.InvalidWeight, sampleWeightedByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_values_zero, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_values_zero, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.invalid));
    var empty_weighted_by_ptrs_into: [0]*const RootItemWeights.Entry = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedPtrsByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &empty_weighted_by_ptrs_into, &empty_weighted_by_indices_into, &empty_weighted_by_keys_into, RootItemWeights.invalid));
    try sampleWeightedPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &empty_weighted_by_ptrs_into, &empty_weighted_by_indices_into, &empty_weighted_by_keys_into, RootItemWeights.invalid);
    var weighted_by_ptrs_bad_scratch: [2]*const RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedPtrsByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_ptrs_bad_scratch, &weighted_by_values_short_index, &weighted_by_values_two_keys, RootItemWeights.weight));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_ptrs_bad_scratch, &weighted_by_values_short_index, &weighted_by_values_two_keys, RootItemWeights.weight));
    var weighted_by_ptrs_one: [1]*const RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.EmptyInput, sampleWeightedPtrsByInto(RootItemWeights.Entry, f64, failing, &.{}, &weighted_by_ptrs_one, &weighted_by_values_one_index, &weighted_by_values_one_key, RootItemWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &.{}, &weighted_by_ptrs_one, &weighted_by_values_one_index, &weighted_by_values_one_key, RootItemWeights.single));
    var weighted_by_ptrs_zero: [2]*const RootItemWeights.Entry = undefined;
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedPtrsByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_ptrs_zero, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_ptrs_zero, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.zero));
    var weighted_by_ptrs_single: [2]*const RootItemWeights.Entry = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedPtrsByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_ptrs_single, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.single));
    try std.testing.expectEqual(&weighted_by_items[1], weighted_by_ptrs_single[0]);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_ptrs_single, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.single));
    try sampleWeightedPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_ptrs_one, &weighted_by_values_one_index, &weighted_by_values_one_key, RootItemWeights.single);
    try std.testing.expectEqual(&weighted_by_items[1], weighted_by_ptrs_one[0]);
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrsByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_ptrs_zero, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_ptrs_zero, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.invalid));
    var empty_weighted_by_mut_ptrs_into: [0]*RootItemWeights.Entry = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedMutPtrsByInto(RootItemWeights.Entry, f64, failing, &weighted_by_mut_sample_items, &empty_weighted_by_mut_ptrs_into, &empty_weighted_by_indices_into, &empty_weighted_by_keys_into, RootItemWeights.invalid));
    try sampleWeightedMutPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_mut_sample_items, &empty_weighted_by_mut_ptrs_into, &empty_weighted_by_indices_into, &empty_weighted_by_keys_into, RootItemWeights.invalid);
    var weighted_by_mut_ptrs_bad_scratch: [2]*RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedMutPtrsByInto(RootItemWeights.Entry, f64, failing, &weighted_by_mut_sample_items, &weighted_by_mut_ptrs_bad_scratch, &weighted_by_values_short_index, &weighted_by_values_two_keys, RootItemWeights.weight));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedMutPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_mut_sample_items, &weighted_by_mut_ptrs_bad_scratch, &weighted_by_values_short_index, &weighted_by_values_two_keys, RootItemWeights.weight));
    var weighted_by_mut_ptrs_one: [1]*RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.EmptyInput, sampleWeightedMutPtrsByInto(RootItemWeights.Entry, f64, failing, &empty_weighted_by_mut_sample_items, &weighted_by_mut_ptrs_one, &weighted_by_values_one_index, &weighted_by_values_one_key, RootItemWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &empty_weighted_by_mut_sample_items, &weighted_by_mut_ptrs_one, &weighted_by_values_one_index, &weighted_by_values_one_key, RootItemWeights.single));
    var weighted_by_mut_ptrs_zero_items = weighted_by_items;
    var weighted_by_mut_ptrs_zero: [2]*RootItemWeights.Entry = undefined;
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedMutPtrsByInto(RootItemWeights.Entry, f64, failing, &weighted_by_mut_ptrs_zero_items, &weighted_by_mut_ptrs_zero, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_mut_ptrs_zero_items, &weighted_by_mut_ptrs_zero, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.zero));
    var weighted_by_mut_ptrs_single_items = weighted_by_items;
    var weighted_by_mut_ptrs_single: [2]*RootItemWeights.Entry = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedMutPtrsByInto(RootItemWeights.Entry, f64, failing, &weighted_by_mut_ptrs_single_items, &weighted_by_mut_ptrs_single, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.single));
    try std.testing.expectEqual(&weighted_by_mut_ptrs_single_items[1], weighted_by_mut_ptrs_single[0]);
    weighted_by_mut_ptrs_single[0].item = 45;
    try std.testing.expectEqual(@as(u8, 45), weighted_by_mut_ptrs_single_items[1].item);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedMutPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_mut_ptrs_single_items, &weighted_by_mut_ptrs_single, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.single));
    var weighted_by_mut_ptrs_checked_single_items = weighted_by_items;
    try sampleWeightedMutPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_mut_ptrs_checked_single_items, &weighted_by_mut_ptrs_one, &weighted_by_values_one_index, &weighted_by_values_one_key, RootItemWeights.single);
    try std.testing.expectEqual(&weighted_by_mut_ptrs_checked_single_items[1], weighted_by_mut_ptrs_one[0]);
    var weighted_by_mut_ptrs_invalid_items = weighted_by_items;
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrsByInto(RootItemWeights.Entry, f64, failing, &weighted_by_mut_ptrs_invalid_items, &weighted_by_mut_ptrs_zero, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedMutPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_mut_ptrs_invalid_items, &weighted_by_mut_ptrs_zero, &weighted_by_values_two_indices, &weighted_by_values_two_keys, RootItemWeights.invalid));
    var empty_weighted_by_index_indices_into: [0]usize = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &empty_weighted_by_index_indices_into, &empty_weighted_by_keys_into, RootItemWeights.invalid));
    try sampleWeightedIndicesByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &empty_weighted_by_index_indices_into, &empty_weighted_by_keys_into, RootItemWeights.invalid);
    var weighted_by_indices_bad_scratch: [2]usize = undefined;
    var weighted_by_indices_short_keys: [1]f64 = undefined;
    try std.testing.expectError(error.LengthMismatch, sampleWeightedIndicesByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_indices_bad_scratch, &weighted_by_indices_short_keys, RootItemWeights.weight));
    try std.testing.expectError(error.LengthMismatch, sampleWeightedIndicesByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_indices_bad_scratch, &weighted_by_indices_short_keys, RootItemWeights.weight));
    var weighted_by_indices_one: [1]usize = undefined;
    try std.testing.expectError(error.EmptyInput, sampleWeightedIndicesByInto(RootItemWeights.Entry, f64, failing, &.{}, &weighted_by_indices_one, &weighted_by_values_one_key, RootItemWeights.single));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByIntoChecked(RootItemWeights.Entry, f64, failing, &.{}, &weighted_by_indices_one, &weighted_by_values_one_key, RootItemWeights.single));
    var weighted_by_indices_zero: [2]usize = undefined;
    try std.testing.expectEqual(@as(usize, 0), try sampleWeightedIndicesByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_indices_zero, &weighted_by_values_two_keys, RootItemWeights.zero));
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_indices_zero, &weighted_by_values_two_keys, RootItemWeights.zero));
    var weighted_by_indices_single: [2]usize = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleWeightedIndicesByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_indices_single, &weighted_by_values_two_keys, RootItemWeights.single));
    try std.testing.expectEqual(@as(usize, 1), weighted_by_indices_single[0]);
    try std.testing.expectError(error.InvalidParameter, sampleWeightedIndicesByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_indices_single, &weighted_by_values_two_keys, RootItemWeights.single));
    try sampleWeightedIndicesByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_indices_one, &weighted_by_values_one_key, RootItemWeights.single);
    try std.testing.expectEqual(@as(usize, 1), weighted_by_indices_one[0]);
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesByInto(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_indices_zero, &weighted_by_values_two_keys, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, sampleWeightedIndicesByIntoChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, &weighted_by_indices_zero, &weighted_by_values_two_keys, RootItemWeights.invalid));
    try std.testing.expectEqual(@as(?usize, null), try weightedIndexBy(RootItemWeights.Entry, f64, failing, &.{}, RootItemWeights.single));
    try std.testing.expectError(error.EmptyInput, weightedIndexByChecked(RootItemWeights.Entry, f64, failing, &.{}, RootItemWeights.single));
    try std.testing.expectEqual(@as(?usize, null), try weightedIndexBy(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.EmptyInput, weightedIndexByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectEqual(@as(?usize, 1), try weightedIndexBy(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.single));
    try std.testing.expectEqual(@as(usize, 1), try weightedIndexByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.single));
    try std.testing.expectError(error.InvalidWeight, weightedIndexBy(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectEqual(@as(?u32, null), try weightedIndexU32By(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.EmptyInput, weightedIndexU32ByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectEqual(@as(?u32, 1), try weightedIndexU32By(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.single));
    try std.testing.expectEqual(@as(u32, 1), try weightedIndexU32ByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.single));
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32ByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.invalid));
    const huge_weighted_by_items = @as([*]const RootItemWeights.Entry, @ptrFromInt(0x1000))[0 .. @as(usize, std.math.maxInt(u32)) + 1];
    try std.testing.expectError(error.InvalidParameter, weightedIndexU32By(RootItemWeights.Entry, f64, failing, huge_weighted_by_items, RootItemWeights.single));
    var weighted_by_empty_fill: [0]?usize = .{};
    try fillWeightedIndexBy(RootItemWeights.Entry, f64, failing, &weighted_by_empty_fill, &weighted_by_items, RootItemWeights.invalid);
    var weighted_by_empty_checked_fill: [0]usize = .{};
    try fillWeightedIndexByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_empty_checked_fill, &weighted_by_items, RootItemWeights.invalid);
    var weighted_by_zero_fill: [3]?usize = undefined;
    try fillWeightedIndexBy(RootItemWeights.Entry, f64, failing, &weighted_by_zero_fill, &weighted_by_items, RootItemWeights.zero);
    try std.testing.expectEqualSlices(?usize, &.{ null, null, null }, &weighted_by_zero_fill);
    var weighted_by_checked_fill: [3]usize = undefined;
    try std.testing.expectError(error.EmptyInput, fillWeightedIndexByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_checked_fill, &weighted_by_items, RootItemWeights.zero));
    try fillWeightedIndexBy(RootItemWeights.Entry, f64, failing, &weighted_by_zero_fill, &weighted_by_items, RootItemWeights.single);
    try std.testing.expectEqualSlices(?usize, &.{ 1, 1, 1 }, &weighted_by_zero_fill);
    try fillWeightedIndexByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_checked_fill, &weighted_by_items, RootItemWeights.single);
    try std.testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, &weighted_by_checked_fill);
    try std.testing.expectError(error.InvalidWeight, fillWeightedIndexBy(RootItemWeights.Entry, f64, failing, &weighted_by_zero_fill, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, fillWeightedIndexByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_checked_fill, &weighted_by_items, RootItemWeights.invalid));
    var weighted_u32_by_empty_fill: [0]?u32 = .{};
    try fillWeightedIndexU32By(RootItemWeights.Entry, f64, failing, &weighted_u32_by_empty_fill, &weighted_by_items, RootItemWeights.invalid);
    var weighted_u32_by_empty_checked_fill: [0]u32 = .{};
    try fillWeightedIndexU32ByChecked(RootItemWeights.Entry, f64, failing, &weighted_u32_by_empty_checked_fill, &weighted_by_items, RootItemWeights.invalid);
    var weighted_u32_by_zero_fill: [3]?u32 = undefined;
    try fillWeightedIndexU32By(RootItemWeights.Entry, f64, failing, &weighted_u32_by_zero_fill, &weighted_by_items, RootItemWeights.zero);
    try std.testing.expectEqualSlices(?u32, &.{ null, null, null }, &weighted_u32_by_zero_fill);
    var weighted_u32_by_checked_fill: [3]u32 = undefined;
    try std.testing.expectError(error.EmptyInput, fillWeightedIndexU32ByChecked(RootItemWeights.Entry, f64, failing, &weighted_u32_by_checked_fill, &weighted_by_items, RootItemWeights.zero));
    try fillWeightedIndexU32By(RootItemWeights.Entry, f64, failing, &weighted_u32_by_zero_fill, &weighted_by_items, RootItemWeights.single);
    try std.testing.expectEqualSlices(?u32, &.{ 1, 1, 1 }, &weighted_u32_by_zero_fill);
    try fillWeightedIndexU32ByChecked(RootItemWeights.Entry, f64, failing, &weighted_u32_by_checked_fill, &weighted_by_items, RootItemWeights.single);
    try std.testing.expectEqualSlices(u32, &.{ 1, 1, 1 }, &weighted_u32_by_checked_fill);
    try std.testing.expectError(error.InvalidWeight, fillWeightedIndexU32By(RootItemWeights.Entry, f64, failing, &weighted_u32_by_zero_fill, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, fillWeightedIndexU32ByChecked(RootItemWeights.Entry, f64, failing, &weighted_u32_by_checked_fill, &weighted_by_items, RootItemWeights.invalid));
    var weighted_u32_by_oversized: [1]?u32 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillWeightedIndexU32By(RootItemWeights.Entry, f64, failing, &weighted_u32_by_oversized, huge_weighted_by_items, RootItemWeights.single));
    var weighted_u32_by_checked_oversized: [1]u32 = undefined;
    try std.testing.expectError(error.InvalidParameter, fillWeightedIndexU32ByChecked(RootItemWeights.Entry, f64, failing, &weighted_u32_by_checked_oversized, huge_weighted_by_items, RootItemWeights.single));
    const empty_weighted_by_batch = try weightedIndexBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 0, &weighted_by_items, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_by_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_by_batch.len);
    const empty_weighted_by_checked_batch = try weightedIndexBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 0, &weighted_by_items, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_by_checked_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_by_checked_batch.len);
    const zero_weighted_by_batch = try weightedIndexBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.zero);
    defer std.testing.allocator.free(zero_weighted_by_batch);
    try std.testing.expectEqualSlices(?usize, &.{ null, null, null }, zero_weighted_by_batch);
    try std.testing.expectError(error.EmptyInput, weightedIndexBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.zero));
    var weighted_by_checked_empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, weightedIndexBatchByChecked(RootItemWeights.Entry, f64, failing, weighted_by_checked_empty_alloc.allocator(), 3, &weighted_by_items, RootItemWeights.zero));
    const single_weighted_by_batch = try weightedIndexBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_by_batch);
    try std.testing.expectEqualSlices(?usize, &.{ 1, 1, 1 }, single_weighted_by_batch);
    const single_weighted_by_checked_batch = try weightedIndexBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_by_checked_batch);
    try std.testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, single_weighted_by_checked_batch);
    try std.testing.expectError(error.InvalidWeight, weightedIndexBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, weightedIndexBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.invalid));
    var weighted_by_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexBatchBy(RootItemWeights.Entry, f64, failing, weighted_by_invalid_alloc.allocator(), 3, &weighted_by_items, RootItemWeights.invalid));
    var weighted_by_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexBatchByChecked(RootItemWeights.Entry, f64, failing, weighted_by_checked_invalid_alloc.allocator(), 3, &weighted_by_items, RootItemWeights.invalid));
    const empty_weighted_u32_by_batch = try weightedIndexU32BatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 0, &weighted_by_items, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_u32_by_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_u32_by_batch.len);
    const empty_weighted_u32_by_checked_batch = try weightedIndexU32BatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 0, &weighted_by_items, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_u32_by_checked_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_u32_by_checked_batch.len);
    try std.testing.expectError(error.InvalidParameter, weightedIndexU32BatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 1, huge_weighted_by_items, RootItemWeights.single));
    try std.testing.expectError(error.InvalidParameter, weightedIndexU32BatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 1, huge_weighted_by_items, RootItemWeights.single));
    var weighted_u32_by_oversized_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, weightedIndexU32BatchBy(RootItemWeights.Entry, f64, failing, weighted_u32_by_oversized_alloc.allocator(), 1, huge_weighted_by_items, RootItemWeights.single));
    var weighted_u32_by_checked_oversized_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, weightedIndexU32BatchByChecked(RootItemWeights.Entry, f64, failing, weighted_u32_by_checked_oversized_alloc.allocator(), 1, huge_weighted_by_items, RootItemWeights.single));
    const zero_weighted_u32_by_batch = try weightedIndexU32BatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.zero);
    defer std.testing.allocator.free(zero_weighted_u32_by_batch);
    try std.testing.expectEqualSlices(?u32, &.{ null, null, null }, zero_weighted_u32_by_batch);
    try std.testing.expectError(error.EmptyInput, weightedIndexU32BatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.zero));
    var weighted_u32_by_checked_empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, weightedIndexU32BatchByChecked(RootItemWeights.Entry, f64, failing, weighted_u32_by_checked_empty_alloc.allocator(), 3, &weighted_by_items, RootItemWeights.zero));
    const single_weighted_u32_by_batch = try weightedIndexU32BatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_u32_by_batch);
    try std.testing.expectEqualSlices(?u32, &.{ 1, 1, 1 }, single_weighted_u32_by_batch);
    const single_weighted_u32_by_checked_batch = try weightedIndexU32BatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_u32_by_checked_batch);
    try std.testing.expectEqualSlices(u32, &.{ 1, 1, 1 }, single_weighted_u32_by_checked_batch);
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32BatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32BatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.invalid));
    var weighted_u32_by_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32BatchBy(RootItemWeights.Entry, f64, failing, weighted_u32_by_invalid_alloc.allocator(), 3, &weighted_by_items, RootItemWeights.invalid));
    var weighted_u32_by_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32BatchByChecked(RootItemWeights.Entry, f64, failing, weighted_u32_by_checked_invalid_alloc.allocator(), 3, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try weightedIndexArrayBy(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try weightedIndexArrayByChecked(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[3]usize, null), try weightedIndexArrayBy(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.EmptyInput, weightedIndexArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, &(try weightedIndexArrayBy(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.single)).?);
    try std.testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, &(try weightedIndexArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.single)));
    try std.testing.expectError(error.InvalidWeight, weightedIndexArrayBy(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, weightedIndexArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try weightedIndexU32ArrayBy(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try weightedIndexU32ArrayByChecked(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[3]u32, null), try weightedIndexU32ArrayBy(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.EmptyInput, weightedIndexU32ArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectEqualSlices(u32, &.{ 1, 1, 1 }, &(try weightedIndexU32ArrayBy(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.single)).?);
    try std.testing.expectEqualSlices(u32, &.{ 1, 1, 1 }, &(try weightedIndexU32ArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.single)));
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32ArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidParameter, weightedIndexU32ArrayBy(RootItemWeights.Entry, f64, failing, 3, huge_weighted_by_items, RootItemWeights.single));
    try std.testing.expectEqual(@as(?RootItemWeights.Entry, null), try chooseWeightedBy(RootItemWeights.Entry, f64, failing, &.{}, RootItemWeights.single));
    try std.testing.expectEqual(@as(?RootItemWeights.Entry, null), try chooseWeightedBy(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.EmptyInput, chooseWeightedByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.zero));
    const single_weighted_value_by = (try chooseWeightedBy(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.single)).?;
    try std.testing.expectEqual(@as(u8, 20), single_weighted_value_by.item);
    const single_weighted_value_by_checked = try chooseWeightedByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.single);
    try std.testing.expectEqual(@as(u8, 20), single_weighted_value_by_checked.item);
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBy(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectEqual(@as(?*const RootItemWeights.Entry, null), try chooseWeightedConstPtrBy(RootItemWeights.Entry, f64, failing, &.{}, RootItemWeights.single));
    try std.testing.expectEqual(@as(?*const RootItemWeights.Entry, null), try chooseWeightedConstPtrBy(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.EmptyInput, chooseWeightedConstPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectEqual(&weighted_by_items[1], (try chooseWeightedConstPtrBy(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.single)).?);
    try std.testing.expectEqual(&weighted_by_items[1], try chooseWeightedConstPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.single));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBy(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_items, RootItemWeights.invalid));
    var empty_weighted_by_mut_items: [0]RootItemWeights.Entry = .{};
    try std.testing.expectEqual(@as(?*RootItemWeights.Entry, null), try chooseWeightedPtrBy(RootItemWeights.Entry, f64, failing, &empty_weighted_by_mut_items, RootItemWeights.single));
    var weighted_by_mut_zero_items = weighted_by_items;
    try std.testing.expectEqual(@as(?*RootItemWeights.Entry, null), try chooseWeightedPtrBy(RootItemWeights.Entry, f64, failing, &weighted_by_mut_zero_items, RootItemWeights.zero));
    try std.testing.expectError(error.EmptyInput, chooseWeightedPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_mut_zero_items, RootItemWeights.zero));
    var weighted_by_mut_single_items = weighted_by_items;
    const single_weighted_mut_ptr_by = (try chooseWeightedPtrBy(RootItemWeights.Entry, f64, failing, &weighted_by_mut_single_items, RootItemWeights.single)).?;
    try std.testing.expectEqual(&weighted_by_mut_single_items[1], single_weighted_mut_ptr_by);
    single_weighted_mut_ptr_by.item = 99;
    try std.testing.expectEqual(@as(u8, 99), weighted_by_mut_single_items[1].item);
    var weighted_by_mut_single_checked_items = weighted_by_items;
    try std.testing.expectEqual(&weighted_by_mut_single_checked_items[1], try chooseWeightedPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_mut_single_checked_items, RootItemWeights.single));
    var weighted_by_mut_invalid_items = weighted_by_items;
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBy(RootItemWeights.Entry, f64, failing, &weighted_by_mut_invalid_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_mut_invalid_items, RootItemWeights.invalid));
    var weighted_value_by_empty_fill: [0]?RootItemWeights.Entry = .{};
    try fillChooseWeightedBy(RootItemWeights.Entry, f64, failing, &weighted_value_by_empty_fill, &weighted_by_items, RootItemWeights.invalid);
    var weighted_value_by_empty_checked_fill: [0]RootItemWeights.Entry = .{};
    try fillChooseWeightedByChecked(RootItemWeights.Entry, f64, failing, &weighted_value_by_empty_checked_fill, &weighted_by_items, RootItemWeights.invalid);
    var weighted_value_by_zero_fill: [3]?RootItemWeights.Entry = undefined;
    try fillChooseWeightedBy(RootItemWeights.Entry, f64, failing, &weighted_value_by_zero_fill, &weighted_by_items, RootItemWeights.zero);
    for (weighted_value_by_zero_fill) |value| try std.testing.expect(value == null);
    var weighted_value_by_checked_fill: [3]RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.EmptyInput, fillChooseWeightedByChecked(RootItemWeights.Entry, f64, failing, &weighted_value_by_checked_fill, &weighted_by_items, RootItemWeights.zero));
    try fillChooseWeightedBy(RootItemWeights.Entry, f64, failing, &weighted_value_by_zero_fill, &weighted_by_items, RootItemWeights.single);
    for (weighted_value_by_zero_fill) |value| try std.testing.expectEqual(@as(u8, 20), value.?.item);
    try fillChooseWeightedByChecked(RootItemWeights.Entry, f64, failing, &weighted_value_by_checked_fill, &weighted_by_items, RootItemWeights.single);
    for (weighted_value_by_checked_fill) |value| try std.testing.expectEqual(@as(u8, 20), value.item);
    try std.testing.expectError(error.InvalidWeight, fillChooseWeightedBy(RootItemWeights.Entry, f64, failing, &weighted_value_by_zero_fill, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, fillChooseWeightedByChecked(RootItemWeights.Entry, f64, failing, &weighted_value_by_checked_fill, &weighted_by_items, RootItemWeights.invalid));
    const empty_weighted_value_by_batch = try chooseWeightedBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 0, &weighted_by_items, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_value_by_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_value_by_batch.len);
    const empty_weighted_value_by_checked_batch = try chooseWeightedBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 0, &weighted_by_items, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_value_by_checked_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_value_by_checked_batch.len);
    const zero_weighted_value_by_batch = try chooseWeightedBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.zero);
    defer std.testing.allocator.free(zero_weighted_value_by_batch);
    for (zero_weighted_value_by_batch) |value| try std.testing.expect(value == null);
    try std.testing.expectError(error.EmptyInput, chooseWeightedBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.zero));
    var weighted_value_by_checked_empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, chooseWeightedBatchByChecked(RootItemWeights.Entry, f64, failing, weighted_value_by_checked_empty_alloc.allocator(), 3, &weighted_by_items, RootItemWeights.zero));
    const single_weighted_value_by_batch = try chooseWeightedBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_value_by_batch);
    for (single_weighted_value_by_batch) |value| try std.testing.expectEqual(@as(u8, 20), value.?.item);
    const single_weighted_value_by_checked_batch = try chooseWeightedBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_value_by_checked_batch);
    for (single_weighted_value_by_checked_batch) |value| try std.testing.expectEqual(@as(u8, 20), value.item);
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.invalid));
    var weighted_value_by_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatchBy(RootItemWeights.Entry, f64, failing, weighted_value_by_invalid_alloc.allocator(), 3, &weighted_by_items, RootItemWeights.invalid));
    var weighted_value_by_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatchByChecked(RootItemWeights.Entry, f64, failing, weighted_value_by_checked_invalid_alloc.allocator(), 3, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try chooseWeightedValueArrayBy(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try chooseWeightedValueArrayByChecked(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[3]RootItemWeights.Entry, null), try chooseWeightedValueArrayBy(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.EmptyInput, chooseWeightedValueArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.zero));
    for ((try chooseWeightedValueArrayBy(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.single)).?) |value| try std.testing.expectEqual(@as(u8, 20), value.item);
    for (try chooseWeightedValueArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.single)) |value| try std.testing.expectEqual(@as(u8, 20), value.item);
    try std.testing.expectError(error.InvalidWeight, chooseWeightedValueArrayBy(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedValueArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try chooseWeightedConstPtrArrayBy(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try chooseWeightedConstPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 0, &weighted_by_items, RootItemWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[3]*const RootItemWeights.Entry, null), try chooseWeightedConstPtrArrayBy(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.zero));
    try std.testing.expectError(error.EmptyInput, chooseWeightedConstPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.zero));
    for ((try chooseWeightedConstPtrArrayBy(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.single)).?) |ptr| try std.testing.expectEqual(&weighted_by_items[1], ptr);
    for (try chooseWeightedConstPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.single)) |ptr| try std.testing.expectEqual(&weighted_by_items[1], ptr);
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrArrayBy(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &weighted_by_items, RootItemWeights.invalid));
    var weighted_const_ptr_by_empty_fill: [0]?*const RootItemWeights.Entry = .{};
    try fillChooseWeightedConstPtrBy(RootItemWeights.Entry, f64, failing, &weighted_const_ptr_by_empty_fill, &weighted_by_items, RootItemWeights.invalid);
    var weighted_const_ptr_by_empty_checked_fill: [0]*const RootItemWeights.Entry = .{};
    try fillChooseWeightedConstPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_const_ptr_by_empty_checked_fill, &weighted_by_items, RootItemWeights.invalid);
    var weighted_const_ptr_by_zero_fill: [3]?*const RootItemWeights.Entry = undefined;
    try fillChooseWeightedConstPtrBy(RootItemWeights.Entry, f64, failing, &weighted_const_ptr_by_zero_fill, &weighted_by_items, RootItemWeights.zero);
    for (weighted_const_ptr_by_zero_fill) |ptr| try std.testing.expect(ptr == null);
    var weighted_const_ptr_by_checked_fill: [3]*const RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.EmptyInput, fillChooseWeightedConstPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_const_ptr_by_checked_fill, &weighted_by_items, RootItemWeights.zero));
    try fillChooseWeightedConstPtrBy(RootItemWeights.Entry, f64, failing, &weighted_const_ptr_by_zero_fill, &weighted_by_items, RootItemWeights.single);
    for (weighted_const_ptr_by_zero_fill) |ptr| try std.testing.expectEqual(&weighted_by_items[1], ptr.?);
    try fillChooseWeightedConstPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_const_ptr_by_checked_fill, &weighted_by_items, RootItemWeights.single);
    for (weighted_const_ptr_by_checked_fill) |ptr| try std.testing.expectEqual(&weighted_by_items[1], ptr);
    try std.testing.expectError(error.InvalidWeight, fillChooseWeightedConstPtrBy(RootItemWeights.Entry, f64, failing, &weighted_const_ptr_by_zero_fill, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, fillChooseWeightedConstPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_const_ptr_by_checked_fill, &weighted_by_items, RootItemWeights.invalid));
    const empty_weighted_const_ptr_by_batch = try chooseWeightedConstPtrBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 0, &weighted_by_items, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_const_ptr_by_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_const_ptr_by_batch.len);
    const empty_weighted_const_ptr_by_checked_batch = try chooseWeightedConstPtrBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 0, &weighted_by_items, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_const_ptr_by_checked_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_const_ptr_by_checked_batch.len);
    const zero_weighted_const_ptr_by_batch = try chooseWeightedConstPtrBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.zero);
    defer std.testing.allocator.free(zero_weighted_const_ptr_by_batch);
    for (zero_weighted_const_ptr_by_batch) |ptr| try std.testing.expect(ptr == null);
    try std.testing.expectError(error.EmptyInput, chooseWeightedConstPtrBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.zero));
    var weighted_const_ptr_by_checked_empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, chooseWeightedConstPtrBatchByChecked(RootItemWeights.Entry, f64, failing, weighted_const_ptr_by_checked_empty_alloc.allocator(), 3, &weighted_by_items, RootItemWeights.zero));
    const single_weighted_const_ptr_by_batch = try chooseWeightedConstPtrBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_const_ptr_by_batch);
    for (single_weighted_const_ptr_by_batch) |ptr| try std.testing.expectEqual(&weighted_by_items[1], ptr.?);
    const single_weighted_const_ptr_by_checked_batch = try chooseWeightedConstPtrBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_const_ptr_by_checked_batch);
    for (single_weighted_const_ptr_by_checked_batch) |ptr| try std.testing.expectEqual(&weighted_by_items[1], ptr);
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &weighted_by_items, RootItemWeights.invalid));
    var weighted_const_ptr_by_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatchBy(RootItemWeights.Entry, f64, failing, weighted_const_ptr_by_invalid_alloc.allocator(), 3, &weighted_by_items, RootItemWeights.invalid));
    var weighted_const_ptr_by_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatchByChecked(RootItemWeights.Entry, f64, failing, weighted_const_ptr_by_checked_invalid_alloc.allocator(), 3, &weighted_by_items, RootItemWeights.invalid));
    var weighted_mut_ptr_by_empty_items: [0]RootItemWeights.Entry = .{};
    var weighted_mut_ptr_by_empty_fill: [0]?*RootItemWeights.Entry = .{};
    try fillChooseWeightedPtrBy(RootItemWeights.Entry, f64, failing, &weighted_mut_ptr_by_empty_fill, &weighted_mut_ptr_by_empty_items, RootItemWeights.invalid);
    var weighted_mut_ptr_by_empty_checked_fill: [0]*RootItemWeights.Entry = .{};
    try fillChooseWeightedPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_mut_ptr_by_empty_checked_fill, &weighted_by_mut_invalid_items, RootItemWeights.invalid);
    var weighted_mut_ptr_by_zero_items = weighted_by_items;
    var weighted_mut_ptr_by_zero_fill: [3]?*RootItemWeights.Entry = undefined;
    try fillChooseWeightedPtrBy(RootItemWeights.Entry, f64, failing, &weighted_mut_ptr_by_zero_fill, &weighted_mut_ptr_by_zero_items, RootItemWeights.zero);
    for (weighted_mut_ptr_by_zero_fill) |ptr| try std.testing.expect(ptr == null);
    var weighted_mut_ptr_by_checked_fill: [3]*RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.EmptyInput, fillChooseWeightedPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_mut_ptr_by_checked_fill, &weighted_mut_ptr_by_zero_items, RootItemWeights.zero));
    var weighted_mut_ptr_by_single_items = weighted_by_items;
    try fillChooseWeightedPtrBy(RootItemWeights.Entry, f64, failing, &weighted_mut_ptr_by_zero_fill, &weighted_mut_ptr_by_single_items, RootItemWeights.single);
    for (weighted_mut_ptr_by_zero_fill) |ptr| try std.testing.expectEqual(&weighted_mut_ptr_by_single_items[1], ptr.?);
    weighted_mut_ptr_by_zero_fill[0].?.item = 77;
    try std.testing.expectEqual(@as(u8, 77), weighted_mut_ptr_by_single_items[1].item);
    var weighted_mut_ptr_by_single_checked_items = weighted_by_items;
    try fillChooseWeightedPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_mut_ptr_by_checked_fill, &weighted_mut_ptr_by_single_checked_items, RootItemWeights.single);
    for (weighted_mut_ptr_by_checked_fill) |ptr| try std.testing.expectEqual(&weighted_mut_ptr_by_single_checked_items[1], ptr);
    var weighted_mut_ptr_by_invalid_items = weighted_by_items;
    try std.testing.expectError(error.InvalidWeight, fillChooseWeightedPtrBy(RootItemWeights.Entry, f64, failing, &weighted_mut_ptr_by_zero_fill, &weighted_mut_ptr_by_invalid_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, fillChooseWeightedPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_mut_ptr_by_checked_fill, &weighted_mut_ptr_by_invalid_items, RootItemWeights.invalid));
    var empty_weighted_mut_ptr_by_batch_items: [0]RootItemWeights.Entry = .{};
    const empty_weighted_mut_ptr_by_batch = try chooseWeightedPtrBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 0, &empty_weighted_mut_ptr_by_batch_items, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_mut_ptr_by_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_mut_ptr_by_batch.len);
    const empty_weighted_mut_ptr_by_checked_batch = try chooseWeightedPtrBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 0, &weighted_mut_ptr_by_invalid_items, RootItemWeights.invalid);
    defer std.testing.allocator.free(empty_weighted_mut_ptr_by_checked_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_mut_ptr_by_checked_batch.len);
    var zero_weighted_mut_ptr_by_batch_items = weighted_by_items;
    const zero_weighted_mut_ptr_by_batch = try chooseWeightedPtrBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &zero_weighted_mut_ptr_by_batch_items, RootItemWeights.zero);
    defer std.testing.allocator.free(zero_weighted_mut_ptr_by_batch);
    for (zero_weighted_mut_ptr_by_batch) |ptr| try std.testing.expect(ptr == null);
    try std.testing.expectError(error.EmptyInput, chooseWeightedPtrBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &zero_weighted_mut_ptr_by_batch_items, RootItemWeights.zero));
    var weighted_mut_ptr_by_checked_empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, chooseWeightedPtrBatchByChecked(RootItemWeights.Entry, f64, failing, weighted_mut_ptr_by_checked_empty_alloc.allocator(), 3, &zero_weighted_mut_ptr_by_batch_items, RootItemWeights.zero));
    var single_weighted_mut_ptr_by_batch_items = weighted_by_items;
    const single_weighted_mut_ptr_by_batch = try chooseWeightedPtrBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &single_weighted_mut_ptr_by_batch_items, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_mut_ptr_by_batch);
    for (single_weighted_mut_ptr_by_batch) |ptr| try std.testing.expectEqual(&single_weighted_mut_ptr_by_batch_items[1], ptr.?);
    single_weighted_mut_ptr_by_batch[0].?.item = 66;
    try std.testing.expectEqual(@as(u8, 66), single_weighted_mut_ptr_by_batch_items[1].item);
    var single_weighted_mut_ptr_by_checked_batch_items = weighted_by_items;
    const single_weighted_mut_ptr_by_checked_batch = try chooseWeightedPtrBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &single_weighted_mut_ptr_by_checked_batch_items, RootItemWeights.single);
    defer std.testing.allocator.free(single_weighted_mut_ptr_by_checked_batch);
    for (single_weighted_mut_ptr_by_checked_batch) |ptr| try std.testing.expectEqual(&single_weighted_mut_ptr_by_checked_batch_items[1], ptr);
    var invalid_weighted_mut_ptr_by_batch_items = weighted_by_items;
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &invalid_weighted_mut_ptr_by_batch_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 3, &invalid_weighted_mut_ptr_by_batch_items, RootItemWeights.invalid));
    var weighted_mut_ptr_by_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatchBy(RootItemWeights.Entry, f64, failing, weighted_mut_ptr_by_invalid_alloc.allocator(), 3, &invalid_weighted_mut_ptr_by_batch_items, RootItemWeights.invalid));
    var weighted_mut_ptr_by_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatchByChecked(RootItemWeights.Entry, f64, failing, weighted_mut_ptr_by_checked_invalid_alloc.allocator(), 3, &invalid_weighted_mut_ptr_by_batch_items, RootItemWeights.invalid));
    var empty_weighted_mut_ptr_by_array_items: [0]RootItemWeights.Entry = .{};
    try std.testing.expectEqual(@as(usize, 0), (try chooseWeightedPtrArrayBy(RootItemWeights.Entry, f64, failing, 0, &empty_weighted_mut_ptr_by_array_items, RootItemWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try chooseWeightedPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 0, &invalid_weighted_mut_ptr_by_batch_items, RootItemWeights.invalid)).len);
    var zero_weighted_mut_ptr_by_array_items = weighted_by_items;
    try std.testing.expectEqual(@as(?[3]*RootItemWeights.Entry, null), try chooseWeightedPtrArrayBy(RootItemWeights.Entry, f64, failing, 3, &zero_weighted_mut_ptr_by_array_items, RootItemWeights.zero));
    try std.testing.expectError(error.EmptyInput, chooseWeightedPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &zero_weighted_mut_ptr_by_array_items, RootItemWeights.zero));
    var single_weighted_mut_ptr_by_array_items = weighted_by_items;
    const single_weighted_mut_ptr_by_array = (try chooseWeightedPtrArrayBy(RootItemWeights.Entry, f64, failing, 3, &single_weighted_mut_ptr_by_array_items, RootItemWeights.single)).?;
    for (single_weighted_mut_ptr_by_array) |ptr| try std.testing.expectEqual(&single_weighted_mut_ptr_by_array_items[1], ptr);
    single_weighted_mut_ptr_by_array[0].item = 55;
    try std.testing.expectEqual(@as(u8, 55), single_weighted_mut_ptr_by_array_items[1].item);
    var single_weighted_mut_ptr_by_checked_array_items = weighted_by_items;
    for (try chooseWeightedPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &single_weighted_mut_ptr_by_checked_array_items, RootItemWeights.single)) |ptr| try std.testing.expectEqual(&single_weighted_mut_ptr_by_checked_array_items[1], ptr);
    var invalid_weighted_mut_ptr_by_array_items = weighted_by_items;
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrArrayBy(RootItemWeights.Entry, f64, failing, 3, &invalid_weighted_mut_ptr_by_array_items, RootItemWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 3, &invalid_weighted_mut_ptr_by_array_items, RootItemWeights.invalid));
    const weighted_by_index_items = [_]u8{ 10, 20, 30 };
    try std.testing.expectEqual(@as(?u8, null), try chooseWeightedByIndex(u8, f64, failing, &.{}, RootByIndexWeights.single));
    try std.testing.expectEqual(@as(?u8, null), try chooseWeightedByIndex(u8, f64, failing, &weighted_by_index_items, RootByIndexWeights.zero));
    try std.testing.expectError(error.EmptyInput, chooseWeightedByIndexChecked(u8, f64, failing, &weighted_by_index_items, RootByIndexWeights.zero));
    try std.testing.expectEqual(@as(?u8, 20), try chooseWeightedByIndex(u8, f64, failing, &weighted_by_index_items, RootByIndexWeights.single));
    try std.testing.expectEqual(@as(u8, 20), try chooseWeightedByIndexChecked(u8, f64, failing, &weighted_by_index_items, RootByIndexWeights.single));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedByIndex(u8, f64, failing, &weighted_by_index_items, RootByIndexWeights.invalid));
    var weighted_by_index_empty_fill: [0]?u8 = .{};
    try fillChooseWeightedByIndex(u8, f64, failing, &weighted_by_index_empty_fill, &weighted_by_index_items, RootByIndexWeights.invalid);
    var weighted_by_index_empty_checked_fill: [0]u8 = .{};
    try fillChooseWeightedByIndexChecked(u8, f64, failing, &weighted_by_index_empty_checked_fill, &weighted_by_index_items, RootByIndexWeights.invalid);
    var weighted_by_index_zero_fill: [3]?u8 = undefined;
    try fillChooseWeightedByIndex(u8, f64, failing, &weighted_by_index_zero_fill, &weighted_by_index_items, RootByIndexWeights.zero);
    try std.testing.expectEqualSlices(?u8, &.{ null, null, null }, &weighted_by_index_zero_fill);
    var weighted_by_index_checked_fill: [3]u8 = undefined;
    try std.testing.expectError(error.EmptyInput, fillChooseWeightedByIndexChecked(u8, f64, failing, &weighted_by_index_checked_fill, &weighted_by_index_items, RootByIndexWeights.zero));
    try fillChooseWeightedByIndex(u8, f64, failing, &weighted_by_index_zero_fill, &weighted_by_index_items, RootByIndexWeights.single);
    try std.testing.expectEqualSlices(?u8, &.{ 20, 20, 20 }, &weighted_by_index_zero_fill);
    try fillChooseWeightedByIndexChecked(u8, f64, failing, &weighted_by_index_checked_fill, &weighted_by_index_items, RootByIndexWeights.single);
    try std.testing.expectEqualSlices(u8, &.{ 20, 20, 20 }, &weighted_by_index_checked_fill);
    try std.testing.expectError(error.InvalidWeight, fillChooseWeightedByIndex(u8, f64, failing, &weighted_by_index_zero_fill, &weighted_by_index_items, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, fillChooseWeightedByIndexChecked(u8, f64, failing, &weighted_by_index_checked_fill, &weighted_by_index_items, RootByIndexWeights.invalid));
    const weighted_by_index_empty_batch = try chooseWeightedBatchByIndex(u8, f64, failing, std.testing.allocator, 0, &weighted_by_index_items, RootByIndexWeights.invalid);
    defer std.testing.allocator.free(weighted_by_index_empty_batch);
    try std.testing.expectEqual(@as(usize, 0), weighted_by_index_empty_batch.len);
    const weighted_by_index_empty_checked_batch = try chooseWeightedBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 0, &weighted_by_index_items, RootByIndexWeights.invalid);
    defer std.testing.allocator.free(weighted_by_index_empty_checked_batch);
    try std.testing.expectEqual(@as(usize, 0), weighted_by_index_empty_checked_batch.len);
    const weighted_by_index_zero_batch = try chooseWeightedBatchByIndex(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_items, RootByIndexWeights.zero);
    defer std.testing.allocator.free(weighted_by_index_zero_batch);
    try std.testing.expectEqualSlices(?u8, &.{ null, null, null }, weighted_by_index_zero_batch);
    try std.testing.expectError(error.EmptyInput, chooseWeightedBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_items, RootByIndexWeights.zero));
    var weighted_by_index_checked_empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, chooseWeightedBatchByIndexChecked(u8, f64, failing, weighted_by_index_checked_empty_alloc.allocator(), 3, &weighted_by_index_items, RootByIndexWeights.zero));
    const weighted_by_index_single_batch = try chooseWeightedBatchByIndex(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_items, RootByIndexWeights.single);
    defer std.testing.allocator.free(weighted_by_index_single_batch);
    try std.testing.expectEqualSlices(?u8, &.{ 20, 20, 20 }, weighted_by_index_single_batch);
    const weighted_by_index_single_checked_batch = try chooseWeightedBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_items, RootByIndexWeights.single);
    defer std.testing.allocator.free(weighted_by_index_single_checked_batch);
    try std.testing.expectEqualSlices(u8, &.{ 20, 20, 20 }, weighted_by_index_single_checked_batch);
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatchByIndex(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_items, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_items, RootByIndexWeights.invalid));
    var weighted_by_index_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatchByIndex(u8, f64, failing, weighted_by_index_invalid_alloc.allocator(), 3, &weighted_by_index_items, RootByIndexWeights.invalid));
    var weighted_by_index_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatchByIndexChecked(u8, f64, failing, weighted_by_index_checked_invalid_alloc.allocator(), 3, &weighted_by_index_items, RootByIndexWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try chooseWeightedValueArrayByIndex(u8, f64, failing, 0, &weighted_by_index_items, RootByIndexWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try chooseWeightedValueArrayByIndexChecked(u8, f64, failing, 0, &weighted_by_index_items, RootByIndexWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[3]u8, null), try chooseWeightedValueArrayByIndex(u8, f64, failing, 3, &weighted_by_index_items, RootByIndexWeights.zero));
    try std.testing.expectError(error.EmptyInput, chooseWeightedValueArrayByIndexChecked(u8, f64, failing, 3, &weighted_by_index_items, RootByIndexWeights.zero));
    try std.testing.expectEqualSlices(u8, &.{ 20, 20, 20 }, &(try chooseWeightedValueArrayByIndex(u8, f64, failing, 3, &weighted_by_index_items, RootByIndexWeights.single)).?);
    try std.testing.expectEqualSlices(u8, &.{ 20, 20, 20 }, &(try chooseWeightedValueArrayByIndexChecked(u8, f64, failing, 3, &weighted_by_index_items, RootByIndexWeights.single)));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedValueArrayByIndex(u8, f64, failing, 3, &weighted_by_index_items, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedValueArrayByIndexChecked(u8, f64, failing, 3, &weighted_by_index_items, RootByIndexWeights.invalid));
    try std.testing.expectEqual(@as(?*const u8, null), try chooseWeightedConstPtrByIndex(u8, f64, failing, &.{}, RootByIndexWeights.single));
    try std.testing.expectEqual(@as(?*const u8, null), try chooseWeightedConstPtrByIndex(u8, f64, failing, &weighted_by_index_items, RootByIndexWeights.zero));
    try std.testing.expectError(error.EmptyInput, chooseWeightedConstPtrByIndexChecked(u8, f64, failing, &weighted_by_index_items, RootByIndexWeights.zero));
    try std.testing.expectEqual(&weighted_by_index_items[1], (try chooseWeightedConstPtrByIndex(u8, f64, failing, &weighted_by_index_items, RootByIndexWeights.single)).?);
    try std.testing.expectEqual(&weighted_by_index_items[1], try chooseWeightedConstPtrByIndexChecked(u8, f64, failing, &weighted_by_index_items, RootByIndexWeights.single));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrByIndexChecked(u8, f64, failing, &weighted_by_index_items, RootByIndexWeights.invalid));
    var weighted_const_ptr_by_index_empty_fill: [0]?*const u8 = .{};
    try fillChooseWeightedConstPtrByIndex(u8, f64, failing, &weighted_const_ptr_by_index_empty_fill, &weighted_by_index_items, RootByIndexWeights.invalid);
    var weighted_const_ptr_by_index_empty_checked_fill: [0]*const u8 = .{};
    try fillChooseWeightedConstPtrByIndexChecked(u8, f64, failing, &weighted_const_ptr_by_index_empty_checked_fill, &weighted_by_index_items, RootByIndexWeights.invalid);
    var weighted_const_ptr_by_index_zero_fill: [3]?*const u8 = undefined;
    try fillChooseWeightedConstPtrByIndex(u8, f64, failing, &weighted_const_ptr_by_index_zero_fill, &weighted_by_index_items, RootByIndexWeights.zero);
    try std.testing.expectEqual(@as(?*const u8, null), weighted_const_ptr_by_index_zero_fill[0]);
    try std.testing.expectEqual(@as(?*const u8, null), weighted_const_ptr_by_index_zero_fill[1]);
    try std.testing.expectEqual(@as(?*const u8, null), weighted_const_ptr_by_index_zero_fill[2]);
    var weighted_const_ptr_by_index_checked_fill: [3]*const u8 = undefined;
    try std.testing.expectError(error.EmptyInput, fillChooseWeightedConstPtrByIndexChecked(u8, f64, failing, &weighted_const_ptr_by_index_checked_fill, &weighted_by_index_items, RootByIndexWeights.zero));
    try fillChooseWeightedConstPtrByIndex(u8, f64, failing, &weighted_const_ptr_by_index_zero_fill, &weighted_by_index_items, RootByIndexWeights.single);
    for (weighted_const_ptr_by_index_zero_fill) |ptr| try std.testing.expectEqual(&weighted_by_index_items[1], ptr.?);
    try fillChooseWeightedConstPtrByIndexChecked(u8, f64, failing, &weighted_const_ptr_by_index_checked_fill, &weighted_by_index_items, RootByIndexWeights.single);
    for (weighted_const_ptr_by_index_checked_fill) |ptr| try std.testing.expectEqual(&weighted_by_index_items[1], ptr);
    try std.testing.expectError(error.InvalidWeight, fillChooseWeightedConstPtrByIndex(u8, f64, failing, &weighted_const_ptr_by_index_zero_fill, &weighted_by_index_items, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, fillChooseWeightedConstPtrByIndexChecked(u8, f64, failing, &weighted_const_ptr_by_index_checked_fill, &weighted_by_index_items, RootByIndexWeights.invalid));
    const weighted_const_ptr_by_index_empty_batch = try chooseWeightedConstPtrBatchByIndex(u8, f64, failing, std.testing.allocator, 0, &weighted_by_index_items, RootByIndexWeights.invalid);
    defer std.testing.allocator.free(weighted_const_ptr_by_index_empty_batch);
    try std.testing.expectEqual(@as(usize, 0), weighted_const_ptr_by_index_empty_batch.len);
    const weighted_const_ptr_by_index_empty_checked_batch = try chooseWeightedConstPtrBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 0, &weighted_by_index_items, RootByIndexWeights.invalid);
    defer std.testing.allocator.free(weighted_const_ptr_by_index_empty_checked_batch);
    try std.testing.expectEqual(@as(usize, 0), weighted_const_ptr_by_index_empty_checked_batch.len);
    const weighted_const_ptr_by_index_zero_batch = try chooseWeightedConstPtrBatchByIndex(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_items, RootByIndexWeights.zero);
    defer std.testing.allocator.free(weighted_const_ptr_by_index_zero_batch);
    try std.testing.expectEqual(@as(?*const u8, null), weighted_const_ptr_by_index_zero_batch[0]);
    try std.testing.expectEqual(@as(?*const u8, null), weighted_const_ptr_by_index_zero_batch[1]);
    try std.testing.expectEqual(@as(?*const u8, null), weighted_const_ptr_by_index_zero_batch[2]);
    try std.testing.expectError(error.EmptyInput, chooseWeightedConstPtrBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_items, RootByIndexWeights.zero));
    var weighted_const_ptr_by_index_checked_empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, chooseWeightedConstPtrBatchByIndexChecked(u8, f64, failing, weighted_const_ptr_by_index_checked_empty_alloc.allocator(), 3, &weighted_by_index_items, RootByIndexWeights.zero));
    const weighted_const_ptr_by_index_single_batch = try chooseWeightedConstPtrBatchByIndex(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_items, RootByIndexWeights.single);
    defer std.testing.allocator.free(weighted_const_ptr_by_index_single_batch);
    for (weighted_const_ptr_by_index_single_batch) |ptr| try std.testing.expectEqual(&weighted_by_index_items[1], ptr.?);
    const weighted_const_ptr_by_index_single_checked_batch = try chooseWeightedConstPtrBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_items, RootByIndexWeights.single);
    defer std.testing.allocator.free(weighted_const_ptr_by_index_single_checked_batch);
    for (weighted_const_ptr_by_index_single_checked_batch) |ptr| try std.testing.expectEqual(&weighted_by_index_items[1], ptr);
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatchByIndex(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_items, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_items, RootByIndexWeights.invalid));
    var weighted_const_ptr_by_index_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatchByIndex(u8, f64, failing, weighted_const_ptr_by_index_invalid_alloc.allocator(), 3, &weighted_by_index_items, RootByIndexWeights.invalid));
    var weighted_const_ptr_by_index_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatchByIndexChecked(u8, f64, failing, weighted_const_ptr_by_index_checked_invalid_alloc.allocator(), 3, &weighted_by_index_items, RootByIndexWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try chooseWeightedConstPtrArrayByIndex(u8, f64, failing, 0, &weighted_by_index_items, RootByIndexWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try chooseWeightedConstPtrArrayByIndexChecked(u8, f64, failing, 0, &weighted_by_index_items, RootByIndexWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[3]*const u8, null), try chooseWeightedConstPtrArrayByIndex(u8, f64, failing, 3, &weighted_by_index_items, RootByIndexWeights.zero));
    try std.testing.expectError(error.EmptyInput, chooseWeightedConstPtrArrayByIndexChecked(u8, f64, failing, 3, &weighted_by_index_items, RootByIndexWeights.zero));
    const weighted_const_ptr_by_index_single_array = (try chooseWeightedConstPtrArrayByIndex(u8, f64, failing, 3, &weighted_by_index_items, RootByIndexWeights.single)).?;
    for (weighted_const_ptr_by_index_single_array) |ptr| try std.testing.expectEqual(&weighted_by_index_items[1], ptr);
    const weighted_const_ptr_by_index_single_checked_array = try chooseWeightedConstPtrArrayByIndexChecked(u8, f64, failing, 3, &weighted_by_index_items, RootByIndexWeights.single);
    for (weighted_const_ptr_by_index_single_checked_array) |ptr| try std.testing.expectEqual(&weighted_by_index_items[1], ptr);
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrArrayByIndex(u8, f64, failing, 3, &weighted_by_index_items, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrArrayByIndexChecked(u8, f64, failing, 3, &weighted_by_index_items, RootByIndexWeights.invalid));
    var weighted_by_index_mut_items = weighted_by_index_items;
    var empty_weighted_by_index_mut_items: [0]u8 = .{};
    try std.testing.expectEqual(@as(?*u8, null), try chooseWeightedPtrByIndex(u8, f64, failing, &empty_weighted_by_index_mut_items, RootByIndexWeights.single));
    try std.testing.expectEqual(@as(?*u8, null), try chooseWeightedPtrByIndex(u8, f64, failing, &weighted_by_index_mut_items, RootByIndexWeights.zero));
    try std.testing.expectError(error.EmptyInput, chooseWeightedPtrByIndexChecked(u8, f64, failing, &weighted_by_index_mut_items, RootByIndexWeights.zero));
    const deterministic_weighted_mut_ptr_by_index = (try chooseWeightedPtrByIndex(u8, f64, failing, &weighted_by_index_mut_items, RootByIndexWeights.single)).?;
    try std.testing.expectEqual(&weighted_by_index_mut_items[1], deterministic_weighted_mut_ptr_by_index);
    deterministic_weighted_mut_ptr_by_index.* = 21;
    try std.testing.expectEqual(@as(u8, 21), weighted_by_index_mut_items[1]);
    weighted_by_index_mut_items[1] = 20;
    try std.testing.expectEqual(&weighted_by_index_mut_items[1], try chooseWeightedPtrByIndexChecked(u8, f64, failing, &weighted_by_index_mut_items, RootByIndexWeights.single));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrByIndex(u8, f64, failing, &weighted_by_index_mut_items, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrByIndexChecked(u8, f64, failing, &weighted_by_index_mut_items, RootByIndexWeights.invalid));
    var weighted_mut_ptr_by_index_empty_fill: [0]?*u8 = .{};
    try fillChooseWeightedPtrByIndex(u8, f64, failing, &weighted_mut_ptr_by_index_empty_fill, &weighted_by_index_mut_items, RootByIndexWeights.invalid);
    var weighted_mut_ptr_by_index_empty_checked_fill: [0]*u8 = .{};
    try fillChooseWeightedPtrByIndexChecked(u8, f64, failing, &weighted_mut_ptr_by_index_empty_checked_fill, &weighted_by_index_mut_items, RootByIndexWeights.invalid);
    var weighted_mut_ptr_by_index_zero_fill: [3]?*u8 = undefined;
    try fillChooseWeightedPtrByIndex(u8, f64, failing, &weighted_mut_ptr_by_index_zero_fill, &weighted_by_index_mut_items, RootByIndexWeights.zero);
    try std.testing.expectEqual(@as(?*u8, null), weighted_mut_ptr_by_index_zero_fill[0]);
    try std.testing.expectEqual(@as(?*u8, null), weighted_mut_ptr_by_index_zero_fill[1]);
    try std.testing.expectEqual(@as(?*u8, null), weighted_mut_ptr_by_index_zero_fill[2]);
    var weighted_mut_ptr_by_index_checked_fill: [3]*u8 = undefined;
    try std.testing.expectError(error.EmptyInput, fillChooseWeightedPtrByIndexChecked(u8, f64, failing, &weighted_mut_ptr_by_index_checked_fill, &weighted_by_index_mut_items, RootByIndexWeights.zero));
    try fillChooseWeightedPtrByIndex(u8, f64, failing, &weighted_mut_ptr_by_index_zero_fill, &weighted_by_index_mut_items, RootByIndexWeights.single);
    for (weighted_mut_ptr_by_index_zero_fill) |ptr| try std.testing.expectEqual(&weighted_by_index_mut_items[1], ptr.?);
    weighted_mut_ptr_by_index_zero_fill[0].?.* = 22;
    try std.testing.expectEqual(@as(u8, 22), weighted_by_index_mut_items[1]);
    weighted_by_index_mut_items[1] = 20;
    try fillChooseWeightedPtrByIndexChecked(u8, f64, failing, &weighted_mut_ptr_by_index_checked_fill, &weighted_by_index_mut_items, RootByIndexWeights.single);
    for (weighted_mut_ptr_by_index_checked_fill) |ptr| try std.testing.expectEqual(&weighted_by_index_mut_items[1], ptr);
    try std.testing.expectError(error.InvalidWeight, fillChooseWeightedPtrByIndex(u8, f64, failing, &weighted_mut_ptr_by_index_zero_fill, &weighted_by_index_mut_items, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, fillChooseWeightedPtrByIndexChecked(u8, f64, failing, &weighted_mut_ptr_by_index_checked_fill, &weighted_by_index_mut_items, RootByIndexWeights.invalid));
    const weighted_mut_ptr_by_index_empty_batch = try chooseWeightedPtrBatchByIndex(u8, f64, failing, std.testing.allocator, 0, &weighted_by_index_mut_items, RootByIndexWeights.invalid);
    defer std.testing.allocator.free(weighted_mut_ptr_by_index_empty_batch);
    try std.testing.expectEqual(@as(usize, 0), weighted_mut_ptr_by_index_empty_batch.len);
    const weighted_mut_ptr_by_index_empty_checked_batch = try chooseWeightedPtrBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 0, &weighted_by_index_mut_items, RootByIndexWeights.invalid);
    defer std.testing.allocator.free(weighted_mut_ptr_by_index_empty_checked_batch);
    try std.testing.expectEqual(@as(usize, 0), weighted_mut_ptr_by_index_empty_checked_batch.len);
    const weighted_mut_ptr_by_index_zero_batch = try chooseWeightedPtrBatchByIndex(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_mut_items, RootByIndexWeights.zero);
    defer std.testing.allocator.free(weighted_mut_ptr_by_index_zero_batch);
    try std.testing.expectEqual(@as(?*u8, null), weighted_mut_ptr_by_index_zero_batch[0]);
    try std.testing.expectEqual(@as(?*u8, null), weighted_mut_ptr_by_index_zero_batch[1]);
    try std.testing.expectEqual(@as(?*u8, null), weighted_mut_ptr_by_index_zero_batch[2]);
    try std.testing.expectError(error.EmptyInput, chooseWeightedPtrBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_mut_items, RootByIndexWeights.zero));
    var weighted_mut_ptr_by_index_checked_empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyInput, chooseWeightedPtrBatchByIndexChecked(u8, f64, failing, weighted_mut_ptr_by_index_checked_empty_alloc.allocator(), 3, &weighted_by_index_mut_items, RootByIndexWeights.zero));
    const weighted_mut_ptr_by_index_single_batch = try chooseWeightedPtrBatchByIndex(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_mut_items, RootByIndexWeights.single);
    defer std.testing.allocator.free(weighted_mut_ptr_by_index_single_batch);
    for (weighted_mut_ptr_by_index_single_batch) |ptr| try std.testing.expectEqual(&weighted_by_index_mut_items[1], ptr.?);
    weighted_mut_ptr_by_index_single_batch[0].?.* = 23;
    try std.testing.expectEqual(@as(u8, 23), weighted_by_index_mut_items[1]);
    weighted_by_index_mut_items[1] = 20;
    const weighted_mut_ptr_by_index_single_checked_batch = try chooseWeightedPtrBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_mut_items, RootByIndexWeights.single);
    defer std.testing.allocator.free(weighted_mut_ptr_by_index_single_checked_batch);
    for (weighted_mut_ptr_by_index_single_checked_batch) |ptr| try std.testing.expectEqual(&weighted_by_index_mut_items[1], ptr);
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatchByIndex(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_mut_items, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 3, &weighted_by_index_mut_items, RootByIndexWeights.invalid));
    var weighted_mut_ptr_by_index_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatchByIndex(u8, f64, failing, weighted_mut_ptr_by_index_invalid_alloc.allocator(), 3, &weighted_by_index_mut_items, RootByIndexWeights.invalid));
    var weighted_mut_ptr_by_index_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatchByIndexChecked(u8, f64, failing, weighted_mut_ptr_by_index_checked_invalid_alloc.allocator(), 3, &weighted_by_index_mut_items, RootByIndexWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try chooseWeightedPtrArrayByIndex(u8, f64, failing, 0, &weighted_by_index_mut_items, RootByIndexWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try chooseWeightedPtrArrayByIndexChecked(u8, f64, failing, 0, &weighted_by_index_mut_items, RootByIndexWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[3]*u8, null), try chooseWeightedPtrArrayByIndex(u8, f64, failing, 3, &weighted_by_index_mut_items, RootByIndexWeights.zero));
    try std.testing.expectError(error.EmptyInput, chooseWeightedPtrArrayByIndexChecked(u8, f64, failing, 3, &weighted_by_index_mut_items, RootByIndexWeights.zero));
    const weighted_mut_ptr_by_index_single_array = (try chooseWeightedPtrArrayByIndex(u8, f64, failing, 3, &weighted_by_index_mut_items, RootByIndexWeights.single)).?;
    for (weighted_mut_ptr_by_index_single_array) |ptr| try std.testing.expectEqual(&weighted_by_index_mut_items[1], ptr);
    weighted_mut_ptr_by_index_single_array[0].* = 24;
    try std.testing.expectEqual(@as(u8, 24), weighted_by_index_mut_items[1]);
    weighted_by_index_mut_items[1] = 20;
    const weighted_mut_ptr_by_index_single_checked_array = try chooseWeightedPtrArrayByIndexChecked(u8, f64, failing, 3, &weighted_by_index_mut_items, RootByIndexWeights.single);
    for (weighted_mut_ptr_by_index_single_checked_array) |ptr| try std.testing.expectEqual(&weighted_by_index_mut_items[1], ptr);
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrArrayByIndex(u8, f64, failing, 3, &weighted_by_index_mut_items, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrArrayByIndexChecked(u8, f64, failing, 3, &weighted_by_index_mut_items, RootByIndexWeights.invalid));
    var by_index_empty: [0]?usize = .{};
    try fillWeightedIndexByIndex(f64, failing, &by_index_empty, 3, RootByIndexWeights.invalid);
    var by_index_empty_checked: [0]usize = .{};
    try fillWeightedIndexByIndexChecked(f64, failing, &by_index_empty_checked, 3, RootByIndexWeights.invalid);
    var by_index_zero: [3]?usize = undefined;
    try fillWeightedIndexByIndex(f64, failing, &by_index_zero, 3, RootByIndexWeights.zero);
    try std.testing.expectEqualSlices(?usize, &.{ null, null, null }, &by_index_zero);
    var by_index_checked: [3]usize = undefined;
    try std.testing.expectError(error.EmptyInput, fillWeightedIndexByIndexChecked(f64, failing, &by_index_checked, 3, RootByIndexWeights.zero));
    try fillWeightedIndexByIndex(f64, failing, &by_index_zero, 3, RootByIndexWeights.single);
    try std.testing.expectEqualSlices(?usize, &.{ 1, 1, 1 }, &by_index_zero);
    try fillWeightedIndexByIndexChecked(f64, failing, &by_index_checked, 3, RootByIndexWeights.single);
    try std.testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, &by_index_checked);
    try std.testing.expectError(error.InvalidWeight, fillWeightedIndexByIndex(f64, failing, &by_index_zero, 3, RootByIndexWeights.invalid));
    var by_index_u32_zero: [3]?u32 = undefined;
    try fillWeightedIndexU32ByIndex(f64, failing, &by_index_u32_zero, 3, RootByIndexWeights.zero);
    try std.testing.expectEqualSlices(?u32, &.{ null, null, null }, &by_index_u32_zero);
    var by_index_u32_checked: [3]u32 = undefined;
    try std.testing.expectError(error.EmptyInput, fillWeightedIndexU32ByIndexChecked(f64, failing, &by_index_u32_checked, 3, RootByIndexWeights.zero));
    try fillWeightedIndexU32ByIndex(f64, failing, &by_index_u32_zero, 3, RootByIndexWeights.single);
    try std.testing.expectEqualSlices(?u32, &.{ 1, 1, 1 }, &by_index_u32_zero);
    try fillWeightedIndexU32ByIndexChecked(f64, failing, &by_index_u32_checked, 3, RootByIndexWeights.single);
    try std.testing.expectEqualSlices(u32, &.{ 1, 1, 1 }, &by_index_u32_checked);
    try std.testing.expectError(error.InvalidWeight, fillWeightedIndexU32ByIndex(f64, failing, &by_index_u32_zero, 3, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidParameter, fillWeightedIndexU32ByIndex(f64, failing, &by_index_u32_zero, @as(usize, std.math.maxInt(u32)) + 1, RootByIndexWeights.single));
    const empty_by_index_batch = try weightedIndexBatchByIndex(f64, failing, std.testing.allocator, 0, 3, RootByIndexWeights.invalid);
    defer std.testing.allocator.free(empty_by_index_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_by_index_batch.len);
    const empty_by_index_batch_checked = try weightedIndexBatchByIndexChecked(f64, failing, std.testing.allocator, 0, 3, RootByIndexWeights.invalid);
    defer std.testing.allocator.free(empty_by_index_batch_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_by_index_batch_checked.len);
    const by_index_zero_batch = try weightedIndexBatchByIndex(f64, failing, std.testing.allocator, 3, 3, RootByIndexWeights.zero);
    defer std.testing.allocator.free(by_index_zero_batch);
    try std.testing.expectEqualSlices(?usize, &.{ null, null, null }, by_index_zero_batch);
    try std.testing.expectError(error.EmptyInput, weightedIndexBatchByIndexChecked(f64, failing, std.testing.allocator, 3, 3, RootByIndexWeights.zero));
    const by_index_single_batch = try weightedIndexBatchByIndex(f64, failing, std.testing.allocator, 3, 3, RootByIndexWeights.single);
    defer std.testing.allocator.free(by_index_single_batch);
    try std.testing.expectEqualSlices(?usize, &.{ 1, 1, 1 }, by_index_single_batch);
    const by_index_single_batch_checked = try weightedIndexBatchByIndexChecked(f64, failing, std.testing.allocator, 3, 3, RootByIndexWeights.single);
    defer std.testing.allocator.free(by_index_single_batch_checked);
    try std.testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, by_index_single_batch_checked);
    try std.testing.expectError(error.InvalidWeight, weightedIndexBatchByIndex(f64, failing, std.testing.allocator, 3, 3, RootByIndexWeights.invalid));
    const empty_by_index_u32_batch = try weightedIndexU32BatchByIndex(f64, failing, std.testing.allocator, 0, 3, RootByIndexWeights.invalid);
    defer std.testing.allocator.free(empty_by_index_u32_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_by_index_u32_batch.len);
    const empty_by_index_u32_batch_checked = try weightedIndexU32BatchByIndexChecked(f64, failing, std.testing.allocator, 0, 3, RootByIndexWeights.invalid);
    defer std.testing.allocator.free(empty_by_index_u32_batch_checked);
    try std.testing.expectEqual(@as(usize, 0), empty_by_index_u32_batch_checked.len);
    const by_index_u32_zero_batch = try weightedIndexU32BatchByIndex(f64, failing, std.testing.allocator, 3, 3, RootByIndexWeights.zero);
    defer std.testing.allocator.free(by_index_u32_zero_batch);
    try std.testing.expectEqualSlices(?u32, &.{ null, null, null }, by_index_u32_zero_batch);
    try std.testing.expectError(error.EmptyInput, weightedIndexU32BatchByIndexChecked(f64, failing, std.testing.allocator, 3, 3, RootByIndexWeights.zero));
    const by_index_u32_single_batch = try weightedIndexU32BatchByIndex(f64, failing, std.testing.allocator, 3, 3, RootByIndexWeights.single);
    defer std.testing.allocator.free(by_index_u32_single_batch);
    try std.testing.expectEqualSlices(?u32, &.{ 1, 1, 1 }, by_index_u32_single_batch);
    const by_index_u32_single_batch_checked = try weightedIndexU32BatchByIndexChecked(f64, failing, std.testing.allocator, 3, 3, RootByIndexWeights.single);
    defer std.testing.allocator.free(by_index_u32_single_batch_checked);
    try std.testing.expectEqualSlices(u32, &.{ 1, 1, 1 }, by_index_u32_single_batch_checked);
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32BatchByIndexChecked(f64, failing, std.testing.allocator, 3, 3, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidParameter, weightedIndexU32BatchByIndex(f64, failing, std.testing.allocator, 3, @as(usize, std.math.maxInt(u32)) + 1, RootByIndexWeights.single));
    try std.testing.expectEqual(@as(usize, 0), (try weightedIndexArrayByIndex(f64, failing, 0, 3, RootByIndexWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try weightedIndexArrayByIndexChecked(f64, failing, 0, 3, RootByIndexWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[3]usize, null), try weightedIndexArrayByIndex(f64, failing, 3, 3, RootByIndexWeights.zero));
    try std.testing.expectError(error.EmptyInput, weightedIndexArrayByIndexChecked(f64, failing, 3, 3, RootByIndexWeights.zero));
    try std.testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, &(try weightedIndexArrayByIndex(f64, failing, 3, 3, RootByIndexWeights.single)).?);
    try std.testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, &(try weightedIndexArrayByIndexChecked(f64, failing, 3, 3, RootByIndexWeights.single)));
    try std.testing.expectError(error.InvalidWeight, weightedIndexArrayByIndex(f64, failing, 3, 3, RootByIndexWeights.invalid));
    try std.testing.expectEqual(@as(usize, 0), (try weightedIndexU32ArrayByIndex(f64, failing, 0, 3, RootByIndexWeights.invalid)).?.len);
    try std.testing.expectEqual(@as(usize, 0), (try weightedIndexU32ArrayByIndexChecked(f64, failing, 0, 3, RootByIndexWeights.invalid)).len);
    try std.testing.expectEqual(@as(?[3]u32, null), try weightedIndexU32ArrayByIndex(f64, failing, 3, 3, RootByIndexWeights.zero));
    try std.testing.expectError(error.EmptyInput, weightedIndexU32ArrayByIndexChecked(f64, failing, 3, 3, RootByIndexWeights.zero));
    try std.testing.expectEqualSlices(u32, &.{ 1, 1, 1 }, &(try weightedIndexU32ArrayByIndex(f64, failing, 3, 3, RootByIndexWeights.single)).?);
    try std.testing.expectEqualSlices(u32, &.{ 1, 1, 1 }, &(try weightedIndexU32ArrayByIndexChecked(f64, failing, 3, 3, RootByIndexWeights.single)));
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32ArrayByIndexChecked(f64, failing, 3, 3, RootByIndexWeights.invalid));
    try std.testing.expectError(error.InvalidParameter, weightedIndexU32ArrayByIndex(f64, failing, 3, @as(usize, std.math.maxInt(u32)) + 1, RootByIndexWeights.single));
    try std.testing.expectEqual(@as(?u32, null), try weightedIndexU32(failing, &empty_weights));
    try std.testing.expectEqual(@as(?u32, null), try weightedIndexU32Checked(failing, &empty_weights));
    var empty_weighted_u32_fill: [3]?u32 = undefined;
    try fillWeightedIndexU32(failing, &empty_weighted_u32_fill, &empty_weights);
    try std.testing.expectEqualSlices(?u32, &.{ null, null, null }, &empty_weighted_u32_fill);
    const empty_weighted_u32_batch = try weightedIndexU32Batch(failing, std.testing.allocator, 3, &empty_weights);
    defer std.testing.allocator.free(empty_weighted_u32_batch);
    try std.testing.expectEqualSlices(?u32, &.{ null, null, null }, empty_weighted_u32_batch);
    try std.testing.expect((try weightedIndexU32Array(failing, 0, &empty_weights)) != null);
    try std.testing.expectEqual(@as(?[3]u32, null), try weightedIndexU32Array(failing, 3, &empty_weights));
    var empty_weighted_u32_checked_fill: [0]u32 = .{};
    try fillWeightedIndexU32Checked(failing, &empty_weighted_u32_checked_fill, &empty_weights);
    try std.testing.expectEqual(@as(usize, 0), (try weightedIndexU32ArrayChecked(failing, 0, &empty_weights)).len);
    try std.testing.expectError(error.EmptyRange, weightedIndexU32ArrayChecked(failing, 3, &empty_weights));
    const empty_weighted_u32_checked_batch = try weightedIndexU32BatchChecked(failing, std.testing.allocator, 0, &empty_weights);
    defer std.testing.allocator.free(empty_weighted_u32_checked_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_u32_checked_batch.len);
    try std.testing.expectError(error.EmptyRange, weightedIndexU32BatchChecked(failing, std.testing.allocator, 3, &empty_weights));
    var weighted_u32_invalid_fill: [1]?u32 = undefined;
    try std.testing.expectError(error.InvalidWeight, fillWeightedIndexU32(failing, &weighted_u32_invalid_fill, &.{ -1, 2 }));
    var weighted_u32_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32Batch(failing, weighted_u32_invalid_alloc.allocator(), 3, &.{ std.math.nan(f64), 1 }));
    var weighted_u32_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32BatchChecked(failing, weighted_u32_checked_invalid_alloc.allocator(), 3, &.{ std.math.nan(f64), 1 }));
    const empty_weighted_u32_invalid_batch = try weightedIndexU32Batch(failing, std.testing.allocator, 0, &.{ std.math.nan(f64), 1 });
    defer std.testing.allocator.free(empty_weighted_u32_invalid_batch);
    try std.testing.expectEqual(@as(usize, 0), empty_weighted_u32_invalid_batch.len);
    try std.testing.expectEqual(@as(?u32, 1), try weightedIndexU32(failing, &single_weight));
    try std.testing.expectEqual(@as(?u32, 1), try weightedIndexU32Checked(failing, &single_weight));
    try fillWeightedIndexU32(failing, &empty_weighted_u32_fill, &single_weight);
    try std.testing.expectEqualSlices(?u32, &.{ 1, 1, 1 }, &empty_weighted_u32_fill);
    var single_weight_u32_checked_fill: [3]u32 = undefined;
    try fillWeightedIndexU32Checked(failing, &single_weight_u32_checked_fill, &single_weight);
    try std.testing.expectEqualSlices(u32, &.{ 1, 1, 1 }, &single_weight_u32_checked_fill);
    const single_weight_u32_batch = try weightedIndexU32Batch(failing, std.testing.allocator, 3, &single_weight);
    defer std.testing.allocator.free(single_weight_u32_batch);
    try std.testing.expectEqualSlices(?u32, &.{ 1, 1, 1 }, single_weight_u32_batch);
    const single_weight_u32_checked_batch = try weightedIndexU32BatchChecked(failing, std.testing.allocator, 3, &single_weight);
    defer std.testing.allocator.free(single_weight_u32_checked_batch);
    try std.testing.expectEqualSlices(u32, &.{ 1, 1, 1 }, single_weight_u32_checked_batch);
    try std.testing.expectEqualSlices(u32, &.{ 1, 1, 1 }, &(try weightedIndexU32Array(failing, 3, &single_weight)).?);
    try std.testing.expectEqualSlices(u32, &.{ 1, 1, 1 }, &(try weightedIndexU32ArrayChecked(failing, 3, &single_weight)));
    try std.testing.expectError(error.InvalidWeight, weightedIndexU32Checked(failing, &.{ 1, std.math.nan(f64) }));
    try std.testing.expectError(error.InvalidWeight, fillWeightedIndexU32Checked(failing, &single_weight_u32_checked_fill, &.{ -1, 2 }));
    try std.testing.expectError(error.InvalidWeight, weightedIndexChecked(failing, &.{ 1, std.math.nan(f64) }));
    try std.testing.expectError(error.InvalidWeight, fillWeightedIndexChecked(failing, &single_weight_checked_fill, &.{ -1, 2 }));
    const weighted_single_items = [_]u8{ 10, 20, 30 };
    try std.testing.expectEqual(@as(?u8, null), try chooseWeighted(u8, failing, &weighted_single_items, &empty_weights));
    try std.testing.expectEqual(@as(?[3]u8, null), try chooseWeightedValueArray(u8, failing, 3, &weighted_single_items, &empty_weights));
    var empty_weighted_choice_fill: [3]?u8 = undefined;
    try fillChooseWeighted(u8, failing, &empty_weighted_choice_fill, &weighted_single_items, &empty_weights);
    try std.testing.expectEqualSlices(?u8, &.{ null, null, null }, &empty_weighted_choice_fill);
    const empty_weighted_choice_batch = try chooseWeightedBatch(u8, failing, std.testing.allocator, 3, &weighted_single_items, &empty_weights);
    defer std.testing.allocator.free(empty_weighted_choice_batch);
    try std.testing.expectEqualSlices(?u8, &.{ null, null, null }, empty_weighted_choice_batch);
    var weighted_choice_mismatch_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, chooseWeightedBatch(u8, failing, weighted_choice_mismatch_alloc.allocator(), 3, &.{ 1, 2 }, &.{1}));
    var weighted_choice_checked_mismatch_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, chooseWeightedBatchChecked(u8, failing, weighted_choice_checked_mismatch_alloc.allocator(), 3, &.{ 1, 2 }, &.{1}));
    var weighted_choice_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatch(u8, failing, weighted_choice_invalid_alloc.allocator(), 3, &weighted_single_items, &.{ std.math.nan(f64), 1, 1 }));
    var weighted_choice_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedBatchChecked(u8, failing, weighted_choice_checked_invalid_alloc.allocator(), 3, &weighted_single_items, &.{ std.math.nan(f64), 1, 1 }));
    try std.testing.expectError(error.EmptyRange, chooseWeightedChecked(u8, failing, &weighted_single_items, &empty_weights));
    var weighted_choice_checked_empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, chooseWeightedBatchChecked(u8, failing, weighted_choice_checked_empty_alloc.allocator(), 3, &weighted_single_items, &empty_weights));
    try std.testing.expectError(error.EmptyRange, chooseWeightedValueArrayChecked(u8, failing, 3, &weighted_single_items, &empty_weights));
    try std.testing.expectEqual(@as(?u8, 20), try chooseWeighted(u8, failing, &weighted_single_items, &single_weight));
    try std.testing.expectEqual(@as(u8, 20), try chooseWeightedChecked(u8, failing, &weighted_single_items, &single_weight));
    try fillChooseWeighted(u8, failing, &empty_weighted_choice_fill, &weighted_single_items, &single_weight);
    try std.testing.expectEqualSlices(?u8, &.{ 20, 20, 20 }, &empty_weighted_choice_fill);
    var single_weighted_choice_checked_fill: [3]u8 = undefined;
    try fillChooseWeightedChecked(u8, failing, &single_weighted_choice_checked_fill, &weighted_single_items, &single_weight);
    try std.testing.expectEqualSlices(u8, &.{ 20, 20, 20 }, &single_weighted_choice_checked_fill);
    const single_weighted_choice_batch = try chooseWeightedBatch(u8, failing, std.testing.allocator, 3, &weighted_single_items, &single_weight);
    defer std.testing.allocator.free(single_weighted_choice_batch);
    try std.testing.expectEqualSlices(?u8, &.{ 20, 20, 20 }, single_weighted_choice_batch);
    const single_weighted_choice_checked_batch = try chooseWeightedBatchChecked(u8, failing, std.testing.allocator, 3, &weighted_single_items, &single_weight);
    defer std.testing.allocator.free(single_weighted_choice_checked_batch);
    try std.testing.expectEqualSlices(u8, &.{ 20, 20, 20 }, single_weighted_choice_checked_batch);
    try std.testing.expectEqualSlices(u8, &.{ 20, 20, 20 }, &(try chooseWeightedValueArray(u8, failing, 3, &weighted_single_items, &single_weight)).?);
    try std.testing.expectEqualSlices(u8, &.{ 20, 20, 20 }, &(try chooseWeightedValueArrayChecked(u8, failing, 3, &weighted_single_items, &single_weight)));
    try std.testing.expectEqual(@as(?*const u8, null), try chooseWeightedConstPtr(u8, failing, &weighted_single_items, &empty_weights));
    try std.testing.expectEqual(@as(?[3]*const u8, null), try chooseWeightedConstPtrArray(u8, failing, 3, &weighted_single_items, &empty_weights));
    var empty_weighted_const_ptr_fill: [3]?*const u8 = undefined;
    try fillChooseWeightedConstPtr(u8, failing, &empty_weighted_const_ptr_fill, &weighted_single_items, &empty_weights);
    try std.testing.expectEqualSlices(?*const u8, &.{ null, null, null }, &empty_weighted_const_ptr_fill);
    const empty_weighted_const_ptr_batch = try chooseWeightedConstPtrBatch(u8, failing, std.testing.allocator, 3, &weighted_single_items, &empty_weights);
    defer std.testing.allocator.free(empty_weighted_const_ptr_batch);
    try std.testing.expectEqualSlices(?*const u8, &.{ null, null, null }, empty_weighted_const_ptr_batch);
    var weighted_const_ptr_mismatch_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, chooseWeightedConstPtrBatch(u8, failing, weighted_const_ptr_mismatch_alloc.allocator(), 3, &.{ 1, 2 }, &.{1}));
    var weighted_const_ptr_checked_mismatch_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, chooseWeightedConstPtrBatchChecked(u8, failing, weighted_const_ptr_checked_mismatch_alloc.allocator(), 3, &.{ 1, 2 }, &.{1}));
    var weighted_const_ptr_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatch(u8, failing, weighted_const_ptr_invalid_alloc.allocator(), 3, &weighted_single_items, &.{ std.math.nan(f64), 1, 1 }));
    var weighted_const_ptr_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrBatchChecked(u8, failing, weighted_const_ptr_checked_invalid_alloc.allocator(), 3, &weighted_single_items, &.{ std.math.nan(f64), 1, 1 }));
    try std.testing.expectError(error.EmptyRange, chooseWeightedConstPtrChecked(u8, failing, &weighted_single_items, &empty_weights));
    var weighted_const_ptr_checked_empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, chooseWeightedConstPtrBatchChecked(u8, failing, weighted_const_ptr_checked_empty_alloc.allocator(), 3, &weighted_single_items, &empty_weights));
    try std.testing.expectError(error.EmptyRange, chooseWeightedConstPtrArrayChecked(u8, failing, 3, &weighted_single_items, &empty_weights));
    try std.testing.expectEqual(&weighted_single_items[1], (try chooseWeightedConstPtr(u8, failing, &weighted_single_items, &single_weight)).?);
    try std.testing.expectEqual(&weighted_single_items[1], try chooseWeightedConstPtrChecked(u8, failing, &weighted_single_items, &single_weight));
    try fillChooseWeightedConstPtr(u8, failing, &empty_weighted_const_ptr_fill, &weighted_single_items, &single_weight);
    for (empty_weighted_const_ptr_fill) |value| try std.testing.expectEqual(&weighted_single_items[1], value.?);
    var single_weighted_const_ptr_checked_fill: [3]*const u8 = undefined;
    try fillChooseWeightedConstPtrChecked(u8, failing, &single_weighted_const_ptr_checked_fill, &weighted_single_items, &single_weight);
    for (single_weighted_const_ptr_checked_fill) |value| try std.testing.expectEqual(&weighted_single_items[1], value);
    const single_weighted_const_ptr_batch = try chooseWeightedConstPtrBatch(u8, failing, std.testing.allocator, 3, &weighted_single_items, &single_weight);
    defer std.testing.allocator.free(single_weighted_const_ptr_batch);
    for (single_weighted_const_ptr_batch) |value| try std.testing.expectEqual(&weighted_single_items[1], value.?);
    const single_weighted_const_ptr_checked_batch = try chooseWeightedConstPtrBatchChecked(u8, failing, std.testing.allocator, 3, &weighted_single_items, &single_weight);
    defer std.testing.allocator.free(single_weighted_const_ptr_checked_batch);
    for (single_weighted_const_ptr_checked_batch) |value| try std.testing.expectEqual(&weighted_single_items[1], value);
    const single_weighted_const_ptr_array = (try chooseWeightedConstPtrArray(u8, failing, 3, &weighted_single_items, &single_weight)).?;
    for (single_weighted_const_ptr_array) |value| try std.testing.expectEqual(&weighted_single_items[1], value);
    const single_weighted_const_ptr_checked_array = try chooseWeightedConstPtrArrayChecked(u8, failing, 3, &weighted_single_items, &single_weight);
    for (single_weighted_const_ptr_checked_array) |value| try std.testing.expectEqual(&weighted_single_items[1], value);
    try std.testing.expectError(error.InvalidParameter, chooseWeightedConstPtr(u8, failing, &.{ 1, 2 }, &single_weight));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedConstPtrChecked(u8, failing, &weighted_single_items, &.{ 1, std.math.nan(f64), 2 }));
    var weighted_single_mut_items = weighted_single_items;
    try std.testing.expectEqual(@as(?*u8, null), try chooseWeightedPtr(u8, failing, &weighted_single_mut_items, &empty_weights));
    try std.testing.expectEqual(@as(?[3]*u8, null), try chooseWeightedPtrArray(u8, failing, 3, &weighted_single_mut_items, &empty_weights));
    var empty_weighted_ptr_fill: [3]?*u8 = undefined;
    try fillChooseWeightedPtr(u8, failing, &empty_weighted_ptr_fill, &weighted_single_mut_items, &empty_weights);
    try std.testing.expectEqualSlices(?*u8, &.{ null, null, null }, &empty_weighted_ptr_fill);
    const empty_weighted_ptr_batch = try chooseWeightedPtrBatch(u8, failing, std.testing.allocator, 3, &weighted_single_mut_items, &empty_weights);
    defer std.testing.allocator.free(empty_weighted_ptr_batch);
    try std.testing.expectEqualSlices(?*u8, &.{ null, null, null }, empty_weighted_ptr_batch);
    var weighted_ptr_mismatch_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, chooseWeightedPtrBatch(u8, failing, weighted_ptr_mismatch_alloc.allocator(), 3, &weighted_single_mut_items, &.{1}));
    var weighted_ptr_checked_mismatch_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidParameter, chooseWeightedPtrBatchChecked(u8, failing, weighted_ptr_checked_mismatch_alloc.allocator(), 3, &weighted_single_mut_items, &.{1}));
    var weighted_ptr_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatch(u8, failing, weighted_ptr_invalid_alloc.allocator(), 3, &weighted_single_mut_items, &.{ std.math.nan(f64), 1, 1 }));
    var weighted_ptr_checked_invalid_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrBatchChecked(u8, failing, weighted_ptr_checked_invalid_alloc.allocator(), 3, &weighted_single_mut_items, &.{ std.math.nan(f64), 1, 1 }));
    try std.testing.expectError(error.EmptyRange, chooseWeightedPtrChecked(u8, failing, &weighted_single_mut_items, &empty_weights));
    var weighted_ptr_checked_empty_alloc = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    try std.testing.expectError(error.EmptyRange, chooseWeightedPtrBatchChecked(u8, failing, weighted_ptr_checked_empty_alloc.allocator(), 3, &weighted_single_mut_items, &empty_weights));
    try std.testing.expectError(error.EmptyRange, chooseWeightedPtrArrayChecked(u8, failing, 3, &weighted_single_mut_items, &empty_weights));
    try std.testing.expectEqual(&weighted_single_mut_items[1], (try chooseWeightedPtr(u8, failing, &weighted_single_mut_items, &single_weight)).?);
    try std.testing.expectEqual(&weighted_single_mut_items[1], try chooseWeightedPtrChecked(u8, failing, &weighted_single_mut_items, &single_weight));
    try fillChooseWeightedPtr(u8, failing, &empty_weighted_ptr_fill, &weighted_single_mut_items, &single_weight);
    for (empty_weighted_ptr_fill) |value| try std.testing.expectEqual(&weighted_single_mut_items[1], value.?);
    var single_weighted_ptr_checked_fill: [3]*u8 = undefined;
    try fillChooseWeightedPtrChecked(u8, failing, &single_weighted_ptr_checked_fill, &weighted_single_mut_items, &single_weight);
    for (single_weighted_ptr_checked_fill) |value| try std.testing.expectEqual(&weighted_single_mut_items[1], value);
    const single_weighted_ptr_batch = try chooseWeightedPtrBatch(u8, failing, std.testing.allocator, 3, &weighted_single_mut_items, &single_weight);
    defer std.testing.allocator.free(single_weighted_ptr_batch);
    for (single_weighted_ptr_batch) |value| try std.testing.expectEqual(&weighted_single_mut_items[1], value.?);
    const single_weighted_ptr_checked_batch = try chooseWeightedPtrBatchChecked(u8, failing, std.testing.allocator, 3, &weighted_single_mut_items, &single_weight);
    defer std.testing.allocator.free(single_weighted_ptr_checked_batch);
    for (single_weighted_ptr_checked_batch) |value| try std.testing.expectEqual(&weighted_single_mut_items[1], value);
    const single_weighted_ptr_array = (try chooseWeightedPtrArray(u8, failing, 3, &weighted_single_mut_items, &single_weight)).?;
    for (single_weighted_ptr_array) |value| try std.testing.expectEqual(&weighted_single_mut_items[1], value);
    const single_weighted_ptr_checked_array = try chooseWeightedPtrArrayChecked(u8, failing, 3, &weighted_single_mut_items, &single_weight);
    for (single_weighted_ptr_checked_array) |value| try std.testing.expectEqual(&weighted_single_mut_items[1], value);
    var mismatched_weighted_mut_items = [_]u8{ 1, 2 };
    try std.testing.expectError(error.InvalidParameter, chooseWeightedPtr(u8, failing, &mismatched_weighted_mut_items, &single_weight));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedPtrChecked(u8, failing, &weighted_single_mut_items, &.{ 1, std.math.nan(f64), 2 }));
    try std.testing.expectError(error.InvalidParameter, chooseWeighted(u8, failing, &.{ 1, 2 }, &single_weight));
    try std.testing.expectError(error.InvalidWeight, chooseWeightedChecked(u8, failing, &weighted_single_items, &.{ 1, std.math.nan(f64), 2 }));
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
    try std.testing.expectError(error.EntropyUnavailable, chooseIndexArray(failing, 1, 2));
    try std.testing.expectError(error.EntropyUnavailable, chooseIndexArrayU32(failing, 1, 2));
    try std.testing.expectError(error.EntropyUnavailable, choose(u8, failing, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, fillChoose(u8, failing, &byte, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseBatch(u8, failing, std.testing.allocator, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseValueArray(u8, failing, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseRepeatedValueArray(u8, failing, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseConstPtr(u8, failing, &.{ 1, 2 }));
    var one_const_ptr: [1]*const u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseConstPtr(u8, failing, &one_const_ptr, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseConstPtrBatch(u8, failing, std.testing.allocator, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseConstPtrArray(u8, failing, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseRepeatedConstPtrArray(u8, failing, 1, &.{ 1, 2 }));
    var mutable_pair = [_]u8{ 1, 2 };
    try std.testing.expectError(error.EntropyUnavailable, choosePtr(u8, failing, &mutable_pair));
    var one_ptr: [1]*u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChoosePtr(u8, failing, &one_ptr, &mutable_pair));
    try std.testing.expectError(error.EntropyUnavailable, choosePtrBatch(u8, failing, std.testing.allocator, 1, &mutable_pair));
    try std.testing.expectError(error.EntropyUnavailable, choosePtrArray(u8, failing, 1, &mutable_pair));
    try std.testing.expectError(error.EntropyUnavailable, chooseRepeatedPtrArray(u8, failing, 1, &mutable_pair));
    var shuffle_pair = [_]u8{ 1, 2 };
    try std.testing.expectError(error.EntropyUnavailable, shuffle(u8, failing, &shuffle_pair));
    try std.testing.expectError(error.EntropyUnavailable, partialShuffle(u8, failing, &shuffle_pair, 1));
    try std.testing.expectError(error.EntropyUnavailable, partialShuffleSplit(u8, failing, &shuffle_pair, 1));
    try std.testing.expectError(error.EntropyUnavailable, partialShuffleTail(u8, failing, &shuffle_pair, 1));
    try std.testing.expectError(error.EntropyUnavailable, partialShuffleTailSplit(u8, failing, &shuffle_pair, 1));
    try std.testing.expectError(error.EntropyUnavailable, sampleWithoutReplacement(u8, failing, std.testing.allocator, &sample_items, 1));
    try std.testing.expectError(error.EntropyUnavailable, sampleWithoutReplacementChecked(u8, failing, std.testing.allocator, &sample_items, 1));
    try std.testing.expectError(error.EntropyUnavailable, chooseMultiple(u8, failing, std.testing.allocator, &sample_items, 1));
    try std.testing.expectError(error.EntropyUnavailable, chooseMultipleChecked(u8, failing, std.testing.allocator, &sample_items, 1));
    try std.testing.expectError(error.EntropyUnavailable, sampleItemsArray(u8, failing, 2, &sample_items));
    try std.testing.expectError(error.EntropyUnavailable, sampleItemsArrayChecked(u8, failing, 2, &sample_items));
    try std.testing.expectError(error.EntropyUnavailable, chooseArray(u8, failing, 2, &sample_items));
    try std.testing.expectError(error.EntropyUnavailable, chooseArrayChecked(u8, failing, 2, &sample_items));
    try std.testing.expectError(error.EntropyUnavailable, samplePtrArray(u8, failing, 2, &sample_items));
    try std.testing.expectError(error.EntropyUnavailable, samplePtrArrayChecked(u8, failing, 2, &sample_items));
    try std.testing.expectError(error.EntropyUnavailable, samplePtrs(u8, failing, std.testing.allocator, &sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, samplePtrsChecked(u8, failing, std.testing.allocator, &sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, chooseMultiplePtrs(u8, failing, std.testing.allocator, &sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, chooseMultiplePtrsChecked(u8, failing, std.testing.allocator, &sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleMutPtrArray(u8, failing, 2, &mutable_sample_items));
    try std.testing.expectError(error.EntropyUnavailable, sampleMutPtrArrayChecked(u8, failing, 2, &mutable_sample_items));
    try std.testing.expectError(error.EntropyUnavailable, sampleMutPtrs(u8, failing, std.testing.allocator, &mutable_sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleMutPtrsChecked(u8, failing, std.testing.allocator, &mutable_sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, chooseMultipleMutPtrs(u8, failing, std.testing.allocator, &mutable_sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, chooseMultipleMutPtrsChecked(u8, failing, std.testing.allocator, &mutable_sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleItemsIter(u8, failing, std.testing.allocator, &sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleItemsIterChecked(u8, failing, std.testing.allocator, &sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, samplePtrsIter(u8, failing, std.testing.allocator, &sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, samplePtrsIterChecked(u8, failing, std.testing.allocator, &sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleMutPtrsIter(u8, failing, std.testing.allocator, &mutable_sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleMutPtrsIterChecked(u8, failing, std.testing.allocator, &mutable_sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, reservoirSample(u8, failing, std.testing.allocator, &sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, reservoirSampleChecked(u8, failing, std.testing.allocator, &sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, reservoirSamplePtrs(u8, failing, std.testing.allocator, &sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, reservoirSamplePtrsChecked(u8, failing, std.testing.allocator, &sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, reservoirSampleMutPtrs(u8, failing, std.testing.allocator, &mutable_sample_items, 2));
    try std.testing.expectError(error.EntropyUnavailable, reservoirSampleMutPtrsChecked(u8, failing, std.testing.allocator, &mutable_sample_items, 2));
    var reservoir_values_entropy: [2]u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, reservoirSampleInto(u8, failing, &sample_items, &reservoir_values_entropy));
    try std.testing.expectError(error.EntropyUnavailable, reservoirSampleIntoChecked(u8, failing, &sample_items, &reservoir_values_entropy));
    var reservoir_ptrs_entropy: [2]*const u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, reservoirSamplePtrsInto(u8, failing, &sample_items, &reservoir_ptrs_entropy));
    try std.testing.expectError(error.EntropyUnavailable, reservoirSamplePtrsIntoChecked(u8, failing, &sample_items, &reservoir_ptrs_entropy));
    var reservoir_mut_ptrs_entropy: [2]*u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, reservoirSampleMutPtrsInto(u8, failing, &mutable_sample_items, &reservoir_mut_ptrs_entropy));
    try std.testing.expectError(error.EntropyUnavailable, reservoirSampleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &reservoir_mut_ptrs_entropy));
    var values_entropy: [2]u8 = undefined;
    var values_entropy_scratch: [2]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleItemsInto(u8, failing, &sample_items, &values_entropy, &values_entropy_scratch));
    try std.testing.expectError(error.EntropyUnavailable, sampleItemsIntoChecked(u8, failing, &sample_items, &values_entropy, &values_entropy_scratch));
    try std.testing.expectError(error.EntropyUnavailable, chooseMultipleInto(u8, failing, &sample_items, &values_entropy, &values_entropy_scratch));
    try std.testing.expectError(error.EntropyUnavailable, chooseMultipleIntoChecked(u8, failing, &sample_items, &values_entropy, &values_entropy_scratch));
    var ptrs_entropy: [2]*const u8 = undefined;
    var ptrs_entropy_scratch: [2]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, samplePtrsInto(u8, failing, &sample_items, &ptrs_entropy, &ptrs_entropy_scratch));
    try std.testing.expectError(error.EntropyUnavailable, samplePtrsIntoChecked(u8, failing, &sample_items, &ptrs_entropy, &ptrs_entropy_scratch));
    try std.testing.expectError(error.EntropyUnavailable, chooseMultiplePtrsInto(u8, failing, &sample_items, &ptrs_entropy, &ptrs_entropy_scratch));
    try std.testing.expectError(error.EntropyUnavailable, chooseMultiplePtrsIntoChecked(u8, failing, &sample_items, &ptrs_entropy, &ptrs_entropy_scratch));
    var mut_ptrs_entropy: [2]*u8 = undefined;
    var mut_ptrs_entropy_scratch: [2]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleMutPtrsInto(u8, failing, &mutable_sample_items, &mut_ptrs_entropy, &mut_ptrs_entropy_scratch));
    try std.testing.expectError(error.EntropyUnavailable, sampleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &mut_ptrs_entropy, &mut_ptrs_entropy_scratch));
    try std.testing.expectError(error.EntropyUnavailable, chooseMultipleMutPtrsInto(u8, failing, &mutable_sample_items, &mut_ptrs_entropy, &mut_ptrs_entropy_scratch));
    try std.testing.expectError(error.EntropyUnavailable, chooseMultipleMutPtrsIntoChecked(u8, failing, &mutable_sample_items, &mut_ptrs_entropy, &mut_ptrs_entropy_scratch));
    try std.testing.expectError(error.EntropyUnavailable, sampleIndexVec(failing, std.testing.allocator, 5, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleIndexVecChecked(failing, std.testing.allocator, 5, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleArray(failing, 2, 5));
    try std.testing.expectError(error.EntropyUnavailable, sampleArrayChecked(failing, 2, 5));
    try std.testing.expectError(error.EntropyUnavailable, sampleArrayU32(failing, 2, 5));
    try std.testing.expectError(error.EntropyUnavailable, sampleArrayU32Checked(failing, 2, 5));
    try std.testing.expectError(error.EntropyUnavailable, sampleIndices(failing, std.testing.allocator, 5, 2));
    var sample_indices_one: [1]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleIndicesInto(failing, 5, &sample_indices_one));
    try std.testing.expectError(error.EntropyUnavailable, sampleIndicesU32(failing, std.testing.allocator, 5, 2));
    var sample_indices_u32_one: [1]u32 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleIndicesU32Into(failing, 5, &sample_indices_u32_one));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndices(f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesU32(f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexVec(f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexVecChecked(f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexArray(f64, failing, 2, &.{ 1, 2, 3 }));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexArrayChecked(f64, failing, 2, &.{ 1, 2, 3 }));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexArrayU32(f64, failing, 2, &.{ 1, 2, 3 }));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexArrayU32Checked(f64, failing, 2, &.{ 1, 2, 3 }));
    var weighted_indices_entropy: [2]usize = undefined;
    var weighted_indices_entropy_keys: [2]f64 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesInto(f64, failing, &.{ 1, 2, 3 }, &weighted_indices_entropy, &weighted_indices_entropy_keys));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesIntoChecked(f64, failing, &.{ 1, 2, 3 }, &weighted_indices_entropy, &weighted_indices_entropy_keys));
    var weighted_indices_u32_entropy: [2]u32 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesU32Into(f64, failing, &.{ 1, 2, 3 }, &weighted_indices_u32_entropy, &weighted_indices_entropy_keys));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesU32IntoChecked(f64, failing, &.{ 1, 2, 3 }, &weighted_indices_u32_entropy, &weighted_indices_entropy_keys));
    var weighted_values_entropy: [2]u8 = undefined;
    var weighted_value_indices_entropy: [2]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedInto(u8, f64, failing, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }, &weighted_values_entropy, &weighted_value_indices_entropy, &weighted_indices_entropy_keys));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIntoChecked(u8, f64, failing, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }, &weighted_values_entropy, &weighted_value_indices_entropy, &weighted_indices_entropy_keys));
    var weighted_ptrs_entropy: [2]*const u8 = undefined;
    var weighted_ptr_indices_entropy: [2]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedPtrsInto(u8, f64, failing, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }, &weighted_ptrs_entropy, &weighted_ptr_indices_entropy, &weighted_indices_entropy_keys));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedPtrsIntoChecked(u8, f64, failing, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }, &weighted_ptrs_entropy, &weighted_ptr_indices_entropy, &weighted_indices_entropy_keys));
    var weighted_mut_ptrs_entropy_items = [_]u8{ 1, 2, 3 };
    var weighted_mut_ptrs_entropy: [2]*u8 = undefined;
    var weighted_mut_ptr_indices_entropy: [2]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedMutPtrsInto(u8, f64, failing, &weighted_mut_ptrs_entropy_items, &.{ 1, 2, 3 }, &weighted_mut_ptrs_entropy, &weighted_mut_ptr_indices_entropy, &weighted_indices_entropy_keys));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedMutPtrsIntoChecked(u8, f64, failing, &weighted_mut_ptrs_entropy_items, &.{ 1, 2, 3 }, &weighted_mut_ptrs_entropy, &weighted_mut_ptr_indices_entropy, &weighted_indices_entropy_keys));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeighted(u8, f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, weighted_by_items[0..2], 2, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, weighted_by_items[0..2], 2, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesU32By(RootItemWeights.Entry, f64, failing, std.testing.allocator, weighted_by_items[0..2], 2, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesU32ByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, weighted_by_items[0..2], 2, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexVecBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, weighted_by_items[0..2], 2, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexVecByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, weighted_by_items[0..2], 2, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexArrayBy(RootItemWeights.Entry, f64, failing, 2, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexArrayByChecked(RootItemWeights.Entry, f64, failing, 2, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexArrayU32By(RootItemWeights.Entry, f64, failing, 2, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexArrayU32ByChecked(RootItemWeights.Entry, f64, failing, 2, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedArrayBy(RootItemWeights.Entry, f64, failing, 2, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedArrayByChecked(RootItemWeights.Entry, f64, failing, 2, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedPtrArrayBy(RootItemWeights.Entry, f64, failing, 2, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 2, weighted_by_items[0..2], RootItemWeights.weight));
    var weighted_mut_ptr_array_by_entropy_items = weighted_by_items;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedMutPtrArrayBy(RootItemWeights.Entry, f64, failing, 2, weighted_mut_ptr_array_by_entropy_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedMutPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 2, weighted_mut_ptr_array_by_entropy_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, weighted_by_items[0..2], 2, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, weighted_by_items[0..2], 2, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedPtrsBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, weighted_by_items[0..2], 2, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedPtrsByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, weighted_by_items[0..2], 2, RootItemWeights.weight));
    var weighted_by_mut_sample_entropy_items = weighted_by_items;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedMutPtrsBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, weighted_by_mut_sample_entropy_items[0..2], 2, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedMutPtrsByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, weighted_by_mut_sample_entropy_items[0..2], 2, RootItemWeights.weight));
    var weighted_by_values_entropy: [2]RootItemWeights.Entry = undefined;
    var weighted_by_values_entropy_indices: [2]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedByInto(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], &weighted_by_values_entropy, &weighted_by_values_entropy_indices, &weighted_indices_entropy_keys, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedByIntoChecked(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], &weighted_by_values_entropy, &weighted_by_values_entropy_indices, &weighted_indices_entropy_keys, RootItemWeights.weight));
    var weighted_by_ptrs_entropy: [2]*const RootItemWeights.Entry = undefined;
    var weighted_by_ptrs_entropy_indices: [2]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedPtrsByInto(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], &weighted_by_ptrs_entropy, &weighted_by_ptrs_entropy_indices, &weighted_indices_entropy_keys, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], &weighted_by_ptrs_entropy, &weighted_by_ptrs_entropy_indices, &weighted_indices_entropy_keys, RootItemWeights.weight));
    var weighted_by_mut_ptrs_entropy_items = weighted_by_items;
    var weighted_by_mut_ptrs_entropy: [2]*RootItemWeights.Entry = undefined;
    var weighted_by_mut_ptrs_entropy_indices: [2]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedMutPtrsByInto(RootItemWeights.Entry, f64, failing, weighted_by_mut_ptrs_entropy_items[0..2], &weighted_by_mut_ptrs_entropy, &weighted_by_mut_ptrs_entropy_indices, &weighted_indices_entropy_keys, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedMutPtrsByIntoChecked(RootItemWeights.Entry, f64, failing, weighted_by_mut_ptrs_entropy_items[0..2], &weighted_by_mut_ptrs_entropy, &weighted_by_mut_ptrs_entropy_indices, &weighted_indices_entropy_keys, RootItemWeights.weight));
    var weighted_by_indices_by_entropy: [2]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesByInto(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], &weighted_by_indices_by_entropy, &weighted_indices_entropy_keys, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesByIntoChecked(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], &weighted_by_indices_by_entropy, &weighted_indices_entropy_keys, RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedArray(u8, f64, failing, 2, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedPtrs(u8, f64, failing, std.testing.allocator, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedPtrArray(u8, f64, failing, 2, &.{ 1, 2, 3 }, &.{ 1, 2, 3 }));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedMutPtrs(u8, f64, failing, std.testing.allocator, &weighted_mut_nr_items, &.{ 1, 2, 3 }, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedMutPtrsChecked(u8, f64, failing, std.testing.allocator, &weighted_mut_nr_items, &.{ 1, 2, 3 }, 2));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedMutPtrArray(u8, f64, failing, 2, &weighted_mut_nr_items, &.{ 1, 2, 3 }));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedMutPtrArrayChecked(u8, f64, failing, 2, &weighted_mut_nr_items, &.{ 1, 2, 3 }));
    var entropy_iter = SliceIter{ .items = &.{ 1, 2 } };
    try std.testing.expectError(error.EntropyUnavailable, chooseIterator(u8, failing, &entropy_iter));
    var entropy_iter_checked = SliceIter{ .items = &.{ 1, 2 } };
    try std.testing.expectError(error.EntropyUnavailable, chooseIteratorChecked(u8, failing, &entropy_iter_checked));
    var entropy_hinted = SliceIter{ .items = &.{ 1, 2 } };
    try std.testing.expectError(error.EntropyUnavailable, chooseIteratorHinted(u8, failing, &entropy_hinted));
    var entropy_stable = SliceIter{ .items = &.{ 1, 2 } };
    try std.testing.expectError(error.EntropyUnavailable, chooseIteratorStable(u8, failing, &entropy_stable));
    const WeightedIter = struct {
        const Entry = struct { item: u8, weight: f64 };
        items: []const Entry,
        index: usize = 0,

        pub fn next(self: *@This()) ?Entry {
            if (self.index >= self.items.len) return null;
            const value = self.items[self.index];
            self.index += 1;
            return value;
        }
    };
    const weighted_empty_entries = [_]WeightedIter.Entry{};
    var weighted_empty = WeightedIter{ .items = &weighted_empty_entries };
    try std.testing.expectEqual(@as(?u8, null), try chooseIteratorWeighted(u8, failing, &weighted_empty));
    var weighted_empty_checked = WeightedIter{ .items = &weighted_empty_entries };
    try std.testing.expectError(error.EmptyInput, chooseIteratorWeightedChecked(u8, failing, &weighted_empty_checked));
    const weighted_zero_entries = [_]WeightedIter.Entry{
        .{ .item = 1, .weight = 0 },
        .{ .item = 2, .weight = 0 },
    };
    var weighted_zero = WeightedIter{ .items = &weighted_zero_entries };
    try std.testing.expectEqual(@as(?u8, null), try chooseIteratorWeighted(u8, failing, &weighted_zero));
    var weighted_zero_checked = WeightedIter{ .items = &weighted_zero_entries };
    try std.testing.expectError(error.EmptyInput, chooseIteratorWeightedChecked(u8, failing, &weighted_zero_checked));
    const weighted_single_entries = [_]WeightedIter.Entry{
        .{ .item = 1, .weight = 0 },
        .{ .item = 2, .weight = 5 },
        .{ .item = 3, .weight = 0 },
    };
    var weighted_single = WeightedIter{ .items = &weighted_single_entries };
    try std.testing.expectEqual(@as(?u8, 2), try chooseIteratorWeighted(u8, failing, &weighted_single));
    var weighted_single_checked = WeightedIter{ .items = &weighted_single_entries };
    try std.testing.expectEqual(@as(u8, 2), try chooseIteratorWeightedChecked(u8, failing, &weighted_single_checked));
    const weighted_bad_entries = [_]WeightedIter.Entry{.{ .item = 1, .weight = std.math.nan(f64) }};
    var weighted_bad = WeightedIter{ .items = &weighted_bad_entries };
    try std.testing.expectError(error.InvalidWeight, chooseIteratorWeighted(u8, failing, &weighted_bad));
    const weighted_entropy_entries = [_]WeightedIter.Entry{
        .{ .item = 1, .weight = 1 },
        .{ .item = 2, .weight = 1 },
    };
    const weighted_two_positive_entries = [_]WeightedIter.Entry{
        .{ .item = 1, .weight = 1 },
        .{ .item = 2, .weight = 1 },
        .{ .item = 3, .weight = 0 },
    };
    var weighted_entropy = WeightedIter{ .items = &weighted_entropy_entries };
    try std.testing.expectError(error.EntropyUnavailable, chooseIteratorWeighted(u8, failing, &weighted_entropy));
    var sample_iter_empty = SliceIter{ .items = &.{} };
    const sample_iter_empty_out = try sampleIterator(u8, failing, std.testing.allocator, &sample_iter_empty, 0);
    defer std.testing.allocator.free(sample_iter_empty_out);
    try std.testing.expectEqual(@as(usize, 0), sample_iter_empty_out.len);
    var sample_iter_short = SliceIter{ .items = &.{ 1, 2 } };
    const sample_iter_short_out = try sampleIterator(u8, failing, std.testing.allocator, &sample_iter_short, 4);
    defer std.testing.allocator.free(sample_iter_short_out);
    try std.testing.expectEqualSlices(u8, &.{ 1, 2 }, sample_iter_short_out);
    var sample_iter_exact = SliceIter{ .items = &.{ 1, 2 } };
    const sample_iter_exact_out = try sampleIteratorChecked(u8, failing, std.testing.allocator, &sample_iter_exact, 2);
    defer std.testing.allocator.free(sample_iter_exact_out);
    try std.testing.expectEqualSlices(u8, &.{ 1, 2 }, sample_iter_exact_out);
    var sample_iter_short_checked = SliceIter{ .items = &.{ 1, 2 } };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorChecked(u8, failing, std.testing.allocator, &sample_iter_short_checked, 3));
    var sample_iter_entropy = SliceIter{ .items = &.{ 1, 2, 3 } };
    try std.testing.expectError(error.EntropyUnavailable, sampleIterator(u8, failing, std.testing.allocator, &sample_iter_entropy, 2));
    var sample_iter_entropy_checked = SliceIter{ .items = &.{ 1, 2, 3 } };
    try std.testing.expectError(error.EntropyUnavailable, sampleIteratorChecked(u8, failing, std.testing.allocator, &sample_iter_entropy_checked, 2));
    var sample_into_empty_iter = SliceIter{ .items = &.{} };
    var sample_into_empty: [0]u8 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleIteratorInto(u8, failing, &sample_into_empty_iter, &sample_into_empty));
    var sample_into_short_iter = SliceIter{ .items = &.{ 1, 2 } };
    var sample_into_short: [4]u8 = undefined;
    try std.testing.expectEqual(@as(usize, 2), try sampleIteratorInto(u8, failing, &sample_into_short_iter, &sample_into_short));
    try std.testing.expectEqualSlices(u8, &.{ 1, 2 }, sample_into_short[0..2]);
    var sample_into_exact_iter = SliceIter{ .items = &.{ 1, 2 } };
    var sample_into_exact: [2]u8 = undefined;
    try sampleIteratorIntoChecked(u8, failing, &sample_into_exact_iter, &sample_into_exact);
    try std.testing.expectEqualSlices(u8, &.{ 1, 2 }, &sample_into_exact);
    var sample_into_short_checked_iter = SliceIter{ .items = &.{ 1, 2 } };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorIntoChecked(u8, failing, &sample_into_short_checked_iter, &sample_into_short));
    var sample_into_entropy_iter = SliceIter{ .items = &.{ 1, 2, 3 } };
    var sample_into_entropy: [2]u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleIteratorInto(u8, failing, &sample_into_entropy_iter, &sample_into_entropy));
    var sample_fill_empty_iter = SliceIter{ .items = &.{} };
    var sample_fill_empty: [0]u8 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleIteratorFill(u8, failing, &sample_fill_empty_iter, &sample_fill_empty));
    var sample_fill_short_iter = SliceIter{ .items = &.{ 1, 2 } };
    var sample_fill_short: [4]u8 = undefined;
    try std.testing.expectEqual(@as(usize, 2), try sampleIteratorFill(u8, failing, &sample_fill_short_iter, &sample_fill_short));
    try std.testing.expectEqualSlices(u8, &.{ 1, 2 }, sample_fill_short[0..2]);
    var sample_fill_exact_iter = SliceIter{ .items = &.{ 1, 2 } };
    var sample_fill_exact: [2]u8 = undefined;
    try sampleIteratorFillChecked(u8, failing, &sample_fill_exact_iter, &sample_fill_exact);
    try std.testing.expectEqualSlices(u8, &.{ 1, 2 }, &sample_fill_exact);
    var sample_fill_short_checked_iter = SliceIter{ .items = &.{ 1, 2 } };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorFillChecked(u8, failing, &sample_fill_short_checked_iter, &sample_fill_short));
    var sample_fill_entropy_iter = SliceIter{ .items = &.{ 1, 2, 3 } };
    var sample_fill_entropy: [2]u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleIteratorFill(u8, failing, &sample_fill_entropy_iter, &sample_fill_entropy));
    var sample_fill_entropy_checked_iter = SliceIter{ .items = &.{ 1, 2, 3 } };
    try std.testing.expectError(error.EntropyUnavailable, sampleIteratorFillChecked(u8, failing, &sample_fill_entropy_checked_iter, &sample_fill_entropy));
    var sample_array_empty_iter = SliceIter{ .items = &.{} };
    try std.testing.expectEqual(@as(usize, 0), (try sampleIteratorArray(u8, failing, 0, &sample_array_empty_iter)).?.len);
    var sample_array_short_iter = SliceIter{ .items = &.{ 1, 2 } };
    try std.testing.expectEqual(@as(?[3]u8, null), try sampleIteratorArray(u8, failing, 3, &sample_array_short_iter));
    var sample_array_exact_iter = SliceIter{ .items = &.{ 1, 2 } };
    try std.testing.expectEqualSlices(u8, &.{ 1, 2 }, &(try sampleIteratorArrayChecked(u8, failing, 2, &sample_array_exact_iter)));
    var sample_array_short_checked_iter = SliceIter{ .items = &.{ 1, 2 } };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorArrayChecked(u8, failing, 3, &sample_array_short_checked_iter));
    var sample_array_entropy_iter = SliceIter{ .items = &.{ 1, 2, 3 } };
    try std.testing.expectError(error.EntropyUnavailable, sampleIteratorArray(u8, failing, 2, &sample_array_entropy_iter));
    var weighted_sample_empty = WeightedIter{ .items = &weighted_empty_entries };
    const weighted_sample_empty_out = try sampleIteratorWeighted(u8, failing, std.testing.allocator, &weighted_sample_empty, 0);
    defer std.testing.allocator.free(weighted_sample_empty_out);
    try std.testing.expectEqual(@as(usize, 0), weighted_sample_empty_out.len);
    var weighted_sample_empty_checked = WeightedIter{ .items = &weighted_entropy_entries };
    const weighted_sample_empty_checked_out = try sampleIteratorWeightedChecked(u8, failing, std.testing.allocator, &weighted_sample_empty_checked, 0);
    defer std.testing.allocator.free(weighted_sample_empty_checked_out);
    try std.testing.expectEqual(@as(usize, 0), weighted_sample_empty_checked_out.len);
    var weighted_sample_zero = WeightedIter{ .items = &weighted_zero_entries };
    const weighted_sample_zero_out = try sampleIteratorWeighted(u8, failing, std.testing.allocator, &weighted_sample_zero, 1);
    defer std.testing.allocator.free(weighted_sample_zero_out);
    try std.testing.expectEqual(@as(usize, 0), weighted_sample_zero_out.len);
    var weighted_sample_zero_checked = WeightedIter{ .items = &weighted_zero_entries };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedChecked(u8, failing, std.testing.allocator, &weighted_sample_zero_checked, 1));
    var weighted_sample_single = WeightedIter{ .items = &weighted_single_entries };
    const weighted_sample_single_out = try sampleIteratorWeighted(u8, failing, std.testing.allocator, &weighted_sample_single, 2);
    defer std.testing.allocator.free(weighted_sample_single_out);
    try std.testing.expectEqualSlices(u8, &.{2}, weighted_sample_single_out);
    var weighted_sample_single_checked = WeightedIter{ .items = &weighted_single_entries };
    const weighted_sample_single_checked_out = try sampleIteratorWeightedChecked(u8, failing, std.testing.allocator, &weighted_sample_single_checked, 1);
    defer std.testing.allocator.free(weighted_sample_single_checked_out);
    try std.testing.expectEqualSlices(u8, &.{2}, weighted_sample_single_checked_out);
    var weighted_sample_single_too_many_checked = WeightedIter{ .items = &weighted_single_entries };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedChecked(u8, failing, std.testing.allocator, &weighted_sample_single_too_many_checked, 2));
    var weighted_sample_two_positive_too_many_checked = WeightedIter{ .items = &weighted_two_positive_entries };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedChecked(u8, failing, std.testing.allocator, &weighted_sample_two_positive_too_many_checked, 3));
    var weighted_sample_bad = WeightedIter{ .items = &weighted_bad_entries };
    try std.testing.expectError(error.InvalidWeight, sampleIteratorWeighted(u8, failing, std.testing.allocator, &weighted_sample_bad, 1));
    var weighted_sample_bad_checked = WeightedIter{ .items = &weighted_bad_entries };
    try std.testing.expectError(error.InvalidWeight, sampleIteratorWeightedChecked(u8, failing, std.testing.allocator, &weighted_sample_bad_checked, 1));
    var weighted_sample_entropy = WeightedIter{ .items = &weighted_entropy_entries };
    try std.testing.expectError(error.EntropyUnavailable, sampleIteratorWeighted(u8, failing, std.testing.allocator, &weighted_sample_entropy, 1));
    var weighted_sample_entropy_checked = WeightedIter{ .items = &weighted_entropy_entries };
    try std.testing.expectError(error.EntropyUnavailable, sampleIteratorWeightedChecked(u8, failing, std.testing.allocator, &weighted_sample_entropy_checked, 1));
    var weighted_into_empty = WeightedIter{ .items = &weighted_entropy_entries };
    var weighted_into_empty_out: [0]u8 = .{};
    var weighted_into_empty_keys: [0]f64 = .{};
    try std.testing.expectEqual(@as(usize, 0), try sampleIteratorWeightedInto(u8, failing, &weighted_into_empty, &weighted_into_empty_out, &weighted_into_empty_keys));
    var weighted_into_empty_checked = WeightedIter{ .items = &weighted_entropy_entries };
    try sampleIteratorWeightedIntoChecked(u8, failing, &weighted_into_empty_checked, &weighted_into_empty_out, &weighted_into_empty_keys);
    var weighted_into_short_scratch = WeightedIter{ .items = &weighted_entropy_entries };
    var weighted_into_out: [1]u8 = undefined;
    var weighted_into_bad_keys: [0]f64 = .{};
    try std.testing.expectError(error.LengthMismatch, sampleIteratorWeightedInto(u8, failing, &weighted_into_short_scratch, &weighted_into_out, &weighted_into_bad_keys));
    try std.testing.expectError(error.LengthMismatch, sampleIteratorWeightedIntoChecked(u8, failing, &weighted_into_short_scratch, &weighted_into_out, &weighted_into_bad_keys));
    var weighted_into_zero = WeightedIter{ .items = &weighted_zero_entries };
    var weighted_into_zero_out: [1]u8 = undefined;
    var weighted_into_zero_keys: [1]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 0), try sampleIteratorWeightedInto(u8, failing, &weighted_into_zero, &weighted_into_zero_out, &weighted_into_zero_keys));
    var weighted_into_zero_checked = WeightedIter{ .items = &weighted_zero_entries };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedIntoChecked(u8, failing, &weighted_into_zero_checked, &weighted_into_zero_out, &weighted_into_zero_keys));
    var weighted_into_single = WeightedIter{ .items = &weighted_single_entries };
    var weighted_into_single_out: [2]u8 = undefined;
    var weighted_into_single_keys: [2]f64 = undefined;
    try std.testing.expectEqual(@as(usize, 1), try sampleIteratorWeightedInto(u8, failing, &weighted_into_single, &weighted_into_single_out, &weighted_into_single_keys));
    try std.testing.expectEqual(@as(u8, 2), weighted_into_single_out[0]);
    var weighted_into_single_checked = WeightedIter{ .items = &weighted_single_entries };
    try sampleIteratorWeightedIntoChecked(u8, failing, &weighted_into_single_checked, weighted_into_single_out[0..1], weighted_into_single_keys[0..1]);
    try std.testing.expectEqual(@as(u8, 2), weighted_into_single_out[0]);
    var weighted_into_single_too_many_checked = WeightedIter{ .items = &weighted_single_entries };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedIntoChecked(u8, failing, &weighted_into_single_too_many_checked, &weighted_into_single_out, &weighted_into_single_keys));
    var weighted_into_two_positive_too_many_checked = WeightedIter{ .items = &weighted_two_positive_entries };
    var weighted_into_two_positive_out: [3]u8 = undefined;
    var weighted_into_two_positive_keys: [3]f64 = undefined;
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedIntoChecked(u8, failing, &weighted_into_two_positive_too_many_checked, &weighted_into_two_positive_out, &weighted_into_two_positive_keys));
    var weighted_into_bad = WeightedIter{ .items = &weighted_bad_entries };
    try std.testing.expectError(error.InvalidWeight, sampleIteratorWeightedInto(u8, failing, &weighted_into_bad, &weighted_into_out, &weighted_into_zero_keys));
    var weighted_into_bad_checked = WeightedIter{ .items = &weighted_bad_entries };
    try std.testing.expectError(error.InvalidWeight, sampleIteratorWeightedIntoChecked(u8, failing, &weighted_into_bad_checked, &weighted_into_out, &weighted_into_zero_keys));
    var weighted_into_entropy = WeightedIter{ .items = &weighted_entropy_entries };
    var weighted_into_keys: [1]f64 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleIteratorWeightedInto(u8, failing, &weighted_into_entropy, &weighted_into_out, &weighted_into_keys));
    var weighted_into_entropy_checked = WeightedIter{ .items = &weighted_entropy_entries };
    try std.testing.expectError(error.EntropyUnavailable, sampleIteratorWeightedIntoChecked(u8, failing, &weighted_into_entropy_checked, &weighted_into_out, &weighted_into_keys));
    var weighted_array_empty = WeightedIter{ .items = &weighted_entropy_entries };
    try std.testing.expectEqual(@as(usize, 0), (try sampleIteratorWeightedArray(u8, failing, 0, &weighted_array_empty)).?.len);
    var weighted_array_empty_checked = WeightedIter{ .items = &weighted_entropy_entries };
    try std.testing.expectEqual(@as(usize, 0), (try sampleIteratorWeightedArrayChecked(u8, failing, 0, &weighted_array_empty_checked)).len);
    var weighted_array_zero = WeightedIter{ .items = &weighted_zero_entries };
    try std.testing.expectEqual(@as(?[1]u8, null), try sampleIteratorWeightedArray(u8, failing, 1, &weighted_array_zero));
    var weighted_array_zero_checked = WeightedIter{ .items = &weighted_zero_entries };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedArrayChecked(u8, failing, 1, &weighted_array_zero_checked));
    var weighted_array_single = WeightedIter{ .items = &weighted_single_entries };
    try std.testing.expectEqualSlices(u8, &.{2}, &(try sampleIteratorWeightedArray(u8, failing, 1, &weighted_array_single)).?);
    var weighted_array_single_checked = WeightedIter{ .items = &weighted_single_entries };
    try std.testing.expectEqualSlices(u8, &.{2}, &(try sampleIteratorWeightedArrayChecked(u8, failing, 1, &weighted_array_single_checked)));
    var weighted_array_single_too_many = WeightedIter{ .items = &weighted_single_entries };
    try std.testing.expectEqual(@as(?[2]u8, null), try sampleIteratorWeightedArray(u8, failing, 2, &weighted_array_single_too_many));
    var weighted_array_single_too_many_checked = WeightedIter{ .items = &weighted_single_entries };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedArrayChecked(u8, failing, 2, &weighted_array_single_too_many_checked));
    var weighted_array_two_positive_too_many = WeightedIter{ .items = &weighted_two_positive_entries };
    try std.testing.expectEqual(@as(?[3]u8, null), try sampleIteratorWeightedArray(u8, failing, 3, &weighted_array_two_positive_too_many));
    var weighted_array_two_positive_too_many_checked = WeightedIter{ .items = &weighted_two_positive_entries };
    try std.testing.expectError(error.InvalidParameter, sampleIteratorWeightedArrayChecked(u8, failing, 3, &weighted_array_two_positive_too_many_checked));
    var weighted_array_bad = WeightedIter{ .items = &weighted_bad_entries };
    try std.testing.expectError(error.InvalidWeight, sampleIteratorWeightedArray(u8, failing, 1, &weighted_array_bad));
    var weighted_array_bad_checked = WeightedIter{ .items = &weighted_bad_entries };
    try std.testing.expectError(error.InvalidWeight, sampleIteratorWeightedArrayChecked(u8, failing, 1, &weighted_array_bad_checked));
    var weighted_array_entropy = WeightedIter{ .items = &weighted_entropy_entries };
    try std.testing.expectError(error.EntropyUnavailable, sampleIteratorWeightedArray(u8, failing, 1, &weighted_array_entropy));
    var weighted_array_entropy_checked = WeightedIter{ .items = &weighted_entropy_entries };
    try std.testing.expectError(error.EntropyUnavailable, sampleIteratorWeightedArrayChecked(u8, failing, 1, &weighted_array_entropy_checked));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndex(failing, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexChecked(failing, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexByIndex(f64, failing, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexByIndexChecked(f64, failing, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesByIndex(f64, failing, std.testing.allocator, 2, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesByIndexChecked(f64, failing, std.testing.allocator, 2, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesU32ByIndex(f64, failing, std.testing.allocator, 2, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesU32ByIndexChecked(f64, failing, std.testing.allocator, 2, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexVecByIndex(f64, failing, std.testing.allocator, 2, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexVecByIndexChecked(f64, failing, std.testing.allocator, 2, 2, RootByIndexWeights.weight));
    var weighted_indices_by_index_entropy: [2]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesByIndexInto(f64, failing, 2, &weighted_indices_by_index_entropy, &weighted_indices_entropy_keys, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesByIndexIntoChecked(f64, failing, 2, &weighted_indices_by_index_entropy, &weighted_indices_entropy_keys, RootByIndexWeights.weight));
    var weighted_indices_u32_by_index_entropy: [2]u32 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesU32ByIndexInto(f64, failing, 2, &weighted_indices_u32_by_index_entropy, &weighted_indices_entropy_keys, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndicesU32ByIndexIntoChecked(f64, failing, 2, &weighted_indices_u32_by_index_entropy, &weighted_indices_entropy_keys, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexArrayByIndex(f64, failing, 2, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexArrayByIndexChecked(f64, failing, 2, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexArrayU32ByIndex(f64, failing, 2, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, sampleWeightedIndexArrayU32ByIndexChecked(f64, failing, 2, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexBy(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexByChecked(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32By(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32ByChecked(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], RootItemWeights.weight));
    var weighted_by_entropy: [1]?usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndexBy(RootItemWeights.Entry, f64, failing, &weighted_by_entropy, weighted_by_items[0..2], RootItemWeights.weight));
    var weighted_by_checked_entropy: [1]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndexByChecked(RootItemWeights.Entry, f64, failing, &weighted_by_checked_entropy, weighted_by_items[0..2], RootItemWeights.weight));
    var weighted_u32_by_entropy: [1]?u32 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndexU32By(RootItemWeights.Entry, f64, failing, &weighted_u32_by_entropy, weighted_by_items[0..2], RootItemWeights.weight));
    var weighted_u32_by_checked_entropy: [1]u32 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndexU32ByChecked(RootItemWeights.Entry, f64, failing, &weighted_u32_by_checked_entropy, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32BatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32BatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexArrayBy(RootItemWeights.Entry, f64, failing, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexArrayByChecked(RootItemWeights.Entry, f64, failing, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32ArrayBy(RootItemWeights.Entry, f64, failing, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32ArrayByChecked(RootItemWeights.Entry, f64, failing, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedBy(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedByChecked(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrBy(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrByChecked(RootItemWeights.Entry, f64, failing, weighted_by_items[0..2], RootItemWeights.weight));
    var weighted_by_mut_entropy_items = weighted_by_items;
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrBy(RootItemWeights.Entry, f64, failing, weighted_by_mut_entropy_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrByChecked(RootItemWeights.Entry, f64, failing, weighted_by_mut_entropy_items[0..2], RootItemWeights.weight));
    var weighted_value_by_entropy: [1]?RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedBy(RootItemWeights.Entry, f64, failing, &weighted_value_by_entropy, weighted_by_items[0..2], RootItemWeights.weight));
    var weighted_value_by_checked_entropy: [1]RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedByChecked(RootItemWeights.Entry, f64, failing, &weighted_value_by_checked_entropy, weighted_by_items[0..2], RootItemWeights.weight));
    var weighted_const_ptr_by_entropy: [1]?*const RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedConstPtrBy(RootItemWeights.Entry, f64, failing, &weighted_const_ptr_by_entropy, weighted_by_items[0..2], RootItemWeights.weight));
    var weighted_const_ptr_by_checked_entropy: [1]*const RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedConstPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_const_ptr_by_checked_entropy, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedValueArrayBy(RootItemWeights.Entry, f64, failing, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedValueArrayByChecked(RootItemWeights.Entry, f64, failing, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrArrayBy(RootItemWeights.Entry, f64, failing, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 1, weighted_by_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 1, weighted_by_items[0..2], RootItemWeights.weight));
    var weighted_mut_ptr_by_entropy_items = weighted_by_items;
    var weighted_mut_ptr_by_entropy: [1]?*RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedPtrBy(RootItemWeights.Entry, f64, failing, &weighted_mut_ptr_by_entropy, weighted_mut_ptr_by_entropy_items[0..2], RootItemWeights.weight));
    var weighted_mut_ptr_by_checked_entropy: [1]*RootItemWeights.Entry = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedPtrByChecked(RootItemWeights.Entry, f64, failing, &weighted_mut_ptr_by_checked_entropy, weighted_mut_ptr_by_entropy_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrBatchBy(RootItemWeights.Entry, f64, failing, std.testing.allocator, 1, weighted_mut_ptr_by_entropy_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrBatchByChecked(RootItemWeights.Entry, f64, failing, std.testing.allocator, 1, weighted_mut_ptr_by_entropy_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrArrayBy(RootItemWeights.Entry, f64, failing, 1, weighted_mut_ptr_by_entropy_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrArrayByChecked(RootItemWeights.Entry, f64, failing, 1, weighted_mut_ptr_by_entropy_items[0..2], RootItemWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32ByIndex(f64, failing, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32ByIndexChecked(f64, failing, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedByIndex(u8, f64, failing, &.{ 1, 2 }, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedByIndexChecked(u8, f64, failing, &.{ 1, 2 }, RootByIndexWeights.weight));
    var weighted_value_by_index_entropy: [1]?u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedByIndex(u8, f64, failing, &weighted_value_by_index_entropy, &.{ 1, 2 }, RootByIndexWeights.weight));
    var weighted_value_by_index_checked_entropy: [1]u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedByIndexChecked(u8, f64, failing, &weighted_value_by_index_checked_entropy, &.{ 1, 2 }, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedBatchByIndex(u8, f64, failing, std.testing.allocator, 1, &.{ 1, 2 }, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 1, &.{ 1, 2 }, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedValueArrayByIndex(u8, f64, failing, 1, &.{ 1, 2 }, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedValueArrayByIndexChecked(u8, f64, failing, 1, &.{ 1, 2 }, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrByIndex(u8, f64, failing, &.{ 1, 2 }, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrByIndexChecked(u8, f64, failing, &.{ 1, 2 }, RootByIndexWeights.weight));
    var weighted_const_ptr_by_index_entropy: [1]?*const u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedConstPtrByIndex(u8, f64, failing, &weighted_const_ptr_by_index_entropy, &.{ 1, 2 }, RootByIndexWeights.weight));
    var weighted_const_ptr_by_index_checked_entropy: [1]*const u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedConstPtrByIndexChecked(u8, f64, failing, &weighted_const_ptr_by_index_checked_entropy, &.{ 1, 2 }, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrBatchByIndex(u8, f64, failing, std.testing.allocator, 1, &.{ 1, 2 }, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 1, &.{ 1, 2 }, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrArrayByIndex(u8, f64, failing, 1, &.{ 1, 2 }, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrArrayByIndexChecked(u8, f64, failing, 1, &.{ 1, 2 }, RootByIndexWeights.weight));
    var weighted_mut_by_index_pair = [_]u8{ 1, 2 };
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrByIndex(u8, f64, failing, &weighted_mut_by_index_pair, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrByIndexChecked(u8, f64, failing, &weighted_mut_by_index_pair, RootByIndexWeights.weight));
    var weighted_mut_ptr_by_index_entropy: [1]?*u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedPtrByIndex(u8, f64, failing, &weighted_mut_ptr_by_index_entropy, &weighted_mut_by_index_pair, RootByIndexWeights.weight));
    var weighted_mut_ptr_by_index_checked_entropy: [1]*u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedPtrByIndexChecked(u8, f64, failing, &weighted_mut_ptr_by_index_checked_entropy, &weighted_mut_by_index_pair, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrBatchByIndex(u8, f64, failing, std.testing.allocator, 1, &weighted_mut_by_index_pair, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrBatchByIndexChecked(u8, f64, failing, std.testing.allocator, 1, &weighted_mut_by_index_pair, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrArrayByIndex(u8, f64, failing, 1, &weighted_mut_by_index_pair, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrArrayByIndexChecked(u8, f64, failing, 1, &weighted_mut_by_index_pair, RootByIndexWeights.weight));
    var by_index_entropy: [1]?usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndexByIndex(f64, failing, &by_index_entropy, 2, RootByIndexWeights.weight));
    var by_index_checked_entropy: [1]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndexByIndexChecked(f64, failing, &by_index_checked_entropy, 2, RootByIndexWeights.weight));
    var by_index_u32_entropy: [1]?u32 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndexU32ByIndex(f64, failing, &by_index_u32_entropy, 2, RootByIndexWeights.weight));
    var by_index_u32_checked_entropy: [1]u32 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndexU32ByIndexChecked(f64, failing, &by_index_u32_checked_entropy, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexBatchByIndex(f64, failing, std.testing.allocator, 1, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexBatchByIndexChecked(f64, failing, std.testing.allocator, 1, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32BatchByIndex(f64, failing, std.testing.allocator, 1, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32BatchByIndexChecked(f64, failing, std.testing.allocator, 1, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexArrayByIndex(f64, failing, 1, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexArrayByIndexChecked(f64, failing, 1, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32ArrayByIndex(f64, failing, 1, 2, RootByIndexWeights.weight));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32ArrayByIndexChecked(f64, failing, 1, 2, RootByIndexWeights.weight));
    var weighted_one: [1]?usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndex(failing, &weighted_one, &.{ 1, 2 }));
    var weighted_checked_one: [1]usize = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndexChecked(failing, &weighted_checked_one, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexBatch(failing, std.testing.allocator, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexBatchChecked(failing, std.testing.allocator, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32(failing, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32Checked(failing, &.{ 1, 2 }));
    var weighted_u32_one: [1]?u32 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndexU32(failing, &weighted_u32_one, &.{ 1, 2 }));
    var weighted_u32_checked_one: [1]u32 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillWeightedIndexU32Checked(failing, &weighted_u32_checked_one, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32Batch(failing, std.testing.allocator, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32BatchChecked(failing, std.testing.allocator, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexArray(failing, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexArrayChecked(failing, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32Array(failing, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, weightedIndexU32ArrayChecked(failing, 1, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeighted(u8, failing, &.{ 1, 2 }, &.{ 1, 2 }));
    var weighted_choice_one: [1]?u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeighted(u8, failing, &weighted_choice_one, &.{ 1, 2 }, &.{ 1, 2 }));
    var weighted_choice_checked_one: [1]u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedChecked(u8, failing, &weighted_choice_checked_one, &.{ 1, 2 }, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedBatch(u8, failing, std.testing.allocator, 1, &.{ 1, 2 }, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedBatchChecked(u8, failing, std.testing.allocator, 1, &.{ 1, 2 }, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedValueArray(u8, failing, 1, &.{ 1, 2 }, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedValueArrayChecked(u8, failing, 1, &.{ 1, 2 }, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtr(u8, failing, &.{ 1, 2 }, &.{ 1, 2 }));
    var weighted_const_ptr_one: [1]?*const u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedConstPtr(u8, failing, &weighted_const_ptr_one, &.{ 1, 2 }, &.{ 1, 2 }));
    var weighted_const_ptr_checked_one: [1]*const u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedConstPtrChecked(u8, failing, &weighted_const_ptr_checked_one, &.{ 1, 2 }, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrBatch(u8, failing, std.testing.allocator, 1, &.{ 1, 2 }, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrBatchChecked(u8, failing, std.testing.allocator, 1, &.{ 1, 2 }, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrArray(u8, failing, 1, &.{ 1, 2 }, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedConstPtrArrayChecked(u8, failing, 1, &.{ 1, 2 }, &.{ 1, 2 }));
    var weighted_mut_pair = [_]u8{ 1, 2 };
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtr(u8, failing, &weighted_mut_pair, &.{ 1, 2 }));
    var weighted_ptr_one: [1]?*u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedPtr(u8, failing, &weighted_ptr_one, &weighted_mut_pair, &.{ 1, 2 }));
    var weighted_ptr_checked_one: [1]*u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fillChooseWeightedPtrChecked(u8, failing, &weighted_ptr_checked_one, &weighted_mut_pair, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrBatch(u8, failing, std.testing.allocator, 1, &weighted_mut_pair, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrBatchChecked(u8, failing, std.testing.allocator, 1, &weighted_mut_pair, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrArray(u8, failing, 1, &weighted_mut_pair, &.{ 1, 2 }));
    try std.testing.expectError(error.EntropyUnavailable, chooseWeightedPtrArrayChecked(u8, failing, 1, &weighted_mut_pair, &.{ 1, 2 }));
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
