import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/base_scaffold_widget.dart';
import '../../component/empty_error_state_widget.dart';
import '../../component/loader_widget.dart';
import '../../main.dart';
import '../../model/sanad_chat_model.dart';
import '../../network/rest_apis.dart';
import '../../utils/colors.dart';
import '../auth/sign_in_screen.dart';
import 'widget/sanad_conversation_item_widget.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController searchCont = TextEditingController();
  List<SanadConversationItem> conversations = [];
  bool isLoading = true;
  String selectedFilter = 'all'; // 'all', 'unread', 'buzz', 'docs'

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (appStore.isLoggedIn) {
      fetchConversations();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchConversations({bool silent = false}) async {
    if (!silent) {
      setState(() => isLoading = true);
    }
    try {
      final list = await getSanadChatConversations(
        search: searchCont.text,
        filter: selectedFilter,
      );
      if (mounted) {
        setState(() {
          conversations = list;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    searchCont.dispose();
    super.dispose();
  }

  Widget _buildFilterChip(String label, String filterKey, {int? count}) {
    bool isSelected = selectedFilter == filterKey;
    return GestureDetector(
      onTap: () {
        if (selectedFilter != filterKey) {
          setState(() {
            selectedFilter = filterKey;
          });
          fetchConversations();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? brandBlueLight : context.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? brandBlueLight : context.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: boldTextStyle(
                size: 12,
                color: isSelected ? Colors.white : appTextSecondaryColor,
              ),
            ),
            if (count != null && count > 0) ...[
              4.width,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.25) : brandBlueLight.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: boldTextStyle(
                    size: 10,
                    color: isSelected ? Colors.white : brandBlueLight,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: 'Unified Inbox',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: brandBlueLight),
          onPressed: () => fetchConversations(),
        ),
      ],
      child: Observer(builder: (context) {
        if (!appStore.isLoggedIn) {
          return NoDataWidget(
            title: 'Please Sign In',
            subTitle: 'Sign in to access your government request chats and team communication.',
            onRetry: () async {
              await SignInScreen(isFromDashboard: true).launch(context);
              if (appStore.isLoggedIn) {
                fetchConversations();
              }
            },
            retryText: 'Sign In',
            imageWidget: EmptyStateWidget(),
          ).paddingSymmetric(horizontal: 16);
        }

        return Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.dividerColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: appTextSecondaryColor, size: 20),
                  8.width,
                  Expanded(
                    child: TextField(
                      controller: searchCont,
                      decoration: InputDecoration(
                        hintText: 'Search requests or conversations...',
                        hintStyle: secondaryTextStyle(size: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (val) {
                        fetchConversations(silent: true);
                      },
                    ),
                  ),
                  if (searchCont.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: appTextSecondaryColor),
                      onPressed: () {
                        searchCont.clear();
                        fetchConversations();
                      },
                    ),
                ],
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  _buildFilterChip('Unread', 'unread'),
                  _buildFilterChip('Buzz Alerts', 'buzz'),
                  _buildFilterChip('Docs Needed', 'docs'),
                ],
              ),
            ),
            6.height,

            // Conversations List
            Expanded(
              child: isLoading
                  ? LoaderWidget().center()
                  : RefreshIndicator(
                      onRefresh: () => fetchConversations(silent: false),
                      child: conversations.isEmpty
                          ? NoDataWidget(
                              title: 'No Conversations Found',
                              subTitle: 'When you create a service request, your unified chat thread will appear here.',
                              imageWidget: EmptyStateWidget(),
                            ).paddingSymmetric(horizontal: 24)
                          : ListView.builder(
                              itemCount: conversations.length,
                              padding: const EdgeInsets.only(bottom: 24),
                              itemBuilder: (context, index) {
                                return SanadConversationItemWidget(
                                  conversation: conversations[index],
                                  onRefresh: () => fetchConversations(silent: true),
                                );
                              },
                            ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
