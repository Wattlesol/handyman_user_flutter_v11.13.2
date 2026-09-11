import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/service/view_all_service_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';

class SubCategoryScreen extends StatefulWidget {
  final CategoryData categoryData;

  const SubCategoryScreen({Key? key, required this.categoryData}) : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  late Future<List<CategoryData>> future;
  List<CategoryData> subCategoryList = [];

  static const Color brandBlue = Color(0xFF1F6BFF);
  static const Color brandNavy = Color(0xFF0F2933);

  @override
  void initState() {
    super.initState();
    loadSubCategories();
  }

  void loadSubCategories() {
    future = getSubCategoryListAPI(catId: widget.categoryData.id.validate()).then((list) {
      // Filter out the artificial 'All' item if present for the subcategory cards view
      return list.where((item) => item.id != -1).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: widget.categoryData.name.validate(),
      child: SnapHelperWidget<List<CategoryData>>(
        future: future,
        loadingWidget: LoaderWidget().center(),
        errorBuilder: (error) => NoDataWidget(
          title: error,
          imageWidget: const ErrorStateWidget(),
          retryText: language.reload,
          onRetry: () => setState(() => loadSubCategories()),
        ),
        onSuccess: (list) {
          if (list.isEmpty) {
            // If no subcategories, navigate directly to all services
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("No subcategories found for this category.", style: secondaryTextStyle()),
                  16.height,
                  AppButton(
                    text: "View All Services",
                    color: brandBlue,
                    textColor: Colors.white,
                    onTap: () {
                      ViewAllServiceScreen(
                        categoryId: widget.categoryData.id.validate(),
                        categoryName: widget.categoryData.name,
                        isFromCategory: true,
                      ).launch(context);
                    },
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Header Banner
                Container(
                  width: context.width(),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [brandBlue, brandNavy],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.category_outlined, color: Colors.white, size: 24),
                          ),
                          12.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.categoryData.name.validate(),
                                  style: boldTextStyle(size: 18, color: Colors.white),
                                ),
                                2.height,
                                Text(
                                  "${list.length} subcategories available",
                                  style: secondaryTextStyle(size: 12, color: Colors.white.withOpacity(0.85)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (widget.categoryData.description.validate().isNotEmpty) ...[
                        10.height,
                        Text(
                          widget.categoryData.description.validate(),
                          style: secondaryTextStyle(size: 12, color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                      12.height,
                      AppButton(
                        width: context.width(),
                        text: "View All Services in this Category",
                        color: Colors.white,
                        textColor: brandBlue,
                        height: 36,
                        shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        onTap: () {
                          ViewAllServiceScreen(
                            categoryId: widget.categoryData.id.validate(),
                            categoryName: widget.categoryData.name,
                            isFromCategory: true,
                          ).launch(context);
                        },
                      ),
                    ],
                  ),
                ),
                20.height,

                Text("Select Subcategory", style: boldTextStyle(size: 16)),
                12.height,

                // Subcategory Cards List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => 12.height,
                  itemBuilder: (_, index) {
                    CategoryData sub = list[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          ViewAllServiceScreen(
                            categoryId: widget.categoryData.id.validate(),
                            categoryName: widget.categoryData.name,
                            subCategoryId: sub.id,
                            subCategoryName: sub.name,
                            isFromCategory: true,
                          ).launch(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: brandBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.subdirectory_arrow_right, color: brandBlue, size: 22),
                              ),
                              14.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub.name.validate(),
                                      style: boldTextStyle(size: 15),
                                    ),
                                    if (sub.description.validate().isNotEmpty) ...[
                                      3.height,
                                      Text(
                                        sub.description.validate(),
                                        style: secondaryTextStyle(size: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              10.width,
                              if (sub.services != null && sub.services! > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: brandBlue.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "${sub.services} ${sub.services == 1 ? 'Service' : 'Services'}",
                                    style: boldTextStyle(size: 11, color: brandBlue),
                                  ),
                                ),
                              8.width,
                              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
