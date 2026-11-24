#!/usr/bin/env bash
set -euo pipefail

# Mount only the requested tree so release builds also exercise standalone use.
tree=$1
workdir=$2
shift 2
tex_root=${FDU_TEX_ROOT:-"$HOME/texmf"}
if [[ -z ${FDU_TEX_ROOT:-} && ! -d "$tex_root" && -d /mnt/storage/qq/texmf ]]; then
  tex_root=/mnt/storage/qq/texmf
fi
font_dir="$tex_root/fonts/truetype"
mkdir -p "$font_dir"
exec docker run --rm -u "$(id -u):$(id -g)" \
  -e HOME=/tmp -e TEXMFHOME=/texmf -e "TEXINPUTS=${TEXINPUTS:-}" \
  -v "$font_dir:/usr/local/share/fonts/fduthesis:ro" \
  -v "$tree:/work" -v "$tex_root:/texmf" -w "$workdir" \
  texlive/texlive:latest \
  latexmk "$@"
