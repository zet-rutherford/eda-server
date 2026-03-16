#!/usr/bin/env python3
"""
OpenLane runner for CoreNPU miner evaluation.
Placeholder - returns dummy success values since synthesis is not used for this challenge.
"""

import json
import sys


def main():
    # Return success with dummy values (synthesis not used for Challenge 0011)
    result = {
        "success": True,
        "results": {
            "area_um2": 0.0,
            "fmax_mhz": 0.0,
            "power_mw": 0.0
        }
    }
    print(json.dumps(result))
    sys.exit(0)


if __name__ == "__main__":
    main()
