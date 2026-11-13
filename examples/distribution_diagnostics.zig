const std = @import("std");
const alea = @import("alea");

fn printOptional(comptime T: type, stdout: *std.Io.Writer, label: []const u8, value: ?T) !void {
    if (value) |v| {
        try stdout.print("{s}{d:.6}", .{ label, v });
    } else {
        try stdout.print("{s}unbounded/undefined", .{label});
    }
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var engine = alea.ScalarPrng.init(0xd1a6_0001);

    const normal = try alea.distributions.Normal(f64).initMeanCv(10, 0.25);
    const normal_from_z = normal.fromZScore(1.5);
    try stdout.print("Normal mean/CV: mean={d:.3}, stddev={d:.3}, variance={d:.3}, z=1.5 -> {d:.3}, sample={d:.6}\n", .{ normal.meanValue(), normal.stddevValue(), normal.varianceValue(), normal_from_z, normal.sampleFrom(&engine) });

    var log_normal = try alea.distributions.LogNormal(f64).initMeanCv(2, 0.5);
    try stdout.print("LogNormal mean/CV: log-mean={d:.6}, log-stddev={d:.6}, expected={d:.3}, variance={d:.3}, median={d:.3}, sample={d:.6}\n", .{ log_normal.logMeanValue(), log_normal.logStddevValue(), log_normal.expectedValue(), log_normal.varianceValue(), log_normal.medianValue(), log_normal.sampleFrom(&engine) });

    const exponential = try alea.distributions.Exponential(f64).init(4);
    try stdout.print("Exponential(rate=4): inverse-rate={d:.3}, expected={d:.3}, variance={d:.3}, median={d:.3}, support=[{d:.1}, ", .{ exponential.inverseRateValue(), exponential.expectedValue(), exponential.varianceValue(), exponential.medianValue(), exponential.minValue() });
    try printOptional(f64, stdout, "", exponential.maxValue());
    try stdout.print("], sample={d:.6}\n", .{exponential.sampleFrom(&engine)});

    const gamma = try alea.distributions.Gamma(f64).init(2, 3);
    try stdout.print("Gamma(shape=2,scale=3): expected={d:.3}, variance={d:.3}, mode={d:.3}, sample={d:.6}\n", .{ gamma.expectedValue(), gamma.varianceValue(), gamma.modeValue(), gamma.sampleFrom(&engine) });

    const beta = try alea.distributions.Beta(f64).init(2, 5);
    try stdout.print("Beta(2,5): expected={d:.3}, variance={d:.3}, ", .{ beta.expectedValue(), beta.varianceValue() });
    try printOptional(f64, stdout, "mode=", beta.modeValue());
    try stdout.print(", sample={d:.6}\n", .{beta.sampleFrom(&engine)});

    const pert = try alea.distributions.Pert(f64).initRange(-1, 2).withShape(4).withMean(0.5);
    try stdout.print("PERT range builder: min={d:.1}, max={d:.1}, shape={d:.1}, expected={d:.3}, variance={d:.3}, ", .{ pert.minValue(), pert.maxValue(), pert.shapeValue(), pert.expectedValue(), pert.varianceValue() });
    try printOptional(f64, stdout, "mode=", pert.modeValue());
    try stdout.print(", sample={d:.6}\n", .{pert.sampleFrom(&engine)});

    const poisson = try alea.distributions.Poisson.init(20);
    try stdout.print("Poisson(lambda=20): expected={d:.1}, variance={d:.1}, support=[{}, ", .{ poisson.expectedValue(), poisson.varianceValue(), poisson.minValue() });
    if (poisson.maxValue()) |max| {
        try stdout.print("{}", .{max});
    } else {
        try stdout.print("unbounded", .{});
    }
    try stdout.print("], sample={}\n", .{poisson.sampleFrom(&engine)});

    // Closed-form CDF/quantile diagnostics and sampler-level methods.
    const laplace = try alea.distributions.Laplace(f64).init(0, 1);
    const laplace_cdf = laplace.cdf(1);
    const laplace_q90 = laplace.quantile(0.9);
    try stdout.print("Laplace(0,1): cdf(1)={d:.6}, quantile(0.9)={d:.6}\n", .{ laplace_cdf, laplace_q90 });

    const weibull = try alea.distributions.Weibull(f64).init(1, 2);
    try stdout.print("Weibull(1,2): cdf(1)={d:.6}, quantile(0.5)={d:.6}\n", .{ weibull.cdf(1), weibull.quantile(0.5) });

    const triangular = try alea.distributions.Triangular(f64).init(0, 0.5, 1);
    try stdout.print("Triangular(0,0.5,1): cdf(0.25)={d:.6}, quantile(0.5)={d:.6}\n", .{ triangular.cdf(0.25), triangular.quantile(0.5) });

    const kumaraswamy = try alea.distributions.Kumaraswamy(f64).init(2, 3);
    try stdout.print("Kumaraswamy(2,3): cdf(0.5)={d:.6}, quantile(0.5)={d:.6}\n", .{ kumaraswamy.cdf(0.5), kumaraswamy.quantile(0.5) });

    const cdf_x: f64 = 1;
    const cdf_p: f64 = 0.5;
    const cdf_zero: f64 = 0;
    const cdf_one: f64 = 1;
    const cdf_two: f64 = 2;
    try stdout.print("frechetCdf(1; 0,1,2)={d:.6}, paretoQuantile(0.5; 1,2)={d:.6}\n", .{
        alea.distributions.frechetCdf(cdf_x, cdf_zero, cdf_one, cdf_two),
        alea.distributions.paretoQuantile(cdf_p, cdf_one, cdf_two),
    });

    try stdout.print("\nUse constructor/accessor diagnostics to echo parameters, support, moments, and derived parameterizations before sampling.\n", .{});
    try stdout.flush();
}
