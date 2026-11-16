#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"
if [[ "$EUID" -eq 0 ]]; then
    echo 'Run this as your desktop user, without sudo. The script uses sudo for apt only.' >&2
    exit 1
fi
sudo apt-get update
sudo apt-get install -y python3 python3-venv python3-tk ffmpeg curl unzip ca-certificates
python3 -m venv .venv-debian
.venv-debian/bin/python -m pip install --upgrade pip
.venv-debian/bin/python -m pip install --upgrade -r requirements.txt

# Keep the JavaScript runtime local to this project.
case "$(uname -m)" in
    x86_64) deno_target=x86_64-unknown-linux-gnu ;;
    aarch64|arm64) deno_target=aarch64-unknown-linux-gnu ;;
    *) echo 'Unsupported Deno architecture. Install a supported JavaScript runtime manually.' >&2; exit 1 ;;
esac
mkdir -p .runtime/bin
archive="$(mktemp)"
trap 'rm -f -- "$archive"' EXIT
curl --fail --location --retry 3 "https://github.com/denoland/deno/releases/latest/download/deno-${deno_target}.zip" -o "$archive"
unzip -o "$archive" -d .runtime/bin
chmod +x .runtime/bin/deno
export PATH="$PROJECT_DIR/.runtime/bin:$PATH"
.venv-debian/bin/python youtube_music_playlist_downloader.py --check-deps
echo 'Setup complete. Start from your desktop terminal with: bash run-debian.sh'
