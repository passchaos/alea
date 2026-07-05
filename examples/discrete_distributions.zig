const std = @import("std");
const alea = @import("alea");

fn printOptionalU64(stdout: *std.Io.Writer, value: ?u64) !void {
    if (value) |v| try stdout.print("{}", .{v}) else try stdout.print("unbounded", .{});
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var engine = alea.ScalarPrng.init(0xd15c_0001);

    const bernoulli = try alea.distributions.Bernoulli.init(0.25);
    const bernoulli_new = try alea.distributions.Bernoulli.new(0.25);
    var bernoulli_fill: [12]bool = undefined;
    bernoulli.fillFrom(&engine, &bernoulli_fill);
    try stdout.print("Bernoulli(p=.25): expected={d:.2}, variance={d:.4}, sample={}, fill={any}\n", .{ bernoulli.expectedValue(), bernoulli.varianceValue(), bernoulli.sampleFrom(&engine), bernoulli_fill });
    try stdout.print("Bernoulli.new(p=.25): expected={d:.2}\n", .{bernoulli_new.expectedValue()});

    const binomial = try alea.distributions.Binomial.init(40, 0.25);
    var binomial_fill: [6]u64 = undefined;
    binomial.fillFrom(&engine, &binomial_fill);
    try stdout.print("Binomial(n=40,p=.25): expected={d:.2}, variance={d:.2}, sample={}, fill={any}\n", .{ binomial.expectedValue(), binomial.varianceValue(), binomial.sampleFrom(&engine), binomial_fill });

    const negative = try alea.distributions.NegativeBinomial.init(5, 0.4);
    try stdout.print("NegativeBinomial(successes=5,p=.4): expected failures={d:.2}, variance={d:.2}, sample={}\n", .{ negative.expectedValue(), negative.varianceValue(), negative.sampleFrom(&engine) });

    const poisson = try alea.distributions.Poisson.init(20);
    var poisson_fill: [6]u64 = undefined;
    poisson.fillFrom(&engine, &poisson_fill);
    try stdout.print("Poisson(lambda=20): expected={d:.1}, variance={d:.1}, support=[{}, ", .{ poisson.expectedValue(), poisson.varianceValue(), poisson.minValue() });
    try printOptionalU64(stdout, poisson.maxValue());
    try stdout.print("], sample={}, fill={any}\n", .{ poisson.sampleFrom(&engine), poisson_fill });

    const geometric = try alea.distributions.Geometric.init(0.25);
    const failures = try alea.distributions.GeometricFailures.init(0.25);
    const standard_failures = alea.distributions.StandardGeometric{};
    try stdout.print("Geometric trials(p=.25): expected={d:.2}, sample={}\n", .{ geometric.expectedValue(), geometric.sampleFrom(&engine) });
    try stdout.print("Geometric failures(p=.25): expected={d:.2}, sample={}\n", .{ failures.expectedValue(), failures.sampleFrom(&engine) });
    try stdout.print("StandardGeometric failures(p=.5): expected={d:.2}, sample={}\n", .{ standard_failures.expectedValue(), standard_failures.sampleFrom(&engine) });

    const hyper = try alea.distributions.Hypergeometric.init(100, 30, 10);
    var hyper_fill: [6]u64 = undefined;
    hyper.fillFrom(&engine, &hyper_fill);
    try stdout.print("Hypergeometric(N=100,K=30,n=10): expected={d:.2}, variance={d:.2}, support=[{}, {}], sample={}, fill={any}\n", .{ hyper.expectedValue(), hyper.varianceValue(), hyper.minValue(), hyper.maxValue(), hyper.sampleFrom(&engine), hyper_fill });

    const vector_binomial = try alea.distributions.VectorBinomial(@Vector(8, u64)).init(20, 0.3);
    const vector_poisson = try alea.distributions.VectorPoisson(@Vector(8, u64)).init(4);
    try stdout.print("VectorBinomial u64x8 sample: {any}\n", .{vector_binomial.sampleFrom(&engine)});
    try stdout.print("VectorPoisson u64x8 sample: {any}\n", .{vector_poisson.sampleFrom(&engine)});

    const invalid_name = if (alea.distributions.Bernoulli.init(1.5)) |_| "unexpected-success" else |err| @errorName(err);
    try stdout.print("invalid Bernoulli(p=1.5) -> {s}\n", .{invalid_name});

    try stdout.print("\nUse reusable discrete samplers when parameters repeat, fillFrom for bulk slices, failures variants for rand-style geometric counts, and vector samplers for lane batches.\n", .{});
    try stdout.flush();
}
