const std = @import("std");
const alea = @import("alea");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    try checkBernoulli();
    try checkBinomial();
    try checkPoisson();
    try checkContinuous();
    try checkBoundedSupport();

    try stdout.print("distcheck ok\n", .{});
    try stdout.flush();
}

fn checkBernoulli() !void {
    var engine = alea.FastPrng.init(0xbee);
    const rng = alea.Rng.init(&engine);
    try expectBernoulliMean(rng, 0.1, 0.085, 0.115);
    try expectBernoulliMean(rng, 0.5, 0.48, 0.52);
    try expectBernoulliMean(rng, 0.9, 0.885, 0.915);
}

fn expectBernoulliMean(rng: alea.Rng, p: f64, min: f64, max: f64) !void {
    const dist = try alea.distributions.Bernoulli.init(p);
    const samples = 20_000;
    var sum: usize = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) sum += @intFromBool(dist.sample(rng));
    try expectFloatBetween("bernoulli", @as(f64, @floatFromInt(sum)) / @as(f64, @floatFromInt(samples)), min, max);
}

fn checkBinomial() !void {
    var engine = alea.FastPrng.init(0xb10);
    const rng = alea.Rng.init(&engine);
    try expectBinomialMean(rng, 20, 0.2, 3.8, 4.2);
    try expectBinomialMean(rng, 64, 0.5, 31.4, 32.6);
    try expectBinomialMean(rng, 10_000, 0.01, 98.8, 101.2);
}

fn expectBinomialMean(rng: alea.Rng, trials: u64, p: f64, min: f64, max: f64) !void {
    const samples = 10_000;
    var sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) sum += @floatFromInt(alea.distributions.binomial(rng, trials, p));
    try expectFloatBetween("binomial", sum / @as(f64, @floatFromInt(samples)), min, max);
}

fn checkPoisson() !void {
    var engine = alea.FastPrng.init(0x9015);
    const rng = alea.Rng.init(&engine);
    try expectPoissonMean(rng, 2, 1.9, 2.1);
    try expectPoissonMean(rng, 20, 19.7, 20.3);
    try expectPoissonMean(rng, 80, 79.5, 80.5);
}

fn expectPoissonMean(rng: alea.Rng, lambda: f64, min: f64, max: f64) !void {
    const samples = 20_000;
    var sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) sum += @floatFromInt(alea.distributions.poisson(rng, lambda));
    try expectFloatBetween("poisson", sum / @as(f64, @floatFromInt(samples)), min, max);
}

fn checkContinuous() !void {
    var engine = alea.DefaultPrng.init(0xc0ffee);
    const rng = alea.Rng.init(&engine);
    try expectContinuousMean("normal", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.normal(r, f64, 5, 2);
        }
    }.sample, 4.95, 5.05);
    try expectContinuousMean("exponential", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.exponential(r, f64, 4);
        }
    }.sample, 0.24, 0.26);
    try expectContinuousMean("gamma", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.gamma(r, f64, 2, 3);
        }
    }.sample, 5.85, 6.15);
    try expectContinuousMean("beta", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.beta(r, f64, 2, 5);
        }
    }.sample, 0.275, 0.295);
}

fn expectContinuousMean(comptime label: []const u8, rng: alea.Rng, samples: usize, sampleFn: *const fn (alea.Rng) f64, min: f64, max: f64) !void {
    var sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) sum += sampleFn(rng);
    try expectFloatBetween(label, sum / @as(f64, @floatFromInt(samples)), min, max);
}

fn checkBoundedSupport() !void {
    var engine = alea.FastPrng.init(0x500);
    const rng = alea.Rng.init(&engine);

    var i: usize = 0;
    while (i < 10_000) : (i += 1) {
        const tri = alea.distributions.triangular(rng, f64, -2, 0, 3);
        if (!(tri >= -2 and tri <= 3)) return error.DistributionCheckFailed;
        const beta = alea.distributions.beta(rng, f64, 2, 5);
        if (!(beta >= 0 and beta <= 1)) return error.DistributionCheckFailed;
        const pareto = alea.distributions.pareto(rng, f64, 2, 3);
        if (!(pareto >= 2)) return error.DistributionCheckFailed;
    }
}

fn expectFloatBetween(comptime label: []const u8, value: f64, min: f64, max: f64) !void {
    if (!(value >= min and value <= max)) {
        std.debug.print("{s}: {d:.6} not in [{d:.6}, {d:.6}]\n", .{ label, value, min, max });
        return error.DistributionCheckFailed;
    }
}
