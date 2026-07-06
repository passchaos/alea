const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [2048]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    try printStatus(stdout);
    try stdout.flush();
}

fn printStatus(stdout: *std.Io.Writer) !void {
    try stdout.print(
        \\Alea local rand/rand_distr status (2026-07-06)
        \\- Baseline: ~/Work/rand plus cached rand_distr 0.6.0
        \\- Latest gate: zig build validate-local passes
        \\- Public surface: surfacecheck ok for rand/rand_core/rand_distr manifests
        \\- Rust comparison: parser tests and rand-bench-smoke pass
        \\- Runtime runners: node/cargo/rustc found; qemu/wine/wasmtime/wasmer not available
        \\- Current conclusion: no known unblocked local Rust core RNG gap
        \\- Remaining blocker: S4-M11 exact/default dense SIMD winner, new runtime, or new local Rust gap
        \\- Details: compare/results/s4-m420-current-rand-status.md
        \\
    , .{});
}

test "status output keeps key local rand comparison tokens" {
    var buf: [2048]u8 = undefined;
    var writer = std.Io.Writer.fixed(&buf);
    try printStatus(&writer);
    const out = std.Io.Writer.buffered(&writer);

    try std.testing.expect(std.mem.indexOf(u8, out, "Alea local rand/rand_distr status") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "~/Work/rand") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "rand_distr 0.6.0") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "zig build validate-local passes") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "surfacecheck ok") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "rand-bench-smoke pass") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "no known unblocked local Rust core RNG gap") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "S4-M11") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "compare/results/s4-m420-current-rand-status.md") != null);
}
