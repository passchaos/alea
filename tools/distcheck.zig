const std = @import("std");
const alea = @import("alea");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    try checkBernoulli();
    try checkBinomial();
    try checkDiscrete();
    try checkPoisson();
    try checkContinuous();
    try checkExtremeAndShape();
    try checkBoundedSupport();
    try checkVectorDistributions();

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

fn checkDiscrete() !void {
    var engine = alea.FastPrng.init(0xd15c);
    const rng = alea.Rng.init(&engine);
    try expectDiscreteMean("negative-binomial", rng, 20_000, struct {
        fn sample(r: alea.Rng) u64 {
            return alea.distributions.negativeBinomial(r, 5, 0.4);
        }
    }.sample, 7.2, 7.8);
    try expectDiscreteMean("hypergeometric", rng, 20_000, struct {
        fn sample(r: alea.Rng) u64 {
            return alea.distributions.hypergeometric(r, 100, 30, 10);
        }
    }.sample, 2.8, 3.2);
}

fn expectDiscreteMean(comptime label: []const u8, rng: alea.Rng, samples: usize, sampleFn: *const fn (alea.Rng) u64, min: f64, max: f64) !void {
    var sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) sum += @floatFromInt(sampleFn(rng));
    try expectFloatBetween(label, sum / @as(f64, @floatFromInt(samples)), min, max);
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
    try expectContinuousMean("log-normal", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.logNormal(r, f64, 0, 0.25);
        }
    }.sample, 1.02, 1.04);
    try expectContinuousMean("chi-squared", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.chiSquared(r, f64, 4);
        }
    }.sample, 3.9, 4.1);
    try expectContinuousMean("student-t", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.studentT(r, f64, 10);
        }
    }.sample, -0.05, 0.05);
    try expectContinuousMean("fisher-f", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.fisherF(r, f64, 5, 20);
        }
    }.sample, 1.05, 1.18);
    try expectContinuousMean("weibull", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.weibull(r, f64, 2, 1.5);
        }
    }.sample, 1.75, 1.85);
}

fn checkExtremeAndShape() !void {
    var engine = alea.FastPrng.init(0xe751);
    const rng = alea.Rng.init(&engine);
    try expectContinuousMean("gumbel", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.gumbel(r, f64, 0, 1);
        }
    }.sample, 0.55, 0.61);
    try expectContinuousMean("frechet", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.frechet(r, f64, 0, 1, 3);
        }
    }.sample, 1.30, 1.40);
    try expectContinuousMean("skew-normal", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.skewNormal(r, f64, 0, 1, 1);
        }
    }.sample, 0.52, 0.60);
    try expectContinuousMean("pert", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.pert(r, f64, -1, 0.5, 2, 4);
        }
    }.sample, 0.45, 0.55);
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
        const cauchy = alea.distributions.cauchy(rng, f64, 0, 1);
        if (!std.math.isFinite(cauchy)) return error.DistributionCheckFailed;
        const pert = alea.distributions.pert(rng, f64, -1, 0.5, 2, 4);
        if (!(pert >= -1 and pert <= 2)) return error.DistributionCheckFailed;
    }
}

fn checkVectorDistributions() !void {
    var engine = alea.FastPrng.init(0x7ec7);
    const rng = alea.Rng.init(&engine);

    const dirichlet = try alea.distributions.Dirichlet(f64).init(&.{ 1.0, 2.0, 3.0 });
    const multinomial = try alea.distributions.Multinomial.init(100, &.{ 1.0, 2.0, 3.0 });

    var i: usize = 0;
    while (i < 5000) : (i += 1) {
        var simplex: [3]f64 = undefined;
        dirichlet.sampleInto(rng, &simplex);
        var simplex_sum: f64 = 0;
        for (simplex) |value| {
            if (!(value >= 0 and value <= 1)) return error.DistributionCheckFailed;
            simplex_sum += value;
        }
        try expectFloatBetween("dirichlet sum", simplex_sum, 0.999999999999, 1.000000000001);

        var counts: [3]u64 = undefined;
        multinomial.sampleInto(rng, &counts);
        var total: u64 = 0;
        for (counts) |count| total += count;
        if (total != 100) return error.DistributionCheckFailed;

        const circle = alea.distributions.unitCircle(rng, f64);
        try expectFloatBetween("unit circle norm", circle[0] * circle[0] + circle[1] * circle[1], 0.999999999999, 1.000000000001);
        const disc = alea.distributions.unitDisc(rng, f64);
        if (disc[0] * disc[0] + disc[1] * disc[1] > 1) return error.DistributionCheckFailed;
        const sphere = alea.distributions.unitSphere(rng, f64);
        try expectFloatBetween("unit sphere norm", sphere[0] * sphere[0] + sphere[1] * sphere[1] + sphere[2] * sphere[2], 0.999999999999, 1.000000000001);
        const ball = alea.distributions.unitBall(rng, f64);
        if (ball[0] * ball[0] + ball[1] * ball[1] + ball[2] * ball[2] > 1) return error.DistributionCheckFailed;
    }
}

fn expectFloatBetween(comptime label: []const u8, value: f64, min: f64, max: f64) !void {
    if (!(value >= min and value <= max)) {
        std.debug.print("{s}: {d:.6} not in [{d:.6}, {d:.6}]\n", .{ label, value, min, max });
        return error.DistributionCheckFailed;
    }
}
