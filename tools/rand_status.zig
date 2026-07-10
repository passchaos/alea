const std = @import("std");

const schema_version = 1;

const OutputMode = enum { text, json, schema_version, help, self_test };

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
        .schema_version => try printSchemaVersion(stdout),
        .help => try printUsage(stdout),
        .self_test => try runSelfTest(stdout),
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
    if (std.mem.eql(u8, arg, "--schema-version")) return .schema_version;
    if (std.mem.eql(u8, arg, "--help")) return .help;
    if (std.mem.eql(u8, arg, "--self-test")) return .self_test;
    _ = current;
    return error.UnknownArgument;
}

fn printUsage(writer: *std.Io.Writer) !void {
    try writer.print(
        \\usage: rand-status [--json]
        \\       rand-status --schema-version
        \\       rand-status --self-test
        \\       rand-status --help
        \\       --json prints the current local rand/rand_distr status as stable JSON
        \\       --schema-version prints the stable JSON schema version
        \\       --self-test validates text, JSON, help, and bad-argument paths without Rust tools
        \\
    , .{});
}

fn runSelfTest(stdout: *std.Io.Writer) !void {
    var text_buf: [2048]u8 = undefined;
    var text_writer = std.Io.Writer.fixed(&text_buf);
    try printStatus(&text_writer);
    const text = std.Io.Writer.buffered(&text_writer);
    if (!hasAll(text, &.{
        "Alea local rand/rand_distr status",
        "~/Work/rand",
        "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1185 follow-ups closed for current bar",
        "no known unblocked local Rust core RNG gap",
        "S4-M11",
        "compare/results/s4-m420-current-rand-status.md",
    })) return error.SelfTestFailed;

    var json_buf: [4096]u8 = undefined;
    var json_writer = std.Io.Writer.fixed(&json_buf);
    try printJson(&json_writer);
    const json = std.Io.Writer.buffered(&json_writer);
    if (!hasAll(json, &.{
        "\"schema_version\": 1",
        "\"baseline\"",
        "\"rand\": \"~/Work/rand\"",
        "\"validate_local_passes\": true",
        "\"opportunity_runners_available\": false",
        "\"current_conclusion\": \"S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1185 follow-ups closed for current bar\"",
        "\"no_known_unblocked_gap\": true",
        "\"remaining_blocker\": \"S4-M1186",
        "\"s4_m11_blocked\": false",
        "\"details\": \"compare/results/s4-m420-current-rand-status.md\"",
        "\"local_rand_status\": \"compare/results/s4-m420-current-rand-status.md\"",
        "\"blocker_audit\": \"compare/results/s4-m11-blocker-audit.md\"",
        "\"latest_validate_local_evidence\": \"compare/results/s4-m1185-dense-simd-probe-refresh.md\"",
    })) return error.SelfTestFailed;

    var help_buf: [1024]u8 = undefined;
    var help_writer = std.Io.Writer.fixed(&help_buf);
    try printUsage(&help_writer);
    const help = std.Io.Writer.buffered(&help_writer);
    if (!hasAll(help, &.{
        "usage: rand-status [--json]",
        "rand-status --schema-version",
        "rand-status --self-test",
        "--json prints the current local rand/rand_distr status as stable JSON",
        "--schema-version prints the stable JSON schema version",
        "--self-test validates text, JSON, help, and bad-argument paths without Rust tools",
    })) return error.SelfTestFailed;
    var version_buf: [32]u8 = undefined;
    var version_writer = std.Io.Writer.fixed(&version_buf);
    try printSchemaVersion(&version_writer);
    if (!std.mem.eql(u8, std.Io.Writer.buffered(&version_writer), "1\n")) return error.SelfTestFailed;
    if (parseModeSlice(&.{"--definitely-bad"})) |_| {
        return error.SelfTestFailed;
    } else |err| {
        if (err != error.UnknownArgument) return error.SelfTestFailed;
    }

    try stdout.print("rand-status self-test ok\n", .{});
}

fn hasAll(haystack: []const u8, needles: []const []const u8) bool {
    for (needles) |needle| {
        if (std.mem.indexOf(u8, haystack, needle) == null) return false;
    }
    return true;
}

fn printStatus(stdout: *std.Io.Writer) !void {
    try stdout.print(
        \\Alea local rand/rand_distr status (2026-07-10)
        \\- Baseline: ~/Work/rand plus cached rand_distr 0.6.0
        \\- Latest gate: zig build validate-local passes
        \\- Public surface: surfacecheck ok for rand/rand_core/rand_distr manifests
        \\- Rust comparison: parser tests and rand-bench-smoke pass
        \\- Runtime runners: node/cargo/rustc found; Wasmtime 31.0.0 profilelongcheck evidence recorded
        \\- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1185 follow-ups closed for current bar
        \\- Local Rust gap: no known unblocked local Rust core RNG gap
        \\- Next bar: S4-M1186 post-S4-M1185 exact/default dense SIMD, broader runtime, or new local Rust gap
        \\- Details: compare/results/s4-m420-current-rand-status.md
        \\
    , .{});
}

fn printSchemaVersion(stdout: *std.Io.Writer) !void {
    try stdout.print("{d}\n", .{schema_version});
}

fn printJson(stdout: *std.Io.Writer) !void {
    try stdout.writeAll(
        \\{
        \\  "schema_version": 1,
        \\  "date": "2026-07-10",
        \\  "baseline": {
        \\    "rand": "~/Work/rand",
        \\    "rand_distr": "cached rand_distr 0.6.0"
        \\  },
        \\  "latest_gate": "zig build validate-local passes",
        \\  "validate_local_passes": true,
        \\  "public_surface": "surfacecheck ok for rand/rand_core/rand_distr manifests",
        \\  "rust_comparison": "parser tests and rand-bench-smoke pass",
        \\  "runtime_runners": "node/cargo/rustc found; Wasmtime 31.0.0 profilelongcheck evidence recorded",
        \\  "opportunity_runners_available": false,
        \\  "current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1185 follow-ups closed for current bar",
        \\  "no_known_unblocked_gap": true,
        \\  "remaining_blocker": "S4-M1186 post-S4-M1185 next product bar",
        \\  "s4_m11_blocked": false,
        \\  "details": "compare/results/s4-m420-current-rand-status.md",
        \\  "local_rand_status": "compare/results/s4-m420-current-rand-status.md",
        \\  "blocker_audit": "compare/results/s4-m11-blocker-audit.md",
        \\  "latest_validate_local_evidence": "compare/results/s4-m1185-dense-simd-probe-refresh.md"
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
    try std.testing.expect(std.mem.indexOf(u8, out, "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1185 follow-ups closed for current bar") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "no known unblocked local Rust core RNG gap") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "S4-M11") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "compare/results/s4-m420-current-rand-status.md") != null);
}

test "json output keeps stable machine-readable status keys" {
    var buf: [4096]u8 = undefined;
    var writer = std.Io.Writer.fixed(&buf);
    try printJson(&writer);
    const out = std.Io.Writer.buffered(&writer);

    try std.testing.expect(std.mem.indexOf(u8, out, "\"schema_version\": 1") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"baseline\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"rand\": \"~/Work/rand\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"rand_distr\": \"cached rand_distr 0.6.0\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"validate_local_passes\": true") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"opportunity_runners_available\": false") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"current_conclusion\": \"S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1185 follow-ups closed for current bar\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"no_known_unblocked_gap\": true") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"remaining_blocker\": \"S4-M1186") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"s4_m11_blocked\": false") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"details\": \"compare/results/s4-m420-current-rand-status.md\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"local_rand_status\": \"compare/results/s4-m420-current-rand-status.md\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"blocker_audit\": \"compare/results/s4-m11-blocker-audit.md\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "\"latest_validate_local_evidence\": \"compare/results/s4-m1185-dense-simd-probe-refresh.md\"") != null);
}

test "argument parser supports text json and help" {
    try std.testing.expectEqual(OutputMode.text, try parseModeSlice(&.{}));
    try std.testing.expectEqual(OutputMode.json, try parseModeSlice(&.{"--json"}));
    try std.testing.expectEqual(OutputMode.schema_version, try parseModeSlice(&.{"--schema-version"}));
    try std.testing.expectEqual(OutputMode.help, try parseModeSlice(&.{"--help"}));
    try std.testing.expectEqual(OutputMode.self_test, try parseModeSlice(&.{"--self-test"}));
    try std.testing.expectEqual(OutputMode.help, try parseModeSlice(&.{ "--json", "--help" }));
    try std.testing.expectError(error.UnknownArgument, parseModeSlice(&.{"--bad"}));
}

test "self-test validates text json and help output" {
    var buf: [128]u8 = undefined;
    var writer = std.Io.Writer.fixed(&buf);
    try runSelfTest(&writer);
    try std.testing.expectEqualStrings("rand-status self-test ok\n", std.Io.Writer.buffered(&writer));
}
