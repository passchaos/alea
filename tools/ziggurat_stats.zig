const std = @import("std");
const alea = @import("alea");

const ziggurat = std.Random.ziggurat;

const Counts = struct {
    fast: usize = 0,
    accepted_reject: usize = 0,
    rejected_retry: usize = 0,
    tail: usize = 0,
    words: usize = 0,

    fn total(self: Counts) usize {
        return self.fast + self.accepted_reject + self.tail;
    }
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    const samples: usize = 16 * 1024 * 1024;
    var normal_engine = alea.ScalarPrng.init(0xd15a);
    var exponential_engine = alea.ScalarPrng.init(0xe15a);

    const normal_counts = sampleNormal(&normal_engine, samples);
    const exp_counts = sampleExponential(&exponential_engine, samples);

    try printCounts(stdout, "normal", normal_counts);
    try printCounts(stdout, "exponential", exp_counts);
    try stdout.flush();
}

fn sampleNormal(engine: *alea.ScalarPrng, samples: usize) Counts {
    var counts = Counts{};
    var produced: usize = 0;
    while (produced < samples) : (produced += 1) {
        while (true) {
            counts.words += 1;
            const bits = engine.next();
            const i: usize = @as(u8, @truncate(bits));
            const repr = (@as(u64, 0x400) << 52) | (bits >> 12);
            const u: f64 = @as(f64, @bitCast(repr)) - 3.0;
            const x = u * ziggurat.NormDist.x[i];
            const test_x = @abs(x);

            if (test_x < ziggurat.NormDist.x[i + 1]) {
                counts.fast += 1;
                break;
            }
            if (i == 0) {
                counts.tail += 1;
                consumeNormalTail(engine, u);
                break;
            }
            if (ziggurat.NormDist.f[i + 1] + (ziggurat.NormDist.f[i] - ziggurat.NormDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x * x / 2.0)) {
                counts.accepted_reject += 1;
                break;
            }
            counts.rejected_retry += 1;
        }
    }
    return counts;
}

fn consumeNormalTail(engine: *alea.ScalarPrng, u: f64) void {
    _ = u;
    var x: f64 = 1;
    var y: f64 = 0;
    while (-2.0 * y < x * x) {
        x = @log(alea.Rng.floatFrom(engine, f64)) / ziggurat.norm_r;
        y = @log(alea.Rng.floatFrom(engine, f64));
    }
}

fn sampleExponential(engine: *alea.ScalarPrng, samples: usize) Counts {
    var counts = Counts{};
    var produced: usize = 0;
    while (produced < samples) : (produced += 1) {
        while (true) {
            counts.words += 1;
            const bits = engine.next();
            const i: usize = @as(u8, @truncate(bits));
            const repr = (@as(u64, 0x3ff) << 52) | (bits >> 12);
            const u: f64 = @as(f64, @bitCast(repr)) - (1.0 - std.math.floatEps(f64) / 2.0);
            const x = u * ziggurat.ExpDist.x[i];

            if (x < ziggurat.ExpDist.x[i + 1]) {
                counts.fast += 1;
                break;
            }
            if (i == 0) {
                counts.tail += 1;
                _ = ziggurat.exp_r - @log(alea.Rng.floatFrom(engine, f64));
                break;
            }
            if (ziggurat.ExpDist.f[i + 1] + (ziggurat.ExpDist.f[i] - ziggurat.ExpDist.f[i + 1]) * alea.Rng.floatFrom(engine, f64) < @exp(-x)) {
                counts.accepted_reject += 1;
                break;
            }
            counts.rejected_retry += 1;
        }
    }
    return counts;
}

fn printCounts(stdout: *std.Io.Writer, comptime name: []const u8, counts: Counts) !void {
    const total_f: f64 = @floatFromInt(counts.total());
    try stdout.print(
        "{s}: total={} fast={} ({d:.4}%) accepted_reject={} ({d:.4}%) tail={} ({d:.4}%) retries={} words_per_sample={d:.6}\n",
        .{
            name,
            counts.total(),
            counts.fast,
            percent(counts.fast, total_f),
            counts.accepted_reject,
            percent(counts.accepted_reject, total_f),
            counts.tail,
            percent(counts.tail, total_f),
            counts.rejected_retry,
            @as(f64, @floatFromInt(counts.words)) / total_f,
        },
    );
}

fn percent(value: usize, total: f64) f64 {
    return @as(f64, @floatFromInt(value)) * 100.0 / total;
}
