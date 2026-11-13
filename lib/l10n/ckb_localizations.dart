// Framework localizations for Central Kurdish (Sorani, `ckb`).
//
// The installed Flutter SDK (3.44.8) ships no `ckb` resources in
// flutter_localizations (no material_ckb.arb / cupertino_ckb.arb /
// widgets_ckb.arb), and the `intl` package has no `ckb` date or number data.
// Declaring `Locale('ckb')` alone would therefore leave Material widgets
// without localizations and with left-to-right layout. These delegates supply:
//   * right-to-left text direction,
//   * Kurdish strings for every user-facing framework label, tooltip and
//     accessibility announcement,
//   * Arabic-Indic digits, matching the numerals printed in the Kurdish book.
//
// Keyboard key-cap names (used only for hardware-keyboard shortcut hints) keep
// the framework defaults.
//
// All wording here is newly written and must be reviewed by a fluent Sorani
// speaker before release (see docs/release-dependencies.md).

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/numerals.dart';

String _d(Object value) => localizeDigits(value.toString(), 'ckb');

const _months = [
  'کانوونی دووەم',
  'شوبات',
  'ئازار',
  'نیسان',
  'ئایار',
  'حوزەیران',
  'تەمموز',
  'ئاب',
  'ئەیلوول',
  'تشرینی یەکەم',
  'تشرینی دووەم',
  'کانوونی یەکەم',
];
// DateTime.weekday: 1 = Monday … 7 = Sunday.
const _weekdays = [
  'دووشەممە',
  'سێشەممە',
  'چوارشەممە',
  'پێنجشەممە',
  'هەینی',
  'شەممە',
  'یەکشەممە',
];

class CkbWidgetsLocalizations extends DefaultWidgetsLocalizations {
  const CkbWidgetsLocalizations();

  static const LocalizationsDelegate<WidgetsLocalizations> delegate =
      _CkbDelegate<WidgetsLocalizations>(CkbWidgetsLocalizations());

  @override
  TextDirection get textDirection => TextDirection.rtl;
  @override
  String get reorderItemUp => 'بیبە بۆ سەرەوە';
  @override
  String get reorderItemDown => 'بیبە بۆ خوارەوە';
  @override
  String get reorderItemLeft => 'بیبە بۆ چەپ';
  @override
  String get reorderItemRight => 'بیبە بۆ ڕاست';
  @override
  String get reorderItemToEnd => 'بیبە بۆ کۆتایی';
  @override
  String get reorderItemToStart => 'بیبە بۆ سەرەتا';
  @override
  String get searchResultsFound => 'ئەنجامی گەڕان دۆزرایەوە';
  @override
  String get noResultsFound => 'هیچ ئەنجامێک نەدۆزرایەوە';
  @override
  String get copyButtonLabel => 'لەبەرگرتنەوە';
  @override
  String get cutButtonLabel => 'بڕین';
  @override
  String get pasteButtonLabel => 'لکاندن';
  @override
  String get selectAllButtonLabel => 'دیاریکردنی هەموو';
  @override
  String get lookUpButtonLabel => 'سەیرکردن';
  @override
  String get searchWebButtonLabel => 'گەڕان لە وێب';
  @override
  String get shareButtonLabel => 'هاوبەشکردن';
  @override
  String get radioButtonUnselectedLabel => 'دیاری نەکراوە';
}

class CkbMaterialLocalizations extends DefaultMaterialLocalizations {
  const CkbMaterialLocalizations();

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _CkbDelegate<MaterialLocalizations>(CkbMaterialLocalizations());

  @override
  ScriptCategory get scriptCategory => ScriptCategory.tall;

  @override
  String get openAppDrawerTooltip => 'کردنەوەی لیستی ڕێنیشاندەر';
  @override
  String get backButtonTooltip => 'گەڕانەوە';
  @override
  String get clearButtonTooltip => 'سڕینەوەی دەق';
  @override
  String get closeButtonTooltip => 'داخستن';
  @override
  String get deleteButtonTooltip => 'سڕینەوە';
  @override
  String get moreButtonTooltip => 'زیاتر';
  @override
  String get nextMonthTooltip => 'مانگی داهاتوو';
  @override
  String get previousMonthTooltip => 'مانگی پێشوو';
  @override
  String get firstPageTooltip => 'یەکەم لاپەڕە';
  @override
  String get lastPageTooltip => 'دوایین لاپەڕە';
  @override
  String get nextPageTooltip => 'لاپەڕەی داهاتوو';
  @override
  String get previousPageTooltip => 'لاپەڕەی پێشوو';
  @override
  String get showMenuTooltip => 'پیشاندانی لیست';
  @override
  String aboutListTileTitle(String applicationName) =>
      'دەربارەی $applicationName';
  @override
  String get licensesPageTitle => 'مۆڵەتەکان';
  @override
  String licensesPackageDetailText(int licenseCount) =>
      '${_d(licenseCount)} مۆڵەت';
  @override
  String pageRowsInfoTitle(
    int firstRow,
    int lastRow,
    int rowCount,
    bool rowCountIsApproximate,
  ) => rowCountIsApproximate
      ? '${_d(firstRow)}–${_d(lastRow)} لە نزیکەی ${_d(rowCount)}'
      : '${_d(firstRow)}–${_d(lastRow)} لە ${_d(rowCount)}';
  @override
  String get rowsPerPageTitle => 'ڕیز لە هەر لاپەڕەیەکدا:';
  @override
  String tabLabel({required int tabIndex, required int tabCount}) =>
      'تابی ${_d(tabIndex)} لە ${_d(tabCount)}';
  @override
  String selectedRowCountTitle(int selectedRowCount) =>
      '${_d(selectedRowCount)} دیاریکراو';
  @override
  String get cancelButtonLabel => 'پاشگەزبوونەوە';
  @override
  String get closeButtonLabel => 'داخستن';
  @override
  String get continueButtonLabel => 'بەردەوامبوون';
  @override
  String get copyButtonLabel => 'لەبەرگرتنەوە';
  @override
  String get cutButtonLabel => 'بڕین';
  @override
  String get scanTextButtonLabel => 'سکانکردنی دەق';
  @override
  String get okButtonLabel => 'باشە';
  @override
  String get pasteButtonLabel => 'لکاندن';
  @override
  String get selectAllButtonLabel => 'دیاریکردنی هەموو';
  @override
  String get lookUpButtonLabel => 'سەیرکردن';
  @override
  String get searchWebButtonLabel => 'گەڕان لە وێب';
  @override
  String get shareButtonLabel => 'هاوبەشکردن';
  @override
  String get viewLicensesButtonLabel => 'بینینی مۆڵەتەکان';
  @override
  String get anteMeridiemAbbreviation => 'پ.ن';
  @override
  String get postMeridiemAbbreviation => 'د.ن';
  @override
  String get timePickerHourModeAnnouncement => 'کاتژمێر هەڵبژێرە';
  @override
  String get timePickerMinuteModeAnnouncement => 'خولەک هەڵبژێرە';
  @override
  String get modalBarrierDismissLabel => 'داخستن';
  @override
  String get menuDismissLabel => 'داخستنی لیست';
  @override
  String get drawerLabel => 'لیستی ڕێنیشاندەر';
  @override
  String get popupMenuLabel => 'لیستی دەرکەوتوو';
  @override
  String get menuBarMenuLabel => 'لیستی شریتی لیست';
  @override
  String get dialogLabel => 'دیالۆگ';
  @override
  String get alertDialogLabel => 'ئاگاداری';
  @override
  String get searchFieldLabel => 'گەڕان';
  @override
  String get currentDateLabel => 'ئەمڕۆ';
  @override
  String get selectedDateLabel => 'دیاریکراو';
  @override
  String get scrimLabel => 'پەردە';
  @override
  String get bottomSheetLabel => 'پەڕەی خوارەوە';
  @override
  String scrimOnTapHint(String modalRouteContentName) =>
      'داخستنی $modalRouteContentName';

  @override
  String formatDecimal(int number) =>
      _d(super.formatDecimal(number).replaceAll(',', '٬'));
  @override
  String formatHour(
    TimeOfDay timeOfDay, {
    bool alwaysUse24HourFormat = false,
  }) => _d(
    super.formatHour(timeOfDay, alwaysUse24HourFormat: alwaysUse24HourFormat),
  );
  @override
  String formatMinute(TimeOfDay timeOfDay) => _d(super.formatMinute(timeOfDay));
  @override
  String formatTimeOfDay(
    TimeOfDay timeOfDay, {
    bool alwaysUse24HourFormat = false,
  }) => _d(
    super.formatTimeOfDay(
      timeOfDay,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    ),
  );
  @override
  String formatYear(DateTime date) => _d(date.year);
  @override
  String formatCompactDate(DateTime date) =>
      _d('${date.day}/${date.month}/${date.year}');
  @override
  String formatShortDate(DateTime date) =>
      '${_d(date.day)}ی ${_months[date.month - 1]} ${_d(date.year)}';
  @override
  String formatMediumDate(DateTime date) =>
      '${_weekdays[date.weekday - 1]}، ${_d(date.day)}ی ${_months[date.month - 1]}';
  @override
  String formatFullDate(DateTime date) =>
      '${_weekdays[date.weekday - 1]}، ${_d(date.day)}ی ${_months[date.month - 1]}ی ${_d(date.year)}';
  @override
  String formatMonthYear(DateTime date) =>
      '${_months[date.month - 1]} ${_d(date.year)}';
  @override
  String formatShortMonthDay(DateTime date) =>
      '${_d(date.day)}ی ${_months[date.month - 1]}';
  @override
  List<String> get narrowWeekdays => const ['ی', 'د', 'س', 'چ', 'پ', 'ھ', 'ش'];
  @override
  int get firstDayOfWeekIndex => 6; // Saturday

  @override
  String get dateSeparator => '/';
  @override
  String get dateHelpText => 'ڕۆژ/مانگ/ساڵ';
  @override
  String get selectYearSemanticsLabel => 'ساڵ هەڵبژێرە';
  @override
  String get unspecifiedDate => 'بەروار';
  @override
  String get unspecifiedDateRange => 'ماوەی بەروار';
  @override
  String get dateInputLabel => 'بەروار بنووسە';
  @override
  String get dateRangeStartLabel => 'بەرواری دەستپێک';
  @override
  String get dateRangeEndLabel => 'بەرواری کۆتایی';
  @override
  String dateRangeStartDateSemanticLabel(String formattedDate) =>
      'بەرواری دەستپێک $formattedDate';
  @override
  String dateRangeEndDateSemanticLabel(String formattedDate) =>
      'بەرواری کۆتایی $formattedDate';
  @override
  String get invalidDateFormatLabel => 'شێوازی بەروار هەڵەیە.';
  @override
  String get invalidDateRangeLabel => 'ماوەکە هەڵەیە.';
  @override
  String get dateOutOfRangeLabel => 'لە دەرەوەی ماوەکەیە.';
  @override
  String get saveButtonLabel => 'پاشەکەوتکردن';
  @override
  String get datePickerHelpText => 'بەروار هەڵبژێرە';
  @override
  String get dateRangePickerHelpText => 'ماوە هەڵبژێرە';
  @override
  String get calendarModeButtonLabel => 'گۆڕین بۆ ڕۆژژمێر';
  @override
  String get inputDateModeButtonLabel => 'گۆڕین بۆ نووسین';
  @override
  String get timePickerDialHelpText => 'کات هەڵبژێرە';
  @override
  String get timePickerInputHelpText => 'کات بنووسە';
  @override
  String get timePickerHourLabel => 'کاتژمێر';
  @override
  String get timePickerMinuteLabel => 'خولەک';
  @override
  String get invalidTimeLabel => 'کاتێکی دروست بنووسە';
  @override
  String get dialModeButtonLabel => 'گۆڕین بۆ هەڵبژاردنی کاتژمێر';
  @override
  String get inputTimeModeButtonLabel => 'گۆڕین بۆ نووسینی دەق';
  @override
  String get signedInLabel => 'چوونەژوورەوە کراوە';
  @override
  String get hideAccountsLabel => 'شاردنەوەی هەژمارەکان';
  @override
  String get showAccountsLabel => 'پیشاندانی هەژمارەکان';
  @override
  String get reorderItemToStart => 'بیبە بۆ سەرەتا';
  @override
  String get reorderItemToEnd => 'بیبە بۆ کۆتایی';
  @override
  String get reorderItemUp => 'بیبە بۆ سەرەوە';
  @override
  String get reorderItemDown => 'بیبە بۆ خوارەوە';
  @override
  String get reorderItemLeft => 'بیبە بۆ چەپ';
  @override
  String get reorderItemRight => 'بیبە بۆ ڕاست';
  @override
  String get expandedIconTapHint => 'داخستنەوە';
  @override
  String get collapsedIconTapHint => 'کردنەوە';
  @override
  String get expansionTileExpandedHint => 'دوو جار لێی بدە بۆ داخستنەوە';
  @override
  String get expansionTileCollapsedHint => 'دوو جار لێی بدە بۆ کردنەوە';
  @override
  String get expansionTileExpandedTapHint => 'داخستنەوە';
  @override
  String get expansionTileCollapsedTapHint => 'کردنەوە بۆ وردەکاری زیاتر';
  @override
  String get expandedHint => 'داخراوەتەوە';
  @override
  String get collapsedHint => 'کراوەتەوە';
  @override
  String remainingTextFieldCharacterCount(int remaining) =>
      '${_d(remaining)} پیت ماوە';
  @override
  String get refreshIndicatorSemanticLabel => 'نوێکردنەوە';
}

class CkbCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const CkbCupertinoLocalizations();

  static const LocalizationsDelegate<CupertinoLocalizations> delegate =
      _CkbDelegate<CupertinoLocalizations>(CkbCupertinoLocalizations());

  @override
  String datePickerYear(int yearIndex) => _d(yearIndex);
  @override
  String datePickerMonth(int monthIndex) => _months[monthIndex - 1];
  @override
  String datePickerStandaloneMonth(int monthIndex) => _months[monthIndex - 1];
  @override
  String datePickerDayOfMonth(int dayIndex, [int? weekDay]) => weekDay == null
      ? _d(dayIndex)
      : '${_weekdays[weekDay - 1]} ${_d(dayIndex)}';
  @override
  String datePickerHour(int hour) => _d(hour);
  @override
  String datePickerHourSemanticsLabel(int hour) => 'کاتژمێر ${_d(hour)}';
  @override
  String datePickerMinute(int minute) => _d(minute.toString().padLeft(2, '0'));
  @override
  String datePickerMinuteSemanticsLabel(int minute) => '${_d(minute)} خولەک';
  @override
  String datePickerMediumDate(DateTime date) =>
      '${_weekdays[date.weekday - 1]} ${_d(date.day)}ی ${_months[date.month - 1]}';
  @override
  String get anteMeridiemAbbreviation => 'پ.ن';
  @override
  String get postMeridiemAbbreviation => 'د.ن';
  @override
  String get todayLabel => 'ئەمڕۆ';
  @override
  String get alertDialogLabel => 'ئاگاداری';
  @override
  String tabSemanticsLabel({required int tabIndex, required int tabCount}) =>
      'تابی ${_d(tabIndex)} لە ${_d(tabCount)}';
  @override
  String timerPickerHour(int hour) => _d(hour);
  @override
  String timerPickerMinute(int minute) => _d(minute);
  @override
  String timerPickerSecond(int second) => _d(second);
  @override
  String timerPickerHourLabel(int hour) => 'کاتژمێر';
  @override
  String timerPickerMinuteLabel(int minute) => 'خولەک';
  @override
  String timerPickerSecondLabel(int second) => 'چرکە';
  @override
  String get cutButtonLabel => 'بڕین';
  @override
  String get copyButtonLabel => 'لەبەرگرتنەوە';
  @override
  String get pasteButtonLabel => 'لکاندن';
  @override
  String get clearButtonLabel => 'سڕینەوە';
  @override
  String get noSpellCheckReplacementsLabel => 'هیچ جێگرەوەیەک نەدۆزرایەوە';
  @override
  String get selectAllButtonLabel => 'دیاریکردنی هەموو';
  @override
  String get lookUpButtonLabel => 'سەیرکردن';
  @override
  String get searchWebButtonLabel => 'گەڕان لە وێب';
  @override
  String get shareButtonLabel => 'هاوبەشکردن...';
  @override
  String get searchTextFieldPlaceholderLabel => 'گەڕان';
  @override
  String get modalBarrierDismissLabel => 'داخستن';
  @override
  String get menuDismissLabel => 'داخستنی لیست';
  @override
  String get cancelButtonLabel => 'پاشگەزبوونەوە';
  @override
  String get backButtonLabel => 'گەڕانەوە';
  @override
  String get expansionTileExpandedHint => 'دوو جار لێی بدە بۆ داخستنەوە';
  @override
  String get expansionTileCollapsedHint => 'دوو جار لێی بدە بۆ کردنەوە';
  @override
  String get expansionTileExpandedTapHint => 'داخستنەوە';
  @override
  String get expansionTileCollapsedTapHint => 'کردنەوە بۆ وردەکاری زیاتر';
  @override
  String get expandedHint => 'داخراوەتەوە';
  @override
  String get collapsedHint => 'کراوەتەوە';
}

class _CkbDelegate<T> extends LocalizationsDelegate<T> {
  const _CkbDelegate(this.value);
  final T value;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<T> load(Locale locale) => SynchronousFuture<T>(value);

  @override
  bool shouldReload(covariant LocalizationsDelegate<T> old) => false;

  @override
  String toString() => 'CkbLocalizations.delegate<$T>';
}

/// Delegates to place *before* the Global* delegates in MaterialApp.
const List<LocalizationsDelegate<dynamic>> ckbFrameworkDelegates = [
  CkbMaterialLocalizations.delegate,
  CkbCupertinoLocalizations.delegate,
  CkbWidgetsLocalizations.delegate,
];
