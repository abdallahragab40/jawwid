import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/content/content_repository.dart';

Map<String, dynamic> read(String name) =>
    jsonDecode(File('assets/content/$name.json').readAsStringSync())
        as Map<String, dynamic>;

ContentRepository partialRelease(bool approveOptions) {
  final quiz = read('quiz');
  final question = (quiz['questions'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((q) => q['type'] == 'identify');
  question['review'] = {'status': 'reviewed'};
  quiz['questions'] = [question];
  final rules = read('rules');
  for (final rule in rules['rules'] as List) {
    rule['review'] = {
      'status':
          approveOptions && (question['options'] as List).contains(rule['id'])
          ? 'reviewed'
          : 'draft',
    };
  }
  return ContentRepository.fromJson(
    editions: read('editions'),
    curriculum: read('curriculum'),
    rules: rules,
    quiz: quiz,
    makharij: read('makharij'),
    quran: read('quran'),
    searchTerms: read('search_terms'),
    searchPages: read('search_pages'),
    channel: ContentChannel.release,
  );
}

void main() {
  test(
    'a reviewed identify question waits until all answer cards are available',
    () {
      expect(partialRelease(false).questions, isEmpty);
      final ready = partialRelease(true);
      expect(ready.questions, hasLength(1));
      expect(
        ready.questions.single.ruleOptions.every(
          (id) => ready.rule(id) != null,
        ),
        isTrue,
      );
    },
  );
}
