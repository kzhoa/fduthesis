#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
engine=${1:-xelatex}
case "$engine" in
  xelatex|lualatex) ;;
  *) echo "usage: $0 [xelatex|lualatex] [tex-file]" >&2; exit 2 ;;
esac
file=${2:-example/thesis/main.tex}
out="build/compile/$engine/${file%.tex}"
mkdir -p "$out"
TEXINPUTS=/work/src: scripts/run-tex.sh "$PWD" "/work/$(dirname "$file")" \
  "-$engine" -interaction=nonstopmode -halt-on-error "-outdir=/work/$out" "$(basename "$file")"

if [[ "$file" -ef example/thesis/cover-print.tex ]]; then
  cp "$out/cover-print.pdf" example/thesis/cover-print.pdf
fi
