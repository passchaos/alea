const SplitMix64 = @This();

state: u64,

pub fn init(seed: u64) SplitMix64 {
    return .{ .state = seed };
}

pub fn seedFromU64(seed: u64) SplitMix64 {
    return init(seed);
}

pub fn next(self: *SplitMix64) u64 {
    self.state +%= 0x9e3779b97f4a7c15;

    var z = self.state;
    z = (z ^ (z >> 30)) *% 0xbf58476d1ce4e5b9;
    z = (z ^ (z >> 27)) *% 0x94d049bb133111eb;
    return z ^ (z >> 31);
}

pub fn nextU64(self: *SplitMix64) u64 {
    return self.next();
}

pub fn nextU32(self: *SplitMix64) u32 {
    return @truncate(self.next() >> 32);
}

test "splitmix64 next has stable snapshots" {
    var rng = SplitMix64.init(0x1234_5678_9abc_def0);
    try @import("std").testing.expectEqual(@as(u64, 0x161922c645ce50e8), rng.next());
    try @import("std").testing.expectEqual(@as(u64, 0xad760cafa1697b60), rng.next());
    try @import("std").testing.expectEqual(@as(u64, 0x3501ff44902ca50d), rng.next());
    try @import("std").testing.expectEqual(@as(u64, 0xecdac3a5189c532f), rng.state);
}
