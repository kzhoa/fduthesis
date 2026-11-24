#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
scripts/sync-examples.sh
for engine in xelatex lualatex; do
  scripts/latex-env.sh "$engine" example/thesis/main.tex
  scripts/latex-env.sh "$engine" example/thesis_en/main.tex
  python3 test/check-front-matter.py "build/compile/$engine/example/thesis/main/main.pdf"
  python3 test/check-front-matter.py --english "build/compile/$engine/example/thesis_en/main/main.pdf"
  scripts/latex-env.sh "$engine" test/main-page-numbering.tex
  scripts/latex-env.sh "$engine" test/special-pages.tex
  for key in student-id title-en supervisor-title; do
    grep -Fq "Required metadata '$key' is missing." "build/compile/$engine/test/special-pages/special-pages.log"
  done
done
cp build/compile/xelatex/example/thesis_en/main/main.pdf example/thesis_en/thesis.pdf
