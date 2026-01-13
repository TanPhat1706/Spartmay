import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/features/wallet/data/models/wallet_model.dart';
import 'package:spartmay/features/wallet/logic/wallet_provider.dart';
// Import Page và Widget mới
import 'package:spartmay/features/wallet/presentation/pages/add_edit_wallet_page.dart';
import 'package:spartmay/features/wallet/presentation/widgets/wallet_item.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Chỉ fetch nếu list rỗng để tránh spam API
      final provider = context.read<WalletProvider>();
      if (provider.wallets.isEmpty) {
        provider.fetchWallets();
      }
    });
  }

  // Hàm chuyển trang thống nhất cho cả Thêm và Sửa
  void _navigateToForm({Wallet? wallet}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditWalletPage(wallet: wallet),
      ),
    );

    // Nếu thao tác thành công (result == true), hiện thông báo
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wallet == null ? "Tạo ví mới thành công!" : "Cập nhật ví thành công!"),
          backgroundColor: Colors.green,
        ),
      );
      // Provider đã tự notifyListeners() nên UI tự cập nhật, không cần gọi fetch lại
    }
  }

  void _deleteWallet(int id) async {
    final success = await context.read<WalletProvider>().deleteWallet(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa ví thành công")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.backgroundLight,
      appBar: AppBar(
        title: const Text("Quản lý ví", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: ColorPalette.primaryGreen));
          
          if (provider.wallets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("Chưa có ví nào, hãy thêm mới!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.wallets.length,
            itemBuilder: (context, index) {
              final wallet = provider.wallets[index];
              return WalletItem(
                wallet: wallet,
                onTap: () => _navigateToForm(wallet: wallet), // Bấm vào để Sửa
                onDelete: () => _deleteWallet(wallet.id!),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorPalette.primaryGreen,
        onPressed: () => _navigateToForm(), // Bấm vào để Thêm mới (không truyền wallet)
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}