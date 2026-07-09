# S4-M1123 Wasmtime Accepted Profile Runtime Evidence

## Gap

S4-M11 allowed the current blocker to close through any one of these branches:

1. an exact/default-compatible dense SIMD normal/exponential kernel that wins in
   the real vector-slice harness;
2. accepted profile validation on another genuine runtime or architecture target;
3. a newly found local `rand` / `rand_distr` core gap.

No exact/default dense SIMD winner has been found, but this session made a new
non-Node WASI runtime available locally by downloading Wasmtime and executing the
accepted vector-profile validation wasm under it. This is a distinct runtime from
the existing Node WASI evidence and therefore closes the S4-M11 runtime branch
for the current bar.

## Runtime

```text
$ uname -m
x86_64

$ ./.zig-cache/tools/wasmtime-v31.0.0-x86_64-linux/wasmtime --version
wasmtime 31.0.0 (7a9be587f 2025-03-20)
```

The Wasmtime binary was downloaded from the upstream release asset:

```text
https://github.com/bytecodealliance/wasmtime/releases/download/v31.0.0/wasmtime-v31.0.0-x86_64-linux.tar.xz
```

## Validation

The wasm profile executable was built with the existing WASI profile-long build
step, then run directly under Wasmtime:

```text
$ zig build -Doptimize=ReleaseFast wasi-profilelongcheck
...
profilelongcheck ok
.zig-cache/o/49c630dcc41edbdc1de4fcf988b370c3/alea-wasi-profilelongcheck.wasm

$ ./.zig-cache/tools/wasmtime-v31.0.0-x86_64-linux/wasmtime \
  .zig-cache/o/49c630dcc41edbdc1de4fcf988b370c3/alea-wasi-profilelongcheck.wasm
VectorStandardNormalTableF32 seed[0]: mean=-0.00011648 variance=0.99981435 max_abs=4.00877237
VectorStandardNormalTableF32 seed[1]: mean=0.00057318 variance=0.99806206 max_abs=4.00877237
VectorStandardNormalTableF32 seed[2]: mean=-0.00118588 variance=1.00005322 max_abs=4.00877237
VectorStandardNormalTableF32 seed[3]: mean=-0.00042350 variance=0.99972858 max_abs=4.00877237
VectorStandardNormalTableF32 seed[4]: mean=-0.00066204 variance=0.99823496 max_abs=4.00877237
VectorStandardNormalTableF32 seed[5]: mean=0.00076557 variance=0.99902954 max_abs=4.00877237
VectorStandardNormalTableF32 seed[6]: mean=-0.00086918 variance=1.00180518 max_abs=4.00877237
VectorStandardNormalTableF32 seed[7]: mean=0.00170336 variance=1.00057259 max_abs=4.00877237
VectorStandardNormalTableF32 long aggregate: seeds=8 lanes=8388608 mean=-0.00002687 variance=0.99966339 max_abs=4.00877237
  abs_tail(|x|>=2.5)=0.01246202 pos=0.00625122 neg=0.00621080 expected=0.01245117
  abs_tail(|x|>=3.0)=0.00270879 pos=0.00136578 neg=0.00134301 expected=0.00268555
  abs_tail(|x|>=3.5)=0.00049460 pos=0.00025082 neg=0.00024378 expected=0.00048828
  abs_tail(|x|>=4.0)=0.00012398 pos=0.00006378 neg=0.00006020 expected=0.00012207
VectorStandardNormalTableF64 seed[0]: mean=0.00027211 variance=0.99784518 max_abs=4.00877259
VectorStandardNormalTableF64 seed[1]: mean=0.00139791 variance=0.99666285 max_abs=4.00877259
VectorStandardNormalTableF64 seed[2]: mean=-0.00021698 variance=1.00020592 max_abs=4.00877259
VectorStandardNormalTableF64 seed[3]: mean=-0.00053513 variance=0.99983535 max_abs=4.00877259
VectorStandardNormalTableF64 seed[4]: mean=-0.00192636 variance=0.99941601 max_abs=4.00877259
VectorStandardNormalTableF64 seed[5]: mean=-0.00004111 variance=0.99728435 max_abs=4.00877259
VectorStandardNormalTableF64 seed[6]: mean=0.00024162 variance=0.99836098 max_abs=4.00877259
VectorStandardNormalTableF64 seed[7]: mean=0.00040157 variance=1.00258290 max_abs=4.00877259
VectorStandardNormalTableF64 long aggregate: seeds=8 lanes=8388608 mean=-0.00005080 variance=0.99902498 max_abs=4.00877259
  abs_tail(|x|>=2.5)=0.01246059 pos=0.00620747 neg=0.00625312 expected=0.01245117
  abs_tail(|x|>=3.0)=0.00269783 pos=0.00134003 neg=0.00135779 expected=0.00268555
  abs_tail(|x|>=3.5)=0.00049603 pos=0.00023854 neg=0.00025749 expected=0.00048828
  abs_tail(|x|>=4.0)=0.00011671 pos=0.00005555 neg=0.00006115 expected=0.00012207
VectorStandardExponentialTableF32 long aggregate: seeds=8 lanes=8388608 mean=1.00022063 variance=1.00161240 min=0.00003052 max=10.39720726
  tail(x>=4.0)=0.01839852 expected=0.01831055
  tail(x>=6.0)=0.00254965 expected=0.00250244
  tail(x>=8.0)=0.00031030 expected=0.00030518
  tail(x>=10.0)=0.00006211 expected=0.00006104
VectorStandardExponentialTableF64 long aggregate: seeds=8 lanes=8388608 mean=1.00004324 variance=0.99999883 min=0.00003052 max=10.39720771
  tail(x>=4.0)=0.01834273 expected=0.01831055
  tail(x>=6.0)=0.00250745 expected=0.00250244
  tail(x>=8.0)=0.00030458 expected=0.00030518
  tail(x>=10.0)=0.00006151 expected=0.00006104
VectorStandardExponentialApproxLogF32 long aggregate: seeds=8 lanes=8388608 mean=0.99958611 variance=0.99853514 min=-0.00000000 max=17.32868004
  tail(x>=4.0)=0.01828253 expected=0.01831564
  tail(x>=6.0)=0.00244248 expected=0.00247875
  tail(x>=8.0)=0.00033665 expected=0.00033546
  tail(x>=10.0)=0.00004530 expected=0.00004540
profilelongcheck ok
```

A shorter profile smoke was also run directly under Wasmtime and passed:

```text
$ ./.zig-cache/tools/wasmtime-v31.0.0-x86_64-linux/wasmtime \
  .zig-cache/o/5a6de332c07a6d0373dd3486e76f73aa/alea-wasi-profilecheck.wasm
profilecheck ok
```

Repository validation for the evidence/docs/tooling update:

```text
$ zig build roadmapcheck && zig build toolingcheck && zig build rand-status-self-test && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
toolingcheck ok
rand-status self-test ok
statcheck ok
examplecheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M11 is closed for the current bar via its additional-runtime branch. The
exact/default vector normal/exponential APIs still use scalar ziggurat lane-fill,
and the accepted table/approx-log profiles remain explicit opt-in output-mapping
contracts. This is not whole-goal completion: the roadmap now raises the next
bar to broader default/exact dense-kernel work, additional non-WASI architecture
or OS execution, and future local `rand` / `rand_distr` audits.
