import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_database_service.dart';

/// Generic upload / download helper for Supabase Storage buckets.
class SupabaseStorageService {
  final SupabaseDatabaseService _db;

  const SupabaseStorageService(this._db);

  /// Uploads a file at [filePath] to [bucket] under [storagePath].
  ///
  /// Returns the public URL of the uploaded file.
  Future<String> uploadFile({
    required String bucket,
    required String storagePath,
    required String filePath,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    await _db.storage.from(bucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = _db.storage.from(bucket).getPublicUrl(storagePath);
    return publicUrl;
  }

  /// Uploads raw bytes to [bucket] under [storagePath].
  ///
  /// Returns the public URL of the uploaded file.
  Future<String> uploadBytes({
    required String bucket,
    required String storagePath,
    required Uint8List bytes,
    String? contentType,
  }) async {
    await _db.storage.from(bucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );

    return _db.storage.from(bucket).getPublicUrl(storagePath);
  }

  /// Downloads a file from [bucket] at [storagePath] as bytes.
  Future<Uint8List> downloadFile({
    required String bucket,
    required String storagePath,
  }) async {
    return await _db.storage.from(bucket).download(storagePath);
  }

  /// Returns the public URL for a file in [bucket] at [storagePath].
  String getPublicUrl({
    required String bucket,
    required String storagePath,
  }) {
    return _db.storage.from(bucket).getPublicUrl(storagePath);
  }

  /// Deletes files from [bucket] at the given [storagePaths].
  Future<void> deleteFiles({
    required String bucket,
    required List<String> storagePaths,
  }) async {
    await _db.storage.from(bucket).remove(storagePaths);
  }
}
