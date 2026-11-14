import '../../content/models.dart';

/// A navigation/review outline drawn verbatim from the lesson's own headings.
List<(int, LessonBlock)> lessonOutline(Lesson lesson) => [
  for (final (index, block) in lesson.blocks.indexed)
    if (block.type == LessonBlockType.h1 || block.type == LessonBlockType.h2)
      (index, block),
];

/// Approximate reading effort, not a completion target or mastery measure.
/// Arabic-script text is also separated on whitespace; listening isn't timed.
int lessonReadingMinutes(Lesson lesson) {
  final words = lesson.blocks.fold<int>(
    0,
    (total, b) =>
        total +
        b.plain.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length,
  );
  return (words / 160).ceil().clamp(1, 180);
}
