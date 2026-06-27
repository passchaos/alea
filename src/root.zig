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

pub const SplitMix64 = @import("engines/splitmix64.zig");
pub const Wyhash64 = @import("engines/wyhash64.zig");
pub const Alea4x64 = @import("engines/alea4x64.zig");
pub const Xoshiro256PlusPlus = @import("engines/xoshiro256plusplus.zig");
pub const Xoshiro256 = @import("engines/xoshiro256.zig");
pub const Pcg64 = @import("engines/pcg64.zig");
pub const ChaCha = @import("engines/chacha.zig");

pub const DefaultPrng = Xoshiro256;
pub const FastPrng = Alea4x64;
pub const HashPrng = Wyhash64;
pub const ReproduciblePrng = Pcg64;
pub const SecurePrng = ChaCha;

pub fn default(seed: u64) DefaultPrng {
    return DefaultPrng.init(seed);
}

pub fn fast(seed: u64) FastPrng {
    return FastPrng.init(seed);
}

pub fn reproducible(seed: u64) ReproduciblePrng {
    return ReproduciblePrng.init(seed);
}

pub fn secureFromSeed(seed: u64) SecurePrng {
    return SecurePrng.initFromU64(seed);
}

pub fn secure(io: std.Io) !SecurePrng {
    var seed_bytes: [SecurePrng.seed_length]u8 = undefined;
    try std.Io.randomSecure(io, &seed_bytes);
    return SecurePrng.init(seed_bytes);
}

pub fn rng(engine: anytype) Rng {
    return Rng.init(engine);
}

test {
    std.testing.refAllDecls(@This());
}
