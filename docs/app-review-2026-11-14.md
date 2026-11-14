# App review — 14 November 2026

The app has a substantial offline foundation and good automated coverage. The highest priorities are dependable saving, reader/navigation edge cases, notification synchronization, and making the intended learning experience available in the release channel. More features should follow those fixes and a reviewed first learning unit.

## Evidence and limits

- Fresh `flutter analyze`: no issues.
- Fresh `flutter test`: 162 tests passed, including rendering, storage recovery, localization, accessibility guidelines, and product flows.
- Fresh `python3 -m unittest discover -s tools/tests`: 2 tests passed.
- Fresh content inventory generated to `/tmp/jawwid-review-audit`: 432 draft items, no missing native lessons.
- Two isolated probes in `/tmp/jawwid_review_probe_test.dart` confirmed stale topic retention and live-state changes after failed saves. An initial probe also produced a Riverpod assertion during disposal with a pending position write.
- Reviewed startup, persistence, backups, state, routes, reader, lessons, practice/checkpoints, search, reminders, settings/support, release configuration, and content-review tooling.
- Sampled existing English Home and Arabic Settings screenshots. These were existing images, not newly captured screens.
- The preceding reader task verified document reuse and middle-page opening in all four editions using real PDFium on Android. That check establishes navigation/reuse, not a measured before/after speedup.
- This is a code and automated-test review with sampled visual evidence. Physical-device performance, VoiceOver/TalkBack interaction, actual notification delivery, fluent-language review, and Tajweed correctness remain unverified here. No store-policy or legal determination was performed.
- This section records the original review snapshot. The implementation follow-up below supersedes its software findings; external review and hardware dependencies remain open.

## Findings, ordered by priority

### 1. Release content differs substantially from the development experience — release blocker

Inventory: 118 native lessons (30 Arabic, 30 Sorani, 29 English, 29 Indonesian), 22 rule cards, and 292 questions; **zero approved items in every category**. The release channel intentionally hides drafts. A development demo therefore shows a much fuller learning app than an ordinary release build. The source books and topic/reference flows remain available.

Evidence: `lib/content/content_repository.dart:19`, `:51`, `:82`; fresh audit and `docs/release-audit/README.md`.

Action: review one coherent unit, including its translations, cards, and practice, and run onboarding → lesson → practice → review using the release channel. Keep draft protection. Do not resolve this by simply changing approval flags or shipping preview content without review.

### 2. Ordinary save failures leave live state changed and lack user recovery — high

`StudyController._set` assigns state before `flush`; `flush` calls synchronous disk writes without handling failures. Disk-full or I/O failure can leave a note, bookmark, setting, or answer visible in memory even though it will disappear after restart. A delayed position save can fail through a timer without a useful message. Backup restoration correctly writes before replacing state, but ordinary changes do not have equivalent handling.

Evidence: `lib/features/study/study_state.dart:489`, `:504`; `lib/core/json_store.dart:71`. The isolated failing-store probe confirmed the live weekly goal changed despite the save throwing.

Action: represent unsaved state explicitly, show a localized persistent failure/retry message, and retain dirty state until a successful write. Add disk-full and transient-error tests for notes, quiz answers, and delayed position writes. Avoid silently reporting durable success.

### 3. Disposal with a pending position write uses an invalid Riverpod Ref — medium

The `ref.onDispose` callback calls `flush()`, which reads `storeProvider` through `ref`. An isolated container-disposal probe with a pending `recordPosition` write raised Riverpod's “Cannot use Ref or modify other providers inside life-cycles/selectors” assertion. The callback's intended final save is consequently unreliable. Normal app suspension has a separate lifecycle flush; this finding concerns provider/container teardown or recreation.

Evidence: `lib/features/study/study_state.dart:479`, `:506`.

Action: capture the storage dependency and last serializable state while the provider is alive, and avoid Ref access during disposal. Test teardown before the 600 ms debounce expires and verify the persisted page.

### 4. Front matter keeps an unrelated previous topic — medium

After reading topic t10 and navigating to the cover, `lastRead` becomes page 1 with topic t10 because `recordPosition` falls back to the old topic. Switching languages then maps this as t10 rather than front matter. Home can also describe or reopen the old lesson while the saved PDF position is the cover.

Evidence: `lib/features/study/study_state.dart:627`; `resolveContinue` in `lib/features/reader/reader_screen.dart`. Reproduced with Arabic t10 → page 1 → English continue target.

Action: distinguish the last PDF location from the last native lesson, or clear the topic when the page belongs to none. Test covers, introduction, references, and cross-language continuation.

### 5. Page navigation during PDF loading can be lost — medium

`_goTo` only sends a navigation command when the controller is ready, but updates the page label and saved position regardless. The viewer's initial page remains the original `_initialPage`; `onViewerReady` does not apply a queued target. Moving the slider or using Go to page during a slow load can therefore show one requested page in controls before the viewer opens a different page.

Evidence: `lib/features/reader/reader_screen.dart:107`, `:383`.

Action: retain the latest pending page and apply it once ready, or disable navigation until readiness with clear loading feedback. Test delayed loading plus multiple page selections; the last selection must win.

### 6. Reminder updates can complete out of order; failures are only logged — medium

The synchronization provider launches independent asynchronous cancel/schedule operations. Rapid time/language changes or toggling off while scheduling is pending can allow an older operation to finish last. Initialization also lacks a shared in-flight future. Scheduling failures only reach `debugPrint`, leaving the switch enabled without confirming a scheduled reminder. Timezone discovery is cached for the service lifetime, so a timezone change while the app remains alive is not refreshed.

Evidence: `lib/core/reminder.dart:54`, `:139`; settings opt-in at `lib/features/more/more_screen.dart:442`.

Action: serialize operations or reconcile to the latest requested configuration, share initialization, expose scheduling errors, and refresh timezone on foreground entry. Test delayed/reordered completion, failure, and off-during-schedule; verify actual delivery on hardware.

### 7. Lesson scrolling performs synchronous durable writes — medium performance risk

Every changed visible section calls `recordLessonSection`, which calls `_set` without debounce. This serializes the entire state, flushes the temporary file, copies the backup, and renames on the UI isolate. Crossing several headings during a fling can produce repeated disk work, increasingly expensive with many notes/history entries. This is a source-confirmed hot path; frame impact has not been profiled on hardware.

Evidence: `lib/features/lessons/lesson_screen.dart:76`, `lib/features/study/study_state.dart:666`, `lib/core/json_store.dart:71`.

Action: debounce section-position writes and flush pending state on lifecycle transitions. Profile long lessons with a realistically large learner state on a low-end Android phone.

### 8. Sort-question correctness is hidden from screen readers — medium accessibility gap

Each letter tile excludes descendant semantics and supplies only the letter, selection state, and a return hint. After checking, the correctness icon and color communicate right/wrong visually, but the semantic label/value does not include that result. General tap-target/label tests do not establish that a blind learner receives equivalent feedback.

Evidence: `lib/features/practice/sort_board.dart:101`.

Action: include localized group and correct/incorrect result semantics for checked items, with accessible correction guidance. Verify the complete sorting interaction using TalkBack and VoiceOver.

### 9. PDF error view has no retry action — medium usability gap

The reader error banner only renders a message. A failed document load leaves the learner needing to leave and reopen the book; the reader does not offer an explicit reload action. A clearer distinction between preparing the document and rendering a page would also make slow first opens easier to understand.

Evidence: `lib/features/reader/reader_screen.dart:409`.

Action: add localized Retry and Back controls, preserving the requested edition/page and using the shared document lifecycle safely. Test transient load failure followed by successful retry.

### 10. Production packaging and approval workflow remain incomplete — release blockers / process gaps

- Android release uses the debug signing configuration: `android/app/build.gradle.kts:31`. Configure production signing and validate the actual release artifacts before distribution.
- Rights, translations, expert review, and physical-device checks remain documented dependencies in `docs/release-dependencies.md`; their completion is not established by passing tests.
- Lesson approval is a topic/language flag applied again after source edits; it is not bound to the reviewed source fingerprint (`tools/build_lessons.py:311`). The audit records fingerprints but does not revoke approvals. Before approvals begin, bind approval to a source hash or require explicit re-review when content changes.
- No `.github` workflow is present. No repository CI configuration was identified in this review; external CI may exist. Add automated analysis, tests, content validation, and a release-channel smoke check to the actual delivery pipeline.

## Enhancements worth prioritizing

| Order | Enhancement | Benefit / acceptance check |
|---|---|---|
| 1 | A reviewed first learning unit | A new learner can finish lesson → example → short practice → next step in the actual release build. |
| 2 | Simplify Home's primary action | Existing screenshots show daily activity, editable weekly goal, Continue, progress, and practice competing above the topic list. Make Continue/Start the clear primary action; collapse or move goal editing into Settings. Validate with first-session learner observation. |
| 3 | File-based backup export/import | Keep text backup as a fallback, but offer saving/sharing a backup file and opening it through the platform picker. Show date and data counts before replacement. This reduces clipboard friction for real recovery. |
| 4 | Undo for deleting notes/bookmarks | Current delete buttons mutate immediately. A short Undo action protects accidental deletion, especially for authored notes. |
| 5 | Measured reader performance | Track cold process, first book, saved middle page, reopen, edition switch, and first visible page render in profile/release mode. Measure frame times and memory with large learner data. Current reuse checks do not assert time to a painted page or provide a baseline. |
| 6 | Verified audio for one unit | Tajweed learning benefits from hearing the exact example. Start with reviewed, licensed clips plus repeat and offline controls; expand after teacher/learner evaluation. This requires recordings and review, not placeholder controls. |
| 7 | Clear learning outcomes and delayed recall | Add reviewed “you should be able to…” goals and a brief recap per unit, then use the existing due-review scheduler for later recall. Distinguish reading completion from demonstrated practice performance. |
| 8 | Better support context | Offer app/content version, edition, page/topic/question and optional device details in a user-visible report preview, so loading problems can be reproduced without exposing notes. |

## Suggested delivery sequence

1. Fix saving, pending-write disposal, stale topic mapping, loading-time navigation, and reminder ordering. Add focused regression coverage for each.
2. Add accessible sort feedback, PDF retry, debounced section saving, backup files, and delete Undo. Profile the current reader preparation approach before further caching changes.
3. Complete review for one unit, production signing, release-channel end-to-end verification, and hardware checks. Then pilot the simpler Home and verified audio.

The existing offline storage/recovery, per-language resume, searchable lessons, resumable practice, and multilingual layout tests are useful strengths. The next investment should make those paths dependable and available in production before expanding the feature surface.


## Implementation follow-up — 14 November 2026

Implemented the software fixes from this review: persistent save-failure/retry feedback, disposal-safe pending writes, front-matter topic clearing, queued reader navigation, serialized reminder reconciliation with foreground refresh and error feedback, debounced lesson positions, localized sort-result semantics, and reader retry/back controls. Added backup file import/export with metadata preview, note/bookmark deletion Undo, simpler Home goal presentation, and contextual support details.

Content approvals now bind to reviewed source fingerprints; source changes invalidate approval. Added regression tests and a CI workflow for formatting, analysis, tests, content rebuild integrity and an optional full-content approval gate. Android production packaging requires owner-supplied signing configuration; it no longer falls back to the debug key.

The reviewed first-unit and audio-input plans are prepared in `first-unit-release-plan.md`. Expert approvals, recordings/rights, store credentials and physical-device performance/accessibility evidence cannot be supplied by code changes. No draft content was approved.
