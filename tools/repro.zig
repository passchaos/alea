const std = @import("std");
const alea = @import("alea");
const builtin = @import("builtin");

pub fn main(init: std.process.Init) !void {
    if (builtin.target.os.tag == .wasi) {
        try printReport(null);
        return;
    }

    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    try printReport(stdout);
    try stdout.flush();
}

fn printReport(stdout: ?*std.Io.Writer) !void {
    try printEngine(stdout, "alea4x64", alea.Alea4x64, 0x1234);
    try printEngine(stdout, "wyhash64", alea.Wyhash64, 0x1234);
    try printEngine(stdout, "xoshiro256", alea.Xoshiro256, 0x1234);
    try printEngine(stdout, "xoshiro256++", alea.Xoshiro256PlusPlus, 0x1234);
    try printEngine(stdout, "pcg64", alea.Pcg64, 0x1234);
    try printEngine(stdout, "chacha12", alea.ChaCha, 0x1234);

    const seed = alea.Seed.fromString("repro");
    try emit(stdout, "seed.fromString(repro)=0x{x}\n", .{seed.state});
    try emit(stdout, "seed.stream(7)=0x{x}\n", .{seed.stream(7).state});
}

fn printEngine(stdout: ?*std.Io.Writer, comptime name: []const u8, comptime Engine: type, seed: u64) !void {
    var engine = if (Engine == alea.ChaCha) Engine.initFromU64(seed) else Engine.init(seed);
    try emit(stdout, "{s}", .{name});
    var i: usize = 0;
    while (i < 8) : (i += 1) {
        try emit(stdout, " 0x{x}", .{engine.next()});
    }
    try emit(stdout, "\n", .{});
}

fn emit(stdout: ?*std.Io.Writer, comptime fmt: []const u8, args: anytype) !void {
    if (builtin.target.os.tag == .wasi) {
        std.debug.print(fmt, args);
    } else {
        try stdout.?.print(fmt, args);
    }
}
