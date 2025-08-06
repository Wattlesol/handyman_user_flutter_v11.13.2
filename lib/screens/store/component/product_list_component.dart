import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/screens/store/component/product_component.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../products_screen.dart';

class ProductListComponent extends StatelessWidget {
  final List<ProductData> productList;

  ProductListComponent({required this.productList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        ViewAllLabel(
          label: language.products,
          list: productList,
          onTap: () {
            ProductsScreen().launch(context);
          },
        ).paddingSymmetric(horizontal: 16),
        8.height,
        productList.isNotEmpty
            ? Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(productList.length, (index) {
                  return ProductComponent(
                    productData: productList[index], 
                    width: context.width() / 2 - 26
                  );
                }),
              ).paddingSymmetric(horizontal: 16, vertical: 8)
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: NoDataWidget(
                  title: language.noProductsFound,
                  imageWidget: EmptyStateWidget(),
                ),
              ).center(),
      ],
    );
  }
}
