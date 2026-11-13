# Store artwork (drafts)

Rendered by `test/rendering/store_art_test.dart` with the app's own fonts and colours:

* `feature_graphic_ar.png`, `feature_graphic_en.png` — Google Play feature graphic (1024 × 500).
* `screenshot_<lang>_1…6.png` — captioned store screenshots (1290 × 2796; accepted by Google Play and as App Store 6.7"/6.9" screenshots): home, a lesson, practice, a sort drill, the articulation explorer, the original book pages.

**These are drafts.** They are built from `docs/screenshots/`, which are taken in the development-preview channel and show the "Development preview" badge. After the content review, retake the screenshots and regenerate:

```sh
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots_test.dart -d <iPhone simulator>
flutter test test/rendering/store_art_test.dart --update-goldens
```

Kurdish and Indonesian store listings can reuse the English or Arabic images, or add a language to `_shots` in the test.

Store listing name suggestion: «جَوِّد – تبسيط التجويد» / «Jawwid – Simplifying Tajweed».
