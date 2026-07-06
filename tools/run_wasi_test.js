#!/usr/bin/env node
const { WASI } = require('node:wasi');
const fs = require('node:fs');

function usage() {
  console.error('usage: run_wasi_test.js [--dry-run] <test.wasm> [args...]');
}

const rawArgs = process.argv.slice(2);
if (rawArgs[0] === '--help') {
  usage();
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
  console.log(`wasi ${wasiArgs.join(' ')}`);
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
