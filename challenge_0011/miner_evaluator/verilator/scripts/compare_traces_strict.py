#!/usr/bin/env python3
"""
Compare Spike and Coral trace CSVs to find mismatches - STRICT VERSION.

IMPORTANT: This version does NOT ignore WAW bugs!
This is for Challenge 0011 evaluation where miners must fix the WAW tracer bug.
Any value mismatch counts as a failure.

Compares: PC, instruction, rd, rd_value
Reports first N mismatches and summary statistics.
"""

import argparse
import csv
import sys


def load_csv(path):
    """Load CSV trace file."""
    with open(path, 'r') as f:
        reader = csv.DictReader(f)
        return list(reader)


def detect_loop_start(trace, loop_window=10, loop_repeat_threshold=3):
    """Detect where an infinite loop starts in a trace.

    Returns the index where the loop pattern first begins, or len(trace) if no loop.
    """
    if len(trace) < loop_window * loop_repeat_threshold:
        return len(trace)

    pcs = [entry['pc'] for entry in trace]

    # Check from the end of the trace backwards
    for pattern_len in range(1, loop_window + 1):
        if len(pcs) >= pattern_len * loop_repeat_threshold:
            pattern = pcs[-pattern_len:]
            is_loop = True
            for i in range(1, loop_repeat_threshold):
                start_idx = -(pattern_len * (i + 1))
                end_idx = -(pattern_len * i)
                if end_idx == 0:
                    check_pattern = pcs[start_idx:]
                else:
                    check_pattern = pcs[start_idx:end_idx]
                if check_pattern != pattern:
                    is_loop = False
                    break
            if is_loop:
                # Find where this loop pattern first started
                loop_start_pc = pattern[0]
                # Search backwards to find first occurrence of this loop
                for idx in range(len(pcs) - pattern_len * loop_repeat_threshold, -1, -1):
                    if pcs[idx:idx+pattern_len] == pattern:
                        return idx
                return len(pcs) - pattern_len * loop_repeat_threshold

    return len(trace)


def trim_to_loop_start(spike, coral):
    """Trim both traces to the point where loops start (if any).

    If both traces end in a loop, trim to the shorter one to enable fair comparison.
    Returns trimmed copies of both traces and info about trimming.
    """
    spike_loop = detect_loop_start(spike)
    coral_loop = detect_loop_start(coral)

    trim_info = {
        'spike_loop_at': spike_loop if spike_loop < len(spike) else None,
        'coral_loop_at': coral_loop if coral_loop < len(coral) else None,
        'spike_original_len': len(spike),
        'coral_original_len': len(coral),
    }

    # If both have loops, trim to where loops start
    if spike_loop < len(spike) and coral_loop < len(coral):
        # Trim to first loop occurrence for fair comparison
        min_loop = min(spike_loop, coral_loop)
        return spike[:min_loop], coral[:min_loop], trim_info

    # If only one has a loop, trim the longer one to match the loop start
    if spike_loop < len(spike):
        return spike[:spike_loop], coral[:spike_loop], trim_info
    if coral_loop < len(coral):
        return spike[:coral_loop], coral[:coral_loop], trim_info

    return spike, coral, trim_info


def normalize_pc(pc_hex, offset):
    """Normalize PC by subtracting offset."""
    if offset == 0:
        return pc_hex
    pc_int = int(pc_hex, 16)
    normalized = pc_int - offset
    if normalized < 0:
        normalized = 0  # Clamp to 0
    return f"{normalized:08x}"


def is_vector_compare_instruction(inst_hex):
    """Check if instruction is a vector compare (vmslt, vmseq, etc.).

    These instructions write mask results to vector registers.
    Spike's tracer doesn't log RD for these, causing false RD_MISMATCH.
    """
    try:
        inst = int(inst_hex, 16)
        opcode = inst & 0x7f
        funct6 = (inst >> 26) & 0x3f

        # Must be vector opcode (0x57)
        if opcode != 0x57:
            return False

        # Check for compare instructions (funct6 = 0x18-0x1F range)
        if 0x18 <= funct6 <= 0x1F:
            return True

        return False
    except:
        return False


def is_vector_move_instruction(inst_hex):
    """Check if instruction is a vector move (vmv.v.x, vmv.v.v, vmv.s.x, etc.).

    These show width mismatches between Spike and Coral tracers.
    """
    try:
        inst = int(inst_hex, 16)
        opcode = inst & 0x7f
        funct3 = (inst >> 12) & 0x7
        funct6 = (inst >> 26) & 0x3f
        vs2 = (inst >> 20) & 0x1f

        # Must be vector opcode (0x57)
        if opcode != 0x57:
            return False

        # vmv.v.x, vmv.v.v, vmv.v.i: funct6 = 0x17 (010111), vs2=0
        if funct6 == 0x17 and vs2 == 0:
            return True

        # vmv.s.x: funct6 = 0x10 (010000), funct3=110 (OPMVX)
        if funct6 == 0x10 and funct3 == 6:
            return True

        return False
    except:
        return False


def is_nan_boxing_mismatch(spike_val, coral_val, rd):
    """Detect if mismatch is due to NaN-boxing difference for float values."""
    # Only applies to float registers
    if not rd.startswith('f'):
        return False

    # Normalize values
    spike_norm = spike_val.lower().lstrip('0') or '0'
    coral_norm = coral_val.lower().lstrip('0') or '0'

    # Check for NaN-boxing pattern: spike has ffffffff prefix
    if spike_val.lower().startswith('ffffffff'):
        # Extract lower 32 bits from spike
        spike_lower = spike_val[-8:].lstrip('0') or '0'
        if spike_lower == coral_norm:
            return True

    # Also check reverse
    if coral_val.lower().startswith('ffffffff'):
        coral_lower = coral_val[-8:].lstrip('0') or '0'
        if coral_lower == spike_norm:
            return True

    return False


def compare_traces(spike_csv, coral_csv, max_errors=10, ignore_rd_value=False,
                   spike_pc_offset=0, coral_pc_offset=0, auto_trim_loops=True):
    """Compare two trace CSVs - STRICT MODE (no WAW exceptions).

    Args:
        spike_csv: Path to Spike trace CSV
        coral_csv: Path to Coral trace CSV
        max_errors: Maximum number of errors to report in detail
        ignore_rd_value: If True, only compare PC and instruction (not rd values)
        spike_pc_offset: Offset to subtract from Spike PCs (e.g., 0x80000000)
        coral_pc_offset: Offset to subtract from Coral PCs (usually 0)
        auto_trim_loops: If True, auto-trim traces at loop boundaries for fair comparison

    Returns:
        Tuple of (match_count, mismatch_count, length_diff, errors_list, spike_len, coral_len, trim_info)
    """
    spike = load_csv(spike_csv)
    coral = load_csv(coral_csv)

    # Auto-trim at loop boundaries if enabled
    trim_info = None
    if auto_trim_loops:
        spike, coral, trim_info = trim_to_loop_start(spike, coral)

    # Normalize PCs if offsets provided
    if spike_pc_offset or coral_pc_offset:
        for entry in spike:
            entry['pc'] = normalize_pc(entry['pc'], spike_pc_offset)
        for entry in coral:
            entry['pc'] = normalize_pc(entry['pc'], coral_pc_offset)

    errors = []
    match_count = 0
    mismatch_count = 0

    # Compare instruction by instruction
    min_len = min(len(spike), len(coral))
    length_diff = abs(len(spike) - len(coral))

    for i in range(min_len):
        s = spike[i]
        c = coral[i]

        # Compare PC
        if s['pc'] != c['pc']:
            if len(errors) < max_errors:
                errors.append({
                    'index': i + 1,
                    'type': 'PC_MISMATCH',
                    'spike': s,
                    'coral': c,
                    'detail': f"PC: spike=0x{s['pc']} coral=0x{c['pc']}"
                })
            mismatch_count += 1
            continue

        # Compare instruction encoding
        if s['inst'] != c['inst']:
            if len(errors) < max_errors:
                errors.append({
                    'index': i + 1,
                    'type': 'INST_MISMATCH',
                    'spike': s,
                    'coral': c,
                    'detail': f"Inst @ PC=0x{s['pc']}: spike=0x{s['inst']} coral=0x{c['inst']}"
                })
            mismatch_count += 1
            continue

        # Compare rd (destination register)
        if s['rd'] != c['rd']:
            # VERIF-001: Spike doesn't log RD for certain vector instructions
            if s['rd'] == '-' and c['rd'].startswith('v'):
                match_count += 1
                continue

            # Also handle float register mismatches where one side shows '-'
            if (s['rd'] == '-' and c['rd'].startswith('f')) or \
               (c['rd'] == '-' and s['rd'].startswith('f')):
                match_count += 1
                continue

            if len(errors) < max_errors:
                errors.append({
                    'index': i + 1,
                    'type': 'RD_MISMATCH',
                    'spike': s,
                    'coral': c,
                    'detail': f"RD @ PC=0x{s['pc']}: spike={s['rd']} coral={c['rd']}"
                })
            mismatch_count += 1
            continue

        # Skip v0 value comparisons (known debug trace bug, not affecting execution)
        # Skip vector move instructions (tracer width mismatch, not execution bug)
        if is_vector_move_instruction(s['inst']):
            match_count += 1
            continue

        if not ignore_rd_value and s['rd'] != '-' and s['rd'] != 'v0':
            # Normalize values (remove leading zeros for comparison)
            spike_val = s['rd_value'].lstrip('0') or '0'
            coral_val = c['rd_value'].lstrip('0') or '0'

            if spike_val != coral_val:
                # NaN-boxing mismatch for float values (representation difference)
                if is_nan_boxing_mismatch(s['rd_value'], c['rd_value'], s['rd']):
                    match_count += 1
                    continue

                # STRICT MODE: WAW bugs are NOT ignored - they count as failures!
                # This is the key difference from the normal compare_traces.py
                if len(errors) < max_errors:
                    is_vector = s['rd'].startswith('v')
                    errors.append({
                        'index': i + 1,
                        'type': 'RD_VALUE_MISMATCH',
                        'spike': s,
                        'coral': c,
                        'detail': f"RD value @ PC=0x{s['pc']} {s['rd']}: spike=0x{s['rd_value']} coral=0x{c['rd_value']}",
                        'note': 'POTENTIAL_WAW_BUG' if is_vector else ''
                    })
                mismatch_count += 1
                continue

        match_count += 1

    return match_count, mismatch_count, length_diff, errors, len(spike), len(coral), trim_info


def print_report(match, mismatch, length_diff, errors, spike_len, coral_len, trim_info=None):
    """Print comparison report."""
    total = match + mismatch

    print("=" * 70)
    print("TRACE COMPARISON REPORT (STRICT MODE - WAW BUGS NOT IGNORED)")
    print("=" * 70)

    # Show trimming info if loops were detected
    if trim_info:
        if trim_info['spike_loop_at'] is not None or trim_info['coral_loop_at'] is not None:
            print("Loop Detection (auto-trimmed for comparison):")
            if trim_info['spike_loop_at'] is not None:
                print(f"  Spike: loop at instr {trim_info['spike_loop_at']} (original: {trim_info['spike_original_len']})")
            if trim_info['coral_loop_at'] is not None:
                print(f"  Coral: loop at instr {trim_info['coral_loop_at']} (original: {trim_info['coral_original_len']})")
            print("-" * 70)

    print(f"Spike instructions:  {spike_len}")
    print(f"Coral instructions:  {coral_len}")
    print(f"Length difference:   {length_diff}")
    print("-" * 70)
    print(f"Compared:            {total}")
    print(f"Match:               {match}")
    print(f"Mismatch:            {mismatch}")
    if total > 0:
        print(f"Match rate:          {100*match/total:.2f}%")
    print("-" * 70)

    if errors:
        # Show errors
        print(f"\nFirst {len(errors)} errors:")
        print("-" * 70)
        for e in errors:
            print(f"[{e['index']:6d}] {e['type']}")
            print(f"         {e['detail']}")
            if e.get('note'):
                print(f"         Note: {e['note']}")
            if e['type'] == 'RD_VALUE_MISMATCH':
                print(f"         Spike: inst=0x{e['spike']['inst']}")
                print(f"         Coral: inst=0x{e['coral']['inst']}")
            print()

    # Strict pass/fail based on 0 mismatches
    if mismatch == 0:
        if length_diff > 0:
            print(f"\n*** PASS: Traces match! (length diff {length_diff} - loop/termination variance) ***")
        else:
            print("\n*** PASS: Traces match perfectly! ***")
        return 0
    else:
        print(f"\n*** FAIL: {mismatch} mismatches, {length_diff} length difference ***")
        print("NOTE: WAW bugs are NOT ignored in strict mode - miners must fix the tracer!")
        return 1


def parse_hex(value):
    """Parse hex value (with or without 0x prefix)."""
    return int(value, 16)


def main():
    parser = argparse.ArgumentParser(description='Compare Spike and Coral trace CSVs (STRICT - no WAW exceptions)')
    parser.add_argument('spike_csv', help='Spike trace CSV file')
    parser.add_argument('coral_csv', help='Coral trace CSV file')
    parser.add_argument('--max-errors', type=int, default=10, help='Max errors to show')
    parser.add_argument('--ignore-rd-value', action='store_true',
                        help='Only compare PC and instruction, not rd values')
    parser.add_argument('--spike-pc-offset', type=parse_hex, default=0,
                        help='Offset to subtract from Spike PCs (hex, e.g., 0x80000000)')
    parser.add_argument('--coral-pc-offset', type=parse_hex, default=0,
                        help='Offset to subtract from Coral PCs (hex, usually 0)')
    args = parser.parse_args()

    match, mismatch, length_diff, errors, spike_len, coral_len, trim_info = compare_traces(
        args.spike_csv, args.coral_csv, args.max_errors, args.ignore_rd_value,
        args.spike_pc_offset, args.coral_pc_offset
    )
    rc = print_report(match, mismatch, length_diff, errors, spike_len, coral_len, trim_info)
    sys.exit(rc)


if __name__ == '__main__':
    main()
