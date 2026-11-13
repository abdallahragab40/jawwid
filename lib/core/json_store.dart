import 'dart:convert';
import 'dart:io';

/// Durable, versioned JSON storage for the learner's own data
/// (settings, reading positions, bookmarks, notes, progress).
///
/// * Writes are atomic: data goes to a temporary file that is then renamed.
/// * The previous good file is kept as `.bak` and used if the main file is
///   unreadable.
/// * Every document carries `schemaVersion`; [migrate] upgrades older
///   documents step by step so app updates never discard user data.
class JsonStore {
  JsonStore(this.directory, {this.fileName = 'rattil_user_data.json'});

  final Directory directory;
  final String fileName;

  static const int currentSchemaVersion = 2;

  File get _file => File('${directory.path}/$fileName');
  File get _tmp => File('${directory.path}/$fileName.tmp');
  File get _bak => File('${directory.path}/$fileName.bak');

  // The document is small (a few kilobytes), so synchronous I/O is used: a
  // save completes before the app can be suspended mid-write, and there is no
  // interleaving between overlapping saves.

  Future<Map<String, dynamic>> load() async => loadSync();

  Map<String, dynamic> loadSync() {
    for (final f in [_file, _bak]) {
      try {
        if (f.existsSync()) {
          final decoded = jsonDecode(f.readAsStringSync());
          if (decoded is Map<String, dynamic>) return migrate(decoded);
        }
      } on FormatException {
        // Corrupt file: fall through to the backup.
      } on FileSystemException {
        // Unreadable: fall through.
      }
    }
    return migrate(<String, dynamic>{});
  }

  Future<void> save(Map<String, dynamic> data) async => saveSync(data);

  void saveSync(Map<String, dynamic> data) {
    directory.createSync(recursive: true);
    final payload = const JsonEncoder.withIndent(
      ' ',
    ).convert({...data, 'schemaVersion': currentSchemaVersion});
    _tmp.writeAsStringSync(payload, flush: true);
    if (_file.existsSync()) {
      try {
        _file.copySync(_bak.path);
      } on FileSystemException {
        // A failed backup must not block saving.
      }
    }
    _tmp.renameSync(_file.path);
  }

  /// Upgrades [data] from any older schema to [currentSchemaVersion].
  static Map<String, dynamic> migrate(Map<String, dynamic> data) {
    final out = Map<String, dynamic>.from(data);
    var version =
        (out['schemaVersion'] as num?)?.toInt() ??
        (out.isEmpty ? currentSchemaVersion : 1);
    // v1 -> v2: reading positions moved from a single `lastPage` integer
    // (Arabic edition only) to a per-edition map, and `completed` (a list of
    // topic ids) became `topicStatus`.
    if (version < 2) {
      final positions = <String, dynamic>{
        ...?(out['positions'] as Map?)?.cast<String, dynamic>(),
      };
      final legacyPage = out.remove('lastPage');
      if (legacyPage is num && !positions.containsKey('ar')) {
        positions['ar'] = legacyPage.toInt();
      }
      out['positions'] = positions;
      final status = <String, dynamic>{
        ...?(out['topicStatus'] as Map?)?.cast<String, dynamic>(),
      };
      final legacyCompleted = out.remove('completed');
      if (legacyCompleted is List) {
        for (final id in legacyCompleted.whereType<String>()) {
          status[id] = {'status': 'completed'};
        }
      }
      out['topicStatus'] = status;
      version = 2;
    }
    out['schemaVersion'] = version;
    return out;
  }
}
