#!/usr/bin/env python3
"""Verifies that the bundled (optimised) PDFs render identically to the masters.

For every page of every edition it renders master and bundled copy with
PDFium (the engine the app uses, via pypdfium2) and MuPDF, compares pixels,
compares the text layer, and renders sample pages at 600% for a high-zoom check.

Requires: pip install pymupdf pypdfium2 numpy
Usage:    python3 tools/verify_opt.py  >  docs/evidence/pdf_optimization_verification.json
"""
import json, os, sys

import numpy as np
import pymupdf
import pypdfium2 as pdfium

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EDITIONS = ['ar', 'ckb', 'en', 'id']
# Pages chosen for small tashkeel, Qur'anic marks, coloured letters, fine
# diagram lines, tables and ornamental headings.
HIGH_ZOOM_PAGES = [5, 17, 28, 36, 47, 66]


def main():
    out = {}
    for ed in EDITIONS:
        master = os.path.join(ROOT, 'source', 'books', f'rattil-level2-{ed}.pdf')
        bundled = os.path.join(ROOT, 'assets', 'books', f'{ed}.pdf')
        a, b = pymupdf.open(master), pymupdf.open(bundled)
        assert len(a) == len(b)
        mupdf_diff = [i + 1 for i in range(len(a))
                      if a[i].get_pixmap(matrix=pymupdf.Matrix(1.5, 1.5)).samples
                      != b[i].get_pixmap(matrix=pymupdf.Matrix(1.5, 1.5)).samples]
        text_diff = [i + 1 for i in range(len(a)) if a[i].get_text() != b[i].get_text()]
        fa, fb = pdfium.PdfDocument(master), pdfium.PdfDocument(bundled)
        pd_diff, max_delta = [], 0
        for i in range(len(fa)):
            ia = np.asarray(fa[i].render(scale=1.5).to_pil())
            ib = np.asarray(fb[i].render(scale=1.5).to_pil())
            if ia.shape != ib.shape or not np.array_equal(ia, ib):
                pd_diff.append(i + 1)
                max_delta = max(max_delta, int(np.abs(ia.astype(int) - ib.astype(int)).max()))
        hz = []
        for pg in HIGH_ZOOM_PAGES:
            ia = np.asarray(fa[pg - 1].render(scale=6).to_pil())
            ib = np.asarray(fb[pg - 1].render(scale=6).to_pil())
            hz.append((pg, bool(np.array_equal(ia, ib))))
        out[ed] = dict(pages=len(a), master_bytes=os.path.getsize(master), bundled_bytes=os.path.getsize(bundled),
                       pdfium_150pct_diff_pages=pd_diff, pdfium_max_channel_delta=max_delta,
                       pdfium_600pct_identical=hz, mupdf_150pct_diff_pages=mupdf_diff,
                       text_layer_diff_pages=text_diff)
        print(ed, out[ed], file=sys.stderr, flush=True)
    json.dump(out, sys.stdout, indent=1)


if __name__ == '__main__':
    main()
