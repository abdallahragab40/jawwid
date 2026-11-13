// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navLessons => 'الدروس';

  @override
  String get navRules => 'القواعد';

  @override
  String get navPractice => 'التدريب';

  @override
  String get navMore => 'المزيد';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionDone => 'تم';

  @override
  String get actionGo => 'انتقال';

  @override
  String get actionOk => 'حسنًا';

  @override
  String get actionSave => 'حفظ';

  @override
  String get editionArabic => 'النسخة العربية';

  @override
  String get editionKurdish => 'النسخة الكردية';

  @override
  String get editionEnglish => 'النسخة الإنجليزية';

  @override
  String get editionIndonesian => 'النسخة الإندونيسية';

  @override
  String pageLabel(String number) {
    return 'صفحة $number';
  }

  @override
  String pageRangeLabel(String start, String end) {
    return 'الصفحات $start–$end';
  }

  @override
  String get pageCover => 'الغلاف';

  @override
  String get pageBackCover => 'الغلاف الخلفي';

  @override
  String get pageUnnumbered => 'صفحة غير مرقّمة';

  @override
  String get homeContinueTitle => 'تابع القراءة';

  @override
  String get homeStartTitle => 'ابدأ بالدرس الأول';

  @override
  String homeContinueOtherEdition(String current, String other) {
    return 'هذا الموضوع غير موجود في $current، لذلك يُفتح في $other.';
  }

  @override
  String get homeCurriculum => 'فهرس موضوعات التجويد';

  @override
  String homeCurriculumSummary(String topics, String groups) {
    return '$topics موضوعًا في $groups وحدات';
  }

  @override
  String welcomeIntro(String book) {
    return 'تعلّم التجويد خطوة بخطوة مع كتاب «$book».';
  }

  @override
  String get welcomeLessons => 'دروس واضحة من نصّ الكتاب نفسه';

  @override
  String get welcomeBook => 'صفحات الكتاب الأصلية دائمًا في متناولك';

  @override
  String get welcomePractice => 'تدريبات قصيرة مع شرح لكل إجابة';

  @override
  String get welcomeChooseLanguage => 'اختر لغتك';

  @override
  String get welcomeLanguageLater => 'يمكنك تغييرها لاحقًا من الإعدادات.';

  @override
  String get welcomeStart => 'ابدأ التعلّم';

  @override
  String unitCompleted(String number, String title) {
    return 'أتممت الوحدة $number: $title. بارك الله فيك!';
  }

  @override
  String get homeProgressTitle => 'تقدّمك';

  @override
  String homeLessonsDone(String done, String total) {
    return 'أكملت $done من $total';
  }

  @override
  String homePracticeAccuracy(String percent) {
    return '$percent٪ إجابات صحيحة';
  }

  @override
  String get homePracticeTeaser => 'اختبر نفسك في دقيقتين';

  @override
  String homeUnitLabel(String number) {
    return 'الوحدة $number';
  }

  @override
  String get homeSeeAll => 'كل الموضوعات';

  @override
  String get homeRecentBookmarks => 'أحدث العلامات';

  @override
  String get homeReviewSuggestion => 'اقتراح للمراجعة';

  @override
  String reviewMissed(String correct, String answered, String topic) {
    return 'أصبتَ في $correct من $answered من أسئلة «$topic». راجع الدرس ثم أعد المحاولة.';
  }

  @override
  String reviewTryPractice(String topic) {
    return 'قرأتَ «$topic». جرّب أسئلته للتثبيت.';
  }

  @override
  String reviewFinishLesson(String topic) {
    return 'بدأتَ «$topic». أكمله وعلّمه مكتملًا عندما تنتهي.';
  }

  @override
  String reviewNextLesson(String topic) {
    return 'الدرس التالي: «$topic».';
  }

  @override
  String get reviewOpenLesson => 'افتح الدرس';

  @override
  String streakDays(String count) {
    return 'أيام دراسة متتالية: $count';
  }

  @override
  String get streakNone => 'كل يوم فرصة جديدة للتعلّم.';

  @override
  String get curriculumTitle => 'موضوعات التجويد';

  @override
  String curriculumIntro(String count) {
    return 'الموضوعات ($count) بترتيب الكتاب، ويمكنك فتح أي موضوع مباشرة.';
  }

  @override
  String curriculumProgress(String read, String completed, String total) {
    return 'بدأت: $read · مكتملة: $completed · من $total';
  }

  @override
  String get curriculumGroupsNote =>
      'تقسيم الوحدات لتسهيل التصفح فقط، وليس من الكتاب.';

  @override
  String get statusNotStarted => 'لم يبدأ';

  @override
  String get statusRead => 'تمت قراءته';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String topicNumber(String number) {
    return 'الموضوع $number';
  }

  @override
  String get topicInTheBook => 'في الكتاب';

  @override
  String topicReadHint(String edition) {
    return 'تُعرض الصفحات الأصلية من $edition كما هي.';
  }

  @override
  String get topicOpenPages => 'افتح صفحات الدرس';

  @override
  String get topicUnavailableTitle => 'غير متوفر في هذه النسخة';

  @override
  String topicUnavailableInEdition(String topic, String edition) {
    return 'موضوع «$topic» غير موجود في $edition. يمكنك قراءته في نسخة أخرى.';
  }

  @override
  String topicNotInEditionShort(String edition) {
    return 'غير موجود في $edition';
  }

  @override
  String get topicPartialShort => 'تغطية جزئية';

  @override
  String get topicAvailableIn => 'متوفر في:';

  @override
  String get topicMarkCompleted => 'علّمه مكتملًا';

  @override
  String get topicOtherEditions => 'هذا الموضوع في النسخ الأخرى';

  @override
  String get topicRelatedRules => 'بطاقات القواعد';

  @override
  String get topicPractice => 'التدريب';

  @override
  String get readerLoading => 'جارٍ فتح الكتاب…';

  @override
  String get readerError =>
      'تعذّر فتح هذه النسخة. أعد تثبيت التطبيق إذا استمرت المشكلة.';

  @override
  String readerPageSemantics(String edition, String page) {
    return 'صفحة الكتاب: $edition، $page. انقر لإظهار أدوات القراءة أو إخفائها.';
  }

  @override
  String readerPositionOf(String current, String total) {
    return '$current من $total';
  }

  @override
  String get readerAddBookmark => 'إضافة علامة';

  @override
  String get readerRemoveBookmark => 'إزالة العلامة';

  @override
  String get bookmarkAdded => 'أُضيفت العلامة';

  @override
  String get bookmarkRemoved => 'أُزيلت العلامة';

  @override
  String get readerNotes => 'ملاحظات الصفحة';

  @override
  String get readerMore => 'خيارات أخرى';

  @override
  String get readerGoToPage => 'الانتقال إلى صفحة';

  @override
  String get goToPageFieldLabel => 'رقم الصفحة المطبوع';

  @override
  String goToPageInvalid(String min, String max) {
    return 'أدخل رقمًا بين $min و$max.';
  }

  @override
  String get readerChooseEdition => 'القراءة في نسخة أخرى';

  @override
  String get lessonPrevSection => 'القسم السابق';

  @override
  String get lessonNextSection => 'القسم التالي';

  @override
  String get lessonSourceInfo => 'عن مصدر النص';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsTextSize => 'حجم نص الدروس';

  @override
  String get textSmaller => 'تصغير النص';

  @override
  String get textLarger => 'تكبير النص';

  @override
  String get readerAppearance => 'مظهر القراءة';

  @override
  String get readerThemeLight => 'فاتح';

  @override
  String get readerThemeSepia => 'ورقي';

  @override
  String get readerThemeNight => 'ليلي';

  @override
  String get readerDimPages => 'تخفيف سطوع الصفحات';

  @override
  String get readerDimPagesHint => 'يخفّف السطوع بالتساوي دون تغيير الألوان.';

  @override
  String get readerColorsNote =>
      'ألوان الكتاب تحمل معنى تعليميًّا، لذلك لا تُعكس الصفحات ولا يُعاد تلوينها.';

  @override
  String get readerShowThumbnails => 'إظهار الصفحات المصغّرة';

  @override
  String get readerHideThumbnails => 'إخفاء الصفحات المصغّرة';

  @override
  String get readerLessonDetails => 'تفاصيل الدرس';

  @override
  String notesForPage(String page) {
    return 'ملاحظات $page';
  }

  @override
  String get notesPrivateHint => 'تُحفظ ملاحظاتك على هذا الجهاز فقط.';

  @override
  String get notesHint => 'اكتب ملاحظة…';

  @override
  String get notesAdd => 'إضافة ملاحظة';

  @override
  String get notesEdit => 'تعديل الملاحظة';

  @override
  String get notesOpenPage => 'افتح الصفحة';

  @override
  String get notesEmpty => 'لا توجد ملاحظات بعد. أضف ملاحظة من شاشة القراءة.';

  @override
  String get notesTab => 'الملاحظات';

  @override
  String get bookmarksTab => 'العلامات';

  @override
  String get bookmarksEmpty => 'لا توجد علامات بعد. أضف علامة من شاشة القراءة.';

  @override
  String get bookmarksAndNotes => 'العلامات والملاحظات';

  @override
  String get rulesTitle => 'دليل القواعد';

  @override
  String get rulesIntro =>
      'بطاقات مختصرة للقواعد المشروحة في الكتب، مع مثال موثّق ورابط إلى الدرس.';

  @override
  String get rulesAwaitingReview =>
      'بطاقات القواعد قيد المراجعة العلمية وستتوفر بعد اعتمادها. الكتب متاحة كاملة في الدروس.';

  @override
  String get ruleCardTitle => 'بطاقة القاعدة';

  @override
  String ruleFromLesson(String topic) {
    return 'من درس: $topic';
  }

  @override
  String get ruleDefinition => 'التعريف';

  @override
  String ruleSourceLine(String edition, String page) {
    return 'من $edition، صفحة $page';
  }

  @override
  String ruleNotInEdition(String edition) {
    return 'لا يتناول $edition هذه الجزئية بنص مستقل؛ الملخّص أعلاه كُتب للتطبيق.';
  }

  @override
  String get ruleArabicSource => 'نص النسخة العربية:';

  @override
  String get ruleLetters => 'الحروف';

  @override
  String get ruleAllLettersExcept => 'جميع الحروف ما عدا:';

  @override
  String get ruleExample => 'مثال';

  @override
  String get ruleHighlightedLetters => 'الحروف الملوّنة';

  @override
  String get ruleInTheBooks => 'في الكتب';

  @override
  String get ruleOpenLesson => 'الدرس';

  @override
  String get rulePractice => 'تدرّب';

  @override
  String quranExcerptFrom(String reference) {
    return 'مقتطف من $reference';
  }

  @override
  String quranExcerptSemantics(
    String text,
    String highlighted,
    String reference,
  ) {
    return 'مثال قرآني: $text. الحروف الملوّنة: $highlighted. $reference';
  }

  @override
  String get previewBadge => 'معاينة للتطوير';

  @override
  String get previewExplanation =>
      'هذه المادة الإضافية لم تُراجَع بعد من مختص، وتظهر في نسخة التطوير فقط.';

  @override
  String get makharijTitle => 'مخارج الحروف';

  @override
  String get makharijSubtitle => 'الرسم التوضيحي مع المخارج السبعة عشر';

  @override
  String makharijIntro(String areas, String points) {
    return 'يعرض الكتاب $areas مخارج عامة و$points مخرجًا خاصًّا. اختر مخرجًا لترى موضعه ووصفه.';
  }

  @override
  String get makharijDiagramSource => 'الرسم من الكتاب نفسه. كبّره بإصبعين.';

  @override
  String get makharijOpenDiagramPage => 'صفحة الرسم';

  @override
  String get makharijAllPoints => 'جميع المخارج';

  @override
  String get makharijAllAreas => 'الكل';

  @override
  String get makharijNotMarked =>
      'لا يحدد الرسم هذا الموضع بعلامة؛ راجع صفحة الكتاب لرسمه التفصيلي.';

  @override
  String makharijReadInBook(String edition, String page) {
    return '$edition، صفحة $page';
  }

  @override
  String get practiceTitle => 'التدريب';

  @override
  String get practiceIntro =>
      'أسئلة إضافية كُتبت للتطبيق، وأمثلتها مأخوذة من جداول الكتب وموثّقة.';

  @override
  String get practiceAwaitingReview =>
      'أسئلة التدريب قيد المراجعة وستتوفر بعد اعتمادها.';

  @override
  String get practiceOverall => 'نتيجتك';

  @override
  String practiceNotTried(String count) {
    return 'عدد الأسئلة: $count — لم تبدأ بعد.';
  }

  @override
  String practicePerformance(String correct, String answered, String total) {
    return 'صحيحة: $correct من $answered مُجابة · المجموع $total';
  }

  @override
  String get practiceSeparateFromReading =>
      'تقدّم القراءة يُسجَّل منفصلًا عن نتائج التدريب.';

  @override
  String get practiceStart => 'ابدأ التدريب';

  @override
  String get practiceContinue => 'تابع التدريب';

  @override
  String get practiceByLesson => 'حسب الدرس';

  @override
  String get practiceThisLesson => 'تدرّب على هذا الدرس';

  @override
  String get practiceReset => 'مسح نتائج التدريب';

  @override
  String get practiceResetConfirm =>
      'ستُمسح نتائج التدريب فقط. تبقى العلامات والملاحظات وتقدّم القراءة كما هي.';

  @override
  String quizProgress(String current, String total) {
    return 'السؤال $current من $total';
  }

  @override
  String get quizSupplementary => 'سؤال إضافي، ليس من نص الكتاب.';

  @override
  String get quizIdentifyPrompt => 'ما الحكم في الحروف الملوّنة؟';

  @override
  String get quizTrueFalsePrompt => 'صواب أم خطأ؟';

  @override
  String get quizTrue => 'صواب';

  @override
  String get quizFalse => 'خطأ';

  @override
  String quizCounts(String value) {
    return '$value حركات';
  }

  @override
  String get quizFeedbackCorrect => 'إجابة صحيحة';

  @override
  String get quizFeedbackIncorrect => 'ليست هذه الإجابة';

  @override
  String get quizCorrectAnswer => 'الإجابة الصحيحة';

  @override
  String get quizYourAnswer => 'إجابتك';

  @override
  String get quizReviewRule => 'بطاقة القاعدة';

  @override
  String get quizOpenLesson => 'الدرس';

  @override
  String get quizNext => 'السؤال التالي';

  @override
  String get quizSeeResult => 'عرض النتيجة';

  @override
  String get quizFinished => 'أحسنت المتابعة';

  @override
  String quizScore(String correct, String total) {
    return 'أصبت في $correct من $total';
  }

  @override
  String get quizFinishedHint =>
      'ستظهر الأسئلة التي أخطأت فيها أولًا في المرة القادمة.';

  @override
  String get practiceQuick => 'تدريب سريع';

  @override
  String practiceQuickHint(String count) {
    return '$count أسئلة من كل الدروس، تبدأ بما أخطأت فيه سابقًا.';
  }

  @override
  String practiceMistakes(String count) {
    return 'راجع أخطائي ($count)';
  }

  @override
  String get lessonCheckTitle => 'اختبر فهمك';

  @override
  String lessonCheckBody(String count) {
    return '$count أسئلة قصيرة على هذا الدرس';
  }

  @override
  String get lessonCheckStart => 'ابدأ';

  @override
  String get quizLessonCompleted => 'أحسنت! سُجّل الدرس مكتملًا.';

  @override
  String get quizSortHint => 'اختر حرفًا ثم المجموعة التي ينتمي إليها.';

  @override
  String get quizCheck => 'تحقّق';

  @override
  String get quizSortReturn => 'اضغط لإعادته';

  @override
  String get quizPracticeAgain => 'جولة أخرى';

  @override
  String get quizMissedHeading => 'للمراجعة';

  @override
  String get quizPerfect => 'كلها صحيحة، أحسنت!';

  @override
  String get searchTitle => 'البحث';

  @override
  String get searchHint => 'ابحث عن موضوع أو قاعدة أو مصطلح';

  @override
  String get searchCoverage =>
      'يبحث في عناوين الموضوعات وأسماء القواعد والمصطلحات بالّلغات الأربع. أما نص الصفحات فيُبحث فيه في النسختين الإنجليزية والإندونيسية فقط، لأن نص النسختين العربية والكردية لا يُستخرج بدقة.';

  @override
  String get searchLessons => 'الموضوعات';

  @override
  String get searchRules => 'بطاقات القواعد';

  @override
  String searchPagesIn(String edition) {
    return 'صفحات من $edition';
  }

  @override
  String get searchPagesNote =>
      'وُجدت الكلمة في نص هذه الصفحات؛ موضعها داخل الصفحة غير محدد.';

  @override
  String searchMatched(String text) {
    return 'يطابق: $text';
  }

  @override
  String searchNoResults(String query) {
    return 'لا نتائج لـ«$query»';
  }

  @override
  String get searchNoResultsHint =>
      'جرّب اسم الحكم أو جزءًا منه، مثل: الإخفاء، القلقلة، المد.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageHint =>
      'تتغير الواجهة ونسخة الكتاب معًا. يُحفظ موضع القراءة في كل نسخة على حدة، ويُنقل الدرس الحالي إلى ما يقابله.';

  @override
  String get settingsStudy => 'الدراسة';

  @override
  String get settingsStreak => 'عدّاد الأيام المتتالية';

  @override
  String get settingsStreakHint => 'خيار هادئ يظهر في الرئيسية.';

  @override
  String get settingsHaptics => 'الاهتزاز عند اللمس';

  @override
  String get settingsHapticsHint =>
      'اهتزاز خفيف عند تغيير القسم، وتعليم الدرس مكتملًا، والإجابة في التدريب.';

  @override
  String get settingsReminder => 'تذكير يومي';

  @override
  String get settingsReminderHint =>
      'إشعار واحد كل يوم في الوقت الذي تختاره. يُجدوَل على جهازك ولا يُرسل شيء إلى أي جهة.';

  @override
  String get settingsReminderTime => 'وقت التذكير';

  @override
  String get settingsReminderDenied =>
      'لم يُسمح بالإشعارات. يمكنك السماح بها من إعدادات الجهاز ثم تفعيل التذكير.';

  @override
  String get reminderBody =>
      'حان وقت وِردك من التجويد. تابع درسك من حيث توقفت.';

  @override
  String get reminderChannel => 'التذكير اليومي';

  @override
  String get bookTitle => 'الكتاب كاملًا';

  @override
  String bookSubtitle(String edition) {
    return 'تصفّح صفحات $edition كاملةً كمرجع';
  }

  @override
  String get settingsOffline =>
      'تعمل الكتب الأربعة وأدوات الدراسة دون اتصال بالإنترنت، ولا يلزم إنشاء حساب. إرسال الملاحظات وتحويل مبالغ الدعم يتمّان عبر خدمات خارجية.';

  @override
  String get lessonRead => 'اقرأ الدرس';

  @override
  String get lessonOriginalPages => 'الصفحات الأصلية';

  @override
  String lessonFromPage(String page) {
    return 'من صفحة $page';
  }

  @override
  String get lessonViewInBook => 'اعرضها في الكتاب';

  @override
  String lessonSourceNote(String edition) {
    return 'هذا النص منقول من صفحات $edition. الصفحات الأصلية هي المرجع.';
  }

  @override
  String get lessonUnderReview =>
      'لم يُراجَع هذا النقل بعد؛ عند أي اختلاف فالمعتمد هو الصفحة الأصلية.';

  @override
  String get lessonFigure => 'رسمٌ توضيحيٌّ من الكتاب، انقر للتكبير';

  @override
  String get lessonFullVerse => 'الآية كاملة';

  @override
  String get lessonQuranTapHint => 'انقر لعرض الآية كاملة';

  @override
  String get lessonContents => 'محتويات الدرس';

  @override
  String get lessonEnd => 'نهاية الدرس';

  @override
  String get lessonPrevious => 'الدرس السابق';

  @override
  String get lessonNext => 'الدرس التالي';

  @override
  String get searchInLessons => 'في نصوص الدروس';

  @override
  String get searchCoverageWithLessons =>
      'يبحث في نصوص الدروس وعناوين الموضوعات وأسماء القواعد والمصطلحات بالّلغات الأربع، وفي نص صفحات النسختين الإنجليزية والإندونيسية.';

  @override
  String get aboutTitle => 'عن التطبيق';

  @override
  String get aboutBody =>
      'رفيق لدراسة التجويد مبني حول كتب «تبسيط التجويد – المستوى الثاني». تُعرض الكتب الأصلية كما هي، وتحيط بها أدوات للتصفح والمراجعة والتدريب.';

  @override
  String get aboutBooks => 'الكتب';

  @override
  String aboutAuthor(String name) {
    return 'المؤلف: $name';
  }

  @override
  String aboutTranslator(String name) {
    return 'الترجمة: $name';
  }

  @override
  String get aboutDistribution =>
      'ينص الكتاب على أن «حق النشر متاح للجميع ما دام بعيدًا عن الزيادة أو النقصان».';

  @override
  String get aboutUnchanged =>
      'تُعرض الصفحات دون أي إضافة أو حذف. النسخ المضمّنة مضغوطة بنيويًّا فقط، وقد تحقق أن عرضها مطابق للأصل بكسلًا بكسل.';

  @override
  String get aboutPrivacyTitle => 'الخصوصية';

  @override
  String get aboutPrivacy =>
      'لا يجمع جوِّد بيانات تحليلات الاستخدام. تُحفظ إعداداتك وتقدّمك وملاحظاتك على جهازك فقط، وتُحذف بحذف التطبيق. إرسال الملاحظات يفتح تطبيق بريدك، وروابط الدعم تفتح تطبيق دفع أو موقعًا خارجيًا. تتعامل هذه الخدمات مع المعلومات التي تختار إرسالها وفق سياسات الخصوصية الخاصة بها.';

  @override
  String get aboutQuranText => 'النص القرآني';

  @override
  String get aboutTanzil =>
      'الأمثلة القرآنية في الدروس وبطاقات القواعد والتدريب منقولة حرفيًّا من نص مشروع تنزيل (الرسم العثماني، الإصدار 1.1، tanzil.net) ومراجعها محققة آليًّا.';

  @override
  String get aboutSupplementary => 'المواد الإضافية';

  @override
  String get aboutSupplementaryBody =>
      'نصوص الدروس وبطاقات القواعد وأسئلة التدريب ومستكشف المخارج مبنية على نصوص الكتب، وتُراجَع قبل اعتمادها للإصدار.';

  @override
  String get aboutFonts => 'الخطوط';

  @override
  String get aboutFontsBody =>
      'Noto Naskh Arabic وNoto Sans Arabic وAmiri وAmiri Quran وLiterata وInter، جميعها بترخيص SIL Open Font License 1.1. خطوط الكتب الأصلية لا تُوزَّع مع التطبيق.';

  @override
  String get aboutLicenses => 'التراخيص';

  @override
  String aboutContentVersion(String version) {
    return 'إصدار المحتوى: $version';
  }

  @override
  String get feedbackTitle => 'أرسل ملاحظاتك';

  @override
  String get feedbackIntro =>
      'وجدت مشكلة أو لديك اقتراح؟ اكتب للمطوّر. سيُفتح تطبيق بريدك لتراجع الرسالة وترسلها بنفسك.';

  @override
  String get feedbackSubject => 'الموضوع';

  @override
  String get feedbackMessage => 'ملاحظاتك';

  @override
  String get feedbackRequired => 'يرجى ملء هذا الحقل.';

  @override
  String get feedbackSend => 'فتح تطبيق البريد';

  @override
  String get feedbackFallback =>
      'تعذّر فتح تطبيق البريد. انسخ رسالتك وأرسلها إلى العنوان أدناه.';

  @override
  String get feedbackCopy => 'نسخ الرسالة';

  @override
  String get contactCopyEmail => 'نسخ عنوان البريد';

  @override
  String get contactCopied => 'تم النسخ';

  @override
  String get supportTitle => 'ادعمني بفنجان قهوة';

  @override
  String get supportIntro =>
      'إذا أفادك جوِّد، يمكنك إرسال هدية اختيارية لدعم المطوّر. تظل جميع مزايا التعلّم مجانية، ولا تفتح الهدايا أي محتوى أو مزايا إضافية.';

  @override
  String get supportTransfer =>
      'اختر إنستاباي أو أرسل إلى إحدى محفظتي الهاتف في مصر أدناه.';

  @override
  String get supportVerify =>
      'تحقّق من اسم المستلم وأي رسوم في تطبيق الدفع قبل التأكيد. تتم التحويلات عبر مزوّد الدفع؛ لا يستطيع جوِّد تأكيدها أو استردادها.';

  @override
  String get supportCopyNumber => 'نسخ الرقم';

  @override
  String get supportOpenInstapay => 'فتح إنستاباي';

  @override
  String get supportCopyAddress => 'نسخ عنوان الدفع';

  @override
  String get supportLinkFailed =>
      'تعذّر فتح إنستاباي. انسخ عنوان الدفع واستخدمه في تطبيق الدفع.';

  @override
  String get supportEtisalat => 'اتصالات كاش';

  @override
  String get supportVodafone => 'فودافون كاش';
}
