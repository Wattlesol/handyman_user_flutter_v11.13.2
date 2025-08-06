import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/model/store_data_model.dart';

import 'pagination_model.dart';

class ProductResponse {
  List<ProductData>? productList;
  Pagination? pagination;
  num? max;
  num? min;

  ProductResponse({this.productList, this.pagination, this.max, this.min});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Handle Laravel pagination format where data is nested in data.data
      List<ProductData>? products;
      if (json['data'] != null) {
        if (json['data'] is List) {
          // Direct array format
          products = [];
          for (var item in json['data']) {
            try {
              if (item is Map<String, dynamic>) {
                products.add(ProductData.fromJson(item));
              }
            } catch (e) {
              print('Error parsing product item: $e');
              // Skip this item and continue
            }
          }
        } else if (json['data'] is Map &&
            json['data']['data'] != null &&
            json['data']['data'] is List) {
          // Laravel pagination format
          products = [];
          for (var item in json['data']['data']) {
            try {
              if (item is Map<String, dynamic>) {
                products.add(ProductData.fromJson(item));
              }
            } catch (e) {
              print('Error parsing product item: $e');
              // Skip this item and continue
            }
          }
        }
      }

      return ProductResponse(
        productList: products,
        max: json['max'] != null
            ? num.tryParse(json['max'].toString()) ?? 0.0
            : 0.0,
        min: json['min'] != null
            ? num.tryParse(json['min'].toString()) ?? 0.0
            : 0.0,
        pagination: json['data'] != null &&
                json['data'] is Map &&
                json['data']['current_page'] != null
            ? Pagination.fromJson(json['data'])
            : json['pagination'] != null && json['pagination'] is Map
                ? Pagination.fromJson(json['pagination'])
                : null,
      );
    } catch (e) {
      print('Error parsing ProductResponse: $e');
      // Return empty response on error
      return ProductResponse(productList: [], pagination: null);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['max'] = this.max;
    data['min'] = this.min;
    if (this.productList != null) {
      data['data'] = this.productList!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class StoreResponse {
  StoreData? store;
  List<ProductData>? featuredProducts;
  List<ProductCategory>? categories;

  StoreResponse({this.store, this.featuredProducts, this.categories});

  factory StoreResponse.fromJson(Map<String, dynamic> json) {
    return StoreResponse(
      store: json['store'] != null
          ? StoreData.fromJson(json['store'])
          : json['data'] != null
              ? StoreData.fromJson(json['data'])
              : null,
      featuredProducts: json['featured_products'] != null
          ? (json['featured_products'] as List)
              .map((i) => ProductData.fromJson(i))
              .toList()
          : null,
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((i) => ProductCategory.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.store != null) {
      data['store'] = this.store!.toJson();
    }
    if (this.featuredProducts != null) {
      data['featured_products'] =
          this.featuredProducts!.map((v) => v.toJson()).toList();
    }
    if (this.categories != null) {
      data['categories'] = this.categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductCategoryResponse {
  List<ProductCategory>? categories;
  Pagination? pagination;

  ProductCategoryResponse({this.categories, this.pagination});

  factory ProductCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ProductCategoryResponse(
      categories: json['data'] != null
          ? (json['data'] as List)
              .map((i) => ProductCategory.fromJson(i))
              .toList()
          : null,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categories != null) {
      data['data'] = this.categories!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}
