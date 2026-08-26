import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppUser {
  final String uid;
  final String name;
  final int avatarColorValue;
  final DateTime? lastSeen;

  AppUser({
    required this.uid,
    required this.name,
    required this.avatarColorValue,
    this.lastSeen,
  });

  Color get avatarColor => Color(avatarColorValue);

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarColorValue': avatarColorValue,
      'lastSeen': FieldValue.serverTimestamp(),
    };
  }

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      name: data['name'] as String? ?? 'Pengguna',
      avatarColorValue: data['avatarColorValue'] as int? ??
          AppColors.avatarPalette[0].toARGB32(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  static int randomAvatarColorValue() {
    final idx =
        DateTime.now().microsecondsSinceEpoch % AppColors.avatarPalette.length;
    return AppColors.avatarPalette[idx].toARGB32();
  }
}
