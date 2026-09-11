import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../model/sanad_chat_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';

class SanadBuzzAlertCardWidget extends StatefulWidget {
  final SanadBuzzAlertModel buzzAlert;
  final VoidCallback? onAcknowledged;

  const SanadBuzzAlertCardWidget({
    Key? key,
    required this.buzzAlert,
    this.onAcknowledged,
  }) : super(key: key);

  @override
  _SanadBuzzAlertCardWidgetState createState() => _SanadBuzzAlertCardWidgetState();
}

class _SanadBuzzAlertCardWidgetState extends State<SanadBuzzAlertCardWidget> {
  bool isAcknowledging = false;
  bool isAcknowledged = false;

  @override
  void initState() {
    super.initState();
    isAcknowledged = widget.buzzAlert.status == 'acknowledged';
  }

  Future<void> _handleAcknowledge() async {
    if (widget.buzzAlert.id == null || isAcknowledged) return;
    setState(() => isAcknowledging = true);
    try {
      await acknowledgeBuzzAlert(widget.buzzAlert.id!);
      setState(() {
        isAcknowledged = true;
        isAcknowledging = false;
      });
      toast('Alert acknowledged');
      widget.onAcknowledged?.call();
    } catch (e) {
      setState(() => isAcknowledging = false);
      toast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brandRedLight.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: brandRedLight.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Buzz Alert Icon + Priority Pill + Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: brandRedLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 14),
              ),
              8.width,
              Expanded(
                child: Text(
                  'Urgent Buzz Alert',
                  style: boldTextStyle(size: 14, color: brandRedDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isAcknowledged ? brandGreenLight.withOpacity(0.15) : brandRedLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAcknowledged ? 'Acknowledged' : (widget.buzzAlert.priority?.toUpperCase() ?? 'URGENT'),
                  style: boldTextStyle(
                    size: 10,
                    color: isAcknowledged ? brandGreenDark : brandRedDark,
                  ),
                ),
              ),
            ],
          ),
          8.height,

          // Message Body
          Text(
            widget.buzzAlert.message ?? '',
            style: primaryTextStyle(size: 13, color: const Color(0xFF2D1515)),
          ),
          12.height,

          // Acknowledge Action Button
          if (!isAcknowledged)
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandRedLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: isAcknowledging
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                label: Text(
                  isAcknowledging ? 'Processing...' : 'Acknowledge Notice',
                  style: boldTextStyle(color: Colors.white, size: 13),
                ),
                onPressed: isAcknowledging ? null : _handleAcknowledge,
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.check_circle, color: brandGreenLight, size: 16),
                6.width,
                Text(
                  'Acknowledged by you',
                  style: secondaryTextStyle(size: 12, color: brandGreenDark),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
