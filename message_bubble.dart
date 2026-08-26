import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../models/message.dart';
import '../screens/image_viewer_screen.dart';
import '../screens/video_player_screen.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final bool isSeenByOther;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isSeenByOther,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final StorageService _storageService = StorageService();
  bool _downloadingDoc = false;
  double _docProgress = 0;

  Color _bubbleColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.isMe) {
      return isDark ? AppColors.darkBubbleMe : AppColors.lightBubbleMe;
    }
    return isDark ? AppColors.darkBubbleOther : AppColors.lightBubbleOther;
  }

  Widget _statusTicks() {
    if (!widget.isMe) return const SizedBox.shrink();
    final stillUploading = widget.message.type != MessageType.text &&
        widget.message.mediaUrl == null;

    IconData icon;
    Color color;
    if (stillUploading) {
      icon = Icons.access_time;
      color = Colors.black45;
    } else if (widget.isSeenByOther) {
      icon = Icons.done_all;
      color = AppColors.blueTick;
    } else {
      icon = Icons.done_all;
      color = Colors.black45;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(icon, size: 15, color: color),
    );
  }

  Widget _metaRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormatter.bubbleTime(widget.message.timestamp),
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
          _statusTicks(),
        ],
      ),
    );
  }

  Future<void> _openDocument() async {
    final msg = widget.message;
    if (msg.mediaUrl == null) return;
    setState(() {
      _downloadingDoc = true;
      _docProgress = 0;
    });
    try {
      final localPath = await _storageService.downloadDocument(
        url: msg.mediaUrl!,
        fileName: msg.fileName ?? 'dokumen',
        onProgress: (p) => setState(() => _docProgress = p),
      );
      await OpenFilex.open(localPath);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka dokumen: $e')),
      );
    } finally {
      if (mounted) setState(() => _downloadingDoc = false);
    }
  }

  Widget _buildContent(BuildContext context) {
    final msg = widget.message;
    final stillUploading = msg.type != MessageType.text && msg.mediaUrl == null;

    switch (msg.type) {
      case MessageType.text:
        return Text(msg.text ?? '', style: const TextStyle(fontSize: 15.5));

      case MessageType.image:
        if (stillUploading) {
          return _placeholderBox(icon: Icons.image, label: 'Mengunggah foto…');
        }
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImageViewerScreen(networkUrl: msg.mediaUrl),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              msg.mediaUrl!,
              width: 220,
              height: 220,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return SizedBox(
                  width: 220,
                  height: 220,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                width: 220,
                height: 220,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
        );

      case MessageType.video:
        if (stillUploading) {
          return _placeholderBox(
              icon: Icons.videocam, label: 'Mengunggah video…');
        }
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(networkUrl: msg.mediaUrl),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.movie, color: Colors.white38, size: 50),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.play_arrow, color: Colors.white, size: 32),
              ),
            ],
          ),
        );

      case MessageType.document:
        if (stillUploading) {
          return _placeholderBox(
              icon: Icons.insert_drive_file, label: 'Mengunggah dokumen…');
        }
        final ext = (msg.fileName ?? '').split('.').last.toUpperCase();
        return GestureDetector(
          onTap: _downloadingDoc ? null : _openDocument,
          child: Container(
            width: 230,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.tealGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: _downloadingDoc
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            value: _docProgress > 0 ? _docProgress : null,
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          ext.length > 4 ? 'FILE' : ext,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.fileName ?? 'Dokumen',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _downloadingDoc
                            ? 'Mengunduh… ketuk untuk membuka setelah selesai'
                            : '${DateFormatter.fileSize(msg.fileSizeBytes ?? 0)} · Ketuk untuk buka',
                        style: const TextStyle(
                            fontSize: 11.5, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _placeholderBox({required IconData icon, required String label}) {
    return Container(
      width: 220,
      height: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 18, color: Colors.black45),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final align =
        widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = widget.isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        padding: EdgeInsets.symmetric(
          horizontal: widget.message.type == MessageType.text ? 10 : 6,
          vertical: widget.message.type == MessageType.text ? 8 : 6,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: _bubbleColor(context),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: align,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContent(context),
            _metaRow(context),
          ],
        ),
      ),
    );
  }
}
