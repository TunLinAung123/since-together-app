import 'package:flutter/material.dart';
import 'package:since_together/core/constants/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final myId = Supabase.instance.client.auth.currentUser!.id;
    final isMe = message['sender_id'] == myId;
    final senderName = message['sender']?['display_name'] ?? 'Unknown';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 2),
              child: Text(
                senderName,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message['content'],
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textDark,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
