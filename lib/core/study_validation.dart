import '../content/content_repository.dart';
import '../features/study/study_state.dart';

/// Checks navigable references before installing imported or restored state.
void validateStudyReferences(StudyState state, ContentRepository content) {
  void checkPage(String edition, int page) {
    final book = content.editions[edition];
    if (book == null || page < 1 || page > book.pageCount) {
      throw const FormatException('Unknown edition or invalid page');
    }
  }

  for (final entry in state.positions.entries) {
    checkPage(entry.key, entry.value);
  }
  for (final bookmark in state.bookmarks) {
    checkPage(bookmark.edition, bookmark.page);
  }
  for (final note in state.notes) {
    checkPage(note.edition, note.page);
  }
  final last = state.lastRead;
  if (last != null) {
    checkPage(last.edition, last.page);
    if (last.topicId != null && content.topicOrNull(last.topicId) == null) {
      throw const FormatException('Unknown last-read topic');
    }
  }
}
