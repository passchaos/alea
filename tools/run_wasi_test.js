#!/usr/bin/env node
const { WASI } = require('node:wasi');
const fs = require('node:fs');

const wasmPath = process.argv[2];
if (!wasmPath) {
  console.error('usage: run_wasi_test.js <test.wasm> [args...]');
  process.exit(2);
}

const wasi = new WASI({
  version: 'preview1',
  args: [wasmPath, ...process.argv.slice(3)],
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
