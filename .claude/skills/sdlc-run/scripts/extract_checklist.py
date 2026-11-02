#!/usr/bin/env python3
"""Print checklist items from an sdlc/ .xlsx template as JSON for the reviewer."""
import json
import os
import sys
import warnings

import openpyxl

warnings.simplefilter("ignore")


def items_of(path):
    wb = openpyxl.load_workbook(path)
    if "Checklist" in wb.sheetnames and wb["Checklist"]["D10"].value == "Assessment":
        ws = wb["Checklist"]
        rows, section = [], None
        for r in range(11, ws.max_row + 1):
            a, b = ws.cell(r, 1).value, ws.cell(r, 2).value
            if b is None and isinstance(a, str) and not a.startswith("="):
                section = a
            elif isinstance(b, str) and not b.startswith("<") and ws.cell(r, 7).value is not None:
                rows.append({"row": r, "category": section, "Checklist Item": b,
                             "Priority": ws.cell(r, 6).value, "Severity": ws.cell(r, 7).value})
        return {"format": "yes_no", "statuses": ["Yes", "No", "N/A"], "items": rows}
    ws = wb.worksheets[0]
    head = next(r for r in ws.iter_rows() if "Status" in [c.value for c in r])
    cols = {c.value: c.column for c in head}
    rows, cat = [], None
    for r in range(head[0].row + 1, ws.max_row + 1):
        cat = ws.cell(r, cols["Category"]).value or cat
        item = ws.cell(r, cols["Checklist Item"]).value
        if item:
            rows.append({"row": r, "category": cat, "Checklist Item": item,
                         "Description": ws.cell(r, cols["Description / Question"]).value})
    statuses = ["Pending", "Pass", "Fail", "N/A"] if "Code_Review" in os.path.basename(path) else ["Done", "In Progress", "Pending", "N/A"]
    return {"format": "status", "statuses": statuses, "items": rows}


if __name__ == "__main__":
    print(json.dumps(items_of(sys.argv[1]), ensure_ascii=False, indent=1))
