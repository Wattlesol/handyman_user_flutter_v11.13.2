import 'package:booking_system_flutter/app_theme.dart';
import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/model/product_response_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/store/component/product_component.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';

class ProductsScreen extends StatefulWidget {
  final bool isFeatured;
  final int? categoryId;
  final String? categoryName;
  final String? searchQuery;
  final bool isMainStoreTab;
  final List<ProductCategory>? preloadedCategories;

  ProductsScreen({
    this.isFeatured = false,
    this.categoryId,
    this.categoryName,
    this.searchQuery,
    this.isMainStoreTab = false,
    this.preloadedCategories,
  });

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<ProductData> productList = [];
  List<ProductCategory> categoryList = [];

  int page = 1;
  bool isLastPage = false;
  bool isApiCalled = false;
  bool isLoading = true;

  int? selectedCategoryId;
  String selectedSortBy = 'name';
  String selectedSortOrder = 'asc';

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    selectedCategoryId = widget.categoryId;
    if (widget.searchQuery != null) {
      searchController.text = widget.searchQuery!;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Use preloaded categories if available, otherwise load them
      if (widget.preloadedCategories != null) {
        categoryList = widget.preloadedCategories!;
        print('Using preloaded categories: ${categoryList.length} categories');

        // Only load products
        final productsResponse = await (widget.isFeatured
            ? getFeaturedProducts(perPage: PER_PAGE_ITEM)
            : searchController.text.isNotEmpty
                ? searchProducts(
                    query: searchController.text,
                    categoryId: selectedCategoryId,
                    page: page,
                    perPage: PER_PAGE_ITEM,
                  )
                : getProducts(
                    categoryId: selectedCategoryId,
                    page: page,
                    perPage: PER_PAGE_ITEM,
                    sortBy: selectedSortBy,
                    sortOrder: selectedSortOrder,
                  ));

        productList = productsResponse.productList ?? [];
        print('Products loaded: ${productList.length} products');
      } else {
        // Load both categories and products simultaneously
        final results = await Future.wait([
          getProductCategories(),
          widget.isFeatured
              ? getFeaturedProducts(perPage: PER_PAGE_ITEM)
              : searchController.text.isNotEmpty
                  ? searchProducts(
                      query: searchController.text,
                      categoryId: selectedCategoryId,
                      page: page,
                      perPage: PER_PAGE_ITEM,
                    )
                  : getProducts(
                      categoryId: selectedCategoryId,
                      page: page,
                      perPage: PER_PAGE_ITEM,
                      sortBy: selectedSortBy,
                      sortOrder: selectedSortOrder,
                    ),
        ]);

        final categoriesResponse = results[0] as ProductCategoryResponse;
        final productsResponse = results[1] as ProductResponse;

        categoryList = categoriesResponse.categories ?? [];
        productList = productsResponse.productList ?? [];

        print(
            'Data loaded: ${categoryList.length} categories, ${productList.length} products');
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> loadProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      page = 1;
      productList.clear();
    }

    setState(() {
      isLoading = true;
    });

    try {
      print(
          'Loading products: page=$page, categoryId=$selectedCategoryId, search=${searchController.text}');
      ProductResponse response;

      if (widget.isFeatured) {
        print('Loading featured products...');
        response = await getFeaturedProducts(perPage: PER_PAGE_ITEM);
      } else if (searchController.text.isNotEmpty) {
        print('Searching products...');
        response = await searchProducts(
          query: searchController.text,
          categoryId: selectedCategoryId,
          page: page,
          perPage: PER_PAGE_ITEM,
        );
      } else {
        print('Loading all products...');
        response = await getProducts(
          categoryId: selectedCategoryId,
          page: page,
          perPage: PER_PAGE_ITEM,
          sortBy: selectedSortBy,
          sortOrder: selectedSortOrder,
        );
      }

      if (page == 1) productList.clear();
      productList.addAll(response.productList ?? []);
      print(
          'Products loaded: ${response.productList?.length ?? 0} new products, total: ${productList.length}');

      isLastPage = (response.productList?.length ?? 0) < PER_PAGE_ITEM;
      page++;

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      toast(e.toString());
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.isMainStoreTab
            ? language.store
            : widget.isFeatured
                ? language.featuredProducts
                : language.products,
        textColor: Colors.white,
        textSize: APP_BAR_TEXT_SIZE,
        color: context.brandColors.brandBlue,
        systemUiOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness:
                appStore.isDarkMode ? Brightness.light : Brightness.light,
            statusBarColor: context.primaryColor),
        showBack: Navigator.canPop(context),
        backWidget: BackWidget(),
        actions: [
          IconButton(
            icon: ic_filter.iconImage(color: Colors.white),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(),
              _buildSortOptions(),
              Expanded(
                child: isLoading && productList.isEmpty
                    ? LoaderWidget()
                    : productList.isEmpty
                        ? NoDataWidget(
                            title: language.noProductsFound,
                            imageWidget: EmptyStateWidget(),
                          )
                        : AnimatedListView(
                            itemCount: productList.length,
                            padding: EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              return ProductComponent(
                                productData: productList[index],
                                width: context.width() / 2 - 24,
                                isBorderEnabled: true,
                                onUpdate: () => loadProducts(isRefresh: true),
                              ).paddingBottom(16);
                            },
                            onNextPage: () {
                              if (!isLastPage) {
                                loadProducts();
                              }
                            },
                            onSwipeRefresh: () async {
                              await loadProducts(isRefresh: true);
                            },
                          ),
              ),
            ],
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: language.searchProducts,
          prefixIcon: Icon(Icons.search, color: primaryColor),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    loadProducts(isRefresh: true);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (value) {
          loadProducts(isRefresh: true);
        },
      ),
    );
  }

  Widget _buildCategoryChip(int? categoryId, String name) {
    bool isSelected = selectedCategoryId == categoryId;

    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_circle, size: 16, color: primaryColor),
              4.width,
            ],
            Text(name),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          selectedCategoryId = selected ? categoryId : null;
          loadProducts(isRefresh: true);
        },
        backgroundColor: context.cardColor,
        selectedColor: primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? primaryColor : context.dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(language.sortBy, style: boldTextStyle(size: 14)),
          8.width,
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip(language.newest, 'created_at', 'desc'),
                  _buildSortChip(language.oldest, 'created_at', 'asc'),
                  _buildSortChip(language.priceLowToHigh, 'price', 'asc'),
                  _buildSortChip(language.priceHighToLow, 'price', 'desc'),
                  _buildSortChip(language.popularity, 'total_rating', 'desc'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String sortBy, String sortOrder) {
    bool isSelected =
        selectedSortBy == sortBy && selectedSortOrder == sortOrder;

    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            selectedSortBy = sortBy;
            selectedSortOrder = sortOrder;
            loadProducts(isRefresh: true);
          }
        },
        backgroundColor: context.cardColor,
        selectedColor: primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language.filterByCategory, style: boldTextStyle()),
              16.height,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCategoryChip(null, language.allCategories),
                  ...categoryList.map((category) =>
                      _buildCategoryChip(category.id, category.name ?? '')),
                ],
              ),
              24.height,
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        selectedCategoryId = null;
                        Navigator.pop(context);
                        loadProducts(isRefresh: true);
                      },
                      child: Text(language.reset),
                    ),
                  ),
                  16.width,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        loadProducts(isRefresh: true);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      child: Text(language.save,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
