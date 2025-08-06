import 'dart:convert';

import 'package:nb_utils/nb_utils.dart';

import 'multi_language_request_model.dart';

class ProductData {
  int? id;
  int? categoryId;
  int? storeId;
  int? status;
  int? isFeatured;
  int? stockQuantity;
  num? price;
  num? salePrice;
  num? discount;
  num? totalReview;
  num? totalRating;
  num? isFavourite;
  String? name;
  String? description;
  String? shortDescription;
  String? sku;
  String? categoryName;
  String? storeName;
  String? type;
  String? createdAt;
  String? updatedAt;
  List<String>? images;
  List<ProductImage>? imageArray;
  List<ProductVariant>? variants;
  List<ProductAttribute>? attributes;
  Map<String, MultiLanguageRequest>? translations;

  //Local
  bool isSelected = false;

  bool get isFeaturedProduct => isFeatured.validate() == 1;

  bool get isInStock => stockQuantity.validate() > 0;

  bool get isOnSale =>
      salePrice.validate() > 0 && salePrice.validate() < price.validate();

  num get finalPrice => isOnSale ? salePrice.validate() : price.validate();

  num get discountPercentage => isOnSale
      ? ((price.validate() - salePrice.validate()) / price.validate() * 100)
      : 0;

  ProductData({
    this.id,
    this.name,
    this.description,
    this.shortDescription,
    this.sku,
    this.categoryId,
    this.categoryName,
    this.storeId,
    this.storeName,
    this.price,
    this.salePrice,
    this.discount,
    this.stockQuantity,
    this.status,
    this.isFeatured,
    this.totalRating,
    this.totalReview,
    this.isFavourite,
    this.type,
    this.images,
    this.imageArray,
    this.variants,
    this.attributes,
    this.createdAt,
    this.updatedAt,
    this.translations,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      shortDescription: json['short_description'],
      sku: json['sku'],
      categoryId: json['category_id'] ??
          json['product_category_id'] ??
          json['category']?['id'],
      categoryName: json['category_name'] ?? json['category']?['name'],
      storeId: json['store_id'],
      storeName: json['store_name'],
      price: json['price'] != null
          ? num.tryParse(json['price'].toString())
          : json['base_price'] != null
              ? num.tryParse(json['base_price'].toString())
              : json['final_price'] != null
                  ? num.tryParse(json['final_price'].toString())
                  : null,
      salePrice: json['sale_price'] != null
          ? num.tryParse(json['sale_price'].toString())
          : json['selling_price'] != null
              ? num.tryParse(json['selling_price'].toString())
              : json['effective_price'] != null
                  ? num.tryParse(json['effective_price'].toString())
                  : null,
      discount: json['discount'] != null ? json['discount'] : 0,
      stockQuantity: json['stock_quantity'],
      status: json['status'] is bool
          ? (json['status'] == true ? 1 : 0)
          : json['status'],
      isFeatured: json['is_featured'] is bool
          ? (json['is_featured'] == true ? 1 : 0)
          : json['is_featured'],
      totalRating: json['total_rating'],
      totalReview: json['total_review'],
      isFavourite: json['is_favourite'],
      type: json['type'],
      images: ProductData._parseImages(json),
      imageArray: json['image_array'] != null
          ? (json['image_array'] as List)
              .map((i) => ProductImage.fromJson(i))
              .toList()
          : null,
      variants: json['variants'] != null
          ? (json['variants'] as List)
              .map((i) => ProductVariant.fromJson(i))
              .toList()
          : null,
      attributes: json['attributes'] != null
          ? (json['attributes'] as List)
              .map((i) => ProductAttribute.fromJson(i))
              .toList()
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      translations: json['translations'] != null
          ? (jsonDecode(json['translations']) as Map<String, dynamic>).map(
              (key, value) {
                if (value is Map<String, dynamic>) {
                  return MapEntry(key, MultiLanguageRequest.fromJson(value));
                } else {
                  print('Unexpected translation value for key $key: $value');
                  return MapEntry(key, MultiLanguageRequest());
                }
              },
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['short_description'] = this.shortDescription;
    data['sku'] = this.sku;
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    data['store_id'] = this.storeId;
    data['store_name'] = this.storeName;
    data['price'] = this.price;
    data['sale_price'] = this.salePrice;
    data['discount'] = this.discount;
    data['stock_quantity'] = this.stockQuantity;
    data['status'] = this.status;
    data['is_featured'] = this.isFeatured;
    data['total_rating'] = this.totalRating;
    data['total_review'] = this.totalReview;
    data['is_favourite'] = this.isFavourite;
    data['type'] = this.type;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.images != null) {
      data['images'] = this.images;
    }
    if (this.imageArray != null) {
      data['image_array'] = this.imageArray!.map((v) => v.toJson()).toList();
    }
    if (this.variants != null) {
      data['variants'] = this.variants!.map((v) => v.toJson()).toList();
    }
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.map((v) => v.toJson()).toList();
    }
    if (this.translations != null) {
      data['translations'] = jsonEncode(this
          .translations!
          .map((key, value) => MapEntry(key, value.toJson())));
    }
    return data;
  }

  static List<String>? _parseImages(Map<String, dynamic> json) {
    try {
      // Handle different image field formats from API
      if (json['images'] != null && json['images'] is List) {
        List<String> imageList = [];
        for (var item in json['images']) {
          if (item != null) {
            imageList.add(item.toString());
          }
        }
        return imageList.isNotEmpty ? imageList : null;
      } else if (json['media'] != null && json['media'] is List) {
        // Handle Laravel media library format
        List<String> mediaUrls = [];
        for (var media in json['media']) {
          if (media is Map<String, dynamic>) {
            if (media['original_url'] != null) {
              mediaUrls.add(media['original_url'].toString());
            } else if (media['url'] != null) {
              mediaUrls.add(media['url'].toString());
            }
          }
        }
        return mediaUrls.isNotEmpty ? mediaUrls : null;
      } else if (json['gallery'] != null && json['gallery'] is List) {
        List<String> galleryList = [];
        for (var item in json['gallery']) {
          if (item != null) {
            galleryList.add(item.toString());
          }
        }
        return galleryList.isNotEmpty ? galleryList : null;
      } else if (json['main_image'] != null) {
        return [json['main_image'].toString()];
      } else if (json['image_url'] != null) {
        return [json['image_url'].toString()];
      } else if (json['image'] != null) {
        return [json['image'].toString()];
      }
    } catch (e) {
      print('Error parsing images: $e');
    }

    // Return default image if no images found or error occurred
    return ['http://127.0.0.1:8000/images/default.png'];
  }
}

class ProductImage {
  int? id;
  String? url;
  String? alt;
  int? sortOrder;

  ProductImage({this.id, this.url, this.alt, this.sortOrder});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      url: json['url'],
      alt: json['alt'],
      sortOrder: json['sort_order'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    data['alt'] = this.alt;
    data['sort_order'] = this.sortOrder;
    return data;
  }
}

class ProductVariant {
  int? id;
  String? name;
  num? price;
  int? stockQuantity;
  String? sku;
  Map<String, String>? attributes;

  ProductVariant(
      {this.id,
      this.name,
      this.price,
      this.stockQuantity,
      this.sku,
      this.attributes});

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      stockQuantity: json['stock_quantity'],
      sku: json['sku'],
      attributes: json['attributes'] != null
          ? Map<String, String>.from(json['attributes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['stock_quantity'] = this.stockQuantity;
    data['sku'] = this.sku;
    data['attributes'] = this.attributes;
    return data;
  }
}

class ProductAttribute {
  int? id;
  String? name;
  String? value;
  String? type;

  ProductAttribute({this.id, this.name, this.value, this.type});

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'],
      name: json['name'],
      value: json['value'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['value'] = this.value;
    data['type'] = this.type;
    return data;
  }
}

class ProductCategory {
  int? id;
  String? name;
  String? description;
  String? image;
  int? parentId;
  int? sortOrder;
  int? status;

  ProductCategory(
      {this.id,
      this.name,
      this.description,
      this.image,
      this.parentId,
      this.sortOrder,
      this.status});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      parentId: json['parent_id'],
      sortOrder: json['sort_order'] ?? 0,
      status: json['status'] is bool
          ? (json['status'] == true ? 1 : 0)
          : json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['parent_id'] = this.parentId;
    data['sort_order'] = this.sortOrder;
    data['status'] = this.status;
    return data;
  }
}
