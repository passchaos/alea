const std = @import("std");
const alea = @import("alea");

const Options = struct {
    engine_name: []const u8 = "fast",
    seed: u64 = 0x51a7_c0de,
    bytes: usize = 64 * 1024 * 1024,
};

const EngineKind = enum {
    fast,
    default,
    wyhash64,
    pcg64,
    xoshiro128plusplus,
    xoshiro256plusplus,
    chacha8,
    chacha12,
    chacha20,
};

pub fn main(init: std.process.Init) !void {
    var arena = std.heap.ArenaAllocator.init(init.gpa);
    defer arena.deinit();
    const args = try init.minimal.args.toSlice(arena.allocator());
    const io = init.io;

    const options = parseOptions(args) catch return usage();

    var stdout_buffer: [8192]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    switch (engineKind(options.engine_name) orelse return usage()) {
        .fast => {
            var engine = alea.FastPrng.init(options.seed);
            try writeStream(&engine, stdout, options.bytes);
        },
        .default => {
            var engine = alea.DefaultPrng.init(options.seed);
            try writeStream(&engine, stdout, options.bytes);
        },
        .wyhash64 => {
            var engine = alea.Wyhash64.init(options.seed);
            try writeStream(&engine, stdout, options.bytes);
        },
        .pcg64 => {
            var engine = alea.Pcg64.init(options.seed);
            try writeStream(&engine, stdout, options.bytes);
        },
        .xoshiro128plusplus => {
            var engine = alea.Xoshiro128PlusPlus.init(options.seed);
            try writeStream(&engine, stdout, options.bytes);
        },
        .xoshiro256plusplus => {
            var engine = alea.Xoshiro256PlusPlus.init(options.seed);
            try writeStream(&engine, stdout, options.bytes);
        },
        .chacha8 => {
            var engine = alea.ChaCha8Rng.initFromU64(options.seed);
            try writeStream(&engine, stdout, options.bytes);
        },
        .chacha12 => {
            var engine = alea.ChaCha.initFromU64(options.seed);
            try writeStream(&engine, stdout, options.bytes);
        },
        .chacha20 => {
            var engine = alea.ChaCha20Rng.initFromU64(options.seed);
            try writeStream(&engine, stdout, options.bytes);
        },
    }

    try stdout.flush();
}

fn parseOptions(args: []const []const u8) !Options {
    var options: Options = .{};
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--engine")) {
            i += 1;
            if (i >= args.len) return error.InvalidArguments;
            if (engineKind(args[i]) == null) return error.InvalidArguments;
            options.engine_name = args[i];
        } else if (std.mem.eql(u8, args[i], "--seed")) {
            i += 1;
            if (i >= args.len) return error.InvalidArguments;
            options.seed = std.fmt.parseInt(u64, args[i], 0) catch return error.InvalidArguments;
        } else if (std.mem.eql(u8, args[i], "--bytes")) {
            i += 1;
            if (i >= args.len) return error.InvalidArguments;
            options.bytes = std.fmt.parseInt(usize, args[i], 0) catch return error.InvalidArguments;
        } else {
            return error.InvalidArguments;
        }
    }
    return options;
}

fn engineKind(name: []const u8) ?EngineKind {
    if (std.mem.eql(u8, name, "fast") or std.mem.eql(u8, name, "alea4x64")) return .fast;
    if (std.mem.eql(u8, name, "default") or std.mem.eql(u8, name, "xoshiro256")) return .default;
    if (std.mem.eql(u8, name, "wyhash64")) return .wyhash64;
    if (std.mem.eql(u8, name, "pcg64")) return .pcg64;
    if (std.mem.eql(u8, name, "xoshiro128++")) return .xoshiro128plusplus;
    if (std.mem.eql(u8, name, "xoshiro256++")) return .xoshiro256plusplus;
    if (std.mem.eql(u8, name, "chacha8")) return .chacha8;
    if (std.mem.eql(u8, name, "chacha12")) return .chacha12;
    if (std.mem.eql(u8, name, "chacha20")) return .chacha20;
    return null;
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
        \\usage: zig build stream -- [--engine fast|default|wyhash64|pcg64|xoshiro128++|xoshiro256++|chacha8|chacha12|chacha20] [--seed N] [--bytes N]
        \\
        \\Example:
        \\  zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1073741824 | RNG_test stdin64
        \\
    , .{});
    return error.InvalidArguments;
}

test "engineKind accepts documented engine names and aliases" {
    try std.testing.expectEqual(EngineKind.fast, engineKind("fast").?);
    try std.testing.expectEqual(EngineKind.fast, engineKind("alea4x64").?);
    try std.testing.expectEqual(EngineKind.default, engineKind("default").?);
    try std.testing.expectEqual(EngineKind.default, engineKind("xoshiro256").?);
    try std.testing.expectEqual(EngineKind.xoshiro128plusplus, engineKind("xoshiro128++").?);
    try std.testing.expectEqual(EngineKind.xoshiro256plusplus, engineKind("xoshiro256++").?);
    try std.testing.expectEqual(EngineKind.chacha20, engineKind("chacha20").?);
    try std.testing.expect(engineKind("missing-engine") == null);
}

test "parseOptions handles defaults and explicit values" {
    const defaults = try parseOptions(&.{"stream"});
    try std.testing.expectEqualStrings("fast", defaults.engine_name);
    try std.testing.expectEqual(@as(u64, 0x51a7_c0de), defaults.seed);
    try std.testing.expectEqual(@as(usize, 64 * 1024 * 1024), defaults.bytes);

    const explicit = try parseOptions(&.{ "stream", "--engine", "pcg64", "--seed", "0x2a", "--bytes", "4096" });
    try std.testing.expectEqualStrings("pcg64", explicit.engine_name);
    try std.testing.expectEqual(@as(u64, 0x2a), explicit.seed);
    try std.testing.expectEqual(@as(usize, 4096), explicit.bytes);
}

test "parseOptions rejects unknown flags and missing values" {
    try std.testing.expectError(error.InvalidArguments, parseOptions(&.{ "stream", "--engine" }));
    try std.testing.expectError(error.InvalidArguments, parseOptions(&.{ "stream", "--engine", "missing-engine" }));
    try std.testing.expectError(error.InvalidArguments, parseOptions(&.{ "stream", "--seed", "not-a-number" }));
    try std.testing.expectError(error.InvalidArguments, parseOptions(&.{ "stream", "--bytes" }));
    try std.testing.expectError(error.InvalidArguments, parseOptions(&.{ "stream", "--unknown" }));
}
