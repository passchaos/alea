const std = @import("std");
const alea = @import("alea");

fn mean(comptime T: type, values: []const T) f64 {
    var sum: f64 = 0;
    for (values) |value| sum += @floatCast(value);
    return sum / @as(f64, @floatFromInt(values.len));
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var exact_engine = alea.ScalarPrng.init(0x1090);
    var buffered_engine = alea.ScalarPrng.init(0x1090);
    var native_engine = alea.ScalarPrng.init(0x1090);
    var exp2_engine = alea.ScalarPrng.init(0x1090);
    var native_exp2_engine = alea.ScalarPrng.init(0x1090);

    var exact: [16]f32 = undefined;
    var buffered_out: [16]f32 = undefined;
    var native: [16]f32 = undefined;
    var exp2: [16]f32 = undefined;
    var native_exp2: [16]f32 = undefined;

    alea.distributions.fillLogNormalFrom(&exact_engine, f32, &exact, 0, 0.25);
    var buffered = try alea.distributions.BufferedLogNormal(f32, 8).init(0, 0.25);
    buffered.fillFrom(&buffered_engine, &buffered_out);
    alea.distributions.fillLogNormalNativeF32From(&native_engine, &native, 0, 0.25);
    alea.distributions.fillLogNormalExp2F32From(&exp2_engine, &exp2, 0, 0.25);
    alea.distributions.fillLogNormalNativeExp2F32From(&native_exp2_engine, &native_exp2, 0, 0.25);

    try stdout.print("exact LogNormal(f32) first={d:.6}, mean16={d:.6}\n", .{ exact[0], mean(f32, &exact) });
    try stdout.print("buffered exact first={d:.6}, mean16={d:.6}, buffered-left={}\n", .{ buffered_out[0], mean(f32, &buffered_out), buffered.bufferedValueCount() });
    try stdout.print("native-f32 normal source first={d:.6}, mean16={d:.6}\n", .{ native[0], mean(f32, &native) });
    try stdout.print("exp2 transform first={d:.6}, mean16={d:.6}\n", .{ exp2[0], mean(f32, &exp2) });
    try stdout.print("native-f32 + exp2 first={d:.6}, mean16={d:.6}\n", .{ native_exp2[0], mean(f32, &native_exp2) });

    if (try tryLibcProfiles(stdout)) {
        try stdout.print("libc-backed profiles loaded on this target.\n", .{});
    } else {
        try stdout.print("libc-backed LogNormalDlsymExp/LogNormalLibmvec profiles are unavailable on this target.\n", .{});
    }

    try stdout.print("\nUse exact LogNormal for stable @exp output; use named Native/Exp2/libc profiles only when their output-mapping and platform contracts are acceptable.\n", .{});
    try stdout.flush();
}

fn tryLibcProfiles(stdout: *std.Io.Writer) !bool {
    var any_loaded = false;

    var dlsym = alea.distributions.LogNormalDlsymExp(f32, 8).init(0, 0.25) catch |err| switch (err) {
        error.LibmUnavailable => null,
        else => return err,
    };
    if (dlsym) |*sampler| {
        defer sampler.deinit();
        var engine = alea.ScalarPrng.init(0x1090);
        const sample = sampler.sampleFrom(&engine);
        try stdout.print("dlsym libm exp first={d:.6}, buffered-left={}\n", .{ sample, sampler.bufferedValueCount() });
        any_loaded = true;
    }

    var libmvec = alea.distributions.LogNormalLibmvec(f32, 8).init(0, 0.25) catch |err| switch (err) {
        error.LibmvecUnavailable => null,
        else => return err,
    };
    if (libmvec) |*sampler| {
        defer sampler.deinit();
        var engine = alea.ScalarPrng.init(0x1090);
        const sample = sampler.sampleFrom(&engine);
        try stdout.print("libmvec exp first={d:.6}, buffered-left={}\n", .{ sample, sampler.bufferedValueCount() });
        any_loaded = true;
    }

    return any_loaded;
}
