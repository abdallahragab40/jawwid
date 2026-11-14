# Jawwid product review and roadmap

Reviewed 13 November 2026. Scope: repository implementation, bundled content, existing simulator screenshots, release documentation, static analysis and automated tests. This is not a new hands-on device audit or a user research study. Recommendations are hypotheses to validate. “Adoption” is interpreted as helping new users start and return.

## Product direction

Build an offline Tajweed learning companion with a clear daily journey: learn one concept, try examples, revisit it later, and apply it aloud. Preserve the calm emerald/paper visual identity, original-book references, four-language support, optional reminders, and account-free use.

The strongest next investment is a complete, reviewed learning journey. More screens alone will not establish engagement. Audio is the most natural substantial expansion because the subject concerns recitation; quizzes alone cannot establish pronunciation competence.

## Verified baseline

- 30 topics in eight groups; Arabic, Sorani, English and Indonesian editions.
- 118 native lessons: 30 Arabic, 30 Sorani, 29 English and 29 Indonesian. Topic t07 is absent in the latter two editions.
- All 118 lessons, all 22 rule cards and all 292 questions are currently draft. `content_src/lessons/reviewed.json` is absent. Default release filtering therefore exposes none of these native lessons/cards/questions. Source books and curriculum remain available.
- Five bottom tabs remain present in release, including Rules and Practice with awaiting-review states.
- Existing engagement features include continue reading, suggested next activity, ten-question practice, three-question lesson checks, mistake review, unit celebrations, optional streaks and configurable local reminders.
- Bookmarks, notes, per-edition PDF position and practice history are local. Storage has atomic writes, backup recovery and migrations. There is no user-facing export/import or account sync.
- Native lessons track the opened topic, but do not persist the current section/block. PDF page position is persisted.
- Practice selection prioritizes last-wrong, then unseen, then previously correct questions. It does not use elapsed time to schedule reviews, although answer timestamps exist.
- A lesson opening counts as a study day and marks reading progress; this should not be interpreted as proof of comprehension.
- `flutter analyze`: passed with no issues. `flutter test --reporter compact`: 115 tests passed during this review. Existing validation documentation contains older counts and should be refreshed.

## Screen and journey review

| Area | Current strengths | Recommended enhancement | Priority |
|---|---|---|---|
| Welcome | Clear benefits, native language names, no account barrier | Move language choices higher; retain Arabic default unless product policy changes. Offer a skippable beginner/revision choice and open a useful first activity directly. | P1 |
| Home | Strong continue card, visible progress, practice and units | Put one “Today: about 5 minutes” action first; follow with exact resume and due review. Reduce competition between continue, suggested review and unit choices. | P1 |
| Curriculum | Structured, unlocked units and completion status | Add outcomes and approximate effort; distinguish available lessons from absent/unreviewed material. Make recommended next steps edition-aware. | P1 |
| Native lessons | Readable typography, section navigation, exact examples, source links | Persist section anchors; add reviewed short summaries and checks at natural section boundaries. Keep original transcription identifiable. | P1 |
| PDF reader | Original reference, edition mapping, saved pages, reader themes | Keep as reference; improve movement between a lesson section and its original page. Verify memory, zoom and recovery on low-end hardware. | P1 |
| Rule cards | Concise reference and topic grouping | Add favorites, related-rule comparisons and “practice this distinction.” Expose only approved cards. | P2 |
| Makharij | Interactive diagram and articulation-point descriptions | Link directly from relevant lesson examples; add verified audio and simple articulator animations later. | P2 |
| Practice | Mixed sessions, random options, explanations, mistakes mode, sort exercises | Offer 3/5/10-question sessions, learned-topics default with optional all-topics practice, spaced reviews and session recovery. | P1 |
| Progress | Reading and quiz performance are already separate | Show completion, latest-answer correctness and delayed recall separately. Avoid describing recognition quizzes as recitation mastery. | P1 |
| Search | Normalization, lesson snippets, topic/rule/book results | Add useful empty-state suggestions and recent searches; make cross-language book results explicit. Arabic/Sorani PDF full-text coverage differs from native lesson search. | P2 |
| Notes/bookmarks | Offline and durable | Add lesson-section anchors, filtering and portable backup. Retain PDF page links. | P1–P2 |
| Settings | Language, themes, text sizing, haptics, reminders, streak options | Offer reminder setup after a successful session; keep it optional. Add weekly goals and a clear data export/restore path. | P1 |
| Feedback/support | Email composition with copy fallback; external payment options | Add “report this content” with topic/question ID, edition and app version prefilled. Review payment presentation for each target store before submission. | P0–P1 |

Visual observations from sampled existing screenshots: the identity is coherent and readable; Home uses substantial space for progress cards before later recommendations, and long lesson titles truncate in the toolbar and section bar. Preserve large tap targets, but make the full lesson title accessible and move the next useful action higher. Validate changes in RTL, dark mode and enlarged text rather than compressing all typography.

## Fix the release experience first — P0

1. Establish a content approval matrix by topic, language and item type. Verified: lesson approval input is already language-specific (`reviewed.get(lang, [])` in `tools/build_lessons.py`), so one translation's approval does not approve the others. Store reviewer, date and source revision, with approval invalidated or flagged after relevant edits.
2. Complete a small coherent reviewed learning path before broad promotion. Include lessons, matching rule cards, enough varied questions, explanations and all advertised translations. Do not bypass release filtering to make preview features appear.
3. Make release navigation useful: avoid primary tabs that contain only an awaiting-review sentence. If shipping a staged curriculum, explain availability and offer a real next action. Test the actual release channel and generate store screenshots from it.
4. Make recommended next lessons and progress totals edition-aware. Home's next-lesson and unit selection currently iterate all topics without excluding topics absent from the selected edition; English/Indonesian can be sent to the t07 unavailable overview. Keep canonical full-course progress only if clearly labelled, alongside achievable edition progress.
5. Close the repository's documented publication dependencies: rights/permissions, expert and language review, signing/ownership, hardware accessibility, notification delivery and low-end performance. These are documented outstanding items, not an independent legal determination.
6. Review the existing InstaPay/wallet support screen against current store rules for the intended countries and business model. Do not assume a developer tip, nonprofit donation and personal gift are interchangeable. Apple explicitly addresses developer tipping and fundraising in its review guidelines: https://developer.apple.com/app-store/review/guidelines/ . This review does not establish store approval or a policy violation.

Acceptance: every advertised release journey works using reviewed content; no primary navigation dead ends; unavailable edition topics do not become the recommended next task; screenshots match shipped behavior.

## First improvement cycle — P1

Suggested order for one Flutter developer; estimates are rough engineering effort, exclude content review, and are not commitments.

| Work item | Estimate | Acceptance evidence |
|---|---|---|
| Exact lesson resume + edition-aware recommendations | 3–5 days | Reopening after process restart restores a stable section in the selected language; removed sections fall back safely; EN/ID recommendations skip t07. |
| Focused daily session and optional learner goal | 4–6 days | User can start a short lesson/check/review sequence from Home; skip onboarding choices; finish with a clear next step. |
| Short practice and spaced review | 5–8 days | Due items use a controllable clock; answer history survives restart; practice defaults to relevant learned material; wrong answers return sooner. |
| Honest progress and weekly summary | 2–4 days | Completion and quiz retention are separate; opening a page alone does not count as completing a daily learning goal. |
| Export/import and contextual feedback | 3–5 days | Round trip preserves notes/progress; malformed/newer files are rejected safely; replacement or merging is explicit; feedback contains no private notes by default. |
| Release/device regression pass | 3–5 days | RTL, all four languages, large text, TalkBack/VoiceOver, offline restart, notification tap and low-end reader behavior checked. |

Build on existing `StudyController`, versioned `JsonStore`, `buildSession` and content review tooling. Prefer a small deterministic scheduling service over introducing a backend. Store section identifiers with content version handling rather than raw scroll pixels alone. Extend practice records with next-review time and successful delayed reviews; do not call a single correct answer mastery.

Spaced retrieval has research support, but a particular interval sequence must be evaluated with this audience. Start with an understandable schedule, such as 1/3/7/14 days after successful reviews, and treat those numbers as a prototype choice. Source: Carpenter et al., “The science of effective learning with spacing and retrieval practice”: https://doi.org/10.1038/s44159-022-00089-1 .

## Adoption and engagement experiments

- First-session success: give users one practical, reviewed concept and a short check before asking about reminders. Prototype target: at least 8 of 10 observed testers complete it without help. This is a proposed usability gate, not a measured baseline.
- Return value: “Review two concepts from last time” and exact section resume. Use weekly consistency goals; keep streaks optional and avoid guilt after a missed day.
- Small pilot: recruit approximately 12–20 learners across supported languages and experience levels, plus Tajweed teachers. Observe first use, then follow up after one and two weeks. This sample finds usability issues; it cannot establish market-wide retention.
- Track activation (first meaningful lesson/check completed), D7 return (learning activity on day seven among the eligible cohort), weekly learning days, due-review completion and delayed quiz accuracy. Include denominators and segment by language/experience where the sample supports it.
- Preserve the current no-tracking promise: begin with consented interviews, diaries and user-initiated export of minimal pilot summaries. Device-local counters do not provide aggregate retention automatically. Remote analytics would be a separate product/privacy decision.
- Distribution experiment: a reviewed seven-day starter curriculum shared through cooperating teachers and learning groups; localized store descriptions show the actual available journey and offline benefits. Test one channel at a time.
- Add optional sharing of a lesson reference or learning milestone after publication links exist. Keep personal scores/notes private by default. Never gate content on sharing or ratings.
- Positioning hypothesis: “Learn and review Tajweed in small steps, offline, with original-book references.” Validate comprehension with learners instead of making unverified superiority claims about other apps.

## Expansion sequence

| Expansion | Value | Dependencies and scope | Recommendation |
|---|---|---|---|
| Verified example audio | Connects written rules to sound | Qualified reciter, recording rights, pronunciation review, clip metadata, repeat controls and offline size budget | First major expansion; pilot one unit. |
| Listen, record, compare | Supports deliberate recitation practice | Audio foundation, microphone consent, private local storage and deletion | Next; initially self-comparison with clear teacher guidance. |
| Beginner bridge | Helps learners who cannot yet follow the Level-2 source | New reviewed objectives, Arabic-letter prerequisites and translations | Pilot after testing beginner demand. |
| Rule comparison and listening exercises | Develops discrimination beyond memorized options | Reviewed contrast examples, question variety and verified audio | Build alongside the first audio unit. |
| Teacher companion | Assignments and targeted human feedback | First test local assignment codes and user-shared progress; accounts/backend only for proven needs | Small partner pilot before a full portal. |
| Optional backup/sync | Multi-device continuity | Export/import first; then authentication, conflict handling, deletion and revised privacy model | Later, optional; offline use remains complete. |
| Additional levels/languages | Broadens reach | Author permissions, reviewer capacity and sustainable updates | Expand only after the current learning loop works. |
| AI pronunciation assessment | Potential feedback at scale | Expert-labelled evaluation, error analysis, diverse speakers/devices and clear uncertainty | Research track, not a near-term release promise. |

Avoid starting with public leaderboards, an unmoderated social feed, mandatory accounts or broad AI religious answers. These add substantial product and operational work before the core journey is validated. A completion certificate, if added, should describe course participation and never imply qualified recitation certification.

## Delivery sequence and decision gates

1. Release readiness and first reviewed path: content review runs in parallel with edition/resume fixes. Publication waits on the relevant external approvals; no reliable calendar estimate is possible yet.
2. Guided learning loop: deliver daily session, relevant short practice and spaced review in small changes. Add focused tests for scheduling, persistence, content availability and navigation.
3. Pilot and revise: measure first-session completion and return behavior using the agreed privacy-preserving method. Fix observed abandonment before adding another large feature.
4. One-unit audio pilot: compare comprehension and practical usefulness with learners and a teacher. Expand recordings only after the workflow is useful and sustainable.

Recommended first implementation batch: exact lesson resume, edition-aware next steps/progress, and useful release-channel navigation. These solve concrete existing friction while expert content review proceeds.

## Evidence map

- Content visibility/counts: `lib/content/content_repository.dart`, `assets/content/lessons_*.json`, `assets/content/rules.json`, `assets/content/quiz.json`.
- Entry/navigation: `lib/features/welcome/welcome_screen.dart`, `lib/features/home/home_screen.dart`, `lib/app/shell.dart`, `lib/app/routes.dart`.
- Resume/progress: `lib/features/lessons/lesson_screen.dart`, `lib/features/study/study_state.dart`, `lib/features/reader/reader_screen.dart`.
- Practice: `lib/features/practice/session.dart`, `practice_screen.dart`, `quiz_screen.dart`.
- Reference/discovery: curriculum, rules, makharij and search feature directories.
- Storage/preferences/support: `lib/core/json_store.dart`, `lib/features/more/`, `docs/privacy.md`.
- Release constraints: `docs/release-dependencies.md`, `docs/validation.md`.
- Sampled visual evidence: `docs/screenshots/ar_01_home.png`, `en_11_lesson.png`, `ar_06_practice.png`. These are existing preview screenshots, not fresh release captures.

## Implementation progress

Following the review, the first implementation batches now include:

- Per-language native lesson section resume, invalidated by a deterministic content fingerprint.
- Edition-aware Home recommendations, unit progress and Home completion totals.
- A short daily activity entry on Home and configurable weekly goals. Weekly learning days count answers and explicit lesson completion; legacy reading/streak days remain separate. Weeks start Monday.
- 3/5/10-question practice, a learned-topics default with an all-topics switch (new learners can explore the full pool), and due-only reviews.
- Local review scheduling at 1/3/7/14 days after successful delayed answers; wrong answers restart at one day. Immediate repeat answers do not advance the interval. Existing mistake-only practice is still available immediately.
- Useful original-book links from release Rules/Practice awaiting-review screens.
- Explicit clipboard export/import with a versioned backup envelope, validation and replacement confirmation. Restore preserves this device's notification opt-in. This is a portable text backup, not automatic cloud sync or a file picker.
- Contextual feedback from lessons and questions. Reports prefill the content identifier and language; the learner chooses whether to send through their mail app.
- Interrupted quiz recovery from Practice, preserving question/option order, score, missed questions and lesson context. Answers and the next checkpoint are saved atomically; completing or resetting practice clears the checkpoint. Starting a fresh session replaces the previous checkpoint. Unsubmitted sort placements are not checkpoints.
- Saved-session validation against visible questions, content version, question content fingerprint and valid option permutations. Malformed checkpoints are discarded without dropping the rest of the learner state.
- Per-language recent search history (at most eight queries), saved on submission or result selection, with clear-history control and topic suggestions when search is empty.
- Full lesson titles available through toolbar tooltips.
- Favorite rule cards persist locally and appear at the top of Rules, respecting content-review visibility.
- Lesson-section notes can be added from Contents or the lesson end. Notes preserve their source page and section heading, survive export/import and edits, and reopen the matching section in the same edition. Changed anchors and other-language notes retain the source PDF link.
- Shared note editor owns and disposes its text controller with its dialog route.
- App relaunched and hot-restarted successfully on the iPhone 17 Pro simulator; the current Arabic Home screen was visually inspected. This does not replace hardware or full-screen visual validation.
- Rule comparison is reachable from Rules and individual cards. It compares two distinct visible cards using existing definitions, letters, examples, explanations and source links, with per-rule practice. It stacks on narrow screens or enlarged text and uses columns on wider screens. Draft cards remain excluded from release.
- Optional learning preference (step by step, revision, explore) persists in learner data and backups and is editable in Settings. Home prioritizes resumable practice, then the selected activity and available content; revision falls back to learning when no reviewed questions are available.
- Welcome language choices appear earlier; Start learning stays visible while optional choices scroll. The Arabic default and unrestricted lesson access are retained.
- Comparison rendering was visually checked with bundled fonts in Arabic and English; all four languages have small-phone/enlarged-text layout tests.
- Source-derived lesson review outlines and approximate reading-time labels, with edition-aware curriculum progress and delayed-recall question counts.
- Release identify questions require all answer cards to be visible; backup imports validate edition/page references before replacing data.
- Read-only release audit and source-fingerprint matrix, plus a learner-pilot guide and blank private-use log template.
- Startup displays loading/error/retry UI in four languages, times out a stalled loader after 30 seconds and preserves unreadable/newer saved files. Typed corruption can recover from the last good backup; its first recovery save preserves that backup.
- Pending progress writes flush when the app leaves the foreground. Streak/weekly date labels and reminder scheduling handle calendar-day/DST boundaries.
- Unreadable startup state can be repaired through confirmed manual backup restoration after assets load; the recovery form hides export and reboots the app session after a successful save. Newer-schema data still requires an update. Restore writes reach disk before replacing live progress; cancellation/failure tests preserve prior files/state.
- New interface strings in all four languages; fluent-language review remains needed for authored translations.

Core product code and research handoff preparation are delivered; see `completion-and-handoff.md`. Remaining dependencies are human-reviewed authored lesson summaries/outcomes, full hardware/visual validation, actual pilot recruitment/measurement, store/rights/signing evidence, approved content and verified audio. Teacher/cloud/AI extensions remain future options, not functioning services.

The baseline inventory and test count above describe the original review snapshot, before these changes.

Latest implementation update: 14 November 2026.
