import 'dart:io';
import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/sanad_request_detail_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/chat/user_chat_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SanadRequestDetailScreen extends StatefulWidget {
  final int requestId;

  const SanadRequestDetailScreen({Key? key, required this.requestId}) : super(key: key);

  @override
  State<SanadRequestDetailScreen> createState() => _SanadRequestDetailScreenState();
}

class _SanadRequestDetailScreenState extends State<SanadRequestDetailScreen> {
  late Future<SanadRequestDetailModel> futureRequest;
  bool isUploading = false;
  String? selectedChoiceId;
  XFile? pickedFile;
  final ScrollController _scrollController = ScrollController();

  static const Color brandBlue = Color(0xFF1F6BFF);
  static const Color brandNavy = Color(0xFF0F2933);
  static const Color brandRed = Color(0xFFE53935);
  static const Color brandGreen = Color(0xFF2E7D32);
  static const Color brandYellow = Color(0xFFF57F17);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    futureRequest = getSanadRequestDetail(widget.requestId);
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return "-";
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat("yyyy-MM-dd HH:mm").format(dt);
    } catch (_) {
      return raw;
    }
  }

  Color _getStageColor(String? stage) {
    switch (stage?.toLowerCase()) {
      case "submitted":
      case "pending":
        return brandBlue;
      case "accepted":
      case "assigned_to_partner":
      case "assigned_to_employee":
        return const Color(0xFF0288D1);
      case "in_progress":
        return brandYellow;
      case "awaiting_customer_action":
        return Colors.deepOrange;
      case "awaiting_quality_review":
        return Colors.purple;
      case "completed":
      case "closed":
        return brandGreen;
      case "cancelled":
      case "rejected":
        return brandRed;
      default:
        return brandBlue;
    }
  }

  Future<void> _handleUpload(SanadRequestDetailModel detail) async {
    if (selectedChoiceId == null) {
      toast("Please select a document type");
      return;
    }
    if (pickedFile == null) {
      toast("Please select a file to upload");
      return;
    }

    setState(() => isUploading = true);
    try {
      await uploadSanadRequestDocument(
        requestId: widget.requestId,
        filePath: pickedFile!.path,
        documentSelection: selectedChoiceId!,
      );
      toast("Document uploaded successfully!");
      setState(() {
        pickedFile = null;
        selectedChoiceId = null;
        loadData();
      });
    } catch (e) {
      toast("Upload failed: $e");
    } finally {
      setState(() => isUploading = false);
    }
  }

  void _showCancelDialog(SanadRequestDetailModel detail) {
    final TextEditingController reasonCont = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Cancel Request", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Are you sure you want to cancel this request?"),
              12.height,
              AppTextField(
                controller: reasonCont,
                textFieldType: TextFieldType.MULTILINE,
                decoration: inputDecoration(context, labelText: "Reason for cancellation"),
                minLines: 3,
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => finish(ctx),
              child: Text("Close", style: secondaryTextStyle()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: brandRed),
              onPressed: () async {
                if (reasonCont.text.trim().isEmpty) {
                  toast("Please enter a reason");
                  return;
                }
                finish(ctx);
                appStore.setLoading(true);
                try {
                  await cancelSanadRequest(
                    requestId: widget.requestId,
                    reason: reasonCont.text.trim(),
                  );
                  toast("Request cancelled successfully");
                  setState(() {
                    loadData();
                  });
                } catch (e) {
                  toast("Cancellation error: $e");
                } finally {
                  appStore.setLoading(false);
                }
              },
              child: const Text("Confirm Cancel", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SanadRequestDetailModel>(
      future: futureRequest,
      builder: (context, snapshot) {
        final detail = snapshot.data;
        final title = detail != null
            ? (detail.quickReference ?? detail.sanadReference ?? "Request #${widget.requestId}")
            : "Request #${widget.requestId}";

        return AppScaffold(
          appBarTitle: title,
          actions: [
            IconButton(
              tooltip: "Talk to Quick",
              onPressed: () {
                UserChatScreen(requestId: widget.requestId).launch(context);
              },
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            ).paddingRight(4),
          ],
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                loadData();
              });
              await futureRequest;
            },
            child: snapshot.connectionState == ConnectionState.waiting
                ? LoaderWidget().center()
                : snapshot.hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Failed to load request: ${snapshot.error}", textAlign: TextAlign.center, style: primaryTextStyle()),
                            16.height,
                            AppButton(
                              text: "Retry",
                              color: brandBlue,
                              textColor: Colors.white,
                              onTap: () => setState(() => loadData()),
                            ),
                          ],
                        ).paddingAll(24),
                      )
                    : _buildContent(detail!),
          ),
        );
      },
    );
  }

  Widget _buildContent(SanadRequestDetailModel detail) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Subtitle Banner
          Container(
            width: context.width(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [brandBlue, brandNavy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Request ${detail.quickReference ?? detail.sanadReference ?? '#${detail.id}'}",
                  style: boldTextStyle(size: 20, color: Colors.white),
                ),
                4.height,
                Text(
                  detail.serviceName ?? "Government Transaction",
                  style: secondaryTextStyle(size: 14, color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
          14.height,

          // Urgent Buzz Alerts
          if (detail.openBuzzAlerts != null && detail.openBuzzAlerts!.isNotEmpty) ...[
            for (final buzz in detail.openBuzzAlerts!) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: brandRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: brandRed.withOpacity(0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.bolt, color: brandRed, size: 22),
                    10.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("Urgent Buzz", style: boldTextStyle(size: 13, color: brandRed)),
                              const Spacer(),
                              Text(_formatDateTime(buzz.createdAt), style: secondaryTextStyle(size: 10)),
                            ],
                          ),
                          4.height,
                          Text(buzz.message ?? "", style: primaryTextStyle(size: 13)),
                          8.height,
                          Align(
                            alignment: Alignment.centerRight,
                            child: AppButton(
                              text: "Talk to Quick",
                              height: 30,
                              color: brandBlue,
                              textColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              onTap: () {
                                UserChatScreen(requestId: detail.id).launch(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          // Request Information Card
          _buildCard(
            title: "Request Information",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoGrid([
                  {"label": "Service", "value": detail.serviceName ?? "-"},
                  {"label": "Service Provider", "value": detail.serviceProvider ?? "Quick"},
                  {"label": "Support", "value": detail.supportTeam ?? "Quick team"},
                  {"label": "SLA", "value": _formatDateTime(detail.slaDueAt)},
                  {"label": "Created", "value": _formatDateTime(detail.createdAt)},
                  {"label": "Estimated Completion", "value": _formatDateTime(detail.expectedCompletionAt)},
                ]),
                16.height,
                // Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Progress", style: boldTextStyle(size: 14)),
                    Text("${detail.progress ?? 15}%", style: boldTextStyle(size: 14, color: brandBlue)),
                  ],
                ),
                6.height,
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ((detail.progress ?? 15).toDouble()) / 100.0,
                    minHeight: 8,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(brandBlue),
                  ),
                ),
                12.height,
                // Stage Pill & Description
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStageColor(detail.sanadStage).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        detail.stageLabel ?? detail.sanadStage?.capitalizeFirstLetter() ?? "Submitted",
                        style: boldTextStyle(size: 12, color: _getStageColor(detail.sanadStage)),
                      ),
                    ),
                    10.width,
                    Expanded(
                      child: Text(
                        detail.stageDescription ?? "The next expected step is managed by the Quick team.",
                        style: secondaryTextStyle(size: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          14.height,

          // Timeline / Request History Card
          _buildCard(
            title: "Timeline",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.timeline != null && detail.timeline!.isNotEmpty) ...[
                  for (int i = 0; i < detail.timeline!.length; i++) ...[
                    _buildTimelineRow(
                      item: detail.timeline![i],
                      isLast: i == detail.timeline!.length - 1,
                    ),
                  ],
                ] else ...[
                  Text("No timeline events yet", style: secondaryTextStyle()),
                ],
              ],
            ),
          ),
          14.height,

          // Quick Support Card
          _buildCard(
            title: "Quick Support",
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Need help with this request?", style: boldTextStyle(size: 14)),
                      4.height,
                      Text("Open this request's dedicated conversation with the Quick team.", style: secondaryTextStyle(size: 12)),
                    ],
                  ),
                ),
                12.width,
                AppButton(
                  text: "Talk to Quick",
                  color: brandBlue,
                  textColor: Colors.white,
                  onTap: () {
                    UserChatScreen(requestId: detail.id).launch(context);
                  },
                ),
              ],
            ),
          ),
          14.height,

          // Required Documents Card
          _buildCard(
            title: "Required Documents",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.requiredDocuments != null && detail.requiredDocuments!.isNotEmpty) ...[
                  for (final doc in detail.requiredDocuments!) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: context.dividerColor, width: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(doc.name ?? "Document", style: primaryTextStyle(size: 13)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getDocBadgeColor(doc.status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              doc.status?.capitalizeFirstLetter() ?? "Required",
                              style: boldTextStyle(size: 11, color: _getDocBadgeColor(doc.status)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  Text("No required document list configured.", style: secondaryTextStyle(size: 13)).paddingBottom(8),
                ],

                // Document Upload Form
                if (detail.documentChoices != null && detail.documentChoices!.isNotEmpty) ...[
                  16.height,
                  Text("Upload Required Document", style: boldTextStyle(size: 13)),
                  8.height,
                  DropdownButtonFormField<String>(
                    value: selectedChoiceId,
                    isExpanded: true,
                    decoration: inputDecoration(context, labelText: "Select Document Type"),
                    items: detail.documentChoices!.map((choice) {
                      return DropdownMenuItem<String>(
                        value: choice.id,
                        child: Text(choice.label ?? choice.name ?? "Document", overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedChoiceId = val);
                    },
                  ),
                  10.height,
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final file = await picker.pickImage(source: ImageSource.gallery);
                          if (file != null) {
                            setState(() => pickedFile = file);
                          }
                        },
                        icon: const Icon(Icons.attach_file, size: 16),
                        label: Text(
                          pickedFile != null ? pickedFile!.name : "Choose File",
                          style: secondaryTextStyle(size: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).expand(),
                      12.width,
                      AppButton(
                        text: isUploading ? "Uploading..." : "Upload",
                        color: brandBlue,
                        textColor: Colors.white,
                        enabled: !isUploading,
                        onTap: () => _handleUpload(detail),
                      ),
                    ],
                  ),
                ] else ...[
                  Text("There are no requested documents to upload right now.", style: secondaryTextStyle(size: 12)).paddingTop(6),
                ],
              ],
            ),
          ),
          14.height,

          // Document Requests & Buzz Card
          if (detail.pendingDocumentRequests != null && detail.pendingDocumentRequests!.isNotEmpty) ...[
            _buildCard(
              title: "Document Requests",
              child: Column(
                children: [
                  for (final req in detail.pendingDocumentRequests!) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: context.dividerColor, width: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(req.documentName ?? "Document Request", style: boldTextStyle(size: 13)),
                                if (req.instructions != null || req.reason != null)
                                  Text(req.instructions ?? req.reason ?? "", style: secondaryTextStyle(size: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              req.status?.capitalizeFirstLetter() ?? "Pending",
                              style: boldTextStyle(size: 11, color: Colors.deepOrange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            14.height,
          ],

          // Verified Documents Card
          if (detail.verifiedDocuments != null && detail.verifiedDocuments!.isNotEmpty) ...[
            _buildCard(
              title: "Verified Documents",
              child: Column(
                children: [
                  for (final doc in detail.verifiedDocuments!) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: context.dividerColor, width: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doc.documentType ?? doc.fileName ?? "Verified Document", style: boldTextStyle(size: 13)),
                                if (doc.approvedAt != null)
                                  Text("Approved: ${_formatDateTime(doc.approvedAt)}", style: secondaryTextStyle(size: 11)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: brandGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text("Verified", style: boldTextStyle(size: 11, color: brandGreen)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            14.height,
          ],

          // Billing & Payment Card
          _buildCard(
            title: "Billing & Payment",
            child: Column(
              children: [
                _buildBillingRow("Invoice", (detail.billing?.invoiceAvailable == true) ? "Available" : "-"),
                _buildBillingRow("Service Fee", "${detail.billing?.serviceFee ?? 0} SAR"),
                _buildBillingRow("VAT", "${detail.billing?.vat ?? 0} SAR"),
                _buildBillingRow("Total Amount", "${detail.billing?.totalAmount ?? 0} SAR", isBold: true),
                _buildBillingRow("Payment Status", detail.billing?.paymentStatus?.capitalizeFirstLetter() ?? "Pending"),
                _buildBillingRow("Payment Method", detail.billing?.paymentMethod ?? "Not Specified"),
              ],
            ),
          ),
          18.height,

          // State Management & Cancellation Action
          if (detail.cancellationAllowed == true) ...[
            AppButton(
              width: context.width(),
              text: "Cancel Request",
              color: Colors.white,
              textColor: brandRed,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: brandRed, width: 1.5),
              ),
              onTap: () => _showCancelDialog(detail),
            ),
          ] else ...[
            Container(
              width: context.width(),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_clock, size: 18, color: brandNavy),
                      8.width,
                      Expanded(
                        child: Text(
                          detail.cancellationNotice ??
                              "This request has been accepted and is being processed. Cancellation requires contacting Quick Support.",
                          style: secondaryTextStyle(size: 12),
                        ),
                      ),
                    ],
                  ),
                  10.height,
                  AppButton(
                    width: context.width(),
                    text: "Request Cancellation via Support",
                    color: brandNavy,
                    textColor: Colors.white,
                    onTap: () {
                      UserChatScreen(requestId: detail.id).launch(context);
                    },
                  ),
                ],
              ),
            ),
          ],
          24.height,
        ],
      ),
    );
  }

  Color _getDocBadgeColor(String? status) {
    switch (status?.toLowerCase()) {
      case "verified":
      case "approved":
        return brandGreen;
      case "submitted":
        return brandBlue;
      default:
        return brandRed;
    }
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: context.width(),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: boldTextStyle(size: 15)),
          12.height,
          child,
        ],
      ),
    );
  }

  Widget _buildInfoGrid(List<Map<String, String>> items) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: items.map((item) {
        return SizedBox(
          width: (context.width() - 80) / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item["label"]!, style: secondaryTextStyle(size: 11)),
              2.height,
              Text(item["value"]!, style: boldTextStyle(size: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimelineRow({required SanadRequestTimelineItem item, required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: brandBlue,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: brandBlue.withOpacity(0.3),
              ),
          ],
        ),
        12.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title ?? "Status Updated", style: boldTextStyle(size: 13)),
              2.height,
              Text(item.note ?? "Request status updated", style: secondaryTextStyle(size: 12)),
              2.height,
              Text(_formatDateTime(item.createdAt), style: secondaryTextStyle(size: 10)),
              8.height,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillingRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? boldTextStyle(size: 13) : secondaryTextStyle(size: 13)),
          Text(value, style: isBold ? boldTextStyle(size: 14, color: brandBlue) : primaryTextStyle(size: 13)),
        ],
      ),
    );
  }
}
