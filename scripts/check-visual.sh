#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for engine in xelatex lualatex; do
  out=build/layout/$engine
  mkdir -p "$out"
  TEXINPUTS=/work/src: scripts/run-tex.sh "$PWD" /work/test/visual -g "-$engine" -interaction=nonstopmode \
    -halt-on-error "-outdir=/work/$out" long-fields.tex spine.tex
  python3 test/check-front-matter.py "$out/long-fields.pdf"
  /usr/bin/python3 test/visual/check.py "$engine" "$out/long-fields.pdf" "$out/spine.pdf"
done
