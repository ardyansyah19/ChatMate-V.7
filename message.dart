import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, video, document }

MessageType messageTypeFromString(String value) {
  return MessageType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => MessageType.text,
  );
}

class ChatMessage {
  final String id;
  final String senderId;
  final MessageType type;
  final DateTime timestamp;

  /// Isi teks (untuk pesan teks) atau caption (untuk attachment)
  final String? text;

  /// URL unduhan permanen dari Firebase Storage. Null selagi masih diunggah.
  final String? mediaUrl;

  final String? fileName;
  final int? fileSizeBytes;

  /// Daftar uid yang sudah membaca pesan ini (dipakai untuk centang biru)
  final List<String> seenBy;

  /// Hanya dipakai di sisi client saat pesan baru saja dikirim & file
  /// masih dalam proses upload — path lokal untuk preview sementara.
  final String? localPreviewPath;
  final bool isUploading;
  final double uploadProgress;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.type,
    required this.timestamp,
    this.text,
    this.mediaUrl,
    this.fileName,
    this.fileSizeBytes,
    this.seenBy = const [],
    this.localPreviewPath,
    this.isUploading = false,
    this.uploadProgress = 0,
  });

  ChatMessage copyWith({
    String? mediaUrl,
    bool? isUploading,
    double? uploadProgress,
    List<String>? seenBy,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      type: type,
      timestamp: timestamp,
      text: text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      seenBy: seenBy ?? this.seenBy,
      localPreviewPath: localPreviewPath,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'type': type.name,
      'text': text,
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'seenBy': seenBy,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['timestamp'];
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      type: messageTypeFromString(data['type'] as String? ?? 'text'),
      timestamp: ts is Timestamp ? ts.toDate() : DateTime.now(),
      text: data['text'] as String?,
      mediaUrl: data['mediaUrl'] as String?,
      fileName: data['fileName'] as String?,
      fileSizeBytes: data['fileSizeBytes'] as int?,
      seenBy: List<String>.from(data['seenBy'] as List? ?? const []),
    );
  }
}
