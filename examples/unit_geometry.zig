const std = @import("std");
const alea = @import("alea");

fn norm2_2(point: [2]f64) f64 {
    return point[0] * point[0] + point[1] * point[1];
}

fn norm2_3(point: [3]f64) f64 {
    return point[0] * point[0] + point[1] * point[1] + point[2] * point[2];
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var engine = alea.ScalarPrng.init(0x6017_0001);

    const circle = alea.distributions.unitCircleFrom(&engine, f64);
    const disc = alea.distributions.unitDiscFrom(&engine, f64);
    const sphere = alea.distributions.unitSphereFrom(&engine, f64);
    const ball = alea.distributions.unitBallFrom(&engine, f64);

    try stdout.print("unit circle point: {any}, norm2={d:.12}\n", .{ circle, norm2_2(circle) });
    try stdout.print("unit disc point: {any}, norm2={d:.12}\n", .{ disc, norm2_2(disc) });
    try stdout.print("unit sphere point: {any}, norm2={d:.12}\n", .{ sphere, norm2_3(sphere) });
    try stdout.print("unit ball point: {any}, norm2={d:.12}\n", .{ ball, norm2_3(ball) });

    var circles: [3][2]f64 = undefined;
    var discs: [3][2]f64 = undefined;
    var spheres: [3][3]f64 = undefined;
    var balls: [3][3]f64 = undefined;
    alea.distributions.fillUnitCircleFrom(&engine, f64, &circles);
    alea.distributions.fillUnitDiscFrom(&engine, f64, &discs);
    alea.distributions.fillUnitSphereFrom(&engine, f64, &spheres);
    alea.distributions.fillUnitBallFrom(&engine, f64, &balls);

    try stdout.print("filled circles: {any}\n", .{circles});
    try stdout.print("filled discs: {any}\n", .{discs});
    try stdout.print("filled spheres: {any}\n", .{spheres});
    try stdout.print("filled balls: {any}\n", .{balls});

    const circle_sampler = alea.distributions.UnitCircle(f64){};
    const ball_sampler = alea.distributions.UnitBall(f64){};
    try stdout.print("UnitCircle diagnostics: dim={}, surface={}, coord-var={d:.3}, radial-mean={d:.3}\n", .{ circle_sampler.dimensionValue(), circle_sampler.isSurface(), circle_sampler.coordinateVarianceValue(), circle_sampler.radialExpectedValue() });
    try stdout.print("UnitBall diagnostics: dim={}, surface={}, coord-var={d:.3}, radial-mean={d:.3}\n", .{ ball_sampler.dimensionValue(), ball_sampler.isSurface(), ball_sampler.coordinateVarianceValue(), ball_sampler.radialExpectedValue() });

    var vector_engine = alea.ScalarPrng.init(0x6017_0002);
    const vector_circle = alea.distributions.vectorUnitCircleFrom(&vector_engine, @Vector(4, f64));
    const vector_ball = alea.distributions.vectorUnitBallFrom(&vector_engine, @Vector(4, f64));
    try stdout.print("vector unit circle f64x4 x lanes: {any}\n", .{vector_circle[0]});
    try stdout.print("vector unit circle f64x4 y lanes: {any}\n", .{vector_circle[1]});
    try stdout.print("vector unit ball f64x4 x lanes: {any}\n", .{vector_ball[0]});
    try stdout.print("vector unit ball f64x4 y lanes: {any}\n", .{vector_ball[1]});
    try stdout.print("vector unit ball f64x4 z lanes: {any}\n", .{vector_ball[2]});

    try stdout.print("\nUse circle/sphere for unit surfaces, disc/ball for filled volumes, fill* helpers for point slices, and vectorUnit* helpers for vector-lane batches.\n", .{});
    try stdout.flush();
}
