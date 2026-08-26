import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Dio _dio = Dio();
  final _uuid = const Uuid();

  /// Mengunggah file ke Firebase Storage di path chats/{chatId}/{namaUnik}
  /// sambil melaporkan progres (0.0 - 1.0), lalu mengembalikan URL unduhan
  /// permanen yang bisa dibuka siapa pun yang punya akses ke chat itu.
  Future<String> uploadChatFile({
    required String chatId,
    required File file,
    required String originalFileName,
    required void Function(double progress) onProgress,
  }) async {
    final ext = originalFileName.contains('.')
        ? originalFileName.split('.').last
        : '';
    final uniqueName = '${_uuid.v4()}${ext.isNotEmpty ? '.$ext' : ''}';
    final ref = _storage.ref().child('chats/$chatId/$uniqueName');

    final uploadTask = ref.putFile(file);
    uploadTask.snapshotEvents.listen((snapshot) {
      if (snapshot.totalBytes > 0) {
        onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    });

    final snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }

  /// Mengunduh foto/video dari URL Firebase Storage lalu menyimpannya
  /// langsung ke galeri HP penerima.
  Future<void> saveMediaToGallery({
    required String url,
    required bool isVideo,
    void Function(double progress)? onProgress,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final ext = isVideo ? 'mp4' : 'jpg';
    final tempPath =
        '${tempDir.path}/chatmate_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _dio.download(
      url,
      tempPath,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      },
    );

    if (isVideo) {
      await Gal.putVideo(tempPath, album: 'ChatMate');
    } else {
      await Gal.putImage(tempPath, album: 'ChatMate');
    }
  }

  /// Mengunduh dokumen dari URL Firebase Storage ke folder dokumen aplikasi
  /// lalu mengembalikan path lokalnya supaya bisa dibuka dengan open_filex.
  Future<String> downloadDocument({
    required String url,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final localPath = '${dir.path}/$fileName';

    await _dio.download(
      url,
      localPath,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      },
    );

    return localPath;
  }
}
