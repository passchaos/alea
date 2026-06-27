const std = @import("std");
const alea = @import("alea");

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.gpa);
    const io = init.io;

    var engine_name: []const u8 = "fast";
    var seed: u64 = 0x51a7_c0de;
    var bytes: usize = 64 * 1024 * 1024;

    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--engine")) {
            i += 1;
            if (i >= args.len) return usage();
            engine_name = args[i];
        } else if (std.mem.eql(u8, args[i], "--seed")) {
            i += 1;
            if (i >= args.len) return usage();
            seed = try std.fmt.parseInt(u64, args[i], 0);
        } else if (std.mem.eql(u8, args[i], "--bytes")) {
            i += 1;
            if (i >= args.len) return usage();
            bytes = try std.fmt.parseInt(usize, args[i], 0);
        } else if (std.mem.eql(u8, args[i], "--help")) {
            return usage();
        } else {
            return usage();
        }
    }

    var stdout_buffer: [8192]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    if (std.mem.eql(u8, engine_name, "fast") or std.mem.eql(u8, engine_name, "alea4x64")) {
        var engine = alea.FastPrng.init(seed);
        try writeStream(&engine, stdout, bytes);
    } else if (std.mem.eql(u8, engine_name, "default") or std.mem.eql(u8, engine_name, "xoshiro256")) {
        var engine = alea.DefaultPrng.init(seed);
        try writeStream(&engine, stdout, bytes);
    } else if (std.mem.eql(u8, engine_name, "wyhash64")) {
        var engine = alea.Wyhash64.init(seed);
        try writeStream(&engine, stdout, bytes);
    } else if (std.mem.eql(u8, engine_name, "pcg64")) {
        var engine = alea.Pcg64.init(seed);
        try writeStream(&engine, stdout, bytes);
    } else if (std.mem.eql(u8, engine_name, "xoshiro256++")) {
        var engine = alea.Xoshiro256PlusPlus.init(seed);
        try writeStream(&engine, stdout, bytes);
    } else if (std.mem.eql(u8, engine_name, "chacha12")) {
        var engine = alea.ChaCha.initFromU64(seed);
        try writeStream(&engine, stdout, bytes);
    } else {
        return usage();
    }

    try stdout.flush();
}

fn writeStream(engine: anytype, stdout: *std.Io.Writer, bytes: usize) !void {
    var buffer: [8192]u8 = undefined;
    var remaining = bytes;
    while (remaining > 0) {
        const n = @min(buffer.len, remaining);
        engine.fill(buffer[0..n]);
        try stdout.writeAll(buffer[0..n]);
        remaining -= n;
    }
}

fn usage() error{InvalidArguments} {
    std.debug.print(
        \\usage: zig build stream -- [--engine fast|default|wyhash64|pcg64|xoshiro256++|chacha12] [--seed N] [--bytes N]
        \\
        \\Example:
        \\  zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1073741824 | RNG_test stdin64
        \\
    , .{});
    return error.InvalidArguments;
}
