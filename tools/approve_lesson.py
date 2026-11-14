#!/usr/bin/env python3
"""Record a human's lesson approval against a supplied source fingerprint.

Usage: python3 tools/approve_lesson.py --language en --topic t01 \
  --reviewer 'Name' --sha256 <hash-from-reviewed-source>
This does not review or approve content automatically.
"""
import argparse
import datetime
import json
import re
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from review_integrity import file_fingerprint

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--language', choices=['ar', 'ckb', 'en', 'id'], required=True)
    parser.add_argument('--topic', required=True)
    parser.add_argument('--reviewer', required=True)
    parser.add_argument('--sha256', required=True)
    args = parser.parse_args()
    if not args.reviewer.strip() or not re.fullmatch(r't\d{2}', args.topic):
        parser.error('A reviewer name and valid topic ID are required')
    source = ROOT / 'content_src' / 'lessons' / f'{args.topic}.{args.language}.txt'
    if not source.is_file() or file_fingerprint(source) != args.sha256:
        parser.error('Source does not match the reviewed fingerprint; review the current source again')
    path = source.parent / 'reviewed.json'
    data = json.loads(path.read_text()) if path.exists() else {}
    if not isinstance(data.get(args.language, {}), dict):
        parser.error('Migrate legacy topic-only approvals before recording new approvals')
    data.setdefault(args.language, {})[args.topic] = {
        'status': 'reviewed', 'source_sha256': args.sha256,
        'by': args.reviewer.strip(), 'date': datetime.date.today().isoformat(),
    }
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    print('Recorded supplied approval; rebuild content to apply it.')


if __name__ == '__main__':
    main()
