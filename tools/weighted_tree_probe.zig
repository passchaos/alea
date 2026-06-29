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

    try stdout.print("weighted tree probe count={}\n", .{sample_count});
    try benchFill(io, stdout, "weighted tree current fill", sample_count, currentFill);
    try benchFill(io, stdout, "weighted tree inline traversal", sample_count, inlineTraversalFill);
    try stdout.flush();
}

fn benchFill(
    io: std.Io,
    stdout: *std.Io.Writer,
    comptime name: []const u8,
    sample_count: usize,
    comptime fillFn: anytype,
) !void {
    var best_million_per_s: f64 = 0;
    var best_checksum: usize = 0;
    var out: [1024]usize = undefined;
    const initial = [_]u32{ 1, 2, 3, 0, 5, 8, 13, 21 };

    var trial: usize = 0;
    while (trial < trials) : (trial += 1) {
        var engine = alea.FastPrng.init(0x77ee);
        var tree = try alea.distributions.WeightedTree(u32).init(std.heap.smp_allocator, &initial);
        defer tree.deinit();

        const start = std.Io.Clock.awake.now(io).nanoseconds;
        var remaining = sample_count;
        var checksum: usize = 0;
        while (remaining > 0) {
            const n = @min(remaining, out.len);
            fillFn(&engine, tree, out[0..n]);
            for (out[0..n]) |value| checksum +%= value;
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
    try stdout.print("{s}: {d:.1} M samples/s checksum={}\n", .{ name, best_million_per_s, best_checksum });
}

fn currentFill(source: *alea.FastPrng, tree: alea.distributions.WeightedTree(u32), dest: []usize) void {
    tree.fillFrom(source, dest);
}

fn inlineTraversalFill(source: *alea.FastPrng, tree: alea.distributions.WeightedTree(u32), dest: []usize) void {
    const items = tree.subtotals.items;
    const total = items[0];
    for (dest) |*slot| {
        var target = alea.Rng.floatFrom(source, f64) * total;
        var index: usize = 0;
        while (true) {
            const left_index = 2 * index + 1;
            const left = if (left_index < items.len) items[left_index] else 0;
            if (target < left) {
                index = left_index;
                continue;
            }
            target -= left;

            const right_index = left_index + 1;
            const right = if (right_index < items.len) items[right_index] else 0;
            if (target < right) {
                index = right_index;
                continue;
            }
            target -= right;

            const own = items[index] - left - right;
            if (target < own or own > 0) {
                slot.* = index;
                break;
            }
        }
    }
}
