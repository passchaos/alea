const SplitMix64 = @This();

state: u64,

pub fn init(seed: u64) SplitMix64 {
    return .{ .state = seed };
}

pub fn next(self: *SplitMix64) u64 {
    self.state +%= 0x9e3779b97f4a7c15;

    var z = self.state;
    z = (z ^ (z >> 30)) *% 0xbf58476d1ce4e5b9;
    z = (z ^ (z >> 27)) *% 0x94d049bb133111eb;
    return z ^ (z >> 31);
}
