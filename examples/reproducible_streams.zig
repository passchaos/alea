const std = @import("std");
const alea = @import("alea");

fn printNext(stdout: *std.Io.Writer, label: []const u8, engine: anytype, count: usize) !void {
    try stdout.print("{s}:", .{label});
    var i: usize = 0;
    while (i < count) : (i += 1) try stdout.print(" 0x{x}", .{engine.next()});
    try stdout.print("\n", .{});
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const experiment = alea.Seed.fromString("experiment:demo");
    const sampling_seed = experiment.mix("sampling");
    const audit_seed = experiment.mix("audit");

    try stdout.print("experiment seed: 0x{x}\n", .{experiment.state});
    try stdout.print("sampling stream[0]: 0x{x}\n", .{sampling_seed.stream(0).state});
    try stdout.print("sampling stream[1]: 0x{x}\n", .{sampling_seed.stream(1).state});
    try stdout.print("audit stream[0]: 0x{x}\n", .{audit_seed.stream(0).state});

    var default_engine = alea.default(sampling_seed.stream(0).state);
    var fast_engine = alea.fast(sampling_seed.stream(1).state);
    var scalar_engine = alea.scalar(sampling_seed.stream(2).state);
    var reproducible_engine = alea.reproducible(sampling_seed.stream(3).state);
    var secure_style_engine = alea.secureFromSeed(sampling_seed.stream(4).state);
    var raw_alias_engine = alea.DefaultPrng.init(sampling_seed.stream(5).state);
    const engine_raw64 = raw_alias_engine.nextU64();
    const engine_raw32 = raw_alias_engine.nextU32();
    var engine_fill_bytes: [8]u8 = undefined;
    raw_alias_engine.fillBytes(&engine_fill_bytes);
    var seed_alias_engine = alea.DefaultPrng.seedFromU64(sampling_seed.stream(6).state);
    var from_seed_alias_engine = alea.DefaultPrng.fromSeed(sampling_seed.stream(7));
    const byte_seed = [_]u8{
        0x30, 0x65, 0x6c, 0x61, 0x2d, 0x73, 0x65, 0x65,
        0x64, 0x2d, 0x62, 0x79, 0x74, 0x65, 0x73, 0x21,
        0x5a, 0x69, 0x67, 0x2d, 0x72, 0x6e, 0x67, 0x21,
        0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
    };
    var from_seed_bytes_alias_engine = alea.DefaultPrng.fromSeedBytes(byte_seed);
    var from_rng_source = alea.ScalarPrng.init(sampling_seed.stream(8).state);
    var from_rng_alias_engine = alea.DefaultPrng.fromRng(&from_rng_source);
    var fork_parent = alea.DefaultPrng.init(sampling_seed.stream(9).state);
    var fork_child = fork_parent.fork();

    try printNext(stdout, "DefaultPrng/Xoshiro256", &default_engine, 3);
    try printNext(stdout, "FastPrng/Alea4x64", &fast_engine, 3);
    try printNext(stdout, "ScalarPrng/Wyhash64", &scalar_engine, 3);
    try printNext(stdout, "ReproduciblePrng/Pcg64", &reproducible_engine, 3);
    try printNext(stdout, "SecurePrng/ChaCha12-from-seed", &secure_style_engine, 3);
    try stdout.print("engine raw aliases: nextU64=0x{x}, nextU32=0x{x}, fillBytes={any}\n", .{ engine_raw64, engine_raw32, engine_fill_bytes });
    try stdout.print("engine seedFromU64 alias next: 0x{x}\n", .{seed_alias_engine.next()});
    try stdout.print("engine fromSeed alias next: 0x{x}\n", .{from_seed_alias_engine.next()});
    try stdout.print("engine fromSeedBytes alias next: 0x{x}\n", .{from_seed_bytes_alias_engine.next()});
    try stdout.print("engine fromRng alias next: 0x{x}, fork child next: 0x{x}\n", .{ from_rng_alias_engine.next(), fork_child.next() });

    var parent_a = alea.Xoshiro256.init(0x5150);
    var parent_b = alea.Xoshiro256.init(0x5150);
    var child_a = parent_a.split();
    var child_b = parent_b.split();
    try stdout.print("xoshiro split reproducible: parent-next equal={}, child-next equal={}\n", .{ parent_a.next() == parent_b.next(), child_a.next() == child_b.next() });

    var jumped = alea.Xoshiro256PlusPlus.init(0x5150);
    jumped.jump();
    try printNext(stdout, "Xoshiro256++ after jump", &jumped, 2);

    var pcg_stream_7 = alea.Pcg64.initTwo(0x5150, 7);
    var pcg_stream_8 = alea.Pcg64.initTwo(0x5150, 8);
    try printNext(stdout, "Pcg64 seed=0x5150 stream=7", &pcg_stream_7, 2);
    try printNext(stdout, "Pcg64 seed=0x5150 stream=8", &pcg_stream_8, 2);

    try stdout.print("\nUse Seed.mix and Seed.stream for stable named substreams; choose Default/Fast/Scalar/Reproducible/Secure-style engines by workload and reproducibility contract.\n", .{});
    try stdout.flush();
}
