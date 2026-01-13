import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/features/wallet/data/models/wallet_model.dart';

class WalletItem extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const WalletItem({
    super.key,
    required this.wallet,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(wallet.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Xác nhận xóa"),
            content: Text("Bạn có chắc muốn xóa ví '${wallet.name}' không?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: ColorPalette.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(wallet.type.icon, color: ColorPalette.primaryGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(wallet.type.displayName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${NumberFormat("#,###").format(wallet.balance)} đ",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ColorPalette.primaryGreen),
                  ),
                  if (!wallet.includeInTotal)
                    const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.visibility_off, size: 14, color: Colors.grey))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}