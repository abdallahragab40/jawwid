import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/json_store.dart';
import 'package:rattil/core/study_validation.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/content/language.dart';
import '../helpers.dart';

void main() {
  test(
    'typed corruption falls back and first recovery save preserves good backup',
    () {
      final dir = tempDir();
      addTearDown(() => dir.deleteSync(recursive: true));
      final store = JsonStore(dir);
      store.saveSync(
        const StudyState(
          language: AppLanguage.en,
          positions: {'en': 41},
        ).toJson(),
      );
      store.saveSync({'bookmarks': 123});
      final backup = File('${dir.path}/rattil_user_data.json.bak');
      final goodBackup = backup.readAsStringSync();
      final recovered = store.loadValidated(StudyState.fromJson);
      expect(recovered.language, AppLanguage.en);
      expect(recovered.positions['en'], 41);
      store.saveSync(recovered.toJson());
      expect(backup.readAsStringSync(), goodBackup);
      expect(
        JsonStore(dir).loadValidated(StudyState.fromJson).language,
        AppLanguage.en,
      );
    },
  );

  test(
    'both invalid files cause a recoverable error without changing either file',
    () {
      final dir = tempDir();
      addTearDown(() => dir.deleteSync(recursive: true));
      final main = File('${dir.path}/rattil_user_data.json')
        ..writeAsStringSync('{bad');
      final backup = File('${main.path}.bak')..writeAsStringSync('[1,2]');
      expect(
        () => JsonStore(dir).loadValidated(StudyState.fromJson),
        throwsA(isA<UnreadableStoreData>()),
      );
      expect(main.readAsStringSync(), '{bad');
      expect(backup.readAsStringSync(), '[1,2]');
    },
  );

  test(
    'newer schema is protected even when an older readable backup exists',
    () {
      final dir = tempDir();
      addTearDown(() => dir.deleteSync(recursive: true));
      final store = JsonStore(dir);
      store.saveSync(const StudyState().toJson());
      store.saveSync(const StudyState().toJson());
      final file = File('${dir.path}/rattil_user_data.json');
      final newer = jsonEncode({
        'schemaVersion': JsonStore.currentSchemaVersion + 1,
        'futureData': 'keep',
      });
      file.writeAsStringSync(newer);
      expect(
        () => store.loadValidated(StudyState.fromJson),
        throwsA(isA<UnsupportedStoreVersion>()),
      );
      expect(file.readAsStringSync(), newer);
    },
  );

  test('invalid navigable references also trigger typed backup recovery', () {
    final dir = tempDir();
    addTearDown(() => dir.deleteSync(recursive: true));
    final store = JsonStore(dir);
    store.saveSync(const StudyState(positions: {'ar': 42}).toJson());
    store.saveSync(const StudyState(positions: {'ar': 999}).toJson());
    final restored = store.loadValidated((json) {
      final state = StudyState.fromJson(json);
      validateStudyReferences(state, loadContent());
      return state;
    });
    expect(restored.positions['ar'], 42);
  });
}
