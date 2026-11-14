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
flutter build apk --release      # Android: configure android/key.properties first
flutter build appbundle --release
flutter build ios --release      # needs a signing team in Xcode
```

Android release builds never use the debug key. Copy `android/key.properties.example` to `android/key.properties` and fill it locally with your upload-keystore configuration; both the real properties file and keystores are ignored by Git. Missing signing configuration stops release packaging. For an unsigned local inspection artifact only: `ORG_GRADLE_PROJECT_jawwidAllowUnsignedRelease=true flutter build apk --release`. Unsigned APKs cannot be installed directly or uploaded as signed releases.

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

* **Rule cards / questions** — edit `content_src/*.src.json`, then `./tools/build_all.sh` (the quiz build rewrites `quran.json`, so the lesson build must run after it). A multiple-choice option is a number, counts, an Arabic term (`{"arabic": …}`), or text in each language (`{"text": {"ar": …, "ckb": …, "en": …, "id": …}}`); a Qur'anic word in a question always goes in `example` (reference + pattern), never in the prompt. Qur'anic examples are written as a reference plus a plain-letter pattern with `[ ]` around highlighted letters (e.g. `"59:9"`, `"م[ن] [ه]اجر"`). The build copies the exact Uthmani text from Tanzil and fails if a pattern does not match. To find a phrase: `python3 -I tools/qsearch.py "من هاجر"`.
* **Drafted questions** — `python3 -I tools/gen_identify_questions.py && ./tools/build_all.sh` rewrites the generated questions (q101+) in `content_src/quiz.src.json` from the book examples listed in the tool; hand-written questions (q01–q99) are kept.
* **Native lessons** — edit `content_src/lessons/<topic>.<lang>.txt` (format documented at the top of `tools/build_lessons.py`: `@page`, headings, lists, `= term | text`, tables, `!crop x0 y0 x1 y1`, inline `{{q REF|PATTERN}}` and `{{a ARABIC}}`), then `PYTHON=<python with PyMuPDF> ./tools/build_all.sh`. PyMuPDF is only needed when a figure crop is added or moved; `tools/page_images.py <lang> <pages…>` prints figure rectangles. Open questions found while transcribing are kept in `content_src/lessons/REVIEW_NOTES.md`.
* **Review pack** — `python3 -I tools/make_review_pack.py` writes `docs/review/review.html` (every rule card and question by topic, four languages, example highlighted, right answer marked) and `docs/review/review.csv` (one row per item; rows already filled in are kept). The reviewer writes `ok` or `change` + a note per row; `python3 -I tools/apply_review.py docs/review/review.csv --reviewer "Name"` approves the `ok` rows and lists requested changes in `docs/review/feedback.md`; then `./tools/build_all.sh`.
* **Approving content** — after expert review, apply the fingerprinted CSV with `tools/apply_review.py`. For lessons, use `python3 -I tools/approve_lesson.py --language en --topic t01 --reviewer "Name" --sha256 <reviewed-source-hash>`. Approvals now bind to the reviewed source; edits invalidate them on rebuild. Legacy flags without fingerprints remain draft. Rebuild before regenerating a review pack; stale compiled content is rejected. See `docs/first-unit-release-plan.md`.
* **Topic/page mapping** — `assets/content/curriculum.json`; `docs/topic-page-mapping.md` documents how it was verified.
* **Search page index** — `python3 tools/build_search_index.py source/books` (needs PyMuPDF).
* **PDF optimisation** — `python3 tools/optimize_pdf.py source/books/rattil-level2-ar.pdf assets/books/ar.pdf`, then `python3 tools/verify_opt.py > docs/evidence/pdf_optimization_verification.json` (needs PyMuPDF, pypdfium2, numpy).

## User data

Settings, per-edition reading positions, bookmarks, notes, reading progress and practice results are stored locally (no account) in one versioned JSON document in the app-support directory (`lib/core/json_store.dart`): atomic writes, a backup copy, and step-wise schema migrations so updates keep existing data.

Choose a study preference on Welcome or in Settings: step by step, revision, or explore. Home uses that preference for its daily activity and offers interrupted practice first.

Compare two available rule cards from Rules or an individual card; comparisons retain the existing content-review filtering and source references. Rule cards can be saved as favorites from their star button. Add a note for a lesson section from its Contents sheet; find it later under More → Bookmarks and notes. Section notes retain an original-page link when their native anchor is unavailable.

More → Backup and restore provides explicit portable backup files through the system picker, plus a copy/paste text fallback. Restore previews the backup date and note/bookmark counts. Restoration asks before replacing current data and preserves notification opt-in on the receiving device. Backups include private notes; the app does not upload them.

Practice offers 3/5/10-question sessions and scheduled reviews. Interrupted sessions can be continued from Practice at the next unanswered question, preserving score and option order. A fresh session replaces the saved one; a content update can invalidate it. Search remembers up to eight submitted/selected queries per language, with a clear-history control. Home includes a short daily activity and weekly learning goals; these goals count answers and explicit completion separately from reading-day streaks.

See `docs/` for the verified mapping, coverage report, licence records, validation results, product roadmap and outstanding release dependencies.

## Product completion and release handoff

See [implementation and handoff](docs/completion-and-handoff.md) for delivered work and remaining external dependencies. [Pilot guide](docs/pilot-guide.md) prepares usability/adoption research; no participant data is bundled.

Generate a read-only content inventory and source-fingerprint matrix with `python3 -I tools/release_audit.py` (outputs `docs/release-audit/`). `--require-reviewed` deliberately fails until all intended full-course content is approved; this is not a rights/signing/store approval check. Lesson approvals are per-language in `content_src/lessons/reviewed.json`.

Run native integration screenshots and platform builds sequentially: Flutter regenerates platform plugin registrants, so concurrent integration/release builds can race over test-plugin registration. Current product-journey screenshots: `integration_test/product_journeys_test.dart`.

Startup now draws a loading screen while local assets and saved data open. It tries the last good backup if typed data validation fails, offers a non-destructive retry on failure or a 30-second stall, and protects data written by a newer schema. Pending reading-position writes are flushed when the app leaves the foreground. Reminder dates and progress day labels use calendar-safe arithmetic across daylight-saving changes.

If both local study files are unreadable after assets have loaded, the startup recovery screen can open a restore-only backup form. It never exports an empty replacement backup, requires confirmation before writing, and reloads the app after a successful restore. Write failures preserve live progress and show an error. This recovery action is unavailable for data from a newer schema; update the app instead. Recovery reminders default off because the unreadable device preference cannot be trusted.
