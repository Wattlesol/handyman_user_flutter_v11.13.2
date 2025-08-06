import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/disabled_rating_bar_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/screens/store/product_detail_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ProductComponent extends StatefulWidget {
  final ProductData productData;
  final double? width;
  final bool? isBorderEnabled;
  final VoidCallback? onUpdate;
  final bool isFavouriteProduct;
  final bool isFromDashboard;
  final bool isFromViewAllProduct;

  ProductComponent({
    required this.productData,
    this.width,
    this.isBorderEnabled,
    this.isFavouriteProduct = false,
    this.onUpdate,
    this.isFromDashboard = false,
    this.isFromViewAllProduct = false,
  });

  @override
  ProductComponentState createState() => ProductComponentState();
}

class ProductComponentState extends State<ProductComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildProductComponent() {
      return Container(
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(),
          backgroundColor: context.cardColor,
          border: widget.isBorderEnabled.validate(value: false)
              ? appStore.isDarkMode
                  ? Border.all(color: context.dividerColor)
                  : null
              : null,
        ),
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 205,
              width: context.width(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CachedImageWidget(
                    url: widget.productData.images.validate().isNotEmpty
                        ? widget.productData.images!.first.validate()
                        : '',
                    fit: BoxFit.cover,
                    height: 180,
                    width: widget.width ?? context.width(),
                    circle: false,
                  ).cornerRadiusWithClipRRectOnly(
                      topRight: defaultRadius.toInt(),
                      topLeft: defaultRadius.toInt()),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      constraints:
                          BoxConstraints(maxWidth: context.width() * 0.3),
                      decoration: boxDecorationWithShadow(
                        backgroundColor:
                            context.cardColor.withValues(alpha: 0.9),
                        borderRadius: radius(24),
                      ),
                      child: Text(
                        "${widget.productData.categoryName.validate()}"
                            .toUpperCase(),
                        style: boldTextStyle(
                            color: appStore.isDarkMode ? white : primaryColor,
                            size: 12),
                        overflow: TextOverflow.ellipsis,
                      ).paddingSymmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                  if (widget.productData.isOnSale)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: boxDecorationWithShadow(
                          backgroundColor: Colors.red,
                          borderRadius: radius(24),
                        ),
                        child: Text(
                          language.onSale,
                          style: boldTextStyle(color: Colors.white, size: 10),
                        ),
                      ),
                    ),
                  if (widget.isFavouriteProduct)
                    Positioned(
                      top: 8,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(right: 8),
                        decoration: boxDecorationWithShadow(
                            boxShape: BoxShape.circle,
                            backgroundColor: context.cardColor),
                        child: widget.productData.isFavourite == 1
                            ? ic_fill_heart.iconImage(
                                color: favouriteColor, size: 18)
                            : ic_heart.iconImage(
                                color: unFavouriteColor, size: 18),
                      ).onTap(() async {
                        // TODO: Implement add/remove from wishlist for products
                        widget.onUpdate?.call();
                      }),
                    ),
                  Positioned(
                    bottom: 12,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: boxDecorationWithShadow(
                        backgroundColor: primaryColor,
                        borderRadius: radius(24),
                        border: Border.all(color: context.cardColor, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.productData.isOnSale) ...[
                            Text(
                              '${appConfigurationStore.currencySymbol}${widget.productData.price.validate().toStringAsFixed(2)}',
                              style: boldTextStyle(
                                  color: Colors.white,
                                  size: 10,
                                  decoration: TextDecoration.lineThrough),
                            ),
                            4.width,
                          ],
                          Text(
                            '${appConfigurationStore.currencySymbol}${widget.productData.finalPrice.toStringAsFixed(2)}',
                            style: boldTextStyle(color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!widget.productData.isInStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(defaultRadius),
                            topRight: Radius.circular(defaultRadius),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: boxDecorationWithShadow(
                              backgroundColor: Colors.red,
                              borderRadius: radius(24),
                            ),
                            child: Text(
                              language.outOfStock,
                              style:
                                  boldTextStyle(color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DisabledRatingBarWidget(
                        rating: widget.productData.totalRating.validate(),
                        size: 14)
                    .paddingSymmetric(horizontal: 16),
                8.height,
                Text(
                  widget.productData.name.validate(),
                  style: boldTextStyle(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).paddingSymmetric(horizontal: 16),
                8.height,
                if (widget.productData.storeName.validate().isNotEmpty)
                  Row(
                    children: [
                      ic_store.iconImage(
                          size: 16, color: appTextSecondaryColor),
                      8.width,
                      Text(
                        widget.productData.storeName.validate(),
                        style: secondaryTextStyle(
                            size: 12,
                            color: appStore.isDarkMode
                                ? Colors.white
                                : appTextSecondaryColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).expand()
                    ],
                  ).paddingSymmetric(horizontal: 16),
                16.height,
              ],
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
        ProductDetailScreen(
          productId: widget.productData.id.validate(),
          product: widget.productData,
        ).launch(context).then((value) {
          setStatusBarColor(context.primaryColor);
          widget.onUpdate?.call();
        });
      },
      child: buildProductComponent(),
    );
  }
}
