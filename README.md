# جَوِّد — Jawwid · تبسيط التجويد

A calm, offline Tajweed study app for Android and iOS, built around the four Level-2 editions of *تبسيط التجويد / Simplifying Tajweed* (Arabic, Kurdish Sorani, English, Indonesian).

**Hybrid design.** The original books are shown unchanged in a PDF reader; native Flutter screens provide the curriculum, rule cards, an articulation-point explorer, practice, search, bookmarks and notes. Arabic is the first-launch language, regardless of device language.

The product name is configurable in one place: `lib/app/branding.dart` (plus the platform labels `ios/Runner/Info.plist › CFBundleDisplayName` and `android/app/src/main/AndroidManifest.xml › android:label`).

## Requirements (as verified on the development machine)

* Flutter **3.44.8** (stable), Dart 3.12.2.
* Xcode with iOS 15+ SDKs (the project's iOS deployment target was raised from the template's 13.0 to **15.0**, because the installed Xcode no longer supports 13.0). Plugins are integrated with Swift Package Manager; there is no Podfile.
* Android SDK (the app builds with the Flutter defaults for compile/min/target SDK).
* Network access the first time you build, so `pdfium_flutter` can download the PDFium binaries. After that the app itself needs no network at all.

## Run

```sh
flutter pub get          # also generates lib/l10n/generated from lib/l10n/arb
flutter run              # pick a simulator/emulator/device
```

Development and profile builds show unreviewed supplementary content (rule cards, practice), labelled **Development preview**. Release builds show only reviewed material. Override either way:

```sh
flutter run --dart-define=RATTIL_CONTENT_CHANNEL=release
flutter run --release --dart-define=RATTIL_CONTENT_CHANNEL=preview
```

## Test

```sh
dart format --set-exit-if-changed lib test integration_test test_driver
flutter analyze
flutter test                                   # unit + widget + rendering tests
flutter test test/rendering --update-goldens   # regenerate text-rendering images
```

On-device checks (real PDFium rendering, all 118 topic links, screenshots into `docs/screenshots/`):

```sh
flutter devices                                # find a simulator/device id
# every topic link opens the mapped page in the real PDF viewer (118 links)
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/topic_links_test.dart -d <device-id>
# screenshots of every main screen in the four languages → docs/screenshots/
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots_test.dart -d <device-id>
```

## Build

```sh
flutter build apk --release      # Android (uses the template's debug signing until a release key is configured)
flutter build appbundle --release
flutter build ios --release      # needs a signing team in Xcode
```

## Repository layout

```
assets/books/        bundled PDFs (structurally optimised, pixel-identical)
assets/content/      editions, curriculum + page mapping, rules, quiz, makharij, Qur'an excerpts, search data
assets/fonts/        OFL fonts + licences
assets/images/       articulation diagram extracted from the book
content_src/         hand-edited sources for rules, quiz and the native lessons (Qur'anic text as Tanzil patterns)
source/books/        original PDFs, unchanged masters + SHA256SUMS (not bundled)
lib/app/             app shell, theme, branding, routes
lib/content/         typed models + content repository (release/preview policy)
lib/core/            numerals, search normalisation, versioned JSON store
lib/features/        home, curriculum, reader, rules, makharij, practice, search, study state, more
lib/l10n/            ARB files (ar, ckb, en, id) + Kurdish framework localisations
tools/               content build, PDF optimisation + verification, search index, Tanzil search
docs/                mapping, coverage, licences, validation, release dependencies, screenshots
```

## Content workflow

* **Rule cards / questions** — edit `content_src/*.src.json`, then `python3 -I tools/build_content.py`. Qur'anic examples are written as a reference plus a plain-letter pattern with `[ ]` around highlighted letters (e.g. `"59:9"`, `"م[ن] [ه]اجر"`). The build copies the exact Uthmani text from Tanzil and fails if a pattern does not match. To find a phrase: `python3 -I tools/qsearch.py "من هاجر"`.
* **Drafted questions** — `python3 -I tools/gen_identify_questions.py && python3 -I tools/build_content.py` rewrites the generated questions (q101+) in `content_src/quiz.src.json` from the book examples listed in the tool; hand-written questions (q01–q99) are kept.
* **Native lessons** — edit `content_src/lessons/<topic>.<lang>.txt` (format documented at the top of `tools/build_lessons.py`: `@page`, headings, lists, `= term | text`, tables, `!crop x0 y0 x1 y1`, inline `{{q REF|PATTERN}}` and `{{a ARABIC}}`), then `PYTHON=<python with PyMuPDF> ./tools/build_all.sh`. PyMuPDF is only needed when a figure crop is added or moved; `tools/page_images.py <lang> <pages…>` prints figure rectangles. Open questions found while transcribing are kept in `content_src/lessons/REVIEW_NOTES.md`.
* **Approving content** — set `"review": {"status": "reviewed"}` on a card or question, or list a topic in `content_src/lessons/reviewed.json`, after expert review; only then does it appear in release builds.
* **Topic/page mapping** — `assets/content/curriculum.json`; `docs/topic-page-mapping.md` documents how it was verified.
* **Search page index** — `python3 tools/build_search_index.py source/books` (needs PyMuPDF).
* **PDF optimisation** — `python3 tools/optimize_pdf.py source/books/rattil-level2-ar.pdf assets/books/ar.pdf`, then `python3 tools/verify_opt.py > docs/evidence/pdf_optimization_verification.json` (needs PyMuPDF, pypdfium2, numpy).

## User data

Settings, per-edition reading positions, bookmarks, notes, reading progress and practice results are stored locally (no account) in one versioned JSON document in the app-support directory (`lib/core/json_store.dart`): atomic writes, a backup copy, and step-wise schema migrations so updates keep existing data.

See `docs/` for the verified mapping, coverage report, licence records, validation results and outstanding release dependencies.
