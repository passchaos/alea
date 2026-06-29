const std = @import("std");
const alea = @import("alea");

const trials = 3;
const default_count = 8 * 1024 * 1024;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var args = std.process.Args.Iterator.init(init.minimal.args);
    defer args.deinit();
    _ = args.next();
    const sample_count = if (args.next()) |arg|
        std.fmt.parseInt(usize, arg, 10) catch default_count
    else
        default_count;

    try stdout.print("erlang probe count={}\n", .{sample_count});
    try benchFacade(io, stdout, "facade current fill k=2", 0xe211, sample_count, currentFill2);
    try benchFacade(io, stdout, "facade product vector4 k=2", 0xe211, sample_count, productVector2);
    try benchScalarFacade(io, stdout, "scalar-facade current fill k=2", 0xe211, sample_count, currentFill2);
    try benchScalarFacade(io, stdout, "scalar-facade product vector4 k=2", 0xe211, sample_count, productVector2);
    try benchFacade(io, stdout, "facade current fill k=3", 0xe311, sample_count, currentFill);
    try benchFacade(io, stdout, "facade product vector4 k=3", 0xe311, sample_count, productVector4);
    try benchScalarFacade(io, stdout, "scalar-facade current fill k=3", 0xe311, sample_count, currentFill);
    try benchScalarFacade(io, stdout, "scalar-facade product vector4 k=3", 0xe311, sample_count, productVector4);
    try benchFacade(io, stdout, "facade current fill k=4", 0xe411, sample_count, currentFill4);
    try benchFacade(io, stdout, "facade product vector4 k=4", 0xe411, sample_count, productVector4K4);
    try benchFill(alea.FastPrng, io, stdout, "fast current fill k=3", 0xe311, sample_count, currentFill);
    try benchFill(alea.FastPrng, io, stdout, "fast product scalar k=3", 0xe311, sample_count, productScalar);
    try benchFill(alea.FastPrng, io, stdout, "fast product vector4 k=3", 0xe311, sample_count, productVector4);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar current fill k=3", 0xe311, sample_count, currentFill);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar product scalar k=3", 0xe311, sample_count, productScalar);
    try benchFill(alea.ScalarPrng, io, stdout, "scalar product vector4 k=3", 0xe311, sample_count, productVector4);
    try stdout.flush();
}

fn benchFacade(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime fillFn: anytype,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(seed);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(rng, out[0..n]);
            for (out[0..n]) |item| checksum += item;
            remaining -= n;
        }

        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(sample_count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchScalarFacade(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime fillFn: anytype,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(seed);
        const rng = alea.Rng.init(&engine);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(rng, out[0..n]);
            for (out[0..n]) |item| checksum += item;
            remaining -= n;
        }

        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(sample_count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn benchFill(
    comptime Source: type,
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    seed: u64,
    sample_count: usize,
    comptime fillFn: anytype,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [1024]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = Source.init(seed);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, out[0..n]);
            for (out[0..n]) |item| checksum += item;
            remaining -= n;
        }

        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(sample_count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print("{s}: {d:.1} M samples/s checksum={d:.3}\n", .{ name, best_million_per_s, best_checksum });
}

fn currentFill(source: anytype, dest: []f64) void {
    alea.distributions.fillErlangFrom(source, f64, dest, 3, 2);
}

fn currentFill2(source: anytype, dest: []f64) void {
    alea.distributions.fillErlangFrom(source, f64, dest, 2, 2);
}

fn currentFill4(source: anytype, dest: []f64) void {
    alea.distributions.fillErlangFrom(source, f64, dest, 4, 2);
}

fn productScalar(source: anytype, dest: []f64) void {
    for (dest) |*item| {
        const product =
            alea.Rng.floatOpenFrom(source, f64) *
            alea.Rng.floatOpenFrom(source, f64) *
            alea.Rng.floatOpenFrom(source, f64);
        item.* = -2.0 * @log(product);
    }
}

fn productVector4(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    multiplyByOpenUniform(source, dest);
    multiplyByOpenUniform(source, dest);
    transformVector4Log(dest, 2);
}

fn productVector2(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    multiplyByOpenUniform(source, dest);
    transformVector4Log(dest, 2);
}

fn productVector4K4(source: anytype, dest: []f64) void {
    alea.Rng.fillOpenFrom(source, f64, dest);
    multiplyByOpenUniform(source, dest);
    multiplyByOpenUniform(source, dest);
    multiplyByOpenUniform(source, dest);
    transformVector4Log(dest, 2);
}

fn multiplyByOpenUniform(source: anytype, dest: []f64) void {
    var uniforms: [1024]f64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, uniforms.len);
        alea.Rng.fillOpenFrom(source, f64, uniforms[0..take]);
        for (dest[i .. i + take], uniforms[0..take]) |*item, uniform| item.* *= uniform;
        i += take;
    }
}

fn transformVector4Log(dest: []f64, scale: f64) void {
    const VectorType = @Vector(4, f64);
    const scale_vec: VectorType = @splat(-scale);

    var i: usize = 0;
    while (i + 4 <= dest.len) : (i += 4) {
        const input: VectorType = .{ dest[i], dest[i + 1], dest[i + 2], dest[i + 3] };
        const out = scale_vec * @log(input);
        inline for (0..4) |lane| dest[i + lane] = out[lane];
    }

    while (i < dest.len) : (i += 1) dest[i] = -scale * @log(dest[i]);
}
