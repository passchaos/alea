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
    try std.testing.expectError(error.EmptyRange, fillRangeChecked(u8, failing, &collapsed_exclusive, 3, 3));
    try std.testing.expectError(error.EmptyRange, fillRangeAtMostChecked(u8, failing, &collapsed_inclusive, 6, 5));
    try std.testing.expectError(error.InvalidProbability, fillRandomBoolChecked(failing, &deterministic_bool, 1.1));
    try std.testing.expectError(error.InvalidProbability, fillRandomRatioChecked(failing, &deterministic_bool, 2, 1));

    try std.testing.expectError(error.EntropyUnavailable, randomValue(u8, failing));
    try std.testing.expectError(error.EntropyUnavailable, randomRangeChecked(u8, failing, 3, 5));
    try std.testing.expectError(error.EntropyUnavailable, randomIter(u8, failing));
    var byte: [1]u8 = undefined;
    try std.testing.expectError(error.EntropyUnavailable, fill(u8, failing, &byte));
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
