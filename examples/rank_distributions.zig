const std = @import("std");
const alea = @import("alea");

fn printOptionalF64(stdout: *std.Io.Writer, label: []const u8, value: ?f64) !void {
    if (value) |v| try stdout.print("{s}{d:.0}", .{ label, v }) else try stdout.print("{s}unbounded/degenerate", .{label});
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var engine = alea.ScalarPrng.init(0x7a1f_0001);

    const zipf = try alea.distributions.Zipf(f64).init(10, 1.5);
    var zipf_fill: [12]f64 = undefined;
    zipf.fillFrom(&engine, &zipf_fill);
    try stdout.print("Zipf(n=10, exponent=1.5): min={d:.0}, max={d:.0}, exponent={d:.1}, sample={d:.0}, fill={any}\n", .{ zipf.minValue(), zipf.maxValue(), zipf.exponentValue(), zipf.sampleFrom(&engine), zipf_fill });

    const zeta = try alea.distributions.Zeta(f64).init(3);
    var zeta_fill: [12]f64 = undefined;
    zeta.fillFrom(&engine, &zeta_fill);
    try stdout.print("Zeta(exponent=3): min={d:.0}, ", .{zeta.minValue()});
    try printOptionalF64(stdout, "max=", zeta.maxValue());
    try stdout.print(", exponent={d:.1}, sample={d:.0}, fill={any}\n", .{ zeta.exponentValue(), zeta.sampleFrom(&engine), zeta_fill });

    const vector_zipf = try alea.distributions.VectorZipf(@Vector(4, f64)).init(10, 1.5);
    const vector_zeta = try alea.distributions.VectorZeta(@Vector(4, f64)).init(3);
    try stdout.print("VectorZipf f64x4 sample: {any}\n", .{vector_zipf.sampleFrom(&engine)});
    try stdout.print("VectorZeta f64x4 sample: {any}\n", .{vector_zeta.sampleFrom(&engine)});

    const degenerate_zipf = try alea.distributions.Zipf(f64).init(10, std.math.inf(f64));
    const degenerate_zeta = try alea.distributions.Zeta(f64).init(std.math.inf(f64));
    try stdout.print("degenerate Zipf exponent=inf: ", .{});
    try printOptionalF64(stdout, "n=", degenerate_zipf.nValue());
    try stdout.print(", max={d:.0}, sample={d:.0}\n", .{ degenerate_zipf.maxValue(), degenerate_zipf.sampleFrom(&engine) });
    try stdout.print("degenerate Zeta exponent=inf: max={d:.0}, sample={d:.0}\n", .{ degenerate_zeta.maxValue().?, degenerate_zeta.sampleFrom(&engine) });

    const invalid_zipf_name = if (alea.distributions.Zipf(f64).init(0, 1.5)) |_| "unexpected-success" else |err| @errorName(err);
    const invalid_zeta_name = if (alea.distributions.Zeta(f64).init(1)) |_| "unexpected-success" else |err| @errorName(err);
    try stdout.print("invalid Zipf(n=0) -> {s}; invalid Zeta(exponent=1) -> {s}\n", .{ invalid_zipf_name, invalid_zeta_name });

    try stdout.print("\nUse Zipf for finite ranked populations, Zeta for unbounded ranks, and vector Zipf/Zeta helpers for lane batches; infinite exponents collapse to rank 1.\n", .{});
    try stdout.flush();
}
