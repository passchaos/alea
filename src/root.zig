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

pub const SplitMix64 = @import("engines/splitmix64.zig");
pub const Wyhash64 = @import("engines/wyhash64.zig");
pub const Alea4x64 = @import("engines/alea4x64.zig");
pub const Xoshiro256PlusPlus = @import("engines/xoshiro256plusplus.zig");
pub const Xoshiro256 = @import("engines/xoshiro256.zig");
pub const Pcg64 = @import("engines/pcg64.zig");
pub const ChaCha = @import("engines/chacha.zig");

pub const DefaultPrng = Xoshiro256;
pub const FastPrng = Alea4x64;
pub const ScalarPrng = Wyhash64;
pub const HashPrng = Wyhash64;
pub const ReproduciblePrng = Pcg64;
pub const SecurePrng = ChaCha;

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

fn engineFromSeed(comptime Engine: type, seed: u64) Engine {
    if (comptime Engine == ChaCha) return Engine.initFromU64(seed);
    return Engine.init(seed);
}

fn expectFullEngineRawAliases(comptime Engine: type, seed: u64) !void {
    var direct_u64 = engineFromSeed(Engine, seed);
    var alias_u64 = engineFromSeed(Engine, seed);
    try std.testing.expectEqual(direct_u64.next(), alias_u64.nextU64());

    var direct_u32 = engineFromSeed(Engine, seed);
    var alias_u32 = engineFromSeed(Engine, seed);
    try std.testing.expectEqual(@as(u32, @truncate(direct_u32.next() >> 32)), alias_u32.nextU32());

    var direct_fill = engineFromSeed(Engine, seed);
    var alias_fill = engineFromSeed(Engine, seed);
    var direct_bytes: [23]u8 = undefined;
    var alias_bytes: [23]u8 = undefined;
    direct_fill.fill(&direct_bytes);
    alias_fill.fillBytes(&alias_bytes);
    try std.testing.expectEqualSlices(u8, &direct_bytes, &alias_bytes);
}

test "engine raw aliases preserve stream shape" {
    const seed: u64 = 0x5150_f00d_dead_beef;

    inline for (.{ Alea4x64, Wyhash64, Xoshiro256, Xoshiro256PlusPlus, Pcg64, ChaCha }) |Engine| {
        try expectFullEngineRawAliases(Engine, seed);
    }

    var splitmix_direct_u64 = SplitMix64.init(seed);
    var splitmix_alias_u64 = SplitMix64.init(seed);
    try std.testing.expectEqual(splitmix_direct_u64.next(), splitmix_alias_u64.nextU64());

    var splitmix_direct_u32 = SplitMix64.init(seed);
    var splitmix_alias_u32 = SplitMix64.init(seed);
    try std.testing.expectEqual(@as(u32, @truncate(splitmix_direct_u32.next() >> 32)), splitmix_alias_u32.nextU32());
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

fn expectEngineFromRngAlias(comptime Engine: type, seed: u64) !void {
    var direct_source = ScalarPrng.init(seed);
    var alias_source = ScalarPrng.init(seed);
    var direct = engineFromSeed(Engine, direct_source.next());
    var alias = Engine.fromRng(&alias_source);
    try std.testing.expectEqual(direct.next(), alias.next());
    try std.testing.expectEqual(direct_source.next(), alias_source.next());
}

fn expectEngineForkAlias(comptime Engine: type, seed: u64) !void {
    var direct_parent = engineFromSeed(Engine, seed);
    var alias_parent = engineFromSeed(Engine, seed);
    var direct_child = engineFromSeed(Engine, direct_parent.next());
    var alias_child = alias_parent.fork();
    try std.testing.expectEqual(direct_child.next(), alias_child.next());
    try std.testing.expectEqual(direct_parent.next(), alias_parent.next());
}

test "engine fromRng and fork aliases consume one seed draw" {
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
    }
}
