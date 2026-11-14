# Jawwid implementation and handoff

Updated 14 November 2026. This records delivered software and explicit dependencies; it is not store-release approval.

## Delivered product work

| Area | Result |
|---|---|
| Return to learning | Native lesson section resume per language/content revision; interrupted quizzes recover order, score and next unanswered question. |
| Daily activity | Preference for guided learning/revision/exploration; resumable practice first, due review and edition-aware next steps. |
| Weekly goals | Configurable goal; answer/completion days separated from page-open streak days. |
| Practice | 3/5/10-question sessions, relevant learned-topic pool, all-topic switch, mistakes, scheduled review and delayed-recall question count. |
| Progress | Home/unit/curriculum totals exclude unavailable edition topics while canonical topics remain discoverable. |
| Lesson scope | Source-heading review outline, Contents navigation and approximate reading effort. No new expert-authored teaching claims are silently approved. |
| Study tools | Favorite rules, adaptive two-rule comparison, section notes with source-page fallback, shared note editor. |
| Discovery | Multilingual search suggestions and bounded, clearable per-language recent history. |
| Reliability | Loading/retry startup, typed backup recovery without overwriting the good backup on first recovery save, newer-schema protection, lifecycle progress flush and DST-safe date calculations. |
| Portability | Versioned clipboard backup/restore with confirmation and page validation; disk-first commit protects live progress on write failure. Startup can restore unreadable state through a restore-only form. Normal restore retains the device reminder preference; startup recovery defaults it off. |
| Feedback | Lesson/question identifier and language can be prefilled into learner-controlled email feedback. |
| Release behavior | Draft filtering retained; empty Rules/Practice provide source-book actions; identify questions wait for visible answer cards. |
| Validation | 177 Flutter tests, 6 content-tool tests, a passing simulator journey with 25 fresh screenshots, Android debug/release builds and release-emulator Home smoke; see `validation.md` for limits. |
| Review handoff | `release-audit/` records current status and source fingerprints; existing expert-review tools remain authoritative. |
| Adoption | `pilot-guide.md` and a blank private-use log template prepare supervised usability/return research. No recruitment or pilot results are claimed. |

## Human/external dependencies

| Dependency | Required input/evidence | Next prepared step |
|---|---|---|
| Content accuracy | Qualified Tajweed reviewers and fluent language reviewers | Review `docs/review/`, lesson source notes and `release-audit/review-matrix.csv`; approve through existing source workflows. |
| Derived teaching outcomes/summaries | Reviewed authored material, with translation and source attribution | Current source-heading outlines work; add authored summaries only with reviewed content metadata. |
| Distribution rights | Author/translator/font/excerpt permissions identified in `release-dependencies.md` | The draft permission request is ready in `permission-request.md`; the owner sends it and records the response. |
| Store identity/signing | Owner-controlled application identifier, Android release keystore and iOS team | Configure locally, build signed store artifacts, then update screenshots from the real release channel. Production builds now require owner-supplied keys; debug signing is no longer a release fallback. |
| Store listing/payment review | Intended markets, business model and current platform review evidence | Review the existing voluntary support screen and final store forms before upload. |
| Hardware checks | Android/iPhone access, screen-reader users, notification delivery/reboot and low-end performance evidence | Execute the checks documented in `release-dependencies.md`; simulator/widget tests do not replace them. |
| Adoption validation | Consenting pilot participants and teacher partners | Run `pilot-guide.md`; keep identifiable/private research data outside Git. |
| Audio expansion | Licensed verified recordings and a qualified review process | Pilot one unit with playback/repeat before expanding recording/self-comparison. |
| Teacher/cloud features | Validated demand, account/privacy model, service ownership and operating budget | These are future product options rather than implemented services. |
| AI recitation assessment | Expert-labelled evaluation and acceptable error criteria | Research stage; no automated religious/recitation certification is presented. |

## Repeatable checks

```sh
flutter analyze
flutter test
python3 -I -m unittest discover -s tools/tests -v
python3 -I tools/release_audit.py
flutter build apk --release --target-platform android-arm64
```

`python3 -I tools/release_audit.py --require-reviewed` is an optional full-content readiness gate and is expected to fail while the current 432 items remain draft. A generated audit never grants approval or verifies legal/store/hardware readiness. Partial launches require an explicitly reviewed, useful learning path and accurate listings; this audit does not choose one automatically.

No existing user data was reset, no content was marked reviewed, and no store upload or external invitation was performed as part of this implementation.
