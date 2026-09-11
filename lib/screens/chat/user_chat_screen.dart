import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/base_scaffold_widget.dart';
import '../../component/loader_widget.dart';
import '../../main.dart';
import '../../model/sanad_chat_model.dart';
import '../../model/user_data_model.dart';
import '../../network/rest_apis.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../booking/booking_detail_screen.dart';
import '../booking/sanad_request_detail_screen.dart';
import 'widget/sanad_buzz_alert_card_widget.dart';
import 'widget/sanad_chat_bubble_widget.dart';
import 'widget/sanad_document_request_card_widget.dart';

class UserChatScreen extends StatefulWidget {
  final SanadConversationItem? conversation;
  final int? requestId;
  final UserData? receiverUser;
  final bool isChattingAllow;

  const UserChatScreen({
    Key? key,
    this.conversation,
    this.requestId,
    this.receiverUser,
    this.isChattingAllow = true,
  }) : super(key: key);

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController messageCont = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode messageFocus = FocusNode();

  List<SanadChatMessageModel> messages = [];
  List<SanadDocumentRequestModel> documentRequests = [];
  List<SanadBuzzAlertModel> buzzAlerts = [];

  bool isLoading = true;
  bool isSending = false;
  bool isAiMode = false;
  Timer? _pollingTimer;

  int get effectiveRequestId =>
      widget.conversation?.id ?? widget.requestId ?? (widget.receiverUser?.id ?? 0);

  String get requestReference =>
      widget.conversation?.sanadReference ?? 'QUICK-${effectiveRequestId.toString().padLeft(6, '0')}';

  String get serviceTitle =>
      widget.conversation?.serviceName ?? widget.receiverUser?.displayName ?? 'Service Request';

  String get stageTitle =>
      widget.conversation?.sanadStage?.replaceAll('_', ' ').capitalizeFirstLetter() ?? 'Submitted';

  @override
  void initState() {
    super.initState();
    fetchCommunication();
    // Auto-poll for new messages every 6 seconds while screen is open
    _pollingTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted && !isSending) {
        fetchCommunication(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    messageCont.dispose();
    scrollController.dispose();
    messageFocus.dispose();
    super.dispose();
  }

  Future<void> fetchCommunication({bool silent = false}) async {
    if (effectiveRequestId == 0) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    if (!silent) {
      setState(() => isLoading = true);
    }

    try {
      final res = await getRequestCommunication(effectiveRequestId);
      if (mounted) {
        List<SanadChatMessageModel> allMsgs = [];
        int? threadId;

        for (var t in res.threads) {
          threadId ??= t.id;
          allMsgs.addAll(t.messages);
        }

        // Sort messages chronologically
        allMsgs.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return a.createdAt!.compareTo(b.createdAt!);
        });

        setState(() {
          messages = allMsgs;
          documentRequests = res.documentRequests;
          isLoading = false;
        });

        // Mark read
        if (threadId != null) {
          markRequestCommunicationRead(requestId: effectiveRequestId, threadId: threadId);
        }

        // Auto-scroll to bottom on first load
        if (!silent) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        if (!silent) {
          toast(e.toString());
        }
      }
    }
  }

  void _scrollToBottom() {
    afterBuildCreated(() {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> handleSendMessage() async {
    final text = messageCont.text.trim();
    if (text.isEmpty || isSending) return;

    messageCont.clear();
    setState(() => isSending = true);

    if (isAiMode) {
      // AI query
      final tempUserMsg = SanadChatMessageModel(
        senderRole: 'customer',
        message: text,
        createdAt: DateTime.now().toIso8601String(),
      );
      setState(() {
        messages.add(tempUserMsg);
      });
      _scrollToBottom();

      try {
        final aiRes = await askSanadAi(question: text, requestId: effectiveRequestId);
        if (mounted) {
          final aiMsg = SanadChatMessageModel(
            senderRole: 'ai',
            senderName: 'AI First Responder',
            message: aiRes.answer ?? 'No answer provided',
            createdAt: DateTime.now().toIso8601String(),
            aiInteractionId: aiRes.id,
          );
          setState(() {
            messages.add(aiMsg);
            isSending = false;
          });
          _scrollToBottom();
        }
      } catch (e) {
        if (mounted) {
          setState(() => isSending = false);
          toast(e.toString());
        }
      }
    } else {
      // Regular message to request team
      try {
        final newMsg = await sendRequestCommunicationMessage(
          requestId: effectiveRequestId,
          message: text,
        );
        if (mounted) {
          setState(() {
            messages.add(newMsg);
            isSending = false;
          });
          _scrollToBottom();
        }
      } catch (e) {
        if (mounted) {
          setState(() => isSending = false);
          toast(e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: requestReference,
      actions: [
        // Shortcut to view full Request / Booking Details
        if (effectiveRequestId > 0)
          TextButton.icon(
            onPressed: () {
              SanadRequestDetailScreen(requestId: effectiveRequestId).launch(context);
            },
            icon: const Icon(Icons.assignment_outlined, size: 16, color: brandBlueLight),
            label: Text(
              'Request',
              style: boldTextStyle(size: 13, color: brandBlueLight),
            ),
          ).paddingRight(8),
      ],
      child: Column(
        children: [
          // Room Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: context.cardColor,
              border: Border(
                bottom: BorderSide(color: context.dividerColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceTitle,
                        style: boldTextStyle(size: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      3.height,
                      Row(
                        children: [
                          Text(
                            requestReference,
                            style: secondaryTextStyle(size: 12, color: brandBlueLight),
                          ),
                          8.width,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: brandBlueLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              stageTitle,
                              style: boldTextStyle(size: 10, color: brandBlueLight),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Timeline Stream
          Expanded(
            child: isLoading
                ? LoaderWidget().center()
                : RefreshIndicator(
                    onRefresh: () => fetchCommunication(silent: false),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        // Pending Document Requests Cards at top of chat
                        if (documentRequests.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Text(
                              'Action Required Documents',
                              style: boldTextStyle(size: 12, color: appTextSecondaryColor),
                            ),
                          ),
                          ...documentRequests.map(
                            (docReq) => SanadDocumentRequestCardWidget(
                              docRequest: docReq,
                              onUploadTap: () {
                                toast('Please attach document in the composer below.');
                              },
                            ),
                          ),
                          const Divider(height: 24, thickness: 1).paddingSymmetric(horizontal: 16),
                        ],

                        // Urgent Buzz Alerts
                        ...buzzAlerts.map(
                          (buzz) => SanadBuzzAlertCardWidget(
                            buzzAlert: buzz,
                            onAcknowledged: () => fetchCommunication(silent: true),
                          ),
                        ),

                        // Message Stream
                        if (messages.isEmpty && documentRequests.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                            child: Column(
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 48, color: appTextSecondaryColor.withOpacity(0.4)),
                                12.height,
                                Text(
                                  'No messages yet in this request.',
                                  style: boldTextStyle(size: 14),
                                ),
                                4.height,
                                Text(
                                  'Send a message or ask AI to start the conversation with the operations team.',
                                  style: secondaryTextStyle(size: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ...messages.map((msg) {
                            if (msg.messageType == 'buzz' && msg.buzzAlert != null) {
                              return SanadBuzzAlertCardWidget(
                                buzzAlert: msg.buzzAlert!,
                                onAcknowledged: () => fetchCommunication(silent: true),
                              );
                            }
                            if (msg.messageType == 'document_request' && msg.documentRequest != null) {
                              return SanadDocumentRequestCardWidget(
                                docRequest: msg.documentRequest!,
                              );
                            }
                            return SanadChatBubbleWidget(message: msg);
                          }),
                      ],
                    ),
                  ),
          ),

          // AI Mode Toggle Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: isAiMode ? Colors.purple.withOpacity(0.06) : Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: isAiMode ? Colors.purple : appTextSecondaryColor,
                    ),
                    6.width,
                    Text(
                      isAiMode ? 'AI First Responder Active' : 'Team Chat Mode',
                      style: boldTextStyle(
                        size: 12,
                        color: isAiMode ? Colors.purple : appTextSecondaryColor,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => isAiMode = !isAiMode);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isAiMode ? Colors.purple : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAiMode ? 'Switch to Staff' : 'Ask AI',
                      style: boldTextStyle(size: 11, color: isAiMode ? Colors.white : appTextPrimaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message Composer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.cardColor,
              border: Border(
                top: BorderSide(color: context.dividerColor, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Attachment Icon
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: appTextSecondaryColor),
                    onPressed: () {
                      toast('Document attachment option');
                    },
                  ),

                  // Message Input
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isAiMode ? Colors.purple.withOpacity(0.4) : context.dividerColor,
                        ),
                      ),
                      child: TextField(
                        controller: messageCont,
                        focusNode: messageFocus,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: isAiMode ? 'Ask AI about this request...' : 'Type a message...',
                          hintStyle: secondaryTextStyle(size: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => handleSendMessage(),
                      ),
                    ),
                  ),
                  8.width,

                  // Send Button
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isAiMode ? Colors.purple : brandBlueLight,
                      shape: BoxShape.circle,
                    ),
                    child: isSending
                        ? const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white, size: 18),
                            onPressed: handleSendMessage,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
