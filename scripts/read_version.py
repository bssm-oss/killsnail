#!/usr/bin/env python3
from pathlib import Path
import re
import sys

text = Path("project.yml").read_text(encoding="utf-8")
match = re.search(r"MARKETING_VERSION:\s*([0-9]+\.[0-9]+\.[0-9]+)", text)

if not match:
    sys.exit("Unable to find MARKETING_VERSION in project.yml")

print(match.group(1))
