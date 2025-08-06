import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/screens/store/component/product_component.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../products_screen.dart';

class FeaturedProductListComponent extends StatelessWidget {
  final List<ProductData> productList;

  FeaturedProductListComponent({required this.productList});

  @override
  Widget build(BuildContext context) {
    // Always show the section, even if empty

    return Container(
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          ViewAllLabel(
            label: language.featuredProducts,
            list: productList,
            onTap: () {
              ProductsScreen(isFeatured: true).launch(context);
            },
          ).paddingSymmetric(horizontal: 16),
          if (productList.isNotEmpty)
            HorizontalList(
              itemCount: productList.length,
              spacing: 16,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemBuilder: (context, index) => ProductComponent(
                  productData: productList[index],
                  width: 280,
                  isBorderEnabled: true),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: NoDataWidget(
                title: language.noProductsFound,
                imageWidget: EmptyStateWidget(),
              ),
            ).center(),
        ],
      ),
    );
  }
}
