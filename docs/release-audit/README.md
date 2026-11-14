# Release content audit

Content inventory only; rights, signing, store policies and hardware checks require separate evidence.

Generated with `python3 -I tools/release_audit.py`. This is a snapshot, not approval.

| Content | Available | Reviewed |
|---|---:|---:|
| Lessons (ar) | 30 | 0 |
| Lessons (ckb) | 30 | 0 |
| Lessons (en) | 29 | 0 |
| Lessons (id) | 29 | 0 |
| Rules | 22 | 0 |
| Questions | 292 | 0 |

Draft items: 432.
Missing native lessons: 0.
Reviewed questions blocked by unavailable answer cards: 0.

Lesson approval is language-specific in `content_src/lessons/reviewed.json`.
Rule/question approval applies to the whole multilingual item. Use the existing expert review pack to review every translation.
The CSV records current status and source fingerprints; editing it does not approve content.
Re-run after source changes. Existing approval flags are not automatically revoked by this report; reviewers must compare the fingerprints.

See `docs/release-dependencies.md` for outstanding rights, expert review, signing and hardware dependencies.
