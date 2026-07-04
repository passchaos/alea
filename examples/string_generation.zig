const std = @import("std");
const alea = @import("alea");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var engine = alea.ScalarPrng.init(0x57_1e_600d);

    const token = try alea.ascii.stringFrom(allocator, &engine, 16);
    defer allocator.free(token);

    var lower_buf: [12]u8 = undefined;
    alea.ascii.Lowercase.fillFrom(&engine, &lower_buf);

    const custom = alea.ascii.Charset.init("ABC123-_");
    var probabilities: [8]f64 = undefined;
    try custom.probabilitiesInto(&probabilities);
    var custom_buf: [16]u8 = undefined;
    custom.fillFrom(&engine, &custom_buf);
    const custom_alloc = try custom.allocFrom(allocator, &engine, 10);
    defer allocator.free(custom_alloc);

    const scalar = alea.ascii.unicodeScalarFrom(&engine);
    const utf8 = try alea.ascii.unicodeUtf8AllocFrom(allocator, &engine, 6);
    defer allocator.free(utf8);

    var utf8_buf: [try alea.ascii.unicodeUtf8Capacity(6)]u8 = undefined;
    const utf8_into = try alea.ascii.unicodeUtf8IntoFrom(&engine, &utf8_buf, 6);

    const maybe_empty = alea.ascii.Charset{ .bytes = "" };
    const empty_checked_name = if (maybe_empty.sampleCheckedFrom(&engine)) |_| "unexpected-success" else |err| @errorName(err);

    try stdout.print("alphanumeric string: {s}\n", .{token});
    try stdout.print("lowercase fill: {s}\n", .{lower_buf});
    try stdout.print("custom charset probabilities: {any}\n", .{probabilities});
    try stdout.print("custom charset fill: {s}\n", .{custom_buf});
    try stdout.print("custom charset alloc: {s}\n", .{custom_alloc});
    try stdout.print("unicode scalar: U+{X:0>4}\n", .{scalar});
    try stdout.print("unicode utf8 alloc: {s}\n", .{utf8});
    try stdout.print("unicode utf8 into: {s}\n", .{utf8_into});
    try stdout.print("empty charset checked result: {s}\n", .{empty_checked_name});
    try stdout.print("\nUse predefined ASCII charsets for common tokens, Charset for custom alphabets and diagnostics, and unicodeUtf8Capacity/unicodeUtf8Into for caller-owned UTF-8 buffers.\n", .{});
    try stdout.flush();
}
