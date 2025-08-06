import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/empty_error_state_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/screens/store/order_checkout_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final ProductData? product; // Optional if already have product data

  const ProductDetailScreen({
    Key? key,
    required this.productId,
    this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductData? product;
  bool isLoading = true;
  int quantity = 1;
  int selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (widget.product != null) {
      product = widget.product;
      setState(() {
        isLoading = false;
      });
    } else {
      await loadProductDetails();
    }
  }

  Future<void> loadProductDetails() async {
    try {
      setState(() {
        isLoading = true;
      });

      product = await getProductDetails(widget.productId);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading product details: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product?.name ?? language.productDetails),
        elevation: 0,
        backgroundColor: context.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: boldTextStyle(color: Colors.white, size: 18),
      ),
      body: isLoading
          ? LoaderWidget()
          : product == null
              ? NoDataWidget(
                  title: 'Product not found',
                  imageWidget: EmptyStateWidget(),
                )
              : _buildProductDetails(),
      bottomNavigationBar:
          isLoading || product == null ? null : _buildBottomBar(),
    );
  }

  Widget _buildProductDetails() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImages(),
          16.height,
          _buildProductInfo(),
          16.height,
          _buildQuantitySelector(),
          16.height,
          _buildProductDescription(),
          16.height,
          _buildProductSpecs(),
          100.height, // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildProductImages() {
    List<String> images = product?.images ?? [];
    if (images.isEmpty) {
      images = ['http://127.0.0.1:8000/images/default.png'];
    }

    return Column(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: radius(),
            backgroundColor: context.cardColor,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(defaultRadius),
            child: Image.network(
              images[selectedImageIndex],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: context.cardColor,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: context.iconColor,
                  ),
                );
              },
            ),
          ),
        ),
        if (images.length > 1) ...[
          16.height,
          Container(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.only(right: 8),
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: radius(8),
                      backgroundColor: context.cardColor,
                      border: Border.all(
                        color: selectedImageIndex == index
                            ? primaryColor
                            : context.dividerColor,
                        width: selectedImageIndex == index ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image, color: context.iconColor);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product?.name ?? '',
          style: boldTextStyle(size: 20),
        ),
        8.height,
        if (product?.categoryName != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              borderRadius: radius(12),
            ),
            child: Text(
              product!.categoryName!,
              style: boldTextStyle(color: primaryColor, size: 12),
            ),
          ),
        12.height,
        Row(
          children: [
            if (product?.salePrice != null && product!.salePrice! > 0) ...[
              Text(
                '\$${product!.salePrice!.toStringAsFixed(2)}',
                style: boldTextStyle(color: primaryColor, size: 24),
              ),
              8.width,
              Text(
                '\$${product!.price!.toStringAsFixed(2)}',
                style: secondaryTextStyle(
                  decoration: TextDecoration.lineThrough,
                  size: 16,
                ),
              ),
            ] else ...[
              Text(
                '\$${product!.price!.toStringAsFixed(2)}',
                style: boldTextStyle(color: primaryColor, size: 24),
              ),
            ],
            Spacer(),
            if (product?.totalRating != null && product!.totalRating! > 0)
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  4.width,
                  Text(
                    '${product!.totalRating!.toStringAsFixed(1)}',
                    style: boldTextStyle(size: 14),
                  ),
                  if (product?.totalReview != null)
                    Text(
                      ' (${product!.totalReview})',
                      style: secondaryTextStyle(size: 12),
                    ),
                ],
              ),
          ],
        ),
        if (product?.shortDescription != null) ...[
          12.height,
          Text(
            product!.shortDescription!,
            style: secondaryTextStyle(size: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Row(
        children: [
          Text(
            'Quantity',
            style: boldTextStyle(size: 16),
          ),
          Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: quantity > 1
                    ? () {
                        setState(() {
                          quantity--;
                        });
                      }
                    : null,
                icon: Icon(Icons.remove_circle_outline),
                color: primaryColor,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.scaffoldBackgroundColor,
                  borderRadius: radius(8),
                ),
                child: Text(
                  quantity.toString(),
                  style: boldTextStyle(size: 16),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                },
                icon: Icon(Icons.add_circle_outline),
                color: primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductDescription() {
    if (product?.description == null) return Offstage();

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
            'Description',
            style: boldTextStyle(size: 16),
          ),
          12.height,
          Text(
            product!.description!,
            style: primaryTextStyle(size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSpecs() {
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
            'Product Information',
            style: boldTextStyle(size: 16),
          ),
          12.height,
          if (product?.sku != null) _buildSpecRow('SKU', product!.sku!),
          if (product?.stockQuantity != null)
            _buildSpecRow('Stock', '${product!.stockQuantity} available'),
          if (product?.categoryName != null)
            _buildSpecRow('Category', product!.categoryName!),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: secondaryTextStyle(size: 14),
            ),
          ),
          Text(': ', style: secondaryTextStyle()),
          Expanded(
            child: Text(
              value,
              style: primaryTextStyle(size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    double totalPrice =
        ((product?.salePrice ?? product?.price ?? 0).toDouble()) * quantity;

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: secondaryTextStyle(size: 12),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: boldTextStyle(color: primaryColor, size: 20),
                ),
              ],
            ),
          ),
          16.width,
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (appStore.isLoggedIn) {
                  OrderCheckoutScreen(
                    product: product!,
                    quantity: quantity,
                  ).launch(context);
                } else {
                  // Show login screen
                  SignInScreen(
                    returnExpected: true,
                  ).launch(context).then((value) {
                    if (value == true && appStore.isLoggedIn) {
                      // User logged in successfully, proceed to checkout
                      OrderCheckoutScreen(
                        product: product!,
                        quantity: quantity,
                      ).launch(context);
                    }
                  });
                }
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
                'Order Now',
                style: boldTextStyle(color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
