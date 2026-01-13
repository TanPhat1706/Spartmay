import 'package:flutter/material.dart';

class CategoryStat {
  final String categoryName;
  final String icon;
  final double amount;
  final Color color;
  final String colorHex;

  CategoryStat({
    required this.categoryName,
    required this.icon,
    required this.amount,
    required this.color,
    required this.colorHex,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    String hexColor = json['colorHex'] ?? '#808080'; // Mặc định màu xám nếu null
    return CategoryStat(
      categoryName: json['categoryName'] ?? 'Khác',
      icon: json['icon'] ?? 'category',
      amount: (json['amount'] as num).toDouble(),
      colorHex: hexColor,
      color: _hexToColor(hexColor), // Tự động convert khi parse
    );
  }

  // Helper chuyển chuỗi Hex (#FF5733) thành Color(0xFFFF5733)
  static Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff'); // Thêm Alpha (Opactity) 100%
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey; // Fallback nếu mã màu lỗi
    }
  }
}