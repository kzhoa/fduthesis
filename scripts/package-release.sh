#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

scripts/sync-examples.sh
mkdir -p release
stage=$(mktemp -d "$PWD/release/stage.XXXXXX")
trap 'rm -r -- "$stage"' EXIT
mkdir -p "$stage/thesis/figures"
cp LICENSE src/{fduthesis.cls,fduthesis-logo.png} example/thesis/{README.md,main.tex,cover-print.tex,reference.bib} "$stage/thesis/"
cp example/thesis/figures/{figure1,figure2}.pdf "$stage/thesis/figures/"

cp -R example/thesis/fonts "$stage/thesis/"

TEXINPUTS= scripts/run-tex.sh "$stage/thesis" /work -xelatex -halt-on-error -interaction=nonstopmode main.tex cover-print.tex

cp "$stage/thesis/main.pdf" "$stage/thesis/thesis.pdf"
(cd "$stage" && zip -q fduthesis.zip thesis/fonts/ thesis/{fduthesis.cls,fduthesis-logo.png,main.tex,cover-print.tex,reference.bib,thesis.pdf,cover-print.pdf,README.md,LICENSE,figures/figure1.pdf,figures/figure2.pdf})
cp "$stage/thesis/"{thesis.pdf,cover-print.pdf,LICENSE} example/thesis/
mv "$stage/fduthesis.zip" release/
