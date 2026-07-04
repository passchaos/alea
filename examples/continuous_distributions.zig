const std = @import("std");
const alea = @import("alea");

fn printOptionalF64(stdout: *std.Io.Writer, label: []const u8, value: ?f64) !void {
    if (value) |v| {
        try stdout.print("{s}{d:.6}", .{ label, v });
    } else {
        try stdout.print("{s}undefined/unbounded", .{label});
    }
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var engine = alea.ScalarPrng.init(0xc017_0001);

    const gamma = try alea.distributions.Gamma(f64).init(2, 3);
    const beta = try alea.distributions.Beta(f64).init(2, 5);
    const fisher = try alea.distributions.FisherF(f64).init(5, 20);
    const student = try alea.distributions.StudentT(f64).init(8);
    const triangular = try alea.distributions.Triangular(f64).init(-1, 0.25, 2);
    const arcsine = try alea.distributions.Arcsine(f64).init(-2, 3);
    const cauchy = try alea.distributions.Cauchy(f64).init(0, 1);
    const laplace = try alea.distributions.Laplace(f64).init(0, 2);
    const logistic = try alea.distributions.Logistic(f64).init(0, 1.5);
    const rayleigh = try alea.distributions.Rayleigh(f64).init(2);
    const pareto = try alea.distributions.Pareto(f64).init(1, 3);
    const weibull = try alea.distributions.Weibull(f64).init(2, 1.5);

    try stdout.print("Gamma(shape=2,scale=3): mean={d:.3}, var={d:.3}, mode={d:.3}, sample={d:.6}\n", .{ gamma.expectedValue(), gamma.varianceValue(), gamma.modeValue(), gamma.sampleFrom(&engine) });
    try stdout.print("Beta(2,5): mean={d:.3}, var={d:.3}, ", .{ beta.expectedValue(), beta.varianceValue() });
    try printOptionalF64(stdout, "mode=", beta.modeValue());
    try stdout.print(", sample={d:.6}\n", .{beta.sampleFrom(&engine)});

    try stdout.print("FisherF(d1=5,d2=20): ", .{});
    try printOptionalF64(stdout, "mean=", fisher.expectedValue());
    try stdout.print(", ", .{});
    try printOptionalF64(stdout, "var=", fisher.varianceValue());
    try stdout.print(", sample={d:.6}\n", .{fisher.sampleFrom(&engine)});

    try stdout.print("StudentT(dof=8): ", .{});
    try printOptionalF64(stdout, "mean=", student.expectedValue());
    try stdout.print(", ", .{});
    try printOptionalF64(stdout, "var=", student.varianceValue());
    try stdout.print(", sample={d:.6}\n", .{student.sampleFrom(&engine)});

    try stdout.print("Triangular(-1,0.25,2): mean={d:.3}, median={d:.3}, sample={d:.6}\n", .{ triangular.expectedValue(), triangular.medianValue(), triangular.sampleFrom(&engine) });
    try stdout.print("Arcsine(-2,3): mean={d:.3}, median={d:.3}, sample={d:.6}\n", .{ arcsine.expectedValue(), arcsine.medianValue(), arcsine.sampleFrom(&engine) });

    try stdout.print("Cauchy(0,1): median={d:.3}, mode={d:.3}, ", .{ cauchy.medianValue(), cauchy.modeValue() });
    try printOptionalF64(stdout, "mean=", cauchy.expectedValue());
    try stdout.print(", sample={d:.6}\n", .{cauchy.sampleFrom(&engine)});

    try stdout.print("Laplace(0,2): mean={d:.3}, var={d:.3}, sample={d:.6}\n", .{ laplace.expectedValue(), laplace.varianceValue(), laplace.sampleFrom(&engine) });
    try stdout.print("Logistic(0,1.5): mean={d:.3}, var={d:.3}, sample={d:.6}\n", .{ logistic.expectedValue(), logistic.varianceValue(), logistic.sampleFrom(&engine) });
    try stdout.print("Rayleigh(scale=2): mean={d:.3}, var={d:.3}, median={d:.3}, sample={d:.6}\n", .{ rayleigh.expectedValue(), rayleigh.varianceValue(), rayleigh.medianValue(), rayleigh.sampleFrom(&engine) });

    try stdout.print("Pareto(scale=1,shape=3): ", .{});
    try printOptionalF64(stdout, "mean=", pareto.expectedValue());
    try stdout.print(", ", .{});
    try printOptionalF64(stdout, "var=", pareto.varianceValue());
    try stdout.print(", median={d:.3}, sample={d:.6}\n", .{ pareto.medianValue(), pareto.sampleFrom(&engine) });

    try stdout.print("Weibull(scale=2,shape=1.5): mean={d:.3}, var={d:.3}, median={d:.3}, sample={d:.6}\n", .{ weibull.expectedValue(), weibull.varianceValue(), weibull.medianValue(), weibull.sampleFrom(&engine) });

    var beta_fill: [6]f64 = undefined;
    beta.fillFrom(&engine, &beta_fill);
    const vector_gamma = try alea.distributions.VectorGamma(@Vector(4, f64)).init(2, 3);
    try stdout.print("Beta.fillFrom: {any}\n", .{beta_fill});
    try stdout.print("VectorGamma f64x4 sample: {any}\n", .{vector_gamma.sampleFrom(&engine)});

    const invalid_name = if (alea.distributions.Weibull(f64).init(1, 0)) |_| "unexpected-success" else |err| @errorName(err);
    try stdout.print("invalid Weibull(scale=1,shape=0) -> {s}\n", .{invalid_name});

    try stdout.print("\nUse reusable continuous samplers to keep parameters and diagnostics together; fillFrom handles bulk slices, and vector samplers cover lane batches for supported families.\n", .{});
    try stdout.flush();
}
