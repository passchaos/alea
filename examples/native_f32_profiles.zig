const std = @import("std");
const alea = @import("alea");

fn mean(values: []const f32) f64 {
    var sum: f64 = 0;
    for (values) |value| sum += @floatCast(value);
    return sum / @as(f64, @floatFromInt(values.len));
}

fn vectorMean(values: []const @Vector(8, f32)) f64 {
    var sum: f64 = 0;
    for (values) |value| {
        inline for (0..8) |lane| sum += @floatCast(value[lane]);
    }
    return sum / @as(f64, @floatFromInt(values.len * 8));
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var exact_normal_engine = alea.ScalarPrng.init(0xf320);
    var native_normal_engine = alea.ScalarPrng.init(0xf320);
    var exact_param_normal_engine = alea.ScalarPrng.init(0xf321);
    var native_param_normal_engine = alea.ScalarPrng.init(0xf321);
    var exact_exp_engine = alea.ScalarPrng.init(0xf322);
    var native_exp_engine = alea.ScalarPrng.init(0xf322);
    var exact_param_exp_engine = alea.ScalarPrng.init(0xf323);
    var native_param_exp_engine = alea.ScalarPrng.init(0xf323);

    var exact_normal: [16]f32 = undefined;
    var native_normal: [16]f32 = undefined;
    var exact_param_normal: [16]f32 = undefined;
    var native_param_normal: [16]f32 = undefined;
    var exact_exp: [16]f32 = undefined;
    var native_exp: [16]f32 = undefined;
    var exact_param_exp: [16]f32 = undefined;
    var native_param_exp: [16]f32 = undefined;

    alea.distributions.fillStandardNormalFrom(&exact_normal_engine, f32, &exact_normal);
    alea.distributions.fillStandardNormalNativeF32From(&native_normal_engine, &native_normal);
    alea.distributions.fillNormalFrom(&exact_param_normal_engine, f32, &exact_param_normal, 5, 2);
    alea.distributions.fillNormalNativeF32From(&native_param_normal_engine, &native_param_normal, 5, 2);
    alea.distributions.fillStandardExponentialFrom(&exact_exp_engine, f32, &exact_exp);
    alea.distributions.fillStandardExponentialNativeF32From(&native_exp_engine, &native_exp);
    alea.distributions.fillExponentialFrom(&exact_param_exp_engine, f32, &exact_param_exp, 4);
    alea.distributions.fillExponentialNativeF32From(&native_param_exp_engine, &native_param_exp, 4);

    var exact_vec_engine = alea.ScalarPrng.init(0xf324);
    var native_vec_engine = alea.ScalarPrng.init(0xf324);
    var exact_vec: [2]@Vector(8, f32) = undefined;
    var native_vec: [2]@Vector(8, f32) = undefined;
    alea.distributions.fillVectorStandardNormalFrom(&exact_vec_engine, @Vector(8, f32), &exact_vec);
    alea.distributions.fillVectorStandardNormalNativeF32From(&native_vec_engine, @Vector(8, f32), &native_vec);

    try stdout.print("standard normal f32 first: exact={d:.6}, native={d:.6}\n", .{ exact_normal[0], native_normal[0] });
    try stdout.print("standard normal mean16: exact={d:.6}, native={d:.6}\n", .{ mean(&exact_normal), mean(&native_normal) });
    try stdout.print("normal(mean=5,stddev=2) first: exact={d:.6}, native={d:.6}\n", .{ exact_param_normal[0], native_param_normal[0] });
    try stdout.print("normal(mean=5,stddev=2) mean16: exact={d:.6}, native={d:.6}\n", .{ mean(&exact_param_normal), mean(&native_param_normal) });
    try stdout.print("standard exponential f32 first: exact={d:.6}, native={d:.6}\n", .{ exact_exp[0], native_exp[0] });
    try stdout.print("standard exponential mean16: exact={d:.6}, native={d:.6}\n", .{ mean(&exact_exp), mean(&native_exp) });
    try stdout.print("exponential(rate=4) first: exact={d:.6}, native={d:.6}\n", .{ exact_param_exp[0], native_param_exp[0] });
    try stdout.print("exponential(rate=4) mean16: exact={d:.6}, native={d:.6}\n", .{ mean(&exact_param_exp), mean(&native_param_exp) });
    try stdout.print("vector standard normal f32x8 first exact: {any}\n", .{exact_vec[0]});
    try stdout.print("vector standard normal f32x8 first native: {any}\n", .{native_vec[0]});
    try stdout.print("vector standard normal means over {} lanes: exact={d:.6}, native={d:.6}\n", .{ exact_vec.len * 8, vectorMean(&exact_vec), vectorMean(&native_vec) });
    try stdout.print("\nNativeF32 names are explicit opt-ins: they use f32-native ziggurat candidates for throughput and intentionally do not match exact/default f64-backed f32 output mapping.\n", .{});
    try stdout.flush();
}
