import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/core/utils/icon_utils.dart';
// Import Entity Transaction chuẩn của em
import 'package:spartmay/features/transaction/data/models/transaction_model.dart';
import 'package:spartmay/features/transaction/presentation/pages/transaction_detail_screen.dart'; 
// Import màn hình chi tiết để xử lý sự kiện Tap

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap; // Cho phép override hành động click nếu cần

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Logic xác định màu sắc và dấu +/-
    final isIncome = transaction.category.type == TransactionType.INCOME;
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';

    return GestureDetector(
      // Mặc định click vào sẽ mở màn hình chi tiết
      onTap: onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(transaction: transaction),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
             BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
             ),
          ],
        ),
        child: Row(
          children: [
            // 1. Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconUtils.getIconByName(transaction.category.icon), // Hàm helper lấy icon
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // 2. Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category.name, // Hiển thị tên danh mục làm title chính
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (transaction.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.note,
                      style: const TextStyle(color: ColorPalette.textGrey, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(transaction.date), // Format ngày chuẩn
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),

            // 3. Amount
            Text(
              "$sign${NumberFormat("#,###").format(transaction.amount.abs())} đ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}