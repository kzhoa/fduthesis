"""Compare the long-fields fixture with the reviewed rasters for one engine."""

import re
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageChops

engine, filename, spine_filename = sys.argv[1:]
pdf = Path(filename)
baseline = Path(__file__).parent / "baseline" / engine
fixture = Path(__file__).with_name("long-fields.tex").read_text()
pages = subprocess.check_output(["pdftotext", "-layout", pdf, "-"]).decode().split("\f")
if len(pages) != 15 or pages[-1].strip():
    sys.exit("Expected exactly fourteen pages")
cover = "".join(pages[0].split())
for field in ("title", "title-en", "department"):
    value = re.search(rf"\b{field} = \{{([^}}]+)\}}", fixture)
    if not value or "".join(value[1].split()) not in cover:
        sys.exit(f"Missing or truncated {field} on the cover")
if re.search(r"Overfull \\[hv]box|Missing character:", pdf.with_suffix(".log").read_text()):
    sys.exit("The long-fields fixture has overflowing material or missing glyphs")

for page, label in [(1, "cover"), (4, "abstract-zh"), (5, "abstract-en"), (14, "declarations")]:
    if label != "abstract-en":
        fonts = subprocess.check_output(["pdffonts", "-f", str(page), "-l", str(page), pdf], text=True)
        if "SimSun" not in fonts or "FandolSong" in fonts:
            sys.exit(f"{engine} {label}: visual baselines require SimSun. Install simsun.ttc in the build font directory.")
    prefix = pdf.parent / label
    subprocess.run(["pdftoppm", "-f", str(page), "-l", str(page), "-singlefile",
                    "-r", "120", "-gray", "-png", pdf, prefix], check=True)
    actual = Image.open(prefix.with_suffix(".png")).convert("L")
    expected = Image.open(baseline / (label + ".png")).convert("L")
    if actual.size != expected.size:
        sys.exit(f"{engine} {label}: page size changed")
    diff = ImageChops.difference(actual, expected)
    if diff.getbbox():
        diff.save(pdf.parent / (label + "-diff.png"))
        sys.exit(f"{engine} {label}: raster changed in {diff.getbbox()}")
print(f"{engine}: four page rasters and complete cover fields verified")

spine = Path(spine_filename)
text = subprocess.check_output(["pdftotext", "-layout", spine, "-"], text=True)
lines = [line.strip() for line in text.splitlines() if line.strip()]
if lines != list("基于Transformer2026模型的分析AliceZhang复旦大学"):
    sys.exit(f"{engine}: expected one upright spine character per line")
if "Overfull" in spine.with_suffix(".log").read_text():
    sys.exit(f"{engine}: spine content overflows")
