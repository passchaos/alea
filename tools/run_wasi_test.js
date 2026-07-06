#!/usr/bin/env node
const { WASI } = require('node:wasi');
const fs = require('node:fs');
const { spawnSync } = require('node:child_process');

function usage() {
  console.error('usage: run_wasi_test.js [--dry-run] <test.wasm> [args...]');
  console.error('       run_wasi_test.js --self-test');
  console.error('       --self-test validates dry-run and missing-argument paths without wasm');
}

function dryRunLine(args) {
  return `wasi ${args.join(' ')}`;
}

function selfTest() {
  const script = __filename;
  const defaultRun = spawnSync(process.execPath, [script, '--dry-run', 'sample.wasm', '--flag'], { encoding: 'utf8' });
  if (defaultRun.status !== 0 || defaultRun.stdout.trim() !== 'wasi sample.wasm --flag') {
    console.error('run_wasi_test self-test: dry-run command mismatch');
    console.error(defaultRun.stdout || defaultRun.stderr);
    process.exit(1);
  }

  const missingRun = spawnSync(process.execPath, [script, '--dry-run'], { encoding: 'utf8' });
  if (missingRun.status !== 2 || !missingRun.stderr.includes('usage: run_wasi_test.js')) {
    console.error('run_wasi_test self-test: missing-argument usage mismatch');
    console.error(missingRun.stdout || missingRun.stderr);
    process.exit(1);
  }

  console.log('run_wasi_test self-test ok');
}

const rawArgs = process.argv.slice(2);
if (rawArgs[0] === '--help') {
  usage();
  process.exit(0);
}
if (rawArgs[0] === '--self-test') {
  selfTest();
  process.exit(0);
}

let dryRun = false;
if (rawArgs[0] === '--dry-run') {
  dryRun = true;
  rawArgs.shift();
}

const wasmPath = rawArgs[0];
if (!wasmPath) {
  usage();
  process.exit(2);
}

const wasiArgs = [wasmPath, ...rawArgs.slice(1)];
if (dryRun) {
  console.log(dryRunLine(wasiArgs));
  process.exit(0);
}

const wasi = new WASI({
  version: 'preview1',
  args: wasiArgs,
  env: process.env,
  preopens: {
    '/': '/',
    '.': process.cwd(),
  },
});

(async () => {
  const bytes = fs.readFileSync(wasmPath);
  const module = await WebAssembly.compile(bytes);
  const instance = await WebAssembly.instantiate(module, wasi.getImportObject());
  const exitCode = wasi.start(instance);
  if (typeof exitCode === 'number' && exitCode !== 0) {
    process.exit(exitCode);
  }
})().catch((err) => {
  console.error(err && err.stack ? err.stack : err);
  process.exit(1);
});
