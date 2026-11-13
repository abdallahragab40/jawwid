# Validation results

Environment: macOS (Darwin 27.2), Flutter 3.44.8 / Dart 3.12.2, Xcode with iOS 27 simulators, Android SDK. Network was available (the "Flutter download restriction" reported earlier no longer applies: pub.dev, PyPI and GitHub all answered). Every result below was actually executed in this session; nothing is reported as passing without having run.

## Static checks
| Check | Command | Result |
|---|---|---|
| Formatting | `dart format lib test integration_test test_driver` | clean |
| Static analysis | `flutter analyze` | **No issues found** |
| Localisation generation | `flutter gen-l10n` | ar, ckb, en, id generated; 245 keys in each language, code ↔ ARB key sets identical (scripted check) |

## Automated tests — `flutter test` (94 tests, all passing)
| File | What it proves |
|---|---|
| `test/core/core_test.dart` | Arabic-Indic digits for ar/ckb, Western for en/id; search normalisation (tashkeel, alef forms, kaf/yeh code points) keeps ڕ/ر ڵ/ل ێ/ی ۆ/و ە/ه and ئ distinct in strict mode, folds them only in loose mode, never folds پ چ ژ گ ڤ; JsonStore atomic save survives a fresh instance ("restart"), corrupt file falls back to backup, v1→v2 migration keeps positions/completions/bookmarks |
| `test/content/content_test.dart` | page counts; printed ↔ physical conversion for covers, blank pages, last numbered pages and round-trip on every page of every edition; 30 topics in source order, 8 contiguous groups; every range inside its edition and in order; spot-checked start pages; exactly two absences (t07 EN/ID) and partial notes in all languages; shared pages (AR 98); cross-edition mapping by topic keeps the offset and returns null for absent topics; 22 rule cards with a source page inside the right topic for every non-authored definition; 43 Qur'anic excerpts whose highlights never start on or split a combining mark; 28 questions with valid answers; release channel hides all draft material; makharij 5 areas / 17 points / landmark coordinates in range |
| `test/features/search_test.dart` | الإخفاء / الاخفاء / إخفاء / الإِخْفَاءُ → topic 10 and rule r05; القلقلة with/without tashkeel → topic 8 and r10; Kurdish exact terms; Arabic-keyboard ك/ي in Kurdish queries; ل-for-ڵ found only as a lower-ranked *folded* hit; English and Indonesian terms; irrelevant queries (pizza, bluetooth, كمبيوتر, xyz123) return nothing; "ال" alone returns nothing (**this test caught a real bug, fixed**); page hits for EN "ikhfaa" include pages 48–49, ID "qalqalah" p.34 → topic 8; no page index for AR/CKB |
| `test/app_flow_test.dart` | **first launch is Arabic** with the device locale set to en-US (RTL, Arabic strings); **connected flow** Arabic home → Lessons → topic 10 → *open lesson pages* (reader opens AR p.41) → page change to 46 saved → rule card r05 (source "النسخة العربية، صفحة ٤٦") → practice → correct answer recorded → *mark completed* → a fresh store read shows language, position 46, completion and quiz record; bookmarks and notes survive a restart; language switching to ckb keeps context by topic (continue card AR 46 → CKB 52, `CkbMaterialLocalizations` active, RTL) and to en (EN 46, LTR) with shared progress and per-edition positions; a topic absent from the English edition shows the explanation and other editions, with no "open pages" button; release channel shows "under review" for Rules and Practice; **each language on a 320×640 screen at 1.6× text** across all tabs, a rule card, a quiz question and the five heaviest lessons (t06, t08, t14, t15, t26) without layout errors (**this caught an overflow in the lesson page-marker row, fixed**); the lesson **contents sheet** jumps to a section; the **end of a lesson** marks the topic completed and opens the next lesson, and English navigation skips topic 7, which that edition does not have |
| `test/content/lessons_test.dart` | **every topic has a native lesson in every edition that covers it** (118 = 30 × 4 − 2 absences); every lesson block lies inside its topic's page range; every Qur'anic excerpt in every lesson is a verbatim substring of its Tanzil verse and no highlight starts on or splits a combining mark; no raw source markup leaks into displayed text; the release channel hides draft lessons; lesson full-text search in Arabic (with/without diacritics), Kurdish (exact and Arabic-keyboard spellings), English and Indonesian, and irrelevant/too-short queries return nothing |
| `test/features/quiz_test.dart` | options are shown in a random order (the answer is never fixed in one position); sessions are 10 questions that mix rules and lessons (topic 10 cannot fill one); earlier mistakes come first and the mistakes mode holds only those; the 3-question check at the end of a lesson can mark the lesson completed |
| `test/features/sort_test.dart` | sort questions: placing every letter in its group is correct; a wrong placement is marked per letter; a placed letter can be taken back; Check waits until every letter is placed |
| `test/features/lesson_nav_test.dart` | the lesson section bar moves to the next section and back; completing every lesson of a unit shows the celebration once |
| `test/features/accessibility_test.dart` | Flutter's accessibility guidelines (tap targets 48dp / 44pt, labelled buttons, text contrast) on home, lessons, rules, practice, more, lesson, rule card, quiz, articulation explorer, search and settings — all four languages in light, Arabic and English in dark — plus the welcome screen and a sort question |
| `test/rendering/*` | renders with the real bundled fonts (see *Rendering* below), including the topic-10 lesson in all four languages and the app icon artwork |

Visual defects found by reviewing the device screenshots and fixed: rule-card letter chips stretched to full width; the articulation diagram showed a black frame because its PDF soft mask had not been applied on extraction.

Layout problems found by these tests and fixed: topic "In the book" row (3 px overflow, Arabic at 400 px), the development-preview badge (up to 158 px at 1.6× text), the review-suggestion label tag on Home, and the quiz preview row.

## On-device tests (iOS simulator, iPhone 17 Pro, real PDFium rendering)
| Check | Command | Result |
|---|---|---|
| Build | `flutter build ios --simulator --debug` | ✓ built (after raising the deployment target from 13.0 to 15.0, which the installed Xcode requires) |
| Build | `flutter build apk --debug` | ✓ built |
| Build | `flutter build apk --release` | ✓ built (111 MB universal APK: native code for three architectures plus the 24 MB of book PDFs; the Play Store app bundle ships one architecture per phone) |
| Build | `flutter build apk --release --split-per-abi` | ✓ built (2026-11-13, with the native lessons) — arm64-v8a 58.9 MB, armeabi-v7a 54.4 MB, x86_64 60.7 MB; of which bundled PDFs 25.4 MB, lesson figures 7.1 MB (163 JPEGs), lesson and verse data about 1.9 MB, fonts 4.4 MB. Release mode uses the release content channel (draft lessons, cards and questions hidden). Not run on an emulator. |
| **Topic links** | `flutter drive … --target=integration_test/topic_links_test.dart` | **118 / 118** topic links (30 topics × 4 editions − 2 absences) open the mapped page, as reported by the viewer controller's *visible* page (`PdfViewerController.pageNumber`), not the requested page |
| Scroll position | part of `screenshots_test.dart` | moving the real viewer to page 44 updates the remembered position through `onPageChanged` |
| Screenshots | `flutter drive … --target=integration_test/screenshots_test.dart` | 55 screenshots in `docs/screenshots/` (index: `docs/screenshots/README.md`), including the native lessons, a cropped figure, a rebuilt table and the contents sheet in all four languages. Reviewing them found that brackets around Arabic inside English/Indonesian text could wrap onto the wrong line; fixed by keeping the brackets inside the right-to-left isolate. |

Note on test design: the first version of the topic-link test passed trivially because it read the position the reader records when it *opens*; a stricter version showed the viewer does not emit `onPageChanged` for the initial page; the final version reads the controller's visible page. Visual confirmation (AR p.41 shows the heading «أحكام النون الساكنة والتنوين», printed footer ٤١): `docs/screenshots/ar_04_reader.png` and the probe screenshot described in the session log.

## Navigation, haptics and the daily reminder (2026-11-13)
* A topic opens its lesson directly (curriculum, search, rule cards, Home suggestions, practice); the topic overview appears only when there is no lesson (topic absent from the edition, or lesson not yet approved in release). The completion switch, practice, related rule cards and other editions are at the end of the lesson. The whole book is a separate reference (Home card, More tab). "Level two" wording removed from the topic list and Home.
* Tests: Home start/continue open lessons and the whole book opens the reader at page 1; no «المستوى» text on Home or the topic list; t07 in English opens the overview; the reminder is off by default, scheduled at 20:00 in the learner's language, follows time and language changes, cancels when turned off, survives save/restore; a declined permission keeps it off with an explanation; haptics can be turned off.
* Android emulator (Medium Phone, Android 16): turning the reminder on showed the system notification-permission prompt; after allowing, `dumpsys alarm` listed one `RTC_WAKEUP` alarm for the app at 20:00 local with a +1 h window (inexact scheduling: no exact-alarm permission is requested, so delivery can be up to about an hour late). Delivery at the scheduled time and after a reboot were not observed.
* Notifications plugin pinned to 22.3.3: 23.x needs Android compileSdk 37 / AGP 9.1, newer than this project's toolchain.

## Lesson content build
`./tools/build_all.sh` (with `PYTHON` pointing at an interpreter that has PyMuPDF, needed only when a figure crop is added or moved):
* 118 lesson files parsed; **every Qur'anic pattern resolved against Tanzil** (634 verses written to `quran.json`); any unmatched pattern stops the build and nothing is written.
* Every block's page is checked against the topic's page range in `curriculum.json`.
* Figure crops (163) are rendered from the unchanged master PDFs at 2.5×; a crop is re-rendered whenever its rectangle changes (`content_src/lessons/crops.lock.json`). Each crop was inspected visually.
* Layout found by rendering and fixed: the detailed waqf table (topic 26) was four columns wide and scrolled sideways on a phone; it is now one narrow table per type under its own heading. A highlight was split around a tatweel (لْـَٔيْكَةِ); the build now merges highlight ranges separated only by a tatweel and its marks.

## Bundled PDFs (structural optimisation)
`tools/verify_opt.py` → `docs/evidence/pdf_optimization_verification.json`
* **PDFium** (the app's renderer): every page of all four editions **pixel-identical** at 150 % (max channel delta 0), and pages 5, 17, 28, 36, 47, 66 pixel-identical at **600 %** (small tashkeel, Qur'anic marks, coloured letters, diagram lines, tables, ornamental headings).
* Text layer identical on every page.
* **MuPDF** shows differences on the covers only at low zoom (≤ 0.2 % of pixels), disappearing at 600 %. Cause: MuPDF reuses one down-sampled decode when a merged image is drawn at several sizes. It is a renderer cache effect, not a content change; PDFium is unaffected.
* Size 41.0 MB → 25.4 MB (−38 %). No lossy recompression was used, so no "lossless" claim is needed beyond the measured pixel identity.

## Rendering of Arabic, Kurdish and Qur'anic text
Images in `docs/evidence/rendering/` (generated by `flutter test test/rendering --update-goldens` with the bundled fonts):
* `quran_highlights.png` — all 22 rule examples, highlighted vs plain.
* `highlight_variants.png` — large-size comparison (colour only / colour + background / plain). **Arabic joining is preserved across every colour boundary and every combining mark is present** (e.g. أَنْعَمْتَ keeps all five marks: three black, two red). An earlier small-size view suggested missing marks; the large-size check showed this was a reading error, not a rendering defect.
* `arabic_kurdish_specimen.png` — ڕ ڵ ێ ۆ ە ڤ پ چ ژ گ ک ی ئ and Kurdish words in Noto Naskh Arabic (400/700), Noto Sans Arabic and Amiri; Arabic with full tashkeel; Arabic-Indic digits — all shaped and positioned correctly.

## Reader themes and educational colour
`docs/evidence/reader_theme_color_check.json` — colours sampled from AR pages 16, 24, 36, 42, 46, 53, 66, 72 and from the diagram and label colours:
* **Sepia** (multiply #F8EFDC): the red used for rule letters moves ΔE₀₀ 1.5 (hue 0.1°); dark red 1.0; diagram blue/green/purple/yellow ≤ 4.7 (hue ≤ 9°); pale pink tints shift most (hue up to 19°, ΔE ≤ 6.4). The smallest pairwise difference between sampled colours stays essentially the same (4.4 → 4.1), so no two educational colours merge.
* **Night**: dark controls and backdrop with **original page colours**; optional uniform dimming (×0.82 on R, G, B) changes hue by ≤ 2.4°. Pages are never inverted.
* Screenshots: `docs/screenshots/ar_reader_theme_{light,sepia,night,night_dimmed}.png`.

## Requirements checklist
| Requirement | Status | Evidence |
|---|---|---|
| First launch is Arabic | ✓ | app_flow_test, `ar_00_first_launch.png` |
| All four languages render correctly | ✓ | screenshots ×4, layout tests ×4 |
| Mixed-direction content | ✓ | Arabic examples always RTL in EN/ID (Directionality.rtl), LTR snippets in AR search |
| Topic links open correct pages in every edition | ✓ | 118/118 on device |
| Language switching preserves context | ✓ | app_flow_test |
| Search behaves as described | ✓ | search_test; coverage stated in UI |
| Notes, bookmarks, progress survive restart | ✓ | app_flow_test, core_test |
| Offline reading | ✓ by design | all books/fonts/content bundled; no network code in the app |
| Diacritics and Kurdish glyphs intact | ✓ | rendering evidence |
| Enlarged text and small screens | ✓ | layout tests at 320×640 and 1.6× |
| Reader themes preserve educational colours | ✓ | colour check |
| No unfinished controls appear functional | ✓ | no audio/score controls; every control navigates or acts |

## Not verified here
* Physical Android/iOS devices (only the iOS simulator was available; the Android APK was built but not run on an emulator).
* Screen-reader pass with TalkBack / VoiceOver.
* Release-mode performance on a low-end phone.
