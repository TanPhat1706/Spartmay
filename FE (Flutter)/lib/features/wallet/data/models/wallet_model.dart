import 'package:flutter/material.dart';

enum WalletType {
  CASH,
  BANK_ACCOUNT,
  CREDIT_CARD,
  E_WALLET,
  OTHER
}

extension WalletTypeExtension on WalletType {
  String get displayName {
    switch (this) {
      case WalletType.CASH: return 'Tiền mặt';
      case WalletType.BANK_ACCOUNT: return 'Tài khoản ngân hàng';
      case WalletType.CREDIT_CARD: return 'Thẻ tín dụng';
      case WalletType.E_WALLET: return 'Ví điện tử';
      case WalletType.OTHER: return 'Khác';
    }
  }

  IconData get icon {
    switch (this) {
      case WalletType.CASH: return Icons.money;
      case WalletType.BANK_ACCOUNT: return Icons.account_balance;
      case WalletType.CREDIT_CARD: return Icons.credit_card;
      case WalletType.E_WALLET: return Icons.account_balance_wallet;
      case WalletType.OTHER: return Icons.category;
    }
  }
}

class Wallet {
  final int? id;
  final String name;
  final double balance;
  final WalletType type;
  final bool includeInTotal;

  Wallet({
    this.id,
    required this.name,
    required this.balance,
    required this.type,
    this.includeInTotal = true,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name'],
      balance: (json['balance'] as num).toDouble(),
      type: WalletType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => WalletType.OTHER),
      includeInTotal: json['includeInTotal'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'balance': balance,
      'type': type.toString().split('.').last,
      'includeInTotal': includeInTotal,
    };
  }
}