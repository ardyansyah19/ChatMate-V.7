// File ini HARUS diganti sebelum menjalankan aplikasi.
//
// Jangan diedit manual — generate otomatis dengan menjalankan perintah ini
// di root folder project (lihat README.md untuk langkah lengkapnya):
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Perintah di atas akan login ke akun Firebase kamu, menyambungkan project
// Firebase yang sudah dibuat di console.firebase.google.com, lalu menimpa
// file ini secara otomatis dengan kunci konfigurasi Firebase yang asli
// untuk Android & iOS.
//
// Nilai di bawah ini hanyalah PLACEHOLDER dan tidak akan berfungsi.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'ChatMate belum dikonfigurasi untuk web. Jalankan `flutterfire configure` '
        'dan pilih platform web jika kamu ingin menjalankan di browser.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk platform ini. '
          'Jalankan `flutterfire configure` untuk menambahkannya.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'GANTI_DENGAN_API_KEY_ANDROID',
    appId: 'GANTI_DENGAN_APP_ID_ANDROID',
    messagingSenderId: 'GANTI_DENGAN_SENDER_ID',
    projectId: 'GANTI_DENGAN_PROJECT_ID',
    storageBucket: 'GANTI_DENGAN_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'GANTI_DENGAN_API_KEY_IOS',
    appId: 'GANTI_DENGAN_APP_ID_IOS',
    messagingSenderId: 'GANTI_DENGAN_SENDER_ID',
    projectId: 'GANTI_DENGAN_PROJECT_ID',
    storageBucket: 'GANTI_DENGAN_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.chatmate',
  );
}
