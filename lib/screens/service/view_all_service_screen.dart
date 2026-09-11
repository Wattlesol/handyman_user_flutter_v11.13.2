import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/screens/service/shimmer/view_all_service_shimmer.dart';
import 'package:booking_system_flutter/store/filter_store.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/cached_image_widget.dart';
import '../../component/empty_error_state_widget.dart';
import '../../main.dart';
import '../../model/category_model.dart';
import '../../model/service_data_model.dart';
import '../../network/rest_apis.dart';
import '../../utils/common.dart';
import '../../utils/constant.dart';
import '../../utils/images.dart';
import '../filter/filter_screen.dart';
import 'component/service_component.dart';

class ViewAllServiceScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;
  final int? subCategoryId;
  final String? subCategoryName;
  final String isFeatured;
  final bool isFromProvider;
  final bool isFromCategory;
  final int? providerId;
  final List<ServiceData>? serviceList;

  ViewAllServiceScreen({
    this.categoryId,
    this.categoryName = '',
    this.subCategoryId,
    this.subCategoryName = '',
    this.isFeatured = '',
    this.isFromProvider = true,
    this.isFromCategory = false,
    this.providerId,
    this.serviceList,
    Key? key,
  }) : super(key: key);

  @override
  State<ViewAllServiceScreen> createState() => _ViewAllServiceScreenState();
}

class _ViewAllServiceScreenState extends State<ViewAllServiceScreen> {
  Future<List<CategoryData>>? futureCategory;
  List<CategoryData> categoryList = [];

  Future<List<ServiceData>>? futureService;
  List<ServiceData> serviceList = [];

  FocusNode myFocusNode = FocusNode();
  TextEditingController searchCont = TextEditingController();

  int? subCategory;

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    filterStore = FilterStore();
    if (widget.serviceList != null && widget.serviceList!.isNotEmpty) {
      serviceList = List.from(widget.serviceList!);
    }
    if (widget.subCategoryId != null) {
      subCategory = widget.subCategoryId;
    }
    init();
  }

  void init() async {
    fetchAllServiceData();

    if (widget.categoryId != null) {
      fetchCategoryList();
    }
  }

  void fetchCategoryList() async {
    futureCategory = getSubCategoryListAPI(
      catId: widget.categoryId!,
    );
  }

  void fetchAllServiceData() async {
    futureService = searchServiceAPI(
      page: page,
      list: serviceList,
      categoryId: widget.categoryId != null ? widget.categoryId.validate().toString() : filterStore.categoryId.join(','),
      subCategory: subCategory != null ? subCategory.validate().toString() : '',
      providerId: widget.providerId != null ? widget.providerId.toString() : filterStore.providerId.join(","),
      isPriceMin: filterStore.isPriceMin,
      isPriceMax: filterStore.isPriceMax,
      ratingId: filterStore.ratingId.join(','),
      search: searchCont.text,
      latitude: "",
      longitude: "",
      lastPageCallBack: (p0) {
        isLastPage = p0;
      },
      isFeatured: widget.isFeatured,
    );
  }

  String get setSearchString {
    if (!widget.subCategoryName.isEmptyOrNull) {
      return widget.subCategoryName!;
    } else if (!widget.categoryName.isEmptyOrNull) {
      return widget.categoryName!;
    } else if (widget.isFeatured == "1") {
      return language.lblFeatured;
    } else {
      return language.allServices;
    }
  }

  Widget subCategoryWidget() {
    return SnapHelperWidget<List<CategoryData>>(
      future: futureCategory,
      initialData: cachedSubcategoryList.firstWhere((element) => element?.$1 == widget.categoryId.validate(), orElse: () => null)?.$2,
      loadingWidget: Offstage(),
      onSuccess: (list) {
        if (list.length <= 1) return Offstage();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            12.height,
            Text(language.lblSubcategories, style: boldTextStyle(size: 14)).paddingLeft(16),
            8.height,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: list.map((data) {
                  bool isSelected = (subCategory == null || subCategory == -1)
                      ? data.id == -1
                      : subCategory == data.id;

                  return GestureDetector(
                    onTap: () {
                      subCategory = data.id == -1 ? null : data.id;
                      page = 1;
                      appStore.setLoading(true);
                      fetchAllServiceData();
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? context.primaryColor : context.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? context.primaryColor : context.dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(Icons.check, size: 14, color: Colors.white),
                            6.width,
                          ],
                          Text(
                            data.id == -1 ? language.lblAll : data.name.validate(),
                            style: boldTextStyle(
                              size: 13,
                              color: isSelected ? Colors.white : (appStore.isDarkMode ? Colors.white : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            12.height,
          ],
        );
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    filterStore.clearFilters();
    myFocusNode.dispose();
    filterStore.setSelectedSubCategory(catId: 0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: AppScaffold(
        appBarTitle: setSearchString,
        child: SizedBox(
          height: context.height(),
          width: context.width(),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    AppTextField(
                      textFieldType: TextFieldType.OTHER,
                      focus: myFocusNode,
                      controller: searchCont,
                      suffix: CloseButton(
                        onPressed: () {
                          page = 1;
                          searchCont.clear();
                          filterStore.setSearch('');
                          appStore.setLoading(true);
                          fetchAllServiceData();
                          setState(() {});
                        },
                      ).visible(searchCont.text.isNotEmpty),
                      onFieldSubmitted: (s) {
                        page = 1;

                        filterStore.setSearch(s);
                        appStore.setLoading(true);

                        fetchAllServiceData();
                        setState(() {});
                      },
                      decoration: inputDecoration(context).copyWith(
                        hintText: "${language.lblSearchFor} $setSearchString",
                        prefixIcon: ic_search.iconImage(size: 10).paddingAll(14),
                        hintStyle: secondaryTextStyle(),
                      ),
                    ).expand(),
                    16.width,
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: boxDecorationDefault(color: context.primaryColor),
                      child: CachedImageWidget(
                        url: ic_filter,
                        height: 26,
                        width: 26,
                        color: Colors.white,
                      ),
                    ).onTap(() {
                      hideKeyboard(context);

                      FilterScreen(isFromProvider: widget.isFromProvider, isFromCategory: widget.isFromCategory).launch(context).then((value) {
                        if (value != null) {
                          page = 1;
                          appStore.setLoading(true);

                          fetchAllServiceData();
                          setState(() {});
                        }
                      });
                    }, borderRadius: radius())
                  ],
                ),
              ),
              AnimatedScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                onSwipeRefresh: () {
                  page = 1;

                  appStore.setLoading(true);
                  fetchAllServiceData();
                  setState(() {});

                  return Future.value(false);
                },
                onNextPage: () {
                  if (!isLastPage) {
                    page++;

                    appStore.setLoading(true);
                    fetchAllServiceData();
                    setState(() {});
                  }
                },
                children: [
                  if (widget.categoryId != null) subCategoryWidget(),
                  16.height,
                  SnapHelperWidget<List<ServiceData>>(
                    future: futureService,
                    initialData: serviceList.isNotEmpty ? serviceList : null,
                    loadingWidget: ViewAllServiceShimmer(),
                    errorBuilder: (p0) {
                      return NoDataWidget(
                        title: p0,
                        retryText: language.reload,
                        imageWidget: ErrorStateWidget(),
                        onRetry: () {
                          page = 1;
                          appStore.setLoading(true);

                          fetchAllServiceData();
                          setState(() {});
                        },
                      );
                    },
                    onSuccess: (data) {
                      final displayList = (data.isNotEmpty) ? data : serviceList;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.service, style: boldTextStyle(size: LABEL_TEXT_SIZE)).paddingSymmetric(horizontal: 16),
                          AnimatedListView(
                            itemCount: displayList.length,
                            listAnimationType: ListAnimationType.FadeIn,
                            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            emptyWidget: NoDataWidget(
                              title: language.lblNoServicesFound,
                              subTitle: (searchCont.text.isNotEmpty || filterStore.providerId.isNotEmpty || filterStore.categoryId.isNotEmpty) ? language.noDataFoundInFilter : null,
                              imageWidget: EmptyStateWidget(),
                            ),
                            itemBuilder: (_, index) {
                              return ServiceComponent(
                                serviceData: displayList[index],
                                isFromViewAllService: true,
                              ).paddingAll(8);
                            },
                          ).paddingAll(8),
                        ],
                      );
                    },
                  ),
                ],
              ).expand(),
            ],
          ),
        ),
      ),
    );
  }
}
