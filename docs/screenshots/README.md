# Screenshots (iPhone 17 Pro simulator, real PDFium rendering)

Captured by `integration_test/screenshots_test.dart` with a small study history (two lessons completed, a bookmark, two practice answers), in the development-preview content channel.

| Screen | Arabic | Kurdish | English | Indonesian |
|---|---|---|---|---|
| First launch (welcome) | `ar_00_first_launch.png` | — | — | — |
| Home | `ar_01_home.png` | `ckb_01_home.png` | `en_01_home.png` | `id_01_home.png` |
| Curriculum | `ar_02_lessons.png` | `ckb_02_lessons.png` | `en_02_lessons.png` | `id_02_lessons.png` |
| Topic 10 | `ar_03_topic.png` | `ckb_03_topic.png` | `en_03_topic.png` | `id_03_topic.png` |
| Original pages (reader) | `ar_04_reader.png` | `ckb_04_reader.png` | `en_04_reader.png` | `id_04_reader.png` |
| Rule card (Ikhfaa) | `ar_05_rule_card.png` | `ckb_05_rule_card.png` | `en_05_rule_card.png` | `id_05_rule_card.png` |
| Practice question | `ar_06_practice.png` | `ckb_06_practice.png` | `en_06_practice.png` | `id_06_practice.png` |
| Practice feedback | `ar_07_feedback.png` | — | — | — |
| Articulation explorer | `ar_08_makharij.png` | `ckb_08_makharij.png` | `en_08_makharij.png` | `id_08_makharij.png` |
| Search | `ar_09_search.png` | `ckb_09_search.png` | `en_09_search.png` | `id_09_search.png` |
| Topic absent from edition | — | — | `en_10_topic_not_in_edition.png` | — |
| Native lesson (topic 10, opening) | `ar_11_lesson.png` | `ckb_11_lesson.png` | `en_11_lesson.png` | `id_11_lesson.png` |
| Lesson figure cropped from the book (topic 8) | `ar_12_lesson_figure.png` | `ckb_12_lesson_figure.png` | `en_12_lesson_figure.png` | `id_12_lesson_figure.png` |
| Lesson table rebuilt natively (topic 26) | `ar_13_lesson_table.png` | `ckb_13_lesson_table.png` | `en_13_lesson_table.png` | `id_13_lesson_table.png` |
| Sort question | `ar_15_sort.png` | `ckb_15_sort.png` | `en_15_sort.png` | `id_15_sort.png` |
| Sort question, letters being placed | `ar_16_sort_placing.png` | `ckb_16_sort_placing.png` | `en_16_sort_placing.png` | `id_16_sort_placing.png` |
| Lesson contents sheet (topic 26) | `ar_14_lesson_contents.png` | `ckb_14_lesson_contents.png` | `en_14_lesson_contents.png` | `id_14_lesson_contents.png` |

Reader themes (Arabic edition, page 46): `ar_reader_theme_light.png`, `ar_reader_theme_sepia.png`, `ar_reader_theme_night.png`, `ar_reader_theme_night_dimmed.png`.

The practice-feedback screenshot is taken only where the first question's options include the tapped answer, which happened in Arabic.

Dark theme (`integration_test/dark_screenshots_test.dart`), Arabic and English: `dark_<lang>_home.png`, `dark_<lang>_lessons.png`, `dark_<lang>_practice_tab.png`, `dark_<lang>_lesson.png`, `dark_<lang>_rule_card.png`, `dark_<lang>_quiz_feedback.png`.

## Current product journeys — 2026-11-14

`integration_test/product_journeys_test.dart` captures 25 preview-channel images on the iPhone 17 Pro simulator with isolated in-memory study data: `update_<language>_<theme>_<screen>.png`. Languages: ar, ckb, en, id in light; en additionally in dark. Screens: `home`, `comparison`, `backup`, `settings`, `lesson_contents`. These show the current daily goals, comparison, portability, preferences and section-note entry points. They are development evidence, not store screenshots from approved release content.

The final capture pass was inspected after correcting selected-chip contrast and waiting explicitly for route transitions.
