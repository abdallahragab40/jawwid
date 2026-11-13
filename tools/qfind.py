#!/usr/bin/env python3
"""Shows how a plain-letter phrase is spelled and voweled in Tanzil.
Usage: python3 -I tools/qfind.py "من تخشى" ["..."]"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_lessons import VERSES, ORDER, BASES, SEQ, parse_pattern, _find  # noqa: E402

for q in sys.argv[1:]:
    letters, _, _ = parse_pattern(q)
    seen, out = {}, []
    for k in ORDER:
        i = _find(SEQ[k], letters)
        if i < 0:
            continue
        bs = BASES[k]
        form = VERSES[k][bs[i][1]:bs[i + len(letters) - 1][2]]
        seen.setdefault(form, []).append(f'{k[0]}:{k[1]}')
    print(f'## {q}: {sum(len(v) for v in seen.values())} hits')
    for form, refs in list(seen.items())[:8]:
        print(f'   {form}   ×{len(refs)}  e.g. {", ".join(refs[:3])}')
