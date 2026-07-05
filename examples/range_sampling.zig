const std = @import("std");
const alea = @import("alea");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var engine = alea.ScalarPrng.init(0x7261_6e67_65);
    const rng = alea.Rng.init(&engine);

    const die_exclusive = rng.intRangeLessThan(u8, 1, 7);
    const die_inclusive = rng.intRangeAtMost(u8, 1, 6);
    const random_range_die = rng.randomRange(u8, 1, 7);
    const random_range_at_most_die = rng.randomRangeAtMost(u8, 1, 6);
    const signed_offset = rng.intRangeLessThan(i32, -10, 11);
    const unit = rng.float(f64);
    const open = rng.floatOpen(f64);
    const open_closed = rng.floatOpenClosed(f64);
    const centered = rng.floatRange(f64, -1, 1);
    const uniform_error: alea.distributions.UniformError = error.EmptyRange;
    const duration = rng.durationRangeAtMost(.fromMilliseconds(10), .fromMilliseconds(20));
    const duration_batch = try rng.durationRangeAtMostBatch(allocator, 4, .fromMilliseconds(10), .fromMilliseconds(20));
    defer allocator.free(duration_batch);
    const duration_sampler = try alea.distributions.UniformDuration.newInclusive(.fromMilliseconds(10), .fromMilliseconds(20));
    var duration_sampler_engine = alea.ScalarPrng.init(0x7261_6e67_64);
    var duration_sampler_values: [3]std.Io.Duration = undefined;
    duration_sampler.fillFrom(&duration_sampler_engine, &duration_sampler_values);
    const sample_single = try alea.distributions.sampleSingleFrom(&engine, u8, 1, 7);
    const sample_single_inclusive = try alea.distributions.sampleSingleInclusiveFrom(&engine, u8, 1, 6);
    const standard_uniform = alea.distributions.StandardUniform{};
    const StandardPair = struct { bool, u16 };
    var standard_engine = alea.ScalarPrng.init(0x7261_6e67_73);
    const standard_rng = alea.Rng.init(&standard_engine);
    const standard_pair = standard_rng.sample(StandardPair, standard_uniform);
    const standard_word = alea.Rng.sampleFrom(&standard_engine, u32, standard_uniform);
    var standard_units: [3]f32 = undefined;
    standard_uniform.fillFrom(&standard_engine, f32, &standard_units);

    try stdout.print("integer ranges: less-than die={}, inclusive die={}, signed offset={}\n", .{ die_exclusive, die_inclusive, signed_offset });
    try stdout.print("randomRange die={}, randomRangeAtMost die={}\n", .{ random_range_die, random_range_at_most_die });
    try stdout.print("float units: [0,1)={d:.8}, (0,1)={d:.8}, (0,1]={d:.8}, range[-1,1)={d:.8}\n", .{ unit, open, open_closed, centered });
    try stdout.print("sampleSingle die={}, sampleSingleInclusive die={}\n", .{ sample_single, sample_single_inclusive });
    try stdout.print("UniformError alias -> {s}\n", .{@errorName(uniform_error)});
    try stdout.print("StandardUniform pair={any}, u32={}, f32 fill [0,1): {any}\n", .{ standard_pair, standard_word, standard_units });
    try stdout.print("duration range [10ms,20ms]: {} ns\n", .{duration.nanoseconds});
    try stdout.print("durationRangeAtMostBatch [10ms,20ms]: {any}\n", .{duration_batch});
    try stdout.print("UniformDuration.newInclusive [10ms,20ms]: {any}\n", .{duration_sampler_values});

    var fill_engine = alea.ScalarPrng.init(0x7261_6e67_66);
    var ints: [8]u16 = undefined;
    var floats: [8]f64 = undefined;
    var open_values: [8]f32 = undefined;
    alea.Rng.fillRangeFrom(&fill_engine, u16, &ints, 100, 200);
    alea.Rng.fillRangeFrom(&fill_engine, f64, &floats, -5, 5);
    alea.Rng.fillOpenClosedFrom(&fill_engine, f32, &open_values);
    try stdout.print("fillRange u16 [100,200): {any}\n", .{ints});
    try stdout.print("fillRange f64 [-5,5): {any}\n", .{floats});
    try stdout.print("fillOpenClosed f32 (0,1]: {any}\n", .{open_values});

    var batch_engine = alea.ScalarPrng.init(0x7261_6e67_69);
    const owned_ints = try alea.Rng.rangeBatchFrom(&batch_engine, u16, allocator, 6, 100, 200);
    defer allocator.free(owned_ints);
    const owned_inclusive_ints = try alea.Rng.rangeAtMostBatchCheckedFrom(&batch_engine, i16, allocator, 6, -50, 50);
    defer allocator.free(owned_inclusive_ints);
    const owned_floats = try alea.Rng.rangeBatchCheckedFrom(&batch_engine, f64, allocator, 6, -5, 5);
    defer allocator.free(owned_floats);
    const owned_open = try alea.Rng.openBatchFrom(&batch_engine, f32, allocator, 6);
    defer allocator.free(owned_open);
    const owned_open_closed = try alea.Rng.openClosedBatchFrom(&batch_engine, f32, allocator, 6);
    defer allocator.free(owned_open_closed);
    try stdout.print("rangeBatch u16 [100,200): {any}\n", .{owned_ints});
    try stdout.print("rangeAtMostBatchChecked i16 [-50,50]: {any}\n", .{owned_inclusive_ints});
    try stdout.print("rangeBatchChecked f64 [-5,5): {any}\n", .{owned_floats});
    try stdout.print("openBatch f32 (0,1): {any}\n", .{owned_open});
    try stdout.print("openClosedBatch f32 (0,1]: {any}\n", .{owned_open_closed});

    var dist_engine = alea.ScalarPrng.init(0x7261_6e67_67);
    const uniform = try alea.distributions.Uniform(f64).new(-2, 3);
    const inclusive_die = try alea.distributions.Uniform(u8).newInclusive(1, 6);
    const Even = struct {
        pub fn map(value: u8) bool {
            return value % 2 == 0;
        }
    };
    var mapped_engine = alea.ScalarPrng.init(0x7261_6e67_6d);
    const mapped_even_die = alea.distributions.map(u8, bool, inclusive_die, Even{}).sampleFrom(&mapped_engine);
    var uniform_values: [4]f64 = undefined;
    uniform.fillFrom(&dist_engine, &uniform_values);
    try stdout.print("Uniform(f64).new low={d:.1}, high={d:.1}, expected={d:.2}, variance={d:.2}, sample={d:.6}\n", .{ uniform.lowValue(), uniform.highValue(), uniform.expectedValue(), uniform.varianceValue(), uniform.sampleFrom(&dist_engine) });
    try stdout.print("Uniform(u8).newInclusive die isInclusive={}, sample={}\n", .{ inclusive_die.isInclusive(), inclusive_die.sampleFrom(&dist_engine) });
    try stdout.print("mapped Uniform even die: {}\n", .{mapped_even_die});
    try stdout.print("Uniform(f64).fillFrom: {any}\n", .{uniform_values});

    var vector_engine = alea.ScalarPrng.init(0x7261_6e67_68);
    const vec_range = alea.Rng.vectorRangeFrom(&vector_engine, @Vector(4, f32), -1, 1);
    const vec_open = alea.Rng.vectorOpenFrom(&vector_engine, @Vector(4, f32));
    const vec_open_closed = alea.Rng.vectorOpenClosedFrom(&vector_engine, @Vector(4, f32));
    const vec_uniform = alea.distributions.vectorUniformFrom(&vector_engine, @Vector(4, f32), 10, 20);
    const vec_uniform_sampler = try alea.distributions.VectorUniform(@Vector(4, f32)).new(10, 20);
    const vec_uniform_inclusive_sampler = try alea.distributions.VectorUniform(@Vector(4, i32)).newInclusive(-10, 10);
    var distribution_iter_engine = alea.ScalarPrng.init(0x7261_6e67_6e);
    var distribution_die_iter = alea.distributions.sampleIterFrom(&distribution_iter_engine, u8, inclusive_die);
    const distribution_die_iter_hint = distribution_die_iter.sizeHint();
    const distribution_die_iter_roll = distribution_die_iter.next().?;
    const vec_range_batch = try alea.Rng.vectorRangeBatchFrom(&vector_engine, @Vector(4, f32), allocator, 3, -1, 1);
    defer allocator.free(vec_range_batch);
    const vec_range_at_most_batch = try alea.Rng.vectorRangeAtMostBatchCheckedFrom(&vector_engine, @Vector(4, i32), allocator, 3, -10, 10);
    defer allocator.free(vec_range_at_most_batch);
    const vec_open_batch = try alea.Rng.vectorOpenBatchFrom(&vector_engine, @Vector(4, f32), allocator, 3);
    defer allocator.free(vec_open_batch);
    const vec_open_closed_batch = try alea.Rng.vectorOpenClosedBatchFrom(&vector_engine, @Vector(4, f32), allocator, 3);
    defer allocator.free(vec_open_closed_batch);
    try stdout.print("vectorRange f32x4 [-1,1): {any}\n", .{vec_range});
    try stdout.print("vectorOpen f32x4 (0,1): {any}\n", .{vec_open});
    try stdout.print("vectorOpenClosed f32x4 (0,1]: {any}\n", .{vec_open_closed});
    try stdout.print("distribution vectorUniform f32x4 [10,20): {any}\n", .{vec_uniform});
    try stdout.print("VectorUniform(f32x4).new low={d:.1}, high={d:.1}, sample={any}\n", .{ vec_uniform_sampler.lowValue(), vec_uniform_sampler.highValue(), vec_uniform_sampler.sampleFrom(&vector_engine) });
    try stdout.print("VectorUniform(i32x4).newInclusive low={}, high={}, isInclusive={}, sample={any}\n", .{ vec_uniform_inclusive_sampler.lowValue(), vec_uniform_inclusive_sampler.highValue(), vec_uniform_inclusive_sampler.isInclusive(), vec_uniform_inclusive_sampler.sampleFrom(&vector_engine) });
    try stdout.print("distribution sampleIter die: {}, unbounded={}\n", .{ distribution_die_iter_roll, distribution_die_iter_hint.upper == null });
    try stdout.print("vectorRangeBatch f32x4 [-1,1): {any}\n", .{vec_range_batch});
    try stdout.print("vectorRangeAtMostBatch i32x4 [-10,10]: {any}\n", .{vec_range_at_most_batch});
    try stdout.print("vectorOpenBatch f32x4 (0,1): {any}\n", .{vec_open_batch});
    try stdout.print("vectorOpenClosedBatch f32x4 (0,1]: {any}\n", .{vec_open_closed_batch});

    const collapsed = rng.floatRange(f64, 2.5, 2.5);
    const checked_error_name = if (rng.intRangeLessThanChecked(u32, 3, 3)) |_| "unexpected-success" else |err| @errorName(err);
    try stdout.print("collapsed floatRange returns {d:.1}; invalid checked int range -> {s}\n", .{ collapsed, checked_error_name });
    try stdout.print("\nUse less-than ranges for half-open intervals, at-most/inclusive Uniform for closed integer ranges, strict Open01/OpenClosed01 helpers for endpoint-sensitive floats, and durationRange* for std.Io.Duration.\n", .{});
    try stdout.flush();
}
