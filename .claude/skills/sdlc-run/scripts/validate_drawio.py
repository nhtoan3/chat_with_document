#!/usr/bin/env python3
"""Validate draw.io files: XML parse, structure, unique ids, edge refs, sibling overlaps,
edge segments through unrelated shapes, rough text fit."""
import glob, html, re, sys
import xml.etree.ElementTree as ET

CONT = ("swimlane", "shape=folder", "container=1", "umlFrame", "umlLifeline")
def sty(c): return c.get("style") or ""
def strip(s):
    s = re.sub(r"<br\s*/?>", "\n", s or "")
    return html.unescape(re.sub(r"<[^>]+>", "", s))

def check(path):
    errs, warns = [], []
    try:
        root = ET.parse(path).getroot()
    except ET.ParseError as ex:
        return [f"XML parse: {ex}"], [], {}
    if root.tag != "mxfile": errs.append("root is not mxfile")
    dgs = root.findall("diagram")
    if not dgs: errs.append("no <diagram>")
    seen, stats = set(), {"pages": len(dgs), "vertices": 0, "edges": 0}
    for d in dgs:
        pn = d.get("name")
        m = d.find("mxGraphModel")
        if m is None:
            errs.append(f"[{pn}] compressed or missing mxGraphModel"); continue
        cells = m.find("root").findall("mxCell")
        ids = {}
        for c in cells:
            i = c.get("id")
            if i is None: errs.append(f"[{pn}] cell without id")
            ids[i] = c
            key = i if i not in ("0", "1") else f"{pn}:{i}"
            if key in seen: errs.append(f"[{pn}] duplicate id {i}")
            seen.add(key)
        if "0" not in ids or "1" not in ids: errs.append(f"[{pn}] missing root cells 0/1")
        children = {}
        for c in cells:
            p = c.get("parent")
            if c.get("id") != "0":
                if p not in ids: errs.append(f"[{pn}] {c.get('id')} parent {p} missing")
                children.setdefault(p, []).append(c)
        def geom(c):
            g = c.find("mxGeometry")
            return tuple(float(g.get(k, 0)) for k in ("x", "y", "width", "height"))
        def abspos(c):
            x, y, w, h = geom(c); p = ids.get(c.get("parent"))
            while p is not None and p.get("vertex") == "1":
                px, py, _, _ = geom(p); x += px; y += py; p = ids.get(p.get("parent"))
            return x, y, w, h
        verts = [c for c in cells if c.get("vertex") == "1"]
        edges = [c for c in cells if c.get("edge") == "1"]
        stats["vertices"] += len(verts); stats["edges"] += len(edges)
        def is_cont(c): return any(t in sty(c) for t in CONT) or c.get("id") in children and any(v.get("vertex")=="1" for v in children[c.get("id")])
        # vertex geometry + sibling overlap
        for c in verts:
            if c.find("mxGeometry") is None: errs.append(f"[{pn}] {c.get('id')} no geometry")
        sib = {}
        for c in verts: sib.setdefault(c.get("parent"), []).append(c)
        for p, lst in sib.items():
            lst = [c for c in lst if not is_cont(c)]
            for i, a in enumerate(lst):
                ax, ay, aw, ah = geom(a)
                for b in lst[i+1:]:
                    bx, by, bw, bh = geom(b)
                    if ax < bx + bw and bx < ax + aw and ay < by + bh and by < ay + ah:
                        errs.append(f"[{pn}] overlap {a.get('id')} / {b.get('id')}")
            # sibling containers vs non-containers/containers too (not frames/lifelines, which overlay by design)
            all_ = [c for c in sib[p] if "umlFrame" not in sty(c) and "umlLifeline" not in sty(c) and "line;" not in sty(c)]
            for i, a in enumerate(all_):
                if not is_cont(a): pass
                ax, ay, aw, ah = geom(a)
                for b in all_[i+1:]:
                    if not (is_cont(a) or is_cont(b)): continue
                    bx, by, bw, bh = geom(b)
                    if ax < bx + bw and bx < ax + aw and ay < by + bh and by < ay + ah:
                        errs.append(f"[{pn}] container overlap {a.get('id')} / {b.get('id')}")
            # children must fit inside parent
            pc = ids.get(p)
            if pc is not None and pc.get("vertex") == "1" and "umlLifeline" not in sty(pc) and "umlFrame" not in sty(pc):
                _, _, pw, ph = geom(pc)
                for c in sib[p]:
                    x, y, w, h = geom(c)
                    if x < -0.01 or y < -0.01 or x + w > pw + .01 or y + h > ph + .01:
                        errs.append(f"[{pn}] {c.get('id')} outside parent {p}")
        # edges
        def anc(c):
            out = set(); p = c
            while p is not None and p.get("vertex") == "1":
                out.add(p.get("id")); p = ids.get(p.get("parent"))
            return out
        def desc(i):
            out = {i}
            for k in children.get(i, []): out |= desc(k.get("id"))
            return out
        solid = [c for c in verts if not is_cont(c) and "text;" not in sty(c)[:5] and "line;" not in sty(c)[:5] and "orthogonalPerimeter" not in sty(c) and "shape=note" not in sty(c)]
        solid += [c for c in verts if "swimlane" in sty(c) and "stackLayout" in sty(c)]
        for e in edges:
            s, t = e.get("source"), e.get("target")
            if not s or s not in ids: errs.append(f"[{pn}] edge {e.get('id')} source {s} invalid"); continue
            if not t or t not in ids: errs.append(f"[{pn}] edge {e.get('id')} target {t} invalid"); continue
            st = dict(x.split("=", 1) for x in sty(e).split(";") if "=" in x)
            sx, sy, sw, sh = abspos(ids[s]); tx, ty, tw, th = abspos(ids[t])
            pts = [(sx + float(st.get("exitX", .5)) * sw, sy + float(st.get("exitY", .5)) * sh)]
            arr = e.find("mxGeometry").find("Array")
            if arr is not None: pts += [(float(p.get("x")), float(p.get("y"))) for p in arr]
            pts.append((tx + float(st.get("entryX", .5)) * tw, ty + float(st.get("entryY", .5)) * th))
            skip = anc(ids[s]) | anc(ids[t]) | desc(s) | desc(t)
            for v in solid:
                if v.get("id") in skip or "swimlane" in sty(ids[v.get("parent")]): continue
                x, y, w, h = abspos(v)
                for (a, b), (c_, d) in zip(pts, pts[1:]):
                    # Liang-Barsky
                    t0, t1, dx, dy, hit = 0, 1, c_-a, d-b, True
                    for pp, q in ((-dx, a-x), (dx, x+w-a), (-dy, b-y), (dy, y+h-b)):
                        if pp == 0:
                            if q <= 0: hit = False
                        else:
                            r = q/pp
                            if pp < 0: t0 = max(t0, r)
                            else: t1 = min(t1, r)
                    if hit and t0 < t1 - 1e-6:
                        warns.append(f"[{pn}] edge {e.get('id')} crosses {v.get('id')}")
                        break
        # rough text fit
        for c in verts:
            s_ = sty(c)
            if c.get("value") in (None, "") or "labelPosition=right" in s_: continue
            fs = float(dict(x.split("=",1) for x in s_.split(";") if "=" in x).get("fontSize", 12))
            x, y, w, h = geom(c)
            lines = strip(c.get("value")).split("\n")
            maxw = w - 8
            if "swimlane" in s_ or "umlFrame" in s_ or "umlLifeline" in s_: continue
            n = 0
            for l in lines:
                lw = len(l) * fs * 0.52
                if "nowrap" in s_:
                    n += 1
                    if lw > w: warns.append(f"[{pn}] text wider than box: {c.get('id')} ({lw:.0f}>{w:.0f})")
                else:
                    n += max(1, int(lw // max(maxw, 1)) + (1 if lw % max(maxw, 1) else 0))
            if n * fs * 1.2 > h + 2 and "folder" not in s_:
                warns.append(f"[{pn}] text taller than box: {c.get('id')} ({n*fs*1.2:.0f}>{h:.0f})")
    return errs, warns, stats

def main():
    files = sys.argv[1:] or sorted(glob.glob("docs/04-design/diagrams/*.drawio"))
    bad = 0
    for f in files:
        e, w, st = check(f)
        print(f"{f.split('/')[-1]}: {'OK' if not e else 'FAIL'} {st} errors={len(e)} warnings={len(w)}")
        for x in e: print("  ERROR", x)
        for x in w: print("  warn ", x)
        bad += len(e)
    sys.exit(1 if bad else 0)
main()
