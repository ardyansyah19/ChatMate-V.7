# ChatMate V.7
By Ahmad Riiko Dyansyah

## Bagaimana cara kerjanya

- **Firebase Authentication (Anonymous)** — tiap HP yang membuka app otomatis
  dapat akun unik; kamu cukup mengisi nama saat pertama kali buka.
- **Cloud Firestore** — menyimpan daftar pengguna, daftar chat, dan setiap pesan
  secara real-time. Begitu satu HP mengirim pesan, HP penerima langsung menerimanya
  tanpa perlu refresh.
- **Firebase Storage** — foto/video/dokumen yang dikirim diunggah ke sana, lalu
  pesan menyimpan URL unduhannya. Penerima bisa menonton/membuka langsung, atau
  menekan tombol **Download** untuk menyimpan foto/video ke galeri HP-nya, atau
  dokumen ke penyimpanan lokal lalu dibuka dengan aplikasi bawaan.

## Fitur

- Login sederhana dengan nama (tanpa password)
- Daftar kontak otomatis dari semua pengguna yang pernah membuka app ("Chat Baru")
- Chat 1-on-1 real-time, tersimpan permanen di cloud
- Kirim **teks**, dengan status kirim (centang) dan status dibaca (centang biru, real dari penerima)
- Kirim **foto** dari galeri/kamera → penerima bisa lihat full screen & **download ke galerinya**
- Kirim **video** dari galeri/kamera → penerima bisa putar langsung & **download ke galerinya**
- Kirim **dokumen** apa saja → penerima **download** ke HP-nya lalu dibuka otomatis
- Progress bar saat mengunggah/mengunduh file
- Badge belum-dibaca per chat, real-time
- Mode gelap otomatis mengikuti sistem HP

## Struktur Proyek

```
lib/
 ├── main.dart                     # Entry point, inisialisasi Firebase
 ├── firebase_options.dart         # WAJIB diganti — lihat langkah 3 di bawah
 ├── models/                       # AppUser, ChatSummary, ChatMessage
 ├── services/                     # AuthService, UserService, ChatService, StorageService
 ├── theme/                        # Warna & tema (light/dark)
 ├── utils/                        # Helper format tanggal & ukuran file
 ├── widgets/                      # Komponen UI (bubble, tile, avatar, attachment sheet)
 └── screens/                      # Halaman (auth gate, setup profil, list chat, chat baru, detail chat, viewer)
```

## Cara Menjalankan

### 1. Buat project Firebase
1. Buka https://console.firebase.google.com → **Add project** → beri nama bebas (mis. `chatmate-riko`) → selesaikan wizard.
2. Di menu kiri, buka **Build → Authentication** → tab **Sign-in method** → aktifkan **Anonymous**.
3. Buka **Build → Firestore Database** → **Create database** → pilih lokasi (mis. `asia-southeast2`) → mode **Production**.
4. Buka **Build → Storage** → **Get started** → lokasi sama seperti Firestore.

### 2. Buat project Flutter kosong sebagai wadah
```bash
flutter create chatmate_app
```
Timpa (copy-paste, replace) folder `lib/`, file `pubspec.yaml`, `assets/`, dan `analysis_options.yaml` dari hasil unduhan ini ke dalam `chatmate_app/`.

### 3. Sambungkan ke project Firebase kamu (WAJIB — jangan dilewati)
```bash
cd chatmate_app
dart pub global activate flutterfire_cli
flutterfire configure
```
Ikuti instruksinya: pilih project Firebase yang tadi dibuat, pilih platform **android** dan **ios**. Perintah ini otomatis:
- Menimpa `lib/firebase_options.dart` dengan kunci konfigurasi asli
- Menambahkan `android/app/google-services.json`
- Menambahkan `ios/Runner/GoogleService-Info.plist`
- Mendaftarkan plugin Google Services di Gradle

### 4. Atur aturan keamanan (security rules)
Supaya app bisa baca/tulis data, buka **Firestore → Rules** di console dan pakai (untuk tahap pengembangan):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
Lalu buka **Storage → Rules** dan pakai:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
> Aturan di atas mengizinkan siapa pun yang sudah login (termasuk akun anonim) membaca & menulis — cukup untuk pengembangan/skripsi. Untuk produksi sungguhan, persempit lagi aturannya (mis. hanya boleh baca/tulis chat yang dia ikut serta).

### 5. Install dependency
```bash
flutter pub get
```

### 6. Tambahkan izin kamera, galeri, dan penyimpanan

**Android** — `android/app/src/main/AndroidManifest.xml`, tambahkan di dalam `<manifest>` (sebelum `<application>`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>
```
Pastikan `minSdkVersion` di `android/app/build.gradle` (atau `build.gradle.kts`) minimal **21**.

**iOS** — `ios/Runner/Info.plist`, tambahkan sebelum `</dict>` penutup terakhir:
```xml
<key>NSCameraUsageDescription</key>
<string>ChatMate membutuhkan akses kamera untuk mengambil foto dan video</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ChatMate membutuhkan akses galeri untuk memilih dan menyimpan foto/video</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>ChatMate membutuhkan akses untuk menyimpan foto/video yang kamu unduh</string>
<key>NSMicrophoneUsageDescription</key>
<string>ChatMate membutuhkan akses mikrofon untuk merekam video</string>
```

### 7. Jalankan
```bash
flutter run
```

## Cara mencobanya jadi 2 pengguna (sender & receiver)

1. Jalankan app di HP A (atau emulator A) → isi nama, misal "Riko".
2. Jalankan app di HP B (HP fisik teman, emulator kedua, atau `flutter run -d <device_id>` ke device lain) → isi nama, misal "Fajar".
3. Di HP A, tekan tombol **+ / Chat baru** → pilih "Fajar" dari daftar kontak.
4. Kirim foto dari HP A. Buka HP B → chat dengan "Riko" otomatis muncul dengan badge belum dibaca → foto bisa dibuka, diputar (kalau video), atau ditekan tombol **Download** untuk disimpan ke galeri HP B.

## Catatan

- Semua chat & file tersimpan permanen di Firebase milikmu sendiri (bisa dicek langsung di Firestore/Storage console) — bukan simulasi lokal lagi.
- Karena pakai Anonymous Auth, kalau aplikasi di-uninstall lalu di-install ulang, akun lama hilang dan harus isi nama baru (akan dianggap pengguna baru). Kalau nanti mau login permanen (bisa pindah HP tanpa kehilangan akun), tinggal ganti ke Email/Password atau Google Sign-In — beri tahu saya kalau mau saya bantu tambahkan.
- `lib/firebase_options.dart` yang ada di zip ini hanya **placeholder** dan tidak akan berfungsi sebelum kamu menjalankan `flutterfire configure` (langkah 3) dengan project Firebase kamu sendiri.
