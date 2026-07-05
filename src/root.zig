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
pub const seq = @import("seq.zig");
pub const ascii = @import("ascii.zig");
pub const quality = @import("quality.zig");
pub const SysRng = Rng.SysRng;

pub const SplitMix64 = @import("engines/splitmix64.zig");
pub const Wyhash64 = @import("engines/wyhash64.zig");
pub const Alea4x64 = @import("engines/alea4x64.zig");
pub const Xoshiro256PlusPlus = @import("engines/xoshiro256plusplus.zig");
pub const Xoshiro256 = @import("engines/xoshiro256.zig");
pub const Pcg64 = @import("engines/pcg64.zig");
pub const ChaCha = @import("engines/chacha.zig");
pub const StepRng = @import("engines/step.zig");

pub const DefaultPrng = Xoshiro256;
pub const FastPrng = Alea4x64;
pub const ScalarPrng = Wyhash64;
pub const HashPrng = Wyhash64;
pub const ReproduciblePrng = Pcg64;
pub const SecurePrng = ChaCha;
pub const StdRng = SecurePrng;
pub const SmallRng = Xoshiro256PlusPlus;

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
    if (comptime Engine == Pcg64) {
        var seed_bytes: [16]u8 = undefined;
        try std.Io.randomSecure(io, &seed_bytes);
        return Engine.fromSeedBytes(seed_bytes);
    }
    if (comptime Engine == Alea4x64 or Engine == Xoshiro256 or Engine == Xoshiro256PlusPlus) {
        var seed_bytes: [32]u8 = undefined;
        try std.Io.randomSecure(io, &seed_bytes);
        return Engine.fromSeedBytes(seed_bytes);
    }
    if (comptime Engine == ChaCha) {
        var seed_bytes: [ChaCha.seed_length]u8 = undefined;
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
}

fn engineFromSeed(comptime Engine: type, seed: u64) Engine {
    if (comptime Engine == ChaCha) return Engine.initFromU64(seed);
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

    inline for (.{ Alea4x64, Wyhash64, Xoshiro256, Xoshiro256PlusPlus, Pcg64, ChaCha }) |Engine| {
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
}

fn expectEngineSeedFromU64Alias(comptime Engine: type, seed: u64) !void {
    var direct = engineFromSeed(Engine, seed);
    var alias = Engine.seedFromU64(seed);
    try std.testing.expectEqual(direct.next(), alias.next());
}

test "engine seedFromU64 aliases mirror constructors" {
    const seed: u64 = 0x5150_5eed_1234_5678;

    inline for (.{ SplitMix64, Alea4x64, Wyhash64, Xoshiro256, Xoshiro256PlusPlus, Pcg64, ChaCha }) |Engine| {
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

    inline for (.{ SplitMix64, Alea4x64, Wyhash64, Xoshiro256, Xoshiro256PlusPlus, Pcg64, ChaCha }) |Engine| {
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
    if (comptime Engine == Pcg64) {
        return Pcg64.initTwo(seedWord(seed, 0), seedWord(seed, 1));
    }
    if (comptime Engine == ChaCha) {
        return ChaCha.init(seed);
    }
    @compileError("unsupported engine");
}

fn seedWord(seed: anytype, comptime index: usize) u64 {
    return std.mem.readInt(u64, seed[index * 8 ..][0..8], .little);
}

fn xoshiro256StateIsZero(state: [4]u64) bool {
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
    try expectEngineFromSeedBytesAlias(Alea4x64, seed32);
    try expectEngineFromSeedBytesAlias(Xoshiro256, seed32);
    try expectEngineFromSeedBytesAlias(Xoshiro256PlusPlus, seed32);
    try expectEngineFromSeedBytesAlias(ChaCha, seed32);

    const zero_seed = [_]u8{0} ** 32;
    var xoshiro_zero_direct = Xoshiro256.init(0);
    var xoshiro_zero_alias = Xoshiro256.fromSeedBytes(zero_seed);
    try std.testing.expectEqual(xoshiro_zero_direct.next(), xoshiro_zero_alias.next());

    var xoshiro_pp_zero_direct = Xoshiro256PlusPlus.init(0);
    var xoshiro_pp_zero_alias = Xoshiro256PlusPlus.fromSeedBytes(zero_seed);
    try std.testing.expectEqual(xoshiro_pp_zero_direct.next(), xoshiro_pp_zero_alias.next());
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
    if (comptime Engine == ChaCha) {
        var key: [ChaCha.seed_length]u8 = undefined;
        var i: usize = 0;
        while (i < key.len) : (i += 8) {
            var bytes: [8]u8 = undefined;
            std.mem.writeInt(u64, &bytes, source.next(), .little);
            @memcpy(key[i..][0..8], &bytes);
        }
        return ChaCha.init(key);
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

    inline for (.{ SplitMix64, Alea4x64, Wyhash64, Xoshiro256, Xoshiro256PlusPlus, Pcg64, ChaCha }) |Engine| {
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
    if (comptime Engine == ChaCha) {
        var key: [ChaCha.seed_length]u8 = undefined;
        var i: usize = 0;
        while (i < key.len) : (i += 8) {
            var bytes: [8]u8 = undefined;
            std.mem.writeInt(u64, &bytes, try source.tryNext(), .little);
            @memcpy(key[i..][0..8], &bytes);
        }
        return ChaCha.init(key);
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

    inline for (.{Pcg64}) |Engine| {
        try expectEngineTryFromRngAlias(Engine, &words);
        try expectEngineTryFromRngFailure(Engine, &words, 1);
    }

    inline for (.{ Alea4x64, Xoshiro256, Xoshiro256PlusPlus, ChaCha }) |Engine| {
        try expectEngineTryFromRngAlias(Engine, &words);
        try expectEngineTryFromRngFailure(Engine, &words, 3);
    }
}
