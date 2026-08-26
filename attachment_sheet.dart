import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/message.dart';

/// Hasil pilihan attachment yang dikembalikan ke ChatDetailScreen
class AttachmentResult {
  final MessageType type;
  final File file;

  AttachmentResult({required this.type, required this.file});
}

class AttachmentSheet extends StatelessWidget {
  const AttachmentSheet({super.key});

  static Future<AttachmentResult?> show(BuildContext context) {
    return showModalBottomSheet<AttachmentResult>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const AttachmentSheet(),
    );
  }

  Future<void> _pickDocument(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.single.path == null) return;
    if (!context.mounted) return;
    Navigator.pop(
      context,
      AttachmentResult(
        type: MessageType.document,
        file: File(result.files.single.path!),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;
    if (!context.mounted) return;
    Navigator.pop(
      context,
      AttachmentResult(type: MessageType.image, file: File(picked.path)),
    );
  }

  Future<void> _pickVideo(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 5),
    );
    if (picked == null) return;
    if (!context.mounted) return;
    Navigator.pop(
      context,
      AttachmentResult(type: MessageType.video, file: File(picked.path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF233138) : Colors.white;

    final options = <_AttachOption>[
      _AttachOption(
        icon: Icons.insert_drive_file,
        label: 'Dokumen',
        color: const Color(0xFF7F66FF),
        onTap: () => _pickDocument(context),
      ),
      _AttachOption(
        icon: Icons.photo_library,
        label: 'Galeri',
        color: const Color(0xFFBF59CF),
        onTap: () => _pickImage(context, ImageSource.gallery),
      ),
      _AttachOption(
        icon: Icons.videocam,
        label: 'Video',
        color: const Color(0xFFEC407A),
        onTap: () => _pickVideo(context, ImageSource.gallery),
      ),
      _AttachOption(
        icon: Icons.camera_alt,
        label: 'Kamera',
        color: const Color(0xFFFF6F61),
        onTap: () => _pickImage(context, ImageSource.camera),
      ),
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Wrap(
          runSpacing: 18,
          children: [
            for (final opt in options)
              InkWell(
                onTap: opt.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: opt.color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(opt.icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        opt.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttachOption {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
