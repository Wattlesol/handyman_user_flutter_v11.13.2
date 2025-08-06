import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/screens/store/my_orders_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';

class OrderSuccessScreen extends StatefulWidget {
  final dynamic orderId;
  final Map<String, dynamic>? orderData;

  const OrderSuccessScreen({
    Key? key,
    required this.orderId,
    this.orderData,
  }) : super(key: key);

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                      32.height,
                      Text(
                        'Order Placed Successfully!',
                        style: boldTextStyle(size: 24),
                        textAlign: TextAlign.center,
                      ),
                      16.height,
                      Text(
                        'Thank you for your order. We\'ll send you a confirmation email shortly.',
                        style: secondaryTextStyle(size: 16),
                        textAlign: TextAlign.center,
                      ),
                      24.height,
                      _buildOrderInfo(),
                      24.height,
                      _buildNextSteps(),
                      24.height, // Add some bottom padding for scroll
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID',
                style: secondaryTextStyle(),
              ),
              Text(
                widget.orderData?['data']?['order_number'] ??
                    '#${widget.orderId}',
                style: boldTextStyle(color: primaryColor),
              ),
            ],
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status',
                style: secondaryTextStyle(),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: radius(12),
                ),
                child: Text(
                  'Processing',
                  style: boldTextStyle(color: Colors.orange, size: 12),
                ),
              ),
            ],
          ),
          if (widget.orderData?['data']?['total_amount'] != null) ...[
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: secondaryTextStyle(),
                ),
                Text(
                  '\$${widget.orderData?['data']?['total_amount']?.toString() ?? '0'}',
                  style: boldTextStyle(color: primaryColor, size: 16),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextSteps() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: primaryColor.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Next?',
            style: boldTextStyle(size: 16, color: primaryColor),
          ),
          16.height,
          _buildStepItem(
            icon: Icons.email_outlined,
            title: 'Confirmation Email',
            subtitle: 'You\'ll receive an order confirmation email',
          ),
          12.height,
          _buildStepItem(
            icon: Icons.inventory_2_outlined,
            title: 'Order Processing',
            subtitle: 'We\'ll prepare your order for shipment',
          ),
          12.height,
          _buildStepItem(
            icon: Icons.local_shipping_outlined,
            title: 'Shipping Updates',
            subtitle: 'Track your order in the My Orders section',
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        12.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: boldTextStyle(size: 14),
              ),
              Text(
                subtitle,
                style: secondaryTextStyle(size: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              MyOrdersScreen().launch(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
            ),
            child: Text(
              'Track Order',
              style: boldTextStyle(color: Colors.white, size: 16),
            ),
          ),
        ),
        16.height,
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
            ),
            child: Text(
              'Continue Shopping',
              style: boldTextStyle(color: primaryColor, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
