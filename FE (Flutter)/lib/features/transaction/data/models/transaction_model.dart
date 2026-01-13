import 'package:spartmay/features/wallet/data/models/wallet_model.dart';

enum TransactionType { INCOME, EXPENSE }

class Category {
  final int id;
  final String name;
  final String icon;
  final TransactionType type;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      type: json['type'] == 'INCOME' ? TransactionType.INCOME : TransactionType.EXPENSE,
    );
  }
}

class Transaction {
  final int id;
  final double amount;
  final String note;
  final Category category;
  final Wallet wallet;
  final DateTime date;

  Transaction({
    required this.id,
    required this.amount,
    required this.note,
    required this.category,
    required this.wallet,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      note: json['note'],
      category: Category.fromJson(json['category']),
      wallet: Wallet.fromJson(json['wallet']),
      date: DateTime.parse(json['date']),
    );
  }
}

class TransactionRequest {
  final double amount;
  final String note;
  final int categoryId;
  final int walletId;
  final DateTime date;

  TransactionRequest({
    required this.amount,
    required this.note,
    required this.categoryId,
    required this.walletId,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'note': note,
      'categoryId': categoryId,
      'walletId': walletId,
      'date': date.toIso8601String(),
    };
  }
}

class PaginatedTransactionResponse {
  final List<Transaction> content;
  final bool last;
  final int totalPages;
  final int totalElements;

  PaginatedTransactionResponse({
    required this.content,
    required this.last,
    required this.totalPages,
    required this.totalElements,
  });

  factory PaginatedTransactionResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedTransactionResponse(
      content: (json['content'] as List).map((e) => Transaction.fromJson(e)).toList(),
      last: json['last'] ?? true,
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
    );
  }
}

class DailyStat {
  final DateTime date;
  final double income;
  final double expense;

  DailyStat({
    required this.date,
    required this.income,
    required this.expense,
  });

  factory DailyStat.fromJson(Map<String, dynamic> json) {
    return DailyStat(
      date: DateTime.parse(json['date']),
      income: (json['income'] as num).toDouble(),
      expense: (json['expense'] as num).toDouble(),
    );
  }
}

class MonthlySummaryResponse {
  final double totalIncome;
  final double totalExpense;
  final List<DailyStat> dailyStats;

  MonthlySummaryResponse({
    required this.totalIncome,
    required this.totalExpense,
    required this.dailyStats,
  });

  factory MonthlySummaryResponse.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryResponse(
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpense: (json['totalExpense'] as num).toDouble(),
      dailyStats: (json['dailyStats'] as List)
          .map((e) => DailyStat.fromJson(e))
          .toList(),
    );
  }
}