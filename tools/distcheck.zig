const std = @import("std");
const alea = @import("alea");
const builtin = @import("builtin");

pub fn main(init: std.process.Init) !void {
    var long_samples: usize = 0;
    if (builtin.target.os.tag != .wasi) {
        var arena = std.heap.ArenaAllocator.init(init.gpa);
        defer arena.deinit();
        const args = try init.minimal.args.toSlice(arena.allocator());
        var i: usize = 1;
        while (i < args.len) : (i += 1) {
            if (std.mem.eql(u8, args[i], "--long")) {
                long_samples = if (i + 1 < args.len)
                    (std.fmt.parseInt(usize, args[i + 1], 10) catch 1_000_000)
                else
                    1_000_000;
                i += 1;
            }
        }
    }

    if (builtin.target.os.tag == .wasi) {
        try runChecks();
        std.debug.print("distcheck ok\n", .{});
        return;
    }

    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    try runChecks();
    if (long_samples > 0) {
        try checkLongRun(long_samples);
        try stdout.print("distlongcheck ok ({d} samples)\n", .{long_samples});
    } else {
        try stdout.print("distcheck ok\n", .{});
    }
    try stdout.flush();
}

fn runChecks() !void {
    try checkBernoulli();
    try checkBinomial();
    try checkDiscrete();
    try checkPoisson();
    try checkContinuous();
    try checkExtremeAndShape();
    try checkInverseAndRank();
    try checkBoundedSupport();
    try checkVectorDistributions();
    try checkMultivariateNormal();
    try checkConstructorErgonomics();
    try checkAdvancedMultivariate();
    try checkBetaFamilies();
    try checkCauchyQuantiles();
    try checkDyadicChanceFills();
}

/// The packed `fillChance` kernels must match their requested probabilities
/// across the dedicated masks and the nibble/ratio fallbacks.
fn checkDyadicChanceFills() !void {
    var engine = alea.FastPrng.init(0xd1a7);
    const rng = alea.Rng.init(&engine);
    var buf: [100_000]bool = undefined;
    const cases = [_]f64{ 0.25, 0.375, 0.5, 0.0625, 0.75, 0.125, 0.1875, 0.3125, 0.875, 0.0078125 };
    for (cases) |probability| {
        rng.fillChance(&buf, probability);
        var trues: usize = 0;
        for (buf) |value| trues += @intFromBool(value);
        const fraction = @as(f64, @floatFromInt(trues)) / @as(f64, @floatFromInt(buf.len));
        try expectFloatBetween("dyadic fillChance fraction", fraction, probability - 0.006, probability + 0.006);
    }
}

/// The Cauchy law has no finite mean, so gate its median and quartiles: for
/// the standard Cauchy, P(X <= 0) = 1/2, P(X <= -1) = 1/4, and P(X <= 1) = 3/4.
fn checkCauchyQuantiles() !void {
    var engine = alea.FastPrng.init(0xca0c);
    const rng = alea.Rng.init(&engine);

    const samples: usize = 100_000;
    var le_zero: usize = 0;
    var le_minus_one: usize = 0;
    var le_one: usize = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        const x = alea.distributions.cauchy(rng, f64, 0, 1);
        if (x <= 0) le_zero += 1;
        if (x <= -1) le_minus_one += 1;
        if (x <= 1) le_one += 1;
    }
    const nf: f64 = @floatFromInt(samples);
    try expectFloatBetween("cauchy median", @as(f64, @floatFromInt(le_zero)) / nf, 0.494, 0.506);
    try expectFloatBetween("cauchy q1", @as(f64, @floatFromInt(le_minus_one)) / nf, 0.244, 0.256);
    try expectFloatBetween("cauchy q3", @as(f64, @floatFromInt(le_one)) / nf, 0.744, 0.756);
}

fn checkAdvancedMultivariate() !void {
    var engine = alea.FastPrng.init(0xa0d1);
    const rng = alea.Rng.init(&engine);

    // Bingham 3D concentration along the dominant axis.
    {
        const matrix = [3][3]f64{
            .{ 0, 0, 0 },
            .{ 0, -10, 0 },
            .{ 0, 0, -10 },
        };
        const dist = try alea.distributions.Bingham(f64, 3).init(matrix);
        const samples = 20_000;
        var sum_w2: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const point = dist.sample(rng);
            const norm_sq = point[0] * point[0] + point[1] * point[1] + point[2] * point[2];
            try expectFloatBetween("bingham norm", norm_sq, 1 - 1e-9, 1 + 1e-9);
            sum_w2 += point[0] * point[0];
        }
        try expectFloatBetween("bingham concentration", sum_w2 / @as(f64, @floatFromInt(samples)), 0.86, 0.92);
    }

    // Gaussian copula correlation recovery through probit coordinates.
    {
        const correlation = [2][2]f64{ .{ 1, 0.7 }, .{ 0.7, 1 } };
        const dist = try alea.distributions.StaticGaussianCopula(f64, 2).init(correlation);
        const samples = 10_000;
        var sum0: f64 = 0;
        var sum1: f64 = 0;
        var sum00: f64 = 0;
        var sum11: f64 = 0;
        var sum01: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const u = dist.sample(rng);
            try expectFloatBetween("gaussian copula u0", u[0], 1e-12, 1 - 1e-12);
            try expectFloatBetween("gaussian copula u1", u[1], 1e-12, 1 - 1e-12);
            const z0 = alea.distributions.probit(u[0]);
            const z1 = alea.distributions.probit(u[1]);
            sum0 += z0;
            sum1 += z1;
            sum00 += z0 * z0;
            sum11 += z1 * z1;
            sum01 += z0 * z1;
        }
        const nf = @as(f64, @floatFromInt(samples));
        const mean0 = sum0 / nf;
        const mean1 = sum1 / nf;
        const var0 = sum00 / nf - mean0 * mean0;
        const var1 = sum11 / nf - mean1 * mean1;
        const covariance = sum01 / nf - mean0 * mean1;
        try expectFloatBetween("gaussian copula rho", covariance / @sqrt(var0 * var1), 0.65, 0.75);
    }

    // Student-t copula lower-tail dependence.
    {
        const correlation = [2][2]f64{ .{ 1, 0.8 }, .{ 0.8, 1 } };
        const dist = try alea.distributions.StaticStudentTCopula(f64, 2).init(correlation, 3);
        const samples = 10_000;
        var both_low: usize = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const u = dist.sample(rng);
            if (u[0] < 0.1 and u[1] < 0.1) both_low += 1;
        }
        try expectFloatBetween("student-t copula tail", @as(f64, @floatFromInt(both_low)) / @as(f64, @floatFromInt(samples)), 0.03, 0.15);
    }

    // Static matrix normal row/column covariance recovery.
    {
        const mean = [2][2]f64{ .{ 0, 0 }, .{ 0, 0 } };
        const row_covariance = [2][2]f64{ .{ 1, 0.6 }, .{ 0.6, 1 } };
        const col_covariance = [2][2]f64{ .{ 1, 0.4 }, .{ 0.4, 1 } };
        const dist = try alea.distributions.StaticMatrixNormal(f64, 2, 2).init(mean, row_covariance, col_covariance);
        const samples = 20_000;
        var row_cross: f64 = 0;
        var col_cross: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const sample = dist.sample(rng);
            row_cross += sample[0][0] * sample[1][0];
            col_cross += sample[0][0] * sample[0][1];
        }
        const nf = @as(f64, @floatFromInt(samples));
        try expectFloatBetween("matrix normal row covariance", row_cross / nf, 0.55, 0.65);
        try expectFloatBetween("matrix normal col covariance", col_cross / nf, 0.35, 0.45);
    }

    // Non-unit matrix-normal scales: the transform must include the Cholesky
    // diagonal (the strict-lower product sampled unit variance for every
    // diagonal).
    {
        const mean = [2][1]f64{ .{0}, .{0} };
        const row_covariance = [2][2]f64{ .{ 4, 0 }, .{ 0, 9 } };
        const col_covariance = [1][1]f64{.{1}};
        const dist = try alea.distributions.StaticMatrixNormal(f64, 2, 1).init(mean, row_covariance, col_covariance);
        const samples = 20_000;
        var var0: f64 = 0;
        var var1: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const sample = dist.sample(rng);
            var0 += sample[0][0] * sample[0][0];
            var1 += sample[1][0] * sample[1][0];
        }
        const nf = @as(f64, @floatFromInt(samples));
        try expectFloatBetween("matrix normal row scale 4", var0 / nf, 3.7, 4.3);
        try expectFloatBetween("matrix normal row scale 9", var1 / nf, 8.4, 9.6);
    }
    {
        const allocator = if (builtin.target.os.tag == .wasi) std.heap.wasm_allocator else std.heap.smp_allocator;
        const mean = [_]f64{0};
        const row_covariance = [_]f64{4};
        const col_covariance = [_]f64{1};
        var dist = try alea.distributions.MatrixNormal(f64).init(allocator, &mean, &row_covariance, &col_covariance);
        defer dist.deinit();
        const samples = 20_000;
        var out: [1]f64 = undefined;
        var sum_sq: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            dist.sampleInto(rng, &out);
            sum_sq += out[0] * out[0];
        }
        try expectFloatBetween("dynamic matrix normal row scale 4", sum_sq / @as(f64, @floatFromInt(samples)), 3.7, 4.3);
    }

    // Static matrix-t variance formula.
    {
        const mean = [2][2]f64{ .{ 0, 0 }, .{ 0, 0 } };
        const identity = [2][2]f64{ .{ 1, 0 }, .{ 0, 1 } };
        const dist = try alea.distributions.StaticMatrixT(f64, 2, 2).init(mean, identity, identity, 5);
        const samples = 20_000;
        var sum_sq: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const sample = dist.sample(rng);
            sum_sq += sample[0][0] * sample[0][0];
        }
        try expectFloatBetween("matrix t variance", sum_sq / @as(f64, @floatFromInt(samples)), 1.5, 1.85);
    }

    // Wishart Bartlett product must include the below-diagonal Gaussian terms.
    // A truncated L*A product leaves identity-scale draws exactly diagonal and
    // shrinks the non-diagonal scale covariance.
    {
        const identity = [2][2]f64{ .{ 1, 0 }, .{ 0, 1 } };
        const dist = try alea.distributions.StaticWishart(f64, 2).init(identity, 5);
        const samples = 20_000;
        var sum_off_sq: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const sample = dist.sample(rng);
            sum_off_sq += sample[0][1] * sample[0][1];
        }
        try expectFloatBetween("wishart identity off-diagonal", sum_off_sq / @as(f64, @floatFromInt(samples)), 4.5, 5.5);
    }
    {
        const allocator = if (builtin.target.os.tag == .wasi) std.heap.wasm_allocator else std.heap.smp_allocator;
        const scale = [_]f64{ 2, 0.5, 0.5, 1 };
        var dist = try alea.distributions.Wishart(f64).init(allocator, &scale, 6);
        defer dist.deinit();
        const samples = 20_000;
        var sum00: f64 = 0;
        var sum01: f64 = 0;
        var sum11: f64 = 0;
        var sum01_sq: f64 = 0;
        var out: [4]f64 = undefined;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            dist.sampleInto(rng, &out);
            sum00 += out[0];
            sum01 += out[1];
            sum11 += out[3];
            sum01_sq += out[1] * out[1];
        }
        const nf: f64 = @floatFromInt(samples);
        try expectFloatBetween("wishart mean00", sum00 / nf, 11.6, 12.4);
        try expectFloatBetween("wishart mean01", sum01 / nf, 2.85, 3.15);
        try expectFloatBetween("wishart mean11", sum11 / nf, 5.7, 6.3);
        const mean01 = sum01 / nf;
        try expectFloatBetween("wishart off-diagonal variance", sum01_sq / nf - mean01 * mean01, 11.5, 15.5);
    }

    // Allocator-backed multivariate Student-t moment recovery.
    {
        const allocator = if (builtin.target.os.tag == .wasi) std.heap.wasm_allocator else std.heap.smp_allocator;
        const mean = [_]f64{ 0, 0 };
        const covariance = [_]f64{ 1, 0.2, 0.2, 1 };
        var dist = try alea.distributions.MultivariateT(f64).init(allocator, &mean, &covariance, 5);
        defer dist.deinit();
        const samples = 20_000;
        var sum: f64 = 0;
        var sum_sq: f64 = 0;
        var out: [2]f64 = undefined;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            dist.sampleIntoFrom(&engine, &out);
            sum += out[0];
            sum_sq += out[0] * out[0];
        }
        const nf: f64 = @floatFromInt(samples);
        const observed_mean = sum / nf;
        try expectFloatBetween("multivariate t mean", observed_mean, -0.05, 0.05);
        try expectFloatBetween("multivariate t variance", sum_sq / nf - observed_mean * observed_mean, 1.5, 1.85);
        const variance = try dist.varianceAt(0);
        if (variance) |value| {
            try expectFloatBetween("multivariate t accessor variance", value, 1.666, 1.667);
        } else {
            return error.DistributionCheckFailed;
        }
    }

    // Allocator-backed multivariate Laplace moment recovery.
    {
        const allocator = if (builtin.target.os.tag == .wasi) std.heap.wasm_allocator else std.heap.smp_allocator;
        const mean = [_]f64{ 0, 0 };
        const covariance = [_]f64{ 1, 0.2, 0.2, 1 };
        var dist = try alea.distributions.MultivariateLaplace(f64).init(allocator, &mean, &covariance);
        defer dist.deinit();
        const samples = 40_000;
        var sum: f64 = 0;
        var sum_sq: f64 = 0;
        var out: [2]f64 = undefined;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            dist.sampleIntoFrom(&engine, &out);
            sum += out[0];
            sum_sq += out[0] * out[0];
        }
        const nf: f64 = @floatFromInt(samples);
        const observed_mean = sum / nf;
        try expectFloatBetween("multivariate laplace mean", observed_mean, -0.05, 0.05);
        try expectFloatBetween("multivariate laplace variance", sum_sq / nf - observed_mean * observed_mean, 0.88, 1.12);
        try expectFloatBetween("multivariate laplace accessor variance", try dist.varianceAt(0), 0.999, 1.001);
    }

    // Allocator-backed multivariate skew-normal moment recovery.
    {
        const allocator = if (builtin.target.os.tag == .wasi) std.heap.wasm_allocator else std.heap.smp_allocator;
        const location = [_]f64{ 0, 0 };
        const scale = [_]f64{ 1, 0.5, 0.5, 2 };
        const shape = [_]f64{ 2, -1 };
        var dist = try alea.distributions.MultivariateSkewNormal(f64).init(allocator, &location, &scale, &shape);
        defer dist.deinit();
        const inv_sqrt5: f64 = 1.0 / @sqrt(5.0);
        const delta0: f64 = 1.5 * inv_sqrt5;
        const normal_factor: f64 = @sqrt(2.0 / std.math.pi);
        const expected_mean0 = normal_factor * delta0;
        const expected_var0 = 1 - (2.0 / std.math.pi) * delta0 * delta0;
        const samples = 40_000;
        var sum: f64 = 0;
        var sum_sq: f64 = 0;
        var out: [2]f64 = undefined;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            dist.sampleIntoFrom(&engine, &out);
            sum += out[0];
            sum_sq += out[0] * out[0];
        }
        const nf: f64 = @floatFromInt(samples);
        const observed_mean = sum / nf;
        try expectFloatBetween("multivariate skew-normal mean", observed_mean, expected_mean0 - 0.03, expected_mean0 + 0.03);
        try expectFloatBetween("multivariate skew-normal variance", sum_sq / nf - observed_mean * observed_mean, expected_var0 - 0.06, expected_var0 + 0.06);
        try expectFloatBetween("multivariate skew-normal accessor variance", try dist.varianceAt(0), expected_var0 - 1e-9, expected_var0 + 1e-9);
    }

    // Kent (Fisher-Bingham F5) directional moment recovery.
    {
        const mean = [3]f64{ 0, 0, 1 };
        const major = [3]f64{ 1, 0, 0 };
        const dist = try alea.distributions.Kent(f64).init(mean, major, 5, 1.5);
        const rho = dist.meanResultantLength();
        const samples = 40_000;
        var sum_z: f64 = 0;
        var sums_sq = [_]f64{0} ** 3;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const point = dist.sampleFrom(&engine);
            const norm_sq = point[0] * point[0] + point[1] * point[1] + point[2] * point[2];
            if (@abs(norm_sq - 1) > 1e-9) return error.DistributionCheckFailed;
            sum_z += point[2];
            inline for (0..3) |k| sums_sq[k] += point[k] * point[k];
        }
        const nf: f64 = @floatFromInt(samples);
        const observed_z = sum_z / nf;
        try expectFloatBetween("kent mean resultant", observed_z, rho - 0.03, rho + 0.03);
        try expectFloatBetween("kent major-axis variance", sums_sq[0] / nf, dist.varianceAt(0) - 0.03, dist.varianceAt(0) + 0.03);
        try expectFloatBetween("kent minor-axis variance", sums_sq[1] / nf, dist.varianceAt(1) - 0.03, dist.varianceAt(1) + 0.03);
        if (!(dist.varianceAt(0) > dist.varianceAt(1))) return error.DistributionCheckFailed;
        const trace_expected = dist.varianceValue();
        const trace_observed = dist.varianceAt(0) + dist.varianceAt(1) + dist.varianceAt(2);
        try expectFloatBetween("kent trace identity", trace_observed, trace_expected - 1e-9, trace_expected + 1e-9);
    }

    // Matrix von Mises-Fisher Gibbs sampler with a zero second column.
    {
        const allocator = if (builtin.target.os.tag == .wasi) std.heap.wasm_allocator else std.heap.smp_allocator;
        const kappa: f64 = 5;
        const parameter = [6]f64{ 0, 0, 0, 0, kappa, 0 };
        var dist = try alea.distributions.MatrixVonMisesFisher(f64).initWithOptions(allocator, &parameter, 3, 2, 100, 10);
        defer dist.deinit();
        const vmf = try alea.distributions.VonMisesFisher(f64, 3).init(.{ 0, 0, 1 }, kappa);
        const expected_z = vmf.meanResultantLength();
        const samples = 20_000;
        var sum_z: f64 = 0;
        var sum_col1 = [_]f64{0} ** 3;
        var out: [6]f64 = undefined;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            try dist.sampleIntoFrom(&engine, &out);
            sum_z += out[4];
            inline for (0..3) |k| sum_col1[k] += out[k * 2 + 1];
        }
        const nf: f64 = @floatFromInt(samples);
        try expectFloatBetween("matrix vmf first-column mean", sum_z / nf, expected_z - 0.03, expected_z + 0.03);
        inline for (0..3) |k| {
            try expectFloatBetween("matrix vmf second-column mean", sum_col1[k] / nf, -0.03, 0.03);
        }
    }

    // Matrix Fisher SO(3) isotropic trace moment.
    {
        const d: f64 = 2;
        const parameter = [3][3]f64{
            .{ d, 0, 0 },
            .{ 0, d, 0 },
            .{ 0, 0, d },
        };
        const dist = try alea.distributions.MatrixFisher(f64).init(parameter);
        const steps: usize = 20_000;
        var num: f64 = 0;
        var den: f64 = 0;
        var i: usize = 0;
        while (i < steps) : (i += 1) {
            const w = -1 + 2 * (@as(f64, @floatFromInt(i)) + 0.5) / @as(f64, @floatFromInt(steps));
            const weight = @exp(4 * d * w * w) * @sqrt(1 - w * w);
            num += (4 * w * w - 1) * weight;
            den += weight;
        }
        const expected = num / den;
        const samples = 20_000;
        var sum: f64 = 0;
        i = 0;
        while (i < samples) : (i += 1) {
            const r = dist.sampleFrom(&engine);
            sum += r[0][0] + r[1][1] + r[2][2];
        }
        const nf: f64 = @floatFromInt(samples);
        try expectFloatBetween("matrix fisher trace", sum / nf, expected - 0.03, expected + 0.03);
    }

    // Matrix Fisher O(3) mixture weight and determinant frequency.
    {
        const parameter = [3][3]f64{
            .{ 2, 0, 0 },
            .{ 0, 2, 0 },
            .{ 0, 0, 2 },
        };
        const dist = try alea.distributions.MatrixFisherO3(f64).init(parameter);
        const steps: usize = 20_000;
        var z_so: f64 = 0;
        var z_ref: f64 = 0;
        var i: usize = 0;
        while (i < steps) : (i += 1) {
            const w = -1 + 2 * (@as(f64, @floatFromInt(i)) + 0.5) / @as(f64, @floatFromInt(steps));
            const s = @sqrt(1 - w * w);
            z_so += s * @exp(-8 * (1 - w * w));
            z_ref += s * @exp(-8 * w * w);
        }
        const expected = z_so / (z_so + z_ref);
        try expectFloatBetween("matrix fisher o3 weight", dist.soWeightValue(), expected - 1e-3, expected + 1e-3);

        const samples = 20_000;
        var positive_det: usize = 0;
        i = 0;
        while (i < samples) : (i += 1) {
            const r = dist.sampleFrom(&engine);
            const det = r[0][0] * (r[1][1] * r[2][2] - r[1][2] * r[2][1]) -
                r[0][1] * (r[1][0] * r[2][2] - r[1][2] * r[2][0]) +
                r[0][2] * (r[1][0] * r[2][1] - r[1][1] * r[2][0]);
            if (det > 0) positive_det += 1;
        }
        const nf: f64 = @floatFromInt(samples);
        try expectFloatBetween("matrix fisher o3 det frequency", @as(f64, @floatFromInt(positive_det)) / nf, expected - 0.03, expected + 0.03);
    }

    // SIMD von Mises-Fisher f64x4 moment recovery.
    {
        const V = @Vector(4, f64);
        const kappa: f64 = 5;
        const dist = try alea.distributions.VectorVonMisesFisher(V).init(.{ 0, 0, 1 }, kappa);
        const vmf = try alea.distributions.VonMisesFisher(f64, 3).init(.{ 0, 0, 1 }, kappa);
        const expected = vmf.meanResultantLength();
        const samples = 10_000;
        var sum_z: f64 = 0;
        var count: usize = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const p = dist.sampleFrom(&engine);
            inline for (0..4) |lane| {
                const norm_sq = p[0][lane] * p[0][lane] + p[1][lane] * p[1][lane] + p[2][lane] * p[2][lane];
                if (@abs(norm_sq - 1) > 1e-9) return error.DistributionCheckFailed;
                sum_z += p[2][lane];
                count += 1;
            }
        }
        const nf: f64 = @floatFromInt(count);
        try expectFloatBetween("vector vmf mean resultant", sum_z / nf, expected - 0.03, expected + 0.03);
    }

    // SIMD Watson f64x4 axial moment recovery.
    {
        const V = @Vector(4, f64);
        const dist = try alea.distributions.VectorWatson(V).init(.{ 0, 0, 1 }, 5);
        const scalar = try alea.distributions.Watson(f64, 3).init(.{ 0, 0, 1 }, 5);
        const expected = scalar.meanCosineSquared();
        const samples = 10_000;
        var sum_z2: f64 = 0;
        var count: usize = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const p = dist.sampleFrom(&engine);
            inline for (0..4) |lane| {
                const norm_sq = p[0][lane] * p[0][lane] + p[1][lane] * p[1][lane] + p[2][lane] * p[2][lane];
                if (@abs(norm_sq - 1) > 1e-9) return error.DistributionCheckFailed;
                sum_z2 += p[2][lane] * p[2][lane];
                count += 1;
            }
        }
        const nf: f64 = @floatFromInt(count);
        try expectFloatBetween("vector watson mean cosine squared", sum_z2 / nf, expected - 0.03, expected + 0.03);
    }

    // SIMD Bingham f64x4 axial moment recovery.
    {
        const V = @Vector(4, f64);
        const matrix = [3][3]f64{
            .{ 0, 0, 0 },
            .{ 0, -3, 0 },
            .{ 0, 0, -3 },
        };
        const dist = try alea.distributions.VectorBingham(V).init(matrix);
        const steps: usize = 20_000;
        var num: f64 = 0;
        var den: f64 = 0;
        var i: usize = 0;
        while (i < steps) : (i += 1) {
            const w = -1 + 2 * (@as(f64, @floatFromInt(i)) + 0.5) / @as(f64, @floatFromInt(steps));
            const weight = @exp(3 * w * w);
            num += w * w * weight;
            den += weight;
        }
        const expected = num / den;
        const samples = 10_000;
        var sum_x0_sq: f64 = 0;
        var count: usize = 0;
        i = 0;
        while (i < samples) : (i += 1) {
            const p = dist.sampleFrom(&engine);
            inline for (0..4) |lane| {
                const norm_sq = p[0][lane] * p[0][lane] + p[1][lane] * p[1][lane] + p[2][lane] * p[2][lane];
                if (@abs(norm_sq - 1) > 1e-9) return error.DistributionCheckFailed;
                sum_x0_sq += p[0][lane] * p[0][lane];
                count += 1;
            }
        }
        const nf: f64 = @floatFromInt(count);
        try expectFloatBetween("vector bingham mean x0^2", sum_x0_sq / nf, expected - 0.03, expected + 0.03);
    }

    // SIMD Kent f64x4 mean-resultant recovery.
    {
        const V = @Vector(4, f64);
        const mean = [3]f64{ 0, 0, 1 };
        const major = [3]f64{ 1, 0, 0 };
        const dist = try alea.distributions.VectorKent(V).init(mean, major, 5, 1.5);
        const scalar = try alea.distributions.Kent(f64).init(mean, major, 5, 1.5);
        const expected = scalar.meanResultantLength();
        const samples = 10_000;
        var sum_z: f64 = 0;
        var count: usize = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const p = dist.sampleFrom(&engine);
            inline for (0..4) |lane| {
                const norm_sq = p[0][lane] * p[0][lane] + p[1][lane] * p[1][lane] + p[2][lane] * p[2][lane];
                if (@abs(norm_sq - 1) > 1e-9) return error.DistributionCheckFailed;
                sum_z += p[2][lane];
                count += 1;
            }
        }
        const nf: f64 = @floatFromInt(count);
        try expectFloatBetween("vector kent mean resultant", sum_z / nf, expected - 0.03, expected + 0.03);
    }

    // Continuous and discrete CDF/quantile round-trips.
    {
        const p: f64 = 0.3;
        const beta_a: f64 = 2;
        const beta_b: f64 = 5;
        try expectFloatBetween("beta quantile", alea.distributions.betaCdf(alea.distributions.betaQuantile(p, beta_a, beta_b), beta_a, beta_b), p - 1e-9, p + 1e-9);
        const gamma_shape: f64 = 2.5;
        const gamma_scale: f64 = 1.5;
        try expectFloatBetween("gamma quantile", alea.distributions.gammaCdf(alea.distributions.gammaQuantile(p, gamma_shape, gamma_scale), gamma_shape, gamma_scale), p - 1e-9, p + 1e-9);
        const chi_dof: f64 = 4;
        try expectFloatBetween("chi-squared quantile", alea.distributions.chiSquaredCdf(alea.distributions.chiSquaredQuantile(p, chi_dof), chi_dof), p - 1e-9, p + 1e-9);
        const t_dof: f64 = 5;
        try expectFloatBetween("student-t quantile", alea.distributions.studentTCdf(alea.distributions.studentTQuantile(p, t_dof), t_dof), p - 1e-9, p + 1e-9);
        const f_d1: f64 = 5;
        const f_d2: f64 = 10;
        try expectFloatBetween("fisher-f quantile", alea.distributions.fisherFCdf(alea.distributions.fisherFQuantile(p, f_d1, f_d2), f_d1, f_d2), p - 1e-9, p + 1e-9);
        const exp_rate: f64 = 2;
        try expectFloatBetween("exponential quantile", alea.distributions.exponentialCdf(alea.distributions.exponentialQuantile(p, exp_rate), exp_rate), p - 1e-9, p + 1e-9);
        const log_mean: f64 = 0.5;
        const log_stddev: f64 = 0.75;
        try expectFloatBetween("log-normal quantile", alea.distributions.logNormalCdf(alea.distributions.logNormalQuantile(p, log_mean, log_stddev), log_mean, log_stddev), p - 1e-5, p + 1e-5);
        const half_scale: f64 = 2;
        try expectFloatBetween("half-normal quantile", alea.distributions.halfNormalCdf(alea.distributions.halfNormalQuantile(p, half_scale), half_scale), p - 1e-5, p + 1e-5);
        const chi_k: f64 = 4;
        try expectFloatBetween("chi quantile", alea.distributions.chiCdf(alea.distributions.chiQuantile(p, chi_k), chi_k), p - 1e-9, p + 1e-9);
        const erlang_shape: f64 = 2;
        const erlang_scale: f64 = 1.5;
        try expectFloatBetween("erlang quantile", alea.distributions.erlangCdf(alea.distributions.erlangQuantile(p, erlang_shape, erlang_scale), erlang_shape, erlang_scale), p - 1e-9, p + 1e-9);
        const maxwell_scale: f64 = 1.5;
        try expectFloatBetween("maxwell quantile", alea.distributions.maxwellCdf(alea.distributions.maxwellQuantile(p, maxwell_scale), maxwell_scale), p - 1e-9, p + 1e-9);
        const bp_alpha: f64 = 2;
        const bp_beta: f64 = 5;
        try expectFloatBetween("beta-prime quantile", alea.distributions.betaPrimeCdf(alea.distributions.betaPrimeQuantile(p, bp_alpha, bp_beta), bp_alpha, bp_beta), p - 1e-9, p + 1e-9);
        const ll_scale: f64 = 1.5;
        const ll_shape: f64 = 2.5;
        try expectFloatBetween("log-logistic quantile", alea.distributions.logLogisticCdf(alea.distributions.logLogisticQuantile(p, ll_scale, ll_shape), ll_scale, ll_shape), p - 1e-9, p + 1e-9);
        const ig_shape: f64 = 3;
        const ig_scale: f64 = 2;
        try expectFloatBetween("inverse-gamma quantile", alea.distributions.inverseGammaCdf(alea.distributions.inverseGammaQuantile(p, ig_shape, ig_scale), ig_shape, ig_scale), p - 1e-9, p + 1e-9);
        const nak_m: f64 = 2;
        const nak_omega: f64 = 3;
        try expectFloatBetween("nakagami quantile", alea.distributions.nakagamiCdf(alea.distributions.nakagamiQuantile(p, nak_m, nak_omega), nak_m, nak_omega), p - 1e-9, p + 1e-9);
        const eg_mu: f64 = 1;
        const eg_sigma: f64 = 0.5;
        const eg_tau: f64 = 1.5;
        try expectFloatBetween("ex-gaussian quantile", alea.distributions.exGaussianCdf(alea.distributions.exGaussianQuantile(p, eg_mu, eg_sigma, eg_tau), eg_mu, eg_sigma, eg_tau), p - 1e-4, p + 1e-4);
        const inv_gauss_mean: f64 = 1;
        const inv_gauss_shape: f64 = 2;
        try expectFloatBetween("inverse-gaussian quantile", alea.distributions.inverseGaussianCdf(alea.distributions.inverseGaussianQuantile(p, inv_gauss_mean, inv_gauss_shape), inv_gauss_mean, inv_gauss_shape), p - 1e-6, p + 1e-6);
        const sn_shape: f64 = 1;
        try expectFloatBetween("skew-normal quantile", alea.distributions.skewNormalCdf(alea.distributions.skewNormalQuantile(p, @as(f64, 0), @as(f64, 1), sn_shape), @as(f64, 0), @as(f64, 1), sn_shape), p - 1e-4, p + 1e-4);
        const pert_min: f64 = 0;
        const pert_mode: f64 = 0.5;
        const pert_max: f64 = 1;
        const pert_shape: f64 = 4;
        try expectFloatBetween("pert quantile", alea.distributions.pertCdf(alea.distributions.pertQuantile(p, pert_min, pert_mode, pert_max, pert_shape), pert_min, pert_mode, pert_max, pert_shape), p - 1e-9, p + 1e-9);
        const rice_nu: f64 = 1;
        const rice_sigma: f64 = 1;
        try expectFloatBetween("rice quantile", alea.distributions.riceCdf(alea.distributions.riceQuantile(p, rice_nu, rice_sigma), rice_nu, rice_sigma), p - 1e-5, p + 1e-5);
        const hoyt_q: f64 = 0.5;
        const hoyt_omega: f64 = 1;
        try expectFloatBetween("hoyt quantile", alea.distributions.hoytCdf(alea.distributions.hoytQuantile(p, hoyt_q, hoyt_omega), hoyt_q, hoyt_omega), p - 1e-5, p + 1e-5);
        const gpd_xi: f64 = 0.3;
        try expectFloatBetween("generalized-pareto quantile", alea.distributions.generalizedParetoCdf(alea.distributions.generalizedParetoQuantile(p, 1, 2, gpd_xi), 1, 2, gpd_xi), p - 1e-9, p + 1e-9);
        const sics_df: f64 = 5;
        const sics_scale: f64 = 2;
        try expectFloatBetween("scaled-inverse-chi-squared quantile", alea.distributions.scaledInverseChiSquaredCdf(alea.distributions.scaledInverseChiSquaredQuantile(p, sics_df, sics_scale), sics_df, sics_scale), p - 1e-7, p + 1e-7);
        const nc2_k: f64 = 3;
        const nc2_lambda: f64 = 4;
        try expectFloatBetween("noncentral chi-squared quantile", alea.distributions.noncentralChiSquaredCdf(alea.distributions.noncentralChiSquaredQuantile(p, nc2_k, nc2_lambda), nc2_k, nc2_lambda), p - 1e-6, p + 1e-6);
        const ncf_d1: f64 = 5;
        const ncf_d2: f64 = 10;
        const ncf_lambda: f64 = 4;
        try expectFloatBetween("noncentral f quantile", alea.distributions.noncentralFCdf(alea.distributions.noncentralFQuantile(p, ncf_d1, ncf_d2, ncf_lambda), ncf_d1, ncf_d2, ncf_lambda), p - 1e-6, p + 1e-6);
        try expectFloatBetween("truncated-normal quantile", alea.distributions.truncatedNormalCdf(alea.distributions.truncatedNormalQuantile(p, 0, 1, -1, 1), 0, 1, -1, 1), p - 1e-7, p + 1e-7);
        const uniform_dist = try alea.distributions.Uniform(f64).init(2, 5);
        try expectFloatBetween("uniform quantile", uniform_dist.cdf(uniform_dist.quantile(p)), p - 1e-12, p + 1e-12);
        const discrete_q: f64 = 0.7;
        const poisson_lambda: f64 = 5;
        try expectFloatBetween("poisson quantile", alea.distributions.poissonCdf(alea.distributions.poissonQuantile(discrete_q, poisson_lambda), poisson_lambda), discrete_q, 1.0);
        const binomial_n: f64 = 20;
        const binomial_p: f64 = 0.3;
        try expectFloatBetween("binomial quantile", alea.distributions.binomialCdf(alea.distributions.binomialQuantile(discrete_q, binomial_n, binomial_p), binomial_n, binomial_p), discrete_q, 1.0);
        const geometric_p: f64 = 0.4;
        try expectFloatBetween("geometric quantile", alea.distributions.geometricCdf(alea.distributions.geometricQuantile(discrete_q, geometric_p), geometric_p), discrete_q, 1.0);
        const negative_binomial_s: f64 = 3;
        const negative_binomial_p: f64 = 0.5;
        try expectFloatBetween("negative binomial quantile", alea.distributions.negativeBinomialCdf(alea.distributions.negativeBinomialQuantile(discrete_q, negative_binomial_s, negative_binomial_p), negative_binomial_s, negative_binomial_p), discrete_q, 1.0);
        const hypergeometric_population: f64 = 60;
        const hypergeometric_successes: f64 = 24;
        const hypergeometric_draws: f64 = 15;
        try expectFloatBetween("hypergeometric quantile", alea.distributions.hypergeometricCdf(alea.distributions.hypergeometricQuantile(discrete_q, hypergeometric_population, hypergeometric_successes, hypergeometric_draws), hypergeometric_population, hypergeometric_successes, hypergeometric_draws), discrete_q, 1.0);
        const zipf_n: f64 = 40;
        const zipf_s: f64 = 1.5;
        try expectFloatBetween("zipf quantile", alea.distributions.zipfCdf(alea.distributions.zipfQuantile(discrete_q, zipf_n, zipf_s), zipf_n, zipf_s), discrete_q, 1.0);
        const zeta_s: f64 = 2.5;
        try expectFloatBetween("zeta quantile", alea.distributions.zetaCdf(alea.distributions.zetaQuantile(discrete_q, zeta_s), zeta_s), discrete_q, 1.0);
        const bernoulli_p: f64 = 0.3;
        try expectFloatBetween("bernoulli quantile", alea.distributions.bernoulliCdf(alea.distributions.bernoulliQuantile(discrete_q, bernoulli_p), bernoulli_p), discrete_q, 1.0);
    }

    // Huge-lambda Poisson quantile inversion: CDF(k) >= q and CDF(k-1) < q.
    // The Poisson CDF uses the incomplete-gamma Wilson-Hilferty fallback at
    // these shapes, so this also guards the fallback's inversion accuracy.
    {
        const lambdas = [_]f64{ 1e6, 1e12 };
        const quantiles = [_]f64{ 1e-6, 0.01, 0.5, 0.99, 1 - 1e-6 };
        for (lambdas) |lambda| {
            for (quantiles) |q| {
                const k = alea.distributions.poissonQuantile(q, lambda);
                try expectFloatBetween("poisson huge quantile cdf", alea.distributions.poissonCdf(k, lambda), q, 1.0);
                try expectFloatBetween("poisson huge quantile predecessor", alea.distributions.poissonCdf(k - 1, lambda), 0.0, q);
            }
        }
    }

    // Multivariate marginal diagnostics.
    {
        const alpha = [_]f64{ 2, 3, 5 };
        const dirichlet = try alea.distributions.Dirichlet(f64).init(&alpha);
        const x: f64 = 0.3;
        const dirichlet_a: f64 = 2;
        const dirichlet_b: f64 = 8;
        const expected_beta = alea.distributions.betaCdf(x, dirichlet_a, dirichlet_b);
        try expectFloatBetween("dirichlet marginal", try dirichlet.marginalCdf(0, x), expected_beta - 1e-12, expected_beta + 1e-12);

        const probabilities = [_]f64{ 1, 3 };
        const multinomial = try alea.distributions.Multinomial.init(20, &probabilities);
        const marginal_k: f64 = 5;
        const marginal_n: f64 = 20;
        const marginal_p: f64 = 0.25;
        const expected_binomial = alea.distributions.binomialCdf(marginal_k, marginal_n, marginal_p);
        try expectFloatBetween("multinomial marginal", try multinomial.marginalCdf(0, marginal_k), expected_binomial - 1e-12, expected_binomial + 1e-12);
    }
}

fn checkBetaFamilies() !void {
    var engine = alea.FastPrng.init(0xbe7e);
    const rng = alea.Rng.init(&engine);

    // BetaPrime(3, 5) moments and quantile round-trip.
    {
        const dist = try alea.distributions.BetaPrime(f64).init(3, 5);
        const samples = 20_000;
        var sum: f64 = 0;
        var sum_sq: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const x = dist.sample(rng);
            sum += x;
            sum_sq += x * x;
        }
        const nf: f64 = @floatFromInt(samples);
        const mean = sum / nf;
        try expectFloatBetween("beta prime mean", mean, 0.72, 0.78);
        try expectFloatBetween("beta prime variance", sum_sq / nf - mean * mean, 0.36, 0.52);
        try expectFloatBetween("beta prime quantile", dist.cdf(dist.quantile(0.3)), 0.3 - 1e-9, 0.3 + 1e-9);
    }

    // BetaBinomial uniform and overdispersed moments.
    {
        const uniform_dist = try alea.distributions.BetaBinomial.init(10, 1, 1);
        const samples = 20_000;
        var sum: f64 = 0;
        var sum_sq: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const x: f64 = @floatFromInt(uniform_dist.sample(rng));
            sum += x;
            sum_sq += x * x;
        }
        const nf: f64 = @floatFromInt(samples);
        const mean = sum / nf;
        try expectFloatBetween("beta binomial uniform mean", mean, 4.9, 5.1);
        try expectFloatBetween("beta binomial uniform variance", sum_sq / nf - mean * mean, 9.0, 11.0);

        const over_dist = try alea.distributions.BetaBinomial.init(20, 0.5, 0.5);
        var over_sum: f64 = 0;
        var over_sum_sq: f64 = 0;
        i = 0;
        while (i < samples) : (i += 1) {
            const x: f64 = @floatFromInt(over_dist.sample(rng));
            over_sum += x;
            over_sum_sq += x * x;
        }
        const over_mean = over_sum / nf;
        try expectFloatBetween("beta binomial overdispersed mean", over_mean, 9.8, 10.2);
        try expectFloatBetween("beta binomial overdispersed variance", over_sum_sq / nf - over_mean * over_mean, 48.0, 57.0);

        var pmf_sum: f64 = 0;
        var k: u64 = 0;
        while (k <= 20) : (k += 1) pmf_sum += over_dist.pmf(@floatFromInt(k));
        try expectFloatBetween("beta binomial pmf sum", pmf_sum, 1.0 - 1e-10, 1.0 + 1e-10);

        const q: f64 = 0.7;
        const quantile = over_dist.quantile(q);
        try expectFloatBetween("beta binomial quantile", over_dist.cdf(quantile), q, 1.0);
    }
}

fn checkConstructorErgonomics() !void {
    var engine = alea.FastPrng.init(0xc057);
    const rng = alea.Rng.init(&engine);
    var buffered_engine = alea.FastPrng.init(0xc058);
    const buffered_rng = alea.Rng.init(&buffered_engine);

    try expectContinuousMean("log-normal-mean-cv", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            var dist = alea.distributions.LogNormal(f64).initMeanCv(2, 0.5) catch unreachable;
            return dist.sample(r);
        }
    }.sample, 1.95, 2.05);
    try expectContinuousMean("buffered-log-normal-mean-cv", buffered_rng, 20_000, struct {
        var dist = alea.distributions.BufferedLogNormal(f64, 128).initMeanCv(2, 0.5) catch unreachable;

        fn sample(r: alea.Rng) f64 {
            return dist.sample(r);
        }
    }.sample, 1.95, 2.05);
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

    const cached_inversion = try alea.distributions.CachedBinomial.init(1_000, 0.012);
    try expectCachedBinomialMean(rng, &cached_inversion, 11.8, 12.2);
    const cached_hin = try alea.distributions.CachedBinomial.init(10_000, 0.01);
    try expectCachedBinomialMean(rng, &cached_hin, 98.8, 101.2);

    // Huge-trial paths: tiny-p waiting, fair-to-HIN dispatch, and the stable
    // HIN setup.
    try expectBinomialMean(rng, 1_000_000_000_000_000_000, 2e-17, 19.4, 20.6);
    try expectBinomialMean(rng, 1_000_000_000, 0.5, 4.99e8, 5.01e8);
    try expectBinomialMean(rng, 1_000_000_000_000_000_000, 0.5, 4.99e17, 5.01e17);
}

fn expectCachedBinomialMean(rng: alea.Rng, dist: *const alea.distributions.CachedBinomial, min: f64, max: f64) !void {
    const samples = 10_000;
    var sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) sum += @floatFromInt(dist.sample(rng));
    try expectFloatBetween("cached binomial", sum / @as(f64, @floatFromInt(samples)), min, max);
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
    try expectDiscreteMean("hypergeometric-large", rng, 4_000, struct {
        fn sample(r: alea.Rng) u64 {
            return alea.distributions.hypergeometric(r, 5000, 2500, 500);
        }
    }.sample, 248.5, 251.5);
    try expectDiscreteMean("hypergeometric-skew-large", rng, 4_000, struct {
        fn sample(r: alea.Rng) u64 {
            return alea.distributions.hypergeometric(r, 10_000, 1_000, 2_000);
        }
    }.sample, 198.5, 201.5);
    // Variance recovery covers the inverse-transform, H2PE, and draw-loop
    // sampling paths.
    try expectDiscreteVariance("hypergeometric variance", rng, 20_000, struct {
        fn sample(r: alea.Rng) u64 {
            return alea.distributions.hypergeometric(r, 100, 30, 10);
        }
    }.sample, 1.85, 1.97);
    try expectDiscreteVariance("hypergeometric-large variance", rng, 20_000, struct {
        fn sample(r: alea.Rng) u64 {
            return alea.distributions.hypergeometric(r, 5000, 2500, 500);
        }
    }.sample, 110.5, 114.5);
    try expectDiscreteVariance("hypergeometric-skew-large variance", rng, 20_000, struct {
        fn sample(r: alea.Rng) u64 {
            return alea.distributions.hypergeometric(r, 10_000, 1_000, 2_000);
        }
    }.sample, 141.0, 147.0);
    // Rare successes fall back to the exact draw loop when the
    // inverse-transform PMF product overflows.
    try expectDiscreteVariance("hypergeometric-rare variance", rng, 20_000, struct {
        fn sample(r: alea.Rng) u64 {
            return alea.distributions.hypergeometric(r, 100_000, 100, 1_000);
        }
    }.sample, 0.90, 1.08);

    // Huge-population paths: H2PE, inverse-transform init, and the
    // gamma-Poisson negative-binomial mixture.
    try expectDiscreteMean("negative-binomial huge", rng, 20_000, struct {
        fn sample(r: alea.Rng) u64 {
            return alea.distributions.negativeBinomial(r, 1 << 20, 0.5);
        }
    }.sample, 1.038e6, 1.058e6);
    try expectDiscreteMean("hypergeometric huge", rng, 20_000, struct {
        fn sample(r: alea.Rng) u64 {
            return alea.distributions.hypergeometric(r, 1_000_000_000_000_000_000, 100_000_000_000_000_000, 500_000_000_000_000_000);
        }
    }.sample, 4.99e16, 5.01e16);
    try expectDiscreteMean("hypergeometric huge edge", rng, 20_000, struct {
        fn sample(r: alea.Rng) u64 {
            return alea.distributions.hypergeometric(r, 1_000_000_000_000_000_000, 5, 500_000_000_000_000_000);
        }
    }.sample, 2.4, 2.6);

    // Huge-population CDF and quantile: normal fallback above 2^53, the
    // Poisson limit for rare categories, and the near-full-draws complement.
    {
        const population: f64 = 1e18;
        const successes: f64 = 1e17;
        const draws: f64 = 5e17;
        var q: f64 = 0.05;
        while (q < 1) : (q += 0.1) {
            const k = alea.distributions.hypergeometricQuantile(q, population, successes, draws);
            try expectFloatBetween("hypergeometric huge quantile", alea.distributions.hypergeometricCdf(k, population, successes, draws), q - 1e-6, 1.0);
            try expectFloatBetween("hypergeometric huge quantile tail", alea.distributions.hypergeometricCdf(k - 1e7, population, successes, draws), 0.0, q - 1e-3);
        }
        try expectFloatBetween("hypergeometric huge median", alea.distributions.hypergeometricQuantile(0.5, population, successes, draws), 5e16 - 1, 5e16 + 1);

        const rare_successes: f64 = 1e10;
        const rare_draws: f64 = 1e10;
        try expectFloatBetween("hypergeometric huge rare cdf", alea.distributions.hypergeometricCdf(@as(f64, 100), population, rare_successes, rare_draws), 0.5265, 0.5267);
        try expectFloatBetween("hypergeometric huge rare median", alea.distributions.hypergeometricQuantile(0.5, population, rare_successes, rare_draws), 99, 101);

        const near_full = 1e18 - 1e10;
        try expectFloatBetween("hypergeometric huge folded cdf", alea.distributions.hypergeometricCdf(@as(f64, 999999), population, 1e6, near_full), 0.0099, 0.0100);
        try expectFloatBetween("hypergeometric huge folded quantile", alea.distributions.hypergeometricQuantile(0.5, population, 1e6, near_full), 1e6 - 1, 1e6 + 1);
    }

    // Hypergeometric CDF agrees with empirical frequencies.
    {
        const dist = try alea.distributions.Hypergeometric.init(100, 30, 10);
        const samples = 20_000;
        var count: usize = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            if (dist.sample(rng) <= 2) count += 1;
        }
        const empirical = @as(f64, @floatFromInt(count)) / @as(f64, @floatFromInt(samples));
        try expectFloatBetween("hypergeometric cdf", dist.cdf(2), empirical - 0.02, empirical + 0.02);
    }
}

fn expectDiscreteMean(comptime label: []const u8, rng: alea.Rng, samples: usize, sampleFn: *const fn (alea.Rng) u64, min: f64, max: f64) !void {
    var sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) sum += @floatFromInt(sampleFn(rng));
    try expectFloatBetween(label, sum / @as(f64, @floatFromInt(samples)), min, max);
}

fn expectDiscreteVariance(comptime label: []const u8, rng: alea.Rng, samples: usize, sampleFn: *const fn (alea.Rng) u64, min: f64, max: f64) !void {
    var sum: f64 = 0;
    var sum_sq: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) {
        const x: f64 = @floatFromInt(sampleFn(rng));
        sum += x;
        sum_sq += x * x;
    }
    const nf: f64 = @floatFromInt(samples);
    const mean = sum / nf;
    try expectFloatBetween(label, sum_sq / nf - mean * mean, min, max);
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
    try expectContinuousMean("standard-normal", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.standardNormal(r, f64);
        }
    }.sample, -0.05, 0.05);
    var native_normal_engine = alea.DefaultPrng.init(0xc0ff_ee41);
    const native_normal_rng = alea.Rng.init(&native_normal_engine);
    try expectContinuousMean("standard-normal-native-f32", native_normal_rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.standardNormalNativeF32(r);
        }
    }.sample, -0.05, 0.05);
    var native_parameterized_normal_engine = alea.DefaultPrng.init(0xc0ff_ee44);
    const native_parameterized_normal_rng = alea.Rng.init(&native_parameterized_normal_engine);
    try expectContinuousMean("normal-native-f32", native_parameterized_normal_rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.normalNativeF32(r, 5, 2);
        }
    }.sample, 4.95, 5.05);
    try expectContinuousMean("exponential", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.exponential(r, f64, 4);
        }
    }.sample, 0.24, 0.26);
    try expectContinuousMean("standard-exponential", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.standardExponential(r, f64);
        }
    }.sample, 0.98, 1.02);
    var native_exponential_engine = alea.DefaultPrng.init(0xc0ff_ee42);
    const native_exponential_rng = alea.Rng.init(&native_exponential_engine);
    try expectContinuousMean("standard-exponential-native-f32", native_exponential_rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.standardExponentialNativeF32(r);
        }
    }.sample, 0.98, 1.02);
    var native_parameterized_exponential_engine = alea.DefaultPrng.init(0xc0ff_ee45);
    const native_parameterized_exponential_rng = alea.Rng.init(&native_parameterized_exponential_engine);
    try expectContinuousMean("exponential-native-f32", native_parameterized_exponential_rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.exponentialNativeF32(r, 4);
        }
    }.sample, 0.24, 0.26);
    try expectContinuousMean("gamma", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.gamma(r, f64, 2, 3);
        }
    }.sample, 5.85, 6.15);
    try expectContinuousMean("gamma-shape-one", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.gamma(r, f64, 1, 3);
        }
    }.sample, 2.94, 3.06);
    try expectContinuousMean("gamma-shape-half", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.gamma(r, f64, 0.5, 3);
        }
    }.sample, 1.45, 1.55);
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
    var buffered_log_normal_engine = alea.DefaultPrng.init(0xc0ff_ee47);
    const buffered_log_normal_rng = alea.Rng.init(&buffered_log_normal_engine);
    try expectContinuousMean("buffered-log-normal", buffered_log_normal_rng, 20_000, struct {
        var dist = alea.distributions.BufferedLogNormal(f64, 128).init(0, 0.25) catch unreachable;

        fn sample(r: alea.Rng) f64 {
            return dist.sample(r);
        }
    }.sample, 1.02, 1.04);
    if (builtin.link_libc) {
        var libmvec_log_normal_engine = alea.DefaultPrng.init(0xc0ff_ee48);
        const libmvec_log_normal_rng = alea.Rng.init(&libmvec_log_normal_engine);
        var libmvec_dist = alea.distributions.LogNormalLibmvec(f64, 128).init(0, 0.25) catch |err| switch (err) {
            error.LibmvecUnavailable => null,
            else => return err,
        };
        if (libmvec_dist) |*dist| {
            defer dist.deinit();
            try expectContinuousMeanWithContext(*alea.distributions.LogNormalLibmvec(f64, 128), "log-normal-libmvec", libmvec_log_normal_rng, 20_000, dist, struct {
                fn sample(ctx: *alea.distributions.LogNormalLibmvec(f64, 128), r: alea.Rng) f64 {
                    return ctx.sample(r);
                }
            }.sample, 1.02, 1.04);
        }
        var libmvec_log_normal_f32_engine = alea.DefaultPrng.init(0xc0ff_ee50);
        const libmvec_log_normal_f32_rng = alea.Rng.init(&libmvec_log_normal_f32_engine);
        var libmvec_f32_dist = alea.distributions.LogNormalLibmvec(f32, 128).init(0, 0.25) catch |err| switch (err) {
            error.LibmvecUnavailable => null,
            else => return err,
        };
        if (libmvec_f32_dist) |*dist| {
            defer dist.deinit();
            try expectContinuousMeanWithContext(*alea.distributions.LogNormalLibmvec(f32, 128), "log-normal-libmvec-f32", libmvec_log_normal_f32_rng, 20_000, dist, struct {
                fn sample(ctx: *alea.distributions.LogNormalLibmvec(f32, 128), r: alea.Rng) f64 {
                    return ctx.sample(r);
                }
            }.sample, 1.02, 1.04);
        }
        var dlsym_log_normal_engine = alea.DefaultPrng.init(0xc0ff_ee49);
        const dlsym_log_normal_rng = alea.Rng.init(&dlsym_log_normal_engine);
        var dlsym_dist = alea.distributions.LogNormalDlsymExp(f64, 128).init(0, 0.25) catch |err| switch (err) {
            error.LibmUnavailable => null,
            else => return err,
        };
        if (dlsym_dist) |*dist| {
            defer dist.deinit();
            try expectContinuousMeanWithContext(*alea.distributions.LogNormalDlsymExp(f64, 128), "log-normal-dlsym-exp", dlsym_log_normal_rng, 20_000, dist, struct {
                fn sample(ctx: *alea.distributions.LogNormalDlsymExp(f64, 128), r: alea.Rng) f64 {
                    return ctx.sample(r);
                }
            }.sample, 1.02, 1.04);
        }
        var dlsym_log_normal_f32_engine = alea.DefaultPrng.init(0xc0ff_ee51);
        const dlsym_log_normal_f32_rng = alea.Rng.init(&dlsym_log_normal_f32_engine);
        var dlsym_f32_dist = alea.distributions.LogNormalDlsymExp(f32, 128).init(0, 0.25) catch |err| switch (err) {
            error.LibmUnavailable => null,
            else => return err,
        };
        if (dlsym_f32_dist) |*dist| {
            defer dist.deinit();
            try expectContinuousMeanWithContext(*alea.distributions.LogNormalDlsymExp(f32, 128), "log-normal-dlsym-exp-f32", dlsym_log_normal_f32_rng, 20_000, dist, struct {
                fn sample(ctx: *alea.distributions.LogNormalDlsymExp(f32, 128), r: alea.Rng) f64 {
                    return ctx.sample(r);
                }
            }.sample, 1.02, 1.04);
        }
    }
    var log_normal_exp2_engine = alea.DefaultPrng.init(0xc0ff_ee32);
    const log_normal_exp2_rng = alea.Rng.init(&log_normal_exp2_engine);
    try expectContinuousMean("log-normal-exp2-f32", log_normal_exp2_rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.logNormalExp2F32(r, 0, 0.25);
        }
    }.sample, 1.02, 1.04);
    var log_normal_approx_engine = alea.DefaultPrng.init(0xc0ff_ee31);
    const log_normal_approx_rng = alea.Rng.init(&log_normal_approx_engine);
    try expectContinuousMean("log-normal-approx-f32", log_normal_approx_rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.logNormalApproxF32(r, 0, 0.25);
        }
    }.sample, 1.02, 1.04);
    var log_normal_native_engine = alea.DefaultPrng.init(0xc0ff_ee43);
    const log_normal_native_rng = alea.Rng.init(&log_normal_native_engine);
    try expectContinuousMean("log-normal-native-f32", log_normal_native_rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.logNormalNativeF32(r, 0, 0.25);
        }
    }.sample, 1.02, 1.04);
    var log_normal_native_exp2_engine = alea.DefaultPrng.init(0xc0ff_ee46);
    const log_normal_native_exp2_rng = alea.Rng.init(&log_normal_native_exp2_engine);
    try expectContinuousMean("log-normal-native-exp2-f32", log_normal_native_exp2_rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.logNormalNativeExp2F32(r, 0, 0.25);
        }
    }.sample, 1.02, 1.04);
    try expectContinuousMean("half-normal", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.halfNormal(r, f64, 2);
        }
    }.sample, 1.55, 1.65);
    try expectContinuousMean("chi-squared", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.chiSquared(r, f64, 4);
        }
    }.sample, 3.9, 4.1);
    try expectContinuousMean("chi", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.chi(r, f64, 4);
        }
    }.sample, 1.85, 1.9);
    try expectContinuousMean("erlang", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.erlang(r, f64, 3, 2);
        }
    }.sample, 5.85, 6.15);
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
    try expectContinuousMean("arcsine", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.arcsine(r, f64, -1, 3);
        }
    }.sample, 0.95, 1.05);
    try expectContinuousMean("laplace", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.laplace(r, f64, 0, 1);
        }
    }.sample, -0.05, 0.05);
    try expectContinuousMean("logistic", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.logistic(r, f64, 0, 1);
        }
    }.sample, -0.05, 0.05);
    try expectContinuousMean("log-logistic", rng, 100_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.logLogistic(r, f64, 2, 3);
        }
    }.sample, 2.36, 2.46);
    try expectContinuousMean("kumaraswamy", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.kumaraswamy(r, f64, 2, 5);
        }
    }.sample, 0.365, 0.375);
    try expectContinuousMean("kumaraswamy-beta-one", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.kumaraswamy(r, f64, 2, 1);
        }
    }.sample, 0.66, 0.68);
    try expectContinuousMean("kumaraswamy-alpha-one", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.kumaraswamy(r, f64, 1, 5);
        }
    }.sample, 0.16, 0.18);
    try expectContinuousMean("power-function", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.powerFunction(r, f64, -1, 2, 3);
        }
    }.sample, 1.22, 1.28);
    try expectContinuousMean("power-function-shape-one", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.powerFunction(r, f64, -1, 2, 1);
        }
    }.sample, 0.48, 0.52);
    try expectContinuousMean("power-function-shape-two", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.powerFunction(r, f64, -1, 2, 2);
        }
    }.sample, 0.98, 1.02);
    try expectContinuousMean("rayleigh", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.rayleigh(r, f64, 2);
        }
    }.sample, 2.45, 2.57);
    try expectContinuousMean("maxwell", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.maxwell(r, f64, 2);
        }
    }.sample, 3.1, 3.25);
    try expectContinuousMean("weibull", rng, 20_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.weibull(r, f64, 2, 1.5);
        }
    }.sample, 1.75, 1.85);
    try expectContinuousMean("weibull-shape-one", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.weibull(r, f64, 2, 1);
        }
    }.sample, 1.96, 2.04);
    try expectContinuousMean("chi-squared-dof-one", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.chiSquared(r, f64, 1);
        }
    }.sample, 0.96, 1.04);
    try expectContinuousMean("chi-dof-one", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.chi(r, f64, 1);
        }
    }.sample, 0.77, 0.83);
    try expectContinuousMean("beta-unit", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.beta(r, f64, 1, 1);
        }
    }.sample, 0.49, 0.51);
    try expectContinuousMean("beta-alpha-two", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.beta(r, f64, 2, 1);
        }
    }.sample, 0.66, 0.68);
    try expectContinuousMean("beta-one-two", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.beta(r, f64, 1, 2);
        }
    }.sample, 0.32, 0.34);
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
    try expectContinuousMean("pareto", rng, 100_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.pareto(r, f64, 2, 3);
        }
    }.sample, 2.90, 3.10);
    try expectContinuousMean("generalized-pareto", rng, 100_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.generalizedPareto(r, f64, 1, 2, 0.3);
        }
    }.sample, 3.75, 3.95);
    try expectContinuousMean("inverse-gamma", rng, 50_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.inverseGamma(r, f64, 4, 2);
        }
    }.sample, 0.64, 0.69);
    try expectContinuousMean("scaled-inverse-chi-squared", rng, 100_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.scaledInverseChiSquared(r, f64, 5, 2);
        }
    }.sample, 3.20, 3.45);
    try expectContinuousMean("ex-gaussian", rng, 50_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.exGaussian(r, f64, 1, 2, 3);
        }
    }.sample, 3.90, 4.10);
    try expectContinuousMean("triangular", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.triangular(r, f64, 1, 2, 5);
        }
    }.sample, 2.60, 2.73);
    try expectContinuousMean("nakagami", rng, 50_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.nakagami(r, f64, 2, 1);
        }
    }.sample, 0.92, 0.96);
    try expectContinuousMean("rice", rng, 50_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.rice(r, f64, 1, 1);
        }
    }.sample, 1.52, 1.58);
    try expectContinuousMean("hoyt", rng, 50_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.hoyt(r, f64, 0.5, 1);
        }
    }.sample, 0.85, 0.88);
}

fn checkInverseAndRank() !void {
    var engine = alea.FastPrng.init(0x1645);
    const rng = alea.Rng.init(&engine);
    try expectContinuousMean("inverse-gaussian", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.inverseGaussian(r, f64, 1, 2);
        }
    }.sample, 0.97, 1.03);
    try expectContinuousMean("normal-inverse-gaussian", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.normalInverseGaussian(r, f64, 2, 1);
        }
    }.sample, 0.52, 0.63);
    try expectContinuousMean("zipf", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.zipf(r, f64, 10, 1.5);
        }
    }.sample, 2.3, 2.7);
    try expectContinuousMean("zeta", rng, 25_000, struct {
        fn sample(r: alea.Rng) f64 {
            return alea.distributions.zeta(r, f64, 3);
        }
    }.sample, 1.30, 1.45);
}

fn expectContinuousMean(comptime label: []const u8, rng: alea.Rng, samples: usize, sampleFn: *const fn (alea.Rng) f64, min: f64, max: f64) !void {
    var sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) sum += sampleFn(rng);
    try expectFloatBetween(label, sum / @as(f64, @floatFromInt(samples)), min, max);
}

fn expectContinuousMeanWithContext(
    comptime Context: type,
    comptime label: []const u8,
    rng: alea.Rng,
    samples: usize,
    context: Context,
    sampleFn: *const fn (Context, alea.Rng) f64,
    min: f64,
    max: f64,
) !void {
    var sum: f64 = 0;
    var i: usize = 0;
    while (i < samples) : (i += 1) sum += sampleFn(context, rng);
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
        const pareto_shape_one = alea.distributions.pareto(rng, f64, 2, 1);
        if (!(pareto_shape_one >= 2)) return error.DistributionCheckFailed;
        const cauchy = alea.distributions.cauchy(rng, f64, 0, 1);
        if (!std.math.isFinite(cauchy)) return error.DistributionCheckFailed;
        const log_logistic_shape_one = alea.distributions.logLogistic(rng, f64, 2, 1);
        if (!(log_logistic_shape_one > 0) or !std.math.isFinite(log_logistic_shape_one)) return error.DistributionCheckFailed;
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
    var category_sums = [_]f64{ 0, 0, 0 };
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
        for (counts, 0..) |count, index| {
            total += count;
            category_sums[index] += @floatFromInt(count);
        }
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

    // The multinomial draws its largest category first; the marginal means
    // must still match n·p_i / total.
    const sample_count: f64 = 5000;
    const expected_means = [_]f64{ 100.0 / 6.0, 200.0 / 6.0, 300.0 / 6.0 };
    for (expected_means, 0..) |expected, index| {
        try expectFloatBetween("multinomial marginal mean", category_sums[index] / sample_count, expected - 0.5, expected + 0.5);
    }

    var direct_engine = alea.ScalarPrng.init(0x7ec8);
    var circles: [128][2]f64 = undefined;
    var discs: [128][2]f64 = undefined;
    var spheres: [128][3]f64 = undefined;
    var balls: [128][3]f64 = undefined;
    alea.distributions.fillUnitCircleFrom(&direct_engine, f64, &circles);
    alea.distributions.fillUnitDiscFrom(&direct_engine, f64, &discs);
    alea.distributions.fillUnitSphereFrom(&direct_engine, f64, &spheres);
    alea.distributions.fillUnitBallFrom(&direct_engine, f64, &balls);
    for (circles) |circle| {
        try expectFloatBetween("fill unit circle norm", circle[0] * circle[0] + circle[1] * circle[1], 0.999999999999, 1.000000000001);
    }
    for (discs) |disc| {
        if (disc[0] * disc[0] + disc[1] * disc[1] > 1) return error.DistributionCheckFailed;
    }
    for (spheres) |sphere| {
        try expectFloatBetween("fill unit sphere norm", sphere[0] * sphere[0] + sphere[1] * sphere[1] + sphere[2] * sphere[2], 0.999999999999, 1.000000000001);
    }
    for (balls) |ball| {
        if (ball[0] * ball[0] + ball[1] * ball[1] + ball[2] * ball[2] > 1) return error.DistributionCheckFailed;
    }

    var vector_log_normal_engine = alea.ScalarPrng.init(0x7109);
    var log_normal_f64: [128]@Vector(4, f64) = undefined;
    alea.distributions.fillVectorLogNormalFrom(&vector_log_normal_engine, @Vector(4, f64), &log_normal_f64, 0, 0.25);
    try expectVectorMean(@Vector(4, f64), "vector log-normal f64x4", &log_normal_f64, 1.02, 1.04);

    var vector_log_normal_f32_engine = alea.ScalarPrng.init(0x710a);
    var log_normal_f32: [128]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorLogNormalFrom(&vector_log_normal_f32_engine, @Vector(8, f32), &log_normal_f32, 0, 0.25);
    try expectVectorMean(@Vector(8, f32), "vector log-normal f32x8", &log_normal_f32, 1.02, 1.04);

    var vector_log_normal_approx_engine = alea.ScalarPrng.init(0x710b);
    var log_normal_approx: [128]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorLogNormalApproxF32From(&vector_log_normal_approx_engine, @Vector(8, f32), &log_normal_approx, 0, 0.25);
    try expectVectorMean(@Vector(8, f32), "vector log-normal approx f32x8", &log_normal_approx, 1.02, 1.04);

    var vector_log_normal_exp2_engine = alea.ScalarPrng.init(0x710c);
    var log_normal_exp2: [128]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorLogNormalExp2F32From(&vector_log_normal_exp2_engine, @Vector(8, f32), &log_normal_exp2, 0, 0.25);
    try expectVectorMean(@Vector(8, f32), "vector log-normal exp2 f32x8", &log_normal_exp2, 1.02, 1.04);

    var vector_log_normal_native_engine = alea.ScalarPrng.init(0x710f);
    var log_normal_native: [128]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorLogNormalNativeF32From(&vector_log_normal_native_engine, @Vector(8, f32), &log_normal_native, 0, 0.25);
    try expectVectorMean(@Vector(8, f32), "vector log-normal native f32x8", &log_normal_native, 1.02, 1.04);

    var vector_log_normal_native_exp2_engine = alea.ScalarPrng.init(0x7112);
    var log_normal_native_exp2: [128]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorLogNormalNativeExp2F32From(&vector_log_normal_native_exp2_engine, @Vector(8, f32), &log_normal_native_exp2, 0, 0.25);
    try expectVectorMean(@Vector(8, f32), "vector log-normal native exp2 f32x8", &log_normal_native_exp2, 1.02, 1.04);

    var vector_native_normal_engine = alea.ScalarPrng.init(0x710d);
    var native_normal: [128]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorStandardNormalNativeF32From(&vector_native_normal_engine, @Vector(8, f32), &native_normal);
    try expectVectorMean(@Vector(8, f32), "vector standard-normal native f32x8", &native_normal, -0.08, 0.08);

    const approximation_vectors = 4096;

    var vector_table_normal_engine = alea.ScalarPrng.init(0x7115);
    var table_normal: [approximation_vectors]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorStandardNormalTableF32From(&vector_table_normal_engine, @Vector(8, f32), &table_normal);
    try expectVectorMoments(@Vector(8, f32), "vector standard-normal table f32x8", &table_normal, -0.03, 0.03, 0.96, 1.04);
    try expectStandardNormalCdfGates(@Vector(8, f32), "vector standard-normal table f32x8", &table_normal);

    var vector_table_normal_f64_engine = alea.ScalarPrng.init(0x7117);
    var table_normal_f64: [approximation_vectors]@Vector(4, f64) = undefined;
    alea.distributions.fillVectorStandardNormalTableF64From(&vector_table_normal_f64_engine, @Vector(4, f64), &table_normal_f64);
    try expectVectorMoments(@Vector(4, f64), "vector standard-normal table f64x4", &table_normal_f64, -0.03, 0.03, 0.96, 1.04);
    try expectStandardNormalCdfGates(@Vector(4, f64), "vector standard-normal table f64x4", &table_normal_f64);

    var vector_native_exponential_engine = alea.ScalarPrng.init(0x710e);
    var native_exponential: [128]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorStandardExponentialNativeF32From(&vector_native_exponential_engine, @Vector(8, f32), &native_exponential);
    try expectVectorMean(@Vector(8, f32), "vector standard-exponential native f32x8", &native_exponential, 0.94, 1.06);

    var vector_approx_log_exponential_engine = alea.ScalarPrng.init(0x7113);
    var approx_log_exponential: [approximation_vectors]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorStandardExponentialApproxLogF32From(&vector_approx_log_exponential_engine, @Vector(8, f32), &approx_log_exponential);
    try expectVectorMoments(@Vector(8, f32), "vector standard-exponential approx-log f32x8", &approx_log_exponential, 0.96, 1.04, 0.90, 1.10);
    try expectStandardExponentialCdfGates(@Vector(8, f32), "vector standard-exponential approx-log f32x8", &approx_log_exponential);

    var vector_table_exponential_engine = alea.ScalarPrng.init(0x7119);
    var table_exponential: [approximation_vectors]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorStandardExponentialTableF32From(&vector_table_exponential_engine, @Vector(8, f32), &table_exponential);
    try expectVectorMoments(@Vector(8, f32), "vector standard-exponential table f32x8", &table_exponential, 0.96, 1.04, 0.90, 1.10);
    try expectStandardExponentialCdfGates(@Vector(8, f32), "vector standard-exponential table f32x8", &table_exponential);

    var vector_table_exponential_f64_engine = alea.ScalarPrng.init(0x711a);
    var table_exponential_f64: [approximation_vectors]@Vector(4, f64) = undefined;
    alea.distributions.fillVectorStandardExponentialTableF64From(&vector_table_exponential_f64_engine, @Vector(4, f64), &table_exponential_f64);
    try expectVectorMoments(@Vector(4, f64), "vector standard-exponential table f64x4", &table_exponential_f64, 0.96, 1.04, 0.90, 1.10);
    try expectStandardExponentialCdfGates(@Vector(4, f64), "vector standard-exponential table f64x4", &table_exponential_f64);

    var vector_parameterized_native_normal_engine = alea.ScalarPrng.init(0x7110);
    var parameterized_native_normal: [128]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorNormalNativeF32From(&vector_parameterized_native_normal_engine, @Vector(8, f32), &parameterized_native_normal, 5, 2);
    try expectVectorMean(@Vector(8, f32), "vector normal native f32x8", &parameterized_native_normal, 4.85, 5.15);

    var vector_parameterized_table_normal_engine = alea.ScalarPrng.init(0x7116);
    var parameterized_table_normal: [approximation_vectors]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorNormalTableF32From(&vector_parameterized_table_normal_engine, @Vector(8, f32), &parameterized_table_normal, 5, 2);
    try expectVectorMoments(@Vector(8, f32), "vector normal table f32x8", &parameterized_table_normal, 4.94, 5.06, 3.8, 4.2);

    var vector_parameterized_table_normal_f64_engine = alea.ScalarPrng.init(0x7118);
    var parameterized_table_normal_f64: [approximation_vectors]@Vector(4, f64) = undefined;
    alea.distributions.fillVectorNormalTableF64From(&vector_parameterized_table_normal_f64_engine, @Vector(4, f64), &parameterized_table_normal_f64, 5, 2);
    try expectVectorMoments(@Vector(4, f64), "vector normal table f64x4", &parameterized_table_normal_f64, 4.94, 5.06, 3.8, 4.2);

    var vector_parameterized_native_exponential_engine = alea.ScalarPrng.init(0x7111);
    var parameterized_native_exponential: [128]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorExponentialNativeF32From(&vector_parameterized_native_exponential_engine, @Vector(8, f32), &parameterized_native_exponential, 4);
    try expectVectorMean(@Vector(8, f32), "vector exponential native f32x8", &parameterized_native_exponential, 0.23, 0.27);

    var vector_parameterized_approx_log_exponential_engine = alea.ScalarPrng.init(0x7114);
    var parameterized_approx_log_exponential: [approximation_vectors]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorExponentialApproxLogF32From(&vector_parameterized_approx_log_exponential_engine, @Vector(8, f32), &parameterized_approx_log_exponential, 4);
    try expectVectorMoments(@Vector(8, f32), "vector exponential approx-log f32x8", &parameterized_approx_log_exponential, 0.24, 0.26, 0.055, 0.075);

    var vector_parameterized_table_exponential_engine = alea.ScalarPrng.init(0x711b);
    var parameterized_table_exponential: [approximation_vectors]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorExponentialTableF32From(&vector_parameterized_table_exponential_engine, @Vector(8, f32), &parameterized_table_exponential, 4);
    try expectVectorMoments(@Vector(8, f32), "vector exponential table f32x8", &parameterized_table_exponential, 0.24, 0.26, 0.055, 0.075);

    var vector_parameterized_table_exponential_f64_engine = alea.ScalarPrng.init(0x711c);
    var parameterized_table_exponential_f64: [approximation_vectors]@Vector(4, f64) = undefined;
    alea.distributions.fillVectorExponentialTableF64From(&vector_parameterized_table_exponential_f64_engine, @Vector(4, f64), &parameterized_table_exponential_f64, 4);
    try expectVectorMoments(@Vector(4, f64), "vector exponential table f64x4", &parameterized_table_exponential_f64, 0.24, 0.26, 0.055, 0.075);
}

fn checkMultivariateNormal() !void {
    const expected_mean = [_]f64{ 1, -2, 0.5 };
    const expected_covariance = [_]f64{
        1.0,  0.6, -0.2,
        0.6,  2.0, 0.3,
        -0.2, 0.3, 0.5,
    };
    const allocator = if (builtin.target.os.tag == .wasi) std.heap.wasm_allocator else std.heap.smp_allocator;
    var sampler = try alea.distributions.MultivariateNormal(f64).init(
        allocator,
        &expected_mean,
        &expected_covariance,
    );
    defer sampler.deinit();

    const sample_count = 40_000;
    var engine = alea.ScalarPrng.init(0x4d56_4e4f);
    var sums = [_]f64{0} ** expected_mean.len;
    var products = [_]f64{0} ** expected_covariance.len;
    var sample: [expected_mean.len]f64 = undefined;
    for (0..sample_count) |_| {
        sampler.sampleIntoFrom(&engine, &sample);
        for (0..expected_mean.len) |row| {
            sums[row] += sample[row];
            for (0..expected_mean.len) |col| {
                products[row * expected_mean.len + col] += sample[row] * sample[col];
            }
        }
    }

    const count: f64 = @floatFromInt(sample_count);
    var observed_mean: [expected_mean.len]f64 = undefined;
    for (0..expected_mean.len) |index| {
        observed_mean[index] = sums[index] / count;
        try expectFloatBetween(
            "multivariate-normal mean",
            observed_mean[index],
            expected_mean[index] - 0.035,
            expected_mean[index] + 0.035,
        );
    }
    for (0..expected_mean.len) |row| {
        for (0..expected_mean.len) |col| {
            const observed = products[row * expected_mean.len + col] / count -
                observed_mean[row] * observed_mean[col];
            const expected = expected_covariance[row * expected_mean.len + col];
            try expectFloatBetween(
                "multivariate-normal covariance",
                observed,
                expected - 0.05,
                expected + 0.05,
            );
        }
    }

    const static_sampler = try alea.distributions.StaticMultivariateNormal(f64, 3).init(
        expected_mean,
        .{
            .{ 1.0, 0.6, -0.2 },
            .{ 0.6, 2.0, 0.3 },
            .{ -0.2, 0.3, 0.5 },
        },
    );
    var static_engine = alea.ScalarPrng.init(0x4d56_4e50);
    var static_sums = [_]f64{0} ** expected_mean.len;
    var static_products = [_]f64{0} ** expected_covariance.len;
    for (0..sample_count) |_| {
        const static_sample = static_sampler.sampleFrom(&static_engine);
        for (0..expected_mean.len) |row| {
            static_sums[row] += static_sample[row];
            for (0..expected_mean.len) |col| {
                static_products[row * expected_mean.len + col] +=
                    static_sample[row] * static_sample[col];
            }
        }
    }
    for (0..expected_mean.len) |index| {
        observed_mean[index] = static_sums[index] / count;
        try expectFloatBetween(
            "static-multivariate-normal mean",
            observed_mean[index],
            expected_mean[index] - 0.035,
            expected_mean[index] + 0.035,
        );
    }
    for (0..expected_mean.len) |row| {
        for (0..expected_mean.len) |col| {
            const observed = static_products[row * expected_mean.len + col] / count -
                observed_mean[row] * observed_mean[col];
            const expected = expected_covariance[row * expected_mean.len + col];
            try expectFloatBetween(
                "static-multivariate-normal covariance",
                observed,
                expected - 0.05,
                expected + 0.05,
            );
        }
    }
}

fn expectVectorMean(comptime VectorType: type, comptime label: []const u8, samples: []const VectorType, min: f64, max: f64) !void {
    const info = @typeInfo(VectorType).vector;
    var sum: f64 = 0;
    for (samples) |sample| {
        inline for (0..info.len) |lane| sum += sample[lane];
    }
    const count = samples.len * info.len;
    try expectFloatBetween(label, sum / @as(f64, @floatFromInt(count)), min, max);
}

fn expectVectorMoments(comptime VectorType: type, comptime label: []const u8, samples: []const VectorType, min_mean: f64, max_mean: f64, min_variance: f64, max_variance: f64) !void {
    const info = @typeInfo(VectorType).vector;
    var sum: f64 = 0;
    var sum_squares: f64 = 0;
    for (samples) |sample| {
        inline for (0..info.len) |lane| {
            const value: f64 = @floatCast(sample[lane]);
            sum += value;
            sum_squares += value * value;
        }
    }
    const count: f64 = @floatFromInt(samples.len * info.len);
    const mean = sum / count;
    const variance = sum_squares / count - mean * mean;
    try expectFloatBetween(label, mean, min_mean, max_mean);
    try expectFloatBetween(label, variance, min_variance, max_variance);
}

/// Longer seeded moment-recovery run for the core and recently added
/// multivariate/directional families. Invoked with `--long [samples]`.
fn checkLongRun(samples: usize) !void {
    const allocator = std.heap.smp_allocator;
    const nf: f64 = @floatFromInt(samples);

    {
        var engine = alea.FastPrng.init(0x10c1);
        const rng = alea.Rng.init(&engine);
        var sum: f64 = 0;
        var sum_sq: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const x = alea.distributions.standardNormal(rng, f64);
            sum += x;
            sum_sq += x * x;
        }
        const mean = sum / nf;
        try expectFloatBetween("long normal mean", mean, -0.005, 0.005);
        try expectFloatBetween("long normal variance", sum_sq / nf - mean * mean, 0.99, 1.01);
    }

    {
        var engine = alea.FastPrng.init(0x10c2);
        const rng = alea.Rng.init(&engine);
        var sum: f64 = 0;
        var sum_sq: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const x = alea.distributions.standardExponential(rng, f64);
            sum += x;
            sum_sq += x * x;
        }
        const mean = sum / nf;
        try expectFloatBetween("long exponential mean", mean, 0.99, 1.01);
        try expectFloatBetween("long exponential variance", sum_sq / nf - mean * mean, 0.98, 1.02);
    }

    {
        var engine = alea.FastPrng.init(0x10c3);
        const rng = alea.Rng.init(&engine);
        var sum: f64 = 0;
        var sum_sq: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const x: f64 = @floatFromInt(alea.distributions.poisson(rng, 4));
            sum += x;
            sum_sq += x * x;
        }
        const mean = sum / nf;
        try expectFloatBetween("long poisson mean", mean, 3.98, 4.02);
        try expectFloatBetween("long poisson variance", sum_sq / nf - mean * mean, 3.96, 4.04);
    }

    {
        var engine = alea.FastPrng.init(0x10c4);
        const rng = alea.Rng.init(&engine);
        var sum: f64 = 0;
        var sum_sq: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const x = alea.distributions.gamma(rng, f64, 2.5, 1.5);
            sum += x;
            sum_sq += x * x;
        }
        const mean = sum / nf;
        try expectFloatBetween("long gamma mean", mean, 3.73, 3.77);
        try expectFloatBetween("long gamma variance", sum_sq / nf - mean * mean, 5.56, 5.69);
    }

    {
        var engine = alea.FastPrng.init(0x10c5);
        const rng = alea.Rng.init(&engine);
        const mean = [_]f64{ 0, 0 };
        const covariance = [_]f64{ 1, 0.3, 0.3, 1 };
        var dist = try alea.distributions.MultivariateNormal(f64).init(allocator, &mean, &covariance);
        defer dist.deinit();
        var sums = [_]f64{0} ** 2;
        var sums_sq = [_]f64{0} ** 2;
        var cross: f64 = 0;
        var out: [2]f64 = undefined;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            dist.sampleInto(rng, &out);
            sums[0] += out[0];
            sums[1] += out[1];
            sums_sq[0] += out[0] * out[0];
            sums_sq[1] += out[1] * out[1];
            cross += out[0] * out[1];
        }
        const m0 = sums[0] / nf;
        const m1 = sums[1] / nf;
        try expectFloatBetween("long mvn mean0", m0, -0.005, 0.005);
        try expectFloatBetween("long mvn mean1", m1, -0.005, 0.005);
        try expectFloatBetween("long mvn var0", sums_sq[0] / nf - m0 * m0, 0.99, 1.01);
        try expectFloatBetween("long mvn var1", sums_sq[1] / nf - m1 * m1, 0.99, 1.01);
        try expectFloatBetween("long mvn cov01", cross / nf - m0 * m1, 0.29, 0.31);
    }

    {
        var engine = alea.FastPrng.init(0x10c6);
        const rng = alea.Rng.init(&engine);
        const mean = [_]f64{ 0, 0 };
        const covariance = [_]f64{ 1, 0.3, 0.3, 1 };
        var dist = try alea.distributions.MultivariateT(f64).init(allocator, &mean, &covariance, 5);
        defer dist.deinit();
        var sums = [_]f64{0} ** 2;
        var sums_sq = [_]f64{0} ** 2;
        var cross: f64 = 0;
        var out: [2]f64 = undefined;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            dist.sampleInto(rng, &out);
            sums[0] += out[0];
            sums[1] += out[1];
            sums_sq[0] += out[0] * out[0];
            sums_sq[1] += out[1] * out[1];
            cross += out[0] * out[1];
        }
        const m0 = sums[0] / nf;
        const m1 = sums[1] / nf;
        try expectFloatBetween("long mvt mean0", m0, -0.01, 0.01);
        try expectFloatBetween("long mvt mean1", m1, -0.01, 0.01);
        try expectFloatBetween("long mvt var0", sums_sq[0] / nf - m0 * m0, 1.63, 1.70);
        try expectFloatBetween("long mvt var1", sums_sq[1] / nf - m1 * m1, 1.63, 1.70);
        try expectFloatBetween("long mvt cov01", cross / nf - m0 * m1, 0.48, 0.52);
    }

    {
        var engine = alea.FastPrng.init(0x10c7);
        const rng = alea.Rng.init(&engine);
        const location = [_]f64{ 0, 0 };
        const scale = [_]f64{ 1, 0.5, 0.5, 2 };
        const shape = [_]f64{ 2, -1 };
        var dist = try alea.distributions.MultivariateSkewNormal(f64).init(allocator, &location, &scale, &shape);
        defer dist.deinit();
        const inv_sqrt5: f64 = 1.0 / @sqrt(5.0);
        const delta0: f64 = 1.5 * inv_sqrt5;
        const delta1: f64 = -inv_sqrt5;
        const normal_factor: f64 = @sqrt(2.0 / std.math.pi);
        const cov_factor: f64 = 2.0 / std.math.pi;
        const expected_mean0 = normal_factor * delta0;
        const expected_mean1 = normal_factor * delta1;
        const expected_var0 = 1 - cov_factor * delta0 * delta0;
        const expected_var1 = 2 - cov_factor * delta1 * delta1;
        const expected_cov01 = 0.5 - cov_factor * delta0 * delta1;
        var sums = [_]f64{0} ** 2;
        var sums_sq = [_]f64{0} ** 2;
        var cross: f64 = 0;
        var out: [2]f64 = undefined;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            dist.sampleInto(rng, &out);
            sums[0] += out[0];
            sums[1] += out[1];
            sums_sq[0] += out[0] * out[0];
            sums_sq[1] += out[1] * out[1];
            cross += out[0] * out[1];
        }
        const m0 = sums[0] / nf;
        const m1 = sums[1] / nf;
        try expectFloatBetween("long mvskewn mean0", m0, expected_mean0 - 0.004, expected_mean0 + 0.004);
        try expectFloatBetween("long mvskewn mean1", m1, expected_mean1 - 0.004, expected_mean1 + 0.004);
        try expectFloatBetween("long mvskewn var0", sums_sq[0] / nf - m0 * m0, expected_var0 - 0.01, expected_var0 + 0.01);
        try expectFloatBetween("long mvskewn var1", sums_sq[1] / nf - m1 * m1, expected_var1 - 0.01, expected_var1 + 0.01);
        try expectFloatBetween("long mvskewn cov01", cross / nf - m0 * m1, expected_cov01 - 0.01, expected_cov01 + 0.01);
    }

    {
        var engine = alea.FastPrng.init(0x10c8);
        const rng = alea.Rng.init(&engine);
        const dist = try alea.distributions.Kent(f64).init(.{ 0, 0, 1 }, .{ 1, 0, 0 }, 5, 1.5);
        const rho = dist.meanResultantLength();
        var sum_z: f64 = 0;
        var sums_sq = [_]f64{0} ** 3;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const point = dist.sample(rng);
            sum_z += point[2];
            inline for (0..3) |k| sums_sq[k] += point[k] * point[k];
        }
        try expectFloatBetween("long kent mean resultant", sum_z / nf, rho - 0.003, rho + 0.003);
        try expectFloatBetween("long kent var0", sums_sq[0] / nf, dist.varianceAt(0) - 0.005, dist.varianceAt(0) + 0.005);
        try expectFloatBetween("long kent var1", sums_sq[1] / nf, dist.varianceAt(1) - 0.005, dist.varianceAt(1) + 0.005);
    }

    {
        var engine = alea.FastPrng.init(0x10c9);
        const rng = alea.Rng.init(&engine);
        const matrix = [3][3]f64{
            .{ 0, 0, 0 },
            .{ 0, -3, 0 },
            .{ 0, 0, -3 },
        };
        const dist = try alea.distributions.Bingham(f64, 3).init(matrix);
        var sum_sq: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const point = dist.sample(rng);
            sum_sq += point[0] * point[0];
        }
        const steps: usize = 20_000;
        var num: f64 = 0;
        var den: f64 = 0;
        var j: usize = 0;
        while (j < steps) : (j += 1) {
            const w = -1 + 2 * (@as(f64, @floatFromInt(j)) + 0.5) / @as(f64, @floatFromInt(steps));
            const weight = @exp(3 * w * w);
            num += w * w * weight;
            den += weight;
        }
        const expected = num / den;
        try expectFloatBetween("long bingham mean x0^2", sum_sq / nf, expected - 0.003, expected + 0.003);
    }

    {
        var engine = alea.FastPrng.init(0x10ca);
        const rng = alea.Rng.init(&engine);
        const mean = [3]f64{ 0, 0, 1 };
        const dist = try alea.distributions.VonMisesFisher(f64, 3).init(mean, 5);
        const expected = dist.meanResultantLength();
        var sum: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const point = dist.sample(rng);
            sum += point[2];
        }
        try expectFloatBetween("long vmf mean resultant", sum / nf, expected - 0.002, expected + 0.002);
    }

    // Exact SO(3) matrix Fisher isotropic trace moment.
    {
        var engine = alea.FastPrng.init(0x10ce);
        const rng = alea.Rng.init(&engine);
        const d: f64 = 2;
        const dist = try alea.distributions.MatrixFisher(f64).init(.{
            .{ d, 0, 0 },
            .{ 0, d, 0 },
            .{ 0, 0, d },
        });
        const steps: usize = 20_000;
        var num: f64 = 0;
        var den: f64 = 0;
        var i: usize = 0;
        while (i < steps) : (i += 1) {
            const w = -1 + 2 * (@as(f64, @floatFromInt(i)) + 0.5) / @as(f64, @floatFromInt(steps));
            const weight = @exp(4 * d * w * w) * @sqrt(1 - w * w);
            num += (4 * w * w - 1) * weight;
            den += weight;
        }
        const expected = num / den;
        var sum: f64 = 0;
        i = 0;
        while (i < samples) : (i += 1) {
            const rotation = dist.sample(rng);
            sum += rotation[0][0] + rotation[1][1] + rotation[2][2];
        }
        try expectFloatBetween("long matrix fisher trace", sum / nf, expected - 0.004, expected + 0.004);
    }

    // O(3) matrix Fisher component frequency.
    {
        var engine = alea.FastPrng.init(0x10d1);
        const rng = alea.Rng.init(&engine);
        const parameter = [3][3]f64{
            .{ 2, 0, 0 },
            .{ 0, 2, 0 },
            .{ 0, 0, 2 },
        };
        const dist = try alea.distributions.MatrixFisherO3(f64).init(parameter);
        const expected = dist.soWeightValue();
        var positive_det: usize = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const r = dist.sample(rng);
            const det = r[0][0] * (r[1][1] * r[2][2] - r[1][2] * r[2][1]) -
                r[0][1] * (r[1][0] * r[2][2] - r[1][2] * r[2][0]) +
                r[0][2] * (r[1][0] * r[2][1] - r[1][1] * r[2][0]);
            if (det > 0) positive_det += 1;
        }
        try expectFloatBetween("long matrix fisher o3 det frequency", @as(f64, @floatFromInt(positive_det)) / nf, expected - 0.005, expected + 0.005);
    }

    // SIMD von Mises-Fisher lane moment.
    {
        var engine = alea.FastPrng.init(0x10cf);
        const rng = alea.Rng.init(&engine);
        const V = @Vector(4, f64);
        const kappa: f64 = 5;
        const dist = try alea.distributions.VectorVonMisesFisher(V).init(.{ 0, 0, 1 }, kappa);
        const vmf = try alea.distributions.VonMisesFisher(f64, 3).init(.{ 0, 0, 1 }, kappa);
        const expected = vmf.meanResultantLength();
        const vector_count = samples / 4;
        var sum_z: f64 = 0;
        var i: usize = 0;
        while (i < vector_count) : (i += 1) {
            const point = dist.sample(rng);
            inline for (0..4) |lane| sum_z += point[2][lane];
        }
        const lane_nf: f64 = @floatFromInt(vector_count * 4);
        try expectFloatBetween("long vector vmf mean", sum_z / lane_nf, expected - 0.003, expected + 0.003);
    }

    // Scalar Watson bipolar and girdle mean cosine-squared moments.
    {
        var engine = alea.FastPrng.init(0x10d2);
        const rng = alea.Rng.init(&engine);
        const bipolar = try alea.distributions.Watson(f64, 3).init(.{ 0, 0, 1 }, 5);
        const girdle = try alea.distributions.Watson(f64, 3).init(.{ 0, 0, 1 }, -3);
        const bipolar_expected = bipolar.meanCosineSquared();
        const girdle_expected = girdle.meanCosineSquared();
        var bipolar_sum: f64 = 0;
        var girdle_sum: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const p = bipolar.sample(rng);
            bipolar_sum += p[2] * p[2];
            const q = girdle.sample(rng);
            girdle_sum += q[2] * q[2];
        }
        try expectFloatBetween("long watson bipolar mean cos2", bipolar_sum / nf, bipolar_expected - 0.003, bipolar_expected + 0.003);
        try expectFloatBetween("long watson girdle mean cos2", girdle_sum / nf, girdle_expected - 0.003, girdle_expected + 0.003);
    }

    // SIMD Watson lane mean cosine-squared moment.
    {
        var engine = alea.FastPrng.init(0x10d3);
        const rng = alea.Rng.init(&engine);
        const V = @Vector(4, f64);
        const kappa: f64 = 5;
        const dist = try alea.distributions.VectorWatson(V).init(.{ 0, 0, 1 }, kappa);
        const scalar = try alea.distributions.Watson(f64, 3).init(.{ 0, 0, 1 }, kappa);
        const expected = scalar.meanCosineSquared();
        const vector_count = samples / 4;
        var sum_z2: f64 = 0;
        var i: usize = 0;
        while (i < vector_count) : (i += 1) {
            const point = dist.sample(rng);
            inline for (0..4) |lane| sum_z2 += point[2][lane] * point[2][lane];
        }
        const lane_nf: f64 = @floatFromInt(vector_count * 4);
        try expectFloatBetween("long vector watson mean cos2", sum_z2 / lane_nf, expected - 0.003, expected + 0.003);
    }

    // SIMD Bingham lane axial moment.
    {
        var engine = alea.FastPrng.init(0x10d4);
        const rng = alea.Rng.init(&engine);
        const V = @Vector(4, f64);
        const matrix = [3][3]f64{
            .{ 0, 0, 0 },
            .{ 0, -5, 0 },
            .{ 0, 0, -5 },
        };
        const dist = try alea.distributions.VectorBingham(V).init(matrix);
        const steps: usize = 20_000;
        var num: f64 = 0;
        var den: f64 = 0;
        var j: usize = 0;
        while (j < steps) : (j += 1) {
            const w = -1 + 2 * (@as(f64, @floatFromInt(j)) + 0.5) / @as(f64, @floatFromInt(steps));
            const weight = @exp(5 * w * w);
            num += w * w * weight;
            den += weight;
        }
        const expected = num / den;
        const vector_count = samples / 4;
        var sum_x0_sq: f64 = 0;
        var i: usize = 0;
        while (i < vector_count) : (i += 1) {
            const point = dist.sample(rng);
            inline for (0..4) |lane| sum_x0_sq += point[0][lane] * point[0][lane];
        }
        const lane_nf: f64 = @floatFromInt(vector_count * 4);
        try expectFloatBetween("long vector bingham mean x0^2", sum_x0_sq / lane_nf, expected - 0.003, expected + 0.003);
    }

    // SIMD Kent lane mean-resultant recovery.
    {
        var engine = alea.FastPrng.init(0x10d5);
        const rng = alea.Rng.init(&engine);
        const V = @Vector(4, f64);
        const dist = try alea.distributions.VectorKent(V).init(.{ 0, 0, 1 }, .{ 1, 0, 0 }, 5, 1.5);
        const expected = dist.meanResultantLength();
        const vector_count = samples / 4;
        var sum_z: f64 = 0;
        var i: usize = 0;
        while (i < vector_count) : (i += 1) {
            const point = dist.sample(rng);
            inline for (0..4) |lane| sum_z += point[2][lane];
        }
        const lane_nf: f64 = @floatFromInt(vector_count * 4);
        try expectFloatBetween("long vector kent mean resultant", sum_z / lane_nf, expected - 0.003, expected + 0.003);
    }

    // Gibbs matrix Langevin marginal moments.
    {
        var engine = alea.FastPrng.init(0x10d0);
        const rng = alea.Rng.init(&engine);
        const kappa: f64 = 5;
        const parameter = [6]f64{ 0, 0, 0, 0, kappa, 0 };
        var dist = try alea.distributions.MatrixVonMisesFisher(f64).initWithOptions(allocator, &parameter, 3, 2, 100, 10);
        defer dist.deinit();
        const vmf = try alea.distributions.VonMisesFisher(f64, 3).init(.{ 0, 0, 1 }, kappa);
        const expected = vmf.meanResultantLength();
        const count = @min(samples, 100_000);
        var sum_z: f64 = 0;
        var sum_col1 = [_]f64{0} ** 3;
        var out: [6]f64 = undefined;
        var i: usize = 0;
        while (i < count) : (i += 1) {
            try dist.sampleInto(rng, &out);
            sum_z += out[4];
            inline for (0..3) |k| sum_col1[k] += out[k * 2 + 1];
        }
        const count_nf: f64 = @floatFromInt(count);
        try expectFloatBetween("long matrix vmf first-column mean", sum_z / count_nf, expected - 0.02, expected + 0.02);
        inline for (0..3) |k| {
            try expectFloatBetween("long matrix vmf second-column mean", sum_col1[k] / count_nf, -0.02, 0.02);
        }
    }

    // Wishart and Inverse-Wishart joint moment recovery with a non-diagonal
    // scale; the full Bartlett L*A product is required for these means and the
    // off-diagonal variance.
    {
        var engine = alea.FastPrng.init(0x10d7);
        const rng = alea.Rng.init(&engine);
        const scale = [_]f64{ 2, 0.5, 0.5, 1 };
        var wishart = try alea.distributions.Wishart(f64).init(allocator, &scale, 6);
        defer wishart.deinit();
        var iwishart = try alea.distributions.InverseWishart(f64).init(allocator, &scale, 10);
        defer iwishart.deinit();
        var sum_w00: f64 = 0;
        var sum_w01: f64 = 0;
        var sum_w11: f64 = 0;
        var sum_w01_sq: f64 = 0;
        var sum_i00: f64 = 0;
        var sum_i01: f64 = 0;
        var sum_i11: f64 = 0;
        var w: [4]f64 = undefined;
        var iw: [4]f64 = undefined;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            wishart.sampleInto(rng, &w);
            sum_w00 += w[0];
            sum_w01 += w[1];
            sum_w11 += w[3];
            sum_w01_sq += w[1] * w[1];
            iwishart.sampleInto(rng, &iw);
            sum_i00 += iw[0];
            sum_i01 += iw[1];
            sum_i11 += iw[3];
        }
        try expectFloatBetween("long wishart mean00", sum_w00 / nf, 11.99, 12.01);
        try expectFloatBetween("long wishart mean01", sum_w01 / nf, 2.99, 3.01);
        try expectFloatBetween("long wishart mean11", sum_w11 / nf, 5.99, 6.01);
        const wishart_mean01 = sum_w01 / nf;
        try expectFloatBetween("long wishart off-diagonal variance", sum_w01_sq / nf - wishart_mean01 * wishart_mean01, 13.4, 13.6);
        // E[IW] = Psi / (nu - dim - 1) = Psi / 7.
        try expectFloatBetween("long inverse wishart mean00", sum_i00 / nf, 0.2807, 0.2907);
        try expectFloatBetween("long inverse wishart mean01", sum_i01 / nf, 0.0694, 0.0734);
        try expectFloatBetween("long inverse wishart mean11", sum_i11 / nf, 0.1399, 0.1459);
    }

    // Discrete sampler CDF consistency at fixed thresholds.
    {
        var engine = alea.FastPrng.init(0x10d6);
        const rng = alea.Rng.init(&engine);
        const binomial = try alea.distributions.Binomial.init(20, 0.3);
        const poisson = try alea.distributions.Poisson.init(5);
        const hypergeometric = try alea.distributions.Hypergeometric.init(100, 30, 10);
        const negative_binomial = try alea.distributions.NegativeBinomial.init(3, 0.5);
        const geometric = try alea.distributions.Geometric.init(0.4);
        const zipf_dist = try alea.distributions.Zipf(f64).init(40, 1.5);
        const zeta_dist = try alea.distributions.Zeta(f64).init(2.5);
        const bernoulli = try alea.distributions.Bernoulli.init(0.3);
        var binomial_hits = [_]usize{0} ** 3;
        var poisson_hits = [_]usize{0} ** 3;
        var hypergeometric_hits = [_]usize{0} ** 3;
        var negative_binomial_hits = [_]usize{0} ** 3;
        var geometric_hits = [_]usize{0} ** 3;
        var zipf_hits = [_]usize{0} ** 3;
        var zeta_hits = [_]usize{0} ** 3;
        var bernoulli_hits: usize = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const b = binomial.sample(rng);
            if (b <= 4) binomial_hits[0] += 1;
            if (b <= 6) binomial_hits[1] += 1;
            if (b <= 8) binomial_hits[2] += 1;
            const p = poisson.sample(rng);
            if (p <= 3) poisson_hits[0] += 1;
            if (p <= 5) poisson_hits[1] += 1;
            if (p <= 8) poisson_hits[2] += 1;
            const h = hypergeometric.sample(rng);
            if (h <= 2) hypergeometric_hits[0] += 1;
            if (h <= 3) hypergeometric_hits[1] += 1;
            if (h <= 5) hypergeometric_hits[2] += 1;
            const nb = negative_binomial.sample(rng);
            if (nb <= 1) negative_binomial_hits[0] += 1;
            if (nb <= 3) negative_binomial_hits[1] += 1;
            if (nb <= 6) negative_binomial_hits[2] += 1;
            const g = geometric.sample(rng);
            if (g <= 1) geometric_hits[0] += 1;
            if (g <= 2) geometric_hits[1] += 1;
            if (g <= 4) geometric_hits[2] += 1;
            const zf = zipf_dist.sample(rng);
            if (zf <= 2) zipf_hits[0] += 1;
            if (zf <= 4) zipf_hits[1] += 1;
            if (zf <= 8) zipf_hits[2] += 1;
            const zt = zeta_dist.sample(rng);
            if (zt <= 1) zeta_hits[0] += 1;
            if (zt <= 3) zeta_hits[1] += 1;
            if (zt <= 8) zeta_hits[2] += 1;
            if (!bernoulli.sample(rng)) bernoulli_hits += 1;
        }
        try expectEmpiricalCdf("long binomial cdf(4)", binomial_hits[0], samples, binomial.cdf(4));
        try expectEmpiricalCdf("long binomial cdf(6)", binomial_hits[1], samples, binomial.cdf(6));
        try expectEmpiricalCdf("long binomial cdf(8)", binomial_hits[2], samples, binomial.cdf(8));
        try expectEmpiricalCdf("long poisson cdf(3)", poisson_hits[0], samples, poisson.cdf(3));
        try expectEmpiricalCdf("long poisson cdf(5)", poisson_hits[1], samples, poisson.cdf(5));
        try expectEmpiricalCdf("long poisson cdf(8)", poisson_hits[2], samples, poisson.cdf(8));
        try expectEmpiricalCdf("long hypergeometric cdf(2)", hypergeometric_hits[0], samples, hypergeometric.cdf(2));
        try expectEmpiricalCdf("long hypergeometric cdf(3)", hypergeometric_hits[1], samples, hypergeometric.cdf(3));
        try expectEmpiricalCdf("long hypergeometric cdf(5)", hypergeometric_hits[2], samples, hypergeometric.cdf(5));
        try expectEmpiricalCdf("long negative binomial cdf(1)", negative_binomial_hits[0], samples, negative_binomial.cdf(1));
        try expectEmpiricalCdf("long negative binomial cdf(3)", negative_binomial_hits[1], samples, negative_binomial.cdf(3));
        try expectEmpiricalCdf("long negative binomial cdf(6)", negative_binomial_hits[2], samples, negative_binomial.cdf(6));
        try expectEmpiricalCdf("long geometric cdf(1)", geometric_hits[0], samples, geometric.cdf(1));
        try expectEmpiricalCdf("long geometric cdf(2)", geometric_hits[1], samples, geometric.cdf(2));
        try expectEmpiricalCdf("long geometric cdf(4)", geometric_hits[2], samples, geometric.cdf(4));
        try expectEmpiricalCdf("long zipf cdf(2)", zipf_hits[0], samples, zipf_dist.cdf(2));
        try expectEmpiricalCdf("long zipf cdf(4)", zipf_hits[1], samples, zipf_dist.cdf(4));
        try expectEmpiricalCdf("long zipf cdf(8)", zipf_hits[2], samples, zipf_dist.cdf(8));
        try expectEmpiricalCdf("long zeta cdf(1)", zeta_hits[0], samples, zeta_dist.cdf(1));
        try expectEmpiricalCdf("long zeta cdf(3)", zeta_hits[1], samples, zeta_dist.cdf(3));
        try expectEmpiricalCdf("long zeta cdf(8)", zeta_hits[2], samples, zeta_dist.cdf(8));
        try expectEmpiricalCdf("long bernoulli cdf(0)", bernoulli_hits, samples, bernoulli.cdf(0));
        const inv_n = 1 / @as(f64, @floatFromInt(samples));
        std.debug.print("long discrete cdf: binomial(4)={d:.6} poisson(5)={d:.6} hypergeometric(2)={d:.6} negative-binomial(3)={d:.6} geometric(2)={d:.6} zipf(2)={d:.6} zeta(1)={d:.6} bernoulli(0)={d:.6}\n", .{
            @as(f64, @floatFromInt(binomial_hits[0])) * inv_n,
            @as(f64, @floatFromInt(poisson_hits[1])) * inv_n,
            @as(f64, @floatFromInt(hypergeometric_hits[0])) * inv_n,
            @as(f64, @floatFromInt(negative_binomial_hits[1])) * inv_n,
            @as(f64, @floatFromInt(geometric_hits[1])) * inv_n,
            @as(f64, @floatFromInt(zipf_hits[0])) * inv_n,
            @as(f64, @floatFromInt(zeta_hits[0])) * inv_n,
            @as(f64, @floatFromInt(bernoulli_hits)) * inv_n,
        });
    }

    // Cached binomial sampler: inversion walk (mean < 16) and HIN (mean >= 16).
    {
        var engine = alea.FastPrng.init(0x10d9);
        const rng = alea.Rng.init(&engine);
        const inversion = try alea.distributions.CachedBinomial.init(1_000, 0.012);
        const hin = try alea.distributions.CachedBinomial.init(10_000, 0.01);
        var inversion_hits = [_]usize{0} ** 3;
        var hin_hits = [_]usize{0} ** 3;
        var inversion_sum: f64 = 0;
        var inversion_sum_sq: f64 = 0;
        var hin_sum: f64 = 0;
        var hin_sum_sq: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const a: f64 = @floatFromInt(inversion.sample(rng));
            inversion_sum += a;
            inversion_sum_sq += a * a;
            if (a <= 8) inversion_hits[0] += 1;
            if (a <= 12) inversion_hits[1] += 1;
            if (a <= 16) inversion_hits[2] += 1;
            const b: f64 = @floatFromInt(hin.sample(rng));
            hin_sum += b;
            hin_sum_sq += b * b;
            if (b <= 90) hin_hits[0] += 1;
            if (b <= 100) hin_hits[1] += 1;
            if (b <= 110) hin_hits[2] += 1;
        }
        const inversion_mean = inversion_sum / nf;
        const hin_mean = hin_sum / nf;
        try expectFloatBetween("long cached binomial inversion mean", inversion_mean, 11.98, 12.02);
        try expectFloatBetween("long cached binomial inversion variance", inversion_sum_sq / nf - inversion_mean * inversion_mean, 11.80, 11.92);
        try expectFloatBetween("long cached binomial hin mean", hin_mean, 99.90, 100.10);
        try expectFloatBetween("long cached binomial hin variance", hin_sum_sq / nf - hin_mean * hin_mean, 98.70, 99.30);
        try expectEmpiricalCdf("long cached binomial inversion cdf(8)", inversion_hits[0], samples, alea.distributions.binomialCdf(@as(f64, 8), @as(f64, 1000), @as(f64, 0.012)));
        try expectEmpiricalCdf("long cached binomial inversion cdf(12)", inversion_hits[1], samples, alea.distributions.binomialCdf(@as(f64, 12), @as(f64, 1000), @as(f64, 0.012)));
        try expectEmpiricalCdf("long cached binomial inversion cdf(16)", inversion_hits[2], samples, alea.distributions.binomialCdf(@as(f64, 16), @as(f64, 1000), @as(f64, 0.012)));
        try expectEmpiricalCdf("long cached binomial hin cdf(90)", hin_hits[0], samples, alea.distributions.binomialCdf(@as(f64, 90), @as(f64, 10000), @as(f64, 0.01)));
        try expectEmpiricalCdf("long cached binomial hin cdf(100)", hin_hits[1], samples, alea.distributions.binomialCdf(@as(f64, 100), @as(f64, 10000), @as(f64, 0.01)));
        try expectEmpiricalCdf("long cached binomial hin cdf(110)", hin_hits[2], samples, alea.distributions.binomialCdf(@as(f64, 110), @as(f64, 10000), @as(f64, 0.01)));
        const inv_n = 1 / @as(f64, @floatFromInt(samples));
        std.debug.print("long cached binomial cdf: inversion(12)={d:.6} hin(100)={d:.6}\n", .{
            @as(f64, @floatFromInt(inversion_hits[1])) * inv_n,
            @as(f64, @floatFromInt(hin_hits[1])) * inv_n,
        });
    }

    // Huge-parameter samplers: tiny-p binomial, fair-to-HIN dispatch, huge
    // hypergeometric (H2PE and inverse transform), and the gamma-Poisson
    // negative-binomial mixture.
    {
        var engine = alea.FastPrng.init(0x10da);
        const rng = alea.Rng.init(&engine);
        var sum: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) sum += @floatFromInt(alea.distributions.binomial(rng, 1_000_000_000_000_000_000, 2e-17));
        // The HIN small-p envelope carries a known ~0.015 absolute mean
        // offset, so the gate only rejects gross regressions.
        try expectFloatBetween("long binomial tiny-p", sum / nf, 19.9, 20.1);
    }
    {
        var engine = alea.FastPrng.init(0x10db);
        const rng = alea.Rng.init(&engine);
        var sum: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) sum += @floatFromInt(alea.distributions.binomial(rng, 1_000_000_000_000_000_000, 0.5));
        try expectFloatBetween("long binomial huge fair", sum / nf, 4.9999e17, 5.0001e17);
    }
    {
        var engine = alea.FastPrng.init(0x10dc);
        const rng = alea.Rng.init(&engine);
        var sum: f64 = 0;
        var below: usize = 0;
        var above: usize = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const x = alea.distributions.hypergeometric(rng, 1_000_000_000_000_000_000, 100_000_000_000_000_000, 500_000_000_000_000_000);
            sum += @floatFromInt(x);
            if (x <= 49_999_999_900_000_000) below += 1;
            if (x <= 50_000_000_100_000_000) above += 1;
        }
        try expectFloatBetween("long hypergeometric huge", sum / nf, 4.9999e16, 5.0001e16);
        // Normal fallback at ±⅔σ: Φ(−2/3) and Φ(2/3).
        const cdf_below = alea.distributions.hypergeometricCdf(@as(f64, 49_999_999_900_000_000), @as(f64, 1e18), @as(f64, 1e17), @as(f64, 5e17));
        const cdf_above = alea.distributions.hypergeometricCdf(@as(f64, 50_000_000_100_000_000), @as(f64, 1e18), @as(f64, 1e17), @as(f64, 5e17));
        try expectEmpiricalCdf("long hypergeometric huge cdf(mean−1e8)", below, samples, cdf_below);
        try expectEmpiricalCdf("long hypergeometric huge cdf(mean+1e8)", above, samples, cdf_above);
        std.debug.print("long hypergeometric huge cdf: below={d:.6} (cdf {d:.6}) above={d:.6} (cdf {d:.6})\n", .{
            @as(f64, @floatFromInt(below)) / nf,
            cdf_below,
            @as(f64, @floatFromInt(above)) / nf,
            cdf_above,
        });
    }
    {
        // Rare-category huge population: the Poisson limit shares its
        // regime with the H2PE sampler.
        var engine = alea.FastPrng.init(0x10df);
        const rng = alea.Rng.init(&engine);
        var hits: usize = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            if (alea.distributions.hypergeometric(rng, 1_000_000_000_000_000_000, 10_000_000_000, 10_000_000_000) <= 100) hits += 1;
        }
        const cdf_rare = alea.distributions.hypergeometricCdf(@as(f64, 100), @as(f64, 1e18), @as(f64, 1e10), @as(f64, 1e10));
        try expectEmpiricalCdf("long hypergeometric huge rare cdf(100)", hits, samples, cdf_rare);
        std.debug.print("long hypergeometric huge rare cdf: empirical={d:.6} (cdf {d:.6})\n", .{
            @as(f64, @floatFromInt(hits)) / nf,
            cdf_rare,
        });
    }
    {
        var engine = alea.FastPrng.init(0x10dd);
        const rng = alea.Rng.init(&engine);
        var sum: f64 = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) sum += @floatFromInt(alea.distributions.hypergeometric(rng, 1_000_000_000_000_000_000, 5, 500_000_000_000_000_000));
        try expectFloatBetween("long hypergeometric huge edge", sum / nf, 2.49, 2.51);
    }
    {
        var engine = alea.FastPrng.init(0x10de);
        const rng = alea.Rng.init(&engine);
        var sum: f64 = 0;
        var hits: usize = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const x = alea.distributions.negativeBinomial(rng, 1 << 20, 0.5);
            sum += @floatFromInt(x);
            if (x <= 1_048_576) hits += 1;
        }
        try expectFloatBetween("long negative-binomial mixture", sum / nf, 1.0485e6, 1.0487e6);
        const cdf = alea.distributions.negativeBinomialCdf(@as(f64, 1_048_576), @as(f64, 1 << 20), @as(f64, 0.5));
        try expectEmpiricalCdf("long negative-binomial mixture cdf(mean)", hits, samples, cdf);
        std.debug.print("long negative-binomial mixture cdf: empirical={d:.6} (cdf {d:.6})\n", .{
            @as(f64, @floatFromInt(hits)) / nf,
            cdf,
        });
    }
    {
        // Huge-shape beta: the gamma-ratio sampler and the normal-fallback CDF
        // share the same 1e10-scale parameters.
        var engine = alea.FastPrng.init(0x10e0);
        const rng = alea.Rng.init(&engine);
        const beta_dist = try alea.distributions.Beta(f64).init(1e10, 1e10);
        var lower: usize = 0;
        var upper: usize = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const x = beta_dist.sample(rng);
            if (x <= 0.5 - 1e-5) lower += 1;
            if (x <= 0.5 + 1e-5) upper += 1;
        }
        const cdf_lower = alea.distributions.betaCdf(@as(f64, 0.5 - 1e-5), @as(f64, 1e10), @as(f64, 1e10));
        const cdf_upper = alea.distributions.betaCdf(@as(f64, 0.5 + 1e-5), @as(f64, 1e10), @as(f64, 1e10));
        try expectEmpiricalCdf("long beta huge cdf(0.5-1e-5)", lower, samples, cdf_lower);
        try expectEmpiricalCdf("long beta huge cdf(0.5+1e-5)", upper, samples, cdf_upper);
        std.debug.print("long beta huge cdf: lower={d:.6} (cdf {d:.6}) upper={d:.6} (cdf {d:.6})\n", .{
            @as(f64, @floatFromInt(lower)) / nf,
            cdf_lower,
            @as(f64, @floatFromInt(upper)) / nf,
            cdf_upper,
        });
    }

    // Continuous sampler CDF consistency at fixed thresholds.
    {
        var engine = alea.FastPrng.init(0x10d7);
        const rng = alea.Rng.init(&engine);
        const beta = try alea.distributions.Beta(f64).init(2, 5);
        const gamma = try alea.distributions.Gamma(f64).init(2.5, 1.5);
        const student_t = try alea.distributions.StudentT(f64).init(5);
        const fisher_f = try alea.distributions.FisherF(f64).init(5, 10);
        const exponential = try alea.distributions.Exponential(f64).init(2);
        var log_normal = try alea.distributions.LogNormal(f64).init(0, 0.5);
        const log_logistic = try alea.distributions.LogLogistic(f64).init(1.5, 2.5);
        const nakagami = try alea.distributions.Nakagami(f64).init(2, 3);
        const ex_gaussian = try alea.distributions.ExGaussian(f64).init(1, 0.5, 1.5);
        const inverse_gaussian = try alea.distributions.InverseGaussian(f64).init(1, 2);
        const skew_normal = try alea.distributions.SkewNormal(f64).init(0, 1, 1);
        const pert = try alea.distributions.Pert(f64).init(0, 0.5, 1, 4);
        const rice_dist = try alea.distributions.Rice(f64).init(1, 0.5);
        const hoyt_dist = try alea.distributions.Hoyt(f64).init(0.5, 1);
        var beta_hits = [_]usize{0} ** 3;
        var gamma_hits = [_]usize{0} ** 3;
        var student_hits = [_]usize{0} ** 3;
        var fisher_hits = [_]usize{0} ** 3;
        var exponential_hits = [_]usize{0} ** 3;
        var log_normal_hits = [_]usize{0} ** 3;
        var log_logistic_hits = [_]usize{0} ** 3;
        var nakagami_hits = [_]usize{0} ** 3;
        var ex_gaussian_hits = [_]usize{0} ** 3;
        var inverse_gaussian_hits = [_]usize{0} ** 3;
        var skew_normal_hits = [_]usize{0} ** 3;
        var pert_hits = [_]usize{0} ** 3;
        var rice_hits = [_]usize{0} ** 3;
        var hoyt_hits = [_]usize{0} ** 3;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const b = beta.sample(rng);
            if (b <= 0.1) beta_hits[0] += 1;
            if (b <= 0.3) beta_hits[1] += 1;
            if (b <= 0.6) beta_hits[2] += 1;
            const g = gamma.sample(rng);
            if (g <= 1) gamma_hits[0] += 1;
            if (g <= 3) gamma_hits[1] += 1;
            if (g <= 5) gamma_hits[2] += 1;
            const t = student_t.sample(rng);
            if (t <= -1) student_hits[0] += 1;
            if (t <= 0) student_hits[1] += 1;
            if (t <= 1.5) student_hits[2] += 1;
            const f = fisher_f.sample(rng);
            if (f <= 0.5) fisher_hits[0] += 1;
            if (f <= 1) fisher_hits[1] += 1;
            if (f <= 2) fisher_hits[2] += 1;
            const e = exponential.sample(rng);
            if (e <= 0.25) exponential_hits[0] += 1;
            if (e <= 0.5) exponential_hits[1] += 1;
            if (e <= 1) exponential_hits[2] += 1;
            const ln = log_normal.sample(rng);
            if (ln <= 0.5) log_normal_hits[0] += 1;
            if (ln <= 1) log_normal_hits[1] += 1;
            if (ln <= 2) log_normal_hits[2] += 1;
            const ll = log_logistic.sample(rng);
            if (ll <= 0.75) log_logistic_hits[0] += 1;
            if (ll <= 1.5) log_logistic_hits[1] += 1;
            if (ll <= 3) log_logistic_hits[2] += 1;
            const nk = nakagami.sample(rng);
            if (nk <= 1) nakagami_hits[0] += 1;
            if (nk <= 2) nakagami_hits[1] += 1;
            if (nk <= 3) nakagami_hits[2] += 1;
            const eg = ex_gaussian.sample(rng);
            if (eg <= 1) ex_gaussian_hits[0] += 1;
            if (eg <= 2) ex_gaussian_hits[1] += 1;
            if (eg <= 3) ex_gaussian_hits[2] += 1;
            const ig = inverse_gaussian.sample(rng);
            if (ig <= 0.5) inverse_gaussian_hits[0] += 1;
            if (ig <= 1) inverse_gaussian_hits[1] += 1;
            if (ig <= 2) inverse_gaussian_hits[2] += 1;
            const sn = skew_normal.sample(rng);
            if (sn <= -0.5) skew_normal_hits[0] += 1;
            if (sn <= 0) skew_normal_hits[1] += 1;
            if (sn <= 0.5) skew_normal_hits[2] += 1;
            const pe = pert.sample(rng);
            if (pe <= 0.25) pert_hits[0] += 1;
            if (pe <= 0.5) pert_hits[1] += 1;
            if (pe <= 0.75) pert_hits[2] += 1;
            const ri = rice_dist.sample(rng);
            if (ri <= 0.5) rice_hits[0] += 1;
            if (ri <= 1) rice_hits[1] += 1;
            if (ri <= 2) rice_hits[2] += 1;
            const ho = hoyt_dist.sample(rng);
            if (ho <= 0.5) hoyt_hits[0] += 1;
            if (ho <= 1) hoyt_hits[1] += 1;
            if (ho <= 2) hoyt_hits[2] += 1;
        }
        const beta_x = [_]f64{ 0.1, 0.3, 0.6 };
        const gamma_x = [_]f64{ 1, 3, 5 };
        const student_x = [_]f64{ -1, 0, 1.5 };
        const fisher_x = [_]f64{ 0.5, 1, 2 };
        const exponential_x = [_]f64{ 0.25, 0.5, 1 };
        const log_normal_x = [_]f64{ 0.5, 1, 2 };
        const log_logistic_x = [_]f64{ 0.75, 1.5, 3 };
        const nakagami_x = [_]f64{ 1, 2, 3 };
        const ex_gaussian_x = [_]f64{ 1, 2, 3 };
        const inverse_gaussian_x = [_]f64{ 0.5, 1, 2 };
        const skew_normal_x = [_]f64{ -0.5, 0, 0.5 };
        const pert_x = [_]f64{ 0.25, 0.5, 0.75 };
        const rice_x = [_]f64{ 0.5, 1, 2 };
        const hoyt_x = [_]f64{ 0.5, 1, 2 };
        try expectEmpiricalCdf("long beta cdf(0.1)", beta_hits[0], samples, beta.cdf(beta_x[0]));
        try expectEmpiricalCdf("long beta cdf(0.3)", beta_hits[1], samples, beta.cdf(beta_x[1]));
        try expectEmpiricalCdf("long beta cdf(0.6)", beta_hits[2], samples, beta.cdf(beta_x[2]));
        try expectEmpiricalCdf("long gamma cdf(1)", gamma_hits[0], samples, gamma.cdf(gamma_x[0]));
        try expectEmpiricalCdf("long gamma cdf(3)", gamma_hits[1], samples, gamma.cdf(gamma_x[1]));
        try expectEmpiricalCdf("long gamma cdf(5)", gamma_hits[2], samples, gamma.cdf(gamma_x[2]));
        try expectEmpiricalCdf("long student-t cdf(-1)", student_hits[0], samples, student_t.cdf(student_x[0]));
        try expectEmpiricalCdf("long student-t cdf(0)", student_hits[1], samples, student_t.cdf(student_x[1]));
        try expectEmpiricalCdf("long student-t cdf(1.5)", student_hits[2], samples, student_t.cdf(student_x[2]));
        try expectEmpiricalCdf("long fisher-f cdf(0.5)", fisher_hits[0], samples, fisher_f.cdf(fisher_x[0]));
        try expectEmpiricalCdf("long fisher-f cdf(1)", fisher_hits[1], samples, fisher_f.cdf(fisher_x[1]));
        try expectEmpiricalCdf("long fisher-f cdf(2)", fisher_hits[2], samples, fisher_f.cdf(fisher_x[2]));
        try expectEmpiricalCdf("long exponential cdf(0.25)", exponential_hits[0], samples, exponential.cdf(exponential_x[0]));
        try expectEmpiricalCdf("long exponential cdf(0.5)", exponential_hits[1], samples, exponential.cdf(exponential_x[1]));
        try expectEmpiricalCdf("long exponential cdf(1)", exponential_hits[2], samples, exponential.cdf(exponential_x[2]));
        try expectEmpiricalCdf("long log-normal cdf(0.5)", log_normal_hits[0], samples, log_normal.cdf(log_normal_x[0]));
        try expectEmpiricalCdf("long log-normal cdf(1)", log_normal_hits[1], samples, log_normal.cdf(log_normal_x[1]));
        try expectEmpiricalCdf("long log-normal cdf(2)", log_normal_hits[2], samples, log_normal.cdf(log_normal_x[2]));
        try expectEmpiricalCdf("long log-logistic cdf(0.75)", log_logistic_hits[0], samples, log_logistic.cdf(log_logistic_x[0]));
        try expectEmpiricalCdf("long log-logistic cdf(1.5)", log_logistic_hits[1], samples, log_logistic.cdf(log_logistic_x[1]));
        try expectEmpiricalCdf("long log-logistic cdf(3)", log_logistic_hits[2], samples, log_logistic.cdf(log_logistic_x[2]));
        try expectEmpiricalCdf("long nakagami cdf(1)", nakagami_hits[0], samples, nakagami.cdf(nakagami_x[0]));
        try expectEmpiricalCdf("long nakagami cdf(2)", nakagami_hits[1], samples, nakagami.cdf(nakagami_x[1]));
        try expectEmpiricalCdf("long nakagami cdf(3)", nakagami_hits[2], samples, nakagami.cdf(nakagami_x[2]));
        try expectEmpiricalCdf("long ex-gaussian cdf(1)", ex_gaussian_hits[0], samples, ex_gaussian.cdf(ex_gaussian_x[0]));
        try expectEmpiricalCdf("long ex-gaussian cdf(2)", ex_gaussian_hits[1], samples, ex_gaussian.cdf(ex_gaussian_x[1]));
        try expectEmpiricalCdf("long ex-gaussian cdf(3)", ex_gaussian_hits[2], samples, ex_gaussian.cdf(ex_gaussian_x[2]));
        try expectEmpiricalCdf("long inverse-gaussian cdf(0.5)", inverse_gaussian_hits[0], samples, inverse_gaussian.cdf(inverse_gaussian_x[0]));
        try expectEmpiricalCdf("long inverse-gaussian cdf(1)", inverse_gaussian_hits[1], samples, inverse_gaussian.cdf(inverse_gaussian_x[1]));
        try expectEmpiricalCdf("long inverse-gaussian cdf(2)", inverse_gaussian_hits[2], samples, inverse_gaussian.cdf(inverse_gaussian_x[2]));
        try expectEmpiricalCdf("long skew-normal cdf(-0.5)", skew_normal_hits[0], samples, skew_normal.cdf(skew_normal_x[0]));
        try expectEmpiricalCdf("long skew-normal cdf(0)", skew_normal_hits[1], samples, skew_normal.cdf(skew_normal_x[1]));
        try expectEmpiricalCdf("long skew-normal cdf(0.5)", skew_normal_hits[2], samples, skew_normal.cdf(skew_normal_x[2]));
        try expectEmpiricalCdf("long pert cdf(0.25)", pert_hits[0], samples, pert.cdf(pert_x[0]));
        try expectEmpiricalCdf("long pert cdf(0.5)", pert_hits[1], samples, pert.cdf(pert_x[1]));
        try expectEmpiricalCdf("long pert cdf(0.75)", pert_hits[2], samples, pert.cdf(pert_x[2]));
        try expectEmpiricalCdf("long rice cdf(0.5)", rice_hits[0], samples, rice_dist.cdf(rice_x[0]));
        try expectEmpiricalCdf("long rice cdf(1)", rice_hits[1], samples, rice_dist.cdf(rice_x[1]));
        try expectEmpiricalCdf("long rice cdf(2)", rice_hits[2], samples, rice_dist.cdf(rice_x[2]));
        try expectEmpiricalCdf("long hoyt cdf(0.5)", hoyt_hits[0], samples, hoyt_dist.cdf(hoyt_x[0]));
        try expectEmpiricalCdf("long hoyt cdf(1)", hoyt_hits[1], samples, hoyt_dist.cdf(hoyt_x[1]));
        try expectEmpiricalCdf("long hoyt cdf(2)", hoyt_hits[2], samples, hoyt_dist.cdf(hoyt_x[2]));
        const inv_n = 1 / @as(f64, @floatFromInt(samples));
        std.debug.print("long continuous cdf: beta(0.3)={d:.6} gamma(3)={d:.6} student-t(0)={d:.6} fisher-f(1)={d:.6} exponential(0.5)={d:.6} log-normal(1)={d:.6} log-logistic(1.5)={d:.6} nakagami(2)={d:.6} ex-gaussian(2)={d:.6} inverse-gaussian(1)={d:.6} skew-normal(0)={d:.6} pert(0.5)={d:.6} rice(1)={d:.6} hoyt(1)={d:.6}\n", .{
            @as(f64, @floatFromInt(beta_hits[1])) * inv_n,
            @as(f64, @floatFromInt(gamma_hits[1])) * inv_n,
            @as(f64, @floatFromInt(student_hits[1])) * inv_n,
            @as(f64, @floatFromInt(fisher_hits[1])) * inv_n,
            @as(f64, @floatFromInt(exponential_hits[1])) * inv_n,
            @as(f64, @floatFromInt(log_normal_hits[1])) * inv_n,
            @as(f64, @floatFromInt(log_logistic_hits[1])) * inv_n,
            @as(f64, @floatFromInt(nakagami_hits[1])) * inv_n,
            @as(f64, @floatFromInt(ex_gaussian_hits[1])) * inv_n,
            @as(f64, @floatFromInt(inverse_gaussian_hits[1])) * inv_n,
            @as(f64, @floatFromInt(skew_normal_hits[1])) * inv_n,
            @as(f64, @floatFromInt(pert_hits[1])) * inv_n,
            @as(f64, @floatFromInt(rice_hits[1])) * inv_n,
            @as(f64, @floatFromInt(hoyt_hits[1])) * inv_n,
        });
    }

    // Tail probabilities.
    {
        var engine = alea.FastPrng.init(0x10cb);
        const rng = alea.Rng.init(&engine);
        var normal_tail: usize = 0;
        var exponential_tail: usize = 0;
        var student_tail: usize = 0;
        const tail_threshold: f64 = 3;
        const tail_nu: f64 = 5;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            if (@abs(alea.distributions.standardNormal(rng, f64)) > tail_threshold) normal_tail += 1;
            if (alea.distributions.standardExponential(rng, f64) > tail_threshold) exponential_tail += 1;
            if (@abs(alea.distributions.studentT(rng, f64, tail_nu)) > tail_threshold) student_tail += 1;
        }
        const normal_rate = @as(f64, @floatFromInt(normal_tail)) / nf;
        const exponential_rate = @as(f64, @floatFromInt(exponential_tail)) / nf;
        const student_rate = @as(f64, @floatFromInt(student_tail)) / nf;
        const student_expected = 2 * (1 - alea.distributions.studentTCdf(tail_threshold, tail_nu));
        try expectFloatBetween("long normal tail", normal_rate, 0.00270 - 0.0005, 0.00270 + 0.0005);
        try expectFloatBetween("long exponential tail", exponential_rate, 0.049787 - 0.0015, 0.049787 + 0.0015);
        try expectFloatBetween("long student-t tail", student_rate, student_expected - 0.002, student_expected + 0.002);
        std.debug.print("long tails: normal={d:.6} exponential={d:.6} student-t={d:.6} (expected {d:.6})\n", .{ normal_rate, exponential_rate, student_rate, student_expected });
    }

    // Copula correlation and lower-tail dependence.
    {
        const correlation = [2][2]f64{ .{ 1, 0.6 }, .{ 0.6, 1 } };
        const gaussian = try alea.distributions.StaticGaussianCopula(f64, 2).init(correlation);
        const student = try alea.distributions.StaticStudentTCopula(f64, 2).init(correlation, 3);

        var g_engine = alea.FastPrng.init(0x10cc);
        const g_rng = alea.Rng.init(&g_engine);
        var g_sum0: f64 = 0;
        var g_sum1: f64 = 0;
        var g_sum00: f64 = 0;
        var g_sum11: f64 = 0;
        var g_sum01: f64 = 0;
        var g_joint_low: usize = 0;
        var i: usize = 0;
        while (i < samples) : (i += 1) {
            const u = gaussian.sample(g_rng);
            const z0 = alea.distributions.probit(u[0]);
            const z1 = alea.distributions.probit(u[1]);
            g_sum0 += z0;
            g_sum1 += z1;
            g_sum00 += z0 * z0;
            g_sum11 += z1 * z1;
            g_sum01 += z0 * z1;
            if (u[0] < 0.01 and u[1] < 0.01) g_joint_low += 1;
        }
        const g_m0 = g_sum0 / nf;
        const g_m1 = g_sum1 / nf;
        const g_cov = g_sum01 / nf - g_m0 * g_m1;
        const g_sd0 = @sqrt(g_sum00 / nf - g_m0 * g_m0);
        const g_sd1 = @sqrt(g_sum11 / nf - g_m1 * g_m1);
        try expectFloatBetween("long gaussian copula correlation", g_cov / (g_sd0 * g_sd1), 0.595, 0.605);

        var t_engine = alea.FastPrng.init(0x10cd);
        const t_rng = alea.Rng.init(&t_engine);
        var t_joint_low: usize = 0;
        i = 0;
        while (i < samples) : (i += 1) {
            const u = student.sample(t_rng);
            if (u[0] < 0.01 and u[1] < 0.01) t_joint_low += 1;
        }
        const g_rate = @as(f64, @floatFromInt(g_joint_low)) / nf;
        const t_rate = @as(f64, @floatFromInt(t_joint_low)) / nf;
        // The ν=3 t-copula has positive lower-tail dependence, so its 1% joint
        // lower-tail rate should be materially above the Gaussian copula's.
        if (!(t_rate > 1.5 * g_rate)) {
            std.debug.print("long copula tail dependence: t={d:.6} gaussian={d:.6}\n", .{ t_rate, g_rate });
            return error.DistributionCheckFailed;
        }
        std.debug.print("long copula 1% joint lower-tail rates: gaussian={d:.6} student-t={d:.6}\n", .{ g_rate, t_rate });
    }
}

fn expectStandardNormalCdfGates(comptime VectorType: type, comptime label: []const u8, samples: []const VectorType) !void {
    try expectVectorCdfAt(VectorType, label ++ " cdf(-2)", samples, -2.0, 0.015, 0.035);
    try expectVectorCdfAt(VectorType, label ++ " cdf(-1)", samples, -1.0, 0.135, 0.185);
    try expectVectorCdfAt(VectorType, label ++ " cdf(0)", samples, 0.0, 0.475, 0.525);
    try expectVectorCdfAt(VectorType, label ++ " cdf(1)", samples, 1.0, 0.815, 0.865);
    try expectVectorCdfAt(VectorType, label ++ " cdf(2)", samples, 2.0, 0.965, 0.990);
}

fn expectStandardExponentialCdfGates(comptime VectorType: type, comptime label: []const u8, samples: []const VectorType) !void {
    try expectVectorCdfAt(VectorType, label ++ " cdf(0.25)", samples, 0.25, 0.195, 0.250);
    try expectVectorCdfAt(VectorType, label ++ " cdf(0.5)", samples, 0.5, 0.365, 0.425);
    try expectVectorCdfAt(VectorType, label ++ " cdf(1)", samples, 1.0, 0.605, 0.660);
    try expectVectorCdfAt(VectorType, label ++ " cdf(2)", samples, 2.0, 0.835, 0.895);
    try expectVectorCdfAt(VectorType, label ++ " cdf(4)", samples, 4.0, 0.965, 0.995);
}

fn expectVectorCdfAt(comptime VectorType: type, comptime label: []const u8, samples: []const VectorType, threshold: f64, min: f64, max: f64) !void {
    const info = @typeInfo(VectorType).vector;
    var le_count: usize = 0;
    for (samples) |sample| {
        inline for (0..info.len) |lane| {
            const value: f64 = @floatCast(sample[lane]);
            le_count += @intFromBool(value <= threshold);
        }
    }
    const count: f64 = @floatFromInt(samples.len * info.len);
    try expectFloatBetween(label, @as(f64, @floatFromInt(le_count)) / count, min, max);
}

fn expectFloatBetween(comptime label: []const u8, value: f64, min: f64, max: f64) !void {
    if (!floatInClosedRange(value, min, max)) {
        std.debug.print("{s}: {d:.6} not in [{d:.6}, {d:.6}]\n", .{ label, value, min, max });
        return error.DistributionCheckFailed;
    }
}

fn expectEmpiricalCdf(comptime label: []const u8, hits: usize, samples: usize, expected: f64) !void {
    const empirical = @as(f64, @floatFromInt(hits)) / @as(f64, @floatFromInt(samples));
    try expectFloatBetween(label, empirical, expected - 0.002, expected + 0.002);
}

fn floatInClosedRange(value: f64, min: f64, max: f64) bool {
    return value >= min and value <= max;
}

test "float closed-range predicate accepts finite inclusive boundaries" {
    try std.testing.expect(floatInClosedRange(0.0, 0.0, 1.0));
    try std.testing.expect(floatInClosedRange(1.0, 0.0, 1.0));
    try std.testing.expect(floatInClosedRange(0.5, 0.0, 1.0));
    try std.testing.expect(!floatInClosedRange(-0.01, 0.0, 1.0));
    try std.testing.expect(!floatInClosedRange(1.01, 0.0, 1.0));
    try std.testing.expect(!floatInClosedRange(std.math.nan(f64), 0.0, 1.0));
}

test "empirical cdf helper accepts boundary rates" {
    try expectEmpiricalCdf("exact", 500, 1000, 0.5);
    try expectEmpiricalCdf("upper boundary", 502, 1000, 0.5);
    try expectEmpiricalCdf("lower boundary", 498, 1000, 0.5);
}
