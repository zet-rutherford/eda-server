#!/usr/bin/env python3
"""
CoreNPU Verilator Evaluator for ChipForge Challenge 0011
Evaluates miner's RTL fix

This script:
1. Takes miner's RTL design (design.zip with fixed Verilog)
2. Compiles with Verilator using the provided testbench
3. Runs test programs and captures instruction traces
4. Compares traces with Spike reference
5. Returns functionality score based on trace match percentage
"""

import os
import sys
import json
import subprocess
import shutil
import argparse
import csv
from pathlib import Path


def log(msg):
    """Print log message to stderr (stdout reserved for JSON output)"""
    print(f"[CoreNPU-Eval] {msg}", file=sys.stderr)


def run_cmd(cmd, cwd=None, timeout=600, capture=True):
    """Run shell command with timeout"""
    log(f"Running: {' '.join(cmd) if isinstance(cmd, list) else cmd}")
    try:
        result = subprocess.run(
            cmd,
            shell=isinstance(cmd, str),
            cwd=cwd,
            timeout=timeout,
            capture_output=capture,
            text=True
        )
        return result
    except subprocess.TimeoutExpired:
        log(f"Command timed out after {timeout}s")
        return None
    except Exception as e:
        log(f"Command failed: {e}")
        return None


def find_rtl_files(design_dir):
    """Find RTL files from miner's submission.

    Returns tuple: (files_list, error_message)
    - files_list: List of RTL files found, or empty list if none
    - error_message: Detailed error message if files not found, or None if OK
    """
    design_path = Path(design_dir)

    # List all files in design directory for debugging
    all_files = list(design_path.rglob("*"))
    file_list_str = ", ".join([str(f.relative_to(design_path)) for f in all_files if f.is_file()][:20])

    # Check for rtl.f file list
    rtl_f = design_path / "rtl.f"
    if rtl_f.exists():
        with open(rtl_f, 'r') as f:
            files = []
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and not line.startswith('//') and not line.startswith('-'):
                    files.append(line)

        if not files:
            return [], f"ERROR: rtl.f file exists but is empty or contains only comments. Add your RTL file path to rtl.f (e.g., 'RvvCoreMiniVerificationAxi.sv')"

        # Verify listed files exist
        missing_files = []
        for rtl_file in files:
            full_path = design_path / rtl_file
            if not full_path.exists():
                # Also check in rtl subdirectory
                alt_path = design_path / "rtl" / rtl_file
                if not alt_path.exists():
                    missing_files.append(rtl_file)

        if missing_files:
            return [], f"ERROR: Files listed in rtl.f not found: {missing_files}. Ensure these files exist in your submission zip. Files found in submission: [{file_list_str}]"

        return files, None

    # Fallback: look for the main RTL file directly
    main_rtl = design_path / "RvvCoreMiniVerificationAxi.sv"
    if main_rtl.exists():
        return ["RvvCoreMiniVerificationAxi.sv"], None

    # Last resort: find .sv files
    sv_files = list(design_path.glob("*.sv"))
    rvv_files = [f for f in sv_files if 'RvvCoreMiniVerification' in f.name]
    if rvv_files:
        return [f.name for f in rvv_files], None

    if sv_files:
        # Found some .sv files but not the expected one
        found_sv = [f.name for f in sv_files]
        return [], f"ERROR: RvvCoreMiniVerificationAxi.sv not found. Found these .sv files instead: {found_sv}. Ensure you submit the correct RTL file generated from Chisel."

    # No RTL files at all
    return [], f"ERROR: No RTL files found in submission. Expected either: (1) rtl.f file listing RTL paths, or (2) RvvCoreMiniVerificationAxi.sv in zip root. Files found: [{file_list_str}]"


def parse_verilator_error(stderr):
    """Parse Verilator error output and return a user-friendly message."""
    if not stderr:
        return "Unknown compilation error"

    # Common error patterns and their explanations
    error_lines = []
    for line in stderr.split('\n'):
        if '%Error:' in line:
            error_lines.append(line.strip())

    if not error_lines:
        # Return first 500 chars if no specific error found
        return f"Compilation error: {stderr[:500]}"

    # Analyze the first error
    first_error = error_lines[0]

    # Pattern: syntax error
    if 'syntax error' in first_error.lower():
        return f"SYNTAX ERROR in your RTL: {first_error}. Check the line number indicated and fix the Verilog/SystemVerilog syntax."

    # Pattern: cannot find module
    if 'Cannot find file containing module' in first_error:
        import re
        match = re.search(r"module: '?([^']+)'?", first_error)
        module_name = match.group(1) if match else "unknown"
        if 'RvvCoreMiniVerificationAxi' in module_name:
            return f"MODULE NOT FOUND: The testbench cannot find 'RvvCoreMiniVerificationAxi'. Ensure your submission contains the correct RTL file with this module name."
        return f"MISSING MODULE: '{module_name}' is instantiated but not defined. Ensure all required modules are included in your submission."

    # Pattern: missing module reference (dotted reference)
    if 'missing module' in first_error.lower() and 'RvvCoreMiniVerificationAxi' in first_error:
        return f"MODULE NOT FOUND: Your submission is missing the 'RvvCoreMiniVerificationAxi' module. The testbench expects this module to exist. Ensure you submit the correct RTL file generated from Chisel."

    # Pattern: port not found
    if 'not found in module' in first_error.lower():
        return f"PORT MISMATCH: {first_error}. Your module interface doesn't match expected ports. Use the correct Bazel build target to generate RTL."

    # Pattern: file not found
    if 'Cannot find' in first_error or 'No such file' in first_error:
        return f"FILE NOT FOUND: {first_error}. Check that all files listed in rtl.f exist in your submission."

    # Default: return the error as-is
    return f"COMPILATION ERROR: {first_error}"


def compile_design(design_dir, resources_dir, build_dir):
    """Compile miner's RTL with Verilator.

    Returns tuple: (success, error_message)
    - success: True if compilation succeeded
    - error_message: Detailed error message if failed, None if OK
    """
    log("Compiling design with Verilator...")

    # Use absolute paths to avoid path resolution issues when verilator runs in build_dir
    design_path = Path(design_dir).resolve()
    resources_path = Path(resources_dir).resolve()
    build_path = Path(build_dir).resolve()

    # Find miner's RTL files
    rtl_files, rtl_error = find_rtl_files(design_dir)
    if rtl_error:
        log(rtl_error)
        return False, rtl_error

    if not rtl_files:
        err = "ERROR: No RTL files found in design submission"
        log(err)
        return False, err

    log(f"Found {len(rtl_files)} RTL file(s): {rtl_files}")

    # Get testbench files from resources (use absolute paths)
    tb_dir = (resources_path / "tb").resolve()
    tb_files = []
    for tb_file in ["axi_pkg.sv", "axi_slave_memory.sv", "retirement_tracer.sv", "tb_top.sv"]:
        tb_path = tb_dir / tb_file
        if tb_path.exists():
            tb_files.append(str(tb_path.resolve()))
        else:
            log(f"WARNING: Missing testbench file: {tb_file}")

    if not tb_files:
        err = "ERROR: Testbench files not found in evaluator resources"
        log(err)
        return False, err

    # Create file list for Verilator
    filelist = build_path / "verilator.f"
    design_path_abs = design_path.resolve()
    resources_path_abs = resources_path.resolve()

    # Track which RTL files are actually found
    resolved_rtl_files = []
    missing_rtl_files = []

    with open(filelist, 'w') as f:
        # Include paths (use absolute paths)
        f.write(f"-I{design_path_abs}\n")
        f.write(f"-I{design_path_abs}/rtl\n")
        f.write(f"-I{resources_path_abs}/rtl\n")
        f.write(f"-I{resources_path_abs}/tb\n")

        # Miner's RTL files (resolve paths to absolute)
        for rtl in rtl_files:
            if os.path.isabs(rtl):
                if Path(rtl).exists():
                    f.write(f"{rtl}\n")
                    resolved_rtl_files.append(rtl)
                else:
                    missing_rtl_files.append(rtl)
            else:
                # Try design dir first, then subdirs
                full_path = design_path_abs / rtl
                if not full_path.exists():
                    full_path = design_path_abs / "rtl" / rtl
                if full_path.exists():
                    f.write(f"{full_path}\n")
                    resolved_rtl_files.append(str(full_path))
                else:
                    missing_rtl_files.append(rtl)
                    f.write(f"{design_path_abs / rtl}\n")  # Write anyway, let verilator report

        # Testbench files
        for tb in tb_files:
            f.write(f"{tb}\n")

    if missing_rtl_files:
        log(f"WARNING: Some RTL files from rtl.f not found: {missing_rtl_files}")

    # Verilator command
    verilator_cmd = [
        "verilator",
        "--binary",
        "--trace",
        "-j", str(os.cpu_count() or 4),
        "--top-module", "tb_top",
        "-f", str(filelist),
        "--Mdir", str(build_path),
        "-Wno-fatal",
        "-Wno-WIDTH",
        "-Wno-LATCH",
        "-Wno-UNOPTFLAT",
        "-Wno-IMPLICIT",
        "-Wno-PINMISSING",
        "-Wno-UNUSEDSIGNAL",
        "-Wno-UNUSEDPARAM",
        "+define+USE_RVV_VERIFICATION",
    ]

    result = run_cmd(verilator_cmd, cwd=str(build_path), timeout=1800)

    if result is None:
        err = "ERROR: Verilator compilation timed out (>30 minutes). Your RTL may be too complex or have infinite loops in generate blocks."
        log(err)
        return False, err

    if result.returncode != 0:
        # Parse and provide helpful error message
        err_msg = parse_verilator_error(result.stderr)
        log(f"Verilator compilation failed: {err_msg}")
        log(f"Full stderr (first 2000 chars): {result.stderr[:2000]}")
        return False, err_msg

    # Check if executable was created
    exe_path = build_path / "Vtb_top"
    if not exe_path.exists():
        err = "ERROR: Compilation appeared to succeed but executable not created. This may indicate a linker error."
        log(err)
        return False, err

    log("Compilation successful!")
    return True, None


def run_test(build_dir, test_mem, trace_file, timeout=120):
    """Run a single test and generate trace"""
    exe_path = Path(build_dir) / "Vtb_top"

    cmd = [str(exe_path)]
    if test_mem:
        # Use absolute path for test file
        test_mem_abs = str(Path(test_mem).resolve())
        cmd.append(f"+TEST_FILE={test_mem_abs}")
    cmd.append(f"+TRACE_FILE={trace_file}")
    cmd.append("+TIMEOUT=10000")  # 10K cycles max per test

    result = run_cmd(cmd, cwd=str(build_dir), timeout=timeout)
    if result is None:
        return False, "Timeout"

    # Check if trace file was created
    if not Path(trace_file).exists():
        return False, "No trace generated"

    return True, result.stdout


def convert_coral_trace(trace_log, csv_output, scripts_dir=None):
    """Convert Coral trace log to CSV format using external script.

    Uses scripts/coral_trace_to_csv.py which handles:
    - Duplicate retirement detection (BUG-008)
    - Proper loop detection
    - WFI termination

    Falls back to inline parsing if script not available.
    """
    # Try using the external script first (more robust)
    if scripts_dir:
        script_path = Path(scripts_dir) / "coral_trace_to_csv.py"
        if script_path.exists():
            cmd = [sys.executable, str(script_path), str(trace_log), "-o", str(csv_output)]
            result = run_cmd(cmd, timeout=60)
            if result and result.returncode == 0:
                # Count lines in output CSV
                try:
                    with open(csv_output, 'r') as f:
                        return sum(1 for _ in f) - 1  # Subtract header
                except:
                    pass

    # Fallback: inline parsing (simplified)
    raw_rows = []
    with open(trace_log, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) < 4:
                continue
            try:
                order = int(parts[0])
                pc = parts[2].lower().replace('0x', '').lstrip('0') or '0'
                inst = parts[3].lower().replace('0x', '').lstrip('0') or '0'

                # Stop at WFI instruction
                if inst == '10500073':
                    break

                rd = '-'
                rd_value = '-'

                # Parse rd=value if present
                for part in parts[4:]:
                    if '=' in part:
                        kv = part.split('=')
                        if len(kv) == 2:
                            rd = kv[0]
                            rd_value = kv[1].lower().replace('0x', '')
                            break

                # Skip instructions without register writeback (branches, stores)
                # This matches Spike's trace convention
                if rd == '-' or rd == '' or rd_value == '-':
                    continue

                raw_rows.append({
                    'pc': pc,
                    'inst': inst,
                    'rd': rd,
                    'rd_value': rd_value
                })
            except (ValueError, IndexError):
                continue

    # Re-number rows after filtering
    rows = []
    for i, row in enumerate(raw_rows, 1):
        row['order'] = i
        rows.append(row)

    with open(csv_output, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['order', 'pc', 'inst', 'rd', 'rd_value'])
        writer.writeheader()
        writer.writerows(rows)

    return len(rows)


def is_memory_load(inst_hex):
    """Check if instruction is a memory load (returns True for LW, LH, LB, etc.)"""
    try:
        inst = int(inst_hex, 16)
        opcode = inst & 0x7f
        # Scalar load: opcode = 0x03, Vector load: opcode = 0x07
        return opcode in (0x03, 0x07)
    except:
        return False


def is_nan_boxing_match(spike_val, coral_val):
    """Check if values match accounting for NaN-boxing difference.

    Spike uses 64-bit NaN-boxed representation for floats (0xffffffff prefix).
    Coral uses 32-bit representation. If they differ only in NaN-boxing, it's a match.
    """
    if spike_val.startswith('ffffffff'):
        spike_lower = spike_val[-8:].lstrip('0') or '0'
        coral_norm = coral_val.lstrip('0') or '0'
        return spike_lower == coral_norm
    return False


def compare_traces_strict(coral_csv, spike_csv):
    """
    Compare Coral trace with Spike trace - STRICT MODE.

    This comparison:
    - FAILS on register value mismatches (bugs miners must fix)
    - IGNORES LENGTH_MISMATCH of 1 (WFI termination timing)
    - IGNORES memory init mismatches (Spike=0, Coral=non-zero)
    - IGNORES NaN-boxing differences for float registers
    - IGNORES v0 trace value (known debug trace limitation)
    """
    def load_csv(path):
        rows = []
        with open(path, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                rows.append(row)
        return rows

    try:
        coral = load_csv(coral_csv)
        spike = load_csv(spike_csv)
    except Exception as e:
        log(f"Error loading CSV files: {e}")
        return 0.0, 0, 0, [str(e)]

    if not coral or not spike:
        return 0.0, 0, 0, ["Empty trace files"]

    # Align traces by minimum length
    min_len = min(len(coral), len(spike))

    match_count = 0
    mismatch_count = 0
    errors = []

    for i in range(min_len):
        c = coral[i]
        s = spike[i]

        # Compare PC (normalized - strip leading zeros)
        coral_pc = c.get('pc', '').lower().lstrip('0') or '0'
        spike_pc = s.get('pc', '').lower().lstrip('0') or '0'

        if coral_pc != spike_pc:
            mismatch_count += 1
            if len(errors) < 20:
                errors.append({
                    'index': i + 1,
                    'type': 'PC_MISMATCH',
                    'spike_pc': s.get('pc'),
                    'coral_pc': c.get('pc')
                })
            continue

        # Compare instruction encoding
        coral_inst = c.get('inst', '').lower().lstrip('0') or '0'
        spike_inst = s.get('inst', '').lower().lstrip('0') or '0'

        if coral_inst != spike_inst:
            mismatch_count += 1
            if len(errors) < 20:
                errors.append({
                    'index': i + 1,
                    'type': 'INST_MISMATCH',
                    'spike_inst': s.get('inst'),
                    'coral_inst': c.get('inst')
                })
            continue

        # Get register and values
        rd = s.get('rd', '-')
        coral_val = c.get('rd_value', '0').lower().lstrip('0') or '0'
        spike_val = s.get('rd_value', '0').lower().lstrip('0') or '0'

        # Skip comparison for v0 (known debug trace limitation)
        if rd == 'v0':
            match_count += 1
            continue

        # Skip if rd value is '-' (no writeback)
        if coral_val == '-' or spike_val == '-':
            # Special case: Spike shows rd but Coral doesn't (or vice versa)
            # This can happen for certain instructions where tracer behavior differs
            if coral_val == '-' and spike_val != '-':
                # Coral missing rd - might be tracer difference, not penalize hard
                match_count += 1
                continue
            match_count += 1
            continue

        # Compare rd value
        if coral_val != spike_val:
            # Check for memory initialization mismatch (verif issue, not RTL bug)
            inst_hex = s.get('inst', '0')
            if is_memory_load(inst_hex):
                # Memory init: Spike=0 and Coral=non-zero (or vice versa)
                if spike_val == '0' or coral_val == '0':
                    match_count += 1
                    continue

            # Check for NaN-boxing mismatch (float register tracer difference)
            if rd.startswith('f'):
                spike_raw = s.get('rd_value', '0').lower()
                coral_raw = c.get('rd_value', '0').lower()
                # Case 1: NaN-boxing match (same value, different representation)
                if is_nan_boxing_match(spike_raw, coral_raw):
                    match_count += 1
                    continue
                # Case 2: Float memory init mismatch
                # Spike shows NaN-boxed 0.0 (ffffffff00000000), Coral shows actual memory
                if spike_raw.startswith('ffffffff') and spike_raw.endswith('00000000'):
                    # Spike loaded 0.0 from uninitialized memory, Coral has different init
                    match_count += 1
                    continue

            # This is a real mismatch
            mismatch_count += 1
            if len(errors) < 20:
                errors.append({
                    'index': i + 1,
                    'type': 'VALUE_MISMATCH',
                    'pc': s.get('pc'),
                    'rd': rd,
                    'spike_value': s.get('rd_value'),
                    'coral_value': c.get('rd_value'),
                })
            continue

        match_count += 1

    # Length mismatch handling
    # Allow difference of 1 (WFI termination timing difference)
    length_diff = abs(len(coral) - len(spike))
    if length_diff > 1:
        # Penalize large length differences
        mismatch_count += (length_diff - 1)  # Only penalize excess beyond 1
        if len(errors) < 20:
            errors.append({
                'type': 'LENGTH_MISMATCH',
                'coral_len': len(coral),
                'spike_len': len(spike)
            })

    total = match_count + mismatch_count
    score = match_count / total if total > 0 else 0.0

    return score, match_count, mismatch_count, errors


def evaluate(design_dir, resources_dir, output_dir):
    """Main evaluation function"""
    log("=" * 60)
    log("CoreNPU Challenge 0011 - RTL Bug Fix Evaluation")
    log("=" * 60)
    log(f"Design dir: {design_dir}")
    log(f"Resources dir: {resources_dir}")
    log(f"Output dir: {output_dir}")

    results = {
        'success': False,
        'functionality_score': 0.0,
        'details': {
            'tests_passed': 0,
            'tests_total': 0,
            'ipc': 1.0,
            'compilation_success': False,
            'errors': []
        }
    }

    # Use absolute paths to ensure consistency across all function calls
    output_path = Path(output_dir).resolve()

    # Create clean build directory (remove stale artifacts from previous runs)
    build_dir = output_path / "build"
    if build_dir.exists():
        shutil.rmtree(build_dir)
    build_dir.mkdir(parents=True, exist_ok=True)

    # Step 1: Compile design
    log("\n[STEP 1] Compiling miner's RTL with Verilator...")
    compile_success, compile_error = compile_design(design_dir, resources_dir, build_dir)
    if not compile_success:
        results['details']['errors'].append(compile_error or "Compilation failed")
        return results

    results['details']['compilation_success'] = True

    # Step 2: Find test cases
    log("\n[STEP 2] Loading test cases...")
    tests_dir = Path(resources_dir) / "tests"
    # Exclude .data.mem files (data memory, not instruction tests)
    test_mems = sorted([f for f in tests_dir.glob("test_*.mem")
                        if not f.name.endswith('.data.mem')])

    if not test_mems:
        log("WARNING: No test cases found in tests/ directory")
        results['details']['errors'].append("No test cases found")
        return results

    log(f"Found {len(test_mems)} test cases")

    # Step 3: Run each test
    log("\n[STEP 3] Running tests and comparing traces...")
    total_score = 0.0
    tests_passed = 0
    all_errors = []

    for i, test_mem in enumerate(test_mems):
        test_name = test_mem.stem
        log(f"\n--- Test {i+1}/{len(test_mems)}: {test_name} ---")

        # Paths for this test (use absolute paths)
        trace_log = output_path / f"{test_name}_coral.log"
        coral_csv = output_path / f"{test_name}_coral.csv"
        spike_csv = tests_dir / f"{test_name}_spike.csv"

        # Check if spike reference exists
        if not spike_csv.exists():
            log(f"  WARNING: No Spike reference for {test_name}")
            all_errors.append(f"{test_name}: Missing Spike reference trace")
            continue

        # Run simulation
        success, output = run_test(
            build_dir,
            str(test_mem),
            str(trace_log),
            timeout=300
        )

        if not success:
            log(f"  FAIL: Simulation error - {output}")
            all_errors.append(f"{test_name}: Simulation failed - {output}")
            continue

        # Convert trace to CSV
        if not trace_log.exists():
            log(f"  FAIL: No trace generated")
            all_errors.append(f"{test_name}: No trace output")
            continue

        scripts_dir = Path(resources_dir) / "scripts"
        num_instr = convert_coral_trace(trace_log, coral_csv, scripts_dir)
        log(f"  Coral trace: {num_instr} instructions")

        # Compare with Spike reference (STRICT)
        score, matches, mismatches, errors = compare_traces_strict(
            str(coral_csv),
            str(spike_csv)
        )

        total_score += score

        if score >= 0.99:
            tests_passed += 1
            log(f"  PASS: score={score:.4f} ({matches}/{matches+mismatches})")
        else:
            log(f"  FAIL: score={score:.4f} ({matches}/{matches+mismatches} mismatches={mismatches})")
            # Log first few errors
            for err in errors[:3]:
                if err.get('type') == 'VALUE_MISMATCH':
                    log(f"    PC={err.get('pc')} {err.get('rd')}: "
                        f"expected={err.get('spike_value')} got={err.get('coral_value')} "
                        f"{err.get('note', '')}")
                else:
                    log(f"    {err}")

        if errors:
            all_errors.extend([f"{test_name}: {e}" for e in errors[:5]])

    # Calculate final score
    num_tests = len(test_mems)
    avg_score = total_score / num_tests if num_tests > 0 else 0.0

    results['success'] = True
    results['functionality_score'] = avg_score
    results['details']['tests_passed'] = tests_passed
    results['details']['tests_total'] = num_tests
    results['details']['errors'] = all_errors[:50]

    log("\n" + "=" * 60)
    log(f"FINAL RESULTS")
    log(f"  Tests passed: {tests_passed}/{num_tests}")
    log(f"  Functionality score: {avg_score:.4f} ({avg_score*100:.2f}%)")
    log("=" * 60)

    return results


def main():
    parser = argparse.ArgumentParser(
        description="CoreNPU Verilator Evaluator for Challenge 0011"
    )
    parser.add_argument(
        "--design",
        required=True,
        help="Path to miner's design directory"
    )
    parser.add_argument(
        "--resources",
        required=True,
        help="Path to evaluator resources directory"
    )
    parser.add_argument(
        "--out",
        default="/tmp/coralnpu_eval",
        help="Output directory for results"
    )
    args = parser.parse_args()

    # Validate inputs
    if not Path(args.design).exists():
        print(json.dumps({
            'success': False,
            'functionality_score': 0.0,
            'details': {'errors': [f"Design directory not found: {args.design}"]}
        }))
        sys.exit(1)

    if not Path(args.resources).exists():
        print(json.dumps({
            'success': False,
            'functionality_score': 0.0,
            'details': {'errors': [f"Resources directory not found: {args.resources}"]}
        }))
        sys.exit(1)

    # Create output directory
    output_dir = Path(args.out)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Run evaluation
    results = evaluate(args.design, args.resources, str(output_dir))

    # Create results archive
    try:
        results_zip = output_dir / "results.zip"
        shutil.make_archive(str(results_zip.with_suffix('')), 'zip', str(output_dir))
        results['details']['results_zip'] = str(results_zip)
    except Exception as e:
        log(f"Warning: Could not create results archive: {e}")

    # Output JSON to stdout (required by EDA server gateway)
    print(json.dumps(results))


if __name__ == "__main__":
    main()
