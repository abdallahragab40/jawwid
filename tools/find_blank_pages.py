#!/usr/bin/env python3
"""Finds pages with no visible content (e.g. the white page after the cover)
in each bundled edition and records them as `blankPages` in
assets/content/editions.json. The reader lays these out with zero height so
the learner never scrolls past an empty white sheet; the PDFs themselves are
not changed. Needs PyMuPDF.
"""
import json, os
import pymupdf

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
path = os.path.join(ROOT, 'assets', 'content', 'editions.json')
data = json.load(open(path, encoding='utf-8'))
for ed in data['editions']:
    doc = pymupdf.open(os.path.join(ROOT, ed['asset']))
    blank = []
    for i, page in enumerate(doc):
        pix = page.get_pixmap(matrix=pymupdf.Matrix(0.5, 0.5))
        s, n = pix.samples, pix.n
        # Blank: practically no pixel darker than near-white (some "empty"
        # pages are a faint off-white rather than pure white).
        dark = sum(1 for k in range(0, len(s), n) if min(s[k:k + 3]) < 235)
        if dark / (pix.width * pix.height) < 0.0005:
            blank.append(i + 1)
    ed['blankPages'] = blank
    print(ed['id'], blank)
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write('\n')
