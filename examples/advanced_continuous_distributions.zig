const std = @import("std");
const alea = @import("alea");

fn printOptionalF64(stdout: *std.Io.Writer, label: []const u8, value: ?f64) !void {
    if (value) |v| try stdout.print("{s}{d:.6}", .{ label, v }) else try stdout.print("{s}undefined/unbounded", .{label});
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var engine = alea.ScalarPrng.init(0xad_c017_0001);

    const half = try alea.distributions.HalfNormal(f64).init(2);
    const chi_sq = try alea.distributions.ChiSquared(f64).init(4);
    const chi = try alea.distributions.Chi(f64).init(4);
    const erlang = try alea.distributions.Erlang(f64).init(3, 2);
    const maxwell = try alea.distributions.Maxwell(f64).init(2);
    const log_logistic = try alea.distributions.LogLogistic(f64).init(2, 3);
    const kumaraswamy = try alea.distributions.Kumaraswamy(f64).init(2, 5);
    const power = try alea.distributions.PowerFunction(f64).init(0, 2, 3);
    const gumbel = try alea.distributions.Gumbel(f64).init(0, 2);
    const frechet = try alea.distributions.Frechet(f64).init(0, 2, 3);
    const skew = try alea.distributions.SkewNormal(f64).init(0, 1, 4);
    const inverse_gaussian = try alea.distributions.InverseGaussian(f64).init(2, 5);
    const nig = try alea.distributions.NormalInverseGaussian(f64).init(3, 1);

    try stdout.print("HalfNormal(scale=2): mean={d:.3}, var={d:.3}, sample={d:.6}\n", .{ half.expectedValue(), half.varianceValue(), half.sampleFrom(&engine) });
    try stdout.print("ChiSquared(dof=4): mean={d:.3}, var={d:.3}, mode={d:.3}, sample={d:.6}\n", .{ chi_sq.expectedValue(), chi_sq.varianceValue(), chi_sq.modeValue(), chi_sq.sampleFrom(&engine) });
    try stdout.print("Chi(dof=4): mean={d:.3}, var={d:.3}, mode={d:.3}, sample={d:.6}\n", .{ chi.expectedValue(), chi.varianceValue(), chi.modeValue(), chi.sampleFrom(&engine) });
    try stdout.print("Erlang(shape=3,scale=2): mean={d:.3}, var={d:.3}, mode={d:.3}, sample={d:.6}\n", .{ erlang.expectedValue(), erlang.varianceValue(), erlang.modeValue(), erlang.sampleFrom(&engine) });
    try stdout.print("Maxwell(scale=2): mean={d:.3}, var={d:.3}, mode={d:.3}, sample={d:.6}\n", .{ maxwell.expectedValue(), maxwell.varianceValue(), maxwell.modeValue(), maxwell.sampleFrom(&engine) });

    try stdout.print("LogLogistic(scale=2,shape=3): ", .{});
    try printOptionalF64(stdout, "mean=", log_logistic.expectedValue());
    try stdout.print(", ", .{});
    try printOptionalF64(stdout, "var=", log_logistic.varianceValue());
    try stdout.print(", median={d:.3}, sample={d:.6}\n", .{ log_logistic.medianValue(), log_logistic.sampleFrom(&engine) });

    try stdout.print("Kumaraswamy(alpha=2,beta=5): mean={d:.3}, var={d:.3}, median={d:.3}, sample={d:.6}\n", .{ kumaraswamy.expectedValue(), kumaraswamy.varianceValue(), kumaraswamy.medianValue(), kumaraswamy.sampleFrom(&engine) });
    try stdout.print("PowerFunction(min=0,max=2,shape=3): mean={d:.3}, var={d:.3}, median={d:.3}, sample={d:.6}\n", .{ power.expectedValue(), power.varianceValue(), power.medianValue(), power.sampleFrom(&engine) });
    try stdout.print("Gumbel(location=0,scale=2): mean={d:.3}, var={d:.3}, median={d:.3}, sample={d:.6}\n", .{ gumbel.expectedValue(), gumbel.varianceValue(), gumbel.medianValue(), gumbel.sampleFrom(&engine) });

    try stdout.print("Frechet(location=0,scale=2,shape=3): ", .{});
    try printOptionalF64(stdout, "mean=", frechet.expectedValue());
    try stdout.print(", ", .{});
    try printOptionalF64(stdout, "var=", frechet.varianceValue());
    try stdout.print(", median={d:.3}, sample={d:.6}\n", .{ frechet.medianValue(), frechet.sampleFrom(&engine) });

    try stdout.print("SkewNormal(location=0,scale=1,shape=4): mean={d:.3}, var={d:.3}, sample={d:.6}\n", .{ skew.expectedValue(), skew.varianceValue(), skew.sampleFrom(&engine) });
    try stdout.print("InverseGaussian(mean=2,shape=5): mean={d:.3}, var={d:.3}, sample={d:.6}\n", .{ inverse_gaussian.expectedValue(), inverse_gaussian.varianceValue(), inverse_gaussian.sampleFrom(&engine) });
    try stdout.print("NormalInverseGaussian(alpha=3,beta=1): mean={d:.3}, var={d:.3}, sample={d:.6}\n", .{ nig.expectedValue(), nig.varianceValue(), nig.sampleFrom(&engine) });

    var skew_fill: [6]f64 = undefined;
    skew.fillFrom(&engine, &skew_fill);
    const vector_chi = try alea.distributions.VectorChi(@Vector(4, f64)).init(4);
    const vector_skew = try alea.distributions.VectorSkewNormal(@Vector(4, f64)).init(0, 1, 4);
    try stdout.print("SkewNormal.fillFrom: {any}\n", .{skew_fill});
    try stdout.print("VectorChi f64x4 sample: {any}\n", .{vector_chi.sampleFrom(&engine)});
    try stdout.print("VectorSkewNormal f64x4 sample: {any}\n", .{vector_skew.sampleFrom(&engine)});

    const invalid_name = if (alea.distributions.NormalInverseGaussian(f64).init(1, 2)) |_| "unexpected-success" else |err| @errorName(err);
    try stdout.print("invalid NormalInverseGaussian(alpha=1,beta=2) -> {s}\n", .{invalid_name});

    try stdout.print("\nUse these advanced continuous samplers for shape/tail families; accessors expose moments/support when defined, and vector samplers cover lane batches for supported profiles.\n", .{});
    try stdout.flush();
}
