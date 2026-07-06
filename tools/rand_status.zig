const std = @import("std");

const OutputMode = enum { text, json, help };

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var stderr_buffer: [1024]u8 = undefined;
    var stderr_file = std.Io.File.stderr().writer(init.io, &stderr_buffer);
    const stderr = &stderr_file.interface;

    var args = std.process.Args.Iterator.init(init.minimal.args);
    defer args.deinit();
    _ = args.next();
    const mode = parseModeIterator(&args) catch |err| switch (err) {
        error.UnknownArgument => {
            try printUsage(stderr);
            try stderr.flush();
            return err;
        },
    };

    switch (mode) {
        .text => try printStatus(stdout),
        .json => try printJson(stdout),
        .help => try printUsage(stdout),
    }
    try stdout.flush();
}

fn parseModeIterator(args: *std.process.Args.Iterator) !OutputMode {
    var mode: OutputMode = .text;
    while (args.next()) |arg| {
        mode = try parseModeArg(mode, arg);
    }
    return mode;
}

fn parseModeSlice(args: []const []const u8) !OutputMode {
    var mode: OutputMode = .text;
    for (args) |arg| {
        mode = try parseModeArg(mode, arg);
    }
    return mode;
}

fn parseModeArg(current: OutputMode, arg: []const u8) !OutputMode {
    if (std.mem.eql(u8, arg, "--json")) return .json;
    if (std.mem.eql(u8, arg, "--help")) return .help;
    _ = current;
    return error.UnknownArgument;
}

fn printUsage(writer: *std.Io.Writer) !void {
    try writer.print(
        \\usage: rand-status [--json]
        \\       rand-status --help
        \\       --json prints the current local rand/rand_distr status as stable JSON
        \\
    , .{});
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

fn printJson(stdout: *std.Io.Writer) !void {
    try stdout.writeAll(
        \\{
        \\  "date": "2026-07-06",
        \\  "baseline": {
        \\    "rand": "~/Work/rand",
        \\    "rand_distr": "cached rand_distr 0.6.0"
        \\  },
        \\  "latest_gate": "zig build validate-local passes",
        \\  "public_surface": "surfacecheck ok for rand/rand_core/rand_distr manifests",
        \\  "rust_comparison": "parser tests and rand-bench-smoke pass",
        \\  "runtime_runners": "node/cargo/rustc found; qemu/wine/wasmtime/wasmer not available",
        \\  "current_conclusion": "no known unblocked local Rust core RNG gap",
        \\  "remaining_blocker": "S4-M11 exact/default dense SIMD winner, new runtime, or new local Rust gap",
        \\  "details": "compare/results/s4-m420-current-rand-status.md"
        \\}
        \\
    );
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

test "json output keeps stable machine-readable status keys" {
    var buf: [4096]u8 = undefined;
    var writer = std.Io.Writer.fixed(&buf);
    try printJson(&writer);
    const out = std.Io.Writer.buffered(&writer);

    try std.testing.expect(std.mem.indexOf(u8, out, "\"baseline\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"rand\": \"~/Work/rand\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"rand_distr\": \"cached rand_distr 0.6.0\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"current_conclusion\": \"no known unblocked local Rust core RNG gap\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"remaining_blocker\": \"S4-M11") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"details\": \"compare/results/s4-m420-current-rand-status.md\"") != null);
}

test "argument parser supports text json and help" {
    try std.testing.expectEqual(OutputMode.text, try parseModeSlice(&.{}));
    try std.testing.expectEqual(OutputMode.json, try parseModeSlice(&.{"--json"}));
    try std.testing.expectEqual(OutputMode.help, try parseModeSlice(&.{"--help"}));
    try std.testing.expectEqual(OutputMode.help, try parseModeSlice(&.{ "--json", "--help" }));
    try std.testing.expectError(error.UnknownArgument, parseModeSlice(&.{"--bad"}));
}
