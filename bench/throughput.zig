const std = @import("std");
const alea = @import("alea");

const MiB = 1024 * 1024;
const trials = 3;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const bytes: usize = 128 * MiB;
    var buffer: [4096]u8 = undefined;

    try stdout.print("byte throughput\n", .{});
    try benchEngine(io, stdout, "alea4x64", alea.Alea4x64, bytes, &buffer);
    try benchEngine(io, stdout, "xoshiro256++", alea.Xoshiro256PlusPlus, bytes, &buffer);
    try benchEngine(io, stdout, "wyhash64", alea.Wyhash64, bytes, &buffer);
    try benchEngine(io, stdout, "xoshiro256**", alea.Xoshiro256, bytes, &buffer);
    try benchEngine(io, stdout, "pcg64", alea.Pcg64, bytes, &buffer);
    try benchEngine(io, stdout, "chacha12", alea.ChaCha, bytes, &buffer);
    try stdout.print("\nfill-only throughput\n", .{});
    try benchFillOnly(io, stdout, "alea4x64 fill-only", alea.Alea4x64, bytes, &buffer);
    try benchFillOnly(io, stdout, "xoshiro256++ fill-only", alea.Xoshiro256PlusPlus, bytes, &buffer);
    try stdout.print("\nrange throughput\n", .{});
    try benchRangeFacade(io, stdout, "alea bounded u32 facade", bytes / 8);
    try benchRangeDirect(io, stdout, "alea bounded u32 direct", bytes / 8);
    try stdout.print("\nsequence throughput\n", .{});
    try benchSeqFacade(io, stdout, "alea sample indices facade", 1_000_000, 10_000);
    try benchSeqDirect(io, stdout, "alea sample indices direct", 1_000_000, 10_000);
    try benchSeqIndexVecFacade(io, stdout, "alea sample index vec facade", 1_000_000, 10_000);
    try benchSeqIndexVecDirect(io, stdout, "alea sample index vec direct", 1_000_000, 10_000);
    try benchSeqU32Facade(io, stdout, "alea sample indices u32 facade", 1_000_000, 10_000);
    try benchSeqU32Direct(io, stdout, "alea sample indices u32 direct", 1_000_000, 10_000);
    try stdout.print("\ndistribution throughput\n", .{});
    try benchBernoulli(io, stdout, "alea bernoulli", bytes / 64);
    try benchNormal(io, stdout, "alea normal", bytes / 64);
    try benchExponential(io, stdout, "alea exponential", bytes / 64);
    try benchPoisson(io, stdout, "alea poisson", bytes / 64);
    try benchBinomial(io, stdout, "alea binomial", bytes / 64);
    try benchBinomialLarge(io, stdout, "alea binomial large", bytes / 256);
    try benchBinomialApprox(io, stdout, "alea binomial poisson approx", bytes / 256);
    try benchNegativeBinomial(io, stdout, "alea negative-binomial", bytes / 128);
    try benchHypergeometric(io, stdout, "alea hypergeometric", bytes / 128);
    try benchMultinomial(io, stdout, "alea multinomial", bytes / 512);
    try benchGamma(io, stdout, "alea gamma", bytes / 128);
    try benchChiSquared(io, stdout, "alea chi-squared", bytes / 128);
    try benchBeta(io, stdout, "alea beta", bytes / 128);
    try benchFisherF(io, stdout, "alea fisher-f", bytes / 128);
    try benchTriangular(io, stdout, "alea triangular", bytes / 128);
    try benchCauchy(io, stdout, "alea cauchy", bytes / 128);
    try benchDirichlet(io, stdout, "alea dirichlet", bytes / 512);
    try benchLogNormal(io, stdout, "alea log-normal", bytes / 128);
    try benchStudentT(io, stdout, "alea student-t", bytes / 128);
    try benchPareto(io, stdout, "alea pareto", bytes / 128);
    try benchWeibull(io, stdout, "alea weibull", bytes / 128);
    try benchGumbel(io, stdout, "alea gumbel", bytes / 128);
    try benchFrechet(io, stdout, "alea frechet", bytes / 128);
    try benchSkewNormal(io, stdout, "alea skew-normal", bytes / 128);
    try benchPert(io, stdout, "alea pert", bytes / 128);
    try benchUnitCircle(io, stdout, "alea unit circle", bytes / 128);
    try benchUnitDisc(io, stdout, "alea unit disc", bytes / 128);
    try benchUnitSphere(io, stdout, "alea unit sphere", bytes / 128);
    try benchUnitBall(io, stdout, "alea unit ball", bytes / 128);
    try benchInverseGaussian(io, stdout, "alea inverse-gaussian", bytes / 128);
    try benchNormalInverseGaussian(io, stdout, "alea normal-inverse-gaussian", bytes / 128);
    try benchZipf(io, stdout, "alea zipf", bytes / 128);
    try benchZeta(io, stdout, "alea zeta", bytes / 128);
    try stdout.flush();
}

fn benchEngine(io: std.Io, stdout: *std.Io.Writer, name: []const u8, comptime Engine: type, bytes: usize, buffer: []u8) !void {
    var best_mib_per_s: f64 = 0;
    var best_checksum: u8 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = if (Engine == alea.ChaCha) Engine.initFromU64(0x1234_5678) else Engine.init(0x1234_5678);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = bytes;
        var checksum: u8 = 0;
        while (remaining > 0) {
            const n = @min(buffer.len, remaining);
            engine.fill(buffer[0..n]);
            for (buffer[0..n]) |byte| checksum ^= byte;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const mib_per_s = (@as(f64, @floatFromInt(bytes)) / @as(f64, @floatFromInt(MiB))) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (mib_per_s > best_mib_per_s) {
            best_mib_per_s = mib_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} MiB/s checksum={}\n", .{ name, best_mib_per_s, best_checksum });
}

fn benchFillOnly(io: std.Io, stdout: *std.Io.Writer, name: []const u8, comptime Engine: type, bytes: usize, buffer: []u8) !void {
    var best_mib_per_s: f64 = 0;
    var best_tail: u8 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = if (Engine == alea.ChaCha) Engine.initFromU64(0x1234_5678) else Engine.init(0x1234_5678);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = bytes;
        while (remaining > 0) {
            const n = @min(buffer.len, remaining);
            engine.fill(buffer[0..n]);
            std.mem.doNotOptimizeAway(buffer.ptr);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const mib_per_s = (@as(f64, @floatFromInt(bytes)) / @as(f64, @floatFromInt(MiB))) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (mib_per_s > best_mib_per_s) {
            best_mib_per_s = mib_per_s;
            best_tail = buffer[buffer.len - 1];
        }
    }

    try stdout.print("{s}: {d:.1} MiB/s tail={}\n", .{ name, best_mib_per_s, best_tail });
}

fn benchRangeFacade(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x9999);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) {
            checksum +%= rng.uintLessThan(u32, 1_000_003);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchRangeDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x9999);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) {
            checksum +%= alea.Rng.uintLessThanFrom(&engine, u32, 1_000_003);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchSeqFacade(io: std.Io, stdout: *std.Io.Writer, name: []const u8, length: usize, amount: usize) !void {
    var best_thousand_per_s: f64 = 0;
    var best_checksum: usize = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xabcd);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        const indices = try alea.seq.sampleIndices(std.heap.smp_allocator, rng, length, amount);
        defer std.heap.smp_allocator.free(indices);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        var checksum: usize = 0;
        for (indices) |index| checksum +%= index;
        const thousand_per_s = (@as(f64, @floatFromInt(amount)) / 1_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (thousand_per_s > best_thousand_per_s) {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} K chosen/s checksum={}\n", .{ name, best_thousand_per_s, best_checksum });
}

fn benchSeqDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, length: usize, amount: usize) !void {
    var best_thousand_per_s: f64 = 0;
    var best_checksum: usize = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xabcd);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        const indices = try alea.seq.sampleIndicesFrom(std.heap.smp_allocator, &engine, length, amount);
        defer std.heap.smp_allocator.free(indices);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        var checksum: usize = 0;
        for (indices) |index| checksum +%= index;
        const thousand_per_s = (@as(f64, @floatFromInt(amount)) / 1_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (thousand_per_s > best_thousand_per_s) {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} K chosen/s checksum={}\n", .{ name, best_thousand_per_s, best_checksum });
}

fn benchSeqIndexVecFacade(io: std.Io, stdout: *std.Io.Writer, name: []const u8, length: usize, amount: usize) !void {
    var best_thousand_per_s: f64 = 0;
    var best_checksum: usize = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xabcd);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        const indices = try alea.seq.sampleIndexVec(std.heap.smp_allocator, rng, length, amount);
        defer indices.deinit(std.heap.smp_allocator);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        var checksum: usize = 0;
        var i: usize = 0;
        while (i < indices.len()) : (i += 1) checksum +%= indices.at(i);
        const thousand_per_s = (@as(f64, @floatFromInt(amount)) / 1_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (thousand_per_s > best_thousand_per_s) {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} K chosen/s checksum={}\n", .{ name, best_thousand_per_s, best_checksum });
}

fn benchSeqIndexVecDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, length: usize, amount: usize) !void {
    var best_thousand_per_s: f64 = 0;
    var best_checksum: usize = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xabcd);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        const indices = try alea.seq.sampleIndexVecFrom(std.heap.smp_allocator, &engine, length, amount);
        defer indices.deinit(std.heap.smp_allocator);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        var checksum: usize = 0;
        var i: usize = 0;
        while (i < indices.len()) : (i += 1) checksum +%= indices.at(i);
        const thousand_per_s = (@as(f64, @floatFromInt(amount)) / 1_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (thousand_per_s > best_thousand_per_s) {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} K chosen/s checksum={}\n", .{ name, best_thousand_per_s, best_checksum });
}

fn benchSeqU32Facade(io: std.Io, stdout: *std.Io.Writer, name: []const u8, length: u32, amount: u32) !void {
    var best_thousand_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xabcd);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        const indices = try alea.seq.sampleIndicesU32(std.heap.smp_allocator, rng, length, amount);
        defer std.heap.smp_allocator.free(indices);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        var checksum: u64 = 0;
        for (indices) |index| checksum +%= index;
        const thousand_per_s = (@as(f64, @floatFromInt(amount)) / 1_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (thousand_per_s > best_thousand_per_s) {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} K chosen/s checksum={}\n", .{ name, best_thousand_per_s, best_checksum });
}

fn benchSeqU32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, length: u32, amount: u32) !void {
    var best_thousand_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xabcd);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        const indices = try alea.seq.sampleIndicesU32From(std.heap.smp_allocator, &engine, length, amount);
        defer std.heap.smp_allocator.free(indices);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        var checksum: u64 = 0;
        for (indices) |index| checksum +%= index;
        const thousand_per_s = (@as(f64, @floatFromInt(amount)) / 1_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (thousand_per_s > best_thousand_per_s) {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} K chosen/s checksum={}\n", .{ name, best_thousand_per_s, best_checksum });
}

fn benchNormal(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd15a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += rng.normal(f64, 0, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBernoulli(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Bernoulli.init(0.25) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xbe44);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum += @intFromBool(dist.sample(rng));
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchExponential(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xe15a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += rng.exponential(f64, 2);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchPoisson(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xa157);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= alea.distributions.poisson(rng, 20);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBinomial(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xb157);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= alea.distributions.binomial(rng, 40, 0.25);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBinomialLarge(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xb16c);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= alea.distributions.binomial(rng, 10_000, 0.01);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBinomialApprox(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xb16a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= alea.distributions.binomialPoissonApprox(rng, 10_000, 0.01);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNegativeBinomial(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.NegativeBinomial.init(5, 0.4) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x5e6b);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchHypergeometric(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Hypergeometric.init(100, 30, 10) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x4965);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchMultinomial(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Multinomial.init(100, &.{ 1.0, 2.0, 3.0 }) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x4111);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) {
            var out: [3]u64 = undefined;
            dist.sampleInto(rng, &out);
            checksum +%= out[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchGamma(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6a44a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.gamma(rng, f64, 2, 3);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchChiSquared(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc415);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.chiSquared(rng, f64, 4);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBeta(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xbe7a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.beta(rng, f64, 2, 5);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFisherF(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf15c);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.fisherF(rng, f64, 5, 20);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchTriangular(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x751a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.triangular(rng, f64, -1, 0, 2);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchCauchy(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xca11);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.cauchy(rng, f64, 0, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchDirichlet(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const alpha = [_]f64{ 1, 2, 3 };
    const dist = alea.distributions.Dirichlet(f64).init(&alpha) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd151);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) {
            const sample = try dist.sample(std.heap.smp_allocator, rng);
            defer std.heap.smp_allocator.free(sample);
            checksum += sample[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchLogNormal(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x1060);
        const rng = alea.Rng.init(&engine);
        var dist = alea.distributions.LogNormal(f64).init(0, 0.25) catch unreachable;
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchStudentT(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x57dd);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.studentT(rng, f64, 10);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchPareto(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x9a7e70);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.pareto(rng, f64, 2, 3);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchWeibull(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x8e1b);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.weibull(rng, f64, 2, 1.5);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchGumbel(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6cbe1);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.gumbel(rng, f64, 0, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFrechet(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf7ec);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.frechet(rng, f64, 0, 1, 3);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchSkewNormal(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x5ce9);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.skewNormal(rng, f64, 0, 1, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchPert(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x9e71);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.pert(rng, f64, -1, 0.5, 2, 4);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnitCircle(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc11c1e);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) {
            const value = alea.distributions.unitCircle(rng, f64);
            checksum += value[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnitDisc(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd15c);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) {
            const value = alea.distributions.unitDisc(rng, f64);
            checksum += value[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnitSphere(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x59e7e);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) {
            const value = alea.distributions.unitSphere(rng, f64);
            checksum += value[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnitBall(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xba11);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) {
            const value = alea.distributions.unitBall(rng, f64);
            checksum += value[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchInverseGaussian(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x164a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.inverseGaussian(rng, f64, 1, 2);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNormalInverseGaussian(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x916a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.normalInverseGaussian(rng, f64, 2, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchZipf(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Zipf(f64).init(10, 1.5) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x719f);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchZeta(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Zeta(f64).init(3) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x7e7a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}
