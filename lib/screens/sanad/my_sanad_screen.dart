import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class MySanadScreen extends StatefulWidget {
  @override
  State<MySanadScreen> createState() => _MySanadScreenState();
}

class _MySanadScreenState extends State<MySanadScreen> {
  Future<void>? future;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> alerts = [];
  List<Map<String, dynamic>> documents = [];
  List<Map<String, dynamic>> chats = [];
  String aiAnswer = '';

  final TextEditingController chatController = TextEditingController();
  final TextEditingController aiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    future = loadSanadData();
  }

  @override
  void dispose() {
    chatController.dispose();
    aiController.dispose();
    super.dispose();
  }

  Future<void> loadSanadData() async {
    final results = await Future.wait([
      getSanadRequests(perPage: 10),
      getSanadBuzzAlerts(perPage: 10),
      getSanadDocumentVault(perPage: 10),
      getSanadChatThreads(perPage: 10),
    ]);

    requests = _extractList(results[0]);
    alerts = _extractList(results[1]);
    documents = _extractList(results[2]);
    chats = _extractList(results[3]);
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> response) {
    final data = response['data'];
    final rows = data is Map ? data['data'] : data;
    if (rows is List) {
      return rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  int? get firstRequestId => requests.isNotEmpty
      ? int.tryParse(requests.first['id'].toString())
      : null;

  Future<void> refresh() async {
    setState(() {
      future = loadSanadData();
    });
    await future;
  }

  Future<void> sendChat() async {
    final requestId = firstRequestId;
    if (requestId == null) return toast('No Sanad request found');
    if (chatController.text.trim().isEmpty) return toast('Enter a message');

    await sendSanadChatMessage({
      'booking_id': requestId,
      'message': chatController.text.trim(),
    });
    chatController.clear();
    toast('Message sent');
    await refresh();
  }

  Future<void> askAi() async {
    if (aiController.text.trim().isEmpty) return toast('Enter a question');
    final answer = await askSanadAi({'question': aiController.text.trim()});
    setState(() {
      aiAnswer = answer.answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        'My Sanad',
        textColor: Colors.white,
        color: context.primaryColor,
      ),
      body: FutureBuilder<void>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return LoaderWidget().center();
          }

          if (snap.hasError) {
            return Text(snap.error.toString(), style: primaryTextStyle())
                .center()
                .paddingAll(16);
          }

          return RefreshIndicator(
            onRefresh: refresh,
            child: AnimatedScrollView(
              padding: EdgeInsets.all(16),
              children: [
                _sectionTitle('My Requests'),
                ...requests.map((e) => _simpleTile(
                    'Request #${e['id'] ?? '-'}',
                    e['service_name'] ?? e['description'] ?? 'Sanad request',
                    e['sanad_stage'] ?? e['status'] ?? 'new')),
                16.height,
                _sectionTitle('Documents'),
                ...documents.map((e) => _simpleTile(
                    e['title'] ?? e['document_name'] ?? 'Document',
                    e['visibility'] ?? e['document_type'] ?? '',
                    e['status'] ?? 'available')),
                16.height,
                _sectionTitle('Updates'),
                ...alerts.map((e) => _simpleTile(
                    e['title'] ?? 'Buzz',
                    e['message'] ?? e['severity'] ?? '',
                    e['status'] ?? 'open')),
                16.height,
                _sectionTitle('Secure Chat'),
                _textInput(chatController, 'Write a secure message'),
                AppButton(
                  text: 'Send Message',
                  color: primaryColor,
                  textColor: Colors.white,
                  width: context.width(),
                  onTap: sendChat,
                ),
                ...chats.map((e) => _simpleTile(
                    'Request #${e['booking_id'] ?? e['id'] ?? '-'}',
                    e['last_message'] ?? e['message'] ?? 'Thread available',
                    e['status'] ?? 'open')),
                16.height,
                _sectionTitle('AI Assistant'),
                _textInput(aiController, 'Ask the Sanad assistant'),
                AppButton(
                  text: 'Ask AI',
                  color: primaryColor,
                  textColor: Colors.white,
                  width: context.width(),
                  onTap: askAi,
                ),
                if (aiAnswer.isNotEmpty)
                  Text(aiAnswer, style: primaryTextStyle()).paddingTop(12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: boldTextStyle(size: 16)).paddingBottom(8);
  }

  Widget _textInput(TextEditingController controller, String hint) {
    return AppTextField(
      controller: controller,
      textFieldType: TextFieldType.MULTILINE,
      minLines: 1,
      maxLines: 4,
      decoration: inputDecoration(context, hintText: hint),
    ).paddingBottom(8);
  }

  Widget _simpleTile(String title, String subtitle, String trailing) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: boldTextStyle(size: 14)),
              4.height,
              Text(subtitle, style: secondaryTextStyle(), maxLines: 2),
            ],
          ).expand(),
          Text(trailing, style: secondaryTextStyle(size: 12)),
        ],
      ),
    );
  }
}
