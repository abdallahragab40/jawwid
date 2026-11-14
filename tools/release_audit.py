#!/usr/bin/env python3
"""Read-only inventory of release content; never grants expert approval.

python3 -I tools/release_audit.py
python3 -I tools/release_audit.py --require-reviewed  # all-content release gate
"""
import argparse
import csv
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LANGUAGES = ('ar', 'ckb', 'en', 'id')


def reviewed(value):
    return (value.get('status') if isinstance(value, dict) else value) == 'reviewed'


def audit(root=ROOT):
    content = root / 'assets' / 'content'
    files = ['curriculum.json', 'rules.json', 'quiz.json',
             *[f'lessons_{lang}.json' for lang in LANGUAGES]]
    raw = {name: (content / name).read_bytes() for name in files}
    data = {name: json.loads(payload) for name, payload in raw.items()}
    rules = data['rules.json']['rules']
    questions = data['quiz.json']['questions']
    approved_rules = {r['id'] for r in rules if reviewed(r.get('review'))}
    rows = []
    lesson_counts = {}
    for lang in LANGUAGES:
        lessons = data[f'lessons_{lang}.json']['lessons']
        lesson_counts[lang] = {
            'available': len(lessons),
            'reviewed': sum(reviewed(l.get('review')) for l in lessons.values()),
        }
        for topic, lesson in lessons.items():
            source = root / 'content_src' / 'lessons' / f'{topic}.{lang}.txt'
            rows.append({'kind': 'lesson', 'id': topic, 'language': lang,
                         'topic': topic, 'status': 'reviewed' if reviewed(lesson.get('review')) else 'draft',
                         'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest() if source.exists() else ''})
    blocked_questions = []
    for kind, items in [('rule', rules), ('question', questions)]:
        for item in items:
            status = 'reviewed' if reviewed(item.get('review')) else 'draft'
            rows.append({'kind': kind, 'id': item['id'], 'language': 'all',
                         'topic': item['topic'], 'status': status,
                         'source_sha256': hashlib.sha256(json.dumps(item, ensure_ascii=False, sort_keys=True).encode()).hexdigest()})
            if kind == 'question' and status == 'reviewed' and item['type'] == 'identify':
                missing = [option for option in item['options'] if option not in approved_rules]
                if missing:
                    blocked_questions.append({'id': item['id'], 'unavailable_rule_options': missing})
    missing_lessons = [
        {'topic': topic['id'], 'language': lang}
        for topic in data['curriculum.json']['topics'] for lang in LANGUAGES
        if topic['pages'].get(lang) is not None and
        topic['id'] not in data[f'lessons_{lang}.json']['lessons']
    ]
    draft = [row for row in rows if row['status'] != 'reviewed']
    return {
        'schemaVersion': 1,
        'scope': 'Content inventory only; rights, signing, store policies and hardware checks require separate evidence.',
        'files': {name: hashlib.sha256(payload).hexdigest() for name, payload in raw.items()},
        'lessons': lesson_counts,
        'rules': {'available': len(rules), 'reviewed': len(approved_rules)},
        'questions': {'available': len(questions), 'reviewed': sum(reviewed(q.get('review')) for q in questions)},
        'reviewed_questions_with_unavailable_options': blocked_questions,
        'missing_native_lessons': missing_lessons,
        'all_content_reviewed': bool(rules and questions) and not draft and not blocked_questions and not missing_lessons,
        'draft_items': len(draft),
        'matrix': rows,
    }


def write_report(report, output):
    output.mkdir(parents=True, exist_ok=True)
    (output / 'content-audit.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    with (output / 'review-matrix.csv').open('w', newline='', encoding='utf-8') as handle:
        writer = csv.DictWriter(handle, fieldnames=['kind', 'id', 'language', 'topic', 'status', 'source_sha256'])
        writer.writeheader()
        writer.writerows(report['matrix'])
    lines = ['# Release content audit', '', report['scope'], '',
             'Generated with `python3 -I tools/release_audit.py`. This is a snapshot, not approval.', '',
             '| Content | Available | Reviewed |', '|---|---:|---:|']
    for lang, count in report['lessons'].items():
        lines.append(f"| Lessons ({lang}) | {count['available']} | {count['reviewed']} |")
    for kind in ['rules', 'questions']:
        count = report[kind]
        lines.append(f"| {kind.title()} | {count['available']} | {count['reviewed']} |")
    lines += ['', f"Draft items: {report['draft_items']}.",
              f"Missing native lessons: {len(report['missing_native_lessons'])}.",
              f"Reviewed questions blocked by unavailable answer cards: {len(report['reviewed_questions_with_unavailable_options'])}.", '',
              'Lesson approval is language-specific in `content_src/lessons/reviewed.json`.',
              'Rule/question approval applies to the whole multilingual item. Use the existing expert review pack to review every translation.',
              'The CSV records current status and source fingerprints; editing it does not approve content.',
              'Re-run after source changes. Existing approval flags are not automatically revoked by this report; reviewers must compare the fingerprints.', '',
              'See `docs/release-dependencies.md` for outstanding rights, expert review, signing and hardware dependencies.']
    (output / 'README.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', type=Path, default=ROOT / 'docs' / 'release-audit')
    parser.add_argument('--require-reviewed', action='store_true')
    args = parser.parse_args()
    report = audit()
    write_report(report, args.output_dir)
    print(f"Wrote content audit: {report['draft_items']} draft items; {len(report['reviewed_questions_with_unavailable_options'])} blocked questions.")
    return 1 if args.require_reviewed and not report['all_content_reviewed'] else 0


if __name__ == '__main__':
    raise SystemExit(main())
