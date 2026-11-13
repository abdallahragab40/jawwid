import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/licenses.dart';
import 'content/content_repository.dart';
import 'core/json_store.dart';
import 'features/study/study_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerBundledLicenses();
  final content = await ContentRepository.load();
  final store = JsonStore(await getApplicationSupportDirectory());
  final initial = StudyState.fromJson(await store.load());
  runApp(
    ProviderScope(
      overrides: [
        contentProvider.overrideWithValue(content),
        storeProvider.overrideWithValue(store),
        initialStudyStateProvider.overrideWithValue(initial),
      ],
      child: const RattilApp(),
    ),
  );
}
