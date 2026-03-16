#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker run --rm \
  -v "$SCRIPT_DIR/challenge_0011":/workspace \
  -v "$SCRIPT_DIR/results":/app/results \
  chipforge_eda_server-verilator-api \
  python3 /workspace/miner_evaluator/verilator/run.py \
    --design /workspace/design \
    --resources /workspace/miner_evaluator/verilator \
    --out /app/results/dev_test
