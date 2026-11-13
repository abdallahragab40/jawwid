# Font, asset and source licence records

Verified facts are marked **verified** (checked in the files themselves). Anything not established is marked **not established** and is listed in `docs/release-dependencies.md`.

## 1. Source books (four Level-2 editions)

| Edition | File (master, unchanged) | SHA-256 | Credits printed in the book |
|---|---|---|---|
| Arabic | `source/books/rattil-level2-ar.pdf` | `23b2be94…8654664a` | Author: حسين كريم محمد |
| Kurdish (Sorani) | `source/books/rattil-level2-ckb.pdf` | `369bf536…f0e7` | Author: حسين كريم محمد (no separate translator credited) |
| English | `source/books/rattil-level2-en.pdf` | `4aede637…77ed12` | Author: Hussein Kareem Mohammed · Translated by Nisreen Kamal Shalash (EN p.3) |
| Indonesian | `source/books/rattil-level2-id.pdf` | `285401ae…c0460394` | Author: Husein Karim Muhammad · Translated by Ustadzah Ana Fi Naimatin (ID p.3) |

Full hashes: `source/books/SHA256SUMS`. The masters are byte-identical to the files supplied (verified with `cmp`).

**Distribution condition (verified, quoted from the books' introduction, EN p.3):** "A copyright is available for everyone as long as he keeps them away from adding or removing." The Arabic introduction (p.3) carries the same condition.

**Not established:** explicit permission to (a) bundle the PDFs inside a commercial or free app, (b) ship structurally optimised copies, (c) derive supplementary material (transcribed definitions, the extracted diagram image, rule cards, questions). The app is designed to respect the stated condition (nothing added to or removed from the pages; supplementary material is clearly separate and attributed), but written confirmation from the author is a release dependency.

### Bundled copies
`assets/books/{ar,ckb,en,id}.pdf` are structurally optimised copies (byte-identical image streams merged, unused objects removed, object streams compressed — `tools/optimize_pdf.py`). No image is re-encoded and no content stream is rewritten. Size: 41.0 MB → 25.4 MB total (−38%). Rendering evidence: `docs/evidence/pdf_optimization_verification.json` and `docs/validation.md`.

## 2. Fonts embedded inside the PDFs (not shipped as app fonts)

Identified from the embedded font programs (name tables), **verified**:

| Embedded font | Identity / rights holder (from the font's own name table) | Embedded as | Redistributable as an app font? |
|---|---|---|---|
| Calibri, Cambria, Sakkal Majalla | © Microsoft Corporation ("Microsoft supplied font… create, display, and print content") | subsets | **No** |
| Times New Roman, Arial, Symbol | © The Monotype Corporation / Microsoft | full | **No** |
| `___WRD_EMBED_SUB_52/53/54` | **KFGQPC Uthman Taha Naskh** — © 2008–2010 King Fahd Glorious Quran Printing Complex, "ELECTRONIC END-USER LICENSE AGREEMENT… All rights reserved" | subset (637 glyphs) | **No** (EULA; not verified to allow app redistribution) |
| `___WRD_EMBED_SUB_16xx/17xx/51` (HQPB1–HQPB5) | Qur'an word-glyph fonts, "Amgad" | subsets (≈220 glyphs each) | **No / not established**. These encode Qur'anic words as private glyph codes, which is why Qur'anic text cannot be extracted from the PDFs. |
| +Amo TModern / TModernA | © 2008 Monotype Imaging | subsets | **No** |
| 55_Sarchia_Kurdish | © 2013 Sarchia Banokay, All Rights Reserved | subsets | **No** |
| Rabar_062 | © 2013 Rabar Arkan, All Rights Reserved | subsets | **No** |
| Ali_K_Alwand, Ali-Arabesque | Ali Ni'ma, 1998 (freeware origin, licence not stated) | subsets | **Not established** |
| Bold Italic Art | Platinum Technology 96 | subset | **Not established** |
| HutSutRalston | © 2001 Nick Curtis | subset | **Not established** |

An embedded subset is not a complete font and its presence in a PDF grants no right to reuse it. None of these are used by the native interface. They remain embedded in the PDFs as published by the author; whether redistributing those PDFs inside an app is covered by the fonts' embedding permissions is part of the release dependency above.

## 3. Fonts bundled with the app (`assets/fonts`) — SIL Open Font License 1.1

| Family | Role | Source | Reserved Font Name |
|---|---|---|---|
| Noto Naskh Arabic (400/500/700) | Arabic & Kurdish reading text | google/fonts `ofl/notonaskharabic` | none |
| Noto Sans Arabic (400–700) | Arabic & Kurdish interface controls | google/fonts `ofl/notosansarabic` | none |
| Amiri (Regular, Bold) | Arabic & Kurdish headings | google/fonts `ofl/amiri` | none |
| Amiri Quran | Qur'anic examples only | google/fonts `ofl/amiriquran` | none |
| Literata (400/600/700, opsz 16) | English & Indonesian reading text and headings | google/fonts `ofl/literata` | none |
| Inter (400–700, opsz 14) | English & Indonesian interface controls | google/fonts `ofl/inter` | none |

Licence texts: `assets/fonts/licenses/` (also shown in the app's licence page). Static weights were instanced from the upstream variable fonts with `fontTools varLib.instancer` — a modification permitted by OFL 1.1; none of these families declares a Reserved Font Name. Upstream file hashes: `docs/evidence/font_upstream_sha256.txt`.

**Evaluated and not used:** *Lora* — declares Reserved Font Name "Lora" (modified versions must be renamed) and lacks ḥ ṣ ḍ ṭ ẓ ʿ ʾ used in Indonesian transliterations (e.g. ID p.110 "Aḥkām", "Muḥāfaẓah"). Literata covers all of them.

Glyph coverage check (all **verified**, `docs/validation.md`): Noto Naskh Arabic, Noto Sans Arabic and Amiri contain ڕ ڵ ێ ۆ ە ڤ پ چ ژ گ ک ی ئ, ZWNJ/ZWJ, all harakat, the Qur'anic annotation marks U+06D6–U+06ED and U+08F0–U+08F2, and Arabic-Indic digits. Amiri Quran lacks Kurdish letters and is used for Qur'anic text only.

## 4. Qur'anic text

Tanzil Quran Text (Uthmani, version 1.1), © 2007–2026 Tanzil Project, **Creative Commons Attribution 3.0**; verbatim copies only ("CHANGING IT IS NOT ALLOWED"); source must be indicated with a link to tanzil.net. The app ships only the verses it uses (634, for rule cards, questions and lessons) (`assets/content/quran.json`, with the full notice) and displays verbatim excerpts of them, labelled "Excerpt from …". Attribution appears in About and the licence page. Whether displaying a *partial* verse with coloured letters is within "verbatim" is a reasonable reading but is listed for confirmation.

## 5. Other assets

* `assets/images/makharij_sagittal.png` — the label-free articulation illustration from the embedded image object on AR p.15 (JPEG xref 524 with its soft mask xref 525): the JPEG was decoded once and combined with its transparency mask, then saved losslessly as PNG; no other change (the same image appears on EN p.17, CKB p.18, ID p.18). Book content: covered by the book permission dependency.
* `assets/images/lessons/*.jpg` (163 files) — figures cropped from the books' own pages (illustrations of articulation, letter characteristics, mushaf signs, etc.), rendered from the unchanged master PDFs; no other change. Book content: covered by the book permission dependency.
* Native lesson text (`assets/content/lessons_*.json`) — the books' own text, transcribed (Arabic, Kurdish) or taken from the text layer (English, Indonesian). Book and translation content: covered by the book and translator permission dependencies.
* App icon (`ios/Runner/Assets.xcassets/AppIcon.appiconset`, `android/app/src/main/res/mipmap-*`) — original artwork made for this app: the name «جَوِّد» set in Noto Naskh Arabic Bold (OFL, §3) on a geometric eight-pointed star; generated from `test/rendering/app_icon_test.dart` by `tools/make_icons.py`.

## 6. Software packages

| Package | Version | Licence |
|---|---|---|
| Flutter SDK / flutter_localizations | 3.44.8 | BSD-3-Clause |
| pdfrx / pdfrx_engine / pdfium_flutter / pdfium_dart | 2.4.8 / 0.4.7 / 0.2.3 / 0.2.5 | MIT |
| PDFium (native binaries fetched by pdfium_flutter) | — | BSD-3-Clause (Google/Foxit) |
| flutter_riverpod | 3.4.3 | MIT |
| path_provider | 2.1.x | BSD-3-Clause |
| intl | 0.20.x | BSD-3-Clause |

Package licences are collected automatically by Flutter's licence page (`About → Licences`).
