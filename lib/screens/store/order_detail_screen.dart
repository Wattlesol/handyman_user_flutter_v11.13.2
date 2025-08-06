import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/empty_error_state_widget.dart';

import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/utils/colors.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic>? orderData;

  const OrderDetailScreen({
    Key? key,
    required this.orderId,
    this.orderData,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? orderDetails;
  Map<String, dynamic>? trackingInfo;
  bool isLoading = true;
  bool isLoadingTracking = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (widget.orderData != null) {
      orderDetails = widget.orderData;
      setState(() {
        isLoading = false;
      });
    } else {
      await loadOrderDetails();
    }
    await loadTrackingInfo();
  }

  Future<void> loadOrderDetails() async {
    try {
      setState(() {
        isLoading = true;
      });

      var response = await getOrderDetails(widget.orderId);
      orderDetails = response['data'] ?? response;

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading order details: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> loadTrackingInfo() async {
    try {
      setState(() {
        isLoadingTracking = true;
      });

      var response = await trackOrder(widget.orderId);
      trackingInfo = response['data'] ?? response;

      if (mounted) {
        setState(() {
          isLoadingTracking = false;
        });
      }
    } catch (e) {
      print('Error loading tracking info: $e');
      if (mounted) {
        setState(() {
          isLoadingTracking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        elevation: 0,
        backgroundColor: context.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: boldTextStyle(color: Colors.white, size: 18),
      ),
      body: isLoading
          ? LoaderWidget()
          : orderDetails == null
              ? NoDataWidget(
                  title: 'Order Not Found',
                  imageWidget: EmptyStateWidget(),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderHeader(),
                      16.height,
                      _buildOrderStatus(),
                      16.height,
                      _buildTrackingInfo(),
                      16.height,
                      _buildOrderItems(),
                      16.height,
                      _buildDeliveryAddress(),
                      16.height,
                      _buildPaymentInfo(),
                      16.height,
                      _buildOrderSummary(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOrderHeader() {
    String orderId = orderDetails?['id']?.toString() ?? '';
    String orderNumber = orderDetails?['order_number']?.toString() ??
        orderDetails?['formatted_order_number']?.toString() ??
        'Order #$orderId';
    String createdAt = orderDetails?['created_at']?.toString() ?? '';

    DateTime? orderDate;
    try {
      orderDate = DateTime.parse(createdAt);
    } catch (e) {
      orderDate = DateTime.now();
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderNumber,
                style: boldTextStyle(size: 18),
              ),
              Text(
                '${orderDate.day}/${orderDate.month}/${orderDate.year}',
                style: secondaryTextStyle(),
              ),
            ],
          ),
          8.height,
          Text(
            'Placed on ${orderDate.day}/${orderDate.month}/${orderDate.year} at ${orderDate.hour}:${orderDate.minute.toString().padLeft(2, '0')}',
            style: secondaryTextStyle(size: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus() {
    String status = orderDetails?['status']?.toString() ?? '';
    Color statusColor = _getStatusColor(status);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Status',
                  style: secondaryTextStyle(size: 12),
                ),
                Text(
                  status.toUpperCase(),
                  style: boldTextStyle(color: statusColor, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfo() {
    if (isLoadingTracking) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(),
          backgroundColor: context.cardColor,
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (trackingInfo == null) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(),
          backgroundColor: context.cardColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Tracking',
              style: boldTextStyle(size: 16),
            ),
            12.height,
            Text(
              'Tracking information will be available once your order is shipped.',
              style: secondaryTextStyle(),
            ),
          ],
        ),
      );
    }

    List<dynamic> trackingSteps = trackingInfo?['tracking_steps'] ?? [];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Tracking',
            style: boldTextStyle(size: 16),
          ),
          16.height,
          if (trackingSteps.isEmpty)
            Text(
              'No tracking information available yet.',
              style: secondaryTextStyle(),
            )
          else
            ...trackingSteps.map((step) => _buildTrackingStep(step)).toList(),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(Map<String, dynamic> step) {
    String title = step['title'] ?? '';
    String description = step['description'] ?? '';
    String timestamp = step['timestamp'] ?? '';
    bool isCompleted = step['is_completed'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isCompleted ? primaryColor : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 12)
                : null,
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
                if (description.isNotEmpty) ...[
                  4.height,
                  Text(
                    description,
                    style: secondaryTextStyle(size: 12),
                  ),
                ],
                if (timestamp.isNotEmpty) ...[
                  4.height,
                  Text(
                    timestamp,
                    style: secondaryTextStyle(size: 10),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    List<dynamic> items = orderDetails?['items'] ?? [];
    if (items.isEmpty) {
      // If no items array, try to build from product info
      if (orderDetails?['product'] != null) {
        items = [orderDetails!['product']];
      }
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items',
            style: boldTextStyle(size: 16),
          ),
          16.height,
          if (items.isEmpty)
            Text(
              'No items information available.',
              style: secondaryTextStyle(),
            )
          else
            ...items.map((item) => _buildOrderItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    String name = item['name'] ?? item['product_name'] ?? '';
    String image = item['image'] ??
        item['product_image'] ??
        'http://127.0.0.1:8000/images/default.png';
    int quantity = item['quantity'] ?? 1;
    double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: radius(8),
              backgroundColor: context.scaffoldBackgroundColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image, color: context.iconColor);
                },
              ),
            ),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: boldTextStyle(size: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                Text(
                  'Quantity: $quantity',
                  style: secondaryTextStyle(size: 12),
                ),
                4.height,
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: boldTextStyle(color: primaryColor, size: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    var addressData = orderDetails?['delivery_address'];
    if (addressData == null) return Offstage();

    Map<String, dynamic>? address;

    // Handle both JSON string and Map formats
    if (addressData is String) {
      try {
        address = Map<String, dynamic>.from(json.decode(addressData));
      } catch (e) {
        print('Error parsing delivery address JSON: $e');
        return Offstage();
      }
    } else if (addressData is Map<String, dynamic>) {
      address = addressData;
    } else {
      return Offstage();
    }

    String fullAddress = '';
    String name = address['name']?.toString() ?? '';
    String addressLine =
        address['address']?.toString() ?? address['street']?.toString() ?? '';
    String city = address['city']?.toString() ?? '';
    String state = address['state']?.toString() ?? '';
    String zip =
        address['zip']?.toString() ?? address['zip_code']?.toString() ?? '';
    String country = address['country']?.toString() ?? '';
    String phone = orderDetails?['delivery_phone']?.toString() ?? '';

    if (name.isNotEmpty) fullAddress += '$name\n';
    if (addressLine.isNotEmpty) fullAddress += '$addressLine\n';
    if (city.isNotEmpty || state.isNotEmpty || zip.isNotEmpty) {
      fullAddress += '$city';
      if (state.isNotEmpty) fullAddress += ', $state';
      if (zip.isNotEmpty) fullAddress += ' $zip';
      fullAddress += '\n';
    }
    if (country.isNotEmpty) fullAddress += country;
    if (phone.isNotEmpty) fullAddress += '\nPhone: $phone';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Address',
            style: boldTextStyle(size: 16),
          ),
          12.height,
          Text(
            fullAddress.isNotEmpty ? fullAddress.trim() : 'No address provided',
            style: primaryTextStyle(size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    String paymentMethod = orderDetails?['payment_method']?.toString() ?? '';
    String paymentStatus = orderDetails?['payment_status']?.toString() ?? '';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Information',
            style: boldTextStyle(size: 16),
          ),
          12.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment Method', style: secondaryTextStyle()),
              Text(paymentMethod.toUpperCase(), style: primaryTextStyle()),
            ],
          ),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment Status', style: secondaryTextStyle()),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: _getPaymentStatusColor(paymentStatus)
                      .withValues(alpha: 0.1),
                  borderRadius: radius(12),
                ),
                child: Text(
                  paymentStatus.toUpperCase(),
                  style: boldTextStyle(
                      color: _getPaymentStatusColor(paymentStatus), size: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    double subtotal =
        double.tryParse(orderDetails?['subtotal']?.toString() ?? '0') ?? 0;
    double taxAmount =
        double.tryParse(orderDetails?['tax_amount']?.toString() ?? '0') ?? 0;
    double deliveryFee =
        double.tryParse(orderDetails?['delivery_fee']?.toString() ?? '0') ?? 0;
    double total = double.tryParse(orderDetails?['total_amount']?.toString() ??
            orderDetails?['total']?.toString() ??
            '0') ??
        0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: boldTextStyle(size: 16),
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: primaryTextStyle()),
              Text('\$${subtotal.toStringAsFixed(2)}',
                  style: primaryTextStyle()),
            ],
          ),
          8.height,
          if (taxAmount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax', style: primaryTextStyle()),
                Text('\$${taxAmount.toStringAsFixed(2)}',
                    style: primaryTextStyle()),
              ],
            ),
            8.height,
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery Fee', style: primaryTextStyle()),
              Text(
                  deliveryFee > 0
                      ? '\$${deliveryFee.toStringAsFixed(2)}'
                      : 'Free',
                  style: primaryTextStyle()),
            ],
          ),
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: boldTextStyle(size: 16)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: boldTextStyle(size: 16, color: primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
