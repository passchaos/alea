const std = @import("std");
const alea = @import("alea");

const ziggurat = std.Random.ziggurat;
const trials = 3;

const norm_ratio = blk: {
    var out: [256]f64 = undefined;
    for (&out, 0..) |*item, i| item.* = ziggurat.NormDist.x[i + 1] / ziggurat.NormDist.x[i];
    break :blk out;
};

const native_norm_ratio_f32 = blk: {
    var out: [256]f32 = undefined;
    for (&out, 0..) |*item, i| item.* = @floatCast(ziggurat.NormDist.x[i + 1] / ziggurat.NormDist.x[i]);
    break :blk out;
};

const native_norm_x_f32 = blk: {
    var out: [257]f32 = undefined;
    for (&out, 0..) |*item, i| item.* = @floatCast(ziggurat.NormDist.x[i]);
    break :blk out;
};

const native_norm_f_f32 = blk: {
    var out: [257]f32 = undefined;
    for (&out, 0..) |*item, i| item.* = @floatCast(ziggurat.NormDist.f[i]);
    break :blk out;
};

const native_norm_r_f32: f32 = @floatCast(ziggurat.norm_r);

const norm_threshold = blk: {
    var out: [256]u64 = undefined;
    for (&out, 0..) |*item, i| {
        const ratio = ziggurat.NormDist.x[i + 1] / ziggurat.NormDist.x[i];
        item.* = @intFromFloat(@ceil(ratio * @as(f64, @floatFromInt(@as(u64, 1) << 51))));
    }
    break :blk out;
};

const norm_lower_threshold = blk: {
    var out: [256]u64 = undefined;
    for (&out, 0..) |*item, i| item.* = (@as(u64, 1) << 51) - norm_threshold[i];
    break :blk out;
};

const norm_upper_threshold = blk: {
    var out: [256]u64 = undefined;
    for (&out, 0..) |*item, i| item.* = (@as(u64, 1) << 51) + norm_threshold[i];
    break :blk out;
};

const exp_threshold = blk: {
    var out: [256]u64 = undefined;
    for (&out, 0..) |*item, i| {
        const threshold_ratio = ziggurat.ExpDist.x[i + 1] / ziggurat.ExpDist.x[i];
        item.* = @intFromFloat(@ceil(threshold_ratio * @as(f64, @floatFromInt(@as(u64, 1) << 52)) - 0.5));
    }
    break :blk out;
};

const native_exp_threshold_f32 = blk: {
    var out: [256]u32 = undefined;
    for (&out, 0..) |*item, i| {
        const threshold_ratio = ziggurat.ExpDist.x[i + 1] / ziggurat.ExpDist.x[i];
        item.* = @intFromFloat(@ceil(threshold_ratio * @as(f64, @floatFromInt(@as(u32, 1) << 23)) - 0.5));
    }
    break :blk out;
};

const native_exp_x_f32 = blk: {
    var out: [257]f32 = undefined;
    for (&out, 0..) |*item, i| item.* = @floatCast(ziggurat.ExpDist.x[i]);
    break :blk out;
};

const native_exp_f_f32 = blk: {
    var out: [257]f32 = undefined;
    for (&out, 0..) |*item, i| item.* = @floatCast(ziggurat.ExpDist.f[i]);
    break :blk out;
};

const native_exp_r_f32: f32 = @floatCast(ziggurat.exp_r);

var bench_filter: ?[]const u8 = null;

fn shouldRun(name: []const u8) bool {
    return bench_filter == null or std.mem.indexOf(u8, name, bench_filter.?) != null;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var args = std.process.Args.Iterator.init(init.minimal.args);
    defer args.deinit();
    _ = args.next();
    const lanes: usize = if (args.next()) |arg|
        std.fmt.parseInt(usize, arg, 10) catch 16 * 1024 * 1024
    else
        16 * 1024 * 1024;
    bench_filter = args.next();
    try stdout.print("vector microbench lanes={} filter={s}\n", .{ lanes, bench_filter orelse "<all>" });
    try benchFillVectorChanceBool(io, stdout, "alea fillVectorChance boolx64 p=0.25", lanes);
    try benchFillVectorRatioBool(io, stdout, "alea fillVectorRatio boolx64 1/4", lanes);
    try benchBoolX64(io, stdout, "alea distributions.fillVectorBernoulli boolx64 p=0.25", lanes, 0xb464, fillDistBernoulliBool);
    try benchBoolX64(io, stdout, "alea distributions.fillVectorBernoulli boolx64 direct p=0.25", lanes, 0xb464, fillDistBernoulliBoolDirect);
    try benchBoolX64(io, stdout, "alea distributions.VectorBernoulli.fill boolx64 p=0.25", lanes, 0xb464, fillDistBernoulliSamplerBool);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorBinomial u64x4 n=10 p=0.5", lanes / 4, 0xb150, fillDistBinomialU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorBinomial u64x4 direct n=10 p=0.5", lanes / 4, 0xb150, fillDistBinomialU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorBinomial.fill u64x4 n=10 p=0.5", lanes / 4, 0xb150, fillDistBinomialSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorBinomialPoissonApprox u64x4", lanes / 16, 0xb151, fillDistBinomialApproxU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorBinomialPoissonApprox u64x4 direct", lanes / 16, 0xb151, fillDistBinomialApproxU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorBinomialPoissonApprox.fill u64x4", lanes / 16, 0xb151, fillDistBinomialApproxSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorNegativeBinomial u64x4 r=5 p=0.25", lanes / 16, 0xb180, fillDistNegativeBinomialU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorNegativeBinomial u64x4 direct r=5 p=0.25", lanes / 16, 0xb180, fillDistNegativeBinomialU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorNegativeBinomial.fill u64x4 r=5 p=0.25", lanes / 16, 0xb180, fillDistNegativeBinomialSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorHypergeometric u64x4", lanes / 8, 0xb190, fillDistHypergeometricU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorHypergeometric u64x4 direct", lanes / 8, 0xb190, fillDistHypergeometricU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorHypergeometric.fill u64x4", lanes / 8, 0xb190, fillDistHypergeometricSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorGeometric u64x4 p=0.25", lanes / 8, 0xb250, fillDistGeometricU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorGeometric u64x4 direct p=0.25", lanes / 8, 0xb250, fillDistGeometricU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorGeometric.fill u64x4 p=0.25", lanes / 8, 0xb250, fillDistGeometricSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorGeometricFailures u64x4 p=0.25", lanes / 8, 0xb251, fillDistGeometricFailuresU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorGeometricFailures u64x4 direct p=0.25", lanes / 8, 0xb251, fillDistGeometricFailuresU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorGeometricFailures.fill u64x4 p=0.25", lanes / 8, 0xb251, fillDistGeometricFailuresSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorStandardGeometric u64x4", lanes / 4, 0xb252, fillDistStandardGeometricU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorStandardGeometric u64x4 direct", lanes / 4, 0xb252, fillDistStandardGeometricU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorStandardGeometric.fill u64x4", lanes / 4, 0xb252, fillDistStandardGeometricSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorPoisson u64x4 lambda=12", lanes / 4, 0xb012, fillDistPoissonU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorPoisson u64x4 direct lambda=12", lanes / 4, 0xb012, fillDistPoissonU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorPoisson.fill u64x4 lambda=12", lanes / 4, 0xb012, fillDistPoissonSamplerU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorPoissonAhrensDieter u64x4 lambda=20", lanes / 4, 0xb020, fillDistPoissonAhrensDieterU64);
    try benchVectorU64x4(io, stdout, "alea distributions.fillVectorPoissonAhrensDieter u64x4 direct lambda=20", lanes / 4, 0xb020, fillDistPoissonAhrensDieterU64Direct);
    try benchVectorU64x4(io, stdout, "alea distributions.VectorPoissonAhrensDieter.fill u64x4 lambda=20", lanes / 4, 0xb020, fillDistPoissonAhrensDieterSamplerU64);
    try benchFillVectorOpenF32(io, stdout, "alea fillVectorOpen f32x8", lanes);
    try benchFillVectorOpenClosedF32(io, stdout, "alea fillVectorOpenClosed f32x8", lanes);
    try benchFillVectorRangeF32(io, stdout, "alea fillVectorRange f32x8", lanes);
    try benchFillVectorF64(io, stdout, "alea fillVector f64x4", lanes);
    try benchFillVectorOpenF64(io, stdout, "alea fillVectorOpen f64x4", lanes);
    try benchFillVectorOpenClosedF64(io, stdout, "alea fillVectorOpenClosed f64x4", lanes);
    try benchFillVectorRangeF64(io, stdout, "alea fillVectorRange f64x4", lanes);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorUniform f32x8", lanes, 0xa118, fillDistUniformF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorUniform f32x8 direct", lanes, 0xa118, fillDistUniformF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.Open01.fill f32x8", lanes, 0xa119, fillDistOpen01F32);
    try benchVectorF64x4(io, stdout, "alea distributions.OpenClosed01.fill f64x4", lanes, 0xa11a, fillDistOpenClosed01F64);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardNormal f32x8", lanes / 4, 0xd188, fillDistStandardNormalF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardNormal f32x8 direct", lanes / 4, 0xd188, fillDistStandardNormalF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardNormalNativeF32 f32x8", lanes / 4, 0xd189, fillDistStandardNormalNativeF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardNormalNativeF32 f32x8 direct", lanes / 4, 0xd189, fillDistStandardNormalNativeF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.VectorStandardNormalNativeF32.fill f32x8", lanes / 4, 0xd189, fillDistStandardNormalNativeSamplerF32);
    try benchFillVectorF32x8Local(io, stdout, "alea distributions.fillVectorStandardNormalNativeF32 f32x8 repair candidate", lanes / 4, 0xd189, fillStandardNormalF32NativeRepair);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorNormalNativeF32 f32x8", lanes / 4, 0xd18a, fillDistNormalNativeF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorNormalNativeF32 f32x8 direct", lanes / 4, 0xd18a, fillDistNormalNativeF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.VectorNormalNativeF32.fill f32x8", lanes / 4, 0xd18a, fillDistNormalNativeSamplerF32);
    try benchFillVectorF32x8Local(io, stdout, "alea distributions.fillVectorNormalNativeF32 f32x8 repair candidate", lanes / 4, 0xd18a, fillNormalF32NativeRepair);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorNormal f64x4", lanes / 8, 0xd184, fillDistNormalF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorNormal f64x4 direct", lanes / 8, 0xd184, fillDistNormalF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorLogNormal f64x4", lanes / 16, 0xd194, fillDistLogNormalF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorLogNormal f64x4 direct", lanes / 16, 0xd194, fillDistLogNormalF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorLogNormal.fill f64x4", lanes / 16, 0xd194, fillDistLogNormalSamplerF64);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorLogNormal f32x8", lanes / 16, 0xd193, fillDistLogNormalF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorLogNormal f32x8 direct", lanes / 16, 0xd193, fillDistLogNormalF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.VectorLogNormal.fill f32x8", lanes / 16, 0xd193, fillDistLogNormalSamplerF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorLogNormalNativeF32 f32x8", lanes / 16, 0xd197, fillDistLogNormalNativeF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorLogNormalNativeF32 f32x8 direct", lanes / 16, 0xd197, fillDistLogNormalNativeF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.VectorLogNormalNativeF32.fill f32x8", lanes / 16, 0xd197, fillDistLogNormalNativeSamplerF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorLogNormalNativeExp2F32 f32x8", lanes / 16, 0xd198, fillDistLogNormalNativeExp2F32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorLogNormalNativeExp2F32 f32x8 direct", lanes / 16, 0xd198, fillDistLogNormalNativeExp2F32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.VectorLogNormalNativeExp2F32.fill f32x8", lanes / 16, 0xd198, fillDistLogNormalNativeExp2SamplerF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorLogNormalApproxF32 f32x8", lanes / 16, 0xd195, fillDistLogNormalApproxF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorLogNormalApproxF32 f32x8 direct", lanes / 16, 0xd195, fillDistLogNormalApproxF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.VectorLogNormalApproxF32.fill f32x8", lanes / 16, 0xd195, fillDistLogNormalApproxSamplerF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorLogNormalExp2F32 f32x8", lanes / 16, 0xd196, fillDistLogNormalExp2F32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorLogNormalExp2F32 f32x8 direct", lanes / 16, 0xd196, fillDistLogNormalExp2F32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.VectorLogNormalExp2F32.fill f32x8", lanes / 16, 0xd196, fillDistLogNormalExp2SamplerF32);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorHalfNormal f64x4", lanes / 8, 0xd1a4, fillDistHalfNormalF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorHalfNormal f64x4 direct", lanes / 8, 0xd1a4, fillDistHalfNormalF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorHalfNormal.fill f64x4", lanes / 8, 0xd1a4, fillDistHalfNormalSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorGamma f64x4", lanes / 16, 0xd2a4, fillDistGammaF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorGamma f64x4 direct", lanes / 16, 0xd2a4, fillDistGammaF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorGamma.fill f64x4", lanes / 16, 0xd2a4, fillDistGammaSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorChiSquared f64x4", lanes / 16, 0xd2b4, fillDistChiSquaredF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorChiSquared f64x4 direct", lanes / 16, 0xd2b4, fillDistChiSquaredF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorChiSquared.fill f64x4", lanes / 16, 0xd2b4, fillDistChiSquaredSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorChi f64x4", lanes / 16, 0xd2c4, fillDistChiF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorChi f64x4 direct", lanes / 16, 0xd2c4, fillDistChiF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorChi.fill f64x4", lanes / 16, 0xd2c4, fillDistChiSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorErlang f64x4", lanes / 16, 0xd2d4, fillDistErlangF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorErlang f64x4 direct", lanes / 16, 0xd2d4, fillDistErlangF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorErlang.fill f64x4", lanes / 16, 0xd2d4, fillDistErlangSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorBeta f64x4", lanes / 32, 0xd2e4, fillDistBetaF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorBeta f64x4 direct", lanes / 32, 0xd2e4, fillDistBetaF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorBeta.fill f64x4", lanes / 32, 0xd2e4, fillDistBetaSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorFisherF f64x4", lanes / 32, 0xd2f4, fillDistFisherF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorFisherF f64x4 direct", lanes / 32, 0xd2f4, fillDistFisherF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorFisherF.fill f64x4", lanes / 32, 0xd2f4, fillDistFisherFSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorStudentT f64x4", lanes / 32, 0xd304, fillDistStudentTF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorStudentT f64x4 direct", lanes / 32, 0xd304, fillDistStudentTF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorStudentT.fill f64x4", lanes / 32, 0xd304, fillDistStudentTSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorTriangular f64x4", lanes, 0xd314, fillDistTriangularF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorTriangular f64x4 direct", lanes, 0xd314, fillDistTriangularF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorTriangular.fill f64x4", lanes, 0xd314, fillDistTriangularSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorArcsine f64x4", lanes / 2, 0xd324, fillDistArcsineF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorArcsine f64x4 direct", lanes / 2, 0xd324, fillDistArcsineF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorArcsine.fill f64x4", lanes / 2, 0xd324, fillDistArcsineSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorCauchy f64x4", lanes / 2, 0xd334, fillDistCauchyF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorCauchy f64x4 direct", lanes / 2, 0xd334, fillDistCauchyF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorCauchy.fill f64x4", lanes / 2, 0xd334, fillDistCauchySamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorLaplace f64x4", lanes / 2, 0xd344, fillDistLaplaceF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorLaplace f64x4 direct", lanes / 2, 0xd344, fillDistLaplaceF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorLaplace.fill f64x4", lanes / 2, 0xd344, fillDistLaplaceSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorLogistic f64x4", lanes / 2, 0xd354, fillDistLogisticF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorLogistic f64x4 direct", lanes / 2, 0xd354, fillDistLogisticF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorLogistic.fill f64x4", lanes / 2, 0xd354, fillDistLogisticSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorLogLogistic f64x4", lanes / 32, 0xd364, fillDistLogLogisticF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorLogLogistic f64x4 direct", lanes / 32, 0xd364, fillDistLogLogisticF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorLogLogistic.fill f64x4", lanes / 32, 0xd364, fillDistLogLogisticSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorKumaraswamy f64x4", lanes / 32, 0xd374, fillDistKumaraswamyF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorKumaraswamy f64x4 direct", lanes / 32, 0xd374, fillDistKumaraswamyF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorKumaraswamy.fill f64x4", lanes / 32, 0xd374, fillDistKumaraswamySamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorPowerFunction f64x4", lanes / 2, 0xd384, fillDistPowerFunctionF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorPowerFunction f64x4 direct", lanes / 2, 0xd384, fillDistPowerFunctionF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorPowerFunction.fill f64x4", lanes / 2, 0xd384, fillDistPowerFunctionSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorRayleigh f64x4", lanes / 2, 0xd394, fillDistRayleighF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorRayleigh f64x4 direct", lanes / 2, 0xd394, fillDistRayleighF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorRayleigh.fill f64x4", lanes / 2, 0xd394, fillDistRayleighSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorMaxwell f64x4", lanes / 32, 0xd3a4, fillDistMaxwellF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorMaxwell f64x4 direct", lanes / 32, 0xd3a4, fillDistMaxwellF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorMaxwell.fill f64x4", lanes / 32, 0xd3a4, fillDistMaxwellSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorPareto f64x4", lanes / 2, 0xd3b4, fillDistParetoF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorPareto f64x4 direct", lanes / 2, 0xd3b4, fillDistParetoF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorPareto.fill f64x4", lanes / 2, 0xd3b4, fillDistParetoSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorWeibull f64x4", lanes / 2, 0xd3c4, fillDistWeibullF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorWeibull f64x4 direct", lanes / 2, 0xd3c4, fillDistWeibullF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorWeibull.fill f64x4", lanes / 2, 0xd3c4, fillDistWeibullSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorGumbel f64x4", lanes / 2, 0xd3d4, fillDistGumbelF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorGumbel f64x4 direct", lanes / 2, 0xd3d4, fillDistGumbelF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorGumbel.fill f64x4", lanes / 2, 0xd3d4, fillDistGumbelSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorFrechet f64x4", lanes / 2, 0xd3e4, fillDistFrechetF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorFrechet f64x4 direct", lanes / 2, 0xd3e4, fillDistFrechetF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorFrechet.fill f64x4", lanes / 2, 0xd3e4, fillDistFrechetSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorSkewNormal f64x4", lanes / 8, 0xd3f4, fillDistSkewNormalF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorSkewNormal f64x4 direct", lanes / 8, 0xd3f4, fillDistSkewNormalF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorSkewNormal.fill f64x4", lanes / 8, 0xd3f4, fillDistSkewNormalSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorPert f64x4", lanes / 32, 0xd404, fillDistPertF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorPert f64x4 direct", lanes / 32, 0xd404, fillDistPertF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorPert.fill f64x4", lanes / 32, 0xd404, fillDistPertSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorInverseGaussian f64x4", lanes / 8, 0xd414, fillDistInverseGaussianF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorInverseGaussian f64x4 direct", lanes / 8, 0xd414, fillDistInverseGaussianF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorInverseGaussian.fill f64x4", lanes / 8, 0xd414, fillDistInverseGaussianSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorNormalInverseGaussian f64x4", lanes / 8, 0xd424, fillDistNormalInverseGaussianF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorNormalInverseGaussian f64x4 direct", lanes / 8, 0xd424, fillDistNormalInverseGaussianF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorNormalInverseGaussian.fill f64x4", lanes / 8, 0xd424, fillDistNormalInverseGaussianSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorZipf f64x4", lanes / 128, 0xd434, fillDistZipfF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorZipf f64x4 direct", lanes / 128, 0xd434, fillDistZipfF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorZipf.fill f64x4", lanes / 128, 0xd434, fillDistZipfSamplerF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorZeta f64x4", lanes / 128, 0xd444, fillDistZetaF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorZeta f64x4 direct", lanes / 128, 0xd444, fillDistZetaF64Direct);
    try benchVectorF64x4(io, stdout, "alea distributions.VectorZeta.fill f64x4", lanes / 128, 0xd444, fillDistZetaSamplerF64);
    try benchUnit2F64x4(io, stdout, "alea distributions.fillVectorUnitCircle f64x4", lanes / 8, 0xd454, fillDistUnitCircleF64);
    try benchUnit2F64x4(io, stdout, "alea distributions.fillVectorUnitCircle f64x4 direct", lanes / 8, 0xd454, fillDistUnitCircleF64Direct);
    try benchUnit2F64x4(io, stdout, "alea distributions.VectorUnitCircle.fill f64x4", lanes / 8, 0xd454, fillDistUnitCircleSamplerF64);
    try benchUnit2F64x4(io, stdout, "alea distributions.fillVectorUnitDisc f64x4", lanes / 8, 0xd464, fillDistUnitDiscF64);
    try benchUnit2F64x4(io, stdout, "alea distributions.fillVectorUnitDisc f64x4 direct", lanes / 8, 0xd464, fillDistUnitDiscF64Direct);
    try benchUnit2F64x4(io, stdout, "alea distributions.VectorUnitDisc.fill f64x4", lanes / 8, 0xd464, fillDistUnitDiscSamplerF64);
    try benchUnit3F64x4(io, stdout, "alea distributions.fillVectorUnitSphere f64x4", lanes / 8, 0xd474, fillDistUnitSphereF64);
    try benchUnit3F64x4(io, stdout, "alea distributions.fillVectorUnitSphere f64x4 direct", lanes / 8, 0xd474, fillDistUnitSphereF64Direct);
    try benchUnit3F64x4(io, stdout, "alea distributions.VectorUnitSphere.fill f64x4", lanes / 8, 0xd474, fillDistUnitSphereSamplerF64);
    try benchUnit3F64x4(io, stdout, "alea distributions.fillVectorUnitBall f64x4", lanes / 16, 0xd484, fillDistUnitBallF64);
    try benchUnit3F64x4(io, stdout, "alea distributions.fillVectorUnitBall f64x4 direct", lanes / 16, 0xd484, fillDistUnitBallF64Direct);
    try benchUnit3F64x4(io, stdout, "alea distributions.VectorUnitBall.fill f64x4", lanes / 16, 0xd484, fillDistUnitBallSamplerF64);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardExponential f32x8", lanes, 0xe188, fillDistStandardExponentialF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardExponential f32x8 direct", lanes, 0xe188, fillDistStandardExponentialF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardExponentialNativeF32 f32x8", lanes, 0xe189, fillDistStandardExponentialNativeF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardExponentialNativeF32 f32x8 direct", lanes, 0xe189, fillDistStandardExponentialNativeF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.VectorStandardExponentialNativeF32.fill f32x8", lanes, 0xe189, fillDistStandardExponentialNativeSamplerF32);
    try benchFillVectorF32x8Local(io, stdout, "alea distributions.fillVectorStandardExponentialNativeF32 f32x8 repair candidate", lanes, 0xe189, fillStandardExponentialF32NativeRepair);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardExponentialApproxLogF32 f32x8", lanes, 0xe18b, fillDistStandardExponentialApproxLogF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorStandardExponentialApproxLogF32 f32x8 direct", lanes, 0xe18b, fillDistStandardExponentialApproxLogF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.VectorStandardExponentialApproxLogF32.fill f32x8", lanes, 0xe18b, fillDistStandardExponentialApproxLogSamplerF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorExponentialNativeF32 f32x8", lanes, 0xe18a, fillDistExponentialNativeF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorExponentialNativeF32 f32x8 direct", lanes, 0xe18a, fillDistExponentialNativeF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.VectorExponentialNativeF32.fill f32x8", lanes, 0xe18a, fillDistExponentialNativeSamplerF32);
    try benchFillVectorF32x8Local(io, stdout, "alea distributions.fillVectorExponentialNativeF32 f32x8 repair candidate", lanes, 0xe18a, fillExponentialF32NativeRepair);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorExponentialApproxLogF32 f32x8", lanes, 0xe18c, fillDistExponentialApproxLogF32);
    try benchVectorF32x8(io, stdout, "alea distributions.fillVectorExponentialApproxLogF32 f32x8 direct", lanes, 0xe18c, fillDistExponentialApproxLogF32Direct);
    try benchVectorF32x8(io, stdout, "alea distributions.VectorExponentialApproxLogF32.fill f32x8", lanes, 0xe18c, fillDistExponentialApproxLogSamplerF32);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorExponential f64x4", lanes / 2, 0xe184, fillDistExponentialF64);
    try benchVectorF64x4(io, stdout, "alea distributions.fillVectorExponential f64x4 direct", lanes / 2, 0xe184, fillDistExponentialF64Direct);
    try benchFillVectorStandardNormalF32(io, stdout, "alea fillVectorStandardNormal f32x8", lanes / 4);
    try benchFillVectorStandardNormalF32Direct(io, stdout, "alea fillVectorStandardNormal f32x8 direct", lanes / 4);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 native candidate", lanes / 4, 0xd188, fillStandardNormalF32Native);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 flat-slice candidate", lanes / 4, 0xd188, fillStandardNormalF32FlatSlice);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 marsaglia-polar candidate", lanes / 4, 0xd188, fillStandardNormalF32MarsagliaPolar);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 approx-log polar candidate", lanes / 4, 0xd188, fillStandardNormalF32ApproxLogPolar);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 ratio-uniforms candidate", lanes / 4, 0xd188, fillStandardNormalF32RatioUniforms);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 ratio-uniforms dense-block candidate", lanes / 4, 0xd188, fillStandardNormalF32RatioUniformsDenseBlock);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 inverse-cdf candidate", lanes / 4, 0xd188, fillStandardNormalF32InverseCdf);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 inverse-cdf f32 candidate", lanes / 4, 0xd188, fillStandardNormalF32InverseCdfF32);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 inverse-cdf central candidate", lanes / 4, 0xd188, fillStandardNormalF32InverseCdfCentral);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 inverse-cdf tail-repair candidate", lanes / 4, 0xd188, fillStandardNormalF32InverseCdfTailRepair);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 inverse-cdf central-only probe", lanes / 4, 0xd188, fillStandardNormalF32InverseCdfCentralOnly);
    try benchFillVectorStandardNormalF32Repair(io, stdout, "alea fillVectorStandardNormal f32x8 repair candidate", lanes / 4);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 same-candidate repair", lanes / 4, 0xd188, fillStandardNormalF32SameCandidateRepair);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 all-accepted repair", lanes / 4, 0xd188, fillStandardNormalF32AllAcceptedRepair);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 block-fallback candidate", lanes / 4, 0xd188, fillStandardNormalF32BlockFallback);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardNormal f32x8 range-block candidate", lanes / 4, 0xd188, fillStandardNormalF32RangeBlock);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorStandardNormal f32x8 fast direct", lanes / 4, 0xd188, fillStandardNormalF32FastDirect);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorStandardNormal f32x8 fast repair candidate", lanes / 4, 0xd188, fillStandardNormalF32FastRepair);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorStandardNormal f32x8 fast same-candidate repair", lanes / 4, 0xd188, fillStandardNormalF32FastSameCandidateRepair);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorStandardNormal f32x8 fast all-accepted repair", lanes / 4, 0xd188, fillStandardNormalF32FastAllAcceptedRepair);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorStandardNormal f32x8 fast block-fallback candidate", lanes / 4, 0xd188, fillStandardNormalF32FastBlockFallback);
    try benchFillVectorStandardNormalF64(io, stdout, "alea fillVectorStandardNormal f64x4", lanes / 8);
    try benchFillVectorStandardNormalF64Direct(io, stdout, "alea fillVectorStandardNormal f64x4 direct", lanes / 8);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 local scalar candidate", lanes / 8, 0xd184, fillStandardNormalF64Local);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 noinline local candidate", lanes / 8, 0xd184, fillStandardNormalF64NoInlineLocal);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 marsaglia-polar candidate", lanes / 8, 0xd184, fillStandardNormalF64MarsagliaPolar);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 approx-log polar candidate", lanes / 8, 0xd184, fillStandardNormalF64ApproxLogPolar);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 ratio-uniforms candidate", lanes / 8, 0xd184, fillStandardNormalF64RatioUniforms);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 ratio-uniforms dense-block candidate", lanes / 8, 0xd184, fillStandardNormalF64RatioUniformsDenseBlock);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 inverse-cdf candidate", lanes / 8, 0xd184, fillStandardNormalF64InverseCdf);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 inverse-cdf central candidate", lanes / 8, 0xd184, fillStandardNormalF64InverseCdfCentral);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 inverse-cdf tail-repair candidate", lanes / 8, 0xd184, fillStandardNormalF64InverseCdfTailRepair);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 same-candidate repair", lanes / 8, 0xd184, fillStandardNormalF64SameCandidateRepair);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 all-accepted repair", lanes / 8, 0xd184, fillStandardNormalF64AllAcceptedRepair);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 block-fallback candidate", lanes / 8, 0xd184, fillStandardNormalF64BlockFallback);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardNormal f64x4 range-block candidate", lanes / 8, 0xd184, fillStandardNormalF64RangeBlock);
    try benchFillVectorNormalF32(io, stdout, "alea fillVectorNormal f32x8", lanes / 4);
    try benchFillVectorNormalF32Direct(io, stdout, "alea fillVectorNormal f32x8 direct", lanes / 4);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 flat-slice candidate", lanes / 4, 0xd188, fillNormalF32FlatSlice);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 marsaglia-polar candidate", lanes / 4, 0xd188, fillNormalF32MarsagliaPolar);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 approx-log polar candidate", lanes / 4, 0xd188, fillNormalF32ApproxLogPolar);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 ratio-uniforms candidate", lanes / 4, 0xd188, fillNormalF32RatioUniforms);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 ratio-uniforms dense-block candidate", lanes / 4, 0xd188, fillNormalF32RatioUniformsDenseBlock);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 inverse-cdf candidate", lanes / 4, 0xd188, fillNormalF32InverseCdf);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 inverse-cdf f32 candidate", lanes / 4, 0xd188, fillNormalF32InverseCdfF32);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 inverse-cdf central candidate", lanes / 4, 0xd188, fillNormalF32InverseCdfCentral);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 inverse-cdf tail-repair candidate", lanes / 4, 0xd188, fillNormalF32InverseCdfTailRepair);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 inverse-cdf central-only probe", lanes / 4, 0xd188, fillNormalF32InverseCdfCentralOnly);
    try benchFillVectorNormalF32Repair(io, stdout, "alea fillVectorNormal f32x8 repair candidate", lanes / 4);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 same-candidate repair", lanes / 4, 0xd188, fillNormalF32SameCandidateRepair);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 all-accepted repair", lanes / 4, 0xd188, fillNormalF32AllAcceptedRepair);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 block-fallback candidate", lanes / 4, 0xd188, fillNormalF32BlockFallback);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorNormal f32x8 range-block candidate", lanes / 4, 0xd188, fillNormalF32RangeBlock);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorNormal f32x8 fast direct", lanes / 4, 0xd188, fillNormalF32FastDirect);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorNormal f32x8 fast repair candidate", lanes / 4, 0xd188, fillNormalF32FastRepair);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorNormal f32x8 fast same-candidate repair", lanes / 4, 0xd188, fillNormalF32FastSameCandidateRepair);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorNormal f32x8 fast all-accepted repair", lanes / 4, 0xd188, fillNormalF32FastAllAcceptedRepair);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorNormal f32x8 fast block-fallback candidate", lanes / 4, 0xd188, fillNormalF32FastBlockFallback);
    try benchFillVectorNormalF64(io, stdout, "alea fillVectorNormal f64x4", lanes / 8);
    try benchFillVectorNormalF64Direct(io, stdout, "alea fillVectorNormal f64x4 direct", lanes / 8);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 local scalar candidate", lanes / 8, 0xd184, fillNormalF64Local);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 noinline local candidate", lanes / 8, 0xd184, fillNormalF64NoInlineLocal);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 marsaglia-polar candidate", lanes / 8, 0xd184, fillNormalF64MarsagliaPolar);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 approx-log polar candidate", lanes / 8, 0xd184, fillNormalF64ApproxLogPolar);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 ratio-uniforms candidate", lanes / 8, 0xd184, fillNormalF64RatioUniforms);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 ratio-uniforms dense-block candidate", lanes / 8, 0xd184, fillNormalF64RatioUniformsDenseBlock);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 inverse-cdf candidate", lanes / 8, 0xd184, fillNormalF64InverseCdf);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 inverse-cdf central candidate", lanes / 8, 0xd184, fillNormalF64InverseCdfCentral);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 inverse-cdf tail-repair candidate", lanes / 8, 0xd184, fillNormalF64InverseCdfTailRepair);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 same-candidate repair", lanes / 8, 0xd184, fillNormalF64SameCandidateRepair);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 all-accepted repair", lanes / 8, 0xd184, fillNormalF64AllAcceptedRepair);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 block-fallback candidate", lanes / 8, 0xd184, fillNormalF64BlockFallback);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorNormal f64x4 range-block candidate", lanes / 8, 0xd184, fillNormalF64RangeBlock);
    try benchFillVectorStandardExponentialF32(io, stdout, "alea fillVectorStandardExponential f32x8", lanes);
    try benchFillVectorStandardExponentialF32Direct(io, stdout, "alea fillVectorStandardExponential f32x8 direct", lanes);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardExponential f32x8 native candidate", lanes, 0xe188, fillStandardExponentialF32Native);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardExponential f32x8 flat-slice candidate", lanes, 0xe188, fillStandardExponentialF32FlatSlice);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardExponential f32x8 approx-log candidate", lanes, 0xe188, fillStandardExponentialF32ApproxLog);
    try benchFillVectorStandardExponentialF32Repair(io, stdout, "alea fillVectorStandardExponential f32x8 repair candidate", lanes);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardExponential f32x8 same-candidate repair", lanes, 0xe188, fillStandardExponentialF32SameCandidateRepair);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardExponential f32x8 all-accepted repair", lanes, 0xe188, fillStandardExponentialF32AllAcceptedRepair);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardExponential f32x8 block-fallback candidate", lanes, 0xe188, fillStandardExponentialF32BlockFallback);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorStandardExponential f32x8 mask-redraw candidate", lanes, 0xe188, fillStandardExponentialF32MaskRedraw);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorStandardExponential f32x8 fast direct", lanes, 0xe188, fillStandardExponentialF32FastDirect);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorStandardExponential f32x8 fast repair candidate", lanes, 0xe188, fillStandardExponentialF32FastRepair);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorStandardExponential f32x8 fast same-candidate repair", lanes, 0xe188, fillStandardExponentialF32FastSameCandidateRepair);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorStandardExponential f32x8 fast all-accepted repair", lanes, 0xe188, fillStandardExponentialF32FastAllAcceptedRepair);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorStandardExponential f32x8 fast block-fallback candidate", lanes, 0xe188, fillStandardExponentialF32FastBlockFallback);
    try benchFillVectorStandardExponentialF64(io, stdout, "alea fillVectorStandardExponential f64x4", lanes / 2);
    try benchFillVectorStandardExponentialF64Direct(io, stdout, "alea fillVectorStandardExponential f64x4 direct", lanes / 2);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardExponential f64x4 local scalar candidate", lanes / 2, 0xe184, fillStandardExponentialF64Local);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardExponential f64x4 approx-log candidate", lanes / 2, 0xe184, fillStandardExponentialF64ApproxLog);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardExponential f64x4 same-candidate repair", lanes / 2, 0xe184, fillStandardExponentialF64SameCandidateRepair);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardExponential f64x4 all-accepted repair", lanes / 2, 0xe184, fillStandardExponentialF64AllAcceptedRepair);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardExponential f64x4 block-fallback candidate", lanes / 2, 0xe184, fillStandardExponentialF64BlockFallback);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorStandardExponential f64x4 mask-redraw candidate", lanes / 2, 0xe184, fillStandardExponentialF64MaskRedraw);
    try benchFillVectorExponentialF32(io, stdout, "alea fillVectorExponential f32x8", lanes);
    try benchFillVectorExponentialF32Direct(io, stdout, "alea fillVectorExponential f32x8 direct", lanes);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorExponential f32x8 flat-slice candidate", lanes, 0xe188, fillExponentialF32FlatSlice);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorExponential f32x8 approx-log candidate", lanes, 0xe188, fillExponentialF32ApproxLog);
    try benchFillVectorExponentialF32Repair(io, stdout, "alea fillVectorExponential f32x8 repair candidate", lanes);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorExponential f32x8 same-candidate repair", lanes, 0xe188, fillExponentialF32SameCandidateRepair);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorExponential f32x8 all-accepted repair", lanes, 0xe188, fillExponentialF32AllAcceptedRepair);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorExponential f32x8 block-fallback candidate", lanes, 0xe188, fillExponentialF32BlockFallback);
    try benchFillVectorF32x8Local(io, stdout, "alea fillVectorExponential f32x8 mask-redraw candidate", lanes, 0xe188, fillExponentialF32MaskRedraw);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorExponential f32x8 fast direct", lanes, 0xe188, fillExponentialF32FastDirect);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorExponential f32x8 fast repair candidate", lanes, 0xe188, fillExponentialF32FastRepair);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorExponential f32x8 fast same-candidate repair", lanes, 0xe188, fillExponentialF32FastSameCandidateRepair);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorExponential f32x8 fast all-accepted repair", lanes, 0xe188, fillExponentialF32FastAllAcceptedRepair);
    try benchFillVectorF32x8Fast(io, stdout, "alea fillVectorExponential f32x8 fast block-fallback candidate", lanes, 0xe188, fillExponentialF32FastBlockFallback);
    try benchFillVectorExponentialF64(io, stdout, "alea fillVectorExponential f64x4", lanes / 2);
    try benchFillVectorExponentialF64Direct(io, stdout, "alea fillVectorExponential f64x4 direct", lanes / 2);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorExponential f64x4 local scalar candidate", lanes / 2, 0xe184, fillExponentialF64Local);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorExponential f64x4 approx-log candidate", lanes / 2, 0xe184, fillExponentialF64ApproxLog);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorExponential f64x4 same-candidate repair", lanes / 2, 0xe184, fillExponentialF64SameCandidateRepair);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorExponential f64x4 all-accepted repair", lanes / 2, 0xe184, fillExponentialF64AllAcceptedRepair);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorExponential f64x4 block-fallback candidate", lanes / 2, 0xe184, fillExponentialF64BlockFallback);
    try benchFillVectorF64x4Local(io, stdout, "alea fillVectorExponential f64x4 mask-redraw candidate", lanes / 2, 0xe184, fillExponentialF64MaskRedraw);
    try stdout.flush();
}

fn benchFillVectorChanceBool(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [256]@Vector(64, bool) = undefined;
    const vector_count = lanes / 64;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xc464);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorChance(@Vector(64, bool), out[0..n], 0.25);
            checksum += checksumBoolVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 64)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBoolX64(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.ScalarPrng, alea.Rng, []@Vector(64, bool)) void,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [256]@Vector(64, bool) = undefined;
    const vector_count = lanes / 64;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, rng, out[0..n]);
            checksum += checksumBoolVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 64)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn fillDistBernoulliBool(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(64, bool)) void {
    alea.distributions.fillVectorBernoulli(rng, @Vector(64, bool), dest, 0.25);
}

fn fillDistBernoulliBoolDirect(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(64, bool)) void {
    alea.distributions.fillVectorBernoulliFrom(engine, @Vector(64, bool), dest, 0.25);
}

fn fillDistBernoulliSamplerBool(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(64, bool)) void {
    const sampler = alea.distributions.VectorBernoulli(@Vector(64, bool)).initRatio(1, 4) catch unreachable;
    sampler.fill(rng, dest);
}

fn benchFillVectorRatioBool(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [256]@Vector(64, bool) = undefined;
    const vector_count = lanes / 64;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x7146);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorRatio(@Vector(64, bool), out[0..n], 1, 4);
            checksum += checksumBoolVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 64)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorU64x4(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.ScalarPrng, alea.Rng, []@Vector(4, u64)) void,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [128]@Vector(4, u64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, rng, out[0..n]);
            checksum +%= checksumVectorsU64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn fillDistBinomialU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorBinomial(rng, @Vector(4, u64), dest, 10, 0.5);
}

fn fillDistBinomialU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorBinomialFrom(engine, @Vector(4, u64), dest, 10, 0.5);
}

fn fillDistBinomialSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorBinomial(@Vector(4, u64)).init(10, 0.5) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistBinomialApproxU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorBinomialPoissonApprox(rng, @Vector(4, u64), dest, 10_000, 0.01);
}

fn fillDistBinomialApproxU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorBinomialPoissonApproxFrom(engine, @Vector(4, u64), dest, 10_000, 0.01);
}

fn fillDistBinomialApproxSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorBinomialPoissonApprox(@Vector(4, u64)).init(10_000, 0.01) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistNegativeBinomialU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorNegativeBinomial(rng, @Vector(4, u64), dest, 5, 0.25);
}

fn fillDistNegativeBinomialU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorNegativeBinomialFrom(engine, @Vector(4, u64), dest, 5, 0.25);
}

fn fillDistNegativeBinomialSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorNegativeBinomial(@Vector(4, u64)).init(5, 0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistHypergeometricU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorHypergeometric(rng, @Vector(4, u64), dest, 100, 30, 10);
}

fn fillDistHypergeometricU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorHypergeometricFrom(engine, @Vector(4, u64), dest, 100, 30, 10);
}

fn fillDistHypergeometricSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorHypergeometric(@Vector(4, u64)).init(100, 30, 10) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistGeometricU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorGeometric(rng, @Vector(4, u64), dest, 0.25);
}

fn fillDistGeometricU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorGeometricFrom(engine, @Vector(4, u64), dest, 0.25);
}

fn fillDistGeometricSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorGeometric(@Vector(4, u64)).init(0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistGeometricFailuresU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorGeometricFailures(rng, @Vector(4, u64), dest, 0.25);
}

fn fillDistGeometricFailuresU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorGeometricFailuresFrom(engine, @Vector(4, u64), dest, 0.25);
}

fn fillDistGeometricFailuresSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorGeometricFailures(@Vector(4, u64)).init(0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistStandardGeometricU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorStandardGeometric(rng, @Vector(4, u64), dest);
}

fn fillDistStandardGeometricU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorStandardGeometricFrom(engine, @Vector(4, u64), dest);
}

fn fillDistStandardGeometricSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorStandardGeometric(@Vector(4, u64)){};
    sampler.fill(rng, dest);
}

fn fillDistPoissonU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorPoisson(rng, @Vector(4, u64), dest, 12);
}

fn fillDistPoissonU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorPoissonFrom(engine, @Vector(4, u64), dest, 12);
}

fn fillDistPoissonSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorPoisson(@Vector(4, u64)).init(12) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistPoissonAhrensDieterU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorPoissonAhrensDieter(rng, @Vector(4, u64), dest, 20);
}

fn fillDistPoissonAhrensDieterU64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, u64)) void {
    alea.distributions.fillVectorPoissonAhrensDieterFrom(engine, @Vector(4, u64), dest, 20);
}

fn fillDistPoissonAhrensDieterSamplerU64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, u64)) void {
    const sampler = alea.distributions.VectorPoissonAhrensDieter(@Vector(4, u64)).init(20) catch unreachable;
    sampler.fill(rng, dest);
}

fn benchFillVectorOpenF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x0f88);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorOpenFrom(&engine, @Vector(8, f32), out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorOpenClosedF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x0fc8);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorOpenClosedFrom(&engine, @Vector(8, f32), out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorRangeF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xf188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorRange(@Vector(8, f32), out[0..n], -1, 1);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xf164);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fill(@Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorOpenF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x0f64);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorOpenFrom(&engine, @Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorOpenClosedF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x0c64);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorOpenClosedFrom(&engine, @Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorRangeF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xf164);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorRange(@Vector(4, f64), out[0..n], -1, 1);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorF32x8(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.ScalarPrng, alea.Rng, []@Vector(8, f32)) void,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, rng, out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorF64x4(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.ScalarPrng, alea.Rng, []@Vector(4, f64)) void,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, rng, out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnit2F64x4(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.ScalarPrng, alea.Rng, [][2]@Vector(4, f64)) void,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256][2]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, rng, out[0..n]);
            checksum += checksumUnit2F64x4(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnit3F64x4(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.ScalarPrng, alea.Rng, [][3]@Vector(4, f64)) void,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256][3]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, rng, out[0..n]);
            checksum += checksumUnit3F64x4(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn fillDistUniformF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorUniform(rng, @Vector(8, f32), dest, -1, 1);
}

fn fillDistUniformF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorUniformFrom(engine, @Vector(8, f32), dest, -1, 1);
}

fn fillDistOpen01F32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    (alea.distributions.Open01{}).fill(rng, @Vector(8, f32), dest);
}

fn fillDistOpenClosed01F64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    (alea.distributions.OpenClosed01{}).fill(rng, @Vector(4, f64), dest);
}

fn fillDistStandardNormalF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardNormal(rng, @Vector(8, f32), dest);
}

fn fillDistStandardNormalF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardNormalFrom(engine, @Vector(8, f32), dest);
}

fn fillDistStandardNormalNativeF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardNormalNativeF32(rng, @Vector(8, f32), dest);
}

fn fillDistStandardNormalNativeF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardNormalNativeF32From(engine, @Vector(8, f32), dest);
}

fn fillDistStandardNormalNativeSamplerF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    const sampler = alea.distributions.VectorStandardNormalNativeF32(@Vector(8, f32)){};
    sampler.fill(rng, dest);
}

fn fillDistNormalNativeF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorNormalNativeF32(rng, @Vector(8, f32), dest, 0, 1);
}

fn fillDistNormalNativeF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorNormalNativeF32From(engine, @Vector(8, f32), dest, 0, 1);
}

fn fillDistNormalNativeSamplerF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    const sampler = alea.distributions.VectorNormalNativeF32(@Vector(8, f32)).init(0, 1) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistNormalF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorNormal(rng, @Vector(4, f64), dest, 0, 1);
}

fn fillDistNormalF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorNormalFrom(engine, @Vector(4, f64), dest, 0, 1);
}

fn fillDistLogNormalF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorLogNormal(rng, @Vector(4, f64), dest, 0, 0.25);
}

fn fillDistLogNormalF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorLogNormalFrom(engine, @Vector(4, f64), dest, 0, 0.25);
}

fn fillDistLogNormalSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorLogNormal(@Vector(4, f64)).init(0, 0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistLogNormalF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorLogNormal(rng, @Vector(8, f32), dest, 0, 0.25);
}

fn fillDistLogNormalF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorLogNormalFrom(engine, @Vector(8, f32), dest, 0, 0.25);
}

fn fillDistLogNormalSamplerF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    const sampler = alea.distributions.VectorLogNormal(@Vector(8, f32)).init(0, 0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistLogNormalNativeF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorLogNormalNativeF32(rng, @Vector(8, f32), dest, 0, 0.25);
}

fn fillDistLogNormalNativeF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorLogNormalNativeF32From(engine, @Vector(8, f32), dest, 0, 0.25);
}

fn fillDistLogNormalNativeSamplerF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    const sampler = alea.distributions.VectorLogNormalNativeF32(@Vector(8, f32)).init(0, 0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistLogNormalNativeExp2F32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorLogNormalNativeExp2F32(rng, @Vector(8, f32), dest, 0, 0.25);
}

fn fillDistLogNormalNativeExp2F32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorLogNormalNativeExp2F32From(engine, @Vector(8, f32), dest, 0, 0.25);
}

fn fillDistLogNormalNativeExp2SamplerF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    const sampler = alea.distributions.VectorLogNormalNativeExp2F32(@Vector(8, f32)).init(0, 0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistLogNormalApproxF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorLogNormalApproxF32(rng, @Vector(8, f32), dest, 0, 0.25);
}

fn fillDistLogNormalApproxF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorLogNormalApproxF32From(engine, @Vector(8, f32), dest, 0, 0.25);
}

fn fillDistLogNormalApproxSamplerF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    const sampler = alea.distributions.VectorLogNormalApproxF32(@Vector(8, f32)).init(0, 0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistLogNormalExp2F32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorLogNormalExp2F32(rng, @Vector(8, f32), dest, 0, 0.25);
}

fn fillDistLogNormalExp2F32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorLogNormalExp2F32From(engine, @Vector(8, f32), dest, 0, 0.25);
}

fn fillDistLogNormalExp2SamplerF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    const sampler = alea.distributions.VectorLogNormalExp2F32(@Vector(8, f32)).init(0, 0.25) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistHalfNormalF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorHalfNormal(rng, @Vector(4, f64), dest, 2);
}

fn fillDistHalfNormalF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorHalfNormalFrom(engine, @Vector(4, f64), dest, 2);
}

fn fillDistHalfNormalSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorHalfNormal(@Vector(4, f64)).init(2) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistGammaF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorGamma(rng, @Vector(4, f64), dest, 2, 3);
}

fn fillDistGammaF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorGammaFrom(engine, @Vector(4, f64), dest, 2, 3);
}

fn fillDistGammaSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorGamma(@Vector(4, f64)).init(2, 3) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistChiSquaredF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorChiSquared(rng, @Vector(4, f64), dest, 4);
}

fn fillDistChiSquaredF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorChiSquaredFrom(engine, @Vector(4, f64), dest, 4);
}

fn fillDistChiSquaredSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorChiSquared(@Vector(4, f64)).init(4) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistChiF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorChi(rng, @Vector(4, f64), dest, 4);
}

fn fillDistChiF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorChiFrom(engine, @Vector(4, f64), dest, 4);
}

fn fillDistChiSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorChi(@Vector(4, f64)).init(4) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistErlangF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorErlang(rng, @Vector(4, f64), dest, 3, 2);
}

fn fillDistErlangF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorErlangFrom(engine, @Vector(4, f64), dest, 3, 2);
}

fn fillDistErlangSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorErlang(@Vector(4, f64)).init(3, 2) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistBetaF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorBeta(rng, @Vector(4, f64), dest, 2, 5);
}

fn fillDistBetaF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorBetaFrom(engine, @Vector(4, f64), dest, 2, 5);
}

fn fillDistBetaSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorBeta(@Vector(4, f64)).init(2, 5) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistFisherF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorFisherF(rng, @Vector(4, f64), dest, 5, 20);
}

fn fillDistFisherF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorFisherFFrom(engine, @Vector(4, f64), dest, 5, 20);
}

fn fillDistFisherFSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorFisherF(@Vector(4, f64)).init(5, 20) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistStudentTF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorStudentT(rng, @Vector(4, f64), dest, 10);
}

fn fillDistStudentTF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorStudentTFrom(engine, @Vector(4, f64), dest, 10);
}

fn fillDistStudentTSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorStudentT(@Vector(4, f64)).init(10) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistTriangularF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorTriangular(rng, @Vector(4, f64), dest, -1, 0, 2);
}

fn fillDistTriangularF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorTriangularFrom(engine, @Vector(4, f64), dest, -1, 0, 2);
}

fn fillDistTriangularSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorTriangular(@Vector(4, f64)).init(-1, 0, 2) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistArcsineF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorArcsine(rng, @Vector(4, f64), dest, -1, 3);
}

fn fillDistArcsineF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorArcsineFrom(engine, @Vector(4, f64), dest, -1, 3);
}

fn fillDistArcsineSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorArcsine(@Vector(4, f64)).init(-1, 3) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistCauchyF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorCauchy(rng, @Vector(4, f64), dest, 0, 1);
}

fn fillDistCauchyF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorCauchyFrom(engine, @Vector(4, f64), dest, 0, 1);
}

fn fillDistCauchySamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorCauchy(@Vector(4, f64)).init(0, 1) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistLaplaceF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorLaplace(rng, @Vector(4, f64), dest, 0, 1);
}

fn fillDistLaplaceF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorLaplaceFrom(engine, @Vector(4, f64), dest, 0, 1);
}

fn fillDistLaplaceSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorLaplace(@Vector(4, f64)).init(0, 1) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistLogisticF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorLogistic(rng, @Vector(4, f64), dest, 0, 1);
}

fn fillDistLogisticF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorLogisticFrom(engine, @Vector(4, f64), dest, 0, 1);
}

fn fillDistLogisticSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorLogistic(@Vector(4, f64)).init(0, 1) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistLogLogisticF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorLogLogistic(rng, @Vector(4, f64), dest, 2, 3);
}

fn fillDistLogLogisticF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorLogLogisticFrom(engine, @Vector(4, f64), dest, 2, 3);
}

fn fillDistLogLogisticSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorLogLogistic(@Vector(4, f64)).init(2, 3) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistKumaraswamyF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorKumaraswamy(rng, @Vector(4, f64), dest, 2, 5);
}

fn fillDistKumaraswamyF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorKumaraswamyFrom(engine, @Vector(4, f64), dest, 2, 5);
}

fn fillDistKumaraswamySamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorKumaraswamy(@Vector(4, f64)).init(2, 5) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistPowerFunctionF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorPowerFunction(rng, @Vector(4, f64), dest, -1, 2, 3);
}

fn fillDistPowerFunctionF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorPowerFunctionFrom(engine, @Vector(4, f64), dest, -1, 2, 3);
}

fn fillDistPowerFunctionSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorPowerFunction(@Vector(4, f64)).init(-1, 2, 3) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistRayleighF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorRayleigh(rng, @Vector(4, f64), dest, 2);
}

fn fillDistRayleighF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorRayleighFrom(engine, @Vector(4, f64), dest, 2);
}

fn fillDistRayleighSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorRayleigh(@Vector(4, f64)).init(2) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistMaxwellF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorMaxwell(rng, @Vector(4, f64), dest, 2);
}

fn fillDistMaxwellF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorMaxwellFrom(engine, @Vector(4, f64), dest, 2);
}

fn fillDistMaxwellSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorMaxwell(@Vector(4, f64)).init(2) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistParetoF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorPareto(rng, @Vector(4, f64), dest, 2, 3);
}

fn fillDistParetoF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorParetoFrom(engine, @Vector(4, f64), dest, 2, 3);
}

fn fillDistParetoSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorPareto(@Vector(4, f64)).init(2, 3) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistWeibullF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorWeibull(rng, @Vector(4, f64), dest, 2, 1.5);
}

fn fillDistWeibullF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorWeibullFrom(engine, @Vector(4, f64), dest, 2, 1.5);
}

fn fillDistWeibullSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorWeibull(@Vector(4, f64)).init(2, 1.5) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistGumbelF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorGumbel(rng, @Vector(4, f64), dest, 0, 1);
}

fn fillDistGumbelF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorGumbelFrom(engine, @Vector(4, f64), dest, 0, 1);
}

fn fillDistGumbelSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorGumbel(@Vector(4, f64)).init(0, 1) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistFrechetF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorFrechet(rng, @Vector(4, f64), dest, 0, 2, 3);
}

fn fillDistFrechetF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorFrechetFrom(engine, @Vector(4, f64), dest, 0, 2, 3);
}

fn fillDistFrechetSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorFrechet(@Vector(4, f64)).init(0, 2, 3) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistSkewNormalF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorSkewNormal(rng, @Vector(4, f64), dest, 0, 1, 2);
}

fn fillDistSkewNormalF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorSkewNormalFrom(engine, @Vector(4, f64), dest, 0, 1, 2);
}

fn fillDistSkewNormalSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorSkewNormal(@Vector(4, f64)).init(0, 1, 2) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistPertF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorPert(rng, @Vector(4, f64), dest, 0, 4, 10, 4);
}

fn fillDistPertF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorPertFrom(engine, @Vector(4, f64), dest, 0, 4, 10, 4);
}

fn fillDistPertSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorPert(@Vector(4, f64)).init(0, 4, 10, 4) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistInverseGaussianF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorInverseGaussian(rng, @Vector(4, f64), dest, 1, 2);
}

fn fillDistInverseGaussianF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorInverseGaussianFrom(engine, @Vector(4, f64), dest, 1, 2);
}

fn fillDistInverseGaussianSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorInverseGaussian(@Vector(4, f64)).init(1, 2) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistNormalInverseGaussianF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorNormalInverseGaussian(rng, @Vector(4, f64), dest, 2, 1);
}

fn fillDistNormalInverseGaussianF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorNormalInverseGaussianFrom(engine, @Vector(4, f64), dest, 2, 1);
}

fn fillDistNormalInverseGaussianSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorNormalInverseGaussian(@Vector(4, f64)).init(2, 1) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistZipfF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorZipf(rng, @Vector(4, f64), dest, 10, 1.5);
}

fn fillDistZipfF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorZipfFrom(engine, @Vector(4, f64), dest, 10, 1.5);
}

fn fillDistZipfSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorZipf(@Vector(4, f64)).init(10, 1.5) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistZetaF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorZeta(rng, @Vector(4, f64), dest, 3);
}

fn fillDistZetaF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorZetaFrom(engine, @Vector(4, f64), dest, 3);
}

fn fillDistZetaSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorZeta(@Vector(4, f64)).init(3) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistUnitCircleF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: [][2]@Vector(4, f64)) void {
    alea.distributions.fillVectorUnitCircle(rng, @Vector(4, f64), dest);
}

fn fillDistUnitCircleF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: [][2]@Vector(4, f64)) void {
    alea.distributions.fillVectorUnitCircleFrom(engine, @Vector(4, f64), dest);
}

fn fillDistUnitCircleSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: [][2]@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorUnitCircle(@Vector(4, f64)){};
    sampler.fill(rng, dest);
}

fn fillDistUnitDiscF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: [][2]@Vector(4, f64)) void {
    alea.distributions.fillVectorUnitDisc(rng, @Vector(4, f64), dest);
}

fn fillDistUnitDiscF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: [][2]@Vector(4, f64)) void {
    alea.distributions.fillVectorUnitDiscFrom(engine, @Vector(4, f64), dest);
}

fn fillDistUnitDiscSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: [][2]@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorUnitDisc(@Vector(4, f64)){};
    sampler.fill(rng, dest);
}

fn fillDistUnitSphereF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: [][3]@Vector(4, f64)) void {
    alea.distributions.fillVectorUnitSphere(rng, @Vector(4, f64), dest);
}

fn fillDistUnitSphereF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: [][3]@Vector(4, f64)) void {
    alea.distributions.fillVectorUnitSphereFrom(engine, @Vector(4, f64), dest);
}

fn fillDistUnitSphereSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: [][3]@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorUnitSphere(@Vector(4, f64)){};
    sampler.fill(rng, dest);
}

fn fillDistUnitBallF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: [][3]@Vector(4, f64)) void {
    alea.distributions.fillVectorUnitBall(rng, @Vector(4, f64), dest);
}

fn fillDistUnitBallF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: [][3]@Vector(4, f64)) void {
    alea.distributions.fillVectorUnitBallFrom(engine, @Vector(4, f64), dest);
}

fn fillDistUnitBallSamplerF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: [][3]@Vector(4, f64)) void {
    const sampler = alea.distributions.VectorUnitBall(@Vector(4, f64)){};
    sampler.fill(rng, dest);
}

fn fillDistStandardExponentialF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardExponential(rng, @Vector(8, f32), dest);
}

fn fillDistStandardExponentialF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardExponentialFrom(engine, @Vector(8, f32), dest);
}

fn fillDistStandardExponentialNativeF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardExponentialNativeF32(rng, @Vector(8, f32), dest);
}

fn fillDistStandardExponentialNativeF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardExponentialNativeF32From(engine, @Vector(8, f32), dest);
}

fn fillDistStandardExponentialNativeSamplerF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    const sampler = alea.distributions.VectorStandardExponentialNativeF32(@Vector(8, f32)){};
    sampler.fill(rng, dest);
}

fn fillDistStandardExponentialApproxLogF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardExponentialApproxLogF32(rng, @Vector(8, f32), dest);
}

fn fillDistStandardExponentialApproxLogF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorStandardExponentialApproxLogF32From(engine, @Vector(8, f32), dest);
}

fn fillDistStandardExponentialApproxLogSamplerF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    const sampler = alea.distributions.VectorStandardExponentialApproxLogF32(@Vector(8, f32)){};
    sampler.fill(rng, dest);
}

fn fillDistExponentialNativeF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorExponentialNativeF32(rng, @Vector(8, f32), dest, 2);
}

fn fillDistExponentialNativeF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorExponentialNativeF32From(engine, @Vector(8, f32), dest, 2);
}

fn fillDistExponentialNativeSamplerF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    const sampler = alea.distributions.VectorExponentialNativeF32(@Vector(8, f32)).init(2) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistExponentialApproxLogF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorExponentialApproxLogF32(rng, @Vector(8, f32), dest, 2);
}

fn fillDistExponentialApproxLogF32Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(8, f32)) void {
    alea.distributions.fillVectorExponentialApproxLogF32From(engine, @Vector(8, f32), dest, 2);
}

fn fillDistExponentialApproxLogSamplerF32(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(8, f32)) void {
    const sampler = alea.distributions.VectorExponentialApproxLogF32(@Vector(8, f32)).init(2) catch unreachable;
    sampler.fill(rng, dest);
}

fn fillDistExponentialF64(_: *alea.ScalarPrng, rng: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorExponential(rng, @Vector(4, f64), dest, 2);
}

fn fillDistExponentialF64Direct(engine: *alea.ScalarPrng, _: alea.Rng, dest: []@Vector(4, f64)) void {
    alea.distributions.fillVectorExponentialFrom(engine, @Vector(4, f64), dest, 2);
}

fn benchFillVectorStandardNormalF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorStandardNormal(@Vector(8, f32), out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardNormalF32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorStandardNormalFrom(&engine, @Vector(8, f32), out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardNormalF32Repair(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillStandardNormalF32Repair(&engine, out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorF32x8Fast(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.FastPrng, []@Vector(8, f32)) void,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorF32x8Local(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.ScalarPrng, []@Vector(8, f32)) void,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorF64x4Local(
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    lanes: usize,
    comptime seed: u64,
    comptime fillFn: fn (*alea.ScalarPrng, []@Vector(4, f64)) void,
) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardNormalF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd184);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorStandardNormal(@Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardNormalF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd184);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorStandardNormalFrom(&engine, @Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorNormalF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorNormal(@Vector(8, f32), out[0..n], 0, 1);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorNormalF32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorNormalFrom(&engine, @Vector(8, f32), out[0..n], 0, 1);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorNormalF32Repair(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillNormalF32Repair(&engine, out[0..n], 0, 1);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorNormalF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd184);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorNormal(@Vector(4, f64), out[0..n], 0, 1);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorNormalF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd184);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorNormalFrom(&engine, @Vector(4, f64), out[0..n], 0, 1);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardExponentialF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorStandardExponential(@Vector(8, f32), out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardExponentialF32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorStandardExponentialFrom(&engine, @Vector(8, f32), out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardExponentialF32Repair(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillStandardExponentialF32Repair(&engine, out[0..n]);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardExponentialF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe184);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorStandardExponential(@Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorStandardExponentialF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe184);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorStandardExponentialFrom(&engine, @Vector(4, f64), out[0..n]);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorExponentialF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorExponential(@Vector(8, f32), out[0..n], 2);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorExponentialF32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorExponentialFrom(&engine, @Vector(8, f32), out[0..n], 2);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorExponentialF32Repair(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [256]@Vector(8, f32) = undefined;
    const vector_count = lanes / 8;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe188);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillExponentialF32Repair(&engine, out[0..n], 2);
            checksum += checksumVectors(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 8)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorExponentialF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe184);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillVectorExponential(@Vector(4, f64), out[0..n], 2);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillVectorExponentialF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, lanes: usize) !void {
    if (!shouldRun(name)) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [256]@Vector(4, f64) = undefined;
    const vector_count = lanes / 4;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe184);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = vector_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillVectorExponentialFrom(&engine, @Vector(4, f64), out[0..n], 2);
            checksum += checksumVectorsF64(&out, n);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(vector_count * 4)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn checksumBoolVectors(vectors: []const @Vector(64, bool), len: usize) u64 {
    var checksum: u64 = 0;
    for (vectors[0..len]) |vec| {
        inline for (0..64) |lane| checksum += @intFromBool(vec[lane]);
    }
    return checksum;
}

fn checksumVectorsU64(vectors: []const @Vector(4, u64), len: usize) u64 {
    var checksum: u64 = 0;
    for (vectors[0..len]) |vec| {
        inline for (0..4) |lane| checksum +%= vec[lane];
    }
    return checksum;
}

fn checksumVectors(vectors: []const @Vector(8, f32), len: usize) f32 {
    var checksum: f32 = 0;
    for (vectors[0..len]) |vec| {
        inline for (0..8) |lane| checksum += vec[lane];
    }
    return checksum;
}

fn checksumVectorsF64(vectors: []const @Vector(4, f64), len: usize) f64 {
    var checksum: f64 = 0;
    for (vectors[0..len]) |vec| {
        inline for (0..4) |lane| checksum += vec[lane];
    }
    return checksum;
}

fn checksumUnit2F64x4(points: []const [2]@Vector(4, f64), len: usize) f64 {
    var checksum: f64 = 0;
    for (points[0..len]) |point| {
        inline for (0..4) |lane| checksum += point[0][lane] + point[1][lane];
    }
    return checksum;
}

fn checksumUnit3F64x4(points: []const [3]@Vector(4, f64), len: usize) f64 {
    var checksum: f64 = 0;
    for (points[0..len]) |point| {
        inline for (0..4) |lane| checksum += point[0][lane] + point[1][lane] + point[2][lane];
    }
    return checksum;
}

fn fillStandardNormalF32Repair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairNormalF32Correct(engine);
}

fn fillStandardNormalF32FlatSlice(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const scalars = std.mem.bytesAsSlice(f32, std.mem.sliceAsBytes(dest));
    alea.Rng.fillNormalFrom(engine, f32, scalars, 0, 1);
}

fn fillStandardNormalF32Native(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const scalars = std.mem.bytesAsSlice(f32, std.mem.sliceAsBytes(dest));
    alea.distributions.fillStandardNormalNativeF32From(engine, scalars);
}

fn fillStandardNormalF32MarsagliaPolar(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorMarsagliaPolarNormalF32(engine);
}

fn fillStandardNormalF32ApproxLogPolar(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorApproxLogPolarNormalF32(engine);
}

fn fillStandardNormalF32RatioUniforms(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRatioUniformsNormalF32(engine);
}

fn fillStandardNormalF32RatioUniformsDenseBlock(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRatioUniformsNormalF32DenseBlock(engine);
}

fn fillStandardNormalF32InverseCdf(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorInverseCdfNormalF32(engine);
}

fn fillStandardNormalF32InverseCdfF32(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorInverseCdfNormalF32Fast(engine);
}

fn fillStandardNormalF32InverseCdfCentral(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorInverseCdfNormalF32Central(engine);
}

fn fillStandardNormalF32InverseCdfTailRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorInverseCdfNormalF32TailRepair(engine);
}

fn fillStandardNormalF32InverseCdfCentralOnly(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorInverseCdfNormalF32CentralOnly(engine);
}

fn fillStandardNormalF32NativeRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairNativeNormalF32(engine);
}

fn fillStandardNormalF32SameCandidateRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairNormalF32SameCandidate(engine);
}

fn fillStandardNormalF32AllAcceptedRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairNormalF32AllAccepted(engine);
}

fn fillStandardNormalF32BlockFallback(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairNormalF32BlockFallback(engine);
}

fn fillStandardNormalF32RangeBlock(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairNormalF32RangeBlock(engine);
}

fn fillNormalF32Repair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32), mean: f32, stddev: f32) void {
    const mean_vec: @Vector(8, f32) = @splat(mean);
    const stddev_vec: @Vector(8, f32) = @splat(stddev);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF32Correct(engine);
}

fn fillNormalF32FlatSlice(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const scalars = std.mem.bytesAsSlice(f32, std.mem.sliceAsBytes(dest));
    alea.Rng.fillNormalFrom(engine, f32, scalars, 0, 1);
}

fn fillNormalF32NativeRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNativeNormalF32(engine);
}

fn fillNormalF32MarsagliaPolar(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorMarsagliaPolarNormalF32(engine);
}

fn fillNormalF32ApproxLogPolar(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorApproxLogPolarNormalF32(engine);
}

fn fillNormalF32RatioUniforms(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRatioUniformsNormalF32(engine);
}

fn fillNormalF32RatioUniformsDenseBlock(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRatioUniformsNormalF32DenseBlock(engine);
}

fn fillNormalF32InverseCdf(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorInverseCdfNormalF32(engine);
}

fn fillNormalF32InverseCdfF32(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorInverseCdfNormalF32Fast(engine);
}

fn fillNormalF32InverseCdfCentral(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorInverseCdfNormalF32Central(engine);
}

fn fillNormalF32InverseCdfTailRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorInverseCdfNormalF32TailRepair(engine);
}

fn fillNormalF32InverseCdfCentralOnly(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorInverseCdfNormalF32CentralOnly(engine);
}

fn fillNormalF32SameCandidateRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF32SameCandidate(engine);
}

fn fillNormalF32AllAcceptedRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF32AllAccepted(engine);
}

fn fillNormalF32BlockFallback(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF32BlockFallback(engine);
}

fn fillNormalF32RangeBlock(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF32RangeBlock(engine);
}

fn fillStandardExponentialF32Repair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairExponentialF32Correct(engine);
}

fn fillStandardExponentialF32FlatSlice(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const scalars = std.mem.bytesAsSlice(f32, std.mem.sliceAsBytes(dest));
    alea.Rng.fillExponentialFrom(engine, f32, scalars, 1);
}

fn fillStandardExponentialF32ApproxLog(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorApproxLogExponentialF32(engine);
}

fn fillStandardExponentialF32Native(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const scalars = std.mem.bytesAsSlice(f32, std.mem.sliceAsBytes(dest));
    alea.distributions.fillStandardExponentialNativeF32From(engine, scalars);
}

fn fillStandardExponentialF32NativeRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairNativeExponentialF32(engine);
}

fn fillStandardExponentialF32SameCandidateRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairExponentialF32SameCandidate(engine);
}

fn fillStandardExponentialF32AllAcceptedRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairExponentialF32AllAccepted(engine);
}

fn fillStandardExponentialF32BlockFallback(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairExponentialF32BlockFallback(engine);
}

fn fillStandardExponentialF32MaskRedraw(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorMaskRedrawExponentialF32(engine);
}

fn fillExponentialF32Repair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32), rate: f32) void {
    const inverse_rate: @Vector(8, f32) = @splat(1 / rate);
    for (dest) |*item| item.* = vectorRepairExponentialF32Correct(engine) * inverse_rate;
}

fn fillExponentialF32FlatSlice(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const scalars = std.mem.bytesAsSlice(f32, std.mem.sliceAsBytes(dest));
    alea.Rng.fillExponentialFrom(engine, f32, scalars, 2);
}

fn fillExponentialF32ApproxLog(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const inverse_rate: @Vector(8, f32) = @splat(0.5);
    for (dest) |*item| item.* = vectorApproxLogExponentialF32(engine) * inverse_rate;
}

fn fillExponentialF32NativeRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const inverse_rate: @Vector(8, f32) = @splat(0.5);
    for (dest) |*item| item.* = vectorRepairNativeExponentialF32(engine) * inverse_rate;
}

fn fillExponentialF32SameCandidateRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const inverse_rate: @Vector(8, f32) = @splat(0.5);
    for (dest) |*item| item.* = vectorRepairExponentialF32SameCandidate(engine) * inverse_rate;
}

fn fillExponentialF32AllAcceptedRepair(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const inverse_rate: @Vector(8, f32) = @splat(0.5);
    for (dest) |*item| item.* = vectorRepairExponentialF32AllAccepted(engine) * inverse_rate;
}

fn fillExponentialF32BlockFallback(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const inverse_rate: @Vector(8, f32) = @splat(0.5);
    for (dest) |*item| item.* = vectorRepairExponentialF32BlockFallback(engine) * inverse_rate;
}

fn fillExponentialF32MaskRedraw(engine: *alea.ScalarPrng, dest: []@Vector(8, f32)) void {
    const inverse_rate: @Vector(8, f32) = @splat(0.5);
    for (dest) |*item| item.* = vectorMaskRedrawExponentialF32(engine) * inverse_rate;
}

fn fillStandardNormalF32FastDirect(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    alea.Rng.fillVectorStandardNormalFrom(engine, @Vector(8, f32), dest);
}

fn fillStandardNormalF32FastRepair(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairNormalF32FastCorrect(engine);
}

fn fillStandardNormalF32FastSameCandidateRepair(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairNormalF32FastSameCandidate(engine);
}

fn fillStandardNormalF32FastAllAcceptedRepair(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairNormalF32FastAllAccepted(engine);
}

fn fillStandardNormalF32FastBlockFallback(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairNormalF32FastBlockFallback(engine);
}

fn fillNormalF32FastDirect(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    alea.Rng.fillVectorNormalFrom(engine, @Vector(8, f32), dest, 0, 1);
}

fn fillNormalF32FastRepair(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF32FastCorrect(engine);
}

fn fillNormalF32FastSameCandidateRepair(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF32FastSameCandidate(engine);
}

fn fillNormalF32FastAllAcceptedRepair(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF32FastAllAccepted(engine);
}

fn fillNormalF32FastBlockFallback(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    const mean_vec: @Vector(8, f32) = @splat(0);
    const stddev_vec: @Vector(8, f32) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF32FastBlockFallback(engine);
}

fn fillStandardExponentialF32FastDirect(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    alea.Rng.fillVectorStandardExponentialFrom(engine, @Vector(8, f32), dest);
}

fn fillStandardExponentialF32FastRepair(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairExponentialF32FastCorrect(engine);
}

fn fillStandardExponentialF32FastSameCandidateRepair(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairExponentialF32FastSameCandidate(engine);
}

fn fillStandardExponentialF32FastAllAcceptedRepair(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairExponentialF32FastAllAccepted(engine);
}

fn fillStandardExponentialF32FastBlockFallback(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    for (dest) |*item| item.* = vectorRepairExponentialF32FastBlockFallback(engine);
}

fn fillExponentialF32FastDirect(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    alea.Rng.fillVectorExponentialFrom(engine, @Vector(8, f32), dest, 2);
}

fn fillExponentialF32FastRepair(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    const inverse_rate: @Vector(8, f32) = @splat(0.5);
    for (dest) |*item| item.* = vectorRepairExponentialF32FastCorrect(engine) * inverse_rate;
}

fn fillExponentialF32FastSameCandidateRepair(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    const inverse_rate: @Vector(8, f32) = @splat(0.5);
    for (dest) |*item| item.* = vectorRepairExponentialF32FastSameCandidate(engine) * inverse_rate;
}

fn fillExponentialF32FastAllAcceptedRepair(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    const inverse_rate: @Vector(8, f32) = @splat(0.5);
    for (dest) |*item| item.* = vectorRepairExponentialF32FastAllAccepted(engine) * inverse_rate;
}

fn fillExponentialF32FastBlockFallback(engine: *alea.FastPrng, dest: []@Vector(8, f32)) void {
    const inverse_rate: @Vector(8, f32) = @splat(0.5);
    for (dest) |*item| item.* = vectorRepairExponentialF32FastBlockFallback(engine) * inverse_rate;
}

fn fillStandardNormalF64Local(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorNormalF64Local(engine);
}

fn fillStandardNormalF64NoInlineLocal(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorNormalF64NoInlineLocal(engine);
}

fn fillStandardNormalF64MarsagliaPolar(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorMarsagliaPolarNormalF64(engine);
}

fn fillStandardNormalF64ApproxLogPolar(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorApproxLogPolarNormalF64(engine);
}

fn fillStandardNormalF64RatioUniforms(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorRatioUniformsNormalF64(engine);
}

fn fillStandardNormalF64RatioUniformsDenseBlock(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorRatioUniformsNormalF64DenseBlock(engine);
}

fn fillStandardNormalF64InverseCdf(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorInverseCdfNormalF64(engine);
}

fn fillStandardNormalF64InverseCdfCentral(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorInverseCdfNormalF64Central(engine);
}

fn fillStandardNormalF64InverseCdfTailRepair(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorInverseCdfNormalF64TailRepair(engine);
}

fn fillStandardNormalF64SameCandidateRepair(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorRepairNormalF64SameCandidate(engine);
}

fn fillStandardNormalF64AllAcceptedRepair(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorRepairNormalF64AllAccepted(engine);
}

fn fillStandardNormalF64BlockFallback(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorRepairNormalF64BlockFallback(engine);
}

fn fillStandardNormalF64RangeBlock(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorRepairNormalF64RangeBlock(engine);
}

fn fillNormalF64Local(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorNormalF64Local(engine);
}

fn fillNormalF64NoInlineLocal(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorNormalF64NoInlineLocal(engine);
}

fn fillNormalF64MarsagliaPolar(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(1);
    for (dest) |*item| item.* = vectorMarsagliaPolarNormalF64(engine) * inverse_rate;
}

fn fillNormalF64ApproxLogPolar(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(1);
    for (dest) |*item| item.* = vectorApproxLogPolarNormalF64(engine) * inverse_rate;
}

fn fillNormalF64RatioUniforms(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(1);
    for (dest) |*item| item.* = vectorRatioUniformsNormalF64(engine) * inverse_rate;
}

fn fillNormalF64RatioUniformsDenseBlock(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(1);
    for (dest) |*item| item.* = vectorRatioUniformsNormalF64DenseBlock(engine) * inverse_rate;
}

fn fillNormalF64InverseCdf(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(1);
    for (dest) |*item| item.* = vectorInverseCdfNormalF64(engine) * inverse_rate;
}

fn fillNormalF64InverseCdfCentral(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(1);
    for (dest) |*item| item.* = vectorInverseCdfNormalF64Central(engine) * inverse_rate;
}

fn fillNormalF64InverseCdfTailRepair(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(1);
    for (dest) |*item| item.* = vectorInverseCdfNormalF64TailRepair(engine) * inverse_rate;
}

fn fillNormalF64SameCandidateRepair(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const mean_vec: @Vector(4, f64) = @splat(0);
    const stddev_vec: @Vector(4, f64) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF64SameCandidate(engine);
}

fn fillNormalF64AllAcceptedRepair(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const mean_vec: @Vector(4, f64) = @splat(0);
    const stddev_vec: @Vector(4, f64) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF64AllAccepted(engine);
}

fn fillNormalF64BlockFallback(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const mean_vec: @Vector(4, f64) = @splat(0);
    const stddev_vec: @Vector(4, f64) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF64BlockFallback(engine);
}

fn fillNormalF64RangeBlock(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const mean_vec: @Vector(4, f64) = @splat(0);
    const stddev_vec: @Vector(4, f64) = @splat(1);
    for (dest) |*item| item.* = mean_vec + stddev_vec * vectorRepairNormalF64RangeBlock(engine);
}

fn fillStandardExponentialF64Local(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorExponentialF64Local(engine);
}

fn fillStandardExponentialF64ApproxLog(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorApproxLogExponentialF64(engine);
}

fn fillStandardExponentialF64SameCandidateRepair(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorRepairExponentialF64SameCandidate(engine);
}

fn fillStandardExponentialF64AllAcceptedRepair(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorRepairExponentialF64AllAccepted(engine);
}

fn fillStandardExponentialF64BlockFallback(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorRepairExponentialF64BlockFallback(engine);
}

fn fillStandardExponentialF64MaskRedraw(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    for (dest) |*item| item.* = vectorMaskRedrawExponentialF64(engine);
}

fn fillExponentialF64Local(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(0.5);
    for (dest) |*item| item.* = vectorExponentialF64Local(engine) * inverse_rate;
}

fn fillExponentialF64ApproxLog(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(0.5);
    for (dest) |*item| item.* = vectorApproxLogExponentialF64(engine) * inverse_rate;
}

fn fillExponentialF64SameCandidateRepair(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(0.5);
    for (dest) |*item| item.* = vectorRepairExponentialF64SameCandidate(engine) * inverse_rate;
}

fn fillExponentialF64AllAcceptedRepair(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(0.5);
    for (dest) |*item| item.* = vectorRepairExponentialF64AllAccepted(engine) * inverse_rate;
}

fn fillExponentialF64BlockFallback(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(0.5);
    for (dest) |*item| item.* = vectorRepairExponentialF64BlockFallback(engine) * inverse_rate;
}

fn fillExponentialF64MaskRedraw(engine: *alea.ScalarPrng, dest: []@Vector(4, f64)) void {
    const inverse_rate: @Vector(4, f64) = @splat(0.5);
    for (dest) |*item| item.* = vectorMaskRedrawExponentialF64(engine) * inverse_rate;
}

fn vectorNormalF64Local(engine: *alea.ScalarPrng) @Vector(4, f64) {
    var out: @Vector(4, f64) = undefined;
    inline for (0..4) |lane| out[lane] = ratioNormal(engine);
    return out;
}

noinline fn vectorNormalF64NoInlineLocal(engine: *alea.ScalarPrng) @Vector(4, f64) {
    var out: @Vector(4, f64) = undefined;
    inline for (0..4) |lane| out[lane] = ratioNormal(engine);
    return out;
}

fn vectorExponentialF64Local(engine: *alea.ScalarPrng) @Vector(4, f64) {
    var out: @Vector(4, f64) = undefined;
    inline for (0..4) |lane| out[lane] = thresholdExponential(engine);
    return out;
}

fn vectorApproxLogExponentialF32(engine: *alea.ScalarPrng) @Vector(8, f32) {
    return approxNegLogF32(vectorOpenF32Local(engine));
}

fn vectorApproxLogExponentialF64(engine: *alea.ScalarPrng) @Vector(4, f64) {
    return approxNegLogF64(vectorOpenF64Local(engine));
}

fn approxNegLogF32(u: @Vector(8, f32)) @Vector(8, f32) {
    const Vec = @Vector(8, f32);
    const VecU = @Vector(8, u32);
    const bits: VecU = @bitCast(u);
    const exponent_bits = (bits >> @as(VecU, @splat(23))) & @as(VecU, @splat(0xff));
    const mantissa_bits = (bits & @as(VecU, @splat(0x7fffff))) | @as(VecU, @splat(@as(u32, 0x7f) << 23));
    var exponent = @as(Vec, @floatFromInt(@as(@Vector(8, i32), @intCast(exponent_bits)))) - @as(Vec, @splat(127.0));
    var m = @as(Vec, @bitCast(mantissa_bits));
    const high_mask = m > @as(Vec, @splat(1.4142135623730951));
    m = @select(f32, high_mask, m * @as(Vec, @splat(0.5)), m);
    exponent += @select(f32, high_mask, @as(Vec, @splat(1.0)), @as(Vec, @splat(0.0)));
    const z = (m - @as(Vec, @splat(1.0))) / (m + @as(Vec, @splat(1.0)));
    const z2 = z * z;
    const z4 = z2 * z2;
    const z8 = z4 * z4;
    const poly = @as(Vec, @splat(1.0)) + z2 * @as(Vec, @splat(1.0 / 3.0)) + z4 * @as(Vec, @splat(1.0 / 5.0)) + z4 * z2 * @as(Vec, @splat(1.0 / 7.0)) + z8 * @as(Vec, @splat(1.0 / 9.0));
    const log_m = @as(Vec, @splat(2.0)) * z * poly;
    return -(exponent * @as(Vec, @splat(std.math.ln2)) + log_m);
}

fn approxNegLogF64(u: @Vector(4, f64)) @Vector(4, f64) {
    const Vec = @Vector(4, f64);
    const VecU = @Vector(4, u64);
    const bits: VecU = @bitCast(u);
    const exponent_bits = (bits >> @as(VecU, @splat(52))) & @as(VecU, @splat(0x7ff));
    const mantissa_bits = (bits & @as(VecU, @splat(0x000f_ffff_ffff_ffff))) | @as(VecU, @splat(@as(u64, 0x3ff) << 52));
    var exponent = @as(Vec, @floatFromInt(@as(@Vector(4, i64), @intCast(exponent_bits)))) - @as(Vec, @splat(1023.0));
    var m = @as(Vec, @bitCast(mantissa_bits));
    const high_mask = m > @as(Vec, @splat(1.4142135623730951));
    m = @select(f64, high_mask, m * @as(Vec, @splat(0.5)), m);
    exponent += @select(f64, high_mask, @as(Vec, @splat(1.0)), @as(Vec, @splat(0.0)));
    const z = (m - @as(Vec, @splat(1.0))) / (m + @as(Vec, @splat(1.0)));
    const z2 = z * z;
    const z4 = z2 * z2;
    const z8 = z4 * z4;
    const poly = @as(Vec, @splat(1.0)) + z2 * @as(Vec, @splat(1.0 / 3.0)) + z4 * @as(Vec, @splat(1.0 / 5.0)) + z4 * z2 * @as(Vec, @splat(1.0 / 7.0)) + z8 * @as(Vec, @splat(1.0 / 9.0));
    const log_m = @as(Vec, @splat(2.0)) * z * poly;
    return -(exponent * @as(Vec, @splat(std.math.ln2)) + log_m);
}

fn vectorMarsagliaPolarNormalF32(engine: *alea.ScalarPrng) @Vector(8, f32) {
    var out: [8]f32 = undefined;
    var filled: usize = 0;
    while (filled < out.len) {
        const x = alea.Rng.floatRangeFrom(engine, f32, -1, 1);
        const y = alea.Rng.floatRangeFrom(engine, f32, -1, 1);
        const s = x * x + y * y;
        if (s == 0 or s >= 1) continue;
        const factor = @sqrt(-2.0 * @log(s) / s);
        out[filled] = x * factor;
        filled += 1;
        if (filled < out.len) {
            out[filled] = y * factor;
            filled += 1;
        }
    }
    return out;
}

fn vectorMarsagliaPolarNormalF64(engine: *alea.ScalarPrng) @Vector(4, f64) {
    var out: [4]f64 = undefined;
    var filled: usize = 0;
    while (filled < out.len) {
        const x = alea.Rng.floatRangeFrom(engine, f64, -1, 1);
        const y = alea.Rng.floatRangeFrom(engine, f64, -1, 1);
        const s = x * x + y * y;
        if (s == 0 or s >= 1) continue;
        const factor = @sqrt(-2.0 * @log(s) / s);
        out[filled] = x * factor;
        filled += 1;
        if (filled < out.len) {
            out[filled] = y * factor;
            filled += 1;
        }
    }
    return out;
}

fn vectorApproxLogPolarNormalF32(engine: *alea.ScalarPrng) @Vector(8, f32) {
    var out: [8]f32 = undefined;
    var filled: usize = 0;
    while (filled < out.len) {
        const x = alea.Rng.floatRangeFrom(engine, f32, -1, 1);
        const y = alea.Rng.floatRangeFrom(engine, f32, -1, 1);
        const s = x * x + y * y;
        if (s == 0 or s >= 1) continue;
        const factor = @sqrt(2.0 * approxNegLogScalarF32(s) / s);
        out[filled] = x * factor;
        filled += 1;
        if (filled < out.len) {
            out[filled] = y * factor;
            filled += 1;
        }
    }
    return out;
}

fn vectorApproxLogPolarNormalF64(engine: *alea.ScalarPrng) @Vector(4, f64) {
    var out: [4]f64 = undefined;
    var filled: usize = 0;
    while (filled < out.len) {
        const x = alea.Rng.floatRangeFrom(engine, f64, -1, 1);
        const y = alea.Rng.floatRangeFrom(engine, f64, -1, 1);
        const s = x * x + y * y;
        if (s == 0 or s >= 1) continue;
        const factor = @sqrt(2.0 * approxNegLogScalarF64(s) / s);
        out[filled] = x * factor;
        filled += 1;
        if (filled < out.len) {
            out[filled] = y * factor;
            filled += 1;
        }
    }
    return out;
}

fn approxNegLogScalarF32(u: f32) f32 {
    return approxNegLogF32(@as(@Vector(8, f32), @splat(u)))[0];
}

fn approxNegLogScalarF64(u: f64) f64 {
    return approxNegLogF64(@as(@Vector(4, f64), @splat(u)))[0];
}

fn vectorRatioUniformsNormalF32(engine: *alea.ScalarPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| out[lane] = @floatCast(ratioUniformsNormalF64(engine));
    return out;
}

fn vectorRatioUniformsNormalF32DenseBlock(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const Vec = @Vector(8, f32);
    while (true) {
        const u = vectorOpenF32Local(engine);
        const v = @as(Vec, @splat(1.7156)) * (vectorF32Local(engine) - @as(Vec, @splat(0.5)));
        const x = u - @as(Vec, @splat(0.449871));
        const y = @abs(v) + @as(Vec, @splat(0.386595));
        const q = x * x + y * (@as(Vec, @splat(0.196)) * y - @as(Vec, @splat(0.25472)) * x);
        const immediate = q < @as(Vec, @splat(0.27597));
        var all_immediate = true;
        inline for (0..8) |lane| all_immediate = all_immediate and immediate[lane];
        if (all_immediate) return v / u;
        const possible = q <= @as(Vec, @splat(0.27846));
        var any_possible = false;
        inline for (0..8) |lane| any_possible = any_possible or possible[lane];
        if (any_possible) {
            const log_limit = @as(Vec, @splat(-4.0)) * u * u * @log(u);
            const exact = v * v <= log_limit;
            var all_exact = true;
            inline for (0..8) |lane| all_exact = all_exact and (immediate[lane] or (possible[lane] and exact[lane]));
            if (all_exact) return v / u;
        }
    }
}

fn vectorRatioUniformsNormalF64(engine: *alea.ScalarPrng) @Vector(4, f64) {
    var out: @Vector(4, f64) = undefined;
    inline for (0..4) |lane| out[lane] = ratioUniformsNormalF64(engine);
    return out;
}

fn vectorRatioUniformsNormalF64DenseBlock(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const Vec = @Vector(4, f64);
    while (true) {
        const u = vectorOpenF64Local(engine);
        const v = @as(Vec, @splat(1.7156)) * (vectorF64Local(engine) - @as(Vec, @splat(0.5)));
        const x = u - @as(Vec, @splat(0.449871));
        const y = @abs(v) + @as(Vec, @splat(0.386595));
        const q = x * x + y * (@as(Vec, @splat(0.196)) * y - @as(Vec, @splat(0.25472)) * x);
        const immediate = q < @as(Vec, @splat(0.27597));
        var all_immediate = true;
        inline for (0..4) |lane| all_immediate = all_immediate and immediate[lane];
        if (all_immediate) return v / u;
        const possible = q <= @as(Vec, @splat(0.27846));
        var any_possible = false;
        inline for (0..4) |lane| any_possible = any_possible or possible[lane];
        if (any_possible) {
            const log_limit = @as(Vec, @splat(-4.0)) * u * u * @log(u);
            const exact = v * v <= log_limit;
            var all_exact = true;
            inline for (0..4) |lane| all_exact = all_exact and (immediate[lane] or (possible[lane] and exact[lane]));
            if (all_exact) return v / u;
        }
    }
}

fn ratioUniformsNormalF64(engine: *alea.ScalarPrng) f64 {
    while (true) {
        const u = alea.Rng.floatOpenFrom(engine, f64);
        const v = 1.7156 * (alea.Rng.floatFrom(engine, f64) - 0.5);
        const x = u - 0.449871;
        const y = @abs(v) + 0.386595;
        const q = x * x + y * (0.196 * y - 0.25472 * x);
        if (q < 0.27597) return v / u;
        if (q <= 0.27846 and v * v <= -4.0 * u * u * @log(u)) return v / u;
    }
}

fn vectorInverseCdfNormalF32(engine: *alea.ScalarPrng) @Vector(8, f32) {
    return @floatCast(inverseCdfNormalVec(@as(@Vector(8, f64), @floatCast(vectorOpenF32Local(engine)))));
}

fn vectorInverseCdfNormalF32Fast(engine: *alea.ScalarPrng) @Vector(8, f32) {
    return inverseCdfNormalF32Vec(vectorOpenF32Local(engine));
}

fn vectorInverseCdfNormalF32Central(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const p = vectorOpenF32Local(engine);
    const q = p - @as(@Vector(8, f32), @splat(0.5));
    var central = true;
    inline for (0..8) |lane| central = central and @abs(q[lane]) <= 0.47575;
    return if (central) inverseCdfNormalF32CentralVec(p) else inverseCdfNormalF32Vec(p);
}

fn vectorInverseCdfNormalF32TailRepair(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const p = vectorOpenF32Local(engine);
    var out = inverseCdfNormalF32CentralVec(p);
    inline for (0..8) |lane| {
        if (p[lane] < 0.02425 or p[lane] > 0.97575) out[lane] = inverseCdfNormalScalarF32(p[lane]);
    }
    return out;
}

fn vectorInverseCdfNormalF32CentralOnly(engine: *alea.ScalarPrng) @Vector(8, f32) {
    return inverseCdfNormalF32CentralVec(vectorF32Local(engine));
}

fn vectorInverseCdfNormalF64(engine: *alea.ScalarPrng) @Vector(4, f64) {
    return inverseCdfNormalVec(vectorOpenF64Local(engine));
}

fn vectorInverseCdfNormalF64Central(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const p = vectorOpenF64Local(engine);
    const q = p - @as(@Vector(4, f64), @splat(0.5));
    var central = true;
    inline for (0..4) |lane| central = central and @abs(q[lane]) <= 0.47575;
    return if (central) inverseCdfNormalCentralVec(p) else inverseCdfNormalVec(p);
}

fn vectorInverseCdfNormalF64TailRepair(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const p = vectorOpenF64Local(engine);
    var out = inverseCdfNormalCentralVec(p);
    inline for (0..4) |lane| {
        if (p[lane] < 0.02425 or p[lane] > 0.97575) out[lane] = inverseCdfNormalScalarF64(p[lane]);
    }
    return out;
}

fn inverseCdfNormalScalarF32(p: f32) f32 {
    return inverseCdfNormalF32Vec(@as(@Vector(8, f32), @splat(p)))[0];
}

fn inverseCdfNormalScalarF64(p: f64) f64 {
    return inverseCdfNormalVec(@as(@Vector(4, f64), @splat(p)))[0];
}

fn inverseCdfNormalF32CentralVec(p: @Vector(8, f32)) @Vector(8, f32) {
    const Vec = @Vector(8, f32);
    const q_mid = p - @as(Vec, @splat(0.5));
    const r = q_mid * q_mid;
    var mid_num: Vec = @splat(-3.9696831e+01);
    mid_num = mid_num * r + @as(Vec, @splat(2.2094611e+02));
    mid_num = mid_num * r + @as(Vec, @splat(-2.7592850e+02));
    mid_num = mid_num * r + @as(Vec, @splat(1.3835776e+02));
    mid_num = mid_num * r + @as(Vec, @splat(-3.0664799e+01));
    mid_num = mid_num * r + @as(Vec, @splat(2.5066283e+00));
    mid_num *= q_mid;
    var mid_den: Vec = @splat(-5.4476097e+01);
    mid_den = mid_den * r + @as(Vec, @splat(1.6158583e+02));
    mid_den = mid_den * r + @as(Vec, @splat(-1.5569897e+02));
    mid_den = mid_den * r + @as(Vec, @splat(6.6801315e+01));
    mid_den = mid_den * r + @as(Vec, @splat(-1.3280682e+01));
    mid_den = mid_den * r + @as(Vec, @splat(1.0));
    return mid_num / mid_den;
}

fn inverseCdfNormalCentralVec(p: anytype) @TypeOf(p) {
    const Vec = @TypeOf(p);
    const q_mid = p - @as(Vec, @splat(0.5));
    const r = q_mid * q_mid;
    var mid_num: Vec = @splat(-3.969683028665376e+01);
    mid_num = mid_num * r + @as(Vec, @splat(2.209460984245205e+02));
    mid_num = mid_num * r + @as(Vec, @splat(-2.759285104469687e+02));
    mid_num = mid_num * r + @as(Vec, @splat(1.383577518672690e+02));
    mid_num = mid_num * r + @as(Vec, @splat(-3.066479806614716e+01));
    mid_num = mid_num * r + @as(Vec, @splat(2.506628277459239e+00));
    mid_num *= q_mid;
    var mid_den: Vec = @splat(-5.447609879822406e+01);
    mid_den = mid_den * r + @as(Vec, @splat(1.615858368580409e+02));
    mid_den = mid_den * r + @as(Vec, @splat(-1.556989798598866e+02));
    mid_den = mid_den * r + @as(Vec, @splat(6.680131188771972e+01));
    mid_den = mid_den * r + @as(Vec, @splat(-1.328068155288572e+01));
    mid_den = mid_den * r + @as(Vec, @splat(1.0));
    return mid_num / mid_den;
}

fn inverseCdfNormalF32Vec(p: @Vector(8, f32)) @Vector(8, f32) {
    const Vec = @Vector(8, f32);
    const p_low: Vec = @splat(0.02425);
    const p_high: Vec = @splat(0.97575);

    const q_low = @sqrt(@as(Vec, @splat(-2.0)) * @log(p));
    var low_num: Vec = @splat(-7.784894e-03);
    low_num = low_num * q_low + @as(Vec, @splat(-3.2239646e-01));
    low_num = low_num * q_low + @as(Vec, @splat(-2.4007583e+00));
    low_num = low_num * q_low + @as(Vec, @splat(-2.5497325e+00));
    low_num = low_num * q_low + @as(Vec, @splat(4.3746643e+00));
    low_num = low_num * q_low + @as(Vec, @splat(2.9381640e+00));
    var low_den: Vec = @splat(7.7846957e-03);
    low_den = low_den * q_low + @as(Vec, @splat(3.2246712e-01));
    low_den = low_den * q_low + @as(Vec, @splat(2.4451342e+00));
    low_den = low_den * q_low + @as(Vec, @splat(3.7544086e+00));
    low_den = low_den * q_low + @as(Vec, @splat(1.0));
    const low = low_num / low_den;

    const q_mid = p - @as(Vec, @splat(0.5));
    const r = q_mid * q_mid;
    var mid_num: Vec = @splat(-3.9696831e+01);
    mid_num = mid_num * r + @as(Vec, @splat(2.2094611e+02));
    mid_num = mid_num * r + @as(Vec, @splat(-2.7592850e+02));
    mid_num = mid_num * r + @as(Vec, @splat(1.3835776e+02));
    mid_num = mid_num * r + @as(Vec, @splat(-3.0664799e+01));
    mid_num = mid_num * r + @as(Vec, @splat(2.5066283e+00));
    mid_num *= q_mid;
    var mid_den: Vec = @splat(-5.4476097e+01);
    mid_den = mid_den * r + @as(Vec, @splat(1.6158583e+02));
    mid_den = mid_den * r + @as(Vec, @splat(-1.5569897e+02));
    mid_den = mid_den * r + @as(Vec, @splat(6.6801315e+01));
    mid_den = mid_den * r + @as(Vec, @splat(-1.3280682e+01));
    mid_den = mid_den * r + @as(Vec, @splat(1.0));
    const mid = mid_num / mid_den;

    const q_high = @sqrt(@as(Vec, @splat(-2.0)) * @log(@as(Vec, @splat(1.0)) - p));
    var high_num: Vec = @splat(-7.784894e-03);
    high_num = high_num * q_high + @as(Vec, @splat(-3.2239646e-01));
    high_num = high_num * q_high + @as(Vec, @splat(-2.4007583e+00));
    high_num = high_num * q_high + @as(Vec, @splat(-2.5497325e+00));
    high_num = high_num * q_high + @as(Vec, @splat(4.3746643e+00));
    high_num = high_num * q_high + @as(Vec, @splat(2.9381640e+00));
    var high_den: Vec = @splat(7.7846957e-03);
    high_den = high_den * q_high + @as(Vec, @splat(3.2246712e-01));
    high_den = high_den * q_high + @as(Vec, @splat(2.4451342e+00));
    high_den = high_den * q_high + @as(Vec, @splat(3.7544086e+00));
    high_den = high_den * q_high + @as(Vec, @splat(1.0));
    const high = -(high_num / high_den);

    const low_mask = p < p_low;
    const high_mask = p > p_high;
    return @select(f32, high_mask, high, @select(f32, low_mask, low, mid));
}

fn inverseCdfNormalVec(p: anytype) @TypeOf(p) {
    const Vec = @TypeOf(p);
    const info = @typeInfo(Vec).vector;
    const T = info.child;
    const p_low: Vec = @splat(0.02425);
    const p_high: Vec = @splat(0.97575);

    const q_low = @sqrt(@as(Vec, @splat(-2.0)) * @log(p));
    var low_num: Vec = @splat(-7.784894002430293e-03);
    low_num = low_num * q_low + @as(Vec, @splat(-3.223964580411365e-01));
    low_num = low_num * q_low + @as(Vec, @splat(-2.400758277161838e+00));
    low_num = low_num * q_low + @as(Vec, @splat(-2.549732539343734e+00));
    low_num = low_num * q_low + @as(Vec, @splat(4.374664141464968e+00));
    low_num = low_num * q_low + @as(Vec, @splat(2.938163982698783e+00));
    var low_den: Vec = @splat(7.784695709041462e-03);
    low_den = low_den * q_low + @as(Vec, @splat(3.224671290700398e-01));
    low_den = low_den * q_low + @as(Vec, @splat(2.445134137142996e+00));
    low_den = low_den * q_low + @as(Vec, @splat(3.754408661907416e+00));
    low_den = low_den * q_low + @as(Vec, @splat(1.0));
    const low = low_num / low_den;

    const q_mid = p - @as(Vec, @splat(0.5));
    const r = q_mid * q_mid;
    var mid_num: Vec = @splat(-3.969683028665376e+01);
    mid_num = mid_num * r + @as(Vec, @splat(2.209460984245205e+02));
    mid_num = mid_num * r + @as(Vec, @splat(-2.759285104469687e+02));
    mid_num = mid_num * r + @as(Vec, @splat(1.383577518672690e+02));
    mid_num = mid_num * r + @as(Vec, @splat(-3.066479806614716e+01));
    mid_num = mid_num * r + @as(Vec, @splat(2.506628277459239e+00));
    mid_num *= q_mid;
    var mid_den: Vec = @splat(-5.447609879822406e+01);
    mid_den = mid_den * r + @as(Vec, @splat(1.615858368580409e+02));
    mid_den = mid_den * r + @as(Vec, @splat(-1.556989798598866e+02));
    mid_den = mid_den * r + @as(Vec, @splat(6.680131188771972e+01));
    mid_den = mid_den * r + @as(Vec, @splat(-1.328068155288572e+01));
    mid_den = mid_den * r + @as(Vec, @splat(1.0));
    const mid = mid_num / mid_den;

    const q_high = @sqrt(@as(Vec, @splat(-2.0)) * @log(@as(Vec, @splat(1.0)) - p));
    var high_num: Vec = @splat(-7.784894002430293e-03);
    high_num = high_num * q_high + @as(Vec, @splat(-3.223964580411365e-01));
    high_num = high_num * q_high + @as(Vec, @splat(-2.400758277161838e+00));
    high_num = high_num * q_high + @as(Vec, @splat(-2.549732539343734e+00));
    high_num = high_num * q_high + @as(Vec, @splat(4.374664141464968e+00));
    high_num = high_num * q_high + @as(Vec, @splat(2.938163982698783e+00));
    var high_den: Vec = @splat(7.784695709041462e-03);
    high_den = high_den * q_high + @as(Vec, @splat(3.224671290700398e-01));
    high_den = high_den * q_high + @as(Vec, @splat(2.445134137142996e+00));
    high_den = high_den * q_high + @as(Vec, @splat(3.754408661907416e+00));
    high_den = high_den * q_high + @as(Vec, @splat(1.0));
    const high = -(high_num / high_den);

    const low_mask = p < p_low;
    const high_mask = p > p_high;
    return @select(T, high_mask, high, @select(T, low_mask, low, mid));
}

fn vectorF32Local(engine: *alea.ScalarPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    var bits: u64 = 0;
    inline for (0..8) |lane| {
        if (lane % 2 == 0) bits = engine.next();
        out[lane] = if (lane % 2 == 0)
            f32FromBitsLocal(@truncate(bits >> 40))
        else
            f32FromBitsLocal(@truncate(bits >> 16));
    }
    return out;
}

fn vectorOpenF32Local(engine: *alea.ScalarPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    var bits: u64 = 0;
    inline for (0..8) |lane| {
        if (lane % 2 == 0) bits = engine.next();
        const raw: u24 = if (lane % 2 == 0)
            @truncate(bits >> 40)
        else
            @truncate(bits >> 16);
        out[lane] = (@as(f32, @floatFromInt(raw)) + 0.5) * (1.0 / 16777216.0);
    }
    return out;
}

fn vectorF64Local(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const VecU64 = @Vector(4, u64);
    var raw: VecU64 = undefined;
    inline for (0..4) |lane| raw[lane] = ((engine.next() >> 12) | (@as(u64, 0x3ff) << 52));
    return @as(@Vector(4, f64), @bitCast(raw)) - @as(@Vector(4, f64), @splat(1.0));
}

fn vectorOpenF64Local(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const VecU64 = @Vector(4, u64);
    var raw: VecU64 = undefined;
    inline for (0..4) |lane| raw[lane] = ((engine.next() >> 12) | (@as(u64, 0x3ff) << 52));
    return @as(@Vector(4, f64), @bitCast(raw)) - @as(@Vector(4, f64), @splat(1.0 - std.math.floatEps(f64) / 2.0));
}

fn f32FromBitsLocal(bits: u24) f32 {
    const repr = (@as(u32, 0x7f) << 23) | @as(u32, bits >> 1);
    return (@as(f32, @bitCast(repr)) - 1.0) + @as(f32, @floatFromInt(bits & 1)) * (1.0 / 16777216.0);
}

fn vectorRepairNormalF64SameCandidate(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const VecF64 = @Vector(4, f64);
    const VecU64 = @Vector(4, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..4) |lane| bits_vec[lane] = engine.next();

    var ratios: VecF64 = undefined;
    var out: VecF64 = undefined;
    inline for (0..4) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        ratios[lane] = norm_ratio[i];
        out[lane] = u * ziggurat.NormDist.x[i];
    }

    const reprs = (@as(VecU64, @splat(@as(u64, 0x400) << 52)) | (bits_vec >> @as(VecU64, @splat(12))));
    const u_values: VecF64 = @as(VecF64, @bitCast(reprs)) - @as(VecF64, @splat(3.0));
    const mask = @abs(u_values) < ratios;
    inline for (0..4) |lane| {
        if (!mask[lane]) out[lane] = ratioNormalWithInitial(engine, bits_vec[lane]);
    }
    return out;
}

fn vectorRepairNormalF64AllAccepted(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const VecF64 = @Vector(4, f64);
    const VecU64 = @Vector(4, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..4) |lane| bits_vec[lane] = engine.next();

    var ratios: VecF64 = undefined;
    var out: VecF64 = undefined;
    inline for (0..4) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        ratios[lane] = norm_ratio[i];
        out[lane] = u * ziggurat.NormDist.x[i];
    }

    const reprs = (@as(VecU64, @splat(@as(u64, 0x400) << 52)) | (bits_vec >> @as(VecU64, @splat(12))));
    const u_values: VecF64 = @as(VecF64, @bitCast(reprs)) - @as(VecF64, @splat(3.0));
    const mask = @abs(u_values) < ratios;
    var all_accepted = true;
    inline for (0..4) |lane| all_accepted = all_accepted and mask[lane];
    if (all_accepted) return out;
    inline for (0..4) |lane| {
        if (!mask[lane]) out[lane] = ratioNormalWithInitial(engine, bits_vec[lane]);
    }
    return out;
}

fn vectorRepairNormalF64BlockFallback(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const VecF64 = @Vector(4, f64);
    const VecU64 = @Vector(4, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..4) |lane| bits_vec[lane] = engine.next();

    var ratios: VecF64 = undefined;
    var out: VecF64 = undefined;
    inline for (0..4) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        ratios[lane] = norm_ratio[i];
        out[lane] = u * ziggurat.NormDist.x[i];
    }

    const reprs = (@as(VecU64, @splat(@as(u64, 0x400) << 52)) | (bits_vec >> @as(VecU64, @splat(12))));
    const u_values: VecF64 = @as(VecF64, @bitCast(reprs)) - @as(VecF64, @splat(3.0));
    const mask = @abs(u_values) < ratios;
    var all_accepted = true;
    inline for (0..4) |lane| all_accepted = all_accepted and mask[lane];
    return if (all_accepted) out else vectorNormalF64Local(engine);
}

fn vectorRepairNormalF64RangeBlock(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const VecU64 = @Vector(4, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..4) |lane| bits_vec[lane] = engine.next();

    var lower: VecU64 = undefined;
    var upper: VecU64 = undefined;
    var mantissas: VecU64 = undefined;
    var out: @Vector(4, f64) = undefined;
    inline for (0..4) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x400) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        lower[lane] = norm_lower_threshold[i];
        upper[lane] = norm_upper_threshold[i];
        mantissas[lane] = mantissa;
        out[lane] = u * ziggurat.NormDist.x[i];
    }

    const mask = (mantissas > lower) & (mantissas < upper);
    var all_accepted = true;
    inline for (0..4) |lane| all_accepted = all_accepted and mask[lane];
    return if (all_accepted) out else vectorNormalF64Local(engine);
}

fn vectorRepairExponentialF64SameCandidate(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const VecU64 = @Vector(4, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..4) |lane| bits_vec[lane] = engine.next();

    var thresholds: VecU64 = undefined;
    var mantissas: VecU64 = undefined;
    var out: @Vector(4, f64) = undefined;
    inline for (0..4) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
        thresholds[lane] = exp_threshold[i];
        mantissas[lane] = mantissa;
        out[lane] = u * ziggurat.ExpDist.x[i];
    }

    const mask = mantissas < thresholds;
    inline for (0..4) |lane| {
        if (!mask[lane]) out[lane] = thresholdExponentialWithInitial(engine, bits_vec[lane]);
    }
    return out;
}

fn vectorRepairExponentialF64AllAccepted(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const VecU64 = @Vector(4, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..4) |lane| bits_vec[lane] = engine.next();

    var thresholds: VecU64 = undefined;
    var mantissas: VecU64 = undefined;
    var out: @Vector(4, f64) = undefined;
    inline for (0..4) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
        thresholds[lane] = exp_threshold[i];
        mantissas[lane] = mantissa;
        out[lane] = u * ziggurat.ExpDist.x[i];
    }

    const mask = mantissas < thresholds;
    var all_accepted = true;
    inline for (0..4) |lane| all_accepted = all_accepted and mask[lane];
    if (all_accepted) return out;
    inline for (0..4) |lane| {
        if (!mask[lane]) out[lane] = thresholdExponentialWithInitial(engine, bits_vec[lane]);
    }
    return out;
}

fn vectorRepairExponentialF64BlockFallback(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const VecU64 = @Vector(4, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..4) |lane| bits_vec[lane] = engine.next();

    var thresholds: VecU64 = undefined;
    var mantissas: VecU64 = undefined;
    var out: @Vector(4, f64) = undefined;
    inline for (0..4) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
        thresholds[lane] = exp_threshold[i];
        mantissas[lane] = mantissa;
        out[lane] = u * ziggurat.ExpDist.x[i];
    }

    const mask = mantissas < thresholds;
    var all_accepted = true;
    inline for (0..4) |lane| all_accepted = all_accepted and mask[lane];
    return if (all_accepted) out else vectorExponentialF64Local(engine);
}

fn vectorMaskRedrawExponentialF64(engine: *alea.ScalarPrng) @Vector(4, f64) {
    const VecU64 = @Vector(4, u64);
    var out: @Vector(4, f64) = @splat(0);
    var filled: @Vector(4, bool) = @splat(false);
    while (true) {
        var bits_vec: VecU64 = undefined;
        inline for (0..4) |lane| bits_vec[lane] = engine.next();

        var thresholds: VecU64 = undefined;
        var mantissas: VecU64 = undefined;
        var candidate: @Vector(4, f64) = undefined;
        inline for (0..4) |lane| {
            const bits = bits_vec[lane];
            const i: usize = @as(u8, @truncate(bits));
            const mantissa = bits >> 12;
            const repr = (@as(u64, 0x3ff) << 52) | mantissa;
            const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
            thresholds[lane] = exp_threshold[i];
            mantissas[lane] = mantissa;
            candidate[lane] = u * ziggurat.ExpDist.x[i];
        }

        const fast_mask = mantissas < thresholds;
        inline for (0..4) |lane| {
            if (!filled[lane] and fast_mask[lane]) {
                out[lane] = candidate[lane];
                filled[lane] = true;
            }
        }

        var all_filled = true;
        inline for (0..4) |lane| all_filled = all_filled and filled[lane];
        if (all_filled) return out;
    }
}

fn vectorRepairNormalF32Correct(engine: *alea.ScalarPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| out[lane] = @floatCast(ratioNormal(engine));
    return out;
}

fn vectorRepairNormalF32SameCandidate(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const VecF64 = @Vector(8, f64);
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var ratios: VecF64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        ratios[lane] = norm_ratio[i];
        out[lane] = @floatCast(u * ziggurat.NormDist.x[i]);
    }

    const reprs = (@as(VecU64, @splat(@as(u64, 0x400) << 52)) | (bits_vec >> @as(VecU64, @splat(12))));
    const u_values: VecF64 = @as(VecF64, @bitCast(reprs)) - @as(VecF64, @splat(3.0));
    const mask = @abs(u_values) < ratios;
    inline for (0..8) |lane| {
        if (!mask[lane]) out[lane] = @floatCast(ratioNormalWithInitial(engine, bits_vec[lane]));
    }
    return out;
}

fn vectorRepairNormalF32AllAccepted(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const VecF64 = @Vector(8, f64);
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var ratios: VecF64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        ratios[lane] = norm_ratio[i];
        out[lane] = @floatCast(u * ziggurat.NormDist.x[i]);
    }

    const reprs = (@as(VecU64, @splat(@as(u64, 0x400) << 52)) | (bits_vec >> @as(VecU64, @splat(12))));
    const u_values: VecF64 = @as(VecF64, @bitCast(reprs)) - @as(VecF64, @splat(3.0));
    const mask = @abs(u_values) < ratios;
    var all_accepted = true;
    inline for (0..8) |lane| all_accepted = all_accepted and mask[lane];
    if (all_accepted) return out;
    inline for (0..8) |lane| {
        if (!mask[lane]) out[lane] = @floatCast(ratioNormalWithInitial(engine, bits_vec[lane]));
    }
    return out;
}

fn vectorRepairNormalF32BlockFallback(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const VecF64 = @Vector(8, f64);
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var ratios: VecF64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        ratios[lane] = norm_ratio[i];
        out[lane] = @floatCast(u * ziggurat.NormDist.x[i]);
    }

    const reprs = (@as(VecU64, @splat(@as(u64, 0x400) << 52)) | (bits_vec >> @as(VecU64, @splat(12))));
    const u_values: VecF64 = @as(VecF64, @bitCast(reprs)) - @as(VecF64, @splat(3.0));
    const mask = @abs(u_values) < ratios;
    var all_accepted = true;
    inline for (0..8) |lane| all_accepted = all_accepted and mask[lane];
    return if (all_accepted) out else vectorRepairNormalF32Correct(engine);
}

fn vectorRepairNormalF32RangeBlock(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var lower: VecU64 = undefined;
    var upper: VecU64 = undefined;
    var mantissas: VecU64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x400) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        lower[lane] = norm_lower_threshold[i];
        upper[lane] = norm_upper_threshold[i];
        mantissas[lane] = mantissa;
        out[lane] = @floatCast(u * ziggurat.NormDist.x[i]);
    }

    const mask = (mantissas > lower) & (mantissas < upper);
    var all_accepted = true;
    inline for (0..8) |lane| all_accepted = all_accepted and mask[lane];
    return if (all_accepted) out else vectorRepairNormalF32Correct(engine);
}

fn vectorRepairNativeNormalF32(engine: *alea.ScalarPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;

    inline for (0..8) |lane| {
        const bits: u32 = @truncate(engine.next());
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 9;
        const repr = (@as(u32, 0x80) << 23) | mantissa;
        const u: f32 = @as(f32, @bitCast(repr)) - 3.0;

        out[lane] = u * native_norm_x_f32[i];
        if (!(@abs(u) < native_norm_ratio_f32[i])) {
            out[lane] = nativeNormalF32WithInitial(engine, bits);
        }
    }
    return out;
}

fn vectorRepairExponentialF32Correct(engine: *alea.ScalarPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| out[lane] = @floatCast(thresholdExponential(engine));
    return out;
}

fn vectorRepairExponentialF32SameCandidate(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var thresholds: VecU64 = undefined;
    var mantissas: VecU64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
        thresholds[lane] = exp_threshold[i];
        mantissas[lane] = mantissa;
        out[lane] = @floatCast(u * ziggurat.ExpDist.x[i]);
    }

    const mask = mantissas < thresholds;
    inline for (0..8) |lane| {
        if (!mask[lane]) out[lane] = @floatCast(thresholdExponentialWithInitial(engine, bits_vec[lane]));
    }
    return out;
}

fn vectorRepairExponentialF32AllAccepted(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var thresholds: VecU64 = undefined;
    var mantissas: VecU64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
        thresholds[lane] = exp_threshold[i];
        mantissas[lane] = mantissa;
        out[lane] = @floatCast(u * ziggurat.ExpDist.x[i]);
    }

    const mask = mantissas < thresholds;
    var all_accepted = true;
    inline for (0..8) |lane| all_accepted = all_accepted and mask[lane];
    if (all_accepted) return out;
    inline for (0..8) |lane| {
        if (!mask[lane]) out[lane] = @floatCast(thresholdExponentialWithInitial(engine, bits_vec[lane]));
    }
    return out;
}

fn vectorRepairExponentialF32BlockFallback(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var thresholds: VecU64 = undefined;
    var mantissas: VecU64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
        thresholds[lane] = exp_threshold[i];
        mantissas[lane] = mantissa;
        out[lane] = @floatCast(u * ziggurat.ExpDist.x[i]);
    }

    const mask = mantissas < thresholds;
    var all_accepted = true;
    inline for (0..8) |lane| all_accepted = all_accepted and mask[lane];
    return if (all_accepted) out else vectorRepairExponentialF32Correct(engine);
}

fn vectorMaskRedrawExponentialF32(engine: *alea.ScalarPrng) @Vector(8, f32) {
    const VecU64 = @Vector(8, u64);
    var out: @Vector(8, f32) = @splat(0);
    var filled: @Vector(8, bool) = @splat(false);
    while (true) {
        var bits_vec: VecU64 = undefined;
        inline for (0..8) |lane| bits_vec[lane] = engine.next();

        var thresholds: VecU64 = undefined;
        var mantissas: VecU64 = undefined;
        var candidate: @Vector(8, f32) = undefined;
        inline for (0..8) |lane| {
            const bits = bits_vec[lane];
            const i: usize = @as(u8, @truncate(bits));
            const mantissa = bits >> 12;
            const repr = (@as(u64, 0x3ff) << 52) | mantissa;
            const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
            thresholds[lane] = exp_threshold[i];
            mantissas[lane] = mantissa;
            candidate[lane] = @floatCast(u * ziggurat.ExpDist.x[i]);
        }

        const fast_mask = mantissas < thresholds;
        inline for (0..8) |lane| {
            if (!filled[lane] and fast_mask[lane]) {
                out[lane] = candidate[lane];
                filled[lane] = true;
            }
        }

        var all_filled = true;
        inline for (0..8) |lane| all_filled = all_filled and filled[lane];
        if (all_filled) return out;
    }
}

fn vectorRepairNativeExponentialF32(engine: *alea.ScalarPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;

    inline for (0..8) |lane| {
        const bits: u32 = @truncate(engine.next());
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 9;
        const repr = (@as(u32, 0x7f) << 23) | mantissa;
        const u: f32 = @as(f32, @bitCast(repr)) - (1.0 - std.math.floatEps(f32) / 2.0);

        out[lane] = u * native_exp_x_f32[i];
        if (!(mantissa < native_exp_threshold_f32[i])) {
            out[lane] = nativeExponentialF32WithInitial(engine, bits);
        }
    }
    return out;
}

fn vectorRepairNormalF32FastCorrect(engine: *alea.FastPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| out[lane] = @floatCast(ratioNormalFast(engine));
    return out;
}

fn vectorRepairNormalF32FastSameCandidate(engine: *alea.FastPrng) @Vector(8, f32) {
    const VecF64 = @Vector(8, f64);
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var ratios: VecF64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        ratios[lane] = norm_ratio[i];
        out[lane] = @floatCast(u * ziggurat.NormDist.x[i]);
    }

    const reprs = (@as(VecU64, @splat(@as(u64, 0x400) << 52)) | (bits_vec >> @as(VecU64, @splat(12))));
    const u_values: VecF64 = @as(VecF64, @bitCast(reprs)) - @as(VecF64, @splat(3.0));
    const mask = @abs(u_values) < ratios;
    inline for (0..8) |lane| {
        if (!mask[lane]) out[lane] = @floatCast(ratioNormalFastWithInitial(engine, bits_vec[lane]));
    }
    return out;
}

fn vectorRepairNormalF32FastAllAccepted(engine: *alea.FastPrng) @Vector(8, f32) {
    const VecF64 = @Vector(8, f64);
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var ratios: VecF64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        ratios[lane] = norm_ratio[i];
        out[lane] = @floatCast(u * ziggurat.NormDist.x[i]);
    }

    const reprs = (@as(VecU64, @splat(@as(u64, 0x400) << 52)) | (bits_vec >> @as(VecU64, @splat(12))));
    const u_values: VecF64 = @as(VecF64, @bitCast(reprs)) - @as(VecF64, @splat(3.0));
    const mask = @abs(u_values) < ratios;
    var all_accepted = true;
    inline for (0..8) |lane| all_accepted = all_accepted and mask[lane];
    if (all_accepted) return out;
    inline for (0..8) |lane| {
        if (!mask[lane]) out[lane] = @floatCast(ratioNormalFastWithInitial(engine, bits_vec[lane]));
    }
    return out;
}

fn vectorRepairNormalF32FastBlockFallback(engine: *alea.FastPrng) @Vector(8, f32) {
    const VecF64 = @Vector(8, f64);
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var ratios: VecF64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
        ratios[lane] = norm_ratio[i];
        out[lane] = @floatCast(u * ziggurat.NormDist.x[i]);
    }

    const reprs = (@as(VecU64, @splat(@as(u64, 0x400) << 52)) | (bits_vec >> @as(VecU64, @splat(12))));
    const u_values: VecF64 = @as(VecF64, @bitCast(reprs)) - @as(VecF64, @splat(3.0));
    const mask = @abs(u_values) < ratios;
    var all_accepted = true;
    inline for (0..8) |lane| all_accepted = all_accepted and mask[lane];
    return if (all_accepted) out else vectorRepairNormalF32FastCorrect(engine);
}

fn vectorRepairExponentialF32FastCorrect(engine: *alea.FastPrng) @Vector(8, f32) {
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| out[lane] = @floatCast(thresholdExponentialFast(engine));
    return out;
}

fn vectorRepairExponentialF32FastBlockFallback(engine: *alea.FastPrng) @Vector(8, f32) {
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var thresholds: VecU64 = undefined;
    var mantissas: VecU64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
        thresholds[lane] = exp_threshold[i];
        mantissas[lane] = mantissa;
        out[lane] = @floatCast(u * ziggurat.ExpDist.x[i]);
    }

    const mask = mantissas < thresholds;
    var all_accepted = true;
    inline for (0..8) |lane| all_accepted = all_accepted and mask[lane];
    return if (all_accepted) out else vectorRepairExponentialF32FastCorrect(engine);
}

fn vectorRepairExponentialF32FastSameCandidate(engine: *alea.FastPrng) @Vector(8, f32) {
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var thresholds: VecU64 = undefined;
    var mantissas: VecU64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
        thresholds[lane] = exp_threshold[i];
        mantissas[lane] = mantissa;
        out[lane] = @floatCast(u * ziggurat.ExpDist.x[i]);
    }

    const mask = mantissas < thresholds;
    inline for (0..8) |lane| {
        if (!mask[lane]) out[lane] = @floatCast(thresholdExponentialFastWithInitial(engine, bits_vec[lane]));
    }
    return out;
}

fn vectorRepairExponentialF32FastAllAccepted(engine: *alea.FastPrng) @Vector(8, f32) {
    const VecU64 = @Vector(8, u64);

    var bits_vec: VecU64 = undefined;
    inline for (0..8) |lane| bits_vec[lane] = engine.next();

    var thresholds: VecU64 = undefined;
    var mantissas: VecU64 = undefined;
    var out: @Vector(8, f32) = undefined;
    inline for (0..8) |lane| {
        const bits = bits_vec[lane];
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
        thresholds[lane] = exp_threshold[i];
        mantissas[lane] = mantissa;
        out[lane] = @floatCast(u * ziggurat.ExpDist.x[i]);
    }

    const mask = mantissas < thresholds;
    var all_accepted = true;
    inline for (0..8) |lane| all_accepted = all_accepted and mask[lane];
    if (all_accepted) return out;
    inline for (0..8) |lane| {
        if (!mask[lane]) out[lane] = @floatCast(thresholdExponentialFastWithInitial(engine, bits_vec[lane]));
    }
    return out;
}

fn ratioNormal(engine: *alea.ScalarPrng) f64 {
    return ratioNormalWithInitial(engine, engine.next());
}

fn ratioNormalWithInitial(engine: *alea.ScalarPrng, initial_bits: u64) f64 {
    var bits = initial_bits;
    while (true) {
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;

        if (@abs(u) < norm_ratio[i]) {
            @branchHint(.likely);
            return u * ziggurat.NormDist.x[i];
        }
        const x = u * ziggurat.NormDist.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return normalTail(engine, u);
        }
        if (ziggurat.NormDist.f[i + 1] + (ziggurat.NormDist.f[i] - ziggurat.NormDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x * x / 2.0)) return x;
        bits = engine.next();
    }
}

fn normalTail(engine: *alea.ScalarPrng, u: f64) f64 {
    var x: f64 = 1;
    var y: f64 = 0;
    while (-2.0 * y < x * x) {
        x = @log(alea.Rng.floatOpenFrom(engine, f64)) / ziggurat.norm_r;
        y = @log(alea.Rng.floatOpenFrom(engine, f64));
    }
    return if (u < 0) x - ziggurat.norm_r else ziggurat.norm_r - x;
}

fn nativeNormalF32WithInitial(engine: *alea.ScalarPrng, initial_bits: u32) f32 {
    var bits = initial_bits;
    while (true) {
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 9;
        const repr = (@as(u32, 0x80) << 23) | mantissa;
        const u: f32 = @as(f32, @bitCast(repr)) - 3.0;

        if (@abs(u) < native_norm_ratio_f32[i]) {
            @branchHint(.likely);
            return u * native_norm_x_f32[i];
        }
        const x = u * native_norm_x_f32[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return nativeNormalF32Tail(engine, u);
        }
        if (native_norm_f_f32[i + 1] + (native_norm_f_f32[i] - native_norm_f_f32[i + 1]) * alea.Rng.floatFrom(engine, f32) < @exp(-x * x / 2.0)) return x;
        bits = @truncate(engine.next());
    }
}

fn nativeNormalF32Tail(engine: *alea.ScalarPrng, u: f32) f32 {
    var x: f32 = 1;
    var y: f32 = 0;
    while (-2.0 * y < x * x) {
        x = @log(alea.Rng.floatOpenFrom(engine, f32)) / native_norm_r_f32;
        y = @log(alea.Rng.floatOpenFrom(engine, f32));
    }
    return if (u < 0) x - native_norm_r_f32 else native_norm_r_f32 - x;
}

fn thresholdExponential(engine: *alea.ScalarPrng) f64 {
    return thresholdExponentialWithInitial(engine, engine.next());
}

fn thresholdExponentialWithInitial(engine: *alea.ScalarPrng, initial_bits: u64) f64 {
    var bits = initial_bits;
    while (true) {
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);

        if (mantissa < exp_threshold[i]) {
            @branchHint(.likely);
            return u * ziggurat.ExpDist.x[i];
        }
        const x = u * ziggurat.ExpDist.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return ziggurat.exp_r - @log(alea.Rng.floatOpenFrom(engine, f64));
        }
        if (ziggurat.ExpDist.f[i + 1] + (ziggurat.ExpDist.f[i] - ziggurat.ExpDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x)) return x;
        bits = engine.next();
    }
}

fn nativeExponentialF32WithInitial(engine: *alea.ScalarPrng, initial_bits: u32) f32 {
    var bits = initial_bits;
    while (true) {
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 9;
        const repr = (@as(u32, 0x7f) << 23) | mantissa;
        const u: f32 = @as(f32, @bitCast(repr)) - (1.0 - std.math.floatEps(f32) / 2.0);

        if (mantissa < native_exp_threshold_f32[i]) {
            @branchHint(.likely);
            return u * native_exp_x_f32[i];
        }
        const x = u * native_exp_x_f32[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return native_exp_r_f32 - @log(alea.Rng.floatOpenFrom(engine, f32));
        }
        if (native_exp_f_f32[i + 1] + (native_exp_f_f32[i] - native_exp_f_f32[i + 1]) * alea.Rng.floatFrom(engine, f32) < @exp(-x)) return x;
        bits = @truncate(engine.next());
    }
}

fn ratioNormalFast(engine: *alea.FastPrng) f64 {
    return ratioNormalFastWithInitial(engine, engine.next());
}

fn ratioNormalFastWithInitial(engine: *alea.FastPrng, initial_bits: u64) f64 {
    var bits = initial_bits;
    while (true) {
        const i: usize = @as(u8, @truncate(bits));
        const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
        const u: f64 = @as(f64, @bitCast(repr)) - 3.0;

        if (@abs(u) < norm_ratio[i]) {
            @branchHint(.likely);
            return u * ziggurat.NormDist.x[i];
        }
        const x = u * ziggurat.NormDist.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return normalTailFast(engine, u);
        }
        if (ziggurat.NormDist.f[i + 1] + (ziggurat.NormDist.f[i] - ziggurat.NormDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x * x / 2.0)) return x;
        bits = engine.next();
    }
}

fn normalTailFast(engine: *alea.FastPrng, u: f64) f64 {
    var x: f64 = 1;
    var y: f64 = 0;
    while (-2.0 * y < x * x) {
        x = @log(alea.Rng.floatOpenFrom(engine, f64)) / ziggurat.norm_r;
        y = @log(alea.Rng.floatOpenFrom(engine, f64));
    }
    return if (u < 0) x - ziggurat.norm_r else ziggurat.norm_r - x;
}

fn thresholdExponentialFast(engine: *alea.FastPrng) f64 {
    return thresholdExponentialFastWithInitial(engine, engine.next());
}

fn thresholdExponentialFastWithInitial(engine: *alea.FastPrng, initial_bits: u64) f64 {
    var bits = initial_bits;
    while (true) {
        const i: usize = @as(u8, @truncate(bits));
        const mantissa = bits >> 12;
        const repr = (@as(u64, 0x3ff) << 52) | mantissa;
        const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);

        if (mantissa < exp_threshold[i]) {
            @branchHint(.likely);
            return u * ziggurat.ExpDist.x[i];
        }
        const x = u * ziggurat.ExpDist.x[i];
        if (i == 0) {
            @branchHint(.unlikely);
            return ziggurat.exp_r - @log(alea.Rng.floatOpenFrom(engine, f64));
        }
        if (ziggurat.ExpDist.f[i + 1] + (ziggurat.ExpDist.f[i] - ziggurat.ExpDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x)) return x;
        bits = engine.next();
    }
}
