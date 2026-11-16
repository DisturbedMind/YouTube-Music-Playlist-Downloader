#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"
export PATH="$PROJECT_DIR/.runtime/bin:$PATH"
if [[ ! -x .venv-debian/bin/python ]]; then
    echo 'Install dependencies first: bash install-debian.sh' >&2
    exit 1
fi
exec .venv-debian/bin/python youtube_music_playlist_downloader.py "$@"
