import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../model/sanad_chat_model.dart';
import '../../../utils/colors.dart';

class SanadDocumentRequestCardWidget extends StatelessWidget {
  final SanadDocumentRequestModel docRequest;
  final VoidCallback? onUploadTap;

  const SanadDocumentRequestCardWidget({
    Key? key,
    required this.docRequest,
    this.onUploadTap,
  }) : super(key: key);

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return brandGreenLight;
      case 'submitted':
        return brandBlueLight;
      case 'replacement_requested':
      case 'rejected':
        return brandRedLight;
      default:
        return brandYellowLight;
    }
  }

  String _getStatusText(String? status) {
    if (status == null || status.isEmpty) return 'Action Required';
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Upload';
      case 'submitted':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'replacement_requested':
        return 'Re-upload Needed';
      default:
        return status.capitalizeFirstLetter();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPending = docRequest.status == 'pending' || docRequest.status == 'replacement_requested';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brandBlueLight.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Document icon + Title + Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: brandBlueLight.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description, color: brandBlueLight, size: 18),
              ),
              10.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      docRequest.documentName ?? 'Required Document',
                      style: boldTextStyle(size: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    2.height,
                    Text(
                      docRequest.required == true ? 'Mandatory Document' : 'Optional Attachment',
                      style: secondaryTextStyle(size: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _getStatusColor(docRequest.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusText(docRequest.status),
                  style: boldTextStyle(
                    size: 10,
                    color: _getStatusColor(docRequest.status),
                  ),
                ),
              ),
            ],
          ),
          8.height,

          // Reason / Instructions
          if (docRequest.reason != null && docRequest.reason!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'Reason: ${docRequest.reason}',
                style: primaryTextStyle(size: 13),
              ),
            ),
          if (docRequest.instructions != null && docRequest.instructions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Instructions: ${docRequest.instructions}',
                style: secondaryTextStyle(size: 12),
              ),
            ),

          if (isPending) ...[
            8.height,
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: brandBlueLight, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: brandBlueLight.withOpacity(0.04),
                ),
                icon: const Icon(Icons.cloud_upload_outlined, size: 16, color: brandBlueLight),
                label: Text(
                  'Upload / Attach from Vault',
                  style: boldTextStyle(color: brandBlueLight, size: 13),
                ),
                onPressed: () {
                  if (onUploadTap != null) {
                    onUploadTap!();
                  } else {
                    toast('Opening document upload...');
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
