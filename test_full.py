#!/usr/bin/env python3
"""
Modified example_usage.py - Support design + evaluator (testcases)
Usage:
  python test_full.py
  python test_full.py --design path/to/design.zip --evaluator path/to/testcases.zip
"""

import os
import sys
import requests
import glob
import argparse
from pathlib import Path

# Configuration
API_KEY = os.getenv("EDA_API_KEY", "test-key")
BASE_URL = os.getenv("EDA_BASE_URL", "http://localhost:8080")
TEST_DIR = "test"

# Colors
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
NC = '\033[0m'

def print_info(msg):
    print(f"{GREEN}[INFO]{NC} {msg}")

def print_warn(msg):
    print(f"{YELLOW}[WARN]{NC} {msg}")

def print_error(msg):
    print(f"{RED}[ERROR]{NC} {msg}")

def find_zip_file(pattern):
    """Find ZIP file matching pattern in test_designs/"""
    files = glob.glob(f"{TEST_DIR}/{pattern}")
    if files:
        return files[0]
    return None

def main():
    parser = argparse.ArgumentParser(description='ChipForge EDA Server - Test with Testcases')
    parser.add_argument('--design', '-d', type=str, help='Path to design ZIP file')
    parser.add_argument('--evaluator', '-e', type=str, help='Path to evaluator/testcases ZIP file')
    args = parser.parse_args()

    print("="*60)
    print("ChipForge EDA Server - Test with Testcases")
    print("="*60)

    # Get design ZIP
    if args.design:
        design_zip = args.design
        if not Path(design_zip).exists():
            print_error(f"Design file not found: {design_zip}")
            sys.exit(1)
        print_info(f"Design: {design_zip}")
    else:
        print_info("Looking for design ZIP...")
        design_zip = (
            find_zip_file("*design*.zip") or
            find_zip_file("challenge_*.zip") or
            find_zip_file("*.zip")
        )

        if not design_zip:
            print_error(f"No design ZIP found in {TEST_DIR}/")
            print_error("Expected file like: *design*.zip, challenge_*.zip, or any .zip")
            print_error("Or use: python test_full.py --design path/to/design.zip --evaluator path/to/testcases.zip")
            sys.exit(1)

        print_info(f"Design: {design_zip}")

    # Get evaluator ZIP
    if args.evaluator:
        evaluator_zip = args.evaluator
        if not Path(evaluator_zip).exists():
            print_error(f"Evaluator file not found: {evaluator_zip}")
            sys.exit(1)
        print_info(f"Evaluator: {evaluator_zip}")
    else:
        print_info("Looking for evaluator ZIP...")
        evaluator_zip = (
            find_zip_file("*evaluator*.zip") or
            find_zip_file("*testcase*.zip") or
            find_zip_file("*test*.zip")
        )

        if not evaluator_zip:
            print_error(f"No evaluator ZIP found in {TEST_DIR}/")
            print_error("Expected file like: *evaluator*.zip, *testcase*.zip, or *test*.zip")
            print("")
            print_warn("To test WITHOUT testcases, use simple_test.py instead")
            print_error("Or use: python test_full.py --design path/to/design.zip --evaluator path/to/testcases.zip")
            sys.exit(1)

        print_info(f"Evaluator: {evaluator_zip}")
    
    # Check file sizes
    design_size = Path(design_zip).stat().st_size / 1024
    eval_size = Path(evaluator_zip).stat().st_size / (1024 * 1024)
    
    print_info(f"Design size: {design_size:.1f} KB")
    print_info(f"Evaluator size: {eval_size:.1f} MB")
    
    print("")
    print_info("="*60)
    print_info("Uploading to API...")
    print_info("This may take several minutes...")
    print_info("="*60)
    
    # Upload both files
    try:
        with open(design_zip, 'rb') as df, open(evaluator_zip, 'rb') as ef:
            files = {
                'design_zip': (Path(design_zip).name, df, 'application/zip'),
                'evaluator_zip': (Path(evaluator_zip).name, ef, 'application/zip'),
            }
            
            headers = {"x-api-key": API_KEY}
            
            # Use /evaluate endpoint for full testing with testcases
            url = f"{BASE_URL}/evaluate"
            print_info(f"Endpoint: {url}")
            
            resp = requests.post(
                url,
                files=files,
                headers=headers,
                timeout=7200  # 2 hours
            )
            
            print("")
            print_info(f"HTTP Status: {resp.status_code}")
            
            if resp.status_code == 200:
                print_info("="*60)
                print_info("SUCCESS!")
                print_info("="*60)
                
                result = resp.json()
                
                # Display results
                print("")
                print_info("--- Results Summary ---")
                
                # Verilator results (functionality)
                verilator = result.get('verilator_results', {})
                if verilator:
                    v_details = verilator.get('results', {})
                    func_score = v_details.get('functionality_score', 0)
                    
                    print_info(f"Functionality Score: {func_score * 100:.1f}%")
                    
                    details = v_details.get('details', {})
                    if details:
                        total_instr = details.get('total_instructions', 0)
                        passed_instr = details.get('instructions_passed', 0)
                        ipc = details.get('ipc', 0)
                        
                        print_info(f"Instructions Passed: {passed_instr}/{total_instr}")
                        print_info(f"IPC: {ipc:.3f}")
                
                # OpenLane results (area/performance)
                openlane = result.get('openlane_results', {})
                if openlane:
                    o_data = openlane.get('results', {})
                    area = o_data.get('area_um2', 0)
                    fmax = o_data.get('fmax_mhz', 0)
                    
                    print_info(f"Area: {area:.1f} µm²")
                    print_info(f"Fmax: {fmax:.2f} MHz")
                
                # Final score
                final_score = result.get('final_score')
                if final_score is not None:
                    print("")
                    print_info("="*60)
                    
                    if isinstance(final_score, dict):
                        overall = final_score.get('overall', 0)
                        print_info(f"FINAL SCORE: {overall:.2f}")

                        if overall >= 70:
                            print_info("EXCELLENT! Score >= 70 - Challenge PASSED!")
                        else:
                            print_warn(f"Score < 70 (got {overall:.2f}). Need improvement.")
                    else:
                        print_info(f"FINAL SCORE: {final_score:.2f}")

                        if final_score >= 70:
                            print_info("EXCELLENT! Score >= 70 - Challenge PASSED!")
                        else:
                            print_warn(f"Score < 70 (got {final_score:.2f}). Need improvement.")
                    
                    print_info("="*60)
                
                # Full JSON response
                print("")
                print_info("Full JSON response:")
                import json
                print(json.dumps(result, indent=2))
                
            else:
                print_error("="*60)
                print_error("FAILED!")
                print_error("="*60)
                print_error(f"Status: {resp.status_code}")
                print_error(resp.text)
                sys.exit(1)
                
    except requests.exceptions.Timeout:
        print_error("Request timeout (> 2 hours)")
        sys.exit(1)
    except requests.exceptions.ConnectionError as e:
        print_error(f"Connection error: {e}")
        print_error("Is the gateway service running?")
        print_error("Check: docker ps | grep gateway")
        sys.exit(1)
    except Exception as e:
        print_error(f"Error: {e}")
        sys.exit(1)
    
    print("")
    print_info("Test completed successfully!")

if __name__ == "__main__":
    main()