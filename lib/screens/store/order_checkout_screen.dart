import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/screens/store/order_success_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';

class OrderCheckoutScreen extends StatefulWidget {
  final ProductData product;
  final int quantity;

  const OrderCheckoutScreen({
    Key? key,
    required this.product,
    required this.quantity,
  }) : super(key: key);

  @override
  State<OrderCheckoutScreen> createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends State<OrderCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Address fields
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipController = TextEditingController();
  final countryController = TextEditingController(text: 'USA');
  final phoneController = TextEditingController();
  final notesController = TextEditingController();

  // Payment
  List<Map<String, dynamic>> paymentMethods = [];
  String? selectedPaymentMethod;
  bool isLoading = false;
  bool isLoadingPaymentMethods = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await loadPaymentMethods();
    // Pre-fill address if user has saved address
    await loadUserAddress();
  }

  Future<void> loadPaymentMethods() async {
    try {
      setState(() {
        isLoadingPaymentMethods = true;
      });

      paymentMethods = await getPaymentMethods();

      if (paymentMethods.isNotEmpty) {
        selectedPaymentMethod = paymentMethods.first['key'] ??
            paymentMethods.first['id']?.toString();
      }

      if (mounted) {
        setState(() {
          isLoadingPaymentMethods = false;
        });
      }
    } catch (e) {
      print('Error loading payment methods: $e');
      // Add default payment methods as fallback
      paymentMethods = [
        {'key': 'cash', 'name': 'Cash on Delivery', 'icon': 'money'},
        {'key': 'wallet', 'name': 'Wallet', 'icon': 'account_balance_wallet'},
        {'key': 'stripe', 'name': 'Credit/Debit Card', 'icon': 'credit_card'},
      ];
      selectedPaymentMethod = 'cash';

      if (mounted) {
        setState(() {
          isLoadingPaymentMethods = false;
        });
      }
    }
  }

  Future<void> loadUserAddress() async {
    // TODO: Load user's saved address from preferences or API
    // For now, we'll leave fields empty for user to fill
  }

  Future<void> placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedPaymentMethod == null) {
      toast('Please select a payment method');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> deliveryAddress = {
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'zip': zipController.text.trim(),
        'country': countryController.text.trim(),
      };

      var response = await createOrder(
        productId: widget.product.id!,
        quantity: widget.quantity,
        deliveryAddress: deliveryAddress,
        deliveryPhone: phoneController.text.trim(),
        paymentMethod: selectedPaymentMethod!,
        deliveryNotes: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
      );

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Navigate to success screen
        OrderSuccessScreen(
          orderId: response['data']?['id'] ?? response['id'],
          orderData: response,
        ).launch(context, isNewTask: true);
      }
    } catch (e) {
      print('Error placing order: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        toast('Failed to place order: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Additional safety check - redirect to login if not authenticated
    if (!appStore.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        SignInScreen(returnExpected: true).launch(context);
      });
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double totalPrice =
        ((widget.product.salePrice ?? widget.product.price ?? 0).toDouble()) *
            widget.quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        elevation: 0,
        backgroundColor: context.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: boldTextStyle(color: Colors.white, size: 18),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(),
                  24.height,
                  _buildDeliveryAddress(),
                  24.height,
                  _buildPaymentMethods(),
                  24.height,
                  _buildOrderNotes(),
                  24.height,
                  _buildOrderTotal(totalPrice),
                  100.height, // Space for bottom button
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(child: LoaderWidget()),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(totalPrice),
    );
  }

  Widget _buildOrderSummary() {
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
                    widget.product.images?.first ??
                        'http://127.0.0.1:8000/images/default.png',
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
                      widget.product.name ?? '',
                      style: boldTextStyle(size: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.height,
                    Text(
                      'Quantity: ${widget.quantity}',
                      style: secondaryTextStyle(size: 12),
                    ),
                    4.height,
                    Text(
                      '\$${(widget.product.salePrice ?? widget.product.price ?? 0).toStringAsFixed(2)} each',
                      style: boldTextStyle(color: primaryColor, size: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
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
          16.height,
          TextFormField(
            controller: nameController,
            decoration: inputDecoration(context, labelText: 'Full Name'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          16.height,
          TextFormField(
            controller: addressController,
            decoration: inputDecoration(context, labelText: 'Street Address'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter street address';
              }
              return null;
            },
          ),
          16.height,
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: cityController,
                  decoration: inputDecoration(context, labelText: 'City'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
              ),
              12.width,
              Expanded(
                child: TextFormField(
                  controller: stateController,
                  decoration: inputDecoration(context, labelText: 'State'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter state';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          16.height,
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: zipController,
                  decoration: inputDecoration(context, labelText: 'ZIP Code'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter ZIP code';
                    }
                    return null;
                  },
                ),
              ),
              12.width,
              Expanded(
                child: TextFormField(
                  controller: countryController,
                  decoration: inputDecoration(context, labelText: 'Country'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter country';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          16.height,
          TextFormField(
            controller: phoneController,
            decoration: inputDecoration(context, labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
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
            'Payment Method',
            style: boldTextStyle(size: 16),
          ),
          16.height,
          if (isLoadingPaymentMethods)
            Center(child: CircularProgressIndicator())
          else
            ...paymentMethods.map((method) {
              String key = method['key'] ?? method['id']?.toString() ?? '';
              String name = method['name'] ?? method['title'] ?? key;

              return RadioListTile<String>(
                value: key,
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value;
                  });
                },
                title: Text(name, style: primaryTextStyle()),
                contentPadding: EdgeInsets.zero,
                activeColor: primaryColor,
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderNotes() {
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
            'Order Notes (Optional)',
            style: boldTextStyle(size: 16),
          ),
          16.height,
          TextFormField(
            controller: notesController,
            decoration: inputDecoration(context,
                labelText: 'Special instructions for delivery'),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotal(double totalPrice) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: primaryTextStyle()),
              Text('\$${totalPrice.toStringAsFixed(2)}',
                  style: primaryTextStyle()),
            ],
          ),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery Fee', style: primaryTextStyle()),
              Text('Free', style: primaryTextStyle(color: Colors.green)),
            ],
          ),
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: boldTextStyle(size: 18)),
              Text('\$${totalPrice.toStringAsFixed(2)}',
                  style: boldTextStyle(size: 18, color: primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double totalPrice) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
        ),
        child: Text(
          isLoading
              ? 'Placing Order...'
              : 'Place Order - \$${totalPrice.toStringAsFixed(2)}',
          style: boldTextStyle(color: Colors.white, size: 16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    countryController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
