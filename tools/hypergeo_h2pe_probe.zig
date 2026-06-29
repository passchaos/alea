const std = @import("std");
const alea = @import("alea");

const trials = 3;
const default_count = 128 * 1024 * 1024 / 256;

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

    try benchCurrent(io, stdout, sample_count);
    try stdout.flush();
}

fn benchCurrent(io: std.Io, stdout: *std.Io.Writer, sample_count: usize) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: u64 = 0;
    const dist = alea.distributions.Hypergeometric.init(5000, 2500, 500) catch unreachable;
    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.ScalarPrng.init(0x4966);
        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var checksum: u64 = 0;
        var i: usize = 0;
        while (i < sample_count) : (i += 1) checksum +%= dist.sampleFrom(&engine);
        const elapsed_ns = std.Io.Clock.awake.now(io).nanoseconds - start;
        const million_per_s = (@as(f64, @floatFromInt(sample_count)) / 1_000_000.0) /
            (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
        if (million_per_s > best_million_per_s) {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    std.mem.doNotOptimizeAway(best_checksum);
    try stdout.print(
        "current large hypergeometric scalar direct: {d:.1} M samples/s count={} checksum={}\n",
        .{ best_million_per_s, sample_count, best_checksum },
    );
}
