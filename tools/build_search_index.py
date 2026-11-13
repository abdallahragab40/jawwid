#!/usr/bin/env python3
"""Builds assets/content/search_pages.json: a page-level text index for the
English and Indonesian editions only.

Why only these two: their PDF text layers contain reliable Latin text. The
Arabic and Kurdish editions (and the Arabic fragments inside the EN/ID editions)
extract as broken presentation forms or private Qur'an-font glyph codes, so they
are NOT indexed here; topic titles, rule names and curated terms cover them
instead (see assets/content/search_terms.json).

The index keeps only Latin-script runs. It is never displayed as educational
content; snippets are shown only as "text found on page N" hints.

Requires PyMuPDF (pip install pymupdf). Usage:
  python3 tools/build_search_index.py source/books
"""
import json, os, re, sys

import pymupdf  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HEADERS = {'en': ['Simplifying Tajweed'], 'id': ['Tajwid Ringkas Disertai Warna, Gambar, dan Bagan', 'Tajwid Ringkas']}


def clean_page(text, lang):
    for h in HEADERS[lang]:
        text = text.replace(h, ' ')
    keep = []
    for line in text.split('\n'):
        # Drop any run of Arabic-script characters (unreliable in these layers).
        line = re.sub(r'[؀-ۿݐ-ݿࢠ-ࣿﭐ-﷿ﹰ-﻿]+', ' ', line)
        line = re.sub(r'[-]', ' ', line)  # private-use glyph codes
        line = re.sub(r'[﴿﴾\[\]]', ' ', line)
        line = re.sub(r'\s+', ' ', line).strip()
        if re.search(r'[A-Za-z]{2,}', line):
            keep.append(line)
    out = ' '.join(keep)
    out = re.sub(r'\(\s*\)', ' ', out)
    return re.sub(r'\s+', ' ', out).strip()


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'source', 'books')
    result = {'schemaVersion': 1,
              'notes': 'Latin-script text from the EN and ID PDF text layers, one entry per physical page. Search aid only.',
              'editions': {}}
    for lang in ('en', 'id'):
        doc = pymupdf.open(os.path.join(src, f'rattil-level2-{lang}.pdf'))
        pages = {}
        for i, page in enumerate(doc):
            t = clean_page(page.get_text(), lang)
            if len(t) > 20:
                pages[str(i + 1)] = t
        result['editions'][lang] = pages
    path = os.path.join(ROOT, 'assets', 'content', 'search_pages.json')
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, separators=(',', ':'))
    print('ok', {k: len(v) for k, v in result['editions'].items()}, os.path.getsize(path), 'bytes')


if __name__ == '__main__':
    main()
