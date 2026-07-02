const std = @import("std");
const alea = @import("alea");

const ziggurat = std.Random.ziggurat;
const trials = 3;

const norm_ratio = blk: {
    var out: [256]f64 = undefined;
    for (&out, 0..) |*item, i| item.* = ziggurat.NormDist.x[i + 1] / ziggurat.NormDist.x[i];
    break :blk out;
};

const exp_threshold = blk: {
    var out: [256]u64 = undefined;
    for (&out, 0..) |*item, i| {
        const threshold_ratio = ziggurat.ExpDist.x[i + 1] / ziggurat.ExpDist.x[i];
        item.* = @intFromFloat(@ceil(threshold_ratio * @as(f64, @floatFromInt(@as(u64, 1) << 52)) - 0.5));
    }
    break :blk out;
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const lanes: usize = 16 * 1024 * 1024;
    try stdout.print("vector microbench\n", .{});
    try benchFillVectorChanceBool(io, stdout, "alea fillVectorChance boolx64 p=0.25", lanes);
    try benchFillVectorRatioBool(io, stdout, "alea fillVectorRatio boolx64 1/4", lanes);
    try benchBoolX64(io, stdout, "alea distributions.fillVectorBernoulli boolx64 p=0.25", lanes, 0xb464, fillDistBernoulliBool);
    try benchBoolX64(io, stdout, "alea distributions.fillVectorBernoulli boolx64 direct p=0.25", lanes, 0xb464, fillDistBernoulliBoolDirect);
    try benchBoolX64(io, stdout, "alea distributions.VectorBernoulli.fill boolx64 p=0.25", lanes, 0xb464, fillDistBernoulliSamplerBool);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorBinomial u64x4 n=10 p=0.5", lanes / 4, 0xb150, fillDistBinomialU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorBinomial u64x4 direct n=10 p=0.5", lanes / 4, 0xb150, fillDistBinomialU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorBinomial.fill u64x4 n=10 p=0.5", lanes / 4, 0xb150, fillDistBinomialSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorNegativeBinomial u64x4 r=5 p=0.25", lanes / 16, 0xb180, fillDistNegativeBinomialU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorNegativeBinomial u64x4 direct r=5 p=0.25", lanes / 16, 0xb180, fillDistNegativeBinomialU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorNegativeBinomial.fill u64x4 r=5 p=0.25", lanes / 16, 0xb180, fillDistNegativeBinomialSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorHypergeometric u64x4", lanes / 8, 0xb190, fillDistHypergeometricU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorHypergeometric u64x4 direct", lanes / 8, 0xb190, fillDistHypergeometricU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorHypergeometric.fill u64x4", lanes / 8, 0xb190, fillDistHypergeometricSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorGeometric u64x4 p=0.25", lanes / 8, 0xb250, fillDistGeometricU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorGeometric u64x4 direct p=0.25", lanes / 8, 0xb250, fillDistGeometricU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorGeometric.fill u64x4 p=0.25", lanes / 8, 0xb250, fillDistGeometricSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorGeometricFailures u64x4 p=0.25", lanes / 8, 0xb251, fillDistGeometricFailuresU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorGeometricFailures u64x4 direct p=0.25", lanes / 8, 0xb251, fillDistGeometricFailuresU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorGeometricFailures.fill u64x4 p=0.25", lanes / 8, 0xb251, fillDistGeometricFailuresSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorStandardGeometric u64x4", lanes / 4, 0xb252, fillDistStandardGeometricU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorStandardGeometric u64x4 direct", lanes / 4, 0xb252, fillDistStandardGeometricU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorStandardGeometric.fill u64x4", lanes / 4, 0xb252, fillDistStandardGeometricSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorPoisson u64x4 lambda=12", lanes / 4, 0xb012, fillDistPoissonU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorPoisson u64x4 direct lambda=12", lanes / 4, 0xb012, fillDistPoissonU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorPoisson.fill u64x4 lambda=12", lanes / 4, 0xb012, fillDistPoissonSamplerU64);
    try benchFillVectorOpenF32(io, stdout, "alea fillVectorOpen f32x8", lanes);
    try benchFillVectorOpenClosedF32(io, stdout, "alea fillVectorOpenClosed f32x8", lanes);
    try benchFillVectorRangeF32(io, stdout, "alea fillVectorRange f32x8", lanes);
    try benchFillVectorF64(io, stdout, "alea fillVector f64x4", lanes);
    try benchFillVectorOpenF64(io, stdout, "alea fillVectorOpen f64x4", lanes);
    try benchFillVectorOpenClosedF64(io, stdout, "alea fillVectorOpenClosed f64x4", lanes);
    try benchFillVectorRangeF64(io, stdout, "alea fillVectorRange f64x4", lanes);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorUniform f32x8", lanes, 0xa118, fillDistUniformF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorUniform f32x8 direct", lanes, 0xa118, fillDistUniformF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.Open01.fill f32x8", lanes, 0xa119, fillDistOpen01F32);
    try benchVectorF64x4(io, stdout, "alea distributions.OpenClosed01.fill f64x4", lanes, 0xa11a, fillDistOpenClosed01F64);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardNormal f32x8", lanes / 4, 0xd188, fillDistStandardNormalF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardNormal f32x8 direct", lanes / 4, 0xd188, fillDistStandardNormalF32Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorNormal f64x4", lanes / 8, 0xd184, fillDistNormalF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorNormal f64x4 direct", lanes / 8, 0xd184, fillDistNormalF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorLogNormal f64x4", lanes / 16, 0xd194, fillDistLogNormalF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorLogNormal f64x4 direct", lanes / 16, 0xd194, fillDistLogNormalF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorLogNormal.fill f64x4", lanes / 16, 0xd194, fillDistLogNormalSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorHalfNormal f64x4", lanes / 8, 0xd1a4, fillDistHalfNormalF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorHalfNormal f64x4 direct", lanes / 8, 0xd1a4, fillDistHalfNormalF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorHalfNormal.fill f64x4", lanes / 8, 0xd1a4, fillDistHalfNormalSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorGamma f64x4", lanes / 16, 0xd2a4, fillDistGammaF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorGamma f64x4 direct", lanes / 16, 0xd2a4, fillDistGammaF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorGamma.fill f64x4", lanes / 16, 0xd2a4, fillDistGammaSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorChiSquared f64x4", lanes / 16, 0xd2b4, fillDistChiSquaredF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorChiSquared f64x4 direct", lanes / 16, 0xd2b4, fillDistChiSquaredF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorChiSquared.fill f64x4", lanes / 16, 0xd2b4, fillDistChiSquaredSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorChi f64x4", lanes / 16, 0xd2c4, fillDistChiF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorChi f64x4 direct", lanes / 16, 0xd2c4, fillDistChiF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorChi.fill f64x4", lanes / 16, 0xd2c4, fillDistChiSamplerF64);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardExponential f32x8", lanes, 0xe188, fillDistStandardExponentialF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardExponential f32x8 direct", lanes, 0xe188, fillDistStandardExponentialF32Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorExponential f64x4", lanes / 2, 0xe184, fillDistExponentialF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorExponential f64x4 direct", lanes / 2, 0xe184, fillDistExponentialF64Direct);
    try benchFillVectorStandardNormalF32(io, stdout, "alea fillVectorStandardNormal f32x8", lanes / 4);
    try benchFillVectorStandardNormalF32Direct(io, stdout, "alea fillVectorStandardNormal f32x8 direct", lanes / 4);
    try benchFillVectorStandardNormalF32Repair(io, stdout, "alea fillVectorStandardNormal f32x8 repair candidate", lanes / 4);
    try benchFillVectorStandardNormalF64(io, stdout, "alea fillVectorStandardNormal f64x4", lanes / 8);
    try benchFillVectorStandardNormalF64Direct(io, stdout, "alea fillVectorStandardNormal f64x4 direct", lanes / 8);
    try benchFillVectorNormalF32(io, stdout, "alea fillVectorNormal f32x8", lanes / 4);
    try benchFillVectorNormalF32Direct(io, stdout, "alea fillVectorNormal f32x8 direct", lanes / 4);
    try benchFillVectorNormalF32Repair(io, stdout, "alea fillVectorNormal f32x8 repair candidate", lanes / 4);
    try benchFillVectorNormalF64(io, stdout, "alea fillVectorNormal f64x4", lanes / 8);
    try benchFillVectorNormalF64Direct(io, stdout, "alea fillVectorNormal f64x4 direct", lanes / 8);
    try benchFillVectorStandardExponentialF32(io, stdout, "alea fillVectorStandardExponential f32x8", lanes);
    try benchFillVectorStandardExponentialF32Direct(io, stdout, "alea fillVectorStandardExponential f32x8 direct", lanes);
    try benchFillVectorStandardExponentialF32Repair(io, stdout, "alea fillVectorStandardExponential f32x8 repair candidate", lanes);
    try benchFillVectorStandardExponentialF64(io, stdout, "alea fillVectorStandardExponential f64x4", lanes / 2);
    try benchFillVectorStandardExponentialF64Direct(io, stdout, "alea fillVectorStandardExponential f64x4 direct", lanes / 2);
    try benchFillVectorExponentialF32(io, stdout, "alea fillVectorExponential f32x8", lanes);
    try benchFillVectorExponentialF32Direct(io, stdout, "alea fillVectorExponential f32x8 direct", lanes);
    try benchFillVectorExponentialF32Repair(io, stdout, "alea fillVectorExponential f32x8 repair candidate", lanes);
    try benchFillVectorExponentialF64(io, stdout, "alea fillVectorExponential f64x4", lanes / 2);
    try benchFillVectorExponentialF64Direct(io, stdout, "alea fillVectorExponential f64x4 direct", lanes / 2);
    try stdout.flush();
}

fn benchFillVectorChanceBool(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [256]@Vector(64, bool) = undefined;
    const vector_count = lanes / 64;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xc464);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorChance(@Vector(64, bool), out[0..n], 0.25);
            checksum += checksumBoolVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 64)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBoolX64(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.ScalarPrng, alea.Rng, []@Vector(64, bool)) void,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [256]@Vector(64, bool) = undefined;
    const vector_count = lanes / 64;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, rng, out[0..n]);
            checksum += checksumBoolVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 64)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn fillDistBernoulliBool(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(64, bool)) void {
    alea.distributions.fillVectorBernoulli(rng, @Vector(64, bool), dest, 0.25);
}

fn fillDistBernoulliBoolDirect(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(64, bool)) void {
    alea.distributions.fillVectorBernoulliFrom(engine, @Vector(64, bool), dest, 0.25);
}

fn fillDistBernoulliSamplerBool(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(64, bool)) void {
    const sampler = alea.distributions.VectorBernoulli(@Vector(64, bool)).initRatio(1, 4) catch unreachable;
    sampler.fill(rng, dest);
}

fn benchFillVectorRatioBool(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [256]@Vector(64, bool) = undefined;
    const vector_count = lanes / 64;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x7146);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorRatio(@Vector(64, bool), out[0..n], 1, 4);
            checksum += checksumBoolVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 64)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorU64x4(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.ScalarPrng, alea.Rng, []@Vector(4, u64)) void,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [128]@Vector(4, u64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, rng, out[0..n]);
            checksum +%= checksumVectorsU64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn fillDistBinomialU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorBinomial(rng, @Vector(4, u64), dest, 10, 0.5);
}

fn fillDistBinomialU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorBinomialFrom(engine, @Vector(4, u64), dest, 10, 0.5);
}

fn fillDistBinomialSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorBinomial(@Vector(4, u64)).init(10, 0.5) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistNegativeBinomialU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorNegativeBinomial(rng, @Vector(4, u64), dest, 5, 0.25);
}

fn fillDistNegativeBinomialU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorNegativeBinomialFrom(engine, @Vector(4, u64), dest, 5, 0.25);
}

fn fillDistNegativeBinomialSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorNegativeBinomial(@Vector(4, u64)).init(5, 0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistHypergeometricU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorHypergeometric(rng, @Vector(4, u64), dest, 100, 30, 10);
}

fn fillDistHypergeometricU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorHypergeometricFrom(engine, @Vector(4, u64), dest, 100, 30, 10);
}

fn fillDistHypergeometricSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorHypergeometric(@Vector(4, u64)).init(100, 30, 10) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistGeometricU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorGeometric(rng, @Vector(4, u64), dest, 0.25);
}

fn fillDistGeometricU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorGeometricFrom(engine, @Vector(4, u64), dest, 0.25);
}

fn fillDistGeometricSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorGeometric(@Vector(4, u64)).init(0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistGeometricFailuresU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorGeometricFailures(rng, @Vector(4, u64), dest, 0.25);
}

fn fillDistGeometricFailuresU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorGeometricFailuresFrom(engine, @Vector(4, u64), dest, 0.25);
}

fn fillDistGeometricFailuresSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorGeometricFailures(@Vector(4, u64)).init(0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistStandardGeometricU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorStandardGeometric(rng, @Vector(4, u64), dest);
}

fn fillDistStandardGeometricU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorStandardGeometricFrom(engine, @Vector(4, u64), dest);
}

fn fillDistStandardGeometricSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorStandardGeometric(@Vector(4, u64)){};
    sampler.fill(rng, dest);
}

fn fillDistPoissonU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorPoisson(rng, @Vector(4, u64), dest, 12);
}

fn fillDistPoissonU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorPoissonFrom(engine, @Vector(4, u64), dest, 12);
}

fn fillDistPoissonSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorPoisson(@Vector(4, u64)).init(12) catch unreachable;
    sampler.fill(rng, dest);
}

fn benchFillVectorOpenF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x0f88);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorOpenFrom(&engine, @Vector(8, f32), out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorOpenClosedF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x0fc8);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorOpenClosedFrom(&engine, @Vector(8, f32), out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorRangeF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xf188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorRange(@Vector(8, f32), out[0..n], -1, 1);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xf164);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fill(@Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorOpenF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x0f64);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorOpenFrom(&engine, @Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorOpenClosedF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x0c64);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorOpenClosedFrom(&engine, @Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorRangeF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xf164);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorRange(@Vector(4, f64), out[0..n], -1, 1);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorF32x8(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.ScalarPrng, alea.Rng, []@Vector(8, f32)) void,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, rng, out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorF64x4(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.ScalarPrng, alea.Rng, []@Vector(4, f64)) void,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, rng, out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn fillDistUniformF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorUniform(rng, @Vector(8, f32), dest, -1, 1);
}

fn fillDistUniformF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorUniformFrom(engine, @Vector(8, f32), dest, -1, 1);
}

fn fillDistOpen01F32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    (alea.distributions.Open01{}).fill(rng, @Vector(8, f32), dest);
}

fn fillDistOpenClosed01F64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    (alea.distributions.OpenClosed01{}).fill(rng, @Vector(4, f64), dest);
}

fn fillDistStandardNormalF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardNormal(rng, @Vector(8, f32), dest);
}

fn fillDistStandardNormalF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardNormalFrom(engine, @Vector(8, f32), dest);
}

fn fillDistNormalF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorNormal(rng, @Vector(4, f64), dest, 0, 1);
}

fn fillDistNormalF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorNormalFrom(engine, @Vector(4, f64), dest, 0, 1);
}

fn fillDistLogNormalF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorLogNormal(rng, @Vector(4, f64), dest, 0, 0.25);
}

fn fillDistLogNormalF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorLogNormalFrom(engine, @Vector(4, f64), dest, 0, 0.25);
}

fn fillDistLogNormalSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorLogNormal(@Vector(4, f64)).init(0, 0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistHalfNormalF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorHalfNormal(rng, @Vector(4, f64), dest, 2);
}

fn fillDistHalfNormalF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorHalfNormalFrom(engine, @Vector(4, f64), dest, 2);
}

fn fillDistHalfNormalSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorHalfNormal(@Vector(4, f64)).init(2) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistGammaF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorGamma(rng, @Vector(4, f64), dest, 2, 3);
}

fn fillDistGammaF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorGammaFrom(engine, @Vector(4, f64), dest, 2, 3);
}

fn fillDistGammaSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorGamma(@Vector(4, f64)).init(2, 3) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistChiSquaredF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorChiSquared(rng, @Vector(4, f64), dest, 4);
}

fn fillDistChiSquaredF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorChiSquaredFrom(engine, @Vector(4, f64), dest, 4);
}

fn fillDistChiSquaredSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorChiSquared(@Vector(4, f64)).init(4) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistChiF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorChi(rng, @Vector(4, f64), dest, 4);
}

fn fillDistChiF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorChiFrom(engine, @Vector(4, f64), dest, 4);
}

fn fillDistChiSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorChi(@Vector(4, f64)).init(4) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistStandardExponentialF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardExponential(rng, @Vector(8, f32), dest);
}

fn fillDistStandardExponentialF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardExponentialFrom(engine, @Vector(8, f32), dest);
}

fn fillDistExponentialF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorExponential(rng, @Vector(4, f64), dest, 2);
}

fn fillDistExponentialF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorExponentialFrom(engine, @Vector(4, f64), dest, 2);
}

fn benchFillVectorStandardNormalF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorStandardNormal(@Vector(8, f32), out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardNormalF32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorStandardNormalFrom(&engine, @Vector(8, f32), out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardNormalF32Repair(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillStandardNormalF32Repair(&engine, out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardNormalF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd184);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorStandardNormal(@Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardNormalF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd184);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorStandardNormalFrom(&engine, @Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorNormalF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorNormal(@Vector(8, f32), out[0..n], 0, 1);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorNormalF32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorNormalFrom(&engine, @Vector(8, f32), out[0..n], 0, 1);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorNormalF32Repair(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillNormalF32Repair(&engine, out[0..n], 0, 1);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorNormalF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd184);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorNormal(@Vector(4, f64), out[0..n], 0, 1);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorNormalF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd184);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorNormalFrom(&engine, @Vector(4, f64), out[0..n], 0, 1);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardExponentialF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorStandardExponential(@Vector(8, f32), out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardExponentialF32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorStandardExponentialFrom(&engine, @Vector(8, f32), out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardExponentialF32Repair(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillStandardExponentialF32Repair(&engine, out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardExponentialF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe184);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorStandardExponential(@Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardExponentialF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe184);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorStandardExponentialFrom(&engine, @Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorExponentialF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorExponential(@Vector(8, f32), out[0..n], 2);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorExponentialF32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorExponentialFrom(&engine, @Vector(8, f32), out[0..n], 2);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorExponentialF32Repair(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillExponentialF32Repair(&engine, out[0..n], 2);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorExponentialF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe184);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorExponential(@Vector(4, f64), out[0..n], 2);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorExponentialF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe184);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorExponentialFrom(&engine, @Vector(4, f64), out[0..n], 2);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn checksumBoolVectors(vectors: []const @Vector(64, bool), len: usize) u64 {
    var checksum: u64 = 0;
    for (vectors[0..len]) |vec| {
        inline for (0..64) |lane| checksum += @intFromBool(vec[lane]);
    }
    return checksum;
}

fn checksumVectorsU64(vectors: []const @Vector(4, u64), len: usize) u64 {
    var checksum: u64 = 0;
    for (vectors[0..len]) |vec| {
        inline for (0..4) |lane| checksum +%= vec[lane];
    }
    return checksum;
}

fn checksumVectors(vectors: []const @Vector(8, f32), len: usize) f32 {
    var checksum: f32 = 0;
    for (vectors[0..len]) |vec| {
        inline for (0..8) |lane| checksum += vec[lane];
    }
    return checksum;
}

fn checksumVectorsF64(vectors: []const @Vector(4, f64), len: usize) f64 {
    var checksum: f64 = 0;
    for (vectors[0..len]) |vec| {
        inline for (0..4) |lane| checksum += vec[lane];
    }
    return checksum;
}

fn fillStandardNormalF32Repair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairNormalF32Correct(engine);
}

fn fillNormalF32Repair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32), mean: f32, stddev: f32) void {
    const mean_vec: @Vector(8, f32) = @splat(mean);
    const stddev_vec: @Vector(8, f32) = @splat(stddev);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF32Correct(engine);
}

fn fillStandardExponentialF32Repair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairExponentialF32Correct(engine);
}

fn fillExponentialF32Repair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32), rate: f32) void {
    const inverse_rate: @Vector(8, f32) = @splat(1 / rate);
    for (dest) |*item| item.* = vectorRepairExponentialF32Correct(engine) * inverse_rate;
}

fn vectorRepairNormalF32Correct(engine: *alea.ScalarPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| out[lane] = @floatCast(ratioNormal(engine));
    return out;
}

fn vectorRepairExponentialF32Correct(engine: *alea.ScalarPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| out[lane] = @floatCast(thresholdExponential(engine));
    return out;
}

fn ratioNormal(engine: *alea.ScalarPrng) f64 {
    while (true) {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;

        if (@abs(u) < norm_ratio[i]) {
            @branchHint(.likely);
            return u * ziggurat.NormDist.x[i];
        }
        const x = u * ziggurat.NormDist.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return normalTail(engine, u);
        }
        if (ziggurat.NormDist.f[i + 1] + (ziggurat.NormDist.f[i] - ziggurat.NormDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x * x / 2.0)) return x;
    }
}

fn normalTail(engine: *alea.ScalarPrng, u: f64) f64 {
    var x: f64 = 1;
    var y: f64 = 0;
    while (-2.0 * y < x * x) {
        x = @log(alea.Rng.floatOpenFrom(engine, f64)) / ziggurat.norm_r;
        y = @log(alea.Rng.floatOpenFrom(engine, f64));
    }
    return if (u < 0) x - ziggurat.norm_r else ziggurat.norm_r - x;
}

fn thresholdExponential(engine: *alea.ScalarPrng) f64 {
    while (true) {
        const bits = engine.next();
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);

        if (mantissa < exp_threshold[i]) {
            @branchHint(.likely);
            return u * ziggurat.ExpDist.x[i];
        }
        const x = u * ziggurat.ExpDist.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return ziggurat.exp_r - @log(alea.Rng.floatOpenFrom(engine, f64));
        }
        if (ziggurat.ExpDist.f[i + 1] + (ziggurat.ExpDist.f[i] - ziggurat.ExpDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x)) return x;
    }
}
