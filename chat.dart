import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';

class ChatSummary {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, int> participantAvatarColors;

  final String? lastMessageText;
  final MessageType? lastMessageType;
  final String? lastMessageSenderId;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount;

  ChatSummary({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantAvatarColors,
    this.lastMessageText,
    this.lastMessageType,
    this.lastMessageSenderId,
    this.lastMessageTime,
    this.unreadCount = const {},
  });

  String otherUserId(String myUid) =>
      participantIds.firstWhere((id) => id != myUid, orElse: () => myUid);

  String otherUserName(String myUid) =>
      participantNames[otherUserId(myUid)] ?? 'Pengguna';

  int otherUserAvatarColor(String myUid) =>
      participantAvatarColors[otherUserId(myUid)] ?? 0xFF25D366;

  int unreadFor(String myUid) => unreadCount[myUid] ?? 0;

  String previewText() {
    if (lastMessageType == null) return 'Mulai percakapan';
    switch (lastMessageType!) {
      case MessageType.text:
        return lastMessageText ?? '';
      case MessageType.image:
        return '📷 Foto';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.document:
        return '📄 Dokumen';
    }
  }

  /// Membuat id chat yang deterministik & unik untuk sepasang pengguna,
  /// supaya dua orang yang sama selalu memakai dokumen chat yang sama.
  static String buildChatId(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  factory ChatSummary.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['lastMessageTime'];
    return ChatSummary(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] as List? ?? const []),
      participantNames:
          Map<String, String>.from(data['participantNames'] as Map? ?? const {}),
      participantAvatarColors: Map<String, int>.from(
          data['participantAvatarColors'] as Map? ?? const {}),
      lastMessageText: data['lastMessageText'] as String?,
      lastMessageType: data['lastMessageType'] != null
          ? messageTypeFromString(data['lastMessageType'] as String)
          : null,
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      lastMessageTime: ts is Timestamp ? ts.toDate() : null,
      unreadCount: Map<String, int>.from(data['unreadCount'] as Map? ?? const {}),
    );
  }
}
