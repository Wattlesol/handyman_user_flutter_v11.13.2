import 'package:booking_system_flutter/app_theme.dart';
import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/store_data_model.dart';
import 'package:booking_system_flutter/model/product_response_model.dart';
import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/store/products_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late Future<StoreResponse> future;
  StoreData? storeData;
  List<ProductCategory> categoryList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load both store and categories simultaneously
      final results = await Future.wait([
        getStore(),
        getProductCategories(),
      ]);

      final storeResponse = results[0] as StoreResponse;
      final categoriesResponse = results[1] as ProductCategoryResponse;

      storeData = storeResponse.store;
      categoryList = categoriesResponse.categories ?? [];

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading store data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.store,
        textColor: Colors.white,
        textSize: APP_BAR_TEXT_SIZE,
        color: context.brandColors.brandBlue,
        systemUiOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness:
                appStore.isDarkMode ? Brightness.light : Brightness.light,
            statusBarColor: context.primaryColor),
        showBack: Navigator.canPop(context),
        backWidget: BackWidget(),
      ),
      body: isLoading
          ? LoaderWidget()
          : storeData == null
              ? NoDataWidget(
                  title: language.noStoreFound,
                  imageWidget: EmptyStateWidget(),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStoreHeader(),
                      16.height,
                      _buildStoreInfo(),
                      24.height,
                      if (categoryList.isNotEmpty) ...[
                        _buildCategoriesSection(),
                        24.height,
                      ],
                      _buildViewProductsButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStoreHeader() {
    return Container(
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Column(
        children: [
          if (storeData?.banner != null && storeData!.banner!.isNotEmpty)
            CachedImageWidget(
              url: storeData!.banner!,
              height: 200,
              width: context.width(),
              fit: BoxFit.cover,
            ).cornerRadiusWithClipRRectOnly(
              topLeft: defaultRadius.toInt(),
              topRight: defaultRadius.toInt(),
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                if (storeData?.logo != null && storeData!.logo!.isNotEmpty)
                  CachedImageWidget(
                    url: storeData!.logo!,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    circle: true,
                  )
                else
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: ic_store.iconImage(size: 30, color: primaryColor),
                  ),
                16.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeData?.name ?? language.store,
                        style: boldTextStyle(size: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.height,
                      if (storeData?.description != null &&
                          storeData!.description!.isNotEmpty)
                        Text(
                          storeData!.description!,
                          style: secondaryTextStyle(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      8.height,
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: storeData?.isOpen == true
                              ? Colors.green
                              : Colors.red,
                          borderRadius: radius(20),
                        ),
                        child: Text(
                          storeData?.isOpen == true
                              ? language.storeOpen
                              : language.storeClosed,
                          style: boldTextStyle(color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Container(
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.storeDetails,
            style: boldTextStyle(size: 16),
          ),
          16.height,
          if (storeData?.address != null && storeData!.address!.isNotEmpty)
            _buildInfoRow(
                Icons.location_on, language.storeAddress, storeData!.address!),
          if (storeData?.phone != null && storeData!.phone!.isNotEmpty)
            _buildInfoRow(Icons.phone, language.storePhone, storeData!.phone!),
          if (storeData?.email != null && storeData!.email!.isNotEmpty)
            _buildInfoRow(Icons.email, language.storeEmail, storeData!.email!),
          if (storeData?.website != null && storeData!.website!.isNotEmpty)
            _buildInfoRow(
                Icons.language, language.storeWebsite, storeData!.website!),
          if (storeData?.openingHours != null &&
              storeData!.openingHours!.isNotEmpty)
            _buildInfoRow(Icons.access_time, language.openingHours,
                '${storeData!.openingHours!} - ${storeData!.closingHours ?? ''}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: primaryColor),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: secondaryTextStyle(size: 12)),
                4.height,
                Text(value, style: primaryTextStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewProductsButton() {
    return Container(
      width: context.width(),
      child: ElevatedButton(
        onPressed: () {
          ProductsScreen(preloadedCategories: categoryList).launch(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
        ),
        child: Text(
          language.viewProducts,
          style: boldTextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category, color: primaryColor, size: 20),
              8.width,
              Text(
                language.productCategories,
                style: boldTextStyle(size: 16),
              ),
              Spacer(),
              Text(
                '${categoryList.length} ${language.productCategories.toLowerCase()}',
                style: secondaryTextStyle(size: 12),
              ),
            ],
          ),
          16.height,
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categoryList.length,
              itemBuilder: (context, index) {
                ProductCategory category = categoryList[index];
                return Container(
                  width: 120,
                  margin: EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      ProductsScreen(
                        categoryId: category.id,
                        categoryName: category.name,
                        preloadedCategories: categoryList,
                      ).launch(context);
                    },
                    child: Container(
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: radius(),
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3)),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.category,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                          6.height,
                          Flexible(
                            child: Text(
                              category.name ?? '',
                              style:
                                  boldTextStyle(size: 11, color: primaryColor),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
