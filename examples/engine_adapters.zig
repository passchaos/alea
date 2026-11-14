const std = @import("std");
const alea = @import("alea");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    // Reseed a fast engine from a deterministic source every four draws.
    var reseeder_engine = alea.SplitMix64.init(0x5eed);
    var adapter = alea.rngs.ReseedingRng(alea.Xoshiro256PlusPlus).init(
        alea.Xoshiro256PlusPlus.seedFromU64(7),
        alea.Rng.init(&reseeder_engine),
        4,
    );
    const rng = alea.Rng.init(&adapter);
    var values: [6]u64 = undefined;
    for (&values) |*value| value.* = rng.nextU64();
    try stdout.print("reseeding draws: {any}\n", .{values});
    try stdout.print("reseeds: {}\n", .{adapter.reseedCount()});

    // Replay a captured byte stream through the same facade.
    const captured = [_]u8{
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10,
    };
    var replay_reader = std.Io.Reader.fixed(&captured);
    var replay_source = alea.rngs.ReaderRng.init(&replay_reader);
    const replay_rng = alea.Rng.init(&replay_source);
    const first = replay_rng.nextU64();
    const second = replay_rng.nextU32();
    try stdout.print("replayed word: 0x{x}, u32: 0x{x}\n", .{ first, second });

    // The comptime-specialized view works over the adapter as well.
    const specialized = alea.RngOf(alea.rngs.ReseedingRng(alea.Xoshiro256PlusPlus)).init(&adapter);
    const uniform = specialized.float(f64);
    try stdout.print("specialized uniform: {d:.6}\n", .{uniform});
    try stdout.flush();
}
