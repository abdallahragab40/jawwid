#!/usr/bin/env python3
"""Applies a filled-in docs/review/review.csv.

  decision = ok      -> the rule card / question becomes "reviewed" (shown in
                        release builds), with the date
  decision = change  -> stays draft; listed in docs/review/feedback.md
  note / kurdish_note on any row -> listed in docs/review/feedback.md

Afterwards rebuild: ./tools/build_all.sh   (the review status of generated
questions survives tools/gen_identify_questions.py).

Usage: python3 -I tools/apply_review.py [path/to/review.csv] [--reviewer NAME]
"""
import csv, datetime, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from review_integrity import item_fingerprint

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCES = {'rule card': ('rules.src.json', 'rules'), 'question': ('quiz.src.json', 'questions')}
OK = {'ok', 'approve', 'approved', 'yes', 'y', '✓', 'نعم', 'موافق'}
CHANGE = {'change', 'no', 'fix', 'n', 'تعديل'}


def main():
    args = sys.argv[1:]
    reviewer = None
    if '--reviewer' in args:
        i = args.index('--reviewer')
        reviewer = args[i + 1]
        del args[i:i + 2]
    path = args[0] if args else os.path.join(ROOT, 'docs', 'review', 'review.csv')
    with open(path, encoding='utf-8-sig', newline='') as f:
        rows = list(csv.DictReader(f))

    data = {}
    for kind, (name, key) in SOURCES.items():
        p = os.path.join(ROOT, 'content_src', name)
        with open(p, encoding='utf-8') as source:
            data[kind] = (p, json.load(source), key)
    index = {kind: {item['id']: item for item in d[1][d[2]]} for kind, d in data.items()}

    today = datetime.date.today().isoformat()
    approved, changes, unknown, ignored = [], [], [], []
    for r in rows:
        kind, rid = r.get('kind', '').strip(), r.get('id', '').strip()
        decision = r.get('decision', '').strip().lower()
        note, knote = r.get('note', '').strip(), r.get('kurdish_note', '').strip()
        if kind == 'string':  # interface wording: notes only
            if note or knote:
                changes.append((rid, kind, '', decision or '—', note, knote))
            continue
        item = index.get(kind, {}).get(rid)
        if item is None:
            if decision or note or knote:
                unknown.append(rid)
            continue
        if decision in OK:
            fingerprint = item_fingerprint(item)
            if r.get('source_sha256') != fingerprint:
                print(f'Skipping stale/unfingerprinted approval: {kind}:{rid}; regenerate the review pack and review again.')
                continue
            review = {'status': 'reviewed', 'date': today, 'source_sha256': fingerprint}
            if reviewer:
                review['by'] = reviewer
            item['review'] = review
            approved.append(rid)
        elif decision in CHANGE:
            item['review'] = {'status': 'draft'}
        elif decision and decision not in CHANGE:
            ignored.append((rid, decision))
        if decision in CHANGE or note or knote:
            changes.append((rid, kind, r.get('topic', ''), decision or '—', note, knote))

    for kind, (p, doc, _) in data.items():
        with open(p, 'w', encoding='utf-8') as f:
            json.dump(doc, f, ensure_ascii=False, indent=1)
            f.write('\n')

    out = os.path.join(ROOT, 'docs', 'review', 'feedback.md')
    with open(out, 'w', encoding='utf-8') as f:
        f.write(f'# Review feedback ({today})\n\n')
        f.write(f'Approved: {len(approved)}. Changes requested or notes: {len(changes)}.\n\n')
        if changes:
            f.write('| id | kind | topic | decision | note | Kurdish note |\n|---|---|---|---|---|---|\n')
            for rid, kind, topic, decision, note, knote in changes:
                cell = lambda s: s.replace('|', '\\|').replace('\n', ' ')
                f.write(f'| {rid} | {kind} | {topic} | {decision} | {cell(note)} | {cell(knote)} |\n')
    print(f'approved {len(approved)}, changes/notes {len(changes)} -> docs/review/feedback.md')
    if unknown:
        print('unknown ids (not changed):', ', '.join(unknown))
    if ignored:
        print('unrecognised decisions (use ok or change):', ', '.join(f'{i}={d}' for i, d in ignored))
    print('now run: ./tools/build_all.sh')


if __name__ == '__main__':
    main()
