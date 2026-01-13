import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import để logout
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/core/utils/dialog_utils.dart';
import 'package:spartmay/features/auth/presentation/pages/login_screen.dart'; // Import màn hình Login
// Import các Provider
import 'package:spartmay/features/transaction/logic/transaction_provider.dart';
import 'package:spartmay/features/wallet/logic/wallet_provider.dart';
import 'package:spartmay/features/user/logic/user_provider.dart'; // Import UserProvider
// Import các màn hình con
import 'package:spartmay/features/transaction/presentation/pages/transaction_history_screen.dart';
import 'package:spartmay/features/wallet/presentation/pages/wallet_screen.dart';
import 'package:spartmay/features/category/presentation/pages/category_screen.dart';
import 'package:spartmay/features/transaction/presentation/widgets/transaction_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // Hàm tải dữ liệu tổng hợp
  Future<void> _loadData() async {
    final walletProvider = context.read<WalletProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final userProvider = context.read<UserProvider>(); // Lấy UserProvider

    // Gọi song song 4 việc: Ví, Giao dịch, Thống kê, Thông tin User
    await Future.wait([
      walletProvider.fetchTotalBalance(),
      transactionProvider.refreshTransactions(),
      transactionProvider.fetchMonthlySummary(),
      userProvider.loadUser(), // Load tên người dùng
    ]);
  }

  // Hàm xử lý đăng xuất
  void _handleLogout() async {
    // 1. Xóa token
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');

    // 2. Chuyển về màn hình Login
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat("#,###");
    return "${formatter.format(amount)} đ";
  }

  @override
  Widget build(BuildContext context) {
    // 👇 SỬA: Dùng Consumer3 để lắng nghe thêm UserProvider
    return Consumer3<WalletProvider, TransactionProvider, UserProvider>(
      builder: (context, walletProvider, txProvider, userProvider, child) {
        
        final bool isFirstLoad = walletProvider.isLoading || (txProvider.isLoading && txProvider.transactions.isEmpty);

        if (isFirstLoad) {
        return const Center(child: CircularProgressIndicator(color: ColorPalette.primaryGreen));
      }

        final totalBalance = walletProvider.totalBalance;
        final income = txProvider.monthlySummary?.totalIncome ?? 0;
        final expense = txProvider.monthlySummary?.totalExpense ?? 0;
        final recentTransactions = txProvider.transactions.take(5).toList();
        
        // Lấy tên User (nếu chưa load xong thì hiện "Bạn")
        final userName = userProvider.user?.fullName ?? "Bạn";

        return RefreshIndicator(
          onRefresh: _loadData,
          color: ColorPalette.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // Khoảng cách top an toàn
                
                // 👇 1. HEADER (Xin chào + Logout)
                _buildHeader(userName),
                
                const SizedBox(height: 24),

                // 2. Card Tổng quan
                _buildTotalBalanceCard(totalBalance, income, expense),
                
                const SizedBox(height: 24),
                
                // 3. Menu Chức năng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionItem(Icons.account_balance_wallet, "Ví của tôi", 
                      () => _navigateAndRefresh(context, const WalletScreen())
                    ),
                    _buildActionItem(Icons.pie_chart, "Danh mục", 
                      () => _navigateAndRefresh(context, const CategoryScreen())
                    ),
                    _buildActionItem(Icons.savings, "Tiết kiệm", () {
                      DialogUtils.showComingSoon(context);
                    }),
                    _buildActionItem(Icons.more_horiz, "Khác", () {
                      DialogUtils.showComingSoon(context);
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // 4. Header "Giao dịch gần đây"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Giao dịch gần đây",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorPalette.textDark),
                    ),
                    TextButton(
                      onPressed: () => _navigateAndRefresh(context, const TransactionHistoryScreen()),
                      child: const Text("Xem tất cả", style: TextStyle(color: ColorPalette.primaryGreen)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 5. Danh sách giao dịch
                if (recentTransactions.isEmpty) 
                   const Center(
                     child: Padding(
                       padding: EdgeInsets.symmetric(vertical: 30),
                       child: Text("Chưa có giao dịch nào", style: TextStyle(color: Colors.grey)),
                     )
                   )
                else
                   ...recentTransactions.map((tx) => TransactionItem(transaction: tx)),

                const SizedBox(height: 80), 
              ],
            ),
          ),
        );
      },
    );
  }

  // 👇 Widget Header Mới
  Widget _buildHeader(String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Xin chào,",
              style: TextStyle(fontSize: 14, color: ColorPalette.textGrey),
            ),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: ColorPalette.textDark
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Nút thông báo (Tĩnh)
            Container(
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.amber),
                onPressed: () {
                  DialogUtils.showComingSoon(context);
                }, // Chưa có chức năng
              ),
            ),
            const SizedBox(width: 12),
            // Nút Đăng xuất
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: _handleLogout,
              ),
            ),
          ],
        )
      ],
    );
  }
  
  // Hàm điều hướng và refresh data khi quay lại
  Future<void> _navigateAndRefresh(BuildContext context, Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (context.mounted) {
      _loadData();
    }
  }

  // ... (Giữ nguyên các widget _buildTotalBalanceCard, _buildMiniStat, _buildActionItem cũ của em)
  Widget _buildTotalBalanceCard(double balance, double income, double expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorPalette.primaryGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryGreen.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tổng số dư", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            formatCurrency(balance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMiniStat(Icons.arrow_upward, "Thu: ${formatCurrency(income)}"),
              const SizedBox(width: 12),
              _buildMiniStat(Icons.arrow_downward, "Chi: ${formatCurrency(expense)}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Icon(icon, color: ColorPalette.primaryGreen),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: ColorPalette.textGrey)),
        ],
      ),
    );
  }
}