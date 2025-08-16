import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/screens/store/component/product_component.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../products_screen.dart';

class FeaturedProductListComponent extends StatelessWidget {
  final List<ProductData> productList;

  FeaturedProductListComponent({required this.productList});

  @override
  Widget build(BuildContext context) {
    // Hide the entire section if there are no featured products
    if (productList.isEmpty) return Offstage();

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
          HorizontalList(
            itemCount: productList.length,
            spacing: 16,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemBuilder: (context, index) => ProductComponent(
                productData: productList[index],
                width: 280,
                isBorderEnabled: true),
          ),
        ],
      ),
    );
  }
}
