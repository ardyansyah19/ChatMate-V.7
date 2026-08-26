import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  Future<void> createOrUpdateUser({
    required String uid,
    required String name,
  }) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) {
      await _users.doc(uid).update({
        'name': name,
        'lastSeen': FieldValue.serverTimestamp(),
      });
      return;
    }
    await _users.doc(uid).set({
      'name': name,
      'avatarColorValue': AppUser.randomAvatarColorValue(),
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  /// Daftar semua pengguna terdaftar selain diri sendiri, dipakai di
  /// layar "Chat Baru" untuk memilih siapa yang mau diajak chat.
  Stream<List<AppUser>> streamOtherUsers(String myUid) {
    return _users.orderBy('name').snapshots().map((snap) => snap.docs
        .where((d) => d.id != myUid)
        .map((d) => AppUser.fromDoc(d))
        .toList());
  }
}
