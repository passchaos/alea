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
    const sample_string = try alea.ascii.Alphanumeric.sampleStringFrom(allocator, &engine, 12);
    defer allocator.free(sample_string);
    const dist_alpha = alea.Rng.sampleFrom(&engine, u8, alea.distributions.Alphanumeric);
    const dist_letter = alea.Rng.sampleFrom(&engine, u8, alea.distributions.Alphabetic);
    var appended = try std.ArrayList(u8).initCapacity(allocator, 8);
    defer appended.deinit(allocator);
    try appended.appendSlice(allocator, "tag:");
    try alea.ascii.Alphanumeric.appendStringFrom(allocator, &engine, &appended, 8);

    var lower_buf: [12]u8 = undefined;
    alea.ascii.Lowercase.fillFrom(&engine, &lower_buf);

    const custom = alea.ascii.Charset.init("ABC123-_");
    var probabilities: [8]f64 = undefined;
    try custom.probabilitiesInto(&probabilities);
    const custom_num_choices = custom.numChoices();
    const custom_constant_index = custom.constantIndex();
    const custom_item = try custom.item(0);
    const custom_item_buf = [_]u8{custom_item};
    const custom_get = custom.get(0).?;
    const custom_get_missing = custom.get(custom.len()) == null;
    const custom_get_buf = [_]u8{custom_get};
    const custom_probability = custom.probability(0).?;
    const custom_missing_probability = custom.probability(custom.len()) == null;
    var custom_probability_iter = custom.probabilityIter();
    var custom_probability_iter_fill: [4]f64 = undefined;
    _ = custom_probability_iter.fill(&custom_probability_iter_fill);
    const custom_probability_iter_hint = custom_probability_iter.sizeHint();
    var custom_buf: [16]u8 = undefined;
    custom.fillFrom(&engine, &custom_buf);
    const custom_alloc = try custom.allocFrom(allocator, &engine, 10);
    defer allocator.free(custom_alloc);

    const scalar = alea.ascii.unicodeScalarFrom(&engine);
    const rng = alea.Rng.init(&engine);
    var scalar_fill: [4]u21 = undefined;
    rng.fillUnicodeScalar(&scalar_fill);
    const scalar_batch = try rng.unicodeScalarBatch(allocator, 4);
    defer allocator.free(scalar_batch);
    var scalar_range_fill: [4]u21 = undefined;
    try rng.fillUnicodeScalarRangeLessThanChecked(&scalar_range_fill, 0xD7F0, 0xE010);
    const scalar_range_batch = try rng.unicodeScalarRangeAtMostBatchChecked(allocator, 4, 0x41, 0x5A);
    defer allocator.free(scalar_range_batch);
    const scalar_range_sampler = try alea.distributions.UniformUnicodeScalar.newInclusive(0x41, 0x5A);
    var scalar_range_sampler_values: [4]u21 = undefined;
    scalar_range_sampler.fillFrom(&engine, &scalar_range_sampler_values);
    const utf8 = try alea.ascii.unicodeUtf8AllocFrom(allocator, &engine, 6);
    defer allocator.free(utf8);

    var utf8_buf: [try alea.ascii.unicodeUtf8Capacity(6)]u8 = undefined;
    const utf8_into = try alea.ascii.unicodeUtf8IntoFrom(&engine, &utf8_buf, 6);
    const unicode_symbols = alea.ascii.UnicodeCharset.init(&.{ 'α', 'β', 'γ', 0x1F600 });
    const unicode_symbol_string = try unicode_symbols.sampleStringFrom(allocator, &engine, 8);
    defer allocator.free(unicode_symbol_string);
    var unicode_appended = try std.ArrayList(u8).initCapacity(allocator, 8);
    defer unicode_appended.deinit(allocator);
    try unicode_appended.appendSlice(allocator, "u:");
    try unicode_symbols.appendStringFrom(allocator, &engine, &unicode_appended, 5);
    const unicode_symbol_choices = unicode_symbols.numChoices();
    const unicode_symbol_max_utf8 = unicode_symbols.maxUtf8Len();

    const maybe_empty = alea.ascii.Charset{ .bytes = "" };
    const empty_checked_name = if (maybe_empty.sampleCheckedFrom(&engine)) |_| "unexpected-success" else |err| @errorName(err);
    const single_charset = alea.ascii.Charset.init("Z");

    try stdout.print("alphanumeric string: {s}\n", .{token});
    try stdout.print("sampleString alphanumeric: {s}\n", .{sample_string});
    try stdout.print("distribution Alphanumeric/Alphabetic bytes: {c}/{c}\n", .{ dist_alpha, dist_letter });
    try stdout.print("appendString alphanumeric: {s}\n", .{appended.items});
    try stdout.print("lowercase fill: {s}\n", .{lower_buf});
    try stdout.print("custom charset probabilities: {any}\n", .{probabilities});
    try stdout.print("custom charset numChoices: {}\n", .{custom_num_choices});
    try stdout.print("custom charset constantIndex: {?}\n", .{custom_constant_index});
    try stdout.print("custom charset item(0)={s}\n", .{&custom_item_buf});
    try stdout.print("custom charset get(0)={s} missing={}\n", .{ &custom_get_buf, custom_get_missing });
    try stdout.print("custom charset probability(0)={d:.3} missing={}\n", .{ custom_probability, custom_missing_probability });
    try stdout.print("custom charset probabilityIter fill: {any}\n", .{custom_probability_iter_fill});
    try stdout.print("custom charset probabilityIter sizeHint: {}..{}\n", .{ custom_probability_iter_hint.lower, custom_probability_iter_hint.upper.? });
    try stdout.print("custom charset fill: {s}\n", .{custom_buf});
    try stdout.print("custom charset alloc: {s}\n", .{custom_alloc});
    try stdout.print("unicode scalar: U+{X:0>4}\n", .{scalar});
    try stdout.print("unicode scalar fill: {any}\n", .{scalar_fill});
    try stdout.print("unicode scalar batch: {any}\n", .{scalar_batch});
    try stdout.print("unicode scalar range fill: {any}\n", .{scalar_range_fill});
    try stdout.print("unicode scalar range batch: {any}\n", .{scalar_range_batch});
    try stdout.print("UniformUnicodeScalar range sampler: {any}\n", .{scalar_range_sampler_values});
    try stdout.print("unicode utf8 alloc: {s}\n", .{utf8});
    try stdout.print("unicode utf8 into: {s}\n", .{utf8_into});
    try stdout.print("unicode charset sampleString: {s}\n", .{unicode_symbol_string});
    try stdout.print("unicode charset appendString: {s}\n", .{unicode_appended.items});
    try stdout.print("UnicodeCharset numChoices={} maxUtf8Len={}\n", .{ unicode_symbol_choices, unicode_symbol_max_utf8 });
    try stdout.print("single charset constantIndex: {?}\n", .{single_charset.constantIndex()});
    try stdout.print("empty charset checked result: {s}\n", .{empty_checked_name});
    try stdout.print("\nUse predefined ASCII charsets for common tokens, Charset for custom alphabets and diagnostics, UnicodeCharset for reusable Unicode scalar alphabets, unicodeScalarBatch/fillUnicodeScalar plus range variants for codepoint batches, and unicodeUtf8Capacity/unicodeUtf8Into for caller-owned UTF-8 buffers.\n", .{});
    try stdout.flush();
}
