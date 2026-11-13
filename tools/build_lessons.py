#!/usr/bin/env python3
"""Builds native lesson content from content_src/lessons/<topic>.<lang>.txt.

Writes assets/content/lessons_<lang>.json (one file per language).

Source format (one block per line; blank lines are ignored):

  @page 42                 source page (physical PDF page) for the following blocks
  # Heading                section heading       ## Sub-heading      ### Label tag
  - text                   bullet item           1) text             numbered item (number kept)
  > text                   note / remark box
  = term | text            labelled line ("Definition: ...")
  | a | b | c |            table row; the first row of a table is its header row
  !image makharij          diagram image (asset key)
  !crop x0 y0 x1 y1        illustration cropped from the current @page of the
                           edition's master PDF (PDF points, origin top-left).
                           Rendered once to assets/images/lessons/ (needs PyMuPDF).
  anything else            paragraph

Inline markup inside any text:
  **text**                 emphasis (the books' red)
  {{q REF|PATTERN}}        Qur'anic excerpt. REF is "s:a" or "?" (search the
                           whole text). PATTERN is plain letters; wrap
                           highlighted letters in [ ]; use "…" to span from one
                           phrase to another inside the same verse; use "*" for
                           the whole verse. The exact Uthmani text is copied
                           verbatim from Tanzil. The build fails on no match.
  {{a TEXT}}               Arabic (non-Qur'anic) text inside any language, shown RTL.

Every topic file starts with a header line:  %status sourceTranscribed|sourceExtracted
Usage: python3 -I tools/build_lessons.py
"""
import json, os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_content import load_tanzil, bases, is_mark, FOLD  # noqa: E402

HARAKAT = set(chr(c) for c in range(0x064B, 0x0653))


def parse_pattern(pat):
    """Returns (letters, highlight flags, required harakat per letter).

    Harakat typed in the pattern must be present on the matched letter
    (subset match), so a vocalised pattern picks the form printed in the book."""
    letters, hl, marks, inside, skip = [], [], [], False, False
    for ch in pat:
        if ch == '[':
            inside = True
            continue
        if ch == ']':
            inside = False
            continue
        if is_mark(ch):
            if ch in HARAKAT and marks and not skip:
                marks[-1].add(ch)
            continue
        f = FOLD.get(ch, ch)
        if not f:
            # Tatweel: marks written on it belong to it, not to the letter before.
            skip = True
            continue
        skip = False
        letters.append(f)
        hl.append(inside)
        marks.append(set())
    return letters, hl, marks

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'content_src', 'lessons')
LANGS = ['ar', 'ckb', 'en', 'id']
INLINE = re.compile(r'\{\{(q|a) (.*?)\}\}|\*\*(.+?)\*\*')

VERSES, _ = load_tanzil()
ORDER = sorted(VERSES)
def _merge_spaces(bs):
    # Tanzil writes pause marks after a space ("مَنْ ۜ رَاقٍ"); treat a run of
    # spaces (with the marks attached to them) as a single word boundary.
    out = []
    for b in bs:
        if b[0] == ' ' and out and out[-1][0] == ' ':
            out[-1] = (' ', out[-1][1], b[2])
        else:
            out.append(b)
    return out


BASES = {k: _merge_spaces(bases(v)) for k, v in VERSES.items()}
SEQ = {k: [b[0] for b in v] for k, v in BASES.items()}
used_verses = set()
FAILURES = []
CROPS = []


def _marks_at(text, b):
    return set(text[b[1] + 1:b[2]]) & HARAKAT


def _find(seq, letters, start=0, marks=None, text=None, bs=None):
    n = len(letters)
    for i in range(start, len(seq) - n + 1):
        if seq[i:i + n] == letters and (i == 0 or seq[i - 1] == ' ') and (i + n == len(seq) or seq[i + n] == ' '):
            if marks and any(m and not m <= _marks_at(text, bs[i + k]) for k, m in enumerate(marks)):
                continue
            return i
    return -1


def resolve(ref, pattern, where):
    keys = ORDER if ref == '?' else [tuple(int(x) for x in ref.split(':'))]
    for key in keys:
        if key not in VERSES:
            sys.exit(f'{where}: unknown reference {ref}')
        text, bs, seq = VERSES[key], BASES[key], SEQ[key]
        if pattern.strip() == '*':
            i0, i1, hl = 0, len(bs) - 1, [False] * len(bs)
        else:
            parts = [p.strip() for p in pattern.split('…')]
            l0, h0, m0 = parse_pattern(parts[0])
            i0 = _find(seq, l0, 0, m0, text, bs)
            if i0 < 0:
                continue
            if len(parts) == 1:
                i1, hl = i0 + len(l0) - 1, h0
            else:
                l1, h1, m1 = parse_pattern(parts[-1])
                j = _find(seq, l1, i0 + len(l0), m1, text, bs)
                if j < 0:
                    continue
                i1 = j + len(l1) - 1
                hl = h0 + [False] * (j - i0 - len(l0)) + h1
        start, end = bs[i0][1], bs[i1][2]
        excerpt = text[start:end]
        ranges = []
        for k in range(i1 - i0 + 1):
            if k < len(hl) and hl[k]:
                rs, re_ = bs[i0 + k][1] - start, bs[i0 + k][2] - start
                gap = excerpt[ranges[-1][1]:rs] if ranges else None
                # Merge across a gap that holds only a tatweel and its marks
                # (e.g. لْـَٔيْكَةِ), so the highlight is not visibly broken.
                if ranges and all(c == 'ـ' or is_mark(c) for c in gap):
                    ranges[-1][1] = re_
                else:
                    ranges.append([rs, re_])
        for rs, re_ in ranges:
            assert not is_mark(excerpt[rs]), (where, excerpt)
        used_verses.add(key)
        return {'ref': f'{key[0]}:{key[1]}', 'surah': key[0], 'ayah': key[1], 'text': excerpt,
                'isWholeAyah': excerpt == text, 'highlights': ranges}
    FAILURES.append(f'{where}: not found: {ref} | {pattern}')
    return {'ref': '0:0', 'surah': 0, 'ayah': 0, 'text': pattern, 'isWholeAyah': False, 'highlights': []}


def _split_cells(line):
    """Splits a table row on '|' that are not inside {{ }}."""
    body = line.strip()
    if body.startswith('|'):
        body = body[1:]
    if body.endswith('|'):
        body = body[:-1]
    cells, cur, depth, i = [], '', 0, 0
    while i < len(body):
        if body.startswith('{{', i):
            depth += 1; cur += '{{'; i += 2; continue
        if body.startswith('}}', i) and depth:
            depth -= 1; cur += '}}'; i += 2; continue
        if body[i] == '|' and depth == 0:
            cells.append(cur); cur = ''; i += 1; continue
        cur += body[i]; i += 1
    cells.append(cur)
    return cells


def spans(text, where):
    if '{{' in INLINE.sub('', text) or '}}' in INLINE.sub('', text):
        FAILURES.append(f'{where}: unbalanced or malformed {{{{ }}}} markup: {text[:60]}')
    out, pos = [], 0
    for m in INLINE.finditer(text):
        if m.start() > pos:
            out.append({'x': text[pos:m.start()]})
        kind, body, emph = m.group(1), m.group(2), m.group(3)
        if emph is not None:
            if '{{' in emph:
                # Markup inside emphasis: keep Arabic/Qur'an spans, emphasise the rest.
                for sp in spans(emph, where):
                    out.append({'e': sp['x']} if 'x' in sp else sp)
            else:
                out.append({'e': emph})
        elif kind == 'a':
            out.append({'a': body.strip()})
        else:
            ref, _, pat = body.partition('|')
            out.append({'q': resolve(ref.strip(), pat.strip(), where)})
        pos = m.end()
    if pos < len(text):
        out.append({'x': text[pos:]})
    return out


def parse_file(path, topic, lang):
    page, blocks, table, status = None, [], None, None
    for n, raw in enumerate(open(path, encoding='utf-8'), 1):
        line = raw.strip()
        where = f'{os.path.basename(path)}:{n}'
        if not line.startswith('|') and table is not None:
            blocks.append(table)
            table = None
        if not line:
            continue
        if line.startswith('%status'):
            status = line.split()[1]
            continue
        if line.startswith('@page'):
            page = int(line.split()[1])
            continue
        if page is None:
            sys.exit(f'{where}: block before @page')
        if line.startswith('|'):
            cells = [c.strip() for c in _split_cells(line)]
            if all(re.fullmatch(r'-+', c) for c in cells):
                continue
            if table is None:
                table = {'t': 'table', 'page': page, 'rows': []}
            table['rows'].append([spans(c, where) for c in cells])
            continue
        m = re.match(r'^(#{1,3}) (.*)$', line)
        if m:
            blocks.append({'t': f'h{len(m.group(1))}', 'page': page, 's': spans(m.group(2), where)})
            continue
        if line.startswith('- '):
            blocks.append({'t': 'li', 'page': page, 's': spans(line[2:], where)})
            continue
        m = re.match(r'^(\S{1,4})\) (.*)$', line)
        if m:
            blocks.append({'t': 'ol', 'n': m.group(1), 'page': page, 's': spans(m.group(2), where)})
            continue
        if line.startswith('> '):
            blocks.append({'t': 'note', 'page': page, 's': spans(line[2:], where)})
            continue
        if line.startswith('= '):
            term, _, rest = line[2:].partition('|')
            blocks.append({'t': 'def', 'page': page, 'k': spans(term.strip(), where), 's': spans(rest.strip(), where)})
            continue
        if line.startswith('!image '):
            blocks.append({'t': 'img', 'page': page, 'key': line.split()[1]})
            continue
        if line.startswith('!crop '):
            rect = [float(v) for v in line.split()[1:5]]
            name = f'{lang}_p{page:03d}_{len([b for b in blocks if b["t"] == "crop"]) + 1}_{topic}.jpg'
            CROPS.append((lang, page, rect, name))
            blocks.append({'t': 'crop', 'page': page, 'asset': f'assets/images/lessons/{name}', 'w': rect[2] - rect[0], 'h': rect[3] - rect[1]})
            continue
        blocks.append({'t': 'p', 'page': page, 's': spans(line, where)})
    if table is not None:
        blocks.append(table)
    if status is None:
        sys.exit(f'{path}: missing %status line')
    return {'topic': topic, 'status': status, 'review': 'draft', 'blocks': blocks}


def render_crops():
    """Renders each !crop region from the master PDF (unchanged pages) at
    2.5x as JPEG. A file is reused only while its rectangle is unchanged
    (recorded in content_src/lessons/crops.lock.json); stale files are
    removed."""
    out_dir = os.path.join(ROOT, 'assets', 'images', 'lessons')
    os.makedirs(out_dir, exist_ok=True)
    lock_path = os.path.join(SRC, 'crops.lock.json')
    lock = json.load(open(lock_path, encoding='utf-8')) if os.path.exists(lock_path) else {}
    wanted = {c[3]: [c[0], c[1], *c[2]] for c in CROPS}
    for f in os.listdir(out_dir):
        if f.endswith('.jpg') and f not in wanted:
            os.remove(os.path.join(out_dir, f))
    todo = [c for c in CROPS
            if not os.path.exists(os.path.join(out_dir, c[3])) or lock.get(c[3]) != wanted[c[3]]]
    if todo:
        import pymupdf  # noqa: E402  (only needed when crops are added or moved)
        docs = {}
        for lang, page, (x0, y0, x1, y1), name in todo:
            d = docs.setdefault(lang, pymupdf.open(os.path.join(ROOT, 'source', 'books', f'rattil-level2-{lang}.pdf')))
            pix = d[page - 1].get_pixmap(matrix=pymupdf.Matrix(2.5, 2.5), clip=pymupdf.Rect(x0, y0, x1, y1))
            pix.save(os.path.join(out_dir, name), jpg_quality=86)
    if lock != wanted:
        with open(lock_path, 'w', encoding='utf-8') as fh:
            json.dump(dict(sorted(wanted.items())), fh, ensure_ascii=False, indent=0)
            fh.write('\n')


def main():
    curriculum = json.load(open(os.path.join(ROOT, 'assets', 'content', 'curriculum.json'), encoding='utf-8'))
    ranges = {t['id']: t['pages'] for t in curriculum['topics']}
    reviewed = {}
    rp = os.path.join(SRC, 'reviewed.json')
    if os.path.exists(rp):
        reviewed = json.load(open(rp, encoding='utf-8'))
    summary = {}
    for lang in LANGS:
        lessons = {}
        for f in sorted(os.listdir(SRC)) if os.path.isdir(SRC) else []:
            m = re.fullmatch(r'(t\d\d)\.' + lang + r'\.txt', f)
            if not m:
                continue
            topic = m.group(1)
            lesson = parse_file(os.path.join(SRC, f), topic, lang)
            r = ranges[topic][lang]
            if r is None:
                sys.exit(f'{f}: topic has no pages in edition {lang}')
            for b in lesson['blocks']:
                if not (r[0] <= b['page'] <= r[1]):
                    sys.exit(f'{f}: page {b["page"]} outside topic range {r}')
            if topic in reviewed.get(lang, []):
                lesson['review'] = 'reviewed'
            lessons[topic] = lesson
        out = {'schemaVersion': 1, 'language': lang, 'lessons': lessons}
        with open(os.path.join(ROOT, 'assets', 'content', f'lessons_{lang}.json'), 'w', encoding='utf-8') as fh:
            json.dump(out, fh, ensure_ascii=False, separators=(',', ':'))
        summary[lang] = len(lessons)
    if FAILURES:
        print('\n'.join(FAILURES))
        sys.exit(f'{len(FAILURES)} Qur\'anic pattern(s) not found; nothing written to quran.json')
    render_crops()
    # Keep quran.json in sync: add any verse used by lessons.
    qp = os.path.join(ROOT, 'assets', 'content', 'quran.json')
    q = json.load(open(qp, encoding='utf-8'))
    for s, a in used_verses:
        q['verses'][f'{s}:{a}'] = VERSES[(s, a)]
    json.dump(q, open(qp, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    missing = sorted({s for s, _ in used_verses} - {int(k) for k in q['surahNames']})
    print('ok', summary, f'{len(used_verses)} verses', 'surah names missing:' if missing else '', missing or '')


if __name__ == '__main__':
    main()
