# -*- coding: utf-8 -*-
"""Shared helpers: read data/extracted/44-2019-QH14.txt and cut clauses by line number."""
import io
import os
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SRC = os.path.join(ROOT, "data", "extracted", "44-2019-QH14.txt")
LINES = io.open(SRC, encoding="utf-8").read().split("\n")      # LINES[0] is line 1
PAGE = re.compile(r"CÔNG BÁO/Số 559")
NEXT = re.compile(r"^\s+(\d+\.|[a-zđ]\)|Điều \d+\.)\s")
SUB = re.compile(r"^\s+[a-zđ]\)\s")


def find(anchor, lo=1):
    """1-based number of the first line (>= lo) whose stripped text starts with anchor."""
    for n in range(lo, len(LINES) + 1):
        if LINES[n - 1].strip().startswith(anchor):
            return n
    raise SystemExit("anchor not found: %r (from line %d)" % (anchor, lo))


def block(start, sub=False):
    """(first, last) 1-based inclusive: the clause that starts at `start`."""
    end = start
    while end < len(LINES):
        nxt = LINES[end]                     # line end+1
        if not nxt.strip():
            break
        if PAGE.search(nxt):          # running page header: part of the range, not of the text
            end += 1
            continue
        if NEXT.match(nxt) and not (sub and SUB.match(nxt)):
            break
        end += 1
    return start, end


def text(a, b):
    """Verbatim text of lines a..b (line breaks joined by one space; indentation dropped)."""
    return " ".join(l.strip() for l in LINES[a - 1:b] if not PAGE.search(l))


def norm_ws(s):
    return re.sub(r"\s+", " ", s).strip()


D5 = find("Điều 5. Các hành vi bị nghiêm cấm")
D2 = find("Điều 2. Giải thích từ ngữ")
D11 = find("Điều 11. Quản lý việc khuyến mại")
D15 = find("Điều 15. Quản lý kinh doanh rượu")
D16 = find("Điều 16. Điều kiện bán rượu")
D17 = find("Điều 17. Biện pháp quản lý")
D19 = find("Điều 19. Địa điểm không bán rượu, bia")
D32 = find("Điều 32. Trách nhiệm của cơ sở kinh doanh")

# key, label, (start line, last line)
def clause(key, label, anchor, lo, sub=False):
    s = find(anchor, lo)
    a, b = block(s, sub)
    return (key, label, a, b)

ENCODED = [
    clause("D5H", "Điều 5 (tiêu đề)", "Điều 5. Các hành vi bị nghiêm cấm", D5),
    clause("5.3", "Điều 5 khoản 3", "3. Bán, cung cấp, khuyến mại", D5),
    clause("5.9", "Điều 5 khoản 9", "9. Khuyến mại trong hoạt động", D5),
    clause("5.11", "Điều 5 khoản 11", "11. Kinh doanh rượu không có giấy phép", D5),
    clause("5.11i", "Điều 5 khoản 11 nhánh (i)", "11. Kinh doanh rượu không có giấy phép", D5),
    clause("5.11ii", "Điều 5 khoản 11 nhánh (ii)", "11. Kinh doanh rượu không có giấy phép", D5),
    clause("D19H", "Điều 19 (tiêu đề)", "Điều 19. Địa điểm không bán rượu, bia", D19),
    clause("19.1", "Điều 19 khoản 1", "1. Cơ sở y tế.", D19),
    clause("19.2", "Điều 19 khoản 2", "2. Cơ sở giáo dục.", D19),
    clause("19.3", "Điều 19 khoản 3", "3. Cơ sở, khu vực chăm sóc", D19),
    clause("19.4", "Điều 19 khoản 4", "4. Cơ sở cai nghiện", D19),
    clause("19.5", "Điều 19 khoản 5", "5. Cơ sở bảo trợ xã hội", D19),
    clause("19.6", "Điều 19 khoản 6", "6. Nơi làm việc của cơ quan nhà nước", D19),
]

NOT_ENCODED = [
    clause("2.1", "Điều 2 khoản 1", "1. Rượu là đồ uống", D2),
    clause("2.2", "Điều 2 khoản 2", "2. Bia là đồ uống", D2),
    clause("2.4", "Điều 2 khoản 4", "4. Độ cồn là số đo", D2),
    clause("11", "Điều 11", "Điều 11. Quản lý việc khuyến mại", D11),
    clause("15.4", "Điều 15 khoản 4", "4. Điều kiện cấp phép mua bán rượu", D15, sub=True),
    ("16", "Điều 16", D16, D17 - 1),
    clause("32.3", "Điều 32 khoản 3", "3. Không sử dụng lao động", D32),
    clause("32.5", "Điều 32 khoản 5", "5. Cơ sở bán rượu, bia phải niêm yết", D32),
    clause("32.7", "Điều 32 khoản 7", "7. Kể từ ngày Luật này có hiệu lực", D32),
]
# 5.11 nhánh (i) is the first half of the same sentence as 5.11 nhánh (ii): quoted via ENCODED "5.11".
