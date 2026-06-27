use rand::prelude::*;
use rand::seq;
use std::hint::black_box;
use std::time::Instant;

const MIB: usize = 1024 * 1024;
const TRIALS: usize = 3;

fn main() {
    let bytes = 128 * MIB;
    let mut buffer = [0u8; 4096];

    println!("byte throughput");
    bench_bytes::<SmallRng>("rand SmallRng", bytes, &mut buffer);
    bench_bytes::<StdRng>("rand StdRng", bytes, &mut buffer);
    println!("\nfill-only throughput");
    bench_fill_only::<SmallRng>("rand SmallRng fill-only", bytes, &mut buffer);
    bench_fill_only::<StdRng>("rand StdRng fill-only", bytes, &mut buffer);

    println!("\nrange throughput");
    bench_range("rand bounded u32", bytes / 8);

    println!("\nsequence throughput");
    bench_seq("rand sample indices", 1_000_000, 10_000);
}

fn bench_bytes<R>(name: &str, bytes: usize, buffer: &mut [u8])
where
    R: SeedableRng + Rng,
{
    let mut best_mib_per_s = 0.0;
    let mut best_checksum = 0u8;
    for _ in 0..TRIALS {
        let mut rng = R::seed_from_u64(0x1234_5678);
        let start = Instant::now();
        let mut remaining = bytes;
        let mut checksum: u8 = 0;

        while remaining > 0 {
            let n = remaining.min(buffer.len());
            rng.fill(&mut buffer[..n]);
            for byte in &buffer[..n] {
                checksum ^= *byte;
            }
            remaining -= n;
        }

        let seconds = start.elapsed().as_secs_f64();
        let mib_per_s = (bytes as f64 / MIB as f64) / seconds;
        if mib_per_s > best_mib_per_s {
            best_mib_per_s = mib_per_s;
            best_checksum = checksum;
        }
    }

    black_box(best_checksum);
    println!("{name}: {best_mib_per_s:.1} MiB/s checksum={best_checksum}");
}

fn bench_fill_only<R>(name: &str, bytes: usize, buffer: &mut [u8])
where
    R: SeedableRng + Rng,
{
    let mut best_mib_per_s = 0.0;
    let mut best_tail = 0u8;
    for _ in 0..TRIALS {
        let mut rng = R::seed_from_u64(0x1234_5678);
        let start = Instant::now();
        let mut remaining = bytes;

        while remaining > 0 {
            let n = remaining.min(buffer.len());
            rng.fill(&mut buffer[..n]);
            black_box(buffer.as_ptr());
            remaining -= n;
        }

        let seconds = start.elapsed().as_secs_f64();
        let mib_per_s = (bytes as f64 / MIB as f64) / seconds;
        if mib_per_s > best_mib_per_s {
            best_mib_per_s = mib_per_s;
            best_tail = buffer[buffer.len() - 1];
        }
    }

    println!("{name}: {best_mib_per_s:.1} MiB/s tail={best_tail}");
}

fn bench_range(name: &str, count: usize) {
    let mut best_million_per_s = 0.0;
    let mut best_checksum = 0u64;
    for _ in 0..TRIALS {
        let mut rng = SmallRng::seed_from_u64(0x9999);
        let start = Instant::now();
        let mut checksum: u64 = 0;

        for _ in 0..count {
            checksum = checksum.wrapping_add(rng.random_range(0u32..1_000_003) as u64);
        }

        let seconds = start.elapsed().as_secs_f64();
        let million_per_s = (count as f64 / 1_000_000.0) / seconds;
        if million_per_s > best_million_per_s {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    black_box(best_checksum);
    println!("{name}: {best_million_per_s:.1} M samples/s checksum={best_checksum}");
}

fn bench_seq(name: &str, length: usize, amount: usize) {
    let mut best_thousand_per_s = 0.0;
    let mut best_checksum = 0usize;
    for _ in 0..TRIALS {
        let mut rng = SmallRng::seed_from_u64(0xabcd);
        let start = Instant::now();
        let indices = seq::index::sample(&mut rng, length, amount);
        let elapsed = start.elapsed();
        let mut checksum: usize = 0;
        for index in indices.iter() {
            checksum = checksum.wrapping_add(index);
        }

        let thousand_per_s = (amount as f64 / 1_000.0) / elapsed.as_secs_f64();
        if thousand_per_s > best_thousand_per_s {
            best_thousand_per_s = thousand_per_s;
            best_checksum = checksum;
        }
    }

    black_box(best_checksum);
    println!("{name}: {best_thousand_per_s:.1} K chosen/s checksum={best_checksum}");
}
