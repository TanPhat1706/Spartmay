import 'package:flutter/material.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/features/calendar/logic/calendar_provider.dart';
import 'package:spartmay/features/calendar/presentation/pages/calendar_screen.dart';
import 'package:spartmay/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:spartmay/features/stat/logic/stat_provider.dart';
import 'package:spartmay/features/stat/presentation/stat_screen.dart'; // 👇 Nhớ import màn hình Thống kê
import 'package:spartmay/features/transaction/logic/transaction_provider.dart';
import 'package:spartmay/features/transaction/presentation/pages/add_transaction_screen.dart';
import 'package:spartmay/features/user/presentation/profile_screen.dart';
import 'package:spartmay/features/wallet/logic/wallet_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình
  final List<Widget> _screens = [
    const DashboardScreen(), // Index 0: Tổng quan
    const CalendarScreen(),  // Index 1: Lịch
    const StatScreen(),      // Index 2: Thống kê (Đã quay lại)
    const ProfileScreen(),   // Index 3: Tài khoản
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );

    if (mounted) {
      context.read<WalletProvider>().fetchTotalBalance();
      context.read<TransactionProvider>().refreshTransactions();
      context.read<TransactionProvider>().fetchMonthlySummary(); // Cập nhật thẻ Thu/Chi

      final calendarProvider = context.read<CalendarProvider>();
      calendarProvider.fetchMonthlyStats(calendarProvider.focusedDay);
      if (calendarProvider.selectedDay != null) {
        calendarProvider.onDaySelected(calendarProvider.selectedDay!, calendarProvider.focusedDay);
      }

      context.read<StatProvider>().fetchStat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.backgroundLight,
      
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: _openAddTransaction,
          backgroundColor: ColorPalette.primaryGreen,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        height: 70,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabItem(0, Icons.dashboard_outlined, Icons.dashboard, "Tổng quan"),
                  _buildTabItem(1, Icons.calendar_today_outlined, Icons.calendar_today, "Lịch"),
                ],
              ),
            ),

            const SizedBox(width: 48), 

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabItem(2, Icons.insert_chart_outlined, Icons.insert_chart, "Thống kê"),
                  _buildTabItem(3, Icons.person_outline, Icons.person, "Tài khoản"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData iconOutlined, IconData iconFilled, String label) {
    final isSelected = _currentIndex == index;
    
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? iconFilled : iconOutlined,
              color: isSelected ? ColorPalette.primaryGreen : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? ColorPalette.primaryGreen : Colors.grey.shade400,
              ),
            )
          ],
        ),
      ),
    );
  }
}