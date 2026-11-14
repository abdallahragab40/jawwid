# First reviewed learning unit

Use Foundations of Tajweed (`g1`: `t01`, `t02`, `t03`) as the first candidate path. This is a scope proposal, not approval. Keep every item draft until the named reviewers finish.

For each language (Arabic, Sorani, English, Indonesian):

1. A qualified reviewer checks the three native lesson sources against the original pages, resolves applicable `content_src/lessons/REVIEW_NOTES.md` entries, and reviews the source-heading outcomes. Add authored objectives/recaps only when the teacher supplies and approves them.
2. Record the exact source SHA-256, reviewer, and date using `tools/approve_lesson.py`. The command requires the hash of the source actually reviewed. Legacy topic-only flags no longer approve a changed file.
3. Rebuild with `sh tools/build_all.sh`, then generate `python3 -I tools/make_review_pack.py`. The pack includes source hashes. Review the questions/cards for these topics, including every answer option and translation, before applying the completed CSV through `tools/apply_review.py`.
4. Rebuild, check the audit, and run the complete learner path with `--dart-define=RATTIL_CONTENT_CHANNEL=release`. Confirm Start/Continue → lesson → source page → short practice → correct feedback → next lesson → later review. Check the real release-visible pool has enough questions for the proposed session and all identify options have approved cards.
5. Run this path on Android and iPhone with enlarged text and a screen reader. Capture release-channel screenshots; do not reuse preview screenshots as evidence of released content.

The existing approval commands do not grant rights or validate distribution permissions. The separate dependencies in `release-dependencies.md` remain open. No item has been approved by this implementation.

## Audio pilot input

For this same unit, a qualified teacher should select a small set of source-linked recitation examples. Each delivered clip needs: a stable clip ID; lesson/rule ID; verse and exact excerpt; reciter name; written redistribution permission/license; reviewer name/date; local filename; SHA-256; duration; and any repetition/teaching notes. Choose compressed mono files after listening tests, then measure the total offline size.

Acceptance: the example and recording agree, start/end trimming preserves pronunciation, playback and repeat work offline, interruption/headphones/phone calls behave correctly, screen-reader controls identify the example, and the reviewer approves each clip. Do not add silent files, synthetic recitation, or inactive playback buttons to represent missing recordings.

Recordings and reviewed authored objectives were not supplied; their runtime features remain dependent on those inputs. Existing lessons and source-heading outlines continue working.
