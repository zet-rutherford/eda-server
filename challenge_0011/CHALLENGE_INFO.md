# Challenge 0011: CoralNPU RTL Bug Fix

## Overview

The CoralNPU is a RISC-V vector processor (RV32 + V extension). The current RTL has bugs that cause incorrect behavior when certain type of illegal instructions (Vector) are exectued. Your task is to identify and fix the bugs to improve the design's functionality score.

**Difficulty:** Medium
**Target Score:** ≥70% functionality

## Getting Started

**Repository:** https://github.com/google-coral/coralnpu (commit `16711f3`)

The CoralNPU is built from Chisel and supports scalar, vector, and verification configurations. You need to generate the SystemVerilog RTL from the Chisel source. The output file should be named `RvvCoreMiniVerificationAxi.sv`.

## Submission Format

Submit a `.zip` file containing your fixed RTL:

### Option 1: rtl.f file list (Recommended)
```
submission.zip
├── rtl.f
├── RvvCoreMiniVerificationAxi.sv
└── [other .sv/.v files if needed]
```

The `rtl.f` should list RTL files relative to its location:
```
RvvCoreMiniVerificationAxi.sv
```

### Option 2: Single file submission
```
submission.zip
└── RvvCoreMiniVerificationAxi.sv
```

**Note:** Submit generated SystemVerilog, not Chisel source.

## Evaluation

Your submission is evaluated on:
1. **Compilation:** RTL must compile with Verilator
2. **Functionality:** Trace comparison against a reference model across a test suite
3. **Score:** Percentage of trace entries matching the reference

Use the provided `miner_evaluator.zip` to test locally before submitting.

## Expected Results

| Design | Approximate Score |
|--------|-------------------|
| Unmodified (commit 16711f3) | ~30% |
| Partial Bug Fix | ≥70% |
| Full Fix | 100% | 

## Files Provided

- `miner_evaluator.zip` — Local testing package with test suite and evaluation scripts
- `CHALLENGE_INFO.md` — This documentation
