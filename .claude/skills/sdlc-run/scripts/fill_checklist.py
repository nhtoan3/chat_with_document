#!/usr/bin/env python3
"""Copy a checklist template to OUT and fill reviewer results. Refuses on missing rows or bad statuses.

Usage: fill_checklist.py TEMPLATE.xlsx RESULT.json OUT.xlsx [--date YYYY-MM-DD]
"""
import datetime
import json
import os
import sys
import warnings
from collections import Counter

import openpyxl
from openpyxl.styles import Alignment, Font
from openpyxl.worksheet.datavalidation import DataValidation

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from extract_checklist import items_of  # noqa: E402

warnings.simplefilter("ignore")
REVIEWER = "Claude (agent reviewer độc lập) — review L1; chưa có người review, không phải phê duyệt"


def fail(msg):
    sys.exit(f"fill_checklist: {msg}")


def main():
    args = list(sys.argv[1:])
    date = datetime.date.today().isoformat()
    if "--date" in args:
        i = args.index("--date")
        date = args[i + 1]
        del args[i:i + 2]
    if len(args) != 3:
        fail(__doc__)
    template, result, out = args
    if os.path.abspath(template) == os.path.abspath(out) or os.path.abspath(out).startswith(os.path.abspath("sdlc") + os.sep):
        fail("không được ghi đè template trong sdlc/; OUT phải nằm cạnh tài liệu")
    res = json.load(open(result, encoding="utf8"))
    spec = items_of(template)
    given = {i["row"]: i for i in res["items"]}
    expected = {i["row"] for i in spec["items"]}
    if set(given) != expected:
        fail(f"sai dòng: thiếu {sorted(expected - set(given))}, thừa {sorted(set(given) - expected)}")
    for r, i in given.items():
        if i.get("status") not in spec["statuses"]:
            fail(f"dòng {r}: trạng thái không hợp lệ {i.get('status')!r}")
        if not str(i.get("notes", "")).strip():
            fail(f"dòng {r}: thiếu notes")
    wb = openpyxl.load_workbook(template)
    tally = Counter(i["status"] for i in res["items"])
    if spec["format"] == "yes_no":
        ws = wb["Checklist"]
        ws["C4"], ws["C5"], ws["C6"] = REVIEWER, res["document"], date
        for r, i in given.items():
            ws.cell(r, 4).value = i["status"]
            ws.cell(r, 5).value = i["notes"]
            ws.cell(r, 5).alignment = Alignment(wrap_text=True, vertical="top")
        ws["A36"] = res["summary"]
        # Ô "Pass" là kết luận review của con người; agent chỉ được đánh "Review again" hoặc "Other".
        cell = {"review_again": "A42", "other": "A43"}.get(res.get("suggestion"))
        if cell:
            ws[cell] = "[   X   ]"
        elif res.get("suggestion") == "pass":
            ws["A43"] = "[   X   ]"
            ws["B43"] = " - Other: agent không thấy mục No nào chặn; kết luận Pass dành cho người review"
    else:
        ws = wb.worksheets[0]
        head = next(r for r in ws.iter_rows() if "Status" in [c.value for c in r])
        cols = {c.value: c.column for c in head}
        for r, i in given.items():
            ws.cell(r, cols["Status"]).value = i["status"]
            c = ws.cell(r, cols["Notes / Action Items"])
            c.value = i["notes"]
            c.alignment = Alignment(wrap_text=True, vertical="top")
        ws.column_dimensions[openpyxl.utils.get_column_letter(cols["Notes / Action Items"])].width = 70
        if not ws.data_validations.dataValidation:  # template uses an extension openpyxl drops
            dv = DataValidation(type="list", formula1='"' + ",".join(spec["statuses"]) + '"', allow_blank=True)
            dv.add(f"D{head[0].row + 1}:D{max(given)}")
            ws.add_data_validation(dv)
        start = ws.max_row + 2
        block = [("Review summary", None), ("Tài liệu được review", res["document"]), ("Ngày review", date),
                 ("Người review", REVIEWER), ("Kết quả", ", ".join(f"{k}: {v}" for k, v in sorted(tally.items()))),
                 ("Kết luận", res["summary"]),
                 ("Quy ước", "Done = đạt; In Progress = đạt một phần; Pending = chưa đạt hoặc mâu thuẫn; N/A = không áp dụng")]
        for k, (a, b) in enumerate(block):
            ws.cell(start + k, 1).value = a
            ws.cell(start + k, 1).font = Font(bold=True)
            if b:
                ws.cell(start + k, 2).value = b
                ws.merge_cells(start_row=start + k, start_column=2, end_row=start + k, end_column=5)
                ws.cell(start + k, 2).alignment = Alignment(wrap_text=True, vertical="top")
                ws.row_dimensions[start + k].height = 45 if len(str(b)) > 110 else 18
    os.makedirs(os.path.dirname(os.path.abspath(out)) or ".", exist_ok=True)
    wb.save(out)
    print(out, dict(tally))


if __name__ == "__main__":
    main()
