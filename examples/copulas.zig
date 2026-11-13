const std = @import("std");
const alea = @import("alea");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    // Static Gaussian copula: correlated uniforms with a comptime dimension.
    const gaussian_correlation = [2][2]f64{
        .{ 1, 0.7 },
        .{ 0.7, 1 },
    };
    const gaussian = try alea.distributions.StaticGaussianCopula(f64, 2).init(gaussian_correlation);
    var gaussian_engine = alea.ScalarPrng.init(0xc0_1001);
    const gaussian_sample = gaussian.sampleFrom(&gaussian_engine);

    // The Gaussian copula is easiest to interpret through probit-transformed
    // coordinates: their correlation should recover the input rho.
    var sum0: f64 = 0;
    var sum1: f64 = 0;
    var sum00: f64 = 0;
    var sum11: f64 = 0;
    var sum01: f64 = 0;
    const count = 5000;
    for (0..count) |_| {
        const u = gaussian.sampleFrom(&gaussian_engine);
        const z0 = alea.distributions.probit(u[0]);
        const z1 = alea.distributions.probit(u[1]);
        sum0 += z0;
        sum1 += z1;
        sum00 += z0 * z0;
        sum11 += z1 * z1;
        sum01 += z0 * z1;
    }
    const nf: f64 = @floatFromInt(count);
    const mean0 = sum0 / nf;
    const mean1 = sum1 / nf;
    const var0 = sum00 / nf - mean0 * mean0;
    const var1 = sum11 / nf - mean1 * mean1;
    const covariance = sum01 / nf - mean0 * mean1;
    const empirical_correlation = covariance / @sqrt(var0 * var1);

    try stdout.print("gaussian copula sample: {any}\n", .{gaussian_sample});
    try stdout.print("gaussian copula empirical correlation: {d:.3}\n", .{empirical_correlation});

    // Dynamic Gaussian copula: runtime dimension, allocator-owned factor.
    const dynamic_correlation = [_]f64{
        1,   0.4, 0.2,
        0.4, 1,   0.1,
        0.2, 0.1, 1,
    };
    var dynamic_gaussian = try alea.distributions.GaussianCopula(f64).init(allocator, &dynamic_correlation);
    defer dynamic_gaussian.deinit();

    var dynamic_sample: [3]f64 = undefined;
    dynamic_gaussian.sampleIntoFrom(&gaussian_engine, &dynamic_sample);
    var dynamic_batch: [6]f64 = undefined;
    dynamic_gaussian.sampleManyIntoFrom(&gaussian_engine, &dynamic_batch);
    try stdout.print("dynamic gaussian copula sample: {any}\n", .{dynamic_sample});
    try stdout.print("dynamic gaussian copula batch: {any}\n", .{dynamic_batch});

    // Student-t copula: the shared chi-squared scale creates tail dependence.
    const t_correlation = [2][2]f64{
        .{ 1, 0.8 },
        .{ 0.8, 1 },
    };
    const t_copula = try alea.distributions.StaticStudentTCopula(f64, 2).init(t_correlation, 3);
    var t_engine = alea.ScalarPrng.init(0xc0_2001);
    var both_low: usize = 0;
    const t_count = 10000;
    for (0..t_count) |_| {
        const u = t_copula.sampleFrom(&t_engine);
        if (u[0] < 0.1 and u[1] < 0.1) both_low += 1;
    }
    const tail_rate = @as(f64, @floatFromInt(both_low)) / @as(f64, @floatFromInt(t_count));
    try stdout.print("student-t copula joint lower-tail rate: {d:.3}\n", .{tail_rate});

    // Dynamic Student-t copula with clone support.
    var dynamic_t = try alea.distributions.StudentTCopula(f64).init(allocator, &dynamic_correlation, 5);
    defer dynamic_t.deinit();
    var dynamic_t_clone = try dynamic_t.clone(allocator);
    defer dynamic_t_clone.deinit();

    var t_sample: [3]f64 = undefined;
    dynamic_t_clone.sampleIntoFrom(&t_engine, &t_sample);
    try stdout.print("dynamic student-t copula sample: {any}\n", .{t_sample});
    try stdout.print("dynamic student-t copula df: {d:.1}\n", .{dynamic_t_clone.dfValue()});

    try stdout.print("\nUse StaticGaussianCopula / StaticStudentTCopula for comptime dimensions and GaussianCopula / StudentTCopula for runtime dimensions.\n", .{});
    try stdout.flush();
}
