#!/usr/bin/env python3
"""Prints image block rectangles on PDF pages (to choose !crop regions).
Usage: python3 tools/page_images.py ar 17 18"""
import sys
import pymupdf
d = pymupdf.open(f'source/books/rattil-level2-{sys.argv[1]}.pdf')
for pg in map(int, sys.argv[2:]):
    p = d[pg - 1]
    boxes = [pymupdf.Rect(i['bbox']) for i in p.get_image_info() if i['width'] > 60]
    # merge overlapping boxes into figures
    figs = []
    for b in sorted(boxes, key=lambda r: -r.get_area()):
        for f in figs:
            if f.intersects(b + (-6, -6, 6, 6)):
                f |= b
                break
        else:
            figs.append(pymupdf.Rect(b))
    print(pg, [tuple(round(v) for v in f) for f in sorted(figs, key=lambda r: (r.y0, -r.x0))])
