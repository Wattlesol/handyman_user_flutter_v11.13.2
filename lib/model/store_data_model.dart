import 'dart:convert';

import 'package:flutter/material.dart';

import 'multi_language_request_model.dart';

class StoreData {
  int? id;
  String? name;
  String? description;
  String? email;
  String? phone;
  String? address;
  String? city;
  String? state;
  String? country;
  String? zipCode;
  String? logo;
  String? banner;
  String? website;
  int? status;
  String? openingHours;
  String? closingHours;
  List<String>? workingDays;
  num? totalRating;
  num? totalReview;
  String? createdAt;
  String? updatedAt;
  Map<String, MultiLanguageRequest>? translations;

  // Local
  bool get isOpen {
    if (workingDays == null || openingHours == null || closingHours == null)
      return false;

    final now = DateTime.now();
    final currentDay = _getDayName(now.weekday);

    if (!workingDays!.contains(currentDay)) return false;

    final currentTime = TimeOfDay.fromDateTime(now);
    final openTime = _parseTime(openingHours!);
    final closeTime = _parseTime(closingHours!);

    if (openTime == null || closeTime == null) return false;

    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final openMinutes = openTime.hour * 60 + openTime.minute;
    final closeMinutes = closeTime.hour * 60 + closeTime.minute;

    return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  TimeOfDay? _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  StoreData({
    this.id,
    this.name,
    this.description,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.logo,
    this.banner,
    this.website,
    this.status,
    this.openingHours,
    this.closingHours,
    this.workingDays,
    this.totalRating,
    this.totalReview,
    this.createdAt,
    this.updatedAt,
    this.translations,
  });

  factory StoreData.fromJson(Map<String, dynamic> json) {
    return StoreData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zip_code'],
      logo: json['logo'],
      banner: json['banner'],
      website: json['website'],
      status: json['status'] is bool
          ? (json['status'] == true ? 1 : 0)
          : json['status'] is String
              ? (json['status'] == 'approved' ? 1 : 0)
              : json['status'],
      openingHours: json['opening_hours'] ??
          StoreData._parseBusinessHours(json['business_hours'], 'opening'),
      closingHours: json['closing_hours'] ??
          StoreData._parseBusinessHours(json['business_hours'], 'closing'),
      workingDays: json['working_days'] != null
          ? new List<String>.from(json['working_days'])
          : null,
      totalRating: json['total_rating'],
      totalReview: json['total_review'],
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
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['zip_code'] = this.zipCode;
    data['logo'] = this.logo;
    data['banner'] = this.banner;
    data['website'] = this.website;
    data['status'] = this.status;
    data['opening_hours'] = this.openingHours;
    data['closing_hours'] = this.closingHours;
    data['total_rating'] = this.totalRating;
    data['total_review'] = this.totalReview;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.workingDays != null) {
      data['working_days'] = this.workingDays;
    }
    if (this.translations != null) {
      data['translations'] = jsonEncode(this
          .translations!
          .map((key, value) => MapEntry(key, value.toJson())));
    }
    return data;
  }

  static String? _parseBusinessHours(dynamic businessHours, String type) {
    // Handle business_hours field if it exists
    if (businessHours == null) return null;

    // If it's a string, try to parse it as JSON
    if (businessHours is String) {
      try {
        var parsed = jsonDecode(businessHours);
        if (parsed is Map) {
          return type == 'opening' ? parsed['opening'] : parsed['closing'];
        }
      } catch (e) {
        // If parsing fails, return null
        return null;
      }
    }

    // If it's already a Map
    if (businessHours is Map) {
      return type == 'opening'
          ? businessHours['opening']
          : businessHours['closing'];
    }

    return null;
  }
}
