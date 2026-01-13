import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spartmay/features/transaction/presentation/pages/transaction_detail_screen.dart';
import 'package:spartmay/features/transaction/presentation/widgets/transaction_item.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/features/calendar/logic/calendar_provider.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CalendarProvider>();
      // Load thống kê tháng hiện tại
      provider.fetchMonthlyStats(DateTime.now());
      // Load luôn list giao dịch của ngày hôm nay
      provider.onDaySelected(DateTime.now(), DateTime.now());
    });
  }

  // Helper format số tiền nhỏ gọn (200k, 1.5M) để vừa ô lịch
  String formatCompactCurrency(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}k";
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.backgroundLight,
      appBar: AppBar(
        title: const Text("Lịch tài chính", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: ColorPalette.primaryGreen,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<CalendarProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildMonthSummary(provider),
              const SizedBox(height: 10),
              _buildCalendar(provider),
              const SizedBox(height: 10),
              _buildDailySummaryHeader(provider),
              Expanded(
                child: _buildTransactionList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar(CalendarProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 10),
      child: TableCalendar(
        locale: 'vi_VN', // Nhớ setup localization trong main.dart nếu cần tiếng Việt
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: provider.focusedDay,
        selectedDayPredicate: (day) => isSameDay(provider.selectedDay, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 60,
        
        // Style cơ bản
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        
        // Logic chọn ngày và đổi tháng
        onDaySelected: provider.onDaySelected,
        onPageChanged: provider.onPageChanged,

        // --- Custom vẽ ô ngày ---
        calendarBuilders: CalendarBuilders(
          // Vẽ ô ngày mặc định
          defaultBuilder: (context, day, focusedDay) {
            return _buildCustomDayCell(context, day, provider, isSelected: false);
          },
          // Vẽ ô ngày đang chọn
          selectedBuilder: (context, day, focusedDay) {
            return _buildCustomDayCell(context, day, provider, isSelected: true);
          },
          // Vẽ ô ngày hôm nay
          todayBuilder: (context, day, focusedDay) {
            return _buildCustomDayCell(context, day, provider, isToday: true);
          },
        ),
      ),
    );
  }

  Widget _buildMonthSummary(CalendarProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade100, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem("Tổng thu", provider.monthlyIncome, Colors.green),
          Container(width: 1, height: 40, color: Colors.grey.shade200), // Dòng kẻ dọc
          _buildSummaryItem("Tổng chi", provider.monthlyExpense, Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: ColorPalette.textGrey)),
        const SizedBox(height: 4),
        Text(
          // Format tiền tệ
          NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount),
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: color
          ),
        ),
      ],
    );
  }

  // Widget custom cho từng ô ngày
  Widget _buildCustomDayCell(BuildContext context, DateTime day, CalendarProvider provider,
      {bool isSelected = false, bool isToday = false}) {
    
    final stat = provider.getStatForDay(day);
    
    // Màu nền khi chọn
    Color bgColor = Colors.transparent;
    if (isSelected) bgColor = ColorPalette.primaryGreen.withOpacity(0.2);
    if (isToday && !isSelected) bgColor = Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: ColorPalette.primaryGreen, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Số ngày (1, 2, 3...)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                color: isToday ? ColorPalette.primaryGreen : Colors.black87,
              ),
            ),
          ),
          const Spacer(),
          // Hiển thị chấm thu (Xanh)
          if (stat != null && stat.income > 0)
            Text(
              "+${formatCompactCurrency(stat.income)}",
              style: const TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
            
          // --- HIỂN THỊ CHI (ĐỎ) ---
          // SỬA 1: Kiểm tra nhỏ hơn 0 (vì expense là số âm) hoặc khác 0
          if (stat != null && stat.expense < 0) 
             Text(
              // SỬA 2: Dùng .abs() để lấy trị tuyệt đối (bỏ dấu trừ có sẵn)
              // Kết quả sẽ là "-18k" thay vì "--18k"
              "-${formatCompactCurrency(stat.expense.abs())}", 
              style: const TextStyle(fontSize: 8, color: Colors.red, fontWeight: FontWeight.bold),
               maxLines: 1,
            ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildDailySummaryHeader(CalendarProvider provider) {
    if (provider.selectedDay == null) return const SizedBox();
    
    final stat = provider.getStatForDay(provider.selectedDay!);
    final dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              dateFormatter.format(provider.selectedDay!),
              style: const TextStyle(fontWeight: FontWeight.bold, color: ColorPalette.textGrey),
            ),
          ),
          if (stat != null) ...[
             // Tổng kết nhanh của ngày đó
             if (stat.income > 0)
                Text("+${NumberFormat("#,###").format(stat.income.abs())}", style: const TextStyle(color: Colors.green)),
             const SizedBox(width: 8),
             if (stat.expense < 0)
                Text("-${NumberFormat("#,###").format(stat.expense.abs())}", style: const TextStyle(color: Colors.red)),
          ] else 
             const Text("Không có dữ liệu", style: TextStyle(fontSize: 12, color: Colors.grey))
        ],
      ),
    );
  }

  Widget _buildTransactionList(CalendarProvider provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    
    if (provider.selectedDayTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            const Text("Chưa có giao dịch nào", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder( // Dùng builder thay vì separated vì TransactionItem đã có margin bottom
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: provider.selectedDayTransactions.length,
      itemBuilder: (context, index) {
        final tx = provider.selectedDayTransactions[index];
        
        // ✅ Tái sử dụng TransactionItem
        return TransactionItem(
          transaction: tx,
          // Override hành động Tap để reload lịch khi quay lại
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TransactionDetailScreen(transaction: tx)),
            );

            // Khi quay lại (User có thể đã Sửa/Xóa), cần reload data:
            if (context.mounted) {
               // 1. Reload list giao dịch ngày hôm đó
               if (provider.selectedDay != null) {
                 provider.onDaySelected(provider.selectedDay!, provider.focusedDay);
               }
               // 2. Reload chấm màu trên lịch (để cập nhật tổng tiền ngày)
               provider.fetchMonthlyStats(provider.focusedDay);
            }
          },
        );
      },
    );
  }
}