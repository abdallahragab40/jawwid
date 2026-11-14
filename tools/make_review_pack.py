#!/usr/bin/env python3
"""Builds the expert-review pack for rule cards and practice questions.

Writes
  docs/review/review.html  every rule card and question, by topic, in all four
                           languages, with the Qur'anic example highlighted and
                           the right answer marked (open in a browser or print)
  docs/review/review.csv   one row per item: the reviewer fills in
                           `decision` (ok / change) and notes

Rows already filled in an existing review.csv are kept, so the pack can be
rebuilt after content changes without losing a reviewer's work. Apply the
decisions with tools/apply_review.py.

Usage: python3 -I tools/make_review_pack.py   (after ./tools/build_all.sh)
"""
import csv, html, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from review_integrity import item_fingerprint

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTENT = os.path.join(ROOT, 'assets', 'content')
OUT = os.path.join(ROOT, 'docs', 'review')
LANGS = [('ar', 'العربية', 'rtl'), ('ckb', 'کوردی', 'rtl'), ('en', 'English', 'ltr'), ('id', 'Indonesia', 'ltr')]
FIELDS = ['id', 'kind', 'topic', 'type', 'status', 'source_sha256', 'decision', 'note', 'kurdish_note']
TF = {'ar': ('صواب', 'خطأ'), 'ckb': ('ڕاستە', 'هەڵەیە'), 'en': ('True', 'False'), 'id': ('Benar', 'Salah')}


def load(name):
    return json.load(open(os.path.join(CONTENT, name), encoding='utf-8'))


def esc(s):
    return html.escape(str(s))


def excerpt(e, quran):
    """The Qur'anic excerpt with its highlighted letters, plus the reference."""
    if not e:
        return ''
    t, out, pos = e['text'], [], 0
    for a, b in e['highlights']:
        out.append(esc(t[pos:a]))
        out.append(f'<mark>{esc(t[a:b])}</mark>')
        pos = b
    out.append(esc(t[pos:]))
    surah = quran['surahNames'].get(str(e['surah']), {}).get('ar', e['surah'])
    return (f'<div class="quran" dir="rtl">﴿{"".join(out)}﴾</div>'
            f'<div class="ref">{esc(surah)} {e["ref"]}</div>')


def lang_rows(cells):
    """cells: {lang: html}. One row per language."""
    rows = []
    for code, name, d in LANGS:
        rows.append(f'<tr><th>{name}</th><td dir="{d}" lang="{code}">{cells.get(code, "")}</td></tr>')
    return '<table class="langs">' + ''.join(rows) + '</table>'


def options_html(q, rules, code):
    t = q['type']
    if t == 'identify':
        items = [(rules[r]['title'][code], r == q['answer']) for r in q['options']]
    elif t == 'choice':
        items = []
        for i, o in enumerate(q['options']):
            if 'text' in o:
                label = o['text'][code]
            elif 'arabic' in o:
                label = o['arabic']
            elif 'counts' in o:
                label = o['counts'] + ' ×'
            else:
                label = o['number']
            items.append((label, i == q['answer']))
    elif t == 'truefalse':
        yes, no = TF[code]
        items = [(yes, q['answer'] is True), (no, q['answer'] is False)]
    else:  # sort
        out = []
        for g, label in enumerate(q['groups']):
            letters = ' '.join(i['arabic'] for i in q['items'] if i['group'] == g)
            out.append(f'<li><b>{esc(label[code])}</b>: <span dir="rtl">{esc(letters)}</span></li>')
        return '<ul class="sort">' + ''.join(out) + '</ul>'
    return '<ul class="opts">' + ''.join(
        f'<li class="{"ok" if right else ""}">{"✓ " if right else ""}{esc(label)}</li>' for label, right in items) + '</ul>'


def main():
    sources = {}
    for kind, name, key in [('rule card', 'rules', 'rules'), ('question', 'quiz', 'questions')]:
        doc = json.load(open(os.path.join(ROOT, 'content_src', f'{name}.src.json'), encoding='utf-8'))
        sources.update({(kind, item['id']): item_fingerprint(item) for item in doc[key]})
    rules_data, quiz, curriculum, quran = load('rules.json'), load('quiz.json'), load('curriculum.json'), load('quran.json')
    for kind, items in [('rule card', rules_data['rules']), ('question', quiz['questions'])]:
        for item in items:
            if item.get('sourceFingerprint') != sources.get((kind, item['id'])):
                sys.exit(f"Stale compiled content for {kind}:{item['id']}; run tools/build_all.sh first")
    rules = {r['id']: r for r in rules_data['rules']}
    topics = curriculum['topics']
    title = {t['id']: t['title']['ar']['text'] + ' — ' + t['title']['en']['text'] for t in topics}

    by_topic = {t['id']: {'rules': [], 'questions': []} for t in topics}
    for r in rules_data['rules']:
        by_topic[r['topic']]['rules'].append(r)
    for q in quiz['questions']:
        by_topic[q['topic']]['questions'].append(q)

    rows, sections, toc = [], [], []
    for t in topics:
        tid = t['id']
        group = by_topic[tid]
        if not group['rules'] and not group['questions']:
            continue
        count = len(group['rules']) + len(group['questions'])
        toc.append(f'<li><a href="#{tid}">{tid} · {esc(title[tid])}</a> ({count})</li>')
        parts = [f'<h2 id="{tid}">{tid} · {esc(title[tid])}</h2>']
        for r in group['rules']:
            status = r.get('review', {}).get('status', 'draft')
            rows.append({'id': r['id'], 'kind': 'rule card', 'topic': tid, 'type': 'rule', 'status': status})
            definition = {c: esc(r['definition'][c]['text']) + f' <span class="src">({r["definition"][c]["status"]}, p. {r["definition"][c].get("page", "–")})</span>' for c, _, _ in LANGS}
            parts.append(
                f'<section class="item rule"><h3><span class="id">{r["id"]}</span> Rule card · {esc(r["title"]["ar"])} · {esc(r["title"]["en"])} <span class="status">{status}</span></h3>'
                f'<p class="letters" dir="rtl">{esc(r.get("letters", ""))}</p>'
                + excerpt(r.get('example'), quran)
                + '<h4>Title</h4>' + lang_rows({c: esc(r['title'][c]) for c, _, _ in LANGS})
                + '<h4>Definition (quoted from each edition)</h4>' + lang_rows(definition)
                + '<h4>Explanation of the example (written for the app)</h4>' + lang_rows({c: esc(r['explanation'][c]) for c, _, _ in LANGS})
                + '</section>')
        for q in group['questions']:
            status = q.get('review', {}).get('status', 'draft')
            source = 'generated' if q.get('generated') else 'hand-written'
            rows.append({'id': q['id'], 'kind': 'question', 'topic': tid, 'type': q['type'], 'status': status})
            prompt = {}
            for c, _, _ in LANGS:
                if q['type'] == 'identify':
                    prompt[c] = {'ar': 'ما الحكم في الحروف الملوّنة؟', 'ckb': 'حوکمی پیتە ڕەنگکراوەکان چییە؟',
                                 'en': 'Which rule applies to the highlighted letters?',
                                 'id': 'Hukum apa yang berlaku pada huruf yang ditandai?'}[c]
                else:
                    prompt[c] = q['prompt'][c]
            parts.append(
                f'<section class="item"><h3><span class="id">{q["id"]}</span> {q["type"]} · {source} <span class="status">{status}</span></h3>'
                + excerpt(q.get('example'), quran)
                + lang_rows({c: f'<p class="prompt">{esc(prompt[c])}</p>{options_html(q, rules, c)}'
                                f'<p class="expl">{esc(q["explanation"][c])}</p>' for c, _, _ in LANGS})
                + '</section>')
        sections.append(''.join(parts))

    # Interface strings (for the language reviewers, Kurdish above all).
    arb = {c: json.load(open(os.path.join(ROOT, 'lib', 'l10n', 'arb', f'app_{c}.arb'), encoding='utf-8'))
           for c, _, _ in LANGS}
    keys = [k for k in arb['en'] if not k.startswith('@')]
    string_rows = []
    for k in keys:
        rows.append({'id': k, 'kind': 'string', 'topic': '', 'type': 'interface', 'status': ''})
        cells = ''.join(f'<td dir="{d}">{esc(arb[c].get(k, ""))}</td>' for c, _, d in LANGS)
        string_rows.append(f'<tr><th><code>{esc(k)}</code></th>{cells}</tr>')
    toc.append(f'<li><a href="#strings">Interface strings</a> ({len(keys)})</li>')
    sections.append('<h2 id="strings">Interface strings</h2><p>Words on buttons, tabs and messages. '
                    'Wording fixes go in the <i>note</i> / <i>kurdish_note</i> columns of the row with the same key.</p>'
                    '<table class="strings"><tr><th>key</th>' + ''.join(f'<th>{n}</th>' for _, n, _ in LANGS) + '</tr>'
                    + ''.join(string_rows) + '</table>')

    os.makedirs(OUT, exist_ok=True)
    for row in rows:
        row['source_sha256'] = sources.get((row['kind'], row['id']), '')
    page = f'''<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Jawwid review pack</title>
<style>
 body {{ font-family: system-ui, sans-serif; max-width: 980px; margin: 0 auto; padding: 16px; color: #1e2723; background: #fbf8f1; line-height: 1.5; }}
 h1 {{ color: #125f4c; }} h2 {{ color: #125f4c; border-bottom: 2px solid #e2daca; padding-top: 12px; }}
 .item {{ background: #fff; border: 1px solid #e2daca; border-radius: 12px; padding: 12px 16px; margin: 12px 0; break-inside: avoid; }}
 .item h3 {{ font-size: 15px; margin: 0 0 8px; }} .item h4 {{ font-size: 13px; color: #55635d; margin: 10px 0 4px; }}
 .id {{ background: #125f4c; color: #fff; border-radius: 6px; padding: 1px 8px; font-family: ui-monospace, monospace; }}
 .status {{ float: right; font-size: 12px; color: #86662a; background: #f4ecd8; border-radius: 6px; padding: 1px 8px; }}
 .quran {{ font-family: 'Amiri Quran', 'Amiri', 'Noto Naskh Arabic', serif; font-size: 30px; text-align: center; }}
 .quran mark {{ background: #f6d9da; color: #c0262d; }}
 .ref {{ text-align: center; color: #55635d; font-size: 13px; }}
 .letters {{ font-size: 22px; text-align: center; margin: 4px 0; }}
 table.langs {{ width: 100%; border-collapse: collapse; }}
 table.langs th {{ width: 90px; text-align: start; vertical-align: top; color: #55635d; font-weight: 600; font-size: 13px; padding: 6px 8px 6px 0; }}
 table.langs td {{ border-top: 1px solid #efe8d8; padding: 6px 0; }}
 td[dir=rtl] {{ font-family: 'Noto Naskh Arabic', 'Amiri', serif; font-size: 17px; }}
 .prompt {{ font-weight: 600; margin: 0 0 4px; }} .expl {{ color: #3c4a44; margin: 4px 0 0; }}
 ul.opts, ul.sort {{ margin: 0; padding-inline-start: 18px; }} ul.opts li.ok {{ color: #1b7a4b; font-weight: 700; }}
 .src {{ color: #86662a; font-size: 12px; }}
 table.strings {{ border-collapse: collapse; font-size: 14px; }}
 table.strings th, table.strings td {{ border: 1px solid #e2daca; padding: 4px 6px; vertical-align: top; text-align: start; }}
 .how {{ background: #eef5f1; border-radius: 12px; padding: 12px 16px; }}
 @media print {{ body {{ background: #fff; }} .item {{ border-color: #bbb; }} }}
</style></head><body>
<h1>Jawwid — review pack</h1>
<div class="how">
<p><b>{sum(1 for r in rows if r["kind"] == "rule card")} rule cards and {sum(1 for r in rows if r["kind"] == "question")} practice questions</b>, grouped by topic, then the <b>{sum(1 for r in rows if r["kind"] == "string")} interface strings</b>. Everything is <b>draft</b> until approved; only approved items appear in the released app.</p>
<p><b>How to review:</b> open <code>review.csv</code> (Excel or Google Sheets). For each id, write <code>ok</code> in <i>decision</i>, or <code>change</code> with what to change in <i>note</i>. A Kurdish reviewer writes wording fixes in <i>kurdish_note</i>. Then send the file back; <code>tools/apply_review.py</code> approves the <code>ok</code> rows and lists the changes.</p>
<p><b>What to check:</b> the highlighted letters and the rule; that the marked answer is right and the others wrong; that each explanation matches the book; that the four languages say the same thing. Qur'anic text is copied verbatim from Tanzil and checked automatically.</p>
</div>
<h2>Topics</h2><ul>{''.join(toc)}</ul>
{''.join(sections)}
</body></html>'''
    with open(os.path.join(OUT, 'review.html'), 'w', encoding='utf-8') as f:
        f.write(page)

    # Keep whatever a reviewer already filled in.
    path = os.path.join(OUT, 'review.csv')
    previous = {}
    if os.path.exists(path):
        with open(path, encoding='utf-8-sig', newline='') as f:
            previous = {r['id']: r for r in csv.DictReader(f)}
    with open(path, 'w', encoding='utf-8-sig', newline='') as f:
        w = csv.DictWriter(f, fieldnames=FIELDS, lineterminator='\n')
        w.writeheader()
        for r in rows:
            old = previous.get(r['id'], {})
            decision = old.get('decision', '') if old.get('source_sha256') == r['source_sha256'] else ''
            w.writerow({**r, 'decision': decision, **{k: old.get(k, '') for k in ('note', 'kurdish_note')}})
    print(f'review pack: {len(rows)} items -> docs/review/review.html, docs/review/review.csv')


if __name__ == '__main__':
    main()
