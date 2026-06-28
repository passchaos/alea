const std = @import("std");
const alea = @import("alea");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    try printEngine(stdout, "alea4x64", alea.Alea4x64, 0x1234);
    try printEngine(stdout, "wyhash64", alea.Wyhash64, 0x1234);
    try printEngine(stdout, "xoshiro256", alea.Xoshiro256, 0x1234);
    try printEngine(stdout, "xoshiro256++", alea.Xoshiro256PlusPlus, 0x1234);
    try printEngine(stdout, "pcg64", alea.Pcg64, 0x1234);
    try printEngine(stdout, "chacha12", alea.ChaCha, 0x1234);

    const seed = alea.Seed.fromString("repro");
    try stdout.print("seed.fromString(repro)=0x{x}\n", .{seed.state});
    try stdout.print("seed.stream(7)=0x{x}\n", .{seed.stream(7).state});
    try stdout.flush();
}

fn printEngine(stdout: *std.Io.Writer, comptime name: []const u8, comptime Engine: type, seed: u64) !void {
    var engine = if (Engine == alea.ChaCha) Engine.initFromU64(seed) else Engine.init(seed);
    try stdout.print("{s}", .{name});
    var i: usize = 0;
    while (i < 8) : (i += 1) {
        try stdout.print(" 0x{x}", .{engine.next()});
    }
    try stdout.print("\n", .{});
}
