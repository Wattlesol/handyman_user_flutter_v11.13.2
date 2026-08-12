import 'package:booking_system_flutter/component/image_border_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/booking_data_model.dart';

class BookingDetailProviderWidget extends StatefulWidget {
  final UserData providerData;
  final bool canCustomerContact;
  final bool providerIsHandyman;
  final BookingData? bookingDetail;

  BookingDetailProviderWidget(
      {required this.providerData,
      this.canCustomerContact = false,
      this.providerIsHandyman = false,
      this.bookingDetail});

  @override
  BookingDetailProviderWidgetState createState() =>
      BookingDetailProviderWidgetState();
}

class BookingDetailProviderWidgetState
    extends State<BookingDetailProviderWidget> {
  UserData userData = UserData();

  bool isChattingAllow = false;

  int? flag;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    userData = widget.providerData;

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationDefault(
        color: context.cardColor,
        border: appStore.isDarkMode
            ? Border.all(color: context.dividerColor)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ImageBorder(
                  src: widget.providerData.profileImage.validate(), height: 60),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Marquee(
                                  child: Text('Sanad Operations',
                                      style: boldTextStyle()))
                              .flexible(),
                          16.width,
                          Image.asset(ic_verified,
                                  height: 16, color: Colors.green)
                              .visible(
                                  widget.providerData.isVerifyProvider == 1),
                        ],
                      ).expand(),
                    ],
                  ),
                  4.height,
                  Text('Sanad coordinates partner execution internally.',
                      style: secondaryTextStyle(size: 12)),
                ],
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }
}
