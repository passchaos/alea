const std = @import("std");
const alea = @import("alea");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var engine = alea.ScalarPrng.init(0xd1_1001);

    // Scalar von Mises-Fisher on S².
    const vmf = try alea.distributions.VonMisesFisher(f64, 3).init(.{ 0, 0, 1 }, 5);
    var vmf_sum_z: f64 = 0;
    const vmf_count = 5_000;
    for (0..vmf_count) |_| {
        const point = vmf.sampleFrom(&engine);
        const norm_sq = point[0] * point[0] + point[1] * point[1] + point[2] * point[2];
        std.debug.assert(@abs(norm_sq - 1) < 1e-10);
        vmf_sum_z += point[2];
    }
    const vmf_nf: f64 = @floatFromInt(vmf_count);
    try stdout.print("von Mises-Fisher mean z: {d:.3} (expected {d:.3})\n", .{ vmf_sum_z / vmf_nf, vmf.meanResultantLength() });

    // Kent (Fisher-Bingham F5) on S²: ovalness makes γ₂ noisier than γ₃.
    const kent = try alea.distributions.Kent(f64).init(.{ 0, 0, 1 }, .{ 1, 0, 0 }, 5, 1.5);
    var kent_sum_z: f64 = 0;
    var kent_sum_x2: f64 = 0;
    var kent_sum_y2: f64 = 0;
    const kent_count = 5_000;
    for (0..kent_count) |_| {
        const point = kent.sampleFrom(&engine);
        kent_sum_z += point[2];
        kent_sum_x2 += point[0] * point[0];
        kent_sum_y2 += point[1] * point[1];
    }
    const kent_nf: f64 = @floatFromInt(kent_count);
    try stdout.print("kent mean resultant: {d:.3} (expected {d:.3})\n", .{ kent_sum_z / kent_nf, kent.meanResultantLength() });
    try stdout.print("kent gamma2 variance: {d:.3} (expected {d:.3})\n", .{ kent_sum_x2 / kent_nf, kent.varianceAt(0) });
    try stdout.print("kent gamma3 variance: {d:.3} (expected {d:.3})\n", .{ kent_sum_y2 / kent_nf, kent.varianceAt(1) });

    // Bingham axial distribution on S³: diag(0, -3, -3) concentrates x0².
    const bingham = try alea.distributions.Bingham(f64, 3).init(.{
        .{ 0, 0, 0 },
        .{ 0, -3, 0 },
        .{ 0, 0, -3 },
    });
    var bingham_sum_x2: f64 = 0;
    const bingham_count = 5_000;
    for (0..bingham_count) |_| {
        const point = bingham.sampleFrom(&engine);
        bingham_sum_x2 += point[0] * point[0];
    }
    const bingham_nf: f64 = @floatFromInt(bingham_count);
    try stdout.print("bingham E[x0^2]: {d:.3}\n", .{bingham_sum_x2 / bingham_nf});

    // Exact SO(3) matrix Fisher: isotropic F = 2I.
    const matrix_fisher = try alea.distributions.MatrixFisher(f64).init(.{
        .{ 2, 0, 0 },
        .{ 0, 2, 0 },
        .{ 0, 0, 2 },
    });
    var trace_sum: f64 = 0;
    const rotation_count = 5_000;
    for (0..rotation_count) |_| {
        const rotation = matrix_fisher.sampleFrom(&engine);
        trace_sum += rotation[0][0] + rotation[1][1] + rotation[2][2];
    }
    const rotation_nf: f64 = @floatFromInt(rotation_count);
    try stdout.print("matrix Fisher mean trace: {d:.3}\n", .{trace_sum / rotation_nf});

    // Matrix Langevin on V_{2,3} with a zero second column: the first column
    // is vMF and the second is uniform on its orthogonal complement.
    const parameter = [6]f64{ 0, 0, 0, 0, 5, 0 };
    var matrix_vmf = try alea.distributions.MatrixVonMisesFisher(f64).initWithOptions(allocator, &parameter, 3, 2, 100, 10);
    defer matrix_vmf.deinit();
    var matrix_sum_z: f64 = 0;
    var matrix_sum_col1 = [_]f64{0} ** 3;
    const matrix_count = 1_000;
    var matrix_out: [6]f64 = undefined;
    for (0..matrix_count) |_| {
        try matrix_vmf.sampleIntoFrom(&engine, &matrix_out);
        matrix_sum_z += matrix_out[4];
        inline for (0..3) |i| matrix_sum_col1[i] += matrix_out[i * 2 + 1];
    }
    const matrix_nf: f64 = @floatFromInt(matrix_count);
    try stdout.print("matrix vMF first-column mean z: {d:.3}\n", .{matrix_sum_z / matrix_nf});
    try stdout.print("matrix vMF second-column mean: {d:.3} {d:.3} {d:.3}\n", .{
        matrix_sum_col1[0] / matrix_nf,
        matrix_sum_col1[1] / matrix_nf,
        matrix_sum_col1[2] / matrix_nf,
    });

    // SIMD vMF: one independent sample per f64x4 lane.
    const V = @Vector(4, f64);
    const vector_vmf = try alea.distributions.VectorVonMisesFisher(V).init(.{ 0, 0, 1 }, 5);
    var vector_sum_z: f64 = 0;
    var vector_count: usize = 0;
    const vector_samples = 2_000;
    for (0..vector_samples) |_| {
        const point = vector_vmf.sampleFrom(&engine);
        inline for (0..4) |lane| {
            const norm_sq = point[0][lane] * point[0][lane] + point[1][lane] * point[1][lane] + point[2][lane] * point[2][lane];
            std.debug.assert(@abs(norm_sq - 1) < 1e-10);
            vector_sum_z += point[2][lane];
            vector_count += 1;
        }
    }
    const vector_nf: f64 = @floatFromInt(vector_count);
    try stdout.print("vector vMF lane mean z: {d:.3}\n", .{vector_sum_z / vector_nf});

    // Full O(3) matrix Fisher: SO(3)/reflection mixture with deterministic
    // weights from the equivalent S³ Bingham normalizers.
    const o3 = try alea.distributions.MatrixFisherO3(f64).init(.{
        .{ 2, 0, 0 },
        .{ 0, 2, 0 },
        .{ 0, 0, 2 },
    });
    var o3_positive: usize = 0;
    const o3_count = 5_000;
    for (0..o3_count) |_| {
        const r = o3.sampleFrom(&engine);
        const det = r[0][0] * (r[1][1] * r[2][2] - r[1][2] * r[2][1]) -
            r[0][1] * (r[1][0] * r[2][2] - r[1][2] * r[2][0]) +
            r[0][2] * (r[1][0] * r[2][1] - r[1][1] * r[2][0]);
        if (det > 0) o3_positive += 1;
    }
    try stdout.print("matrix Fisher O(3) SO weight: {d:.3}, positive-det rate: {d:.3}\n", .{
        o3.soWeightValue(),
        @as(f64, @floatFromInt(o3_positive)) / @as(f64, @floatFromInt(o3_count)),
    });

    try stdout.print("\nUse the scalar samplers for single points and the Vector* samplers for one sample per SIMD lane.\n", .{});
    try stdout.flush();
}
