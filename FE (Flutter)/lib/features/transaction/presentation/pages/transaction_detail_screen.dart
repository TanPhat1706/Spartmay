import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/core/utils/icon_utils.dart';
import 'package:spartmay/features/transaction/data/models/transaction_model.dart'; // Import entity Transaction chuẩn
import 'package:spartmay/features/transaction/logic/transaction_provider.dart'; // Import Provider
import 'package:spartmay/features/transaction/presentation/pages/add_transaction_screen.dart';
import 'package:spartmay/features/wallet/logic/wallet_provider.dart'; // Import màn hình thêm/sửa

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late Transaction _currentTransaction;

  @override
  void initState() {
    super.initState();
    _currentTransaction = widget.transaction;
  }

  // Hàm format tiền
  String formatCurrency(double amount) {
    final formatter = NumberFormat("#,###");
    return "${formatter.format(amount)} đ";
  }

  // Xử lý Xóa
  void _handleDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa giao dịch này? Số dư ví sẽ được hoàn lại."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Đóng dialog
              final walletProvider = context.read<WalletProvider>();
              
              // Gọi Provider xóa
              final success = await context.read<TransactionProvider>()
                  .deleteTransaction(_currentTransaction.id, walletProvider);

              if (!mounted) return;

              if (success) {
                Navigator.pop(context); // Đóng màn hình Detail về màn hình trước
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã xóa giao dịch"), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Lỗi khi xóa giao dịch"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Xử lý Sửa
  void _handleEdit() async {
    // Điều hướng sang màn hình AddTransactionScreen nhưng ở chế độ Edit
    // Em cần sửa AddTransactionScreen để nhận tham số optional 'transaction'
    final updatedTransaction = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transactionToEdit: _currentTransaction),
      ),
    );

    // Nếu sửa thành công và có dữ liệu trả về
    if (updatedTransaction != null && updatedTransaction is Transaction) {
      setState(() {
        _currentTransaction = updatedTransaction;
      });
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Cập nhật thành công"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _currentTransaction.category.type == TransactionType.INCOME;
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';

    return Scaffold(
      backgroundColor: ColorPalette.backgroundLight, // Màu nền xám nhẹ
      appBar: AppBar(
        title: const Text("Chi tiết giao dịch", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: ColorPalette.primaryGreen),
            onPressed: _handleEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // 1. Phần hiển thị số tiền to đẹp
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconUtils.getIconByName(_currentTransaction.category.icon),
                      size: 40,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentTransaction.category.name,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$sign${formatCurrency(_currentTransaction.amount.abs())}", // Dùng abs() để tránh hiện --
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // 2. Card thông tin chi tiết
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.calendar_today, "Thời gian", 
                    DateFormat('dd/MM/yyyy - HH:mm').format(_currentTransaction.date)),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  
                  _buildDetailRow(Icons.account_balance_wallet, "Ví nguồn", 
                    _currentTransaction.wallet.name), // Giả sử Wallet có field name
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  
                  _buildDetailRow(Icons.description, "Ghi chú", 
                    _currentTransaction.note.isEmpty ? "Không có ghi chú" : _currentTransaction.note),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}