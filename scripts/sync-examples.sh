#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for example in example/thesis example/thesis_en; do
  cp src/{fduthesis.cls,fduthesis-logo.png} "$example/"
done
