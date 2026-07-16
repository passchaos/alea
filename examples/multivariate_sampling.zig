const std = @import("std");
const alea = @import("alea");

fn sumF64(values: []const f64) f64 {
    var total: f64 = 0;
    for (values) |value| total += value;
    return total;
}

fn sumU64(values: []const u64) u64 {
    var total: u64 = 0;
    for (values) |value| total += value;
    return total;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const probabilities = [_]f64{ 1, 2, 3 };
    const multinomial = try alea.distributions.Multinomial.init(24, &probabilities);
    var expected_counts: [probabilities.len]f64 = undefined;
    try multinomial.expectedCountsInto(&expected_counts);

    var multinomial_engine = alea.ScalarPrng.init(0x4d17_1001);
    const allocated_counts = try multinomial.sampleFrom(allocator, &multinomial_engine);
    defer allocator.free(allocated_counts);

    var caller_counts: [probabilities.len]u64 = undefined;
    multinomial.sampleIntoFrom(&multinomial_engine, &caller_counts);

    var batch_counts: [2 * probabilities.len]u64 = undefined;
    multinomial.sampleManyIntoFrom(&multinomial_engine, &batch_counts);

    try stdout.print("multinomial expected counts: {any}\n", .{expected_counts});
    try stdout.print("multinomial allocated sample: {any}, total={}\n", .{ allocated_counts, sumU64(allocated_counts) });
    try stdout.print("multinomial caller-owned sample: {any}, total={}\n", .{ caller_counts, sumU64(&caller_counts) });
    try stdout.print("multinomial batch samples: {any}\n", .{batch_counts});

    const alpha = [_]f64{ 1, 2, 3 };
    const dirichlet = try alea.distributions.Dirichlet(f64).init(&alpha);
    var means: [alpha.len]f64 = undefined;
    try dirichlet.meansInto(&means);

    var dirichlet_engine = alea.ScalarPrng.init(0x4d17_2001);
    const allocated_simplex = try dirichlet.sampleFrom(allocator, &dirichlet_engine);
    defer allocator.free(allocated_simplex);

    var caller_simplex: [alpha.len]f64 = undefined;
    dirichlet.sampleIntoFrom(&dirichlet_engine, &caller_simplex);

    var batch_simplex: [2 * alpha.len]f64 = undefined;
    dirichlet.sampleManyIntoFrom(&dirichlet_engine, &batch_simplex);

    try stdout.print("dirichlet means: {any}\n", .{means});
    try stdout.print("dirichlet allocated sample: {any}, sum={d:.6}\n", .{ allocated_simplex, sumF64(allocated_simplex) });
    try stdout.print("dirichlet caller-owned sample: {any}, sum={d:.6}\n", .{ caller_simplex, sumF64(&caller_simplex) });
    try stdout.print("dirichlet batch samples: {any}\n", .{batch_simplex});

    const gaussian_mean = [_]f64{ 1, -2, 0.5 };
    const gaussian_covariance = [_]f64{
        1.0,  0.6, -0.2,
        0.6,  2.0, 0.3,
        -0.2, 0.3, 0.5,
    };
    var multivariate_normal = try alea.distributions.MultivariateNormal(f64).init(
        allocator,
        &gaussian_mean,
        &gaussian_covariance,
    );
    defer multivariate_normal.deinit();

    var gaussian_engine = alea.ScalarPrng.init(0x4d17_2501);
    const allocated_gaussian = try multivariate_normal.sampleFrom(allocator, &gaussian_engine);
    defer allocator.free(allocated_gaussian);

    var caller_gaussian: [gaussian_mean.len]f64 = undefined;
    multivariate_normal.sampleIntoFrom(&gaussian_engine, &caller_gaussian);

    var batch_gaussian: [2 * gaussian_mean.len]f64 = undefined;
    multivariate_normal.sampleManyIntoFrom(&gaussian_engine, &batch_gaussian);

    try stdout.print("multivariate normal mean: {any}\n", .{multivariate_normal.meanValues()});
    try stdout.print("multivariate normal covariance(0, 1): {d:.3}\n", .{try multivariate_normal.covarianceAt(0, 1)});
    try stdout.print("multivariate normal allocated sample: {any}\n", .{allocated_gaussian});
    try stdout.print("multivariate normal caller-owned sample: {any}\n", .{caller_gaussian});
    try stdout.print("multivariate normal batch samples: {any}\n", .{batch_gaussian});

    const vertex_dirichlet = try alea.distributions.Dirichlet(f64).init(&.{ 2, std.math.inf(f64), 3 });
    var vertex: [3]f64 = undefined;
    var vertex_engine = alea.ScalarPrng.init(0x4d17_3001);
    vertex_dirichlet.sampleIntoFrom(&vertex_engine, &vertex);
    try stdout.print("degenerate dirichlet vertex sample: {any}\n", .{vertex});

    try stdout.print("\nUse allocation-returning sample* helpers for owned results, sampleInto* for caller-owned buffers, and sampleManyInto* for flat batched outputs.\n", .{});
    try stdout.flush();
}
