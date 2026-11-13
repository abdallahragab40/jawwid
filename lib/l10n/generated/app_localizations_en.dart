// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navLessons => 'Lessons';

  @override
  String get navRules => 'Rules';

  @override
  String get navPractice => 'Practice';

  @override
  String get navMore => 'More';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionDone => 'Done';

  @override
  String get actionGo => 'Go';

  @override
  String get actionOk => 'OK';

  @override
  String get actionSave => 'Save';

  @override
  String get editionArabic => 'Arabic edition';

  @override
  String get editionKurdish => 'Kurdish edition';

  @override
  String get editionEnglish => 'English edition';

  @override
  String get editionIndonesian => 'Indonesian edition';

  @override
  String pageLabel(String number) {
    return 'Page $number';
  }

  @override
  String pageRangeLabel(String start, String end) {
    return 'Pages $start–$end';
  }

  @override
  String get pageCover => 'Cover';

  @override
  String get pageBackCover => 'Back cover';

  @override
  String get pageUnnumbered => 'Unnumbered page';

  @override
  String get homeContinueTitle => 'Continue reading';

  @override
  String get homeStartTitle => 'Start with the first lesson';

  @override
  String homeContinueOtherEdition(String current, String other) {
    return 'This topic is not in the $current, so it opens in the $other.';
  }

  @override
  String get homeCurriculum => 'Tajweed topics index';

  @override
  String homeCurriculumSummary(String topics, String groups) {
    return '$topics topics in $groups units';
  }

  @override
  String get homeProgressTitle => 'Your progress';

  @override
  String homeLessonsDone(String done, String total) {
    return '$done of $total completed';
  }

  @override
  String homePracticeAccuracy(String percent) {
    return '$percent% correct';
  }

  @override
  String get homePracticeTeaser => 'Test yourself in two minutes';

  @override
  String homeUnitLabel(String number) {
    return 'Unit $number';
  }

  @override
  String get homeSeeAll => 'All topics';

  @override
  String get homeRecentBookmarks => 'Recent bookmarks';

  @override
  String get homeReviewSuggestion => 'Suggested review';

  @override
  String reviewMissed(String correct, String answered, String topic) {
    return 'You answered $correct of $answered correctly in «$topic». Review the lesson, then try again.';
  }

  @override
  String reviewTryPractice(String topic) {
    return 'You have read «$topic». Try its practice questions to consolidate.';
  }

  @override
  String reviewFinishLesson(String topic) {
    return 'You have started «$topic». Finish it and mark it completed when you are done.';
  }

  @override
  String reviewNextLesson(String topic) {
    return 'Next lesson: «$topic».';
  }

  @override
  String get reviewOpenLesson => 'Open lesson';

  @override
  String streakDays(String count) {
    return 'Consecutive study days: $count';
  }

  @override
  String get streakNone => 'Every day is a fresh chance to learn.';

  @override
  String get curriculumTitle => 'Tajweed topics';

  @override
  String curriculumIntro(String count) {
    return '$count topics in the order of the book. Any topic can be opened directly.';
  }

  @override
  String curriculumProgress(String read, String completed, String total) {
    return 'Started: $read · Completed: $completed · of $total';
  }

  @override
  String get curriculumGroupsNote =>
      'Units are a browsing aid added by the app; they are not part of the book.';

  @override
  String get statusNotStarted => 'Not started';

  @override
  String get statusRead => 'Read';

  @override
  String get statusCompleted => 'Completed';

  @override
  String topicNumber(String number) {
    return 'Topic $number';
  }

  @override
  String get topicInTheBook => 'In the book';

  @override
  String topicReadHint(String edition) {
    return 'The original pages of the $edition are shown as printed.';
  }

  @override
  String get topicOpenPages => 'Open lesson pages';

  @override
  String get topicUnavailableTitle => 'Not in this edition';

  @override
  String topicUnavailableInEdition(String topic, String edition) {
    return 'The topic «$topic» is not included in the $edition. You can read it in another edition.';
  }

  @override
  String topicNotInEditionShort(String edition) {
    return 'Not in the $edition';
  }

  @override
  String get topicPartialShort => 'partly covered';

  @override
  String get topicAvailableIn => 'Available in:';

  @override
  String get topicMarkCompleted => 'Mark as completed';

  @override
  String get topicOtherEditions => 'This topic in other editions';

  @override
  String get topicRelatedRules => 'Rule cards';

  @override
  String get topicPractice => 'Practice';

  @override
  String get readerLoading => 'Opening the book…';

  @override
  String get readerError =>
      'This edition could not be opened. Reinstall the app if the problem continues.';

  @override
  String readerPageSemantics(String edition, String page) {
    return 'Book page: $edition, $page. Tap to show or hide reading controls.';
  }

  @override
  String readerPositionOf(String current, String total) {
    return '$current of $total';
  }

  @override
  String get readerAddBookmark => 'Add bookmark';

  @override
  String get readerRemoveBookmark => 'Remove bookmark';

  @override
  String get bookmarkAdded => 'Bookmark added';

  @override
  String get bookmarkRemoved => 'Bookmark removed';

  @override
  String get readerNotes => 'Page notes';

  @override
  String get readerMore => 'More options';

  @override
  String get readerGoToPage => 'Go to page';

  @override
  String get goToPageFieldLabel => 'Printed page number';

  @override
  String goToPageInvalid(String min, String max) {
    return 'Enter a number between $min and $max.';
  }

  @override
  String get readerChooseEdition => 'Read in another edition';

  @override
  String get lessonSourceInfo => 'About this text';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get themeSystem => 'Automatic';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsTextSize => 'Lesson text size';

  @override
  String get textSmaller => 'Smaller text';

  @override
  String get textLarger => 'Larger text';

  @override
  String get readerAppearance => 'Reading appearance';

  @override
  String get readerThemeLight => 'Light';

  @override
  String get readerThemeSepia => 'Sepia';

  @override
  String get readerThemeNight => 'Night';

  @override
  String get readerDimPages => 'Dim the pages';

  @override
  String get readerDimPagesHint =>
      'Lowers brightness evenly without changing any colour.';

  @override
  String get readerColorsNote =>
      'The book’s colours carry teaching meaning, so pages are never inverted or recoloured.';

  @override
  String get readerShowThumbnails => 'Show page thumbnails';

  @override
  String get readerHideThumbnails => 'Hide page thumbnails';

  @override
  String get readerLessonDetails => 'Lesson details';

  @override
  String notesForPage(String page) {
    return 'Notes for $page';
  }

  @override
  String get notesPrivateHint => 'Your notes are saved on this device only.';

  @override
  String get notesHint => 'Write a note…';

  @override
  String get notesAdd => 'Add note';

  @override
  String get notesEdit => 'Edit note';

  @override
  String get notesOpenPage => 'Open page';

  @override
  String get notesEmpty => 'No notes yet. Add one from the reading screen.';

  @override
  String get notesTab => 'Notes';

  @override
  String get bookmarksTab => 'Bookmarks';

  @override
  String get bookmarksEmpty =>
      'No bookmarks yet. Add one from the reading screen.';

  @override
  String get bookmarksAndNotes => 'Bookmarks and notes';

  @override
  String get rulesTitle => 'Rules guide';

  @override
  String get rulesIntro =>
      'Short cards for rules explained in the books, each with a verified example and a link to the lesson.';

  @override
  String get rulesAwaitingReview =>
      'Rule cards are under expert review and will appear once approved. The complete books are available under Lessons.';

  @override
  String get ruleCardTitle => 'Rule card';

  @override
  String ruleFromLesson(String topic) {
    return 'From the lesson: $topic';
  }

  @override
  String get ruleDefinition => 'Definition';

  @override
  String ruleSourceLine(String edition, String page) {
    return 'From the $edition, page $page';
  }

  @override
  String ruleNotInEdition(String edition) {
    return 'The $edition does not cover this point in its own text; the summary above was written for the app.';
  }

  @override
  String get ruleArabicSource => 'Text of the Arabic edition:';

  @override
  String get ruleLetters => 'Letters';

  @override
  String get ruleAllLettersExcept => 'All letters except:';

  @override
  String get ruleExample => 'Example';

  @override
  String get ruleHighlightedLetters => 'The highlighted letters';

  @override
  String get ruleInTheBooks => 'In the books';

  @override
  String get ruleOpenLesson => 'Lesson';

  @override
  String get rulePractice => 'Practise';

  @override
  String quranExcerptFrom(String reference) {
    return 'Excerpt from $reference';
  }

  @override
  String quranExcerptSemantics(
    String text,
    String highlighted,
    String reference,
  ) {
    return 'Qur’anic example: $text. Highlighted letters: $highlighted. $reference';
  }

  @override
  String get previewBadge => 'Development preview';

  @override
  String get previewExplanation =>
      'This supplementary material has not yet been reviewed by an expert and appears only in development builds.';

  @override
  String get makharijTitle => 'Articulation points';

  @override
  String get makharijSubtitle => 'The diagram with all seventeen points';

  @override
  String makharijIntro(String areas, String points) {
    return 'The book presents $areas general areas and $points specific articulation points. Choose a point to see where it is and how it is described.';
  }

  @override
  String get makharijDiagramSource =>
      'Illustration from the book itself. Pinch to zoom.';

  @override
  String get makharijOpenDiagramPage => 'Diagram page';

  @override
  String get makharijAllPoints => 'All articulation points';

  @override
  String get makharijAllAreas => 'All';

  @override
  String get makharijNotMarked =>
      'This place is not marked on the diagram; see the book page for its detailed illustration.';

  @override
  String makharijReadInBook(String edition, String page) {
    return '$edition, page $page';
  }

  @override
  String get practiceTitle => 'Practice';

  @override
  String get practiceIntro =>
      'Supplementary questions written for the app. Their examples come from the books’ tables and are verified.';

  @override
  String get practiceAwaitingReview =>
      'Practice questions are under review and will appear once approved.';

  @override
  String get practiceOverall => 'Your results';

  @override
  String practiceNotTried(String count) {
    return '$count questions — not started yet.';
  }

  @override
  String practicePerformance(String correct, String answered, String total) {
    return 'Correct: $correct of $answered answered · $total in total';
  }

  @override
  String get practiceSeparateFromReading =>
      'Reading progress is recorded separately from practice results.';

  @override
  String get practiceStart => 'Start practice';

  @override
  String get practiceContinue => 'Continue practice';

  @override
  String get practiceByLesson => 'By lesson';

  @override
  String get practiceThisLesson => 'Practise this lesson';

  @override
  String get practiceReset => 'Clear practice results';

  @override
  String get practiceResetConfirm =>
      'Only practice results will be cleared. Bookmarks, notes and reading progress stay as they are.';

  @override
  String quizProgress(String current, String total) {
    return 'Question $current of $total';
  }

  @override
  String get quizSupplementary =>
      'Supplementary question, not from the book’s text.';

  @override
  String get quizIdentifyPrompt =>
      'Which rule applies to the highlighted letters?';

  @override
  String get quizTrueFalsePrompt => 'True or false?';

  @override
  String get quizTrue => 'True';

  @override
  String get quizFalse => 'False';

  @override
  String quizCounts(String value) {
    return '$value counts';
  }

  @override
  String get quizFeedbackCorrect => 'Correct';

  @override
  String get quizFeedbackIncorrect => 'Not quite';

  @override
  String get quizCorrectAnswer => 'correct answer';

  @override
  String get quizYourAnswer => 'your answer';

  @override
  String get quizReviewRule => 'Rule card';

  @override
  String get quizOpenLesson => 'The lesson';

  @override
  String get quizNext => 'Next question';

  @override
  String get quizSeeResult => 'See result';

  @override
  String get quizFinished => 'Well done for practising';

  @override
  String quizScore(String correct, String total) {
    return '$correct of $total correct';
  }

  @override
  String get quizFinishedHint =>
      'Questions you missed will come first next time.';

  @override
  String get practiceQuick => 'Quick practice';

  @override
  String practiceQuickHint(String count) {
    return '$count questions from all lessons, starting with your earlier mistakes.';
  }

  @override
  String practiceMistakes(String count) {
    return 'Review my mistakes ($count)';
  }

  @override
  String get lessonCheckTitle => 'Check your understanding';

  @override
  String lessonCheckBody(String count) {
    return '$count short questions on this lesson';
  }

  @override
  String get lessonCheckStart => 'Start';

  @override
  String get quizLessonCompleted =>
      'Well done! The lesson is marked as completed.';

  @override
  String get quizPracticeAgain => 'Another round';

  @override
  String get quizMissedHeading => 'To review';

  @override
  String get quizPerfect => 'All correct. Excellent!';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search topics, rules and terms';

  @override
  String get searchCoverage =>
      'Searches topic titles, rule names and key terms in all four languages. Page text is searched only in the English and Indonesian editions, because the text of the Arabic and Kurdish editions cannot be extracted reliably.';

  @override
  String get searchLessons => 'Topics';

  @override
  String get searchRules => 'Rule cards';

  @override
  String searchPagesIn(String edition) {
    return 'Pages in the $edition';
  }

  @override
  String get searchPagesNote =>
      'The word was found in the text of these pages; its exact position on the page is not marked.';

  @override
  String searchMatched(String text) {
    return 'Matches: $text';
  }

  @override
  String searchNoResults(String query) {
    return 'No results for «$query»';
  }

  @override
  String get searchNoResultsHint =>
      'Try the name of a rule or part of it, such as ikhfaa, qalqalah or madd.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageHint =>
      'The interface and the book edition change together. Reading positions are kept per edition, and the current lesson carries over to its equivalent.';

  @override
  String get settingsStudy => 'Study';

  @override
  String get settingsStreak => 'Consecutive-days counter';

  @override
  String get settingsStreakHint => 'A quiet option shown on Home.';

  @override
  String get settingsHaptics => 'Haptic feedback';

  @override
  String get settingsHapticsHint =>
      'A light vibration when you switch sections, mark a lesson completed or answer a question.';

  @override
  String get settingsReminder => 'Daily reminder';

  @override
  String get settingsReminderHint =>
      'One notification a day at the time you choose. It is scheduled on your device; nothing is sent anywhere.';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsReminderDenied =>
      'Notifications are not allowed. You can allow them in the device settings, then turn the reminder on.';

  @override
  String get reminderBody =>
      'Time for today\'s Tajweed study. Continue your lesson where you left off.';

  @override
  String get reminderChannel => 'Daily reminder';

  @override
  String get bookTitle => 'The whole book';

  @override
  String bookSubtitle(String edition) {
    return 'Browse every page of the $edition as a reference';
  }

  @override
  String get settingsOffline =>
      'All four books and every feature work offline. No account is needed.';

  @override
  String get lessonRead => 'Read the lesson';

  @override
  String get lessonOriginalPages => 'Original pages';

  @override
  String lessonFromPage(String page) {
    return 'From page $page';
  }

  @override
  String get lessonViewInBook => 'View in the book';

  @override
  String lessonSourceNote(String edition) {
    return 'This text is taken from the pages of the $edition. The original pages remain the reference.';
  }

  @override
  String get lessonUnderReview =>
      'This transcription has not been reviewed yet; where it differs, the original page is authoritative.';

  @override
  String get lessonFigure => 'Illustration from the book; tap to enlarge';

  @override
  String get lessonFullVerse => 'The full verse';

  @override
  String get lessonQuranTapHint => 'Tap to see the full verse';

  @override
  String get lessonContents => 'Lesson contents';

  @override
  String get lessonEnd => 'End of the lesson';

  @override
  String get lessonPrevious => 'Previous lesson';

  @override
  String get lessonNext => 'Next lesson';

  @override
  String get searchInLessons => 'In the lesson text';

  @override
  String get searchCoverageWithLessons =>
      'Searches the lesson text, topic titles, rule names and key terms in all four languages, and the page text of the English and Indonesian editions.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutBody =>
      'A Tajweed study companion built around the “Simplifying Tajweed – Level 2” books. The original books are shown unchanged, surrounded by tools for browsing, review and practice.';

  @override
  String get aboutBooks => 'The books';

  @override
  String aboutAuthor(String name) {
    return 'Author: $name';
  }

  @override
  String aboutTranslator(String name) {
    return 'Translator: $name';
  }

  @override
  String get aboutDistribution =>
      'The book states that “a copyright is available for everyone as long as he keeps them away from adding or removing.”';

  @override
  String get aboutUnchanged =>
      'Pages are shown with nothing added or removed. The bundled copies are only structurally compacted, and their rendering was verified to be pixel-identical to the originals.';

  @override
  String get aboutPrivacyTitle => 'Privacy';

  @override
  String get aboutPrivacy =>
      'The app collects no data and makes no internet connections. Your settings, progress and notes stay on your device only and are deleted with the app.';

  @override
  String get aboutQuranText => 'Qur’anic text';

  @override
  String get aboutTanzil =>
      'Qur’anic examples in the lessons, rule cards and practice are copied verbatim from the Tanzil Project text (Uthmani script, version 1.1, tanzil.net), and their references are checked automatically.';

  @override
  String get aboutSupplementary => 'Supplementary material';

  @override
  String get aboutSupplementaryBody =>
      'The lesson text, rule cards, practice questions and the articulation explorer are built from the books’ text and are reviewed before they are approved for release.';

  @override
  String get aboutFonts => 'Fonts';

  @override
  String get aboutFontsBody =>
      'Noto Naskh Arabic, Noto Sans Arabic, Amiri, Amiri Quran, Literata and Inter, all under the SIL Open Font License 1.1. The original books’ fonts are not distributed with the app.';

  @override
  String get aboutLicenses => 'Licences';

  @override
  String aboutContentVersion(String version) {
    return 'Content version: $version';
  }
}
