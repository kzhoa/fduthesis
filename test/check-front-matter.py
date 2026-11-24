"""Check the built example's PDF using Poppler's text and outline readers."""

import argparse
import subprocess
from xml.etree import ElementTree


def check_example(pdf):
    text = subprocess.check_output(["pdftotext", "-layout", pdf, "-"]).decode()
    pages = text.split("\f")
    xml = subprocess.check_output(["pdftohtml", "-xml", "-i", "-stdout", pdf])
    outline = ElementTree.fromstring(xml).findall("outline/item")
    targets = {item.text: int(item.attrib["page"]) for item in outline}

    assert targets["指导小组成员名单"] == 2
    assert "英文项目" not in pages[0] and "同等学力人员" not in pages[0]
    assert "王五副教授" not in pages[0]
    assert pages[1].index("李四教授") < pages[1].index("王五副教授")
    chapter, first_page = "有序数组的查找代价", 9
    assert "Abstract" in pages[2] and chapter in pages[2]
    assert targets["摘要"] == 4 and targets["Abstract"] == 5
    for page, number in zip(pages[2:7], ("I", "II", "III", "IV", "V")):
        assert page.strip().splitlines()[-1].strip() == number
    chinese_fonts = subprocess.check_output(["pdffonts", "-f", "4", "-l", "4", pdf], text=True)
    assert any(name in chinese_fonts for name in ("SimSun", "FandolSong")), "Unexpected default Chinese font"
    fonts = subprocess.check_output(["pdffonts", "-f", "5", "-l", "5", pdf], text=True)
    assert "TimesNewRoman" in fonts.replace(" ", ""), "English abstract requires Times New Roman"
    assert not pages[first_page - 2].strip(), "The inserted verso should be empty"
    assert targets[chapter] == first_page and pages[first_page - 1].strip().endswith("1")


def check_english_example(pdf):
    text = subprocess.check_output(["pdftotext", "-layout", pdf, "-"], text=True)
    cover, body = text.split("\f", 1)
    assert "硕士学位论文（学术学位）" in "".join(cover.split())
    title = "When Does a Linear Scan Beat Binary Search?"
    zh_title = "顺序查找何时优于二分查找？"
    assert cover.index(zh_title) < cover.index(title)
    for label in ("学校代码", "学生姓名", "学号", "学科专业", "培养单位"):
        assert label in cover
    pages = [page for page in body.split("\f") if page.strip()]
    assert "指导小组成员名单" in pages[0] and "王五副教授" in pages[0]
    assert "Contents" in pages[1]
    assert pages[2].lstrip().startswith("摘要") and zh_title in pages[2]
    english_abstract = next(i for i, page in enumerate(pages) if page.lstrip().startswith("Abstract"))
    assert "关键词：二分查找" in "".join("".join(pages[2:english_abstract]).split())
    assert title in pages[english_abstract] and "Keywords: binary search" in pages[english_abstract]
    for heading in ("学位论文独创性声明", "学位论文使用授权声明", "导师签名"):
        assert heading in pages[-1]
    assert cover.count("英文项目") == 1
    for heading in ("Chapter 1", "Appendix A", "Figure 1.1", "Table 1.1",
                    "References", "Acknowledgments"):
        assert heading in body, f"Missing English heading: {heading}"
    assert "??" not in body

    # At zoom 1, Poppler reports font sizes in PDF points (bp).
    xml = subprocess.check_output(["pdftohtml", "-xml", "-zoom", "1", "-i", "-stdout", pdf])
    doc = ElementTree.fromstring(xml)
    heading_fonts = {font.get("id") for font in doc.iter("fontspec") if font.get("size") == "16"}
    headings = " ".join("".join(run.itertext()) for run in doc.iter("text")
                        if run.get("font") in heading_fonts)
    for heading in ("Contents", "List of Figures", "List of Tables", "Chapter 1 Counting probes",
                    "Appendix A Checking the endpoints", "References", "Acknowledgments"):
        assert heading in headings, f"Expected a 16 bp heading: {heading}"


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--english", action="store_true")
    parser.add_argument("pdf", nargs="+")
    args = parser.parse_args()
    for filename in args.pdf:
        if args.english:
            check_english_example(filename)
        else:
            check_example(filename)
