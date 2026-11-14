#!/usr/bin/env python3
"""Builds verified content assets for Jawwid (جَوِّد).

Reads   content_src/rules.src.json, content_src/quiz.src.json
Writes  assets/content/rules.json, assets/content/quiz.json, assets/content/quran.json

Qur'anic excerpts are never typed by hand. Each example names a reference
("surah:ayah") and a *plain-letter pattern* such as "م[ن] [ه]اجر". The pattern is
matched against the Tanzil Uthmani text (tools/tanzil-quran-uthmani-1.1.txt)
letter-by-letter while ignoring diacritics; the exact Uthmani substring is then
copied verbatim into the output. Letters inside [...] become highlight ranges,
and every range is widened to include the combining marks that follow its base
letter, so tashkeel is never split from its letter.

The build fails if any reference, pattern or highlight cannot be matched.
Usage:  python3 -I tools/build_content.py
"""
import json, os, re, sys, unicodedata
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from review_integrity import approved_item, item_fingerprint

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TANZIL = os.path.join(ROOT, 'tools', 'tanzil-quran-uthmani-1.1.txt')

# Characters treated as marks that attach to the preceding base letter.
MARK_RANGES = [(0x0610, 0x061A), (0x064B, 0x065F), (0x0670, 0x0670), (0x06D6, 0x06ED), (0x08D3, 0x08FF)]
FOLD = {'ٱ': 'ا', 'أ': 'ا', 'إ': 'ا', 'آ': 'ا',
        'ى': 'ي', 'ؤ': 'و', 'ئ': 'ي', 'ـ': ''}

TANZIL_META = os.path.join(ROOT, 'tools', 'tanzil-quran-data-1.0.xml')


def load_surah_names():
    """Surah names from Tanzil metadata (quran-data.xml, CC-BY)."""
    names = {}
    for m in re.finditer(r'<sura index="(\d+)"[^>]* name="([^"]+)" tname="([^"]+)"', open(TANZIL_META, encoding='utf-8').read()):
        names[int(m.group(1))] = (m.group(2), m.group(3))
    assert len(names) == 114, len(names)
    return names


SURAH_NAMES = load_surah_names()


def is_mark(ch):
    o = ord(ch)
    return any(a <= o <= b for a, b in MARK_RANGES)


def load_tanzil():
    verses, header = {}, []
    with open(TANZIL, encoding='utf-8') as f:
        for line in f:
            if line.startswith('#'):
                header.append(line.rstrip('\n'))
                continue
            if not line.strip():
                continue
            s, a, t = line.rstrip('\n').split('|', 2)
            verses[(int(s), int(a))] = t
    return verses, '\n'.join(h for h in header if h.strip('# =').strip())


def bases(text):
    """Returns [(folded_base_char, start_index, end_index_including_marks)]."""
    out, i = [], 0
    while i < len(text):
        ch = text[i]
        if is_mark(ch):
            if out:  # attach to previous base
                b, s, _ = out[-1]
                out[-1] = (b, s, i + 1)
            i += 1
            continue
        folded = FOLD.get(ch, ch)
        out.append((folded, i, i + 1))
        i += 1
    return [b for b in out if b[0] != '']


def parse_pattern(pat):
    letters, hl, inside = [], [], False
    for ch in pat:
        if ch == '[':
            inside = True; continue
        if ch == ']':
            inside = False; continue
        f = FOLD.get(ch, ch)
        if not f or is_mark(ch):
            continue
        letters.append(f)
        hl.append(inside)
    return letters, hl


def resolve(verses, ref, pattern, where):
    s, a = (int(x) for x in ref.split(':'))
    if (s, a) not in verses:
        sys.exit(f'{where}: unknown reference {ref}')
    text = verses[(s, a)]
    bs = bases(text)
    letters, hl = parse_pattern(pattern)
    seq = [b[0] for b in bs]
    n = len(letters)
    hits = [i for i in range(len(seq) - n + 1) if seq[i:i + n] == letters
            and (i == 0 or seq[i - 1] == ' ') and (i + n == len(seq) or seq[i + n] == ' ')]
    if not hits:
        sys.exit(f'{where}: pattern {pattern!r} not found as whole words in {ref}: {text}')
    i0 = hits[0]
    start, end = bs[i0][1], bs[i0 + n - 1][2]
    excerpt = text[start:end]
    ranges = []
    for k in range(n):
        if not hl[k]:
            continue
        rs, re_ = bs[i0 + k][1] - start, bs[i0 + k][2] - start
        if ranges and ranges[-1][1] == rs:
            ranges[-1][1] = re_
        else:
            ranges.append([rs, re_])
    if not any(hl):
        sys.exit(f'{where}: pattern {pattern!r} has no highlighted letters')
    whole = (excerpt == text)
    # Sanity: highlights never start on a mark and never split a mark from its base.
    for rs, re_ in ranges:
        assert not is_mark(excerpt[rs]), (where, excerpt, rs)
        assert re_ == len(excerpt) or not is_mark(excerpt[re_]), (where, excerpt, re_)
    return {'ref': ref, 'surah': s, 'ayah': a, 'text': excerpt, 'isWholeAyah': whole,
            'highlights': ranges, 'occurrencesInAyah': len(hits)}


def main():
    verses, header = load_tanzil()
    used = set()
    out_files = {}
    for name in ('rules', 'quiz'):
        src_path = os.path.join(ROOT, 'content_src', f'{name}.src.json')
        data = json.load(open(src_path, encoding='utf-8'))
        items = data['rules'] if name == 'rules' else data['questions']
        for item in items:
            source_hash = item_fingerprint(item)
            if item.get('review', {}).get('status') == 'reviewed' and not approved_item(item):
                print(f"Approval invalidated by missing/changed fingerprint: {name}:{item['id']}")
                item['review'] = {'status': 'draft'}
            item['sourceFingerprint'] = source_hash
            ex = item.get('example')
            if ex:
                r = resolve(verses, ex['ref'], ex['pattern'], f"{name}:{item['id']}")
                item['example'] = {**r, 'pattern': ex['pattern']}
                used.add((r['surah'], r['ayah']))
        out_files[name] = data
    quran = {
        'schemaVersion': 1,
        'source': 'Tanzil Quran Text (Uthmani, Version 1.1), https://tanzil.net',
        'license': 'Creative Commons Attribution 3.0. Verbatim copies only; changing the text is not allowed.',
        'notice': header,
        'surahNames': {str(k): {'ar': v[0], 'latin': v[1]} for k, v in SURAH_NAMES.items()},
        'surahNamesSource': 'Tanzil Quran metadata 1.0 (quran-data.xml), (C) 2008-2009 Tanzil.info, CC-BY',
        'verses': {f'{s}:{a}': verses[(s, a)] for s, a in sorted(used)},
    }
    missing = sorted({s for s, _ in used} - set(SURAH_NAMES))
    if missing:
        sys.exit(f'missing surah names for {missing}')
    os.makedirs(os.path.join(ROOT, 'assets', 'content'), exist_ok=True)
    for name, data in out_files.items():
        with open(os.path.join(ROOT, 'assets', 'content', f'{name}.json'), 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=1)
    with open(os.path.join(ROOT, 'assets', 'content', 'quran.json'), 'w', encoding='utf-8') as f:
        json.dump(quran, f, ensure_ascii=False, indent=1)
    print(f"ok: {len(out_files['rules']['rules'])} rules, {len(out_files['quiz']['questions'])} questions, "
          f"{len(used)} verified verses")


if __name__ == '__main__':
    main()
