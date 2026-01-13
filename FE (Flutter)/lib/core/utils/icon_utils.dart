import 'package:flutter/material.dart';

class IconUtils {
  IconUtils._();

  static IconData getIconByName(String iconName) {
    switch (iconName) {
      case 'fastfood': return Icons.fastfood;
      case 'motorcycle': return Icons.motorcycle;
      case 'coffee': return Icons.coffee;
      case 'attach_money': return Icons.attach_money;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'home': return Icons.home;
      case 'medical_services': return Icons.medical_services;
      case 'school': return Icons.school;
      case 'balance': return Icons.balance;
      case 'account_balance': return Icons.account_balance;
      case 'work': return Icons.work;
      case 'savings': return Icons.savings;
      default: return Icons.category;
    }
  }
}