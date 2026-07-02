const std = @import("std");
const alea = @import("alea");

const trials = 3;
const default_count = 16 * 1024 * 1024;

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

    try stdout.print("open-closed f64 probe count={}\n", .{sample_count});
    try benchFill(io, stdout, "facade fillOpenClosed", sample_count, facadeFill);
    try benchFill(io, stdout, "facade fillSample OpenClosed01", sample_count, facadeFillSample);
    try benchFill(io, stdout, "facade raw words 64", sample_count, facadeRawFill64);
    try benchFill(io, stdout, "facade raw words 96", sample_count, facadeRawFill96);
    try benchFill(io, stdout, "facade raw words 128", sample_count, facadeRawFill128);
    try benchFill(io, stdout, "facade raw int-add 128", sample_count, facadeRawFillIntAdd128);
    try benchFill(io, stdout, "facade raw div 128", sample_count, facadeRawFillDiv128);
    try benchFill(io, stdout, "facade raw complement 128", sample_count, facadeRawFillComplement128);
    try benchFill(io, stdout, "facade raw int-sub 128", sample_count, facadeRawFillIntSub128);
    try benchFill(io, stdout, "facade raw words 160", sample_count, facadeRawFill160);
    try benchFill(io, stdout, "facade raw words 192", sample_count, facadeRawFill192);
    try benchFill(io, stdout, "facade raw words 224", sample_count, facadeRawFill224);
    try benchFill(io, stdout, "facade raw words 256", sample_count, facadeRawFill256);
    try benchFill(io, stdout, "direct fillOpenClosedFrom", sample_count, directFill);
    try benchFill(io, stdout, "scalar next conversion", sample_count, scalarNextFill);
    try benchFill(io, stdout, "raw fill words 64", sample_count, rawFill64);
    try benchFill(io, stdout, "raw fill words 96", sample_count, rawFill96);
    try benchFill(io, stdout, "raw fill words 128", sample_count, rawFill128);
    try benchFill(io, stdout, "raw fill int-add 128", sample_count, rawFillIntAdd128);
    try benchFill(io, stdout, "raw fill div 128", sample_count, rawFillDiv128);
    try benchFill(io, stdout, "raw fill complement 128", sample_count, rawFillComplement128);
    try benchFill(io, stdout, "raw fill int-sub 128", sample_count, rawFillIntSub128);
    try benchFill(io, stdout, "raw fill words 512", sample_count, rawFill512);
    try benchFill(io, stdout, "raw fill words 2048", sample_count, rawFill2048);
    try stdout.flush();
}

fn benchFill(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    sample_count: usize,
    comptime fillFn: fn (*alea.FastPrng, []f64) void,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: f64 = 0;
    var out: [4096]f64 = undefined;

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0xf642);
        const start = std.Io.Clock.awake.now(io).nanoseconds;

        var remaining = sample_count;
        var checksum: f64 = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, out[0..n]);
            for (out[0..n]) |value| checksum += value;
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

fn facadeFill(engine: *alea.FastPrng, dest: []f64) void {
    const rng = alea.Rng.init(engine);
    rng.fillOpenClosed(f64, dest);
}

fn facadeFillSample(engine: *alea.FastPrng, dest: []f64) void {
    const rng = alea.Rng.init(engine);
    rng.fillSample(f64, dest, alea.distributions.OpenClosed01{});
}

fn facadeRawFill64(engine: *alea.FastPrng, dest: []f64) void {
    facadeRawFill(engine, dest, 64);
}

fn facadeRawFill96(engine: *alea.FastPrng, dest: []f64) void {
    facadeRawFill(engine, dest, 96);
}

fn facadeRawFill128(engine: *alea.FastPrng, dest: []f64) void {
    facadeRawFill(engine, dest, 128);
}

fn facadeRawFillIntAdd128(engine: *alea.FastPrng, dest: []f64) void {
    facadeRawFillIntAdd(engine, dest, 128);
}

fn facadeRawFillDiv128(engine: *alea.FastPrng, dest: []f64) void {
    facadeRawFillDiv(engine, dest, 128);
}

fn facadeRawFillComplement128(engine: *alea.FastPrng, dest: []f64) void {
    facadeRawFillComplement(engine, dest, 128);
}

fn facadeRawFillIntSub128(engine: *alea.FastPrng, dest: []f64) void {
    facadeRawFillIntSub(engine, dest, 128);
}

fn facadeRawFill160(engine: *alea.FastPrng, dest: []f64) void {
    facadeRawFill(engine, dest, 160);
}

fn facadeRawFill192(engine: *alea.FastPrng, dest: []f64) void {
    facadeRawFill(engine, dest, 192);
}

fn facadeRawFill224(engine: *alea.FastPrng, dest: []f64) void {
    facadeRawFill(engine, dest, 224);
}

fn facadeRawFill256(engine: *alea.FastPrng, dest: []f64) void {
    facadeRawFill(engine, dest, 256);
}

fn directFill(engine: *alea.FastPrng, dest: []f64) void {
    alea.Rng.fillOpenClosedFrom(engine, f64, dest);
}

fn scalarNextFill(engine: *alea.FastPrng, dest: []f64) void {
    for (dest) |*item| item.* = alea.Rng.floatOpenClosedFrom(engine, f64);
}

fn rawFill64(engine: *alea.FastPrng, dest: []f64) void {
    rawFill(engine, dest, 64);
}

fn rawFill96(engine: *alea.FastPrng, dest: []f64) void {
    rawFill(engine, dest, 96);
}

fn rawFill128(engine: *alea.FastPrng, dest: []f64) void {
    rawFill(engine, dest, 128);
}

fn rawFillIntAdd128(engine: *alea.FastPrng, dest: []f64) void {
    rawFillIntAdd(engine, dest, 128);
}

fn rawFillDiv128(engine: *alea.FastPrng, dest: []f64) void {
    rawFillDiv(engine, dest, 128);
}

fn rawFillComplement128(engine: *alea.FastPrng, dest: []f64) void {
    rawFillComplement(engine, dest, 128);
}

fn rawFillIntSub128(engine: *alea.FastPrng, dest: []f64) void {
    rawFillIntSub(engine, dest, 128);
}

fn rawFill512(engine: *alea.FastPrng, dest: []f64) void {
    rawFill(engine, dest, 512);
}

fn rawFill2048(engine: *alea.FastPrng, dest: []f64) void {
    rawFill(engine, dest, 2048);
}

fn facadeRawFill(engine: *alea.FastPrng, dest: []f64, comptime word_count: usize) void {
    const rng = alea.Rng.init(engine);
    var raw_words: [word_count]u64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, raw_words.len);
        rng.bytes(std.mem.sliceAsBytes(raw_words[0..take]));

        var lane: usize = 0;
        while (lane < take) : (lane += 1) {
            const raw = std.mem.littleToNative(u64, raw_words[lane]);
            dest[i + lane] = f64OpenClosedFromRaw(raw);
        }
        i += take;
    }
}

fn rawFill(engine: *alea.FastPrng, dest: []f64, comptime word_count: usize) void {
    var raw_words: [word_count]u64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, raw_words.len);
        engine.fill(std.mem.sliceAsBytes(raw_words[0..take]));

        var lane: usize = 0;
        while (lane < take) : (lane += 1) {
            const raw = std.mem.littleToNative(u64, raw_words[lane]);
            dest[i + lane] = f64OpenClosedFromRaw(raw);
        }
        i += take;
    }
}

fn facadeRawFillIntAdd(engine: *alea.FastPrng, dest: []f64, comptime word_count: usize) void {
    const rng = alea.Rng.init(engine);
    var raw_words: [word_count]u64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, raw_words.len);
        rng.bytes(std.mem.sliceAsBytes(raw_words[0..take]));

        var lane: usize = 0;
        while (lane < take) : (lane += 1) {
            const raw = std.mem.littleToNative(u64, raw_words[lane]);
            dest[i + lane] = f64OpenClosedFromRawIntAdd(raw);
        }
        i += take;
    }
}

fn rawFillIntAdd(engine: *alea.FastPrng, dest: []f64, comptime word_count: usize) void {
    var raw_words: [word_count]u64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, raw_words.len);
        engine.fill(std.mem.sliceAsBytes(raw_words[0..take]));

        var lane: usize = 0;
        while (lane < take) : (lane += 1) {
            const raw = std.mem.littleToNative(u64, raw_words[lane]);
            dest[i + lane] = f64OpenClosedFromRawIntAdd(raw);
        }
        i += take;
    }
}

fn facadeRawFillDiv(engine: *alea.FastPrng, dest: []f64, comptime word_count: usize) void {
    const rng = alea.Rng.init(engine);
    var raw_words: [word_count]u64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, raw_words.len);
        rng.bytes(std.mem.sliceAsBytes(raw_words[0..take]));

        var lane: usize = 0;
        while (lane < take) : (lane += 1) {
            const raw = std.mem.littleToNative(u64, raw_words[lane]);
            dest[i + lane] = f64OpenClosedFromRawDiv(raw);
        }
        i += take;
    }
}

fn rawFillDiv(engine: *alea.FastPrng, dest: []f64, comptime word_count: usize) void {
    var raw_words: [word_count]u64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, raw_words.len);
        engine.fill(std.mem.sliceAsBytes(raw_words[0..take]));

        var lane: usize = 0;
        while (lane < take) : (lane += 1) {
            const raw = std.mem.littleToNative(u64, raw_words[lane]);
            dest[i + lane] = f64OpenClosedFromRawDiv(raw);
        }
        i += take;
    }
}

fn facadeRawFillComplement(engine: *alea.FastPrng, dest: []f64, comptime word_count: usize) void {
    const rng = alea.Rng.init(engine);
    var raw_words: [word_count]u64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, raw_words.len);
        rng.bytes(std.mem.sliceAsBytes(raw_words[0..take]));

        var lane: usize = 0;
        while (lane < take) : (lane += 1) {
            const raw = std.mem.littleToNative(u64, raw_words[lane]);
            dest[i + lane] = f64OpenClosedFromRawComplement(raw);
        }
        i += take;
    }
}

fn rawFillComplement(engine: *alea.FastPrng, dest: []f64, comptime word_count: usize) void {
    var raw_words: [word_count]u64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, raw_words.len);
        engine.fill(std.mem.sliceAsBytes(raw_words[0..take]));

        var lane: usize = 0;
        while (lane < take) : (lane += 1) {
            const raw = std.mem.littleToNative(u64, raw_words[lane]);
            dest[i + lane] = f64OpenClosedFromRawComplement(raw);
        }
        i += take;
    }
}

fn facadeRawFillIntSub(engine: *alea.FastPrng, dest: []f64, comptime word_count: usize) void {
    const rng = alea.Rng.init(engine);
    var raw_words: [word_count]u64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, raw_words.len);
        rng.bytes(std.mem.sliceAsBytes(raw_words[0..take]));

        var lane: usize = 0;
        while (lane < take) : (lane += 1) {
            const raw = std.mem.littleToNative(u64, raw_words[lane]);
            dest[i + lane] = f64OpenClosedFromRawIntSub(raw);
        }
        i += take;
    }
}

fn rawFillIntSub(engine: *alea.FastPrng, dest: []f64, comptime word_count: usize) void {
    var raw_words: [word_count]u64 = undefined;

    var i: usize = 0;
    while (i < dest.len) {
        const take = @min(dest.len - i, raw_words.len);
        engine.fill(std.mem.sliceAsBytes(raw_words[0..take]));

        var lane: usize = 0;
        while (lane < take) : (lane += 1) {
            const raw = std.mem.littleToNative(u64, raw_words[lane]);
            dest[i + lane] = f64OpenClosedFromRawIntSub(raw);
        }
        i += take;
    }
}

fn f64OpenClosedFromRaw(raw: u64) f64 {
    return (@as(f64, @floatFromInt(raw >> 11)) + 1.0) * (1.0 / 9007199254740992.0);
}

fn f64OpenClosedFromRawIntAdd(raw: u64) f64 {
    return @as(f64, @floatFromInt((raw >> 11) + 1)) * (1.0 / 9007199254740992.0);
}

fn f64OpenClosedFromRawDiv(raw: u64) f64 {
    return (@as(f64, @floatFromInt(raw >> 11)) + 1.0) / 9007199254740992.0;
}

fn f64OpenClosedFromRawComplement(raw: u64) f64 {
    return 1.0 - @as(f64, @floatFromInt(raw >> 11)) * (1.0 / 9007199254740992.0);
}

fn f64OpenClosedFromRawIntSub(raw: u64) f64 {
    return @as(f64, @floatFromInt((@as(u64, 1) << 53) - (raw >> 11))) * (1.0 / 9007199254740992.0);
}
