#!/usr/bin/env bash
# scripts/dev/prereqs.sh
set -euo pipefail

echo "⏳ Installing build tools & libraries…"
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    build-essential cmake clang-format pkg-config \
    libpcap-dev libfix8-dev libboost-all-dev \
    python3-dev python3-pip python3-venv \
    git curl wget

echo "⏳ Setting up Python venv (./.venv)…"
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install pytest wheel aiohttp websockets fastapi uvicorn

echo "✅  Prerequisites installed"
