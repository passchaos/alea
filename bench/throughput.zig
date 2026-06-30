const std = @import("std");
const alea = @import("alea");

const MiB = 1024 * 1024;
const trials = 3;

var bench_filter: ?[]const u8 = null;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var args = std.process.Args.Iterator.init(init.minimal.args);
    defer args.deinit();
    _ = args.next();
    var bytes: usize = 128 * MiB;
    if (args.next()) |arg| {
        bytes = std.fmt.parseInt(usize, arg, 10) catch blk: {
            bench_filter = arg;
            break :blk bytes;
        };
    }
    if (args.next()) |arg| bench_filter = arg;
    var buffer: [4096]u8 = undefined;

    try stdout.print("byte throughput\n", .{});
    try benchEngine(io, stdout, "alea4x64", alea.Alea4x64, bytes, &buffer);
    try benchEngine(io, stdout, "xoshiro256++", alea.Xoshiro256PlusPlus, bytes, &buffer);
    try benchEngine(io, stdout, "wyhash64", alea.Wyhash64, bytes, &buffer);
    try benchEngine(io, stdout, "xoshiro256**", alea.Xoshiro256, bytes, &buffer);
    try benchEngine(io, stdout, "pcg64", alea.Pcg64, bytes, &buffer);
    try benchEngine(io, stdout, "chacha12", alea.ChaCha, bytes, &buffer);
    try stdout.print("\nscalar next throughput\n", .{});
    try benchNext(io, stdout, "splitmix64 next", alea.SplitMix64, bytes / 8);
    try benchNext(io, stdout, "alea4x64 next", alea.Alea4x64, bytes / 8);
    try benchNext(io, stdout, "wyhash64 next", alea.Wyhash64, bytes / 8);
    try benchNext(io, stdout, "xoshiro256** next", alea.Xoshiro256, bytes / 8);
    try benchNext(io, stdout, "xoshiro256++ next", alea.Xoshiro256PlusPlus, bytes / 8);
    try benchNext(io, stdout, "pcg64 next", alea.Pcg64, bytes / 8);
    try stdout.print("\nfill-only throughput\n", .{});
    try benchFillOnly(io, stdout, "alea4x64 fill-only", alea.Alea4x64, bytes, &buffer);
    try benchFillOnly(io, stdout, "xoshiro256++ fill-only", alea.Xoshiro256PlusPlus, bytes, &buffer);
    try benchFillTypedU32(io, stdout, "alea fill u32 facade", bytes / 4);
    try benchFillTypedBool(io, stdout, "alea fill bool facade", bytes / 8);
    try benchFillChance(io, stdout, "alea fillChance p=0.25", bytes / 8);
    try benchFillChanceHalf(io, stdout, "alea fillChance p=0.5", bytes / 8);
    try benchFillRatioQuarter(io, stdout, "alea fillRatio 1/4", bytes / 8);
    try benchFillRatioThreeEighths(io, stdout, "alea fillRatio 3/8", bytes / 8);
    try benchFillRatioHalf(io, stdout, "alea fillRatio 1/2", bytes / 8);
    try benchFillTypedF32(io, stdout, "alea fill f32 facade", bytes / 4);
    try benchFillOpenF32(io, stdout, "alea fillOpen f32", bytes / 4);
    try benchFillOpenClosedF32(io, stdout, "alea fillOpenClosed f32", bytes / 4);
    try benchFillTypedF64(io, stdout, "alea fill f64 facade", bytes / 8);
    try benchFillTypedF64Direct(io, stdout, "alea fill f64 direct", bytes / 8);
    try benchFillOpenF64(io, stdout, "alea fillOpen f64", bytes / 8);
    try benchFillOpenClosedF64(io, stdout, "alea fillOpenClosed f64", bytes / 8);
    try stdout.print("\nrange throughput\n", .{});
    try benchRangeFacade(io, stdout, "alea bounded u32 facade", bytes / 8);
    try benchRangeDirect(io, stdout, "alea bounded u32 direct", bytes / 8);
    try benchFloatF32(io, stdout, "alea float f32 facade", bytes / 4);
    try benchFloatF32Direct(io, stdout, "alea float f32 direct", bytes / 4);
    try benchFloatOpenF32(io, stdout, "alea floatOpen f32 facade", bytes / 4);
    try benchFloatOpenF32Direct(io, stdout, "alea floatOpen f32 direct", bytes / 4);
    try benchFloatOpenClosedF32(io, stdout, "alea floatOpenClosed f32 facade", bytes / 4);
    try benchFloatOpenClosedF32Direct(io, stdout, "alea floatOpenClosed f32 direct", bytes / 4);
    try benchFloatRangeF32(io, stdout, "alea floatRange f32 facade", bytes / 4);
    try benchFloatRangeF32Direct(io, stdout, "alea floatRange f32 direct", bytes / 4);
    try benchFloatF64(io, stdout, "alea float f64 facade", bytes / 8);
    try benchFloatF64Direct(io, stdout, "alea float f64 direct", bytes / 8);
    try benchFloatOpenF64(io, stdout, "alea floatOpen f64 facade", bytes / 8);
    try benchFloatOpenF64Direct(io, stdout, "alea floatOpen f64 direct", bytes / 8);
    try benchFloatOpenClosedF64(io, stdout, "alea floatOpenClosed f64 facade", bytes / 8);
    try benchFloatOpenClosedF64Direct(io, stdout, "alea floatOpenClosed f64 direct", bytes / 8);
    try benchFloatRangeF64(io, stdout, "alea floatRange f64 facade", bytes / 8);
    try benchFloatRangeF64Direct(io, stdout, "alea floatRange f64 direct", bytes / 8);
    try benchUniformFillF64Direct(io, stdout, "alea Uniform(f64).fillFrom direct", bytes / 8);
    try benchVectorBool(io, stdout, "alea vector boolx64 facade", bytes / 8);
    try benchVectorChance(io, stdout, "alea vector chance boolx64 p=0.25", bytes / 8);
    try benchVectorChanceHalf(io, stdout, "alea vector chance boolx64 p=0.5", bytes / 8);
    try benchVectorRatioQuarter(io, stdout, "alea vector ratio boolx64 1/4", bytes / 8);
    try benchVectorRatioThreeEighths(io, stdout, "alea vector ratio boolx64 3/8", bytes / 8);
    try benchVectorRatioHalf(io, stdout, "alea vector ratio boolx64 1/2", bytes / 8);
    try benchVectorInt(io, stdout, "alea vector u16x16 facade", bytes / 8);
    try benchVectorIntDirect(io, stdout, "alea vector u16x16 direct", bytes / 8);
    try benchVectorRange(io, stdout, "alea vector bounded i32x8 facade", bytes / 8);
    try benchVectorRangeDirect(io, stdout, "alea vector bounded i32x8 direct", bytes / 8);
    try benchVectorFloat(io, stdout, "alea vector f32x8 facade", bytes / 8);
    try benchFillRange(io, stdout, "alea fillRange i32", bytes / 8);
    try benchFillRangeF32(io, stdout, "alea fillRange f32", bytes / 4);
    try benchFillRangeF64(io, stdout, "alea fillRange f64", bytes / 8);
    try benchFillRangeF64Direct(io, stdout, "alea fillRange f64 direct", bytes / 8);
    try stdout.print("\nstring throughput\n", .{});
    try benchAlphanumeric(io, stdout, "alea alphanumeric", bytes / 8);
    try stdout.print("\nsequence throughput\n", .{});
    try benchSeqFacade(io, stdout, "alea sample indices facade", 1_000_000, 10_000);
    try benchSeqDirect(io, stdout, "alea sample indices direct", 1_000_000, 10_000);
    try benchSeqIndexVecFacade(io, stdout, "alea sample index vec facade", 1_000_000, 10_000);
    try benchSeqIndexVecDirect(io, stdout, "alea sample index vec direct", 1_000_000, 10_000);
    try benchSeqU32Facade(io, stdout, "alea sample indices u32 facade", 1_000_000, 10_000);
    try benchSeqU32Direct(io, stdout, "alea sample indices u32 direct", 1_000_000, 10_000);
    try stdout.print("\ndistribution throughput\n", .{});
    try benchBernoulli(io, stdout, "alea bernoulli", bytes / 64);
    try benchFillBernoulli(io, stdout, "alea fillBernoulli p=0.25", bytes / 8);
    try benchAliasTable(io, stdout, "alea alias table", bytes / 256);
    try benchAliasTableDirect(io, stdout, "alea alias table direct", bytes / 256);
    try benchAliasTableFillDirect(io, stdout, "alea alias table fill direct", bytes / 256);
    try benchWeightedChoice(io, stdout, "alea weighted choice", bytes / 256);
    try benchWeightedChoiceDirect(io, stdout, "alea weighted choice direct", bytes / 256);
    try benchWeightedChoiceFillDirect(io, stdout, "alea weighted choice fill direct", bytes / 256);
    try benchWeightedTree(io, stdout, "alea weighted tree update+sample", bytes / 256);
    try benchWeightedTreeDirect(io, stdout, "alea weighted tree direct update+sample", bytes / 256);
    try benchWeightedTreeFillDirect(io, stdout, "alea weighted tree fill direct", bytes / 256);
    try benchWeightedIntTree(io, stdout, "alea weighted int tree update+sample", bytes / 256);
    try benchWeightedIntTreeDirect(io, stdout, "alea weighted int tree direct update+sample", bytes / 256);
    try benchWeightedIntTreeFillDirect(io, stdout, "alea weighted int tree fill direct", bytes / 256);
    try benchNormal(io, stdout, "alea normal", bytes / 64);
    try benchNormalSplitMix(io, stdout, "alea normal splitmix64 direct", bytes / 64);
    try benchNormalWyhash(io, stdout, "alea normal wyhash64 direct", bytes / 64);
    try benchNormalWyhashStdRandom(io, stdout, "alea normal wyhash64 std.Random", bytes / 64);
    try benchNormalStdRandom(io, stdout, "alea normal std.Random direct", bytes / 64);
    try benchNormalFast(io, stdout, "alea normal fast direct", bytes / 64);
    try benchStandardNormalScalar(io, stdout, "alea standard-normal scalar direct", bytes / 64);
    try benchStandardNormalRawScalar(io, stdout, "alea standard-normal raw scalar direct", bytes / 64);
    try benchStandardNormalScalarF32(io, stdout, "alea standard-normal f32 scalar direct", bytes / 64);
    try benchVectorNormalF32(io, stdout, "alea vector normal f32x8", bytes / 64);
    try benchFillStandardNormal(io, stdout, "alea fillStandardNormal", bytes / 64);
    try benchFillStandardNormalScalar(io, stdout, "alea fillStandardNormal scalar direct", bytes / 64);
    try benchFillStandardNormalF32(io, stdout, "alea fillStandardNormal f32", bytes / 64);
    try benchFillStandardNormalF32Scalar(io, stdout, "alea fillStandardNormal f32 scalar direct", bytes / 64);
    try benchFillNormal(io, stdout, "alea fillNormal", bytes / 64);
    try benchFillNormalScalar(io, stdout, "alea fillNormal scalar direct", bytes / 64);
    try benchNormalSamplerFillScalar(io, stdout, "alea Normal.fillFrom scalar direct", bytes / 64);
    try benchFillNormalF32(io, stdout, "alea fillNormal f32", bytes / 64);
    try benchExponential(io, stdout, "alea exponential", bytes / 64);
    try benchExponentialWyhash(io, stdout, "alea exponential wyhash64 direct", bytes / 64);
    try benchExponentialFast(io, stdout, "alea exponential fast direct", bytes / 64);
    try benchStandardExponentialScalar(io, stdout, "alea standard-exponential scalar direct", bytes / 64);
    try benchStandardExponentialRawScalar(io, stdout, "alea standard-exponential raw scalar direct", bytes / 64);
    try benchStandardExponentialScalarF32(io, stdout, "alea standard-exponential f32 scalar direct", bytes / 64);
    try benchVectorExponentialF32(io, stdout, "alea vector exponential f32x8", bytes / 64);
    try benchFillStandardExponential(io, stdout, "alea fillStandardExponential", bytes / 64);
    try benchFillStandardExponentialScalar(io, stdout, "alea fillStandardExponential scalar direct", bytes / 64);
    try benchFillStandardExponentialF32(io, stdout, "alea fillStandardExponential f32", bytes / 64);
    try benchFillStandardExponentialF32Scalar(io, stdout, "alea fillStandardExponential f32 scalar direct", bytes / 64);
    try benchFillExponential(io, stdout, "alea fillExponential", bytes / 64);
    try benchFillExponentialScalar(io, stdout, "alea fillExponential scalar direct", bytes / 64);
    try benchExponentialSamplerFillScalar(io, stdout, "alea Exponential.fillFrom scalar direct", bytes / 64);
    try benchFillExponentialF32(io, stdout, "alea fillExponential f32", bytes / 64);
    try benchPoisson(io, stdout, "alea poisson", bytes / 64);
    try benchPoissonFastDirect(io, stdout, "alea poisson fast direct", bytes / 64);
    try benchPoissonWyhash(io, stdout, "alea poisson wyhash64 direct", bytes / 64);
    try benchPoissonCached(io, stdout, "alea poisson cached", bytes / 64);
    try benchFillPoisson(io, stdout, "alea fillPoisson", bytes / 64);
    try benchFillPoissonFastDirect(io, stdout, "alea fillPoisson fast direct", bytes / 64);
    try benchFillPoissonScalar(io, stdout, "alea fillPoisson scalar direct", bytes / 64);
    try benchGeometric(io, stdout, "alea geometric", bytes / 64);
    try benchFillGeometric(io, stdout, "alea fillGeometric", bytes / 64);
    try benchFillGeometricScalar(io, stdout, "alea fillGeometric scalar direct", bytes / 64);
    try benchGeometricFailures(io, stdout, "alea geometric failures", bytes / 64);
    try benchFillGeometricFailures(io, stdout, "alea fillGeometricFailures", bytes / 64);
    try benchFillGeometricFailuresScalar(io, stdout, "alea fillGeometricFailures scalar direct", bytes / 64);
    try benchStandardGeometric(io, stdout, "alea standard-geometric", bytes / 64);
    try benchStandardGeometricScalar(io, stdout, "alea standard-geometric scalar direct", bytes / 64);
    try benchFillStandardGeometric(io, stdout, "alea fillStandardGeometric", bytes / 64);
    try benchFillStandardGeometricScalar(io, stdout, "alea fillStandardGeometric scalar direct", bytes / 64);
    try benchBinomial(io, stdout, "alea binomial", bytes / 64);
    try benchFillBinomial(io, stdout, "alea fillBinomial", bytes / 64);
    try benchFillBinomialScalar(io, stdout, "alea fillBinomial scalar direct", bytes / 64);
    try benchBinomialLarge(io, stdout, "alea binomial large", bytes / 256);
    try benchBinomialApprox(io, stdout, "alea binomial poisson approx", bytes / 256);
    try benchNegativeBinomial(io, stdout, "alea negative-binomial", bytes / 128);
    try benchFillNegativeBinomial(io, stdout, "alea fillNegativeBinomial", bytes / 128);
    try benchFillNegativeBinomialScalar(io, stdout, "alea fillNegativeBinomial scalar direct", bytes / 128);
    try benchHypergeometric(io, stdout, "alea hypergeometric", bytes / 128);
    try benchFillHypergeometric(io, stdout, "alea fillHypergeometric", bytes / 128);
    try benchFillHypergeometricScalar(io, stdout, "alea fillHypergeometric scalar direct", bytes / 128);
    try benchHypergeometricLarge(io, stdout, "alea hypergeometric large", bytes / 256);
    try benchFillHypergeometricLarge(io, stdout, "alea fillHypergeometric large", bytes / 256);
    try benchFillHypergeometricLargeScalar(io, stdout, "alea fillHypergeometric large scalar direct", bytes / 256);
    try benchMultinomial(io, stdout, "alea multinomial", bytes / 512);
    try benchMultinomialDirect(io, stdout, "alea multinomial direct", bytes / 512);
    try benchMultinomialManyDirect(io, stdout, "alea multinomial many direct", bytes / 512);
    try benchGamma(io, stdout, "alea gamma", bytes / 128);
    try benchGammaScalar(io, stdout, "alea gamma scalar direct", bytes / 128);
    try benchFillGamma(io, stdout, "alea fillGamma", bytes / 128);
    try benchFillGammaScalar(io, stdout, "alea fillGamma scalar direct", bytes / 128);
    try benchFillSampleGamma(io, stdout, "alea fillSample gamma", bytes / 128);
    try benchFillSampleGammaScalar(io, stdout, "alea fillSampleFrom gamma scalar", bytes / 128);
    try benchChiSquared(io, stdout, "alea chi-squared", bytes / 128);
    try benchChiSquaredCached(io, stdout, "alea chi-squared cached", bytes / 128);
    try benchFillChiSquared(io, stdout, "alea fillChiSquared", bytes / 128);
    try benchFillChiSquaredScalar(io, stdout, "alea fillChiSquared scalar direct", bytes / 128);
    try benchChi(io, stdout, "alea chi", bytes / 128);
    try benchFillChi(io, stdout, "alea fillChi", bytes / 128);
    try benchFillChiScalar(io, stdout, "alea fillChi scalar direct", bytes / 128);
    try benchErlang(io, stdout, "alea erlang", bytes / 128);
    try benchFillErlang(io, stdout, "alea fillErlang", bytes / 128);
    try benchFillErlangScalar(io, stdout, "alea fillErlang scalar direct", bytes / 128);
    try benchBeta(io, stdout, "alea beta", bytes / 128);
    try benchBetaCached(io, stdout, "alea beta cached", bytes / 128);
    try benchFillBeta(io, stdout, "alea fillBeta", bytes / 128);
    try benchFillBetaScalar(io, stdout, "alea fillBeta scalar direct", bytes / 128);
    try benchFisherF(io, stdout, "alea fisher-f", bytes / 128);
    try benchFisherFDirect(io, stdout, "alea fisher-f direct", bytes / 128);
    try benchFisherFCached(io, stdout, "alea fisher-f cached", bytes / 128);
    try benchFillFisherF(io, stdout, "alea fillFisherF", bytes / 128);
    try benchFillFisherFScalar(io, stdout, "alea fillFisherF scalar direct", bytes / 128);
    try benchTriangular(io, stdout, "alea triangular", bytes / 128);
    try benchTriangularDirect(io, stdout, "alea triangular direct", bytes / 128);
    try benchFillTriangular(io, stdout, "alea fillTriangular", bytes / 128);
    try benchFillTriangularScalar(io, stdout, "alea fillTriangular scalar direct", bytes / 128);
    try benchArcsine(io, stdout, "alea arcsine", bytes / 128);
    try benchFillArcsine(io, stdout, "alea fillArcsine", bytes / 128);
    try benchFillArcsineScalar(io, stdout, "alea fillArcsine scalar direct", bytes / 128);
    try benchCauchy(io, stdout, "alea cauchy", bytes / 128);
    try benchCauchyFastDirect(io, stdout, "alea cauchy fast direct", bytes / 128);
    try benchCauchyScalar(io, stdout, "alea cauchy scalar direct", bytes / 128);
    try benchFillCauchy(io, stdout, "alea fillCauchy", bytes / 128);
    try benchFillCauchyScalar(io, stdout, "alea fillCauchy scalar direct", bytes / 128);
    try benchLaplace(io, stdout, "alea laplace", bytes / 128);
    try benchFillLaplace(io, stdout, "alea fillLaplace", bytes / 128);
    try benchFillLaplaceScalar(io, stdout, "alea fillLaplace scalar direct", bytes / 128);
    try benchLogistic(io, stdout, "alea logistic", bytes / 128);
    try benchFillLogistic(io, stdout, "alea fillLogistic", bytes / 128);
    try benchFillLogisticScalar(io, stdout, "alea fillLogistic scalar direct", bytes / 128);
    try benchLogLogistic(io, stdout, "alea log-logistic", bytes / 128);
    try benchFillLogLogistic(io, stdout, "alea fillLogLogistic", bytes / 128);
    try benchFillLogLogisticScalar(io, stdout, "alea fillLogLogistic scalar direct", bytes / 128);
    try benchKumaraswamy(io, stdout, "alea kumaraswamy", bytes / 128);
    try benchFillKumaraswamy(io, stdout, "alea fillKumaraswamy", bytes / 128);
    try benchFillKumaraswamyScalar(io, stdout, "alea fillKumaraswamy scalar direct", bytes / 128);
    try benchPowerFunction(io, stdout, "alea power-function", bytes / 128);
    try benchFillPowerFunction(io, stdout, "alea fillPowerFunction", bytes / 128);
    try benchFillPowerFunctionScalar(io, stdout, "alea fillPowerFunction scalar direct", bytes / 128);
    try benchRayleigh(io, stdout, "alea rayleigh", bytes / 128);
    try benchFillRayleigh(io, stdout, "alea fillRayleigh", bytes / 128);
    try benchFillRayleighScalar(io, stdout, "alea fillRayleigh scalar direct", bytes / 128);
    try benchMaxwell(io, stdout, "alea maxwell", bytes / 128);
    try benchFillMaxwell(io, stdout, "alea fillMaxwell", bytes / 128);
    try benchFillMaxwellScalar(io, stdout, "alea fillMaxwell scalar direct", bytes / 128);
    try benchDirichlet(io, stdout, "alea dirichlet", bytes / 512);
    try benchDirichletDirect(io, stdout, "alea dirichlet direct", bytes / 512);
    try benchDirichletManyDirect(io, stdout, "alea dirichlet many direct", bytes / 512);
    try benchLogNormal(io, stdout, "alea log-normal", bytes / 128);
    try benchLogNormalFastDirect(io, stdout, "alea log-normal fast direct", bytes / 128);
    try benchLogNormalScalar(io, stdout, "alea log-normal scalar direct", bytes / 128);
    try benchFillLogNormal(io, stdout, "alea fillLogNormal", bytes / 128);
    try benchFillLogNormalFastDirect(io, stdout, "alea fillLogNormal fast direct", bytes / 128);
    try benchFillLogNormalScalar(io, stdout, "alea fillLogNormal scalar direct", bytes / 128);
    try benchHalfNormal(io, stdout, "alea half-normal", bytes / 128);
    try benchFillHalfNormal(io, stdout, "alea fillHalfNormal", bytes / 128);
    try benchFillHalfNormalScalar(io, stdout, "alea fillHalfNormal scalar direct", bytes / 128);
    try benchStudentT(io, stdout, "alea student-t", bytes / 128);
    try benchStudentTDirect(io, stdout, "alea student-t direct", bytes / 128);
    try benchStudentTCached(io, stdout, "alea student-t cached", bytes / 128);
    try benchFillStudentT(io, stdout, "alea fillStudentT", bytes / 128);
    try benchFillStudentTScalar(io, stdout, "alea fillStudentT scalar direct", bytes / 128);
    try benchPareto(io, stdout, "alea pareto", bytes / 128);
    try benchFillPareto(io, stdout, "alea fillPareto", bytes / 128);
    try benchFillParetoScalar(io, stdout, "alea fillPareto scalar direct", bytes / 128);
    try benchWeibull(io, stdout, "alea weibull", bytes / 128);
    try benchFillWeibull(io, stdout, "alea fillWeibull", bytes / 128);
    try benchFillWeibullScalar(io, stdout, "alea fillWeibull scalar direct", bytes / 128);
    try benchGumbel(io, stdout, "alea gumbel", bytes / 128);
    try benchGumbelDirect(io, stdout, "alea gumbel direct", bytes / 128);
    try benchFillGumbel(io, stdout, "alea fillGumbel", bytes / 128);
    try benchFillGumbelScalar(io, stdout, "alea fillGumbel scalar direct", bytes / 128);
    try benchFrechet(io, stdout, "alea frechet", bytes / 128);
    try benchFillFrechet(io, stdout, "alea fillFrechet", bytes / 128);
    try benchFillFrechetScalar(io, stdout, "alea fillFrechet scalar direct", bytes / 128);
    try benchSkewNormal(io, stdout, "alea skew-normal", bytes / 128);
    try benchSkewNormalFastDirect(io, stdout, "alea skew-normal fast direct", bytes / 128);
    try benchSkewNormalRaw(alea.FastPrng, io, stdout, "alea skew-normal raw fast direct", bytes / 128, 0x5ce9, 1);
    try benchSkewNormalScalar(io, stdout, "alea skew-normal scalar direct", bytes / 128);
    try benchSkewNormalRaw(alea.ScalarPrng, io, stdout, "alea skew-normal raw scalar direct", bytes / 128, 0x5ce9, 1);
    try benchSkewNormalShape2(io, stdout, "alea skew-normal shape=2", bytes / 128);
    try benchSkewNormalShape2FastDirect(io, stdout, "alea skew-normal shape=2 fast direct", bytes / 128);
    try benchSkewNormalRaw(alea.FastPrng, io, stdout, "alea skew-normal shape=2 raw fast direct", bytes / 128, 0x5ce2, 2);
    try benchSkewNormalShape2Scalar(io, stdout, "alea skew-normal shape=2 scalar direct", bytes / 128);
    try benchSkewNormalRaw(alea.ScalarPrng, io, stdout, "alea skew-normal shape=2 raw scalar direct", bytes / 128, 0x5ce2, 2);
    try benchFillSkewNormal(io, stdout, "alea fillSkewNormal", bytes / 128);
    try benchFillSkewNormalFastDirect(io, stdout, "alea fillSkewNormal fast direct", bytes / 128);
    try benchFillSkewNormalScalar(io, stdout, "alea fillSkewNormal scalar direct", bytes / 128);
    try benchFillSkewNormalShape2(io, stdout, "alea fillSkewNormal shape=2", bytes / 128);
    try benchFillSkewNormalShape2FastDirect(io, stdout, "alea fillSkewNormal shape=2 fast direct", bytes / 128);
    try benchFillSkewNormalShape2Scalar(io, stdout, "alea fillSkewNormal shape=2 scalar direct", bytes / 128);
    try benchPert(io, stdout, "alea pert", bytes / 128);
    try benchFillPert(io, stdout, "alea fillPert", bytes / 128);
    try benchFillPertScalar(io, stdout, "alea fillPert scalar direct", bytes / 128);
    try benchUnitCircle(io, stdout, "alea unit circle", bytes / 128);
    try benchUnit2FastDirect(io, stdout, "alea unit circle fast direct", bytes / 128, 0xc11c1e, alea.distributions.unitCircleFrom);
    try benchUnitCircleScalar(io, stdout, "alea unit circle scalar direct", bytes / 128);
    try benchUnitDisc(io, stdout, "alea unit disc", bytes / 128);
    try benchUnit2FastDirect(io, stdout, "alea unit disc fast direct", bytes / 128, 0xd15c, alea.distributions.unitDiscFrom);
    try benchUnitDiscScalar(io, stdout, "alea unit disc scalar direct", bytes / 128);
    try benchUnitSphere(io, stdout, "alea unit sphere", bytes / 128);
    try benchUnit3FastDirect(io, stdout, "alea unit sphere fast direct", bytes / 128, 0x59e7e, alea.distributions.unitSphereFrom);
    try benchUnitSphereScalar(io, stdout, "alea unit sphere scalar direct", bytes / 128);
    try benchUnitBall(io, stdout, "alea unit ball", bytes / 128);
    try benchUnit3FastDirect(io, stdout, "alea unit ball fast direct", bytes / 128, 0xba11, alea.distributions.unitBallFrom);
    try benchUnitBallScalar(io, stdout, "alea unit ball scalar direct", bytes / 128);
    try benchFillUnitCircle(io, stdout, "alea fillUnitCircle", bytes / 128);
    try benchFillUnitDisc(io, stdout, "alea fillUnitDisc", bytes / 128);
    try benchFillUnitSphere(io, stdout, "alea fillUnitSphere scalar direct", bytes / 128);
    try benchFillUnitBall(io, stdout, "alea fillUnitBall scalar direct", bytes / 128);
    try benchInverseGaussian(io, stdout, "alea inverse-gaussian", bytes / 128);
    try benchInverseGaussianFastDirect(io, stdout, "alea inverse-gaussian fast direct", bytes / 128);
    try benchFillInverseGaussian(io, stdout, "alea fillInverseGaussian", bytes / 128);
    try benchFillInverseGaussianScalar(io, stdout, "alea fillInverseGaussian scalar direct", bytes / 128);
    try benchInverseGaussianCached(io, stdout, "alea inverse-gaussian cached", bytes / 128);
    try benchNormalInverseGaussian(io, stdout, "alea normal-inverse-gaussian", bytes / 128);
    try benchNormalInverseGaussianFastDirect(io, stdout, "alea normal-inverse-gaussian fast direct", bytes / 128);
    try benchFillNormalInverseGaussian(io, stdout, "alea fillNormalInverseGaussian", bytes / 128);
    try benchFillNormalInverseGaussianScalar(io, stdout, "alea fillNormalInverseGaussian scalar direct", bytes / 128);
    try benchNormalInverseGaussianCached(io, stdout, "alea normal-inverse-gaussian cached", bytes / 128);
    try benchNormalInverseGaussianScalar(io, stdout, "alea normal-inverse-gaussian scalar direct", bytes / 128);
    try benchZipf(io, stdout, "alea zipf", bytes / 128);
    try benchZipfDirect(io, stdout, "alea zipf direct", bytes / 128);
    try benchZipfFillDirect(io, stdout, "alea Zipf.fillFrom direct", bytes / 128);
    try benchZeta(io, stdout, "alea zeta", bytes / 128);
    try benchZetaDirect(io, stdout, "alea zeta direct", bytes / 128);
    try benchZetaFillDirect(io, stdout, "alea Zeta.fillFrom direct", bytes / 128);
    try stdout.flush();
}

fn benchEngine(io: std.Io, stdout: *std.Io.Writer, name: []const u8, comptime Engine: type, bytes: usize, buffer: []u8) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_mib_per_s: f64 = 0;
    var best_checksum: u8 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = if (Engine == alea.ChaCha) Engine.initFromU64(0x1234_5678) else Engine.init(0x1234_5678);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = bytes;
        var checksum: u8 = 0;
        while (remaining > 0) {
            const n = @min(buffer.len, remaining);
            engine.fill(buffer[0..n]);
            for (buffer[0..n]) |byte| checksum ^= byte;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const mib_per_s = (@as(f64, @floatFromInt(bytes)) / @as(f64, @floatFromInt(MiB))) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (mib_per_s > best_mib_per_s) {
            best_mib_per_s = mib_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} MiB/s checksum={}\n", .{ name, best_mib_per_s, best_checksum });
}

fn benchNext(io: std.Io, stdout: *std.Io.Writer, name: []const u8, comptime Engine: type, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = if (Engine == alea.ChaCha) Engine.initFromU64(0x1234_5678) else Engine.init(0x1234_5678);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum ^= engine.next();
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M next/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillOnly(io: std.Io, stdout: *std.Io.Writer, name: []const u8, comptime Engine: type, bytes: usize, buffer: []u8) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_mib_per_s: f64 = 0;
    var best_tail: u8 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = if (Engine == alea.ChaCha) Engine.initFromU64(0x1234_5678) else Engine.init(0x1234_5678);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = bytes;
        while (remaining > 0) {
            const n = @min(buffer.len, remaining);
            engine.fill(buffer[0..n]);
            std.mem.doNotOptimizeAway(buffer.ptr);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const mib_per_s = (@as(f64, @floatFromInt(bytes)) / @as(f64, @floatFromInt(MiB))) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (mib_per_s > best_mib_per_s) {
            best_mib_per_s = mib_per_s;
            best_tail = buffer[buffer.len - 1];
        }
    }

    try stdout.print("{s}: {d:.1} MiB/s tail={}\n", .{ name, best_mib_per_s, best_tail });
}

fn benchFillTypedU32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u32 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf11132);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fill(u32, out[0..n]);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillTypedBool(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]bool = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xb001);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fill(bool, out[0..n]);
            for (out[0..n]) |value| checksum += @intFromBool(value);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillChance(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]bool = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc4a9);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillChance(out[0..n], 0.25);
            for (out[0..n]) |value| checksum += @intFromBool(value);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillChanceHalf(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]bool = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc4a5);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillChance(out[0..n], 0.5);
            for (out[0..n]) |value| checksum += @intFromBool(value);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillRatioQuarter(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]bool = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x7144);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillRatio(out[0..n], 1, 4);
            for (out[0..n]) |value| checksum += @intFromBool(value);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillRatioThreeEighths(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]bool = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x7138);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillRatio(out[0..n], 3, 8);
            for (out[0..n]) |value| checksum += @intFromBool(value);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillRatioHalf(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]bool = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x7122);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillRatio(out[0..n], 1, 2);
            for (out[0..n]) |value| checksum += @intFromBool(value);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillTypedF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf320);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fill(f32, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillOpenF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf321);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillOpen(f32, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillOpenClosedF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf322);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillOpenClosed(f32, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillTypedF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf640);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fill(f64, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillTypedF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf640);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillFrom(&engine, f64, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillOpenF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf641);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillOpen(f64, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillOpenClosedF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf642);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillOpenClosed(f64, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchRangeFacade(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x9999);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) {
            checksum +%= rng.uintLessThan(u32, 1_000_003);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchRangeDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x9999);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) {
            checksum +%= alea.Rng.uintLessThanFrom(&engine, u32, 1_000_003);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf10a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 1) checksum += rng.float(f32);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatF32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf10a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.floatFrom(&engine, f32);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatOpenF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x0f01);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 1) checksum += rng.floatOpen(f32);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatOpenF32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x0f01);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.floatOpenFrom(&engine, f32);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatOpenClosedF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x0c01);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 1) checksum += rng.floatOpenClosed(f32);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatOpenClosedF32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x0c01);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.floatOpenClosedFrom(&engine, f32);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatRangeF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf16e);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 1) checksum += rng.floatRange(f32, -1, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatRangeF32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf16e);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.floatRangeFrom(&engine, f32, -1, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf10a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += rng.float(f64);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf10a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.floatFrom(&engine, f64);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatOpenF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x0f01);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += rng.floatOpen(f64);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatOpenF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x0f01);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.floatOpenFrom(&engine, f64);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatOpenClosedF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x0c01);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += rng.floatOpenClosed(f64);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatOpenClosedF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x0c01);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.floatOpenClosedFrom(&engine, f64);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatRangeF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf16e);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += rng.floatRange(f64, -1, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFloatRangeF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf16e);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.floatRangeFrom(&engine, f64, -1, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorBool(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xb064);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 64) {
            const value = rng.value(@Vector(64, bool));
            inline for (0..64) |lane| checksum += @intFromBool(value[lane]);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorChance(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc464);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 64) {
            const value = rng.vectorChance(@Vector(64, bool), 0.25);
            inline for (0..64) |lane| checksum += @intFromBool(value[lane]);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorChanceHalf(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc465);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 64) {
            const value = rng.vectorChance(@Vector(64, bool), 0.5);
            inline for (0..64) |lane| checksum += @intFromBool(value[lane]);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorRatioQuarter(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x7146);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 64) {
            const value = rng.vectorRatio(@Vector(64, bool), 1, 4);
            inline for (0..64) |lane| checksum += @intFromBool(value[lane]);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorRatioThreeEighths(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x7136);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 64) {
            const value = rng.vectorRatio(@Vector(64, bool), 3, 8);
            inline for (0..64) |lane| checksum += @intFromBool(value[lane]);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorRatioHalf(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x7126);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 64) {
            const value = rng.vectorRatio(@Vector(64, bool), 1, 2);
            inline for (0..64) |lane| checksum += @intFromBool(value[lane]);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorInt(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x1616);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 16) {
            const value = rng.value(@Vector(16, u16));
            inline for (0..16) |lane| checksum +%= value[lane];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorIntDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x1616);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 16) {
            const value = alea.Rng.vectorFrom(&engine, @Vector(16, u16));
            inline for (0..16) |lane| checksum +%= value[lane];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorRange(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: i64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x7ec7);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: i64 = 0;
        while (i < count) : (i += 8) {
            const value = rng.vectorRange(@Vector(8, i32), -1_000_000, 1_000_000);
            inline for (0..8) |lane| checksum +%= value[lane];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorRangeDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: i64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x7ec7);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: i64 = 0;
        while (i < count) : (i += 8) {
            const value = alea.Rng.vectorRangeFrom(&engine, @Vector(8, i32), -1_000_000, 1_000_000);
            inline for (0..8) |lane| checksum +%= value[lane];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorFloat(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf107);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 8) {
            const value = rng.value(@Vector(8, f32));
            inline for (0..8) |lane| checksum += value[lane];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillRange(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: i64 = 0;
    var out: [4096]i32 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf111);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: i64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillRange(i32, out[0..n], -1_000_000, 1_000_000);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillRangeF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf132);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillRange(f32, out[0..n], -1, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillRangeF64(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf164);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillRange(f64, out[0..n], -1, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillRangeF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf164);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillRangeFrom(&engine, f64, out[0..n], -1, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUniformFillF64Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    const dist = alea.distributions.Uniform(f64).init(-1, 1) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf16e);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            dist.fillFrom(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchAlphanumeric(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u8 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xa11a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.ascii.Alphanumeric.fill(rng, out[0..n]);
            for (out[0..n]) |byte| checksum +%= byte;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M chars/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchSeqFacade(io: std.Io, stdout: *std.Io.Writer, name: []const u8, length: usize, amount: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_thousand_per_s: f64 = 0;
    var best_checksum: usize = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xabcd);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        const indices = try alea.seq.sampleIndices(std.heap.smp_allocator, rng, length, amount);
        defer std.heap.smp_allocator.free(indices);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        var checksum: usize = 0;
        for (indices) |index| checksum +%= index;
        const thousand_per_s = (@as(f64, @floatFromInt(amount)) / 1_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (thousand_per_s > best_thousand_per_s) {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} K chosen/s checksum={}\n", .{ name, best_thousand_per_s, best_checksum });
}

fn benchSeqDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, length: usize, amount: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_thousand_per_s: f64 = 0;
    var best_checksum: usize = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xabcd);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        const indices = try alea.seq.sampleIndicesFrom(std.heap.smp_allocator, &engine, length, amount);
        defer std.heap.smp_allocator.free(indices);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        var checksum: usize = 0;
        for (indices) |index| checksum +%= index;
        const thousand_per_s = (@as(f64, @floatFromInt(amount)) / 1_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (thousand_per_s > best_thousand_per_s) {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} K chosen/s checksum={}\n", .{ name, best_thousand_per_s, best_checksum });
}

fn benchSeqIndexVecFacade(io: std.Io, stdout: *std.Io.Writer, name: []const u8, length: usize, amount: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_thousand_per_s: f64 = 0;
    var best_checksum: usize = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xabcd);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        const indices = try alea.seq.sampleIndexVec(std.heap.smp_allocator, rng, length, amount);
        defer indices.deinit(std.heap.smp_allocator);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        var checksum: usize = 0;
        var i: usize = 0;
        while (i < indices.len()) : (i += 1) checksum +%= indices.at(i);
        const thousand_per_s = (@as(f64, @floatFromInt(amount)) / 1_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (thousand_per_s > best_thousand_per_s) {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} K chosen/s checksum={}\n", .{ name, best_thousand_per_s, best_checksum });
}

fn benchSeqIndexVecDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, length: usize, amount: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_thousand_per_s: f64 = 0;
    var best_checksum: usize = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xabcd);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        const indices = try alea.seq.sampleIndexVecFrom(std.heap.smp_allocator, &engine, length, amount);
        defer indices.deinit(std.heap.smp_allocator);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        var checksum: usize = 0;
        var i: usize = 0;
        while (i < indices.len()) : (i += 1) checksum +%= indices.at(i);
        const thousand_per_s = (@as(f64, @floatFromInt(amount)) / 1_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (thousand_per_s > best_thousand_per_s) {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} K chosen/s checksum={}\n", .{ name, best_thousand_per_s, best_checksum });
}

fn benchSeqU32Facade(io: std.Io, stdout: *std.Io.Writer, name: []const u8, length: u32, amount: u32) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_thousand_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xabcd);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        const indices = try alea.seq.sampleIndicesU32(std.heap.smp_allocator, rng, length, amount);
        defer std.heap.smp_allocator.free(indices);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        var checksum: u64 = 0;
        for (indices) |index| checksum +%= index;
        const thousand_per_s = (@as(f64, @floatFromInt(amount)) / 1_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (thousand_per_s > best_thousand_per_s) {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} K chosen/s checksum={}\n", .{ name, best_thousand_per_s, best_checksum });
}

fn benchSeqU32Direct(io: std.Io, stdout: *std.Io.Writer, name: []const u8, length: u32, amount: u32) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_thousand_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xabcd);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        const indices = try alea.seq.sampleIndicesU32From(std.heap.smp_allocator, &engine, length, amount);
        defer std.heap.smp_allocator.free(indices);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        var checksum: u64 = 0;
        for (indices) |index| checksum +%= index;
        const thousand_per_s = (@as(f64, @floatFromInt(amount)) / 1_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (thousand_per_s > best_thousand_per_s) {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} K chosen/s checksum={}\n", .{ name, best_thousand_per_s, best_checksum });
}

fn benchNormal(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd15a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += rng.normal(f64, 0, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNormalSplitMix(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.SplitMix64.init(0xd15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.normalFastFrom(&engine, f64, 0, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNormalWyhash(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.Wyhash64.init(0xd15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.normalFastFrom(&engine, f64, 0, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNormalWyhashStdRandom(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.Wyhash64.init(0xd15f);
        const random = engine.random();
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += random.floatNorm(f64);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNormalStdRandom(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd15c);
        const random = engine.random();
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += random.floatNorm(f64);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNormalFast(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd15e);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.normalFastFrom(&engine, f64, 0, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchStandardNormalScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.StandardNormal(f64){};
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchStandardNormalRawScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.standardNormalFastFrom(&engine, f64);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchStandardNormalScalarF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    const dist = alea.distributions.StandardNormal(f32){};
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorNormalF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd158);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 8) {
            const value = rng.vectorNormal(@Vector(8, f32), 0, 1);
            inline for (0..8) |lane| checksum += value[lane];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillStandardNormal(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd15a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillStandardNormal(rng, f64, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillStandardNormalScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillStandardNormalFrom(&engine, f64, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillStandardNormalF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd15a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillStandardNormal(rng, f32, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillStandardNormalF32Scalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillStandardNormalFrom(&engine, f32, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillNormal(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd15b);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillNormal(f64, out[0..n], 0, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillNormalScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd15b);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillNormalFrom(&engine, f64, out[0..n], 0, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNormalSamplerFillScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    const dist = alea.distributions.Normal(f64).init(0, 1) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd15b);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            dist.fillFrom(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillNormalF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd159);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillNormal(f32, out[0..n], 0, 1);
            for (out[0..n]) |sample| checksum += sample;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBernoulli(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Bernoulli.init(0.25) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xbe44);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum += @intFromBool(dist.sample(rng));
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillBernoulli(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]bool = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xbe44);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillBernoulli(rng, out[0..n], 0.25);
            for (out[0..n]) |value| checksum += @intFromBool(value);
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchAliasTable(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: usize = 0;
    const weights = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xa11a);
        const rng = alea.Rng.init(&engine);
        var table = try alea.distributions.AliasTable(u32).init(std.heap.smp_allocator, &weights);
        defer table.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: usize = 0;
        while (i < count) : (i += 1) {
            checksum +%= table.sample(rng);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchAliasTableDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: usize = 0;
    const weights = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xa11a);
        var table = try alea.distributions.AliasTable(u32).init(std.heap.smp_allocator, &weights);
        defer table.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: usize = 0;
        while (i < count) : (i += 1) {
            checksum +%= table.sampleFrom(&engine);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchAliasTableFillDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: usize = 0;
    var out: [1024]usize = undefined;
    const weights = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xa11a);
        var table = try alea.distributions.AliasTable(u32).init(std.heap.smp_allocator, &weights);
        defer table.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: usize = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            table.fillFrom(&engine, out[0..n]);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchWeightedChoice(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const values = [_]u64{ 1, 2, 3, 4, 5, 8, 13, 21 };
    const weights = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc401ce);
        const rng = alea.Rng.init(&engine);
        var choice = try alea.seq.WeightedChoice(u64, u32).init(std.heap.smp_allocator, &values, &weights);
        defer choice.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) {
            checksum +%= choice.sampleValue(rng);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchWeightedChoiceDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const values = [_]u64{ 1, 2, 3, 4, 5, 8, 13, 21 };
    const weights = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc401ce);
        var choice = try alea.seq.WeightedChoice(u64, u32).init(std.heap.smp_allocator, &values, &weights);
        defer choice.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) {
            checksum +%= choice.sampleValueFrom(&engine);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchWeightedChoiceFillDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [1024]u64 = undefined;
    const values = [_]u64{ 1, 2, 3, 4, 5, 8, 13, 21 };
    const weights = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc401ce);
        var choice = try alea.seq.WeightedChoice(u64, u32).init(std.heap.smp_allocator, &values, &weights);
        defer choice.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            choice.fillValuesFrom(&engine, out[0..n]);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchWeightedTree(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: usize = 0;
    const initial = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x77ee);
        const rng = alea.Rng.init(&engine);
        var tree = try alea.distributions.WeightedTree(u32).init(std.heap.smp_allocator, &initial);
        defer tree.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: usize = 0;
        while (i < count) : (i += 1) {
            const index = i & 7;
            try tree.update(index, @as(u32, @intCast((i % 17) + 1)));
            checksum +%= tree.sample(rng);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M ops/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchWeightedTreeDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: usize = 0;
    const initial = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x77ee);
        var tree = try alea.distributions.WeightedTree(u32).init(std.heap.smp_allocator, &initial);
        defer tree.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: usize = 0;
        while (i < count) : (i += 1) {
            const index = i & 7;
            try tree.update(index, @as(u32, @intCast((i % 17) + 1)));
            checksum +%= tree.sampleFrom(&engine);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M ops/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchWeightedTreeFillDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: usize = 0;
    var out: [1024]usize = undefined;
    const initial = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x77ee);
        var tree = try alea.distributions.WeightedTree(u32).init(std.heap.smp_allocator, &initial);
        defer tree.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: usize = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            tree.fillFrom(&engine, out[0..n]);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchWeightedIntTree(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: usize = 0;
    const initial = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x77ef);
        const rng = alea.Rng.init(&engine);
        var tree = try alea.distributions.WeightedIntTree(u32).init(std.heap.smp_allocator, &initial);
        defer tree.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: usize = 0;
        while (i < count) : (i += 1) {
            const index = i & 7;
            try tree.update(index, @as(u32, @intCast((i % 17) + 1)));
            checksum +%= tree.sample(rng);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M ops/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchWeightedIntTreeDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: usize = 0;
    const initial = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x77ef);
        var tree = try alea.distributions.WeightedIntTree(u32).init(std.heap.smp_allocator, &initial);
        defer tree.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: usize = 0;
        while (i < count) : (i += 1) {
            const index = i & 7;
            try tree.update(index, @as(u32, @intCast((i % 17) + 1)));
            checksum +%= tree.sampleFrom(&engine);
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M ops/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchWeightedIntTreeFillDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: usize = 0;
    var out: [1024]usize = undefined;
    const initial = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x77ef);
        var tree = try alea.distributions.WeightedIntTree(u32).init(std.heap.smp_allocator, &initial);
        defer tree.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: usize = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            tree.fillFrom(&engine, out[0..n]);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchExponential(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xe15a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += rng.exponential(f64, 2);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchExponentialWyhash(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.exponentialFastFrom(&engine, f64, 2);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchExponentialFast(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xe15d);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.exponentialFastFrom(&engine, f64, 2);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchStandardExponentialScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.StandardExponential(f64){};
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchStandardExponentialRawScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.Rng.standardExponentialFastFrom(&engine, f64);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchStandardExponentialScalarF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    const dist = alea.distributions.StandardExponential(f32){};
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchVectorExponentialF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xe158);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f32 = 0;
        while (i < count) : (i += 8) {
            const value = rng.vectorExponential(@Vector(8, f32), 2);
            inline for (0..8) |lane| checksum += value[lane];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M lanes/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillStandardExponential(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xe15a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillStandardExponential(rng, f64, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillStandardExponentialScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillStandardExponentialFrom(&engine, f64, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillStandardExponentialF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xe15a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillStandardExponential(rng, f32, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillStandardExponentialF32Scalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe15a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillStandardExponentialFrom(&engine, f32, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillExponential(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xe15b);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillExponential(f64, out[0..n], 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillExponentialScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe15b);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillExponentialFrom(&engine, f64, out[0..n], 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchExponentialSamplerFillScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    const dist = alea.distributions.Exponential(f64).init(2) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe15b);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            dist.fillFrom(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillExponentialF32(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f32 = 0;
    var out: [4096]f32 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xe15c);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f32 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillExponential(f32, out[0..n], 2);
            for (out[0..n]) |sample| checksum += sample;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchPoisson(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xa157);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= alea.distributions.poisson(rng, 20);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchPoissonFastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Poisson.init(20) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xa157);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchPoissonWyhash(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Poisson.init(20) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xa157);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchPoissonCached(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Poisson.init(20) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xa159);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillPoisson(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xa159);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillPoisson(rng, out[0..n], 20);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillPoissonFastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xa159);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillPoissonFrom(&engine, out[0..n], 20);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillPoissonScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xa157);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillPoissonFrom(&engine, out[0..n], 20);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchGeometric(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Geometric.init(0.25) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6e0);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillGeometric(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6e0);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillGeometric(rng, out[0..n], 0.25);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillGeometricScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x6e0);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillGeometricFrom(&engine, out[0..n], 0.25);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchGeometricFailures(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.GeometricFailures.init(0.25) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6e0);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillGeometricFailures(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6e0);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillGeometricFailures(rng, out[0..n], 0.25);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillGeometricFailuresScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x6e0);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillGeometricFailuresFrom(&engine, out[0..n], 0.25);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchStandardGeometric(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.StandardGeometric{};
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6e05);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchStandardGeometricScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.StandardGeometric{};
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x6e05);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillStandardGeometric(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6e05);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillStandardGeometric(rng, out[0..n]);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillStandardGeometricScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x6e05);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillStandardGeometricFrom(&engine, out[0..n]);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBinomial(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xb157);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= alea.distributions.binomial(rng, 40, 0.25);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillBinomial(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xb157);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillBinomial(rng, out[0..n], 40, 0.25);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillBinomialScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xb157);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillBinomialFrom(&engine, out[0..n], 40, 0.25);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBinomialLarge(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xb16c);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= alea.distributions.binomial(rng, 10_000, 0.01);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBinomialApprox(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xb16a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= alea.distributions.binomialPoissonApprox(rng, 10_000, 0.01);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNegativeBinomial(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.NegativeBinomial.init(5, 0.4) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x5e6b);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillNegativeBinomial(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x5e6b);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillNegativeBinomial(rng, out[0..n], 5, 0.4);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillNegativeBinomialScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x5e6b);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillNegativeBinomialFrom(&engine, out[0..n], 5, 0.4);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchHypergeometric(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Hypergeometric.init(100, 30, 10) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x4965);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillHypergeometric(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x4965);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillHypergeometric(rng, out[0..n], 100, 30, 10);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillHypergeometricScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x4965);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillHypergeometricFrom(&engine, out[0..n], 100, 30, 10);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchHypergeometricLarge(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Hypergeometric.init(5000, 2500, 500) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x4966);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) checksum +%= dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillHypergeometricLarge(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x4966);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillHypergeometric(rng, out[0..n], 5000, 2500, 500);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillHypergeometricLargeScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    var out: [4096]u64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x4966);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillHypergeometricFrom(&engine, out[0..n], 5000, 2500, 500);
            for (out[0..n]) |value| checksum +%= value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchMultinomial(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Multinomial.init(100, &.{ 1.0, 2.0, 3.0 }) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x4111);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) {
            var out: [3]u64 = undefined;
            dist.sampleInto(rng, &out);
            checksum +%= out[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchMultinomialDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Multinomial.init(100, &.{ 1.0, 2.0, 3.0 }) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x4112);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: u64 = 0;
        while (i < count) : (i += 1) {
            var out: [3]u64 = undefined;
            dist.sampleIntoFrom(&engine, &out);
            checksum +%= out[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchMultinomialManyDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Multinomial.init(100, &.{ 1.0, 2.0, 3.0 }) catch unreachable;
    var out: [3 * 128]u64 = undefined;
    const chunk_samples: usize = out.len / 3;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x4112);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: u64 = 0;
        while (remaining > 0) {
            const samples = if (remaining < chunk_samples) remaining else chunk_samples;
            dist.sampleManyIntoFrom(&engine, out[0 .. samples * 3]);
            var i: usize = 0;
            while (i < samples) : (i += 1) checksum +%= out[i * 3];
            remaining -= samples;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchGamma(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6a44a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.gamma(rng, f64, 2, 3);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchGammaScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Gamma(f64).init(2, 3) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x6a44a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillGamma(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6a44b);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillGamma(rng, f64, out[0..n], 2, 3);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillGammaScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x6a44c);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillGammaFrom(&engine, f64, out[0..n], 2, 3);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillSampleGamma(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    const dist = alea.distributions.Gamma(f64).init(2, 3) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6a44b);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            rng.fillSample(f64, out[0..n], dist);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillSampleGammaScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    const dist = alea.distributions.Gamma(f64).init(2, 3) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x6a44c);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.Rng.fillSampleFrom(&engine, f64, out[0..n], dist);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchChiSquared(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc415);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.chiSquared(rng, f64, 4);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchChiSquaredCached(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.ChiSquared(f64).init(4) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xc415);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillChiSquared(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc415);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillChiSquared(rng, f64, out[0..n], 4);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillChiSquaredScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xc415);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillChiSquaredFrom(&engine, f64, out[0..n], 4);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchChi(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Chi(f64).init(4) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xc411);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillChi(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc411);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillChi(rng, f64, out[0..n], 4);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillChiScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xc411);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillChiFrom(&engine, f64, out[0..n], 4);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchErlang(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Erlang(f64).init(3, 2) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe71a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillErlang(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xe71a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillErlang(rng, f64, out[0..n], 3, 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillErlangScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xe71a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillErlangFrom(&engine, f64, out[0..n], 3, 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBeta(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xbe7a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.beta(rng, f64, 2, 5);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchBetaCached(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Beta(f64).init(2, 5) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xbe7a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillBeta(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xbe7a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillBeta(rng, f64, out[0..n], 2, 5);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillBetaScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xbe7a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillBetaFrom(&engine, f64, out[0..n], 2, 5);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFisherF(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf15c);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.fisherF(rng, f64, 5, 20);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFisherFDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xf15c);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.fisherFFrom(&engine, f64, 5, 20);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFisherFCached(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.FisherF(f64).init(5, 20) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xf15c);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillFisherF(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf15c);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillFisherF(rng, f64, out[0..n], 5, 20);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillFisherFScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xf15c);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillFisherFFrom(&engine, f64, out[0..n], 5, 20);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchTriangular(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x751a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.triangular(rng, f64, -1, 0, 2);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchTriangularDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Triangular(f64).init(-1, 0, 2) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x751a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillTriangular(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x751a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillTriangular(rng, f64, out[0..n], -1, 0, 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillTriangularScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x751a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillTriangularFrom(&engine, f64, out[0..n], -1, 0, 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchArcsine(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Arcsine(f64).init(-1, 3) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xa2c5);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillArcsine(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xa2c5);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillArcsine(rng, f64, out[0..n], -1, 3);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillArcsineScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xa2c5);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillArcsineFrom(&engine, f64, out[0..n], -1, 3);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchCauchy(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xca11);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.cauchy(rng, f64, 0, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchCauchyFastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xca11);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.cauchyFrom(&engine, f64, 0, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchCauchyScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xca11);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.cauchyFrom(&engine, f64, 0, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillCauchy(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xca11);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillCauchy(rng, f64, out[0..n], 0, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillCauchyScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xca11);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillCauchyFrom(&engine, f64, out[0..n], 0, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchLaplace(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Laplace(f64).init(0, 1) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x1a9);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillLaplace(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x1aa);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillLaplace(rng, f64, out[0..n], 0, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillLaplaceScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x1aa);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillLaplaceFrom(&engine, f64, out[0..n], 0, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchLogistic(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Logistic(f64).init(0, 1) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x1091);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillLogistic(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x1092);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillLogistic(rng, f64, out[0..n], 0, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillLogisticScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x1092);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillLogisticFrom(&engine, f64, out[0..n], 0, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchLogLogistic(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.LogLogistic(f64).init(2, 3) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x1061a9);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillLogLogistic(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x1061aa);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillLogLogistic(rng, f64, out[0..n], 2, 3);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillLogLogisticScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x1061aa);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillLogLogisticFrom(&engine, f64, out[0..n], 2, 3);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchKumaraswamy(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Kumaraswamy(f64).init(2, 5) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x9a77);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillKumaraswamy(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x9a78);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillKumaraswamy(rng, f64, out[0..n], 2, 5);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillKumaraswamyScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x9a78);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillKumaraswamyFrom(&engine, f64, out[0..n], 2, 5);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchPowerFunction(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.PowerFunction(f64).init(-1, 2, 3) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x90af);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillPowerFunction(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x90b0);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillPowerFunction(rng, f64, out[0..n], -1, 2, 3);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillPowerFunctionScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x90b0);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillPowerFunctionFrom(&engine, f64, out[0..n], -1, 2, 3);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchRayleigh(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Rayleigh(f64).init(2) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x7a11);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillRayleigh(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x7a12);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillRayleigh(rng, f64, out[0..n], 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillRayleighScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x7a12);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillRayleighFrom(&engine, f64, out[0..n], 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchMaxwell(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Maxwell(f64).init(2) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x4a7e11);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillMaxwell(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x4a7e12);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillMaxwell(rng, f64, out[0..n], 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillMaxwellScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x4a7e12);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillMaxwellFrom(&engine, f64, out[0..n], 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchDirichlet(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const alpha = [_]f64{ 1, 2, 3 };
    const dist = alea.distributions.Dirichlet(f64).init(&alpha) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd151);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) {
            const sample = try dist.sample(std.heap.smp_allocator, rng);
            defer std.heap.smp_allocator.free(sample);
            checksum += sample[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchDirichletDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const alpha = [_]f64{ 1, 2, 3 };
    const dist = alea.distributions.Dirichlet(f64).init(&alpha) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd152);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) {
            var sample: [3]f64 = undefined;
            dist.sampleIntoFrom(&engine, &sample);
            checksum += sample[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchDirichletManyDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const alpha = [_]f64{ 1, 2, 3 };
    const dist = alea.distributions.Dirichlet(f64).init(&alpha) catch unreachable;
    var out: [3 * 128]f64 = undefined;
    const chunk_samples: usize = out.len / 3;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd152);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const samples = if (remaining < chunk_samples) remaining else chunk_samples;
            dist.sampleManyIntoFrom(&engine, out[0 .. samples * 3]);
            var i: usize = 0;
            while (i < samples) : (i += 1) checksum += out[i * 3];
            remaining -= samples;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchLogNormal(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x1060);
        const rng = alea.Rng.init(&engine);
        var dist = alea.distributions.LogNormal(f64).init(0, 0.25) catch unreachable;
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchLogNormalFastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var dist = alea.distributions.LogNormal(f64).init(0, 0.25) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x1060);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchLogNormalScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var dist = alea.distributions.LogNormal(f64).init(0, 0.25) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x1061);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillLogNormal(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x1062);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillLogNormal(rng, f64, out[0..n], 0, 0.25);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillLogNormalFastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x1062);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillLogNormalFrom(&engine, f64, out[0..n], 0, 0.25);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillLogNormalScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x1062);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillLogNormalFrom(&engine, f64, out[0..n], 0, 0.25);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchHalfNormal(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.HalfNormal(f64).init(2) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x4a1f);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillHalfNormal(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x4a20);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillHalfNormal(rng, f64, out[0..n], 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillHalfNormalScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x4a20);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillHalfNormalFrom(&engine, f64, out[0..n], 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchStudentT(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x57dd);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.studentT(rng, f64, 10);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchStudentTDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x57d7);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.studentTFrom(&engine, f64, 10);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchStudentTCached(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.StudentT(f64).init(10) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x57dd);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillStudentT(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x57dd);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillStudentT(rng, f64, out[0..n], 10);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillStudentTScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x57dd);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillStudentTFrom(&engine, f64, out[0..n], 10);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchPareto(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x9a7e70);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.pareto(rng, f64, 2, 3);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillPareto(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x9a7e70);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillPareto(rng, f64, out[0..n], 2, 3);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillParetoScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x9a7e70);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillParetoFrom(&engine, f64, out[0..n], 2, 3);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchWeibull(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x8e1b);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.weibull(rng, f64, 2, 1.5);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillWeibull(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x8e1b);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillWeibull(rng, f64, out[0..n], 2, 1.5);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillWeibullScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x8e1b);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillWeibullFrom(&engine, f64, out[0..n], 2, 1.5);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchGumbel(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6cbe1);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.gumbel(rng, f64, 0, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchGumbelDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Gumbel(f64).init(0, 1) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x6cbe1);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillGumbel(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x6cbe1);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillGumbel(rng, f64, out[0..n], 0, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillGumbelScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x6cbe1);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillGumbelFrom(&engine, f64, out[0..n], 0, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFrechet(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf7ec);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.frechet(rng, f64, 0, 1, 3);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillFrechet(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf7ec);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillFrechet(rng, f64, out[0..n], 0, 1, 3);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillFrechetScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xf7ec);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillFrechetFrom(&engine, f64, out[0..n], 0, 1, 3);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchSkewNormal(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x5ce9);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.skewNormal(rng, f64, 0, 1, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchSkewNormalRaw(
    comptime Source: type,
    io: std.Io,
    stdout: *std.Io.Writer,
    name: []const u8,
    count: usize,
    seed: u64,
    comptime shape: f64,
) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.skewNormalFrom(&engine, f64, 0, 1, shape);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchSkewNormalFastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.SkewNormal(f64).init(0, 1, 1) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x5ce9);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchSkewNormalScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.SkewNormal(f64).init(0, 1, 1) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x5ce9);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchSkewNormalShape2(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x5ce2);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.skewNormal(rng, f64, 0, 1, 2);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchSkewNormalShape2FastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.SkewNormal(f64).init(0, 1, 2) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x5ce2);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchSkewNormalShape2Scalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.SkewNormal(f64).init(0, 1, 2) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x5ce2);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillSkewNormal(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x5ce8);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillSkewNormal(rng, f64, out[0..n], 0, 1, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillSkewNormalFastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x5ce8);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillSkewNormalFrom(&engine, f64, out[0..n], 0, 1, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillSkewNormalScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x5ce8);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillSkewNormalFrom(&engine, f64, out[0..n], 0, 1, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillSkewNormalShape2(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x5ce2);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillSkewNormal(rng, f64, out[0..n], 0, 1, 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillSkewNormalShape2FastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    const dist = alea.distributions.SkewNormal(f64).init(0, 1, 2) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x5ce2);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            dist.fillFrom(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillSkewNormalShape2Scalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    const dist = alea.distributions.SkewNormal(f64).init(0, 1, 2) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x5ce2);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            dist.fillFrom(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchPert(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x9e71);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.pert(rng, f64, -1, 0.5, 2, 4);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillPert(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x9e71);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillPert(rng, f64, out[0..n], -1, 0.5, 2, 4);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillPertScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x9e71);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillPertFrom(&engine, f64, out[0..n], -1, 0.5, 2, 4);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnitCircle(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xc11c1e);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) {
            const value = alea.distributions.unitCircle(rng, f64);
            checksum += value[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnit2FastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize, seed: u64, comptime sampleFn: anytype) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += sampleFn(&engine, f64)[0];
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnitCircleScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.UnitCircle(f64){};
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xc11c1e);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine)[0];
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnitDisc(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xd15c);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) {
            const value = alea.distributions.unitDisc(rng, f64);
            checksum += value[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnitDiscScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.UnitDisc(f64){};
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd15c);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine)[0];
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnitSphere(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x59e7e);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) {
            const value = alea.distributions.unitSphere(rng, f64);
            checksum += value[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnit3FastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize, seed: u64, comptime sampleFn: anytype) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += sampleFn(&engine, f64)[0];
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnitSphereScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.UnitSphere(f64){};
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x59e7e);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine)[0];
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnitBall(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xba11);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) {
            const value = alea.distributions.unitBall(rng, f64);
            checksum += value[0];
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchUnitBallScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.UnitBall(f64){};
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xba11);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine)[0];
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillUnitCircle(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024][2]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xc11c1e);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillUnitCircleFrom(&engine, f64, out[0..n]);
            for (out[0..n]) |value| checksum += value[0];
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillUnitDisc(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024][2]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xd15c);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillUnitDiscFrom(&engine, f64, out[0..n]);
            for (out[0..n]) |value| checksum += value[0];
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillUnitSphere(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024][3]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x59e7e);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillUnitSphereFrom(&engine, f64, out[0..n]);
            for (out[0..n]) |value| checksum += value[0];
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillUnitBall(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024][3]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0xba11);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillUnitBallFrom(&engine, f64, out[0..n]);
            for (out[0..n]) |value| checksum += value[0];
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchInverseGaussian(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x164a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.inverseGaussian(rng, f64, 1, 2);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchInverseGaussianFastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x164a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.inverseGaussianFrom(&engine, f64, 1, 2);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillInverseGaussian(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x164c);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillInverseGaussian(rng, f64, out[0..n], 1, 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillInverseGaussianScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x164c);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillInverseGaussianFrom(&engine, f64, out[0..n], 1, 2);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchInverseGaussianCached(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.InverseGaussian(f64).init(1, 2) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x164b);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNormalInverseGaussian(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x916a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.normalInverseGaussian(rng, f64, 2, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNormalInverseGaussianFastDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x916a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.normalInverseGaussianFrom(&engine, f64, 2, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillNormalInverseGaussian(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x916d);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillNormalInverseGaussian(rng, f64, out[0..n], 2, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFillNormalInverseGaussianScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x916d);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            alea.distributions.fillNormalInverseGaussianFrom(&engine, f64, out[0..n], 2, 1);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNormalInverseGaussianCached(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.NormalInverseGaussian(f64).init(2, 1) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x916b);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchNormalInverseGaussianScalar(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x916c);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += alea.distributions.normalInverseGaussianFrom(&engine, f64, 2, 1);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchZipf(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Zipf(f64).init(10, 1.5) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x719f);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchZipfDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Zipf(f64).init(10, 1.5) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x719f);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchZipfFillDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    const dist = alea.distributions.Zipf(f64).init(10, 1.5) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x719f);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            dist.fillFrom(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchZeta(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Zeta(f64).init(3) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x7e7a);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sample(rng);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchZetaDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    const dist = alea.distributions.Zeta(f64).init(3) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x7e7a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var i: usize = 0;
        var checksum: f64 = 0;
        while (i < count) : (i += 1) checksum += dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchZetaFillDirect(io: std.Io, stdout: *std.Io.Writer, name: []const u8, count: usize) !void {
    if (bench_filter) |filter| if (std.ascii.indexOfIgnoreCase(name, filter) == null) return;
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;
    const dist = alea.distributions.Zeta(f64).init(3) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x7e7a);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            dist.fillFrom(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value;
            remaining -= n;
        }
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}
