#!/usr/bin/env python3
"""Lists the Qur'anic examples of the Arabic lessons, grouped by section.

Every example is resolved against Tanzil by the lesson builder's own resolver,
so the printed reference and pattern are exactly what the book's lesson shows.
Used to draft practice questions from the books' example tables; never types
Qur'anic text.

Usage: python3 -I tools/harvest_examples.py [topic ...]   (JSON on stdout)
"""
import io, json, os, re, sys
from contextlib import redirect_stdout

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
with redirect_stdout(io.StringIO()):
    import build_lessons as bl  # noqa: E402

Q = re.compile(r'\{\{q (.*?)\|(.*?)\}\}')


def harvest(topic):
    path = os.path.join(bl.SRC, f'{topic}.ar.txt')
    heads = ['', '', '']
    page = None
    out = []
    for line in open(path, encoding='utf-8'):
        line = line.rstrip('\n')
        if line.startswith('@page'):
            page = int(line.split()[1]); continue
        m = re.match(r'^(#{1,3}) (.*)', line)
        if m:
            lvl = len(m.group(1)) - 1
            heads[lvl] = m.group(2).strip()
            for k in range(lvl + 1, 3):
                heads[k] = ''
            if lvl == 0 or not Q.search(line):
                continue
        row = None
        if line.startswith('|'):
            row = [c.strip() for c in bl._split_cells(line)]
        for qm in Q.finditer(line):
            ref, pat = qm.group(1).strip(), qm.group(2).strip()
            if '…' in pat or pat == '*':
                continue
            r = bl.resolve(ref, pat, f'{topic}:{page}')
            if r['ref'] == '0:0':
                continue
            out.append({'topic': topic, 'page': page, 'h1': heads[0], 'h2': heads[1], 'h3': heads[2],
                        'row': row[0] if row else None, 'table': row is not None,
                        'ref': r['ref'], 'pattern': pat, 'text': r['text']})
    return out


if __name__ == '__main__':
    topics = sys.argv[1:] or sorted({f.split('.')[0] for f in os.listdir(bl.SRC) if f.endswith('.ar.txt')})
    json.dump([e for t in topics for e in harvest(t)], sys.stdout, ensure_ascii=False, indent=1)
