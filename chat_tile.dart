import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import 'avatar_circle.dart';

class ChatTile extends StatelessWidget {
  final ChatSummary chat;
  final String myUid;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.myUid,
    required this.onTap,
  });

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;
    final otherName = chat.otherUserName(myUid);
    final unread = chat.unreadFor(myUid);
    final hasUnread = unread > 0;
    final lastFromMe = chat.lastMessageSenderId == myUid;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AvatarCircle(
              initials: _initialsOf(otherName),
              color: Color(chat.otherUserAvatarColor(myUid)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.5),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (lastFromMe)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.done_all, size: 16, color: subtitleColor),
                        ),
                      Expanded(
                        child: Text(
                          chat.previewText(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasUnread ? null : subtitleColor,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.lastMessageTime == null
                      ? ''
                      : DateFormatter.chatListTime(chat.lastMessageTime!),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: hasUnread ? AppColors.primaryGreen : subtitleColor,
                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.unreadBadge,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      '$unread',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
