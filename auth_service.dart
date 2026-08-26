import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

/// Menggunakan Firebase Anonymous Auth supaya proses "login" sesederhana
/// mungkin (cukup masukkan nama) tapi tiap perangkat tetap punya uid unik
/// dan permanen untuk mengirim & menerima pesan sungguhan.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> registerWithName(String name) async {
    final existing = _auth.currentUser;
    final uid = existing != null
        ? existing.uid
        : (await _auth.signInAnonymously()).user!.uid;
    await _userService.createOrUpdateUser(uid: uid, name: name);
  }

  Future<void> signOut() => _auth.signOut();
}
