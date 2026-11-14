import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'study_backup.dart';

/// Native pickers grant access to only the file selected by the learner.
abstract class BackupFiles {
  Future<bool> save(String text, {required String name, required String title});
  Future<String?> open({required String title});
}

class NativeBackupFiles implements BackupFiles {
  @override
  Future<bool> save(
    String text, {
    required String name,
    required String title,
  }) async {
    final result = await FilePicker.saveFile(
      fileName: name,
      bytes: Uint8List.fromList(utf8.encode(text)),
      mimeType: 'application/json',
      dialogTitle: title,
    );
    return result != null;
  }

  @override
  Future<String?> open({required String title}) async {
    final file = await FilePicker.pickFile(
      dialogTitle: title,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null) return null;
    final length = await file.length();
    if (length != null && length > maxStudyBackupBytes) {
      throw const FormatException('Too large');
    }
    // Bound reads even when a provider cannot report the size beforehand.
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in file.readAsByteStream()) {
      if (bytes.length + chunk.length > maxStudyBackupBytes) {
        throw const FormatException('Too large');
      }
      bytes.add(chunk);
    }
    return utf8.decode(bytes.takeBytes());
  }
}

final backupFilesProvider = Provider<BackupFiles>((_) => NativeBackupFiles());
