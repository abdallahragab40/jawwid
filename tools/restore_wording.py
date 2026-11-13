#!/usr/bin/env python3
"""Restores the edition's own wording in English/Indonesian lessons.

Each lesson page is aligned word by word with the same page of the edition's
PDF text layer. Inside a prose run (the text between protected parts of a
line), the text from the first to the last word that matches the book is
replaced by the book's exact text for that stretch — wording, spelling,
grammar and punctuation as printed.

Never changed: headings, table rows, labels before " | ", bold **terms**,
{{ }} Arabic/Qur'anic segments and [Surah: n] citations. A stretch is left
alone when the book's text for it contains Arabic (figure labels) or is much
longer than the lesson's (a heading or caption pulled in). Text-layer
artefacts are repaired, not copied: page headers and numbers, an apostrophe
split into a space ("isti la" for isti'la), "_" printed for "-".

Usage (needs PyMuPDF):
  python tools/restore_wording.py en t20            # show the changes
  python tools/restore_wording.py en t20 --full     # show whole lines
  python tools/restore_wording.py en t20 --write    # apply them
"""
import difflib, os, re, sys, unicodedata

import pymupdf

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORD = re.compile(r"[A-Za-z][A-Za-z'’]*(?:-[A-Za-z][A-Za-z'’]*)*")
HEADERS = {
    'en': [r'Simplifying\s+Tajweed'],
    'id': [r'Tajwid\s+Ringkas(?:\s+disertai\s+Warna,?\s*Gambar\s+dan\s+Bagan)?'],
}
# Lines holding a correction documented in content_src/lessons/REVIEW_NOTES.md
# (a factual error of the edition, fixed on purpose): never reverted.
KEEP = {
    ('id', 't09'): ['alif pada keadaan yang seharusnya ditipiskan'],
    ('id', 't14'): ['hanya terdapat dalam satu tempat'],
    ('id', 't15'): ['didahului oleh huruf berharakat fathah', 'memanjangkannya lebih dari dua harakat'],
    ('id', 't16'): ["Pertemuan muttashil dan 'aridh lissukun"],
    ('id', 't17'): ['termasuk sifat ithbaq'],
}
PROTECTED = re.compile(r'\{\{.*?\}\}|\[[^\]]*\]|\*\*.*?\*\*')


def bare(w):
    w = unicodedata.normalize('NFKC', w).replace('’', "'").lower()
    return w.replace("'", '').replace('-', '')


def page_text(doc, lang, page):
    raw = doc[page - 1].get_text()
    raw = unicodedata.normalize('NFKC', raw).replace('’', "'").replace('_', '-')
    for h in HEADERS[lang]:
        raw = re.sub(h, ' ', raw)
    raw = re.sub(r'\s+', ' ', raw)
    raw = re.sub(r'(\w) -(\w)', r'\1-\2', raw)  # "Al -Gazari" (from "Al _Gazari")
    return raw


def runs(line):
    """Editable prose runs of a line: (start, end) outside protected parts."""
    if line.startswith(('#', '|', '@', '%', '!')) or not line.strip():
        return []
    start = 0
    bar = line.find(' | ')
    if line.startswith('= ') and bar >= 0:
        start = bar + 3  # the label is left as it is
    m = re.match(r'(?:- |\d+\) )', line[start:])
    if m:
        start += m.end()
    out, pos = [], start
    for p in PROTECTED.finditer(line, start):
        if p.start() > pos:
            out.append((pos, p.start()))
        pos = p.end()
    if pos < len(line):
        out.append((pos, len(line)))
    return out


def restore(lang, topic, write=False, full=False):
    path = os.path.join(ROOT, 'content_src', 'lessons', f'{topic}.{lang}.txt')
    lines = open(path, encoding='utf-8').read().split('\n')
    doc = pymupdf.open(os.path.join(ROOT, 'assets', 'books', f'{lang}.pdf'))
    pages, page = {}, None
    for i, line in enumerate(lines):
        if line.startswith('@page'):
            page = int(line.split()[1])
        elif page is not None:
            pages.setdefault(page, []).append(i)

    new = {}
    for page, idxs in pages.items():
        ltoks = []  # (line, run, start, end, word) for words in prose runs
        for li in idxs:
            for ri, (rs, re_) in enumerate(runs(lines[li])):
                for m in WORD.finditer(lines[li], rs, re_):
                    ltoks.append((li, ri, m.start(), m.end(), m.group()))
        if not ltoks:
            continue
        ptext = page_text(doc, lang, page)
        ptoks = [(m.start(), m.end(), m.group()) for m in WORD.finditer(ptext)]
        lesson_bare = {bare(t[4]) for t in ltoks}
        merged, i = [], 0  # join words split by a lost apostrophe ("isti la")
        while i < len(ptoks):
            if (i + 1 < len(ptoks) and bare(ptoks[i][2]) + bare(ptoks[i + 1][2]) in lesson_bare
                    and bare(ptoks[i][2]) not in lesson_bare):
                merged.append((ptoks[i][0], ptoks[i + 1][1], ptoks[i][2] + ptoks[i + 1][2], True))
                i += 2
            else:
                merged.append((*ptoks[i], False))
                i += 1
        a = [bare(t[2]) for t in merged]
        b = [bare(t[4]) for t in ltoks]
        match = {}  # lesson token index -> page token index
        for blk in difflib.SequenceMatcher(a=a, b=b, autojunk=False).get_matching_blocks():
            for k in range(blk.size):
                match[blk.b + k] = blk.a + k

        headings = set()
        for li in idxs:
            line = lines[li]
            parts = []
            if line.startswith('#'):
                parts.append(re.sub(r'\{\{.*?\}\}|[#()]', ' ', line))
            if line.startswith('= ') and ' | ' in line:
                parts.append(line[2:line.find(' | ')])
            parts += re.findall(r'\*\*(.*?)\*\*', line)
            for part in parts:
                words = WORD.findall(re.sub(r'\{\{.*?\}\}', ' ', part))
                if len(words) >= 2:
                    headings.add(' '.join(words).lower())
        by_run = {}
        for k, t in enumerate(ltoks):
            by_run.setdefault((t[0], t[1]), []).append(k)
        for (li, ri), ks in by_run.items():
            anchored = [k for k in ks if k in match]
            if len(anchored) < 2:
                continue
            k1, k2 = anchored[0], anchored[-1]
            p1, p2 = match[k1], match[k2]
            if p2 < p1 or any(k in match and not p1 <= match[k] <= p2 for k in range(k1, k2 + 1)):
                continue
            s, e = ltoks[k1][2], ltoks[k2][3]
            # Up to four words the lesson added at the edges of the stretch
            # (before the first / after the last matching word) go too.
            lead = [k for k in ks if k < k1]
            trail = [k for k in ks if k > k2]
            used = set(match.values())

            def nearby(ks_, centre):
                window = {bare(merged[j][2]) for j in range(max(0, centre - 15), min(len(merged), centre + 16))}
                return all(bare(ltoks[k][4]) in window for k in ks_)
            if lead and nearby(lead, p1):
                lead = []  # the book has these words right there
            if trail and nearby(trail, p2):
                trail = []
            small = {'the', 'a', 'an', 'of', 'to', 'it', 'is', 'are', 'and', 'in', 'on'}
            if 0 < len(lead) <= 4:
                n = 0  # the book's own unmatched words just before
                while p1 > 0 and p1 - 1 not in used and n < 6 and not re.search(
                        r'[.:;!?]\s*$', ptext[merged[p1 - 1][1]:merged[p1][0]] or ''):
                    p1 -= 1
                    n += 1
                # added words go only if the book's words replace them, or
                # they are small function words the lesson inserted
                if n or all(bare(ltoks[k][4]) in small for k in lead):
                    s = ltoks[lead[0]][2]
            if 0 < len(trail) <= 4:
                n = 0
                while (p2 + 1 < len(merged) and p2 + 1 not in used and n < 6
                       and not re.search(r'[.:;!?]', ptext[merged[p2][1]:merged[p2 + 1][0]])):
                    p2 += 1
                    n += 1
                if n or all(bare(ltoks[k][4]) in small for k in trail):
                    e = ltoks[trail[-1]][3]
            book = ptext[merged[p1][0]:merged[p2][1]]
            ok = True
            for pk in range(p2, p1 - 1, -1):  # repair joined artefacts
                if merged[pk][3]:
                    lk = next((k for k in range(k1, k2 + 1) if match.get(k) == pk), None)
                    if lk is None:
                        ok = False
                        break
                    o = merged[pk][0] - merged[p1][0]
                    book = book[:o] + ltoks[lk][4] + book[o + merged[pk][1] - merged[pk][0]:]
            # Spacing the text layer lost (the printed page has it).
            book = re.sub(r'\(\s+', '(', book)
            book = re.sub(r'\s+\)', ')', book)
            book = re.sub(r'(?<=[A-Za-z])\((?=[A-Za-z])', ' (', book)
            book = re.sub(r'\)(?=[A-Za-z])', ') ', book)
            book = re.sub(r'[,;](?=[A-Za-z])', lambda m: m.group() + ' ', book)
            book = re.sub(r'\s+([,.;:])', r'\1', book)
            # Words the text layer ran together ("comesin" for "comes in").
            lw = [ltoks[k][4] for k in ks]
            for x, y in zip(lw, lw[1:]):
                joined = x + y
                if joined not in lw:
                    book = re.sub(r'\b' + re.escape(joined) + r'\b', x + ' ' + y, book)
            # Words the text layer split ("Menebalkan nya" for Menebalkannya).
            for w in lw:
                for cut in range(2, len(w) - 1):
                    book = re.sub(r'\b' + re.escape(w[:cut]) + ' ' + re.escape(w[cut:]) + r'\b', w, book)
            old = lines[li][s:e]
            # Apostrophe style (' ’ ‘) follows the lesson; it is not wording.
            def plain(w):
                return w.replace('’', "'").replace('‘', "'")
            forms = {plain(w): w for w in re.findall(r"[A-Za-z'’‘-]+", old)}
            book = re.sub(r"[A-Za-z'’‘-]+", lambda m: forms.get(plain(m.group()), m.group()), book)
            if any(k in lines[li] for k in KEEP.get((lang, topic), [])):
                continue
            # The line's own label repeated at the start of the stretch.
            if lines[li].startswith('= ') and ' | ' in lines[li]:
                lbw = [bare(w) for w in WORD.findall(lines[li][2:lines[li].find(' | ')])]
                bw = [bare(w) for w in WORD.findall(book)]
                if len(lbw) >= 2 and bw[:2] == lbw[-2:]:
                    continue
                if lbw and bw[:1] == lbw[-1:] and re.match(r'\W*[A-Za-z\'-]+\s?:', book):
                    continue
            if re.search(r'(^|\s)[a-z]\s?[:\-]?\s*$', book):
                continue  # ends on the next list item's letter ("b:")
            # A heading or label of this page pulled into the stretch.
            low_book, low_old = book.lower(), old.lower()
            if any(h in low_book and h not in low_old for h in headings):
                continue
            # The neighbouring **bold** term pulled into the stretch: misaligned.
            bold = {bare(w) for part in re.findall(r'\*\*(.*?)\*\*', lines[li]) for w in WORD.findall(part)}
            olds = {bare(w) for w in WORD.findall(old)}
            if any(bare(w) in bold and bare(w) not in olds for w in WORD.findall(book)):
                continue
            if not ok or re.search(r'[؀-ۿ]', book) or book.count('(') != book.count(')'):
                continue
            if len(book.split()) > len(old.split()) + 6 or book == old:
                continue
            if set(re.findall(r'\d+', book)) - set(re.findall(r'\d+', lines[li][s:e])):
                continue  # a number the line does not have: misaligned (label, page no.)
            new.setdefault(li, []).append((s, e, book))

    changed = {}
    for li, edits in new.items():
        line = lines[li]
        for s, e, rep in sorted(edits, key=lambda x: -x[0]):
            line = line[:s] + rep + line[e:]
        if line != lines[li]:
            changed[li] = line
    def similarity(x, y):
        return difflib.SequenceMatcher(a=x.split(), b=y.split(), autojunk=False).ratio()
    for li in sorted(changed):
        if '--low' in sys.argv:
            if similarity(lines[li], changed[li]) < 0.5:
                print(f'--- {topic}.{lang}:{li + 1}\n- {lines[li]}\n+ {changed[li]}')
            continue
        if full:
            print(f'--- {topic}.{lang}:{li + 1}\n- {lines[li]}\n+ {changed[li]}')
            continue
        x, y = lines[li].split(' '), changed[li].split(' ')
        pairs = [f"[{' '.join(x[i1:i2])} → {' '.join(y[j1:j2])}]"
                 for op, i1, i2, j1, j2 in difflib.SequenceMatcher(a=x, b=y, autojunk=False).get_opcodes()
                 if op != 'equal']
        print(f'{li + 1}: ' + ' '.join(pairs))
    print(f'{topic}.{lang}: {len(changed)} lines changed')
    if write:
        for li, text in changed.items():
            lines[li] = text
        open(path, 'w', encoding='utf-8').write('\n'.join(lines))


if __name__ == '__main__':
    restore(sys.argv[1], sys.argv[2], '--write' in sys.argv, '--full' in sys.argv)
