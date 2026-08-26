import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import 'storage_service.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  CollectionReference<Map<String, dynamic>> _messagesOf(String chatId) =>
      _chats.doc(chatId).collection('messages');

  /// Membuat dokumen chat (kalau belum ada) antara dua pengguna, lalu
  /// mengembalikan chatId-nya. Dipanggil saat memilih kontak baru.
  Future<String> getOrCreateChat({
    required AppUser me,
    required AppUser other,
  }) async {
    final chatId = ChatSummary.buildChatId(me.uid, other.uid);
    final doc = await _chats.doc(chatId).get();
    if (!doc.exists) {
      await _chats.doc(chatId).set({
        'participantIds': [me.uid, other.uid],
        'participantNames': {me.uid: me.name, other.uid: other.name},
        'participantAvatarColors': {
          me.uid: me.avatarColorValue,
          other.uid: other.avatarColorValue,
        },
        'lastMessageText': null,
        'lastMessageType': null,
        'lastMessageSenderId': null,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': {me.uid: 0, other.uid: 0},
      });
    }
    return chatId;
  }

  /// Stream daftar chat milik pengguna saat ini, terbaru di atas.
  Stream<List<ChatSummary>> streamMyChats(String myUid) {
    return _chats
        .where('participantIds', arrayContains: myUid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ChatSummary.fromDoc).toList());
  }

  /// Stream pesan-pesan dalam satu chat, urut waktu naik (lama ke baru).
  Stream<List<ChatMessage>> streamMessages(String chatId) {
    return _messagesOf(chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromDoc).toList());
  }

  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String otherUserId,
    required String text,
  }) async {
    final msgRef = _messagesOf(chatId).doc();
    await msgRef.set(ChatMessage(
      id: msgRef.id,
      senderId: senderId,
      type: MessageType.text,
      timestamp: DateTime.now(),
      text: text,
      seenBy: [senderId],
    ).toMap());

    await _touchChatAfterSend(
      chatId: chatId,
      senderId: senderId,
      otherUserId: otherUserId,
      previewType: MessageType.text,
      previewText: text,
    );
  }

  /// Mengirim attachment (foto/video/dokumen): dokumen pesan dibuat lebih
  /// dulu dengan status uploading, file diunggah ke Storage, lalu URL-nya
  /// disimpan — supaya penerima bisa membuka/mengunduh file yang sama.
  Future<void> sendAttachmentMessage({
    required String chatId,
    required String senderId,
    required String otherUserId,
    required MessageType type,
    required File file,
    required String fileName,
    required int fileSizeBytes,
    void Function(double progress)? onProgress,
  }) async {
    final msgRef = _messagesOf(chatId).doc();
    await msgRef.set(ChatMessage(
      id: msgRef.id,
      senderId: senderId,
      type: type,
      timestamp: DateTime.now(),
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      seenBy: [senderId],
    ).toMap());

    final url = await _storageService.uploadChatFile(
      chatId: chatId,
      file: file,
      originalFileName: fileName,
      onProgress: onProgress ?? (_) {},
    );

    await msgRef.update({'mediaUrl': url});

    await _touchChatAfterSend(
      chatId: chatId,
      senderId: senderId,
      otherUserId: otherUserId,
      previewType: type,
      previewText: null,
    );
  }

  Future<void> _touchChatAfterSend({
    required String chatId,
    required String senderId,
    required String otherUserId,
    required MessageType previewType,
    String? previewText,
  }) async {
    await _chats.doc(chatId).update({
      'lastMessageText': previewText,
      'lastMessageType': previewType.name,
      'lastMessageSenderId': senderId,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount.$otherUserId': FieldValue.increment(1),
    });
  }

  /// Menandai semua pesan di chat ini sebagai sudah dibaca oleh [myUid],
  /// dan mereset badge belum-dibaca milik saya.
  Future<void> markChatAsRead({
    required String chatId,
    required String myUid,
  }) async {
    final unread = await _messagesOf(chatId)
        .where('senderId', isNotEqualTo: myUid)
        .get();

    final batch = _db.batch();
    for (final doc in unread.docs) {
      final seenBy = List<String>.from(doc.data()['seenBy'] as List? ?? []);
      if (!seenBy.contains(myUid)) {
        batch.update(doc.reference, {
          'seenBy': FieldValue.arrayUnion([myUid]),
        });
      }
    }
    batch.update(_chats.doc(chatId), {'unreadCount.$myUid': 0});
    await batch.commit();
  }
}
