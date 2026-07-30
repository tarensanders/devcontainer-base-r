#!/bin/bash
# Runs INSIDE the image (mounted from the checkout, not baked in, so it works
# against the previously published image too). Writes two manifests to $1:
#   signal.txt - tool versions + R packages; a diff here triggers a release
#   system.txt - Debian packages; shown in release notes but never a trigger,
#                since apt security bumps land almost weekly
# Deliberately no `set -e`: a tool missing from an older image must produce
# "(not installed)", not abort the snapshot.
set -u
out="$1"

ver() {
  local label="$1"; shift
  local v
  v=$("$@" 2>/dev/null | head -1)
  echo "$label ${v:-(not installed)}"
}

{
  ver R R --version
  ver node node --version
  ver claude-code claude --version
  ver quarto quarto --version
  ver gh gh --version
  ver docker docker --version
  ver radian radian --version
  ver python3 python3 --version
  echo
  Rscript -e 'v <- installed.packages()[, c("Package", "Version")]; cat(sprintf("%s %s\n", v[, 1], v[, 2]))' | sort
} > "$out/signal.txt"

dpkg-query -W -f='${Package} ${Version}\n' | sort > "$out/system.txt"
