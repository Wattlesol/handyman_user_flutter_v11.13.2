import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/empty_error_state_widget.dart';

import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/screens/store/order_detail_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';

class MyOrdersScreen extends StatefulWidget {
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> allOrders = [];
  List<Map<String, dynamic>> pendingOrders = [];
  List<Map<String, dynamic>> completedOrders = [];
  List<Map<String, dynamic>> cancelledOrders = [];

  bool isLoading = true;
  int currentPage = 1;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void init() async {
    await loadOrders();
  }

  Future<void> loadOrders({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      hasMoreData = true;
    }

    try {
      setState(() {
        isLoading = true;
      });

      var response = await getMyOrders(page: currentPage, perPage: 20);

      List<Map<String, dynamic>> orders = _parseOrdersResponse(response);

      if (isRefresh) {
        allOrders.clear();
        pendingOrders.clear();
        completedOrders.clear();
        cancelledOrders.clear();
      }

      allOrders.addAll(orders);

      // Filter orders by status
      for (var order in orders) {
        String status = order['status']?.toString().toLowerCase() ?? '';
        switch (status) {
          case 'pending':
          case 'processing':
          case 'confirmed':
            pendingOrders.add(order);
            break;
          case 'completed':
          case 'delivered':
            completedOrders.add(order);
            break;
          case 'cancelled':
          case 'rejected':
            cancelledOrders.add(order);
            break;
        }
      }

      hasMoreData = orders.length >= 20;
      currentPage++;

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading orders: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _parseOrdersResponse(
      Map<String, dynamic> response) {
    List<Map<String, dynamic>> orders = [];

    try {
      print('Parsing orders response...');

      // More defensive parsing with explicit type checks
      if (response['data'] != null) {
        var data = response['data'];
        print('Data type: ${data.runtimeType}');

        if (data is Map<String, dynamic> &&
            data['data'] != null &&
            data['data'] is List) {
          // Laravel pagination format: response.data.data[]
          print('Using Laravel pagination format');
          var dataList = data['data'] as List;
          print('Data list length: ${dataList.length}');

          for (int i = 0; i < dataList.length; i++) {
            try {
              var item = dataList[i];
              print('Item $i type: ${item.runtimeType}');
              if (item is Map<String, dynamic>) {
                orders.add(Map<String, dynamic>.from(item));
              } else {
                print('Skipping non-map item at index $i: $item');
              }
            } catch (e) {
              print('Error parsing order item at index $i: $e');
              // Skip this item and continue
            }
          }
        } else if (data is List) {
          // Direct array format: response.data[]
          print('Using direct array format');
          print('Data list length: ${data.length}');

          for (int i = 0; i < data.length; i++) {
            try {
              var item = data[i];
              print('Item $i type: ${item.runtimeType}');
              if (item is Map<String, dynamic>) {
                orders.add(Map<String, dynamic>.from(item));
              } else {
                print('Skipping non-map item at index $i: $item');
              }
            } catch (e) {
              print('Error parsing order item at index $i: $e');
              // Skip this item and continue
            }
          }
        } else if (data is Map<String, dynamic>) {
          // Single order object format
          print('Using single order format');
          orders.add(Map<String, dynamic>.from(data));
        } else {
          print('Unexpected data format: ${data.runtimeType}');
        }
      } else {
        print('No data field in response');
      }
    } catch (e, stackTrace) {
      print('Error parsing orders response: $e');
      print('Stack trace: $stackTrace');
      orders = []; // Ensure orders is empty on parsing error
    }

    print('Parsed ${orders.length} orders successfully');
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    if (!appStore.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Orders'),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.login,
                size: 64,
                color: Colors.grey,
              ),
              16.height,
              Text(
                'Please Sign In',
                style: boldTextStyle(size: 18),
              ),
              8.height,
              Text(
                'You need to sign in to view your orders',
                style: secondaryTextStyle(),
                textAlign: TextAlign.center,
              ),
              24.height,
              ElevatedButton(
                onPressed: () {
                  SignInScreen(returnExpected: true)
                      .launch(context)
                      .then((value) {
                    if (value == true && appStore.isLoggedIn) {
                      setState(() {
                        init(); // Reload orders after login
                      });
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        elevation: 0,
        backgroundColor: context.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: boldTextStyle(color: Colors.white, size: 18),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'All (${allOrders.length})'),
            Tab(text: 'Pending (${pendingOrders.length})'),
            Tab(text: 'Completed (${completedOrders.length})'),
            Tab(text: 'Cancelled (${cancelledOrders.length})'),
          ],
        ),
      ),
      body: isLoading && allOrders.isEmpty
          ? LoaderWidget()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(allOrders),
                _buildOrdersList(pendingOrders),
                _buildOrdersList(completedOrders),
                _buildOrdersList(cancelledOrders),
              ],
            ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty && !isLoading) {
      return NoDataWidget(
        title: 'No Orders Found',
        subTitle: 'You haven\'t placed any orders yet',
        imageWidget: EmptyStateWidget(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => loadOrders(isRefresh: true),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: orders.length + (hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orders.length) {
            // Load more indicator
            return Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    String status = order['status']?.toString() ?? '';
    String orderId = order['id']?.toString() ?? '';
    String orderNumber = order['order_number']?.toString() ??
        order['formatted_order_number']?.toString() ??
        '#$orderId';
    String total =
        order['total_amount']?.toString() ?? order['total']?.toString() ?? '0';
    String createdAt = order['created_at']?.toString() ?? '';

    // Parse date
    DateTime? orderDate;
    try {
      orderDate = DateTime.parse(createdAt);
    } catch (e) {
      orderDate = DateTime.now();
    }

    Color statusColor = _getStatusColor(status);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: InkWell(
        onTap: () {
          OrderDetailScreen(
            orderId: int.tryParse(orderId) ?? 0,
            orderData: order,
          ).launch(context);
        },
        borderRadius: BorderRadius.circular(defaultRadius),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    orderNumber,
                    style: boldTextStyle(size: 16),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: statusColor.withValues(alpha: 0.1),
                      borderRadius: radius(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: boldTextStyle(color: statusColor, size: 10),
                    ),
                  ),
                ],
              ),
              12.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: secondaryTextStyle(size: 12),
                      ),
                      Text(
                        '\$$total',
                        style: boldTextStyle(color: primaryColor, size: 16),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Order Date',
                        style: secondaryTextStyle(size: 12),
                      ),
                      Text(
                        '${orderDate.day}/${orderDate.month}/${orderDate.year}',
                        style: primaryTextStyle(size: 14),
                      ),
                    ],
                  ),
                ],
              ),
              16.height,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        OrderDetailScreen(
                          orderId: int.tryParse(orderId) ?? 0,
                          orderData: order,
                        ).launch(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: boldTextStyle(color: primaryColor, size: 12),
                      ),
                    ),
                  ),
                  12.width,
                  if (status.toLowerCase() == 'pending' ||
                      status.toLowerCase() == 'processing')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showCancelDialog(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: boldTextStyle(color: Colors.white, size: 12),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Track order or reorder functionality
                          _trackOrder(order);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Track Order',
                          style: boldTextStyle(color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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

  void _showCancelDialog(Map<String, dynamic> order) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel this order?'),
            16.height,
            TextFormField(
              controller: reasonController,
              decoration:
                  inputDecoration(context, labelText: 'Reason (Optional)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelOrder(order, reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(Map<String, dynamic> order, String reason) async {
    try {
      int orderId = int.tryParse(order['id']?.toString() ?? '') ?? 0;
      await cancelOrder(orderId, reason.isEmpty ? 'Cancelled by user' : reason);

      toast('Order cancelled successfully');
      loadOrders(isRefresh: true);
    } catch (e) {
      toast('Failed to cancel order: ${e.toString()}');
    }
  }

  void _trackOrder(Map<String, dynamic> order) {
    OrderDetailScreen(
      orderId: int.tryParse(order['id']?.toString() ?? '') ?? 0,
      orderData: order,
    ).launch(context);
  }
}
