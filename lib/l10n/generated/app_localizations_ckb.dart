// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Central Kurdish (`ckb`).
class AppLocalizationsCkb extends AppLocalizations {
  AppLocalizationsCkb([String locale = 'ckb']) : super(locale);

  @override
  String get navHome => 'سەرەکی';

  @override
  String get navLessons => 'وانەکان';

  @override
  String get navRules => 'ڕێساکان';

  @override
  String get navPractice => 'ڕاهێنان';

  @override
  String get navMore => 'زیاتر';

  @override
  String get actionCancel => 'پاشگەزبوونەوە';

  @override
  String get actionDelete => 'سڕینەوە';

  @override
  String get actionDone => 'تەواو';

  @override
  String get actionGo => 'بڕۆ';

  @override
  String get actionOk => 'باشە';

  @override
  String get actionSave => 'پاشەکەوتکردن';

  @override
  String get editionArabic => 'وەشانی عەرەبی';

  @override
  String get editionKurdish => 'وەشانی کوردی';

  @override
  String get editionEnglish => 'وەشانی ئینگلیزی';

  @override
  String get editionIndonesian => 'وەشانی ئیندۆنیزی';

  @override
  String pageLabel(String number) {
    return 'لاپەڕە $number';
  }

  @override
  String pageRangeLabel(String start, String end) {
    return 'لاپەڕە $start–$end';
  }

  @override
  String get pageCover => 'بەرگ';

  @override
  String get pageBackCover => 'بەرگی دواوە';

  @override
  String get pageUnnumbered => 'لاپەڕەی بێ ژمارە';

  @override
  String get homeContinueTitle => 'بەردەوام بە لە خوێندنەوە';

  @override
  String get homeStartTitle => 'بە وانەی یەکەم دەست پێبکە';

  @override
  String homeContinueOtherEdition(String current, String other) {
    return 'ئەم بابەتە لە $currentدا نییە، بۆیە لە $otherدا دەکرێتەوە.';
  }

  @override
  String get homeCurriculum => 'پێڕستی بابەتەکانی تەجوید';

  @override
  String homeCurriculumSummary(String topics, String groups) {
    return '$topics بابەت لە $groups بەشدا';
  }

  @override
  String get homeRecentBookmarks => 'دوایین نیشانەکان';

  @override
  String get homeReviewSuggestion => 'پێشنیاری پێداچوونەوە';

  @override
  String reviewMissed(String correct, String answered, String topic) {
    return 'لە پرسیارەکانی «$topic» $correct لە $answered دروست بوون. پێداچوونەوە بە وانەکەدا بکە و دووبارە هەوڵ بدەرەوە.';
  }

  @override
  String reviewTryPractice(String topic) {
    return '«$topic»ت خوێندەوە. پرسیارەکانی تاقی بکەرەوە بۆ جێگیرکردن.';
  }

  @override
  String reviewFinishLesson(String topic) {
    return 'دەستت بە «$topic» کردووە. تەواوی بکە و کاتێک تەواو بوو وەک تەواوکراو دیاری بکە.';
  }

  @override
  String reviewNextLesson(String topic) {
    return 'وانەی داهاتوو: «$topic».';
  }

  @override
  String get reviewOpenLesson => 'وانەکە بکەرەوە';

  @override
  String streakDays(String count) {
    return 'ڕۆژانی خوێندنی یەک لەدوای یەک: $count';
  }

  @override
  String get streakNone => 'هەموو ڕۆژێک دەرفەتێکی نوێیە بۆ فێربوون.';

  @override
  String get curriculumTitle => 'بابەتەکانی تەجوید';

  @override
  String curriculumIntro(String count) {
    return 'بابەتەکان ($count) بە ڕیزبەندی کتێبەکەن، دەتوانیت ڕاستەوخۆ هەر بابەتێک بکەیتەوە.';
  }

  @override
  String curriculumProgress(String read, String completed, String total) {
    return 'دەستپێکراو: $read · تەواوکراو: $completed · لە $total';
  }

  @override
  String get curriculumGroupsNote =>
      'دابەشکردنی بەشەکان تەنها بۆ ئاسانکاری گەڕانە و لە کتێبەکەدا نییە.';

  @override
  String get statusNotStarted => 'دەستی پێنەکراوە';

  @override
  String get statusRead => 'خوێندراوەتەوە';

  @override
  String get statusCompleted => 'تەواوکراو';

  @override
  String topicNumber(String number) {
    return 'بابەتی $number';
  }

  @override
  String get topicInTheBook => 'لە کتێبەکەدا';

  @override
  String topicReadHint(String edition) {
    return 'لاپەڕە ڕەسەنەکانی $edition وەک خۆیان پیشان دەدرێن.';
  }

  @override
  String get topicOpenPages => 'لاپەڕەکانی وانەکە بکەرەوە';

  @override
  String get topicUnavailableTitle => 'لەم وەشانەدا بەردەست نییە';

  @override
  String topicUnavailableInEdition(String topic, String edition) {
    return 'بابەتی «$topic» لە $editionدا نییە. دەتوانیت لە وەشانێکی تردا بیخوێنیتەوە.';
  }

  @override
  String topicNotInEditionShort(String edition) {
    return 'لە $editionدا نییە';
  }

  @override
  String get topicPartialShort => 'بەشێکی هەیە';

  @override
  String get topicAvailableIn => 'بەردەستە لە:';

  @override
  String get topicMarkCompleted => 'وەک تەواوکراو دیاری بکە';

  @override
  String get topicOtherEditions => 'ئەم بابەتە لە وەشانەکانی تردا';

  @override
  String get topicRelatedRules => 'کارتەکانی ڕێسا';

  @override
  String get topicPractice => 'ڕاهێنان';

  @override
  String get readerLoading => 'کتێبەکە دەکرێتەوە…';

  @override
  String get readerError =>
      'ئەم وەشانە نەکرایەوە. ئەگەر کێشەکە بەردەوام بوو، ئەپەکە دووبارە دابمەزرێنەوە.';

  @override
  String readerPageSemantics(String edition, String page) {
    return 'لاپەڕەی کتێب: $edition، $page. لێی بدە بۆ پیشاندان یان شاردنەوەی ئامرازەکانی خوێندنەوە.';
  }

  @override
  String readerPositionOf(String current, String total) {
    return '$current لە $total';
  }

  @override
  String get readerAddBookmark => 'زیادکردنی نیشانە';

  @override
  String get readerRemoveBookmark => 'لابردنی نیشانە';

  @override
  String get bookmarkAdded => 'نیشانە زیادکرا';

  @override
  String get bookmarkRemoved => 'نیشانە لابرا';

  @override
  String get readerNotes => 'تێبینییەکانی لاپەڕە';

  @override
  String get readerMore => 'هەڵبژاردەی تر';

  @override
  String get readerGoToPage => 'چوون بۆ لاپەڕە';

  @override
  String get goToPageFieldLabel => 'ژمارەی چاپکراوی لاپەڕە';

  @override
  String goToPageInvalid(String min, String max) {
    return 'ژمارەیەک لە نێوان $min و $max بنووسە.';
  }

  @override
  String get readerChooseEdition => 'خوێندنەوە لە وەشانێکی تر';

  @override
  String get readerAppearance => 'ڕووکاری خوێندنەوە';

  @override
  String get readerThemeLight => 'ڕووناک';

  @override
  String get readerThemeSepia => 'کاغەزی';

  @override
  String get readerThemeNight => 'شەو';

  @override
  String get readerDimPages => 'کەمکردنەوەی ڕووناکی لاپەڕەکان';

  @override
  String get readerDimPagesHint =>
      'ڕووناکی بە یەکسانی کەم دەکاتەوە بەبێ گۆڕینی ڕەنگەکان.';

  @override
  String get readerColorsNote =>
      'ڕەنگەکانی کتێبەکە مانای فێرکارییان هەیە، بۆیە لاپەڕەکان پێچەوانە ناکرێنەوە و ڕەنگیان ناگۆڕدرێت.';

  @override
  String get readerShowThumbnails => 'پیشاندانی لاپەڕە بچووککراوەکان';

  @override
  String get readerHideThumbnails => 'شاردنەوەی لاپەڕە بچووککراوەکان';

  @override
  String get readerLessonDetails => 'وردەکاری وانەکە';

  @override
  String notesForPage(String page) {
    return 'تێبینییەکانی $page';
  }

  @override
  String get notesPrivateHint =>
      'تێبینییەکانت تەنها لەسەر ئەم ئامێرە پاشەکەوت دەکرێن.';

  @override
  String get notesHint => 'تێبینییەک بنووسە…';

  @override
  String get notesAdd => 'زیادکردنی تێبینی';

  @override
  String get notesEdit => 'دەستکاریکردنی تێبینی';

  @override
  String get notesOpenPage => 'لاپەڕەکە بکەرەوە';

  @override
  String get notesEmpty =>
      'هێشتا هیچ تێبینییەک نییە. لە شاشەی خوێندنەوە تێبینی زیاد بکە.';

  @override
  String get notesTab => 'تێبینییەکان';

  @override
  String get bookmarksTab => 'نیشانەکان';

  @override
  String get bookmarksEmpty =>
      'هێشتا هیچ نیشانەیەک نییە. لە شاشەی خوێندنەوە نیشانە زیاد بکە.';

  @override
  String get bookmarksAndNotes => 'نیشانە و تێبینییەکان';

  @override
  String get rulesTitle => 'ڕێبەری ڕێساکان';

  @override
  String get rulesIntro =>
      'کارتی کورت بۆ ئەو ڕێسایانەی لە کتێبەکاندا ڕوونکراونەتەوە، لەگەڵ نموونەیەکی پشتڕاستکراو و بەستەر بۆ وانەکە.';

  @override
  String get rulesAwaitingReview =>
      'کارتەکانی ڕێسا لەژێر پێداچوونەوەی زانستیدان و دوای پەسەندکردن بەردەست دەبن. کتێبەکان بە تەواوی لە وانەکاندا بەردەستن.';

  @override
  String get ruleCardTitle => 'کارتی ڕێسا';

  @override
  String ruleFromLesson(String topic) {
    return 'لە وانەی: $topic';
  }

  @override
  String get ruleDefinition => 'پێناسە';

  @override
  String ruleSourceLine(String edition, String page) {
    return 'لە $edition، لاپەڕە $page';
  }

  @override
  String ruleNotInEdition(String edition) {
    return '$edition ئەم بەشە بە دەقێکی سەربەخۆ باس ناکات؛ کورتەکەی سەرەوە بۆ ئەپەکە نووسراوە.';
  }

  @override
  String get ruleArabicSource => 'دەقی وەشانی عەرەبی:';

  @override
  String get ruleLetters => 'پیتەکان';

  @override
  String get ruleAllLettersExcept => 'هەموو پیتەکان جگە لە:';

  @override
  String get ruleExample => 'نموونە';

  @override
  String get ruleHighlightedLetters => 'پیتە ڕەنگکراوەکان';

  @override
  String get ruleInTheBooks => 'لە کتێبەکاندا';

  @override
  String get ruleOpenLesson => 'وانەکە';

  @override
  String get rulePractice => 'ڕاهێنان بکە';

  @override
  String quranExcerptFrom(String reference) {
    return 'بەشێک لە $reference';
  }

  @override
  String quranExcerptSemantics(
    String text,
    String highlighted,
    String reference,
  ) {
    return 'نموونەی قورئانی: $text. پیتە ڕەنگکراوەکان: $highlighted. $reference';
  }

  @override
  String get previewBadge => 'پێشبینینی گەشەپێدان';

  @override
  String get previewExplanation =>
      'ئەم بابەتە زیادەیە هێشتا لەلایەن پسپۆڕەوە پێداچوونەوەی بۆ نەکراوە و تەنها لە وەشانی گەشەپێداندا دەردەکەوێت.';

  @override
  String get makharijTitle => 'دەرچەی پیتەکان';

  @override
  String get makharijSubtitle => 'وێنەی ڕوونکەرەوە لەگەڵ حەڤدە دەرچەکە';

  @override
  String makharijIntro(String areas, String points) {
    return 'کتێبەکە $areas دەرچەی گشتی و $points دەرچەی تایبەت دەخاتەڕوو. دەرچەیەک هەڵبژێرە بۆ بینینی شوێن و وەسفەکەی.';
  }

  @override
  String get makharijDiagramSource =>
      'وێنەکە هی خودی کتێبەکەیە. بە دوو پەنجە گەورەی بکە.';

  @override
  String get makharijOpenDiagramPage => 'لاپەڕەی وێنەکە';

  @override
  String get makharijAllPoints => 'هەموو دەرچەکان';

  @override
  String get makharijAllAreas => 'هەموو';

  @override
  String get makharijNotMarked =>
      'وێنەکە ئەم شوێنە بە نیشانە دیاری ناکات؛ بۆ وێنە وردەکەی سەیری لاپەڕەی کتێبەکە بکە.';

  @override
  String makharijReadInBook(String edition, String page) {
    return '$edition، لاپەڕە $page';
  }

  @override
  String get practiceTitle => 'ڕاهێنان';

  @override
  String get practiceIntro =>
      'پرسیاری زیادە کە بۆ ئەپەکە نووسراون، نموونەکانیان لە خشتەکانی کتێبەکانەوە وەرگیراون و پشتڕاستکراونەتەوە.';

  @override
  String get practiceAwaitingReview =>
      'پرسیارەکانی ڕاهێنان لەژێر پێداچوونەوەدان و دوای پەسەندکردن بەردەست دەبن.';

  @override
  String get practiceOverall => 'ئەنجامەکەت';

  @override
  String practiceNotTried(String count) {
    return 'ژمارەی پرسیارەکان: $count — هێشتا دەستت پێنەکردووە.';
  }

  @override
  String practicePerformance(String correct, String answered, String total) {
    return 'دروست: $correct لە $answered وەڵامدراو · کۆی گشتی $total';
  }

  @override
  String get practiceSeparateFromReading =>
      'پێشکەوتنی خوێندنەوە جیا لە ئەنجامەکانی ڕاهێنان تۆمار دەکرێت.';

  @override
  String get practiceStart => 'دەست بە ڕاهێنان بکە';

  @override
  String get practiceContinue => 'بەردەوام بە لە ڕاهێنان';

  @override
  String get practiceByLesson => 'بەپێی وانە';

  @override
  String get practiceThisLesson => 'ڕاهێنان لەسەر ئەم وانەیە بکە';

  @override
  String get practiceReset => 'سڕینەوەی ئەنجامەکانی ڕاهێنان';

  @override
  String get practiceResetConfirm =>
      'تەنها ئەنجامەکانی ڕاهێنان دەسڕدرێنەوە. نیشانە و تێبینی و پێشکەوتنی خوێندنەوە وەک خۆیان دەمێننەوە.';

  @override
  String quizProgress(String current, String total) {
    return 'پرسیاری $current لە $total';
  }

  @override
  String get quizSupplementary => 'پرسیاری زیادە، لە دەقی کتێبەکە نییە.';

  @override
  String get quizIdentifyPrompt => 'حوکمی پیتە ڕەنگکراوەکان چییە؟';

  @override
  String get quizTrueFalsePrompt => 'ڕاست یان هەڵە؟';

  @override
  String get quizTrue => 'ڕاست';

  @override
  String get quizFalse => 'هەڵە';

  @override
  String quizCounts(String value) {
    return '$value حەرەکە';
  }

  @override
  String get quizFeedbackCorrect => 'وەڵامی دروست';

  @override
  String get quizFeedbackIncorrect => 'ئەمە وەڵامەکە نییە';

  @override
  String get quizCorrectAnswer => 'وەڵامی دروست';

  @override
  String get quizYourAnswer => 'وەڵامەکەت';

  @override
  String get quizReviewRule => 'کارتی ڕێسا';

  @override
  String get quizOpenLesson => 'وانەکە';

  @override
  String get quizNext => 'پرسیاری داهاتوو';

  @override
  String get quizSeeResult => 'بینینی ئەنجام';

  @override
  String get quizFinished => 'دەستخۆش';

  @override
  String quizScore(String correct, String total) {
    return '$correct لە $total دروست بوون';
  }

  @override
  String get quizFinishedHint =>
      'جاری داهاتوو ئەو پرسیارانەی هەڵەت تێدا کردوون یەکەم دەردەکەون.';

  @override
  String get practiceQuick => 'ڕاهێنانی خێرا';

  @override
  String practiceQuickHint(String count) {
    return '$count پرسیار لە هەموو وانەکان، سەرەتا ئەوانەی پێشتر هەڵەت تێدا کردوون.';
  }

  @override
  String practiceMistakes(String count) {
    return 'پێداچوونەوەی هەڵەکانم ($count)';
  }

  @override
  String get quizPracticeAgain => 'خولێکی تر';

  @override
  String get quizMissedHeading => 'بۆ پێداچوونەوە';

  @override
  String get quizPerfect => 'هەمووی ڕاستە، دەستخۆش!';

  @override
  String get searchTitle => 'گەڕان';

  @override
  String get searchHint => 'بە دوای بابەت یان ڕێسا یان زاراوەدا بگەڕێ';

  @override
  String get searchCoverage =>
      'لە ناونیشانی بابەتەکان و ناوی ڕێساکان و زاراوەکاندا بە هەر چوار زمانەکە دەگەڕێت. دەقی لاپەڕەکان تەنها لە وەشانی ئینگلیزی و ئیندۆنیزیدا دەگەڕدرێت، چونکە دەقی وەشانی عەرەبی و کوردی بە وردی دەرناهێنرێت.';

  @override
  String get searchLessons => 'بابەتەکان';

  @override
  String get searchRules => 'کارتەکانی ڕێسا';

  @override
  String searchPagesIn(String edition) {
    return 'لاپەڕەکانی $edition';
  }

  @override
  String get searchPagesNote =>
      'وشەکە لە دەقی ئەم لاپەڕانەدا دۆزرایەوە؛ شوێنەکەی لەناو لاپەڕەکەدا دیاری ناکرێت.';

  @override
  String searchMatched(String text) {
    return 'یەکدەگرێتەوە لەگەڵ: $text';
  }

  @override
  String searchNoResults(String query) {
    return 'هیچ ئەنجامێک نییە بۆ «$query»';
  }

  @override
  String get searchNoResultsHint =>
      'ناوی حوکمەکە یان بەشێکی تاقی بکەرەوە، وەک: ئیخفاء، قەلقەلە، مەد.';

  @override
  String get settingsTitle => 'ڕێکخستنەکان';

  @override
  String get settingsLanguage => 'زمان';

  @override
  String get settingsLanguageHint =>
      'ڕووکار و وەشانی کتێبەکە پێکەوە دەگۆڕێن. شوێنی خوێندنەوە بۆ هەر وەشانێک بە جیا پاشەکەوت دەکرێت و وانەی ئێستا دەگوازرێتەوە بۆ هاوتاکەی.';

  @override
  String get settingsStudy => 'خوێندن';

  @override
  String get settingsStreak => 'ژمێرەری ڕۆژە یەک لەدوای یەکەکان';

  @override
  String get settingsStreakHint =>
      'هەڵبژاردەیەکی ئارامە کە لە سەرەکیدا دەردەکەوێت.';

  @override
  String get settingsHaptics => 'لەرینەوە لە کاتی دەستلێدان';

  @override
  String get settingsHapticsHint =>
      'لەرینەوەیەکی سووک لە کاتی گۆڕینی بەش، دیاریکردنی وانە وەک تەواوکراو و وەڵامدانەوە لە ڕاهێناندا.';

  @override
  String get settingsReminder => 'بیرخستنەوەی ڕۆژانە';

  @override
  String get settingsReminderHint =>
      'یەک ئاگادارکردنەوە هەموو ڕۆژێک لەو کاتەی هەڵیدەبژێریت. لەسەر ئامێرەکەت ڕێکدەخرێت و هیچ شتێک بۆ هیچ لایەک نانێردرێت.';

  @override
  String get settingsReminderTime => 'کاتی بیرخستنەوە';

  @override
  String get settingsReminderDenied =>
      'ڕێگە بە ئاگادارکردنەوەکان نەدراوە. دەتوانیت لە ڕێکخستنەکانی ئامێرەکەوە ڕێگەی پێبدەیت و پاشان بیرخستنەوەکە چالاک بکەیت.';

  @override
  String get reminderBody =>
      'کاتی خوێندنەوەی تەجویدی ئەمڕۆتە. وانەکەت لەو شوێنەوە بەردەوام بکە کە لێی وەستایت.';

  @override
  String get reminderChannel => 'بیرخستنەوەی ڕۆژانە';

  @override
  String get bookTitle => 'هەموو کتێبەکە';

  @override
  String bookSubtitle(String edition) {
    return 'هەموو لاپەڕەکانی $edition وەک سەرچاوە ببینە';
  }

  @override
  String get settingsOffline =>
      'هەر چوار کتێبەکە و هەموو تایبەتمەندییەکان بەبێ ئینتەرنێت کار دەکەن و پێویست بە دروستکردنی هەژمار ناکات.';

  @override
  String get lessonRead => 'وانەکە بخوێنەوە';

  @override
  String get lessonOriginalPages => 'لاپەڕە ڕەسەنەکان';

  @override
  String lessonFromPage(String page) {
    return 'لە لاپەڕە $page';
  }

  @override
  String get lessonViewInBook => 'لە کتێبەکەدا ببینە';

  @override
  String lessonSourceNote(String edition) {
    return 'ئەم دەقە لە لاپەڕەکانی $edition وەرگیراوە. لاپەڕە ڕەسەنەکان سەرچاوەن.';
  }

  @override
  String get lessonUnderReview =>
      'ئەم گواستنەوەیە هێشتا پێداچوونەوەی بۆ نەکراوە؛ لە هەر جیاوازییەکدا لاپەڕە ڕەسەنەکە پشتی پێدەبەسترێت.';

  @override
  String get lessonFigure =>
      'وێنەیەکی ڕوونکەرەوە لە کتێبەکە، لێی بدە بۆ گەورەکردن';

  @override
  String get lessonFullVerse => 'ئایەتەکە بە تەواوی';

  @override
  String get lessonQuranTapHint => 'لێی بدە بۆ بینینی ئایەتەکە بە تەواوی';

  @override
  String get lessonContents => 'ناوەڕۆکی وانەکە';

  @override
  String get lessonEnd => 'کۆتایی وانەکە';

  @override
  String get lessonPrevious => 'وانەی پێشوو';

  @override
  String get lessonNext => 'وانەی داهاتوو';

  @override
  String get searchInLessons => 'لە دەقی وانەکاندا';

  @override
  String get searchCoverageWithLessons =>
      'لە دەقی وانەکان و ناونیشانی بابەتەکان و ناوی ڕێساکان و زاراوەکاندا بە هەر چوار زمانەکە دەگەڕێت، هەروەها لە دەقی لاپەڕەکانی وەشانی ئینگلیزی و ئیندۆنیزیدا.';

  @override
  String get aboutTitle => 'دەربارەی ئەپەکە';

  @override
  String get aboutBody =>
      'هاوڕێیەکی خوێندنی تەجویدە کە لەسەر کتێبەکانی «ئاسانکردنی تەجوید – ئاستی دووەم» دروستکراوە. کتێبە ڕەسەنەکان وەک خۆیان پیشان دەدرێن و ئامرازی گەڕان و پێداچوونەوە و ڕاهێنانیان لەگەڵدایە.';

  @override
  String get aboutBooks => 'کتێبەکان';

  @override
  String aboutAuthor(String name) {
    return 'نووسەر: $name';
  }

  @override
  String aboutTranslator(String name) {
    return 'وەرگێڕان: $name';
  }

  @override
  String get aboutDistribution =>
      'کتێبەکە دەڵێت مافی بڵاوکردنەوە بۆ هەمووان ڕێگەپێدراوە بەو مەرجەی هیچی بۆ زیاد و کەم نەکرێت.';

  @override
  String get aboutUnchanged =>
      'لاپەڕەکان بەبێ هیچ زیادکردن و لابردنێک پیشان دەدرێن. وەشانە ناوخراوەکان تەنها لە ڕووی پێکهاتەوە پەستێنراون و پشتڕاستکراوەتەوە کە پیشاندانیان پیکسڵ بە پیکسڵ وەک ئەسڵەکەیە.';

  @override
  String get aboutPrivacyTitle => 'تایبەتمەندی';

  @override
  String get aboutPrivacy =>
      'ئەپەکە هیچ زانیارییەک کۆ ناکاتەوە و پەیوەندی بە ئینتەرنێتەوە ناکات. ڕێکخستن و پێشکەوتن و تێبینییەکانت تەنها لەسەر ئامێرەکەت پاشەکەوت دەکرێن و بە سڕینەوەی ئەپەکە دەسڕدرێنەوە.';

  @override
  String get aboutQuranText => 'دەقی قورئان';

  @override
  String get aboutTanzil =>
      'نموونە قورئانییەکانی ناو وانەکان و کارتەکانی ڕێسا و ڕاهێنان وشە بە وشە لە دەقی پڕۆژەی تەنزیل (ڕێنووسی عوسمانی، وەشانی 1.1، tanzil.net) وەرگیراون و سەرچاوەکانیان بە شێوەی ئۆتۆماتیکی پشتڕاستکراونەتەوە.';

  @override
  String get aboutSupplementary => 'بابەتە زیادەکان';

  @override
  String get aboutSupplementaryBody =>
      'دەقی وانەکان و کارتەکانی ڕێسا و پرسیارەکانی ڕاهێنان و گەڕۆکی دەرچەکان لەسەر دەقی کتێبەکان دروستکراون و پێش پەسەندکردن بۆ بڵاوکردنەوە پێداچوونەوەیان بۆ دەکرێت.';

  @override
  String get aboutFonts => 'فۆنتەکان';

  @override
  String get aboutFontsBody =>
      'Noto Naskh Arabic و Noto Sans Arabic و Amiri و Amiri Quran و Literata و Inter، هەموویان بە مۆڵەتی SIL Open Font License 1.1. فۆنتەکانی کتێبە ڕەسەنەکان لەگەڵ ئەپەکەدا دابەش ناکرێن.';

  @override
  String get aboutLicenses => 'مۆڵەتەکان';

  @override
  String aboutContentVersion(String version) {
    return 'وەشانی ناوەڕۆک: $version';
  }
}
