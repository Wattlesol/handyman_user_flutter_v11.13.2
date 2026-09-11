import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../model/sanad_chat_model.dart';
import '../../../utils/colors.dart';

class SanadChatBubbleWidget extends StatelessWidget {
  final SanadChatMessageModel message;

  const SanadChatBubbleWidget({Key? key, required this.message}) : super(key: key);

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      DateTime dt = DateTime.parse(timeStr);
      int hour = dt.hour;
      int minute = dt.minute;
      String ampm = hour >= 12 ? 'PM' : 'AM';
      int formattedHour = hour % 12 == 0 ? 12 : hour % 12;
      String formattedMinute = minute < 10 ? '0$minute' : '$minute';
      return '$formattedHour:$formattedMinute $ampm';
    } catch (_) {
      return '';
    }
  }

  String _getRoleLabel(String? role) {
    switch (role?.toLowerCase()) {
      case 'customer':
      case 'user':
        return 'Customer';
      case 'admin':
      case 'demo_admin':
        return 'Quick Support';
      case 'employee':
      case 'handyman':
        return 'Government Specialist';
      case 'provider':
        return 'Partner Agent';
      case 'ai':
        return 'AI First Responder';
      default:
        return role?.capitalizeFirstLetter() ?? 'Staff';
    }
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'customer':
      case 'user':
        return brandBlueLight;
      case 'admin':
      case 'demo_admin':
        return const Color(0xFF0F2933);
      case 'employee':
      case 'handyman':
        return const Color(0xFF1455D9);
      case 'provider':
        return const Color(0xFF2DB665);
      case 'ai':
        return Colors.purple;
      default:
        return const Color(0xFF5A6B82);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMe = message.isMe;
    bool isAi = message.isAi;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender Name + Role Badge (only if not me)
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.senderName ?? _getRoleLabel(message.senderRole),
                    style: boldTextStyle(size: 11, color: appTextSecondaryColor),
                  ),
                  4.width,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: _getRoleColor(message.senderRole).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getRoleLabel(message.senderRole),
                      style: boldTextStyle(size: 9, color: _getRoleColor(message.senderRole)),
                    ),
                  ),
                ],
              ),
            ),

          // Chat Bubble Card
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? brandBlueLight
                  : (isAi
                      ? Colors.purple.withOpacity(0.08)
                      : (context.cardColor)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              border: isMe
                  ? null
                  : Border.all(
                      color: isAi ? Colors.purple.withOpacity(0.2) : context.dividerColor,
                      width: 1,
                    ),
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (isAi)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.purple, size: 13),
                      4.width,
                      Text(
                        'AI Answer',
                        style: boldTextStyle(size: 11, color: Colors.purple),
                      ),
                    ],
                  ).paddingBottom(4),
                Text(
                  message.message ?? '',
                  style: isMe
                      ? primaryTextStyle(color: Colors.white, size: 14)
                      : primaryTextStyle(size: 14),
                ),
                4.height,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.createdAt),
                      style: secondaryTextStyle(
                        size: 10,
                        color: isMe ? Colors.white.withOpacity(0.7) : appTextSecondaryColor,
                      ),
                    ),
                    if (isMe) ...[
                      4.width,
                      Icon(
                        message.readAt != null ? Icons.done_all : Icons.done,
                        size: 13,
                        color: message.readAt != null ? Colors.white : Colors.white.withOpacity(0.7),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
