import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final String countText;
  final String imageUrl;
  final Color bgCircleLight;
  final Color bgCircleDark;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    this.countText = '',
    this.imageUrl = '',
    this.bgCircleLight = const Color(0xFFE8F1FD),
    this.bgCircleDark = const Color(0xFF16253B),
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'iconCode': icon.codePoint,
      'countText': countText,
      'imageUrl': imageUrl,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    IconData resolvedIcon = Icons.category_rounded;
    final iconVal = json['iconCode'] ?? json['icon'];
    if (iconVal is int) {
      resolvedIcon = IconData(iconVal, fontFamily: 'MaterialIcons');
    } else if (iconVal is String) {
      switch (iconVal.toLowerCase()) {
        case 'medical_services':
        case 'medical':
        case 'doctor':
        case 'doctors':
          resolvedIcon = Icons.medical_services_rounded;
          break;
        case 'gavel':
        case 'advocate':
        case 'advocates':
        case 'lawyer':
          resolvedIcon = Icons.gavel_rounded;
          break;
        case 'restaurant':
        case 'food':
        case 'cafe':
          resolvedIcon = Icons.restaurant_rounded;
          break;
        case 'fitness_center':
        case 'gym':
        case 'fitness':
          resolvedIcon = Icons.fitness_center_rounded;
          break;
        case 'computer':
        case 'technology':
        case 'tech':
          resolvedIcon = Icons.computer_rounded;
          break;
        case 'school':
        case 'education':
          resolvedIcon = Icons.school_rounded;
          break;
        case 'account_balance':
        case 'finance':
        case 'bank':
          resolvedIcon = Icons.account_balance_rounded;
          break;
        case 'home_repair_service':
        case 'services':
          resolvedIcon = Icons.home_repair_service_rounded;
          break;
        case 'local_hospital':
          resolvedIcon = Icons.local_hospital_rounded;
          break;
        default:
          resolvedIcon = Icons.category_rounded;
      }
    }

    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      icon: resolvedIcon,
      countText: json['countText']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}
