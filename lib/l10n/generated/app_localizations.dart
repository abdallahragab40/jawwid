import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ckb.dart';
import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ckb'),
    Locale('en'),
    Locale('id'),
  ];

  /// Bottom navigation: home
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// Bottom navigation: lessons
  ///
  /// In ar, this message translates to:
  /// **'الدروس'**
  String get navLessons;

  /// Bottom navigation: rules guide
  ///
  /// In ar, this message translates to:
  /// **'القواعد'**
  String get navRules;

  /// Bottom navigation: practice
  ///
  /// In ar, this message translates to:
  /// **'التدريب'**
  String get navPractice;

  /// Bottom navigation: more
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get navMore;

  /// No description provided for @actionCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get actionDelete;

  /// No description provided for @actionDone.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get actionDone;

  /// No description provided for @actionGo.
  ///
  /// In ar, this message translates to:
  /// **'انتقال'**
  String get actionGo;

  /// No description provided for @actionOk.
  ///
  /// In ar, this message translates to:
  /// **'حسنًا'**
  String get actionOk;

  /// No description provided for @actionSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get actionSave;

  /// Name of the Arabic book edition
  ///
  /// In ar, this message translates to:
  /// **'النسخة العربية'**
  String get editionArabic;

  /// Name of the Kurdish book edition
  ///
  /// In ar, this message translates to:
  /// **'النسخة الكردية'**
  String get editionKurdish;

  /// Name of the English book edition
  ///
  /// In ar, this message translates to:
  /// **'النسخة الإنجليزية'**
  String get editionEnglish;

  /// Name of the Indonesian book edition
  ///
  /// In ar, this message translates to:
  /// **'النسخة الإندونيسية'**
  String get editionIndonesian;

  /// Printed page number label. {number} is already localized.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {number}'**
  String pageLabel(String number);

  /// Printed page range
  ///
  /// In ar, this message translates to:
  /// **'الصفحات {start}–{end}'**
  String pageRangeLabel(String start, String end);

  /// Front cover page
  ///
  /// In ar, this message translates to:
  /// **'الغلاف'**
  String get pageCover;

  /// Back cover page
  ///
  /// In ar, this message translates to:
  /// **'الغلاف الخلفي'**
  String get pageBackCover;

  /// A page without a printed number
  ///
  /// In ar, this message translates to:
  /// **'صفحة غير مرقّمة'**
  String get pageUnnumbered;

  /// No description provided for @homeContinueTitle.
  ///
  /// In ar, this message translates to:
  /// **'تابع القراءة'**
  String get homeContinueTitle;

  /// No description provided for @homeStartTitle.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بالدرس الأول'**
  String get homeStartTitle;

  /// Last-read topic is missing from the current-language edition
  ///
  /// In ar, this message translates to:
  /// **'هذا الموضوع غير موجود في {current}، لذلك يُفتح في {other}.'**
  String homeContinueOtherEdition(String current, String other);

  /// No description provided for @homeCurriculum.
  ///
  /// In ar, this message translates to:
  /// **'فهرس موضوعات التجويد'**
  String get homeCurriculum;

  /// No description provided for @homeCurriculumSummary.
  ///
  /// In ar, this message translates to:
  /// **'{topics} موضوعًا في {groups} وحدات'**
  String homeCurriculumSummary(String topics, String groups);

  /// First launch: one-line introduction. {book} is the edition title
  ///
  /// In ar, this message translates to:
  /// **'تعلّم التجويد خطوة بخطوة مع كتاب «{book}».'**
  String welcomeIntro(String book);

  /// First launch: feature
  ///
  /// In ar, this message translates to:
  /// **'دروس واضحة من نصّ الكتاب نفسه'**
  String get welcomeLessons;

  /// First launch: feature
  ///
  /// In ar, this message translates to:
  /// **'صفحات الكتاب الأصلية دائمًا في متناولك'**
  String get welcomeBook;

  /// First launch: feature
  ///
  /// In ar, this message translates to:
  /// **'تدريبات قصيرة مع شرح لكل إجابة'**
  String get welcomePractice;

  /// First launch: language picker heading
  ///
  /// In ar, this message translates to:
  /// **'اختر لغتك'**
  String get welcomeChooseLanguage;

  /// No description provided for @welcomeLanguageLater.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تغييرها لاحقًا من الإعدادات.'**
  String get welcomeLanguageLater;

  /// First launch: continue button
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التعلّم'**
  String get welcomeStart;

  /// Celebration when every lesson of a unit is completed. {number} is localized
  ///
  /// In ar, this message translates to:
  /// **'أتممت الوحدة {number}: {title}. بارك الله فيك!'**
  String unitCompleted(String number, String title);

  /// Home: progress tile heading
  ///
  /// In ar, this message translates to:
  /// **'تقدّمك'**
  String get homeProgressTitle;

  /// {done} and {total} are localized
  ///
  /// In ar, this message translates to:
  /// **'أكملت {done} من {total}'**
  String homeLessonsDone(String done, String total);

  /// {percent} is localized
  ///
  /// In ar, this message translates to:
  /// **'{percent}٪ إجابات صحيحة'**
  String homePracticeAccuracy(String percent);

  /// Home: practice tile when nothing has been answered yet
  ///
  /// In ar, this message translates to:
  /// **'اختبر نفسك في دقيقتين'**
  String get homePracticeTeaser;

  /// Label of a curriculum unit. {number} is localized
  ///
  /// In ar, this message translates to:
  /// **'الوحدة {number}'**
  String homeUnitLabel(String number);

  /// Link to the full topic list
  ///
  /// In ar, this message translates to:
  /// **'كل الموضوعات'**
  String get homeSeeAll;

  /// No description provided for @homeRecentBookmarks.
  ///
  /// In ar, this message translates to:
  /// **'أحدث العلامات'**
  String get homeRecentBookmarks;

  /// No description provided for @homeReviewSuggestion.
  ///
  /// In ar, this message translates to:
  /// **'اقتراح للمراجعة'**
  String get homeReviewSuggestion;

  /// No description provided for @reviewMissed.
  ///
  /// In ar, this message translates to:
  /// **'أصبتَ في {correct} من {answered} من أسئلة «{topic}». راجع الدرس ثم أعد المحاولة.'**
  String reviewMissed(String correct, String answered, String topic);

  /// No description provided for @reviewTryPractice.
  ///
  /// In ar, this message translates to:
  /// **'قرأتَ «{topic}». جرّب أسئلته للتثبيت.'**
  String reviewTryPractice(String topic);

  /// No description provided for @reviewFinishLesson.
  ///
  /// In ar, this message translates to:
  /// **'بدأتَ «{topic}». أكمله وعلّمه مكتملًا عندما تنتهي.'**
  String reviewFinishLesson(String topic);

  /// No description provided for @reviewNextLesson.
  ///
  /// In ar, this message translates to:
  /// **'الدرس التالي: «{topic}».'**
  String reviewNextLesson(String topic);

  /// No description provided for @reviewOpenLesson.
  ///
  /// In ar, this message translates to:
  /// **'افتح الدرس'**
  String get reviewOpenLesson;

  /// Optional, quiet study streak. {count} localized.
  ///
  /// In ar, this message translates to:
  /// **'أيام دراسة متتالية: {count}'**
  String streakDays(String count);

  /// Shown when there is no current streak. Never guilt-inducing.
  ///
  /// In ar, this message translates to:
  /// **'كل يوم فرصة جديدة للتعلّم.'**
  String get streakNone;

  /// No description provided for @curriculumTitle.
  ///
  /// In ar, this message translates to:
  /// **'موضوعات التجويد'**
  String get curriculumTitle;

  /// No description provided for @curriculumIntro.
  ///
  /// In ar, this message translates to:
  /// **'الموضوعات ({count}) بترتيب الكتاب، ويمكنك فتح أي موضوع مباشرة.'**
  String curriculumIntro(String count);

  /// No description provided for @curriculumProgress.
  ///
  /// In ar, this message translates to:
  /// **'بدأت: {read} · مكتملة: {completed} · من {total}'**
  String curriculumProgress(String read, String completed, String total);

  /// No description provided for @curriculumGroupsNote.
  ///
  /// In ar, this message translates to:
  /// **'تقسيم الوحدات لتسهيل التصفح فقط، وليس من الكتاب.'**
  String get curriculumGroupsNote;

  /// No description provided for @statusNotStarted.
  ///
  /// In ar, this message translates to:
  /// **'لم يبدأ'**
  String get statusNotStarted;

  /// No description provided for @statusRead.
  ///
  /// In ar, this message translates to:
  /// **'تمت قراءته'**
  String get statusRead;

  /// No description provided for @statusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get statusCompleted;

  /// App bar title of a topic. {number} localized.
  ///
  /// In ar, this message translates to:
  /// **'الموضوع {number}'**
  String topicNumber(String number);

  /// No description provided for @topicInTheBook.
  ///
  /// In ar, this message translates to:
  /// **'في الكتاب'**
  String get topicInTheBook;

  /// No description provided for @topicReadHint.
  ///
  /// In ar, this message translates to:
  /// **'تُعرض الصفحات الأصلية من {edition} كما هي.'**
  String topicReadHint(String edition);

  /// No description provided for @topicOpenPages.
  ///
  /// In ar, this message translates to:
  /// **'افتح صفحات الدرس'**
  String get topicOpenPages;

  /// No description provided for @topicUnavailableTitle.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر في هذه النسخة'**
  String get topicUnavailableTitle;

  /// No description provided for @topicUnavailableInEdition.
  ///
  /// In ar, this message translates to:
  /// **'موضوع «{topic}» غير موجود في {edition}. يمكنك قراءته في نسخة أخرى.'**
  String topicUnavailableInEdition(String topic, String edition);

  /// No description provided for @topicNotInEditionShort.
  ///
  /// In ar, this message translates to:
  /// **'غير موجود في {edition}'**
  String topicNotInEditionShort(String edition);

  /// No description provided for @topicPartialShort.
  ///
  /// In ar, this message translates to:
  /// **'تغطية جزئية'**
  String get topicPartialShort;

  /// No description provided for @topicAvailableIn.
  ///
  /// In ar, this message translates to:
  /// **'متوفر في:'**
  String get topicAvailableIn;

  /// Switch that marks a topic as completed (reading progress).
  ///
  /// In ar, this message translates to:
  /// **'علّمه مكتملًا'**
  String get topicMarkCompleted;

  /// No description provided for @topicOtherEditions.
  ///
  /// In ar, this message translates to:
  /// **'هذا الموضوع في النسخ الأخرى'**
  String get topicOtherEditions;

  /// No description provided for @topicRelatedRules.
  ///
  /// In ar, this message translates to:
  /// **'بطاقات القواعد'**
  String get topicRelatedRules;

  /// No description provided for @topicPractice.
  ///
  /// In ar, this message translates to:
  /// **'التدريب'**
  String get topicPractice;

  /// No description provided for @readerLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ فتح الكتاب…'**
  String get readerLoading;

  /// No description provided for @readerError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح هذه النسخة. أعد تثبيت التطبيق إذا استمرت المشكلة.'**
  String get readerError;

  /// Accessibility label for the page area
  ///
  /// In ar, this message translates to:
  /// **'صفحة الكتاب: {edition}، {page}. انقر لإظهار أدوات القراءة أو إخفائها.'**
  String readerPageSemantics(String edition, String page);

  /// Physical position within the PDF file
  ///
  /// In ar, this message translates to:
  /// **'{current} من {total}'**
  String readerPositionOf(String current, String total);

  /// No description provided for @readerAddBookmark.
  ///
  /// In ar, this message translates to:
  /// **'إضافة علامة'**
  String get readerAddBookmark;

  /// No description provided for @readerRemoveBookmark.
  ///
  /// In ar, this message translates to:
  /// **'إزالة العلامة'**
  String get readerRemoveBookmark;

  /// No description provided for @bookmarkAdded.
  ///
  /// In ar, this message translates to:
  /// **'أُضيفت العلامة'**
  String get bookmarkAdded;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In ar, this message translates to:
  /// **'أُزيلت العلامة'**
  String get bookmarkRemoved;

  /// No description provided for @readerNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات الصفحة'**
  String get readerNotes;

  /// No description provided for @readerMore.
  ///
  /// In ar, this message translates to:
  /// **'خيارات أخرى'**
  String get readerMore;

  /// No description provided for @readerGoToPage.
  ///
  /// In ar, this message translates to:
  /// **'الانتقال إلى صفحة'**
  String get readerGoToPage;

  /// No description provided for @goToPageFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الصفحة المطبوع'**
  String get goToPageFieldLabel;

  /// No description provided for @goToPageInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقمًا بين {min} و{max}.'**
  String goToPageInvalid(String min, String max);

  /// No description provided for @readerChooseEdition.
  ///
  /// In ar, this message translates to:
  /// **'القراءة في نسخة أخرى'**
  String get readerChooseEdition;

  /// Tooltip
  ///
  /// In ar, this message translates to:
  /// **'القسم السابق'**
  String get lessonPrevSection;

  /// Tooltip
  ///
  /// In ar, this message translates to:
  /// **'القسم التالي'**
  String get lessonNextSection;

  /// Tooltip: about the source of this lesson text
  ///
  /// In ar, this message translates to:
  /// **'عن مصدر النص'**
  String get lessonSourceInfo;

  /// Settings section: app colours
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsAppearance;

  /// App theme follows the device
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// Slider: size of lesson text
  ///
  /// In ar, this message translates to:
  /// **'حجم نص الدروس'**
  String get settingsTextSize;

  /// Tooltip: make text smaller
  ///
  /// In ar, this message translates to:
  /// **'تصغير النص'**
  String get textSmaller;

  /// Tooltip: make text larger
  ///
  /// In ar, this message translates to:
  /// **'تكبير النص'**
  String get textLarger;

  /// No description provided for @readerAppearance.
  ///
  /// In ar, this message translates to:
  /// **'مظهر القراءة'**
  String get readerAppearance;

  /// No description provided for @readerThemeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get readerThemeLight;

  /// No description provided for @readerThemeSepia.
  ///
  /// In ar, this message translates to:
  /// **'ورقي'**
  String get readerThemeSepia;

  /// No description provided for @readerThemeNight.
  ///
  /// In ar, this message translates to:
  /// **'ليلي'**
  String get readerThemeNight;

  /// No description provided for @readerDimPages.
  ///
  /// In ar, this message translates to:
  /// **'تخفيف سطوع الصفحات'**
  String get readerDimPages;

  /// No description provided for @readerDimPagesHint.
  ///
  /// In ar, this message translates to:
  /// **'يخفّف السطوع بالتساوي دون تغيير الألوان.'**
  String get readerDimPagesHint;

  /// No description provided for @readerColorsNote.
  ///
  /// In ar, this message translates to:
  /// **'ألوان الكتاب تحمل معنى تعليميًّا، لذلك لا تُعكس الصفحات ولا يُعاد تلوينها.'**
  String get readerColorsNote;

  /// No description provided for @readerShowThumbnails.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الصفحات المصغّرة'**
  String get readerShowThumbnails;

  /// No description provided for @readerHideThumbnails.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الصفحات المصغّرة'**
  String get readerHideThumbnails;

  /// No description provided for @readerLessonDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الدرس'**
  String get readerLessonDetails;

  /// No description provided for @notesForPage.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات {page}'**
  String notesForPage(String page);

  /// No description provided for @notesPrivateHint.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ ملاحظاتك على هذا الجهاز فقط.'**
  String get notesPrivateHint;

  /// No description provided for @notesHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظة…'**
  String get notesHint;

  /// No description provided for @notesAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ملاحظة'**
  String get notesAdd;

  /// No description provided for @notesEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملاحظة'**
  String get notesEdit;

  /// No description provided for @notesOpenPage.
  ///
  /// In ar, this message translates to:
  /// **'افتح الصفحة'**
  String get notesOpenPage;

  /// No description provided for @notesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملاحظات بعد. أضف ملاحظة من محتويات الدرس أو قارئ الكتاب.'**
  String get notesEmpty;

  /// No description provided for @notesTab.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات'**
  String get notesTab;

  /// No description provided for @bookmarksTab.
  ///
  /// In ar, this message translates to:
  /// **'العلامات'**
  String get bookmarksTab;

  /// No description provided for @bookmarksEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد علامات بعد. أضف علامة من شاشة القراءة.'**
  String get bookmarksEmpty;

  /// No description provided for @bookmarksAndNotes.
  ///
  /// In ar, this message translates to:
  /// **'العلامات والملاحظات'**
  String get bookmarksAndNotes;

  /// No description provided for @rulesTitle.
  ///
  /// In ar, this message translates to:
  /// **'دليل القواعد'**
  String get rulesTitle;

  /// No description provided for @rulesIntro.
  ///
  /// In ar, this message translates to:
  /// **'بطاقات مختصرة للقواعد المشروحة في الكتب، مع مثال موثّق ورابط إلى الدرس.'**
  String get rulesIntro;

  /// Release build with no reviewed rule cards yet
  ///
  /// In ar, this message translates to:
  /// **'بطاقات القواعد قيد المراجعة العلمية وستتوفر بعد اعتمادها. الكتب متاحة كاملة في الدروس.'**
  String get rulesAwaitingReview;

  /// No description provided for @ruleCardTitle.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة القاعدة'**
  String get ruleCardTitle;

  /// No description provided for @ruleFromLesson.
  ///
  /// In ar, this message translates to:
  /// **'من درس: {topic}'**
  String ruleFromLesson(String topic);

  /// No description provided for @ruleDefinition.
  ///
  /// In ar, this message translates to:
  /// **'التعريف'**
  String get ruleDefinition;

  /// No description provided for @ruleSourceLine.
  ///
  /// In ar, this message translates to:
  /// **'من {edition}، صفحة {page}'**
  String ruleSourceLine(String edition, String page);

  /// No description provided for @ruleNotInEdition.
  ///
  /// In ar, this message translates to:
  /// **'لا يتناول {edition} هذه الجزئية بنص مستقل؛ الملخّص أعلاه كُتب للتطبيق.'**
  String ruleNotInEdition(String edition);

  /// No description provided for @ruleArabicSource.
  ///
  /// In ar, this message translates to:
  /// **'نص النسخة العربية:'**
  String get ruleArabicSource;

  /// No description provided for @ruleLetters.
  ///
  /// In ar, this message translates to:
  /// **'الحروف'**
  String get ruleLetters;

  /// No description provided for @ruleAllLettersExcept.
  ///
  /// In ar, this message translates to:
  /// **'جميع الحروف ما عدا:'**
  String get ruleAllLettersExcept;

  /// No description provided for @ruleExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال'**
  String get ruleExample;

  /// No description provided for @ruleHighlightedLetters.
  ///
  /// In ar, this message translates to:
  /// **'الحروف الملوّنة'**
  String get ruleHighlightedLetters;

  /// No description provided for @ruleInTheBooks.
  ///
  /// In ar, this message translates to:
  /// **'في الكتب'**
  String get ruleInTheBooks;

  /// No description provided for @ruleOpenLesson.
  ///
  /// In ar, this message translates to:
  /// **'الدرس'**
  String get ruleOpenLesson;

  /// No description provided for @rulePractice.
  ///
  /// In ar, this message translates to:
  /// **'تدرّب'**
  String get rulePractice;

  /// Label under a partial verse
  ///
  /// In ar, this message translates to:
  /// **'مقتطف من {reference}'**
  String quranExcerptFrom(String reference);

  /// Accessibility label for a Qur'anic example
  ///
  /// In ar, this message translates to:
  /// **'مثال قرآني: {text}. الحروف الملوّنة: {highlighted}. {reference}'**
  String quranExcerptSemantics(
    String text,
    String highlighted,
    String reference,
  );

  /// Marks unreviewed supplementary content in development builds
  ///
  /// In ar, this message translates to:
  /// **'معاينة للتطوير'**
  String get previewBadge;

  /// No description provided for @previewExplanation.
  ///
  /// In ar, this message translates to:
  /// **'هذه المادة الإضافية لم تُراجَع بعد من مختص، وتظهر في نسخة التطوير فقط.'**
  String get previewExplanation;

  /// No description provided for @makharijTitle.
  ///
  /// In ar, this message translates to:
  /// **'مخارج الحروف'**
  String get makharijTitle;

  /// No description provided for @makharijSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الرسم التوضيحي مع المخارج السبعة عشر'**
  String get makharijSubtitle;

  /// No description provided for @makharijIntro.
  ///
  /// In ar, this message translates to:
  /// **'يعرض الكتاب {areas} مخارج عامة و{points} مخرجًا خاصًّا. اختر مخرجًا لترى موضعه ووصفه.'**
  String makharijIntro(String areas, String points);

  /// No description provided for @makharijDiagramSource.
  ///
  /// In ar, this message translates to:
  /// **'الرسم من الكتاب نفسه. كبّره بإصبعين.'**
  String get makharijDiagramSource;

  /// No description provided for @makharijOpenDiagramPage.
  ///
  /// In ar, this message translates to:
  /// **'صفحة الرسم'**
  String get makharijOpenDiagramPage;

  /// No description provided for @makharijAllPoints.
  ///
  /// In ar, this message translates to:
  /// **'جميع المخارج'**
  String get makharijAllPoints;

  /// No description provided for @makharijAllAreas.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get makharijAllAreas;

  /// No description provided for @makharijNotMarked.
  ///
  /// In ar, this message translates to:
  /// **'لا يحدد الرسم هذا الموضع بعلامة؛ راجع صفحة الكتاب لرسمه التفصيلي.'**
  String get makharijNotMarked;

  /// No description provided for @makharijReadInBook.
  ///
  /// In ar, this message translates to:
  /// **'{edition}، صفحة {page}'**
  String makharijReadInBook(String edition, String page);

  /// No description provided for @practiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'التدريب'**
  String get practiceTitle;

  /// No description provided for @practiceIntro.
  ///
  /// In ar, this message translates to:
  /// **'أسئلة إضافية كُتبت للتطبيق، وأمثلتها مأخوذة من جداول الكتب وموثّقة.'**
  String get practiceIntro;

  /// No description provided for @practiceAwaitingReview.
  ///
  /// In ar, this message translates to:
  /// **'أسئلة التدريب قيد المراجعة وستتوفر بعد اعتمادها.'**
  String get practiceAwaitingReview;

  /// No description provided for @practiceOverall.
  ///
  /// In ar, this message translates to:
  /// **'نتيجتك'**
  String get practiceOverall;

  /// No description provided for @practiceNotTried.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأسئلة: {count} — لم تبدأ بعد.'**
  String practiceNotTried(String count);

  /// Correct latest answers / answered / total
  ///
  /// In ar, this message translates to:
  /// **'صحيحة: {correct} من {answered} مُجابة · المجموع {total}'**
  String practicePerformance(String correct, String answered, String total);

  /// No description provided for @practiceSeparateFromReading.
  ///
  /// In ar, this message translates to:
  /// **'تقدّم القراءة يُسجَّل منفصلًا عن نتائج التدريب.'**
  String get practiceSeparateFromReading;

  /// No description provided for @practiceStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التدريب'**
  String get practiceStart;

  /// No description provided for @practiceContinue.
  ///
  /// In ar, this message translates to:
  /// **'تابع التدريب'**
  String get practiceContinue;

  /// No description provided for @practiceByLesson.
  ///
  /// In ar, this message translates to:
  /// **'حسب الدرس'**
  String get practiceByLesson;

  /// No description provided for @practiceThisLesson.
  ///
  /// In ar, this message translates to:
  /// **'تدرّب على هذا الدرس'**
  String get practiceThisLesson;

  /// No description provided for @practiceReset.
  ///
  /// In ar, this message translates to:
  /// **'مسح نتائج التدريب'**
  String get practiceReset;

  /// No description provided for @practiceResetConfirm.
  ///
  /// In ar, this message translates to:
  /// **'ستُمسح نتائج التدريب فقط. تبقى العلامات والملاحظات وتقدّم القراءة كما هي.'**
  String get practiceResetConfirm;

  /// No description provided for @quizProgress.
  ///
  /// In ar, this message translates to:
  /// **'السؤال {current} من {total}'**
  String quizProgress(String current, String total);

  /// No description provided for @quizSupplementary.
  ///
  /// In ar, this message translates to:
  /// **'سؤال إضافي، ليس من نص الكتاب.'**
  String get quizSupplementary;

  /// No description provided for @quizIdentifyPrompt.
  ///
  /// In ar, this message translates to:
  /// **'ما الحكم في الحروف الملوّنة؟'**
  String get quizIdentifyPrompt;

  /// No description provided for @quizTrueFalsePrompt.
  ///
  /// In ar, this message translates to:
  /// **'صواب أم خطأ؟'**
  String get quizTrueFalsePrompt;

  /// No description provided for @quizTrue.
  ///
  /// In ar, this message translates to:
  /// **'صواب'**
  String get quizTrue;

  /// No description provided for @quizFalse.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get quizFalse;

  /// A number of counts (harakat). {value} localized.
  ///
  /// In ar, this message translates to:
  /// **'{value} حركات'**
  String quizCounts(String value);

  /// No description provided for @quizFeedbackCorrect.
  ///
  /// In ar, this message translates to:
  /// **'إجابة صحيحة'**
  String get quizFeedbackCorrect;

  /// No description provided for @quizFeedbackIncorrect.
  ///
  /// In ar, this message translates to:
  /// **'ليست هذه الإجابة'**
  String get quizFeedbackIncorrect;

  /// Accessibility value of the correct option
  ///
  /// In ar, this message translates to:
  /// **'الإجابة الصحيحة'**
  String get quizCorrectAnswer;

  /// Accessibility value of the chosen wrong option
  ///
  /// In ar, this message translates to:
  /// **'إجابتك'**
  String get quizYourAnswer;

  /// No description provided for @quizReviewRule.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة القاعدة'**
  String get quizReviewRule;

  /// No description provided for @quizOpenLesson.
  ///
  /// In ar, this message translates to:
  /// **'الدرس'**
  String get quizOpenLesson;

  /// No description provided for @quizNext.
  ///
  /// In ar, this message translates to:
  /// **'السؤال التالي'**
  String get quizNext;

  /// No description provided for @quizSeeResult.
  ///
  /// In ar, this message translates to:
  /// **'عرض النتيجة'**
  String get quizSeeResult;

  /// No description provided for @quizFinished.
  ///
  /// In ar, this message translates to:
  /// **'أحسنت المتابعة'**
  String get quizFinished;

  /// No description provided for @quizScore.
  ///
  /// In ar, this message translates to:
  /// **'أصبت في {correct} من {total}'**
  String quizScore(String correct, String total);

  /// No description provided for @quizFinishedHint.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر الأسئلة التي أخطأت فيها أولًا في المرة القادمة.'**
  String get quizFinishedHint;

  /// Button: a short practice session across all lessons
  ///
  /// In ar, this message translates to:
  /// **'تدريب سريع'**
  String get practiceQuick;

  /// {count} is localized
  ///
  /// In ar, this message translates to:
  /// **'{count} أسئلة من كل الدروس، تبدأ بما أخطأت فيه سابقًا.'**
  String practiceQuickHint(String count);

  /// Button: practise only questions answered wrongly last time. {count} is localized
  ///
  /// In ar, this message translates to:
  /// **'راجع أخطائي ({count})'**
  String practiceMistakes(String count);

  /// Card at the end of a lesson
  ///
  /// In ar, this message translates to:
  /// **'اختبر فهمك'**
  String get lessonCheckTitle;

  /// {count} is localized
  ///
  /// In ar, this message translates to:
  /// **'{count} أسئلة قصيرة على هذا الدرس'**
  String lessonCheckBody(String count);

  /// Button: start the end-of-lesson check
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get lessonCheckStart;

  /// Shown after the learner marks the lesson completed from the quiz result
  ///
  /// In ar, this message translates to:
  /// **'أحسنت! سُجّل الدرس مكتملًا.'**
  String get quizLessonCompleted;

  /// Sort questions: how to play
  ///
  /// In ar, this message translates to:
  /// **'اختر حرفًا ثم المجموعة التي ينتمي إليها.'**
  String get quizSortHint;

  /// Button: check a sort answer
  ///
  /// In ar, this message translates to:
  /// **'تحقّق'**
  String get quizCheck;

  /// Semantics hint on a placed letter
  ///
  /// In ar, this message translates to:
  /// **'اضغط لإعادته'**
  String get quizSortReturn;

  /// Button: start another practice session
  ///
  /// In ar, this message translates to:
  /// **'جولة أخرى'**
  String get quizPracticeAgain;

  /// Heading above the questions missed in this session
  ///
  /// In ar, this message translates to:
  /// **'للمراجعة'**
  String get quizMissedHeading;

  /// Shown when every answer in the session was correct
  ///
  /// In ar, this message translates to:
  /// **'كلها صحيحة، أحسنت!'**
  String get quizPerfect;

  /// No description provided for @searchTitle.
  ///
  /// In ar, this message translates to:
  /// **'البحث'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن موضوع أو قاعدة أو مصطلح'**
  String get searchHint;

  /// Honest description of search coverage
  ///
  /// In ar, this message translates to:
  /// **'يبحث في عناوين الموضوعات وأسماء القواعد والمصطلحات بالّلغات الأربع. أما نص الصفحات فيُبحث فيه في النسختين الإنجليزية والإندونيسية فقط، لأن نص النسختين العربية والكردية لا يُستخرج بدقة.'**
  String get searchCoverage;

  /// No description provided for @searchLessons.
  ///
  /// In ar, this message translates to:
  /// **'الموضوعات'**
  String get searchLessons;

  /// No description provided for @searchRules.
  ///
  /// In ar, this message translates to:
  /// **'بطاقات القواعد'**
  String get searchRules;

  /// No description provided for @searchPagesIn.
  ///
  /// In ar, this message translates to:
  /// **'صفحات من {edition}'**
  String searchPagesIn(String edition);

  /// No description provided for @searchPagesNote.
  ///
  /// In ar, this message translates to:
  /// **'وُجدت الكلمة في نص هذه الصفحات؛ موضعها داخل الصفحة غير محدد.'**
  String get searchPagesNote;

  /// No description provided for @searchMatched.
  ///
  /// In ar, this message translates to:
  /// **'يطابق: {text}'**
  String searchMatched(String text);

  /// No description provided for @searchNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا نتائج لـ«{query}»'**
  String searchNoResults(String query);

  /// No description provided for @searchNoResultsHint.
  ///
  /// In ar, this message translates to:
  /// **'جرّب اسم الحكم أو جزءًا منه، مثل: الإخفاء، القلقلة، المد.'**
  String get searchNoResultsHint;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageHint.
  ///
  /// In ar, this message translates to:
  /// **'تتغير الواجهة ونسخة الكتاب معًا. يُحفظ موضع القراءة في كل نسخة على حدة، ويُنقل الدرس الحالي إلى ما يقابله.'**
  String get settingsLanguageHint;

  /// No description provided for @settingsStudy.
  ///
  /// In ar, this message translates to:
  /// **'الدراسة'**
  String get settingsStudy;

  /// No description provided for @settingsStreak.
  ///
  /// In ar, this message translates to:
  /// **'عدّاد الأيام المتتالية'**
  String get settingsStreak;

  /// No description provided for @settingsStreakHint.
  ///
  /// In ar, this message translates to:
  /// **'خيار هادئ يظهر في الرئيسية.'**
  String get settingsStreakHint;

  /// No description provided for @settingsHaptics.
  ///
  /// In ar, this message translates to:
  /// **'الاهتزاز عند اللمس'**
  String get settingsHaptics;

  /// No description provided for @settingsHapticsHint.
  ///
  /// In ar, this message translates to:
  /// **'اهتزاز خفيف عند تغيير القسم، وتعليم الدرس مكتملًا، والإجابة في التدريب.'**
  String get settingsHapticsHint;

  /// No description provided for @settingsReminder.
  ///
  /// In ar, this message translates to:
  /// **'تذكير يومي'**
  String get settingsReminder;

  /// No description provided for @settingsReminderHint.
  ///
  /// In ar, this message translates to:
  /// **'إشعار واحد كل يوم في الوقت الذي تختاره. يُجدوَل على جهازك ولا يُرسل شيء إلى أي جهة.'**
  String get settingsReminderHint;

  /// No description provided for @settingsReminderTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت التذكير'**
  String get settingsReminderTime;

  /// No description provided for @settingsReminderDenied.
  ///
  /// In ar, this message translates to:
  /// **'لم يُسمح بالإشعارات. يمكنك السماح بها من إعدادات الجهاز ثم تفعيل التذكير.'**
  String get settingsReminderDenied;

  /// Text of the daily reminder notification
  ///
  /// In ar, this message translates to:
  /// **'حان وقت وِردك من التجويد. تابع درسك من حيث توقفت.'**
  String get reminderBody;

  /// Android notification channel name
  ///
  /// In ar, this message translates to:
  /// **'التذكير اليومي'**
  String get reminderChannel;

  /// Entry that opens the whole book for browsing
  ///
  /// In ar, this message translates to:
  /// **'الكتاب كاملًا'**
  String get bookTitle;

  /// {edition} localized edition name
  ///
  /// In ar, this message translates to:
  /// **'تصفّح صفحات {edition} كاملةً كمرجع'**
  String bookSubtitle(String edition);

  /// No description provided for @settingsOffline.
  ///
  /// In ar, this message translates to:
  /// **'تعمل الكتب الأربعة وأدوات الدراسة دون اتصال بالإنترنت، ولا يلزم إنشاء حساب. إرسال الملاحظات وتحويل مبالغ الدعم يتمّان عبر خدمات خارجية.'**
  String get settingsOffline;

  /// Primary button: open the native lesson text
  ///
  /// In ar, this message translates to:
  /// **'اقرأ الدرس'**
  String get lessonRead;

  /// Opens the original PDF pages
  ///
  /// In ar, this message translates to:
  /// **'الصفحات الأصلية'**
  String get lessonOriginalPages;

  /// Marker before content taken from a book page. {page} localized.
  ///
  /// In ar, this message translates to:
  /// **'من صفحة {page}'**
  String lessonFromPage(String page);

  /// No description provided for @lessonViewInBook.
  ///
  /// In ar, this message translates to:
  /// **'اعرضها في الكتاب'**
  String get lessonViewInBook;

  /// No description provided for @lessonSourceNote.
  ///
  /// In ar, this message translates to:
  /// **'هذا النص منقول من صفحات {edition}. الصفحات الأصلية هي المرجع.'**
  String lessonSourceNote(String edition);

  /// Shown in preview builds on unreviewed lesson text
  ///
  /// In ar, this message translates to:
  /// **'لم يُراجَع هذا النقل بعد؛ عند أي اختلاف فالمعتمد هو الصفحة الأصلية.'**
  String get lessonUnderReview;

  /// Accessibility label of a book illustration
  ///
  /// In ar, this message translates to:
  /// **'رسمٌ توضيحيٌّ من الكتاب، انقر للتكبير'**
  String get lessonFigure;

  /// Title of the sheet showing the full verse of an excerpt
  ///
  /// In ar, this message translates to:
  /// **'الآية كاملة'**
  String get lessonFullVerse;

  /// Accessibility hint on a Qur'anic example
  ///
  /// In ar, this message translates to:
  /// **'انقر لعرض الآية كاملة'**
  String get lessonQuranTapHint;

  /// Button/sheet title: list of the lesson's sections
  ///
  /// In ar, this message translates to:
  /// **'محتويات الدرس'**
  String get lessonContents;

  /// Heading at the end of a lesson
  ///
  /// In ar, this message translates to:
  /// **'نهاية الدرس'**
  String get lessonEnd;

  /// No description provided for @lessonPrevious.
  ///
  /// In ar, this message translates to:
  /// **'الدرس السابق'**
  String get lessonPrevious;

  /// No description provided for @lessonNext.
  ///
  /// In ar, this message translates to:
  /// **'الدرس التالي'**
  String get lessonNext;

  /// No description provided for @searchInLessons.
  ///
  /// In ar, this message translates to:
  /// **'في نصوص الدروس'**
  String get searchInLessons;

  /// Search coverage when lesson text is available
  ///
  /// In ar, this message translates to:
  /// **'يبحث في نصوص الدروس وعناوين الموضوعات وأسماء القواعد والمصطلحات بالّلغات الأربع، وفي نص صفحات النسختين الإنجليزية والإندونيسية.'**
  String get searchCoverageWithLessons;

  /// No description provided for @aboutTitle.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In ar, this message translates to:
  /// **'رفيق لدراسة التجويد مبني حول كتب «تبسيط التجويد – المستوى الثاني». تُعرض الكتب الأصلية كما هي، وتحيط بها أدوات للتصفح والمراجعة والتدريب.'**
  String get aboutBody;

  /// No description provided for @aboutBooks.
  ///
  /// In ar, this message translates to:
  /// **'الكتب'**
  String get aboutBooks;

  /// No description provided for @aboutAuthor.
  ///
  /// In ar, this message translates to:
  /// **'المؤلف: {name}'**
  String aboutAuthor(String name);

  /// No description provided for @aboutTranslator.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة: {name}'**
  String aboutTranslator(String name);

  /// Quotes the authors' distribution condition
  ///
  /// In ar, this message translates to:
  /// **'ينص الكتاب على أن «حق النشر متاح للجميع ما دام بعيدًا عن الزيادة أو النقصان».'**
  String get aboutDistribution;

  /// No description provided for @aboutUnchanged.
  ///
  /// In ar, this message translates to:
  /// **'تُعرض الصفحات دون أي إضافة أو حذف. النسخ المضمّنة مضغوطة بنيويًّا فقط، وقد تحقق أن عرضها مطابق للأصل بكسلًا بكسل.'**
  String get aboutUnchanged;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'لا يحتوي «جَوِّد» على إحصاءات استخدام أو تتبّع. تبقى بيانات التعلم وسجل البحث والمفضلة والإعدادات على جهازك. يمكنك نسخ بياناتك، بما فيها الملاحظات، إلى الحافظة وحفظها خارج التطبيق؛ وتبقى النسخ الخارجية بعد حذف التطبيق. تفتح الملاحظات المرسلة تطبيق البريد، وتفتح روابط الدعم تطبيق دفع أو موقعًا خارجيًا. تتعامل تلك الخدمات مع ما تختار إرساله وفق سياساتها الخاصة.'**
  String get aboutPrivacy;

  /// No description provided for @aboutQuranText.
  ///
  /// In ar, this message translates to:
  /// **'النص القرآني'**
  String get aboutQuranText;

  /// No description provided for @aboutTanzil.
  ///
  /// In ar, this message translates to:
  /// **'الأمثلة القرآنية في الدروس وبطاقات القواعد والتدريب منقولة حرفيًّا من نص مشروع تنزيل (الرسم العثماني، الإصدار 1.1، tanzil.net) ومراجعها محققة آليًّا.'**
  String get aboutTanzil;

  /// No description provided for @aboutSupplementary.
  ///
  /// In ar, this message translates to:
  /// **'المواد الإضافية'**
  String get aboutSupplementary;

  /// No description provided for @aboutSupplementaryBody.
  ///
  /// In ar, this message translates to:
  /// **'نصوص الدروس وبطاقات القواعد وأسئلة التدريب ومستكشف المخارج مبنية على نصوص الكتب، وتُراجَع قبل اعتمادها للإصدار.'**
  String get aboutSupplementaryBody;

  /// No description provided for @aboutFonts.
  ///
  /// In ar, this message translates to:
  /// **'الخطوط'**
  String get aboutFonts;

  /// No description provided for @aboutFontsBody.
  ///
  /// In ar, this message translates to:
  /// **'Noto Naskh Arabic وNoto Sans Arabic وAmiri وAmiri Quran وLiterata وInter، جميعها بترخيص SIL Open Font License 1.1. خطوط الكتب الأصلية لا تُوزَّع مع التطبيق.'**
  String get aboutFontsBody;

  /// No description provided for @aboutLicenses.
  ///
  /// In ar, this message translates to:
  /// **'التراخيص'**
  String get aboutLicenses;

  /// No description provided for @aboutContentVersion.
  ///
  /// In ar, this message translates to:
  /// **'إصدار المحتوى: {version}'**
  String aboutContentVersion(String version);

  /// No description provided for @feedbackTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرسل ملاحظاتك'**
  String get feedbackTitle;

  /// No description provided for @feedbackIntro.
  ///
  /// In ar, this message translates to:
  /// **'وجدت مشكلة أو لديك اقتراح؟ اكتب للمطوّر. سيُفتح تطبيق بريدك لتراجع الرسالة وترسلها بنفسك.'**
  String get feedbackIntro;

  /// No description provided for @feedbackSubject.
  ///
  /// In ar, this message translates to:
  /// **'الموضوع'**
  String get feedbackSubject;

  /// No description provided for @feedbackMessage.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظاتك'**
  String get feedbackMessage;

  /// No description provided for @feedbackRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى ملء هذا الحقل.'**
  String get feedbackRequired;

  /// No description provided for @feedbackSend.
  ///
  /// In ar, this message translates to:
  /// **'فتح تطبيق البريد'**
  String get feedbackSend;

  /// No description provided for @feedbackFallback.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح تطبيق البريد. انسخ رسالتك وأرسلها إلى العنوان أدناه.'**
  String get feedbackFallback;

  /// No description provided for @feedbackCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الرسالة'**
  String get feedbackCopy;

  /// No description provided for @contactCopyEmail.
  ///
  /// In ar, this message translates to:
  /// **'نسخ عنوان البريد'**
  String get contactCopyEmail;

  /// No description provided for @contactCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get contactCopied;

  /// No description provided for @supportTitle.
  ///
  /// In ar, this message translates to:
  /// **'ادعمني بفنجان قهوة'**
  String get supportTitle;

  /// No description provided for @supportIntro.
  ///
  /// In ar, this message translates to:
  /// **'إذا أفادك جوِّد، يمكنك إرسال هدية اختيارية لدعم المطوّر. تظل جميع مزايا التعلّم مجانية، ولا تفتح الهدايا أي محتوى أو مزايا إضافية.'**
  String get supportIntro;

  /// No description provided for @supportTransfer.
  ///
  /// In ar, this message translates to:
  /// **'اختر إنستاباي أو أرسل إلى إحدى محفظتي الهاتف في مصر أدناه.'**
  String get supportTransfer;

  /// No description provided for @supportVerify.
  ///
  /// In ar, this message translates to:
  /// **'تحقّق من اسم المستلم وأي رسوم في تطبيق الدفع قبل التأكيد. تتم التحويلات عبر مزوّد الدفع؛ لا يستطيع جوِّد تأكيدها أو استردادها.'**
  String get supportVerify;

  /// No description provided for @supportCopyNumber.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الرقم'**
  String get supportCopyNumber;

  /// No description provided for @supportOpenInstapay.
  ///
  /// In ar, this message translates to:
  /// **'فتح إنستاباي'**
  String get supportOpenInstapay;

  /// No description provided for @supportCopyAddress.
  ///
  /// In ar, this message translates to:
  /// **'نسخ عنوان الدفع'**
  String get supportCopyAddress;

  /// No description provided for @supportLinkFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح إنستاباي. انسخ عنوان الدفع واستخدمه في تطبيق الدفع.'**
  String get supportLinkFailed;

  /// No description provided for @supportEtisalat.
  ///
  /// In ar, this message translates to:
  /// **'اتصالات كاش'**
  String get supportEtisalat;

  /// No description provided for @supportVodafone.
  ///
  /// In ar, this message translates to:
  /// **'فودافون كاش'**
  String get supportVodafone;

  /// No description provided for @practiceLength.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأسئلة'**
  String get practiceLength;

  /// No description provided for @practiceDue.
  ///
  /// In ar, this message translates to:
  /// **'راجع الأسئلة المستحقة'**
  String get practiceDue;

  /// No description provided for @backupTitle.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي والاستعادة'**
  String get backupTitle;

  /// No description provided for @backupIntro.
  ///
  /// In ar, this message translates to:
  /// **'احفظ ملف نسخة احتياطية في مكان خاص، أو انسخ نص النسخة. تشمل النسخة ملاحظاتك وتقدّمك. للاستعادة افتح ملف النسخة أو الصق نصّها أدناه.'**
  String get backupIntro;

  /// No description provided for @backupCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ البيانات'**
  String get backupCopy;

  /// No description provided for @backupRestore.
  ///
  /// In ar, this message translates to:
  /// **'استعادة البيانات'**
  String get backupRestore;

  /// No description provided for @backupConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تستبدل الإعدادات والملاحظات والتقدم الحالي بهذه النسخة؟'**
  String get backupConfirm;

  /// No description provided for @backupInvalid.
  ///
  /// In ar, this message translates to:
  /// **'هذه النسخة غير صالحة أو من إصدار غير مدعوم.'**
  String get backupInvalid;

  /// No description provided for @backupRestored.
  ///
  /// In ar, this message translates to:
  /// **'تمت استعادة البيانات.'**
  String get backupRestored;

  /// No description provided for @dailySession.
  ///
  /// In ar, this message translates to:
  /// **'اليوم: جلسة تعلّم قصيرة'**
  String get dailySession;

  /// No description provided for @practiceAllTopics.
  ///
  /// In ar, this message translates to:
  /// **'تدرّب على جميع الموضوعات'**
  String get practiceAllTopics;

  /// No description provided for @weeklyLearningGoal.
  ///
  /// In ar, this message translates to:
  /// **'هدف التعلم الأسبوعي'**
  String get weeklyLearningGoal;

  /// No description provided for @weeklyLearningDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام التعلم هذا الأسبوع'**
  String get weeklyLearningDays;

  /// No description provided for @practiceResume.
  ///
  /// In ar, this message translates to:
  /// **'تابع التدريب المحفوظ'**
  String get practiceResume;

  /// No description provided for @searchRecent.
  ///
  /// In ar, this message translates to:
  /// **'عمليات البحث الأخيرة'**
  String get searchRecent;

  /// No description provided for @searchClearHistory.
  ///
  /// In ar, this message translates to:
  /// **'مسح سجل البحث'**
  String get searchClearHistory;

  /// No description provided for @ruleFavorite.
  ///
  /// In ar, this message translates to:
  /// **'حفظ القاعدة أو إزالتها من المفضلة'**
  String get ruleFavorite;

  /// No description provided for @ruleFavorites.
  ///
  /// In ar, this message translates to:
  /// **'القواعد المفضلة'**
  String get ruleFavorites;

  /// No description provided for @notesOpenSection.
  ///
  /// In ar, this message translates to:
  /// **'افتح قسم الدرس'**
  String get notesOpenSection;

  /// No description provided for @notesSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الملاحظة'**
  String get notesSaved;

  /// No description provided for @ruleCompare.
  ///
  /// In ar, this message translates to:
  /// **'قارن القواعد'**
  String get ruleCompare;

  /// No description provided for @ruleCompareFirst.
  ///
  /// In ar, this message translates to:
  /// **'القاعدة الأولى'**
  String get ruleCompareFirst;

  /// No description provided for @ruleCompareSecond.
  ///
  /// In ar, this message translates to:
  /// **'القاعدة الثانية'**
  String get ruleCompareSecond;

  /// No description provided for @ruleCompareUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج المقارنة إلى بطاقتين مراجعتين. يمكنك قراءة الكتاب الأصلي في الوقت الحالي.'**
  String get ruleCompareUnavailable;

  /// No description provided for @learningIntent.
  ///
  /// In ar, this message translates to:
  /// **'كيف تودّ أن تتعلّم؟'**
  String get learningIntent;

  /// No description provided for @learningIntentHint.
  ///
  /// In ar, this message translates to:
  /// **'اختياري. يمكنك تغييره في الإعدادات.'**
  String get learningIntentHint;

  /// No description provided for @learningGuided.
  ///
  /// In ar, this message translates to:
  /// **'خطوة بخطوة'**
  String get learningGuided;

  /// No description provided for @learningRevision.
  ///
  /// In ar, this message translates to:
  /// **'المراجعة'**
  String get learningRevision;

  /// No description provided for @learningExplore.
  ///
  /// In ar, this message translates to:
  /// **'استكشف الموضوعات'**
  String get learningExplore;

  /// No description provided for @lessonReviewOutline.
  ///
  /// In ar, this message translates to:
  /// **'راجع أقسام الدرس'**
  String get lessonReviewOutline;

  /// No description provided for @lessonReadingTime.
  ///
  /// In ar, this message translates to:
  /// **'نحو {minutes} دقائق للقراءة'**
  String lessonReadingTime(String minutes);

  /// No description provided for @practiceDelayedReview.
  ///
  /// In ar, this message translates to:
  /// **'أسئلة أُجيب عنها بشكل صحيح بعد فترة: {count}'**
  String practiceDelayedReview(String count);

  /// No description provided for @startupLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ فتح مواد التعلم…'**
  String get startupLoading;

  /// No description provided for @startupFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح جَوِّد. حاول مرة أخرى. لم تتم إعادة تعيين بياناتك المحفوظة.'**
  String get startupFailed;

  /// No description provided for @startupUpdateRequired.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت بياناتك بإصدار أحدث. حدّث جَوِّد للمتابعة.'**
  String get startupUpdateRequired;

  /// No description provided for @startupRetry.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get startupRetry;

  /// No description provided for @backupRecoveryIntro.
  ///
  /// In ar, this message translates to:
  /// **'الصق نسخة احتياطية لاستعادة بياناتك. ستستبدل الموافقة البيانات المحفوظة التي تعذّر قراءتها. يبقى التذكير متوقفًا حتى تفعّله من الإعدادات.'**
  String get backupRecoveryIntro;

  /// No description provided for @backupWriteFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ البيانات المستعادة. تحقّق من مساحة التخزين وحاول مرة أخرى.'**
  String get backupWriteFailed;

  /// No description provided for @savePending.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ حفظ تغييراتك…'**
  String get savePending;

  /// No description provided for @saveFailed.
  ///
  /// In ar, this message translates to:
  /// **'لم تُحفظ تغييراتك الأخيرة. أبقِ التطبيق مفتوحًا وحاول مجددًا.'**
  String get saveFailed;

  /// No description provided for @settingsReminderFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديث التذكير. تحقّق من إعدادات الإشعارات وحاول مجددًا.'**
  String get settingsReminderFailed;

  /// No description provided for @actionUndo.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get actionUndo;

  /// No description provided for @noteDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذفت الملاحظة'**
  String get noteDeleted;

  /// No description provided for @bookmarkDeleted.
  ///
  /// In ar, this message translates to:
  /// **'أُزيلت العلامة'**
  String get bookmarkDeleted;

  /// No description provided for @backupSaveFile.
  ///
  /// In ar, this message translates to:
  /// **'حفظ ملف نسخة احتياطية'**
  String get backupSaveFile;

  /// No description provided for @backupOpenFile.
  ///
  /// In ar, this message translates to:
  /// **'فتح ملف نسخة احتياطية'**
  String get backupOpenFile;

  /// No description provided for @backupFileSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ ملف النسخة الاحتياطية.'**
  String get backupFileSaved;

  /// No description provided for @backupFileError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح ملف النسخة الاحتياطية أو حفظه. حاول مجددًا.'**
  String get backupFileError;

  /// No description provided for @backupSummary.
  ///
  /// In ar, this message translates to:
  /// **'نسخة بتاريخ {date}: {notes} ملاحظات و{bookmarks} علامات.'**
  String backupSummary(String date, String notes, String bookmarks);

  /// No description provided for @backupUnknownDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ غير معروف'**
  String get backupUnknownDate;

  /// No description provided for @feedbackDetails.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق تفاصيل التطبيق والمحتوى'**
  String get feedbackDetails;

  /// No description provided for @feedbackDetailsHint.
  ///
  /// In ar, this message translates to:
  /// **'لن تُرفق ملاحظاتك أو إجاباتك.'**
  String get feedbackDetailsHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'ckb', 'en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ckb':
      return AppLocalizationsCkb();
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
