const std = @import("std");

const SourceGroup = struct {
    label: []const u8,
    root_env: []const u8,
    default_root: []const u8,
    manifest_path: []const u8,
    files: []const []const u8,
    expected_tokens: []const []const u8,
    ignored_tokens: []const []const u8 = &.{},
};

const local_rand_files = [_][]const u8{
    "lib.rs",
    "rng.rs",
    "prelude.rs",
    "rngs/mod.rs",
    "rngs/small.rs",
    "rngs/std.rs",
    "rngs/thread.rs",
    "rngs/xoshiro128plusplus.rs",
    "rngs/xoshiro256plusplus.rs",
    "distr/mod.rs",
    "distr/distribution.rs",
    "distr/float.rs",
    "distr/bernoulli.rs",
    "distr/slice.rs",
    "distr/uniform.rs",
    "distr/uniform_float.rs",
    "distr/uniform_int.rs",
    "distr/uniform_other.rs",
    "distr/weighted/mod.rs",
    "distr/weighted/weighted_index.rs",
    "seq/mod.rs",
    "seq/slice.rs",
    "seq/index.rs",
    "seq/iterator.rs",
};

const local_rand_expected_tokens = [_][]const u8{
    "rand_core",
    "Rng",
    "TryRng",
    "SeedableRng",
    "CryptoRng",
    "TryCryptoRng",
    "distr",
    "rngs",
    "seq",
    "prelude",
    "make_rng",
    "RngReader",
    "random",
    "random_iter",
    "random_range",
    "random_bool",
    "random_ratio",
    "fill",
    "rng()",
    "ThreadRng",
    "StepRng",
    "const_rng",
    "step_rng",
    "RngExt",
    "Fill",
    "SmallRng",
    "StdRng",
    "Xoshiro128PlusPlus",
    "Xoshiro256PlusPlus",
    "ChaCha8Rng",
    "ChaCha12Rng",
    "ChaCha20Rng",
    "SysRng",
    "SysError",
    "Distribution",
    "Iter",
    "Map",
    "SampleString",
    "StandardUniform",
    "Open01",
    "OpenClosed01",
    "Uniform",
    "UniformInt",
    "UniformFloat",
    "UniformUsize",
    "UniformDuration",
    "UniformChar",
    "UniformError",
    "Bernoulli",
    "BernoulliError",
    "Alphanumeric",
    "Alphabetic",
    "Choose",
    "slice::Choose",
    "slice::Empty",
    "WeightedIndex",
    "weighted::WeightedIndex",
    "weighted::Error",
    "SampleUniform",
    "UniformSampler",
    "SampleBorrow",
    "SampleRange",
    "IndexedSamples",
    "SliceChooseIter",
    "IndexedRandom",
    "IndexedMutRandom",
    "SliceRandom",
    "IteratorRandom",
    "seq::index",
    "IndexVec",
    "IndexVecIter",
    "IndexVecIntoIter",
    "sample",
    "sample_weighted",
    "sample_array",
};

const local_rand_ignored_tokens = [_][]const u8{
    "rng",
    "const_rng",
    "step_rng",
    "StepRng",
};

const rand_core_files = [_][]const u8{
    "lib.rs",
    "seedable_rng.rs",
    "block.rs",
    "utils.rs",
    "unwrap_err.rs",
    "word.rs",
};

const rand_core_expected_tokens = [_][]const u8{
    "Rng",
    "TryRng",
    "RngCore",
    "TryRngCore",
    "CryptoRng",
    "TryCryptoRng",
    "SeedableRng",
    "Infallible",
    "UnwrapErr",
    "block",
    "Generator",
    "BlockRng",
    "utils",
    "next_u64_via_u32",
    "fill_bytes_via_next_word",
    "next_word_via_fill",
    "read_words",
    "Word",
};

const rand_distr_files = [_][]const u8{
    "lib.rs",
    "beta.rs",
    "binomial.rs",
    "cauchy.rs",
    "chi_squared.rs",
    "exponential.rs",
    "fisher_f.rs",
    "frechet.rs",
    "gamma.rs",
    "geometric.rs",
    "gumbel.rs",
    "hypergeometric.rs",
    "inverse_gaussian.rs",
    "normal.rs",
    "normal_inverse_gaussian.rs",
    "pareto.rs",
    "pert.rs",
    "poisson.rs",
    "skew_normal.rs",
    "student_t.rs",
    "triangular.rs",
    "unit_ball.rs",
    "unit_circle.rs",
    "unit_disc.rs",
    "unit_sphere.rs",
    "weibull.rs",
    "zeta.rs",
    "zipf.rs",
    "multi/mod.rs",
    "multi/dirichlet.rs",
    "weighted/mod.rs",
    "weighted/weighted_alias.rs",
    "weighted/weighted_tree.rs",
};

const rand_distr_expected_tokens = [_][]const u8{
    "StandardUniform",
    "Uniform",
    "uniform",
    "Open01",
    "OpenClosed01",
    "Alphanumeric",
    "Bernoulli",
    "BernoulliError",
    "Distribution",
    "Iter",
    "Beta",
    "Binomial",
    "Cauchy",
    "ChiSquared",
    "Exp",
    "Exp1",
    "FisherF",
    "Frechet",
    "Gamma",
    "Geometric",
    "StandardGeometric",
    "Gumbel",
    "Hypergeometric",
    "InverseGaussian",
    "LogNormal",
    "Normal",
    "StandardNormal",
    "NormalInverseGaussian",
    "Pareto",
    "Pert",
    "PertBuilder",
    "Poisson",
    "SkewNormal",
    "StudentT",
    "Triangular",
    "UnitBall",
    "UnitCircle",
    "UnitDisc",
    "UnitSphere",
    "Weibull",
    "Zeta",
    "Zipf",
    "NormalError",
    "ExpError",
    "GammaError",
    "PoissonError",
    "ZipfError",
    "new",
    "from_mean_cv",
    "from_zscore",
    "mean",
    "std_dev",
    "with_shape",
    "with_mean",
    "with_mode",
    "multi::Dirichlet",
    "MultiDistribution",
    "ConstMultiDistribution",
    "weighted::WeightedIndex",
    "WeightedAliasIndex",
    "WeightedTreeIndex",
    "is_valid",
    "AliasableWeight",
    "num_traits",
};

const rand_distr_ignored_tokens = [_][]const u8{
    "VoidRng",
    "rng",
};

const groups = [_]SourceGroup{
    .{
        .label = "local rand",
        .root_env = "ALEA_RAND_ROOT",
        .default_root = "/home/passchaos/Work/rand/src",
        .manifest_path = "compare/results/s4-m288-local-rand-public-surface-manifest.md",
        .files = local_rand_files[0..],
        .expected_tokens = local_rand_expected_tokens[0..],
        .ignored_tokens = local_rand_ignored_tokens[0..],
    },
    .{
        .label = "local rand_core",
        .root_env = "ALEA_RAND_CORE_ROOT",
        .default_root = "/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src",
        .manifest_path = "compare/results/s4-m288-local-rand-public-surface-manifest.md",
        .files = rand_core_files[0..],
        .expected_tokens = rand_core_expected_tokens[0..],
    },
    .{
        .label = "local rand_distr",
        .root_env = "ALEA_RAND_DISTR_ROOT",
        .default_root = "/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src",
        .manifest_path = "compare/results/s4-m294-rand-distr-public-surface-manifest.md",
        .files = rand_distr_files[0..],
        .expected_tokens = rand_distr_expected_tokens[0..],
        .ignored_tokens = rand_distr_ignored_tokens[0..],
    },
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = std.heap.smp_allocator;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var stderr_buffer: [4096]u8 = undefined;
    var stderr_file = std.Io.File.stderr().writer(io, &stderr_buffer);
    const stderr = &stderr_file.interface;

    var missing: usize = 0;

    inline for (groups) |group| {
        try checkGroup(io, allocator, stderr, init.environ_map, group, &missing);
    }

    if (missing != 0) {
        try stderr.flush();
        return error.SurfaceManifestDrift;
    }

    try stdout.print("surfacecheck ok\n", .{});
    try stdout.flush();
}

fn checkGroup(
    io: std.Io,
    allocator: std.mem.Allocator,
    stderr: *std.Io.Writer,
    env: *std.process.Environ.Map,
    group: SourceGroup,
    missing: *usize,
) !void {
    const root = env.get(group.root_env) orelse group.default_root;
    std.Io.Dir.accessAbsolute(io, root, .{}) catch |err| {
        try stderr.print(
            "surfacecheck: {s} root `{s}` unavailable ({s}); set {s} to the local checkout/cache root\n",
            .{ group.label, root, @errorName(err), group.root_env },
        );
        missing.* += 1;
        return;
    };

    const manifest = std.Io.Dir.cwd().readFileAlloc(io, group.manifest_path, allocator, .limited(8 * 1024 * 1024)) catch |err| {
        try stderr.print("surfacecheck: unable to read manifest `{s}`: {s}\n", .{ group.manifest_path, @errorName(err) });
        missing.* += 1;
        return;
    };
    defer allocator.free(manifest);

    for (group.expected_tokens) |token| {
        if (std.mem.indexOf(u8, manifest, token) == null) {
            try stderr.print(
                "surfacecheck: {s} manifest `{s}` missing expected public-surface token `{s}`\n",
                .{ group.label, group.manifest_path, token },
            );
            missing.* += 1;
        }
    }

    for (group.files) |relative| {
        const path = try std.fs.path.join(allocator, &.{ root, relative });
        defer allocator.free(path);
        const source = readAbsoluteFile(io, allocator, path) catch |err| {
            try stderr.print("surfacecheck: unable to read {s} source `{s}`: {s}\n", .{ group.label, path, @errorName(err) });
            missing.* += 1;
            continue;
        };
        defer allocator.free(source);

        try checkSourcePublicTokens(stderr, group, relative, source, manifest, missing);
    }
}

fn checkSourcePublicTokens(
    stderr: *std.Io.Writer,
    group: SourceGroup,
    relative: []const u8,
    source: []const u8,
    manifest: []const u8,
    missing: *usize,
) !void {
    var in_cfg_test_module = false;
    var test_module_brace_depth: usize = 0;
    var pending_cfg_test = false;
    var brace_depth: usize = 0;
    var collecting_pub_use = false;
    var pub_use_buffer: [4096]u8 = undefined;
    var pub_use_len: usize = 0;
    var line_it = std.mem.splitScalar(u8, source, '\n');
    while (line_it.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");

        if (!in_cfg_test_module and std.mem.startsWith(u8, trimmed, "#[cfg(test)]")) {
            pending_cfg_test = true;
        }

        if (!in_cfg_test_module and pending_cfg_test and std.mem.startsWith(u8, trimmed, "mod ") and std.mem.indexOfScalar(u8, trimmed, '{') != null) {
            in_cfg_test_module = true;
            test_module_brace_depth = brace_depth;
            pending_cfg_test = false;
        }

        if (in_cfg_test_module) {
            try checkIgnoredTestLine(stderr, group, relative, trimmed, missing);
        } else if (collecting_pub_use) {
            appendPubUseLine(&pub_use_buffer, &pub_use_len, trimmed) catch |err| {
                try stderr.print(
                    "surfacecheck: {s} source `{s}` has oversized pub use block: {s}\n",
                    .{ group.label, relative, @errorName(err) },
                );
                missing.* += 1;
                collecting_pub_use = false;
                pub_use_len = 0;
                continue;
            };
            if (std.mem.indexOfScalar(u8, trimmed, ';') != null) {
                try checkPubUseLine(stderr, group, relative, pub_use_buffer[0..pub_use_len], manifest, missing);
                collecting_pub_use = false;
                pub_use_len = 0;
            }
        } else if (brace_depth == 0) {
            if (std.mem.startsWith(u8, trimmed, "pub use ") and std.mem.indexOfScalar(u8, trimmed, ';') == null) {
                collecting_pub_use = true;
                pub_use_len = 0;
                appendPubUseLine(&pub_use_buffer, &pub_use_len, trimmed) catch |err| {
                    try stderr.print(
                        "surfacecheck: {s} source `{s}` has oversized pub use block: {s}\n",
                        .{ group.label, relative, @errorName(err) },
                    );
                    missing.* += 1;
                    collecting_pub_use = false;
                    pub_use_len = 0;
                };
            } else {
                try checkPublicLine(stderr, group, relative, trimmed, manifest, missing);
            }
        } else {
            try checkPublicMethodLine(stderr, group, relative, trimmed, manifest, missing);
        }

        brace_depth = updateBraceDepth(brace_depth, line);
        if (in_cfg_test_module and brace_depth <= test_module_brace_depth) {
            in_cfg_test_module = false;
        }
        if (trimmed.len != 0 and !std.mem.startsWith(u8, trimmed, "#[cfg(test)]")) {
            if (!(std.mem.startsWith(u8, trimmed, "#[") or trimmed[0] == '/' or trimmed[0] == '#')) {
                pending_cfg_test = false;
            }
        }
    }

    if (collecting_pub_use) {
        try stderr.print(
            "surfacecheck: {s} source `{s}` has unterminated pub use block\n",
            .{ group.label, relative },
        );
        missing.* += 1;
    }
}

fn checkPublicLine(
    stderr: *std.Io.Writer,
    group: SourceGroup,
    relative: []const u8,
    trimmed: []const u8,
    manifest: []const u8,
    missing: *usize,
) !void {
    if (trimmed.len == 0) return;
    if (extractPublicDeclName(trimmed)) |name| {
        if (isIgnored(group, name)) return;
        try requireManifestToken(stderr, group, relative, manifest, name, missing);
        return;
    }
    try checkPubUseLine(stderr, group, relative, trimmed, manifest, missing);
}

fn checkPublicMethodLine(
    stderr: *std.Io.Writer,
    group: SourceGroup,
    relative: []const u8,
    trimmed: []const u8,
    manifest: []const u8,
    missing: *usize,
) !void {
    if (extractPublicFnName(trimmed)) |name| {
        if (isIgnored(group, name)) return;
        try requireManifestToken(stderr, group, relative, manifest, name, missing);
    }
}

fn checkIgnoredTestLine(
    stderr: *std.Io.Writer,
    group: SourceGroup,
    relative: []const u8,
    trimmed: []const u8,
    missing: *usize,
) !void {
    if (extractPublicDeclName(trimmed)) |name| {
        if (!isIgnored(group, name)) {
            try stderr.print(
                "surfacecheck: {s} source `{s}` has unexpected cfg(test) public token `{s}`; either document it or add an explicit ignored-test token\n",
                .{ group.label, relative, name },
            );
            missing.* += 1;
        }
    }
}

fn requireManifestToken(
    stderr: *std.Io.Writer,
    group: SourceGroup,
    relative: []const u8,
    manifest: []const u8,
    token: []const u8,
    missing: *usize,
) !void {
    if (std.mem.indexOf(u8, manifest, token) != null) return;
    try stderr.print(
        "surfacecheck: {s} source `{s}` exposes public token `{s}` not mapped in `{s}`\n",
        .{ group.label, relative, token, group.manifest_path },
    );
    missing.* += 1;
}

fn extractPublicDeclName(trimmed: []const u8) ?[]const u8 {
    if (!std.mem.startsWith(u8, trimmed, "pub ")) return null;
    var rest = std.mem.trimStart(u8, trimmed["pub ".len..], " \t");
    if (std.mem.startsWith(u8, rest, "unsafe ")) {
        rest = std.mem.trimStart(u8, rest["unsafe ".len..], " \t");
    }

    const prefixes = [_][]const u8{ "mod ", "fn ", "struct ", "enum ", "trait ", "type " };
    inline for (prefixes) |prefix| {
        if (std.mem.startsWith(u8, rest, prefix)) {
            const name_start = prefix.len;
            return readIdent(rest[name_start..]);
        }
    }
    return null;
}

fn extractPublicFnName(trimmed: []const u8) ?[]const u8 {
    if (!std.mem.startsWith(u8, trimmed, "pub ")) return null;
    var rest = std.mem.trimStart(u8, trimmed["pub ".len..], " \t");
    if (std.mem.startsWith(u8, rest, "inline ")) {
        rest = std.mem.trimStart(u8, rest["inline ".len..], " \t");
    }
    if (std.mem.startsWith(u8, rest, "fn ")) {
        return readIdent(rest["fn ".len..]);
    }
    return null;
}

fn checkPubUseLine(
    stderr: *std.Io.Writer,
    group: SourceGroup,
    relative: []const u8,
    trimmed: []const u8,
    manifest: []const u8,
    missing: *usize,
) !void {
    if (!std.mem.startsWith(u8, trimmed, "pub use ")) return;
    const body = std.mem.trimEnd(u8, trimmed["pub use ".len..], "; \t\r");
    var parts: [32][]const u8 = [_][]const u8{""} ** 32;
    var count: usize = 0;

    var normalized: [512]u8 = undefined;
    const limited = body[0..@min(body.len, normalized.len)];
    @memcpy(normalized[0..limited.len], limited);
    for (normalized[0..limited.len]) |*byte| {
        switch (byte.*) {
            '{', '}', ',', ';' => byte.* = ' ',
            else => {},
        }
    }

    var it = std.mem.tokenizeAny(u8, normalized[0..limited.len], " \t\r\n");
    while (it.next()) |part| {
        if (count < parts.len) {
            parts[count] = part;
            count += 1;
        }
    }

    var index: usize = 0;
    while (index < count) : (index += 1) {
        const part = parts[index];
        if (std.mem.eql(u8, part, "as")) continue;

        if (index + 2 < count and std.mem.eql(u8, parts[index + 1], "as")) {
            const alias = leafName(parts[index + 2]);
            if (alias.len != 0 and !isIgnored(group, alias)) {
                try requireManifestToken(stderr, group, relative, manifest, alias, missing);
            }
            index += 2;
            continue;
        }

        const leaf = leafName(part);
        if (leaf.len == 0 or isIgnored(group, leaf)) continue;
        try requireManifestToken(stderr, group, relative, manifest, leaf, missing);
    }
}

fn appendPubUseLine(buffer: *[4096]u8, len: *usize, line: []const u8) !void {
    if (len.* + line.len + 1 > buffer.len) return error.PubUseBlockTooLong;
    @memcpy(buffer[len.*..][0..line.len], line);
    len.* += line.len;
    buffer[len.*] = ' ';
    len.* += 1;
}

fn readIdent(text: []const u8) ?[]const u8 {
    var end: usize = 0;
    while (end < text.len and isIdentByte(text[end])) : (end += 1) {}
    if (end == 0) return null;
    return text[0..end];
}

fn leafName(text: []const u8) []const u8 {
    var candidate = text;
    if (std.mem.lastIndexOf(u8, candidate, "::")) |index| {
        candidate = candidate[index + 2 ..];
    }
    if (std.mem.indexOfScalar(u8, candidate, '<')) |index| {
        candidate = candidate[0..index];
    }
    return readIdent(candidate) orelse "";
}

fn isIdentByte(byte: u8) bool {
    return (byte >= 'A' and byte <= 'Z') or
        (byte >= 'a' and byte <= 'z') or
        (byte >= '0' and byte <= '9') or
        byte == '_';
}

fn isIgnored(group: SourceGroup, token: []const u8) bool {
    for (group.ignored_tokens) |ignored| {
        if (std.mem.eql(u8, token, ignored)) return true;
    }
    return false;
}

fn updateBraceDepth(initial: usize, line: []const u8) usize {
    var depth = initial;
    for (line) |byte| {
        switch (byte) {
            '{' => depth += 1,
            '}' => {
                if (depth > 0) depth -= 1;
            },
            else => {},
        }
    }
    return depth;
}

fn readAbsoluteFile(io: std.Io, allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    const directory_name = std.fs.path.dirname(path) orelse return error.InvalidPath;
    const file_name = std.fs.path.basename(path);
    var dir = try std.Io.Dir.openDirAbsolute(io, directory_name, .{});
    defer dir.close(io);
    return dir.readFileAlloc(io, file_name, allocator, .limited(8 * 1024 * 1024));
}
