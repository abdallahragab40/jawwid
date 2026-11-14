"""Bind expert approval to the exact source that was reviewed."""
import hashlib
import json


def item_fingerprint(item):
    payload = {key: value for key, value in item.items() if key != 'review'}
    return hashlib.sha256(json.dumps(payload, ensure_ascii=False,
                                     sort_keys=True, separators=(',', ':')).encode()).hexdigest()


def file_fingerprint(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def approved_item(item):
    review = item.get('review', {})
    return (isinstance(review, dict) and review.get('status') == 'reviewed'
            and review.get('source_sha256') == item_fingerprint(item))


def approved_lesson(approvals, language, topic, source):
    entries = approvals.get(language, {})
    if not isinstance(entries, dict):
        return False  # Legacy topic-only flags need an explicit fingerprint.
    entry = entries.get(topic)
    return (isinstance(entry, dict) and entry.get('status') == 'reviewed'
            and entry.get('source_sha256') == file_fingerprint(source))
