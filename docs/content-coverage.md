# Content and translation coverage

Generated from the bundled content files (`assets/content/*.json`). Status meanings: **sourceTranscribed** = typed from the edition's page image (needs proofreading); **sourceExtracted** = taken from the edition's PDF text layer (Arabic fragments restored from the image); **authored** = written for the app because the edition has no equivalent text (needs subject review; Kurdish also needs fluent-language review); **reviewed** = approved by a qualified reviewer (none yet).

## Original books (the authoritative presentation)

| Edition | Pages | Topics present (of 30) | Absent | Partial |
|---|---|---|---|---|
| Arabic | 102 | 30 | — | — |
| Kurdish (Sorani) | 112 | 30 | — | — |
| English | 109 | 29 | t07 | t14, t22 |
| Indonesian | 112 | 29 | t07 | — |

All four editions are bundled, offline, unchanged in content (see `docs/licenses.md` and `docs/validation.md` for the structural optimisation).

## Native lessons (full text of every topic) — all `draft`

Every topic is also available as an in-app lesson: the book's own text, section by section, with headings, definitions, lists and notes. Its tables are rebuilt as native tables, figures are kept as images cropped from the page, and each section links to the page it came from ("View in the book"). The original pages remain the authoritative presentation.

| Language | Lessons | Status | Blocks | Native tables | Figures cropped from the book | Qur'anic excerpts (verified) |
|---|---|---|---|---|---|---|
| Arabic | 30 | sourceTranscribed (typed from page images) | 1221 | 39 | 42 | 1140 |
| Kurdish (Sorani) | 30 | sourceTranscribed | 1227 | 42 | 41 | 1165 |
| English | 29 (t22 partial: the edition only defines sakt inside the waqf comparison, p.86) | sourceExtracted (text layer; Arabic retyped) | 1197 | 37 | 39 | 1085 |
| Indonesian | 29 | sourceExtracted | 1228 | 36 | 41 | 1112 |

* Topic 7 has no English or Indonesian pages, so it has no lesson in those languages (the app shows the other editions instead).
* **Every Qur'anic word or phrase** in a lesson is copied verbatim from Tanzil Uthmani 1.1 by the build: the source names a reference (or `?`) and a letter pattern; nothing is typed from memory, and the build fails on any pattern without an exact match. 634 verses are referenced in total (`assets/content/quran.json`).
* Where an edition's page contains an error (a wrong verse citation, a misprinted word, a copied line), the lesson follows the corrected Qur'anic text and the case is logged in `content_src/lessons/REVIEW_NOTES.md` for the author and reviewers; the page itself is unchanged.
* Each edition follows its own pages: example lists differ slightly between editions, and the lessons keep those differences.
* Source files: `content_src/lessons/<topic>.<lang>.txt` (118 files); progress table: `content_src/lessons/PROGRESS.md`.

## Topic titles (30)

| Language | sourceTranscribed | sourceExtracted | authored | reviewed |
|---|---|---|---|---|
| Arabic | 30 | 0 | 0 | 0 |
| Kurdish (Sorani) | 30 | 0 | 0 | 0 |
| English | 0 | 29 | 1 | 0 |
| Indonesian | 0 | 29 | 1 | 0 |

Group titles (8) and partial-coverage notes are authored in all four languages.

## Rule cards (22) — supplementary, all `draft`

| Language | sourceTranscribed | sourceExtracted | authored | reviewed |
|---|---|---|---|---|
| Arabic | 22 | 0 | 0 | 0 |
| Kurdish (Sorani) | 22 | 0 | 0 | 0 |
| English | 0 | 20 | 2 | 0 |
| Indonesian | 0 | 22 | 0 | 0 |

Definitions are quoted from each language's own edition with its page. Authored definitions: English r13/r14 (Laam of the name of Allah), because the English edition lacks that subsection. Explanations of the highlighted letters (22 × 4) are authored. Every Qur'anic example (22) is taken from the books' own example tables and copied verbatim from Tanzil with an automatically verified reference.

## Practice questions (277) — supplementary, all `draft`

Every one of the 30 topics has at least two questions. Options are shown in random order in the app.

* **99 hand-written** (q01–q99) — prompts, options and explanations authored in all four languages from each topic's lesson text:
  * q01–q28: the original set (identify 21, choice 5, true/false 2) for the rule topics.
  * q29–q99: 71 concept questions covering the 23 topics that had none (definitions, lahn, ranks of recitation, isti'adhah, basmalah, makharij, titles of the letters, common mistakes, ghunnah levels, the stronger cause, idgham, hamzahs, waqf, ibtida', sakt, the seven alifs, nabr, Hafs's special readings, rawm and ishmam, two sakin letters, sujood at-tilawah, the chain of Hafs, the ten reciters). Where a question is about a Qur'anic word, the word is a verified Tanzil `example` (17 questions), never typed in the prompt.
* **178 drafted** by `tools/gen_identify_questions.py` (q101+, marked `"generated"`; ids stay the same when the tool is rerun, so saved results keep their questions):
  * 151 "identify the rule" questions from the books' example tables, for 19 of the 22 rule cards — noon sakinah and tanween 87, meem sakinah 9, noon/meem mushaddad 4, qalqalah 7, laam of «ال» 15, laam of the name of Allah 4, madd 25.
  * 27 "where is this letter articulated?" questions from the articulation data (every letter with a single articulation point); options are point names, the explanation is the edition's own description of the point.
 Each identify example is a word the Arabic lesson prints (found with `tools/harvest_examples.py`, which uses the lesson builder's Tanzil resolver); highlights cover the letters that decide the rule. Explanations come from per-rule templates in four languages and name the deciding letter.
* Kurdish wording of all new questions needs fluent review; English and Indonesian wording follows each edition's own terms.

## Articulation points (17 points, 5 areas, 14 diagram landmarks)

| Language | sourceTranscribed | sourceExtracted | authored | reviewed |
|---|---|---|---|---|
| Arabic | 17 | 0 | 0 | 0 |
| Kurdish (Sorani) | 17 | 0 | 0 | 0 |
| English | 0 | 17 | 0 | 0 |
| Indonesian | 0 | 17 | 0 | 0 |

Landmark coordinates are the book's own vector marker positions (identical in AR and EN). Landmark labels follow each edition's own diagram labels.

## Search index
* Topic titles (4 languages) and rule-card titles (4 languages) — automatic.
* Curated aliases (`assets/content/search_terms.json`, authored) — all 30 topics × 4 languages.
* Page text: English (106 pages) and Indonesian (109 pages) text layers, Latin script only. Arabic and Kurdish editions have no page-text index (their text layers are not reliable).
* **Lesson text** in all four languages (the native lessons above), so Arabic and Kurdish learners can now search the full content of their own edition; a hit opens the lesson at the matching section.

## Interface strings
208 keys × 4 languages (`lib/l10n/arb`). Arabic, English and Indonesian written for the app; Kurdish written for the app and **needs fluent Sorani review**, as do the Kurdish framework localisations in `lib/l10n/ckb_localizations.dart`.

## What is shown where
* **Preview channel** (debug/profile builds, or `--dart-define=RATTIL_CONTENT_CHANNEL=preview`): everything above, with draft cards/questions marked "Development preview".
* **Release channel** (release builds by default): books, curriculum, reader, bookmarks, notes, search, makharij explorer; rule cards and questions appear only once their `review.status` is `reviewed`. Today that set is empty, and the Rules and Practice tabs say they are under review.
* Reviewer metadata (status fields) never appears on learner screens; only the preview badge, and only in the preview channel.

## Known source discrepancies (PDFs untouched)
* CKB p.20 prints "ط ذ ث" where AR has ظ ذ ث (app letter data uses ظ ذ ث).
* ID p.22: noon articulated "above" the laam point, versus "below" in AR/CKB/EN (kept verbatim; flagged).
* Several English/Indonesian typos are kept verbatim in extracted quotations (e.g. "Its is called", "haruf").

