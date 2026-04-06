#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <version> <sha256>" >&2
  exit 1
fi

VERSION="$1"
SHA="$2"

python3 - "$VERSION" "$SHA" <<'PY'
from pathlib import Path
import re
import sys

version = sys.argv[1]
sha = sys.argv[2]
path = Path("Casks/killsnail.rb")
text = path.read_text(encoding="utf-8")
text = re.sub(r'version ".*?"', f'version "{version}"', text)
text = re.sub(r'sha256 ".*?"', f'sha256 "{sha}"', text)
path.write_text(text, encoding="utf-8")
PY
