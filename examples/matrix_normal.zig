const std = @import("std");
const alea = @import("alea");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    // Dynamic matrix normal: 2x3 mean, row covariance U, column covariance V.
    const mean = [_]f64{
        0.5, -0.5, 1,
        2,   3,    -1,
    };
    const row_covariance = [_]f64{
        1,   0.3,
        0.3, 1,
    };
    const col_covariance = [_]f64{
        1,   0.2,  0.1,
        0.2, 1,    0.15,
        0.1, 0.15, 1,
    };
    var matrix_normal = try alea.distributions.MatrixNormal(f64).init(
        allocator,
        &mean,
        &row_covariance,
        &col_covariance,
    );
    defer matrix_normal.deinit();

    var engine = alea.ScalarPrng.init(0xc0_3001);
    const allocated_sample = try matrix_normal.sampleFrom(allocator, &engine);
    defer allocator.free(allocated_sample);

    var caller_sample: [6]f64 = undefined;
    matrix_normal.sampleIntoFrom(&engine, &caller_sample);

    var batch: [12]f64 = undefined;
    matrix_normal.sampleManyIntoFrom(&engine, &batch);

    try stdout.print("matrix normal shape: {}x{}\n", .{ matrix_normal.rowsValue(), matrix_normal.colsValue() });
    try stdout.print("matrix normal mean: {any}\n", .{matrix_normal.meanValues()});
    try stdout.print("matrix normal row covariance(0, 1): {d:.3}\n", .{try matrix_normal.rowCovarianceAt(0, 1)});
    try stdout.print("matrix normal col covariance(0, 2): {d:.3}\n", .{try matrix_normal.colCovarianceAt(0, 2)});
    try stdout.print("matrix normal variance(0, 0): {d:.3}\n", .{try matrix_normal.varianceAt(0, 0)});
    try stdout.print("matrix normal allocated sample: {any}\n", .{allocated_sample});
    try stdout.print("matrix normal caller-owned sample: {any}\n", .{caller_sample});
    try stdout.print("matrix normal batch samples: {any}\n", .{batch});

    // Static matrix normal: inline mean and Cholesky factors, no allocator.
    const static_matrix_normal = try alea.distributions.StaticMatrixNormal(f64, 2, 2).init(
        .{ .{ 0, 0 }, .{ 0, 0 } },
        .{ .{ 1, 0.5 }, .{ 0.5, 1 } },
        .{ .{ 1, 0.2 }, .{ 0.2, 1 } },
    );
    const static_sample = static_matrix_normal.sampleFrom(&engine);
    var static_batch: [2][2][2]f64 = undefined;
    static_matrix_normal.sampleManyIntoFrom(&engine, &static_batch);

    try stdout.print("static matrix normal sample: {any}\n", .{static_sample});
    try stdout.print("static matrix normal batch: {any}\n", .{static_batch});
    try stdout.print("static matrix normal variance(1, 1): {d:.3}\n", .{try static_matrix_normal.varianceAt(1, 1)});

    try stdout.print("\nUse MatrixNormal for runtime shapes and StaticMatrixNormal for allocation-free comptime shapes.\n", .{});
    try stdout.flush();
}
