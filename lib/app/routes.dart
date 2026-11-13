import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/curriculum/topic_screen.dart';
import '../features/lessons/lesson_screen.dart';
import '../features/makharij/makharij_screen.dart';
import '../features/practice/quiz_screen.dart';
import '../features/reader/reader_screen.dart';
import '../features/rules/rule_card_screen.dart';
import '../features/search/search_screen.dart';
import '../features/study/study_state.dart';

Future<void> openReader(
  BuildContext context, {
  required String edition,
  required int page,
}) => Navigator.of(context).push(
  MaterialPageRoute(
    settings: const RouteSettings(name: 'reader'),
    builder: (_) => ReaderScreen(edition: edition, initialPage: page),
  ),
);

/// Opens a topic: straight into its lesson text when the learner's edition
/// has one (the usual case). Otherwise — the topic is absent from the edition,
/// or its lesson is not yet approved for this build — the topic overview,
/// which explains why and links to the pages.
Future<void> openTopic(BuildContext context, String topicId) {
  final container = ProviderScope.containerOf(context, listen: false);
  final lang = container.read(languageProvider);
  if (container.read(contentProvider).lesson(topicId, lang.code) != null) {
    return openLesson(context, topicId);
  }
  return openTopicOverview(context, topicId);
}

Future<void> openTopicOverview(BuildContext context, String topicId) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: 'topic/$topicId'),
        builder: (_) => TopicScreen(topicId: topicId),
      ),
    );

/// The whole book of the learner's edition, as a reference: opens at the
/// remembered page, or at the first page.
Future<void> openBook(BuildContext context) {
  final container = ProviderScope.containerOf(context, listen: false);
  final ed = container.read(languageProvider).editionId;
  final page = container.read(studyProvider).positions[ed] ?? 1;
  return openReader(context, edition: ed, page: page);
}

Future<void> openRule(BuildContext context, String ruleId) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: 'rule/$ruleId'),
        builder: (_) => RuleCardScreen(ruleId: ruleId),
      ),
    );

Future<void> openQuiz(
  BuildContext context, {
  String? topicId,
  String? ruleId,
}) => Navigator.of(context).push(
  MaterialPageRoute(
    settings: const RouteSettings(name: 'quiz'),
    builder: (_) => QuizScreen(topicId: topicId, ruleId: ruleId),
  ),
);

Future<void> openMakharij(BuildContext context) => Navigator.of(context).push(
  MaterialPageRoute(
    settings: const RouteSettings(name: 'makharij'),
    builder: (_) => const MakharijScreen(),
  ),
);

Future<void> openSearch(BuildContext context) => Navigator.of(context).push(
  MaterialPageRoute(
    settings: const RouteSettings(name: 'search'),
    builder: (_) => const SearchScreen(),
  ),
);

Future<void> openLesson(BuildContext context, String topicId, {int? block}) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: 'lesson/$topicId'),
        builder: (_) => LessonScreen(topicId: topicId, scrollToBlock: block),
      ),
    );

/// Moves to another lesson in place (previous/next), so Back still returns
/// to where the learner came from instead of walking every lesson.
Future<void> replaceLesson(BuildContext context, String topicId) =>
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        settings: RouteSettings(name: 'lesson/$topicId'),
        builder: (_) => LessonScreen(topicId: topicId),
      ),
    );
