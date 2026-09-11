import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../model/sanad_chat_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../user_chat_screen.dart';

class SanadConversationItemWidget extends StatelessWidget {
  final SanadConversationItem conversation;
  final VoidCallback? onRefresh;

  const SanadConversationItemWidget({
    Key? key,
    required this.conversation,
    this.onRefresh,
  }) : super(key: key);

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      DateTime dt = DateTime.parse(timeStr);
      Duration diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }

  Color _getStageColor(String? stage) {
    switch (stage?.toLowerCase()) {
      case 'completed':
      case 'ready_for_delivery':
        return brandGreenLight;
      case 'in_progress':
      case 'government_processing':
      case 'assigned_to_partner':
        return brandBlueLight;
      case 'waiting_for_documents':
      case 'awaiting_customer_action':
        return brandYellowLight;
      case 'escalated':
      case 'cancelled':
        return brandRedLight;
      default:
        return const Color(0xFF5A6B82);
    }
  }

  String _getStageText(String? stage) {
    if (stage == null || stage.isEmpty) return 'Submitted';
    return stage.replaceAll('_', ' ').capitalizeFirstLetter();
  }

  @override
  Widget build(BuildContext context) {
    bool hasUnread = (conversation.unreadCount ?? 0) > 0;
    bool hasBuzz = (conversation.buzzCount ?? 0) > 0;
    bool hasDocs = (conversation.documentPendingCount ?? 0) > 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => UserChatScreen(conversation: conversation)));
        onRefresh?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(14),
          backgroundColor: context.cardColor,
          border: Border.all(
            color: hasUnread ? brandBlueLight.withOpacity(0.4) : context.dividerColor,
            width: hasUnread ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.85),
                    const Color(0xFF0F2933),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  (conversation.sanadReference != null && conversation.sanadReference!.contains('-'))
                      ? conversation.sanadReference!.split('-').last
                      : 'Q',
                  style: boldTextStyle(color: Colors.white, size: 12),
                ),
              ),
            ),
            12.width,

            // Main Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Title + Relative Timestamp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.serviceName ?? 'Service Request',
                          style: boldTextStyle(size: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      4.width,
                      Text(
                        _formatTime(conversation.lastMessageAt),
                        style: secondaryTextStyle(size: 11),
                      ),
                    ],
                  ),
                  4.height,

                  // Second row: Sanad Reference Code + Stage Pill
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: brandBlueLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          conversation.sanadReference ?? '',
                          style: boldTextStyle(size: 10, color: brandBlueLight),
                        ),
                      ),
                      6.width,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStageColor(conversation.sanadStage).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStageText(conversation.sanadStage),
                          style: boldTextStyle(
                            size: 10,
                            color: _getStageColor(conversation.sanadStage),
                          ),
                        ),
                      ),
                    ],
                  ),
                  6.height,

                  // Third row: Last Message snippet
                  Text(
                    conversation.lastMessage ?? 'No messages yet',
                    style: hasUnread
                        ? primaryTextStyle(size: 13, weight: FontWeight.w600)
                        : secondaryTextStyle(size: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  6.height,

                  // Fourth row: Action pills (Buzz, Doc requests, Unread)
                  Row(
                    children: [
                      if (hasBuzz) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: brandRedLight.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, color: brandRedLight, size: 12),
                              2.width,
                              Text(
                                '${conversation.buzzCount} Buzz',
                                style: boldTextStyle(size: 10, color: brandRedLight),
                              ),
                            ],
                          ),
                        ),
                        6.width,
                      ],
                      if (hasDocs) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: brandYellowLight.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.description, color: brandYellowDark, size: 12),
                              2.width,
                              Text(
                                '${conversation.documentPendingCount} Docs Req',
                                style: boldTextStyle(size: 10, color: brandYellowDark),
                              ),
                            ],
                          ),
                        ),
                        6.width,
                      ],
                      if (conversation.aiEnabled == true) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.purple, size: 11),
                              2.width,
                              Text(
                                'AI Support',
                                style: boldTextStyle(size: 10, color: Colors.purple),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (hasUnread) ...[
              8.width,
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: brandBlueLight,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
