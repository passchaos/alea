const std = @import("std");
const alea = @import("alea");

fn vectorMean(comptime VectorType: type, values: []const VectorType) f64 {
    const info = @typeInfo(VectorType).vector;
    var sum: f64 = 0;
    for (values) |value| {
        inline for (0..info.len) |lane| sum += @floatCast(value[lane]);
    }
    return sum / @as(f64, @floatFromInt(values.len * info.len));
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [2048]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var exact_engine = alea.ScalarPrng.init(0xace1);
    var table_engine = alea.ScalarPrng.init(0xace1);
    var approx_engine = alea.ScalarPrng.init(0xace1);

    var exact_normal: [4]@Vector(8, f32) = undefined;
    var table_normal: [4]@Vector(8, f32) = undefined;
    var exact_exp: [4]@Vector(8, f32) = undefined;
    var table_exp: [4]@Vector(8, f32) = undefined;
    var approx_exp: [4]@Vector(8, f32) = undefined;

    alea.distributions.fillVectorStandardNormalFrom(&exact_engine, @Vector(8, f32), &exact_normal);
    alea.distributions.fillVectorStandardNormalTableF32From(&table_engine, @Vector(8, f32), &table_normal);

    exact_engine = alea.ScalarPrng.init(0xace2);
    table_engine = alea.ScalarPrng.init(0xace2);
    approx_engine = alea.ScalarPrng.init(0xace2);
    alea.distributions.fillVectorStandardExponentialFrom(&exact_engine, @Vector(8, f32), &exact_exp);
    alea.distributions.fillVectorStandardExponentialTableF32From(&table_engine, @Vector(8, f32), &table_exp);
    alea.distributions.fillVectorStandardExponentialApproxLogF32From(&approx_engine, @Vector(8, f32), &approx_exp);

    try stdout.print("exact standard normal f32x8 first: {any}\n", .{exact_normal[0]});
    try stdout.print("table standard normal f32x8 first: {any}\n", .{table_normal[0]});
    try stdout.print("normal means over {} lanes: exact={d:.5}, table={d:.5}\n", .{ exact_normal.len * 8, vectorMean(@Vector(8, f32), &exact_normal), vectorMean(@Vector(8, f32), &table_normal) });
    try stdout.print("exact standard exponential f32x8 first: {any}\n", .{exact_exp[0]});
    try stdout.print("table standard exponential f32x8 first: {any}\n", .{table_exp[0]});
    try stdout.print("approx-log standard exponential f32x8 first: {any}\n", .{approx_exp[0]});
    try stdout.print("exponential means over {} lanes: exact={d:.5}, table={d:.5}, approx-log={d:.5}\n", .{ exact_exp.len * 8, vectorMean(@Vector(8, f32), &exact_exp), vectorMean(@Vector(8, f32), &table_exp), vectorMean(@Vector(8, f32), &approx_exp) });
    try stdout.print("\nTable and ApproxLog names are explicit opt-ins: they trade exact/default ziggurat output mapping for throughput-first vector profiles.\n", .{});
    try stdout.flush();
}
