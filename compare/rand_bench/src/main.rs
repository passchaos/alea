use rand::prelude::*;
use rand::seq;
use rand_distr::Distribution as RandDistrDistribution;
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

    println!("\ndistribution throughput");
    bench_bool("rand random_bool", bytes / 8);
    bench_alphanumeric("rand alphanumeric", bytes / 8);
    bench_weighted_index("rand weighted index", bytes / 256);
    bench_weighted_tree("rand_distr weighted tree update+sample", bytes / 256);
    bench_distr_normal("rand_distr normal", bytes / 64);
    bench_distr_exponential("rand_distr exponential", bytes / 64);
    bench_distr_poisson("rand_distr poisson", bytes / 64);
    bench_distr_binomial("rand_distr binomial", bytes / 64);
    bench_distr_gamma("rand_distr gamma", bytes / 128);
    bench_distr_beta("rand_distr beta", bytes / 128);
    bench_distr_gumbel("rand_distr gumbel", bytes / 128);
    bench_distr_frechet("rand_distr frechet", bytes / 128);
    bench_distr_skew_normal("rand_distr skew-normal", bytes / 128);
    bench_distr_pert("rand_distr pert", bytes / 128);
    bench_distr_unit_circle("rand_distr unit circle", bytes / 128);
    bench_distr_unit_disc("rand_distr unit disc", bytes / 128);
    bench_distr_unit_sphere("rand_distr unit sphere", bytes / 128);
    bench_distr_unit_ball("rand_distr unit ball", bytes / 128);
    bench_distr_inverse_gaussian("rand_distr inverse-gaussian", bytes / 128);
    bench_distr_normal_inverse_gaussian("rand_distr normal-inverse-gaussian", bytes / 128);
    bench_distr_zipf("rand_distr zipf", bytes / 128);
    bench_distr_zeta("rand_distr zeta", bytes / 128);
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

fn bench_bool(name: &str, count: usize) {
    let mut best_million_per_s = 0.0;
    let mut best_checksum = 0u64;
    for _ in 0..TRIALS {
        let mut rng = SmallRng::seed_from_u64(0xb001);
        let start = Instant::now();
        let mut checksum: u64 = 0;

        for _ in 0..count {
            checksum = checksum.wrapping_add(rng.random_bool(0.25) as u64);
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

fn bench_alphanumeric(name: &str, count: usize) {
    let mut best_million_per_s = 0.0;
    let mut best_checksum = 0u64;
    for _ in 0..TRIALS {
        let mut rng = SmallRng::seed_from_u64(0xa11a);
        let start = Instant::now();
        let mut checksum: u64 = 0;

        for byte in (&mut rng).sample_iter(rand::distr::Alphanumeric).take(count) {
            checksum = checksum.wrapping_add(byte as u64);
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

fn bench_weighted_index(name: &str, count: usize) {
    let weights = [1u32, 2, 3, 0, 5, 8, 13, 21];
    let mut best_million_per_s = 0.0;
    let mut best_checksum = 0usize;
    for _ in 0..TRIALS {
        let mut rng = SmallRng::seed_from_u64(0xface);
        let dist = rand::distr::weighted::WeightedIndex::new(&weights).unwrap();
        let start = Instant::now();
        let mut checksum: usize = 0;

        for _ in 0..count {
            checksum = checksum.wrapping_add(rng.sample(&dist));
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

fn bench_weighted_tree(name: &str, count: usize) {
    let initial = [1u32, 2, 3, 0, 5, 8, 13, 21];
    let mut best_million_per_s = 0.0;
    let mut best_checksum = 0usize;
    for _ in 0..TRIALS {
        let mut rng = SmallRng::seed_from_u64(0x77ee);
        let mut dist = rand_distr::weighted::WeightedTreeIndex::new(initial).unwrap();
        let start = Instant::now();
        let mut checksum: usize = 0;

        for i in 0..count {
            let index = i & 7;
            dist.update(index, ((i % 17) + 1) as u32).unwrap();
            checksum = checksum.wrapping_add(dist.sample(&mut rng));
        }

        let seconds = start.elapsed().as_secs_f64();
        let million_per_s = (count as f64 / 1_000_000.0) / seconds;
        if million_per_s > best_million_per_s {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    black_box(best_checksum);
    println!("{name}: {best_million_per_s:.1} M ops/s checksum={best_checksum}");
}

fn bench_distr_normal(name: &str, count: usize) {
    let dist = rand_distr::Normal::new(0.0, 1.0).unwrap();
    bench_distr_f64(name, count, 0xd15a, dist);
}

fn bench_distr_exponential(name: &str, count: usize) {
    let dist = rand_distr::Exp::new(2.0).unwrap();
    bench_distr_f64(name, count, 0xe15a, dist);
}

fn bench_distr_gamma(name: &str, count: usize) {
    let dist = rand_distr::Gamma::new(2.0, 3.0).unwrap();
    bench_distr_f64(name, count, 0x6a44a, dist);
}

fn bench_distr_beta(name: &str, count: usize) {
    let dist = rand_distr::Beta::new(2.0, 5.0).unwrap();
    bench_distr_f64(name, count, 0xbe7a, dist);
}

fn bench_distr_gumbel(name: &str, count: usize) {
    let dist = rand_distr::Gumbel::new(0.0, 1.0).unwrap();
    bench_distr_f64(name, count, 0x6cbe1, dist);
}

fn bench_distr_frechet(name: &str, count: usize) {
    let dist = rand_distr::Frechet::new(0.0, 1.0, 3.0).unwrap();
    bench_distr_f64(name, count, 0xf7ec, dist);
}

fn bench_distr_skew_normal(name: &str, count: usize) {
    let dist = rand_distr::SkewNormal::new(0.0, 1.0, 1.0).unwrap();
    bench_distr_f64(name, count, 0x5ce9, dist);
}

fn bench_distr_pert(name: &str, count: usize) {
    let dist = rand_distr::Pert::new(-1.0, 2.0).with_mode(0.5).unwrap();
    bench_distr_f64(name, count, 0x9e71, dist);
}

fn bench_distr_inverse_gaussian(name: &str, count: usize) {
    let dist = rand_distr::InverseGaussian::new(1.0, 2.0).unwrap();
    bench_distr_f64(name, count, 0x164a, dist);
}

fn bench_distr_normal_inverse_gaussian(name: &str, count: usize) {
    let dist = rand_distr::NormalInverseGaussian::new(2.0, 1.0).unwrap();
    bench_distr_f64(name, count, 0x916a, dist);
}

fn bench_distr_zipf(name: &str, count: usize) {
    let dist = rand_distr::Zipf::new(10.0, 1.5).unwrap();
    bench_distr_f64(name, count, 0x719f, dist);
}

fn bench_distr_zeta(name: &str, count: usize) {
    let dist = rand_distr::Zeta::new(3.0).unwrap();
    bench_distr_f64(name, count, 0x7e7a, dist);
}

fn bench_distr_unit_circle(name: &str, count: usize) {
    bench_distr_array2(name, count, 0xc11c1e, rand_distr::UnitCircle);
}

fn bench_distr_unit_disc(name: &str, count: usize) {
    bench_distr_array2(name, count, 0xd15c, rand_distr::UnitDisc);
}

fn bench_distr_unit_sphere(name: &str, count: usize) {
    bench_distr_array3(name, count, 0x59e7e, rand_distr::UnitSphere);
}

fn bench_distr_unit_ball(name: &str, count: usize) {
    bench_distr_array3(name, count, 0xba11, rand_distr::UnitBall);
}

fn bench_distr_array2<D>(name: &str, count: usize, seed: u64, dist: D)
where
    D: RandDistrDistribution<[f64; 2]> + Copy,
{
    let mut best_million_per_s = 0.0;
    let mut best_checksum = 0.0;
    for _ in 0..TRIALS {
        let mut rng = SmallRng::seed_from_u64(seed);
        let start = Instant::now();
        let mut checksum = 0.0;

        for _ in 0..count {
            checksum += dist.sample(&mut rng)[0];
        }

        let seconds = start.elapsed().as_secs_f64();
        let million_per_s = (count as f64 / 1_000_000.0) / seconds;
        if million_per_s > best_million_per_s {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    black_box(best_checksum);
    println!("{name}: {best_million_per_s:.1} M samples/s checksum={best_checksum:.3}");
}

fn bench_distr_array3<D>(name: &str, count: usize, seed: u64, dist: D)
where
    D: RandDistrDistribution<[f64; 3]> + Copy,
{
    let mut best_million_per_s = 0.0;
    let mut best_checksum = 0.0;
    for _ in 0..TRIALS {
        let mut rng = SmallRng::seed_from_u64(seed);
        let start = Instant::now();
        let mut checksum = 0.0;

        for _ in 0..count {
            checksum += dist.sample(&mut rng)[0];
        }

        let seconds = start.elapsed().as_secs_f64();
        let million_per_s = (count as f64 / 1_000_000.0) / seconds;
        if million_per_s > best_million_per_s {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    black_box(best_checksum);
    println!("{name}: {best_million_per_s:.1} M samples/s checksum={best_checksum:.3}");
}

fn bench_distr_f64<D>(name: &str, count: usize, seed: u64, dist: D)
where
    D: RandDistrDistribution<f64> + Copy,
{
    let mut best_million_per_s = 0.0;
    let mut best_checksum = 0.0;
    for _ in 0..TRIALS {
        let mut rng = SmallRng::seed_from_u64(seed);
        let start = Instant::now();
        let mut checksum = 0.0;

        for _ in 0..count {
            checksum += dist.sample(&mut rng);
        }

        let seconds = start.elapsed().as_secs_f64();
        let million_per_s = (count as f64 / 1_000_000.0) / seconds;
        if million_per_s > best_million_per_s {
            best_million_per_s = million_per_s;
            best_checksum = checksum;
        }
    }

    black_box(best_checksum);
    println!("{name}: {best_million_per_s:.1} M samples/s checksum={best_checksum:.3}");
}

fn bench_distr_poisson(name: &str, count: usize) {
    let dist = rand_distr::Poisson::new(20.0).unwrap();
    let mut best_million_per_s = 0.0;
    let mut best_checksum = 0u64;
    for _ in 0..TRIALS {
        let mut rng = SmallRng::seed_from_u64(0xa157);
        let start = Instant::now();
        let mut checksum = 0u64;

        for _ in 0..count {
            checksum = checksum.wrapping_add(dist.sample(&mut rng) as u64);
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

fn bench_distr_binomial(name: &str, count: usize) {
    let dist = rand_distr::Binomial::new(40, 0.25).unwrap();
    let mut best_million_per_s = 0.0;
    let mut best_checksum = 0u64;
    for _ in 0..TRIALS {
        let mut rng = SmallRng::seed_from_u64(0xb157);
        let start = Instant::now();
        let mut checksum = 0u64;

        for _ in 0..count {
            checksum = checksum.wrapping_add(dist.sample(&mut rng));
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
